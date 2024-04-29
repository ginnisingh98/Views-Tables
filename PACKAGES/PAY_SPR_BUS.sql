--------------------------------------------------------
--  DDL for Package PAY_SPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SPR_BUS" AUTHID CURRENT_USER as
/* $Header: pysprrhi.pkh 120.0 2005/05/29 08:54:16 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_security_profile_id
--    p_payroll_id
--     already exists.
--
--  In Arguments:
--    p_security_profile_id
--    p_payroll_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_security_profile_id                  in number
  ,p_payroll_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
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
--    The primary key identified by p_security_profile_id
--    p_payroll_id
--     already exists.
--
--  In Arguments:
--    p_security_profile_id
--    p_payroll_id
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
  (p_security_profile_id                  in     number
  ,p_payroll_id                           in     number
  ) RETURN varchar2;
--
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
  (p_effective_date               in date
  ,p_rec                          in pay_spr_shd.g_rec_type
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
  (p_rec              in pay_spr_shd.g_rec_type
  );
--
-- --------------------------------------------------------------------------
-- |----------------------------<chk_payroll_id>----------------------------|
-- --------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--  This procedure Validates that the payroll_id  passed exists and
--  belongs to the same business group as the security_profile_id.
--
-- In Parameters:
--   security_profile_id
--   payroll_id
--
-- Post Success:
--   Processing continues if the  business_group_id is valid
--
-- Post Failure:
--   An appplication error is raised if  business_group_id was not
--   returned meaning either the payroll_id or security_profile_id is
--   invalid
--
-- Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
------------------------------------------------------------------------------
procedure chk_payroll_id
  (p_payroll_id           in  	     pay_all_payrolls_f.payroll_id%type
  ,p_security_profile_id  in  	     pay_security_payrolls.security_profile_id%type
  ,p_business_group_id    out nocopy pay_all_payrolls_f.business_group_id%type
   );
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_security_profile>-------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--  This procedure Validates that the security_profile passed exists or is
--  global
--
-- In Parameters:
--   security_profile_id
--
-- Post Success:
--   Processing continues if the  business_group_id is valid
--
-- Post Failure:
--   An appplication error is raised if  business_group_id is invalid
--   or global
--
-- Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
------------------------------------------------------------------------------
procedure chk_security_profile
   (p_security_profile_id    in  	per_security_profiles.security_profile_id%type
   ,p_business_group_id      out nocopy per_security_profiles.business_group_id%type
    );
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_for_duplicate>----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--  This procedure validates that the security payroll is unique for this
--  security profile.
--
-- In Parameters:
--   security_profile_id
--   payroll_id
--
-- Post Success:
--   Processing continues without error.
--
-- Post Failure:
--   An appplication error is raised if a duplicate security payroll is
--   found.
--
-- Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
--
PROCEDURE chk_for_duplicate
  (p_security_profile_id IN NUMBER
  ,p_payroll_id          IN NUMBER);
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_view_all_payrolls_flag>-------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--  This procedure validates that the security profile's view all payrolls
--  flag is set to No (payroll restrictions can be added).
--
-- In Parameters:
--   security_profile_id
--
-- Post Success:
--   Processing continues without error.
--
-- Post Failure:
--   An appplication error is raised if the view all payrolls flag is not
--   No.
--
-- Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
--
PROCEDURE chk_view_all_payrolls_flag
  (p_security_profile_id IN NUMBER);
--
-- --------------------------------------------------------------------------
-- |-------------------------<set_view_all_payrolls_flag>-------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--  This procedure will update the security profile's view all payrolls flag
--  to Yes after the last security payroll has been deleted.
--
-- In Parameters:
--   security_profile_id
--
-- Post Success:
--   The security profile is updated and processing continues without error.
--
-- Post Failure:
--   An unexpected error would have occured.  This will be raised and will
--   cause a rollback.
--
-- Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
--
PROCEDURE set_view_all_payrolls_flag
  (p_security_profile_id IN NUMBER);
--
end pay_spr_bus;

 

/

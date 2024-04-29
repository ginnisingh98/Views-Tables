--------------------------------------------------------
--  DDL for Package PQH_REI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REI_BUS" AUTHID CURRENT_USER as
/* $Header: pqreirhi.pkh 120.0 2005/05/29 02:27:10 appldev noship $ */
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
--    The primary key identified by p_role_extra_info_id
--     already exists.
--
--  In Arguments:
--    p_role_extra_info_id
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
  (p_role_extra_info_id                   in number
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
--    The primary key identified by p_role_extra_info_id
--     already exists.
--
--  In Arguments:
--    p_role_extra_info_id
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
  (p_role_extra_info_id                   in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_role_info_type >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the role information type exists in table
--   pqh_role_info_types where active_inactive_flag is 'Y'.
--
-- Pre Conditions:
--   Data must be existed in table pqh_role_info_types.
--
-- In Parameters:
--   p_information_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_role_info_type
  (
   p_information_type   in    pqh_role_info_types.information_type%type
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_role_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in role_ID is in the pqh_roles table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_role_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_role_id
  (
   p_role_id        in      pqh_role_extra_info.role_id%type
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_multiple_occurences_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the number of rows should not exceed one when
--   multiple_occurences_flag = 'N'.
--
-- Pre Conditions:
--   This procedure should execute after procedure chk_information_type.
--
-- In Parameters:
--   p_information_type
--   p_role_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_occurences_flag
  (p_information_type   in pqh_role_extra_info.information_type%type
  ,p_role_id            in pqh_role_extra_info.role_id%type
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the non updateable arguments not changed.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args (p_rec in pqh_rei_shd.g_rec_type);
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
  (p_rec                          in pqh_rei_shd.g_rec_type
  );
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqh_rei_shd.g_rec_type
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
  (p_rec              in pqh_rei_shd.g_rec_type
  );
--
end pqh_rei_bus;

 

/

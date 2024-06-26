--------------------------------------------------------
--  DDL for Package HXC_TAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TAT_BUS" AUTHID CURRENT_USER as
/* $Header: hxtatrhi.pkh 120.0.12010000.2 2008/08/05 12:11:28 ubhat ship $ */
-- -------------------------------------------------------------------------
-- |----------------------< set_security_group_id >------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_time_attribute_id
--     already exists.
--
--  In Arguments:
--    p_time_attribute_id
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
-- -------------------------------------------------------------------------
procedure set_security_group_id
  (p_time_attribute_id in number
  );

-- -------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-----------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_time_attribute_id
--     already exists.
--
--  In Arguments:
--    p_time_attribute_id
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
-- -------------------------------------------------------------------------
function return_legislation_code
  (p_time_attribute_id in number
  ) return varchar2;

-- --------------------------------------------------------------------------
-- |---------------------------< insert_validate >--------------------------|
-- --------------------------------------------------------------------------
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- --------------------------------------------------------------------------
procedure insert_validate
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  );

-- --------------------------------------------------------------------------
-- |---------------------------< update_validate >--------------------------|
-- --------------------------------------------------------------------------
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
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- --------------------------------------------------------------------------
procedure update_validate
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  );

-- --------------------------------------------------------------------------
-- |---------------------------< delete_validate >--------------------------|
-- --------------------------------------------------------------------------
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- --------------------------------------------------------------------------
procedure delete_validate
  (p_rec in hxc_tat_shd.g_rec_type
  );

end hxc_tat_bus;

/

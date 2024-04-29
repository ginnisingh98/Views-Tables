--------------------------------------------------------
--  DDL for Package PER_POS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_BUS" AUTHID CURRENT_USER as
/* $Header: peposrhi.pkh 120.0 2005/05/31 14:54:04 appldev noship $ */
--
-- ---------------------------------------------------------------------------+
-- |------------------------< set_security_group_id >-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
-- Set the security_group_id in CLIENT_INFO for the position's business
-- group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   position_id                    Yes  Number   position_id to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--  The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the position_id does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ---------------------------------------------------------------------------+
procedure set_security_group_id
  (
   p_position_id               in per_positions.position_id%TYPE
  );
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
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
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in per_pos_shd.g_rec_type);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
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
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in per_pos_shd.g_rec_type);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
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
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in per_pos_shd.g_rec_type);
--
--
--  --------------------------------------------------------------------------+
--  |---------------------< return_legislation_code >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Return the legislation code for a specific position
--
--  Prerequisites:
--    The position identified by p_position_id already exists.
--
--  In Arguments:
--    p_position_id
--
--  Post Success:
--    If the position is found this function will return the position's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the position does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_position_id              in number
  ) return varchar2;
--
end per_pos_bus;

 

/

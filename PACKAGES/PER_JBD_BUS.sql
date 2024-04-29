--------------------------------------------------------
--  DDL for Package PER_JBD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBD_BUS" AUTHID CURRENT_USER as
/* $Header: pejbdrhi.pkh 115.0 99/07/18 13:54:50 porting ship $ */
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
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_jbd_shd.g_rec_type);
--
end per_jbd_bus;

 

/

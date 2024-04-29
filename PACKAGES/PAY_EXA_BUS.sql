--------------------------------------------------------
--  DDL for Package PAY_EXA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EXA_BUS" AUTHID CURRENT_USER AS
/* $Header: pyexarhi.pkh 115.5 2002/12/10 18:44:35 dsaxby ship $ */
-- [start of change: 40.1, Dave Harris]
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_territory_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the attribute territory_code.
--   If inserting then we must ensure that the territory_code is valid.
--   If updating then we must ensure that the territory_code has not changed
--   (we still require this check because the record upd interface could
--   still set the territory_code to a value).
--
-- Pre Conditions:
--
-- In Arguments:
--
-- Post Success:
--   The process will successfully exit.
--
-- Post Failure:
--   1) If the territory_code is invalid then an application error will be
--      raised.
--   2) If the territory_code is being updated then an application error will
--      be raise.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_territory_code(
   p_territory_code        in varchar2
  ,p_external_account_id   in number
  ,p_object_version_number in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rule
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
procedure insert_validate(
   p_rec               in pay_exa_shd.g_rec_type
  ,p_business_group_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rule
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
-- ----------------------------------------------------------------------------
procedure update_validate(
   p_rec in pay_exa_shd.g_rec_type
   );
--
END pay_exa_bus;

 

/

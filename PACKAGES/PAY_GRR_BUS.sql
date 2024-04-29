--------------------------------------------------------
--  DDL for Package PAY_GRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GRR_BUS" AUTHID CURRENT_USER as
/* $Header: pygrrrhi.pkh 115.3 2002/12/10 09:48:11 pkakar ship $ */
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific grade rule
--
--  Prerequisites:
--    The grade rule identified by p_grade_rule_id already exists.
--
--  In Arguments:
--    p_grade_rule_id
--
--  Post Success:
--    If the grade_rule is found this function will return the grade rule's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the grade rule does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_grade_rule_id              in number
  ) return varchar2;
--
end pay_grr_bus;

 

/

--------------------------------------------------------
--  DDL for Package PAY_STA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STA_BUS" AUTHID CURRENT_USER as
/* $Header: pystarhi.pkh 120.0.12000000.2 2007/05/01 22:41:10 ahanda noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
g_sta_tax_rule_id  pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE
                   default null;
g_legislation_code   varchar2(150)  default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_emp_state_tax_rule_id already exists.
--
--  In Arguments:
--    p_emp_state_tax_rule_id
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
  (p_emp_state_tax_rule_id in number) return varchar2;
--
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
Procedure insert_validate
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date);
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
Procedure update_validate
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date);
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
Procedure delete_validate
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date,
       p_delete_routine        in varchar2);
--

-- ----------------------------------------------------------------------------
-- chk_ procedures exposed to allow for validation from web self service
--
-- for more information, look at package body for pay_sta_bus (pystarhi.pkb)
--
-- ____________________________________________________________________________
procedure chk_filing_status_code
	(p_emp_state_tax_rule_id in number
	,p_state_code 		 in pay_us_emp_state_tax_rules_f.state_code%TYPE
	,p_filing_status_code    in
		pay_us_emp_state_tax_rules_f.filing_status_code%TYPE
	,p_effective_date	 in date
	,p_validation_start_date in date
	,p_validation_end_date   in date
	);

procedure chk_sit_additional_tax
	(p_emp_state_tax_rule_id in number
	,p_sit_additional_tax	 in
		pay_us_emp_state_tax_rules_f.sit_additional_tax%TYPE
	);
procedure chk_withholding_allowances
	(p_emp_state_tax_rule_id in number
	,p_withholding_allowances in
		pay_us_emp_state_tax_rules_f.withholding_allowances%TYPE
	);

end pay_sta_bus;

 

/

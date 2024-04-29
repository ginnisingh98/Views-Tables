--------------------------------------------------------
--  DDL for Package PER_PEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEA_BUS" AUTHID CURRENT_USER as
/* $Header: pepearhi.pkh 120.0.12010000.2 2008/08/06 09:21:03 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code   varchar2(150) default null;
g_person_analysis_id number        default null;
--
Procedure chk_person_id
       (p_person_id             in per_person_analyses.person_id%TYPE
       ,p_business_group_id     in per_person_analyses.business_group_id%TYPE
       ,p_effective_date	in date
       );
--
-- For web special information types module.
-- Require call to chk_date_from_to, add into header.
--
procedure chk_date_from_to
  (p_person_analysis_id		in	number default null
  ,p_date_from			in	date
  ,p_date_to			in	date
  ,p_object_version_number in number default null);
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			in per_pea_shd.g_rec_type,
 	 p_effective_date	in date);
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
 	(p_rec 			in per_pea_shd.g_rec_type);
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pea_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the legislation code
--
-- Pre Conditions:
--   This private procedure will be called from the user hook procedures.
--
-- In Parameters:
--   the primary key of the table (per_person_analyses)
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the legislation code is not found then it errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_person_analysis_id     in per_person_analyses.person_analysis_id%TYPE
  ) return varchar2;
--
end per_pea_bus;

/

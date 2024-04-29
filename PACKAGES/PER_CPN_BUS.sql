--------------------------------------------------------
--  DDL for Package PER_CPN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPN_BUS" AUTHID CURRENT_USER as
/* $Header: pecpnrhi.pkh 120.0 2005/05/31 07:14:20 appldev noship $ */
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
Procedure insert_validate(p_rec in per_cpn_shd.g_rec_type,
			  p_effective_date in date);
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
Procedure update_validate(p_rec in per_cpn_shd.g_rec_type,
			  p_effective_date in date);
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
Procedure delete_validate(p_rec in per_cpn_shd.g_rec_type);
--
--
-- -----------------------------------------------------------------------------
-- |-------------------------<chk_set_radio_button>---------------------------|
-- -----------------------------------------------------------------------------
-- Description:
--  Checks if the competence has a prficiency rating scale, if yes
--  returns 'PS' (Proficiency Scale exists).
--  Checks if the competence has levels, if yes returns
-- 'CL' (Competence Levels exists)
--  Else it will return 'PS' as default.
--
--  This function is called by the Competence Base View to set the
--  value of a radio group in the form accordingly.
--
--  In Arguments:
--    p_competence_id
--    p_rating_scale_id
--
--  Access Status
--    Internal Table Handler Use Only.
--
Function chk_set_radio_button (p_competence_id	 in number
		     	      ,p_rating_scale_id in number)
Return   varchar2 ;
pragma restrict_references (chk_set_radio_button, WNDS, WNPS);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< return_legislation_code >--------------------------|
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
--   the primary key of the table (per_competences)
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
--
Function return_legislation_code (
         p_competence_id        in   number)
         return  varchar2;
--
--
end per_cpn_bus;

 

/

--------------------------------------------------------
--  DDL for Package HR_QSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSF_BUS" AUTHID CURRENT_USER as
/* $Header: hrqsfrhi.pkh 120.0 2005/05/31 02:27:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_questionnaire_template_id >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Checks that the questionnaire_template_id exists in the
--   HR_QUESTIONNAIRES table.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_questionnaire_template_id
--
-- Post Success:
--   Processing continues if the questionnaire_template_id is valid.
--
-- Post Failure:
--   An application error is raised and processing terminates if the
--   questionnaire_template_id is invalid.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
-- ----------------------------------------------------------------------------
--
Procedure chk_questionnaire_template_id
   (p_questionnaire_template_id
      in hr_quest_fields.questionnaire_template_id%TYPE
   );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_name >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Checks that the name is not null.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_name
--
-- Post Success:
--   If the name is valid, processing continues.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   name is invalid.
--
-- Developer/Implementation notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------
--
Procedure chk_name
  (p_name       in      hr_quest_fields.name%TYPE
  );
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_html_text >----------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Validates that html_text is not null, and that its size is less than
--   27K.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_html_text
--
-- Post Success:
--   Processing continues if the html_text is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   html_text is invalid.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
-- ----------------------------------------------------------------------------
--
Procedure chk_html_text
  (p_html_text  in      hr_quest_fields.html_text%TYPE
  );
--
-- ---------------------------------------------------------------------------
-- |-----------------------------< chk_type >--------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Checks that the TYPE exists in HR_LOOKUPS, where the lookup_type is
--   'QUEST_FIELD_TYPE'.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_type
--   p_effective_date
--
-- Post Success:
--   Processing continues if the type is found to be valid.
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   type is invalid.
--
-- Developer/Implementation Notes:
--  This chk_ procedure should be available from a direct call.
--
-- Access Status:
--   Internal Development Use Only.
--
Procedure chk_type
  (p_type  in hr_quest_fields.type%TYPE
  ,p_effective_date in date
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_sql_required_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Checks that sql_required_flag is not null, and exists in HR_LOOKUPS,
--   where the lookup_code is 'YES_NO'.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_sql_required_flag
--   p_effective_date
--
-- Post Success:
--   Processing continues if the sql_required_flag is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if
--   sql_required_flag is invalid.
--
-- Developer/Implementation Notes:
--   Can be called as a direct call from Forms.
--
-- Access Status:
--   Internal Development Use Only.
--
--
Procedure chk_sql_required_flag
  (p_sql_required_flag   in   hr_quest_fields.sql_required_flag%TYPE
  ,p_effective_date  in   date
  );

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
Procedure insert_validate(p_rec in hr_qsf_shd.g_rec_type,
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
Procedure update_validate(p_rec in hr_qsf_shd.g_rec_type,
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
Procedure delete_validate(p_rec in hr_qsf_shd.g_rec_type);
--
end hr_qsf_bus;

 

/

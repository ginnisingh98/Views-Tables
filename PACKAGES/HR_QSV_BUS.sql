--------------------------------------------------------
--  DDL for Package HR_QSV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSV_BUS" AUTHID CURRENT_USER as
/* $Header: hrqsvrhi.pkh 120.0 2005/05/31 02:31:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_questionnaire_answer_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure validates that questionnaire_answer_id is not null, and
--  that it exists in HR_QUEST_ANSWERS.
--
-- Pre-requisites:
--  None.
--
-- IN Parameters:
--  p_questionnaire_answer_id
--
-- Post Success:
--  Processing cntinues if the questionnaire_answer_id is valid.
--
-- Post Failure:
--  An application error is raised, and processing is terminated if the
--  questionnaire_answer_id is invalid.
--
-- Developer/Implementation Notes:
--  This procedure also populates g_questionnaire_template_id, which is
--  used in a later chk procedure to ensure the field is part of the
--  questionnaire being answered.
--
-- Access Status:
--  Internal Development Use Only
-- ----------------------------------------------------------------------------
procedure chk_questionnaire_answer_id
  (p_questionnaire_answer_id
     in hr_quest_answer_values.questionnaire_answer_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_field_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure validates the field_id, by ensuring that the field_id exists
--  in HR_QUEST_FIELDS.  Also checks that it is unique for the given
--  questionnaire_answer_id, and that the field is part of the questionnaire
--  being answered.
--
-- Pre-requisites:
--  chk_questionnaire_answer_id has been called.
--
-- IN Parameters:
--   p_field_id
--   p_questionnaire_answer_id
--
-- Post Success:
--  Processing continues if the field_id is valid.
--
-- Post Failure:
--  An application error is raised, and processing is terminated if the
--  field_id is invalid.
--
-- Developer/Implementation Notes:
--  Uses the value in g_questionnaire_template_id to determine if the field
--  is part of the questionnaire being answered.  This is populated in the
--  chk_questionnaire_answer_id procedure.
--
-- Access Status:
--  Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_field_id
  (p_field_id   in      hr_quest_answer_values.field_id%TYPE
  ,p_questionnaire_answer_id
    in      hr_quest_answer_values.questionnaire_answer_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete_allowed >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Validates that the row for the given quest_answer_val_id can be deleted,
--  by ensuring that a null value exists for the value field.
--
-- Pre-requisites:
--  None.
--
-- IN Parameters:
--  p_value
--
-- Post Success:
--  Processing continues, and the row is deleted if it is valid to do so.
--
-- Post Failure:
--  An application error is raised, and processing is terminated if it is not
--  appropriate to delete the row.
--
-- Developer/Implementation Notes:
--  p_value is obtained from g_old_rec
--
-- Access Status:
--  Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_delete_allowed
  (p_value in hr_quest_answer_values.value%TYPE
  );
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
Procedure insert_validate(p_rec in hr_qsv_shd.g_rec_type);
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
Procedure update_validate(p_rec in hr_qsv_shd.g_rec_type);
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
Procedure delete_validate(p_rec in hr_qsv_shd.g_rec_type);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< return_legislation_code >------------------------------|
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_quest_answer_val_id in hr_quest_answer_values.quest_answer_val_id%TYPE
  ) return varchar2;
end hr_qsv_bus;
--

 

/

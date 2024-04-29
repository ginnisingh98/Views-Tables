--------------------------------------------------------
--  DDL for Package HR_QSA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSA_BUS" AUTHID CURRENT_USER as
/* $Header: hrqsarhi.pkh 120.0 2005/05/31 02:26:14 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Sets the security_group_id in CLIENT_INFO for the questionnaire_answer business
--   group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_questionnaire_answer_id      Yes  Number   questionaire answer to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the p_questionnaire_answer_id does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_security_group_id(p_questionnaire_answer_id in hr_quest_answers.questionnaire_answer_id%TYPE);
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_type >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the type against HR_LOOKUPS, where the lookup code
--   is QUEST_OBJECT_TYPE.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_type
--   p_effective_date
--
-- Post Success:
--   Processing continues if the type is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   type is invalid.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_type
  (p_type in HR_QUEST_ANSWERS.TYPE%TYPE
  ,p_effective_date in date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_type_object_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that:
--    - when type is APPRAISAL, the type_object_id is valid against
--      PER_APPRAISALS, for the given business group.
--    - when type is PARTICIPANT, the type_object_id is valid against
--      PER_PARTICIPANTS, for the given business_group_id.
--      Also, that the participation is for an appraisal.
--   Further checking is done to ensure the type_object_id is UNIQUE
--   for the given type.
--
-- Pre-Requisites:
--   That the TYPE is valid, and the business_group_id exists.
--
-- IN Parameters:
--   p_type_object_id
--   p_type
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the type_object_id is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   type_object_id is invalid.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_type_object_id
  (p_type_object_id     in HR_QUEST_ANSWERS.type_object_id%TYPE
  ,p_type               in HR_QUEST_ANSWERS.type%TYPE
  ,p_business_group_id  in HR_QUEST_ANSWERS.business_group_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_questionnaire_template_id >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the questionnaire_template_id exists in HR_QUESTIONNAIRES.
--   Also, validates that the questionnaire_template_id is valid against the
--   PER_APPRAISAL_TEMPLATES table, when type = 'APPRAISAL', or valid against
--   the PER_APPRAISALS table when type = 'PARTICIPANT'.
--
-- Pre-requisites:
--   p_type, p_type_object_id and p_business_group_id are all valid.
--
-- IN Parameters:
--   p_questionnaire_template_id
--   p_type
--   p_type_object_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if questionnaire_template_id is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   questionniare_template_id is invalid.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_questionnaire_template_id
  (p_questionnaire_template_id          in
              HR_QUEST_ANSWERS.questionnaire_template_id%TYPE
  ,p_type                               in
        HR_QUEST_ANSWERS.type%TYPE
  ,p_type_object_id                     in
        HR_QUEST_ANSWERS.type_object_id%TYPE
  ,p_business_group_id                  in
        HR_QUEST_ANSWERS.business_group_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_row_delete >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure validates that a row can be deleted, by ensuring that
--   no child rows exist in HR_QUEST_ANSWER_VALUES.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_questionnaire_answer_id
--
-- Post Success:
--   Processing continues, and the row is deleted.
--
-- Post Failure:
--   An application error is raised, and processing terminated if a child row
--   exists, and the row may not be deleted.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_row_delete
  (p_questionnaire_answer_id
    in  hr_quest_answers.questionnaire_answer_id%TYPE
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
Procedure insert_validate(p_rec in hr_qsa_shd.g_rec_type
       ,p_effective_date in date
       );
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
Procedure update_validate(p_rec in hr_qsa_shd.g_rec_type
       ,p_effective_date in date
       );
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
Procedure delete_validate(p_rec in hr_qsa_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |-----------------< return_legislation_code >------------------------------|
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_questionnaire_answer_id in hr_quest_answers.questionnaire_answer_id%TYPE
  ) return varchar2;
--
--
end hr_qsa_bus;

 

/

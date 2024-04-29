--------------------------------------------------------
--  DDL for Package HR_QSN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSN_BUS" AUTHID CURRENT_USER as
/* $Header: hrqsnrhi.pkh 120.1.12010000.3 2008/11/05 10:22:27 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Sets the security_group_id in CLIENT_INFO for the questionnaires business
--   group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_questionnaire_template_id    Yes  Number   questionnaire to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the questionnaire does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_security_group_id
  (p_questionnaire_template_id            in number
  ,p_associated_column1                   in varchar2 default null
  );
--
--
-- --------------------------------------------------------------------------
-- |------------------------< chk_name >------------------------------------|
-- --------------------------------------------------------------------------
--
-- Description:
--      Validates that name is not null, and that it is unique for the
--      given business group id.
--
-- Pre-requisites:
--      The business group id is valid.
--
-- IN Parameters:
--      p_name
--      p_business_group_id
--
-- Post Success:
--      Processing continues if the name is valid.
--
-- Post Failure:
--      An application error is raised and processing is terminated if the
--      name is invalid
--
-- Developer/Implementation Notes:
--      None.
--
-- Access Status:
--      Internal Development Use Only.
--
Procedure chk_name
  (p_name               in      hr_questionnaires.name%TYPE
  ,p_business_group_id  in      hr_questionnaires.name%TYPE
  );
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_text >---------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Validates that text is not null.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_text
--
-- Post Success:
--   Processing continues if the text is valid.
--
-- Post Failure:
--   An application error is raised and processing is terminated if the text
--   is invalid.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
Procedure chk_text
  (p_text               in      hr_questionnaires.text%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_available_flag >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   On insert, this checks that the available flag is 'N'.
--
--   On update, this procedure checks the validity of the available_flag
--   column, against the HR_LOOKUPS table, where the lookup type is YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_available_flag
--   p_effective_date
--   p_questionnaire_template_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   available_flag is invalid.
--
-- Developer Implementation Notes:
--   This procedure should be available from a direct call.
--
-- Access Status:
--   Internal Development Use Only.
--
Procedure chk_available_flag
  (p_available_flag  in hr_questionnaires.available_flag%TYPE
  ,p_effective_date   in date
  ,p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE
  ,p_object_version_number in hr_questionnaires.object_version_number%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_row_delete >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure validates that a row can be deleted, by ensuring that
--   no child rows exist in HR_QUEST_FIELDS.
--
-- Pre-requisites:
--   None.
--
-- IN Parameters:
--   p_questionnaire_template_id
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
  (p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE);
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
--   If a business rule fails the error will not be handled by this procedure
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
Procedure insert_validate(p_rec in hr_qsn_shd.g_rec_type
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
Procedure update_validate(p_rec in hr_qsn_shd.g_rec_type
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
Procedure delete_validate(p_rec in hr_qsn_shd.g_rec_type);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< return_legislation_code >------------------------------|
-- ----------------------------------------------------------------------------
--
Function return_legislation_code
   (p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE
   ) return varchar2;
--
end hr_qsn_bus;

/

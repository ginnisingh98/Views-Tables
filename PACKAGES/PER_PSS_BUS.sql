--------------------------------------------------------
--  DDL for Package PER_PSS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSS_BUS" AUTHID CURRENT_USER as
/* $Header: pepssrhi.pkh 120.0 2005/05/31 15:35:00 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_survey_name_company_code >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that survey_name and
--   survey_company_code:
--     a) Are not null since they are mandatory.
--     b) Form a unique combination.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   object_version_number
--   survey_name
--   survey_company_code.
--
-- Post Success
--   Processing continues if the survey_name and survey_company_code are not
--   null and the combination is valid.
--
-- Post Failure
--   An application error is raised and processing is terminated if the
--   survey_name or survey_company_code are null or combination is invalid.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_name_company_code
(p_salary_survey_id      in number,
 p_object_version_number in number,
 p_survey_name           in per_salary_surveys.survey_name%TYPE,
 p_survey_company_code   in per_salary_surveys.survey_company_code%TYPE);

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
Procedure insert_validate(p_rec in per_pss_shd.g_rec_type,
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
Procedure update_validate(p_rec            in per_pss_shd.g_rec_type,
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
Procedure delete_validate(p_rec in per_pss_shd.g_rec_type);
--
end per_pss_bus;

 

/

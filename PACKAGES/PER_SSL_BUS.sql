--------------------------------------------------------
--  DDL for Package PER_SSL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSL_BUS" AUTHID CURRENT_USER as
/* $Header: pesslrhi.pkh 120.0.12010000.1 2008/07/28 06:01:26 appldev ship $ */

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_job_name_code,
--   survey_region_code, survey_seniority_code, company_size_code,
--   industry_code, survey_age_code form a unique combination with
--   the start_date for this row, between the start_date and
--   end_date of any other row.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   survey_job_name_code
--   survey_region_code
--   survey_seniority_code
--   company_size_code
--   industry_code
--   survey_age_code
--   start_date.
--
-- Post Success
--   Processing continues If the survey_job_name_code, survey_region_code,
--   survey_seniority_code, company_size_code, industry_code survey_age_code
--   form a unique combination with start_date for this row between the
--   start_date and end_date of any other row.
--
-- Post Failure
--   An application error is raised If the survey_job_name_code,
--   survey_region_code, survey_seniority, company_size, industry_code
--   survey_age_code combined with start_date for this row are not unique
--   between start_date and end_date of any other row..
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_unique_key
(p_salary_survey_line_id  in number,
 p_object_version_number  in number,
 p_salary_survey_id       in number,
 p_survey_job_name_code   in per_salary_survey_lines.survey_job_name_code%TYPE,
 p_survey_region_code     in per_salary_survey_lines.survey_region_code%TYPE,
 p_survey_seniority_code  in per_salary_survey_lines.survey_seniority_code%TYPE,
 p_company_size_code      in per_salary_survey_lines.company_size_code%TYPE,
 p_industry_code          in per_salary_survey_lines.industry_code%TYPE,
 p_survey_age_code        in per_salary_survey_lines.survey_age_code%TYPE,
 p_start_date             in per_salary_survey_lines.start_date%TYPE,
 p_end_date               in per_salary_survey_lines.end_date%TYPE);


--
-- ---------------------------------------------------------------
-- |------------------< chk_salary_figures >---------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that
--     a) At least one of the following parameters is not null.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   SALARY_SURVEY_LINE_ID
--   OBJECT_VERSI0N_NUMBER
--   CURRENCY_CODE
--   MINIMUM_PAY
--   MEAN_PAY
--   MAXIMUM_PAY
--   GRADUATE_PAY
--   STARTING_PAY
--   PERCENTAGE_CHANGE
--   JOB_FIRST_QUARTILE
--   JOB_MEDIAN_QUARTILE
--   JOB_THIRD_QUARTILE
--   JOB_FOURTH_QUARTILE
--   MINIMUM_TOTAL_COMPENSATION
--   MEAN_TOTAL_COMPENSATION
--   MAXIMUM_TOTAL_COMPENSATION
--   COMPNSTN_FIRST_QUARTILE
--   COMPNSTN_MEDIAN_QUARTILE
--   COMPNSTN_THIRD_QUARTILE
--   COMPNSTN_FOURTH_QUARTILE
--
-- Post Success
--   Processing continues
--     If at least one of the salary figures is not null.
-- ras    If all the salary figures are numbers.
--
-- Post Failure
--  An application error is raised and processing is terminated:
--     If any of the salary figures is null.
--  ras   If any of the salary figures are not numbers.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_salary_figures
(p_salary_survey_line_id
      in number,
 p_object_version_number
      in number,
p_currency_code
      in per_salary_survey_lines.currency_code%TYPE,
 p_minimum_pay
      in per_salary_survey_lines.minimum_pay%TYPE,
 p_mean_pay
      in per_salary_survey_lines.mean_pay%TYPE,
 p_maximum_pay
      in per_salary_survey_lines.maximum_pay%TYPE,
 p_graduate_pay
      in per_salary_survey_lines.graduate_pay%TYPE,
 p_starting_pay
      in per_salary_survey_lines.starting_pay%TYPE,
 p_percentage_change
      in per_salary_survey_lines.percentage_change%TYPE,
 p_job_first_quartile
      in per_salary_survey_lines.job_first_quartile%TYPE,
 p_job_median_quartile
      in per_salary_survey_lines.job_median_quartile%TYPE,
 p_job_third_quartile
      in per_salary_survey_lines.job_third_quartile%TYPE,
 p_job_fourth_quartile
      in per_salary_survey_lines.job_fourth_quartile%TYPE,
 p_minimum_total_compensation
     in per_salary_survey_lines.minimum_total_compensation%TYPE,
 p_mean_total_compensation
     in per_salary_survey_lines.mean_total_compensation%TYPE,
 p_maximum_total_compensation
     in per_salary_survey_lines.maximum_total_compensation%TYPE,
 p_compnstn_first_quartile
     in per_salary_survey_lines.compnstn_first_quartile%TYPE,
 p_compnstn_median_quartile
     in per_salary_survey_lines.compnstn_median_quartile%TYPE,
 p_compnstn_third_quartile
     in per_salary_survey_lines.compnstn_third_quartile%TYPE,
 p_compnstn_fourth_quartile
     in per_salary_survey_lines.compnstn_fourth_quartile%TYPE
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
Procedure insert_validate(p_rec            in per_ssl_shd.g_rec_type,
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
Procedure update_validate(p_rec            in per_ssl_shd.g_rec_type,
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
Procedure delete_validate(p_rec in per_ssl_shd.g_rec_type);
--
end per_ssl_bus;

/

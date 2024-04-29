--------------------------------------------------------
--  DDL for Package PER_SSM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_BUS" AUTHID CURRENT_USER as
/* $Header: pessmrhi.pkh 120.0 2005/05/31 21:51:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_legislation_code >-----------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code( p_salary_survey_mapping_id in number )
                                  return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in per_ssm_shd.g_rec_type);

-- ----------------------------------------------------------------------------
-- |--------------------< get_salary_survey_line_start >----------------------|
-- ----------------------------------------------------------------------------
--
Function get_salary_survey_line_start
 (p_salary_survey_line_id    in number)
 return date;
--

-- ----------------------------------------------------------------------------
-- |---------------------< get_salary_survey_line_end >-----------------------|
-- ----------------------------------------------------------------------------
--
Function get_salary_survey_line_end
 (p_salary_survey_line_id    in number)
 return date;
--

-- ----------------------------------------------------------------------------
-- |---------------------< chk_salary_survey_line_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_salary_survey_line_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_salary_survey_line_id
(p_salary_survey_mapping_id in number,
 p_salary_survey_line_id    in number,
 p_object_version_number    in number);


-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_parent >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_parent_id ID of FK column in table p_parent_table_name
--   p_parent_table_name is the name of the table for which parent_id is the PK
--   p_business_group_id is the business group ID of the salary survey mapping
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_parent
(p_salary_survey_mapping_id in number,
 p_parent_id                in number,
 p_parent_table_name        in varchar2,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date		    in date);
--
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that salary_survey_line_id,
--   parent_table_name and the parent_table_id are in a unique combination
--   compared to other rows in the table per_salary_survey_mappings.
--
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_parent_id ID of FK column in table p_parent_table_name
--   p_parent_table_name is the name of the table for which parent_id is the PK
--   p_salary_survey_line_id is the salary survey line ID of the salary survey
--   mapping
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the salary_survey_line_id, parent_table_name
--   and the parent_table_id are in a unique combination compared to
--   other rows in the table per_salary_survey_mappings.
--
-- Post Failure
--   Processing stops and an error is raised if the unique key validation
--   is breeched.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_unique_key
(p_salary_survey_mapping_id in number,
 p_parent_id                in number,
 p_parent_table_name        in varchar2,
 p_salary_survey_line_id    in number,
 p_grade_id		    in number,
 p_location_id		    in number,
 p_company_organization_id  in number,
 p_company_age_code	    in varchar2,
 p_object_version_number    in number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_location_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_location_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_location_id
(p_salary_survey_mapping_id in number,
 p_location_id              in number,
 p_object_version_number    in number,
 p_ssl_start_date           in date);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_grade_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_grade_id ID of FK column
--   p_business_group_id the business group ID of the salary survey mapping
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_grade_id
(p_salary_survey_mapping_id in number,
 p_grade_id                 in number,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date		    in date);
  --
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_company_organization_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_company_organization_id ID of FK column
--   p_business_group_id the business group ID of the salary survey mapping
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_company_organization_id
(p_salary_survey_mapping_id in number,
 p_company_organization_id  in number,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date		    in date);
  --
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_company_age_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_company_age_code code for lookup in hr_lookups
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the lookup exists in the lookup table.
--
-- Post Failure
--   Processing stops and an error is raised If the lookup does not
--   exist in the lookup table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_company_age_code
(p_salary_survey_mapping_id in number,
 p_company_age_code         in varchar2,
 p_effective_date           in date,
 p_object_version_number    in number);

-- ----------------------------------------------------------------------------
-- |------------------------< chk_effective_date >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that the effective date is not null and is valid
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_effective_date
--
-- Post Success
--   Processing continues If the effective_date is valid
--
-- Post Failure
--   Processing stops and an error is raised.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_effective_date
(p_effective_date           in date);

--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this Procedure will End normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid Then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
Procedure chk_df
  (p_rec in per_ssm_shd.g_rec_type);
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
Procedure insert_validate( p_rec            in per_ssm_shd.g_rec_type
			 , p_effective_date in date);
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
Procedure update_validate( p_rec            in per_ssm_shd.g_rec_type
			 , p_effective_date in date);
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
Procedure delete_validate(p_rec in per_ssm_shd.g_rec_type);
--
end per_ssm_bus;

 

/

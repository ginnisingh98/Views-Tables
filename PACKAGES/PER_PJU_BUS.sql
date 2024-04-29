--------------------------------------------------------
--  DDL for Package PER_PJU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJU_BUS" AUTHID CURRENT_USER as
/* $Header: pepjurhi.pkh 120.0 2005/05/31 14:24:40 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_previous_job_usage_id
--     already exists.
--
--  In Arguments:
--    p_previous_job_usage_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_previous_job_usage_id                in number
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_previous_job_usage_id
--     already exists.
--
--  In Arguments:
--    p_previous_job_usage_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_previous_job_usage_id                in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_pju_shd.g_rec_type
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_pju_shd.g_rec_type
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_pju_shd.g_rec_type
  );
--
-- Check Procedures
procedure chk_valid_job_dates
          (p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
           ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type
           ,p_start_date
           in  per_previous_job_usages.start_date%type
           ,p_end_date
           in  per_previous_job_usages.end_date%type);
--
procedure chk_period_years
          (p_period_years
           in per_previous_job_usages.period_years%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type);
--
procedure chk_period_months
          (p_period_months
           in  per_previous_job_usages.period_months%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type);
--
procedure chk_period_days
          (p_period_days
           in  per_previous_job_usages.period_days%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type);
--
procedure chk_pju_start_end_dates
          (p_previous_job_usage_id
          in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
          in  per_previous_job_usages.object_version_number%type
          ,p_previous_employer_id
          in  per_previous_job_usages.previous_employer_id%type
          ,p_start_date
          in  per_previous_job_usages.start_date%type
          ,p_end_date
          in  per_previous_job_usages.end_date%type);
--
procedure get_previous_job_dates
          (p_previous_employer_id
           in  per_previous_job_usages.previous_employer_id%type
          ,p_previous_job_id
           in  per_previous_job_usages.previous_job_id%type
          ,p_start_date
           out nocopy per_previous_job_usages.start_date%type
          ,p_end_date
           out nocopy per_previous_job_usages.end_date%type
          ,p_period_years
           out nocopy per_previous_job_usages.period_years%type
          ,p_period_months
           out nocopy per_previous_job_usages.period_months%type
          ,p_period_days
           out nocopy per_previous_job_usages.period_days%type
          );
--
end per_pju_bus;

 

/

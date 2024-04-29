--------------------------------------------------------
--  DDL for Package PER_PJO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJO_BUS" AUTHID CURRENT_USER as
/* $Header: pepjorhi.pkh 120.0.12010000.2 2008/08/06 09:28:32 ubhat ship $ */
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
--    The primary key identified by p_previous_job_id
--     already exists.
--
--  In Arguments:
--    p_previous_job_id
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
  (p_previous_job_id                      in number
  ,p_associated_column1                   in varchar2 default null
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
--    The primary key identified by p_previous_job_id
--     already exists.
--
--  In Arguments:
--    p_previous_job_id
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
  (p_previous_job_id                      in     number
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
  (p_effective_date               in date
  ,p_rec                          in per_pjo_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in per_pjo_shd.g_rec_type
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
  (p_rec              in per_pjo_shd.g_rec_type
  );
--
procedure chk_start_end_dates
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_start_date
          in  per_previous_jobs.start_date%type
          ,p_end_date
          in  per_previous_jobs.end_date%type);
--
procedure chk_pjo_start_end_dates
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_previous_employer_id
          in  per_previous_jobs.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_start_date
          in  per_previous_jobs.start_date%type
          ,p_end_date
          in  per_previous_jobs.end_date%TYPE
	  ,p_effective_date
	  IN  per_previous_jobs.start_date%type);
--
procedure chk_all_assignments
          (p_previous_job_id
          in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
          in  per_previous_jobs.object_version_number%type
          ,p_all_assignments
          in  per_previous_jobs.all_assignments%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_years >----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_years value is between 0 and 99
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_years
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 99
--
-- Post Failure:
--   An application error is raised period_years is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_years
          (p_period_years in  per_previous_jobs.period_years%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_months >---------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_months value is between 0 and 11
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_months
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_months is between 0 and 11
--
-- Post Failure:
--   An application error is raised period_months is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_months
          (p_period_months in  per_previous_jobs.period_months%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_days >-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_days value is between 0 and 365
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_days
--  p_previous_job_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 365
--
-- Post Failure:
--   An application error is raised period_days is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_days
          (p_period_days in  per_previous_jobs.period_days%type
          ,p_previous_job_id
           in  per_previous_jobs.previous_job_id%type
          ,p_object_version_number
           in  per_previous_jobs.object_version_number%type);
--
-- ---------------------------------------------------------------------------
-- |-------------------------< return_leg_code >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_previous_employer_id
--    already exists.
--
--  In Arguments:
--    p_previous_employer_id
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
Function return_leg_code (
         p_previous_employer_id    in number
         ) return varchar2;
--
end per_pjo_bus;

/

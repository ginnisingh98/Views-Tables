--------------------------------------------------------
--  DDL for Package PER_JOB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_BUS" AUTHID CURRENT_USER as
/* $Header: pejobrhi.pkh 120.0 2005/05/31 10:48:07 appldev noship $ */
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
Procedure insert_validate(p_rec in per_job_shd.g_rec_type);
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
Procedure update_validate(p_rec in per_job_shd.g_rec_type);
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
Procedure delete_validate(p_rec in per_job_shd.g_rec_type);
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific job
--
--  Prerequisites:
--    The job identified by p_job_id already exists.
--
--  In Arguments:
--    p_assignment_id
--
--  Post Success:
--    If the job is found this function will return the job's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the job does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_job_id            in number
  ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------

Procedure chk_non_updateable_args
  (p_date_from  in date
  ,p_rec  in per_job_shd.g_rec_type
  ) ;
--
-- -------------------------------------------------------------------------+
-- |------------------------< chk_emp_rights_flag >-------------------------|
-- -------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--    Validates that the employee_rights_flag is either set to 'Y' or 'N'
--    or is null
--
--  Prerequisites:
--
--  In Arguments:
--
--      emp_rights_flag               VARCHAR2        employee rights flag
--      p_rec
--
--  Post Success:
--
--      If the employee rights flag is set and the value is
--      set to either Y, N or null, the insert or update continues
--
--  Post Failure:
--
--      On failure the procedure will raise an application error
--
--  Access Status:
--
--    Public
--
-- {End Of Comments}
--
---------------------------------------------------------------------------+
procedure chk_emp_rights_flag
  (p_emp_rights_flag in per_jobs.emp_rights_flag%TYPE
  ,p_rec in per_job_shd.g_rec_type);
--
-- -------------------------------------------------------------------------+
-- |--------------------------< chk_job_group_id >--------------------------|
-- -------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--
--    Validates the job group id entered. It first checks that the job
--    group id exists in the business group and then it checks if it is
--    global
--
-- Prerequisites:
--
--  In Arguments:
--
--    job_group_id                     number       job group id
--    business_group_id                number       business group id
--
--  Post Success:
--
--     If the job group id is found, procedure continues
--
--  Post Failure:
--
--     On failure the procedure will raise an application error
--
--  Access Status:
--
--     Public
--
-- {End Of Comments}
--
--
---------------------------------------------------------------------------+
procedure chk_job_group_id
  (p_job_group_id       in per_jobs.job_group_id%TYPE
  ,p_business_group_id  in per_jobs.business_group_id%TYPE
  );
--
-- -------------------------------------------------------------------------+
-- |-----------------------< chk_approval_authority >-----------------------|
-- -------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--    Checks that the value of approval authority is not a negative number
--
--  Prerequisites:
--    approval authority must be enabled
--
--  In Arguments:
--    p_approval_authority            varchar       approval authority
--    p_rec
--
--  Post Success:
--    Insert or update process continues
--
--  Post Failure:
--     On failure the procedure will raise an application error
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
--
---------------------------------------------------------------------------+
procedure chk_approval_authority
  (p_approval_authority in per_jobs.approval_authority%TYPE
  ,p_rec in per_job_shd.g_rec_type);
--
-- -------------------------------------------------------------------------+
-- |-----------------------< chk_benchmark_job_flag >-----------------------|
-- -------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--     Checks that benchmark job id and benchmark job flag are not
--     both being used.
--
--  Prerequisites:
--     benchmark job id and benchmark job flag must be populated and
--     enabled
--
--  In Arguments:
--     benchmark_job_id              number      benchmark job id
--     benchmark_job_flag            varchar     benchmark job flag
--     p_rec
--
--  Post Success:
--     Insert or update continues
--
--  Post Failure:
--     On failure the procedure will raise an application error
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
--
---------------------------------------------------------------------------+
procedure chk_benchmark_job_flag
  (p_benchmark_job_flag in per_jobs.benchmark_job_flag%TYPE
  ,p_benchmark_job_id   in per_jobs.benchmark_job_id%TYPE
  ,p_rec in per_job_shd.g_rec_type);
--
-- --------------------------------------------------------------------------+
-- |------------------------< chk_benchmark_job_id >-------------------------|
-- --------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   Validate that benchmark job id being used actually exists for the
--   business group and does not have the same job id as the job being
--   created or updated
--
--  Prerequisites:
--    benchmark job id must be populated and enabled
--
--  In Arguments:
--    p_benchmark_job_id
--    job_id
--    business_group_id
--    p_rec
--
--  Post Success:
--     Insert or update process continues
--
--  Post Failure:
--     On failure the procedure will raise an application error
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
--
---------------------------------------------------------------------------+
procedure chk_benchmark_job_id
  (p_benchmark_job_id    in  per_jobs.benchmark_job_id%TYPE
  ,p_job_id              in  per_jobs.job_id%TYPE
  ,p_business_group_id   in  per_jobs.business_group_id%TYPE
  ,p_rec                 in  per_job_shd.g_rec_type);
--

-- --------------------------------------------------------------------------+
-- |------------------------< check_unique_name >-------------------------|
-- --------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure will ensure the uniqueness of job name for a
--   given business group
--
--  Prerequisites:
--   A valid business group must be existing
--
--  In Arguments:
--    p_job_id
--    p_business_group_id
--    p_name
--
--  Post Success:
--    Appropriate message will be shown to the user, if a duplicate
--    job name is found for the given business group
--
--  Post Failure:
--     None
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
---------------------------------------------------------------------------+
procedure check_unique_name(p_job_id            in number,
                      p_business_group_id in number,
             p_name              in varchar2);
--
-- --------------------------------------------------------------------------+
-- |------------------------< check_date_from >-------------------------|
-- --------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   If the date from item in the jobs block is greater than
--   the date from item in the grades block then raise an error
--
--  Prerequisites:
--   A valid job must be existing
--
--  In Arguments:
--    p_job_id
--    p_date_from
--
--  Post Success:
--    Appropriate message will be shown to the user
--
--  Post Failure:
--     None
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
---------------------------------------------------------------------------+
procedure check_date_from(p_job_id           in number,
           p_date_from        in date);
--
-- --------------------------------------------------------------------------+
-- |------------------------< check_altered_end_date >-----------------------|
-- --------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure will check for valid grades associated for a given  job
--   and Business group, while end dating a job definition.
--
--  Prerequisites:
--   A valid job and business group must be existing
--
--  In Arguments:
--    p_business_group_id
--    p_job_id
--    p_end_of_time
--    p_date_to
--    p_date_from
--
--  Post Success:
--    Returns TRUE for p_early_date_to if the grades end date is greater than
--    the proposed end date for the job definition
--    Returns TRUE for p_early_date_from if the grades from date is greater
--    than the proposed end date for the job definition
--
--  Post Failure:
--     None
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
---------------------------------------------------------------------------+
procedure check_altered_end_date(p_business_group_id      number,
                  p_job_id                 number,
                           p_end_of_time            date,
                  p_date_to                date,
                           p_early_date_to      in out nocopy boolean,
                  p_early_date_from    in out nocopy boolean);
--
-- --------------------------------------------------------------------------+
-- |------------------------< check_delete_record >--------------------------|
-- --------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--  Check there are no values in per_valid_grades, per_job_requirements,
--  per_job_evaluations, per_career_path_elements (check on parent and
--  subordinate id), hr_all_positions_f, per_budget_elements,
--  PER_all_assignments, per_vacancies_f, per_element_links_f
--
--  Prerequisites:
--   A valid job and business group must be existing
--
--  In Arguments:
--    p_business_group_id
--    p_job_id
--
--  Post Success:
--    Appropriate message will be shown to the user, if data is existing in
--    any of the above mentioned table for the given job and business group
--
--  Post Failure:
--     None
--
--  Access Status:
--     Public
--
-- {End Of Comments}
--
---------------------------------------------------------------------------+
procedure check_delete_record(p_job_id            number,
               p_business_group_id number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_evaluation_dates >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will check for the valid evaluations exists outside
--   the effective period, when the user is end dating a job for a given
--   job id.
-- Prerequisites:
--   A valid job must be existing
--
-- In Parameters:
--   Name
--   p_jobid
--   p_job_date_from
--   p_job_date_to
--
-- Post Success:
--   User will be stopped from end dating the job, if any evaluation is
--   existing outside the effective end date of the job,for the given job id.
--   and a suitable message will be shown to the user.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
procedure check_evaluation_dates(p_jobid in number,
                                 p_job_date_from in date,
                                 p_job_date_to in date);
--
end per_job_bus;

 

/

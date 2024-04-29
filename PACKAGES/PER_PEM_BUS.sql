--------------------------------------------------------
--  DDL for Package PER_PEM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEM_BUS" AUTHID CURRENT_USER as
/* $Header: pepemrhi.pkh 120.0.12010000.3 2008/08/06 09:22:15 ubhat ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--    It is only valid to call this procedure when the primary key
--    is within a buisiness group context.
--
--  Prerequisites:
--    The primary key identified by p_previous_employer_id
--     already exists.
--
--  In Arguments:
--    p_previous_employer_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--    An error is also raised when the primary key data is outside
--    of a buisiness group context.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_previous_employer_id                 in number
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
--    The primary key identified by p_previous_employer_id
--     already exists.
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
FUNCTION return_legislation_code
  (p_previous_employer_id                 in     number
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
  ,p_rec                          in per_pem_shd.g_rec_type
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
  ,p_rec                          in per_pem_shd.g_rec_type
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
  (p_rec              in per_pem_shd.g_rec_type
  );
--
procedure chk_start_end_dates
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_start_date
          in  per_previous_employers.start_date%type
          ,p_end_date
          in  per_previous_employers.end_date%TYPE
	  ,p_effective_date
	  IN  per_previous_employers.start_date%type);
--
procedure get_period_values
          (p_start_date     in  per_previous_employers.start_date%type
          ,p_end_date       in  per_previous_employers.end_date%type
          ,p_period_years   out nocopy per_previous_employers.period_years%type
          ,p_period_months  out nocopy per_previous_employers.period_months%type
          ,p_period_days    out nocopy per_previous_employers.period_days%type
          );
--
procedure chk_all_assignments
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_all_assignments
          in  per_previous_employers.all_assignments%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_years >----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_years is between 0 and 99
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_years
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 99
--
-- Post Failure:
--   An application error is raised if period_years value is not in range
--   of 0 and 99.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_years
          (p_period_years in  per_previous_employers.period_years%type
          ,p_previous_employer_id
            in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
            in  per_previous_employers.object_version_number%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_months >---------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_months is between 0 and 11
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_months
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 11
--
-- Post Failure:
--   An application error is raised if period_months value is not in range
--   of 0 and 11.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_months
          (p_period_months in  per_previous_employers.period_months%type
          ,p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_employers.object_version_number%type);
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_days >-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_days is between 0 and 365
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_days
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_days is between 0 and 365
--
-- Post Failure:
--   An application error is raised if period_days value is not in range
--   of 0 and 365.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_days
          (p_period_days in per_previous_employers.period_days%type
          ,p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_employers.object_version_number%type);
--
end per_pem_bus;

/

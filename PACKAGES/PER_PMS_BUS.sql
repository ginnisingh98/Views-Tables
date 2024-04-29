--------------------------------------------------------
--  DDL for Package PER_PMS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMS_BUS" AUTHID CURRENT_USER as
/* $Header: pepmsrhi.pkh 120.2.12010000.1 2008/07/28 05:23:05 appldev ship $ */
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
--    The primary key identified by p_scorecard_id
--     already exists.
--
--  In Arguments:
--    p_scorecard_id
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
  (p_scorecard_id                         in number
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
--    The primary key identified by p_scorecard_id
--     already exists.
--
--  In Arguments:
--    p_scorecard_id
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
  (p_scorecard_id                         in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_assignment_id >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the specified assignment exists
--   and that it is not a Benefits ('B') assignment.
--
-- Pre Conditions:
--   The assignment must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the assignment is valid.
--
-- Post Failure:
--   An application error is raised if the assignment does not exist
--   or is a Benefits assignment.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_scorecard_id          IN         number
  ,p_object_version_number IN         number
  ,p_assignment_id         IN         number
  ,p_person_id             OUT nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_id >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified performance
--   management plan exists.
--
-- Pre Conditions:
--   The plan must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the plan is valid.
--
-- Post Failure:
--   An application error is raised if the plan does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_plan_id
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duplicate >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that a personal scorecard does not
--   already exist for the given assignment and given plan.
--
-- Pre Conditions:
--   The plan and assignment must exist and have been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard is not a duplicate.
--
-- Post Failure:
--   An application error is raised if the scorecard is a duplicate.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_duplicate
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_assignment_id         IN number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dates >--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the start and end date of the scorecard. It
--   first checks that the start date is earlier than the end date and
--   then it checks that the scorecard dates are within the dates of the
--   performance management plan.
--
-- Pre Conditions:
--   Where used, the plan must exist and have been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the dates are valid.
--
-- Post Failure:
--   An application error is raised if the dates are invalid.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_dates
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_start_date            IN date
  ,p_end_date              IN date);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_scorecard_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that the specified assignment does not already
--   have a scorecard with a duplicate name.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard name is unique for the given
--   assignment and the p_duplicate_name_warning is set accordingly
--   (true if the name already exists; false if it does not).
--
-- Post Failure:
--   An error is raised if an unhandled exception occurs.
--
-- Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_scorecard_name
  (p_scorecard_id           IN  number
  ,p_object_version_number  IN  number
  ,p_assignment_id          IN  number
  ,p_scorecard_name         IN  varchar2
  ,p_duplicate_name_warning OUT NOCOPY boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_creator_type >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the creator type is 'MANUAL' or 'AUTO'.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if p_creator_type is valid.
--
-- Post Failure:
--   An application error is raised if the creator_type is not valid.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_creator_type
  (p_creator_type            IN  varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_status_code >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the status code is a valid lookup.
--
-- Pre Conditions:
--   The lookup needs to exist and enabled.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the status code is valid.
--
-- Post Failure:
--   An application error is raised if the status code is not valid.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status_code
  (p_effective_date         IN  date
  ,p_scorecard_id           IN  number
  ,p_object_version_number  IN  number
  ,p_status_code            IN  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_auto_creator_type >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if the creator type is 'AUTO'.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   The p_created_by_plan_warning is set accordingly.
--
-- Post Failure:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_auto_creator_type
  (p_creator_type            IN varchar2
  ,p_created_by_plan_warning OUT NOCOPY boolean);
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_no_objectives >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates that the scorecard does not have any objectives
--   before it is deleted.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard does not have any objectives.
--
-- Post Failure:
--   An application error is raised if the scorecard has objectives.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_no_objectives
  (p_scorecard_id            IN number);
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
  ,p_rec                          in per_pms_shd.g_rec_type
  ,p_person_id                    out nocopy number
  ,p_duplicate_name_warning       out nocopy boolean
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
  ,p_rec                          in per_pms_shd.g_rec_type
  ,p_duplicate_name_warning      out nocopy boolean
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
  (p_rec                        in per_pms_shd.g_rec_type
  ,p_created_by_plan_warning   out nocopy boolean
  );
--
end per_pms_bus;

/

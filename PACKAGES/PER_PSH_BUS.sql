--------------------------------------------------------
--  DDL for Package PER_PSH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSH_BUS" AUTHID CURRENT_USER as
/* $Header: pepshrhi.pkh 120.2 2006/05/08 19:34:18 tpapired noship $ */
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
--    The primary key identified by p_sharing_instance_id
--     already exists.
--
--  In Arguments:
--    p_sharing_instance_id
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
  (p_sharing_instance_id                  in number
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
--    The primary key identified by p_sharing_instance_id
--     already exists.
--
--  In Arguments:
--    p_sharing_instance_id
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
  (p_sharing_instance_id                  in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_scorecard_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified scorecard exists
--
-- Pre Conditions:
--   The scorecard must already exist.
--
-- In Arguments:
--    p_scorecard_id
--    p_person_id
--
-- Post Success:
--   Processing continues if the scorecard is valid.
--
-- Post Failure:
--   An application error is raised if the scorecard does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_scorecard_id
  (p_scorecard_id          IN number
  ,p_person_id             IN number
  );
--
--
-----------------------------------------------------------------------------
--------------------------------<chk_person_id>------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the person_id has been entered
--     as it is a mandatory column
--
--  Pre_conditions:
--    -
--
--  In Arguments:
--    p_person_id
--
--  Post Success:
--    Process continues if :
--    Person id is valid as of effective date.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- person_id is not set or invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_person_id
(p_person_id          in      per_objectives.owning_person_id%TYPE
);
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_scorecard_person_unique >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified scorecard
--   and person_id combination doesn;t already exist.
--
-- Pre Conditions:
--   none
--
-- In Arguments:
--    p_scorecard_id
--    p_person_id
--
--
-- Post Success:
--   Processing continues if the combination does not exist.
--
-- Post Failure:
--   An application error is raised if the combination already exists.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_scorecard_person_unique
  (p_scorecard_id          IN number
  ,p_person_id             IN number
  );
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
  (p_rec                          in per_psh_shd.g_rec_type
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
  (p_rec                          in per_psh_shd.g_rec_type
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
  (p_rec              in per_psh_shd.g_rec_type
  );
--
end per_psh_bus;

 

/

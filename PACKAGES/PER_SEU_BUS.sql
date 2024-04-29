--------------------------------------------------------
--  DDL for Package PER_SEU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEU_BUS" AUTHID CURRENT_USER as
/* $Header: peseurhi.pkh 120.3 2005/11/08 16:30:29 vbanner noship $ */
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
--    The primary key identified by p_security_user_id
--     already exists.
--
--  In Arguments:
--    p_security_user_id
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
  (p_security_user_id                     in number
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
--    The primary key identified by p_security_user_id
--     already exists.
--
--  In Arguments:
--    p_security_user_id
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
  (p_security_user_id                     in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_user_id >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the user_id passed in, is
--   a valid and active user.
--   This proceure does not validate that the user is linked to a HR person
--   nor does it validate that the user has a responsibility attached to
--   the current security profile.
--
-- Prerequisites:
--   The primary key identified by p_security_user_id already exists.
--
-- In Arguments:
--   p_security_user_id
--   p_user_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues if the user given passes the validated.
--
-- Post Failure:
--   An application error is raised if the user is not valid.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_user_id
  (p_security_user_id      in number
  ,p_user_id               in number
  ,p_object_version_number in number
  ,p_effective_date        in date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_security_profile_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the security profile passed
--   in exists.
--
-- Prerequisites:
--   The primary key identified by p_security_user_id already exists.
--
-- In Arguments:
--   p_security_user_id
--   p_security_profile_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if the security profile is validated.
--
-- Post Failure:
--   An application error is raised if the security profile is not valid.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_security_profile_id
  (p_security_user_id      in number
  ,p_security_profile_id   in number
  ,p_object_version_number in number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_association_unique >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that this user does not already
--   exist in this security profile's static list.
--
-- Prerequisites:
--   The primary key identified by p_security_user_id already exists.
--   The user_id column is already validated.
--   The security_profile_id column is already validated.
--
-- In Arguments:
--   p_security_user_id
--   p_user_id
--   p_security_profile_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues if the association is unique.
--
-- Post Failure:
--   An application error is raised if this security profile already
--   includes this user.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_association_unique
  (p_security_user_id      in number
  ,p_user_id               in number
  ,p_security_profile_id   in number
  ,p_object_version_number in number);
--
-- ----------------------------------------------------------------------------
--
procedure chk_process_in_next_run_flag
  (p_security_user_id      in number
  ,p_process_in_next_run_flag in varchar2
  ,p_object_version_number in number);
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
  ,p_rec                          in per_seu_shd.g_rec_type
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
  ,p_rec                          in per_seu_shd.g_rec_type
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
  (p_rec              in per_seu_shd.g_rec_type
  );
--
end per_seu_bus;

 

/

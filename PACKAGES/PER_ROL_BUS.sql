--------------------------------------------------------
--  DDL for Package PER_ROL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ROL_BUS" AUTHID CURRENT_USER as
/* $Header: perolrhi.pkh 120.0 2005/05/31 18:35:08 appldev noship $ */
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
--    The primary key identified by p_role_id
--     already exists.
--
--  In Arguments:
--    p_role_id
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
  (p_role_id                              in number
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
--    The primary key identified by p_role_id
--     already exists.
--
--  In Arguments:
--    p_role_id
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
  (p_role_id                              in     number
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_rol_shd.g_rec_type
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
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_rol_shd.g_rec_type
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_rol_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_dates >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     Validates that the end_date is later than the start_date
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_start_date
--    p_end_date
--    p_role_id
--
-- Post Success:
--    Processing continues if end_date is later than start_date.
--
-- Post Failure:
--    An application error is raised and processing is terminated if
--    end_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
procedure chk_dates
  (p_start_date       in  date
  ,p_end_date         in  date
  );

-- Start of fix 2497485
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dup_roles >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     This function will check for the duplicate roles.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_person_id
--    p_job_group_id
--    p_job_id
--
-- Post Success:
--    A warning message will be shown to the user
--
-- Post Failure:
--    None
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
function chk_dup_roles
         (p_person_id        in    per_roles.person_id%Type
         ,p_job_group_id     in    per_roles.job_group_id%Type
         ,p_job_id           in    per_roles.job_id%Type
         ) return boolean;
-- End of 2497485
--
end per_rol_bus;

 

/

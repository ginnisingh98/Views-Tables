--------------------------------------------------------
--  DDL for Package PER_CKL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CKL_BUS" AUTHID CURRENT_USER as
/* $Header: pecklrhi.pkh 120.3 2006/09/06 06:02:08 sturlapa noship $ */
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
--    The primary key identified by p_checklist_id
--     already exists.
--
--  In Arguments:
--    p_checklist_id
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
  (p_checklist_id                         in number
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
--    The primary key identified by p_checklist_id
--     already exists.
--
--  In Arguments:
--    p_checklist_id
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
  (p_checklist_id                         in     number
  ) RETURN varchar2;
--
--
-- --------------------------------------------------------------------------
-- |------------------------< chk_name >------------------------------------|
-- --------------------------------------------------------------------------
--
-- Description:
--      Validates that name is not null, and that it is unique for the
--      given business group id.
--
-- Pre-requisites:
--      The business group id is valid.
--
-- IN Parameters:
--      p_name
--      p_business_group_id
--
-- Post Success:
--      Processing continues if the name is valid.
--
-- Post Failure:
--      An application error is raised and processing is terminated if the
--      name is invalid
--
-- Developer/Implementation Notes:
--      None.
--
-- Access Status:
--      Internal Development Use Only.
--
Procedure chk_name
  (p_name                   in   per_checklists.name%TYPE
  ,p_category               IN   per_checklists.checklist_category%TYPE
  ,p_business_group_id      in   per_checklists.business_group_id%TYPE
  ,p_checklist_id           in   per_checklists.checklist_id%type
  ,p_object_version_number  in   per_checklists.object_version_number%type
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_ler_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that LIFE_EVENT_REASON_ID exists in ben_ler_f on the
--    effective_date.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_ler_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--   Internal Row Handler Use Only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_ler_id
  (p_ler_id              in    per_checklists.event_reason_id%TYPE
  ,p_business_group_id   in    per_checklists.business_group_id%TYPE
  ,p_effective_date      in    date
   );
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_ckl_category >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that value for CHECKLIST_CATEGORY exists in hr_leg_lookups for
--    the lookup_type of 'CHECKLIST_CATEGORY'.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_checklist_id
--    p_ckl_category
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_ckl_category
  (p_checklist_id           in per_checklists.checklist_id%TYPE,
   p_ckl_category           in per_checklists.checklist_category%TYPE,
   p_effective_date         in date
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
  (p_effective_date               in date
  ,p_rec                          in per_ckl_shd.g_rec_type
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
  ,p_rec                          in per_ckl_shd.g_rec_type
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
  (p_rec              in per_ckl_shd.g_rec_type
  );
--
end per_ckl_bus;

 

/

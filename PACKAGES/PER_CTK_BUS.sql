--------------------------------------------------------
--  DDL for Package PER_CTK_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTK_BUS" AUTHID CURRENT_USER as
/* $Header: pectkrhi.pkh 120.5 2006/09/06 06:03:49 sturlapa noship $ */
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
--    The primary key identified by p_task_in_checklist_id
--     already exists.
--
--  In Arguments:
--    p_task_in_checklist_id
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
  (p_task_in_checklist_id                 in number
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
--    The primary key identified by p_task_in_checklist_id
--     already exists.
--
--  In Arguments:
--    p_task_in_checklist_id
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
  (p_task_in_checklist_id                 in     number
  ) RETURN varchar2;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_checklist_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that CHECKLIST_ID exists in per_checklists on the
--    effective_date.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_checklist_task_id
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
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_checklist_id
  (p_checklist_id       in    per_tasks_in_checklist.checklist_id%TYPE
   );
--

--  ---------------------------------------------------------------------------
--  |------------------------------< chk_task_name >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that TASK_NAME is mandatory
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_checklist_task_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_task_name
  (p_checklist_task_name    in    per_tasks_in_checklist.checklist_task_name%TYPE
  ,p_task_in_checklist_id   in    per_tasks_in_checklist.task_in_checklist_id%TYPE
  ,p_checklist_id           in    per_tasks_in_checklist.checklist_id%TYPE
  ,p_object_version_number  in    per_tasks_in_checklist.object_version_number%type
   );
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_duration_uom >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that target_duration and target_duration_uom are in synch
--      if target_duration has value, target_duration_uom is mandatory
--      target_duration_uom must be one of these values 'D','W', 'M'
--
--  Pre-conditions :
--      Target_duration_uom units must exist in hr-Lookups for
--          lookup_type = QUALIFYING_UNITS
--
--  In Arguments :
--    p_checklist_task_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
--
procedure chk_duration_uom
  (p_target_duration        in    per_tasks_in_checklist.target_duration%TYPE
  ,p_target_duration_uom    in    per_tasks_in_checklist.target_duration_uom%TYPE
  ,p_task_in_checklist_id   in    per_tasks_in_checklist.task_in_checklist_id%TYPE
  ,p_object_version_number  in    per_tasks_in_checklist.object_version_number%type
  ,p_effective_date         in    date
   );

/*
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_ckl_tsk_unique >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that CHECKLIST_ID and TASK_NAME combination not already exists
--    in per_tasks_in_checklist table.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_checklist_id
--    p_checklist_task_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_ckl_tsk_unique
  (p_checklist_id        in    per_tasks_in_checklist.checklist_id%TYPE
  ,p_checklist_task_name in    per_tasks_in_checklist.checklist_task_name%TYPE
   );
--

--  ---------------------------------------------------------------------------
--  |---------------------------< CHK_ELIG_PRFL_ID >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that ELIGIBILITY_PROFILE_ID already exists
--    in BEN_ELIGY_PRFL_F table.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_checklist_task_id
--    p_business_group_id
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
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_elig_prfl_id
  (p_eligibility_profile_id       in    per_tasks_in_checklist.eligibility_profile_id%TYPE
  ,p_business_group_id  in    per_checklists.business_group_id%TYPE
  ,p_effective_date     in    date
   );
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< CHK_ELIG_OBJ_ID >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that eligibility_object_id already exists
--    in ben_elig_obj_f table.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_elig_obj_id
--    p_business_group_id
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
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_elig_obj_id
  (p_elig_obj_id        in    per_tasks_inchecklist.eligibility_object_id%TYPE
  ,p_business_group_id  in    per_checklists.business_group_id%TYPE
  ,p_effective_date     in    date
   );
--
*/
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
  ,p_rec                          in per_ctk_shd.g_rec_type
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
  ,p_rec                          in per_ctk_shd.g_rec_type
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
  (p_rec              in per_ctk_shd.g_rec_type
  );
--
end per_ctk_bus;

 

/

--------------------------------------------------------
--  DDL for Package PAY_RTU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RTU_BUS" AUTHID CURRENT_USER as
/* $Header: pyrturhi.pkh 120.0 2005/05/29 08:29:09 appldev noship $ */
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
--    The primary key identified by p_run_type_usage_id
--     already exists.
--
--  In Arguments:
--    p_run_type_usage_id
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
  (p_run_type_usage_id                    in number
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
--    The primary key identified by p_run_type_usage_id
--     already exists.
--
--  In Arguments:
--    p_run_type_usage_id
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
  (p_run_type_usage_id                    in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
--  |-----------------------< chk_parent_run_type_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the parent_run_type_id enterend by carrying out
--    the following:
--      - check that the parent_run_type_id exists
--      - check that the parent_run_type_id has a run_method = 'C'
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_usage_id
--    p_parent_run_type_id
--    p_effective_date
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the parent_run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) parent_run_type_id does not exist
--     b) run_method of parent_run_type_id is not 'C'
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_parent_run_type_id
  (p_run_type_usage_id     in number
  ,p_parent_run_type_id    in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_legislation_code      in varchar2);
--  ---------------------------------------------------------------------------
--  |------------------------< chk_child_run_type_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the child_run_type_id enterend by carrying out
--    the following:
--      - check that the child_run_type_id exists
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_usage_id
--    p_child_run_type_id
--    p_parent_run_type_id
--    p_effective_date
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the child_run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) child_run_type_id does not exist
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_child_run_type_id
  (p_run_type_usage_id    in number
  ,p_child_run_type_id    in number
  ,p_parent_run_type_id   in number
  ,p_effective_date       in date
  ,p_business_group_id    in number
  ,p_legislation_code     in varchar2);
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_sequence >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the sequence enterend by carrying out the
--    following:
--      - check that the sequence is unique within a parent_run_type_id
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_usage_id
--    p_parent_run_type_id
--    p_sequence
--    p_effective_date
--
--  Post Success:
--    If the sequence is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) sequence is not unique within a run_type_usage_id
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_sequence
  (p_run_type_usage_id  in number
  ,p_parent_run_type_id in number
  ,p_sequence           in number
  ,p_effective_date     in date);
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_rtu_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_rtu_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                   in pay_rtu_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
end pay_rtu_bus;

 

/

--------------------------------------------------------
--  DDL for Package PAY_IVL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVL_BUS" AUTHID CURRENT_USER as
/* $Header: pyivlrhi.pkh 120.0 2005/05/29 06:04:54 appldev noship $ */
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
--    The primary key identified by p_input_value_id
--     already exists.
--
--  In Arguments:
--    p_input_value_id
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
  (p_input_value_id                       in number
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
--    The primary key identified by p_input_value_id
--     already exists.
--
--  In Arguments:
--    p_input_value_id
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
  (p_input_value_id                       in     number
  ) RETURN varchar2;
--
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
  (p_rec                   in pay_ivl_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_default_val_warning   out nocopy boolean
  ,p_min_max_warning       out nocopy boolean
  ,p_pay_basis_warning     out nocopy boolean
  ,p_formula_warning       out nocopy boolean
  ,p_assignment_id_warning out nocopy boolean
  ,p_formula_message       out nocopy varchar2
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
  (p_rec                     in pay_ivl_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in out nocopy varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_default_val_warning     out nocopy boolean
  ,p_min_max_warning         out nocopy boolean
  ,p_link_inp_val_warning    out nocopy boolean
  ,p_pay_basis_warning       out nocopy boolean
  ,p_formula_warning         out nocopy boolean
  ,p_assignment_id_warning   out nocopy boolean
  ,p_formula_message         out nocopy varchar2
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
  (p_rec                   in pay_ivl_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_formula_validation >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure sets the argument p_assignment_id_warning to TRUE if the
--   formula uses an assignment context. If it does not, then it validates the
--   default value against the formula.
--
-- Prerequisites:
--   This procedure is called from insert_validate and update_validate
--   procedures.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the formula validation fails then the process raises an error or
--   sets the argument p_default_formula_warning to TRUE.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_formula_validation
  (p_default_value           in  varchar2
  ,p_warning_or_error        in  varchar2
  ,p_effective_date          in  date
  ,p_input_value_id          in  number  default null
  ,p_formula_id              in  number  default null
  ,p_business_group_id       in  number
  ,p_default_formula_warning out nocopy boolean
  ,p_assignment_id_warning   out nocopy boolean
  ,p_formula_message         out nocopy varchar2
  );
--
end pay_ivl_bus;

 

/

--------------------------------------------------------
--  DDL for Package PAY_PPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPD_BUS" AUTHID CURRENT_USER as
/* $Header: pyppdrhi.pkh 120.1 2006/01/02 00:35 mseshadr noship $ */
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
--    The primary key identified by p_paye_details_id
--     already exists.
--
--  In Arguments:
--    p_paye_details_id
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
  (p_paye_details_id                      in number
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
--    The primary key identified by p_paye_details_id
--     already exists.
--
--  In Arguments:
--    p_paye_details_id
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
  (p_paye_details_id                      in     number
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
  (p_rec                   in pay_ppd_shd.g_rec_type
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
  (p_rec                     in pay_ppd_shd.g_rec_type
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
  (p_rec                   in pay_ppd_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
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
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in pay_ppd_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_contract_category >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Contract Category.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_payee_details_id
--   p_effective_date
--   p_contract_category
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contract_category
  (p_paye_details_id      in number
  ,p_effective_date        in date
  ,p_contract_category     in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_per_asg_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Person/Assignment Id.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_effective_date
--   p_per_or_asg_id
--   p_contract_category
--   p_business_group_id
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_per_asg_id
  (p_effective_date        in date
  ,p_per_or_asg_id         in number
  ,p_contract_category     in varchar2
  ,p_business_group_id     in number
  ,p_object_version_number in number
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_business_group_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Business Group Id.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_paye_details_id
--   p_effective_date
--   p_business_group_id
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id
  (p_paye_details_id      in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  );
-- ----------------------------------------------------------------------------
-- |--------------------< chk_rate_of_tax >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_paye_details_id
--   p_effective_date
--   p_rate_of_tax
--   p_contract_category
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_per_or_asg_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rate_of_tax
  (p_paye_details_id            in number
  ,p_effective_date              in date
  ,p_rate_of_tax		         in varchar2
  ,p_contract_category           in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_per_or_asg_id               in number
  );
-- ----------------------------------------------------------------------------
-- |--------------------< chk_tax_reduction >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_paye_details_id
--   p_effective_date
--   p_tax_reduction
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_tax_reduction
  (p_paye_details_id            in number
  ,p_effective_date              in date
  ,p_tax_reduction		         in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );
-- ----------------------------------------------------------------------------
-- |--------------------< chk_tax_calc_with_spouse_child >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_paye_details_id
--   p_effective_date
--   p_tax_calc_with_spouse_child
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_tax_calc_with_spouse_child
  (p_paye_details_id            in number
  ,p_effective_date              in date
  ,p_tax_calc_with_spouse_child  in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );
-- ----------------------------------------------------------------------------
-- |--------------------< chk_income_reduction >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_paye_details_id
--   p_effective_date
--   p_tax_calc_with_spouse_child
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_income_reduction
  (p_paye_details_id             in number
  ,p_effective_date              in date
  ,p_income_reduction			 in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );
end pay_ppd_bus;

 

/

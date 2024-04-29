--------------------------------------------------------
--  DDL for Package PAY_PSD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PSD_BUS" AUTHID CURRENT_USER as
/* $Header: pypsdrhi.pkh 120.0 2005/10/14 06:40 mseshadr noship $ */
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
--    The primary key identified by p_sii_details_id
--     already exists.
--
--  In Arguments:
--    p_sii_details_id
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
  (p_sii_details_id                       in number
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
--    The primary key identified by p_sii_details_id
--     already exists.
--
--  In Arguments:
--    p_sii_details_id
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
  (p_sii_details_id                       in     number
  ) RETURN varchar2;
--
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
--   p_sii_details_id
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
  (p_sii_details_id        in number
  ,p_effective_date        in date
  ,p_contract_category     in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
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
--   p_sii_details_id
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
  (p_sii_details_id        in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  );

--
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
--
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_emp_social_security_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Employee Social Security Information values.
--
-- Prerequisites:
--
--
-- In Parameters:
-- p_sii_details_id
-- p_effective_date
-- p_emp_social_security_info
-- p_object_version_number
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
Procedure chk_emp_social_security_info
  (p_sii_details_id           in number
  ,p_effective_date           in date
  ,p_emp_social_security_info in varchar2
  ,p_object_version_number    in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_old_age_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Old Age Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_old_age_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_old_age_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_old_age_contribution        in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_pension_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Pension Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_pension_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_pension_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_pension_contribution        in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_sickness_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Sickness Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_sickness_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_sickness_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_sickness_contribution       in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_work_injury_contribution >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Work Injury Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_work_injury_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_work_injury_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_work_injury_contribution    in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_labor_contribution >----------------------------|
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
--   p_sii_details_id
--   p_effective_date
--   p_labor_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_labor_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_labor_contribution          in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_health_contribution >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Health Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_health_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_health_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_health_contribution         in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_unemployment_contribution >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Unemployment Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_unemployment_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
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
Procedure chk_unemployment_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_unemployment_contribution   in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------< chk_old_age_cont_end_reason >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Old Age Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_old_age_contribution
--   p_old_age_cont_end_reason
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
Procedure chk_old_age_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_old_age_contribution        in varchar2
  ,p_old_age_cont_end_reason     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_pension_cont_end_reason >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Pension Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_pension_contribution
--   p_pension_cont_end_reason
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
Procedure chk_pension_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_pension_contribution        in varchar2
  ,p_pension_cont_end_reason     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_sickness_cont_end_reason >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Sickness Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_sickness_contribution
--   p_sickness_cont_end_reason
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
Procedure chk_sickness_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_sickness_contribution       in varchar2
  ,p_sickness_cont_end_reason    in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_work_injury_cont_end >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Work Injury Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_work_injury_contribution
--   p_work_injury_cont_end_reason
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
Procedure chk_work_injury_cont_end
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_work_injury_contribution    in varchar2
  ,p_work_injury_cont_end_reason in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

-- ----------------------------------------------------------------------------
-- |---------------< chk_labor_fund_cont_end_reason >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Fund Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_labor_contribution
--   p_labor_fund_cont_end_reason
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
Procedure chk_labor_fund_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_labor_contribution          in varchar2
  ,p_labor_fund_cont_end_reason  in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

-- ----------------------------------------------------------------------------
-- |------------------< chk_health_cont_end_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Health Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_health_contribution
--   p_health_cont_end_reason
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
Procedure chk_health_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_health_contribution         in varchar2
  ,p_health_cont_end_reason      in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_unemployment_cont_end >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Unemployment Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_unemployment_contribution
--   p_unemployment_cont_end_reason
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
Procedure chk_unemployment_cont_end
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_unemployment_contribution   in varchar2
  ,p_unemployment_cont_end_reason in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  );

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
  (p_rec                   in pay_psd_shd.g_rec_type
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
  (p_rec                     in pay_psd_shd.g_rec_type
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
  (p_rec                   in pay_psd_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_contribution_values >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure derives the various Contribution values when the 'Employee
-- Social Security Information' value is passed in.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_emp_social_security_info
--   p_effective_date
--
-- In/Out Parameters
--   p_old_age_contribution
--   p_pension_contribution
--   p_sickness_contribution
--   p_work_injury_contribution
--   p_labor_contribution
--   p_health_contribution
--   p_unemployment_contribution
--
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:h
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure get_contribution_values
  (p_effective_date in date
  ,p_emp_social_security_info in varchar2
  ,p_old_age_contribution      in out nocopy varchar2
  ,p_pension_contribution      in out nocopy varchar2
  ,p_sickness_contribution     in out nocopy varchar2
  ,p_work_injury_contribution  in out nocopy varchar2
  ,p_labor_contribution        in out nocopy varchar2
  ,p_health_contribution       in out nocopy varchar2
  ,p_unemployment_contribution in out nocopy varchar2);
--
--
end pay_psd_bus;

 

/

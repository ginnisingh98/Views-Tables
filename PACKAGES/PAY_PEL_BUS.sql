--------------------------------------------------------
--  DDL for Package PAY_PEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PEL_BUS" AUTHID CURRENT_USER as
/* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $          */
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
--    The primary key identified by p_element_link_id
--     already exists.
--
--  In Arguments:
--    p_element_link_id
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
(p_element_link_id                      in number
  ,p_associated_column1                   in varchar2 default null
  );
--
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_element_link_id
--     already exists.
--
--  In Arguments:
--    p_element_link_id
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

Function return_legislation_code
  (p_element_link_id                      in     number
  ) RETURN varchar2;

/* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_defaults >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    For the supplied element type id returns the Qualifying conditions,
--    Standard link flag and Mulitply Value flag if not supplied while calling
--    the create element link API.
--    Used for defaulting the values while creating a new element link
--
--  Prerequisites:
--    The primary key identified by p_element_type_id
--     already exists.
--
--  In Arguments:
--    p_element_type_id
--
--  Post Success:
--    Values are returned .
--
--  Post Failure:
--    Values won't be returned
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_defaults
  (p_element_type_id              in number
  ,p_qualifying_age               in out nocopy varchar2
  ,p_qualifying_length_of_service in out nocopy varchar2
  ,p_qualifying_units             in out nocopy varchar2
  ,p_multiply_value_flag          in out nocopy varchar2
  ,p_standard_link_flag           in out nocopy varchar2
  ,p_effective_date               in date
  );


 /* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_link_input_values >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Creates link input values
--
--  Prerequisites:
--    The primary key identified by p_element_type_id
--     already exists.
--
--  In Arguments:
--   p_element_type_id
--   p_element_link_id
--   p_effective_date
--
--  Post Success:
--    Input values created
--
--  Post Failure:
--    Error is raised
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

 Procedure chk_link_input_values
  (p_element_type_id in number,
   p_element_link_id in number,
   p_effective_date  in date
  );


 /* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_end_date >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Gets the least of effective end date among the following
--     1. its element type.
--     2. if the link is to a specific payroll, the end date of that payroll
--        OR
--        if the link is to any payroll, the maximum end date from all of the
--        payrolls
--     3. (start date - 1) of a future link which is not mutually exclusive.-- --
--  Prerequisites:
--
--
--  In Arguments:
--   p_element_type_id
--   p_element_link_id
--   p_effective_start_date
--   p_effective_end_date
--   p_organization_id
--   p_people_group_id
--   p_job_id
--   p_position_id
--   p_grade_id
--   p_location_id
--   p_link_to_all_payrolls_flag
--   p_payroll_id
--   p_employment_category
--   p_pay_basis_id
--   p_business_group_id
--
--  Post Success:
--    Returns End Date
--
--  Post Failure:
--    Error is raised
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

 Procedure chk_end_date
  (p_element_type_id 		in number,
   p_element_link_id 		in number,
   p_effective_start_date 	in date,
   p_effective_end_date 	in out nocopy date,
   p_organization_id 		in number,
   p_people_group_id 		in number,
   p_job_id 			in number,
   p_position_id 		in number,
   p_grade_id 			in number,
   p_location_id 		in number,
   p_link_to_all_payrolls_flag	in varchar2,
   p_payroll_id 		in number,
   p_employment_category 	in varchar2,
   p_pay_basis_id	        in number,
   p_business_group_id 		in number
  );

  /* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_standard_entries >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--  Creates standard entries
--
--  Prerequisites:
--    The primary key identified by p_element_type_id
--     already exists.
--
--  In Arguments:
--    p_business_group_id
--    p_element_link_id
--    p_element_type_id
--    p_effective_start_date
--    p_effective_end_date
--    p_payroll_id
--    p_link_to_all_payrolls_flag
--    p_job_id
--    p_grade_id
--    p_position_id
--    p_organization_id
--    p_location_id
--    p_pay_basis_id
--    p_employment_category
--    p_people_group_id
--
--  Post Success:
--    Standard entries created
--
--  Post Failure:
--    Error raised.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  Procedure chk_standard_entries
  ( p_business_group_id 	in number
   ,p_element_link_id 		in number
   ,p_element_type_id 		in number
   ,p_effective_start_date 	in date
   ,p_effective_end_date 	in date
   ,p_payroll_id 		in number
   ,p_link_to_all_payrolls_flag in varchar2
   ,p_job_id   			in number
   ,p_grade_id  		in number
   ,p_position_id 		in number
   ,p_organization_id 		in number
   ,p_location_id     		in number
   ,p_pay_basis_id      	in number
   ,p_employment_category 	in varchar2
   ,p_people_group_id    	in number
   );

  /* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_asg_link_usages >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--  Creates assignment link usages                                              --
--  Prerequisites:
--    The primary key identified by p_element_type_id
--     already exists.
--
--  In Arguments:
--  p_business_group_id
--  p_people_group_id
--  p_element_link_id
--  p_effective_start_date
--  p_effective_end_date
--
--  Post Success:
--    Assignment Link Usages created
--
--  Post Failure:
--    Error raised.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

   Procedure chk_asg_link_usages
   (p_business_group_id    in   number,
    p_people_group_id      in   number,
    p_element_link_id      in   number,
    p_effective_start_date in   date,
    p_effective_end_date   in   date);


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
--   function calls. Try and avoid using conditional branching logic.
--                                                                              -
-- Access Status:
--   Internal Row Handler Use Only.
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_rec                   in pay_pel_shd.g_rec_type
,p_effective_date        in date
,p_datetrack_mode        in varchar2
,p_validation_start_date in date
,p_validation_end_date   in date
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure controls the execution of all update business rules
-- validation.
--
-- Prerequisites:
--  This private procedure is called from upd procedure.
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
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pel_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                   in pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
  /* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_date_eff_delete >--------------------------|
-- ---------------------------------------------------------------------------
--
--  Description:
--  Checks if entries exists whose earliest date is beyond the new end date or
--  if balance adjustment entries exist at all beyond the new end date
--
--  Prerequisites:
--    The primary key identified by p_element_type_id
--     already exists.
--
--  In Arguments:
--  p_element_link_id
--  p_delete_mode
--  p_validation_start_date
--
--  Post Success:
--    Does not raise an error
--
--  Post Failure:
--    Error raised.
--
--  Access Status:
--    Internal Development Use Only.
--
-- ---------------------------------------------------------------------------
procedure chk_date_eff_delete
  (p_element_link_id in number,
   p_delete_mode in varchar2,
   p_validation_start_date in date
 );

end pay_pel_bus;

/

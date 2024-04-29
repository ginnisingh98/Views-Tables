--------------------------------------------------------
--  DDL for Package PER_APL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APL_BUS" AUTHID CURRENT_USER as
/* $Header: peaplrhi.pkh 120.1 2005/10/25 00:30:44 risgupta noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_termination_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the application termination reason
--
-- Pre Conditions:
--   None
--
-- In Parameters:
--   p_termination_reason
--   p_application_id
--   p_effective_date
--   p_object_version_number
--
-- Post Success:
--   If no violations of the business rules are detected then processing
--   continues.
--
-- Post Failure:
--   The following errors are detected and raised :
--      - termination reason does not exist in HR_LOOKUPS table
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_termination_reason
   (p_termination_reason    in per_applications.termination_reason%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_applications.object_version_number%TYPE);
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_date_received_person_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the person_id and date_received
--   attributes.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_person_id
--   p_business_group_id
--   p_date_received
--   p_projected_hire_date
--   p_date_end
--   p_object_version_number
--
-- Post Success:
--   If no violations of the business rules are detected then processing
--   continues.
--
-- Post Failure:
--   The following errors are detected and raised :
--      - person_id is mandatory
--      - The business_group_id for the specified person_id must be the same
--        as the application business_group_id
--      - system_person_type must be 'APL','EMP_APL','APL_EX_APL','EX_EMP_APL'
--      - date_received is mandatory
--      - date_received <= date_end
--      - If set date_received <= projected_hire_date
--      - date_received,person_id combination not exists in per_applications
--      - person_id,date_received foreign key check into per_people_f table
--
-- Developer Implementation Notes:
--   Update validation is covered by check_non_updateable_args.

-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_date_received_person_id
       (p_person_id             in per_applications.person_id%TYPE
       ,p_business_group_id     in per_applications.business_group_id%TYPE
       ,p_date_received         in per_applications.date_received%TYPE
       ,p_date_end              in per_applications.date_end%TYPE
       ,p_projected_hire_date   in per_applications.projected_hire_date%TYPE
       ,p_application_id        in per_applications.application_id%TYPE
       ,p_object_version_number in per_applications.object_version_number%TYPE
       );
--
-- ----------------------------------------------------------------------------
-- |----------------< chk_projected_hire_date >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validate the projected_hire_date attribute
--
-- Pre Conditions:
--   date_received validated
--
-- In Parameters:
--   p_date_received
--   p_projected_hire_date
--   p_application_id
--   p_object_version_number
--
-- Post Success:
--   If no violations of the business rules are detected then processing
--   continues.
--
-- Post Failure:
--   The following errors are detected and raised :
--      - If set projected_hire_date >= date_received

-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_projected_hire_date
   (p_date_received         in per_applications.date_received%TYPE
   ,p_projected_hire_date   in per_applications.projected_hire_date%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_object_version_number in per_applications.object_version_number%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_end >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the date_end attribute.
--
--   At present this attribute must be null, any attempt to save a non-null
--   date_end value will result in an error.
--
-- Pre Conditions:
--   None
--
-- In Parameters:
--   p_date_end
--   p_date_received
--   p_application_id
--   p_object_version_number
--
-- Post Success:
--   If no violation of the business rules are detected then processing
--   continues.
--
-- Post Failure:
--   The following errors are detected and raised :
--      - date_end not null
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_date_end
   (p_date_end              in per_applications.date_end%TYPE
   ,p_date_received         in per_applications.date_received%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_object_version_number in per_applications.object_version_number%TYPE
   );
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_apl_shd.g_rec_type
			 ,p_effective_date in date
			 ,p_validate_df_flex in boolean default true); -- bug 4689836
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_apl_shd.g_rec_type
			 ,p_effective_date in date);
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
-- Pre Conditions:
--   This private procedure is called from del procedure.
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_apl_shd.g_rec_type);
--
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific application
--
--  Prerequisites:
--    The application identified by p_application_id already exists.
--
--  In Arguments:
--    p_application_id
--
--  Post Success:
--    If the application is found this function will return the application's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the application does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_application_id              in number
  ) return varchar2;
--
end per_apl_bus;

 

/

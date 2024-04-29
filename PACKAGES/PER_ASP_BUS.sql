--------------------------------------------------------
--  DDL for Package PER_ASP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASP_BUS" AUTHID CURRENT_USER as
/* $Header: peasprhi.pkh 115.11 2002/12/05 13:03:31 apholt ship $ */
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
Procedure insert_validate(p_rec in per_asp_shd.g_rec_type);
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
Procedure update_validate(p_rec in per_asp_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_dates >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs basic checks on the assignment dates to ensure
--   that they conform with the business rules.
--   At the moment the only business rule enforced in this procedure is that
--   the end date must be >= the start date and that the start date is not
--   null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_assignment_dates
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_invalid_dates >----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that the start/end
--   dates of new/updated records cannot overlap both the start and the end
--   dates of existing records.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_sec_profile_assignment_id
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--   p_security_profile_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_invalid_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_duplicate_assignments >--------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that there must not
--   be assignments for the same U/R/A/SG but with a different SP.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_duplicate_assignments
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates >------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_sec_profile_assignment_id
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--   p_security_profile_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates >------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_sec_profile_assignment_id
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--   p_security_profile_id
--   p_start_date
--   p_end_date
--   p_clashing_id
--   p_clashing_ovn
--   p_clashing_start_date
--   p_clashing_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   The id of the record which overlaps is returned.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   ,p_clashing_id
                 OUT NOCOPY per_sec_profile_assignments.sec_profile_assignment_id%TYPE
   ,p_clashing_ovn
                 OUT NOCOPY per_sec_profile_assignments.object_version_number%TYPE
   ,p_clashing_start_date
                 OUT NOCOPY per_sec_profile_assignments.start_date%TYPE
   ,p_clashing_end_date
                 OUT NOCOPY per_sec_profile_assignments.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_exists >------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is a wrapper on the function of the same name, which
--   will raise an exception if the business rule check fails.  The
--   intention is that this procedure will be used from within the api
--   whereas the function is to be used in the form enabled interaction
--   with the user to allowing a prompt to ask if they want to modify their
--   record.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_assignment_exists
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_exists >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return TRUE is the specified assignment exists, or
--   FALSE otherwise.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--
-- Post Success:
--   FALSE is returned from the function.
--
-- Post Failure:
--   TRUE is returned from the function.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
FUNCTION chk_assignment_exists
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ) RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |-< get_security_group_id >------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function can be used to retrieve the security_group_id for a given
--   business group name.
--
-- Prerequisites:
--
-- In Parameters:
--   p_business_group_name - the business group name
--
-- Post Success:
--   The security group id for the business group is returned.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
FUNCTION get_security_group_id
   (p_business_group_id  IN NUMBER
   ) RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |-< Synchronize_Assignment_Dates >-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the dates in FND_USER_RESP_GROUPS
--   table are synchronized with the dates in the PER_SEC_PROFILE_ASSIGNMENTS
--   table.  The basic rule is that the start date in F_U_R_G is set to the
--   minimum start date in P_S_P_A, and the end date in F_U_R_G is set to the
--   maximum end date in P_S_P_A (or the end of time if a null entry for the
--   end date exists).
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_user_id
--   p_responsibility_id
--   p_application_id
--   p_security_group_id
--
-- Post Success:
--   The dates in FND_USER_RESP_GROUPS are synchronized and processing
--   continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE Synchronize_Assignment_Dates
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   );
--
end per_asp_bus;

 

/

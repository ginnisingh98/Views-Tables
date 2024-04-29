--------------------------------------------------------
--  DDL for Package OTA_CPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPR_BUS" AUTHID CURRENT_USER as
/* $Header: otcprrhi.pkh 120.0.12000000.1 2007/01/18 04:07:15 appldev noship $ */
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
--    The primary key identified by p_activity_version_id
--    p_prerequisite_course_id
--     already exists.
--
--  In Arguments:
--    p_activity_version_id
--    p_prerequisite_course_id
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
  (p_activity_version_id                  in number
  ,p_prerequisite_course_id               in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
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
--    The primary key identified by p_activity_version_id
--    p_prerequisite_course_id
--     already exists.
--
--  In Arguments:
--    p_activity_version_id
--    p_prerequisite_course_id
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
  (p_activity_version_id                  in     number
  ,p_prerequisite_course_id               in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_key >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the prerequisite course has already been
--   attached to the destination course
--
-- Prerequisites:
--   This private procedure is called from insert_validate.
--
-- In Parameters:
--   p_activity_version_id and p_prerequisite_course_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_unique_key
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_prereq_course_expiry >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the end date of prerequisite course
--   Prerequisite course end date must be greater than or equal to sysdate
--
-- Prerequisites:
--   This private procedure is called from insert_validate.
--
-- In Parameters:
--   p_prerequisite_course_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_prereq_course_expiry
  (
   p_prerequisite_course_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_course_start_date >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the start date of prerequisite and destination
--   courses
--   Prerequisite course start date must be less than or equal to destination
--   course start date.
--
-- Prerequisites:
--   This private procedure is called from insert_validate.
--
-- In Parameters:
--   p_activity_version_id and p_prerequisite_course_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_course_start_date
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_valid_classes_available >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates whether prerequisite course contains valid classes or not.
--   Course should have associated offering and valid classes. Valid classes
--   include classes  whose class type is SCHEDULED or SELFPACED and whose
--   class status is not Cancelled
--
-- Prerequisites:
--   This private procedure is called from insert_validate.
--
-- In Parameters:
--   p_prerequisite_course_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_valid_classes_available
  (p_prerequisite_course_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_course_chaining >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates whether specifying prerequisite course for a course results in
--   course chaining or not.
--
-- Prerequisites:
--   This private procedure is called from insert_validate.
--
-- In Parameters:
--   p_activity_version_id
--   p_prerequisite_course_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure check_course_chaining
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
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
  ,p_rec                          in ota_cpr_shd.g_rec_type
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
  ,p_rec                          in ota_cpr_shd.g_rec_type
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
  (p_rec              in ota_cpr_shd.g_rec_type
  );
--
end ota_cpr_bus;

 

/

--------------------------------------------------------
--  DDL for Package OTA_CCI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CCI_BUS" AUTHID CURRENT_USER as
/* $Header: otccirhi.pkh 120.1 2005/07/21 15:03 estreacy noship $ */
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
--    The primary key identified by p_category_usage_id
--    p_certification_id
--     already exists.
--
--  In Arguments:
--    p_category_usage_id
--    p_certification_id
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
  (p_category_usage_id                    in number
  ,p_certification_id                     in number
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
--    The primary key identified by p_category_usage_id
--    p_certification_id
--     already exists.
--
--  In Arguments:
--    p_category_usage_id
--    p_certification_id
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
  (p_category_usage_id                    in     number
  ,p_certification_id                     in     number
  ) RETURN varchar2;
--
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
  ,p_rec                          in ota_cci_shd.g_rec_type
  ,p_certification_id  in number
  ,p_category_usage_id in number
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
  ,p_rec                          in ota_cci_shd.g_rec_type
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
  (p_rec              in ota_cci_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_if_primary_category >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure Checks if the given Category is Primary for the
--   certification.
--
-- Prerequisites:
--   This private procedure is called from insertValidate and UpdateValidate
--
-- In Parameters:
--   certification_id and Category_usage_id
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
Procedure check_if_primary_category
 (
    p_certification_id  in  number
   ,p_category_usage_id    in  number
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_multiple_primary_ctgr >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if there are multiple Primary Categories.
--   validation.
--
-- Prerequisites:
--   This private procedure is called from insertValidate and UpdateValidate
--
-- In Parameters:
--   certification_id
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
Procedure check_multiple_primary_ctgr
  (
   p_certification_id  in  number
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_start_end_dates >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the sStart and End Dates for the inclusion.
--
-- Prerequisites:
--   This private procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   StartDate and EndDate for the Inclusion.
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
Procedure check_start_end_dates
  (
   p_start_date     in     date
  ,p_end_date       in     date
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_key >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the Category has already been attached to
--   the certification
--
-- Prerequisites:
--   This private procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   certification_id and Category_usage_id
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
   p_certification_id in  number
  ,p_category_usage_id   in  number
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_category_dates >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the start and end date are within the
--   category dates.
--
-- Prerequisites:
--   This private procedure is called from insert_validate and update_validate.
--
-- In Parameters:
--   p_category_usage_id  - Category Usage Id
--   p_start_date         - Start Date Active for the Inclusion
--   p_end_date           - End Date Active for the Inclusion
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
Procedure check_category_dates
  (
   p_category_usage_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  );
--
--
end ota_cci_bus;

 

/

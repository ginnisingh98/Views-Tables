--------------------------------------------------------
--  DDL for Package OTA_AVT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AVT_BUS" AUTHID CURRENT_USER as
/* $Header: otavtrhi.pkh 120.0 2005/05/29 07:02:23 appldev noship $ */
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
--     already exists.
--
--  In Arguments:
--    p_activity_version_id
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
--    The primary key identified by p_activity_version_id
--     already exists.
--
--  In Arguments:
--    p_activity_version_id
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
  ,p_language                             in     varchar2
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
  ,p_rec                          in ota_avt_shd.g_rec_type
  ,p_activity_version_id          in number
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
  ,p_rec                          in ota_avt_shd.g_rec_type
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
  (p_rec              in ota_avt_shd.g_rec_type
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure sets the value required to perform the validation for the
--    MLS widget.
--
-- Prerequisites:
--   This procedure is called from from Translations trigger of MLS block.
--
-- In Parameters:
--  Business_Group_id, Activity_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS block Translations trigger.
PROCEDURE set_translation_globals
  (p_business_group_id              in number
  ,p_activity_id                    in number
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the MLS widget.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_activity_version_id            in number
  ,p_language                       in varchar2
  ,p_version_name                   in varchar2
  ,p_description		    in varchar2
  ,p_intended_audience		    in varchar2
  ,p_objectives                     in varchar2
  ,p_keywords                       in varchar2
  ,p_business_group_id              in number default null
  ,p_activity_id                    in number default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_unique_version_name >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the uniqueness of a name.
--
-- Prerequisites:
--   This procedure is called from from Validate_translation.
--
-- In Parameters:
--  Business_group_id, Name, Activity_id, Language
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   and returns the error status
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
Procedure check_unique_version_name
  (
   p_business_group_id in number default null
  ,p_activity_id       in number default null
  ,p_version_name      in varchar2
  ,p_activity_version_id in number
  ,p_language          in varchar2
  ) ;
--
end ota_avt_bus;

 

/

--------------------------------------------------------
--  DDL for Package IRC_CMP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMP_BUS" AUTHID CURRENT_USER as
/* $Header: ircmprhi.pkh 120.0 2007/11/19 11:40:35 sethanga noship $ */
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
--    The primary key identified by p_communication_property_id
--     already exists.
--
--  In Arguments:
--    p_communication_property_id
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
  (p_communication_property_id            in number
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
--    The primary key identified by p_communication_property_id
--     already exists.
--
--  In Arguments:
--    p_communication_property_id
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
  (p_communication_property_id            in     number
  ) RETURN varchar2;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_default_comm_status >------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'status' exists in the lookup
--   IRC_COMM_DEFAULT_COMM_STATUS.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   status                     varchar2(50) default communication status
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_status does not exist in lookup IRC_COMM_DEFAULT_COMM_STATUS
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_default_comm_status(p_status in varchar2,
                                  p_communication_property_id in number,
                                  p_effective_date in date,
				  p_object_version_number in number);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_allow_add_recipients >-----------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'allow_add_recipients' exists in the lookup
--   IRC_COMM_ALLOW_ADD_RECIPIENTS.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   allow_add_recipients       varchar2(50) allow add recipients flag
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_flag does not exist in lookup IRC_COMM_ALLOW_ADD_RECIPIENTS.
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_allow_add_recipients(p_allow_add_recipients in varchar2,
                                   p_communication_property_id in number,
                                   p_effective_date in date,
				   p_object_version_number in number);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_auto_notification_flag  >--------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'auto_notification_flag' exists in the lookup
--   YES_NO.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   auto_notification_flag     varchar2(1)  auto_notification_flag
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_auto_notification_flag does not exist in lookup YES_NO
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_auto_notification_flag(p_auto_notification_flag in varchar2,
                                     p_communication_property_id in number,
                                     p_effective_date in date,
                                     p_object_version_number in number);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_default_moderator >-----------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'default_moderator' exists in the lookup
--   IRC_COMM_DEFAULT_MODERATOR.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   default_moderator          varchar2(50) default_moderator
--   communication_property_id  number(15)   PK of irc_comm_properties
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_default_moderator does not exist in lookup IRC_COMM_DEFAULT_MODERATOR.
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_default_moderator(p_default_moderator in varchar2,
                                p_communication_property_id in number,
                                p_effective_date in date,
                                p_object_version_number in number) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure-
--  1) that object_id exists in PER_ALL_VACANCIES
--     when the object_type is 'VACANCY'
--  2) that combination of (object_id,object_type) is
--     unique.

-- Pre Conditions:
--
-- In Arguments:
--  p_object_id
--  p_object_type
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_id
  (p_object_id in irc_comm_properties.object_id%TYPE,
   p_object_type in irc_comm_properties.object_type%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_type has one of the following
--   values :
--   'VACANCY'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_object_type
--
-- Post Success:
--  Processing continues if object_type is valid.
--
-- Post Failure:
--   An application error is raised if object_type is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_type
  (p_object_type in irc_comm_properties.object_type%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure groups calls to various business-rules validation procedures
--   which are commonly called by insert_validate and update_validate procedures.
--
-- Prerequisites:
--   This private procedure is called from insert_validate and update_validate
--   procedures.
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
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmp_shd.g_rec_type
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
  ,p_rec                          in irc_cmp_shd.g_rec_type
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
  ,p_rec                          in irc_cmp_shd.g_rec_type
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
  (p_rec              in irc_cmp_shd.g_rec_type
  );
--
end irc_cmp_bus;

/

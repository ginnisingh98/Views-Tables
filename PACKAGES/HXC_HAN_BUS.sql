--------------------------------------------------------
--  DDL for Package HXC_HAN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAN_BUS" AUTHID CURRENT_USER as
/* $Header: hxchanrhi.pkh 120.0 2006/06/19 08:36:25 gsirigin noship $ */
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
--    The primary key identified by p_comp_notification_id
--    p_object_version_number
--     already exists.
--
--  In Arguments:
--    p_comp_notification_id
--    p_object_version_number
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
  (p_comp_notification_id                  in number
  ,p_object_version_number                in number
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
--    The primary key identified by p_comp_notification_id
--    p_object_version_number
--     already exists.
--
--  In Arguments:
--    p_comp_notification_id
--    p_object_version_number
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
  (p_comp_notification_id                  in     number
  ,p_object_version_number                in     number
  ) RETURN varchar2;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_notification_action_code >---------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks if the action code belongs to the set of notifications i.e It
-- must have one of these values - APPROVED, AUTO-APPROVE, ERROR,REJECTED,
-- REQUEST-APPROVAL, REQUEST-APPROVAL-RESEND, SUBMISSION,TRANSFER.
--
--  Prerequisites:
--    Notification action code must be passed.
--
--  In Arguments:
--    p_notification_action_code
--
--
--  Post Success:
--    Processing continues if the action code passed belongs to the list.
--
--  Post Failure:
--    An error is raised if the value does not belong to the list.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_notification_action_code
( p_notification_action_code in varchar2
);


--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_notification_recip_code >---------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks if the recipient code belongs to the set of recipients i.e It
-- must have one of these values - ADMIN, APPROVER, ERROR-ADMIN,PREPARER,
-- SUPERVISOR, WORKER.
--
--  Prerequisites:
--    Notification recipient code must be passed.
--
--  In Arguments:
--    p_notification_recipient_code
--
--
--  Post Success:
--    Processing continues if the recipient code passed belongs to the list.
--
--  Post Failure:
--    An error is raised if the value does not belong to the list.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_notification_recip_code
( p_notification_recipient_code in varchar2
) ;




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
  (p_rec                          in hxc_han_shd.g_rec_type
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
  (p_rec                          in hxc_han_shd.g_rec_type
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
  (p_rec              in hxc_han_shd.g_rec_type
  );
--
end hxc_han_bus;

 

/

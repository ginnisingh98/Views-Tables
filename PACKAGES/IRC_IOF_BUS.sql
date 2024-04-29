--------------------------------------------------------
--  DDL for Package IRC_IOF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOF_BUS" AUTHID CURRENT_USER as
/* $Header: iriofrhi.pkh 120.1 2005/09/29 09:32 mmillmor noship $ */
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
--    The primary key identified by p_offer_id
--     already exists.
--
--  In Arguments:
--    p_offer_id
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
  (p_offer_id                             in number
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
--    The primary key identified by p_offer_id
--     already exists.
--
--  In Arguments:
--    p_offer_id
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
  (p_offer_id                             in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_multiple_fields_updated >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that not more than one field has been updated in the
--   offer record.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   All the IRC_OFFERS table fields except object_version_number and respondent_id
--
-- Post Success:
--   If only one field has been updated, p_mutiple_fields_updated will be set to
--   'false'. If multiple fields have been updated, p_mutiple_fields_updated will be
--   set to 'true'.
--
-- Post Failure:
--   None
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_fields_updated
  ( p_offer_id                     in   number
   ,p_offer_status                 in   varchar2  default null
   ,p_discretionary_job_title      in   varchar2  default null
   ,p_offer_extended_method        in   varchar2  default null
   ,p_expiry_date                  in   date      default null
   ,p_proposed_start_date          in   date      default null
   ,p_offer_letter_tracking_code   in   varchar2  default null
   ,p_offer_postal_service         in   varchar2  default null
   ,p_offer_shipping_date          in   date      default null
   ,p_applicant_assignment_id      in   number    default null
   ,p_offer_assignment_id          in   number    default null
   ,p_address_id                   in   number    default null
   ,p_template_id                  in   number    default null
   ,p_offer_letter_file_type       in   varchar2  default null
   ,p_offer_letter_file_name       in   varchar2  default null
   ,p_attribute_category           in   varchar2  default null
   ,p_attribute1                   in   varchar2  default null
   ,p_attribute2                   in   varchar2  default null
   ,p_attribute3                   in   varchar2  default null
   ,p_attribute4                   in   varchar2  default null
   ,p_attribute5                   in   varchar2  default null
   ,p_attribute6                   in   varchar2  default null
   ,p_attribute7                   in   varchar2  default null
   ,p_attribute8                   in   varchar2  default null
   ,p_attribute9                   in   varchar2  default null
   ,p_attribute10                  in   varchar2  default null
   ,p_attribute11                  in   varchar2  default null
   ,p_attribute12                  in   varchar2  default null
   ,p_attribute13                  in   varchar2  default null
   ,p_attribute14                  in   varchar2  default null
   ,p_attribute15                  in   varchar2  default null
   ,p_attribute16                  in   varchar2  default null
   ,p_attribute17                  in   varchar2  default null
   ,p_attribute18                  in   varchar2  default null
   ,p_attribute19                  in   varchar2  default null
   ,p_attribute20                  in   varchar2  default null
   ,p_attribute21                  in   varchar2  default null
   ,p_attribute22                  in   varchar2  default null
   ,p_attribute23                  in   varchar2  default null
   ,p_attribute24                  in   varchar2  default null
   ,p_attribute25                  in   varchar2  default null
   ,p_attribute26                  in   varchar2  default null
   ,p_attribute27                  in   varchar2  default null
   ,p_attribute28                  in   varchar2  default null
   ,p_attribute29                  in   varchar2  default null
   ,p_attribute30                  in   varchar2  default null
   ,p_mutiple_fields_updated       out nocopy boolean
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
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
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
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
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
  (p_rec              in irc_iof_shd.g_rec_type
  );
--
end irc_iof_bus;

 

/

--------------------------------------------------------
--  DDL for Package OTA_NHS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_NHS_BUS" AUTHID CURRENT_USER as
/* $Header: otnhsrhi.pkh 120.0 2005/05/29 07:26:54 appldev noship $ */
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
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
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
  (p_nota_history_id                           in number
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
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
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
  (p_nota_history_id                           in     number
  ) RETURN varchar2;
--


-- ---------------------------------------------------------------------------
-- |---------------------< chk_df>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_rec
--
--
--  Post Success:
--    The descriptive flexfield will be saved.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure chk_df
  (p_rec in ota_nhs_shd.g_rec_type );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in ota_nhs_shd.g_rec_type);


--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_organization_id  >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the organization_id is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_organization_id
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_organization_id
  (p_nota_history_id                in number
   ,p_organization_id         in number
   ,p_business_group_id       in number
   ,p_effective_date       in date) ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_customer_id  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the customer_id is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_customer_id
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_customer_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_effective_date       in date) ;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_person_id  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the person_id is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_customer_id
-- p_organization_id
--    p_person_id
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_person_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_organization_id         in number
   ,p_person_id            in number
   ,p_business_group_id       in number
   ,p_effective_date       in date) ;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_contact_id  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the contact_id is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_customer_id
-- p_organization_id
--    p_person_id
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure chk_contact_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_organization_id         in number
   ,p_contact_id           in number
   ,p_effective_date       in date) ;



-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_status  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the status is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_status
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_status
  (p_nota_history_id             in number
   ,p_status            in varchar2
   ,p_effective_date       in date);


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_type  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the type valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_type
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_type
  (p_nota_history_id             in number
   ,p_type           in varchar2
   ,p_effective_date       in date);


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_duration_unit  >----------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the duration unit is valid
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_duration_units
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_duration_unit
  (p_nota_history_id             in number
   ,p_duration_units          in varchar2
   ,p_effective_date       in date) ;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_comb_duration  >----------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check whether the both has to be null or both not null
--
--  Prerequisites:
--    The primary key identified by p_nota_history_id
--     already exists.
--
--  In Arguments:
--    p_nota_history_id
--    p_duration_units
-- p_duration
--    p_effective_date
--
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the only one has value.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_comb_duration
  (p_nota_history_id             in number
   ,p_duration             in number
   ,p_duration_units          in varchar2
   ,p_effective_date       in date) ;

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_profile_value  >------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Get Cross Business Group profile and Single Business Group profile
--
--  Prerequisites:
--    None
--
--  In Arguments:
--    None
--
--  out Arguments:
--    p_cross_business_group
--    p_single_busines_group_id
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the only one has value.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure get_profile_value
  (p_cross_business_group      out nocopy varchar2
   ,p_single_business_group_id    out nocopy varchar2);

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
Procedure insert_validate(p_effective_date in date,
                          p_rec in ota_nhs_shd.g_rec_type);
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
Procedure update_validate(p_effective_date in date,
                          p_rec in ota_nhs_shd.g_rec_type);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_nhs_shd.g_rec_type);
--
end ota_nhs_bus;

 

/

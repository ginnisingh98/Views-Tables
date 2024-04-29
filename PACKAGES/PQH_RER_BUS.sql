--------------------------------------------------------
--  DDL for Package PQH_RER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RER_BUS" AUTHID CURRENT_USER as
/* $Header: pqrerrhi.pkh 120.0 2005/10/06 14:53 srajakum noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--    It is only valid to call this procedure when the primary key
--    is within a buisiness group context.
--
--  Prerequisites:
--    The primary key identified by p_rate_element_relation_id
--     already exists.
--
--  In Arguments:
--    p_rate_element_relation_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--    An error is also raised when the primary key data is outside
--    of a buisiness group context.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_rate_element_relation_id             in number
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
--    The primary key identified by p_rate_element_relation_id
--     already exists.
--
--  In Arguments:
--    p_rate_element_relation_id
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
  (p_rate_element_relation_id             in     number
  ) RETURN varchar2;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_criteria_rate_element_id>----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_criteria_rate_element_id (p_rate_element_relation_id          in number,
                            p_criteria_rate_element_id          in number,
                            p_object_version_number in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rel_element_type_id>----------------------------|
-- ----------------------------------------------------------------------------
--

Procedure chk_rel_element_type_id (p_rate_element_relation_id          in number,
                            p_rel_element_type_id          in number,
                            p_object_version_number in number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rel_input_value_id>----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_rel_input_value_id (p_rate_element_relation_id          in number,
                            p_rel_input_value_id          in number,
                            p_object_version_number in number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_business_group_id>----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_business_group_id  (p_rate_element_relation_id          in number,
                            p_business_group_id           in number,
                            p_object_version_number in number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_relation_type_cd>----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_relation_type_cd
                           (p_rate_element_relation_id       in number,
                            p_relation_type_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number);

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
  ,p_rec                          in pqh_rer_shd.g_rec_type
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
  ,p_rec                          in pqh_rer_shd.g_rec_type
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
  (p_rec              in pqh_rer_shd.g_rec_type
  );
--
end pqh_rer_bus;

 

/

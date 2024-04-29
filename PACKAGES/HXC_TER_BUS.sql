--------------------------------------------------------
--  DDL for Package HXC_TER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TER_BUS" AUTHID CURRENT_USER as
/* $Header: hxcterrhi.pkh 120.0 2005/05/29 05:59:43 appldev noship $ */
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_ter_shd.g_rec_type
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
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_ter_shd.g_rec_type
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in hxc_ter_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_start_date >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid start_date
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   start_date
--   end_date
--   object_version_number
--
-- Post Success:
--   Processing continues if the start_date is entered and is valid
--
-- Post Failure:
--   An application error is raised if the start_date is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_start_date
  (
   p_name       in hxc_time_entry_rules.name%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ,p_ovn	in hxc_time_entry_rules.object_version_number%TYPE
  ,p_bg_id NUMBER
  ,p_legislation_code VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_end_date >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid end_date
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   start_date
--   end_date
--   object_version_number
--
-- Post Success:
--   Processing continues if the start_date is entered and is valid
--
-- Post Failure:
--   An application error is raised if the start_date is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_end_date
  (
   p_name       in hxc_time_entry_rules.name%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ,p_ovn	in hxc_time_entry_rules.object_version_number%TYPE
  ,p_bg_id NUMBER
  ,p_legislation_code VARCHAR2
  );
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_code >----------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate the legislation_code against the FND_TERRITORIES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_code
       (p_business_group_id           in      number,
        p_legislation_code           in      varchar2
       );
--
end hxc_ter_bus;

 

/

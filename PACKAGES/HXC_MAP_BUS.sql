--------------------------------------------------------
--  DDL for Package HXC_MAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAP_BUS" AUTHID CURRENT_USER as
/* $Header: hxcmaprhi.pkh 120.0.12010000.1 2008/07/28 11:15:59 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid mapping name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   mapping_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name       in hxc_mappings.name%TYPE
  ,p_mapping_id in hxc_mappings.mapping_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure carries out delete time referential integrity checks
--   to ensure that a mapping or a mapping component is not being used
--   in an approval rule, deposit process or retrieval process.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping_id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the rule is being used.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_mapping_id in hxc_mappings.mapping_id%TYPE
  );
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
  (p_rec                          in hxc_map_shd.g_rec_type
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
  (p_rec                          in hxc_map_shd.g_rec_type
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
  (p_rec              in hxc_map_shd.g_rec_type
  );
--
end hxc_map_bus;

/

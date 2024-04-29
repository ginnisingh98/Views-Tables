--------------------------------------------------------
--  DDL for Package HXC_HTC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTC_BUS" AUTHID CURRENT_USER as
/* $Header: hxchtcrhi.pkh 120.0.12010000.1 2008/07/28 11:13:07 appldev ship $ */

TYPE r_ter_record IS RECORD ( ter_id hxc_time_entry_rules.time_entry_rule_id%TYPE
                             ,attribute varchar2(20) );

TYPE t_ter_table IS TABLE OF r_ter_record INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_time_category >-------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures time category is not duplicated

-- Pre Conditions:
--   None

-- In Arguments:
--   name
--   time_category_id

-- Post Success:
--   Processing continues if the name business rules have not been violated

-- Post Failure:
--   An application error is raised if the name is not valid

-- ----------------------------------------------------------------------------
Procedure chk_time_category
  (
   p_time_category_id   number,
   p_time_category_name varchar2
  );


-- ----------------------------------------------------------------------------
-- |------------------< chk_tc_ref_integrity >--------------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This function checks to see if a time category is referenced elsewhere
--   in the system

-- In Arguments:
--   p_time_category_id

-- Post Success:
--   Returns TRUE if the time category IS NOT referenced

-- Post Failure:
--   Returns FALSE if the time category IS referenced

-- ----------------------------------------------------------------------------

FUNCTION chk_tc_ref_integrity ( p_time_category_id NUMBER ) RETURN BOOLEAN;



-- ----------------------------------------------------------------------------
-- |-----------------< get_tc_ref_integrity_list >----------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This function returns a list of Time Entry Rules which the time category
--   is being used in

-- In Arguments:
--   p_time_category_id

-- Post Success:
--   t_ter_table

-- Post Failure:
--   empty t_ter_table

-- ----------------------------------------------------------------------------

FUNCTION get_tc_ref_integrity_list ( p_time_category_id NUMBER ) RETURN t_ter_table;



-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure carries out delete time referential integrity checks
--   to ensure that a time category is not being used by another time category
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   time_category_id
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
   p_time_category_id number
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
  (p_rec                          in hxc_htc_shd.g_rec_type
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
  (p_rec                          in hxc_htc_shd.g_rec_type
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
  (p_rec              in hxc_htc_shd.g_rec_type
  );
--
end hxc_htc_bus;

/

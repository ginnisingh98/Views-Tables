--------------------------------------------------------
--  DDL for Package HXC_EGC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_EGC_BUS" AUTHID CURRENT_USER as
/* $Header: hxcegcrhi.pkh 120.0 2005/05/29 05:30:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_entity_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity_id is entered
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity id
--
-- Post Success:
--   Processing continues if the mapping component id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the mapping component id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_id
  (
   p_entity_id   in hxc_entity_group_comps.entity_id%TYPE
,  p_entity_type in hxc_entity_group_comps.entity_type%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_entity_group_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity group id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity group id
--
-- Post Success:
--   Processing continues if the entity id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the entity id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_group_id
  (
   p_entity_group_id  in hxc_entity_groups.entity_group_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_entity_type >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity type
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity type
--
-- Post Success:
--   Processing continues if the entity id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the entity id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_type
  (
   p_entity_type  in hxc_entity_group_comps.entity_type%TYPE
,  p_effective_date in DATE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_egc_shd.g_rec_type
  ,p_called_from_form             in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_egc_shd.g_rec_type
  ,p_called_from_form             in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in hxc_egc_shd.g_rec_type
  );
--
end hxc_egc_bus;

 

/

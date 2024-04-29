--------------------------------------------------------
--  DDL for Package PQH_TCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCT_BUS" AUTHID CURRENT_USER as
/* $Header: pqtctrhi.pkh 120.2.12000000.2 2007/04/19 12:48:28 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Additional Checks >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- ----------------------------------------------------------------------------
-- |-------------------------<chk_identifiers_count>--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure validates if the count of list and member identifiers
--   satisfy the set business rules.
--
PROCEDURE chk_identifiers_count(p_transaction_category_id  in   number,
                                p_routing_type             in   varchar2,
                                p_min_member_identifiers   in   number,
                                p_max_list_identifiers     in   number,
                                p_max_member_identifiers   in   number);

--
-- Description:
--   This procedure checks if active transactions exists for the transaction
--   category
--
FUNCTION chk_active_transaction_exists(p_short_name in VARCHAR2,
                                       p_transaction_category_id IN NUMBER)
RETURN VARCHAR2;
--
--
FUNCTION chk_active_transaction_exists(p_transaction_category_id IN NUMBER)
RETURN VARCHAR2;
--
PROCEDURE chk_valid_routing_exists(p_transaction_category_id IN NUMBER,
                                   p_routing_type            IN VARCHAR2);
--
Procedure get_routing_category_name(p_routing_category_id     in number,
                                p_routing_category_name  out nocopy varchar2);
  --
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
Procedure insert_validate(p_rec in pqh_tct_shd.g_rec_type
                         ,p_effective_date in date);
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
Procedure update_validate(p_rec in pqh_tct_shd.g_rec_type
                         ,p_effective_date in date);
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
Procedure delete_validate(p_rec in pqh_tct_shd.g_rec_type
                         ,p_effective_date in date);
--
end pqh_tct_bus;

 

/

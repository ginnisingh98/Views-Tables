--------------------------------------------------------
--  DDL for Package PQH_RCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RCT_BUS" AUTHID CURRENT_USER as
/* $Header: pqrctrhi.pkh 120.0 2005/05/29 02:25:48 appldev noship $ */
--
Procedure chk_universal_routing_exists(p_transaction_category_id in number,
                                       p_default_flag            in varchar2);
--
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in pqh_rct_shd.g_rec_type
                          ,p_effective_date in date);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in pqh_rct_shd.g_rec_type
                          ,p_effective_date in date);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in pqh_rct_shd.g_rec_type
                          ,p_effective_date in date);
-- ---------------------------------------------------------------------------+
Function chk_if_routing_cat_exists
(p_transaction_category_id in pqh_transaction_categories.transaction_category_id%type,
 p_routing_type            in pqh_transaction_categories.member_cd%type)

RETURN BOOLEAN;
-- ---------------------------------------------------------------------------+
end pqh_rct_bus;

 

/

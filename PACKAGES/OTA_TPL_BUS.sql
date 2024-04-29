--------------------------------------------------------
--  DDL for Package OTA_TPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPL_BUS" AUTHID CURRENT_USER as
/* $Header: ottpl01t.pkh 115.0 99/07/16 00:56:02 porting ship $ */
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
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
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
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tpl_shd.g_rec_type);
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
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
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
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tpl_shd.g_rec_type);
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
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
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
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tpl_shd.g_rec_type);
-- ici tpl.h
--***********************************************************
--			TPL: ADDITIONAL PUBLIC PROCEDURES
--***********************************************************
-- Version    Date     Author    	Reason
-- 10.9     19Apr95    lparient.FR	Suppressed close_down_price_list
--					Added change_price_list_dates
--***********************************************************
--
procedure copy_price_list (
        p_tpl_id in number,
        p_new_tpl_name in varchar2,
        p_new_startdate in date,
	p_new_enddate in date,
        p_price_increase in number,
        p_rounding_direction in varchar2,
	p_rounding_factor in number);
--
procedure change_price_list_dates(
        p_price_list_id in number,
        p_new_startdate in date,
        p_new_enddate in date,
	p_change_entries in char );
--
procedure check_single_name (
	p_price_list_id in number
	,p_name		in varchar2
	,p_business_group_id in number );
--
--**********************************************************
--**********************************************************
--
end ota_tpl_bus;

 

/

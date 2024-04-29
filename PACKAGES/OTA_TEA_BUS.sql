--------------------------------------------------------
--  DDL for Package OTA_TEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TEA_BUS" AUTHID CURRENT_USER as
/* $Header: ottea01t.pkh 115.2 2002/11/29 10:05:15 arkashya ship $ */
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
Procedure insert_validate(p_rec in ota_tea_shd.g_rec_type
                         ,p_association_type in varchar2);
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
Procedure update_validate(p_rec in ota_tea_shd.g_rec_type
                         ,p_association_type in varchar2);
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
Procedure delete_validate(p_rec in ota_tea_shd.g_rec_type);
-- ----------------------------------------------------------------------------
Procedure client_check_event_customer (
	 p_event_association_id in number
	,p_event_id in number
	,p_customer_id in number);
-- ----------------------------------------------------------------------------
function derive_standard_price (
	 p_event_id		in number
	,p_business_group_id	in number
	,p_currency_code	in varchar2
	,p_booking_deal_type	in varchar2
	,p_customer_total_delegates in number
	,p_session_date		in date
	)
return number;
-- ----------------------------------------------------------------------------
function new_price_list_hit
	(p_event_id                     IN number
	,p_business_group_id            IN number
	,p_customer_total_delegates     IN number
	,p_customer_total_delegates_old IN number
	,p_session_date                 IN date
	,p_booking_deal_type            IN varchar2
	,p_booking_deal_id              IN number
	)
return boolean;
-- ----------------------------------------------------------------------------
function check_pre_purchase_agreement
	(p_booking_deal_id              IN number,
	 p_event_id                     IN number,
	 p_money_amount                 IN number,
	 p_finance_header_id            IN number) return boolean;
-- ----------------------------------------------------------------------------
function number_of_delegates (
	p_event IN number
	,p_customer IN number )
return number;
pragma restrict_references (number_of_delegates, WNPS,WNDS);
-- ----------------------------------------------------------------------------
--
end ota_tea_bus;

 

/

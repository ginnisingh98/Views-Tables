--------------------------------------------------------
--  DDL for Package OTA_PLE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PLE_BUS" AUTHID CURRENT_USER as
/* $Header: otple01t.pkh 115.0 99/07/16 00:53:01 porting ship $ */
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
Procedure insert_validate(p_rec in ota_ple_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< handle_leap_years >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to handle price list entries so that the leap years
-- are handled correctly.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_start_date = Start date of new price list.
--   p_dates_difference = Amount of days to add to new start date.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should be used for all conditions where a date is
-- calculated by using a number of days added to a certain date.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure handle_leap_years(p_start_date in out date,
                            p_dates_difference  number,
                            p_difference        number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< consider_leap_years >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to calculate how many leap days occur within a
-- certain time period.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_old_tpl_id = Event Id.
--   p_dates_difference = Amount of days to add to start date of event id.
--   p_difference = Amount of leap days in old start date to new start date
--   period.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should be used for all conditions where a date is
-- calculated by using a number of days added to a certain date.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure consider_leap_years(p_old_tpl_id        number,
                              p_dates_difference  in out number);
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
Procedure update_validate(p_rec in ota_ple_shd.g_rec_type);
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
Procedure delete_validate(p_rec in ota_ple_shd.g_rec_type);
--
-- ici insert ple.h
--
--****************************************************************************
--				PLE SPECIFICATION
--				ADDITIONAL PUBLIC PROCEDURES
--****************************************************************************
--
-- Version    Date        Author    	Reason
--  10.7     19Apr95    lparient.FR	Added widen_entries_dates
--				Added select_entries parameter in copy_entries
--
-- ----------------------------------------------------------------------------
-- |------------------------------< copy_price >------------------------------|
-- ----------------------------------------------------------------------------
-- Written by Kurt Fisher (kfisher.)
--
-- PUBLIC
-- Description:
--   Copies all pricelist entry information from a given activity version to
--   another activity version.
--
Procedure copy_price
  (
   p_activity_version_from in  number
  ,p_activity_version_to   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< copy_price_list_entries >------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--	Procedure called from client side.
--
procedure copy_price_list_entries (
        p_price_list_id         number,
        p_increase_date         date,
	p_enddate		date,
        p_increase_rate         number,
        p_round_direction       varchar2,
        p_round_factor          number,
	p_select_entries	char,
	p_starting_from		date
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< copy_price_list >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--  	Procedure called from OTA_TPL_BUS
--
procedure copy_price_list(
	p_old_price_list_id	    in number,
	p_new_price_list_id	    in number,
        p_increase_rate         number,
        p_round_direction       varchar2,
        p_round_factor          number,
	p_old_startdate	in date,
	p_new_startdate	in date,
	p_old_enddate		in date,
	p_new_enddate		in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------< widen_entries_date >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--      Procedure called from OTA_TPL_BUS
--
procedure widen_entries_dates (
	p_price_list_id 	in number
	,p_old_startdate	in date
	,p_new_startdate	in date
	,p_old_enddate		in date
	,p_new_enddate		in date
);
--
--****************************************************************************
--****************************************************************************
--
--
end ota_ple_bus;

 

/

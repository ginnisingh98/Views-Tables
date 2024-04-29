--------------------------------------------------------
--  DDL for Package OTA_TPC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_UTIL" AUTHID CURRENT_USER as
/* $Header: ottpcutl.pkh 120.1 2005/06/24 03:20:17 sbairagi noship $ */
--
function calc_amount(
  p_item_type_usage_id in number,
  p_business_group_id in number,
  p_training_plan_id in number,
  p_organization_id in number,
  p_period_start_date in date,
  p_period_end_date in date,
  p_plan_status in varchar2,
  p_measurement_type_id in number,
  p_cost_level in varchar2,
  p_event_id in number,
  p_delegate_booking_id in number,
  p_to_currency in varchar2,
  p_payroll_id in number)
return number;
--
end OTA_TPC_UTIL;

 

/

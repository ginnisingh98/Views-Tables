--------------------------------------------------------
--  DDL for Package OTA_TFL_API_BUSINESS_RULES3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFL_API_BUSINESS_RULES3" AUTHID CURRENT_USER as
/* $Header: ottfl04t.pkh 115.0 99/07/16 00:55:53 porting ship $ */
--
--
-- ---------------------------------------------------------------------------
-- |--------------------< check_customer_booking_deal >---------------------------|
-- ---------------------------------------------------------------------------
procedure check_customer_booking_deal (
	 p_finance_header_id		in number
	,p_booking_deal_id		in number
   );
--
end ota_tfl_api_business_rules3;

 

/

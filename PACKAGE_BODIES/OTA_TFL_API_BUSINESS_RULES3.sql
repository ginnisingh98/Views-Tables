--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_BUSINESS_RULES3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_BUSINESS_RULES3" as
/* $Header: ottfl04t.pkb 115.2 99/07/16 00:55:49 porting ship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tfl_api_business_rules3.';
g_standard		varchar2(40)    := 'STANDARD';
g_pre_payment		varchar2(40)    := 'PRE-PAYMENT';
g_pre_purchase_payment	varchar2(40)    := 'PRE-PURCHASE PAYMENT';
g_pre_purchase_use	varchar2(40)    := 'PRE-PURCHASE USE';
--
-- Global api dml status
--
g_api_dml		boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_customer_booking_deal>-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure check that:
--   	- The customer_id defined on the booking deal must be the same
--   	customer_id as defined on the header, unless the customer_id is null
--   	on the booking deal.
--
procedure check_customer_booking_deal (
	 p_finance_header_id		in number
	,p_booking_deal_id		in number
   ) is
---------------
  v_proc                 varchar2(72) := g_package||'check_customer_booking_deal';
  v_book_deal_customer_id       OTA_BOOKING_DEALS.CUSTOMER_ID%type;
  v_finance_customer_id         OTA_FINANCE_HEADERS.CUSTOMER_ID%type;
  v_receivable_type		OTA_FINANCE_HEADERS.RECEIVABLE_TYPE%type;
  v_deal_type                   OTA_BOOKING_DEALS.TYPE%type;
  v_number_of_places            number;
  v_limit_each_event_flag       varchar2(1);
  --
  --
  cursor csr_tfh is
    select customer_id,receivable_type
      from ota_finance_headers
     where finance_header_id     =    p_finance_header_id;
  --
  --
  cursor csr_tbd is
    select customer_id,type,number_of_places,limit_each_event_flag
      from ota_booking_deals
     where booking_deal_id       =    p_booking_deal_id;
---------------
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  csr_tbd;
  Fetch csr_tbd into v_book_deal_customer_id
                    ,v_deal_type
                    ,v_number_of_places
                    ,v_limit_each_event_flag;
  Close csr_tbd;
  --
  --
  If v_book_deal_customer_id is NOT null  Then
        Open  csr_tfh;
        Fetch csr_tfh into v_finance_customer_id,v_receivable_type;
        Close csr_tfh;
        If v_book_deal_customer_id <>  v_finance_customer_id  OR
           v_finance_customer_id  is  null                   Then
                fnd_message.set_name('OTA','OTA_13344_TFL_WRONG_DEAL_CUST');
                fnd_message.raise_error;
        End if;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
end check_customer_booking_deal;
--
--
end ota_tfl_api_business_rules3;

/

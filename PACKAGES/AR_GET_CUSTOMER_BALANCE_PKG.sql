--------------------------------------------------------
--  DDL for Package AR_GET_CUSTOMER_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GET_CUSTOMER_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: arxcobls.pls 120.3 2005/10/30 04:42:54 appldev ship $ */


procedure ar_get_customer_balance( p_request_id number
				,p_set_of_books_id number
                               ,p_as_of_date in date
                               ,p_customer_name_from in varchar
                               ,p_customer_name_to in varchar
                               ,p_customer_number_low in varchar
                               ,p_customer_number_high in varchar
                               ,p_currency in varchar
                               ,p_min_invoice_balance in number
                               ,p_min_open_balance in number
                               ,p_account_credits varchar
                               ,p_account_receipts varchar
                               ,p_unapp_receipts varchar
                               ,p_uncleared_receipts varchar
                               ,p_ref_no in varchar
                               ,p_debug_flag in  varchar
                               ,p_trace_flag in varchar);





end AR_GET_CUSTOMER_BALANCE_PKG;

 

/

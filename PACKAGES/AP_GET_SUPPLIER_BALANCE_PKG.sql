--------------------------------------------------------
--  DDL for Package AP_GET_SUPPLIER_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_GET_SUPPLIER_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: apxsobls.pls 120.3 2005/05/13 08:10:05 sguddeti noship $ */


Procedure AP_GET_SUPPLIER_BALANCE( p_request_id in number
				,p_set_of_books_id number
				,p_as_of_date in date
				,p_supplier_name_from in varchar2
                               ,p_supplier_name_to in varchar2
                               ,p_currency in varchar2
                               ,p_min_invoice_balance in number
                               ,p_min_open_balance in number
                               ,p_include_prepayments in varchar2
                               ,p_reference_number in varchar2
                               ,p_debug_flag in  varchar2
                               ,p_trace_flag in varchar2
                                ) ;

FUNCTION get_paid_amount_on_ao_date             -- 2901541
         (p_invoice_id IN NUMBER,
          p_as_of_date IN DATE) RETURN NUMBER;

FUNCTION invoice_is_open_on_ao_date
         (p_invoice_id IN NUMBER,
          p_as_of_date IN DATE) RETURN BOOLEAN; -- 2901541

end AP_GET_SUPPLIER_BALANCE_PKG;

 

/

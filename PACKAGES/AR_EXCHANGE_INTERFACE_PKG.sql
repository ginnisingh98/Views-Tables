--------------------------------------------------------
--  DDL for Package AR_EXCHANGE_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_EXCHANGE_INTERFACE_PKG" AUTHID CURRENT_USER as
/*$Header: AREXINPS.pls 115.2 2002/11/15 02:33:05 anukumar noship $ */

/*
 Transfer registered party information from Exchange to AR for customer creation.
*/
procedure customer_interface (
	p_bill_to_party_id 	IN NUMBER default null,
	p_bill_to_site_use_id 	IN NUMBER default null,
	p_conc_request_id 	IN NUMBER default null,
	x_error_code 		OUT NOCOPY varchar2,
	x_error_msg  		OUT NOCOPY varchar2
	);

/*
 Transfer billing charge records from Exchange to AR for invoicing.
*/
procedure invoice_interface (
	p_cutoff_date 		IN date default null ,
	p_customer_name 	IN VARCHAR2 default null ,
	p_conc_request_id	IN NUMBER default null,
	x_error_code 		OUT NOCOPY varchar2,
	x_error_msg  		OUT NOCOPY varchar2
	) ;
/*
 Create invoices in AR for billing activity for a party, consolidated for a month.
*/


/*
 Record interface errors into pom_billing_interface_errors table.
*/
procedure record_error (
	p_billing_activity_id	IN number default null,
	p_billing_customer_id	IN number default null,
	p_customer_name		IN varchar2 default null,
	p_error_code		IN varchar2,
	p_additional_message	IN varchar2 default null,
	p_action_required	IN varchar2 default null,
	p_invalid_value		IN varchar2
	);

END ar_exchange_interface_pkg;

 

/

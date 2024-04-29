--------------------------------------------------------
--  DDL for Package AR_EXCHANGE_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_EXCHANGE_INTERFACE" AUTHID CURRENT_USER as
/*$Header: AREXINTS.pls 115.3 2002/11/15 02:33:26 anukumar ship $ */

/*
 Create customer record in AR for billing party in Exchange.
*/
procedure ar_customer_interface (
	errbuf out NOCOPY varchar2,
	retcode out NOCOPY varchar2,
	p_customer_name IN VARCHAR2 default null
	);

/*
 Create invoices in AR for billing activity for a party, consolidated for a month.
*/
procedure ar_invoice_interface (
	errbuf out NOCOPY varchar2,
	retcode out NOCOPY varchar2,
	p_cutoff_date IN date default null ,
	p_customer_name IN VARCHAR2 default null
	);

END ar_exchange_interface;

 

/

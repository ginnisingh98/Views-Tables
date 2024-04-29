--------------------------------------------------------
--  DDL for Package JG_RX_IR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_RX_IR_PKG" AUTHID CURRENT_USER as
/* $Header: jgrxpirs.pls 120.4 2005/05/10 06:36:55 hhiraga ship $ */

/* Overload of main logic */
procedure ap_rx_invoice_run (
 	errbuf			out nocopy	varchar2,
  	retcode			out nocopy	number,
	p_request_id		in	number,
	p_login_id		in	number,
        p_reporting_level       in      varchar2,
        p_reporting_entity_id   in      number,
	p_set_of_book_id	in	number,
	p_chart_of_acct_id	in	number,
	p_line_inv		in	varchar2,
	p_acct_date_min		in	date,
	p_acct_date_max		in	date,
	p_batch_id		in	number,
	p_invoice_type		in	varchar2,
	p_entry_person_id	in	number,
	p_doc_sequence_id	in	number,
	p_doc_sequence_value_min	in	number,
	p_doc_sequence_value_max	in	number,
	p_supplier_min		in	varchar2,
	p_supplier_max		in	varchar2,
	p_liability_min		in	varchar2,
	p_liability_max		in	varchar2,
	p_dist_acct_min		in	varchar2,
	p_dist_acct_max		in	varchar2,
	p_inv_currency_code	in	varchar2,
	p_dist_amount_min	in	number,
	p_dist_amount_max	in	number,
	p_entered_date_min	in	date,
	p_entered_date_max	in	date,
	p_cancelled_inv		in	varchar2,
	p_unapproved_inv	in	varchar2
);

procedure ap_rx_invoice_run (
 	errbuf			out nocopy	varchar2,
  	retcode			out nocopy	number,
	p_request_id		in	number,
	p_login_id		in	number,
        p_reporting_level       in      varchar2,
        p_reporting_entity_id   in      number,
	p_set_of_book_id	in	number,
	p_chart_of_acct_id	in	number,
	p_line_inv		in	varchar2,
	p_acct_date_min		in	date,
	p_acct_date_max		in	date,
	p_batch_id		in	number,
	p_invoice_type		in	varchar2,
	p_entry_person_id	in	number,
	p_doc_sequence_id	in	number,
	p_doc_sequence_value_min	in	number,
	p_doc_sequence_value_max	in	number,
	p_supplier_min		in	varchar2,
	p_supplier_max		in	varchar2,
	p_liability_min		in	varchar2,
	p_liability_max		in	varchar2,
	p_dist_acct_min		in	varchar2,
	p_dist_acct_max		in	varchar2,
	p_inv_currency_code	in	varchar2,
	p_dist_amount_min	in	number,
	p_dist_amount_max	in	number,
	p_entered_date_min	in	date,
	p_entered_date_max	in	date,
	p_cancelled_inv		in	boolean,
	p_unapproved_inv	in	boolean
);

end JG_RX_IR_PKG;

 

/

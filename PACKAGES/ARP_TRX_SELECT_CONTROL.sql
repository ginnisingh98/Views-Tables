--------------------------------------------------------
--  DDL for Package ARP_TRX_SELECT_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_SELECT_CONTROL" AUTHID CURRENT_USER AS
/* $Header: ARPLTSCS.pls 115.4 2002/11/15 02:44:04 anukumar ship $ */


	PROCEDURE build_where_clause (
		P_choice		IN	varchar2,
		P_open_invoice		IN	varchar2,
		P_cust_trx_type_id	IN	number,
		p_cust_trx_class	IN	varchar2,
		P_installment_number	IN	number,
		P_dates_low		IN	date,
		P_dates_high		IN	date,
		P_customer_id		IN	number,
		P_customer_class_code	IN	varchar2,
		P_trx_number_low	IN	varchar2,
		P_trx_number_high	IN	varchar2,
		P_batch_id		IN	number,
		P_customer_trx_id	IN	number,
		p_adj_number_low	in	varchar2,
		p_adj_number_high	in	varchar2,
		p_adj_dates_low		in	date,
		p_adj_dates_high	in	date,
		P_where1		OUT NOCOPY	varchar2,
		P_where2		OUT NOCOPY	varchar2,
		p_table1		out NOCOPY	varchar2,
		p_table2		out NOCOPY	varchar2,
                p_call_from		IN	varchar2 default 'INV'
		);

END ARP_TRX_SELECT_CONTROL;

 

/

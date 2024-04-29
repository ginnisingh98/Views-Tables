--------------------------------------------------------
--  DDL for Package GMF_AR_GET_INVOICE_LINES_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_INVOICE_LINES_ID" AUTHID CURRENT_USER AS
/*       $Header: gmfinvss.pls 115.2 2002/11/11 00:39:59 rseshadr ship $ */
PROCEDURE get_invoice_lines_id
	(t_trx_type                 IN	OUT NOCOPY VARCHAR2,
   	t_trx_type_name             IN	OUT NOCOPY VARCHAR2,
	t_invoice_number            IN 	OUT NOCOPY VARCHAR2,
	invoice_index               IN      NUMBER,
   	t_line_id                   OUT     NOCOPY VARCHAR2,
	row_to_fetch                IN 	OUT NOCOPY NUMBER,
	error_status                OUT     NOCOPY NUMBER);

CURSOR cur_get_inv_lines_id1(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name
		order by h.trx_number;

CURSOR cur_get_inv_lines_id2(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name		and
		h.trx_number > t_invoice_number
		order by h.trx_number;

CURSOR cur_get_inv_lines_id3(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name		and
		h.trx_number < t_invoice_number
		order by h.trx_number;

CURSOR cur_get_inv_lines_id4(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name		and
		h.trx_number >= t_invoice_number
		order by h.trx_number;

CURSOR cur_get_inv_lines_id5(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name		and
		h.trx_number <= t_invoice_number
		order by h.trx_number;

CURSOR cur_get_inv_lines_id6(t_trx_type	VARCHAR2,
		t_trx_type_name	VARCHAR2, t_invoice_number VARCHAR2)IS
	SELECT DISTINCT
		h.trx_number,
		t.name,
		l.interface_line_attribute1
	FROM
		RA_CUSTOMER_TRX_ALL h, RA_CUSTOMER_TRX_LINES_ALL l,
		RA_CUST_TRX_TYPES_ALL t
	WHERE
		h.customer_trx_id = l.customer_trx_id  	and
		h.cust_trx_type_id = t.cust_trx_type_id and
		l.interface_line_context = 'GEMMS OP'  	and
		t.type = t_trx_type        		and
		t.name like t_trx_type_name		and
		h.trx_number like t_invoice_number
		order by h.trx_number;

END GMF_AR_GET_INVOICE_LINES_ID;

 

/

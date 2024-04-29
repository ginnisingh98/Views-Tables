--------------------------------------------------------
--  DDL for Package ARP_PROGRAM_BR_REMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROGRAM_BR_REMIT" AUTHID CURRENT_USER AS
/* $Header: ARBRRMPS.pls 120.2.12010000.2 2009/01/27 14:01:55 dgaurab ship $*/

PROCEDURE auto_create_remit_program(
	errbuf				OUT NOCOPY	varchar2,
	retcode				OUT NOCOPY	varchar2,
	p_create_flag       		IN 	varchar2				DEFAULT 'N',
	p_cancel_flag            	IN 	varchar2				DEFAULT 'N',
	p_approve_flag           	IN 	varchar2				DEFAULT 'N',
	p_format_flag            	IN 	varchar2				DEFAULT 'N',
	p_print_flag	           	IN 	varchar2				DEFAULT 'N',
	p_print_bills_flag		IN	varchar2				DEFAULT 'N',
	p_batch_id			IN	varchar2				DEFAULT NULL,
	p_remit_total_low		IN	varchar2				DEFAULT NULL,
	p_remit_total_high		IN	varchar2				DEFAULT NULL,
	p_maturity_date_low		IN	varchar2				DEFAULT NULL,
	p_maturity_date_high		IN	varchar2				DEFAULT NULL,
	p_br_number_low			IN	varchar2				DEFAULT NULL,
	p_br_number_high		IN	varchar2				DEFAULT NULL,
	p_br_amount_low			IN	varchar2				DEFAULT NULL,
	p_br_amount_high		IN	varchar2				DEFAULT NULL,
	p_transaction_type1_id		IN	varchar2				DEFAULT NULL,
	p_transaction_type2_id		IN	varchar2				DEFAULT NULL,
	p_unsigned_flag			IN	varchar2				DEFAULT NULL,
	p_signed_flag			IN	varchar2				DEFAULT NULL,
	p_drawee_issued_flag		IN	varchar2				DEFAULT NULL,
	p_include_unpaid_flag    	IN 	varchar2				DEFAULT NULL,
	p_drawee_id			IN	varchar2				DEFAULT NULL,
	p_drawee_number_low		IN	varchar2				DEFAULT NULL,
	p_drawee_number_high		IN	varchar2				DEFAULT NULL,
	p_drawee_class1_code		IN	varchar2				DEFAULT NULL,
	p_drawee_class2_code		IN	varchar2				DEFAULT NULL,
	p_drawee_class3_code		IN	varchar2				DEFAULT NULL,
	p_drawee_bank_name		IN	varchar2				DEFAULT NULL,
	p_drawee_bank_branch_id		IN	varchar2				DEFAULT NULL,
	p_drawee_branch_city		IN	varchar2				DEFAULT NULL,
	p_br_sort_criteria	    	IN 	varchar2				DEFAULT NULL,
	p_br_order		    	IN 	varchar2				DEFAULT NULL,
	p_drawee_sort_criteria	    	IN 	varchar2				DEFAULT NULL,
	p_drawee_order		    	IN 	varchar2				DEFAULT NULL,
        p_physical_bill			IN	varchar2                                DEFAULT 'N');

FUNCTION get_site_use_id(
           p_cust_account_id NUMBER,
           p_org_id NUMBER,
           p_instr_id NUMBER DEFAULT NULL,
           p_pay_trxn_extn_id NUMBER DEFAULT NULL) RETURN NUMBER;

END  ARP_PROGRAM_BR_REMIT;
--

/

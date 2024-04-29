--------------------------------------------------------
--  DDL for Package ARP_SELECTION_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_SELECTION_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: ARBRSELS.pls 120.4 2005/10/30 03:49:02 appldev ship $ */

procedure insert_p
	( 	p_sel_rec   	IN 	AR_SELECTION_CRITERIA%rowtype			,
                p_sel_id   	OUT NOCOPY 	AR_SELECTION_CRITERIA.selection_criteria_id%type);


PROCEDURE update_p
	( 	p_sel_rec 	IN 	AR_SELECTION_CRITERIA%rowtype			,
                p_sel_id  	IN 	AR_SELECTION_CRITERIA.selection_criteria_id%type);

procedure delete_p
	( 	p_sel_id  	IN 	AR_SELECTION_CRITERIA.selection_criteria_id%type);


PROCEDURE fetch_p
	( 	p_sel_rec  	OUT NOCOPY 	AR_SELECTION_CRITERIA%rowtype			,
                p_sel_id    	IN 	AR_SELECTION_CRITERIA.selection_criteria_id%type);


PROCEDURE lock_p
	( 	p_sel_id 	IN 	AR_SELECTION_CRITERIA.selection_criteria_id%type);


PROCEDURE lock_fetch_p
	( 	p_sel_rec 	IN OUT NOCOPY 	AR_SELECTION_CRITERIA%rowtype			,
                p_sel_id  	IN 	AR_SELECTION_CRITERIA.selection_criteria_id%type);


PROCEDURE lock_compare_p
	( 	p_sel_rec 	IN   	AR_SELECTION_CRITERIA%rowtype			,
                p_sel_id  	IN   	AR_SELECTION_CRITERIA.selection_criteria_id%type);

PROCEDURE lock_compare_cover
	(	p_form_name         		IN  varchar2						,
		p_form_version         		IN  number						,
  		p_selection_criteria_id  	IN  AR_SELECTION_CRITERIA.selection_criteria_id%type	,
  		p_due_date_low			IN  AR_SELECTION_CRITERIA.due_date_low%type		,
		p_due_date_high			IN  AR_SELECTION_CRITERIA.due_date_high%type		,
		p_trx_date_low			IN  AR_SELECTION_CRITERIA.trx_date_low%type		,
		p_trx_date_high			IN  AR_SELECTION_CRITERIA.trx_date_high%type		,
		p_cust_trx_type_id		IN  AR_SELECTION_CRITERIA.cust_trx_type_id%type		,
		p_receipt_method_id		IN  AR_SELECTION_CRITERIA.receipt_method_id%type	,
		p_bank_branch_id		IN  AR_SELECTION_CRITERIA.bank_branch_id%type		,
		p_trx_number_low		IN  AR_SELECTION_CRITERIA.trx_number_low%type		,
		p_trx_number_high		IN  AR_SELECTION_CRITERIA.trx_number_high%type		,
		p_customer_class_code		IN  AR_SELECTION_CRITERIA.customer_class_code%type	,
		p_customer_category_code	IN  AR_SELECTION_CRITERIA.customer_category_code%type	,
		p_customer_id			IN  AR_SELECTION_CRITERIA.customer_id%type		,
		p_site_use_id			IN  AR_SELECTION_CRITERIA.site_use_id%type		);


PROCEDURE set_to_dummy
	( 	p_sel_rec 			OUT NOCOPY AR_SELECTION_CRITERIA%rowtype			);


PROCEDURE display_selection
	(  	p_sel_id 			IN  AR_SELECTION_CRITERIA.selection_criteria_id%type	);


PROCEDURE display_selection_rec
	( 	p_sel_rec 			IN  AR_SELECTION_CRITERIA%rowtype 			);


END ARP_SELECTION_CRITERIA_PKG;

 

/

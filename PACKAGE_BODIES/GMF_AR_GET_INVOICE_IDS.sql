--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_INVOICE_IDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_INVOICE_IDS" AS
/* $Header: gmfinvdb.pls 115.1 2002/11/11 00:39:12 rseshadr ship $ */
	CURSOR cur_get_invoice_ids(
		sales_order_no VARCHAR2,
		t_start_date DATE,
		t_end_date DATE) IS
SELECT
	rac.CUSTOMER_TRX_ID, rac.LAST_UPDATED_BY, rac.LAST_UPDATE_DATE,
	rac.CREATION_DATE, rac.CREATED_BY, rac.LAST_UPDATE_LOGIN,
	rac.TRX_NUMBER, rac.CUST_TRX_TYPE_ID, rac.TRX_DATE,
	rac.SET_OF_BOOKS_ID, BILL_TO_CONTACT_ID, BATCH_ID,
	BATCH_SOURCE_ID, rac.REASON_CODE, SOLD_TO_CUSTOMER_ID,
	SOLD_TO_CONTACT_ID, SOLD_TO_SITE_USE_ID, BILL_TO_CUSTOMER_ID,
	BILL_TO_SITE_USE_ID, SHIP_TO_CUSTOMER_ID, SHIP_TO_CONTACT_ID,
	SHIP_TO_SITE_USE_ID, REMIT_TO_ADDRESS_ID, rac.TERM_ID,
	TERM_DUE_DATE, rac.PREVIOUS_CUSTOMER_TRX_ID, rac.PRIMARY_SALESREP_ID,
	PRINTING_ORIGINAL_DATE, PRINTING_LAST_PRINTED, rac.PRINTING_OPTION,
	PRINTING_COUNT, PRINTING_PENDING, rac.PURCHASE_ORDER,
	rac.PURCHASE_ORDER_REVISION, rac.PURCHASE_ORDER_DATE,CUSTOMER_REFERENCE,
	rac.INTERNAL_NOTES, rac.EXCHANGE_RATE_TYPE, rac.EXCHANGE_DATE,
	rac.EXCHANGE_RATE, rac.TERRITORY_ID, rac.INVOICE_CURRENCY_CODE,
	rac.INITIAL_CUSTOMER_TRX_ID, rac.AGREEMENT_ID, rac.END_DATE_COMMITMENT,
	rac.START_DATE_COMMITMENT, rac.LAST_PRINTED_SEQUENCE_NUM,
	rac.ORIG_SYSTEM_BATCH_NAME,
   	rac.POST_REQUEST_ID, rac.REQUEST_ID, rac.PROGRAM_APPLICATION_ID,
   	rac.PROGRAM_ID, rac.PROGRAM_UPDATE_DATE, FINANCE_CHARGES,
   	COMPLETE_FLAG, POSTING_CONTROL_ID, BILL_TO_ADDRESS_ID,
   	RA_POST_LOOP_NUMBER, SHIP_TO_ADDRESS_ID, CREDIT_METHOD_FOR_RULES,
   	rac.CREDIT_METHOD_FOR_INSTALLMENTS, rac.RECEIPT_METHOD_ID,
	rac.RELATED_CUSTOMER_TRX_ID,
	rac.INVOICING_RULE_ID, rac.SHIP_VIA, rac.SHIP_DATE_ACTUAL,
	rac.WAYBILL_NUMBER, rac.FOB_POINT, rac.CUSTOMER_BANK_ACCOUNT_ID,
	STATUS_TRX, DOC_SEQUENCE_ID,
   	DOC_SEQUENCE_VALUE, rac.PAYING_CUSTOMER_ID, rac.PAYING_SITE_USE_ID,
   	RELATED_BATCH_SOURCE_ID, DEFAULT_TAX_EXEMPT_FLAG,
   	CREATED_FROM
from 	RA_CUSTOMER_TRX_ALL rac
where 	rac.customer_trx_id in
	(select distinct rat.customer_trx_id
		from ra_customer_trx_lines_all rat
		connect by previous_customer_trx_id = prior customer_trx_id
		start with rat.sales_order = sales_order_no )
 	AND (rac.last_update_date between nvl(t_start_date, rac.last_update_date)
	AND nvl(t_end_date, rac.last_update_date));

PROCEDURE get_invoice_ids
	(sales_order_no			IN	OUT 	NOCOPY VARCHAR2,
	invoice_id				OUT 	NOCOPY NUMBER,
	t_start_date			IN 	OUT	NOCOPY DATE,
	t_end_date			IN 	OUT	NOCOPY DATE,
	t_created_by				OUT	NOCOPY NUMBER,
	t_creation_date				OUT	NOCOPY DATE,
	t_last_updated_by			OUT	NOCOPY NUMBER,
	t_last_update_date			OUT	NOCOPY DATE,
	t_customer_trx_id     			OUT   	NOCOPY NUMBER,
	t_last_update_login          		OUT	NOCOPY NUMBER,
	t_trx_number                 		OUT   	NOCOPY VARCHAR2,
	t_cust_trx_type_id           		OUT   	NOCOPY NUMBER,
 	t_trx_date    	            		OUT	NOCOPY DATE,
   	t_set_of_books_id            		OUT   	NOCOPY NUMBER,
	t_bill_to_contact_id         		OUT   	NOCOPY NUMBER,
   	t_batch_id                   		OUT   	NOCOPY NUMBER,
   	t_batch_source_id            		OUT   	NOCOPY NUMBER,
   	t_reason_code                		OUT   	NOCOPY VARCHAR2,
   	t_sold_to_customer_id        		OUT   	NOCOPY NUMBER,
   	t_sold_to_contact_id         		OUT   	NOCOPY NUMBER,
   	t_sold_to_site_use_id        		OUT   	NOCOPY NUMBER,
   	t_bill_to_customer_id        		OUT   	NOCOPY NUMBER,
   	t_bill_to_site_use_id        		OUT   	NOCOPY NUMBER,
   	t_ship_to_customer_id        		OUT   	NOCOPY NUMBER,
   	t_ship_to_contact_id         		OUT   	NOCOPY NUMBER,
   	t_ship_to_site_use_id        		OUT   	NOCOPY NUMBER,
   	t_remit_to_address_id        		OUT   	NOCOPY NUMBER,
   	t_term_id                        	OUT   	NOCOPY NUMBER,
   	t_term_due_date                  	OUT   	NOCOPY DATE,
   	t_previous_customer_trx_id       	OUT   	NOCOPY NUMBER,
   	t_primary_salesrep_id            	OUT   	NOCOPY NUMBER,
   	t_printing_original_date         	OUT   	NOCOPY DATE,
   	t_printing_last_printed          	OUT   	NOCOPY DATE,
   	t_printing_option                	OUT   	NOCOPY VARCHAR2,
   	t_printing_count                 	OUT   	NOCOPY NUMBER,
   	t_printing_pending               	OUT   	NOCOPY VARCHAR2,
   	t_purchase_order                 	OUT   	NOCOPY VARCHAR2,
   	t_purchase_order_revision        	OUT   	NOCOPY VARCHAR2,
   	t_purchase_order_date            	OUT   	NOCOPY DATE,
   	t_customer_reference             	OUT   	NOCOPY VARCHAR2,
   	t_internal_notes                 	OUT   	NOCOPY VARCHAR2,
   	t_exchange_rate_type             	OUT   	NOCOPY VARCHAR2,
   	t_exchange_date                  	OUT   	NOCOPY DATE,
   	t_exchange_rate                  	OUT   	NOCOPY NUMBER,
   	t_territory_id                   	OUT   	NOCOPY NUMBER,
   	t_invoice_currency_code          	OUT   	NOCOPY VARCHAR2,
   	t_initial_customer_trx_id        	OUT   	NOCOPY NUMBER,
   	t_agreement_id                   	OUT   	NOCOPY NUMBER,
   	t_end_date_commitment            	OUT   	NOCOPY DATE,
   	t_start_date_commitment          	OUT   	NOCOPY DATE,
   	t_last_printed_sequence_num      	OUT   	NOCOPY NUMBER,
   	t_orig_system_batch_name         	OUT   	NOCOPY VARCHAR2,
   	t_post_request_id                	OUT   	NOCOPY NUMBER,
   	t_request_id                     	OUT   	NOCOPY NUMBER,
   	t_program_application_id         	OUT   	NOCOPY NUMBER,
   	t_program_id                     	OUT   	NOCOPY NUMBER,
   	t_program_update_date            	OUT   	NOCOPY DATE,
   	t_finance_charges                	OUT   	NOCOPY VARCHAR2,
   	t_complete_flag                  	OUT   	NOCOPY VARCHAR2,
   	t_posting_control_id             	OUT   	NOCOPY NUMBER,
   	t_bill_to_address_id             	OUT   	NOCOPY NUMBER,
   	t_ra_post_loop_number            	OUT   	NOCOPY NUMBER,
   	t_ship_to_address_id             	OUT   	NOCOPY NUMBER,
   	t_credit_method_for_rules        	OUT   	NOCOPY VARCHAR2,
   	t_cr_method_for_installments     	OUT   	NOCOPY VARCHAR2,
   	t_receipt_method_id              	OUT   	NOCOPY NUMBER,
   	t_related_customer_trx_id        	OUT   	NOCOPY NUMBER,
   	t_invoicing_rule_id              	OUT   	NOCOPY NUMBER,
   	t_ship_via                       	OUT   	NOCOPY VARCHAR2,
   	t_ship_date_actual               	OUT   	NOCOPY DATE,
   	t_waybill_number                 	OUT   	NOCOPY VARCHAR2,
   	t_fob_point                      	OUT   	NOCOPY VARCHAR2,
   	t_customer_bank_account_id       	OUT   	NOCOPY NUMBER,
   	t_status_trx                     	OUT   	NOCOPY VARCHAR2,
   	t_doc_sequence_id                	OUT   	NOCOPY NUMBER,
   	t_doc_sequence_value             	OUT   	NOCOPY NUMBER,
   	t_paying_customer_id             	OUT   	NOCOPY NUMBER,
   	t_paying_site_use_id             	OUT   	NOCOPY NUMBER,
   	t_related_batch_source_id        	OUT   	NOCOPY NUMBER,
   	t_default_tax_exempt_flag        	OUT   	NOCOPY VARCHAR2,
   	t_created_from                   	OUT   	NOCOPY VARCHAR2,
	row_to_fetch			IN 	OUT	NOCOPY NUMBER,
	error_status				OUT	NOCOPY NUMBER ) IS

BEGIN
	if NOT cur_get_invoice_ids%ISOPEN
	then
		OPEN cur_get_invoice_ids( sales_order_no, t_start_date, t_end_date);
	end if;

	FETCH cur_get_invoice_ids INTO
		invoice_id,
		t_last_updated_by,
		t_last_update_date,
		t_creation_date,
		t_created_by,
		t_last_update_login,
		t_trx_number,
		t_cust_trx_type_id,
 		t_trx_date,
   		t_set_of_books_id,
 		t_bill_to_contact_id,
   		t_batch_id,
   		t_batch_source_id,
   		t_reason_code,
   		t_sold_to_customer_id,
   		t_sold_to_contact_id,
   		t_sold_to_site_use_id,
   		t_bill_to_customer_id,
   		t_bill_to_site_use_id,
   		t_ship_to_customer_id,
   		t_ship_to_contact_id,
   		t_ship_to_site_use_id,
   		t_remit_to_address_id,
   		t_term_id,
   		t_term_due_date,
   		t_previous_customer_trx_id,
   		t_primary_salesrep_id,
   		t_printing_original_date,
   		t_printing_last_printed,
   		t_printing_option,
   		t_printing_count,
   		t_printing_pending,
   		t_purchase_order,
   		t_purchase_order_revision,
   		t_purchase_order_date,
   		t_customer_reference,
   		t_internal_notes,
   		t_exchange_rate_type,
   		t_exchange_date,
   		t_exchange_rate,
   		t_territory_id,
   		t_invoice_currency_code,
   		t_initial_customer_trx_id,
   		t_agreement_id,
   		t_end_date_commitment,
   		t_start_date_commitment,
   		t_last_printed_sequence_num,
   		t_orig_system_batch_name,
   		t_post_request_id,
   		t_request_id,
   		t_program_application_id,
   		t_program_id,
   		t_program_update_date,
   		t_finance_charges,
   		t_complete_flag,
   		t_posting_control_id,
   		t_bill_to_address_id,
   		t_ra_post_loop_number,
   		t_ship_to_address_id,
   		t_credit_method_for_rules,
   		t_cr_method_for_installments,
   		t_receipt_method_id,
   		t_related_customer_trx_id,
   		t_invoicing_rule_id,
   		t_ship_via,
   		t_ship_date_actual,
   		t_waybill_number,
   		t_fob_point,
   		t_customer_bank_account_id,
   		t_status_trx,
   		t_doc_sequence_id,
   		t_doc_sequence_value,
   		t_paying_customer_id,
   		t_paying_site_use_id,
   		t_related_batch_source_id,
   		t_default_tax_exempt_flag,
   		t_created_from;

	if cur_get_invoice_ids%NOTFOUND
	then
		error_status := 100;
		close cur_get_invoice_ids;
	end if;

	if row_to_fetch = 1 and cur_get_invoice_ids%ISOPEN
	then
		close cur_get_invoice_ids;
	end if;

	EXCEPTION

		when others then
		error_status := SQLCODE;
END get_invoice_ids;
END GMF_AR_GET_INVOICE_IDS;

/

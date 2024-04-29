--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_INVOICE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_INVOICE_HEADER" AS
/* $Header: gmfinrhb.pls 115.5 2004/06/18 17:17:10 vchukkap ship $ */
        apps_base_language	fnd_languages.language_code%TYPE;

	CURSOR cur_get_invoice_header (
		invoice_id NUMBER,
		t_start_date DATE,
		t_end_date DATE) IS

SELECT
	arc.CUSTOMER_TRX_ID, arc.LAST_UPDATED_BY, arc.LAST_UPDATE_DATE,
	arc.CREATION_DATE, arc.CREATED_BY, arc.LAST_UPDATE_LOGIN,
	arc.TRX_NUMBER, arc.CUST_TRX_TYPE_ID, arc.TRX_DATE,
	arc.SET_OF_BOOKS_ID, arc.BILL_TO_CONTACT_ID, arc.BATCH_ID,
	arc.BATCH_SOURCE_ID, arc.REASON_CODE, arc.SOLD_TO_CUSTOMER_ID,
	arc.SOLD_TO_CONTACT_ID, arc.SOLD_TO_SITE_USE_ID, arc.BILL_TO_CUSTOMER_ID,
	arc.BILL_TO_SITE_USE_ID, arc.SHIP_TO_CUSTOMER_ID, arc.SHIP_TO_CONTACT_ID,
	arc.SHIP_TO_SITE_USE_ID, arc.REMIT_TO_ADDRESS_ID, arc.TERM_ID,
	arc.TERM_DUE_DATE, arc.PREVIOUS_CUSTOMER_TRX_ID, arc.PRIMARY_SALESREP_ID,
	arc.PRINTING_ORIGINAL_DATE, arc.PRINTING_LAST_PRINTED, arc.PRINTING_OPTION,
	arc.PRINTING_COUNT, arc.PRINTING_PENDING, arc.PURCHASE_ORDER,
	arc.PURCHASE_ORDER_REVISION, arc.PURCHASE_ORDER_DATE, arc.CUSTOMER_REFERENCE,
	arc.INTERNAL_NOTES, arc.EXCHANGE_RATE_TYPE, arc.EXCHANGE_DATE,
	arc.EXCHANGE_RATE, TERRITORY_ID, arc.INVOICE_CURRENCY_CODE,
	arc.INITIAL_CUSTOMER_TRX_ID, arc.AGREEMENT_ID, arc.END_DATE_COMMITMENT,
	arc.START_DATE_COMMITMENT, arc.LAST_PRINTED_SEQUENCE_NUM,arc.ORIG_SYSTEM_BATCH_NAME,
	arc.POST_REQUEST_ID, arc.REQUEST_ID, arc.PROGRAM_APPLICATION_ID,
   	arc.PROGRAM_ID, arc.PROGRAM_UPDATE_DATE, arc.FINANCE_CHARGES,
   	arc.COMPLETE_FLAG, arc.POSTING_CONTROL_ID, arc.BILL_TO_ADDRESS_ID,
   	arc.RA_POST_LOOP_NUMBER, arc.SHIP_TO_ADDRESS_ID, arc.CREDIT_METHOD_FOR_RULES,
   	arc.CREDIT_METHOD_FOR_INSTALLMENTS, arc.RECEIPT_METHOD_ID,
	arc.RELATED_CUSTOMER_TRX_ID,
	arc.INVOICING_RULE_ID, arc.SHIP_VIA, arc.SHIP_DATE_ACTUAL,
	arc.WAYBILL_NUMBER, arc.FOB_POINT, arc.CUSTOMER_BANK_ACCOUNT_ID,
	arc.STATUS_TRX, arc.DOC_SEQUENCE_ID,
   	arc.DOC_SEQUENCE_VALUE, arc.PAYING_CUSTOMER_ID, arc.PAYING_SITE_USE_ID,
   	arc.RELATED_BATCH_SOURCE_ID, arc.DEFAULT_TAX_EXEMPT_FLAG,
   	arc.CREATED_FROM, sum(arp.AMOUNT_DUE_ORIGINAL), sum(arp.AMOUNT_DUE_REMAINING),
	art.NAME, racust.NAME, racust.TYPE
from	RA_TERMS_TL art,
	RA_CUST_TRX_TYPES_ALL racust,
	AR_PAYMENT_SCHEDULES_ALL arp,
        RA_CUSTOMER_TRX_ALL arc
where 	arc.CUSTOMER_TRX_ID = invoice_id
        AND (arp.CUSTOMER_TRX_ID = arc.customer_trx_id)
        AND (arc.last_update_date between nvl(t_start_date, arc.last_update_date)
	AND nvl(t_end_date, arc.last_update_date))
	AND (art.TERM_ID(+) = arc.TERM_ID)
        AND  nvl(art.language,apps_base_language) = apps_base_language
	AND (arc.CUST_TRX_TYPE_ID = racust.CUST_TRX_TYPE_ID)
	AND (racust.CUST_TRX_TYPE_ID, racust.ORG_ID) =
		(	SELECT 	t.CUST_TRX_TYPE_ID, t.ORG_ID
	 		FROM 	RA_CUST_TRX_TYPES_ALL t
			WHERE 	t.CUST_TRX_TYPE_ID = racust.CUST_TRX_TYPE_ID
			AND	rownum=1)
group by
	arc.CUSTOMER_TRX_ID, arc.LAST_UPDATED_BY, arc.LAST_UPDATE_DATE,
	arc.CREATION_DATE, arc.CREATED_BY, arc.LAST_UPDATE_LOGIN,
	arc.TRX_NUMBER, arc.CUST_TRX_TYPE_ID, arc.TRX_DATE,
	arc.SET_OF_BOOKS_ID, arc.BILL_TO_CONTACT_ID, arc.BATCH_ID,
	arc.BATCH_SOURCE_ID, arc.REASON_CODE, arc.SOLD_TO_CUSTOMER_ID,
	arc.SOLD_TO_CONTACT_ID, arc.SOLD_TO_SITE_USE_ID, arc.BILL_TO_CUSTOMER_ID,
	arc.BILL_TO_SITE_USE_ID, arc.SHIP_TO_CUSTOMER_ID, arc.SHIP_TO_CONTACT_ID,
	arc.SHIP_TO_SITE_USE_ID, arc.REMIT_TO_ADDRESS_ID, arc.TERM_ID,
	arc.TERM_DUE_DATE, arc.PREVIOUS_CUSTOMER_TRX_ID, arc.PRIMARY_SALESREP_ID,
	arc.PRINTING_ORIGINAL_DATE, arc.PRINTING_LAST_PRINTED, arc.PRINTING_OPTION,
	arc.PRINTING_COUNT, arc.PRINTING_PENDING, arc.PURCHASE_ORDER,
	arc.PURCHASE_ORDER_REVISION, arc.PURCHASE_ORDER_DATE, arc.CUSTOMER_REFERENCE,
	arc.INTERNAL_NOTES, arc.EXCHANGE_RATE_TYPE, arc.EXCHANGE_DATE,
	arc.EXCHANGE_RATE, arc.TERRITORY_ID, arc.INVOICE_CURRENCY_CODE,
	arc.INITIAL_CUSTOMER_TRX_ID, arc.AGREEMENT_ID, arc.END_DATE_COMMITMENT,
	arc.START_DATE_COMMITMENT, arc.LAST_PRINTED_SEQUENCE_NUM,arc.ORIG_SYSTEM_BATCH_NAME,
	arc.POST_REQUEST_ID, arc.REQUEST_ID, arc.PROGRAM_APPLICATION_ID,
   	arc.PROGRAM_ID, arc.PROGRAM_UPDATE_DATE, arc.FINANCE_CHARGES,
   	arc.COMPLETE_FLAG, arc.POSTING_CONTROL_ID, arc.BILL_TO_ADDRESS_ID,
   	arc.RA_POST_LOOP_NUMBER, arc.SHIP_TO_ADDRESS_ID, arc.CREDIT_METHOD_FOR_RULES,
   	arc.CREDIT_METHOD_FOR_INSTALLMENTS, arc.RECEIPT_METHOD_ID,
	arc.RELATED_CUSTOMER_TRX_ID,
	arc.INVOICING_RULE_ID, arc.SHIP_VIA, arc.SHIP_DATE_ACTUAL,
	arc.WAYBILL_NUMBER, arc.FOB_POINT, arc.CUSTOMER_BANK_ACCOUNT_ID,
	arc.STATUS_TRX, arc.DOC_SEQUENCE_ID,
   	arc.DOC_SEQUENCE_VALUE, arc.PAYING_CUSTOMER_ID, arc.PAYING_SITE_USE_ID,
   	arc.RELATED_BATCH_SOURCE_ID, arc.DEFAULT_TAX_EXEMPT_FLAG,
   	arc.CREATED_FROM, art.NAME, racust.NAME, racust.TYPE
UNION
SELECT
	arc.CUSTOMER_TRX_ID, arc.LAST_UPDATED_BY, arc.LAST_UPDATE_DATE,
	arc.CREATION_DATE, arc.CREATED_BY, arc.LAST_UPDATE_LOGIN,
	arc.TRX_NUMBER, arc.CUST_TRX_TYPE_ID, arc.TRX_DATE,
	arc.SET_OF_BOOKS_ID, arc.BILL_TO_CONTACT_ID, arc.BATCH_ID,
	arc.BATCH_SOURCE_ID, arc.REASON_CODE, arc.SOLD_TO_CUSTOMER_ID,
	arc.SOLD_TO_CONTACT_ID, arc.SOLD_TO_SITE_USE_ID, arc.BILL_TO_CUSTOMER_ID,
	arc.BILL_TO_SITE_USE_ID, arc.SHIP_TO_CUSTOMER_ID, arc.SHIP_TO_CONTACT_ID,
	arc.SHIP_TO_SITE_USE_ID, arc.REMIT_TO_ADDRESS_ID, arc.TERM_ID,
	arc.TERM_DUE_DATE, arc.PREVIOUS_CUSTOMER_TRX_ID, arc.PRIMARY_SALESREP_ID,
	arc.PRINTING_ORIGINAL_DATE, arc.PRINTING_LAST_PRINTED, arc.PRINTING_OPTION,
	arc.PRINTING_COUNT, arc.PRINTING_PENDING, arc.PURCHASE_ORDER,
	arc.PURCHASE_ORDER_REVISION, arc.PURCHASE_ORDER_DATE, arc.CUSTOMER_REFERENCE,
	arc.INTERNAL_NOTES, arc.EXCHANGE_RATE_TYPE, arc.EXCHANGE_DATE,
	arc.EXCHANGE_RATE, arc.TERRITORY_ID, arc.INVOICE_CURRENCY_CODE,
	arc.INITIAL_CUSTOMER_TRX_ID, arc.AGREEMENT_ID, arc.END_DATE_COMMITMENT,
	arc.START_DATE_COMMITMENT, arc.LAST_PRINTED_SEQUENCE_NUM,arc.ORIG_SYSTEM_BATCH_NAME,
	arc.POST_REQUEST_ID, arc.REQUEST_ID, arc.PROGRAM_APPLICATION_ID,
   	arc.PROGRAM_ID, arc.PROGRAM_UPDATE_DATE, arc.FINANCE_CHARGES,
   	arc.COMPLETE_FLAG, arc.POSTING_CONTROL_ID, arc.BILL_TO_ADDRESS_ID,
   	arc.RA_POST_LOOP_NUMBER, arc.SHIP_TO_ADDRESS_ID, arc.CREDIT_METHOD_FOR_RULES,
   	arc.CREDIT_METHOD_FOR_INSTALLMENTS, arc.RECEIPT_METHOD_ID,
	arc.RELATED_CUSTOMER_TRX_ID,
	arc.INVOICING_RULE_ID, arc.SHIP_VIA, arc.SHIP_DATE_ACTUAL,
	arc.WAYBILL_NUMBER, arc.FOB_POINT, arc.CUSTOMER_BANK_ACCOUNT_ID,
	arc.STATUS_TRX, arc.DOC_SEQUENCE_ID,
   	arc.DOC_SEQUENCE_VALUE, arc.PAYING_CUSTOMER_ID, arc.PAYING_SITE_USE_ID,
   	arc.RELATED_BATCH_SOURCE_ID, arc.DEFAULT_TAX_EXEMPT_FLAG,
   	arc.CREATED_FROM, sum(arp.AMOUNT_DUE_ORIGINAL), sum(arp.AMOUNT_DUE_REMAINING),
	art.NAME, racust.NAME, racust.TYPE
from	RA_TERMS_TL art,
	RA_CUST_TRX_TYPES_ALL racust,
	AR_PAYMENT_SCHEDULES_ALL arp,
        RA_CUSTOMER_TRX_ALL arc
where 	arc.previous_customer_trx_id = invoice_id
        AND (arp.CUSTOMER_TRX_ID = arc.customer_trx_id)
        AND (arc.last_update_date between nvl(t_start_date, arc.last_update_date)
	AND nvl(t_end_date, arc.last_update_date))
	AND (art.TERM_ID(+) = arc.TERM_ID)
        AND  nvl(art.language,apps_base_language) = apps_base_language
	AND (arc.CUST_TRX_TYPE_ID = racust.CUST_TRX_TYPE_ID)
	AND (racust.CUST_TRX_TYPE_ID, racust.ORG_ID) =
		(	SELECT 	t.CUST_TRX_TYPE_ID, t.ORG_ID
	 		FROM 	RA_CUST_TRX_TYPES_ALL t
			WHERE 	t.CUST_TRX_TYPE_ID = racust.CUST_TRX_TYPE_ID
			AND	rownum=1)
group by
	arc.CUSTOMER_TRX_ID, arc.LAST_UPDATED_BY, arc.LAST_UPDATE_DATE,
	arc.CREATION_DATE, arc.CREATED_BY, arc.LAST_UPDATE_LOGIN,
	arc.TRX_NUMBER, arc.CUST_TRX_TYPE_ID, arc.TRX_DATE,
	arc.SET_OF_BOOKS_ID, arc.BILL_TO_CONTACT_ID, arc.BATCH_ID,
	arc.BATCH_SOURCE_ID, arc.REASON_CODE, arc.SOLD_TO_CUSTOMER_ID,
	arc.SOLD_TO_CONTACT_ID, arc.SOLD_TO_SITE_USE_ID, arc.BILL_TO_CUSTOMER_ID,
	arc.BILL_TO_SITE_USE_ID, arc.SHIP_TO_CUSTOMER_ID, arc.SHIP_TO_CONTACT_ID,
	arc.SHIP_TO_SITE_USE_ID, arc.REMIT_TO_ADDRESS_ID, arc.TERM_ID,
	arc.TERM_DUE_DATE, arc.PREVIOUS_CUSTOMER_TRX_ID, arc.PRIMARY_SALESREP_ID,
	arc.PRINTING_ORIGINAL_DATE, arc.PRINTING_LAST_PRINTED, arc.PRINTING_OPTION,
	arc.PRINTING_COUNT, arc.PRINTING_PENDING, arc.PURCHASE_ORDER,
	arc.PURCHASE_ORDER_REVISION, arc.PURCHASE_ORDER_DATE, arc.CUSTOMER_REFERENCE,
	arc.INTERNAL_NOTES, arc.EXCHANGE_RATE_TYPE, arc.EXCHANGE_DATE,
	arc.EXCHANGE_RATE, arc.TERRITORY_ID, arc.INVOICE_CURRENCY_CODE,
	arc.INITIAL_CUSTOMER_TRX_ID, arc.AGREEMENT_ID, arc.END_DATE_COMMITMENT,
	arc.START_DATE_COMMITMENT, arc.LAST_PRINTED_SEQUENCE_NUM,arc.ORIG_SYSTEM_BATCH_NAME,
	arc.POST_REQUEST_ID, arc.REQUEST_ID, arc.PROGRAM_APPLICATION_ID,
   	arc.PROGRAM_ID, arc.PROGRAM_UPDATE_DATE, arc.FINANCE_CHARGES,
   	arc.COMPLETE_FLAG, arc.POSTING_CONTROL_ID, arc.BILL_TO_ADDRESS_ID,
   	arc.RA_POST_LOOP_NUMBER, arc.SHIP_TO_ADDRESS_ID, arc.CREDIT_METHOD_FOR_RULES,
   	arc.CREDIT_METHOD_FOR_INSTALLMENTS, arc.RECEIPT_METHOD_ID,
	arc.RELATED_CUSTOMER_TRX_ID,
	arc.INVOICING_RULE_ID, arc.SHIP_VIA, arc.SHIP_DATE_ACTUAL,
	arc.WAYBILL_NUMBER, arc.FOB_POINT, arc.CUSTOMER_BANK_ACCOUNT_ID,
	arc.STATUS_TRX, arc.DOC_SEQUENCE_ID,
   	arc.DOC_SEQUENCE_VALUE, arc.PAYING_CUSTOMER_ID, arc.PAYING_SITE_USE_ID,
   	arc.RELATED_BATCH_SOURCE_ID, arc.DEFAULT_TAX_EXEMPT_FLAG,
   	arc.CREATED_FROM, art.NAME, racust.NAME, racust.TYPE
order by 26 desc;
/* order by arc.previous_customer_trx_id desc */


PROCEDURE get_invoice_header
	(invoice_id			IN	OUT 	NOCOPY NUMBER,
	t_start_date			IN 	OUT	NOCOPY DATE,
	t_end_date			IN 	OUT	NOCOPY DATE,
	t_created_by				OUT	NOCOPY NUMBER,
	t_creation_date				OUT	NOCOPY DATE,
	t_last_updated_by			OUT	NOCOPY NUMBER,
	t_last_update_date			OUT	NOCOPY DATE,
	t_trx_number                 		OUT   	NOCOPY VARCHAR2,
	t_invoice_amount			OUT	NOCOPY NUMBER,
	t_balance_amount			OUT	NOCOPY NUMBER,
 	t_trx_date	            		OUT	NOCOPY DATE,
	t_cust_trx_type_id     			OUT   	NOCOPY NUMBER,
   	t_invoice_currency_code		        OUT   	NOCOPY VARCHAR2,
   	t_term_id                        	OUT   	NOCOPY NUMBER,
	t_customer_trx_id  	   		OUT   	NOCOPY NUMBER,
	t_last_update_login          		OUT	NOCOPY NUMBER,
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
	error_status				OUT	NOCOPY NUMBER,
	t_term_name				OUT	NOCOPY VARCHAR2,
	t_trx_name				OUT     NOCOPY VARCHAR2,
	t_type					OUT     NOCOPY VARCHAR2) IS

BEGIN
        SELECT language_code
        INTO apps_base_language
        FROM fnd_languages
        WHERE installed_flag = 'B';

	if NOT cur_get_invoice_header%ISOPEN
	then
		OPEN cur_get_invoice_header( invoice_id, t_start_date, t_end_date);
	end if;

	FETCH cur_get_invoice_header INTO
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
   		t_created_from,
		t_invoice_amount,
		t_balance_amount,
		t_term_name,
		t_trx_name,
		t_type;

	if cur_get_invoice_header%NOTFOUND
	then
		error_status := 100;
		close cur_get_invoice_header;
	end if;

	if row_to_fetch = 1 and cur_get_invoice_header%ISOPEN
	then
		close cur_get_invoice_header;
	end if;

	EXCEPTION

		when others then
		error_status := SQLCODE;
END get_invoice_header;
END GMF_AR_GET_INVOICE_HEADER;

/

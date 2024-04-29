--------------------------------------------------------
--  DDL for Package ARP_PROCESS_BR_BATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_BR_BATCHES" AUTHID CURRENT_USER AS
/* $Header: ARTEBRBS.pls 120.2 2003/10/24 02:09:34 orashid arhmapss.pls $ */


PROCEDURE insert_batch (
	p_form_name              	IN  	varchar2				,
	p_form_version           	IN  	number					,
	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE		,
	p_batch_date             	IN  	ra_batches.batch_date%TYPE		,
	p_gl_date                	IN  	ra_batches.gl_date%TYPE			,
	p_TYPE                   	IN  	ra_batches.TYPE%TYPE			,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE		,
  	p_comments               	IN  	ra_batches.comments%TYPE		,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE	,
	p_attribute1             	IN  	ra_batches.attribute1%TYPE		,
 	p_attribute2             	IN  	ra_batches.attribute2%TYPE		,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE		,
  	p_attribute4             	IN  	ra_batches.attribute4%TYPE		,
  	p_attribute5             	IN  	ra_batches.attribute5%TYPE		,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE		,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE		,
  	p_attribute8            	IN  	ra_batches.attribute8%TYPE		,
  	p_attribute9            	IN  	ra_batches.attribute9%TYPE		,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE		,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE		,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE		,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE		,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE		,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE		,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE		,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE		,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE	,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE	,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE	,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE,
  	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE	,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE	,
  	p_site_use_id		   	IN 	ar_selection_criteria.site_use_id%TYPE	,
  	p_selection_criteria_id  	OUT NOCOPY 	ra_batches.selection_criteria_id%TYPE	,
  	p_batch_id               	OUT NOCOPY 	ra_batches.batch_id%TYPE		,
  	p_name               	   	IN OUT NOCOPY 	ra_batches.name%TYPE			);




PROCEDURE update_batch (
  	p_form_name              	IN  	varchar2				,
	p_form_version           	IN  	number					,
  	p_batch_id               	IN  	ra_batches.batch_id%TYPE		,
  	p_name                 	  	IN  	ra_batches.name%TYPE			,
  	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE		,
  	p_batch_date             	IN  	ra_batches.batch_date%TYPE		,
  	p_gl_date                	IN  	ra_batches.gl_date%TYPE			,
  	p_TYPE                   	IN  	ra_batches.TYPE%TYPE			,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE		,
  	p_comments               	IN  	ra_batches.comments%TYPE		,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE	,
  	p_attribute1             	IN  	ra_batches.attribute1%TYPE		,
  	p_attribute2             	IN  	ra_batches.attribute2%TYPE		,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE		,
  	p_attribute4            	IN  	ra_batches.attribute4%TYPE		,
  	p_attribute5             	IN 	ra_batches.attribute5%TYPE		,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE		,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE		,
  	p_attribute8             	IN  	ra_batches.attribute8%TYPE		,
  	p_attribute9             	IN  	ra_batches.attribute9%TYPE		,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE		,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE		,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE		,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE		,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE		,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE		,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE		,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE		,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE	,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE	,
  	p_request_id		   	IN  	ra_batches.request_id%TYPE		,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE	,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE,
  	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE	,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE	,
  	p_site_use_id		   	IN  	ar_selection_criteria.site_use_id%TYPE	,
  	p_selection_criteria_id  	IN  OUT NOCOPY ar_selection_criteria.selection_criteria_id%TYPE);



PROCEDURE delete_batch (
  	p_form_name              	IN 	varchar2				,
  	p_form_version           	IN 	number					,
  	p_batch_id               	IN 	ra_batches.batch_id%TYPE		,
  	p_selection_criteria_id  	IN 	ar_selection_criteria.selection_criteria_id%TYPE);



PROCEDURE lock_compare_batch (
  	p_form_name              	IN  	varchar2			,
  	p_form_version           	IN  	number				,
  	p_batch_id               	IN  	ra_batches.batch_id%TYPE	,
  	p_name                   	IN  	ra_batches.name%TYPE		,
  	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE	,
  	p_batch_date            	IN  	ra_batches.batch_date%TYPE	,
  	p_gl_date                	IN  	ra_batches.gl_date%TYPE		,
  	p_TYPE                   	IN  	ra_batches.TYPE%TYPE		,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE	,
  	p_comments               	IN  	ra_batches.comments%TYPE	,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE,
  	p_attribute1             	IN  	ra_batches.attribute1%TYPE	,
  	p_attribute2             	IN  	ra_batches.attribute2%TYPE	,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE	,
  	p_attribute4             	IN  	ra_batches.attribute4%TYPE	,
  	p_attribute5             	IN  	ra_batches.attribute5%TYPE	,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE	,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE	,
  	p_attribute8             	IN  	ra_batches.attribute8%TYPE	,
  	p_attribute9             	IN  	ra_batches.attribute9%TYPE	,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE	,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE	,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE	,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE	,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE	,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE	,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE	,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE	,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE		,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE		,
  	p_selection_criteria_id  	IN  	ar_selection_criteria.selection_criteria_id%TYPE,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE		,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE	,
 	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE		,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE	,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE		,
  	p_site_use_id		   	IN  	ar_selection_criteria.site_use_id%TYPE		);


PROCEDURE submit_print (
	p_format			IN	varchar2	,
	p_BR_ID				IN	number		,
	p_request_id			OUT NOCOPY	number		);


PROCEDURE br_create(
	p_call                   	IN  	NUMBER					,
	p_draft_mode             	IN  	VARCHAR2 				,
	p_print_flag             	IN  	VARCHAR2				,
	p_batch_id               	IN  	RA_BATCHES.batch_id%TYPE 		,
	p_batch_source_id        	IN  	RA_BATCHES.batch_source_id%TYPE	        ,
	p_batch_date             	IN  	RA_BATCHES.batch_date%TYPE		,
	p_gl_date                	IN  	RA_BATCHES.gl_date%TYPE			,
	p_issue_date             	IN  	RA_BATCHES.issue_date%TYPE		,
	p_maturity_date          	IN  	RA_BATCHES.maturity_date%TYPE 		,
	p_currency_code          	IN  	RA_BATCHES.currency_code%TYPE 		,
	p_comments               	IN  	RA_BATCHES.comments%TYPE 		,
	p_special_instructions   	IN  	RA_BATCHES.special_instructions%TYPE	,
	p_attribute_category     	IN  	RA_BATCHES.attribute_category%TYPE	,
	p_attribute1             	IN  	VARCHAR2				,
	p_attribute2             	IN  	VARCHAR2				,
	p_attribute3             	IN  	VARCHAR2				,
	p_attribute4             	IN  	VARCHAR2				,
	p_attribute5             	IN  	VARCHAR2				,
	p_attribute6             	IN  	VARCHAR2				,
	p_attribute7             	IN  	VARCHAR2				,
	p_attribute8             	IN  	VARCHAR2				,
	p_attribute9             	IN  	VARCHAR2				,
	p_attribute10            	IN  	VARCHAR2				,
	p_attribute11            	IN  	VARCHAR2				,
	p_attribute12            	IN  	VARCHAR2				,
	p_attribute13            	IN  	VARCHAR2				,
	p_attribute14            	IN  	VARCHAR2				,
	p_attribute15            	IN  	VARCHAR2				,
	p_due_date_low           	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE	,
	p_due_date_high          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE	,
	p_trx_date_low           	IN  	RA_CUSTOMER_TRX.trx_date%TYPE		,
	p_trx_date_high          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE		,
	p_trx_type_id            	IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE	,
	p_rcpt_meth_id           	IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
	p_cust_bank_branch_id    	IN  	CE_BANK_BRANCHES_V.branch_party_id%TYPE	,
	p_trx_number_low         	IN  	RA_CUSTOMER_TRX.trx_number%TYPE 	,
	p_trx_number_high        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE 	,
	p_cust_class             	IN  	AR_LOOKUPS.lookup_code%TYPE		,
	p_cust_category          	IN  	AR_LOOKUPS.lookup_code%TYPE 		,
	p_customer_id            	IN  	hz_cust_accounts.cust_account_id%TYPE 		,
	p_site_use_id            	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE		,
	p_req_id                 	OUT NOCOPY 	NUMBER					,
	p_batch_process_status   	OUT NOCOPY 	VARCHAR2 				);

END ARP_PROCESS_BR_BATCHES;

 

/

--------------------------------------------------------
--  DDL for Package ARP_PROGRAM_GENERATE_BR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROGRAM_GENERATE_BR" AUTHID CURRENT_USER AS
/* $Header: ARBRTESS.pls 120.2 2003/10/23 07:44:46 orashid ship $ */


PROCEDURE auto_create_br_program(
		errbuf			      OUT NOCOPY VARCHAR2,
                retcode			      OUT NOCOPY VARCHAR2,
                p_call                        IN  NUMBER,
                p_draft_mode                  IN  VARCHAR2,
                p_print_flag                  IN  VARCHAR2,
                p_batch_id                    IN  RA_BATCHES.batch_id%TYPE			DEFAULT NULL,
                p_batch_source_id             IN  RA_BATCH_SOURCES.batch_source_id%TYPE,
                p_batch_date                  IN  VARCHAR2,
                p_gl_date                     IN  VARCHAR2					DEFAULT NULL,
                p_issue_date                  IN  VARCHAR2					DEFAULT NULL,
                p_maturity_date               IN  VARCHAR2					DEFAULT NULL,
                p_currency_code               IN  RA_BATCHES.currency_code%TYPE			DEFAULT NULL,
                p_comments                    IN  RA_BATCHES.comments%TYPE			DEFAULT NULL,
                p_special_instructions        IN  RA_BATCHES.special_instructions%TYPE		DEFAULT NULL,
                p_attribute_category          IN  RA_BATCHES.attribute_category%TYPE		DEFAULT NULL,
                p_attribute1                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute2                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute3                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute4                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute5                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute6                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute7                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute8                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute9                  IN  VARCHAR2					DEFAULT NULL,
                p_attribute10                 IN  VARCHAR2					DEFAULT NULL,
                p_attribute11                 IN  VARCHAR2					DEFAULT NULL,
                p_attribute12                 IN  VARCHAR2					DEFAULT NULL,
                p_attribute13                 IN  VARCHAR2					DEFAULT NULL,
                p_attribute14                 IN  VARCHAR2					DEFAULT NULL,
                p_attribute15                 IN  VARCHAR2					DEFAULT NULL,
                p_due_date_low                IN  VARCHAR2					DEFAULT NULL,
                p_due_date_high               IN  VARCHAR2					DEFAULT NULL,
                p_trx_date_low                IN  VARCHAR2					DEFAULT NULL,
                p_trx_date_high               IN  VARCHAR2					DEFAULT NULL,
                P_trx_type_id                 IN  RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE	DEFAULT NULL,
                p_rcpt_meth_id                IN  AR_RECEIPT_METHODS.receipt_method_id%TYPE	DEFAULT NULL,
                p_cust_bank_branch_id         IN  ce_bank_branches_v.branch_party_id%TYPE		DEFAULT NULL,
                p_trx_number_low              IN  RA_CUSTOMER_TRX.trx_number%TYPE		DEFAULT NULL,
                p_trx_number_high             IN  RA_CUSTOMER_TRX.trx_number%TYPE		DEFAULT NULL,
                p_cust_class                  IN  AR_LOOKUPS.lookup_code%TYPE			DEFAULT NULL,
                p_cust_category               IN  AR_LOOKUPS.lookup_code%TYPE			DEFAULT NULL,
                p_customer_id                 IN  HZ_CUST_ACCOUNTS.cust_account_id%TYPE			DEFAULT NULL,
                p_site_use_id                 IN  HZ_CUST_SITE_USES.site_use_id%TYPE			DEFAULT NULL);


PROCEDURE auto_create_br_API(
		p_api_version      		IN  NUMBER,
       		p_init_msg_list    		IN  VARCHAR2 := FND_API.G_FALSE	,
        	p_commit           		IN  VARCHAR2 := FND_API.G_TRUE,
        	p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        	x_return_status    		OUT NOCOPY VARCHAR2,
        	x_msg_count        		OUT NOCOPY NUMBER,
        	x_msg_data         		OUT NOCOPY VARCHAR2,
                p_customer_trx_id	    	IN  RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_bill_id	             	OUT NOCOPY RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_request_id                 	OUT NOCOPY NUMBER,
                p_nb_bill	             	OUT NOCOPY NUMBER);


FUNCTION revision RETURN VARCHAR2;

END ARP_PROGRAM_GENERATE_BR;

 

/

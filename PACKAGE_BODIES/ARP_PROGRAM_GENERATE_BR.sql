--------------------------------------------------------
--  DDL for Package Body ARP_PROGRAM_GENERATE_BR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROGRAM_GENERATE_BR" AS
/* $Header: ARBRTESB.pls 120.20.12000000.3 2007/07/25 13:38:15 nemani ship $ */

--------- Private Procedures
PROCEDURE from_automatic_batch_window(
    p_draft_mode            IN  	VARCHAR2,
    p_print_flag            IN  	VARCHAR2,
    p_batch_id		    IN		RA_BATCHES.batch_id%TYPE,
    p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_due_date_high         IN 		AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    P_trx_type_id           IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
    p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
    p_cust_bank_branch_id   IN  	ce_bank_branches_v.branch_party_id%TYPE,
    p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
    p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE);


PROCEDURE from_conc_request_window(
    p_print_flag	    IN		varchar2,
    p_batch_source_id	    IN		RA_BATCHES.batch_source_id%TYPE,
    p_batch_date	    IN		RA_BATCHES.batch_date%TYPE,
    p_gl_date               IN  	VARCHAR2,
    p_issue_date            IN  	VARCHAR2,
    p_maturity_date	    IN		RA_BATCHES.maturity_date%TYPE,
    p_currency_code	    IN		RA_BATCHES.currency_code%TYPE,
    p_comments              IN  	RA_BATCHES.comments%TYPE,
    p_special_instructions  IN  	RA_BATCHES.special_instructions%TYPE,
    p_attribute_category    IN  	RA_BATCHES.attribute_category%TYPE,
    p_attribute1            IN  	VARCHAR2,
    p_attribute2            IN  	VARCHAR2,
    p_attribute3            IN  	VARCHAR2,
    p_attribute4            IN  	VARCHAR2,
    p_attribute5            IN  	VARCHAR2,
    p_attribute6            IN  	VARCHAR2,
    p_attribute7            IN  	VARCHAR2,
    p_attribute8            IN  	VARCHAR2,
    p_attribute9            IN  	VARCHAR2,
    p_attribute10           IN  	VARCHAR2,
    p_attribute11           IN  	VARCHAR2,
    p_attribute12           IN  	VARCHAR2,
    p_attribute13           IN  	VARCHAR2,
    p_attribute14           IN  	VARCHAR2,
    p_attribute15           IN  	VARCHAR2,
    p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_due_date_high         IN 		AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    P_trx_type_id           IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
    p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
    p_cust_bank_branch_id   IN  	CE_BANK_BRANCHES_V.branch_party_id%TYPE,
    p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
    p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE);

PROCEDURE arbr_cr_tmp_table;


PROCEDURE drop_tmp_table;


PROCEDURE create_batch_header (
    p_batch_source_id	    IN		RA_BATCHES.batch_source_id%TYPE,
    p_batch_date	    IN		RA_BATCHES.batch_date%TYPE,
    p_gl_date               IN  	VARCHAR2,                    -- currently not used
    p_issue_date            IN  	VARCHAR2,                    -- currently not used
    p_maturity_date	    IN		RA_BATCHES.maturity_date%TYPE,
    p_currency_code	    IN		RA_BATCHES.currency_code%TYPE,
    p_comments              IN  	RA_BATCHES.comments%TYPE,
    p_special_instructions  IN  	RA_BATCHES.special_instructions%TYPE,
    p_attribute_category    IN  	RA_BATCHES.attribute_category%TYPE,
    p_attribute1            IN  	VARCHAR2,
    p_attribute2            IN  	VARCHAR2,
    p_attribute3            IN  	VARCHAR2,
    p_attribute4            IN  	VARCHAR2,
    p_attribute5            IN  	VARCHAR2,
    p_attribute6            IN  	VARCHAR2,
    p_attribute7            IN  	VARCHAR2,
    p_attribute8            IN  	VARCHAR2,
    p_attribute9            IN  	VARCHAR2,
    p_attribute10           IN  	VARCHAR2,
    p_attribute11           IN  	VARCHAR2,
    p_attribute12           IN  	VARCHAR2,
    p_attribute13           IN  	VARCHAR2,
    p_attribute14           IN  	VARCHAR2,
    p_attribute15           IN  	VARCHAR2,
    p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_due_date_high         IN 		AR_PAYMENT_SCHEDULES.due_date%TYPE,
    p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
    P_trx_type_id           IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
    p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
    p_cust_bank_branch_id   IN  	CE_BANK_BRANCHES_V.branch_party_id%TYPE,
    p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
    p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
    p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
    p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
    p_batch_id              OUT NOCOPY 	RA_BATCHES.batch_id%TYPE,
    p_selection_criteria_id OUT NOCOPY  RA_BATCHES.selection_criteria_id%TYPE);


PROCEDURE update_batch_status(
                p_draft_mode            IN  VARCHAR2,
		p_batch_id              IN   	RA_BATCHES.batch_id%TYPE);


PROCEDURE select_trx_and_create_BR(
                p_draft_mode            IN  	VARCHAR2,
                p_call                  IN      NUMBER,
                p_batch_id              IN   	RA_BATCHES.batch_id%TYPE,
                p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high         IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                P_trx_type_id           IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
                p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
                p_cust_bank_branch_id   IN  	CE_BANK_BRANCHES_V.branch_party_id%TYPE,
                p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE);

-- Bug 3922691 : added additional parameters so dynamic sql can be more fine-tuned
PROCEDURE construct_suffixe_select(
		p_lead_days			IN AR_RECEIPT_METHODS.lead_days%TYPE,
		p_suffixe_select_statement	OUT NOCOPY varchar2,
                p_due_date_low                  IN AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high                 IN AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low                  IN RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high                 IN RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_type_id                   IN ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_trx_number_low                IN RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high               IN RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class                    IN AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category                 IN AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id                   IN HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id                   IN HZ_CUST_SITE_USES.site_use_id%TYPE,
                p_le_id                         IN RA_CUSTOMER_TRX.legal_entity_id%TYPE);

-- bug 3922691 : consolidate code used in 2 procedures
PROCEDURE construct_hz(
                p_receipt_creation_rule_code    IN AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
                p_customer_id                   IN HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_suffix_hz                     OUT NOCOPY varchar2);

-- bug 3922691 : remove p_suffixe_select_statement, add p_lead_days
PROCEDURE select_DM_and_CM_IMM(
		p_lead_days                     IN      AR_RECEIPT_METHODS.lead_days%TYPE,
		p_receipt_creation_rule_code	IN	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
                p_due_date_low          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
               	p_due_date_high         	IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_type_id           	IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_trx_number_low        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            	IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         	IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           	IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
		p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
		p_batch_id			IN	RA_BATCHES.batch_id%TYPE,
		p_invoice_currency_code		IN 	RA_CUSTOMER_TRX.invoice_currency_code%TYPE,
		p_exchange_rate      	    	IN 	RA_CUSTOMER_TRX.exchange_rate%TYPE,
                p_customer_bank_account_id      IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
                p_le_id                         IN      RA_CUSTOMER_TRX.legal_entity_id%TYPE);

-- bug 3922691 : remove p_suffixe_select_statement, add p_lead_days
PROCEDURE select_trx_NIMM(
                p_lead_days                     IN      AR_RECEIPT_METHODS.lead_days%TYPE,
                p_receipt_creation_rule_code    IN      AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
                p_due_date_low          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
               	p_due_date_high         	IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_type_id           	IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
                p_trx_number_low        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            	IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         	IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           	IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
		p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
		p_batch_id			IN	RA_BATCHES.batch_id%TYPE,
		p_invoice_currency_code		IN 	RA_CUSTOMER_TRX.invoice_currency_code%TYPE,
		p_exchange_rate      	    	IN 	RA_CUSTOMER_TRX.exchange_rate%TYPE,
		p_payment_schedule_id		IN	AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
                p_customer_trx_id		IN	RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_customer_bank_account_id      IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
                p_le_id                         IN      RA_CUSTOMER_TRX.legal_entity_id%TYPE);

PROCEDURE create_BR(
		p_draft_mode            	IN  	VARCHAR2,
                p_call                          IN      NUMBER,
                p_batch_id              	IN   	RA_BATCHES.batch_id%TYPE,
		p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
		p_receipt_creation_rule_code	IN	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
		p_maturity_date_rule_code	IN	AR_RECEIPT_METHODS.maturity_date_rule_code%TYPE,
		p_br_min_acctd_amount		IN	AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE,
		p_br_max_acctd_amount		IN	AR_RECEIPT_METHODS.br_max_acctd_amount%TYPE,
		p_currency_code			IN	RA_BATCHES.currency_code%TYPE,
                p_customer_bank_account_id      IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE DEFAULT NULL,
                p_le_id                         IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
                p_bill_id			OUT NOCOPY RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_request_id			OUT NOCOPY NUMBER);


-- Bug 1420183 Added p_receipt_method_id
PROCEDURE AR_BR_INSERT_INTO_REPORT_TABLE(
                p_request_id                   IN  RA_CUSTOMER_TRX.request_id%TYPE,
                p_batch_id                     IN  RA_BATCHES.batch_id%TYPE,
                p_br_customer_trx_id           IN  RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_bill_number                  IN  RA_CUSTOMER_TRX.TRX_NUMBER%TYPE,
                p_br_amount                    IN  AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE,
                p_br_currency                  IN  RA_BATCHES.currency_code%TYPE,
                p_batch_status                 IN  RA_BATCHES.status%TYPE,
                p_maturity_date                IN  RA_BATCHES.maturity_date%TYPE,
                p_drawee_id                    IN  RA_CUSTOMER_TRX.drawee_id%TYPE,
                p_drawee_contact_id            IN  RA_CUSTOMER_TRX.drawee_contact_id%TYPE,
                p_drawee_site_use_id           IN  RA_CUSTOMER_TRX.drawee_site_use_id%TYPE,
                p_drawee_bank_account_id       IN  RA_CUSTOMER_TRX.drawee_bank_account_id%TYPE,
                p_transaction_id               IN  RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_amount_assigned              IN  RA_CUSTOMER_TRX.br_amount%TYPE,
                p_receipt_method_id            IN  AR_RECEIPT_METHODS.receipt_method_id%TYPE);

PROCEDURE run_report_pvt(
	       p_batch_id	IN	RA_BATCHES.batch_id%TYPE);


PROCEDURE print_BR_pvt(
	p_object_id			IN	RA_BATCHES.batch_id%TYPE,
        p_call                          IN      NUMBER,
        p_request_id			OUT NOCOPY NUMBER);


--------- Global variables
G_PKG_NAME 		CONSTANT varchar2(30) 	:= 'ARP_PROGRAM_GENERATE_BR';

TYPE			cur_typ	IS REF CURSOR;

/* Bug 3472744 Declarations for the new pl/sql table included
       and other changes. */

l_error_mesg  fnd_new_messages.message_text%TYPE;
g_num_br_failed    NUMBER := 0 ;

g_ctr  NUMBER := 0;

TYPE errorinvoicerectyp IS RECORD (
     payment_schedule_id ar_payment_schedules.payment_schedule_id%TYPE ,
     customer_trx_id     ar_payment_schedules.customer_trx_id%TYPE ,
     trx_number          ar_payment_schedules.trx_number%TYPE);

TYPE errorinvoicetabtyp IS TABLE OF errorinvoicerectyp
INDEX by BINARY_INTEGER;

errorinv errorinvoicetabtyp;

/* Bug 3472744 End of changes */

g_tmp_table_nimm 	varchar2(50);
g_tmp_table_imm 	varchar2(50);
g_tmp_table_aimm        varchar2(50);  /* Bug 3930958 : define new temporary table */

g_num_br_created	NUMBER :=0;
g_field			varchar2(30);
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- SSA - R12
g_org_id                AR_SYSTEM_PARAMETERS.org_id%TYPE;


PROCEDURE write_debug_and_log(p_message IN VARCHAR2) IS

BEGIN

  IF FND_GLOBAL.CONC_REQUEST_ID is not null THEN

    fnd_file.put_line(FND_FILE.LOG,p_message);

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(p_message);
  END IF;

EXCEPTION
  WHEN others THEN
    NULL;

END write_debug_and_log;


-- Bug2290332: Added for better debugging of create_br procedure when running
-- from Transaction Form.
PROCEDURE program_debug(p_call IN NUMBER, string IN VARCHAR2) IS
BEGIN
IF p_call = 3 THEN
   arp_util.debug(string);
ELSE
   write_debug_and_log(string);
END IF;
END;
--------- Public Procedures

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    auto_create_br_program                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 |     p_call :                                                              |
 |         = 1 if submit from the Automatic Batch Window                     |
 |         = 2 if submit from the Submit Concurrent Request Window           |
 |     p_draft_mode                                                          |
 |         = Y if mode draft is selected                                     |
 |         = N if mode create is selected                                    |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 20/07/2000           |
 |                                                                           |
 +===========================================================================*/
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
                P_trx_type_id                 IN  ra_cust_trx_types.cust_trx_type_id%TYPE	DEFAULT NULL,
                p_rcpt_meth_id                IN  AR_RECEIPT_METHODS.receipt_method_id%TYPE	DEFAULT NULL,
                p_cust_bank_branch_id         IN  ce_bank_branches_v.branch_party_id%TYPE		DEFAULT NULL,
                p_trx_number_low              IN  RA_CUSTOMER_TRX.trx_number%TYPE		DEFAULT NULL,
                p_trx_number_high             IN  RA_CUSTOMER_TRX.trx_number%TYPE		DEFAULT NULL,
                p_cust_class                  IN  AR_LOOKUPS.lookup_code%TYPE			DEFAULT NULL,
                p_cust_category               IN  AR_LOOKUPS.lookup_code%TYPE			DEFAULT NULL,
                p_customer_id                 IN  HZ_CUST_ACCOUNTS.cust_account_id%TYPE			DEFAULT NULL,
                p_site_use_id                 IN  HZ_CUST_SITE_USES.site_use_id%TYPE			DEFAULT NULL) IS

-- Dates
l_batch_date			DATE	:= NULL;
l_gl_date			DATE	:= NULL;
l_issue_date			DATE	:= NULL;
l_maturity_date			DATE	:= NULL;
l_due_date_low			DATE	:= NULL;
l_due_date_high			DATE	:= NULL;
l_trx_date_low			DATE	:= NULL;
l_trx_date_high			DATE	:= NULL;

l_batch_id 			RA_BATCHES.batch_id%TYPE;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.auto_create_br_program (+)');

--------------------------------------------------------------
-- Date Conversions
--------------------------------------------------------------
l_batch_date	:= TO_DATE(p_batch_date,'YYYY/MM/DD HH24:MI:SS');

IF (p_gl_date IS NOT NULL) THEN
    l_gl_date	:= TO_DATE(p_gl_date,'YYYY/MM/DD HH24:MI:SS');
END IF;

IF (p_issue_date IS NOT NULL) THEN
    l_issue_date := TO_DATE(p_issue_date,'YYYY/MM/DD HH24:MI:SS');
END IF;

IF (p_maturity_date IS NOT NULL) THEN
    l_maturity_date := TO_DATE(p_maturity_date,'YYYY/MM/DD HH24:MI:SS');
END IF;

IF (p_due_date_low IS NOT NULL) AND (p_due_date_high IS NOT NULL) THEN
    l_due_date_low  := TO_DATE(p_due_date_low,'YYYY/MM/DD HH24:MI:SS');
    l_due_date_high := TO_DATE(p_due_date_high,'YYYY/MM/DD HH24:MI:SS');
END IF;

IF (p_trx_date_low IS NOT NULL) AND (p_trx_date_high IS NOT NULL) THEN
    l_trx_date_low  := TO_DATE(p_trx_date_low,'YYYY/MM/DD HH24:MI:SS');
    l_trx_date_high := TO_DATE(p_trx_date_high,'YYYY/MM/DD HH24:MI:SS');
END IF;

--------------------------------------------------------------
-- Process
--------------------------------------------------------------
IF (p_call = 1) THEN

    ARP_PROGRAM_GENERATE_BR.from_automatic_batch_window(
                p_draft_mode,
                p_print_flag,
                p_batch_id,
                l_due_date_low,
                l_due_date_high,
                l_trx_date_low,
                l_trx_date_high,
                p_trx_type_id,
                p_rcpt_meth_id,
                p_cust_bank_branch_id,
                p_trx_number_low,
                p_trx_number_high,
                p_cust_class,
                p_cust_category,
                p_customer_id,
                p_site_use_id);

ELSIF (p_call = 2) THEN

       ARP_PROGRAM_GENERATE_BR.from_conc_request_window(
                p_print_flag,
                p_batch_source_id,
                l_batch_date,
                l_gl_date,
                l_issue_date,
                l_maturity_date,
                p_currency_code,
                p_comments,
                p_special_instructions,
                p_attribute_category,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                p_attribute13,
                p_attribute14,
                p_attribute15,
                l_due_date_low,
                l_due_date_high,
                l_trx_date_low,
                l_trx_date_high,
                P_trx_type_id,
                p_rcpt_meth_id,
                p_cust_bank_branch_id,
                p_trx_number_low,
                p_trx_number_high,
                p_cust_class,
                p_cust_category,
                p_customer_id,
                p_site_use_id);


ELSE
   g_field := 'p_call';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','auto_create_br_program');
   FND_MESSAGE.set_token('PARAMETER', g_field);
   APP_EXCEPTION.raise_exception;
END IF;

--Temporary table Drop
ARP_PROGRAM_GENERATE_BR.drop_tmp_table;

/* Bug 3472744 Printing the errored BRs at the end of the log file. */
IF (g_num_br_failed > 0)
THEN
 IF errorinv.EXISTS(g_ctr-1)
 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');

    FND_MESSAGE.SET_NAME('AR','AR_BR_INVALID_TRX_WARNING');
    l_error_mesg := FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_mesg);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'*******************************************************************');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Transaction Number'||rpad(' ',8)||'Payment
Schedule Id'||rpad(' ',7)||'Customer Trx Id'||rpad(' ',11));

    FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------'||rpad(' ',8)||'-------------------'||rpad(' ',7)||'---------------'||rpad(' ',11));

    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');

      FOR l_ctr IN errorinv.FIRST .. errorinv.LAST LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ' || rpad(errorinv(l_ctr).trx_number,26)|| rpad(errorinv(l_ctr).payment_schedule_id,26) || rpad(errorinv(l_ctr).customer_trx_id,26));
      END LOOP;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');

     FND_FILE.PUT_LINE(FND_FILE.LOG,'*******************************************************************');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');

 END IF;
END IF ;

--Temporary table Drop
ARP_PROGRAM_GENERATE_BR.drop_tmp_table;

COMMIT;

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.auto_create_br_program (-)');

EXCEPTION
 WHEN OTHERS THEN
--Temporary table Drop
   ARP_PROGRAM_GENERATE_BR.drop_tmp_table;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.auto_create_br_program');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   RAISE;

END auto_create_br_program;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    from_automatic_batch_window                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 20/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE from_automatic_batch_window(
                p_draft_mode            IN  	VARCHAR2,
                p_print_flag            IN  	VARCHAR2,
                p_batch_id		IN	RA_BATCHES.batch_id%TYPE,
                p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high         IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                P_trx_type_id           IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
                p_cust_bank_branch_id   IN  	ce_bank_branches_v.branch_party_id%TYPE,
                p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE) IS

l_request_id	NUMBER;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.from_automatic_batch_window (+)');

-- Temporary table Creation
ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table;

-- Select the transactions using the users criteria and create the Bills Receivable
ARP_PROGRAM_GENERATE_BR.select_trx_and_create_BR(
                p_draft_mode,
                1,               -- p_call
                p_batch_id,
                p_due_date_low,
                p_due_date_high,
                p_trx_date_low,
                p_trx_date_high,
                P_trx_type_id,
                p_rcpt_meth_id,
                p_cust_bank_branch_id,
                p_trx_number_low,
                p_trx_number_high,
                p_cust_class,
                p_cust_category,
                p_customer_id,
                p_site_use_id);
-- Update the batch status to 'CREATION_COMPLETED' if the batch run in Create mode.
-- Otherwise, the batch status is updated to 'DRAFT'.
ARP_PROGRAM_GENERATE_BR.update_batch_status(
                p_draft_mode,
		p_batch_id);

/* Bug 3472744 Added the check for number of brs created before
       calling the Automatic Batches report and BR printing program. */

IF (g_num_br_created > 0)
THEN
   ------ Run the report 'Automatic Transactions Batch'
          run_report_pvt(p_batch_id);

   ------ Action PRINT BR
          IF (p_print_flag = 'Y') THEN
            print_BR_pvt(p_batch_id,1,l_request_id);
          END IF;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.from_automatic_batch_window (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.from_automatic_batch_window');
   RAISE;

END from_automatic_batch_window;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    from_conc_request_window                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 20/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE from_conc_request_window(
                p_print_flag		IN	varchar2,
		p_batch_source_id	IN	RA_BATCHES.batch_source_id%TYPE,
                p_batch_date		IN	RA_BATCHES.batch_date%TYPE,
                p_gl_date               IN  	VARCHAR2,
                p_issue_date            IN  	VARCHAR2,
                p_maturity_date		IN	RA_BATCHES.maturity_date%TYPE,
                p_currency_code		IN	RA_BATCHES.currency_code%TYPE,
                p_comments              IN  	RA_BATCHES.comments%TYPE,
                p_special_instructions  IN  	RA_BATCHES.special_instructions%TYPE,
                p_attribute_category    IN  	RA_BATCHES.attribute_category%TYPE,
                p_attribute1            IN  	VARCHAR2,
                p_attribute2            IN  	VARCHAR2,
                p_attribute3            IN  	VARCHAR2,
                p_attribute4            IN  	VARCHAR2,
                p_attribute5            IN  	VARCHAR2,
                p_attribute6            IN  	VARCHAR2,
                p_attribute7            IN  	VARCHAR2,
                p_attribute8            IN  	VARCHAR2,
                p_attribute9            IN  	VARCHAR2,
                p_attribute10           IN  	VARCHAR2,
                p_attribute11           IN  	VARCHAR2,
                p_attribute12           IN  	VARCHAR2,
                p_attribute13           IN  	VARCHAR2,
                p_attribute14           IN  	VARCHAR2,
                p_attribute15           IN  	VARCHAR2,
                p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high         IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                P_trx_type_id           IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
                p_cust_bank_branch_id   IN  	ce_bank_branches_v.branch_party_id%TYPE,
                p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE) IS

l_batch_id 			RA_BATCHES.batch_id%TYPE;
l_selection_criteria_id 	RA_BATCHES.selection_criteria_id%TYPE;

l_request_id	NUMBER;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.from_conc_request_window (+)');

-- Temporary table Creation
ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table;

-- Insert the batch header in RA_BATCHES and the criteria in AR_SELECTION_CRITERIA
ARP_PROGRAM_GENERATE_BR.create_batch_header(
		p_batch_source_id,
                p_batch_date,
                p_gl_date,
                p_issue_date,
                p_maturity_date,
                p_currency_code,
                p_comments,
                p_special_instructions,
                p_attribute_category,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                p_attribute13,
                p_attribute14,
                p_attribute15,
                p_due_date_low,
                p_due_date_high,
                p_trx_date_low,
                p_trx_date_high,
                P_trx_type_id,
                p_rcpt_meth_id,
                p_cust_bank_branch_id,
                p_trx_number_low,
                p_trx_number_high,
                p_cust_class,
                p_cust_category,
                p_customer_id,
                p_site_use_id,
                l_batch_id,
                l_selection_criteria_id);



-- Select the transactions using the users criteria and create the Bills Receivable
ARP_PROGRAM_GENERATE_BR.select_trx_and_create_BR(
                'N',               -- p_draft_mode (the user do not have the option of creating a BR batch in Draft Mode, by SRS)
                2,                 -- p_call
                l_batch_id,
                p_due_date_low,
                p_due_date_high,
                p_trx_date_low,
                p_trx_date_high,
                P_trx_type_id,
                p_rcpt_meth_id,
                p_cust_bank_branch_id,
                p_trx_number_low,
                p_trx_number_high,
                p_cust_class,
                p_cust_category,
                p_customer_id,
                p_site_use_id);


--- The batch status is updated to 'Creation Completed'
ARP_PROGRAM_GENERATE_BR.update_batch_status(
                'N',		-- p_draft_mode
		l_batch_id);

/* Bug 3472744 Added the check for number of brs created before
       calling the Automatic Batches report and BR printing program. */

IF (g_num_br_created > 0)
THEN
    -- Run the report 'Automatic Transactions Batch'
       run_report_pvt(l_batch_id);

    ------ Action PRINT BR
       IF (p_print_flag = 'Y') THEN
          print_BR_pvt(l_batch_id,2,l_request_id);
       END IF;
END IF;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.from_conc_request_window (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.from_conc_request_window');
   RAISE;

END from_conc_request_window;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_batch_header                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_batch_header (
		p_batch_source_id	IN	RA_BATCHES.batch_source_id%TYPE,
                p_batch_date		IN	RA_BATCHES.batch_date%TYPE,
                p_gl_date               IN  	VARCHAR2,                    -- currently not used
                p_issue_date            IN  	VARCHAR2,                    -- currently not used
                p_maturity_date		IN	RA_BATCHES.maturity_date%TYPE,
                p_currency_code		IN	RA_BATCHES.currency_code%TYPE,
                p_comments              IN  	RA_BATCHES.comments%TYPE,
                p_special_instructions  IN  	RA_BATCHES.special_instructions%TYPE,
                p_attribute_category    IN  	RA_BATCHES.attribute_category%TYPE,
                p_attribute1            IN  	VARCHAR2,
                p_attribute2            IN  	VARCHAR2,
                p_attribute3            IN  	VARCHAR2,
                p_attribute4            IN  	VARCHAR2,
                p_attribute5            IN  	VARCHAR2,
                p_attribute6            IN  	VARCHAR2,
                p_attribute7            IN  	VARCHAR2,
                p_attribute8            IN  	VARCHAR2,
                p_attribute9            IN  	VARCHAR2,
                p_attribute10           IN  	VARCHAR2,
                p_attribute11           IN  	VARCHAR2,
                p_attribute12           IN  	VARCHAR2,
                p_attribute13           IN  	VARCHAR2,
                p_attribute14           IN  	VARCHAR2,
                p_attribute15           IN  	VARCHAR2,
                p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high         IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                P_trx_type_id           IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
                p_cust_bank_branch_id   IN  	ce_bank_branches_v.branch_party_id%TYPE,
                p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
                p_batch_id              OUT NOCOPY RA_BATCHES.batch_id%TYPE,
                p_selection_criteria_id OUT NOCOPY
                       RA_BATCHES.selection_criteria_id%TYPE)  IS
l_issue_date		RA_BATCHES.issue_date%TYPE;
l_gl_date		RA_BATCHES.gl_date%TYPE;
l_default_rule_used	VARCHAR2(30);
l_error_message		VARCHAR2(30);

l_batch_id      	RA_BATCHES.batch_id%TYPE;
l_selection_criteria_id RA_BATCHES.batch_id%TYPE;
l_name			RA_BATCHES.name%TYPE;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.create_batch_header (+)');

-- The Issue date will be inherited from the Batch date
l_issue_date	:= p_batch_date;

--------------------------------------------------------------
-- Validations
--------------------------------------------------------------
IF NVL(p_maturity_date,l_issue_date) < l_issue_date THEN
    FND_MESSAGE.set_name('AR','AR_BR_MAT_BEFORE_ISSUE_DATE');
    APP_EXCEPTION.raise_exception;
END IF;

-- The GL date will follow defaulting by first trying the issue date, then following open period rules
IF (arp_util.validate_and_default_gl_date(p_batch_date,             		-- gl_date
            				  NULL,                     		-- trx_date
             				  NULL,                     		-- validation_date1
             				  NULL,                      		-- validation-date2
             				  NULL,                      		-- validation-date3
             				  l_issue_date,              		-- default_date1
             				  NULL,                      		-- default_date2
             				  NULL,                      		-- default_date3
             				  NULL,                   	   	-- p_allow_not_open_flag
             				  NULL,                    		-- p_invoicing_rule_id
             				  arp_global.set_of_books_id,		-- p_set_of_books_id
             				  arp_global.program_application_id,	-- p_application-id
             				  l_gl_date,
             				  l_default_rule_used,
             				  l_error_message) = FALSE) THEN
    FND_MESSAGE.set_name('AR', 'GENERIC_MESSAGE');
    FND_MESSAGE.set_token('GENERIC_TEXT',l_error_message);
    APP_EXCEPTION.raise_exception;
END IF;

-- Insert the batch header in RA_BATCHES and the criteria in AR_SELECTION_CRITERIA
arp_process_br_batches.insert_batch('FNDRSRUN',                      -- p_form_name
                                     NULL,                           -- p_form_version
                                     p_batch_source_id,              -- p_batch_source_id
                                     p_batch_date,                   -- p_batch_date
                                     l_gl_date,                      -- p_gl_date
                                     'BR',                           -- p_type
                            	     p_currency_code,                -- p_currency_code
                                     p_comments,                     -- p_comments
                		     p_attribute_category,           -- p_attribute_category
                		     p_attribute1,                   -- p_attribute1
                		     p_attribute2,                   -- p_attribute2
                		     p_attribute3,                   -- p_attribute3
            			     p_attribute4,                   -- p_attribute4
               			     p_attribute5,                   -- p_attribute5
              			     p_attribute6,                   -- p_attribute6
              			     p_attribute7,                   -- p_attribute7
              			     p_attribute8,                   -- p_attribute8
             			     p_attribute9,                   -- p_attribute9
             			     p_attribute10,                  -- p_attribute10
              			     p_attribute11,                  -- p_attribute11
             			     p_attribute12,                  -- p_attribute12
             			     p_attribute13,                  -- p_attribute13
              			     p_attribute14,                  -- p_attribute14
             			     p_attribute15,                  -- p_attribute15
                                     l_issue_date,		     -- p_issue_date
                                     p_maturity_date,                -- p_maturity_date
                                     p_special_instructions,	     -- p_special_instructions
                                     'CREATION_STARTED',             -- p_batch_process_status
              			     p_due_date_low,		     -- p_due_date_low
                		     p_due_date_high,                -- p_due_date_high
                		     p_trx_date_low,                 -- p_trx_date_low
              			     p_trx_date_high,                -- p_trx_date_high
            			     P_trx_type_id,                  -- p_cust_trx_type_id
             			     p_rcpt_meth_id,                 -- p_receipt_method_id
           			     p_cust_bank_branch_id,          -- p_bank_branch_id
           			     p_trx_number_low,               -- p_trx_number_low
          			     p_trx_number_high,              -- p_trx_number_high
          			     p_cust_class,                   -- p_customer_class_code
            			     p_cust_category,                -- p_customer_category_code
               			     p_customer_id,                  -- p_customer_id
                		     p_site_use_id,                  -- p_site_use_id
                              	     l_selection_criteria_id,
                              	     l_batch_id,
                              	     l_name);

FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert the BR Creation Batch name:'||l_name);

p_selection_criteria_id := l_selection_criteria_id;
p_batch_id 		:= l_batch_id;

COMMIT;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.create_batch_header (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.create_batch_header');
   RAISE;

END create_batch_header;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_batch_status                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 08/08/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_batch_status(
                p_draft_mode            IN  VARCHAR2,
		p_batch_id              IN   	RA_BATCHES.batch_id%TYPE) IS

l_batch_rec			RA_BATCHES%ROWTYPE;
l_criteria_rec			AR_SELECTION_CRITERIA%ROWTYPE;

l_selection_criteria_id 	RA_BATCHES.selection_criteria_id%TYPE;
l_status			RA_BATCHES.batch_process_status%TYPE;


BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.update_batch_status (+)');

-- fetch the batch
arp_tbat_pkg.lock_fetch_p(l_batch_rec,p_batch_id);

-- fetch the criteria
IF (l_batch_rec.selection_criteria_id IS NOT NULL) THEN
    Select *
    into l_criteria_rec
    from ar_selection_criteria
    where selection_criteria_id = l_batch_rec.selection_criteria_id;
END IF;

-- Update the batch status to 'CREATION_COMPLETED' if the batch run in Create mode.
-- Otherwise, the batch status is updated to 'DRAFT'.

IF (p_draft_mode = 'Y') THEN
    l_status := 'DRAFT';
ELSE
    l_status := 'CREATION_COMPLETED';
END IF;

arp_process_br_batches.update_batch ('FNDRSRUN',                   		-- p_form_name
                                      NULL,                          		-- p_form_version
				      p_batch_id,				-- p_batch_id
  				      l_batch_rec.name,				-- p_name
  				      l_batch_rec.batch_source_id,		-- p_batch_source_id
  				      l_batch_rec.batch_date,			-- p_batch_date
  				      l_batch_rec.gl_date,			-- p_gl_date
  				      l_batch_rec.type,				-- p_type
  				      l_batch_rec.currency_code,		-- p_currency_code
  				      l_batch_rec.comments,			-- p_comments
  				      l_batch_rec.attribute_category,		-- p_attribute_category
  				      l_batch_rec.attribute1,			-- p_attribute1
  				      l_batch_rec.attribute2,			-- p_attribute2
  				      l_batch_rec.attribute3,			-- p_attribute3
  				      l_batch_rec.attribute4,			-- p_attribute4
  				      l_batch_rec.attribute5,			-- p_attribute5
  				      l_batch_rec.attribute6,			-- p_attribute6
  				      l_batch_rec.attribute7,			-- p_attribute7
  				      l_batch_rec.attribute8,			-- p_attribute8
  				      l_batch_rec.attribute9,			-- p_attribute9
  				      l_batch_rec.attribute10,			-- p_attribute10
  				      l_batch_rec.attribute11,			-- p_attribute11
  				      l_batch_rec.attribute12,			-- p_attribute12
  				      l_batch_rec.attribute13,			-- p_attribute13
  				      l_batch_rec.attribute14,			-- p_attribute14
  				      l_batch_rec.attribute15,			-- p_attribute15
  				      l_batch_rec.issue_date,			-- p_issue_date
  				      l_batch_rec.maturity_date,		-- p_maturity_date
  				      l_batch_rec.special_instructions,		-- p_special_instructions
  				      l_status,					-- p_batch_process_status
  				      arp_global.request_id,			-- p_request_id
  				      l_criteria_rec.due_date_low,		-- p_due_date_low,
  				      l_criteria_rec.due_date_high,		-- p_due_date_high,
  				      l_criteria_rec.trx_date_low,		-- p_trx_date_low,
  				      l_criteria_rec.trx_date_high,		-- p_trx_date_high,
				      l_criteria_rec.cust_trx_type_id,		-- p_cust_trx_type_id
  				      l_criteria_rec.receipt_method_id,		-- p_receipt_method_id
  				      l_criteria_rec.bank_branch_id,		-- p_bank_branch_id
  				      l_criteria_rec.trx_number_low,		-- p_trx_number_low
  				      l_criteria_rec.trx_number_high,		-- p_trx_number_high
  				      l_criteria_rec.customer_class_code,	-- p_customer_class_code
  				      l_criteria_rec.customer_category_code,	-- p_customer_category_code
  				      l_criteria_rec.customer_id,		-- p_customer_id
  				      l_criteria_rec.site_use_id,		-- p_site_use_id
  				      l_selection_criteria_id);

COMMIT;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.update_batch_status (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.update_batch_status');
   RAISE;

END update_batch_status;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_trx_and_create_BR                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/07/2000           |
 |									     |
 | 06-Jun-01	VCRISOST	Bug 1808976 : redefine c_receipt_methods to  |
 |				select customer_bank_account_id as well since|
 |				this is now an implicit grouping rule        |
 | 17-JAN-04    VCRISOST        Bug 4109513 : major changes to looping       |
 |                              mechanism to avoid multiple selects using    |
 |                              null ps.customer_id                          |
 | 11-MAY-05    VCRISOST        LE-R12 : in c_receipt_method, include        |
 |                              trx.legal_entity_id, because it is an        |
 |                              implicit grouping rule                       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE select_trx_and_create_BR(
                p_draft_mode            IN  	VARCHAR2,
                p_call                  IN  	NUMBER,
                p_batch_id              IN   	RA_BATCHES.batch_id%TYPE,
                p_due_date_low          IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_due_date_high         IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
                p_trx_date_low          IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_date_high         IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
                p_trx_type_id           IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
                p_rcpt_meth_id          IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
                p_cust_bank_branch_id   IN  	ce_bank_branches_v.branch_party_id%TYPE,
                p_trx_number_low        IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_trx_number_high       IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
                p_cust_class            IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_cust_category         IN  	AR_LOOKUPS.lookup_code%TYPE,
                p_customer_id           IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_site_use_id           IN  	HZ_CUST_SITE_USES.site_use_id%TYPE) IS

/*
   Bug 1808967 : added trx.customer_bank_account_id in select statement,
   by doing this I have made the bank account id an implicit grouping rule

   Bug 4109513 : move bank account to cursor c_rm_bank, c_receipt_method is for
   distinct receipt methods only
*/

-- Cursor used to select the receipt method
CURSOR c_receipt_method IS
	SELECT distinct pm.receipt_method_id, pm.receipt_creation_rule_code, NVL(pm.lead_days,0),
                        pm.maturity_date_rule_code,
                        DECODE(pm.br_min_acctd_amount,NULL,0.00000001,0,0.00000001,pm.br_min_acctd_amount),
                        NVL(pm.br_max_acctd_amount,9999999999999999999999999999999999),
                        trx.invoice_currency_code, trx.exchange_rate, trx.legal_entity_id
	FROM ra_batches              batch,
             ar_receipt_classes      class,
 	     ar_receipt_methods      pm,
	     ra_customer_trx         trx,
	     ra_cust_trx_types       type,
 	     fnd_currencies_vl       cur
        WHERE pm.receipt_method_id        = NVL(p_rcpt_meth_id,pm.receipt_method_id)
        AND   type.cust_trx_type_id       = NVL(p_trx_type_id,type.cust_trx_type_id)
        AND   trx.trx_number BETWEEN NVL(p_trx_number_low,trx.trx_number) AND NVL(p_trx_number_high,trx.trx_number)
        AND   batch.batch_id                  = p_batch_id
        AND   trx.trx_date                   <= NVL(batch.issue_date,batch.batch_date)
	AND   class.creation_method_code      = 'BR'
	AND   class.receipt_class_id          = pm.receipt_class_id
	AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(pm.start_date,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(pm.end_date,NVL(batch.issue_date,sysdate)))
	AND   pm.receipt_method_id            = trx.receipt_method_id
	AND   trx.cust_trx_type_id            = type.cust_trx_type_id
	AND   type.type in ('INV','CM','DM','DEP','CB')
	AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(type.start_date,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(type.end_date,NVL(batch.issue_date,sysdate)))
	AND   NVL(batch.currency_code,trx.invoice_currency_code) = trx.invoice_currency_code
	AND   trx.invoice_currency_code       = cur.currency_code
	AND   cur.enabled_flag                = 'Y'
	AND   cur.currency_flag               = 'Y'
	AND   NVL(batch.exchange_rate,NVL(trx.exchange_rate,100)) = NVL(trx.exchange_rate,100)
	AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(cur.start_date_active,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(cur.end_date_active,NVL(batch.issue_date,sysdate)))
        AND   pm.br_cust_trx_type_id IS NOT NULL
	ORDER BY pm.receipt_method_id;

/* bug 4109513 : get distinct bank accounts using receipt method */
CURSOR c_rm_bank (rm_id IN NUMBER, cust_id IN NUMBER) IS
      --  SELECT distinct trx.customer_bank_account_id 5051673
         SELECT distinct instrument_id customer_bank_account_id
        FROM ra_batches              batch,
             ar_receipt_classes      class,
             ar_receipt_methods      pm,
             ra_customer_trx         trx,
             ra_cust_trx_types       type,
             fnd_currencies_vl       cur,
             iby_trxn_extensions_v   extn
        WHERE pm.receipt_method_id        = rm_id
        AND   type.cust_trx_type_id       = NVL(p_trx_type_id,type.cust_trx_type_id)
        AND   trx.trx_number BETWEEN NVL(p_trx_number_low,trx.trx_number) AND NVL(p_trx_number_high,trx.trx_number)
        AND   batch.batch_id                  = p_batch_id
        AND   trx.trx_date                   <= NVL(batch.issue_date,batch.batch_date)
        AND   class.creation_method_code      = 'BR'
        AND   class.receipt_class_id          = pm.receipt_class_id
        AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(pm.start_date,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(pm.end_date,NVL(batch.issue_date,sysdate)))
        AND   pm.receipt_method_id            = trx.receipt_method_id
        AND   trx.cust_trx_type_id            = type.cust_trx_type_id
        AND   type.type in ('INV','CM','DM','DEP','CB')
        AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(type.start_date,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(type.end_date,NVL(batch.issue_date,sysdate)))
        AND   NVL(batch.currency_code,trx.invoice_currency_code) = trx.invoice_currency_code
        AND   trx.invoice_currency_code       = cur.currency_code
        AND   cur.enabled_flag                = 'Y'
        AND   cur.currency_flag               = 'Y'
        AND   NVL(batch.exchange_rate,NVL(trx.exchange_rate,100)) = NVL(trx.exchange_rate,100)
        AND   trunc(NVL(batch.issue_date,sysdate))
              BETWEEN trunc(NVL(cur.start_date_active,NVL(batch.issue_date,sysdate)))
              AND trunc(NVL(cur.end_date_active,NVL(batch.issue_date,sysdate)))
        AND   pm.br_cust_trx_type_id IS NOT NULL
        AND   trx.bill_to_customer_id = cust_id
        AND   trx.payment_trxn_extension_id = extn.trxn_extension_id;

c_customer cur_typ;

/* Bug 3393994 Declared the variables used in the new exception handling part. */

c1 cur_typ ;
c2 cur_typ;
l_select varchar2(100) := NULL ;

/* Bug 3472744 */

l_trx_select_statement  	VARCHAR2(5000) :=NULL;
l_suffixe_select_statement      VARCHAR2(4000) :=NULL;
l_suffix_hz                     VARCHAR2(5000) :=NULL;

-- 1st break criteria
l_receipt_method_id		AR_RECEIPT_METHODS.receipt_method_id%TYPE;
l_receipt_creation_rule_code	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE;
l_lead_days			AR_RECEIPT_METHODS.lead_days%TYPE;
l_maturity_date_rule_code	AR_RECEIPT_METHODS.maturity_date_rule_code%TYPE;
l_br_min_acctd_amount		AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE;
l_br_max_acctd_amount		AR_RECEIPT_METHODS.br_max_acctd_amount%TYPE;

l_invoice_currency_code		RA_CUSTOMER_TRX.invoice_currency_code%TYPE;
l_exchange_rate                 RA_CUSTOMER_TRX.exchange_rate%TYPE;
l_le_id                         RA_CUSTOMER_TRX.legal_entity_id%TYPE;

-- Bug 1808976
l_customer_bank_account_id      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE; -- this will FOREVER be -999
l_customer_bank_account_id2     RA_CUSTOMER_TRX.customer_bank_account_id%TYPE; -- this changes per customer

c_grouping	cur_typ;

-- 2nd break criteria
l_customer_id			HZ_CUST_ACCOUNTS.cust_account_id%TYPE;
l_customer_id2                  HZ_CUST_ACCOUNTS.cust_account_id%TYPE;
l_due_date			AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_site_use_id			AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
l_customer_trx_id		AR_PAYMENT_SCHEDULES.customer_trx_id%TYPE;
l_payment_schedule_id		AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;

l_bill_id			RA_CUSTOMER_TRX.customer_trx_id%TYPE;
l_request_id			NUMBER;
-- 3922691
l_print                         BOOLEAN := TRUE;
l_print1                        BOOLEAN := TRUE;

BEGIN

  IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_trx_and_create_BR (+)');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Dump of Parameters');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_low             = ' || p_due_date_low);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_high            = ' || p_due_date_high);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_low             = ' || p_trx_date_low);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_high            = ' || p_trx_date_high);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_type_id              = ' || p_trx_type_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_low           = ' || p_trx_number_low);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_high          = ' || p_trx_number_high);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_class               = ' || p_cust_class);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_category            = ' || p_cust_category);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_id              = ' || p_customer_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_site_use_id              = ' || p_site_use_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_batch_id                 = ' || p_batch_id);
  END IF;

--------------------------------------------------------------------------
---- FIRST LOOP
--------------------------------------------------------------------------
OPEN c_receipt_method;
LOOP

  /* Bug 1808976 : added l_customer_bank_account_id
     Bug 4109513 : process l_customer_bank_account_id later, we just want c_receipt_method
     to return distinct receipt methods per Currency and exchange rate
   */

  FETCH c_receipt_method into l_receipt_method_id, l_receipt_creation_rule_code, l_lead_days,
                              l_maturity_date_rule_code, l_br_min_acctd_amount, l_br_max_acctd_amount,
                              l_invoice_currency_code, l_exchange_rate, l_le_id;

   /* Bug 4109513 : the value -999 signals to construct_suffixe_select, that I don't care about
      bank accounts yet, I just want to pick up all distinct customers using l_receipt_method_id
   */

  l_customer_bank_account_id := -999;
  EXIT WHEN c_receipt_method%NOTFOUND;

  IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Receipt Method Details');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'receipt_method_id         :'||l_receipt_method_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'receipt_creation_rule_code:'||l_receipt_creation_rule_code);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'lead days                 :'||l_lead_days);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'maturity_date_rule_code   :'||l_maturity_date_rule_code);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'br_min_acctd_amount       :'||l_br_min_acctd_amount);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'br_max_acctd_amount       :'||l_br_max_acctd_amount);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'invoice_currency_code     :'||l_invoice_currency_code);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'exchange_rate             :'||l_exchange_rate);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'legal_entity_id           :'||l_le_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'customer_bank_account_id  :'||l_customer_bank_account_id);
  END IF;

  -- Setup of the next cursor according to the handled receipt method
  -- Bug 3922691 : pass additional parameters to construct_suffixe_select,
  --               call new procedure construct_hz

  ARP_PROGRAM_GENERATE_BR.construct_suffixe_select(
			l_lead_days,
			l_suffixe_select_statement,
                        p_due_date_low,
                        p_due_date_high,
                        p_trx_date_low,
                        p_trx_date_high,
                        p_trx_type_id,
                        p_trx_number_low,
                        p_trx_number_high,
                        p_cust_class,
                        p_cust_category,
                        p_customer_id,
                        p_site_use_id,
                        l_le_id);

  ARP_PROGRAM_GENERATE_BR.construct_hz(
                        l_receipt_creation_rule_code,
                        p_customer_id,
                        l_suffix_hz);

  l_suffixe_select_statement := l_suffixe_select_statement || l_suffix_hz;

/* 5051673 Need to verfiy if this is really required
  IF (p_cust_bank_branch_id IS NOT NULL) THEN
      l_suffixe_select_statement := l_suffixe_select_statement ||
           'AND account.bank_branch_id = '||p_cust_bank_branch_id||' ';


      l_suffixe_select_statement := l_suffixe_select_statement ||
           'AND NVL(account.inactive_date,batch.issue_date) >= batch.issue_date ';
  END IF;
*/

  l_trx_select_statement := NULL;

  -- Bug 4109513 : at this point we just want to get all distinct customer_ids that use the
  -- receipt method id picked up by c_receipt_method
  l_trx_select_statement := 'SELECT DISTINCT ps.customer_id '||
                            l_suffixe_select_statement||
                            ' ORDER BY ps.customer_id ';

  if l_print1 AND (p_call <> 3 OR PG_DEBUG in ('Y', 'C')) THEN
     l_print1 := FALSE;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------') ;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'This select will get all distinct customer_ids');
     FND_FILE.PUT_LINE(FND_FILE.LOG,l_trx_select_statement);
  end if;

  IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------') ;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Opening c_customer with the following parameters :');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_receipt_method_id        : ' || to_char(l_receipt_method_id));
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_invoice_currency_code    : ' || l_invoice_currency_code);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_exchange_rate            : ' || to_char(l_exchange_rate));
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_customer_bank_account_id : ' || to_char(l_customer_bank_account_id));
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_le_id                    : ' || to_char(l_le_id));
     fnd_file.put_line(fnd_file.log,'l_trx_st:'||l_trx_select_statement);

  END IF;

  OPEN c_customer FOR l_trx_select_statement
                using   p_due_date_low,
                        p_due_date_high,
                        p_trx_date_low,
                        p_trx_date_high,
                        p_trx_type_id,
                        p_trx_number_low,
                        p_trx_number_high,
                        p_cust_class,
                        p_cust_category,
                        p_customer_id,
                        p_site_use_id,
                        l_receipt_method_id,
                        p_batch_id,
                        l_invoice_currency_code,
                        l_exchange_rate,
                        l_customer_bank_account_id,   -- this will always be -999
                        l_customer_bank_account_id,
                        l_le_id,
                        p_customer_id;

  LOOP

     l_customer_id              := NULL;

     FETCH c_customer into l_customer_id;

     EXIT WHEN c_customer%NOTFOUND;

     IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'...Processing c_customer, customer_id :'||l_customer_id);
     END IF;

     -- 4109513 : Now that we have customer_id, rebuild l_trx_select_statement
     -- to make it more selective on ps.customer_id
     ARP_PROGRAM_GENERATE_BR.construct_suffixe_select(
                        l_lead_days,
                        l_suffixe_select_statement,
                        p_due_date_low,
                        p_due_date_high,
                        p_trx_date_low,
                        p_trx_date_high,
                        p_trx_type_id,
                        p_trx_number_low,
                        p_trx_number_high,
                        p_cust_class,
                        p_cust_category,
                        l_customer_id,
                        p_site_use_id,
                        l_le_id);

     ARP_PROGRAM_GENERATE_BR.construct_hz(
                        l_receipt_creation_rule_code,
                        l_customer_id,
                        l_suffix_hz);

     l_suffixe_select_statement := l_suffixe_select_statement || l_suffix_hz;

     IF (p_cust_bank_branch_id IS NOT NULL) THEN
        l_suffixe_select_statement := l_suffixe_select_statement ||
                 'AND account.bank_branch_id = '||p_cust_bank_branch_id||' ';

        l_suffixe_select_statement := l_suffixe_select_statement ||
                 'AND NVL(account.inactive_date,batch.issue_date) >= batch.issue_date ';
     END IF;

     l_trx_select_statement := NULL;

     IF l_receipt_creation_rule_code = 'PER_CUSTOMER' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.customer_id '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.customer_id ';
     ELSIF l_receipt_creation_rule_code = 'PER_CUSTOMER_DUE_DATE' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.customer_id, ps.due_date '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.customer_id, ps.due_date ';
     ELSIF l_receipt_creation_rule_code = 'PER_SITE' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.customer_site_use_id '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.customer_site_use_id ';
     ELSIF l_receipt_creation_rule_code = 'PER_SITE_DUE_DATE' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.customer_site_use_id, ps.due_date '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.customer_site_use_id, ps.due_date ';
     ELSIF l_receipt_creation_rule_code = 'PER_INVOICE' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.customer_trx_id '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.customer_trx_id ';
     ELSIF l_receipt_creation_rule_code = 'PER_PAYMENT_SCHEDULE' THEN
        l_trx_select_statement := 'SELECT DISTINCT ps.payment_schedule_id '||
                                   l_suffixe_select_statement||
                                   ' ORDER BY ps.payment_schedule_id ';
     ELSE
        FND_MESSAGE.set_name('AR','AR_BR_INVALID_GROUPING_RULE');
        FND_MESSAGE.set_token('GROUPING_RULE',l_receipt_creation_rule_code);
        APP_EXCEPTION.raise_exception;
     END IF;

     -- bug 3888842
     if l_print AND (p_call <> 3 OR PG_DEBUG in ('Y', 'C')) THEN
        l_print := FALSE;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------') ;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'l_trx_select_statement = ' || l_trx_select_statement);
     end if;

     -- process receipt method id Banks
     OPEN c_rm_bank(l_receipt_method_id,l_customer_id);

     LOOP

        FETCH c_rm_bank into l_customer_bank_account_id2;

        EXIT WHEN c_rm_bank%NOTFOUND;

        IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'......Processing c_rm_bank, customer_id : ' ||
                             to_char(l_customer_id) || ' ' ||
                             ' bank_account : ' || to_char(l_customer_bank_account_id2));
        END IF;

        -- bug 1808976 : added l_customer_bank_account_id

        OPEN c_grouping FOR l_trx_select_statement
                using 	p_due_date_low,
              		p_due_date_high,
                	p_trx_date_low,
               		p_trx_date_high,
                	p_trx_type_id,
                	p_trx_number_low,
                	p_trx_number_high,
                	p_cust_class,
                	p_cust_category,
                	l_customer_id,
                	p_site_use_id,
                 	l_receipt_method_id,
			p_batch_id,
                        l_invoice_currency_code,
                        l_exchange_rate,
                        l_customer_bank_account_id2,
                        l_customer_bank_account_id2,
                        l_le_id,
                        l_customer_id;

        LOOP

           /* Bug 3393994 Enclosing the following inside a block so as
              to handle the exception and still continue with the
              next Transaction in the loop. */

           BEGIN

              l_customer_id2		:= NULL;
              l_due_date		:= NULL;
              l_site_use_id		:= NULL;
              l_customer_trx_id		:= NULL;
              l_payment_schedule_id	:= NULL;

              IF (l_receipt_creation_rule_code = 'PER_CUSTOMER') THEN
                 FETCH c_grouping into l_customer_id2;
              ELSIF (l_receipt_creation_rule_code = 'PER_CUSTOMER_DUE_DATE') THEN
                 FETCH c_grouping into l_customer_id2, l_due_date;
              ELSIF (l_receipt_creation_rule_code = 'PER_SITE') THEN
                 FETCH c_grouping into l_site_use_id;
              ELSIF (l_receipt_creation_rule_code = 'PER_SITE_DUE_DATE') THEN
                 FETCH c_grouping into l_site_use_id, l_due_date;
              ELSIF (l_receipt_creation_rule_code = 'PER_INVOICE') THEN
                 FETCH c_grouping into l_customer_trx_id;
              ELSE
                 FETCH c_grouping into l_payment_schedule_id;
              END IF;

              EXIT WHEN c_grouping%NOTFOUND;

              IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                 IF (l_receipt_creation_rule_code = 'PER_CUSTOMER') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, customer_id :'||l_customer_id2);
                 ELSIF (l_receipt_creation_rule_code = 'PER_CUSTOMER_DUE_DATE') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, customer_id :'||
                                      l_customer_id2||' due date :'||l_due_date);
                 ELSIF (l_receipt_creation_rule_code = 'PER_SITE') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, site_use_id :'||l_site_use_id);
                 ELSIF (l_receipt_creation_rule_code = 'PER_SITE_DUE_DATE') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, site_use_id :'||l_site_use_id||
                                      ' due date :'||l_due_date);
                 ELSIF (l_receipt_creation_rule_code = 'PER_INVOICE') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, customer_trx_id :'||l_customer_trx_id);
                 ELSE
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'.........Processing c_grouping, payment_schedule_id :'||
                                      l_payment_schedule_id);
                 END IF;
              END IF;

              -- Selection of the Credit/Debit Note with a payment Term of Immediate (term_id = 5)
              ARP_PROGRAM_GENERATE_BR.select_DM_and_CM_IMM(
				l_lead_days,
				l_receipt_creation_rule_code,
				p_due_date_low,
              			p_due_date_high,
                		p_trx_date_low,
               			p_trx_date_high,
                		p_trx_type_id,
                		p_trx_number_low,
                		p_trx_number_high,
                		p_cust_class,
                		p_cust_category,
                		NVL(l_customer_id2,p_customer_id),
                		NVL(l_site_use_id,p_site_use_id),
                 		l_receipt_method_id,
				p_batch_id,
                       		l_invoice_currency_code,
                        	l_exchange_rate,
                                l_customer_bank_account_id2,
                                l_le_id);

              -- Selection of the "others" transactions
              ARP_PROGRAM_GENERATE_BR.select_trx_NIMM(
				l_lead_days,
                                l_receipt_creation_rule_code,
				NVL(l_due_date,p_due_date_low),
              			NVL(l_due_date,p_due_date_high),
                		p_trx_date_low,
               			p_trx_date_high,
                		p_trx_type_id,
                		p_trx_number_low,
                		p_trx_number_high,
                		p_cust_class,
                		p_cust_category,
                		NVL(l_customer_id2,p_customer_id),
                		NVL(l_site_use_id,p_site_use_id),
                 		l_receipt_method_id,
				p_batch_id,
                       		l_invoice_currency_code,
                        	l_exchange_rate,
				l_payment_schedule_id,
                                l_customer_trx_id,
                                l_customer_bank_account_id2,
                                l_le_id);


              -- Creation of the Bills receivable

              -- bug 1808976 : added l_customer_bank_account_id
              ARP_PROGRAM_GENERATE_BR.create_BR(
			p_draft_mode,
                        p_call,
                	p_batch_id,
		        l_receipt_method_id,
			l_receipt_creation_rule_code,
			l_maturity_date_rule_code,
			l_br_min_acctd_amount,
			l_br_max_acctd_amount,
			l_invoice_currency_code,
                        l_customer_bank_account_id2,
                        l_le_id,
                        l_bill_id,
                        l_request_id);

           /* Bug 3393994 Exception handling inside the loop so that
              program can continue through the next pass thru the loop
              after printing messages in the log file.*/

           EXCEPTION
           WHEN OTHERS THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Creation error for this BR ');
             g_num_br_failed  :=   g_num_br_failed + 1;

             BEGIN

                l_select := 'SELECT payment_schedule_id , customer_trx_id , trx_number FROM ' || g_tmp_table_nimm ;

                OPEN c1 FOR  l_select ;
                LOOP
                   FETCH c1 INTO errorinv(g_ctr);
                   EXIT WHEN c1%NOTFOUND;
                   g_ctr := g_ctr + 1;
                END LOOP ;
                CLOSE c1;

                l_select := 'SELECT payment_schedule_id , customer_trx_id  , trx_number FROM ' || g_tmp_table_imm;

                OPEN c2 FOR l_select ;
                LOOP
                  FETCH c2 INTO errorinv(g_ctr);
                  EXIT WHEN c2%NOTFOUND;
                  g_ctr := g_ctr + 1;
                END LOOP ;
                CLOSE c2;

             EXCEPTION
             WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception : While Inserting into the table errorinv');
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
             END ;

          END ;

        END LOOP;
        CLOSE c_grouping;

     END LOOP;
     CLOSE c_rm_bank;

  END LOOP;
  CLOSE c_customer;

END LOOP;
CLOSE c_receipt_method;


FND_FILE.PUT_LINE(FND_FILE.LOG,'The process has generated '||g_num_br_created||' Bills receivable');
FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_trx_and_create_BR (-)');

EXCEPTION
WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.select_trx_and_create_BR');

   IF c_grouping%ISOPEN THEN
      CLOSE c_grouping;
   END IF;

   IF c_rm_bank%ISOPEN THEN
      CLOSE c_rm_bank;
   END IF;

   IF c_customer%ISOPEN THEN
      CLOSE c_customer;
   END IF;

   IF c_receipt_method%ISOPEN THEN
      CLOSE c_receipt_method;
   END IF;

   RAISE;

END select_trx_and_create_BR;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_hz                                                           |
 |                                                                           |
 | Code to define conditions re. customer_id and customer_site_use_id        |
 | This code was lifted from select_trx_and_Create_br, note same logic also  |
 | existed in auto_create_br_api                                             |
 +===========================================================================*/

PROCEDURE construct_hz(
                p_receipt_creation_rule_code    IN      AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
                p_customer_id                   IN HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
                p_suffix_hz                     OUT NOCOPY varchar2) IS

l_trx_select_statement        VARCHAR2(4000) := NULL;

BEGIN

-- FND_FILE.PUT_LINE(FND_FILE.LOG,'construct_hz (+)');

  /*
     Bug 1710187 :

     IF the grouping rule IS :
     a) PER_CUSTOMER or PER_CUSTOMER_DUE_DATE, there should exist a DRAWEE site
        for this customer ID and it should be active and primary
     b) All other grouping rules, DO NOT require the site to be PRIMARY, but BILL TO
        site must be DRAWEE site as well

  */

     l_trx_select_statement := l_trx_select_statement ||
           ' AND exists
           (SELECT a.cust_account_id
              FROM hz_cust_acct_sites a,
                   hz_cust_site_uses site,
                   hz_cust_account_roles acct_role
             WHERE a.cust_acct_site_id = site.cust_acct_site_id ';

     if p_customer_id is NOT NULL then
     l_trx_select_statement := l_trx_select_statement ||
         'AND a.cust_account_id = :p_customer_id ';
     else
     l_trx_select_statement := l_trx_select_statement ||
         'AND :p_customer_id IS NULL
          AND a.cust_account_id = ps.customer_id ';
     end if;

     IF p_receipt_creation_rule_code IN ('PER_CUSTOMER','PER_CUSTOMER_DUE_DATE') THEN

        l_trx_select_statement := l_trx_select_statement ||
             ' AND site.primary_flag = ''Y'' ';
     ELSE
        l_trx_select_statement := l_trx_select_statement ||
                     ' AND site.cust_acct_site_id IN (select cust_acct_site_id
                                                      from hz_cust_site_uses
                                                     WHERE site_use_id = ps.customer_site_use_id) ';
     END IF;

     l_trx_select_statement := l_trx_select_statement ||
                     ' AND site.site_use_code = ''DRAWEE''
                       AND site.status = ''A''
                       AND site.contact_id = acct_role.cust_account_role_id(+)
                       AND acct_role.status(+) = ''A'') ';


  p_suffix_hz := l_trx_select_statement;

-- FND_FILE.PUT_LINE(FND_FILE.LOG,'construct_hz (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.construct_hz');
   RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_suffixe_select                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 27/07/2000           |
 |									     |
 | 30-APR-01 V Crisostomo	Bug 1744783 : transactions with multiple     |
 |				payment schedule records, only get the first |
 |				installment converted to BR, rest are un-    |
 |				processed				     |
 | 06-JUN-01 V Crisostomo       Bug 1808976 : include condition to restrict  |
 |				on customer_bank_account_id		     |
 | 23-SEP-04  V Crisostomo      Bug 3922691, added params so dynamic sql     |
 |                              can be more selective                        |
 | 17-JAN-04 V Crisostomo	Bug 4109513 : modify logic re.               |
 |                              :p_customer_bank_account_id, subsequent code |
 |                              that uses construct_suffixe_select to build  |
 |                              statement will now pass bank account twice   |
 |                              due to new decode statement                  |
 | 11-MAY-05 V Crisostomo       LE-R12: add p_le_id                          |
 | 21-Jan-06 Surendra Rajan     Removed the references to ap_bank_accounts   |
 +===========================================================================*/

PROCEDURE construct_suffixe_select(
	p_lead_days			IN AR_RECEIPT_METHODS.lead_days%TYPE,
	p_suffixe_select_statement	OUT NOCOPY varchar2,
        p_due_date_low                  IN AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_due_date_high                 IN AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_trx_date_low                  IN RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_date_high                 IN RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_type_id                   IN ra_cust_trx_types.cust_trx_type_id%TYPE,
        p_trx_number_low                IN RA_CUSTOMER_TRX.trx_number%TYPE,
        p_trx_number_high               IN RA_CUSTOMER_TRX.trx_number%TYPE,
        p_cust_class                    IN AR_LOOKUPS.lookup_code%TYPE,
        p_cust_category                 IN AR_LOOKUPS.lookup_code%TYPE,
        p_customer_id                   IN HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
        p_site_use_id                   IN HZ_CUST_SITE_USES.site_use_id%TYPE,
        p_le_id                         IN RA_CUSTOMER_TRX.legal_entity_id%TYPE
) IS

l_trx_select_statement        VARCHAR2(4000) := NULL;

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.construct_suffixe_select (+)');

     /* modified for tca uptake */

     /* Bug 1744783 : for transactions with multiple payment schedule records,
        BR is only created for the first installment, replaced ps.customer_trx_id
        with ps.payment_schedule_id, also did a direct comparison between
        br_ref_payment_schedule_id = ps.payment_schedule, rather than comparing
        to is not null */

     /* Bug 1808976 : add a condition to restrict records based on p_customer_bank_account_id */

     /* Bug 3922691 :
     - replace trx.trx_date with ps.trx_date
     - replace (ps.due_date - pm.lead_days) <= SYSDATE
       with    ps.due_date <= SYSDATE + pm.lead_days
     - use NOT EXISTS in check against ra_customer_trx_lines
     - remove join to hz_cust_acct_sites, this is done in construct_hz
     */
/* Bug 4928711 - Removed the references to ap_bank_accounts */

l_trx_select_statement :=
'FROM ra_batches             batch,
      ar_receipt_methods      pm,
      ar_payment_schedules    ps,
      ra_customer_trx         trx,
      ra_cust_trx_types       type,
      fnd_currencies_vl       cur,
      hz_cust_accounts        cust,
      hz_parties              party,
      iby_trxn_extensions_v   extn
WHERE trx.customer_trx_id             = ps.customer_trx_id
';

-- Bug 3922691 : evaluate each parameter and only add the condition if param is not null

if p_due_date_low is not null and p_due_date_high is not null then
      l_trx_select_statement := l_trx_select_statement ||
'AND ps.due_date BETWEEN :p_due_date_low AND :p_due_date_high
';
elsif p_due_date_low is not null and p_due_date_high is null then
      l_trx_select_statement := l_trx_select_statement ||
'AND ps.due_date = :p_due_date_low
AND :p_due_date_high IS NULL
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_due_date_low is NULL
AND :p_due_date_high IS NULL
';
end if;

if p_trx_date_low is not null and p_trx_date_high is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND trx.trx_date BETWEEN :p_trx_date_low AND :p_trx_date_high
';
elsif p_trx_date_low is not null and p_trx_date_high is null then
   l_trx_select_statement := l_trx_select_statement ||
'AND trx.trx_date = :p_trx_date_low
AND :p_trx_date_high is NULL
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_trx_date_low is NULL
AND :p_trx_date_high is NULL
';
end if;

if p_trx_type_id is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND trx.cust_trx_type_id           = :p_trx_type_id
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_trx_type_id is NULL
';
end if;

if p_trx_number_low is not null and p_trx_number_high is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND trx.trx_number BETWEEN :p_trx_number_low AND :p_trx_number_high
';
elsif p_trx_number_low is not null and p_trx_number_high is null then
   l_trx_select_statement := l_trx_select_statement ||
'AND trx.trx_number = :p_trx_number_low
AND :p_trx_number_high is NULL
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_trx_number_low is NULL
AND :p_trx_number_high is NULL
';
end if;

if p_cust_class is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND NVL(cust.customer_class_code,1) = :p_cust_class
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_cust_class is null
';
end if;

if p_cust_category is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND NVL(party.category_code,1) = :p_cust_category
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND  :p_cust_category is NULL
';
end if;

if p_customer_id is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND ps.customer_id = :p_customer_id
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_customer_id is NULL
';
end if;

if p_site_use_id is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND ps.customer_site_use_id = :p_site_use_id
';
else
      l_trx_select_statement := l_trx_select_statement ||
'AND :p_site_use_id is NULL
';
end if;

l_trx_select_statement := l_trx_select_statement ||
'AND  pm.receipt_method_id            = trx.receipt_method_id
AND   pm.receipt_method_id            = :p_receipt_method_id
AND   batch.batch_id                  = :p_batch_id
AND   ps.trx_date                   <= NVL(batch.issue_date,batch.batch_date)
AND   trx.customer_trx_id             = ps.customer_trx_id
AND   ps.reserved_type  IS NULL
AND   ps.reserved_value IS NULL
AND   ps.amount_in_dispute IS NULL
AND   ps.customer_id                  = cust.cust_account_id
AND   cust.party_id                   = party.party_id
AND   trx.cust_trx_type_id            = type.cust_trx_type_id
AND   ps.invoice_currency_code        = NVL(:p_currency_code,ps.invoice_currency_code)
AND   ps.invoice_currency_code        = cur.currency_code
AND   NVL(ps.exchange_rate,100)       = NVL(:p_exchange_rate,100)
and  trx.payment_trxn_extension_id   = extn.trxn_extension_id(+)
--AND  nvl(trx.customer_bank_account_id, -1) =
--      decode(:p_customer_bank_account_id,-999, nvl(trx.customer_bank_account_id,-1), nvl(:p_customer_bank_account_id,-1))
--Bug5051673
and nvl(extn.instrument_id,-1) 	      = decode(:p_customer_bank_account_id,-999, nvl(extn.instrument_id,-1),nvl(:p_customer_bank_account_id,-1))
AND   NOT EXISTS
(SELECT br_ref_payment_schedule_id
 from
 ra_customer_trx_lines   br_lines,
 ar_transaction_history  th
 where br_lines.br_ref_payment_schedule_id = ps.payment_schedule_id
 and   br_lines.customer_trx_id = th.customer_trx_id
 and   th.current_record_flag   = ''Y''
 and   th.status <> ''CANCELLED'')  /*Bug2290332*/
AND   ps.status =''OP''
AND   cur.enabled_flag =''Y''
AND   cur.currency_flag =''Y''
AND   trx.legal_entity_id = :p_le_id ';

-- The lead days indicate the number of days before the invoice due date that a transaction
-- payment schedule can be exchanged for a bill receivable. IF its value is 999, the lead days
-- isn't used to select the trx.
IF p_lead_days <> 999 THEN
   l_trx_select_statement := l_trx_select_statement ||'
AND ps.due_date <= SYSDATE +  pm.lead_days';
END IF;

p_suffixe_select_statement := l_trx_select_statement;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.construct_suffixe_select (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.construct_suffixe_select');
   RAISE;

END construct_suffixe_select;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_DM_and_CM_IMM                                                   |
 |                                                                           |
 | DESCRIPTION  Selection of the Credit and debit notes with a payment term  |
 |              of 'Immediate'                                               |
 |              This is only run if grouping rule <> 'PER_INVOICE'           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 01/08/2000           |
 |                                                                           |
 | 06-jun-01	VCRISOST	Bug 1808976 : added parameter 		     |
 |				p_customer_bank_account_id                   |
 | 23-SEP-04    VCRISOST        Bug 3922691 : need to rebuild select with    |
 |                              current value of params, no need to pass     |
 |                              p_suffixe_select_statement, instead pass     |
 |                              p_lead_days                                  |
 |                              Need to call construct* procedures           |
 | 11-MAY-05    VCRISOST        LE-R12: add p_le_id                          |
 | 25-MAY-05    VCRISOST 	SSA-R12: add p_org_id                        |
 +===========================================================================*/
PROCEDURE select_DM_and_CM_IMM(
	p_lead_days	                IN      AR_RECEIPT_METHODS.lead_days%TYPE,
	p_receipt_creation_rule_code	IN	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
        p_due_date_low          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_due_date_high         	IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_trx_date_low          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_date_high         	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_type_id           	IN  	ra_cust_trx_types.cust_trx_type_id%TYPE,
        p_trx_number_low        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
        p_trx_number_high       	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
        p_cust_class            	IN  	AR_LOOKUPS.lookup_code%TYPE,
        p_cust_category         	IN  	AR_LOOKUPS.lookup_code%TYPE,
        p_customer_id           	IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
        p_site_use_id           	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
	p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
	p_batch_id			IN	RA_BATCHES.batch_id%TYPE,
	p_invoice_currency_code		IN 	RA_CUSTOMER_TRX.invoice_currency_code%TYPE,
	p_exchange_rate      	    	IN 	RA_CUSTOMER_TRX.exchange_rate%TYPE,
        p_customer_bank_account_id      IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
        p_le_id                         IN      RA_CUSTOMER_TRX.legal_entity_id%TYPE) IS

l_trx_select_statement  	VARCHAR2(5000) :=NULL;
l_suffixe_select_statement      VARCHAR2(5000) :=NULL;
l_suffix_hz                     VARCHAR2(5000) := NULL;

l_delete_statement	VARCHAR2(2000);
l_insert_statement	VARCHAR2(2000);

-- bug 3930958
l_aimm_statement        VARCHAR2(100) := 'SELECT COUNT(*) FROM '|| g_tmp_table_aimm;
l_aimm_ctr              NUMBER;

c_trx			cur_typ;

l_payment_schedule_id	AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;
l_customer_trx_id	AR_PAYMENT_SCHEDULES.customer_trx_id%TYPE;
l_cust_trx_type_id	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE;
l_customer_id		AR_PAYMENT_SCHEDULES.customer_id%TYPE;
l_customer_site_use_id	AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
l_trx_number		AR_PAYMENT_SCHEDULES.trx_number%TYPE;
l_due_date		AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_amount_due_remaining	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
l_org_id                AR_PAYMENT_SCHEDULES.org_id%TYPE;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_DM_and_CM_IMM (+)');

l_delete_statement := 'DELETE FROM '|| g_tmp_table_imm;
execute immediate l_delete_statement;

IF p_receipt_creation_rule_code = 'PER_INVOICE' THEN
--   FND_FILE.PUT_LINE(FND_FILE.LOG,'grouping rule PER INVOICE -> no DM/CM Immediate');
--   FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_DM_and_CM_IMM (-)');
   RETURN;
END IF;

-- If a Credit/Debit Note has been created with a payment term of immediate,
-- it will be included in the first BR that can accomodate its amount irrespective of the due date
-- component of the following BR payment method 's Grouping Rules
-- ONE PER CUSTOMER AND DUE DATE - will effectively become ONE PER CUSTOMER
-- ONE PER SITE AND DUE DATE     - will effectively become ONE PER SITE
-- ONE PER PAYMENT SCHEDULE      - will effectively become ONE PER SITE

-- Bug 3922691, we cannot re-use p_suffixe_select_statement because the
-- param values for  p_due_date_low, p_due_date_high, p_customer_id,
-- p_site_use_id may have changed, need to reconstruct with current values

ARP_PROGRAM_GENERATE_BR.construct_suffixe_select(
                        p_lead_days,
                        l_suffixe_select_statement,
                        p_due_date_low,
                        p_due_date_high,
                        p_trx_date_low,
                        p_trx_date_high,
                        p_trx_type_id,
                        p_trx_number_low,
                        p_trx_number_high,
                        p_cust_class,
                        p_cust_category,
                        p_customer_id,
                        p_site_use_id,
                        p_le_id );

ARP_PROGRAM_GENERATE_BR.construct_hz(
                        p_receipt_creation_rule_code,
                        p_customer_id,
                        l_suffix_hz);


l_suffixe_select_statement := l_suffixe_select_statement || l_suffix_hz;

-- Setup of the next cursor according to the handled receipt method
-- Bug 3930958 : CM's term_id is always null, re-write condition
l_trx_select_statement := l_suffixe_select_statement ||
'AND ((type.type = ''CM'' and ps.term_id is null) OR (type.type = ''DM'' and ps.term_id = 5)) ';

-- SSA-R12 : add org_id
l_trx_select_statement := 'SELECT ps.payment_schedule_id,ps.customer_trx_id,ps.cust_trx_type_id,
                                  ps.customer_id,ps.customer_site_use_id,ps.trx_number,ps.due_date,
                                  ps.amount_due_remaining, ps.org_id '||l_trx_select_statement;

/*
  FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG TOOL 3IMM');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'select_trx_nimm: l_trx_select_statement = ' || l_trx_select_statement);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_low             = ' || p_due_date_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_high            = ' || p_due_date_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_low             = ' || p_trx_date_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_high            = ' || p_trx_date_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_type_id              = ' || p_trx_type_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_low           = ' || p_trx_number_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_high          = ' || p_trx_number_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_class               = ' || p_cust_class);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_category            = ' || p_cust_category);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_id              = ' || p_customer_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_site_use_id              = ' || p_site_use_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_receipt_method_id        = ' || p_receipt_method_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_batch_id                 = ' || p_batch_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_invoice_currency_code    = ' || p_invoice_currency_code);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_exchange_rate            = ' || p_exchange_rate);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_bank_account_id = ' || p_customer_bank_account_id);
*/

OPEN c_trx FOR l_trx_select_statement
                using 	p_due_date_low,
              		p_due_date_high,
                	p_trx_date_low,
               		p_trx_date_high,
                	p_trx_type_id,
                	p_trx_number_low,
                	p_trx_number_high,
                	p_cust_class,
                	p_cust_category,
                	p_customer_id,
                	p_site_use_id,
                 	p_receipt_method_id,
			p_batch_id,
                        p_invoice_currency_code,
                        p_exchange_rate,
                        p_customer_bank_account_id,
                        p_customer_bank_account_id,
                        p_le_id,
                        p_customer_id;

-- SSA-R12 : add org_id
l_insert_statement := 'INSERT INTO '||
                      g_tmp_table_imm ||
                      ' (payment_schedule_id, customer_trx_id, cust_trx_type_id, ' ||
                      'customer_id, customer_site_use_id, trx_number, ' ||
                      'due_date, amount_due_remaining, amount_assigned, exclude_flag, org_id) '||
                      'VALUES (:payment_schedule_id, :customer_trx_id, :cust_trx_type_id, ' ||
                      ':customer_id, :customer_site_use_id, :trx_number, ' ||
                      ':due_date, :amount_due_remaining, NULL, NULL,:org_id) ';

-- Insert INTO the table g_tmp_table_imm of the CM/DM with payment term of Immediate
LOOP

  FETCH c_trx into l_payment_schedule_id,
                   l_customer_trx_id,
                   l_cust_trx_type_id,
                   l_customer_id,
                   l_customer_site_use_id,
                   l_trx_number,
                   l_due_date,
                   l_amount_due_remaining,
                   l_org_id;

  EXIT WHEN c_trx%NOTFOUND;

  execute immediate l_insert_statement
		USING l_payment_schedule_id,
                      l_customer_trx_id,
                      l_cust_trx_type_id,
                      l_customer_id,
                      l_customer_site_use_id,
                      l_trx_number,
                      l_due_date,
                      l_amount_due_remaining,
                      l_org_id;
/*
  FND_FILE.PUT_LINE(FND_FILE.LOG,'select_DM_and_CM_IMM:'||l_payment_schedule_id||' '||
                    l_customer_trx_id||' '||l_trx_number|| ' '||l_customer_site_use_id||' '||
                    l_due_date||' '||l_amount_due_remaining);
*/

END LOOP;
CLOSE c_trx;

-- Bug 3930958 : exclude immediate transactions that have already been previously assigned

execute immediate l_aimm_statement INTO l_aimm_ctr;
IF l_aimm_ctr > 0 then

   l_delete_statement := 'DELETE FROM '|| g_tmp_table_imm ||
                         ' WHERE payment_schedule_id in
                             (select payment_schedule_id
                                from ' || g_tmp_table_aimm || ')';

   execute immediate l_delete_statement;

END IF;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_DM_and_CM_IMM (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.select_DM_and_CM_IMM');

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   RAISE;

END select_DM_and_CM_IMM;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_trx_NIMM                                                        |
 |                                                                           |
 | DESCRIPTION  Selection of the other transactions (I mean INV, DEP and CB) |
 |              and the CM/DM with a payment term of 'Non Immediate'         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 01/08/2000           |
 |									     |
 | 06-Jun-01    VCRISOST        Bug 1808976 : added parameter                |
 |                              p_customer_bank_account_id                   |
 | 23-SEP-04    VCRISOST        Bug 3922691 : need to rebuild select with    |
 |                              current value of params, no need to pass     |
 |                              p_suffixe_select_statement, instead pass     |
 |                              p_lead_days                                  |
 |                              Need to call construct* procedures           |
 | 11-MAY-05    VCRISOST        LE-R12: add p_le_id                          |
 | 25-MAY-05	VCRISOST	SSA-R12: add p_org_id                        |
 +===========================================================================*/
PROCEDURE select_trx_NIMM(
        p_lead_days                     IN      AR_RECEIPT_METHODS.lead_days%TYPE,
        p_receipt_creation_rule_code    IN      AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
        p_due_date_low          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_due_date_high         	IN 	AR_PAYMENT_SCHEDULES.due_date%TYPE,
        p_trx_date_low          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_date_high         	IN  	RA_CUSTOMER_TRX.trx_date%TYPE,
        p_trx_type_id           	IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE,
        p_trx_number_low        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
        p_trx_number_high       	IN  	RA_CUSTOMER_TRX.trx_number%TYPE,
        p_cust_class            	IN  	AR_LOOKUPS.lookup_code%TYPE,
        p_cust_category         	IN  	AR_LOOKUPS.lookup_code%TYPE,
        p_customer_id           	IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
        p_site_use_id           	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE,
	p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
	p_batch_id			IN	RA_BATCHES.batch_id%TYPE,
	p_invoice_currency_code		IN 	RA_CUSTOMER_TRX.invoice_currency_code%TYPE,
	p_exchange_rate      	    	IN 	RA_CUSTOMER_TRX.exchange_rate%TYPE,
	p_payment_schedule_id		IN	AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
        p_customer_trx_id		IN	RA_CUSTOMER_TRX.customer_trx_id%TYPE,
        p_customer_bank_account_id      IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
        p_le_id                         IN      RA_CUSTOMER_TRX.legal_entity_id%TYPE) IS

l_trx_select_statement  	VARCHAR2(5000) :=NULL;
l_suffixe_select_statement      VARCHAR2(5000) :=NULL;
l_suffix_hz                     VARCHAR2(5000) := NULL;

l_delete_statement	VARCHAR2(50);
l_insert_statement	VARCHAR2(2000);

c_trx			cur_typ;

l_payment_schedule_id	AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;
l_customer_trx_id	AR_PAYMENT_SCHEDULES.customer_trx_id%TYPE;
l_cust_trx_type_id	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE;
l_customer_id		AR_PAYMENT_SCHEDULES.customer_id%TYPE;
l_customer_site_use_id	AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
l_trx_number		AR_PAYMENT_SCHEDULES.trx_number%TYPE;
l_due_date		AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_amount_due_remaining	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
l_org_id                AR_PAYMENT_SCHEDULES.org_id%TYPE;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_trx_NIMM (+)');

l_delete_statement := 'DELETE FROM '|| g_tmp_table_nimm;
execute immediate l_delete_statement;


-- Bug 3922691, we cannot re-use p_suffixe_select_statement because the
-- param values for  p_due_date_low, p_due_date_high, p_customer_id,
-- p_site_use_id may have changed, need to reconstruct with current values

ARP_PROGRAM_GENERATE_BR.construct_suffixe_select(
                        p_lead_days,
                        l_suffixe_select_statement,
                        p_due_date_low,
                        p_due_date_high,
                        p_trx_date_low,
                        p_trx_date_high,
                        p_trx_type_id,
                        p_trx_number_low,
                        p_trx_number_high,
                        p_cust_class,
                        p_cust_category,
                        p_customer_id,
                        p_site_use_id,
                        p_le_id );

ARP_PROGRAM_GENERATE_BR.construct_hz(
                        p_receipt_creation_rule_code,
                        p_customer_id,
                        l_suffix_hz);


l_suffixe_select_statement := l_suffixe_select_statement || l_suffix_hz;

-- Setup of the next cursor according to the handled receipt method
-- Bug 3930958 : since CM is always immediate, it would have been picked up in
--               select_DM_and_CM_IMM, no need to pick it again here
l_trx_select_statement := l_suffixe_select_statement ||'AND (type.type IN (''INV'',''DEP'',''CB'') '||
                          'OR (type.type = ''DM'' AND ps.term_id <> 5)) ';

if p_payment_schedule_id is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND ps.payment_schedule_id = :p_payment_schedule_id
';
else
   l_trx_select_statement := l_trx_select_statement ||
'AND :p_payment_schedule_id is null
';
end if;

if p_customer_trx_id is not null then
   l_trx_select_statement := l_trx_select_statement ||
'AND ps.customer_trx_id = :p_customer_trx_id
';
else
   l_trx_select_statement := l_trx_select_statement ||
'AND :p_customer_trx_id is null
';
end if;

l_trx_select_statement := 'SELECT ps.payment_schedule_id,ps.customer_trx_id,ps.cust_trx_type_id,
                                  ps.customer_id,ps.customer_site_use_id,ps.trx_number,ps.due_date,
                                  ps.amount_due_remaining, ps.org_id '||l_trx_select_statement;

/*
  FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG TOOL 3');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'select_trx_nimm: l_trx_select_statement = ' || l_trx_select_statement);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_low             = ' || p_due_date_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_due_date_high            = ' || p_due_date_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_low             = ' || p_trx_date_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_date_high            = ' || p_trx_date_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_type_id              = ' || p_trx_type_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_low           = ' || p_trx_number_low);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_trx_number_high          = ' || p_trx_number_high);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_class               = ' || p_cust_class);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cust_category            = ' || p_cust_category);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_id              = ' || p_customer_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_site_use_id              = ' || p_site_use_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_receipt_method_id        = ' || p_receipt_method_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_batch_id                 = ' || p_batch_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_invoice_currency_code    = ' || p_invoice_currency_code);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_exchange_rate            = ' || p_exchange_rate);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_bank_account_id = ' || p_customer_bank_account_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_payment_schedule_id      = ' || p_payment_schedule_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_customer_trx_id          = ' || p_customer_trx_id);
*/

OPEN c_trx FOR l_trx_select_statement
                using 	p_due_date_low,
              		p_due_date_high,
                	p_trx_date_low,
               		p_trx_date_high,
                	p_trx_type_id,
                	p_trx_number_low,
                	p_trx_number_high,
                	p_cust_class,
                	p_cust_category,
                	p_customer_id,
                	p_site_use_id,
                 	p_receipt_method_id,
			p_batch_id,
                        p_invoice_currency_code,
                        p_exchange_rate,
                        p_customer_bank_account_id,
                        p_customer_bank_account_id,
                        p_le_id,
                        p_customer_id,
                        p_payment_schedule_id,
                        p_customer_trx_id;

l_insert_statement := 'INSERT INTO '|| g_tmp_table_nimm ||
  '(payment_schedule_id,customer_trx_id,cust_trx_type_id,customer_id,customer_site_use_id,trx_number,due_date,' ||
  ' amount_due_remaining,amount_assigned,exclude_flag, org_id) '||
  'VALUES (:payment_schedule_id,:customer_trx_id,:cust_trx_type_id,:customer_id,:customer_site_use_id,:trx_number,:due_date,' ||
  ' :amount_due_remaining,NULL,NULL,:org_id) ';


-- Insert INTO the table g_tmp_table_nimm of the transactions (<> od CM and DM) and the CM and DM
-- with payment term of Non Immediate
LOOP

  FETCH c_trx into l_payment_schedule_id,
                   l_customer_trx_id,
                   l_cust_trx_type_id,
                   l_customer_id,
                   l_customer_site_use_id,
                   l_trx_number,
                   l_due_date,
                   l_amount_due_remaining,
                   l_org_id;

  EXIT WHEN c_trx%NOTFOUND;

  execute immediate l_insert_statement
		USING l_payment_schedule_id,
                      l_customer_trx_id,
                      l_cust_trx_type_id,
                      l_customer_id,
                      l_customer_site_use_id,
                      l_trx_number,
                      l_due_date,
                      l_amount_due_remaining,
                      l_org_id;
/*
  FND_FILE.PUT_LINE(FND_FILE.LOG,'select_trx_NIMM:'||l_payment_schedule_id||' '||l_customer_trx_id||' '||l_trx_number||
                                              ' '||l_customer_site_use_id||' '||l_due_date||' '||l_amount_due_remaining);
*/

END LOOP;
CLOSE c_trx;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.select_trx_NIMM (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.select_trx_NIMM');

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   RAISE;

END select_trx_NIMM;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_BR                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |        p_call : 1 run from the Automatic batch window                     |
 |                 2 run from SRS                                            |
 |                 3 run from the transaction workbench                      |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 31/07/2000           |
 | 									     |
 | 06-Jun-01	VCRISOST	Bug 1808976 : added parameter                |
 				p_customer_bank_account_id                   |
 |                                                                           |
 | 06-Mar-03  Sahana    Bug2686697: BR batch Creation program was failing    |
 |                      if the invoice had multiple terms and the payment    |
 |                      method used rule 'One per Invoice'. Made changes in  |
 |                      Create_BR to handle condition.                       |
 |                                                                           |
 | 18-Apr-03  Sahana    Bug2866665:  Inherit Transaction No does not work for|
 |                      cases where the grouping rule is other then PER_INVOICE
 |                      or PER_PAYMENT_SCHEDULE.Re-wrote the logic which checks
 |                      for the one to one relationship.		     |
 | 09-NOV-04 VCRISOST   Bug 4006714 : restructure logic to exclude trx when  |
 |                      total of all trx to exchange does not fall with amt  |
 |                      range of payment method                              |
 | 11-MAY-05 VCRISOST   LE-R12:Pass p_le_id for create_br_header             |
 | 25-MAY-05 VCRISOST	SSA-R12: pass p_org_id                               |
 | 03-OCT-05 SGNAGARA	PAYMENT UPTAKE: Added payment_trxn_extn_id.          |
 +===========================================================================*/
PROCEDURE create_BR(
	p_draft_mode            	IN  	VARCHAR2,
    	p_call                          IN      NUMBER,
    	p_batch_id              	IN   	RA_BATCHES.batch_id%TYPE,
    	p_receipt_method_id		IN 	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
	p_receipt_creation_rule_code	IN	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE,
	p_maturity_date_rule_code	IN	AR_RECEIPT_METHODS.maturity_date_rule_code%TYPE,
	p_br_min_acctd_amount		IN	AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE,
	p_br_max_acctd_amount		IN	AR_RECEIPT_METHODS.br_max_acctd_amount%TYPE,
	p_currency_code			IN	RA_BATCHES.currency_code%TYPE,
        p_customer_bank_account_id	IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE DEFAULT NULL,
        p_le_id                         IN      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE,
        p_bill_id			OUT NOCOPY	RA_CUSTOMER_TRX.customer_trx_id%TYPE,
        p_request_id			OUT NOCOPY	NUMBER) IS


c_trx				cur_typ;

l_default_printing_option	VARCHAR2(20);

l_return_status    		VARCHAR2(20);
l_msg_count        		NUMBER;
l_msg_data         		VARCHAR2(4000);

l_payment_schedule_id		AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;

l_customer_trx_id		RA_CUSTOMER_TRX.customer_trx_id%TYPE;
l_br_maturity_date		RA_CUSTOMER_TRX.term_due_date%TYPE;
l_cust_trx_type_id		RA_CUSTOMER_TRX.cust_trx_type_id%TYPE;
l_drawee_id			RA_CUSTOMER_TRX.drawee_id%TYPE;
l_drawee_site_use_id            RA_CUSTOMER_TRX.drawee_site_use_id%TYPE;
l_drawee_contact_id		RA_CUSTOMER_TRX.drawee_contact_id%TYPE;
l_drawee_bank_account_id	RA_CUSTOMER_TRX.drawee_bank_account_id%TYPE;
l_created_from			RA_CUSTOMER_TRX.created_from%TYPE;

-- Bug 1808976
l_site_id                       RA_CUSTOMER_TRX.bill_to_site_use_id%TYPE;
l_bill_to_site_id               RA_CUSTOMER_TRX.bill_to_site_use_id%TYPE;


l_customer_trx_line_id		RA_CUSTOMER_TRX_LINES.customer_trx_line_id%TYPE;

l_bill_id			RA_CUSTOMER_TRX.customer_trx_id%TYPE;
l_bill_number			RA_CUSTOMER_TRX.trx_number%TYPE;
l_bill_status			AR_TRANSACTION_HISTORY.status%TYPE;
l_request_id			NUMBER;

l_batch_process_status          RA_BATCHES.batch_process_status%TYPE;
l_batch_source_id		RA_BATCHES.batch_source_id%TYPE;
l_gl_date			RA_BATCHES.gl_date%TYPE;
l_issue_date			RA_BATCHES.issue_date%TYPE;
l_maturity_date			RA_BATCHES.maturity_date%TYPE;
l_comments			RA_BATCHES.comments%TYPE;
l_special_instructions		RA_BATCHES.special_instructions%TYPE;
l_due_date_nimm			RA_BATCHES.maturity_date%TYPE;
l_due_date_imm			RA_BATCHES.maturity_date%TYPE;

l_doc_sequence_id		NUMBER;
l_doc_sequence_value		NUMBER;
l_old_trx_number		VARCHAR2(20);

l_table_name			VARCHAR2(50);
l_statement 			VARCHAR2(1000);
l_update_statement 		VARCHAR2(1000);
l_delete_statement 		VARCHAR2(1000);

l_trx_nimm_statement 		VARCHAR2(100) := 'SELECT COUNT(*) FROM '|| g_tmp_table_nimm ||
                                                 ' WHERE amount_assigned IS NULL';
l_nb_trx_nimm			NUMBER;

l_sum_nimm_statement 		VARCHAR2(100) := 'SELECT SUM(amount_due_remaining) FROM '||
                                                 g_tmp_table_nimm||' WHERE amount_assigned IS NULL';
l_sum_imm_statement 		VARCHAR2(100) := 'SELECT SUM(amount_due_remaining) FROM '||
                                                 g_tmp_table_imm ||' WHERE amount_assigned IS NULL';
l_tot_nimm			NUMBER;
l_tot_imm			NUMBER;
l_br_amount			NUMBER;

l_excluded_amount     		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
l_assigned_amount		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;

l_tot_negative_count		NUMBER;
l_tot_positive_count		NUMBER;

l_tot_rec_nimm 			NUMBER;
l_excluded_rec_nimm		NUMBER;

l_org_id                        NUMBER;

-- Bug 1710187 : define a variable to hold customer_site_use_id for transaction being exchanged for BR
l_bill_to_id			AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;

-- Bug 1708420 : define variable to hold BR_INHERIT_INV_NUM_FLAG value
l_br_inherit_inv_num_flag       AR_RECEIPT_METHODS.BR_INHERIT_INV_NUM_FLAG%TYPE;
l_trx_number			  RA_CUSTOMER_TRX.TRX_NUMBER%TYPE;
l_count_trxid			  NUMBER;
l_count_ps   			  NUMBER;
l_cust_trx_id                   RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE;

-- Bug2290332: Check for Automatic Transaction Numbering
 CURSOR bs_details(p_batch_source_id IN number) is
    SELECT auto_trx_numbering_flag, name
    FROM   ra_batch_sources
    WHERE  batch_source_id = p_batch_source_id;
  rec_bs bs_details%ROWTYPE;

-- Bug 4006714  : define new variables
l_cursor_nimm   VARCHAR2(1000) := 'SELECT payment_schedule_id, due_date, ' ||
                                  'amount_due_remaining, nvl(exclude_flag,''N''), org_id FROM '|| g_tmp_table_nimm ||
                                  ' ORDER BY due_date DESC, amount_due_remaining DESC';

l_cursor_imm    VARCHAR2(1000) := 'SELECT payment_schedule_id, due_date, ' ||
                                  'amount_due_remaining, nvl(exclude_flag,''N''), org_id FROM '|| g_tmp_table_imm ||
                                  ' ORDER BY due_date DESC, amount_due_remaining DESC';
use_cursor_stmt VARCHAR2(1000);
cursor_loop     cur_typ;
c_psid          AR_PAYMENT_SCHEDULES.PAYMENT_SCHEDULE_ID%TYPE;
c_due           AR_PAYMENT_SCHEDULES.DUE_DATE%TYPE;
c_adr           AR_PAYMENT_SCHEDULES.AMOUNT_DUE_REMAINING%TYPE;
c_exc           VARCHAR2(1);
-- end 4006714

jnk1   NUMBER;
jnk2   NUMBER;

--5051673
 l_ext_entity_tab        IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
 l_msg                   RA_INTERFACE_ERRORS.MESSAGE_TEXT%TYPE;
 l_payer                 IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
 l_trxn_attribs          IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
 l_result                IBY_FNDCPT_COMMON_PUB.Result_rec_type;

 l_extension_id          NUMBER default null;


-- l_return_status         VARCHAR2(100);
-- l_msg_count             NUMBER:=0;
-- l_msg_data              VARCHAR2(20000):= NULL;


BEGIN

IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
   program_debug(p_call,'ARP_PROGRAM_GENERATE_BR.create_BR (+)');
END IF;

l_return_status := FND_API.G_RET_STS_SUCCESS;

SAVEPOINT create_BR_SVP;

-------------------------------------------------------------------------------
-- FIRST LOOP
-- are there some stored payment schedules not assigned to a BR ???
-------------------------------------------------------------------------------
LOOP /* process temporary table */

  execute immediate l_trx_nimm_statement INTO l_nb_trx_nimm;
  EXIT WHEN l_nb_trx_nimm=0;

  /* if the handled grouping rule is 'PER_INVOICE', one transaction must generate
     one BR; since only a transaction is stored in the temporary table in this case,
     it isn't necessary to try and exclude some payment schedules if the total amount
     isn't between the min and the max
  */

  execute immediate l_sum_nimm_statement INTO l_tot_nimm;
  execute immediate l_sum_imm_statement  INTO l_tot_imm;
  l_br_amount:= NVL(l_tot_nimm,0) + NVL(l_tot_imm,0);

  -- FND_FILE.PUT_LINE(FND_FILE.LOG,'l_br_amount = ' || to_char(l_br_amount));
  -- FND_FILE.PUT_LINE(FND_FILE.LOG,'p_receipt_creation_rule_code = ' || p_receipt_creation_rule_code);

  IF (p_receipt_creation_rule_code <> 'PER_INVOICE')  THEN


    LOOP
    EXIT WHEN (l_br_amount BETWEEN p_br_min_acctd_amount AND p_br_max_acctd_amount);

      /*---------------------------------------------------------------------------------------
        Bug 4006714 :

        the total amount of transactions for exchange is not within BR amount range defined
        for BR creation payment method,

        if total BR amount is less than minimum exclude negative amounts from NIMM then IMM
        if total BR amount is over the maximum than exclude positive amounts from NIMM then IMM

        the order of excluding transactions is based on due_date DESC and
        amount_due_remaining DESC
        ---------------------------------------------------------------------------------------*/

      -- process non-immediate first
      use_cursor_stmt := l_cursor_nimm;
      l_table_name := g_tmp_table_nimm;

      LOOP -- first process non-immediate then immediate

         EXIT WHEN l_table_name IS NULL;
         EXIT WHEN (l_br_amount BETWEEN p_br_min_acctd_amount AND p_br_max_acctd_amount);

         OPEN cursor_loop FOR use_cursor_stmt;

         LOOP  -- to process all rows in l_table_name

            EXIT WHEN cursor_loop%NOTFOUND;
            EXIT WHEN (l_br_amount BETWEEN p_br_min_acctd_amount AND p_br_max_acctd_amount);

            FETCH cursor_loop into c_psid, c_due, c_adr, c_exc;

              /* Bug 5917574 not to generate BR when total br amount is less than minimum amount
                 of payment method thresh hold */
/*
            IF l_br_amount < p_br_min_acctd_amount THEN
               -- total BR amount is less than MIN BR amount range, need to find
               -- negative amounts to exclude
               IF c_adr < 0 AND c_exc = 'N' THEN

                  l_update_statement := 'UPDATE '||l_table_name|| ' SET exclude_flag = ''Y'' WHERE '||
                                        ' payment_schedule_id = :c_psid';
                  EXECUTE IMMEDIATE l_update_statement USING c_psid;
                  l_br_amount := l_br_amount - c_adr;

                  -- FND_FILE.PUT_LINE(FND_FILE.LOG,'excluding psid = ' || to_char(c_psid) ||
                  --                  ' amount = ' || to_char(c_adr) || ' l_br_amount now = ' || to_char(l_br_amount));
               END IF;
*/
            IF l_br_amount > p_br_max_acctd_amount THEN
               -- total BR amount is more than MAX BR amount range, need to find
               -- positive amounts to exclude
               IF c_adr > 0 AND c_exc = 'N' THEN

                  l_update_statement := 'UPDATE '||l_table_name|| ' SET exclude_flag = ''Y'' WHERE '||
                                        ' payment_schedule_id = :c_psid';
                  EXECUTE IMMEDIATE l_update_statement USING c_psid;
                  l_br_amount := l_br_amount - c_adr;

                  -- FND_FILE.PUT_LINE(FND_FILE.LOG,'excluding psid = ' || to_char(c_psid) ||
                  --                  ' amount = ' || to_char(c_adr) || ' l_br_amount now = ' || to_char(l_br_amount));

               END IF;
            END IF;

         END LOOP;

         -- set to process Immediate table
         IF (l_table_name = g_tmp_table_nimm) THEN
            l_table_name := g_tmp_table_imm;
            use_cursor_stmt := l_cursor_imm;
         ELSE
            l_table_name := NULL;
         END IF;

         CLOSE cursor_loop;
      END LOOP;

      -- no transaction exclusions are sufficient to bring BR into amount range
      IF (l_br_amount NOT BETWEEN p_br_min_acctd_amount AND p_br_max_acctd_amount) THEN
          EXIT;
      END IF;

    END LOOP; /* validate amount is within range */

  END IF; /* (p_receipt_creation_rule_code <> 'PER_INVOICE') */

  /*------------------------------------------------------------
     BR cannot be created because total exceeds BR range amount
    ------------------------------------------------------------*/
  IF (l_br_amount NOT BETWEEN p_br_min_acctd_amount AND p_br_max_acctd_amount) THEN
      IF p_call = 3 THEN
         FND_MESSAGE.set_name('AR', 'AR_BR_AMOUNT_INCORRECT');
         APP_EXCEPTION.raise_exception;
      ELSE
         EXIT;
      END IF;
  END IF;

  l_statement := 'SELECT COUNT(*) FROM '||g_tmp_table_nimm||' WHERE exclude_flag IS NOT NULL ';
  execute immediate l_statement into l_excluded_rec_nimm;


  l_statement := 'SELECT COUNT(*) FROM '||g_tmp_table_nimm;
  execute immediate l_statement into l_tot_rec_nimm;

  /*-----------------------------------------------------------------------------------
     BR cannot be created because only transactions with IMMEDIATE term will be picked
    -----------------------------------------------------------------------------------*/

   IF (l_excluded_rec_nimm > 0) AND (l_tot_rec_nimm = l_excluded_rec_nimm) THEN
      FND_MESSAGE.set_name('AR', 'AR_BR_ONLY_DR_CR');
      IF p_call = 3 THEN
         APP_EXCEPTION.raise_exception;
      ELSE
         program_debug(p_call,FND_MESSAGE.get);
         EXIT;
      END IF;
  END IF;

  /*--------------------------
     Possible creation of BR
    --------------------------*/

  l_statement := 'UPDATE '||g_tmp_table_nimm||
                 ' SET amount_assigned=amount_due_remaining WHERE exclude_flag IS NULL ';
  execute immediate l_statement;

  l_statement := 'UPDATE '||g_tmp_table_imm||
                 ' SET amount_assigned=amount_due_remaining WHERE exclude_flag IS NULL';
  execute immediate l_statement;

  IF (p_call <> 3) THEN

      SELECT batch_source_id,
             batch_process_status,
             gl_date,
             issue_date,
             maturity_date,
             comments,
             special_instructions
      INTO   l_batch_source_id,
             l_batch_process_status,
             l_gl_date,
             l_issue_date,
             l_maturity_date,
             l_comments,
             l_special_instructions
      FROM RA_BATCHES
      WHERE batch_id = p_batch_id;

  ELSE

      l_batch_source_id := fnd_profile.value('AR_BR_BATCH_SOURCE');
      l_batch_process_status := NULL;
      l_gl_date := SYSDATE;
      l_issue_date := SYSDATE;
      l_maturity_date := NULL;
      l_comments :=NULL;
      l_special_instructions := NULL;

  END IF;

 IF (l_batch_source_id IS NULL) THEN
      IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
          program_debug(p_call, 'The Bill receivable can not be created because ' ||
                        'the Batch_source_id is NULL ');
      END IF;
      IF p_call = 3 THEN
         FND_MESSAGE.set_name('AR','AR_NO_PROFILE_VALUE');
         FND_MESSAGE.set_token('PROFILE','AR: Bills Receivable Batch Source');
         APP_EXCEPTION.raise_exception;
      END IF;
      EXIT;

  END IF;


 /* Start of Bug2290332 - Check if automatic numbering is enabled for batch source*/
  OPEN bs_details(l_batch_source_id);
  FETCH bs_details INTO rec_bs;

  IF (rec_bs.auto_trx_numbering_flag = 'N') then
      fnd_message.set_name('AR','AR_BR_MANUAL_BATCH_SOURCE');
      fnd_message.set_token('BATCH_SOURCE_NAME',rec_bs.name);
      IF p_call = 3 THEN
          APP_EXCEPTION.raise_exception;
      ELSE
          program_debug(p_call,FND_MESSAGE.get);
          EXIT;
      END IF;
  END IF;

  CLOSE bs_details;
 /* End of Bug2290332 - Check if automatic numbering is enabled for batch source*/


  -- set created_from
  IF (p_call = 1) THEN
      l_created_from := 'ARBRCBAT.fmx';
  ELSIF (p_call = 2) THEN
      l_created_from := 'FNDRSRUN.fmx';
  ELSIF (p_call = 3) THEN
      l_created_from := 'ARXTWMAI.fmx';
  ELSE
      g_field := 'p_call';
      FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
      FND_MESSAGE.set_token('PROCEDURE','create_BR');
      FND_MESSAGE.set_token('PARAMETER', g_field);
      APP_EXCEPTION.raise_exception;
  END IF;

  -- set BR Maturity date
  IF (l_maturity_date IS NULL) THEN

      IF (p_maturity_date_rule_code = 'EARLIEST') THEN

          l_statement := 'SELECT MIN(due_date) FROM '||g_tmp_table_nimm||' WHERE exclude_flag IS NULL';
          execute immediate l_statement INTO l_due_date_nimm;

          -- Bug 3930958 : exclude CMs when picking trx to base maturity date from
          l_statement := 'SELECT MIN(due_date) FROM '||g_tmp_table_imm||' imm  WHERE exclude_flag IS NULL
                         and not exists (select ''x'' from ra_cust_trx_types t
                                         where t.cust_trx_type_id = imm.cust_trx_type_id
                                         and   t.type = ''CM'') ';
          execute immediate l_statement INTO l_due_date_imm;

          IF (l_due_date_imm IS NULL) THEN
              l_br_maturity_date := l_due_date_nimm;
          ELSIF (l_due_date_nimm < l_due_date_imm) THEN
              l_br_maturity_date := l_due_date_nimm;
          ELSE
              l_br_maturity_date := l_due_date_imm;
          END IF;

      ELSIF (p_maturity_date_rule_code = 'LATEST') THEN

          l_statement := 'SELECT MAX(due_date) FROM '||g_tmp_table_nimm||' WHERE exclude_flag IS NULL';
          execute immediate l_statement INTO l_due_date_nimm;

          -- Bug 3930958 : exclude CMs when picking trx to base maturity date from
          l_statement := 'SELECT MAX(due_date) FROM '||g_tmp_table_imm||' imm WHERE exclude_flag IS NULL
                        and not exists (select ''x'' from ra_cust_trx_types t
                                         where t.cust_trx_type_id = imm.cust_trx_type_id
                                         and   t.type = ''CM'') ';
          execute immediate l_statement INTO l_due_date_imm;

          IF (l_due_date_imm IS NULL) THEN
              l_br_maturity_date := l_due_date_nimm;
          ELSIF (l_due_date_nimm > l_due_date_imm) THEN
              l_br_maturity_date := l_due_date_nimm;
          ELSE
              l_br_maturity_date := l_due_date_imm;
          END IF;

      ELSE
          FND_MESSAGE.set_name('AR','AR_BR_INVALID_MAT_DATE_RULE');
          FND_MESSAGE.set_token('MAT_DATE_RULE',p_maturity_date_rule_code);
          APP_EXCEPTION.raise_exception;
      END IF;

  ELSE
      l_br_maturity_date := l_maturity_date;
  END IF;

  /* -----------------------------------------------------------------------------------------
       4109513 : following sequence was originally in lower section of code,
       I have moved it up here so further selects are not run if BR won't be created anyway

       A bill receivable must not be created when the maturity date is prior to the issue date
  -----------------------------------------------------------------------------------------*/

  IF (TO_DATE(l_br_maturity_date,'DD/MM/RR') < TO_DATE(l_issue_date,'DD/MM/RR')) THEN
      FND_MESSAGE.set_name('AR','AR_BR_INCORRECT_MATURITY_DT');
      FND_MESSAGE.set_token('MATURITY_DT',l_br_maturity_date);
      FND_MESSAGE.set_token('ISSUE_DT',l_issue_date);

      IF p_call = 3 THEN
         APP_EXCEPTION.raise_exception;
      ELSE
         program_debug(p_call,FND_MESSAGE.get);
         EXIT;
      END IF;

  END IF;

  -- BR Transaction type and BR inherit flag
  SELECT br_cust_trx_type_id,
         br_inherit_inv_num_flag
  INTO l_cust_trx_type_id,
       l_br_inherit_inv_num_flag
  FROM ar_receipt_methods
  WHERE receipt_method_id = p_receipt_method_id;

  /* -------------------------------------------------------------------------
     Bug 1708420 : If receipt class was defined to "Inherit Transaction Number"
     then if there exists a one-to-one relationship between the AR transaction
     and the BR that is going to be generated, the BR should inherit the
     AR transaction's number

     Bug2866665:  Inherit Transaction No does not work for cases where the
     grouping rule is other then PER_INVOICE or PER_PAYMENT_SCHEDULE.Re-wrote
     the logic which checks for the one to one relationship.

     -------------------------------------------------------------------------*/

  -- Start of Bug2866665
  IF nvl(l_br_inherit_inv_num_flag,'N') = 'Y' THEN

    l_statement := 'select count( distinct customer_trx_id ), max(customer_trx_id) from ' ||
                g_tmp_table_nimm;
    execute immediate l_statement INTO l_count_trxid, l_cust_trx_id;

    IF l_count_trxid = 1 THEN
           l_statement := 'SELECT count(*), max(ps.trx_number) ' ||
                       'from ar_payment_schedules ps ' ||
                       'where ps.customer_trx_id = ' ||
                       l_cust_trx_id ;
           execute immediate l_statement INTO l_count_ps, l_trx_number;

           IF l_count_ps <> 1 AND
              p_receipt_creation_rule_code in ('PER_PAYMENT_SCHEDULE', 'PER_CUSTOMER_DUE_DATE',
                                               'PER_SITE_DUE_DATE')  THEN
                l_trx_number := NULL;
           END IF;
    ELSE
           l_trx_number := NULL;
    END IF;

  ELSE

    l_trx_number := NULL;  -- Inherit Trx No is N

  END IF;  -- nvl(l_br_inherit_inv_num_flag,'N') = 'Y'


  BEGIN
  IF l_trx_number is not null THEN
      ARP_TRX_VALIDATE.validate_trx_number(l_batch_source_id,l_trx_number,NULL);
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
     l_trx_number := NULL;
  END;

  -- End of Bug2866665

  -- Drawee site information
  -- Whatever the handled grouping rule, only one customer is handled

  l_statement := 'SELECT customer_id, customer_site_use_id, org_id from '||g_tmp_table_nimm||' WHERE ROWNUM < 2';
  execute immediate l_statement INTO l_drawee_id, l_bill_to_id, l_org_id;


  -- the BR drawee must be the primary and active DRAWEE site of the transaction customer.
  /* modified for tca uptake */
  /* Bug 1710187 : the grouping rule dictates whether or not we should check
     for site_uses.primary_flag = 'Y' */

  /*
     DEVELOPER's NOTE (added by vcrisost 06/06/2001)
     -----------------------------------------------
     a limitation of TCA data model prevents recording a link between a bank account
     and a DRAWEE site. Currently the data model will always link Bank accounts to the
     BILL TO site only

     the following 2 selects which try to find bank accounts for the DRAWEE site
     will always return a null l_drawee_bank_account_id

     please see replacement code below tagged with Bug 1808976

  if p_receipt_creation_rule_code in ('PER_CUSTOMER','PER_CUSTOMER_DUE_DATE') then
     SELECT site_uses.site_use_id,
            site_uses.contact_id,
            Null external_bank_account_id
     INTO l_drawee_site_use_id, l_drawee_contact_id, l_drawee_bank_account_id
     FROM hz_cust_accounts cust_acct,
          hz_cust_acct_sites acct_site,
          hz_cust_site_uses site_uses,
          hz_cust_account_roles acct_role
     WHERE cust_acct.cust_account_id = l_drawee_id
     AND   cust_acct.cust_account_id = acct_site.cust_account_id
     AND   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
     AND   site_uses.site_use_code = 'DRAWEE'
     AND   site_uses.status ='A'
     AND   site_uses.primary_flag = 'Y'
     AND   site_uses.contact_id = acct_role.cust_account_role_id(+)
     AND   acct_role.status(+) ='A';
  else
     -- Bug 1710187 : for other grouping rules, ensure that the BILL TO site of
     -- the transaction is ALSO a DRAWEE site

     SELECT site_uses.site_use_id,
            site_uses.contact_id,
            Null external_bank_account_id
     INTO l_drawee_site_use_id, l_drawee_contact_id, l_drawee_bank_account_id
     FROM hz_cust_accounts cust_acct,
          hz_cust_acct_sites acct_site,
          hz_cust_site_uses site_uses,
          hz_cust_account_roles acct_role,
          hz_party_sites party_site
     WHERE cust_acct.cust_account_id = l_drawee_id
     AND   cust_acct.cust_account_id = acct_site.cust_account_id
     AND   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
     AND   site_uses.site_use_code = 'DRAWEE'
     AND   site_uses.status = 'A'
     AND   acct_site.party_site_id = party_site.party_site_id
     AND   party_site.location_id =
         (select bloc.location_id
          FROM   hz_cust_accounts bcust_acct,
                 hz_cust_acct_sites bacct_site,
                 hz_cust_site_uses bsite_uses,
                 hz_party_sites bparty_site,
                 hz_locations bloc
          WHERE  bcust_acct.cust_account_id = l_drawee_id
           AND   bcust_acct.cust_account_id = bacct_site.cust_account_id
           AND   bacct_site.cust_acct_site_id = bsite_uses.cust_acct_site_id
           AND   bsite_uses.site_use_code = 'BILL_TO'
           AND   bsite_uses.site_use_id = l_bill_to_id
           AND   bsite_uses.status = 'A'
           AND   bacct_site.party_site_id = bparty_site.party_site_id
           AND   bloc.location_id =  bparty_site.location_id)
     AND   site_uses.contact_id = acct_role.cust_account_role_id(+)
     AND   acct_role.status(+) ='A';

  end if;

  */

  /* bug 1808976 : replacement code for select statements commented out above

     to define l_drawee_bank_account_id correctly, use the newly passed parameter
     p_customer_bank_account_id to check if the bank account of the AR transaction
     is also a bank account for the primary DRAWEE site

     new logic is as follows :

     Is the grouping rule : (a) one per customer or (b) one per customer per due date ?
     NO  : use the AR transaction's bank account
     YES : is the AR transaction's bank account also defined as a bank account
          for the primary drawee site for this customer ?
          YES : use the AR transaction's bank account
          NO  : use a NULL bank account
  */

  if p_receipt_creation_rule_code in ('PER_CUSTOMER','PER_CUSTOMER_DUE_DATE') then

     /* the AR transaction's bank account should also be defined as a bank account
        of the DRAWEE site, but since bank accounts cannot be linked to a DRAWEE site
        first make sure that this DRAWEE site is also a BILL TO site and then check
        that the bank account is defined for this BILL TO site
     */

     -- get site/contact information pertaining to PRIMARY drawee site

     SELECT site_uses.site_use_id, site_uses.contact_id, acct_site.cust_acct_site_id
     INTO   l_drawee_site_use_id, l_drawee_contact_id, l_site_id
     FROM   hz_cust_accounts cust_acct,
            hz_cust_acct_sites acct_site,
            hz_cust_site_uses site_uses,
            hz_cust_account_roles acct_role
      WHERE cust_acct.cust_account_id = l_drawee_id
      AND   cust_acct.cust_account_id = acct_site.cust_account_id
      AND   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
      AND   site_uses.site_use_code = 'DRAWEE'
      AND   site_uses.status = 'A'
      AND   site_uses.primary_flag = 'Y'
      AND   site_uses.contact_id = acct_role.cust_account_role_id(+)
      AND   acct_role.status(+) ='A';

     -- get the BILL TO site id associated with l_site_id, because this is where
     -- the bank accounts are linked to

     SELECT site_uses.site_use_id
     INTO   l_bill_to_site_id
     FROM   hz_cust_accounts cust_acct,
            hz_cust_acct_sites acct_site,
            hz_cust_site_uses site_uses
      WHERE cust_acct.cust_account_id = l_drawee_id
      AND   cust_acct.cust_account_id = acct_site.cust_account_id
      AND   acct_site.cust_acct_site_id = l_site_id
      AND   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
      AND   site_uses.site_use_code = 'BILL_TO'
      AND   site_uses.status = 'A';

     -- if the following returns no rows it means that the AR's bank account
     -- IS NOT defined as a bank account for the PRIMARY drawee site and the
     -- BR should be created with no Drawee bank info
    /*  5051673 Need to verfiy this
     select instr_assignment_id
     into l_drawee_bank_account_id
     from IBY_FNDCPT_PAYER_ASSGN_INSTR_V instr
    where instr.acct_site_use_id = l_bill_to_site_id
     and  instr.instr_assignment_id = p_customer_bank_account_id
     and nvl(instr.assignment_end_date,sysdate+1 ) > = sysdate;
    */


    /* Bug 4928711 - Removed the references of AP_BANK_ACCOUNT_USES
     BEGIN
        SELECT account.external_bank_account_id
        INTO   l_drawee_bank_account_id
        FROM   ap_bank_account_uses account
        WHERE  account.customer_site_use_id = l_bill_to_site_id
         AND   account.external_bank_account_id = p_customer_bank_account_id
         AND   nvl(account.end_date, sysdate + 1) >= sysdate;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_drawee_bank_account_id := NULL;
     END;
     */



/*
     IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
         program_debug(p_call,'l_drawee_site_use_id = ' || l_drawee_site_use_id);
         program_debug(p_call,'l_drawee_contact_id = ' ||  l_drawee_contact_id);
         program_debug(p_call,'l_site_id = ' || l_site_id);
         program_debug(p_call,'l_bill_to_site_id = ' || l_bill_to_site_id);
         program_debug(p_call,'l_drawee_bank_account_id = ' || l_drawee_bank_account_id);
    END IF;
*/

  else

      /* since all other grouping rules will look at the BILL TO site, and
         the AR transaction can only use the bank account if it was
         defined for this bill to, we can just automatically use the bank
         account from the AR transaction without much more validation */

      SELECT site_uses.site_use_id,
             site_uses.contact_id,
             p_customer_bank_account_id
      INTO l_drawee_site_use_id, l_drawee_contact_id, l_drawee_bank_account_id
      FROM hz_cust_accounts cust_acct,
           hz_cust_acct_sites acct_site,
           hz_cust_site_uses site_uses,
           hz_cust_account_roles acct_role,
           hz_party_sites party_site
      WHERE cust_acct.cust_account_id = l_drawee_id
      AND   cust_acct.cust_account_id = acct_site.cust_account_id
      AND   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
      AND   site_uses.site_use_code = 'DRAWEE'
      AND   site_uses.status = 'A'
      -- following conditions ensure that this DRAWEE site is also a BILL TO site
      AND   acct_site.party_site_id = party_site.party_site_id
      AND   party_site.location_id =
          (select bloc.location_id
           FROM   hz_cust_accounts bcust_acct,
                  hz_cust_acct_sites bacct_site,
                  hz_cust_site_uses bsite_uses,
                  hz_party_sites bparty_site,
                  hz_locations bloc
           WHERE  bcust_acct.cust_account_id = l_drawee_id
            AND   bcust_acct.cust_account_id = bacct_site.cust_account_id
            AND   bacct_site.cust_acct_site_id = bsite_uses.cust_acct_site_id
            AND   bsite_uses.site_use_code = 'BILL_TO'
            AND   bsite_uses.site_use_id = l_bill_to_id
            AND   bsite_uses.status = 'A'
            AND   bacct_site.party_site_id = bparty_site.party_site_id
            AND   bloc.location_id =  bparty_site.location_id)
      AND   site_uses.contact_id = acct_role.cust_account_role_id(+)
      AND   acct_role.status(+) ='A';

  end if;

  l_bill_id	  := NULL;
  l_bill_number   := NULL;
  l_bill_status   := NULL;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  /* -----------------------------------------------------------------------------------------
     4109513 : Transferred following sequence above, right after l_br_maturity_date is defined

     A bill receivable must not be created when the maturity date is prior to the issue date

  IF (TO_DATE(l_br_maturity_date,'DD/MM/RR') < TO_DATE(l_issue_date,'DD/MM/RR')) THEN
      FND_MESSAGE.set_name('AR','AR_BR_INCORRECT_MATURITY_DT');
      FND_MESSAGE.set_token('MATURITY_DT',l_br_maturity_date);
      FND_MESSAGE.set_token('ISSUE_DT',l_issue_date);

      IF p_call = 3 THEN
         APP_EXCEPTION.raise_exception;
      ELSE
         program_debug(p_call,FND_MESSAGE.get);
         EXIT;
      END IF;

  END IF;
  -----------------------------------------------------------------------------------------*/

  /*-----------------------------------------------------------------------------------------------
    IF The Batch has been run in a draft mode, No BR are created but the report table is filled.
    Otherwise,  the BR are created and the report table is filled.
    ------------------------------------------------------------------------------------------------*/
  IF p_draft_mode = 'N' THEN

     /*----------------------------------------
          Create the Bill Receivable Header
       ----------------------------------------*/
     /* Bug 3472744 Placing an enclosing block to handle Exceptions. */

     BEGIN   /* create_br_header block */

     SAVEPOINT create_BR_SVP2;

     IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
       program_debug(p_call,'DEBUG TOOL 4');
       program_debug(p_call,'------------------------------------------------');
       program_debug(p_call,'l_br_maturity_date        '||l_br_maturity_date);
       program_debug(p_call,'l_batch_source_id         '||l_batch_source_id);
       program_debug(p_call,'l_cust_trx_type_id        '||l_cust_trx_type_id);
       program_debug(p_call,'p_currency_code           '||p_currency_code);
       program_debug(p_call,'l_br_amount               '||l_br_amount);
       program_debug(p_call,'l_issue_date              '||l_issue_date);
       program_debug(p_call,'l_gl_date                 '||l_gl_date);
       program_debug(p_call,'l_drawee_id               '||l_drawee_id);
       program_debug(p_call,'l_drawee_site_use_id      '||l_drawee_site_use_id);
       program_debug(p_call,'l_drawee_contact_id       '||l_drawee_contact_id);
       program_debug(p_call,'p_printing_option         '||NULL);
       program_debug(p_call,'l_comments                '||l_comments);
       program_debug(p_call,'l_special_instructions    '||l_special_instructions);
       program_debug(p_call,'l_drawee_bank_account_id  '||l_drawee_bank_account_id);
       program_debug(p_call,'p_batch_id                '||p_batch_id);
       program_debug(p_call,'l_created_from            '||l_created_from);
       program_debug(p_call,'l_trx_number              '||l_trx_number);
       program_debug(p_call,'l_bill_to_id              '||l_bill_to_id);
       program_debug(p_call,'l_org_id                  '||l_org_id);

    END IF;


     -- Bug 1708420 : pass l_trx_number rather than NULL

     program_debug(p_call,'will call AR_BILLS_CREATION_PUB.Create_BR_Header');
   if p_call <> 3 then
     -- SSA-R12 : add l_org_id
     AR_BILLS_CREATION_PUB.Create_BR_Header (
                1.0,				-- p_api_version
                NULL,				-- p_init_msg_list
                NULL,				-- p_commit,
                NULL,				-- p_validation_level
                l_return_status,
                l_msg_count,
                l_msg_data,
		l_trx_number,			-- p_trx_number
		l_br_maturity_date,		-- p_term_due_date
		l_batch_source_id,		-- p_batch_source_id
		l_cust_trx_type_id,		-- p_cust_trx_type_id
		p_currency_code,		-- p_invoice_currency_code
		l_br_amount,			-- p_br_amount
		l_issue_date,			-- p_trx_date
		l_gl_date,			-- p_gl_date
		l_drawee_id,			-- p_drawee_id
		l_drawee_site_use_id,		-- p_drawee_site_use_id
		l_drawee_contact_id,		-- p_drawee_contact_id
		NULL,				-- p_printing_option
		l_comments,			-- p_comments
		l_special_instructions,		-- p_special_instructions
                null, -- p_drawee_bank_Account_id
--		l_drawee_bank_account_id,	-- p_drawee_bank_account_id
		NULL,				-- p_remittance_bank_account_id
		NULL,				-- p_override_remit_account_flag
		p_batch_id,			-- p_batch_id
		NULL,				-- p_doc_sequence_id
		NULL,				-- p_doc_sequence_value
		l_created_from,			-- p_created_from
                NULL,				-- p_attribute_category
		NULL,				-- p_attribute1
		NULL,				-- p_attribute2
		NULL,				-- p_attribute3
		NULL,				-- p_attribute4
		NULL,				-- p_attribute5
		NULL,				-- p_attribute6
		NULL,				-- p_attribute7
		NULL,				-- p_attribute8
		NULL,				-- p_attribute9
		NULL,				-- p_attribute10
		NULL,				-- p_attribute11
		NULL,				-- p_attribute12
		NULL,				-- p_attribute13
		NULL,				-- p_attribute14
		NULL,				-- p_attribute15
                p_le_id,                        -- p_legal_entity
                l_org_id,                       -- p_org_id
		NULL,				-- p_payment_trxn_extn_id
                l_bill_id,
		l_bill_number,
		l_bill_status);

    else

       l_payer.Payment_Function        := 'CUSTOMER_PAYMENT';
       l_payer.Party_Id                :=  arp_trx_defaults_3.get_party_Id(l_drawee_id);
       l_payer.Cust_Account_Id         := l_drawee_id;
       l_trxn_attribs.trxn_ref_number1 := 'BILLS_RECIEVABLE';
       l_ext_entity_tab(1) :=p_customer_bank_account_id;


       IBY_FNDCPT_TRXN_PUB.Copy_Transaction_Extension
       (
       p_api_version        =>1.0,
       p_init_msg_list      =>FND_API.G_TRUE,
       p_commit             =>FND_API.G_FALSE,
       x_return_status      =>l_return_status,
       x_msg_count          =>l_msg_count,
       x_msg_data           =>l_msg_data,
       p_payer              =>l_payer,
       p_payer_equivalency  =>IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_DOWNWARD,
       p_entities           =>l_ext_entity_tab,
       p_trxn_attribs       =>l_trxn_attribs,
       x_entity_id          =>l_extension_id,
       x_response           =>l_result
       );


	  AR_BILLS_CREATION_PUB.Create_BR_Header (
                1.0,                            -- p_api_version
                NULL,                           -- p_init_msg_list
                NULL,                           -- p_commit,
                NULL,                           -- p_validation_level
                l_return_status,
                l_msg_count,
                l_msg_data,
                l_trx_number,                   -- p_trx_number
                l_br_maturity_date,             -- p_term_due_date
                l_batch_source_id,              -- p_batch_source_id
                l_cust_trx_type_id,             -- p_cust_trx_type_id
                p_currency_code,                -- p_invoice_currency_code
                l_br_amount,                    -- p_br_amount
                l_issue_date,                   -- p_trx_date
                l_gl_date,                      -- p_gl_date
                l_drawee_id,                    -- p_drawee_id
                l_drawee_site_use_id,           -- p_drawee_site_use_id
                l_drawee_contact_id,            -- p_drawee_contact_id
                NULL,                           -- p_printing_option
                l_comments,                     -- p_comments
                l_special_instructions,         -- p_special_instructions
                null, -- p_drawee_bank_Account_id
--              l_drawee_bank_account_id,       -- p_drawee_bank_account_id
                NULL,                           -- p_remittance_bank_account_id
                NULL,                           -- p_override_remit_account_flag
                p_batch_id,                     -- p_batch_id
                NULL,                           -- p_doc_sequence_id
                NULL,                           -- p_doc_sequence_value
                l_created_from,                 -- p_created_from
                NULL,                           -- p_attribute_category
                NULL,                           -- p_attribute1
                NULL,                           -- p_attribute2
                NULL,                           -- p_attribute3
                NULL,                           -- p_attribute4
                NULL,                           -- p_attribute5
		NULL,                           -- p_attribute6
                NULL,                           -- p_attribute7
                NULL,                           -- p_attribute8
                NULL,                           -- p_attribute9
                NULL,                           -- p_attribute10
                NULL,                           -- p_attribute11
                NULL,                           -- p_attribute12
                NULL,                           -- p_attribute13
                NULL,                           -- p_attribute14
                NULL,                           -- p_attribute15
                p_le_id,                        -- p_legal_entity
                l_org_id,                       -- p_org_id
                l_extension_id,     -- p_payment_trxn_extn_id
                l_bill_id,
                l_bill_number,
                l_bill_status);
      end if;


      select org_id into jnk1 from ra_customer_trx where customer_trx_id = l_bill_id;
      select org_id into jnk2 from ar_transaction_history where customer_trx_id = l_bill_id;

     program_debug(p_call,'done with AR_BILLS_CREATION_PUB.Create_BR_Header org_id = ' || to_char(jnk1) || 'org_id = ' ||
           to_char(jnk2));

      EXCEPTION    /* Bug 3472744 Enclosed the following check in Exception block */
      WHEN OTHERS THEN

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
         program_debug(p_call,'EXCEPTION AR_BILLS_CREATION_PUB.Create_BR_Header()- unexpected error');
        END IF;
        IF p_call = 3 THEN
          FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
        END IF;
        APP_EXCEPTION.raise_exception;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           l_msg_data := FND_MESSAGE.Get;
           IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                program_debug(p_call,'EXCEPTION AR_BILLS_CREATION_PUB.Create_BR_Header() ' ||                            '- error :'||l_msg_data);
           END IF;
            ROLLBACK TO create_BR_SVP2;
             IF p_call = 3 THEN
                 FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
            END IF;
           APP_EXCEPTION.raise_exception; /* Bug3472744 Moved this from inside p_call=3 */
           --  EXIT; /* Bug 3472744 Commented the EXIT */
      END IF;
      END ; /* create_br_header block change6*/

      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      /*----------------------------------------------------
         Assign the payment schedules to the Bill receivable
        ----------------------------------------------------*/

          -- 1st temporary table
          l_statement := 'SELECT payment_schedule_id, amount_assigned, org_id FROM '||
                         g_tmp_table_nimm||' WHERE amount_assigned IS NOT NULL';
          OPEN c_trx FOR l_statement;

          LOOP

            /* Bug 3472744 Placing an enclosing block to handle Exceptions. */

            BEGIN /* create_br_assignment_nimm  block  */

            FETCH c_trx INTO l_payment_schedule_id, l_assigned_amount, l_org_id;
            EXIT WHEN c_trx%NOTFOUND;

            program_debug(p_call,'nimm: l_org_id                  '||l_org_id);

            program_debug(p_call,'will call AR_BILLS_CREATION_PUB.Create_BR_Assignment for NIMM');
	    AR_BILLS_CREATION_PUB.create_br_assignment (
		1.0,				-- p_api_version
	        NULL,				-- p_init_msg_list
		NULL,				-- p_commit
		NULL,				-- p_validation_level,
                l_return_status,
                l_msg_count,
                l_msg_data,
		l_bill_id,			-- p_customer_trx_id
	 	l_payment_schedule_id,		-- l_payment_schedule_id
		l_assigned_amount,		-- p_assigned_amount
		NULL,				-- p_attribute_category
		NULL,				-- p_attribute1
		NULL,				-- p_attribute2
		NULL,				-- p_attribute3
		NULL,				-- p_attribute4
		NULL,				-- p_attribute5
		NULL,				-- p_attribute6
		NULL,				-- p_attribute7
		NULL,				-- p_attribute8
		NULL,				-- p_attribute9
		NULL,				-- p_attribute10
		NULL,				-- p_attribute11
		NULL,				-- p_attribute12
		NULL,				-- p_attribute13
		NULL,				-- p_attribute14
		NULL,				-- p_attribute15
                l_org_id,                       -- p_org_id
		l_customer_trx_line_id);

        select org_id into jnk1 from ra_customer_trx_lines where customer_trx_line_id = l_customer_trx_line_id;
                program_debug(p_call,'done with AR_BILLS_CREATION_PUB.Create_BR_Assignment for NIMM, org_id = '
                       || to_char(jnk1));

           EXCEPTION /* Bug 3472744 Enclosed the following check in Exception block */
           WHEN OTHERS
           THEN
           IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                    program_debug(p_call,'EXCEPTION NIMM : AR_BILLS_CREATION_PUB.create_br_assignment() ' ||
                                 '- unexpected error ');
               END IF;
               IF p_call = 3 THEN
                  FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
               END IF;
               APP_EXCEPTION.raise_exception;
          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               l_msg_data := FND_MESSAGE.Get;
               IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                    program_debug(p_call,'EXCEPTION NIMM : AR_BILLS_CREATION_PUB.create_br_assignment() ' ||
                                 ' - error :'||l_msg_data);
               END IF;
               ROLLBACK TO create_BR_SVP2;
               IF p_call = 3 THEN
                  FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
               END IF;
               APP_EXCEPTION.raise_exception;
           END IF;
         END; /* create_br_assignment_nimm block change6*/

        END LOOP;
        CLOSE c_trx;


          IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

              -- 2nd temporary table
              l_statement := 'SELECT payment_schedule_id, amount_assigned, org_id FROM '||
                              g_tmp_table_imm||' WHERE amount_assigned IS NOT NULL';
              OPEN c_trx FOR l_statement;

              LOOP

                /* Bug 3472744 Placing an enclosing block to handle Exceptions. */

               BEGIN  /* create_br_assignment_imm block  */

                FETCH c_trx INTO l_payment_schedule_id, l_assigned_amount, l_org_id;
                EXIT WHEN c_trx%NOTFOUND;

                program_debug(p_call,'imm: l_org_id                  '||l_org_id);
                program_debug(p_call,'will call AR_BILLS_CREATION_PUB.Create_BR_Assignment for IMM');


	        AR_BILLS_CREATION_PUB.create_br_assignment (
			1.0,				-- p_api_version
	        	NULL,				-- p_init_msg_list
			NULL,				-- p_commit
			NULL,				-- p_validation_level,
                	l_return_status,
                	l_msg_count,
                	l_msg_data,
			l_bill_id,			-- p_customer_trx_id
	 		l_payment_schedule_id,		-- l_payment_schedule_id
			l_assigned_amount,		-- p_assigned_amount
			NULL,				-- p_attribute_category
			NULL,				-- p_attribute1
			NULL,				-- p_attribute2
			NULL,				-- p_attribute3
			NULL,				-- p_attribute4
			NULL,				-- p_attribute5
			NULL,				-- p_attribute6
			NULL,				-- p_attribute7
			NULL,				-- p_attribute8
			NULL,				-- p_attribute9
			NULL,				-- p_attribute10
			NULL,				-- p_attribute11
			NULL,				-- p_attribute12
			NULL,				-- p_attribute13
			NULL,				-- p_attribute14
			NULL,				-- p_attribute15
                        l_org_id,                       -- p_org_id
			l_customer_trx_line_id);

                program_debug(p_call,'done with AR_BILLS_CREATION_PUB.Create_BR_Assignment for IMM');


              EXCEPTION  /* Bug 3472744 Enclosed the following check in Exception block */
              WHEN OTHERS
              THEN
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                     IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                           program_debug(p_call,'EXCEPTION IMM: AR_BILLS_CREATION_PUB.create_br_assignment() ' ||
                                 '- unexpected error ');
                     END IF;
                     IF p_call = 3 THEN
                            FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
                     END IF;
                   APP_EXCEPTION.raise_exception;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                   l_msg_data := FND_MESSAGE.Get;
                   IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                      program_debug(p_call,'EXCEPTION IMM: AR_BILLS_CREATION_PUB.create_br_assignment() ' ||
                                 ' - error :'||l_msg_data);
                   END IF;
                   ROLLBACK TO create_BR_SVP2;
                   IF p_call = 3 THEN
                      FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
                   END IF;
                   APP_EXCEPTION.raise_exception; /* Bug3472744 Moved this from inside p_call=3 */
                   -- EXIT;  /* Bug 3472744 Commented the exit */
               END IF;
               END ; /* create_br_assignment_imm block change6*/

             END LOOP;
             CLOSE c_trx;


          -- END IF; /* Bug 3472744 Moved the end if to the position before Else */

          IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

             /*----------------------------
               Complete the Bill receivable
               -----------------------------*/

              /* Bug 3472744 Placing an enclosing block to handle Exceptions. */

              BEGIN  /* complete_br block */

              program_debug(p_call,'will call AR_BILLS_MAINTAIN_PUB.Complete_BR');

      	      AR_BILLS_MAINTAIN_PUB.Complete_BR (
			1.0,				-- p_api_version
	        	NULL,				-- p_init_msg_list
			NULL,				-- p_commit
                	NULL,				-- p_validation_level
                	l_return_status,
                	l_msg_count,
                	l_msg_data,
			l_bill_id,			-- p_customer_trx_id
			l_bill_number,                  -- p_trx_number
			l_doc_sequence_id,
			l_doc_sequence_value,
			l_old_trx_number,
			l_bill_status);


              program_debug(p_call,'done with AR_BILLS_MAINTAIN_PUB.Complete_BR');

               EXCEPTION /* Bug 3472744 Enclosed the following check in Exception block */
               WHEN OTHERS
               THEN
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                         program_debug(p_call,
                                     'EXCEPTION AR_BILLS_CREATION_PUB.complete_BR() ' ||
                                     ' - unexpected error ');
                   END IF;
                   IF p_call = 3 THEN
                      FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
                   END IF;
                   APP_EXCEPTION.raise_exception;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                   l_msg_data := FND_MESSAGE.Get;
                   IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
                       program_debug(p_call,
                                     '>>>> EXCEPTION AR_BILLS_CREATION_PUB.complete_BR() ' ||
                                     '- error :'||l_msg_data);
                   END IF;
                  ROLLBACK TO create_BR_SVP2;
                   IF p_call = 3 THEN
                      FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_BR');
                   END IF;
                   APP_EXCEPTION.raise_exception;
                  --  EXIT;
               END IF;
               END ; /* complete_br block change6 */

               /* Bug 3472744 Moved SUCCESS status check to outside the block and
                      added the condition p_call <> 3

                  Bug 3589636/3617582, restructure IF clause to ensure g_num_br_created
                      is incremented when BR creation returns success
               */

               IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                 g_num_br_created := g_num_br_created + 1;

                 IF (p_call <> 3) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'the bill receivable '||l_bill_number||
                                     ' is created (amount='||l_br_amount||')');

                 ELSIF (p_call = 3) THEN
                   /* Action PRINT BR if the program is run from the transaction workbench and
                      the BR type printing option is set to 'Y' */

                   SELECT NVL(default_printing_option,'NOT')
                   into l_default_printing_option
                   FROM ra_cust_trx_types type,
                        ra_customer_trx trx
                   WHERE trx.customer_trx_id = l_bill_id
                   AND trx.cust_trx_type_id = type.cust_trx_type_id;

                   l_request_id := NULL;

                   IF (l_default_printing_option = 'PRI') THEN
                       print_BR_pvt(l_bill_id,3,l_request_id);
                   END IF;

                   p_bill_id    := l_bill_id;
                   p_request_id := l_request_id;

                 END IF;

               END IF;

             END IF;

          END IF;

      END IF;


  ELSE
      g_num_br_created := g_num_br_created + 1;
      l_bill_number := g_num_br_created;
  END IF;



  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_call <> 3) THEN

   /*------------------------------
      fill the report table
     ------------------------------*/

     -- 1st temporary table
     l_statement := 'SELECT customer_trx_id, SUM(amount_assigned) FROM '||
                    g_tmp_table_nimm||
                    ' WHERE amount_assigned IS NOT NULL GROUP BY customer_trx_id ';

     OPEN c_trx FOR l_statement;

     LOOP
        FETCH c_trx INTO l_customer_trx_id, l_assigned_amount;
        EXIT WHEN c_trx%NOTFOUND;

        -- Bug 1420183 Added p_receipt_method_id
        ARP_PROGRAM_GENERATE_BR.ar_br_insert_into_report_table(
                arp_global.request_id,
                p_batch_id,
                l_bill_id,
                NVL(l_bill_number,to_char(g_num_br_created)),
                l_br_amount,
                p_currency_code,
                l_batch_process_status,
                l_br_maturity_date,
                l_drawee_id,
                l_drawee_contact_id,
                l_drawee_site_use_id,
                l_drawee_bank_account_id,
                l_customer_trx_id,
                l_assigned_amount,
                p_receipt_method_id);

     END LOOP;

     CLOSE c_trx;

     -- second temporary table
     l_statement := 'SELECT customer_trx_id, SUM(amount_assigned) FROM '||
                    g_tmp_table_imm||
                    ' WHERE amount_assigned IS NOT NULL GROUP BY customer_trx_id';
     OPEN c_trx FOR l_statement;

     LOOP

        FETCH c_trx INTO l_customer_trx_id, l_assigned_amount;
        EXIT WHEN c_trx%NOTFOUND;

        -- Bug 1420183 Added p_receipt_method_id
        ARP_PROGRAM_GENERATE_BR.ar_br_insert_into_report_table(
                arp_global.request_id,
                p_batch_id,
                l_bill_id,
                NVL(l_bill_number,to_char(g_num_br_created)),
                l_br_amount,
                p_currency_code,
                l_batch_process_status,
                l_br_maturity_date,
                l_drawee_id,
                l_drawee_contact_id,
                l_drawee_site_use_id,
                l_drawee_bank_account_id,
                l_customer_trx_id,
                l_assigned_amount,
                p_receipt_method_id);
     END LOOP;
     CLOSE c_trx;

  END IF;

  -- the used payment schedules are deleted from the temporary tables
  l_delete_statement := 'DELETE FROM '||g_tmp_table_nimm||
                        ' WHERE amount_assigned IS NOT NULL';
  execute immediate l_delete_statement;

  -- bug 3930958 : insert assigned Immediate trx into AIMM table, this will prevent them from getting re-assigned
  -- into subsequent BRs created
  l_statement := 'INSERT INTO ' || g_tmp_table_aimm ||
                 ' SELECT payment_schedule_id from ' || g_tmp_table_imm||
                 ' WHERE amount_assigned IS NOT NULL';
  execute immediate l_statement;

  l_delete_statement := 'DELETE FROM '||g_tmp_table_imm||
                        ' WHERE amount_assigned IS NOT NULL';
  execute immediate l_delete_statement;

/* BUG 4006714 : Do not reset previously excluded transactions, doing so
   allows the code to exchange these transactions for a group rule that was
   already processed earlier, thus violating the grouping rule defined

  -- the excluded payment schedule are released; thus, they could use to create another bill receivable
  l_update_statement := 'UPDATE '||g_tmp_table_nimm||
                        ' SET exclude_flag = NULL WHERE exclude_flag IS NOT NULL';
  execute immediate l_update_statement;

  l_update_statement := 'UPDATE '||g_tmp_table_imm||
                        ' SET exclude_flag = NULL WHERE exclude_flag IS NOT NULL';
  execute immediate l_update_statement;
*/

END LOOP; /* process temporary table */

COMMIT;

IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
   program_debug(p_call,'ARP_PROGRAM_GENERATE_BR.create_BR (-)');
END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF p_call <> 3 OR PG_DEBUG in ('Y', 'C') THEN
      program_debug(p_call,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.create_BR >>>> ROLLBACK');
   END IF;
   ROLLBACK TO create_BR_SVP;

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   RAISE;

END create_BR;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |      AR_BR_INSERT_INTO_REPORT_TABLE                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Attila Rimai - 13/07/2000               |
 |                                                                           |
 +===========================================================================*/
PROCEDURE ar_br_insert_into_report_table(
                p_request_id                   IN RA_CUSTOMER_TRX.request_id%TYPE,
                p_batch_id                     IN  RA_BATCHES.batch_id%TYPE,
                p_br_customer_trx_id           IN  RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_bill_number                  IN  RA_CUSTOMER_TRX.trx_number%TYPE,
                p_br_amount                    IN  AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE,
                p_br_currency                  IN  RA_BATCHES.currency_code%TYPE,
                p_batch_status                 IN  RA_BATCHES.status%TYPE,
                p_maturity_date                IN  RA_BATCHES.maturity_date%TYPE,
                p_drawee_id                    IN  RA_CUSTOMER_TRX.drawee_id%TYPE,
                p_drawee_contact_id            IN  RA_CUSTOMER_TRX.drawee_contact_id%TYPE,
                p_drawee_site_use_id           IN  RA_CUSTOMER_TRX.drawee_site_use_id%TYPE,
                p_drawee_bank_account_id       IN  RA_CUSTOMER_TRX.drawee_bank_account_id%TYPE,
                p_transaction_id               IN  RA_CUSTOMER_TRX.customer_trx_id%TYPE,
                p_amount_assigned              IN  RA_CUSTOMER_TRX.br_amount%TYPE,
                p_receipt_method_id            IN  AR_RECEIPT_METHODS.receipt_method_id%TYPE)  IS

-- Bug 1420183
-- Could pass creation rule code, min/max amounts into this procedure as parameters, but since
-- we need to hit ar_receipt_methods to get lead days, we may as well get the other info there also
CURSOR c_get_receipt_method(l_receipt_method_id IN AR_RECEIPT_METHODS.receipt_method_id%TYPE) IS
SELECT name,
       receipt_creation_rule_code,
       br_min_acctd_amount,
       br_max_acctd_amount,
       lead_days
FROM   ar_receipt_methods
WHERE  receipt_method_id = l_receipt_method_id;

l_receipt_method_name         AR_RECEIPT_METHODS.name%TYPE;
l_receipt_creation_rule_code  AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE;
l_br_min_acctd_amount         AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE;
l_br_max_acctd_amount         AR_RECEIPT_METHODS.br_max_acctd_amount%TYPE;
l_lead_days                   AR_RECEIPT_METHODS.lead_days%TYPE;

BEGIN


OPEN  c_get_receipt_method(p_receipt_method_id);
FETCH c_get_receipt_method into l_receipt_method_name, l_receipt_creation_rule_code,
                                l_br_min_acctd_amount, l_br_max_acctd_amount,
                                l_lead_days;

IF (c_get_receipt_method%NOTFOUND) THEN
    null;
END IF;

CLOSE c_get_receipt_method;

--

INSERT INTO AR_BR_TRX_BATCH_RPT (   creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login ,
                                    request_id,
                                    batch_id,
                                    br_customer_trx_id,
                                    bill_number,
                                    br_amount,
                                    br_currency,
                                    batch_status,
                                    maturity_date,
                                    drawee_id,
                                    drawee_contact_id,
                                    drawee_site_use_id,
                                    drawee_bank_account_id,
                                    transaction_id,
                                    amount_assigned,
                                    receipt_method_name,
                                    receipt_creation_rule_code,
                                    br_min_acctd_amount,
                                    br_max_acctd_amount,
                                    lead_days)
                            VALUES
                                   (sysdate,                                            /* creation_date */
                                    fnd_global.user_id,                                 /* created_by */
                                    sysdate,                                            /* last_update_date */
                                    fnd_global.user_id,                                 /* last_updated_by */
                                    nvl(fnd_global.conc_login_id,fnd_global.login_id),  /* last_update_login */
                                    p_request_id,
                                    p_batch_id,
                                    p_br_customer_trx_id,
                                    p_bill_number,
                                    p_br_amount,
                                    p_br_currency,
                                    p_batch_status,
                                    p_maturity_date,
                                    p_drawee_id,
                                    p_drawee_contact_id,
                                    p_drawee_site_use_id,
                                    p_drawee_bank_account_id,
                                    p_transaction_id,
                                    p_amount_assigned,
                                    l_receipt_method_name,
                                    l_receipt_creation_rule_code,
                                    l_br_min_acctd_amount,
                                    l_br_max_acctd_amount,
                                    l_lead_days);


EXCEPTION WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION OTHERS: ARP_PROGRAM_GENERATE_BR.AR_BR_INSERT_INTO_REPORT_TABLE ');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   IF c_get_receipt_method%ISOPEN THEN
     CLOSE c_get_receipt_method;
   END IF;

END AR_BR_INSERT_INTO_REPORT_TABLE ;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    arbr_cr_tmp_table                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Attila Rimai - 13/07/2000               |
 | 25-MAY-05	VCRISOST	SSA - R12 : add org_id                       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE arbr_cr_tmp_table IS

compteur                NUMBER :=0;
l_suffixe     		VARCHAR2(100)  := NULL;

l_prefixe_nimm 		VARCHAR2(21)   := 'AR_BR_TMP_NIMM';
table_name_nimm		VARCHAR2(50);
nb_nimm			NUMBER;

l_prefixe_imm 		VARCHAR2(21)   := 'AR_BR_TMP_IMM';
table_name_imm		VARCHAR2(50);
nb_imm			NUMBER;

-- 3930958 : define another temp table containing IMM trx that have been assigned
l_prefixe_aimm          VARCHAR2(21)   := 'AR_BR_TMP_AIMM';
table_name_aimm         VARCHAR2(50);
nb_aimm                 NUMBER;

query_create		VARCHAR2(20000);

/* Bug 3441913/ 3432134 */
/* Developer Comments:

   1. The way temporary tables are created in the APPS schema is not correct.
      All tables must be created in AR product schema using ad_ddl package and
      should be reworked at a future date.

      The impact will be invasive, so I am not doing it in this bug.
   2. For now, the check for temporary tables will be done in the same schema as
      the schema from which the package is run (that's where the temp tables are
      getting created.
*/

l_user_schema		VARCHAR2(30) := USER;

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table (+)');

LOOP


  compteur := compteur + 1;
  SELECT to_char(sysdate,'YYYYMMDDHH24MISS') INTO l_suffixe FROM dual;

  table_name_nimm := l_prefixe_nimm||l_suffixe||to_char((compteur-1)*10);
  table_name_imm  := l_prefixe_imm ||l_suffixe||to_char((compteur-1)*10);
  table_name_aimm := l_prefixe_aimm ||l_suffixe||to_char((compteur-1)*10);

  /*
  FND_FILE.PUT_LINE(FND_FILE.LOG,'table_name_nimm = ' || table_name_nimm);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'table_name_imm = ' || table_name_imm);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'table_name_aimm = ' || table_name_aimm);
  */

/* Bug 3441913/3432134 - suffix dba_ views with owner */
/* Added owner predicate which ensure that comply with GSCC Standard - File.Sql.47 */

  BEGIN

	SELECT COUNT(object_name)
  	INTO   nb_nimm
  	FROM   sys.dba_objects
  	WHERE  object_name = table_name_nimm
  	AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_nimm := 0;

  END;

  BEGIN

  	SELECT COUNT(object_name)
  	INTO   nb_imm
  	FROM   sys.dba_objects
  	WHERE  object_name = table_name_imm
  	AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_imm := 0;

  END;

  BEGIN

        SELECT COUNT(object_name)
        INTO   nb_aimm
        FROM   sys.dba_objects
        WHERE  object_name = table_name_aimm
        AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_aimm := 0;

  END;

-- If the table names aren't stored in the table DBA_OJECTS, both temporary tables are created with these names
  IF (nb_nimm=0) AND (nb_imm = 0) AND (nb_aimm = 0) THEN

----------------------------------------------------------------------------------------
-- Creation of the temporary table for Transactions with a payment term of non immediate
----------------------------------------------------------------------------------------
      g_tmp_table_nimm := table_name_nimm;

      query_create := 'CREATE TABLE '|| table_name_nimm ||
                        ' (payment_schedule_id               	NUMBER(15),
			   customer_trx_id			NUMBER(15),
			   cust_trx_type_id			NUMBER(15),
			   customer_id				NUMBER(15),
			   customer_site_use_id			NUMBER(15),
			   trx_number				VARCHAR2(30),
                           due_date				DATE,
                           amount_due_remaining              	NUMBER,
			   amount_assigned			NUMBER,
                           exclude_flag                         VARCHAR2(1),
                           org_id                               NUMBER(15))';

--      FND_FILE.PUT_LINE(FND_FILE.LOG,'Creation of the temporary table '||table_name_nimm);
      execute immediate query_create;

      query_create := 'CREATE INDEX ' || 'ARBR_IND_NIMM' || l_suffixe || to_char((compteur-1)*10) || ' ON '
      || table_name_nimm || ' (customer_trx_id,amount_due_remaining)';
      execute immediate query_create;

-------------------------------------------------------------------------------------
-- Creation of the temporary table for Transactions with a payment term of Immediate
-------------------------------------------------------------------------------------
      g_tmp_table_imm := table_name_imm;

      query_create := 'CREATE TABLE '|| table_name_imm ||
                        ' (payment_schedule_id               	NUMBER(15),
			   customer_trx_id			NUMBER(15),
			   cust_trx_type_id			NUMBER(15),
			   customer_id				NUMBER(15),
			   customer_site_use_id			NUMBER(15),
			   trx_number				VARCHAR2(30),
                           due_date                             DATE,
                           amount_due_remaining              	NUMBER,
			   amount_assigned			NUMBER,
                           exclude_flag                         VARCHAR2(1),
                           org_id                               NUMBER(15))';

--      FND_FILE.PUT_LINE(FND_FILE.LOG,'Creation of the temporary table '||table_name_imm);
      execute immediate query_create;

      query_create := 'CREATE INDEX ' || 'ARBR_IND_IMM' || l_suffixe || to_char((compteur-1)*10) || ' ON ' ||
      table_name_imm || ' (customer_trx_id,amount_due_remaining)';

      execute immediate query_create;

------------------------------------------------------------------------------------------------------------------------
-- Creation of the temporary table for Transactions with a payment term of Immediate which have been assigned
------------------------------------------------------------------------------------------------------------------------
      g_tmp_table_aimm := table_name_aimm;

      query_create := 'CREATE TABLE '|| table_name_aimm ||
                        ' (payment_schedule_id                  NUMBER(15))';

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Creation of the temporary table '||table_name_aimm);
      execute immediate query_create;

      query_create := 'CREATE INDEX ' || 'ARBR_IND_AIMM' || l_suffixe || to_char((compteur-1)*10) || ' ON ' ||
      table_name_aimm || ' (payment_schedule_id)';

      execute immediate query_create;

      EXIT;

  END IF;

END LOOP;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table');
   RAISE;

END arbr_cr_tmp_table;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    drop_tmp_table                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 25/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE drop_tmp_table IS

nb_obj		number;
query_drop	varchar2(50) := NULL;

/* Bug 3441913/3432134 */
l_user_schema   VARCHAR2(30) := USER;


BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.drop_tmp_table (+)');

----------------------------------------------------------------------------------------
-- Drop of the temporary table for Transactions with a payment term of non immediate
----------------------------------------------------------------------------------------
/* Bug 3441913/3432134 - suffix dba_ views with owner */

/* Added owner predicate which ensure that comply with GSCC Standard - File.Sql.47 */

  BEGIN

  	SELECT COUNT(object_name)
  	INTO   nb_obj
  	FROM   sys.dba_objects
  	WHERE  object_name = g_tmp_table_nimm
  	AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_obj := 0;

  END;


IF (nb_obj > 0) THEN
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Drop of the temporary table '||g_tmp_table_nimm);
    query_drop := 'DROP table '||g_tmp_table_nimm;
    execute immediate query_drop;
END IF;

----------------------------------------------------------------------------------------
-- Drop of the temporary table for Transactions with a payment term of immediate
----------------------------------------------------------------------------------------
/* Bug 3441913/3432134 - suffix dba_ views with owner */

/* Added owner predicate which ensure that comply with GSCC Standard - File.Sql.47 */

  BEGIN

  	SELECT COUNT(object_name)
  	INTO   nb_obj
  	FROM   sys.dba_objects
  	WHERE  object_name = g_tmp_table_imm
  	AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_obj := 0;

  END;

IF (nb_obj > 0) THEN
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Drop of the temporary table '||g_tmp_table_imm);
    query_drop := 'DROP table '||g_tmp_table_imm;
    execute immediate query_drop;
END IF;

-----------------------------------------------------------------------------
-- 3930958 : Drop of the temporary table for Assigned Immediate Transactions
-----------------------------------------------------------------------------
  BEGIN

        SELECT COUNT(object_name)
        INTO   nb_obj
        FROM   sys.dba_objects
        WHERE  object_name = g_tmp_table_aimm
        AND    owner       = l_user_schema;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        nb_obj := 0;

  END;

IF (nb_obj > 0) THEN
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Drop of the temporary table '||g_tmp_table_aimm);
    query_drop := 'DROP table '||g_tmp_table_aimm;
    execute immediate query_drop;
END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'ARP_PROGRAM_GENERATE_BR.drop_tmp_table (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.drop_tmp_table');
   RAISE;

END drop_tmp_table;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    run_report_pvt                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable,           |
 |    to run the report 'Automatic Transaction Batch Report'                 |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 25/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE run_report_pvt(
	p_batch_id			IN	RA_BATCHES.batch_id%TYPE) IS

l_request_id		NUMBER;
l_version               VARCHAR2(30);
l_meaning               VARCHAR2(30);

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG,'run_report_pvt (+)');

SAVEPOINT run_report_SVP;

-- parameter p_batch_id mustn't be NULL
IF (p_batch_id IS NULL) THEN
   g_field := 'p_batch_id';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','run_report_pvt');
   FND_MESSAGE.set_token('PARAMETER', g_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter l_version must be 'D' for detail
SELECT LOOKUP_CODE, MEANING
INTO l_version, l_meaning
FROM AR_LOOKUPS
WHERE LOOKUP_TYPE = 'ARBRATBR_REPORT_TYPE'
AND   LOOKUP_CODE = 'D';

FND_FILE.PUT_LINE(FND_FILE.LOG,'------------- Automatic Transactions Batch Report Parameters ---------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'BATCH ID       :'||p_batch_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'VERSION        :'||l_meaning);
FND_FILE.PUT_LINE(FND_FILE.LOG,'API Request ID :'||arp_global.request_id);

-- SSA - R12 : set org id prior to calling submit_request
FND_REQUEST.set_org_id(g_org_id);
l_request_id := FND_REQUEST.submit_request('AR'
                                          ,'ARBRATBR'
                                          ,NULL
					  ,NULL
                                          ,NULL
                                          ,p_batch_id
                                          ,l_version
                                          ,arp_global.request_id);

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROGRAM_BR_REMIT.run_report_pvt');
    APP_EXCEPTION.raise_exception;
ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request : '||to_char(l_request_id));
END IF;

commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'----------------------------------------------------------------------------');

--FND_FILE.PUT_LINE(FND_FILE.LOG,'run_report_pvt (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.run_report_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO run_report_SVP;

END run_report_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    print_BR_pvt                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable,           |
 |    to handle the option Print BR                                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id   : remittance batch identifier                           |
 |                                                                           |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 25/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE print_BR_pvt(
	p_object_id			IN	RA_BATCHES.batch_id%TYPE,
        p_call                          IN      NUMBER,
        p_request_id			OUT NOCOPY 	NUMBER) IS

l_request_id		NUMBER;
l_format                VARCHAR2(30);

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG,'print_BR_pvt (+)');

SAVEPOINT print_BR_SVP;

-- parameter p_object_id mustn't be NULL
IF (p_object_id IS NULL) THEN
   g_field := 'p_object_id';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','print_BR_pvt');
   FND_MESSAGE.set_token('PARAMETER', g_field);
   APP_EXCEPTION.raise_exception;
END IF;


IF p_call <> 3 THEN
-- from the Batch window or SRS
   l_format := 'BR BATCH';
ELSE
-- from the transaction workbench
   l_format := 'IND';
END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------- ACTION Print Bills -----------------------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Program ARBRFMTW parameters');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BATCH OR TRX ID :'||p_object_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'SOB ID          :'||arp_global.set_of_books_id);

-- SSA - R12 : set org id prior to calling submit_request
FND_REQUEST.set_org_id(g_org_id);
l_request_id := FND_REQUEST.submit_request('AR'
                                         ,'ARBRFMTW'
                                         ,NULL
					 ,NULL
                                         ,NULL
                                         ,l_format
                                         ,p_object_id
                                         ,NULL
                                         ,NULL
                                         ,arp_global.set_of_books_id);

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROGRAM_BR_REMIT.print_BR_pvt');
    APP_EXCEPTION.raise_exception;
ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request : '||to_char(l_request_id));
END IF;

p_request_id := l_request_id;

--commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'----------------------------------------------------------------------------');

--FND_FILE.PUT_LINE(FND_FILE.LOG,'print_BR_pvt (-)');

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_GENERATE_BR.print_BR_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO print_BR_SVP;

END print_BR_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    auto_create_br_API                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  this procedure will create a BR given a customer_trx_id 		     |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 |           : OUT : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 10/08/2000           |
 |                                                                           |
 | 06-JUN-01	VCRISOST	Bug 1808976 : add customer_bank_account_id   |
 |				in c_receipt_method cursor		     |
 | 11-MAY-05    VCRISOST        LE-R12: retrieve le_id                       |
 |                                                                           |
 +===========================================================================*/
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
                p_nb_bill	             	OUT NOCOPY NUMBER) IS

l_api_name			CONSTANT varchar2(30) := 'auto_create_br_API';
l_api_version			CONSTANT number	      := 1.0;

-- bug 1808976 : add customer_bank_account_id

CURSOR c_receipt_method IS
  SELECT pm.receipt_method_id,
         pm.receipt_creation_rule_code,
         NVL(pm.lead_days,0),
         pm.maturity_date_rule_code,
         DECODE(pm.br_min_acctd_amount,NULL,0.00000001,0,0.00000001,pm.br_min_acctd_amount),
         NVL(pm.br_max_acctd_amount,9999999999999999999999999999999999),
         trx.invoice_currency_code,
 --        trx.customer_bank_account_id, Bug 5051673
	 trx.payment_trxn_extension_id,
         trx.legal_entity_id
  FROM   ar_receipt_methods pm,
         ra_customer_trx trx
  WHERE  trx.customer_trx_id = p_customer_trx_id
  AND    trx.receipt_method_id = pm.receipt_method_id;

c_grouping			cur_typ;
c_trx				cur_typ;

l_trx_select_statement  	VARCHAR2(3000) :=NULL;
l_suffixe_select_statement  	VARCHAR2(2000) :=NULL;
l_suffix_hz                     VARCHAR2(5000) :=NULL;
l_insert_statement		VARCHAR2(1000) :=NULL;
l_delete_statement		VARCHAR2(1000) :=NULL;

-- 1st break criteria
l_receipt_method_id		AR_RECEIPT_METHODS.receipt_method_id%TYPE;
l_receipt_creation_rule_code	AR_RECEIPT_METHODS.receipt_creation_rule_code%TYPE;
l_lead_days			AR_RECEIPT_METHODS.lead_days%TYPE;
l_maturity_date_rule_code	AR_RECEIPT_METHODS.maturity_date_rule_code%TYPE;
l_br_min_acctd_amount		AR_RECEIPT_METHODS.br_min_acctd_amount%TYPE;
l_br_max_acctd_amount		AR_RECEIPT_METHODS.br_max_acctd_amount%TYPE;
l_invoice_currency_code		RA_CUSTOMER_TRX.invoice_currency_code%TYPE;
l_le_id                         RA_CUSTOMER_TRX.legal_entity_id%TYPE;

-- bug 1808976 :
l_customer_bank_account_id      RA_CUSTOMER_TRX.customer_bank_account_id%TYPE;

l_payment_schedule_id		AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;
l_customer_trx_id		AR_PAYMENT_SCHEDULES.customer_trx_id%TYPE;
l_cust_trx_type_id		AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE;
l_customer_id			AR_PAYMENT_SCHEDULES.customer_id%TYPE;
p_customer_id                   AR_PAYMENT_SCHEDULES.customer_id%TYPE := NULL;
l_customer_site_use_id		AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
l_site_use_id			AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
l_trx_number			AR_PAYMENT_SCHEDULES.trx_number%TYPE;
l_due_date			AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_amount_due_remaining		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;

l_bill_id			RA_CUSTOMER_TRX.customer_trx_id%TYPE;
l_request_id			NUMBER;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_PROGRAM_GENERATE_BR.auto_create_br_API (+)');
END IF;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

-------------------------------------------------------------------------
-- Validations
-------------------------------------------------------------------------
IF p_customer_trx_id IS NULL THEN
   g_field := 'p_customer_trx_id';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','auto_create_br_API');
   FND_MESSAGE.set_token('PARAMETER', g_field);
   app_exception.raise_exception;
END IF;

/*Bug2290332: Reset Variable Storing No of BR Created */
g_num_br_created := 0;


-------------------------------------------------------------------------
-- the transaction payment method is retrieved
-------------------------------------------------------------------------
OPEN c_receipt_method;
FETCH c_receipt_method into l_receipt_method_id, l_receipt_creation_rule_code, l_lead_days,
                            l_maturity_date_rule_code, l_br_min_acctd_amount, l_br_max_acctd_amount,
                            l_invoice_currency_code, l_customer_bank_account_id, l_le_id;

IF (c_receipt_method%NOTFOUND) THEN
   FND_MESSAGE.set_name('AR','AR_BR_INVALID_TRANSACTION');
   FND_MESSAGE.set_token('TRX',p_customer_trx_id);
   APP_EXCEPTION.raise_exception;
END IF;

CLOSE c_receipt_method;

-- Temporary table Creation
ARP_PROGRAM_GENERATE_BR.arbr_cr_tmp_table;

-------------------------------------------------------------------------
-- Setup the transaction select statement
-------------------------------------------------------------------------
/* Bug 1744783 : for transactions with multiple payment schedule records,
   BR is only created for the first installment, replaced ps.customer_trx_id
   with ps.payment_schedule_id, also did a direct comparison between
   br_ref_payment_schedule_id = ps.payment_schedule, rather than comparing
   to is not null

   Bug 1849801 : the changes made for above bug have a typo, the NOT IN clause
   was using ps.payment_schedule rather than ps.payment_schedule_id,
   this was causing an ORA-904 error

   Bug2290332: Modified the sub-query. The sub-query now allows transactions to
   be picked if the BR created earlier against the transaction was cancelled.
   Also added additional condition to check if the payment schedule is open and
   to check that the transaction has not been reserved.
*/

l_suffixe_select_statement := ' FROM ar_payment_schedules ps,'||
                              '      ra_cust_trx_types type,'||
                              '      ra_customer_trx trx,'||
                              '      ar_receipt_methods pm '||
                              'WHERE ps.cust_trx_type_id      = type.cust_trx_type_id '||
                              'AND  (type.type IN (''INV'',''DEP'',''CB'') OR '||
                              '     (type.type IN (''CM'',''DM'') AND ps.term_id <> 5)) '||
                              'AND   ps.customer_trx_id       = NVL(:p_customer_trx_id,ps.customer_trx_id) '||
                              'AND   ps.payment_schedule_id NOT IN '||
                                       '(SELECT br_ref_payment_schedule_id '||
                                         ' from '||
                                         'ra_customer_trx_lines   br_lines, '||
                                         'ar_transaction_history  th '||
                                         'where br_lines.br_ref_payment_schedule_id = ps.payment_schedule_id '||
                                         'and   br_lines.customer_trx_id = th.customer_trx_id '||
	                          'and   th.current_record_flag   = ''Y'' '||
                                          'and   th.status <> ''CANCELLED'') '||
                              'AND   ps.reserved_type  IS NULL '||
                              'AND   ps.reserved_value IS NULL '||
                              'AND   ps.status =''OP'' ' ||
                              'AND   ps.customer_trx_id       = trx.customer_trx_id '||
                              'AND   trx.receipt_method_id    = pm.receipt_method_id ';

  -- bug 3922691
  ARP_PROGRAM_GENERATE_BR.construct_hz(l_receipt_creation_rule_code,
                                       p_customer_id,
                                       l_suffix_hz);

  l_suffixe_select_statement := l_suffixe_select_statement || l_suffix_hz;

IF l_receipt_creation_rule_code = 'PER_CUSTOMER' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.customer_id '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.customer_id ';
ELSIF l_receipt_creation_rule_code = 'PER_CUSTOMER_DUE_DATE' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.customer_id, ps.due_date '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.customer_id, ps.due_date ';
ELSIF l_receipt_creation_rule_code = 'PER_SITE' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.customer_site_use_id '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.customer_site_use_id ';
ELSIF l_receipt_creation_rule_code = 'PER_SITE_DUE_DATE' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.customer_site_use_id, ps.due_date '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.customer_site_use_id, ps.due_date ';
ELSIF l_receipt_creation_rule_code = 'PER_INVOICE' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.customer_trx_id '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.customer_trx_id ';
ELSIF l_receipt_creation_rule_code = 'PER_PAYMENT_SCHEDULE' THEN
   l_trx_select_statement := 'SELECT DISTINCT ps.payment_schedule_id '||
                             l_suffixe_select_statement||
                             ' ORDER BY ps.payment_schedule_id ';
ELSE
   FND_MESSAGE.set_name('AR','AR_BR_INVALID_GROUPING_RULE');
   FND_MESSAGE.set_token('GROUPING_RULE',l_receipt_creation_rule_code);
   APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('l_trx_select_statement = ' || l_trx_select_statement);
END IF;

--------------------------------------------------------------------------
---- FIRST LOOP
--------------------------------------------------------------------------
OPEN c_grouping FOR l_trx_select_statement
                using p_customer_trx_id, p_customer_id;

LOOP

     l_customer_id		:= NULL;
     l_due_date			:= NULL;
     l_site_use_id		:= NULL;
     l_customer_trx_id		:= NULL;
     l_payment_schedule_id	:= NULL;

     IF (l_receipt_creation_rule_code = 'PER_CUSTOMER') THEN
        FETCH c_grouping into l_customer_id;
     ELSIF (l_receipt_creation_rule_code = 'PER_CUSTOMER_DUE_DATE') THEN
        FETCH c_grouping into l_customer_id, l_due_date;
     ELSIF (l_receipt_creation_rule_code = 'PER_SITE') THEN
        FETCH c_grouping into l_site_use_id;
     ELSIF (l_receipt_creation_rule_code = 'PER_SITE_DUE_DATE') THEN
        FETCH c_grouping into l_site_use_id, l_due_date;
     ELSIF (l_receipt_creation_rule_code = 'PER_INVOICE') THEN
        FETCH c_grouping into l_customer_trx_id;
     ELSE
        FETCH c_grouping into l_payment_schedule_id;
     END IF;

     EXIT WHEN c_grouping%NOTFOUND;


     l_trx_select_statement := 'SELECT ps.payment_schedule_id,ps.customer_trx_id,ps.cust_trx_type_id,'||
                               'ps.customer_id,ps.customer_site_use_id,ps.trx_number,ps.due_date,ps.amount_due_remaining '||
                               l_suffixe_select_statement;

     l_trx_select_statement := l_trx_select_statement ||
                              'AND   ps.customer_id           = NVL(:p_customer_id,ps.customer_id) '||
                              'AND   ps.due_date              = NVL(:p_due_date,ps.due_date) '||
                              'AND   ps.customer_site_use_id  = NVL(:p_customer_site_use_id,ps.customer_site_use_id) '||
                              'AND   ps.payment_schedule_id   = NVL(:p_payment_schedule_id,ps.payment_schedule_id) ';


----------------------------------------------------------------------------------------------
---- SECOND LOOP - the bill receivable is created according to the transaction receipt method
----------------------------------------------------------------------------------------------
     l_delete_statement := 'DELETE FROM '|| g_tmp_table_nimm;
     execute immediate l_delete_statement;

     OPEN c_trx FOR l_trx_select_statement
                 using p_customer_trx_id, p_customer_id,
                       l_customer_id, l_due_date, l_site_use_id, l_payment_schedule_id;

     l_insert_statement := 'INSERT INTO '|| g_tmp_table_nimm ||
               '(payment_schedule_id,customer_trx_id,cust_trx_type_id,customer_id,'||
               'customer_site_use_id,trx_number,due_date,amount_due_remaining,amount_assigned,exclude_flag) '||
               'VALUES (:payment_schedule_id,:customer_trx_id,:cust_trx_type_id,:customer_id,'||
               ':customer_site_use_id,:trx_number,:due_date,:amount_due_remaining,NULL,NULL) ';


     LOOP

         FETCH c_trx into l_payment_schedule_id,
                          l_customer_trx_id,
                          l_cust_trx_type_id,
                          l_customer_id,
                          l_customer_site_use_id,
                          l_trx_number,
                          l_due_date,
                          l_amount_due_remaining;

         EXIT WHEN c_trx%NOTFOUND;


         execute immediate l_insert_statement
		USING l_payment_schedule_id,
                      l_customer_trx_id,
                      l_cust_trx_type_id,
                      l_customer_id,
                      l_customer_site_use_id,
                      l_trx_number,
                      l_due_date,
                      l_amount_due_remaining;

---- SECOND LOOP END
     END LOOP;
     CLOSE c_trx;


     -- create the bills receivable

     -- bug 1808976 : pass customer_bank_account_id to create_br
     ARP_PROGRAM_GENERATE_BR.create_BR(
		       'N',			-- p_draft_mode
                	3,			-- p_call
                        NULL,			-- p_batch_id
			l_receipt_method_id,
			l_receipt_creation_rule_code,
			l_maturity_date_rule_code,
			l_br_min_acctd_amount,
			l_br_max_acctd_amount,
			l_invoice_currency_code,
                        l_customer_bank_account_id,
                        l_le_id,
                        l_bill_id,
                        l_request_id);


---- FIRST LOOP END
END LOOP;
CLOSE c_grouping;

IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
END IF;


p_nb_bill	:= g_num_br_created;

IF g_num_br_created > 1 THEN
   p_bill_id	:= NULL;
   p_request_id := NULL;
ELSE
   p_bill_id	:= l_bill_id;
   p_request_id := l_request_id;
END IF;

/*Bug2290332*/
IF g_num_br_created = 0 THEN
   FND_MESSAGE.set_name('AR','AR_BR_NOT_VALID_CONDITION');
   APP_EXCEPTION.raise_exception;
END IF;

--Temporary table Drop
ARP_PROGRAM_GENERATE_BR.drop_tmp_table;

IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_PROGRAM_GENERATE_BR.auto_create_br_API (-)');
END IF;



EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR:ARP_PROGRAM_GENERATE_BR.auto_create_br_API ');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

   IF c_grouping%ISOPEN THEN
      CLOSE c_grouping;
   END IF;

   IF c_receipt_method%ISOPEN THEN
      CLOSE c_receipt_method;
   END IF;

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   ARP_PROGRAM_GENERATE_BR.drop_tmp_table;
   raise;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR: ARP_PROGRAM_GENERATE_BR.auto_create_br_API');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   IF c_grouping%ISOPEN THEN
      CLOSE c_grouping;
   END IF;

   IF c_receipt_method%ISOPEN THEN
      CLOSE c_receipt_method;
   END IF;

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   ARP_PROGRAM_GENERATE_BR.drop_tmp_table;
   raise;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION OTHERS: ARP_PROGRAM_GENERATE_BR.auto_create_br_API');
   END IF;

   IF c_grouping%ISOPEN THEN
      CLOSE c_grouping;
   END IF;

   IF c_receipt_method%ISOPEN THEN
      CLOSE c_receipt_method;
   END IF;

   IF c_trx%ISOPEN THEN
      CLOSE c_trx;
   END IF;

   ARP_PROGRAM_GENERATE_BR.drop_tmp_table;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   raise;

END auto_create_br_API;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      10 JAN 2001 John HALL           Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.20.12000000.3 $';
END revision;
--

BEGIN

select org_id
into g_org_id
from ar_system_parameters;


END ARP_PROGRAM_GENERATE_BR;

/

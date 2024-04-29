--------------------------------------------------------
--  DDL for Package CE_AUTO_BANK_CLEAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_AUTO_BANK_CLEAR" AUTHID CURRENT_USER AS
/* $Header: ceabrcrs.pls 120.5 2008/01/23 13:19:24 kbabu ship $ */
--
-- Global variables
--
G_exchange_date		CE_STATEMENT_LINES.exchange_rate_date%TYPE;
G_exchange_rate_type	CE_STATEMENT_LINES.exchange_rate_type%TYPE;
G_exchange_rate		CE_STATEMENT_LINES.exchange_rate%TYPE;
G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.5 $';

--
-- Variables required for determine manual clearing
--
yes_manual_clearing		NUMBER DEFAULT 0;
yes_reverse_mode		NUMBER DEFAULT 0;

--
-- Passed as parameters
--

G_org_id                        NUMBER;
G_legal_entity_id               NUMBER;

--
-- Functions/Procedures required form SQL functions
--
FUNCTION spec_revision RETURN VARCHAR2;
FUNCTION body_revision RETURN VARCHAR2;
PROCEDURE set_manual_clearing;
PROCEDURE unset_manual_clearing;
PROCEDURE set_reverse_mode;
PROCEDURE unset_reverse_mode;

FUNCTION get_manual_clearing RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES( get_manual_clearing, WNDS, WNPS );
FUNCTION get_reverse_mode RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES( get_reverse_mode, WNDS, WNPS );

PROCEDURE reconcile_process;
PROCEDURE update_line_status(X_statement_line_id	NUMBER,
			     X_status			VARCHAR2);

FUNCTION calculate_clearing_amounts RETURN BOOLEAN;

FUNCTION trx_remain(
		stmt_ln_list	VARCHAR2,
		trx_id_list	VARCHAR2) RETURN NUMBER;

PROCEDURE reconcile_stmt(passin_mode                    VARCHAR2,
                         tx_type                        VARCHAR2,
                         trx_id                         NUMBER,
                         trx_status                     VARCHAR2,
                         receipt_type                   VARCHAR2,
                         exchange_rate_type             VARCHAR2,
                         exchange_date                  DATE,
                         exchange_rate                  NUMBER,
                         amount_cleared                 NUMBER,
                         charges_amount                 NUMBER,
                         errors_amount                  NUMBER,
                         gl_date                        DATE,
			 value_date			DATE,
                         cleared_date                   DATE,
                         ar_cash_receipt_id             NUMBER,
                         X_bank_currency                VARCHAR2,
                         X_statement_line_id            IN OUT NOCOPY NUMBER,
                         X_statement_line_type          VARCHAR2,
                         reference_status               VARCHAR2,
                         trx_currency_type              VARCHAR2,
                         auto_reconciled_flag           VARCHAR2,
                         X_statement_header_id          IN OUT NOCOPY NUMBER,
                	 X_effective_date               DATE      DEFAULT NULL,
                	 X_float_handling_flag          VARCHAR2  DEFAULT NULL,
			 X_currency_code                VARCHAR2 default NULL,
                         X_bank_trx_number              VARCHAR2 default NULL,
                         X_reversed_receipt_flag        VARCHAR2);
PROCEDURE reconcile_trx(
                passin_mode                 	VARCHAR2,
                tx_type                     	VARCHAR2,
                trx_id                      	NUMBER,
                trx_status                  	VARCHAR2,
                receipt_type                	VARCHAR2,
                exchange_rate_type          	VARCHAR2,
                exchange_date               	DATE,
                exchange_rate               	NUMBER,
                amount_cleared              	NUMBER,
                charges_amount              	NUMBER,
                errors_amount               	NUMBER,
                gl_date                     	DATE,
		value_date			DATE,
		cleared_date			DATE,
		ar_cash_receipt_id	    	NUMBER,
                X_bank_currency            	VARCHAR2,
                X_statement_line_id	IN OUT NOCOPY  NUMBER,
		X_statement_line_type		VARCHAR2,
                reference_status         	VARCHAR2,
	        trx_currency_type	   	VARCHAR2,
                auto_reconciled_flag     	VARCHAR2,
                X_statement_header_id 	 IN OUT NOCOPY	NUMBER,
                X_statement_header_date         DATE 		DEFAULT NULL,
                X_bank_trx_number       	VARCHAR2 	DEFAULT NULL,
                X_currency_code         	VARCHAR2 	DEFAULT NULL,
                X_original_amount       	NUMBER 		DEFAULT NULL,
                X_effective_date		DATE		DEFAULT NULL,
                X_float_handling_flag		VARCHAR2	DEFAULT NULL,
                X_reversed_receipt_flag		VARCHAR2,
                X_org_id		       	NUMBER 		DEFAULT NULL,
                X_legal_entity_id       	NUMBER 		DEFAULT NULL);

PROCEDURE reconcile_pay_eft( passin_mode       	   	VARCHAR2,
                	 tx_type                        VARCHAR2,
                	 trx_count			NUMBER,
                	 trx_group	                VARCHAR2,
                	 cleared_trx_type               VARCHAR2,
			 cleared_date			DATE,
                	 X_bank_currency               	VARCHAR2,
                	 X_statement_line_id 	        NUMBER,
			 X_statement_line_type		VARCHAR2,
			 trx_currency_type		VARCHAR2,
                	 auto_reconciled_flag		VARCHAR2,
                	 X_statement_header_id          NUMBER,
                	 X_bank_trx_number              VARCHAR2,
                	 X_bank_account_id		NUMBER,
                         X_payroll_payment_format	VARCHAR2,
                	 X_effective_date		DATE,
                	 X_float_handling_flag		VARCHAR2);

PROCEDURE unclear_process (passin_mode           VARCHAR2,
		 X_header_or_line		 VARCHAR2,
                 tx_type                         VARCHAR2,
                 clearing_trx_type               VARCHAR2,
                 batch_id                        NUMBER,
                 trx_id                          NUMBER,
                 cash_receipt_id                 NUMBER,
                 trx_date                        DATE,
                 gl_date                         DATE,
                 cash_receipt_history_id         IN OUT NOCOPY  NUMBER,
                 stmt_line_id                    NUMBER,
                 status                          VARCHAR2,
		 cleared_date                    DATE,
                 transaction_amount              NUMBER,
                 error_amount                    NUMBER,
                 charge_amount                   NUMBER,
                 currency_code                   VARCHAR2,
                 xtype                           VARCHAR2,
                 xdate                           DATE,
                 xrate                           NUMBER,
                 org_id                          NUMBER,
                 legal_entity_id                 NUMBER);

PROCEDURE DM_reversals
		   ( cash_receipt_id                 NUMBER,
		     cc_id			     NUMBER,
		     cust_trx_type_id		     NUMBER,
		     cust_trx_type		     VARCHAR2,
                     gl_date                         DATE,
		     reversal_date		     DATE,
                     reason                          VARCHAR2,
                     category                        VARCHAR2,
                     module_name                     VARCHAR2,
                     comment                         VARCHAR2,
		     document_number		     NUMBER,
		     doc_sequence_id		     NUMBER);

PROCEDURE reversals( cash_receipt_id                 NUMBER,
                     gl_date                         DATE,
		     reason			     VARCHAR2,
		     category			     VARCHAR2,
                     module_name                     VARCHAR2,
                     comment                         VARCHAR2);

PROCEDURE reconcile_pbatch (passin_mode             	VARCHAR2,
                        pbatch_id               	NUMBER,
                        statement_line_id       IN OUT NOCOPY	NUMBER,
                        gl_date                 	DATE,
			value_date                      DATE,
			cleared_date			DATE,
                        amount_to_clear         	NUMBER,
                        errors_amount           	NUMBER,
                        charges_amount          	NUMBER,
			prorate_amount			NUMBER,
                        exchange_rate_type      	VARCHAR2,
                        exchange_rate_date      	DATE,
                        exchange_rate           	NUMBER,
	                trx_currency_type       	VARCHAR2,
                	X_statement_header_id   IN OUT NOCOPY 	NUMBER,
                	statement_header_date         	DATE 		DEFAULT NULL,
                	X_trx_type              	VARCHAR2 	DEFAULT NULL,
                	X_bank_trx_number       	VARCHAR2 	DEFAULT NULL,
                	X_currency_code         	VARCHAR2 	DEFAULT NULL,
                	X_original_amount       	NUMBER 		DEFAULT NULL,
                	X_effective_date		DATE		DEFAULT NULL,
                	X_float_handling_flag		VARCHAR2	DEFAULT NULL,
                	X_bank_currency_code         	VARCHAR2 	DEFAULT NULL,
			pgroup_id                       VARCHAR2 	DEFAULT NULL); -- FOR SEPA ER 6700007

PROCEDURE reconcile_rbatch(     passin_mode                     VARCHAR2,
                                rbatch_id                       NUMBER,
                                X_statement_line_id     IN OUT NOCOPY  NUMBER,
                                gl_date                         DATE,
				value_date			DATE,
                                bank_currency                   VARCHAR2,
                                exchange_rate_type              VARCHAR2,
                                exchange_rate                   NUMBER,
                                exchange_rate_date              DATE,
                                trx_currency_type               VARCHAR2,
                                module                          VARCHAR2,
                                X_trx_number            IN OUT NOCOPY  VARCHAR2,
                                X_trx_date                      DATE,
                                X_deposit_date                  DATE,
                                X_amount                        NUMBER,
                                X_foreign_diff_amt              NUMBER,
                                X_set_of_books_id               NUMBER,
                                X_misc_currency_code            VARCHAR2,
                                X_receipt_method_id             NUMBER,
                                X_bank_account_id               NUMBER,
                                X_activity_type_id              NUMBER,
                                X_comments                      VARCHAR2,
                                X_reference_type                VARCHAR2,
                                X_clear_currency_code           VARCHAR2,
                                X_tax_id                        NUMBER,
                                X_tax_rate			NUMBER,
                                X_cr_vat_tax_id                 VARCHAR2,
                                X_dr_vat_tax_id                 VARCHAR2,
                                X_trx_type                      VARCHAR2        DEFAULT NULL,
                                X_statement_header_id   IN OUT NOCOPY  NUMBER,
                                X_statement_date                DATE            DEFAULT NULL,
                                X_bank_trx_number               VARCHAR2        DEFAULT NULL,
                                X_statement_amount              NUMBER          DEFAULT NULL,
                                X_original_amount               NUMBER          DEFAULT NULL,
                		X_effective_date		DATE		DEFAULT NULL,
                		X_float_handling_flag		VARCHAR2	DEFAULT NULL);

PROCEDURE misc_receipt(
                X_passin_mode           VARCHAR2,
                X_trx_number            VARCHAR2,
                X_doc_sequence_value    VARCHAR2,
                X_doc_sequence_id       NUMBER,
                X_gl_date               DATE,
		X_value_date		DATE,
                X_trx_date              DATE,
                X_deposit_date          DATE,
                X_amount                NUMBER,
                X_bank_account_amount   NUMBER,
                X_set_of_books_id       NUMBER,
                X_misc_currency_code    VARCHAR2,
                X_exchange_rate_date    DATE,
                X_exchange_rate_type    VARCHAR2,
                X_exchange_rate         NUMBER,
                X_receipt_method_id     NUMBER,
                X_bank_account_id       NUMBER,
                X_activity_type_id      NUMBER,
                X_comments              VARCHAR2,
                X_reference_type        VARCHAR2,
                X_reference_id          NUMBER,
                X_clear_currency_code   VARCHAR2,
                X_statement_line_id     IN OUT NOCOPY NUMBER,
		X_tax_id		NUMBER,
                X_tax_rate		NUMBER,
		X_paid_from		VARCHAR2,
                X_module_name           VARCHAR2,
		X_cr_vat_tax_id		VARCHAR2,
		X_dr_vat_tax_id		VARCHAR2,
	        trx_currency_type       VARCHAR2,
                X_cr_id         IN OUT NOCOPY  NUMBER,
		X_effective_date	DATE,
		X_org_id		NUMBER );

END CE_AUTO_BANK_CLEAR;

/

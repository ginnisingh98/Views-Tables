--------------------------------------------------------
--  DDL for Package JL_BR_AR_GENERATE_DEBIT_MEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_GENERATE_DEBIT_MEMO" AUTHID CURRENT_USER AS
/*$Header: jlbrrdms.pls 120.9.12010000.4 2010/04/20 10:44:06 mkandula ship $*/

/*===========================================================================
  PACKAGE NAME:         JL_BR_INT_DEB_MEMO_SV

  DESCRIPTION:          This package contains the server side Line level
                        Application Program Interfaces (APIs).

  CLIENT/SERVER:        Server

  OWNER:                Ana Claudia Cardoso

  FUNCTION/PROCEDURE:   jl_br_interest_debit_memo()
			get_account()
			ins_ra_batches ()
			generate_interest_DM_number()
			ins_ra_customer_trx ()
			ins_ra_customer_trx_lines ()
			ins_ra_cust_trx_line_salesreps ()
			ins_ra_cust_trx_line_gl_dist ()
			ins_ar_payment_schedules ()

  12-MAR-2004      Included additional parameters as a part of Bug Fix
                   3493840....
  20-JUN-2005     New procedure sla_create_event (SLA KI - bug 4301543)
===========================================================================*/

PROCEDURE jl_br_interest_debit_memo (
  X_original_customer_trx_id	IN	NUMBER,
  X_invoice_amount		IN	NUMBER,
  X_user_id			IN	NUMBER,
  X_cust_trx_type_id		IN	NUMBER,
  X_batch_source_id		IN	NUMBER,
  X_receipt_method_id		IN	NUMBER,
  X_payment_schedule_id		IN	NUMBER,
  X_interest_date		IN	VARCHAR2,
  X_exit			OUT NOCOPY	VARCHAR2,
  x_int_revenue_ccid            IN      NUMBER,
  x_error_code                  OUT NOCOPY  NUMBER,
  X_error_msg                   OUT NOCOPY  VARCHAR2,
  x_token                       OUT NOCOPY  VARCHAR2
);

FUNCTION	get_account(
  X_account_type 	VARCHAR2,
  X_cust_trx_type_id	NUMBER,
  X_salesrep_id	NUMBER,
  x_int_revenue_ccid NUMBER,
  x_billto_site_use_id IN NUMBER,   	 -- Bug#7718063
  x_struct_num NUMBER,
  x_error_code  OUT NOCOPY NUMBER,
  x_error_msg   OUT NOCOPY VARCHAR2,
  x_token       OUT NOCOPY VARCHAR2
) RETURN NUMBER;

PROCEDURE ins_ra_batches (
  X_batch_source_id	IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_invoice_currency_code IN    VARCHAR2,
  X_user_id		IN	NUMBER,
  X_batch_id		IN OUT NOCOPY	NUMBER
);

FUNCTION generate_interest_DM_number(
  X_original_customer_trx_id	NUMBER,
  X_payment_schedule_id		NUMBER
) RETURN VARCHAR2;

PROCEDURE ins_ra_customer_trx (
  X_inv_cust_trx_id	IN	NUMBER,
  X_new_cust_trx_id 	IN OUT NOCOPY	NUMBER,
  X_set_of_books_id	IN OUT NOCOPY	NUMBER,
  X_lastlogin		IN OUT NOCOPY	NUMBER,
  X_primary_salesrep_id	IN OUT NOCOPY	NUMBER,
  X_billto_customer_id	IN OUT NOCOPY	NUMBER,
  X_billto_site_use_id	IN OUT NOCOPY	NUMBER,
  X_invoice_currencycode IN OUT NOCOPY	VARCHAR2,
  X_trx_number		IN OUT NOCOPY	VARCHAR2,
  X_termid		IN OUT NOCOPY	NUMBER,
  X_legal_entity_id IN OUT NOCOPY NUMBER, -- Bug#7835709
  X_cust_trx_type_id	IN	NUMBER,
  X_payment_schedule_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_batch_source_id	IN	NUMBER,
  X_receipt_method_id	IN	NUMBER,
  X_batch_id		IN	NUMBER,
  X_idm_date		IN	DATE
);

PROCEDURE ins_ra_customer_trx_lines (
  X_new_customer_trx_id	IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_set_of_books_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_customertrx_line_id	IN OUT NOCOPY	NUMBER
);

PROCEDURE ins_ra_cust_trx_line_salesreps (
  X_new_cust_trx_id	IN	NUMBER,
  X_new_cust_trx_line_id IN	NUMBER,
  X_salesrep_id		IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_invoice_amount	IN	NUMBER
);

PROCEDURE	ins_ra_cust_trx_line_gl_dist (
  X_customer_trx_id	IN	NUMBER,
  X_customer_trx_line_id IN OUT NOCOPY	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_set_of_books_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_batch_source_id	IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_cust_trx_type_id	IN	NUMBER,
  X_billto_site_use_id  IN      NUMBER,     -- Bug#7718063
  X_salesrep_id		IN	NUMBER,
  X_account_type	IN	VARCHAR,
  X_idm_date		IN	DATE,
  x_int_revenue_ccid    IN      NUMBER,
  X_invoice_currency_code IN    VARCHAR2,
  X_minimum_accountable_unit  IN NUMBER,
  X_precision           IN NUMBER,
  x_error_code          OUT NOCOPY NUMBER,
  X_error_msg           OUT NOCOPY VARCHAR2,
  x_token               OUT NOCOPY VARCHAR2
);

PROCEDURE ins_ar_payment_schedules (
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_invoice_currency_code IN	VARCHAR2,
  X_cust_trx_type_id	IN	NUMBER,
  X_customer_id		IN	NUMBER,
  X_customer_site_use_id IN	NUMBER,
  X_customer_trx_id	IN	NUMBER,
  X_term_id		IN	NUMBER,
  X_trx_number		IN	VARCHAR2,
  X_idm_date		IN	DATE
);

PROCEDURE sla_create_event (
  X_customer_trx_id	IN	NUMBER
);

FUNCTION validate_and_default_gl_date(
  x_receipt_date         IN  DATE,
  x_set_of_books_id      IN  NUMBER,
  x_application_id       IN  NUMBER,
  x_default_gl_date      OUT NOCOPY DATE,
  x_def_rule             OUT NOCOPY VARCHAR2,
  x_error_msg            OUT NOCOPY VARCHAR2) RETURN BOOLEAN ;


END jl_br_ar_generate_debit_memo;

/

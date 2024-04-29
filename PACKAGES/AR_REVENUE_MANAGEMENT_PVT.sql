--------------------------------------------------------
--  DDL for Package AR_REVENUE_MANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_REVENUE_MANAGEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXRVMGS.pls 120.23.12010000.3 2010/02/09 14:35:50 mraymond ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

  TYPE binary_int_table IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

  TYPE number_table IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

 TYPE long_number_table IS TABLE OF NUMBER
    INDEX BY VARCHAR2(100);

  TYPE varchar_table IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;

  TYPE date_table IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;

  TYPE desc_flexfield IS RECORD (
    attribute1  VARCHAR2(150) DEFAULT NULL,
    attribute2  VARCHAR2(150) DEFAULT NULL,
    attribute3  VARCHAR2(150) DEFAULT NULL,
    attribute4  VARCHAR2(150) DEFAULT NULL,
    attribute5  VARCHAR2(150) DEFAULT NULL,
    attribute6  VARCHAR2(150) DEFAULT NULL,
    attribute7  VARCHAR2(150) DEFAULT NULL,
    attribute8  VARCHAR2(150) DEFAULT NULL,
    attribute9  VARCHAR2(150) DEFAULT NULL,
    attribute10 VARCHAR2(150) DEFAULT NULL,
    attribute11 VARCHAR2(150) DEFAULT NULL,
    attribute12 VARCHAR2(150) DEFAULT NULL,
    attribute13 VARCHAR2(150) DEFAULT NULL,
    attribute14 VARCHAR2(150) DEFAULT NULL,
    attribute15 VARCHAR2(150) DEFAULT NULL,
    attribute_category VARCHAR2(30) DEFAULT NULL);
  --
  -- Constants
  --

  c_max_bulk_fetch_size       CONSTANT NUMBER := 1000;

  c_revenue_deferral_event    CONSTANT wf_events.name%TYPE :=
    'oracle.apps.ar.transaction.Invoice.noncollectible';

  c_rule_object_name          CONSTANT VARCHAR2(30) :=
    'AR_REVENUE_DEFERRAL_REASONS';

  c_receipt_application_mode  CONSTANT NUMBER := 1;
  c_receipt_reversal_mode     CONSTANT NUMBER := 2;

  c_manual_override_mode      CONSTANT NUMBER := 1;
  c_acceptance_obtained_mode  CONSTANT NUMBER := 2;
  c_update_reason_mode        CONSTANT NUMBER := 3;

  c_earn_revenue	      CONSTANT VARCHAR2(30) := 'EARN';
  c_unearn_revenue	      CONSTANT VARCHAR2(30) := 'UNEARN';

  not_analyzed	              CONSTANT NUMBER := 2;
  collect   		      CONSTANT NUMBER := 1;
  defer     		      CONSTANT NUMBER := 0;

  credit    	              CONSTANT NUMBER := 1;
  payment_term 	              CONSTANT NUMBER := 2;

  c_recognizable  	      CONSTANT NUMBER := 0;
  c_cash_based    	      CONSTANT NUMBER := 1;
  c_contingency_based	      CONSTANT NUMBER := 2;
  c_combination               CONSTANT NUMBER := 3;
  c_fully_credited            CONSTANT NUMBER := 9; -- 9320279

  c_not_recognized	      CONSTANT NUMBER := 0;
  c_partially_recognized      CONSTANT NUMBER := 1;
  c_fully_recognized	      CONSTANT NUMBER := 2;

  c_acceptance_allowed	      CONSTANT NUMBER := 1;
  c_transaction_not_monitored CONSTANT NUMBER := 2;
  c_acceptance_not_required   CONSTANT NUMBER := 3;

  c_revenue_management_source CONSTANT NUMBER := 1;

  c_yes 		      CONSTANT NUMBER := 0;
  c_no 		      	      CONSTANT NUMBER := 1;

  -- seeded contingencies
  c_pre_billing_acceptance  CONSTANT NUMBER := 1;
  c_explicit_acceptance     CONSTANT NUMBER := 2;
  c_customer_credit         CONSTANT NUMBER := 3;
  c_doubtful_collectibility CONSTANT NUMBER := 4;
  c_extended_payment_term   CONSTANT NUMBER := 5;
  c_delivery                CONSTANT NUMBER := 6;
  c_cancellation            CONSTANT NUMBER := 7;
  c_fiscal_funcing          CONSTANT NUMBER := 8;
  c_refund                  CONSTANT NUMBER := 9;
  c_forfeiture              CONSTANT NUMBER := 10;
  c_installation            CONSTANT NUMBER := 11;
  c_okl_collectibility      CONSTANT NUMBER := 12;
  c_impaird_loans           CONSTANT NUMBER := 13;

FUNCTION revenue_management_enabled
  RETURN BOOLEAN;

FUNCTION cash_based (p_customer_trx_id IN NUMBER)
  RETURN NUMBER;

FUNCTION acceptance_allowed (
  p_customer_trx_id 	 IN NUMBER,
  p_customer_trx_line_id IN NUMBER)
  RETURN NUMBER;

FUNCTION creditworthy (
  p_customer_account_id IN NUMBER,
  p_customer_site_use_id IN NUMBER)
  RETURN NUMBER;

FUNCTION line_collectible (
  p_customer_trx_id      NUMBER,
  p_customer_trx_line_id NUMBER DEFAULT NULL)
  RETURN NUMBER;

FUNCTION txn_collectible (p_customer_trx_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION line_collectibility (
  p_request_id  NUMBER,
  p_source      VARCHAR2 DEFAULT NULL,
  x_error_count OUT NOCOPY NUMBER,
  p_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%TYPE DEFAULT NULL)
  RETURN long_number_table;

FUNCTION line_collectibility(
  p_customer_trx_id 		NUMBER,
  p_customer_trx_line_id 	NUMBER)
  RETURN NUMBER;

PROCEDURE delete_failed_rows (p_request_id IN NUMBER);

PROCEDURE delete_rejected_rows (p_request_id IN NUMBER);

PROCEDURE periodic_sweeper (
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY VARCHAR2,
  p_org_id IN NUMBER);

PROCEDURE receipt_analyzer (
  p_mode 			IN  VARCHAR2 DEFAULT NULL,
  p_customer_trx_id 		IN  NUMBER   DEFAULT NULL,
  p_acctd_amount_applied        IN  NUMBER   DEFAULT NULL,
  p_exchange_rate		IN  NUMBER   DEFAULT NULL,
  p_invoice_currency_code       IN  VARCHAR2 DEFAULT NULL,
  p_tax_applied			IN  NUMBER   DEFAULT NULL,
  p_charges_applied		IN  NUMBER   DEFAULT NULL,
  p_freight_applied		IN  NUMBER   DEFAULT NULL,
  p_line_applied 		IN  NUMBER   DEFAULT NULL,
  p_receivable_application_id   IN  NUMBER   DEFAULT NULL,
  p_gl_date                     IN  DATE     DEFAULT NULL);

PROCEDURE receipt_analyzer (p_request_id IN NUMBER);

PROCEDURE revenue_synchronizer (
  p_mode 			IN  NUMBER    DEFAULT c_manual_override_mode,
  p_customer_trx_id 		IN  NUMBER,
  p_customer_trx_line_id 	IN  NUMBER,
  p_gl_date			IN  DATE      DEFAULT NULL,
  p_comments			IN  VARCHAR2  DEFAULT NULL,
  p_ram_desc_flexfield          IN  desc_flexfield,
  x_scenario 			OUT NOCOPY NUMBER,
  x_first_adjustment_number 	OUT NOCOPY NUMBER,
  x_last_adjustment_number 	OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2);

PROCEDURE process_event (
  p_cust_trx_line_id    IN  NUMBER,
  p_event_date		IN  DATE,
  p_event_code          IN  VARCHAR2);

PROCEDURE update_line_conts (
  p_customer_trx_line_id   NUMBER,
  p_contingency_id         NUMBER,
  p_expiration_date        DATE      DEFAULT NULL,
  p_expiration_event_date  DATE      DEFAULT NULL,
  p_expiration_days        NUMBER    DEFAULT NULL,
  p_completed_flag         VARCHAR2  DEFAULT NULL,
  p_reason_removal_date    DATE      DEFAULT NULL);


PROCEDURE delete_line_conts (
  p_customer_trx_line_id   NUMBER,
  p_contingency_id         NUMBER);

/* 5142216 - This function was defined as public so it could be used
   in sql within the package.  It is not intended for public use...
   although it technically poses no risk by its exposure */

FUNCTION get_line_id (p_so_line_id IN NUMBER) RETURN number;

END ar_revenue_management_pvt;

/

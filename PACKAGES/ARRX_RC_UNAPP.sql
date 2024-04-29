--------------------------------------------------------
--  DDL for Package ARRX_RC_UNAPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_RC_UNAPP" AUTHID CURRENT_USER AS
/* $Header: ARRXUNAS.pls 120.1 2005/10/30 04:45:57 appldev noship $      */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

type  var_t is record(
        request_id                      NUMBER,
        p_reporting_level               VARCHAR2(30),
        p_reporting_entity_id           NUMBER,
        p_sob_id                        NUMBER,
        p_coa_id                        NUMBER,
        p_co_seg_low                    VARCHAR2(25),
        p_co_seg_high                   VARCHAR2(25),
        p_gl_date_from                  DATE,
        p_gl_date_to                    DATE,
        p_entered_currency              VARCHAR2(15),
        p_batch_name_low                VARCHAR2(20),
        p_batch_name_high               VARCHAR2(20),
        p_batch_src_low                 VARCHAR2(50),
        p_batch_src_high                VARCHAR2(50),
        p_customer_name_low             VARCHAR2(50),
        p_customer_name_high            VARCHAR2(50),
        p_customer_number_low           VARCHAR2(30),
        p_customer_number_high          VARCHAR2(30),
        p_receipt_number_low            VARCHAR2(30),
        p_receipt_number_high           VARCHAR2(30),
        organization_name               VARCHAR2(50),
        functional_currency_code        VARCHAR2(15),
        cr_status                       VARCHAR2(40),
        crh_status                      VARCHAR2(40),
        batch_id                        NUMBER,
        batch_name                      VARCHAR2(20),
        cash_receipt_id                 NUMBER,
        receipt_number                  VARCHAR2(30),
        receipt_currency_code           VARCHAR2(15),
        exchange_rate                   NUMBER,
        exchange_date                   DATE,
        exchange_type                   VARCHAR2(30),
        doc_sequence_name               VARCHAR2(30),
        doc_sequence_value              NUMBER,
        deposit_date                    DATE,
        receipt_date                    DATE,
        receipt_status                  VARCHAR2(40),
        bank_name                       VARCHAR2(60),
        bank_name_alt                   VARCHAR2(320),
        bank_branch_name                VARCHAR2(60),
        bank_branch_name_alt            VARCHAR2(320),
        bank_number                     VARCHAR2(30),
        bank_branch_number              VARCHAR2(25),
        bank_account_name               VARCHAR2(80),
        bank_account_name_alt           VARCHAR2(320),
        bank_account_currency           VARCHAR2(15),
        receipt_method                  VARCHAR2(30),
        cash_receipt_history_id         NUMBER,
        gl_date                         DATE,
        receipt_amount                  NUMBER,
        receipt_history_status          VARCHAR2(40),
        acctd_receipt_amount            NUMBER,
        factor_discount_amount          NUMBER,
        acctd_factor_discount_amount    NUMBER,
        unapp_amount                    NUMBER,
        on_acc_amount                   NUMBER,
        claim_amount                    NUMBER,
        prepay_amount                   NUMBER,
        total_unresolved_amount         NUMBER,
        format_currency_code            VARCHAR2(15),
        account_code_combination_id     NUMBER,
        debit_balancing                 VARCHAR2(240),
        customer_id                     NUMBER,
        customer_name                   VARCHAR2(50),
        customer_name_alt               VARCHAR2(320),
        customer_number                 VARCHAR2(30),
        batch_source                    VARCHAR2(30),
        ca_sob_type                     VARCHAR2(1),
        ca_sob_id                       NUMBER
        );
var var_t;

/*========================================================================+
 | PUBLIC PROCEDURE AR_UNAPP_REG                                          |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |    This procedure is the inner procedure for the RXi report. It uses   |
 |    the appropriate fa_rx_util_pkg routines to bild the report          |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |     request_id      IN       Request id for the concurrent program     |
 |   and the other input parameters of the report                         |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 04-OCT-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE ar_unapp_reg(
          request_id             IN  NUMBER,
          p_reporting_level      IN  VARCHAR2,
          p_reporting_entity_id  IN  NUMBER,
          p_sob_id               IN  NUMBER,
          p_coa_id               IN  NUMBER,
          p_co_seg_low           IN  VARCHAR2,
          p_co_seg_high          IN  VARCHAR2,
          p_gl_date_from         IN  DATE,
          p_gl_date_to           IN  DATE,
          p_entered_currency     IN  VARCHAR2,
          p_batch_name_low       IN  VARCHAR2,
          p_batch_name_high      IN  VARCHAR2,
          p_batch_src_low        IN  VARCHAR2,
          p_batch_src_high       IN  VARCHAR2,
          p_customer_name_low    IN  VARCHAR2,
          p_customer_name_high   IN  VARCHAR2,
          p_customer_number_low  IN  VARCHAR2,
          p_customer_number_high IN  VARCHAR2,
          p_receipt_number_low   IN  VARCHAR2,
          p_receipt_number_high  IN  VARCHAR2,
          retcode                OUT NOCOPY NUMBER,
          errbuf                 OUT NOCOPY NUMBER);

/*=======================================================================+
 |  Define the Report Triggers                                           |
 +=======================================================================*/

PROCEDURE before_report;

PROCEDURE bind(c IN INTEGER);

PROCEDURE after_fetch;

END ARRX_RC_UNAPP;

 

/

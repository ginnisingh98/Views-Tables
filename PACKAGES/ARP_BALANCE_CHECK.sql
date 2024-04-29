--------------------------------------------------------
--  DDL for Package ARP_BALANCE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BALANCE_CHECK" AUTHID CURRENT_USER AS
/* $Header: ARBALCHS.pls 120.1.12010000.4 2009/12/22 18:42:22 vpusulur ship $ */

out_of_balance      EXCEPTION;
amount_mismatch     EXCEPTION;
P_ps_rec		  ar_payment_schedules%ROWTYPE;
P_ps_rec_pmt  ar_payment_schedules%ROWTYPE;
P_reg_cm        VARCHAR(2) default 'N';

TYPE unbalanced_receipt IS RECORD (
  	cash_receipt_id	NUMBER,
  	message_code    VARCHAR2(100)
);

TYPE unbalanced_receipts IS TABLE OF unbalanced_receipt
     	INDEX BY BINARY_INTEGER;

/* =======================================================================
 | PROCEDURE Check_Transaction_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for transactions
 |      and tallies that debits equal credits, if not then it sets a
 |      message on the message stack indicating that items are out of
 |      balance.
 |
 | PARAMETERS
 |      p_customer_trx_id       IN      Cash receipt id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_TRANSACTION_BALANCE(p_customer_trx_id IN VARCHAR2,
                                    p_called_from_api IN VARCHAR2 default 'N');

/* =======================================================================
 | PROCEDURE Check_Recp_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for receipts and
 |      adjustments including discounts and tallies that debits equal
 |      credits, if not then it sets a message on the message stack
 |      indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_cr_id                 IN      Cash receipt id
 |      p_request_id            IN      Request id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_RECP_BALANCE(
                  p_cr_id           IN  NUMBER,
                  p_request_id      IN  NUMBER,
                  p_called_from_api IN  VARCHAR2 default 'N');

/* =======================================================================
 | PROCEDURE Check_Recp_Balance_Bulk
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for receipts
 |      including discounts and tallies that debits equal credits, if
 |      not then it sets a message on the message stack indicating that
 |      items are out of balance.
 |
 | PARAMETERS
 |      p_cr_id_low             IN              Cash Receipt Id Low.
 |      p_cr_id_high            IN              Cash Receipt Id High.
 |      p_unbalanced_cr_tbl     OUT NOCOPY      Unbalanced CR Id's.
 * ======================================================================*/
PROCEDURE CHECK_RECP_BALANCE_BULK(
                  p_cr_id_low        IN  NUMBER,
                  p_cr_id_high       IN  NUMBER,
                  p_unbalanced_cr_tbl OUT NOCOPY unbalanced_receipts);

/* =======================================================================
 | PROCEDURE Check_Adj_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for adjustments
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_adj_id                IN      Adjustment id
 |      p_request_id            IN      Request id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_ADJ_BALANCE(
                  p_adj_id          IN  NUMBER,
                  p_request_id      IN  NUMBER,
                  p_called_from_api IN  VARCHAR2 default 'N');

/* =======================================================================
 | PROCEDURE Check_Appln_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for CM Applications
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_receivable_application_id    IN      Receivable Application ID
 |      p_request_id                   IN      Request id
 |      p_called_from_api              IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_APPLN_BALANCE(
                  p_receivable_application_id    IN  NUMBER,
                  p_request_id                   IN  NUMBER,
                  p_called_from_api              IN  VARCHAR2 default 'N');

/* =======================================================================
 | PROCEDURE Check_Appln_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for Receipt Applications
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_receivable_application_id1   IN      Receivable Application ID
 |      p_receivable_application_id2   IN      Receivable Application ID of the pair
 |      p_request_id                   IN      Request id
 |      p_called_from_api              IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_APPLN_BALANCE(
                  p_receivable_application_id1   IN  NUMBER,
                  p_receivable_application_id2   IN  NUMBER,
                  p_request_id                   IN  NUMBER,
                  p_called_from_api              IN  VARCHAR2 default 'N');
/* =======================================================================
 | PROCEDURE Check_Ps_Date
 |
 | DESCRIPTION
 |       This Procedure checks if the gl_date_closed and actual_date_closed
 |       are stamped correctly in ar_payment_schedules when the payment schedule
 |       is closed. It returns the correct values which can can then be sent to the
 |       Fix_Ps_Date procedure to correct the data corruption
 | PARAMETERS
 |      p_ps_id                 IN      Payment Schedule id
 |      p_corrupt_type          OUT     Corruption Type
 |      p_gl_date_closed        OUT     New Value for GL Closed Date
 |      p_actual_date_closed    OUT     New Value for Actual Closed Date
 * ======================================================================*/
PROCEDURE CHECK_PS_DATE(
                  p_ps_rec               IN  ar_payment_schedules%ROWTYPE,
                  p_corrupt_type         OUT NOCOPY VARCHAR2,
                  p_gl_date_closed       OUT NOCOPY DATE,
                  p_actual_date_closed   OUT NOCOPY DATE);

/* =======================================================================
 | PROCEDURE Fix_Ps_Date
 |
 | DESCRIPTION
 |        This procedure corrects the data for the fields gl_date_closed and actual_date_closed
 |        in ar_payment_schedules. The correct values need to be fetched from the procedure
 |        CHECK_PS_DATE
 |
 | PARAMETERS
 |      p_ps_id                 IN      Payment Schedule id
 |      p_corrupt_type          IN      Corruption Type
 |      p_gl_date_closed        IN      New Value for GL Closed Date
 |      p_actual_date_closed    IN      New Value for Actual Closed Date
 * ======================================================================*/
PROCEDURE FIX_PS_DATE(  p_ps_id                IN  NUMBER,
                        p_corrupt_type         IN VARCHAR2,
                        p_gl_date_closed       IN DATE,
                        p_actual_date_closed   IN DATE);

/* =======================================================================
 | PROCEDURE Check_Precision
 |
 | DESCRIPTION
 |    Check the precision of the amount passed with its functional currency
 |    precision. If precision do not match then return TRUE else FALSE.
 | PARAMETERS
 |      p_amount                IN      NUMBER
 * ======================================================================*/
FUNCTION Check_Precision(  p_amount     IN NUMBER )
			   RETURN BOOLEAN;

END ARP_BALANCE_CHECK;


/

--------------------------------------------------------
--  DDL for Package LNS_PAYOFF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_PAYOFF_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_PAYOFF_S.pls 120.0 2005/05/31 17:46:11 appldev noship $ */

/*========================================================================+
|  Declare PUBLIC Data Types and Variables
+========================================================================*/

/*========================================================================+
|  special rec_type for payoff
|  billed flag ='Y' for existing invoices;
|  billed flag = 'N' for invoices to be created
+========================================================================*/
  TYPE INVOICE_DETAILS_REC IS RECORD(CUST_TRX_ID         NUMBER
                                    ,PAYMENT_SCHEDULE_ID NUMBER
                                    ,INVOICE_NUMBER      VARCHAR2(60)
                                    ,INSTALLMENT_NUMBER  NUMBER
                                    ,TRANSACTION_TYPE    VARCHAR2(20) --change this to translated type
                                    ,REMAINING_AMOUNT    NUMBER
                                    ,DUE_DATE            DATE
                                    ,PURPOSE             VARCHAR2(30)
                                    ,BILLED_FLAG         VARCHAR2(1));

  TYPE INVOICE_DETAILS_TBL IS TABLE OF INVOICE_DETAILS_REC INDEX BY BINARY_INTEGER;

/*========================================================================+
|  special rec_types for processPayoff
+========================================================================*/
  TYPE CASH_RECEIPT_REC IS RECORD(CASH_RECEIPT_ID     NUMBER
                                 ,RECEIPT_AMOUNT      NUMBER
                                 ,RECEIPT_CURRENCY    VARCHAR2(10)
                                 ,EXCHANGE_RATE       NUMBER
                                 ,EXCHANGE_DATE       DATE
                                 ,EXCHANGE_RATE_TYPE  VARCHAR2(30)
                                 ,ORIGINAL_CURRENCY   VARCHAR2(10)
                                 ,RECEIPT_NUMBER      VARCHAR2(30));

  TYPE CASH_RECEIPT_TBL IS TABLE OF CASH_RECEIPT_REC INDEX BY BINARY_INTEGER;

  --TYPE CUSTOMER_TRX_ID IS RECORD(CUSTOMER_TRX_ID NUMBER);

  --TYPE CUSTOMER_TRX_TBL IS TABLE OF CUSTOMER_TRX_ID INDEX BY BINARY_INTEGER;

-- new payoffAPI
procedure processPayoff(p_api_version      IN NUMBER
                       ,p_init_msg_list    IN VARCHAR2
                       ,p_loan_id          in number
                       ,p_payoff_date      in date
                       ,p_cash_receipt_ids in LNS_PAYOFF_PUB.CASH_RECEIPT_TBL
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2);

procedure getLoanInvoices(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_loan_id        in number
                         ,p_payoff_date    in date
                         ,x_invoices_tbl   OUT NOCOPY LNS_PAYOFF_PUB.INVOICE_DETAILS_TBL
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE APPLY_RECEIPT(P_CASH_RECEIPT_ID         IN NUMBER
                       ,P_PAYMENT_SCHEDULE_ID     IN NUMBER
                       ,P_APPLY_AMOUNT            IN NUMBER
                       ,p_apply_date              in  DATE
                       ,p_apply_amount_from       IN  NUMBER
                       ,p_trans_to_receipt_rate   IN  NUMBER
                       ,x_return_status           OUT NOCOPY VARCHAR2
                       ,x_msg_count               OUT NOCOPY NUMBER
                       ,x_msg_data                OUT NOCOPY VARCHAR2);


-- This function returns the receipt balance amount in loan currency
FUNCTION getConvertedReceiptAmount(p_receipt_id in number, p_loan_id in number) return NUMBER;

END LNS_PAYOFF_PUB;

 

/

--------------------------------------------------------
--  DDL for Package LNS_BILLING_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_BILLING_BATCH_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_BILLING_S.pls 120.4.12010000.6 2010/03/17 14:01:41 scherkas ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    TYPE LOAN_TO_BILL_REC IS RECORD(
        LOAN_ID                     NUMBER,
        OBJECT_VERSION_NUMBER       NUMBER,
        LOAN_NUMBER                 VARCHAR2(60),
        LOAN_DESCRIPTION            VARCHAR2(250),
        FUNDED_AMOUNT               NUMBER,
        FIRST_PAYMENT_DATE          DATE,
        NEXT_PAYMENT_DUE_DATE       DATE,
        NEXT_PAYMENT_LATE_DATE      DATE,
        BILLED_FLAG                 VARCHAR2(1),
        LOAN_CURRENCY               VARCHAR2(15),
        CUST_ACCOUNT_ID             	NUMBER,
        BILL_TO_ADDRESS_ID          	NUMBER,
        LOAN_PAYMENT_FREQUENCY VARCHAR2(30),
        NUMBER_GRACE_DAYS           NUMBER,
        PAYMENT_APPLICATION_ORDER   VARCHAR2(30),
        CUSTOM_PAYMENTS_FLAG    VARCHAR2(1),
        LAST_PAYMENT_NUMBER       NUMBER,
        NEXT_PAYMENT_NUMBER      NUMBER,
        NEXT_PRINCIPAL_AMOUNT    NUMBER,
        NEXT_INTEREST_AMOUNT     NUMBER,
        NEXT_FEE_AMOUNT             	NUMBER,
        NEXT_AMORTIZATION_ID        NUMBER,
        RATE_ID                     		NUMBER,
        PARENT_AMORTIZATION_ID   NUMBER,
        EXCHANGE_RATE_TYPE        VARCHAR2(30),
        EXCHANGE_DATE               	DATE,
        EXCHANGE_RATE               	NUMBER,
        ORG_ID                      		NUMBER,
        LEGAL_ENTITY_ID             	NUMBER,
        CURRENT_PHASE               	VARCHAR2(30),
        FORGIVENESS_FLAG            	VARCHAR2(1),
        FORGIVENESS_PERCENT       NUMBER,
	    DISABLE_BILLING_FLAG	      	VARCHAR2(1)
    );
    TYPE LOANS_TO_BILL_TBL IS TABLE OF LOAN_TO_BILL_REC INDEX BY BINARY_INTEGER;

    TYPE LOAN_NEXT_DD_REC IS RECORD(
        LOAN_ID                     NUMBER,
        LOAN_NUMBER                 VARCHAR2(60),
        OBJECT_VERSION_NUMBER       NUMBER,
        NEXT_PAYMENT_NUMBER         NUMBER,
        CUSTOM_PAYMENTS_FLAG        VARCHAR2(1)
    );

    TYPE REVERSE_REC IS RECORD(
        TRX_NUMBER                  VARCHAR2(20),
        CUSTOMER_TRX_ID             NUMBER,
        PAYMENT_SCHEDULE_ID         NUMBER,
        CUSTOMER_TRX_LINE_ID        NUMBER,
        LINE_TYPE                   VARCHAR2(30),
        TRX_AMOUNT                  NUMBER,
        APPLIED_AMOUNT              NUMBER,
        ORG_ID                      NUMBER
    );
    TYPE REVERSE_TBL IS TABLE OF REVERSE_REC INDEX BY BINARY_INTEGER;

    TYPE BILL_HEADER_REC IS RECORD(
        HEADER_ID                   NUMBER,
        LOAN_ID                     NUMBER,
        ASSOC_PAYMENT_NUM           NUMBER,
        DUE_DATE                    DATE
    );
    TYPE BILL_HEADERS_TBL IS TABLE OF BILL_HEADER_REC INDEX BY BINARY_INTEGER;

    TYPE BILL_LINE_REC IS RECORD(
        HEADER_ID                   NUMBER,
        LINE_ID                     NUMBER,
        CUSTOMER_TRX_ID             NUMBER,
        PAYMENT_SCHEDULE_ID         NUMBER,
        CUSTOMER_TRX_LINE_ID        NUMBER,
        LINE_REF_ID                 NUMBER,
        LINE_AMOUNT                 NUMBER,
        LINE_TYPE                   VARCHAR2(30),
        LINE_DESC                   VARCHAR2(240),
        CASH_RECEIPT_ID             NUMBER,
        APPLY_AMOUNT                NUMBER,
        PAYMENT_ORDER               NUMBER,
        FEE_SCHEDULE_ID             NUMBER
    );
    TYPE BILL_LINES_TBL IS TABLE OF BILL_LINE_REC INDEX BY BINARY_INTEGER;

    TYPE INVOICE_DETAILS_REC IS RECORD(CUST_TRX_ID         NUMBER
                                        ,PAYMENT_SCHEDULE_ID NUMBER
                                        ,INVOICE_NUMBER      VARCHAR2(60)
                                        ,INSTALLMENT_NUMBER  NUMBER
                                        ,TRANSACTION_TYPE    VARCHAR2(20) --change this to translated type
                                        ,ORIGINAL_AMOUNT     NUMBER
                                        ,REMAINING_AMOUNT    NUMBER
                                        ,FORGIVENESS_AMOUNT  NUMBER
                                        ,DUE_DATE            DATE
                                        ,GL_DATE             DATE
                                        ,PURPOSE             VARCHAR2(30)
                                        ,BILLED_FLAG         VARCHAR2(1)
                                        ,INVOICE_CURRENCY    VARCHAR2(15)
                                        ,EXCHANGE_RATE       NUMBER);

    TYPE INVOICE_DETAILS_TBL IS TABLE OF INVOICE_DETAILS_REC INDEX BY BINARY_INTEGER;

    TYPE CASH_RECEIPT_REC IS RECORD(CASH_RECEIPT_ID     NUMBER
                                    ,RECEIPT_AMOUNT      NUMBER
                                    ,RECEIPT_CURRENCY    VARCHAR2(10)
                                    ,EXCHANGE_RATE       NUMBER
                                    ,EXCHANGE_DATE       DATE
                                    ,EXCHANGE_RATE_TYPE  VARCHAR2(30)
                                    ,ORIGINAL_CURRENCY   VARCHAR2(10)
                                    ,RECEIPT_NUMBER      VARCHAR2(30)
                                    ,APPLY_DATE          DATE
                                    ,GL_DATE             DATE);

    TYPE CASH_RECEIPT_TBL IS TABLE OF CASH_RECEIPT_REC INDEX BY BINARY_INTEGER;

    TYPE AMORTIZATION_SCHED_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/*========================================================================
 | PUBLIC PROCEDURE LNS_BILLING_CONCUR
 |
 | DESCRIPTION
 |      This procedure gets called from CM to start billing engine.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      BORROWER_ID         IN      Inputs borrower id
 |      LOAN_ID             IN      Inputs loan
 |      FROM_DAYS_TO_DD     IN      Inputs from days
 |      TO_DAYS_TO_DD       IN      Inputs to days
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_BILLING_CONCUR(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    BORROWER_ID         IN             NUMBER,
    LOAN_ID             IN             NUMBER,
    FROM_DAYS_TO_DD     IN             NUMBER,
    TO_DAYS_TO_DD       IN             NUMBER);


/*========================================================================
 | PUBLIC PROCEDURE LNS_RVRS_PMT_CONCUR
 |
 | DESCRIPTION
 |      This procedure gets called from CM to start reversal engine.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      LOAN_ID             IN      Inputs loan
 |      REBILL_FLAG         IN      Inputs rebill flag
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_RVRS_PMT_CONCUR(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    LOAN_ID             IN             NUMBER,
    REBILL_FLAG         IN             VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE LNS_ADJUST_RECEIV_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to adjust original receivables for a loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      LOAN_ID             IN      Inputs loan
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_ADJUST_RECEIV_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_ID             IN             NUMBER);



/*========================================================================
 | PUBLIC PROCEDURE BILL_LOANS
 |
 | DESCRIPTION
 |      This procedure searches for loans to bill and process them one by one.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_BORROWER_ID       IN          Inputs borrower id
 |      P_LOAN_ID           IN          Inputs loan id
 |      P_FROM_DAYS_TO_DD   IN          Inputs from days
 |      P_TO_DAYS_TO_DD     IN          Inputs to days
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE BILL_LOANS(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_BORROWER_ID       IN          NUMBER,
    P_LOAN_ID           IN          NUMBER,
    P_FROM_DAYS_TO_DD   IN          NUMBER,
    P_TO_DAYS_TO_DD     IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CALC_PAST_DUE_LOANS_NEXT_DD
 |
 | DESCRIPTION
 |      This procedure searches for overdue loans and recalc new due days.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CALC_PAST_DUE_LOANS_NEXT_DD(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE REVERSE_LAST_AMORTIZATION
 |
 | DESCRIPTION
 |      This procedure searches and reverses last loans amortization.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_LOAN_ID           IN          Inputs loan id
 |      P_REBILL_FLAG       IN          Inputs rebill flag
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REVERSE_LAST_AMORTIZATION(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_ID           IN          NUMBER,
    P_REBILL_FLAG       IN          VARCHAR2,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE CREDIT_AMORTIZATION_PARTIAL
 |
 | DESCRIPTION
 |      This procedure will credit a portion of the last amortization.
 |       The portion can be principal interest or fees
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION       IN          Standard in parameter
 |      P_INIT_MSG_LIST     IN          Standard in parameter
 |      P_COMMIT            IN          Standard in parameter
 |      P_VALIDATION_LEVEL  IN          Standard in parameter
 |      P_LOAN_ID           IN          Inputs loan id
 |      P_LINE_TYPE         IN          PRIN or INT or FEE
 |      X_RETURN_STATUS     OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT         OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA          OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-12-2004            raverma          Created
 |
 *=======================================================================*/
PROCEDURE CREDIT_AMORTIZATION_PARTIAL(P_API_VERSION       IN          NUMBER
                                     ,P_INIT_MSG_LIST     IN          VARCHAR2
                                     ,P_COMMIT            IN          VARCHAR2
                                     ,P_VALIDATION_LEVEL  IN          NUMBER
                                     ,P_LOAN_ID           IN          NUMBER
                                     ,P_LINE_TYPE         IN          VARCHAR2
                                     ,X_RETURN_STATUS     OUT NOCOPY  VARCHAR
                                     ,X_MSG_COUNT         OUT NOCOPY  NUMBER
                                     ,X_MSG_DATA          OUT NOCOPY  VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE CREATE_SINGLE_OFFCYCLE_BILL
 |
 | DESCRIPTION
 |      This procedure creates single manual bill.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_BILL_HEADER_REC   IN          Manual bill header record
 |      P_BILL_LINES_TBL    IN          Manual bill lines
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_SINGLE_OFFCYCLE_BILL(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_BILL_HEADER_REC       IN              LNS_BILLING_BATCH_PUB.BILL_HEADER_REC,
    P_BILL_LINES_TBL        IN              LNS_BILLING_BATCH_PUB.BILL_LINES_TBL,
    X_RETURN_STATUS		    OUT     NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT     NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT     NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CREATE_OFFCYCLE_BILLS
 |
 | DESCRIPTION
 |      This procedure creates multiple manual bills.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_BILL_HEADERS_TBL  IN          Manual bill headers
 |      P_BILL_LINES_TBL    IN          Manual bill lines
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_OFFCYCLE_BILLS(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_BILL_HEADERS_TBL      IN              LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL,
    P_BILL_LINES_TBL        IN              LNS_BILLING_BATCH_PUB.BILL_LINES_TBL,
    X_RETURN_STATUS		    OUT     NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT     NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT     NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE REVERSE_OFFCYCLE_BILL
 |
 | DESCRIPTION
 |      This procedure reverses a single manual bill.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_AMORTIZATION_ID   IN          Input amortization id to reverse
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REVERSE_OFFCYCLE_BILL(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_AMORTIZATION_ID   IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);




/*========================================================================
 | PUBLIC PROCEDURE ADJUST_ORIGINAL_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure adjusts loans original receivable in AR
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE ADJUST_ORIGINAL_RECEIVABLE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE PREBILL_SINGLE_LOAN
 |
 | DESCRIPTION
 |      This procedure prebill (do initial billing) for single loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-23-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE PREBILL_SINGLE_LOAN(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_BILLED_YN             OUT NOCOPY  VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE GENERATE_BILLING_STATEMENT_XML
 |
 | DESCRIPTION
 |      This procedure creates the billing statement xml for single loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN NUMBER
 |      P_AMORTIZATION_SCHEDULE_ID IN NUMBER
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-24-2004            karamach          Created
 | 05-04-2004            scherkas          Modified
 | 06-19-2004            karamach          Changed to use DBMS_XMLQUERY (8i pkg) instead of DBMS_XMLGEN (9i pkg)
 |					   to be compatible with the supported Oracle database version 8.1.7.4
 |					   and avoid 9i dependency
 |
 *=======================================================================*/
PROCEDURE GENERATE_BILLING_STATEMENT_XML(p_loan_id IN NUMBER,
                                         p_amortization_schedule_id IN NUMBER);


/*========================================================================
 | PUBLIC PROCEDURE PROCESS_PAID_LOANS
 |
 | DESCRIPTION
 |      This procedure sets still active paid off loans to status PAIDOFF
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_LOAN_ID           IN          Loan
 |      P_PAYOFF_DATE       IN          Pay off date
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter

 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_PAID_LOANS(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_ID           IN          NUMBER,
    P_PAYOFF_DATE       IN          DATE,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE GET_NEXT_INSTAL_TO_BILL
 |
 | DESCRIPTION
 |      This procedure returns next installment to be billed in LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL format
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_INVOICES_TBL          OUT NOCOPY  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-17-2009            scherkas          Created for bug
 |
 *=======================================================================*/
PROCEDURE GET_NEXT_INSTAL_TO_BILL(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_INVOICES_TBL          OUT NOCOPY  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE BILL_AND_PAY_NEXT_INSTAL
 |
 | DESCRIPTION
 |      This procedure bills and pays next scheduled installment
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-17-2009            scherkas          Created for bug
 |
 *=======================================================================*/
PROCEDURE BILL_AND_PAY_NEXT_INSTAL(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE PAY_INSTALLMENTS
 |
 | DESCRIPTION
 |      This procedure applies cash receipts to given installments
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_AM_SCHED_TBL          IN          LNS_BILLING_BATCH_PUB.AMORTIZATION_SCHED_TBL
 |      P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-17-2009            scherkas          Created for bug
 |
 *=======================================================================*/
PROCEDURE PAY_INSTALLMENTS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_AM_SCHED_TBL          IN          LNS_BILLING_BATCH_PUB.AMORTIZATION_SCHED_TBL,
    P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);




/*========================================================================
 | PUBLIC FUNCTION CAN_BILL_NEXT_INSTAL
 |
 | DESCRIPTION
 |      This function returns true/false is loan ready to bill next installment
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID               IN          Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-17-2009            scherkas          Created for bug
 |
 *=======================================================================*/
FUNCTION CAN_BILL_NEXT_INSTAL(P_LOAN_ID IN NUMBER) return BOOLEAN;



/*========================================================================
 | PUBLIC PROCEDURE GET_FORGIVENESS_AMOUNT
 |
 | DESCRIPTION
 |      This procedure returns forgiveness amount based on forgiveness settings and passed amount
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID               IN          Loan ID
 |      P_AMOUNT                IN          Passed amount
 |      X_FORGIVENESS_AMOUNT    OUT NOCOPY  Returned forgiveness amount
 |      X_REMAINING_AMOUNT      OUT NOCOPY  Returned remianing amount
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-27-2008            scherkas          Created for bug 8400747
 |
 *=======================================================================*/
PROCEDURE GET_FORGIVENESS_AMOUNT(
    P_LOAN_ID               IN          NUMBER,
    P_AMOUNT                IN          NUMBER,
    X_FORGIVENESS_AMOUNT    OUT NOCOPY  NUMBER,
    X_REMAINING_AMOUNT      OUT NOCOPY  NUMBER);



/*========================================================================
 | PUBLIC PROCEDURE GET_BILLED_INSTALLMENT
 |
 | DESCRIPTION
 |      This procedure returns already billed installment in LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL format
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_AM_SCHED_ID           IN          Amortization sched ID
 |      X_INVOICES_TBL          OUT NOCOPY  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-27-2009            scherkas          Created for bug 8468532
 |
 *=======================================================================*/
PROCEDURE GET_BILLED_INSTALLMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_AM_SCHED_ID           IN          NUMBER,
    X_INVOICES_TBL          OUT NOCOPY  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE BILL_AND_PAY_OFFCYCLE_BILLS
 |
 | DESCRIPTION
 |      This procedure bills and pays manual (offcycle) installment
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_BILL_HEADERS_TBL      IN          LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL,
 |      P_BILL_LINES_TBL        IN          LNS_BILLING_BATCH_PUB.BILL_LINES_TBL,
 |      P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-28-2009            scherkas          Created for bug
 |
 *=======================================================================*/
PROCEDURE BILL_AND_PAY_OFFCYCLE_BILLS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_BILL_HEADERS_TBL      IN          LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL,
    P_BILL_LINES_TBL        IN          LNS_BILLING_BATCH_PUB.BILL_LINES_TBL,
    P_CASH_RECEIPTS_TBL     IN          LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);

-- Bug#6830765
PROCEDURE BILL_SING_LOAN_SUBMIT_APPR_FEE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		    IN          NUMBER,
    P_LOAN_ID			    IN          NUMBER,
    X_BILLED_YN			    OUT NOCOPY  VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		    OUT NOCOPY  VARCHAR2);


/*========================================================================
 | PUBLIC FUNCTION IS_BILLING_DISABLED
 |
 | DESCRIPTION
 |      This function returns Y/N  is loan is ready to bill or not
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID               IN          Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Nov-2009           MBOLLI            Created for bug#9090782
 |
 *=======================================================================*/
FUNCTION IS_BILLING_DISABLED(P_LOAN_ID IN NUMBER) return VARCHAR2;


/*========================================================================
 | PUBLIC PROCEDURE ADJUST_ADD_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure adjusts loans additional receivable in AR
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_LINE_ID          IN          Loan Line ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-05-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE ADJUST_ADD_RECEIVABLE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_LINE_ID          IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



END LNS_BILLING_BATCH_PUB;

/

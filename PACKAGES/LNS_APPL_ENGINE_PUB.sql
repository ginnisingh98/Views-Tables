--------------------------------------------------------
--  DDL for Package LNS_APPL_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_APPL_ENGINE_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_APPL_ENG_S.pls 120.0.12010000.3 2010/03/10 16:18:56 scherkas ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    /* input types */
    TYPE SEARCH_REC IS RECORD(
        LOAN_BORROWER_ID        NUMBER,     -- optional
        LOAN_PRODUCT_ID         NUMBER,     -- optional
        LOAN_ID                 NUMBER,     -- optional
        RECEIPT_ID              NUMBER,     -- optional
	    RECEIPT_MATCH_CRITERIA  VARCHAR2(250), -- optional
        RC_FROM_DATE            VARCHAR2(20),       -- optional
        RC_TO_DATE              VARCHAR2(20),        -- optional
        UNAPPLY_FLAG            VARCHAR2(1) -- Hard coded as No
    );

    TYPE SEARCH_RECEIPTS_REC IS RECORD(
        LOAN_ID                 NUMBER,     -- mandatory
        RECEIPT_ID              NUMBER,     -- optional
	    RECEIPT_MATCH_CRITERIA  VARCHAR2(250), -- optional
        RC_FROM_DATE            VARCHAR2(20),       -- optional
        RC_TO_DATE              VARCHAR2(20)        -- optional
    );

    /* output types */
    TYPE RECEIPT_REC IS RECORD(
        RECEIPT_ID              NUMBER,
        RECEIPT_NUMBER          VARCHAR2(30),
        RECEIPT_DATE            DATE,
        PARTY_NAME              VARCHAR2(360),
        REMAINING_AMOUNT        NUMBER,
        RECEIPT_CURRENCY        VARCHAR(15)
    );
    TYPE RECEIPTS_TBL IS TABLE OF RECEIPT_REC INDEX BY BINARY_INTEGER;

    TYPE LOAN_INVOICE_REC IS RECORD(
        CUST_TRX_ID             NUMBER,
        PAYMENT_SCHEDULE_ID     NUMBER,
        TRX_NUMBER              VARCHAR2(30),
        LOAN_BORROWER_ID        NUMBER,
        BORROWER_NAME           VARCHAR2(360),
        LOAN_PRODUCT_ID         NUMBER,
        PRODUCT_NAME            VARCHAR2(80),
        LOAN_ID                 NUMBER,
        LOAN_NUMBER             VARCHAR2(60),
        AMORTIZATION_ID         NUMBER,
        PAYMENT_NUMBER          NUMBER,
        DUE_DATE                DATE,
        BILL_DATE               DATE,
        PHASE                   VARCHAR2(30),
        INVOICE_TYPE_CODE       VARCHAR2(30),
        INVOICE_TYPE_DESC       VARCHAR2(80),
        REMAINING_AMOUNT        NUMBER,
        INVOICE_CURRENCY        VARCHAR2(15),
        EXCHANGE_RATE           NUMBER
    );
    TYPE LOAN_INVOICES_TBL IS TABLE OF LOAN_INVOICE_REC INDEX BY BINARY_INTEGER;

    /* internal types */
    TYPE LOAN_REC IS RECORD(
        SEQUENCE_NUMBER         NUMBER,
        LOAN_ID                 NUMBER,
        LOAN_NUMBER             VARCHAR2(60),
        LOAN_BORROWER_ID        NUMBER,
        BORROWER_NAME           VARCHAR2(360),
        LOAN_PRODUCT_ID         NUMBER,
        PRODUCT_NAME            VARCHAR2(80),
        LOAN_CURRENCY           VARCHAR2(15)
    );

/*========================================================================
 | PUBLIC PROCEDURE SEARCH_RECEIPTS
 |
 | DESCRIPTION
 |      This procedure searches for receipts using passed search criteria record
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_SEARCH_RECEIPTS_REC       IN          Search record
 |      X_RECEIPTS_TBL              OUT NOCOPY  Receipts table
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_RECEIPTS(
    P_SEARCH_RECEIPTS_REC       IN          LNS_APPL_ENGINE_PUB.SEARCH_RECEIPTS_REC,
    X_RECEIPTS_TBL              OUT NOCOPY  LNS_APPL_ENGINE_PUB.RECEIPTS_TBL);



/*========================================================================
 | PUBLIC PROCEDURE SEARCH_LOAN_INVOICES
 |
 | DESCRIPTION
 |      This procedure searches for available loan invoices
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan
 |      X_LOAN_INVOICES_TBL         OUT NOCOPY  Table of loan invoices
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_LOAN_INVOICES(
    P_LOAN_ID                   IN          NUMBER,
    P_FOR_ACTION                IN          VARCHAR2,
    X_LOAN_INVOICES_TBL         OUT NOCOPY  LNS_APPL_ENGINE_PUB.LOAN_INVOICES_TBL);



/*========================================================================
 | PUBLIC PROCEDURE SEARCH_AND_APPLY
 |
 | DESCRIPTION
 |      This procedure applies receipts to loan invoices based on passed search criteria
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_SEARCH_REC        IN          Search record
 |      X_RETURN_STATUS		OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	OUT NOCOPY  Standard out parameter
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
 | 26-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_AND_APPLY(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_SEARCH_REC            IN          LNS_APPL_ENGINE_PUB.SEARCH_REC,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE LNS_APPL_RC_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to apply receipts to loan invoices
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      LOAN_BORROWER_ID    IN      Loan primary borrower id
 |      LOAN_PRODUCT_ID     IN      Loan product id
 |      LOAN_ID             IN      Loan id
 |      RECEIPT_ID          IN      Receipt id
 |      RC_FROM_DATE        IN      From receipt date
 |      RC_TO_DATE          IN      To receipt date
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
 | 24-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_APPL_RC_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_BORROWER_ID    IN             NUMBER,
        LOAN_PRODUCT_ID     IN             NUMBER,
        LOAN_ID             IN             NUMBER,
        RECEIPT_ID          IN             NUMBER,
	    RECEIPT_MATCH_CRITERIA IN         VARCHAR2,
        RC_FROM_DATE        IN             VARCHAR2,
        RC_TO_DATE          IN             VARCHAR2);



END LNS_APPL_ENGINE_PUB;

/

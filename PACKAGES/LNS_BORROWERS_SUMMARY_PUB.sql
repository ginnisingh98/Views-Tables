--------------------------------------------------------
--  DDL for Package LNS_BORROWERS_SUMMARY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_BORROWERS_SUMMARY_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_BORR_SUM_S.pls 120.1 2005/09/19 13:38:06 scherkas noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    TYPE BORROWER_REC IS RECORD(

        /*------------- Borrower Overview ---------------*/
        BORROWER_PARTY_ID               NUMBER,
        BORROWER_NAME                   VARCHAR2(360),
        TAX_PAYER_CODE                  VARCHAR2(50),
        CUSTOMER_CLASSIFICATION         VARCHAR2(100),
        INDUSTRIAL_CLASSIFICATION       VARCHAR2(100),
        YEAR_ESTABLISHED                NUMBER,
        COUNTRY                         VARCHAR2(60),
        ADDRESS1                        VARCHAR2(240),
        ADDRESS2                        VARCHAR2(240),
        ADDRESS3                        VARCHAR2(240),
        ADDRESS4                        VARCHAR2(240),
        CITY                            VARCHAR2(60),
        POSTAL_CODE                     VARCHAR2(60),
        STATE                           VARCHAR2(60),
        PRIMARY_CONTACT_NAME            VARCHAR2(360),
        PRIMARY_PHONE_COUNTRY_CODE      VARCHAR2(10),
        PRIMARY_PHONE_AREA_CODE         VARCHAR2(10),
        PRIMARY_PHONE_NUMBER            VARCHAR2(40),
        PRIMARY_PHONE_EXTENSION         VARCHAR2(20),
        ANNUAL_REVENUE                  NUMBER,
        CUSTOMER_SINCE                  DATE,

        /*------------- Loans Summary -----------------*/
        NUM_ACTIVE_LOANS                NUMBER,
        TOTAL_REMAINING_PRINCIPAL       NUMBER,
        TOTAL_PRINCIPAL_PAID_YTD        NUMBER,
        TOTAL_INTEREST_PAID_YTD         NUMBER,
        TOTAL_FEE_PAID_YTD              NUMBER,
        TOTAL_REQUESTED_LOAN_AMOUNT     NUMBER,
        TOTAL_APPROVED_LOAN_AMOUNT      NUMBER,
        PLEDGED_COLL_AMOUNT             NUMBER,
        LAST_COLL_VALUATION_DATE        DATE,
        ORG_ID                          NUMBER,
        ORG_NAME                        VARCHAR2(240),
        LEGAL_ENTITY_ID                 NUMBER,
        LEGAL_ENTITY_NAME               VARCHAR2(240),
        FUNCTIONAL_CURRENCY             VARCHAR2(15),

        /*------------- Credit Summary -----------------*/
        CREDIT_CLASSIFICATION           VARCHAR2(30),
        REVIEW_CYCLE                    VARCHAR2(30),
        LAST_CREDIT_REVIEW_DATE         DATE,
        CREDIT_RATING                   VARCHAR2(30),
        CREDIT_HOLD                     VARCHAR2(1),
        CREDIT_CHECKING                 VARCHAR2(1),
        TOLERANCE                       NUMBER
    );

    TYPE BORROWER_TBL IS TABLE OF BORROWER_REC INDEX BY BINARY_INTEGER;


/*========================================================================
 | PUBLIC PROCEDURE LNS_BORR_SUM_CONCUR
 |
 | DESCRIPTION
 |      This procedure gets called from CM to start borrower summary generation program.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      BORROWER_PARTY_ID   IN      Inputs borrower party id
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
PROCEDURE LNS_BORR_SUM_CONCUR(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    BORROWER_PARTY_ID   IN             NUMBER);




/*========================================================================
 | PUBLIC PROCEDURE GENERATE_BORROWERS_SUMMARY
 |
 | DESCRIPTION
 |      This procedure generates summary info for all available borrowers
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_BORROWER_PARTY_ID IN          Inputs borrower party id
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
 | 04-14-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE GENERATE_BORROWERS_SUMMARY(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_BORROWER_PARTY_ID IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);


END LNS_BORROWERS_SUMMARY_PUB;

 

/

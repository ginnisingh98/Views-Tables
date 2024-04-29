--------------------------------------------------------
--  DDL for Package LNS_REP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_REP_UTILS" AUTHID CURRENT_USER as
/* $Header: LNS_REP_UTILS_S.pls 120.3.12010000.6 2010/04/15 12:39:43 scherkas ship $ */
/*=======================================================================+
 |  Package Global Constants
  +=======================================================================*/

   g_loan_start_date_from DATE;
   g_loan_start_date_to   DATE;
   g_bill_due_date_from   DATE;
   g_bill_due_date_to     DATE;

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
/*========================================================================+
 Function which returns the global variable g_loan_start_date_from
  ========================================================================*/

  FUNCTION get_loan_start_date_from return DATE;

/*========================================================================+
 Function which returns the global variable g_loan_start_date_to
   ========================================================================*/

  FUNCTION get_loan_start_date_to return DATE;
/*========================================================================+
 Function which returns the global variable g_bill_due_date_from
  ========================================================================*/

  FUNCTION get_bill_due_date_from return DATE;

/*========================================================================+
 Function which returns the global variable g_bill_due_date_to
   ========================================================================*/

  FUNCTION get_bill_due_date_to return DATE;
 /*========================================================================
 | PUBLIC PROCEDURE PRINT_CLOB
 |
 | DESCRIPTION
 |      This process selects the process to run.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_PARAM1                    IN          Standard in parameter
 |      X_PARAM2                    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 | 07-Mar-2005           GBELLARY          Added procedures and functions for
 |                                         Loan Reconciliation Report.
 | 08-Mar-2005           GBELLARY          Changed order of parameters
 |                                         in PROCESS_RECON_REPORT.
 | 23-Aug-2005           GBELLARY          Changed/ added  parameters
 |                                         in PROCESS_RECON_REPORT
 |                                         and PROCESS_PORTFOLIO_REPORT
 |
 *=======================================================================*/
PROCEDURE PRINT_CLOB (   lob_loc                in  clob);
PROCEDURE PROCESS_PORTFOLIO_REPORT(ERRBUF                  OUT NOCOPY VARCHAR2
                                  ,RETCODE                 OUT NOCOPY VARCHAR2
                                  ,LOAN_CLASS              IN         VARCHAR2
                                  ,LOAN_TYPE_ID            IN         NUMBER
                                  ,CURRENCY_CODE           IN         VARCHAR2
                                  ,LOAN_NUMBER             IN         VARCHAR2
                                  ,BORROWER_ID             IN         NUMBER
                                  ,CUST_ACCOUNT_ID         IN         NUMBER
                                  ,LOAN_START_DATE_FROM    IN         VARCHAR2
                                  ,LOAN_START_DATE_TO      IN         VARCHAR2
                                  ,LEGAL_ENTITY_ID         IN         NUMBER
                                  ,PRODUCT_ID              IN         NUMBER
                                  ,LOAN_ASSIGNED_TO        IN         NUMBER
                                  ,LOAN_STATUS1            IN         VARCHAR2
                                  ,LOAN_STATUS2            IN         VARCHAR2
                                  ,INCLUDE_CHARTS          IN         VARCHAR2
                                  );
PROCEDURE PROCESS_RECON_REPORT(ERRBUF                  OUT NOCOPY VARCHAR2
                                  ,RETCODE                 OUT NOCOPY VARCHAR2
                                  ,LOAN_CLASS              IN         VARCHAR2
                                  ,LOAN_TYPE_ID            IN         NUMBER
                                  ,CURRENCY_CODE           IN         VARCHAR2
                                  ,BILL_DUE_DATE_FROM      IN         VARCHAR2
                                  ,BILL_DUE_DATE_TO        IN         VARCHAR2
                                  ,LEGAL_ENTITY_ID         IN         NUMBER
                                  ,LOAN_NUMBER             IN         VARCHAR2
                                  ,BORROWER_ID             IN         NUMBER
                                  ,CUST_ACCOUNT_ID         IN         NUMBER
                                  ,LOAN_ASSIGNED_TO        IN         NUMBER
                                  );
 /*========================================================================
 | PUBLIC PROCEDURE PRINT_CLOB
 |
 | DESCRIPTION
 |      This process selects the process to run.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_PARAM1                    IN          Standard in parameter
 |      X_PARAM2                    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                 Author     Description of Changes
 | 13-JUL-2007		MBOLLI	   Bug#6169438 - New Parameter 'P_GENERATE_AGREEMENT', which
 |				   implies the loan agreement must be regenereated if the value is 'Y'.
 | 22-MAY-2009		GPARUCHU   Bug#8428048 - New parameter P_REASON added to denote the reason for generating
 |				   a new agreement report.
 *=======================================================================*/
PROCEDURE PROCESS_AGREEMENT_REPORT(ERRBUF                  OUT NOCOPY VARCHAR2
                                  ,RETCODE                 OUT NOCOPY VARCHAR2
                                  ,LOAN_ID                 IN         NUMBER
                                  ,P_GENERATE_AGREEMENT    IN         VARCHAR2 DEFAULT 'N'
				  ,P_REASON                IN         VARCHAR2 DEFAULT NULL
				  );
PROCEDURE STORE_LOAN_AGREEMENT    (P_LOAN_ID               IN         NUMBER
				  ,P_AGREEMENT_REASON      IN         VARCHAR2 DEFAULT NULL
				  );

PROCEDURE LNS_TRANSFER_LOANS_CONCUR(ERRBUF                 OUT NOCOPY VARCHAR2
                                   ,RETCODE                OUT NOCOPY VARCHAR2
                                   ,P_FROM_LOAN_OFFICER    IN         NUMBER
                                   ,P_TO_LOAN_OFFICER      IN         NUMBER
                                   );

FUNCTION REPLACE_SPECIAL_CHARS    (P_XML_DATA		   IN	      VARCHAR2)
				  RETURN VARCHAR2;

PROCEDURE STORE_LOAN_AGREEMENT_CP (P_LOAN_ID                 IN         NUMBER
				                  ,P_AGREEMENT_REASON        IN         VARCHAR2);

END LNS_REP_UTILS;

/

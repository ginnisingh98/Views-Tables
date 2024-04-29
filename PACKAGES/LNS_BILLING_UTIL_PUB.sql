--------------------------------------------------------
--  DDL for Package LNS_BILLING_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_BILLING_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_BILL_UTIL_S.pls 120.3.12010000.6 2010/03/17 13:12:02 scherkas ship $ */


/*========================================================================
 | PUBLIC FUNCTION AMOUNT_PAID_YTD
 |
 | DESCRIPTION
 |      This procedure calculates next payment due.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
FUNCTION AMOUNT_PAID_YTD(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION NEXT_PAYMENT_DUE
 |
 | DESCRIPTION
 |      This procedure calculates amount paid YTD.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN            Last payment number for Loan ID
 |      P_LINE_TYPE             Amount due for this line type
 |      P_PAYMENT_NUMBER        Amount due for this payment number
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
FUNCTION NEXT_PAYMENT_DUE(P_LOAN_ID IN NUMBER, P_LINE_TYPE IN VARCHAR2, P_PAYMENT_NUMBER IN NUMBER) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION AMOUNT_PAID_LAST_YEAR
 |
 | DESCRIPTION
 |      This procedure calculates principal paid last year.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
FUNCTION AMOUNT_PAID_LAST_YEAR(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure calculates last payment number.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
FUNCTION LAST_PAYMENT_NUMBER(P_LOAN_ID IN NUMBER) RETURN NUMBER;




/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure calculates last payment number.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
 |      P_PHASE   IN    Phase
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
FUNCTION LAST_PAYMENT_NUMBER(P_LOAN_ID IN NUMBER, P_PHASE IN VARCHAR2) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER_EXT
 |
 | DESCRIPTION
 |      This procedure calculates last payment number taking in consideration 0-th installment.
 |      If any installment is billed ('0'/'1'/'2'/.....) then it returns the installment ELSE
 |	it returns '-1'.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-12-2003            scherkas          Created
 | 18-Aug-2009		 Mbolli		   Bug#6830765 - Modified with old functionality
 |
 *=======================================================================*/
FUNCTION LAST_PAYMENT_NUMBER_EXT(P_LOAN_ID IN NUMBER) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER_EXT_1
 |
 | DESCRIPTION
 |      This procedure calculates last payment number taking in consideration 0-th installment.
 |      If any installment is billed ('0'/'1'/'2'/.....) then it returns the installment ELSE
 |      if any '0th' installments are scheduled(On Activation/On SubmitFor Approval Fees)
 |		then returns '0'  ELSE '-1'
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Aug-2009		 Mbolli		   Bug#6830765 - Created
 |
 *=======================================================================*/
FUNCTION LAST_PAYMENT_NUMBER_EXT_1(P_LOAN_ID IN NUMBER) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER_EXT_2
 |
 | DESCRIPTION
 |      This procedure calculates last payment number and it doesn't consdier '0th' installments
 |	and it returns '-1'.
 |      We created this to use for PREBILL_SINGLE_LOAN in LNS_BILLING_BATCH_PUB package
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Aug-2009		 Mbolli		Created
 |
 *=======================================================================*/
FUNCTION LAST_PAYMENT_NUMBER_EXT_2(P_LOAN_ID IN NUMBER) RETURN NUMBER;

FUNCTION LAST_PAYMENT_NUMBER_EXT_3(P_LOAN_ID IN NUMBER, P_PHASE IN VARCHAR2) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION LAST_AMORTIZATION_SCHED
 |
 | DESCRIPTION
 |      This procedure returns last amortization schedule id.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
FUNCTION LAST_AMORTIZATION_SCHED(P_LOAN_ID IN NUMBER) RETURN NUMBER;




/*========================================================================
 | PUBLIC FUNCTION AMOUNT_OVERDUE
 |
 | DESCRIPTION
 |      This procedure calculates amount overdue.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
FUNCTION AMOUNT_OVERDUE(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION NUMBER_OVERDUE_BILLS
 |
 | DESCRIPTION
 |      This procedure calculates number of overdue bills.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
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
FUNCTION NUMBER_OVERDUE_BILLS(P_LOAN_ID IN NUMBER) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION LAST_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure gets last overdue date.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Loan ID
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
FUNCTION LAST_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE;



/*========================================================================
 | PUBLIC FUNCTION OLDEST_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure gets oldest overdue date.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Loan ID
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
FUNCTION OLDEST_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_AMOUNT
 |
 | DESCRIPTION
 |      This procedure gets last payment amount.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount for Loan ID
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
FUNCTION LAST_PAYMENT_AMOUNT(P_LOAN_ID IN NUMBER) RETURN NUMBER;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_DATE
 |
 | DESCRIPTION
 |      This procedure gets last payment date.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount for Loan ID
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
FUNCTION LAST_PAYMENT_DATE(P_LOAN_ID IN NUMBER) RETURN DATE;



/*========================================================================
 | PUBLIC FUNCTION BALANCE_BY_ACT_DATE
 |
 | DESCRIPTION
 |      This procedure returns loan balance by date.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Loan ID
 |      P_DATE              IN    Date
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
 | 02-01-2006            scherkas          Created
 |
 *=======================================================================*/
FUNCTION LOAN_BALANCE_BY_DATE(P_LOAN_ID IN NUMBER, P_DATE IN DATE) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION GET_LOAN_REMAIN_AMOUNT
 |
 | DESCRIPTION
 |      This function returns funded_amount for the loans in staus
 |     ('INCOMPLETE','REJECTED','DELETED','PENDING','APPROVED','IN_FUNDING','FUNDING_ERROR')
 |      and remaining amount for the other loan statuses.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 22-APR-2009           MBOLLI            Created for bug#8545962
 |
 *=======================================================================*/
FUNCTION GET_LOAN_REMAIN_AMOUNT(P_LOAN_ID IN NUMBER) return NUMBER;

/*========================================================================
 | PUBLIC FUNCTION LAST_INSTALLMENT_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure gets last overdue date.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Loan ID
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
 |  13-Jul-2009           mbolli            Created
 |
 *=======================================================================*/
FUNCTION LAST_INSTALLMENT_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE;


/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_AND_DEFAULT_GL_DATE
 |
 | DESCRIPTION
 |      This procedure validates and defaults gl_date. Created for bug 8859462
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_gl_date            IN    GL_DATE
 |      p_trx_date           IN    TRX_DATE
 |      p_set_of_books_id    IN    set_of_books_id
 |      x_default_gl_date    OUT   New GL_DATE
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
 | 21-Sep-2009           scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_AND_DEFAULT_GL_DATE(p_gl_date              in date,
                                       p_trx_date             in date,
                                       p_set_of_books_id      in number,
                                       x_default_gl_date      out NOCOPY date);

END LNS_BILLING_UTIL_PUB; -- Package spec

/

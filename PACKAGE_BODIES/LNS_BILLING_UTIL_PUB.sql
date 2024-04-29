--------------------------------------------------------
--  DDL for Package Body LNS_BILLING_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_BILLING_UTIL_PUB" AS
/* $Header: LNS_BILL_UTIL_B.pls 120.5.12010000.8 2010/03/17 13:13:13 scherkas ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

    G_PKG_NAME CONSTANT VARCHAR2(30):= 'LNS_BILLING_UTIL_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN

    if (p_msg_level >= G_MSG_LEVEL) then
        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);
    end if;

    if FND_GLOBAL.Conc_Request_Id is not null then
        fnd_file.put_line(FND_FILE.LOG, p_msg);
    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure calculates last payment number.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
FUNCTION LAST_PAYMENT_NUMBER(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
/*
    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select nvl(max(am.PAYMENT_NUMBER), 0)
        from LNS_AMORTIZATION_SCHEDS am,
        lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID and
		am.LOAN_ID = head.LOAN_ID
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
        and am.PARENT_AMORTIZATION_ID is null
		and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');
*/
BEGIN
/*
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
*/
    return LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(P_LOAN_ID, null);
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure calculates last payment number.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
FUNCTION LAST_PAYMENT_NUMBER(P_LOAN_ID IN NUMBER, P_PHASE IN VARCHAR2) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER, P_PHASE VARCHAR2) IS
        select nvl(max(am.PAYMENT_NUMBER), 0)
        from LNS_AMORTIZATION_SCHEDS am,
            lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID
		and am.LOAN_ID = head.LOAN_ID
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
        and am.PARENT_AMORTIZATION_ID is null
        and am.REAMORTIZATION_AMOUNT is null
		and nvl(am.PHASE, 'TERM') = nvl(P_PHASE, nvl(head.CURRENT_PHASE, 'TERM'));

BEGIN
    OPEN get_data_crs(P_LOAN_ID, P_PHASE);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER_EXT
 |
 | DESCRIPTION
 |      This procedure calculates last payment number taking in consideration 0-th installment.
 |      If any installment is billed ('0'/'1'/'2'/.....) then it returns the installment ELSE
 |	it returns '-1'.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
 | 18-Aug-2009		 Mbolli		   Bug#6830765 - Modified with old functionality
 *=======================================================================*/
FUNCTION LAST_PAYMENT_NUMBER_EXT(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER_EXT';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select nvl(max(am.PAYMENT_NUMBER), -1)
        from LNS_AMORTIZATION_SCHEDS am,
        lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID and
		am.LOAN_ID = head.LOAN_ID
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
--        and am.PARENT_AMORTIZATION_ID is null
        and am.REAMORTIZATION_AMOUNT is null  -- fix for bug 7422383
		and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');

BEGIN
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;


/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_NUMBER_EXT_1
 |
 | DESCRIPTION
 |      This procedure calculates last payment number taking in consideration 0-th installment.
 |      If any installment is billed ('0'/'1'/'2'/.....) then it returns the installment ELSE
 |      if any '0th' installments are scheduled(On Activation/On SubmitFor Approval Fees)
 |		then returns '0'  ELSE '-1'
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
 | 18-Aug-2009		 Mbolli		   Bug#6830765 - Created
 *=======================================================================*/
FUNCTION LAST_PAYMENT_NUMBER_EXT_1(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER_EXT_1';
    l_return            NUMBER;
    l_zero_inst_count   NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select nvl(max(am.PAYMENT_NUMBER), -1)
        from LNS_AMORTIZATION_SCHEDS am,
        lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID and
		am.LOAN_ID = head.LOAN_ID
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
--        and am.PARENT_AMORTIZATION_ID is null
        and am.REAMORTIZATION_AMOUNT is null  -- fix for bug 7422383
		and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');

BEGIN
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    IF l_return = -1 THEN

      l_zero_inst_count := 0;

      SELECT nvl(count(1),0)
      INTO l_zero_inst_count
      FROM lns_fee_schedules schd
	   ,lns_fees_all struct
       ,lns_loan_headers_all loan
      WHERE loan.loan_id = P_LOAN_ID
      AND schd.loan_id = loan.loan_id
      AND schd.fee_id = struct.fee_id
      AND struct.fee_type = 'EVENT_ORIGINATION'
      AND schd.fee_installment = 0
      AND schd.active_flag = 'Y'
      AND schd.phase = nvl(loan.CURRENT_PHASE, 'TERM');

      IF l_zero_inst_count <= 0 THEN
        l_return := 0;
      END IF;

    END IF;

    return l_return;
END;


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
FUNCTION LAST_PAYMENT_NUMBER_EXT_2(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER_EXT';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select nvl(max(am.PAYMENT_NUMBER), -1)
        from LNS_AMORTIZATION_SCHEDS am,
        lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID and
		am.LOAN_ID = head.LOAN_ID
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
        and am.PARENT_AMORTIZATION_ID is null
        and am.REAMORTIZATION_AMOUNT is null  -- fix for bug 7422383
		and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');

BEGIN
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;


FUNCTION LAST_PAYMENT_NUMBER_EXT_3(P_LOAN_ID IN NUMBER, P_PHASE IN VARCHAR2) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_NUMBER_EXT_3';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER, P_PHASE VARCHAR2) IS
        select nvl(max(PAYMENT_NUMBER), -1)
        from LNS_AMORTIZATION_SCHEDS
        where LOAN_ID = P_LOAN_ID
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and REAMORTIZATION_AMOUNT is null
		and nvl(PHASE, 'TERM') = nvl(P_PHASE, 'TERM');

BEGIN
    OPEN get_data_crs(P_LOAN_ID, P_PHASE);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;


/*========================================================================
 | PUBLIC FUNCTION LAST_AMORTIZATION_SCHED
 |
 | DESCRIPTION
 |      This procedure returns last amortization schedule id.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Last payment number for Loan ID
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
FUNCTION LAST_AMORTIZATION_SCHED(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_AMORTIZATION_SCHED';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select nvl(max(am.AMORTIZATION_SCHEDULE_ID), -1)
        from LNS_AMORTIZATION_SCHEDS am,
        lns_loan_headers head
        where am.LOAN_ID = P_LOAN_ID
		and am.LOAN_ID = head.LOAN_ID
        and am.PAYMENT_NUMBER = LAST_PAYMENT_NUMBER(am.LOAN_ID)
        and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
        and am.PARENT_AMORTIZATION_ID is null
		and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');

BEGIN
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION NEXT_PAYMENT_DUE
 |
 | DESCRIPTION
 |      This procedure calculates next payment due.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_V instead)
 |
 *=======================================================================*/
FUNCTION NEXT_PAYMENT_DUE(P_LOAN_ID IN NUMBER, P_LINE_TYPE IN VARCHAR2, P_PAYMENT_NUMBER IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'NEXT_PAYMENT_DUE';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;




/*========================================================================
 | PUBLIC FUNCTION AMOUNT_PAID_YTD
 |
 | DESCRIPTION
 |      This procedure calculates amount paid YTD.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_V instead)
 |
 *=======================================================================*/
FUNCTION AMOUNT_PAID_YTD(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'AMOUNT_PAID_YTD';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;



/*========================================================================
 | PUBLIC FUNCTION AMOUNT_PAID_LAST_YEAR
 |
 | DESCRIPTION
 |      This procedure calculates amount paid last year.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_YEARLY_V instead)
 |
 *=======================================================================*/
FUNCTION AMOUNT_PAID_LAST_YEAR(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'AMOUNT_PAID_LAST_YEAR';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;



/*========================================================================
 | PUBLIC FUNCTION AMOUNT_OVERDUE
 |
 | DESCRIPTION
 |      This procedure calculates amount overdue.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID           IN    Amount paid for Loan ID
 |      P_LINE_TYPE         IN    Amount paid for this line type
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_OVERDUE_V instead)
 |
 *=======================================================================*/
FUNCTION AMOUNT_OVERDUE(P_LOAN_ID IN NUMBER, P_LINE_TYPE VARCHAR2) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'AMOUNT_OVERDUE';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;



/*========================================================================
 | PUBLIC FUNCTION NUMBER_OVERDUE_BILLS
 |
 | DESCRIPTION
 |      This procedure calculates number of overdue bills.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_OVERDUE_V instead)
 |
 *=======================================================================*/
FUNCTION NUMBER_OVERDUE_BILLS(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'NUMBER_OVERDUE_BILLS';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure calculates last overdue date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_OVERDUE_V instead)
 |
 *=======================================================================*/
FUNCTION LAST_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_OVERDUE_DATE';
    l_return            DATE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return to_date(null);
END;



/*========================================================================
 | PUBLIC FUNCTION OLDEST_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure calculates oldest overdue date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 01-19-2206            scherkas          Obsoleted (use LNS_PAY_SUM_OVERDUE_V instead)
 |
 *=======================================================================*/
FUNCTION OLDEST_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'OLDEST_OVERDUE_DATE';
    l_return            DATE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return to_date(null);
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_AMOUNT
 |
 | DESCRIPTION
 |      This procedure calculates amount overdue.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 01-19-2206            scherkas          Obsoleted
 |
 *=======================================================================*/
FUNCTION LAST_PAYMENT_AMOUNT(P_LOAN_ID IN NUMBER) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_AMOUNT';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return 0;
END;



/*========================================================================
 | PUBLIC FUNCTION LAST_PAYMENT_DATE
 |
 | DESCRIPTION
 |      This procedure gets last payment date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 01-19-2206            scherkas          Obsoleted
 |
 *=======================================================================*/
FUNCTION LAST_PAYMENT_DATE(P_LOAN_ID IN NUMBER) RETURN DATE
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_PAYMENT_DATE';
    l_return            DATE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    return to_date(null);
END;




/*========================================================================
 | PUBLIC FUNCTION BALANCE_BY_ACT_DATE
 |
 | DESCRIPTION
 |      This procedure returns loan balance by date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
FUNCTION LOAN_BALANCE_BY_DATE(P_LOAN_ID IN NUMBER, P_DATE IN DATE) RETURN NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LOAN_BALANCE_BY_DATE';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER, P_DATE DATE) IS
        select loan.funded_amount -
            (select nvl(sum(rec.amount_applied), 0)
             from
                ar_receivable_applications_all rec,
                LNS_AMORTIZATION_SCHEDS am
             where
                rec.application_type = 'CASH' and
                trunc(rec.apply_date) <= trunc(P_DATE) and
                rec.APPLIED_CUSTOMER_TRX_ID = am.principal_trx_id and
                rec.org_id = loan.org_id and
                am.loan_id = loan.loan_id and
                am.principal_trx_id is not null and
                nvl(am.PHASE, 'TERM') = nvl(loan.CURRENT_PHASE, 'TERM'))
        from lns_loan_headers_all loan
        where loan.loan_id = P_LOAN_ID;

BEGIN
    OPEN get_data_crs(P_LOAN_ID, P_DATE);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    return l_return;
END;


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
FUNCTION GET_LOAN_REMAIN_AMOUNT(P_LOAN_ID IN NUMBER) return NUMBER
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_LOAN_REMAIN_AMOUNT';
    l_remain_amt                    NUMBER;


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR c_remain_amt(P_LOAN_ID NUMBER) IS
     SELECT
       (CASE WHEN LnsLoanHeaderEO.loan_status in ('INCOMPLETE','REJECTED','DELETED','PENDING','APPROVED','IN_FUNDING','FUNDING_ERROR','CANCELLED') OR LnsLoanHeaderEO.FUNDED_AMOUNT = 0 THEN LnsLoanHeaderEO.requested_amount
        ELSE
			LnsLoanHeaderEO.FUNDED_AMOUNT -
			(select nvl(SUM(abs(nvl(psa_prin.AMOUNT_APPLIED, 0))) - SUM(nvl(psa_prin.AMOUNT_ADJUSTED, 0)) + SUM(abs(nvl(psa_prin.AMOUNT_CREDITED, 0))), 0)
			from
			LNS_AMORTIZATION_SCHEDS am
			,ar_payment_schedules_all psa_prin
			where
			am.loan_id = LnsLoanHeaderEO.loan_id
			and am.PHASE = LnsLoanHeaderEO.CURRENT_PHASE
			and am.PAYMENT_NUMBER <= LnsLoanHeaderEO.LAST_PAYMENT_NUMBER
			and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
			and am.REAMORTIZATION_AMOUNT is null
			and psa_prin.customer_trx_id = am.principal_trx_id)
        END)
	FROM LNS_LOAN_HEADERS_ALL LnsLoanHeaderEO
	WHERE loan_id = P_LOAN_ID;

BEGIN

   -- LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- START OF BODY OF API
    --LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);


    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LoanId must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
       -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    open c_remain_amt(P_LOAN_ID);
    fetch c_remain_amt into l_remain_amt;
    close c_remain_amt;

  --  IF l_remain_amt is NULL THEN
  --	l_remain_amt := 0;
  --   END IF;

    --LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
    return l_remain_amt;

--EXCEPTION
--    WHEN OTHERS THEN
       -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception of ' || l_api_name);
END;


/*========================================================================
 | PUBLIC FUNCTION LAST_INSTALLMENT_OVERDUE_DATE
 |
 | DESCRIPTION
 |      This procedure calculates last installment overdue date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
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
 | 13-Jul-2009           mbolli            Created
 |
 *=======================================================================*/
FUNCTION LAST_INSTALLMENT_OVERDUE_DATE(P_LOAN_ID IN NUMBER) RETURN DATE
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LAST_INSTALLMENT_OVERDUE_DATE';
    l_return            DATE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
    CURSOR get_data_crs(P_LOAN_ID IN NUMBER) IS
         SELECT trunc(max(DUE_DATE))
	 FROM lns_amortization_scheds
	 WHERE loan_id = p_loan_id
		AND (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
		AND REAMORTIZATION_AMOUNT is null
		AND nvl(phase, 'TERM') = 'TERM';

BEGIN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin LNS_BILLING_UTIL_PUB.'||l_api_name||' Function + ');
    END IF;
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End LNS_BILLING_UTIL_PUB.'||l_api_name||' Function - ');
    END IF;

    return l_return;
END;



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
                                       x_default_gl_date      out NOCOPY date)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name              CONSTANT VARCHAR2(30) := 'VALIDATE_AND_DEFAULT_GL_DATE';
    l_defaulting_rule_used  varchar2(50);
    l_error_msg             varchar2(100);
    l_return                boolean;
    l_return_char           varchar2(10);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_gl_date = ' || p_gl_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_trx_date = ' || p_trx_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_set_of_books_id = ' || p_set_of_books_id);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling ARP_STANDARD.validate_and_default_gl_date...');
    l_return := ARP_STANDARD.validate_and_default_gl_date(
                    gl_date                => p_gl_date,
                    trx_date               => p_trx_date,
                    validation_date1       => null,
                    validation_date2       => null,
                    validation_date3       => null,
                    default_date1          => null,
                    default_date2          => null,
                    default_date3          => null,
                    p_allow_not_open_flag  => 'N',
                    p_invoicing_rule_id    => null,
                    p_set_of_books_id      => p_set_of_books_id,
                    p_application_id       => 222,
                    default_gl_date        => x_default_gl_date,
                    defaulting_rule_used   => l_defaulting_rule_used,
                    error_message          => l_error_msg);

    if l_return then
        l_return_char := 'true';
    else
        l_return_char := 'false';
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ARP_STANDARD.validate_and_default_gl_date returns:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return = ' || l_return_char);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'x_default_gl_date = ' || x_default_gl_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_defaulting_rule_used = ' || l_defaulting_rule_used);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_error_msg = ' || l_error_msg);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;


BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    /*
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;
    */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

END LNS_BILLING_UTIL_PUB; -- Package body

/

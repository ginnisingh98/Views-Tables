--------------------------------------------------------
--  DDL for Package Body LNS_DEFAULT_HOOKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_DEFAULT_HOOKS_PVT" as
/* $Header: LNS_DEF_HOOKS_B.pls 120.0.12010000.1 2009/07/02 17:41:43 scherkas noship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_DEFAULT_HOOKS_PVT';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
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
 | 04-02-2008            scherkas          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);
        if FND_GLOBAL.Conc_Request_Id is not null then
            fnd_file.put_line(FND_FILE.LOG, p_msg);
        end if;

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



 /*========================================================================
 | PUBLIC PROCEDURE SHIFT_PAY_START_DATES
 |
 | DESCRIPTION
 |      This procedure implements default algorithm for shifting first interest payment and first principal payment dates
 |       on full disbursement payment in AP. New dates are returned back to caller.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    NEW_INT_START_DATE = NEW_LOAN_START_DATE + diff in days between ORIG_INT_START_DATE and  ORIG_LOAN_START_DATE
 |    NEW_PRIN_START_DATE = NEW_LOAN_START_DATE + diff in months between ORIG_PRIN_START_DATE and ORIG_LOAN_START_DATE
 |
 | PARAMETERS
 |      P_LOAN_ID               IN          Loan ID
 |      P_DISBURSEMENT_DATE     IN          Disbursement Date
 |      P_ORIG_LOAN_START_DATE  IN          Original loan start date
 |      P_ORIG_INT_START_DATE   IN          Original interest payment start date. Passed for all amortization methods.
 |      P_ORIG_PRIN_START_DATE  IN          Original principal payment start date. Passed only for Seperate Schedule method.
 |      P_ORIG_LOAN_MATUR_DATE  IN          Original loan maturity date
 |      P_NEW_LOAN_START_DATE   IN          New loan start date
 |      P_NEW_LOAN_MATUR_DATE   IN OUT NOCOPY  New loan maturity date. If changed - new value will be stored
 |      X_NEW_INT_START_DATE    OUT NOCOPY  New/calculated interest payment start date. Must be returned for all amortization methods.
 |      X_NEW_PRIN_START_DATE   OUT NOCOPY  New/calculated principal payment start date. Must be returned only for Seperate Schedule method.
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
PROCEDURE SHIFT_PAY_START_DATES(
        P_LOAN_ID               IN              NUMBER,
        P_DISBURSEMENT_DATE     IN              DATE,
        P_ORIG_LOAN_START_DATE  IN              DATE,
        P_ORIG_INT_START_DATE   IN              DATE,
        P_ORIG_PRIN_START_DATE  IN              DATE,
        P_ORIG_LOAN_MATUR_DATE  IN              DATE,
        P_NEW_LOAN_START_DATE   IN              DATE,
        P_NEW_LOAN_MATUR_DATE   IN OUT NOCOPY   DATE,
        X_NEW_INT_START_DATE    OUT NOCOPY      DATE,
        X_NEW_PRIN_START_DATE   OUT NOCOPY      DATE)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SHIFT_PAY_START_DATES';
    l_day_difference                NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_DISBURSEMENT_DATE: ' || P_DISBURSEMENT_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_ORIG_LOAN_START_DATE: ' || P_ORIG_LOAN_START_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_ORIG_INT_START_DATE: ' || P_ORIG_INT_START_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_ORIG_PRIN_START_DATE: ' || P_ORIG_PRIN_START_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_ORIG_LOAN_MATUR_DATE: ' || P_ORIG_LOAN_MATUR_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_NEW_LOAN_START_DATE: ' || P_NEW_LOAN_START_DATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_NEW_LOAN_MATUR_DATE: ' || P_NEW_LOAN_MATUR_DATE);

    -- default new payment start dates
    X_NEW_INT_START_DATE := P_NEW_LOAN_START_DATE;
    if P_ORIG_PRIN_START_DATE is not null then
        X_NEW_PRIN_START_DATE := P_NEW_LOAN_START_DATE;
    end if;

    -- count the difference between the original loan start date and original interest payment start date
    l_day_difference := P_ORIG_INT_START_DATE - P_ORIG_LOAN_START_DATE;
    logMessage(FND_LOG.LEVEL_PROCEDURE, 'l_int_day_difference: ' || l_day_difference);

    X_NEW_INT_START_DATE := P_NEW_LOAN_START_DATE + l_day_difference;
    logMessage(FND_LOG.LEVEL_PROCEDURE, 'X_NEW_INT_START_DATE: ' || X_NEW_INT_START_DATE);

    -- count the difference between the old start date and old principal first payment date (if its not null)
    if P_ORIG_PRIN_START_DATE is not null then
        l_day_difference := P_ORIG_PRIN_START_DATE - P_ORIG_LOAN_START_DATE;
        logMessage(FND_LOG.LEVEL_PROCEDURE, 'l_prin_day_difference: ' || l_day_difference);

        X_NEW_PRIN_START_DATE := P_NEW_LOAN_START_DATE + l_day_difference;
        logMessage(FND_LOG.LEVEL_PROCEDURE, 'X_NEW_PRIN_START_DATE: ' || X_NEW_PRIN_START_DATE);
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception');
END;




BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

END;

/

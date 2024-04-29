--------------------------------------------------------
--  DDL for Package Body LNS_EXT_LOAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_EXT_LOAN_PUB" as
/* $Header: LNS_EXT_LOAN_B.pls 120.0.12010000.4 2010/04/15 12:45:01 scherkas noship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_EXT_LOAN_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      SAVE_LOAN_EXTENSION
 |      APPROVE_LOAN_EXTENSION
 |      REJECT_LOAN_EXTENSION
 |      CALC_NEW_TERMS
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
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



/*========================================================================
 | PRIVATE PROCEDURE VALIDATE_EXTN
 |
 | DESCRIPTION
 |      This procedure validates extension for different actions
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      SAVE_LOAN_EXTENSION
 |      APPROVE_LOAN_EXTENSION
 |      REJECT_LOAN_EXTENSION
 |      CALC_NEW_TERMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_EXT_REC  IN      Extension record
 |      ACTION          IN      Action
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
 | 09-27-2007            scherkas          Created
 |
 *=======================================================================*/
Procedure VALIDATE_EXTN(P_LOAN_EXT_REC IN LNS_EXT_LOAN_PUB.LOAN_EXT_REC
                        ,P_ACTION IN VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_EXTN';
    l_extn_count                    NUMBER;
    l_loan_status                   VARCHAR2(30);
    l_extn_status                   VARCHAR2(30);
    l_customized                    VARCHAR2(1);
    l_phase                         VARCHAR2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR extn_count_cur(P_LOAN_ID number) IS
        select count(1)
        from lns_loan_extensions
        where loan_id = P_LOAN_ID and
            STATUS = 'PENDING';

    CURSOR extn_details_cur(P_LOAN_EXT_ID number) IS
        select STATUS
        from lns_loan_extensions
        where LOAN_EXT_ID = P_LOAN_EXT_ID;

    CURSOR loan_details_cur(P_LOAN_ID number) IS
        select LOAN_STATUS, nvl(custom_payments_flag, 'N'), nvl(CURRENT_PHASE, 'TERM')
        from lns_loan_headers_all
        where loan_id = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    if (P_LOAN_EXT_REC.LOAN_ID is null or
        P_LOAN_EXT_REC.EXT_TERM is null or
        P_LOAN_EXT_REC.EXT_TERM_PERIOD is null or
        P_LOAN_EXT_REC.EXT_BALLOON_TYPE is null or
        (P_LOAN_EXT_REC.EXT_BALLOON_TYPE = 'TERM' and P_LOAN_EXT_REC.EXT_AMORT_TERM is null) or
        (P_LOAN_EXT_REC.EXT_BALLOON_TYPE = 'AMOUNT' and P_LOAN_EXT_REC.EXT_BALLOON_AMOUNT is null)
        )
    then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Not all required data is set.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_NO_REQ_PAR');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    open loan_details_cur(P_LOAN_EXT_REC.LOAN_ID);
    fetch loan_details_cur into l_loan_status, l_customized, l_phase;
    close loan_details_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_status: ' || l_loan_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_customized: ' || l_customized);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_phase: ' || l_phase);

    if l_customized = 'N' and P_LOAN_EXT_REC.EXT_TERM > 0 then

        if (P_LOAN_EXT_REC.EXT_RATE is null or
            P_LOAN_EXT_REC.EXT_SPREAD is null or
            P_LOAN_EXT_REC.EXT_IO_FLAG is null) then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Not all required data is set.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_NO_REQ_PAR');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    end if;

    if (P_ACTION = 'INSERT') then

        if (l_loan_status <> 'ACTIVE' and
            l_loan_status <> 'APPROVED' and
            l_loan_status <> 'DEFAULT' and
            l_loan_status <> 'DELINQUENT' and
            l_loan_status <> 'FUNDING_ERROR' and
            l_loan_status <> 'IN_FUNDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan status.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_LN_STATUS');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        open extn_count_cur(P_LOAN_EXT_REC.LOAN_ID);
        fetch extn_count_cur into l_extn_count;
        close extn_count_cur;

        if (l_extn_count > 0) then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: A pending extension for this loan already exists.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_ALREADY_EXTN');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    elsif (P_ACTION = 'UPDATE') then

        if (l_loan_status <> 'ACTIVE' and
            l_loan_status <> 'APPROVED' and
            l_loan_status <> 'DEFAULT' and
            l_loan_status <> 'DELINQUENT' and
            l_loan_status <> 'FUNDING_ERROR' and
            l_loan_status <> 'IN_FUNDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan status.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_LN_STATUS');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        open extn_details_cur(P_LOAN_EXT_REC.LOAN_EXT_ID);
        fetch extn_details_cur into l_extn_status;
        close extn_details_cur;

        if (l_extn_status <> 'PENDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan extension.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_EXTN');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;




/*========================================================================
 | PRIVATE PROCEDURE VALIDATE_EXTN
 |
 | DESCRIPTION
 |      This procedure validates extension for different actions
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      APPROVE_LOAN_EXTENSION
 |      REJECT_LOAN_EXTENSION
 |      CALC_NEW_TERMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_EXT_ID   IN      Extension ID
 |      ACTION          IN      Action
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
 | 09-27-2007            scherkas          Created
 | 07-08-2008            scherkas          Fix for bug 7238772
 |
 *=======================================================================*/
Procedure VALIDATE_EXTN(P_LOAN_EXT_ID IN NUMBER
                        ,P_ACTION IN VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_EXTN';

    l_LOAN_ID                       NUMBER;
    l_OLD_INSTALLMENTS              NUMBER;
    l_NEW_TERM                      NUMBER;
    l_NEW_TERM_PERIOD               VARCHAR2(30);
    l_NEW_AMORT_TERM                NUMBER;
    l_NEW_MATURITY_DATE             DATE;
    l_NEW_INSTALLMENTS              NUMBER;
    l_EXT_RATE                      NUMBER;
    l_EXT_SPREAD                    NUMBER;
    l_EXT_IO_FLAG                   VARCHAR2(1);
    l_STATUS                        VARCHAR2(30);
    l_loan_status                   VARCHAR2(30);
    l_customized                    VARCHAR2(1);
    l_NEW_BALLOON_TYPE              VARCHAR2(30);
    l_NEW_BALLOON_AMOUNT            NUMBER;
    l_phase                         VARCHAR2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_ext_cur(P_LOAN_EXT_ID number) IS
        select
            ext.LOAN_ID,
            ext.OLD_INSTALLMENTS,
            ext.NEW_TERM,
            ext.NEW_TERM_PERIOD,
            ext.NEW_BALLOON_TYPE,
            ext.NEW_BALLOON_AMOUNT,
            ext.NEW_AMORT_TERM,
            ext.NEW_MATURITY_DATE,
            ext.NEW_INSTALLMENTS,
            ext.EXT_RATE,
            ext.EXT_SPREAD,
            ext.EXT_IO_FLAG,
            ext.STATUS
        from lns_loan_extensions ext
        where ext.LOAN_EXT_ID = P_LOAN_EXT_ID;

    CURSOR loan_details_cur(P_LOAN_EXT_ID number) IS
        select loan.LOAN_STATUS, nvl(loan.custom_payments_flag, 'N'), nvl(loan.CURRENT_PHASE, 'TERM')
        from lns_loan_headers_all loan,
            lns_loan_extensions ext
        where ext.LOAN_EXT_ID = P_LOAN_EXT_ID and
            ext.loan_id = loan.loan_id;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    open loan_details_cur(P_LOAN_EXT_ID);
    fetch loan_details_cur into l_loan_status, l_customized, l_phase;
    close loan_details_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_status: ' || l_loan_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_customized: ' || l_customized);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_phase: ' || l_phase);

    open loan_ext_cur(P_LOAN_EXT_ID);
    fetch loan_ext_cur
    into l_LOAN_ID,
        l_OLD_INSTALLMENTS,
        l_NEW_TERM,
        l_NEW_TERM_PERIOD,
        l_NEW_BALLOON_TYPE,
        l_NEW_BALLOON_AMOUNT,
        l_NEW_AMORT_TERM,
        l_NEW_MATURITY_DATE,
        l_NEW_INSTALLMENTS,
        l_EXT_RATE,
        l_EXT_SPREAD,
        l_EXT_IO_FLAG,
        l_STATUS;
    close loan_ext_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID: ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OLD_INSTALLMENTS: ' || l_OLD_INSTALLMENTS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_TERM: ' || l_NEW_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_TERM_PERIOD: ' || l_NEW_TERM_PERIOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_BALLOON_TYPE: ' || l_NEW_BALLOON_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_BALLOON_AMOUNT: ' || l_NEW_BALLOON_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_AMORT_TERM: ' || l_NEW_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_MATURITY_DATE: ' || l_NEW_MATURITY_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_NEW_INSTALLMENTS: ' || l_NEW_INSTALLMENTS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_EXT_RATE: ' || l_EXT_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_EXT_SPREAD: ' || l_EXT_SPREAD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_EXT_IO_FLAG: ' || l_EXT_IO_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_STATUS: ' || l_STATUS);

    if (P_ACTION = 'APPROVE') then

        if (l_LOAN_ID is null or
            l_OLD_INSTALLMENTS is null or
            l_NEW_TERM is null or
            l_NEW_TERM_PERIOD is null or
            l_NEW_MATURITY_DATE is null or
            l_NEW_INSTALLMENTS is null or
            l_STATUS is null or
            l_NEW_BALLOON_TYPE is null or
            (l_NEW_BALLOON_TYPE = 'TERM' and l_NEW_AMORT_TERM is null) or
            (l_NEW_BALLOON_TYPE = 'AMOUNT' and l_NEW_BALLOON_AMOUNT is null))
        then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Not all required data is set.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_NO_REQ_PAR');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_customized = 'N' and l_NEW_INSTALLMENTS > l_OLD_INSTALLMENTS then

            if (l_EXT_RATE is null or
                l_EXT_IO_FLAG is null or
                l_EXT_SPREAD is null)
            then

        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Not all required data is set.');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_NO_REQ_PAR');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            end if;

        end if;

        if (l_loan_status <> 'ACTIVE' and
            l_loan_status <> 'APPROVED' and
            l_loan_status <> 'DEFAULT' and
            l_loan_status <> 'DELINQUENT' and
            l_loan_status <> 'FUNDING_ERROR' and
            l_loan_status <> 'IN_FUNDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan status.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_LN_STATUS');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if (l_STATUS <> 'PENDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan extension.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_EXTN');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    elsif (P_ACTION = 'REJECT') then

        if (l_loan_status <> 'ACTIVE' and
            l_loan_status <> 'APPROVED' and
            l_loan_status <> 'DEFAULT' and
            l_loan_status <> 'DELINQUENT' and
            l_loan_status <> 'FUNDING_ERROR' and
            l_loan_status <> 'IN_FUNDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan status.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_LN_STATUS');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if (l_STATUS <> 'PENDING') then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Invalid loan extension.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_EXTN_INVAL_EXTN');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;




/*========================================================================
 | PUBLIC PROCEDURE SAVE_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure inserts/updates loan extension in lns_loan_extensions table
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_REC        IN OUT NOCOPY   LNS_EXT_LOAN_PUB.LOAN_EXT_REC record
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SAVE_LOAN_EXTENSION(
    P_API_VERSION		IN              NUMBER,
    P_INIT_MSG_LIST		IN              VARCHAR2,
    P_COMMIT			IN              VARCHAR2,
    P_VALIDATION_LEVEL	IN              NUMBER,
    P_LOAN_EXT_REC      IN OUT NOCOPY   LNS_EXT_LOAN_PUB.LOAN_EXT_REC,
    X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SAVE_LOAN_EXTENSION';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_NEW_TERM_REC                  LNS_EXT_LOAN_PUB.NEW_TERM_REC;
    l_is_exist			            VARCHAR2(1) := 'N';

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT SAVE_LOAN_EXTENSION;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID:' || P_LOAN_EXT_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_EXT_ID:' || P_LOAN_EXT_REC.LOAN_EXT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DESCRIPTION:' || P_LOAN_EXT_REC.DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_TERM:' || P_LOAN_EXT_REC.EXT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_TERM_PERIOD:' || P_LOAN_EXT_REC.EXT_TERM_PERIOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_BALLOON_TYPE:' || P_LOAN_EXT_REC.EXT_BALLOON_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_BALLOON_AMOUNT:' || P_LOAN_EXT_REC.EXT_BALLOON_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_AMORT_TERM:' || P_LOAN_EXT_REC.EXT_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_RATE:' || P_LOAN_EXT_REC.EXT_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_SPREAD:' || P_LOAN_EXT_REC.EXT_SPREAD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_IO_FLAG:' || P_LOAN_EXT_REC.EXT_IO_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_INDEX_DATE:' || P_LOAN_EXT_REC.EXT_INDEX_DATE);

    if (P_LOAN_EXT_REC.LOAN_EXT_ID is null) then
        VALIDATE_EXTN(P_LOAN_EXT_REC, 'INSERT');
    else
        VALIDATE_EXTN(P_LOAN_EXT_REC, 'UPDATE');
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling CALC_NEW_TERMS...');

    l_NEW_TERM_REC.LOAN_ID := P_LOAN_EXT_REC.LOAN_ID;
    l_NEW_TERM_REC.EXT_TERM := P_LOAN_EXT_REC.EXT_TERM;
    l_NEW_TERM_REC.EXT_TERM_PERIOD := P_LOAN_EXT_REC.EXT_TERM_PERIOD;
    l_NEW_TERM_REC.EXT_BALLOON_TYPE := P_LOAN_EXT_REC.EXT_BALLOON_TYPE;
    l_NEW_TERM_REC.EXT_BALLOON_AMOUNT := P_LOAN_EXT_REC.EXT_BALLOON_AMOUNT;
    l_NEW_TERM_REC.EXT_AMORT_TERM := P_LOAN_EXT_REC.EXT_AMORT_TERM;

    CALC_NEW_TERMS(
        P_API_VERSION		=> 1.0,
        P_INIT_MSG_LIST		=> FND_API.G_TRUE,
        P_COMMIT			=> FND_API.G_FALSE,
        P_VALIDATION_LEVEL	=> FND_API.G_VALID_LEVEL_FULL,
        P_NEW_TERM_REC      => l_NEW_TERM_REC,
        X_RETURN_STATUS		=> l_return_status,
        X_MSG_COUNT			=> l_msg_count,
        X_MSG_DATA	    	=> l_msg_data);

    if (l_return_status <> 'S') then
       RAISE FND_API.G_EXC_ERROR;
    end if;


    BEGIN
      SELECT
          'Y' into l_is_exist
      FROM
        lns_loan_extensions
      WHERE
        loan_ext_id = P_LOAN_EXT_REC.LOAN_EXT_ID;

    EXCEPTION
    WHEN no_data_found THEN
        l_is_exist := 'N';
    END;

    --if (P_LOAN_EXT_REC.LOAN_EXT_ID is null) then

    if (l_is_exist <> 'Y') then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting into lns_loan_extensions...');

        if P_LOAN_EXT_REC.LOAN_EXT_ID is null then
            select lns_loan_extensions_s.NEXTVAL into P_LOAN_EXT_REC.LOAN_EXT_ID from dual;
        end if;

        insert into lns_loan_extensions(
            LOAN_EXT_ID,
            LOAN_ID,
            DESCRIPTION,
            OLD_TERM,
            OLD_TERM_PERIOD,
            OLD_BALLOON_TYPE,
            OLD_BALLOON_AMOUNT,
            OLD_AMORT_TERM,
            OLD_MATURITY_DATE,
            OLD_INSTALLMENTS,
            EXT_TERM,
            EXT_TERM_PERIOD,
            EXT_BALLOON_TYPE,
            EXT_BALLOON_AMOUNT,
            EXT_AMORT_TERM,
            EXT_RATE,
            EXT_SPREAD,
            EXT_IO_FLAG,
            EXT_INDEX_DATE,
            NEW_TERM,
            NEW_TERM_PERIOD,
            NEW_BALLOON_TYPE,
            NEW_BALLOON_AMOUNT,
            NEW_AMORT_TERM,
            NEW_MATURITY_DATE,
            NEW_INSTALLMENTS,
            STATUS,
            APPR_REJECT_DATE,
            APPR_REJECT_BY,
            OBJECT_VERSION_NUMBER,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN)
        values(
            P_LOAN_EXT_REC.LOAN_EXT_ID,
            P_LOAN_EXT_REC.LOAN_ID,
            P_LOAN_EXT_REC.DESCRIPTION,
            l_NEW_TERM_REC.OLD_TERM,
            l_NEW_TERM_REC.OLD_TERM_PERIOD,
            l_NEW_TERM_REC.OLD_BALLOON_TYPE,
            l_NEW_TERM_REC.OLD_BALLOON_AMOUNT,
            l_NEW_TERM_REC.OLD_AMORT_TERM,
            l_NEW_TERM_REC.OLD_MATURITY_DATE,
            l_NEW_TERM_REC.OLD_INSTALLMENTS,
            P_LOAN_EXT_REC.EXT_TERM,
            P_LOAN_EXT_REC.EXT_TERM_PERIOD,
            P_LOAN_EXT_REC.EXT_BALLOON_TYPE,
            P_LOAN_EXT_REC.EXT_BALLOON_AMOUNT,
            P_LOAN_EXT_REC.EXT_AMORT_TERM,
            P_LOAN_EXT_REC.EXT_RATE,
            P_LOAN_EXT_REC.EXT_SPREAD,
            P_LOAN_EXT_REC.EXT_IO_FLAG,
            P_LOAN_EXT_REC.EXT_INDEX_DATE,
            l_NEW_TERM_REC.NEW_TERM,
            l_NEW_TERM_REC.NEW_TERM_PERIOD,
            l_NEW_TERM_REC.NEW_BALLOON_TYPE,
            l_NEW_TERM_REC.NEW_BALLOON_AMOUNT,
            l_NEW_TERM_REC.NEW_AMORT_TERM,
            l_NEW_TERM_REC.NEW_MATURITY_DATE,
            l_NEW_TERM_REC.NEW_INSTALLMENTS,
            'PENDING',
            null,
            null,
            1,
            sysdate,
            LNS_UTILITY_PUB.CREATED_BY,
            sysdate,
            LNS_UTILITY_PUB.LAST_UPDATED_BY,
            LNS_UTILITY_PUB.LAST_UPDATE_LOGIN);

    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_loan_extensions...');

        update LNS_LOAN_EXTENSIONS set
            DESCRIPTION = P_LOAN_EXT_REC.DESCRIPTION,
            OLD_TERM = l_NEW_TERM_REC.OLD_TERM,
            OLD_TERM_PERIOD = l_NEW_TERM_REC.OLD_TERM_PERIOD,
            OLD_BALLOON_TYPE = l_NEW_TERM_REC.OLD_BALLOON_TYPE,
            OLD_BALLOON_AMOUNT = l_NEW_TERM_REC.OLD_BALLOON_AMOUNT,
            OLD_AMORT_TERM = l_NEW_TERM_REC.OLD_AMORT_TERM,
            OLD_MATURITY_DATE = l_NEW_TERM_REC.OLD_MATURITY_DATE,
            OLD_INSTALLMENTS = l_NEW_TERM_REC.OLD_INSTALLMENTS,
            EXT_TERM = P_LOAN_EXT_REC.EXT_TERM,
            EXT_TERM_PERIOD = P_LOAN_EXT_REC.EXT_TERM_PERIOD,
            EXT_BALLOON_TYPE = P_LOAN_EXT_REC.EXT_BALLOON_TYPE,
            EXT_BALLOON_AMOUNT = P_LOAN_EXT_REC.EXT_BALLOON_AMOUNT,
            EXT_AMORT_TERM = P_LOAN_EXT_REC.EXT_AMORT_TERM,
            EXT_RATE = P_LOAN_EXT_REC.EXT_RATE,
            EXT_SPREAD = P_LOAN_EXT_REC.EXT_SPREAD,
            EXT_IO_FLAG = P_LOAN_EXT_REC.EXT_IO_FLAG,
            EXT_INDEX_DATE = P_LOAN_EXT_REC.EXT_INDEX_DATE,
            NEW_TERM = l_NEW_TERM_REC.NEW_TERM,
            NEW_TERM_PERIOD = l_NEW_TERM_REC.NEW_TERM_PERIOD,
            NEW_BALLOON_TYPE = l_NEW_TERM_REC.NEW_BALLOON_TYPE,
            NEW_BALLOON_AMOUNT = l_NEW_TERM_REC.NEW_BALLOON_AMOUNT,
            NEW_AMORT_TERM = l_NEW_TERM_REC.NEW_AMORT_TERM,
            NEW_MATURITY_DATE = l_NEW_TERM_REC.NEW_MATURITY_DATE,
            NEW_INSTALLMENTS = l_NEW_TERM_REC.NEW_INSTALLMENTS,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
        where LOAN_EXT_ID = P_LOAN_EXT_REC.LOAN_EXT_ID;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    -- END OF BODY OF API

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO SAVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SAVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO SAVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE APPROVE_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure approves loan extension and updates loan term data in
 |      lns_loan_headers_all from lns_loan_extensions table
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_ID         IN              Loan extension ID
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_LOAN_EXTENSION(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_EXT_ID       IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPROVE_LOAN_EXTENSION';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_LOAN_ID                       NUMBER;
    l_OLD_INSTALLMENTS              NUMBER;
    l_NEW_TERM                      NUMBER;
    l_NEW_TERM_PERIOD               VARCHAR2(30);
    l_NEW_AMORT_TERM                NUMBER;
    l_NEW_MATURITY_DATE             DATE;
    l_NEW_INSTALLMENTS              NUMBER;
    l_OBJECT_VERSION_NUMBER         NUMBER;
    l_EXT_RATE                      NUMBER;
    l_EXT_SPREAD                    NUMBER;
    l_EXT_IO_FLAG                   VARCHAR2(1);
    l_EXT_INDEX_DATE                DATE;
    l_TERM_ID                       NUMBER;
    l_REQUEST_ID                    number;
    l_last_billed_installment       number;
    l_customized                    VARCHAR2(1);
    l_NEW_BALLOON_TYPE              VARCHAR2(30);
    l_NEW_BALLOON_AMOUNT            NUMBER;

    l_RATE_ID                       number;
    l_RATE                          number;
    l_BEGIN_INSTALLMENT             number;
    l_END_INSTALLMENT               number;
    l_INDEX_RATE                    number;
    l_SPREAD                        number;
    l_INTEREST_ONLY_FLAG            VARCHAR2(1);
    i                               number;
    l_agreement_reason              varchar2(500);
    l_description                   VARCHAR2(30);
    l_EXT_TERM                      number;
    l_EXT_TERM_PERIOD               VARCHAR2(30);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- query loan extension details
    CURSOR loan_ext_cur(P_LOAN_EXT_ID number) IS
        select
            ext.LOAN_ID,
            ext.OLD_INSTALLMENTS,
            ext.NEW_TERM,
            ext.NEW_TERM_PERIOD,
            ext.NEW_BALLOON_TYPE,
            ext.NEW_BALLOON_AMOUNT,
            ext.NEW_AMORT_TERM,
            ext.NEW_MATURITY_DATE,
            ext.NEW_INSTALLMENTS,
            ext.EXT_RATE,
            ext.EXT_SPREAD,
            ext.EXT_IO_FLAG,
            ext.EXT_INDEX_DATE,
            loan.OBJECT_VERSION_NUMBER,
            term.term_id,
            nvl(loan.custom_payments_flag, 'N'),
            ext.DESCRIPTION,
            ext.EXT_TERM,
            ext.EXT_TERM_PERIOD
        from lns_loan_extensions ext,
            lns_loan_headers_all loan,
            lns_terms term
        where ext.LOAN_EXT_ID = P_LOAN_EXT_ID and
            loan.LOAN_ID = ext.LOAN_ID and
            term.loan_id = loan.LOAN_ID;

    -- cursor to load rate schedule
    cursor c_rate_sched(p_term_id NUMBER) IS
      select RATE_ID,
             CURRENT_INTEREST_RATE,
             BEGIN_INSTALLMENT_NUMBER,
             END_INSTALLMENT_NUMBER,
             INDEX_RATE,
             SPREAD,
             INTEREST_ONLY_FLAG
      from lns_rate_schedules
      where term_id = p_term_id and
        END_DATE_ACTIVE is null and
        phase = 'TERM'
      order by END_INSTALLMENT_NUMBER desc;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT APPROVE_LOAN_EXTENSION;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    --IF FND_API.To_Boolean(p_init_msg_list) THEN
    --  FND_MSG_PUB.initialize;
    --END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    VALIDATE_EXTN(P_LOAN_EXT_ID, 'APPROVE');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying extension details...');

    open loan_ext_cur(P_LOAN_EXT_ID);
    fetch loan_ext_cur
    into l_LOAN_ID,
         l_OLD_INSTALLMENTS,
         l_NEW_TERM,
         l_NEW_TERM_PERIOD,
         l_NEW_BALLOON_TYPE,
         l_NEW_BALLOON_AMOUNT,
         l_NEW_AMORT_TERM,
         l_NEW_MATURITY_DATE,
         l_NEW_INSTALLMENTS,
         l_EXT_RATE,
         l_EXT_SPREAD,
         l_EXT_IO_FLAG,
         l_EXT_INDEX_DATE,
         l_OBJECT_VERSION_NUMBER,
         l_TERM_ID,
         l_customized,
         l_description,
         l_EXT_TERM,
         l_EXT_TERM_PERIOD;
    close loan_ext_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OLD_INSTALLMENTS: ' || l_OLD_INSTALLMENTS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_TERM: ' || l_NEW_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_TERM_PERIOD: ' || l_NEW_TERM_PERIOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_BALLOON_TYPE: ' || l_NEW_BALLOON_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_BALLOON_AMOUNT: ' || l_NEW_BALLOON_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_AMORT_TERM: ' || l_NEW_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_MATURITY_DATE: ' || l_NEW_MATURITY_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEW_INSTALLMENTS: ' || l_NEW_INSTALLMENTS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_RATE: ' || l_EXT_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_SPREAD: ' || l_EXT_SPREAD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_IO_FLAG: ' || l_EXT_IO_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_INDEX_DATE: ' || l_EXT_INDEX_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OBJECT_VERSION_NUMBER: ' || l_OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_TERM_ID: ' || l_TERM_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_customized: ' || l_customized);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_description: ' || l_description);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_EXT_TERM: ' || l_EXT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_EXT_TERM_PERIOD: ' || l_EXT_TERM_PERIOD);

    l_loan_header_rec.loan_id := l_LOAN_ID;
    l_loan_header_rec.loan_term := l_NEW_TERM;
    l_loan_header_rec.LOAN_TERM_PERIOD := l_NEW_TERM_PERIOD;
    l_loan_header_rec.BALLOON_PAYMENT_TYPE := l_NEW_BALLOON_TYPE;
    l_loan_header_rec.BALLOON_PAYMENT_AMOUNT := l_NEW_BALLOON_AMOUNT;
    l_loan_header_rec.AMORTIZED_TERM := l_NEW_AMORT_TERM;
    l_loan_header_rec.AMORTIZED_TERM_PERIOD := l_NEW_TERM_PERIOD;
    l_loan_header_rec.LOAN_MATURITY_DATE := l_NEW_MATURITY_DATE;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan...');
    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Synching rate schedule...');

    -- finding right rate row and update it
    i := 0;
    OPEN c_rate_sched(l_TERM_ID);
    LOOP
        i := i + 1;
        FETCH c_rate_sched INTO
            l_RATE_ID,
            l_RATE,
            l_BEGIN_INSTALLMENT,
            l_END_INSTALLMENT,
            l_INDEX_RATE,
            l_SPREAD,
            l_INTEREST_ONLY_FLAG;

        LogMessage(FND_LOG.LEVEL_STATEMENT, i || ') Rate ' || l_RATE || ': ' || l_BEGIN_INSTALLMENT || ' - ' || l_END_INSTALLMENT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_INDEX_RATE = ' || l_INDEX_RATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_SPREAD = ' || l_SPREAD);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_INTEREST_ONLY_FLAG = ' || l_INTEREST_ONLY_FLAG);

        if l_NEW_INSTALLMENTS > l_END_INSTALLMENT then

            if (l_INDEX_RATE = l_EXT_RATE and
            l_SPREAD = l_EXT_SPREAD and
            l_INTEREST_ONLY_FLAG = l_EXT_IO_FLAG)
            then

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || l_NEW_INSTALLMENTS);

                update lns_rate_schedules
                set END_INSTALLMENT_NUMBER = l_NEW_INSTALLMENTS
                where term_id = l_TERM_ID and
                RATE_ID = l_RATE_ID;

            else

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting into LNS_RATE_SCHEDULES...');

                insert into LNS_RATE_SCHEDULES
                (RATE_ID
                ,TERM_ID
                ,INDEX_RATE
                ,SPREAD
                ,CURRENT_INTEREST_RATE
                ,START_DATE_ACTIVE
                ,END_DATE_ACTIVE
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
                ,OBJECT_VERSION_NUMBER
                ,INDEX_DATE
                ,BEGIN_INSTALLMENT_NUMBER
                ,END_INSTALLMENT_NUMBER
                ,INTEREST_ONLY_FLAG
                ,PHASE)
                VALUES
                (LNS_RATE_SCHEDULES_S.nextval
                ,l_TERM_ID
                ,l_EXT_RATE
                ,l_EXT_SPREAD
                ,(l_EXT_RATE+l_EXT_SPREAD)
                ,sysdate
                ,null
                ,lns_utility_pub.created_by
                ,sysdate
                ,lns_utility_pub.last_updated_by
                ,sysdate
                ,lns_utility_pub.LAST_UPDATE_LOGIN
                ,1
                ,l_EXT_INDEX_DATE
                ,l_END_INSTALLMENT+1
                ,l_NEW_INSTALLMENTS
                ,l_EXT_IO_FLAG
                ,'TERM');

            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
            exit;

        elsif l_NEW_INSTALLMENTS >= l_BEGIN_INSTALLMENT and l_NEW_INSTALLMENTS <= l_END_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || l_NEW_INSTALLMENTS);

            update lns_rate_schedules
            set END_INSTALLMENT_NUMBER = l_NEW_INSTALLMENTS
            where term_id = l_TERM_ID and
            RATE_ID = l_RATE_ID;

            exit;

        elsif l_NEW_INSTALLMENTS < l_BEGIN_INSTALLMENT then

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting this row');

            delete from lns_rate_schedules
            where term_id = l_TERM_ID and
            RATE_ID = l_RATE_ID;

        end if;

    END LOOP;

    CLOSE c_rate_sched;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done synching');

    if l_customized = 'Y' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting from LNS_CUSTOM_PAYMNT_SCHEDS rows with DUE_DATE < l_NEW_MATURITY_DATE...');
        delete from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = l_LOAN_ID
        and DUE_DATE > l_NEW_MATURITY_DATE;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    end if;

    -- fix for bug 6724561
    l_last_billed_installment := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_last_billed_installment: ' || l_last_billed_installment);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_LOAN_EXTENSIONS...');

    update LNS_LOAN_EXTENSIONS
    set STATUS = 'APPROVED',
    APPR_REJECT_DATE = sysdate,
    APPR_REJECT_BY = LNS_UTILITY_PUB.USER_ID,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
    LAST_BILLED_INSTALLMENT = l_last_billed_installment
    where LOAN_EXT_ID = P_LOAN_EXT_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    -- END OF BODY OF API

    -- Retrieve agreement reason
    FND_MESSAGE.SET_NAME('LNS', 'LNS_TERM_EXT_AGR_REASON');
    FND_MESSAGE.SET_TOKEN('EXT', l_description);
    FND_MESSAGE.SET_TOKEN('EXT_TERM', l_EXT_TERM);
    FND_MESSAGE.SET_TOKEN('EXT_TERM_PERIOD', lns_utility_pub.get_lookup_meaning('PERIOD', l_EXT_TERM_PERIOD));
    FND_MESSAGE.SET_TOKEN('NEW_MATURITY_DATE', l_NEW_MATURITY_DATE);
    FND_MSG_PUB.Add;
    l_agreement_reason := FND_MSG_PUB.Get(p_encoded => 'F');
    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

    LNS_REP_UTILS.STORE_LOAN_AGREEMENT_CP(l_LOAN_ID, l_agreement_reason);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPROVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPROVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO APPROVE_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE REJECT_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure rejects loan extension. No changes is made in lns_loan_headers_all table
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_ID         IN              Loan extension ID
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REJECT_LOAN_EXTENSION(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_EXT_ID       IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'REJECT_LOAN_EXTENSION';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT REJECT_LOAN_EXTENSION;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    --IF FND_API.To_Boolean(p_init_msg_list) THEN
    --  FND_MSG_PUB.initialize;
    --END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    VALIDATE_EXTN(P_LOAN_EXT_ID, 'REJECT');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_LOAN_EXTENSIONS...');

    update LNS_LOAN_EXTENSIONS
    set STATUS = 'REJECTED',
    APPR_REJECT_DATE = sysdate,
    APPR_REJECT_BY = LNS_UTILITY_PUB.USER_ID,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
    where LOAN_EXT_ID = P_LOAN_EXT_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    -- END OF BODY OF API

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO REJECT_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO REJECT_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO REJECT_LOAN_EXTENSION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE CALC_NEW_TERMS
 |
 | DESCRIPTION
 |      This procedure calculates and returns new loan terms based on input extension loan term data.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_EXT_LOAN_REC        IN OUT NOCOPY   LNS_EXT_LOAN_PUB.NEW_TERM_REC record
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CALC_NEW_TERMS(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_NEW_TERM_REC      IN OUT NOCOPY  LNS_EXT_LOAN_PUB.NEW_TERM_REC,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CALC_NEW_TERMS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_start_date               date;
    l_loan_payment_frequency        VARCHAR2(30);
    l_extend_installments           number;
    l_term1                         number;
    l_ext_term1                     number;
    l_am_term1                      number;
    l_ext_am_term1                  number;
    l_term_id                       number;
    l_first_payment_date            date;
    l_intervals                     number;
    l_pay_in_arrears                varchar2(1);
    l_pay_in_arrears_bool           boolean;
    l_prin_first_pay_date           date;
    l_prin_intervals                number;
    l_prin_payment_frequency        varchar2(30);
    l_prin_pay_in_arrears           varchar2(1);
    l_prin_pay_in_arrears_bool      boolean;
    l_pay_calc_method               varchar2(30);
    l_amortization_frequency        varchar2(30);
    l_customized                    VARCHAR2(1);

    l_payment_tbl               LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- query existent loan data
    CURSOR loan_cur(P_LOAN_ID number) IS
        select
            loan.loan_start_date,
            loan.loan_term,
            loan.LOAN_TERM_PERIOD,
            loan.BALLOON_PAYMENT_TYPE,
            loan.BALLOON_PAYMENT_AMOUNT,
            loan.AMORTIZED_TERM,
            loan.LOAN_MATURITY_DATE,
            term.loan_payment_frequency,
            term.term_id,
            term.amortization_frequency,
            trunc(term.first_payment_date),
            decode(trunc(term.first_payment_date) - trunc(loan.loan_start_date), 0, 'N', 'Y'),  -- calculate in advance or arrears
            nvl(term.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT'),
            trunc(nvl(term.prin_first_pay_date, term.first_payment_date)),
            nvl(term.prin_payment_frequency, term.loan_payment_frequency),
            decode(trunc(nvl(term.prin_first_pay_date, term.first_payment_date)) - trunc(loan.loan_start_date), 0, 'N', 'Y'),
            nvl(loan.custom_payments_flag, 'N')
        from lns_loan_headers_all loan,
            lns_terms term
        where loan.loan_id = P_LOAN_ID and
            loan.loan_id = term.loan_id;

    -- query max installment number
    CURSOR rate_sched_cur(P_TERM_ID number) IS
        select max(end_installment_number)
        from LNS_RATE_SCHEDULES
        where term_id = P_TERM_ID and
        phase = 'TERM' and
        trunc(nvl(END_DATE_ACTIVE,(sysdate+1))) > trunc(sysdate);

    -- query count of custom schedule rows with DUE_DATE < l_NEW_MATURITY_DATE
    CURSOR custom_sched_count(P_LOAN_ID number, P_MATURITY_DATE date) IS
        select count(1)
        from LNS_CUSTOM_PAYMNT_SCHEDS
        where loan_id = P_LOAN_ID
        and DUE_DATE <= P_MATURITY_DATE;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT CALC_NEW_TERMS;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    --IF FND_API.To_Boolean(p_init_msg_list) THEN
    --  FND_MSG_PUB.initialize;
    --END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'LOAN_ID:' || P_NEW_TERM_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_TERM:' || P_NEW_TERM_REC.EXT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_BALLOON_TYPE:' || P_NEW_TERM_REC.EXT_BALLOON_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_BALLOON_AMOUNT:' || P_NEW_TERM_REC.EXT_BALLOON_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_AMORT_TERM:' || P_NEW_TERM_REC.EXT_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXT_TERM_PERIOD:' || P_NEW_TERM_REC.EXT_TERM_PERIOD);

    open loan_cur(P_NEW_TERM_REC.LOAN_ID);
    fetch loan_cur
    into l_loan_start_date,
        P_NEW_TERM_REC.OLD_TERM,
        P_NEW_TERM_REC.OLD_TERM_PERIOD,
        P_NEW_TERM_REC.OLD_BALLOON_TYPE,
        P_NEW_TERM_REC.OLD_BALLOON_AMOUNT,
        P_NEW_TERM_REC.OLD_AMORT_TERM,
        P_NEW_TERM_REC.OLD_MATURITY_DATE,
        l_loan_payment_frequency,
        l_term_id,
        l_amortization_frequency,
        l_first_payment_date,
        l_pay_in_arrears,
        l_pay_calc_method,
        l_prin_first_pay_date,
        l_prin_payment_frequency,
        l_prin_pay_in_arrears,
        l_customized;
    close loan_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Current loan term data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_start_date: '|| l_loan_start_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term: '|| P_NEW_TERM_REC.OLD_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BALLOON_TYPE: '|| P_NEW_TERM_REC.OLD_BALLOON_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BALLOON_AMOUNT: '|| P_NEW_TERM_REC.OLD_BALLOON_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZED_TERM: '|| P_NEW_TERM_REC.OLD_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_TERM_PERIOD: '|| P_NEW_TERM_REC.OLD_TERM_PERIOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'maturity_date: '|| P_NEW_TERM_REC.OLD_MATURITY_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_payment_frequency: '|| l_loan_payment_frequency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'term_id: '|| l_term_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortization_frequency: ' || l_amortization_frequency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'first_payment_date: ' || l_first_payment_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'pay_in_arrears: ' || l_pay_in_arrears);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'pay_calc_method: ' || l_pay_calc_method);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'prin_first_pay_date: ' || l_prin_first_pay_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'prin_payment_frequency: ' || l_prin_payment_frequency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'prin_pay_in_arrears: ' || l_prin_pay_in_arrears);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_customized: ' || l_customized);

    open rate_sched_cur(l_term_id);
    fetch rate_sched_cur
    into P_NEW_TERM_REC.OLD_INSTALLMENTS;
    close rate_sched_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENTS: '|| P_NEW_TERM_REC.OLD_INSTALLMENTS);

    if P_NEW_TERM_REC.OLD_TERM_PERIOD = 'YEARS' then
        if P_NEW_TERM_REC.EXT_TERM_PERIOD = 'YEARS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'YEARS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'MONTHS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'MONTHS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'DAYS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'DAYS';
        end if;
    elsif P_NEW_TERM_REC.OLD_TERM_PERIOD = 'MONTHS' then
        if P_NEW_TERM_REC.EXT_TERM_PERIOD = 'YEARS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'MONTHS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'MONTHS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'MONTHS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'DAYS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'DAYS';
        end if;
    elsif P_NEW_TERM_REC.OLD_TERM_PERIOD = 'DAYS' then
        if P_NEW_TERM_REC.EXT_TERM_PERIOD = 'YEARS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'DAYS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'MONTHS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'DAYS';
        elsif P_NEW_TERM_REC.EXT_TERM_PERIOD = 'DAYS' then
            P_NEW_TERM_REC.NEW_TERM_PERIOD := 'DAYS';
        end if;
    end if;

    if P_NEW_TERM_REC.OLD_TERM_PERIOD = P_NEW_TERM_REC.EXT_TERM_PERIOD then

        P_NEW_TERM_REC.NEW_TERM := P_NEW_TERM_REC.OLD_TERM + P_NEW_TERM_REC.EXT_TERM;

        P_NEW_TERM_REC.NEW_BALLOON_TYPE := P_NEW_TERM_REC.EXT_BALLOON_TYPE;
        if P_NEW_TERM_REC.EXT_BALLOON_TYPE = 'TERM' then
            P_NEW_TERM_REC.NEW_AMORT_TERM := P_NEW_TERM_REC.OLD_AMORT_TERM + P_NEW_TERM_REC.EXT_AMORT_TERM;
            P_NEW_TERM_REC.NEW_BALLOON_AMOUNT := P_NEW_TERM_REC.OLD_BALLOON_AMOUNT;
        else
            P_NEW_TERM_REC.NEW_AMORT_TERM := P_NEW_TERM_REC.NEW_TERM;
            P_NEW_TERM_REC.NEW_BALLOON_AMOUNT := P_NEW_TERM_REC.EXT_BALLOON_AMOUNT;
        end if;

    else

        l_term1 := LNS_FIN_UTILS.intervalsInPeriod(
                                      p_period_number => P_NEW_TERM_REC.OLD_TERM
                                      ,p_period_type1 => P_NEW_TERM_REC.OLD_TERM_PERIOD
                                      ,p_period_type2 => P_NEW_TERM_REC.NEW_TERM_PERIOD);

        l_ext_term1 := LNS_FIN_UTILS.intervalsInPeriod(
                                      p_period_number => P_NEW_TERM_REC.EXT_TERM
                                      ,p_period_type1 => P_NEW_TERM_REC.EXT_TERM_PERIOD
                                      ,p_period_type2 => P_NEW_TERM_REC.NEW_TERM_PERIOD);

        P_NEW_TERM_REC.NEW_TERM := l_term1 + l_ext_term1;

        P_NEW_TERM_REC.NEW_BALLOON_TYPE := P_NEW_TERM_REC.EXT_BALLOON_TYPE;
        if P_NEW_TERM_REC.EXT_BALLOON_TYPE = 'TERM' then
            l_am_term1 := LNS_FIN_UTILS.intervalsInPeriod(
                                        p_period_number => P_NEW_TERM_REC.OLD_AMORT_TERM
                                        ,p_period_type1 => P_NEW_TERM_REC.OLD_TERM_PERIOD
                                        ,p_period_type2 => P_NEW_TERM_REC.NEW_TERM_PERIOD);

            l_ext_am_term1 := LNS_FIN_UTILS.intervalsInPeriod(
                                        p_period_number => P_NEW_TERM_REC.EXT_AMORT_TERM
                                        ,p_period_type1 => P_NEW_TERM_REC.EXT_TERM_PERIOD
                                        ,p_period_type2 => P_NEW_TERM_REC.NEW_TERM_PERIOD);

            P_NEW_TERM_REC.NEW_AMORT_TERM := l_am_term1 + l_ext_am_term1;
            P_NEW_TERM_REC.NEW_BALLOON_AMOUNT := P_NEW_TERM_REC.OLD_BALLOON_AMOUNT;
        else
            P_NEW_TERM_REC.NEW_AMORT_TERM := P_NEW_TERM_REC.NEW_TERM;
            P_NEW_TERM_REC.NEW_BALLOON_AMOUNT := P_NEW_TERM_REC.EXT_BALLOON_AMOUNT;
        end if;

    end if;

    P_NEW_TERM_REC.NEW_MATURITY_DATE := lns_fin_utils.getMaturityDate(
        p_term => P_NEW_TERM_REC.NEW_TERM,
        p_term_period => P_NEW_TERM_REC.NEW_TERM_PERIOD,
        p_frequency => l_loan_payment_frequency,
        p_start_date => l_loan_start_date);


    if l_customized = 'N' then

        -- calculating new number of installments
        if (l_pay_calc_method = 'SEPARATE_SCHEDULES') then

            if l_pay_in_arrears = 'Y' then
                l_pay_in_arrears_bool := true;
            else
                l_pay_in_arrears_bool := false;
            end if;

            if l_prin_pay_in_arrears = 'Y' then
                l_prin_pay_in_arrears_bool := true;
            else
                l_prin_pay_in_arrears_bool := false;
            end if;
/*
            l_intervals := lns_fin_utils.intervalsInPeriod(P_NEW_TERM_REC.NEW_TERM
                                                        ,P_NEW_TERM_REC.NEW_TERM_PERIOD
                                                        ,l_loan_payment_frequency);

            l_prin_intervals := lns_fin_utils.intervalsInPeriod(P_NEW_TERM_REC.NEW_TERM
                                                                ,P_NEW_TERM_REC.NEW_TERM_PERIOD
                                                                ,l_prin_payment_frequency);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_intervals: ' || l_intervals);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_prin_intervals: ' || l_prin_intervals);
*/
            l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                    p_loan_start_date      => l_loan_start_date
                                    ,p_loan_maturity_date  => P_NEW_TERM_REC.NEW_MATURITY_DATE
                                    ,p_int_first_pay_date  => l_first_payment_date
                                    ,p_int_num_intervals   => l_intervals
                                    ,p_int_interval_type   => l_loan_payment_frequency
                                    ,p_int_pay_in_arrears  => l_pay_in_arrears_bool
                                    ,p_prin_first_pay_date => l_prin_first_pay_date
                                    ,p_prin_num_intervals  => l_prin_intervals
                                    ,p_prin_interval_type  => l_prin_payment_frequency
                                    ,p_prin_pay_in_arrears => l_prin_pay_in_arrears_bool);

            P_NEW_TERM_REC.NEW_INSTALLMENTS := l_payment_tbl.count;

        else
/*
            P_NEW_TERM_REC.NEW_INSTALLMENTS := round(LNS_FIN_UTILS.intervalsInPeriod(
                                        p_period_number => P_NEW_TERM_REC.NEW_TERM
                                        ,p_period_type1 => P_NEW_TERM_REC.NEW_TERM_PERIOD
                                        ,p_period_type2 => l_loan_payment_frequency));
*/
            if l_pay_in_arrears = 'Y' then
                l_pay_in_arrears_bool := true;
            else
                l_pay_in_arrears_bool := false;
            end if;

            l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                    p_loan_start_date     => l_loan_start_date
                                    ,p_loan_maturity_date => P_NEW_TERM_REC.NEW_MATURITY_DATE
                                    ,p_first_pay_date     => l_first_payment_date
                                    ,p_num_intervals      => null
                                    ,p_interval_type      => l_loan_payment_frequency
                                    ,p_pay_in_arrears     => l_pay_in_arrears_bool);

            P_NEW_TERM_REC.NEW_INSTALLMENTS := l_payment_tbl.count;

        end if;
    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying number of custom schedule rows...');
        open custom_sched_count(P_NEW_TERM_REC.LOAN_ID, P_NEW_TERM_REC.NEW_MATURITY_DATE);
        fetch custom_sched_count
        into P_NEW_TERM_REC.NEW_INSTALLMENTS;
        close custom_sched_count;

    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New loan term data:');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'NEW_TERM: '|| P_NEW_TERM_REC.NEW_TERM);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'NEW_AMORT_TERM: '|| P_NEW_TERM_REC.NEW_AMORT_TERM);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'NEW_TERM_PERIOD: '|| P_NEW_TERM_REC.NEW_TERM_PERIOD);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'NEW_MATURITY_DATE: '|| P_NEW_TERM_REC.NEW_MATURITY_DATE);
--    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'BEGIN_EXT_INSTAL_NUMBER: '|| P_NEW_TERM_REC.BEGIN_EXT_INSTAL_NUMBER);
--    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'END_EXT_INSTAL_NUMBER: '|| P_NEW_TERM_REC.END_EXT_INSTAL_NUMBER);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'NEW_INSTALLMENTS: '|| P_NEW_TERM_REC.NEW_INSTALLMENTS);

    if (P_NEW_TERM_REC.NEW_AMORT_TERM < P_NEW_TERM_REC.NEW_TERM) then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan amortized term cannot be less than loan term.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_LOAN_TERM_INVALID');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

    end if;

    -- END OF BODY OF API
/*
    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;
*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO CALC_NEW_TERMS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO CALC_NEW_TERMS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception');
    WHEN OTHERS THEN
        --ROLLBACK TO CALC_NEW_TERMS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception');
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

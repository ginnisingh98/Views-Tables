--------------------------------------------------------
--  DDL for Package Body LNS_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FUNDING_PUB" as
/* $Header: LNS_FUNDING_B.pls 120.47.12010000.12 2010/05/14 15:57:15 scherkas ship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_FUNDING_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;
    g_org_id                        number;


PROCEDURE UPDATE_LOAN_FUNDING_STATUS(P_LOAN_ID number);

/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      init
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
 | 01-01-2004            scherkas          Created
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
 | PUBLIC FUNCTION IS_SUBMIT_DISB_ENABLED
 |
 | DESCRIPTION
 |      This function returns is submition of a disbursement header enabled or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_DISB_HEADER_D IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-07-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_SUBMIT_DISB_ENABLED(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'IS_SUBMIT_DISB_ENABLED';
    l_return            VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_DISB_HEADER_ID NUMBER) IS
        select
          CASE
		    WHEN ((nvl(loan.CURRENT_PHASE, 'TERM') = 'OPEN' and (loan.LOAN_STATUS = 'ACTIVE' OR loan.LOAN_STATUS = 'APPROVED')) OR
                  (nvl(loan.CURRENT_PHASE, 'TERM') = 'TERM' and loan.MULTIPLE_FUNDING_FLAG = 'N' and loan.LOAN_STATUS = 'APPROVED'))
            THEN
	          CASE
/*
			    WHEN ((select count(1) from LNS_COND_ASSIGNMENTS where DISB_HEADER_ID = head.DISB_HEADER_ID and
            			MANDATORY_FLAG = 'Y' and (CONDITION_MET_FLAG is null or CONDITION_MET_FLAG = 'N') and
            			(end_date_active is null or trunc(end_date_active) > trunc(sysdate))) > 0) THEN
            		'N'
            	ELSE
		          CASE
*/
				    WHEN (head.status = 'IN_FUNDING') THEN
	            		'N'
				    WHEN (head.status = 'FULLY_FUNDED') THEN
	            		'N'
				    WHEN (head.status = 'PARTIALLY_FUNDED') THEN
			          CASE
					    WHEN ((select nvl(count(1), 0) from lns_disb_lines
                        	   where disb_header_id = head.DISB_HEADER_ID and (status is null or status = 'FUNDING_ERROR')) > 0) THEN
			            	'Y'
			            ELSE
			            	'N'
			            END
				    WHEN (head.status = 'FUNDING_ERROR') THEN
	            		'Y'
				    WHEN (head.status = 'CANCELLED') THEN
	            		'N'
				    WHEN (head.status is null) THEN
			          CASE
					    WHEN ((select nvl(max(DISBURSEMENT_NUMBER), 0) + 1 from lns_disb_headers
                        	   where loan_id = head.loan_id and status = 'FULLY_FUNDED') = head.DISBURSEMENT_NUMBER) THEN
			            	'Y'
			            ELSE
			            	'N'
			            END
			        END
--            	END
		    ELSE
		        'N'
		    END
        from lns_disb_headers head,
        lns_loan_headers loan
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
			head.LOAN_ID = loan.LOAN_ID;

BEGIN
    l_return := 'N';
    OPEN get_data_crs(P_DISB_HEADER_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'IS_SUBMIT_DISB_ENABLED for disb header ' || P_DISB_HEADER_ID || ' = ' || l_return);

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION IS_CANCEL_DISB_ENABLED
 |
 | DESCRIPTION
 |      This function returns is cancel of a disbursements enabled or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_LOAN_D IN            Loan
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-07-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_CANCEL_DISB_ENABLED(P_LOAN_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'IS_CANCEL_DISB_ENABLED';
    l_return            VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_LOAN_ID NUMBER) IS
        select
          CASE
		    WHEN ((nvl(loan.CURRENT_PHASE, 'TERM') = 'OPEN' and
                    (loan.LOAN_STATUS = 'ACTIVE' OR loan.LOAN_STATUS = 'APPROVED')) OR
                  (nvl(loan.CURRENT_PHASE, 'TERM') = 'TERM' and
                    loan.MULTIPLE_FUNDING_FLAG = 'N' and loan.LOAN_STATUS = 'APPROVED'))
            THEN
            	CASE
            	  WHEN ((select nvl(count(1), 0) from lns_disb_lines line, lns_disb_headers head
						where head.loan_id = loan.LOAN_ID and head.disb_header_id = line.disb_header_id and
							(line.status is null or line.status = 'FUNDING_ERROR' or line.status = 'IN_FUNDING')) > 0) THEN
                  'Y'
            ELSE
                	'N'
             END
		    ELSE
		        'N'
		    END
        from lns_loan_headers_all loan
        where loan.LOAN_ID = P_LOAN_ID;

BEGIN
    l_return := 'N';
    OPEN get_data_crs(P_LOAN_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'IS_CANCEL_DISB_ENABLED for loan ' || P_LOAN_ID || ' = ' || l_return);

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION IS_DISB_HDR_READ_ONLY
 |
 | DESCRIPTION
 |      This function returns is disb header read only or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_DISB_HEADER_ID IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_DISB_HDR_READ_ONLY(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'IS_DISB_HDR_READ_ONLY';
    l_return            VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_DISB_HEADER_ID NUMBER) IS
        select
          CASE
		    WHEN ((nvl(loan.CURRENT_PHASE, 'TERM') = 'OPEN' and (loan.LOAN_STATUS = 'ACTIVE' OR loan.LOAN_STATUS = 'APPROVED')) OR
                  (nvl(loan.CURRENT_PHASE, 'TERM') = 'TERM' and loan.MULTIPLE_FUNDING_FLAG = 'N' and loan.LOAN_STATUS = 'APPROVED'))
            THEN
                CASE
                    WHEN (head.status is not null and (head.status = 'FULLY_FUNDED' or head.status = 'CANCELLED' or head.status = 'IN_FUNDING')) THEN
                        'Y'
                    WHEN (head.status is not null and head.status = 'PARTIALLY_FUNDED') THEN
                        CASE
                            WHEN ((select nvl(count(1), 0) from lns_disb_lines
                                where disb_header_id = head.DISB_HEADER_ID and (status is null or status = 'FUNDING_ERROR')) > 0) THEN
                                'N'
                            ELSE
                                'Y'
                            END
                    ELSE
                        'N'
                    END
            ELSE
                'Y'
            END
        from lns_disb_headers head,
            lns_loan_headers_all loan
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
            head.loan_id = loan.loan_id;

BEGIN
    l_return := 'N';
    OPEN get_data_crs(P_DISB_HEADER_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'IS_DISB_HDR_READ_ONLY for disb header ' || P_DISB_HEADER_ID || ' = ' || l_return);

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION IS_DISB_LINE_READ_ONLY
 |
 | DESCRIPTION
 |      This function returns is disb line read only or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_DISB_LINE_ID IN            Disbursement line
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_DISB_LINE_READ_ONLY(P_DISB_LINE_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'IS_DISB_LINE_READ_ONLY';
    l_return            VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_DISB_LINE_ID NUMBER) IS
        select
          CASE
		    WHEN (loan.loan_status = 'INCOMPLETE') THEN
                'N'
            WHEN LNS_FUNDING_PUB.IS_DISB_HDR_READ_ONLY(line.DISB_HEADER_ID) = 'Y' THEN
                'Y'
            ELSE
                CASE
                    WHEN (line.status is not null and (line.status = 'FULLY_FUNDED' or
                          line.status = 'PARTIALLY_FUNDED' or line.status = 'CANCELLED' or
                          line.status = 'IN_FUNDING'))
                    THEN
                        'Y'
                    ELSE
                        'N'
                    END
            END
        from lns_disb_lines line,
            lns_disb_headers head,
            lns_loan_headers_all loan
        where line.DISB_LINE_ID = P_DISB_LINE_ID and
            line.disb_header_id = head.disb_header_id and
            head.loan_id = loan.loan_id;

BEGIN
    l_return := 'N';
    OPEN get_data_crs(P_DISB_LINE_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'IS_DISB_LINE_READ_ONLY for disb line ' || P_DISB_LINE_ID || ' = ' || l_return);

    return l_return;
END;



/*========================================================================
 | PUBLIC FUNCTION IS_LAST_DISB_BEFORE_CONV
 |
 | DESCRIPTION
 |      This function returns is it last disb header before loan conversion.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_DISB_HEADER_ID IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_LAST_DISB_BEFORE_CONV(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'IS_LAST_DISB_BEFORE_CONV';
    l_return            VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_data_crs(P_DISB_HEADER_ID NUMBER) IS
        select
          CASE
		    WHEN (loan.current_phase = 'OPEN' and loan.OPEN_TO_TERM_FLAG = 'Y' and loan.OPEN_TO_TERM_EVENT = 'AUTO_FINAL_DISBURSEMENT') THEN
                CASE
                    WHEN ((select max(DISBURSEMENT_NUMBER) from lns_disb_headers where loan_id = loan.loan_id) = head.DISBURSEMENT_NUMBER) THEN
                        'Y'
                    ELSE
                        'N'
                    END
            ELSE
            	'N'
            END
        from lns_disb_headers head,
            lns_loan_headers_all loan
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
            head.loan_id = loan.loan_id;

BEGIN
    l_return := 'N';
    OPEN get_data_crs(P_DISB_HEADER_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;
    LogMessage(FND_LOG.LEVEL_STATEMENT, l_api_name || ' for disb header ' || P_DISB_HEADER_ID || ' = ' || l_return);

    return l_return;
END;



/*========================================================================
 | PUBLIC PROCEDURE INSERT_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure inserts new disbursement header
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_REC       IN          LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INSERT_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_REC       IN              LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'INSERT_DISB_HEADER';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_pk_id                         NUMBER;
    l_phase                         VARCHAR2(30);
    l_disb_number                   number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT INSERT_DISB_HEADER;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting disbursement header...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_DISB_HEADER_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ACTIVITY_CODE: ' || P_DISB_HEADER_REC.ACTIVITY_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISBURSEMENT_NUMBER: ' || P_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_AMOUNT: ' || P_DISB_HEADER_REC.HEADER_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_PERCENT: ' || P_DISB_HEADER_REC.HEADER_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'STATUS: ' || P_DISB_HEADER_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OBJECT_VERSION_NUMBER: ' || P_DISB_HEADER_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_REQUEST_DATE: ' || P_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'TARGET_DATE: ' || P_DISB_HEADER_REC.TARGET_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AUTOFUNDING_FLAG: ' || P_DISB_HEADER_REC.AUTOFUNDING_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || P_DISB_HEADER_REC.PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DESCRIPTION: ' || P_DISB_HEADER_REC.DESCRIPTION);

    l_phase := P_DISB_HEADER_REC.PHASE;
    if l_phase is null then
        l_phase := 'OPEN';
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_phase);

    -- validation
    l_pk_id := P_DISB_HEADER_REC.DISB_HEADER_ID;

    if P_DISB_HEADER_REC.LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'loan_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    l_disb_number := P_DISB_HEADER_REC.DISBURSEMENT_NUMBER;
    if P_DISB_HEADER_REC.DISBURSEMENT_NUMBER is null then

        select nvl(max(disbursement_number),0)+1 into l_disb_number
        from lns_disb_headers
        where loan_id = P_DISB_HEADER_REC.LOAN_ID and phase = l_phase;

    end if;

    -- calling table handler api
    LNS_DISB_HEADERS_PKG.Insert_Row(
        X_DISB_HEADER_ID		=> l_pk_id,
        P_LOAN_ID		        => P_DISB_HEADER_REC.LOAN_ID,
        P_ACTIVITY_CODE		    => P_DISB_HEADER_REC.ACTIVITY_CODE,
        P_DISBURSEMENT_NUMBER	=> l_disb_number,
        P_HEADER_AMOUNT		    => P_DISB_HEADER_REC.HEADER_AMOUNT,
        P_HEADER_PERCENT		=> P_DISB_HEADER_REC.HEADER_PERCENT,
        P_STATUS		        => P_DISB_HEADER_REC.STATUS,
        P_TARGET_DATE           => P_DISB_HEADER_REC.TARGET_DATE,
        P_PAYMENT_REQUEST_DATE  => P_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
        P_OBJECT_VERSION_NUMBER	=> nvl(P_DISB_HEADER_REC.OBJECT_VERSION_NUMBER, 1),
        P_AUTOFUNDING_FLAG      => P_DISB_HEADER_REC.AUTOFUNDING_FLAG,
        P_PHASE                 => l_phase,
        P_DESCRIPTION           => P_DISB_HEADER_REC.DESCRIPTION);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID: ' || l_pk_id);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted disbursement header' || l_pk_id);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO INSERT_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO INSERT_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO INSERT_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE UPDATE_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure updates disbursement header
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
 |      P_DISB_HEADER_REC       IN          LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_REC       IN              LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'UPDATE_DISB_HEADER';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_disb_header_version           number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info from db
    CURSOR disb_head_cur(P_DISB_HEADER_ID number) IS
        select OBJECT_VERSION_NUMBER
        from lns_disb_headers
        where disb_header_id = P_DISB_HEADER_ID;
--        FOR UPDATE OF disb_header_id NOWAIT;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT UPDATE_DISB_HEADER;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating disbursement header...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID: ' || P_DISB_HEADER_REC.DISB_HEADER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_DISB_HEADER_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ACTIVITY_CODE: ' || P_DISB_HEADER_REC.ACTIVITY_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISBURSEMENT_NUMBER: ' || P_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_AMOUNT: ' || P_DISB_HEADER_REC.HEADER_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_PERCENT: ' || P_DISB_HEADER_REC.HEADER_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'STATUS: ' || P_DISB_HEADER_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OBJECT_VERSION_NUMBER: ' || P_DISB_HEADER_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_REQUEST_DATE: ' || P_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'TARGET_DATE: ' || P_DISB_HEADER_REC.TARGET_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AUTOFUNDING_FLAG: ' || P_DISB_HEADER_REC.AUTOFUNDING_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || P_DISB_HEADER_REC.PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DESCRIPTION: ' || P_DISB_HEADER_REC.DESCRIPTION);

    -- validation

    if P_DISB_HEADER_REC.DISB_HEADER_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_header_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- getting disbursement header info from db
    open disb_head_cur(P_DISB_HEADER_REC.DISB_HEADER_ID);
    fetch disb_head_cur into l_disb_header_version;

    if disb_head_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No disbursement header record found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement header');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_HEADER_REC.DISB_HEADER_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close disb_head_cur;

    if l_disb_header_version <> P_DISB_HEADER_REC.OBJECT_VERSION_NUMBER then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header record has already been changed');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'LNS_DISB_HEADERS');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    l_disb_header_version := nvl(l_disb_header_version, 1) + 1;

    -- calling table handler api
    LNS_DISB_HEADERS_PKG.Update_Row(
        P_DISB_HEADER_ID		=> P_DISB_HEADER_REC.DISB_HEADER_ID,
        P_LOAN_ID		        => P_DISB_HEADER_REC.LOAN_ID,
        P_ACTIVITY_CODE		    => P_DISB_HEADER_REC.ACTIVITY_CODE,
        P_DISBURSEMENT_NUMBER	=> P_DISB_HEADER_REC.DISBURSEMENT_NUMBER,
        P_HEADER_AMOUNT		    => P_DISB_HEADER_REC.HEADER_AMOUNT,
        P_HEADER_PERCENT		=> P_DISB_HEADER_REC.HEADER_PERCENT,
        P_STATUS		        => P_DISB_HEADER_REC.STATUS,
        P_TARGET_DATE           => P_DISB_HEADER_REC.TARGET_DATE,
        P_PAYMENT_REQUEST_DATE  => P_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
        P_OBJECT_VERSION_NUMBER	=> l_disb_header_version,
        P_AUTOFUNDING_FLAG      => P_DISB_HEADER_REC.AUTOFUNDING_FLAG,
        P_PHASE                 => P_DISB_HEADER_REC.PHASE,
        P_DESCRIPTION           => P_DISB_HEADER_REC.DESCRIPTION);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated disbursement header ' || P_DISB_HEADER_REC.DISB_HEADER_ID);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE DELETE_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure updates disbursement header
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
 |      P_DISB_HEADER_IDC       IN          Disbursement Header ID
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE DELETE_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_ID        IN              NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'DELETE_DISB_HEADER';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_status                        VARCHAR2(30);
    l_disb_line_id                  number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info from db
    CURSOR disb_head_cur(P_DISB_HEADER_ID number) IS
        select status
        from lns_disb_headers
        where disb_header_id = P_DISB_HEADER_ID;

    -- getting disbursement lines
    CURSOR disb_line_cur(P_DISB_HEADER_ID number) IS
        select
            DISB_LINE_ID
        from LNS_DISB_LINES
        where DISB_HEADER_ID = P_DISB_HEADER_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT DELETE_DISB_HEADER;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting disbursement header...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID: ' || P_DISB_HEADER_ID);
    -- validation

    if P_DISB_HEADER_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_header_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- getting disbursement header info from db
    open disb_head_cur(P_DISB_HEADER_ID);
    fetch disb_head_cur into l_status;

    if disb_head_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No disbursement header record found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement header');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_HEADER_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close disb_head_cur;

    if l_status is not null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Cannot delete disbursement header. It has already been processed.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_DEL_DISB_HDR');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    open disb_line_cur(P_DISB_HEADER_ID);
    LOOP

        fetch disb_line_cur into l_disb_line_id;
        exit when disb_line_cur%NOTFOUND;

        DELETE_DISB_LINE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_LINE_ID          => l_disb_line_id,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to DELETE_DISB_LINE failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;
    close disb_line_cur;

    -- deteting conditions assignments and fees
    LNS_FEE_ASSIGNMENT_PUB.delete_DISB_FEE_ASSIGNMENT(P_DISB_HEADER_ID);
    LNS_COND_ASSIGNMENT_PUB.delete_DISB_COND_ASSIGNMENT(P_DISB_HEADER_ID);

    delete from lns_distributions where disb_header_id = P_DISB_HEADER_ID;

    -- calling table handler api
    LNS_DISB_HEADERS_PKG.Delete_Row(P_DISB_HEADER_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully deleted disbursement header ' || P_DISB_HEADER_ID);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DELETE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DELETE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO DELETE_DISB_HEADER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE INSERT_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure inserts new disbursement LINE
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
 |      P_DISB_LINE_REC         IN          LNS_FUNDING_PUB.LNS_DISB_LINES_REC
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INSERT_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_REC         IN              LNS_FUNDING_PUB.LNS_DISB_LINES_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'INSERT_DISB_LINE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_pk_id                         NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT INSERT_DISB_LINE;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting disbursement line...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISB_HEADER_ID: ' || P_DISB_LINE_REC.DISB_HEADER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.LINE_AMOUNT: ' || P_DISB_LINE_REC.LINE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.LINE_PERCENT: ' || P_DISB_LINE_REC.LINE_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.PAYEE_PARTY_ID: ' || P_DISB_LINE_REC.PAYEE_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.BANK_ACCOUNT_ID: ' || P_DISB_LINE_REC.BANK_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.PAYMENT_METHOD_CODE: ' || P_DISB_LINE_REC.PAYMENT_METHOD_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.STATUS: ' || P_DISB_LINE_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.REQUEST_DATE: ' || P_DISB_LINE_REC.REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISBURSEMENT_DATE: ' || P_DISB_LINE_REC.DISBURSEMENT_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.OBJECT_VERSION_NUMBER: ' || P_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.INVOICE_INTERFACE_ID: ' || P_DISB_LINE_REC.INVOICE_INTERFACE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.INVOICE_ID: ' || P_DISB_LINE_REC.INVOICE_ID);

    -- validation
    l_pk_id := P_DISB_LINE_REC.DISB_LINE_ID;

    if P_DISB_LINE_REC.DISB_HEADER_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_header_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if P_DISB_LINE_REC.LINE_PERCENT is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Line percent is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE_PERC');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if P_DISB_LINE_REC.PAYEE_PARTY_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payee party ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_DISB_LINES_PKG.Insert_Row');

    -- calling table handler api
    LNS_DISB_LINES_PKG.Insert_Row(
        X_DISB_LINE_ID		    => l_pk_id,
        P_DISB_HEADER_ID		=> P_DISB_LINE_REC.DISB_HEADER_ID,
        P_DISB_LINE_NUMBER		=> P_DISB_LINE_REC.DISB_LINE_NUMBER,
        P_LINE_AMOUNT		    => P_DISB_LINE_REC.LINE_AMOUNT,
        P_LINE_PERCENT		    => P_DISB_LINE_REC.LINE_PERCENT,
        P_PAYEE_PARTY_ID		=> P_DISB_LINE_REC.PAYEE_PARTY_ID,
        P_BANK_ACCOUNT_ID		=> P_DISB_LINE_REC.BANK_ACCOUNT_ID,
        P_PAYMENT_METHOD_CODE	=> P_DISB_LINE_REC.PAYMENT_METHOD_CODE,
        P_STATUS                => P_DISB_LINE_REC.STATUS,
        P_REQUEST_DATE		    => P_DISB_LINE_REC.REQUEST_DATE,
        P_DISBURSEMENT_DATE     => P_DISB_LINE_REC.DISBURSEMENT_DATE,
        P_OBJECT_VERSION_NUMBER	=> nvl(P_DISB_LINE_REC.OBJECT_VERSION_NUMBER, 1),
        P_INVOICE_INTERFACE_ID  => P_DISB_LINE_REC.INVOICE_INTERFACE_ID,
        P_INVOICE_ID            => P_DISB_LINE_REC.INVOICE_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISB_LINE_ID: ' || l_pk_id);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted disbursement line ' || l_pk_id);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO INSERT_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO INSERT_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO INSERT_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE UPDATE_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure updates disbursement LINE
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
 |      P_DISB_LINE_REC         IN          LNS_FUNDING_PUB.LNS_DISB_LINES_REC
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_REC         IN              LNS_FUNDING_PUB.LNS_DISB_LINES_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'UPDATE_DISB_LINE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_disb_line_version             number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement line info from db
    CURSOR disb_line_cur(P_DISB_LINE_ID number) IS
        select OBJECT_VERSION_NUMBER
        from lns_disb_lines
        where disb_line_id = P_DISB_LINE_ID;
--        FOR UPDATE OF disb_line_id NOWAIT;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT UPDATE_DISB_LINE;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating disbursement line...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISB_LINE_ID: ' || P_DISB_LINE_REC.DISB_LINE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISB_HEADER_ID: ' || P_DISB_LINE_REC.DISB_HEADER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.LINE_AMOUNT: ' || P_DISB_LINE_REC.LINE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.LINE_PERCENT: ' || P_DISB_LINE_REC.LINE_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.PAYEE_PARTY_ID: ' || P_DISB_LINE_REC.PAYEE_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.BANK_ACCOUNT_ID: ' || P_DISB_LINE_REC.BANK_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.PAYMENT_METHOD_CODE: ' || P_DISB_LINE_REC.PAYMENT_METHOD_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.STATUS: ' || P_DISB_LINE_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.REQUEST_DATE: ' || P_DISB_LINE_REC.REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.DISBURSEMENT_DATE: ' || P_DISB_LINE_REC.DISBURSEMENT_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.OBJECT_VERSION_NUMBER: ' || P_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.INVOICE_INTERFACE_ID: ' || P_DISB_LINE_REC.INVOICE_INTERFACE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_REC.INVOICE_ID: ' || P_DISB_LINE_REC.INVOICE_ID);

    -- validation

    if P_DISB_LINE_REC.DISB_LINE_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement line ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_line_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- getting disbursement line info from db
    open disb_line_cur(P_DISB_LINE_REC.DISB_LINE_ID);
    fetch disb_line_cur into l_disb_line_version;

    if disb_line_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No disbursement line record found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement line');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_LINE_REC.DISB_LINE_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close disb_line_cur;

    if l_disb_line_version <> P_DISB_LINE_REC.OBJECT_VERSION_NUMBER then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement line record has already been changed');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'LNS_DISB_LINES');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    l_disb_line_version := nvl(l_disb_line_version, 1) + 1;

    -- calling table handler api
    LNS_DISB_LINES_PKG.Update_Row(
        P_DISB_LINE_ID		    => P_DISB_LINE_REC.DISB_LINE_ID,
        P_DISB_HEADER_ID		=> P_DISB_LINE_REC.DISB_HEADER_ID,
        P_DISB_LINE_NUMBER		=> P_DISB_LINE_REC.DISB_LINE_NUMBER,
        P_LINE_AMOUNT		    => P_DISB_LINE_REC.LINE_AMOUNT,
        P_LINE_PERCENT		    => P_DISB_LINE_REC.LINE_PERCENT,
        P_PAYEE_PARTY_ID		=> P_DISB_LINE_REC.PAYEE_PARTY_ID,
        P_BANK_ACCOUNT_ID		=> P_DISB_LINE_REC.BANK_ACCOUNT_ID,
        P_PAYMENT_METHOD_CODE	=> P_DISB_LINE_REC.PAYMENT_METHOD_CODE,
        P_STATUS                => P_DISB_LINE_REC.STATUS,
        P_REQUEST_DATE		    => P_DISB_LINE_REC.REQUEST_DATE,
        P_DISBURSEMENT_DATE     => P_DISB_LINE_REC.DISBURSEMENT_DATE,
        P_OBJECT_VERSION_NUMBER	=> l_disb_line_version,
        P_INVOICE_INTERFACE_ID  => P_DISB_LINE_REC.INVOICE_INTERFACE_ID,
        P_INVOICE_ID            => P_DISB_LINE_REC.INVOICE_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated disbursement line ' || P_DISB_LINE_REC.DISB_LINE_ID);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE DELETE_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure updates disbursement LINE
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
 |      P_DISB_LINE_IDC         IN          Disbursement LINE ID
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE DELETE_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_ID          IN              NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'DELETE_DISB_LINE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_status                        VARCHAR2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header and line info from db
    CURSOR disb_head_cur(P_DISB_LINE_ID number) IS
        select hdr.status
        from lns_disb_headers hdr,
        lns_disb_lines ln
        where hdr.disb_header_id = ln.disb_header_id and
        ln.disb_line_id = P_DISB_LINE_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT DELETE_DISB_LINE;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting disbursement line...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_LINE_ID: ' || P_DISB_LINE_ID);

    -- validation

    if P_DISB_LINE_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement line ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_line_id' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- getting disbursement header and line info from db
    open disb_head_cur(P_DISB_LINE_ID);
    fetch disb_head_cur into l_status;

    if disb_head_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No disbursement line record found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement line');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_LINE_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close disb_head_cur;

    if l_status is not null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Cannot delete disbursement line. It has already been processed.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_DEL_DISB_LN');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- calling table handler api
    LNS_DISB_LINES_PKG.Delete_Row(P_DISB_LINE_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully deleted disbursement line ' || P_DISB_LINE_ID);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DELETE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DELETE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO DELETE_DISB_LINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE CREATE_EXT_IBY_PAYEE
 |
 | DESCRIPTION
 |      This procedure creates external IBY payee
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_DISB_HEADER_ID        IN          Disbursement header ID
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
 | 07-27-2005            scherkas          Created
 | 22-03-2006            karamach          Added check for LOANS_PAYMENT payment_function in the payees_cur cursor to check for existing payees to fix bug5112534
 | 16-05-2006            karamach          Made changes to fix api parameters and add error message checks to fix bug5226980
 |
 *=======================================================================*/
PROCEDURE CREATE_EXT_IBY_PAYEE(
    P_DISB_HEADER_ID        IN          NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_EXT_IBY_PAYEE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Payee_Party_Id                number;
    l_org_id                        number;
    l_count                         number;

    l_External_Payee_Tab            IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
    l_Ext_Payee_ID_Tab              IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_ID_Tab_Type;
    l_Ext_Payee_Create_Tab          IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting payees
    CURSOR payees_cur(P_DISB_HEADER_ID number) IS
        select line.PAYEE_PARTY_ID,
            loan.org_id
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
            head.DISB_HEADER_ID = line.DISB_HEADER_ID and
            head.loan_id = loan.loan_id and not exists
			(select PAYEE_PARTY_ID
            from IBY_EXTERNAL_PAYEES_ALL
            where PAYEE_PARTY_ID = line.PAYEE_PARTY_ID and org_id = loan.org_id and payment_function = 'LOANS_PAYMENTS');
BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Creating external iby payees...');

    -- getting payees
    l_count := 0;
    open payees_cur(P_DISB_HEADER_ID);
    LOOP

        fetch payees_cur into l_Payee_Party_Id, l_org_id;
        exit when payees_cur%NOTFOUND;

        l_count := l_count + 1;
        l_External_Payee_Tab(l_count).Payee_Party_Id := l_Payee_Party_Id;

        -- fix for bug 8781164: dont pass Payer_Org_Id and Payer_Org_Type to Create_External_Payee
        --l_External_Payee_Tab(l_count).Payer_Org_Id := l_org_id;
	    --karamach bug5226980 Pass Payer_Org_Type as well if passing org_id
   	    --l_External_Payee_Tab(l_count).Payer_Org_Type := 'OPERATING_UNIT';

        l_External_Payee_Tab(l_count).Payment_Function := 'LOANS_PAYMENTS';
        l_External_Payee_Tab(l_count).Exclusive_Pay_Flag := 'N';

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee #' || l_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_Party_Id: ' || l_External_Payee_Tab(l_count).Payee_Party_Id);
        --LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payer_Org_Id: ' || l_External_Payee_Tab(l_count).Payer_Org_Id);
        --LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payer_Org_Type: ' || l_External_Payee_Tab(l_count).Payer_Org_Type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Function: ' || l_External_Payee_Tab(l_count).Payment_Function);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Exclusive_Pay_Flag: ' || l_External_Payee_Tab(l_count).Exclusive_Pay_Flag);

    END LOOP;
    close payees_cur;

    if l_External_Payee_Tab.count > 0 then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee...');
        IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_TRUE,
            p_ext_payee_tab         => l_External_Payee_Tab,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            x_ext_payee_id_tab      => l_Ext_Payee_ID_Tab,
            x_ext_payee_status_tab  => l_Ext_Payee_Create_Tab);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

        FOR l_Count IN 1..l_Ext_Payee_ID_Tab.COUNT LOOP
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_Ext_Payee_ID_Tab(' || l_Count || ').Ext_Payee_ID: ' || l_Ext_Payee_ID_Tab(l_Count).Ext_Payee_ID);
        END LOOP;

        FOR l_Count IN 1..l_Ext_Payee_ID_Tab.COUNT LOOP
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_Ext_Payee_Create_Tab(' || l_Count || ').Payee_Creation_Status: ' || l_Ext_Payee_Create_Tab(l_Count).Payee_Creation_Status);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_Ext_Payee_Create_Tab(' || l_Count || ').Payee_Creation_Msg: ' || l_Ext_Payee_Create_Tab(l_Count).Payee_Creation_Msg);
		--karamach bug5226980
		l_return_status := l_Ext_Payee_Create_Tab(l_Count).Payee_Creation_Status;
        	if (l_Ext_Payee_Create_Tab(l_Count).Payee_Creation_Status = 'E') then
        		FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
       			FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee' || ' Payee_Creation_Msg: ' || l_Ext_Payee_Create_Tab(l_Count).Payee_Creation_Msg);
        		FND_MSG_PUB.ADD;
            		RAISE FND_API.G_EXC_ERROR;
        	end if;
        END LOOP;

        if l_return_status = 'E' then
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
       		FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee');
        	FND_MSG_PUB.ADD;
        	FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);
            	RAISE FND_API.G_EXC_ERROR;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully created external iby payees');

    end if;

    -- END OF BODY OF API
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_FOR_APPR
 |
 | DESCRIPTION
 |      This procedure validates disbursement schedule for approval process.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_FOR_APPR(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_FOR_APPR';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_count                         number;
    l_sum_percent                   number;
    l_running_sum                   number;
    l_count1                        number;
    l_sum_percent1                  number;
    l_running_sum1                  number;
    l_funded_amount                 number;
    l_loan_currency                 varchar2(15);
    l_loan_start_date               date;
    l_loan_maturity_date            date;
    l_party_site_id                 number;
    l_due_date                      date;
    l_current_phase                 varchar2(30);

    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting loan info
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select nvl(loan.current_phase, 'TERM')
        from LNS_LOAN_HEADERS loan
        where loan.LOAN_ID = P_LOAN_ID;

    -- getting disbursement header info
    CURSOR disb_headers_cur(P_LOAN_ID number) IS
        select
            loan.REQUESTED_AMOUNT,
            loan.LOAN_CURRENCY,
            head.DISB_HEADER_ID,
            head.LOAN_ID,
            head.ACTIVITY_CODE,
            head.DISBURSEMENT_NUMBER,
            head.HEADER_AMOUNT,
            head.HEADER_PERCENT,
            head.STATUS,
            head.TARGET_DATE,
            decode(nvl(loan.CURRENT_PHASE, 'TERM'), 'TERM', loan.LOAN_START_DATE, loan.OPEN_LOAN_START_DATE),
            loan.OPEN_MATURITY_DATE
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where loan.LOAN_ID = P_LOAN_ID and
            head.LOAN_ID = loan.LOAN_ID
        order by head.DISBURSEMENT_NUMBER;

    -- getting disbursement lines
    CURSOR disb_lines_cur(P_DISB_HEADER_ID number) IS
        select
            line.disb_header_id,
            line.DISB_LINE_NUMBER,
            line.LINE_AMOUNT,
            line.LINE_PERCENT,
            line.PAYEE_PARTY_ID,
            line.BANK_ACCOUNT_ID,
            line.PAYMENT_METHOD_CODE,
            line.REQUEST_DATE,
            nvl(head.PAYMENT_REQUEST_DATE, head.TARGET_DATE)
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head
        where line.DISB_HEADER_ID = P_DISB_HEADER_ID and
            line.DISB_HEADER_ID = head.DISB_HEADER_ID
        order by line.DISB_LINE_NUMBER;

    -- validate party_site for the party
    CURSOR party_site_cur(P_PARTY_ID number, P_DATE date) IS
        SELECT party_site_id
        FROM   HZ_Party_Sites HPS
        WHERE  HPS.Party_ID = P_PARTY_ID
        AND    HPS.Identifying_Address_Flag = 'Y'
        AND    NVL(HPS.Start_Date_Active, P_DATE) = P_DATE;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);

    open loan_info_cur(P_LOAN_ID);
    fetch loan_info_cur into l_current_phase;
    close loan_info_cur;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Current phase: ' || l_current_phase);

    if l_current_phase = 'TERM' then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating disbursement schedule...');

    -- getting all disbursement headers
    l_count := 0;
    l_sum_percent := 0;
    l_running_sum := 0;
    open disb_headers_cur(P_LOAN_ID);

    LOOP

        fetch disb_headers_cur into
            l_funded_amount,
            l_loan_currency,
            l_DISB_HEADER_REC.DISB_HEADER_ID,
            l_DISB_HEADER_REC.LOAN_ID,
            l_DISB_HEADER_REC.ACTIVITY_CODE,
            l_DISB_HEADER_REC.DISBURSEMENT_NUMBER,
            l_DISB_HEADER_REC.HEADER_AMOUNT,
            l_DISB_HEADER_REC.HEADER_PERCENT,
            l_DISB_HEADER_REC.STATUS,
            l_DISB_HEADER_REC.TARGET_DATE,
            l_loan_start_date,
            l_loan_maturity_date;

        if disb_headers_cur%NOTFOUND and l_count = 0 then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    --        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: Disbursement schedule is not found');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CREATE_DISB_SCHED');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        elsif disb_headers_cur%NOTFOUND and l_count > 0 then
            exit;
        end if;

        l_count := l_count + 1;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement header #' || l_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ID: ' || l_DISB_HEADER_REC.LOAN_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header ID: ' || l_DISB_HEADER_REC.DISB_HEADER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Activity Code: ' || l_DISB_HEADER_REC.ACTIVITY_CODE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Number: ' || l_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amount: ' || l_DISB_HEADER_REC.HEADER_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Percent: ' || l_DISB_HEADER_REC.HEADER_PERCENT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Status: ' || l_DISB_HEADER_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Target Date: ' || l_DISB_HEADER_REC.TARGET_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Requested Amount: ' || l_funded_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Currency: ' || l_loan_currency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Open loan start date: ' || l_loan_start_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Open loan maturity date: ' || l_loan_maturity_date);

        if l_DISB_HEADER_REC.LOAN_ID is null then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan ID is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'loan id' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.ACTIVITY_CODE is null then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Activity code is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_ACTIV' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.HEADER_PERCENT is null or l_DISB_HEADER_REC.HEADER_AMOUNT is null then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement percent is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_PERC' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.TARGET_DATE is null then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Target date is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_TARGET_DATE' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if trunc(l_DISB_HEADER_REC.TARGET_DATE) < trunc(l_loan_start_date) then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Target date must be later that start date');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_DISB_TARGET_DATE_ERR' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        l_sum_percent := l_sum_percent + l_DISB_HEADER_REC.HEADER_PERCENT;
        l_running_sum := l_running_sum + l_DISB_HEADER_REC.HEADER_AMOUNT;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating disbursement lines...');

        -- getting disbursement lines
        l_count1 := 0;
        l_sum_percent1 := 0;
        l_running_sum1 := 0;
        open disb_lines_cur(l_DISB_HEADER_REC.DISB_HEADER_ID);

        LOOP

            fetch disb_lines_cur into
                l_DISB_LINE_REC.DISB_HEADER_ID,
                l_DISB_LINE_REC.DISB_LINE_NUMBER,
                l_DISB_LINE_REC.LINE_AMOUNT,
                l_DISB_LINE_REC.LINE_PERCENT,
                l_DISB_LINE_REC.PAYEE_PARTY_ID,
                l_DISB_LINE_REC.BANK_ACCOUNT_ID,
                l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
                l_DISB_LINE_REC.REQUEST_DATE,
                l_due_date;

            if disb_lines_cur%NOTFOUND and l_count1 = 0 then

        --        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: Disbursement lines are not found');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
                FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement line record');
                FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(l_DISB_HEADER_REC.DISB_HEADER_ID), 'null'));
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            elsif disb_lines_cur%NOTFOUND and l_count1 > 0 then
                exit;
            end if;

            l_count1 := l_count1 + 1;

            LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement line #' || l_count);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID: ' || l_DISB_LINE_REC.DISB_HEADER_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Number: ' || l_DISB_LINE_REC.DISB_LINE_NUMBER);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amount: ' || l_DISB_LINE_REC.LINE_AMOUNT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Percent: ' || l_DISB_LINE_REC.LINE_PERCENT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee Party ID: ' || l_DISB_LINE_REC.PAYEE_PARTY_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Bank Account ID: ' || l_DISB_LINE_REC.BANK_ACCOUNT_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Method Code: ' || l_DISB_LINE_REC.PAYMENT_METHOD_CODE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Request Date: ' || l_DISB_LINE_REC.REQUEST_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Due date: ' || l_due_date);

            if l_DISB_LINE_REC.DISB_HEADER_ID is null then

                FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    --            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header is missing');
                FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_header_id' );
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            end if;

            if l_DISB_LINE_REC.LINE_PERCENT is null or l_DISB_LINE_REC.LINE_AMOUNT is null then

                FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    --            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Line percent is missing');
                FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE_PERC' );
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            end if;

            if l_DISB_LINE_REC.PAYEE_PARTY_ID is null then

                FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    --            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payee party ID is missing');
                FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE' );
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            end if;

            -- validate party_site for the party
            open party_site_cur(l_DISB_LINE_REC.PAYEE_PARTY_ID, l_due_date);
            fetch party_site_cur into l_party_site_id;

            -- if no record exists - error; otherwise proceed
            if party_site_cur%NOTFOUND then

                FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

        --        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: No site exist for the party');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_CREATE_PARTY_SITE');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            end if;
            close party_site_cur;

            l_sum_percent1 := l_sum_percent1 + l_DISB_LINE_REC.LINE_PERCENT;
            l_running_sum1 := l_running_sum1 + l_DISB_LINE_REC.LINE_AMOUNT;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement line ' || l_count1 || ' is OK');

        END LOOP;

        close disb_lines_cur;

        -- checking for total percent
        if l_sum_percent1 <> 100 or l_running_sum1 <> l_DISB_HEADER_REC.HEADER_AMOUNT then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total percentage of all lines: ' || l_sum_percent1);
            FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_LN_PERC_INVALID');
            FND_MESSAGE.SET_TOKEN('DISB_NUM', l_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement header ' || l_count || ' is OK');

    END LOOP;

    close disb_headers_cur;

    -- checking for total percent
    if l_sum_percent <> 100 or l_running_sum <> l_funded_amount then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBM_APPR_AND_DISB');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total percentage of all disbursements: ' || l_sum_percent);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_HDR_PERC_INVALID');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated disbursement schedule');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_FOR_SUBMIT
 |
 | DESCRIPTION
 |      This procedure validates all disbursement headers.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement header ID
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_FOR_SUBMIT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_DISB_HEADER_ID        IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_FOR_SUBMIT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_no_pay_mtd_count              NUMBER;
    l_open_start_date               DATE;

    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header and lines info
    CURSOR validate_cur(P_DISB_HEADER_ID number) IS
        select
            head.ACTIVITY_CODE,
            head.DESCRIPTION,
            head.HEADER_AMOUNT,
            head.HEADER_PERCENT,
            head.PAYMENT_REQUEST_DATE,
            head.phase,
            decode(loan.current_phase, 'OPEN', loan.OPEN_LOAN_START_DATE, loan.LOAN_START_DATE),
            (select count(1) from lns_disb_lines where disb_header_id = head.DISB_HEADER_ID and
             PAYMENT_METHOD_CODE is null)
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
            head.LOAN_ID = loan.LOAN_ID and
            nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN');

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating disbursement header for payment request submition...');

    -- getting disbursement header and lines info
    open validate_cur(P_DISB_HEADER_ID);
    fetch validate_cur into l_DISB_HEADER_REC.ACTIVITY_CODE,
                            l_DISB_HEADER_REC.DESCRIPTION,
                            l_DISB_HEADER_REC.HEADER_AMOUNT,
                            l_DISB_HEADER_REC.HEADER_PERCENT,
                            l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
                            l_DISB_HEADER_REC.PHASE,
                            l_open_start_date,
                            l_no_pay_mtd_count;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ACTIVITY_CODE: ' || l_DISB_HEADER_REC.ACTIVITY_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DESCRIPTION: ' || l_DISB_HEADER_REC.DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_AMOUNT: ' || l_DISB_HEADER_REC.HEADER_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'HEADER_PERCENT: ' || l_DISB_HEADER_REC.HEADER_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_REQUEST_DATE: ' || l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_DISB_HEADER_REC.PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_open_start_date: ' || l_open_start_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_no_pay_mtd_count: ' || l_no_pay_mtd_count);

    -- if no record exists - return; otherwise proceed
    if validate_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: Disbursement Header Record is not found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'disbursement header record');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_HEADER_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close validate_cur;

    if l_DISB_HEADER_REC.ACTIVITY_CODE is null and l_DISB_HEADER_REC.DESCRIPTION is null then

--          LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Activity code is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_ACTIV' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if l_DISB_HEADER_REC.HEADER_AMOUNT is null then

--          LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement percent is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_PERC' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- validate Payment request date
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment request date: ' || l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    if l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payment request date is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAY_REQ_DATE' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if trunc(l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE) < trunc(l_open_start_date) then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payment request date must be greater than open start date');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_PAY_REQ_DT_INVALID' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- validate that no lines without payment method
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Number of lines without payment method: ' || l_no_pay_mtd_count);
    if l_no_pay_mtd_count > 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'There are disb lines without payment method');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAY_METHOD' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated disbursement header for payment request submition');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_LINES
 |
 | DESCRIPTION
 |      This procedure validates all disbursement lines for a specific disbursement header.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Header ID
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_LINES(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_DISB_HEADER_ID        IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_LINES';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_count                         number;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_loan_currency                 varchar2(15);
    l_changed                       number;
    l_precision_queried             number;
    l_running_sum                   number;
    l_line_amount                   number;
    l_sum_percent                   number;
    l_header_amount                 number;
    l_le_id                         number;
    l_org_id                        number;
    l_disb_number                   number;
    l_due_date                      date;
    l_party_site_id                 number;

    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;
    TYPE DISB_LINES_TBL IS TABLE OF LNS_FUNDING_PUB.LNS_DISB_LINES_REC INDEX BY BINARY_INTEGER;
    l_DISB_LINES_TBL                DISB_LINES_TBL;


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement lines
    CURSOR disb_lines_cur(P_DISB_HEADER_ID number) IS
        select
            line.DISB_LINE_ID,
            line.DISB_HEADER_ID,
            line.DISB_LINE_NUMBER,
            line.LINE_AMOUNT,
            line.LINE_PERCENT,
            line.PAYEE_PARTY_ID,
            line.BANK_ACCOUNT_ID,
            line.PAYMENT_METHOD_CODE,
            line.REQUEST_DATE,
            line.OBJECT_VERSION_NUMBER,
            line.status,
            line.DISBURSEMENT_DATE,
            head.HEADER_AMOUNT,
            head.DISBURSEMENT_NUMBER,
            loan.LOAN_CURRENCY,
            loan.ORG_ID,
            loan.LEGAL_ENTITY_ID,
            nvl(head.PAYMENT_REQUEST_DATE, head.TARGET_DATE)
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where line.DISB_HEADER_ID = P_DISB_HEADER_ID and
            line.DISB_HEADER_ID = head.DISB_HEADER_ID and
            head.LOAN_ID = loan.LOAN_ID
        order by line.DISB_LINE_ID;

    -- validate party_site for the party
    CURSOR party_site_cur(P_PARTY_ID number, P_DATE date) IS
        SELECT party_site_id
        FROM   HZ_Party_Sites HPS
        WHERE  HPS.Party_ID = P_PARTY_ID
        AND    HPS.Identifying_Address_Flag = 'Y'
        AND    NVL(HPS.Start_Date_Active, P_DATE) = P_DATE;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT VALIDATE_DISB_LINES;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating disbursement lines for header ' || P_DISB_HEADER_ID || '...');

    -- getting disbursement lines
    l_precision_queried := 0;
    l_count := 0;
    l_sum_percent := 0;
    l_running_sum := 0;
    open disb_lines_cur(P_DISB_HEADER_ID);

    LOOP

        fetch disb_lines_cur into
            l_DISB_LINE_REC.DISB_LINE_ID,
            l_DISB_LINE_REC.DISB_HEADER_ID,
            l_DISB_LINE_REC.DISB_LINE_NUMBER,
            l_DISB_LINE_REC.LINE_AMOUNT,
            l_DISB_LINE_REC.LINE_PERCENT,
            l_DISB_LINE_REC.PAYEE_PARTY_ID,
            l_DISB_LINE_REC.BANK_ACCOUNT_ID,
            l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
            l_DISB_LINE_REC.REQUEST_DATE,
            l_DISB_LINE_REC.OBJECT_VERSION_NUMBER,
            l_DISB_LINE_REC.STATUS,
            l_DISB_LINE_REC.DISBURSEMENT_DATE,
            l_header_amount,
            l_disb_number,
            l_loan_currency,
            l_org_id,
            l_le_id,
            l_due_date;

        exit when disb_lines_cur%NOTFOUND;

        l_changed := 0;
        l_count := l_count + 1;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement line #' || l_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line ID: ' || l_DISB_LINE_REC.DISB_LINE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header ID: ' || l_DISB_LINE_REC.DISB_HEADER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Number: ' || l_DISB_LINE_REC.DISB_LINE_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amount: ' || l_DISB_LINE_REC.LINE_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Percent: ' || l_DISB_LINE_REC.LINE_PERCENT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee Party ID: ' || l_DISB_LINE_REC.PAYEE_PARTY_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Bank Account ID: ' || l_DISB_LINE_REC.BANK_ACCOUNT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Method Code: ' || l_DISB_LINE_REC.PAYMENT_METHOD_CODE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Request Date: ' || l_DISB_LINE_REC.REQUEST_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Version: ' || l_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Status: ' || l_DISB_LINE_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Date: ' || l_DISB_LINE_REC.DISBURSEMENT_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header Amount: ' || l_header_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Number: ' || l_disb_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Currency: ' || l_loan_currency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Org ID: ' || l_org_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LE ID: ' || l_le_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Due date: ' || l_due_date);

        if l_DISB_LINE_REC.DISB_HEADER_ID is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement header is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'disb_header_id' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_LINE_REC.LINE_PERCENT is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Line percent is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE_PERC' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_LINE_REC.PAYEE_PARTY_ID is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payee party ID is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_PAYEE' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

/*      -- disabled below validation as part of fix for bug 9709380
        -- validate party_site for the party
        open party_site_cur(l_DISB_LINE_REC.PAYEE_PARTY_ID, l_due_date);
        fetch party_site_cur into l_party_site_id;

        -- if no record exists - error; otherwise proceed
        if party_site_cur%NOTFOUND then

    --        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: No site exist for the party');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CREATE_PARTY_SITE');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;
        close party_site_cur;
*/
        l_sum_percent := l_sum_percent + l_DISB_LINE_REC.LINE_PERCENT;

        if l_DISB_LINE_REC.DISBURSEMENT_DATE is not null then

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'This line has already been successfully disbursed - skiping it');

        else

            if l_precision_queried = 0 then
                -- get precision
                fnd_currency.GET_INFO(CURRENCY_CODE => l_loan_currency,
                                    PRECISION => l_precision,
                                    EXT_PRECISION => l_ext_precision,
                                    MIN_ACCT_UNIT => l_min_acct_unit);

                l_precision_queried := 1;
            end if;

            -- setting new values
            l_DISB_LINE_REC.DISB_LINE_NUMBER := l_count;
            l_DISB_LINE_REC.LINE_AMOUNT := round(l_header_amount * l_DISB_LINE_REC.LINE_PERCENT / 100, l_precision);

            l_DISB_LINES_TBL(l_DISB_LINES_TBL.COUNT + 1) := l_DISB_LINE_REC;

            l_changed := 1;

        end if;

        l_line_amount := l_DISB_LINE_REC.LINE_AMOUNT;
        l_running_sum := l_running_sum + l_line_amount;

    END LOOP;

    close disb_lines_cur;

    if l_changed = 1 then
        l_DISB_LINES_TBL(l_DISB_LINES_TBL.COUNT).LINE_AMOUNT := l_header_amount - (l_running_sum - l_line_amount);
    end if;

    -- checking for total percent
    if l_sum_percent <> 100 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total percentage of all lines: ' || l_sum_percent);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_LN_PERC_INVALID');
        FND_MESSAGE.SET_TOKEN('DISB_NUM', l_disb_number);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- loop thru table and update disb lines table
    FOR l_Count1 IN 1..l_DISB_LINES_TBL.COUNT LOOP

        UPDATE_DISB_LINE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_LINE_REC         => l_DISB_LINES_TBL(l_Count1),
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to UPDATE_DISB_LINE failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated disbursement lines for header ' || P_DISB_HEADER_ID);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO VALIDATE_DISB_LINES;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO VALIDATE_DISB_LINES;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO VALIDATE_DISB_LINES;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');

END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_HEADERS
 |
 | DESCRIPTION
 |      This procedure validates all disbursement headers.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_HEADERS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_HEADERS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_count                         number;
    l_funded_amount                 number;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_loan_currency                 varchar2(15);
    l_changed                       number;
    l_precision_queried             number;
    l_running_sum                   number;
    l_line_amount                   number;
    l_sum_percent                   number;
    l_loan_start_date               date;
    l_loan_maturity_date            date;
    l_loan_status                   varchar2(30);
    l_move_maturity_date            number;

    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    TYPE DISB_HEADERS_TBL IS TABLE OF LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC INDEX BY BINARY_INTEGER;
    l_DISB_HEADERS_TBL              DISB_HEADERS_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info
    CURSOR disb_headers_cur(P_LOAN_ID number) IS
        select
            loan.REQUESTED_AMOUNT,
            loan.LOAN_CURRENCY,
            head.DISB_HEADER_ID,
            head.LOAN_ID,
            head.ACTIVITY_CODE,
            head.DISBURSEMENT_NUMBER,
            head.HEADER_AMOUNT,
            head.HEADER_PERCENT,
            head.STATUS,
            head.TARGET_DATE,
            head.OBJECT_VERSION_NUMBER,
            decode(nvl(loan.CURRENT_PHASE, 'TERM'), 'TERM', loan.LOAN_START_DATE, loan.OPEN_LOAN_START_DATE),
            decode(nvl(loan.CURRENT_PHASE, 'TERM'), 'TERM', loan.LOAN_MATURITY_DATE, loan.OPEN_MATURITY_DATE),
            loan.loan_status,
	        head.payment_request_date,
            head.phase,
            head.description
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where loan.LOAN_ID = P_LOAN_ID and
            head.LOAN_ID = loan.LOAN_ID and
            nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN')
        order by head.TARGET_DATE;

    CURSOR move_maturity_date_cur(P_LOAN_ID number) IS
        select
        CASE
            WHEN (nvl(loan.CURRENT_PHASE, 'TERM') = 'OPEN') THEN
                sign(trunc(loan.OPEN_MATURITY_DATE) -
                    (select trunc(max(PAYMENT_REQUEST_DATE)) from LNS_DISB_HEADERS where LOAN_ID = loan.LOAN_ID))
            WHEN (nvl(loan.CURRENT_PHASE, 'TERM') = 'TERM' and loan.MULTIPLE_FUNDING_FLAG = 'N') THEN
                sign(trunc(loan.LOAN_MATURITY_DATE) -
                    (select trunc(max(PAYMENT_REQUEST_DATE)) from LNS_DISB_HEADERS where LOAN_ID = loan.LOAN_ID))
            ELSE
                1
            END
        from lns_loan_headers_all loan
        where loan.LOAN_ID = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT VALIDATE_DISB_HEADERS;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating all disbursement headers...');

    -- getting all disbursement headers
    l_precision_queried := 0;
    l_count := 0;
    l_sum_percent := 0;
    l_running_sum := 0;
    open disb_headers_cur(P_LOAN_ID);

    LOOP

        fetch disb_headers_cur into
            l_funded_amount,
            l_loan_currency,
            l_DISB_HEADER_REC.DISB_HEADER_ID,
            l_DISB_HEADER_REC.LOAN_ID,
            l_DISB_HEADER_REC.ACTIVITY_CODE,
            l_DISB_HEADER_REC.DISBURSEMENT_NUMBER,
            l_DISB_HEADER_REC.HEADER_AMOUNT,
            l_DISB_HEADER_REC.HEADER_PERCENT,
            l_DISB_HEADER_REC.STATUS,
            l_DISB_HEADER_REC.TARGET_DATE,
            l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER,
            l_loan_start_date,
            l_loan_maturity_date,
            l_loan_status,
	        l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
            l_DISB_HEADER_REC.PHASE,
            l_DISB_HEADER_REC.DESCRIPTION;

        exit when disb_headers_cur%NOTFOUND;

        l_changed := 0;
        l_count := l_count + 1;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement header #' || l_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ID: ' || l_DISB_HEADER_REC.LOAN_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header ID: ' || l_DISB_HEADER_REC.DISB_HEADER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Activity Code: ' || l_DISB_HEADER_REC.ACTIVITY_CODE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Description: ' || l_DISB_HEADER_REC.DESCRIPTION);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Number: ' || l_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amount: ' || l_DISB_HEADER_REC.HEADER_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Percent: ' || l_DISB_HEADER_REC.HEADER_PERCENT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Status: ' || l_DISB_HEADER_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Version: ' || l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Target Date: ' || l_DISB_HEADER_REC.TARGET_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Request Date: ' || l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Phase: ' || l_DISB_HEADER_REC.PHASE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Requested Amount: ' || l_funded_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Currency: ' || l_loan_currency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan start date: ' || l_loan_start_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan maturity date: ' || l_loan_maturity_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan status: ' || l_loan_status);

        if l_DISB_HEADER_REC.LOAN_ID is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan ID is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'loan id' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.ACTIVITY_CODE is null and l_DISB_HEADER_REC.DESCRIPTION is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Activity code is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_ACTIV' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.HEADER_PERCENT is null and l_DISB_HEADER_REC.HEADER_AMOUNT is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Disbursement percent is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_DISB_PERC' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        if l_DISB_HEADER_REC.TARGET_DATE is null and l_DISB_HEADER_REC.PHASE = 'OPEN' then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Target date is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_ENTER_TARGET_DATE' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;
/*
	--karamach --Bug5295091
        if (l_DISB_HEADER_REC.STATUS NOT IN ('CANCELLED','IN_FUNDING','FUNDING_ERROR','PARTIALLY_FUNDED','FULLY_FUNDED')
		AND ( trunc(l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE) < trunc(sysdate))) then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Payment Request date is less than today');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_DISB_REQ_DATE_ERR' );
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;
*/
        if l_loan_status = 'INCOMPLETE' then
            if l_DISB_HEADER_REC.PHASE = 'OPEN' then
                if trunc(l_DISB_HEADER_REC.TARGET_DATE) < trunc(l_loan_start_date) then
        --            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Target date must be later that start date');
                    FND_MESSAGE.SET_NAME( 'LNS', 'LNS_DISB_TARGET_DATE_ERR' );
                    FND_MSG_PUB.ADD;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;

                end if;
            else
                if trunc(l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE) < trunc(l_loan_start_date) then
        --            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Target date must be later that start date');
                    FND_MESSAGE.SET_NAME( 'LNS', 'LNS_DISB_TARGET_DATE_ERR' );
                    FND_MSG_PUB.ADD;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;

                end if;
            end if;
        end if;

        if l_DISB_HEADER_REC.PHASE = 'OPEN' then

            l_sum_percent := l_sum_percent + l_DISB_HEADER_REC.HEADER_PERCENT;

            if l_DISB_HEADER_REC.STATUS is not null then

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Status is already set - nothing to change for this disbursement header');

            else

                if l_precision_queried = 0 then
                    -- get precision
                    fnd_currency.GET_INFO(CURRENCY_CODE => l_loan_currency,
                                        PRECISION => l_precision,
                                        EXT_PRECISION => l_ext_precision,
                                        MIN_ACCT_UNIT => l_min_acct_unit);

                    l_precision_queried := 1;
                end if;

                -- setting new values
                l_DISB_HEADER_REC.DISBURSEMENT_NUMBER := l_count;
                l_DISB_HEADER_REC.HEADER_AMOUNT := round(l_funded_amount * l_DISB_HEADER_REC.HEADER_PERCENT / 100, l_precision);

                l_DISB_HEADERS_TBL(l_DISB_HEADERS_TBL.COUNT + 1) := l_DISB_HEADER_REC;

                l_changed := 1;

            end if;

            l_line_amount := l_DISB_HEADER_REC.HEADER_AMOUNT;
            l_running_sum := l_running_sum + l_line_amount;

        else

            if l_DISB_HEADER_REC.STATUS is not null then
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Status is already set - nothing to change for this disbursement header');
            else
                l_DISB_HEADERS_TBL(l_DISB_HEADERS_TBL.COUNT + 1) := l_DISB_HEADER_REC;
            end if;

        end if;

    END LOOP;

    close disb_headers_cur;

    if l_DISB_HEADER_REC.PHASE = 'OPEN' then

        if l_changed = 1 then
            l_DISB_HEADERS_TBL(l_DISB_HEADERS_TBL.COUNT).HEADER_AMOUNT := l_funded_amount - (l_running_sum - l_line_amount);
        end if;

        -- checking for total percent
        if l_sum_percent <> 100 then
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total percentage of all disbursements: ' || l_sum_percent);
            FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_HDR_PERC_INVALID');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

    end if;

    -- loop thru table and update disb headers table
    FOR l_Count1 IN 1..l_DISB_HEADERS_TBL.COUNT LOOP

        UPDATE_DISB_HEADER(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_REC       => l_DISB_HEADERS_TBL(l_Count1),
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        VALIDATE_DISB_LINES(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_ID        => l_DISB_HEADERS_TBL(l_Count1).DISB_HEADER_ID,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to VALIDATE_DISB_LINES failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;
/*
    -- verify if we need to move open phase maturity date: bug 4884596
    open move_maturity_date_cur(P_LOAN_ID);
    fetch move_maturity_date_cur into l_move_maturity_date;
    close move_maturity_date_cur;

    if l_move_maturity_date = -1 then

        lns_financials.shiftLoan(
            p_loan_id => P_LOAN_ID
            ,p_init_msg_list => FND_API.G_TRUE
            ,p_commit => FND_API.G_FALSE
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to lns_financials.shiftLoan failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;
*/
    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated all disbursement headers');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO VALIDATE_DISB_HEADERS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO VALIDATE_DISB_HEADERS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO VALIDATE_DISB_HEADERS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');

END;




 /*========================================================================
 | PUBLIC PROCEDURE Get_Default_Payment_Attributes
 |
 | DESCRIPTION
 |      This procedure returns default payment attributes from Oracle Payments
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_Trxn_Attributes_Rec   IN          LNS_FUNDING_PUB.Trxn_Attributes_Rec_Type,
 |      x_default_pmt_attrs_rec OUT NOCOPY  LNS_FUNDING_PUB.Default_Pmt_Attrs_Rec_Type,
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
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE Get_Default_Payment_Attributes(
    P_API_VERSION           IN              NUMBER,
    P_INIT_MSG_LIST         IN              VARCHAR2,
    P_COMMIT                IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_Trxn_Attributes_Rec   IN              LNS_FUNDING_PUB.Trxn_Attributes_Rec_Type,
    X_default_pmt_attrs_rec OUT NOCOPY      LNS_FUNDING_PUB.Default_Pmt_Attrs_Rec_Type,
    X_RETURN_STATUS         OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY      NUMBER,
    X_MSG_DATA              OUT NOCOPY      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'Get_Default_Payment_Attributes';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_Trxn_Attributes_Rec           IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
    l_Default_Pmt_Attrs_Rec         IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting bank account number
    CURSOR bank_acc_cur(P_BANK_ACC_ID number) IS
        select masked_bank_account_num,
            bank_account_name
        from IBY_EXT_BANK_ACCOUNTS
        where ext_bank_account_id = P_BANK_ACC_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT Get_Default_Payment_Attr;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Application_Id: ' || P_Trxn_Attributes_Rec.Application_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payer_Legal_Entity_Id: ' || P_Trxn_Attributes_Rec.Payer_Legal_Entity_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payer_Org_Id: ' || P_Trxn_Attributes_Rec.Payer_Org_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payer_Org_Type: ' || P_Trxn_Attributes_Rec.Payer_Org_Type);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_Party_Id: ' || P_Trxn_Attributes_Rec.Payee_Party_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_Party_Site_Id: ' || P_Trxn_Attributes_Rec.Payee_Party_Site_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Supplier_Site_Id: ' || P_Trxn_Attributes_Rec.Supplier_Site_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Pay_Proc_Trxn_Type_Code: ' || P_Trxn_Attributes_Rec.Pay_Proc_Trxn_Type_Code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Currency: ' || P_Trxn_Attributes_Rec.Payment_Currency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Amount: ' || P_Trxn_Attributes_Rec.Payment_Amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Function: ' || P_Trxn_Attributes_Rec.Payment_Function);

    if P_Trxn_Attributes_Rec.Payer_Org_Type is not null then
        l_Trxn_Attributes_Rec.Payer_Org_Type            := P_Trxn_Attributes_Rec.Payer_Org_Type;
    else
        l_Trxn_Attributes_Rec.Payer_Org_Type            := 'OPERATING_UNIT';
    end if;

    l_Trxn_Attributes_Rec.Application_Id            := P_Trxn_Attributes_Rec.Application_Id;
    l_Trxn_Attributes_Rec.Payer_Legal_Entity_Id     := P_Trxn_Attributes_Rec.Payer_Legal_Entity_Id;
    l_Trxn_Attributes_Rec.Payer_Org_Id              := P_Trxn_Attributes_Rec.Payer_Org_Id;
    l_Trxn_Attributes_Rec.Payee_Party_Id            := P_Trxn_Attributes_Rec.Payee_Party_Id;
    l_Trxn_Attributes_Rec.Payee_Party_Site_Id       := P_Trxn_Attributes_Rec.Payee_Party_Site_Id;
    l_Trxn_Attributes_Rec.Supplier_Site_Id          := P_Trxn_Attributes_Rec.Supplier_Site_Id;
    l_Trxn_Attributes_Rec.Pay_Proc_Trxn_Type_Code   := P_Trxn_Attributes_Rec.Pay_Proc_Trxn_Type_Code;
    l_Trxn_Attributes_Rec.Payment_Currency          := P_Trxn_Attributes_Rec.Payment_Currency;
    l_Trxn_Attributes_Rec.Payment_Amount            := P_Trxn_Attributes_Rec.Payment_Amount;
    l_Trxn_Attributes_Rec.Payment_Function          := P_Trxn_Attributes_Rec.Payment_Function;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes...');
    IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes(
        p_api_version             => 1.0,
        p_init_msg_list           => FND_API.G_TRUE,
        p_ignore_payee_pref       => null,
        p_trxn_attributes_rec     => l_Trxn_Attributes_Rec,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data,
        x_default_pmt_attrs_rec   => l_Default_Pmt_Attrs_Rec);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes has failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    X_default_pmt_attrs_rec.Payment_Method_Name := l_Default_Pmt_Attrs_Rec.Payment_Method.Payment_Method_Name;
    X_default_pmt_attrs_rec.Payment_Method_Code := l_Default_Pmt_Attrs_Rec.Payment_Method.Payment_Method_Code;
    X_default_pmt_attrs_rec.Payee_BankAccount_Id := l_Default_Pmt_Attrs_Rec.Payee_BankAccount.Payee_BankAccount_Id;

    -- getting bank account number
    open bank_acc_cur(X_default_pmt_attrs_rec.Payee_BankAccount_Id);
    fetch bank_acc_cur into X_default_pmt_attrs_rec.Payee_BankAccount_Number, X_default_pmt_attrs_rec.Payee_BankAccount_Name;
    close bank_acc_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Return data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Method_Name: ' || X_default_pmt_attrs_rec.Payment_Method_Name);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment_Method_Code: ' || X_default_pmt_attrs_rec.Payment_Method_Code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_BankAccount_Id: ' || X_default_pmt_attrs_rec.Payee_BankAccount_Id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_BankAccount_Number: ' || X_default_pmt_attrs_rec.Payee_BankAccount_Number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee_BankAccount_Name: ' || X_default_pmt_attrs_rec.Payee_BankAccount_Name);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_Default_Payment_Attr;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_Default_Payment_Attr;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO Get_Default_Payment_Attr;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');

END;



/*========================================================================
 | PUBLIC PROCEDURE DEFAULT_PROD_DISBURSEMENTS
 |
 | DESCRIPTION
 |      This procedure Defaults Disbursements for a loan based on product setup. |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan ID
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
 | 12-07-2005            gbellary          Created
 |
 *=======================================================================*/
PROCEDURE DEFAULT_PROD_DISBURSEMENTS(
    P_LOAN_ID               IN          NUMBER) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name     CONSTANT VARCHAR2(30) := 'DEFAULT_PROD_DISBURSEMENTS';
    l_api_version  CONSTANT NUMBER := 1.0;
    l_Trxn_Attributes_Rec   IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
    l_Default_Pmt_Attrs_Rec IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;
    l_org_id                lns_loan_headers_all.org_id%TYPE;
    l_legal_entity_id       lns_Loan_headers_all.legal_entity_id%TYPE;
    l_payment_method_code   lns_disb_lines.payment_method_code%TYPE;
    l_bank_account_id       lns_disb_lines.bank_account_id%TYPE;
    l_payee_party_id        lns_disb_lines.payee_party_id%TYPE;
    l_return_status         varchar2(1);
    l_msg_count             number;
    l_msg_data              varchar2(4000);
    l_current_phase         varchar2(30);
    l_requested_amount      number;
    l_currency              varchar2(15);

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_loan_id: ' || p_loan_id);

    -- standard start of API savepoint
    SAVEPOINT DEFAULT_PROD_DISBURSEMENTS;

    IF p_loan_id IS NULL THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'LOAN ID is missing');
            FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_loan_id' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying loan info...');
    SELECT llh.primary_borrower_id
            ,llh.org_id
            ,llh.legal_entity_id
            ,llh.current_phase
            ,llh.requested_amount + nvl(llh.ADD_REQUESTED_AMOUNT, 0)
            ,llh.LOAN_CURRENCY
    INTO   l_payee_party_id
            ,l_org_id
            ,l_legal_entity_id
            ,l_current_phase
            ,l_requested_amount
            ,l_currency
    FROM   lns_loan_headers_all llh
    WHERE  llh.loan_id = p_loan_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payee_party_id: ' || l_payee_party_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_org_id: ' || l_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_legal_entity_id: ' || l_legal_entity_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_current_phase: ' || l_current_phase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_requested_amount: ' || l_requested_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_currency: ' || l_currency);

    l_Trxn_Attributes_Rec.Application_Id            := 206;
    l_Trxn_Attributes_Rec.Payer_Legal_Entity_Id     := l_legal_entity_id;
    l_Trxn_Attributes_Rec.Payer_Org_Id              := l_org_id;
    l_Trxn_Attributes_Rec.Payer_Org_Type            := 'OPERATING_UNIT';
    l_Trxn_Attributes_Rec.Payee_Party_Id            := l_payee_party_id;
    l_Trxn_Attributes_Rec.Pay_Proc_Trxn_Type_Code   := 'LOAN_PAYMENT';
    l_Trxn_Attributes_Rec.Payment_Currency          := l_currency;
    l_Trxn_Attributes_Rec.Payment_Function          := 'LOANS_PAYMENTS';

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes...');
    IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes(
            p_api_version             => 1.0,
            p_init_msg_list           => FND_API.G_TRUE,
            p_ignore_payee_pref       => null,
            p_trxn_attributes_rec     => l_Trxn_Attributes_Rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data,
            x_default_pmt_attrs_rec   => l_Default_Pmt_Attrs_Rec);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status = 'S' THEN
        l_payment_method_code := l_Default_Pmt_Attrs_Rec.Payment_Method.Payment_Method_Code;
        l_bank_account_id := l_Default_Pmt_Attrs_Rec.Payee_BankAccount.Payee_BankAccount_Id;
    END IF;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payment_method_code: ' || l_payment_method_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_bank_account_id: ' || l_bank_account_id);

    FOR Disb_Rec in (SELECT lns_disb_headers_s.NEXTVAL disb_header_id
                            , loan_product_lines_id
                            , activity_code
                            , disb_percent
                            , sequence_number
                            , llh.primary_borrower_id payee_party_id
                            , lns_disb_lines_s.NEXTVAL disb_line_id
            FROM   lns_loan_headers_all llh, lns_loan_product_lines lpl
            WHERE  llh.loan_id = p_loan_id
        -- AND    llh.multiple_funding_flag = 'Y'  Bug#6613708
            AND    lpl.LOAN_PRODUCT_ID = llh.PRODUCT_ID
            AND    lpl.LOAN_PRODUCT_LINE_TYPE = 'DISBURSEMENT'
            AND    SYSDATE BETWEEN NVL(lpl.start_date_active,SYSDATE)
                        AND NVL(lpl.end_date_active,SYSDATE)
        AND    NOT EXISTS (select 1
                            from   lns_disb_headers ldh
                    where  ldh.loan_id = llh.loan_id)) LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Creating default disbursement');
        -- Default Product Disbursements
        LNS_DISB_HEADERS_PKG.Insert_Row(
            X_DISB_HEADER_ID		=> Disb_Rec.disb_header_id,
            P_LOAN_ID		        => p_loan_id,
            P_ACTIVITY_CODE		    => Disb_Rec.activity_code,
            P_DISBURSEMENT_NUMBER	=> Disb_Rec.sequence_number,
            P_HEADER_PERCENT		=> Disb_Rec.disb_percent,
            P_HEADER_AMOUNT		    => l_requested_amount * Disb_Rec.disb_percent / 100,
            P_OBJECT_VERSION_NUMBER	=> 1,
            P_PHASE => l_current_phase);

        LNS_DISB_LINES_PKG.Insert_Row(
            X_DISB_LINE_ID               => Disb_Rec.disb_line_id,
            P_DISB_HEADER_ID             => Disb_Rec.disb_header_id,
            P_DISB_LINE_NUMBER           => 1,
            P_LINE_PERCENT               => 100,
            P_PAYEE_PARTY_ID             => Disb_Rec.payee_party_id,
            P_PAYMENT_METHOD_CODE        => l_payment_method_code,
            P_BANK_ACCOUNT_ID            => l_bank_account_id,
            P_OBJECT_VERSION_NUMBER      => 1);

        -- Default Product Conditions
        LNS_COND_ASSIGNMENT_PUB.CREATE_LP_DISB_COND_ASSIGNMENT(
            P_LOAN_ID                   => p_loan_id,
            P_DISB_HEADER_ID            => Disb_Rec.disb_header_id
            ,P_LOAN_PRODUCT_LINE_ID     => Disb_Rec.loan_product_lines_id);

        -- Default Product Disbursement Fees
        LNS_FEE_ASSIGNMENT_PUB.CREATE_LP_DISB_FEE_ASSIGNMENT(
            P_DISB_HEADER_ID             => Disb_Rec.disb_header_id
            ,P_LOAN_PRODUCT_LINE_ID       => Disb_Rec.loan_product_lines_id
            ,P_LOAN_ID       => P_LOAN_ID);

    END LOOP;

   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DEFAULT_PROD_DISBURSEMENTS;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Changes Rolled back in '
                           || G_PKG_NAME || '.' || l_api_name);

    WHEN OTHERS THEN
        ROLLBACK TO DEFAULT_PROD_DISBURSEMENTS;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END DEFAULT_PROD_DISBURSEMENTS;



/*========================================================================
 | PUBLIC PROCEDURE SUBMIT_SINGLE_PAY_REQ
 |
 | DESCRIPTION
 |      This procedure submits single payment request to AP.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Line ID
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
 | 06-23-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SUBMIT_SINGLE_PAY_REQ(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST     IN          VARCHAR2,
    P_COMMIT            IN          VARCHAR2,
    P_VALIDATION_LEVEL  IN          NUMBER,
    P_DISB_LINE_ID      IN          NUMBER,
    X_RETURN_STATUS     OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA          OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SUBMIT_SINGLE_PAY_REQ';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;

    TYPE DISB_LINES_TBL IS TABLE OF LNS_FUNDING_PUB.LNS_DISB_LINES_REC INDEX BY BINARY_INTEGER;
    l_DISB_LINES_TBL                DISB_LINES_TBL;

    l_org_id                        number;
    l_invoice_line_id               number;
    l_loan_number                   varchar2(60);
    l_source                        VARCHAR2(80);
    l_description                   VARCHAR2(240);
    l_cc_id                         number;
    l_percent                       number;
    l_Count2                        number;
    l_running_sum                   number;
    l_sum_percent                   number;
    l_line_amount                   number;
    l_EXCHANGE_RATE_TYPE            VARCHAR2(30);
    l_EXCHANGE_DATE                 DATE;
    l_EXCHANGE_RATE                 NUMBER;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_invoice_number                VARCHAR2(50);
    l_loan_currency                 VARCHAR2(15);
    l_invoice_id                    NUMBER;
    l_request_id                    number;
    l_Count1                        number;
    l_loan_id                       number;
    l_le_id                         number;
    l_hist_id                       number;
    l_attempt                       number;
    l_invoice_row_id                varchar2(100);
    l_inv_line_row_id               varchar2(100);
    l_reject_desc                   VARCHAR2(240);
    l_payee                         varchar2(360);
    l_new_invoice                   varchar2(1);
    l_due_date                      date;
    l_ap_inv_id                     number;
    l_precision_queried             number;
    l_phase                         varchar2(30);

    l_rejections                    AP_IMPORT_INVOICES_PKG.rejection_tab_type;
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting info about loan, disbursement header and line info
    CURSOR disb_line_cur(P_DISB_LINE_ID number) IS
        select
            line.DISB_LINE_ID,
            line.DISB_HEADER_ID,
            line.DISB_LINE_NUMBER,
            line.LINE_AMOUNT,
            line.LINE_PERCENT,
            line.PAYEE_PARTY_ID,
            line.BANK_ACCOUNT_ID,
            line.PAYMENT_METHOD_CODE,
            line.STATUS,
            line.REQUEST_DATE,
            line.OBJECT_VERSION_NUMBER,
            head.LOAN_ID,
            head.ACTIVITY_CODE,
            head.DISBURSEMENT_NUMBER,
            head.HEADER_AMOUNT,
            head.HEADER_PERCENT,
            head.STATUS,
            head.TARGET_DATE,
            head.PAYMENT_REQUEST_DATE,
            head.OBJECT_VERSION_NUMBER,
            nvl(lkp.meaning, head.DESCRIPTION),
            loan.LOAN_NUMBER,
            loan.EXCHANGE_RATE_TYPE,
            loan.EXCHANGE_DATE,
            loan.EXCHANGE_RATE,
            loan.LOAN_CURRENCY,
            loan.ORG_ID,
            loan.LEGAL_ENTITY_ID,
            loan.current_phase,
            line.INVOICE_INTERFACE_ID
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head,
            lns_lookups lkp,
            LNS_LOAN_HEADERS_ALL loan
        where line.DISB_LINE_ID = P_DISB_LINE_ID and
            head.DISB_HEADER_ID = line.DISB_HEADER_ID and
            lkp.lookup_type(+) = 'DISB_ACTIVITY' and
            lkp.lookup_code(+) = head.ACTIVITY_CODE and
            loan.loan_id = head.loan_id;

    -- submition attemts info
    CURSOR attempts_cur(P_DISB_LINE_ID number) IS
        select count(1) + 1
        from LNS_DISB_HISTORIES_H
        where DISB_LINE_ID = P_DISB_LINE_ID;

    -- query liability distribution info - invoice header
    CURSOR liability_distr_cur(P_LOAN_ID number) IS
        select CODE_COMBINATION_ID,
               DISTRIBUTION_PERCENT
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'CR' and
            account_name = 'LOAN_LIABILITY' and
            line_type = 'PRIN';

    -- query clearing distribution info - invoice lines
    CURSOR clearing_distr_cur(P_LOAN_ID number, P_DISB_HEADER_ID number) IS
        select CODE_COMBINATION_ID,
               DISTRIBUTION_PERCENT
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_name = 'LOAN_PAYABLE' and
            line_type = 'CLEAR' and
            disb_header_id = P_DISB_HEADER_ID;

    -- generating new invoice id
    CURSOR new_inv_id_cur IS
        select AP_INVOICES_INTERFACE_S.NEXTVAL from dual;

    -- generating new invoice line id
    CURSOR new_inv_ln_id_cur IS
        select AP_INVOICE_LINES_INTERFACE_S.NEXTVAL from dual;

    -- get rejection description
    CURSOR get_reject_cur(P_CODE VARCHAR2) IS
        select description
        from AP_LOOKUP_CODES
        where lookup_type = 'REJECT CODE' and
        lookup_code = P_CODE;

    -- get party for rejection
    CURSOR get_party1_cur(P_ID VARCHAR2) IS
        select party.party_name
        from AP_INVOICES_INTERFACE inv,
        hz_parties party
        where inv.INVOICE_ID = P_ID and
        inv.party_id = party.party_id;

    -- get party for rejection
    CURSOR get_party2_cur(P_ID VARCHAR2) IS
        select party.party_name
        from AP_INVOICES_INTERFACE inv,
        AP_INVOICE_LINES_INTERFACE line,
        hz_parties party
        where line.INVOICE_LINE_ID = P_ID and
        line.INVOICE_ID = inv.INVOICE_ID and
        inv.party_id = party.party_id;

    -- get invoice_id from AP
    CURSOR get_invoice_cur(P_INVOICE_NUM VARCHAR2, P_PARTY_ID number) IS
        select invoice_id
        from ap_invoices_all
        where invoice_num = P_INVOICE_NUM and
            party_id = P_PARTY_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Submitting payment request for line ' || P_DISB_LINE_ID);

    open disb_line_cur(P_DISB_LINE_ID);
    fetch disb_line_cur into
        l_DISB_LINE_REC.DISB_LINE_ID,
        l_DISB_LINE_REC.DISB_HEADER_ID,
        l_DISB_LINE_REC.DISB_LINE_NUMBER,
        l_DISB_LINE_REC.LINE_AMOUNT,
        l_DISB_LINE_REC.LINE_PERCENT,
        l_DISB_LINE_REC.PAYEE_PARTY_ID,
        l_DISB_LINE_REC.BANK_ACCOUNT_ID,
        l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
        l_DISB_LINE_REC.STATUS,
        l_DISB_LINE_REC.REQUEST_DATE,
        l_DISB_LINE_REC.OBJECT_VERSION_NUMBER,
        l_DISB_HEADER_REC.LOAN_ID,
        l_DISB_HEADER_REC.ACTIVITY_CODE,
        l_DISB_HEADER_REC.DISBURSEMENT_NUMBER,
        l_DISB_HEADER_REC.HEADER_AMOUNT,
        l_DISB_HEADER_REC.HEADER_PERCENT,
        l_DISB_HEADER_REC.STATUS,
        l_DISB_HEADER_REC.TARGET_DATE,
        l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
        l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER,
        l_description,
        l_loan_number,
        l_EXCHANGE_RATE_TYPE,
        l_EXCHANGE_DATE,
        l_EXCHANGE_RATE,
        l_loan_currency,
        l_org_id,
        l_le_id,
        l_phase,
        l_DISB_LINE_REC.INVOICE_INTERFACE_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Line Details:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line ID: ' || l_DISB_LINE_REC.DISB_LINE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header ID: ' || l_DISB_LINE_REC.DISB_HEADER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Number: ' || l_DISB_LINE_REC.DISB_LINE_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Amount: ' || l_DISB_LINE_REC.LINE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Percent: ' || l_DISB_LINE_REC.LINE_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee: ' || l_DISB_LINE_REC.PAYEE_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Bank Account: ' || l_DISB_LINE_REC.BANK_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Method: ' || l_DISB_LINE_REC.PAYMENT_METHOD_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Status: ' || l_DISB_LINE_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Request Date: ' || l_DISB_LINE_REC.REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Version: ' || l_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice Interface ID: ' || l_DISB_LINE_REC.INVOICE_INTERFACE_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Header Details:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header ID: ' || l_DISB_LINE_REC.DISB_HEADER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Activity Code: ' || l_DISB_HEADER_REC.ACTIVITY_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement Number: ' || l_DISB_HEADER_REC.DISBURSEMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header Amount: ' || l_DISB_HEADER_REC.HEADER_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header Percent: ' || l_DISB_HEADER_REC.HEADER_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header Status: ' || l_DISB_HEADER_REC.STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Target Date: ' || l_DISB_HEADER_REC.TARGET_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Request Date: ' || l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Version: ' || l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header Description: ' || l_description);

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Details:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ID: ' || l_DISB_HEADER_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Number: ' || l_loan_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Exchange Rate Type: ' || l_EXCHANGE_RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Exchange Date: ' || l_EXCHANGE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Exchange Rate: ' || l_EXCHANGE_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Currency: ' || l_loan_currency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Org ID: ' || l_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LE ID: ' || l_le_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_phase);

    -- submition attemts info
    open attempts_cur(l_DISB_LINE_REC.DISB_LINE_ID);
    fetch attempts_cur into l_attempt;
    close attempts_cur;

    -- generate invoice number
/*
    l_invoice_number := l_loan_number || '-' ||
                        l_DISB_HEADER_REC.DISBURSEMENT_NUMBER;
*/

    l_invoice_number := l_loan_number || '-' || l_phase || '-' ||
                        l_DISB_HEADER_REC.DISBURSEMENT_NUMBER || '-' ||
                        l_DISB_LINE_REC.DISB_LINE_NUMBER;

    -- create disbursement distribution records in lns_distributions
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling create_DisbursementDistribs...');
    LNS_DISTRIBUTIONS_PUB.create_DisbursementDistribs(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_loan_id               => l_DISB_HEADER_REC.LOAN_ID,
            p_disb_header_id        => l_DISB_LINE_REC.DISB_HEADER_ID,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Return status: ' || l_return_status);
    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to LNS_DISTRIBUTIONS_PUB.create_DisbursementDistribs failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- query liability distribution info
    open liability_distr_cur(l_DISB_HEADER_REC.LOAN_ID);
    fetch liability_distr_cur into
        l_cc_id,
        l_percent;
    close liability_distr_cur;

    l_due_date := l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE;
    l_source := 'LOANS';

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AP Invoice datails:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice Number: ' || l_invoice_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Due Date: ' || l_due_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amount: ' || l_DISB_LINE_REC.LINE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Currency: ' || l_loan_currency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_EXCHANGE_RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_EXCHANGE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_EXCHANGE_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payee Party ID: ' || l_DISB_LINE_REC.PAYEE_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Source: ' || l_source);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment Method: ' || l_DISB_LINE_REC.PAYMENT_METHOD_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ACCTS_PAY_CODE_COMBINATION_ID: ' || l_cc_id);

    -- analyzing exchange info
    if l_EXCHANGE_RATE_TYPE is null or
    (l_EXCHANGE_RATE_TYPE is not null and l_EXCHANGE_RATE_TYPE <> 'User') then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Setting exchange rate = null');
        l_EXCHANGE_RATE := null;

    end if;

    l_new_invoice := 'N';
    BEGIN

        SAVEPOINT SUBMIT_SINGLE_PAY_REQ;

        if l_DISB_LINE_REC.INVOICE_INTERFACE_ID is null then

            -- generating new invoice id
            open new_inv_id_cur;
            fetch new_inv_id_cur into l_invoice_id;
            close new_inv_id_cur;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice ID: ' || l_invoice_id);

            l_new_invoice := 'Y';
            -- inserting invoice line
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting AP invoice into interface table...');

            AP_INVOICES_INTERFACE_PKG.INSERT_ROW(
                X_ROWID                        => l_invoice_row_id,
                X_INVOICE_ID                   => l_invoice_id,
                X_INVOICE_NUM                  => l_invoice_number,
                X_INVOICE_TYPE_LOOKUP_CODE     => 'PAYMENT REQUEST',
                X_INVOICE_DATE                 => l_due_date,
                X_PO_NUMBER                    => null,
                X_VENDOR_ID                    => null,
                X_VENDOR_SITE_ID               => null,
                X_INVOICE_AMOUNT               => l_DISB_LINE_REC.LINE_AMOUNT,
                X_INVOICE_CURRENCY_CODE        => l_loan_currency,
                X_PAYMENT_CURRENCY_CODE        => null,
                X_PAYMENT_CROSS_RATE           => null,
                X_PAYMENT_CROSS_RATE_TYPE      => null,
                X_PAYMENT_CROSS_RATE_DATE      => null,
                X_EXCHANGE_RATE                => l_EXCHANGE_RATE,
                X_EXCHANGE_RATE_TYPE           => l_EXCHANGE_RATE_TYPE,
                X_EXCHANGE_DATE                => l_EXCHANGE_DATE,
                X_TERMS_ID                     => null, -- fix for bug 9265018: let ap to default terms_id
                X_DESCRIPTION                  => l_description,
                X_AWT_GROUP_ID                 => null,
                X_AMT_APPLICABLE_TO_DISCOUNT   => null,
                X_ATTRIBUTE_CATEGORY           => null,
                X_ATTRIBUTE1                   => null,
                X_ATTRIBUTE2                   => null,
                X_ATTRIBUTE3                   => null,
                X_ATTRIBUTE4                   => null,
                X_ATTRIBUTE5                   => null,
                X_ATTRIBUTE6                   => null,
                X_ATTRIBUTE7                   => null,
                X_ATTRIBUTE8                   => null,
                X_ATTRIBUTE9                   => null,
                X_ATTRIBUTE10                  => null,
                X_ATTRIBUTE11                  => null,
                X_ATTRIBUTE12                  => null,
                X_ATTRIBUTE13                  => null,
                X_ATTRIBUTE14                  => null,
                X_ATTRIBUTE15                  => null,
                X_GLOBAL_ATTRIBUTE_CATEGORY    => null,
                X_GLOBAL_ATTRIBUTE1            => null,
                X_GLOBAL_ATTRIBUTE2            => null,
                X_GLOBAL_ATTRIBUTE3            => null,
                X_GLOBAL_ATTRIBUTE4            => null,
                X_GLOBAL_ATTRIBUTE5            => null,
                X_GLOBAL_ATTRIBUTE6            => null,
                X_GLOBAL_ATTRIBUTE7            => null,
                X_GLOBAL_ATTRIBUTE8            => null,
                X_GLOBAL_ATTRIBUTE9            => null,
                X_GLOBAL_ATTRIBUTE10           => null,
                X_GLOBAL_ATTRIBUTE11           => null,
                X_GLOBAL_ATTRIBUTE12           => null,
                X_GLOBAL_ATTRIBUTE13           => null,
                X_GLOBAL_ATTRIBUTE14           => null,
                X_GLOBAL_ATTRIBUTE15           => null,
                X_GLOBAL_ATTRIBUTE16           => null,
                X_GLOBAL_ATTRIBUTE17           => null,
                X_GLOBAL_ATTRIBUTE18           => null,
                X_GLOBAL_ATTRIBUTE19           => null,
                X_GLOBAL_ATTRIBUTE20           => null,
                X_STATUS                       => null,
                X_SOURCE                       => l_source,
                X_GROUP_ID                     => l_invoice_number,
                X_WORKFLOW_FLAG                => null,
                X_DOC_CATEGORY_CODE            => null,
                X_VOUCHER_NUM                  => null,
                X_PAY_GROUP_LOOKUP_CODE        => null, --'Standard',
                X_GOODS_RECEIVED_DATE          => null,
                X_INVOICE_RECEIVED_DATE        => sysdate,
                X_GL_DATE                      => l_due_date,
                X_ACCTS_PAY_CCID               => l_cc_id,
    --            X_USSGL_TRANSACTION_CODE       => null,
                X_EXCLUSIVE_PAYMENT_FLAG       => null,
                X_INVOICE_INCLUDES_PREPAY_FLAG => null,
                X_PREPAY_NUM                   => null,
                X_PREPAY_APPLY_AMOUNT          => null,
                X_PREPAY_GL_DATE               => null,
                X_CREATION_DATE                => LNS_UTILITY_PUB.CREATION_DATE,
                X_CREATED_BY                   => LNS_UTILITY_PUB.CREATED_BY,
                X_LAST_UPDATE_DATE             => LNS_UTILITY_PUB.LAST_UPDATE_DATE,
                X_LAST_UPDATED_BY              => LNS_UTILITY_PUB.LAST_UPDATED_BY,
                X_LAST_UPDATE_LOGIN            => LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
                X_ORG_ID                       => l_org_id,
                X_MODE                         => null,
                X_TERMS_DATE                   => null,
                X_REQUESTER_ID                 => null,
                X_OPERATING_UNIT               => null,
                -- Invoice LINes Project Stage 1
                X_PREPAY_LINE_NUM              => null,
                X_REQUESTER_FIRST_NAME         => null,
                X_REQUESTER_LAST_NAME          => null,
                X_REQUESTER_EMPLOYEE_NUM       => null,
                -- eTax Uptake
                X_CALC_TAX_DURING_IMPORT_FLAG  => null,
                X_CONTROL_AMOUNT               => null,
                X_ADD_TAX_TO_INV_AMT_FLAG      => null,
                X_TAX_RELATED_INVOICE_ID       => null,
                X_TAXATION_COUNTRY             => null,
                X_DOCUMENT_SUB_TYPE            => null,
                X_SUPPLIER_TAX_INVOICE_NUMBER  => null,
                X_SUPPLIER_TAX_INVOICE_DATE    => null,
                X_SUPPLIER_TAX_EXCHANGE_RATE   => null,
                X_TAX_INVOICE_RECORDING_DATE   => null,
                X_TAX_INVOICE_INTERNAL_SEQ	   => null,
                X_LEGAL_ENTITY_ID              => l_le_id,
                x_PAYMENT_METHOD_CODE          => l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
                x_PAYMENT_REASON_CODE          => null,
                X_PAYMENT_REASON_COMMENTS      => null,
                x_UNIQUE_REMITTANCE_IDENTIFIER => null,
                x_URI_CHECK_DIGIT              => null,
                x_BANK_CHARGE_BEARER           => null,
                x_DELIVERY_CHANNEL_CODE        => null,
                x_SETTLEMENT_PRIORITY          => null,
                x_remittance_message1          => null,
                x_remittance_message2          => null,
                x_remittance_message3          => null,
                x_NET_OF_RETAINAGE_FLAG        => null,
                x_PORT_OF_ENTRY_CODE           => null,
                X_APPLICATION_ID               => 206,
                X_PRODUCT_TABLE                => null,
                X_REFERENCE_KEY1               => null,
                X_REFERENCE_KEY2               => null,
                X_REFERENCE_KEY3               => null,
                X_REFERENCE_KEY4               => null,
                X_REFERENCE_KEY5               => null,
                X_PARTY_ID                     => l_DISB_LINE_REC.PAYEE_PARTY_ID,
                X_PARTY_SITE_ID                => null,
                X_PAY_PROC_TRXN_TYPE_CODE      => 'LOAN_PAYMENT',
                X_PAYMENT_FUNCTION             => 'LOANS_PAYMENTS',
                X_PAYMENT_PRIORITY             => null);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted new invoice');

        else

            l_invoice_id := l_DISB_LINE_REC.INVOICE_INTERFACE_ID;
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice ID: ' || l_invoice_id);

            -- inserting invoice line
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating AP invoice into interface table...');

            AP_INVOICES_INTERFACE_PKG.UPDATE_ROW(
                X_INVOICE_ID                   => l_invoice_id,
                X_INVOICE_NUM                  => l_invoice_number,
                X_INVOICE_TYPE_LOOKUP_CODE     => 'PAYMENT REQUEST',
                X_INVOICE_DATE                 => l_due_date,
                X_PO_NUMBER                    => null,
                X_VENDOR_ID                    => null,
                X_VENDOR_SITE_ID               => null,
                X_INVOICE_AMOUNT               => l_DISB_LINE_REC.LINE_AMOUNT,
                X_INVOICE_CURRENCY_CODE        => l_loan_currency,
                X_PAYMENT_CURRENCY_CODE        => null,
                X_PAYMENT_CROSS_RATE           => null,
                X_PAYMENT_CROSS_RATE_TYPE      => null,
                X_PAYMENT_CROSS_RATE_DATE      => null,
                X_EXCHANGE_RATE                => l_EXCHANGE_RATE,
                X_EXCHANGE_RATE_TYPE           => l_EXCHANGE_RATE_TYPE,
                X_EXCHANGE_DATE                => l_EXCHANGE_DATE,
                X_TERMS_ID                     => null, -- fix for bug 9265018: let ap to default terms_id
                X_DESCRIPTION                  => l_description,
                X_AWT_GROUP_ID                 => null,
                X_AMT_APPLICABLE_TO_DISCOUNT   => null,
                X_ATTRIBUTE_CATEGORY           => null,
                X_ATTRIBUTE1                   => null,
                X_ATTRIBUTE2                   => null,
                X_ATTRIBUTE3                   => null,
                X_ATTRIBUTE4                   => null,
                X_ATTRIBUTE5                   => null,
                X_ATTRIBUTE6                   => null,
                X_ATTRIBUTE7                   => null,
                X_ATTRIBUTE8                   => null,
                X_ATTRIBUTE9                   => null,
                X_ATTRIBUTE10                  => null,
                X_ATTRIBUTE11                  => null,
                X_ATTRIBUTE12                  => null,
                X_ATTRIBUTE13                  => null,
                X_ATTRIBUTE14                  => null,
                X_ATTRIBUTE15                  => null,
                X_GLOBAL_ATTRIBUTE_CATEGORY    => null,
                X_GLOBAL_ATTRIBUTE1            => null,
                X_GLOBAL_ATTRIBUTE2            => null,
                X_GLOBAL_ATTRIBUTE3            => null,
                X_GLOBAL_ATTRIBUTE4            => null,
                X_GLOBAL_ATTRIBUTE5            => null,
                X_GLOBAL_ATTRIBUTE6            => null,
                X_GLOBAL_ATTRIBUTE7            => null,
                X_GLOBAL_ATTRIBUTE8            => null,
                X_GLOBAL_ATTRIBUTE9            => null,
                X_GLOBAL_ATTRIBUTE10           => null,
                X_GLOBAL_ATTRIBUTE11           => null,
                X_GLOBAL_ATTRIBUTE12           => null,
                X_GLOBAL_ATTRIBUTE13           => null,
                X_GLOBAL_ATTRIBUTE14           => null,
                X_GLOBAL_ATTRIBUTE15           => null,
                X_GLOBAL_ATTRIBUTE16           => null,
                X_GLOBAL_ATTRIBUTE17           => null,
                X_GLOBAL_ATTRIBUTE18           => null,
                X_GLOBAL_ATTRIBUTE19           => null,
                X_GLOBAL_ATTRIBUTE20           => null,
                X_STATUS                       => null,
                X_SOURCE                       => l_source,
                X_GROUP_ID                     => l_invoice_number,
                X_WORKFLOW_FLAG                => null,
                X_DOC_CATEGORY_CODE            => null,
                X_VOUCHER_NUM                  => null,
                X_PAY_GROUP_LOOKUP_CODE        => null, --'Standard',
                X_GOODS_RECEIVED_DATE          => null,
                X_INVOICE_RECEIVED_DATE        => sysdate,
                X_GL_DATE                      => l_due_date,
                X_ACCTS_PAY_CCID               => l_cc_id,
    --            X_USSGL_TRANSACTION_CODE       => null,
                X_EXCLUSIVE_PAYMENT_FLAG       => null,
                X_INVOICE_INCLUDES_PREPAY_FLAG => null,
                X_PREPAY_NUM                   => null,
                X_PREPAY_APPLY_AMOUNT          => null,
                X_PREPAY_GL_DATE               => null,
                X_LAST_UPDATE_DATE             => LNS_UTILITY_PUB.LAST_UPDATE_DATE,
                X_LAST_UPDATED_BY              => LNS_UTILITY_PUB.LAST_UPDATED_BY,
                X_LAST_UPDATE_LOGIN            => LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
                X_MODE                         => null,
                X_TERMS_DATE                   => null,
                X_REQUESTER_ID                 => null,
                X_OPERATING_UNIT               => null,
                -- Invoice LINes Project Stage 1
                X_PREPAY_LINE_NUM              => null,
                X_REQUESTER_FIRST_NAME         => null,
                X_REQUESTER_LAST_NAME          => null,
                X_REQUESTER_EMPLOYEE_NUM       => null,
                -- eTax Uptake
                X_CALC_TAX_DURING_IMPORT_FLAG  => null,
                X_CONTROL_AMOUNT               => null,
                X_ADD_TAX_TO_INV_AMT_FLAG      => null,
                X_TAX_RELATED_INVOICE_ID       => null,
                X_TAXATION_COUNTRY             => null,
                X_DOCUMENT_SUB_TYPE            => null,
                X_SUPPLIER_TAX_INVOICE_NUMBER  => null,
                X_SUPPLIER_TAX_INVOICE_DATE    => null,
                X_SUPPLIER_TAX_EXCHANGE_RATE   => null,
                X_TAX_INVOICE_RECORDING_DATE   => null,
                X_TAX_INVOICE_INTERNAL_SEQ	   => null,
                X_LEGAL_ENTITY_ID              => l_le_id,
                x_PAYMENT_METHOD_CODE          => l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
                x_PAYMENT_REASON_CODE          => null,
                X_PAYMENT_REASON_COMMENTS      => null,
                x_UNIQUE_REMITTANCE_IDENTIFIER => null,
                x_URI_CHECK_DIGIT              => null,
                x_BANK_CHARGE_BEARER           => null,
                x_DELIVERY_CHANNEL_CODE        => null,
                x_SETTLEMENT_PRIORITY          => null,
                x_remittance_message1          => null,
                x_remittance_message2          => null,
                x_remittance_message3          => null,
                x_NET_OF_RETAINAGE_FLAG	       => null,
                x_PORT_OF_ENTRY_CODE           => null,
                X_APPLICATION_ID               => 206,
                X_PRODUCT_TABLE                => null,
                X_REFERENCE_KEY1               => null,
                X_REFERENCE_KEY2               => null,
                X_REFERENCE_KEY3               => null,
                X_REFERENCE_KEY4               => null,
                X_REFERENCE_KEY5               => null,
                X_PARTY_ID                     => l_DISB_LINE_REC.PAYEE_PARTY_ID,
                X_PARTY_SITE_ID                => null,
                X_PAY_PROC_TRXN_TYPE_CODE      => 'LOAN_PAYMENT',
                X_PAYMENT_FUNCTION             => 'LOANS_PAYMENTS',
                X_PAYMENT_PRIORITY             => null);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated invoice');

        end if;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO SUBMIT_SINGLE_PAY_REQ;

            if l_new_invoice = 'Y' then
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to insert invoice into interface table');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FAIL_INS_AP_INV');
                FND_MSG_PUB.Add;
            else
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to update invoice into interface table');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FAIL_UPD_AP_INV');
                FND_MSG_PUB.Add;
            end if;

            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Deleting invoice interface lines
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting invoice interface lines...');

    delete from AP_INVOICE_LINES_INTERFACE
    where INVOICE_ID = l_invoice_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleted');

    -- query clearing distribution info and generating invoice lines
    open clearing_distr_cur(l_DISB_HEADER_REC.LOAN_ID, l_DISB_LINE_REC.DISB_HEADER_ID);

    l_precision_queried := 0;
    l_Count1 := 0;
    l_running_sum := 0;
    l_sum_percent := 0;
    LOOP

        fetch clearing_distr_cur into
            l_cc_id,
            l_percent;

        if clearing_distr_cur%NOTFOUND and l_Count1 > 0 then
            exit;
        elsif clearing_distr_cur%NOTFOUND and l_Count1 = 0 then
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'No distribution record found - setting cc_id = null and percent = 100');
            l_cc_id := null;
            l_percent := 100;
        end if;

        l_Count1 := l_Count1 + 1;
        l_sum_percent := l_sum_percent + l_percent;

        if l_precision_queried = 0 then
            -- get precision
            fnd_currency.GET_INFO(CURRENCY_CODE => l_loan_currency,
                                PRECISION => l_precision,
                                EXT_PRECISION => l_ext_precision,
                                MIN_ACCT_UNIT => l_min_acct_unit);

            l_precision_queried := 1;
        end if;

        -- for each distribution create seperate invoice line
        if l_percent < 100 then

            if l_sum_percent < 100 then

                l_line_amount := round(l_DISB_LINE_REC.LINE_AMOUNT * l_percent / 100, l_precision);

            else

                l_line_amount := l_DISB_LINE_REC.LINE_AMOUNT - l_running_sum;

            end if;

            l_running_sum := l_running_sum + l_line_amount;

        else
            l_line_amount := l_DISB_LINE_REC.LINE_AMOUNT;
        end if;

        l_description :=  l_invoice_number || ' line' || l_Count1;

        -- generating new invoice line id
        open new_inv_ln_id_cur;
        fetch new_inv_ln_id_cur into l_invoice_line_id;
        close new_inv_ln_id_cur;

        BEGIN

            SAVEPOINT SUBMIT_SINGLE_PAY_REQ;

            -- inserting invoice line
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting AP invoice line ' || l_Count1 || ' into interface table...');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line ID: ' || l_invoice_line_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line Amount: ' || l_line_amount);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Description: ' || l_description);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Accounting Date: ' || l_due_date);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'DIST_CODE_COMBINATION_ID: ' || l_cc_id);

            AP_INVOICE_LINES_INTERFACE_PKG.INSERT_ROW(
                X_ROWID                        => l_inv_line_row_id,
                X_INVOICE_ID                   => l_invoice_id,
                X_INVOICE_LINE_ID              => l_invoice_line_id,
                X_LINE_NUMBER                  => l_Count1,
                X_LINE_TYPE_LOOKUP_CODE        => 'ITEM',
                X_LINE_GROUP_NUMBER            => null,
                X_AMOUNT                       => l_line_amount,
                X_ACCOUNTING_DATE              => l_due_date,
                X_DESCRIPTION                  => l_description,
                -- X_AMOUNT_INCLUDES_TAX_FLAG     => null,
                X_PRORATE_ACROSS_FLAG          => null,
                X_TAX_CODE                     => null,
                X_TAX_CODE_ID                  => null,
                -- X_TAX_CODE_OVERRIDE_FLAG       => null,
                -- X_TAX_RECOVERY_RATE            => null,
                -- X_TAX_RECOVERY_OVERRIDE_FLAG   => null,
                -- X_TAX_RECOVERABLE_FLAG         => null,
                X_FINAL_MATCH_FLAG             => null,
                X_PO_HEADER_ID                 => null,
                X_PO_LINE_ID                   => null,
                X_PO_LINE_LOCATION_ID          => null,
                X_PO_DISTRIBUTION_ID           => null,
                X_UNIT_OF_MEAS_LOOKUP_CODE     => null,
                X_INVENTORY_ITEM_ID            => null,
                X_QUANTITY_INVOICED            => null,
                X_UNIT_PRICE                   => null,
                X_DISTRIBUTION_SET_ID          => null,
                X_DIST_CODE_CONCATENATED       => null,
                X_DIST_CODE_COMBINATION_ID     => l_cc_id,
                X_AWT_GROUP_ID                 => null,
                X_ATTRIBUTE_CATEGORY           => null,
                X_ATTRIBUTE1                   => null,
                X_ATTRIBUTE2                   => null,
                X_ATTRIBUTE3                   => null,
                X_ATTRIBUTE4                   => null,
                X_ATTRIBUTE5                   => null,
                X_ATTRIBUTE6                   => null,
                X_ATTRIBUTE7                   => null,
                X_ATTRIBUTE8                   => null,
                X_ATTRIBUTE9                   => null,
                X_ATTRIBUTE10                  => null,
                X_ATTRIBUTE11                  => null,
                X_ATTRIBUTE12                  => null,
                X_ATTRIBUTE13                  => null,
                X_ATTRIBUTE14                  => null,
                X_ATTRIBUTE15                  => null,
                X_GLOBAL_ATTRIBUTE_CATEGORY    => null,
                X_GLOBAL_ATTRIBUTE1            => null,
                X_GLOBAL_ATTRIBUTE2            => null,
                X_GLOBAL_ATTRIBUTE3            => null,
                X_GLOBAL_ATTRIBUTE4            => null,
                X_GLOBAL_ATTRIBUTE5            => null,
                X_GLOBAL_ATTRIBUTE6            => null,
                X_GLOBAL_ATTRIBUTE7            => null,
                X_GLOBAL_ATTRIBUTE8            => null,
                X_GLOBAL_ATTRIBUTE9            => null,
                X_GLOBAL_ATTRIBUTE10           => null,
                X_GLOBAL_ATTRIBUTE11           => null,
                X_GLOBAL_ATTRIBUTE12           => null,
                X_GLOBAL_ATTRIBUTE13           => null,
                X_GLOBAL_ATTRIBUTE14           => null,
                X_GLOBAL_ATTRIBUTE15           => null,
                X_GLOBAL_ATTRIBUTE16           => null,
                X_GLOBAL_ATTRIBUTE17           => null,
                X_GLOBAL_ATTRIBUTE18           => null,
                X_GLOBAL_ATTRIBUTE19           => null,
                X_GLOBAL_ATTRIBUTE20           => null,
                X_PO_RELEASE_ID                => null,
                X_BALANCING_SEGMENT            => null,
                X_COST_CENTER_SEGMENT          => null,
                X_ACCOUNT_SEGMENT              => null,
                X_PROJECT_ID                   => null,
                X_TASK_ID                      => null,
                X_EXPENDITURE_TYPE             => null,
                X_EXPENDITURE_ITEM_DATE        => null,
                X_EXPENDITURE_ORGANIZATION_ID  => null,
                X_PROJECT_ACCOUNTING_CONTEXT   => null,
                X_PA_ADDITION_FLAG             => null,
                X_PA_QUANTITY                  => null,
                X_STAT_AMOUNT                  => null,
                X_TYPE_1099                    => null,
                X_INCOME_TAX_REGION            => null,
                X_ASSETS_TRACKING_FLAG         => null,
                X_PRICE_CORRECTION_FLAG        => null,
--                X_USSGL_TRANSACTION_CODE       => null,
                X_RECEIPT_NUMBER               => null,
                X_MATCH_OPTION                 => null,
                X_RCV_TRANSACTION_ID           => null,
                X_CREATION_DATE                => LNS_UTILITY_PUB.CREATION_DATE,
                X_CREATED_BY                   => LNS_UTILITY_PUB.CREATED_BY,
                X_LAST_UPDATE_DATE             => LNS_UTILITY_PUB.LAST_UPDATE_DATE,
                X_LAST_UPDATED_BY              => LNS_UTILITY_PUB.LAST_UPDATED_BY,
                X_LAST_UPDATE_LOGIN            => LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
                X_ORG_ID                       => l_org_id,
                X_MODE                         => null,
                X_Calling_Sequence             => null,
                X_award_id                     => null,
                X_price_correct_inv_num        => null,
                -- Invoice Lines Project Stage 1
                X_PRICE_CORRECT_INV_LINE_NUM   => null,
                X_SERIAL_NUMBER                => null,
                X_MANUFACTURER                 => null,
                X_MODEL_NUMBER                 => null,
                X_WARRANTY_NUMBER              => null,
                X_ASSET_BOOK_TYPE_CODE         => null,
                X_ASSET_CATEGORY_ID            => null,
                X_REQUESTER_FIRST_NAME         => null,
                X_REQUESTER_LAST_NAME          => null,
                X_REQUESTER_EMPLOYEE_NUM       => null,
                X_REQUESTER_ID                 => null,
                X_DEFERRED_ACCTG_FLAG          => null,
                X_DEF_ACCTG_START_DATE         => null,
                X_DEF_ACCTG_END_DATE           => null,
                X_DEF_ACCTG_NUMBER_OF_PERIODS  => null,
                X_DEF_ACCTG_PERIOD_TYPE        => null,
                -- eTax Uptake
                X_CONTROL_AMOUNT               => null,
                X_ASSESSABLE_VALUE             => null,
                X_DEFAULT_DIST_CCID            => null,
                X_PRIMARY_INTENDED_USE	       => null,
                X_SHIP_TO_LOCATION_ID          => null,
                X_PRODUCT_TYPE                 => null,
                X_PRODUCT_CATEGORY             => null,
                X_PRODUCT_FISC_CLASSIFICATION  => null,
                X_USER_DEFINED_FISC_CLASS      => null,
                X_TRX_BUSINESS_CATEGORY	       => null,
                X_TAX_REGIME_CODE              => null,
                X_TAX                          => null,
                X_TAX_JURISDICTION_CODE	       => null,
                X_TAX_STATUS_CODE              => null,
                X_TAX_RATE_ID                  => null,
                X_TAX_RATE_CODE                => null,
                X_TAX_RATE                     => null,
                X_INCL_IN_TAXABLE_LINE_FLAG	   => null,
                X_PURCHASING_CATEGORY          => null,
                X_PURCHASING_CATEGORY_ID       => null,
                X_COST_FACTOR_NAME             => null,
                X_COST_FACTOR_ID               => null);

        EXCEPTION
        WHEN OTHERS THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to insert invoice line into interface table');
            ROLLBACK TO SUBMIT_SINGLE_PAY_REQ;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_FAIL_INS_AP_INV_LN');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted new invoice line.');

    END LOOP;

    close clearing_distr_cur;

    l_DISB_LINE_REC.INVOICE_INTERFACE_ID := l_invoice_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Submitted payment request...');

    AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST(
        p_api_version             => '1.0',
        p_invoice_interface_id    => l_invoice_id,
        p_budget_control	  => 'N', --Loans takes care of reserving funds using BC - AP should not reserve funds again
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data,
        p_invoice_id              => l_DISB_LINE_REC.INVOICE_ID,
        x_rejection_list          => l_rejections,
        p_calling_sequence        => l_api_name);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST return status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST return invoice_id: ' || l_DISB_LINE_REC.INVOICE_ID);

    -- sanity check: get invoice_id straight from AP
    open get_invoice_cur(l_invoice_number, l_DISB_LINE_REC.PAYEE_PARTY_ID);
    fetch get_invoice_cur into l_ap_inv_id;
    close get_invoice_cur;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Straight query of invoive_id from AP: ' || l_ap_inv_id);

    if l_return_status <> 'S' and
       l_DISB_LINE_REC.INVOICE_ID is null and
       l_ap_inv_id is not null then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'INTERNAL AP ERROR: AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST failed but invoice WAS CREATED!!! Proceeding as its success');
        l_return_status := 'S';
        l_DISB_LINE_REC.INVOICE_ID := l_ap_inv_id;

    elsif l_return_status <> 'S' and
        l_DISB_LINE_REC.INVOICE_ID is not null and
        l_ap_inv_id is not null and
        l_DISB_LINE_REC.INVOICE_ID = l_ap_inv_id then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'INTERNAL AP ERROR: AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST return status is not S but return invoice id is set!!! Proceeding as its success');
        l_return_status := 'S';

    end if;

    IF l_return_status = 'S' THEN

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully submitted payment request.');
        l_DISB_LINE_REC.STATUS := 'IN_FUNDING';
        l_DISB_LINE_REC.REQUEST_DATE := sysdate;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting new history record...');
        -- calling history table handler api
        LNS_DISB_HISTORIES_H_PKG.Insert_Row(
            X_DISB_HISTORY_ID       => l_hist_id,
            P_DISB_LINE_ID          => l_DISB_LINE_REC.DISB_LINE_ID,
            P_ATTEMPT_NUMBER        => l_attempt,
            P_BANK_ACCOUNT_ID       => l_DISB_LINE_REC.BANK_ACCOUNT_ID,
            P_PAYMENT_METHOD_CODE   => l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
            P_REQUEST_DATE          => l_DISB_LINE_REC.REQUEST_DATE,
            P_PAYMENT_REQUEST_DATE  => l_due_date,
            P_STATUS                => l_DISB_LINE_REC.STATUS,
            P_MESSAGES              => null,
            P_OBJECT_VERSION_NUMBER => 1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted new history record with DISB_HISTORY_ID: ' || l_hist_id);

        UPDATE_DISB_LINE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST     => FND_API.G_FALSE,
            P_COMMIT            => FND_API.G_TRUE,
            P_VALIDATION_LEVEL  => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_LINE_REC     => l_DISB_LINE_REC,
            X_RETURN_STATUS     => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA          => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_LINE failed');
        END IF;

    ELSIF l_return_status = 'R' THEN

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Submit payment request return status: ' || l_return_status);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rejections count: ' || l_rejections.COUNT);

        if l_rejections.COUNT > 0 then

            FOR l_Count2 IN 1..l_rejections.COUNT LOOP

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rejection ' || l_Count2);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'parent_table: ' || l_rejections(l_Count2).parent_table);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'parent_id: ' || l_rejections(l_Count2).parent_id);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'reject_lookup_code: ' || l_rejections(l_Count2).reject_lookup_code);

                -- get rejection description
                open get_reject_cur(l_rejections(l_Count2).reject_lookup_code);
                fetch get_reject_cur into l_reject_desc;
                close get_reject_cur;

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rejection desc: ' || l_reject_desc);

                if l_rejections(l_Count2).parent_table = 'AP_INVOICES_INTERFACE' then

                    -- get party for rejection
                    open get_party1_cur(l_rejections(l_Count2).parent_id);
                    fetch get_party1_cur into l_payee;
                    close get_party1_cur;

                elsif l_rejections(l_Count2).parent_table = 'AP_INVOICE_LINES_INTERFACE' then

                    -- get party for rejection
                    open get_party2_cur(l_rejections(l_Count2).parent_id);
                    fetch get_party2_cur into l_payee;
                    close get_party2_cur;

                end if;

                FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_REJECTION');
                FND_MESSAGE.SET_TOKEN('PAYEE', l_payee);
                FND_MESSAGE.SET_TOKEN('REJECTION', l_reject_desc);
                FND_MSG_PUB.Add;

            END LOOP;

        else
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No rejections have been returned');
        end if;

        RAISE FND_API.G_EXC_ERROR;

    ELSE

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Submit payment request return status: ' || l_return_status);
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    COMMIT WORK;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully submitted single payment request');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN

        l_DISB_LINE_REC.STATUS := 'FUNDING_ERROR';
        l_DISB_LINE_REC.REQUEST_DATE := sysdate;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting new history record...');
        -- calling history table handler api
        LNS_DISB_HISTORIES_H_PKG.Insert_Row(
            X_DISB_HISTORY_ID       => l_hist_id,
            P_DISB_LINE_ID          => l_DISB_LINE_REC.DISB_LINE_ID,
            P_ATTEMPT_NUMBER        => l_attempt,
            P_BANK_ACCOUNT_ID       => l_DISB_LINE_REC.BANK_ACCOUNT_ID,
            P_PAYMENT_METHOD_CODE   => l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
            P_REQUEST_DATE          => sysdate,
            P_PAYMENT_REQUEST_DATE  => l_due_date,
            P_STATUS                => l_DISB_LINE_REC.STATUS,
            P_MESSAGES              => null,
            P_OBJECT_VERSION_NUMBER => 1);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted new history record with DISB_HISTORY_ID: ' || l_hist_id);

        UPDATE_DISB_LINE(P_API_VERSION      => 1.0,
                         P_INIT_MSG_LIST    => FND_API.G_FALSE,
                         P_COMMIT           => FND_API.G_TRUE,
                         P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                         P_DISB_LINE_REC    => l_DISB_LINE_REC,
                         X_RETURN_STATUS    => l_return_status,
                         X_MSG_COUNT        => l_msg_count,
                         X_MSG_DATA         => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_LINE failed');
        END IF;

        COMMIT WORK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END;



/*========================================================================
 | PUBLIC PROCEDURE SUBMIT_AUTODISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure submits 1-st disbursement of a loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SUBMIT_AUTODISBURSEMENT(P_API_VERSION       IN          NUMBER,
                                  P_INIT_MSG_LIST     IN          VARCHAR2,
                                  P_COMMIT            IN          VARCHAR2,
                                  P_VALIDATION_LEVEL  IN          NUMBER,
                                  P_LOAN_ID           IN          NUMBER,
                                  X_RETURN_STATUS     OUT NOCOPY  VARCHAR2,
                                  X_MSG_COUNT         OUT NOCOPY  NUMBER,
                                  X_MSG_DATA          OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SUBMIT_AUTODISBURSEMENT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_disb_header_id                number;
    l_autofunding_flag              varchar2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info
    CURSOR disb_headers_cur(P_LOAN_ID number) IS
        select head.DISB_HEADER_ID,
            nvl(head.AUTOFUNDING_FLAG, 'N')
        from LNS_LOAN_HEADERS_ALL loan,
            LNS_DISB_HEADERS head
        where loan.LOAN_ID = P_LOAN_ID and
            loan.loan_id = head.loan_id and
            head.DISBURSEMENT_NUMBER = 1 and
            nvl(loan.CURRENT_PHASE, 'TERM') = nvl(head.PHASE, 'OPEN');

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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

    -- getting disbursement header info
    open disb_headers_cur(P_LOAN_ID);
    fetch disb_headers_cur into l_disb_header_id, l_autofunding_flag;
    close disb_headers_cur;

    if l_autofunding_flag = 'Y' then
        LNS_COND_ASSIGNMENT_PUB.VALIDATE_CUSTOM_CONDITIONS(
                            P_API_VERSION		    => 1.0,
                            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
                            P_COMMIT			    => FND_API.G_FALSE,
                            P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
                            P_OWNER_OBJECT_ID       => l_disb_header_id,
                            P_CONDITION_TYPE        => 'DISBURSEMENT',
                            P_COMPLETE_FLAG         => 'Y',
                            X_RETURN_STATUS		    => l_return_status,
                            X_MSG_COUNT			    => l_msg_count,
                            X_MSG_DATA	    		=> l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        end if;

        SUBMIT_DISBURSEMENT(P_API_VERSION      => 1.0,
                            P_INIT_MSG_LIST    => FND_API.G_FALSE,
                            P_COMMIT           => FND_API.G_FALSE,
                            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                            P_DISB_HEADER_ID   => l_disb_header_id,
                            X_RETURN_STATUS    => l_return_status,
                            X_MSG_COUNT        => l_msg_count,
                            X_MSG_DATA         => l_msg_data);

        x_return_status := l_return_status;
    else
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
    end if;

    COMMIT WORK;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'SUBMIT_AUTODISBURSEMENT returned status: ' || x_return_status);

    -- END OF BODY OF API
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END;




/*========================================================================
 | PUBLIC PROCEDURE SUBMIT_DISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure submits disbursement to AP.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Header ID
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
 | 06-23-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SUBMIT_DISBURSEMENT(P_API_VERSION       IN          NUMBER,
                              P_INIT_MSG_LIST     IN          VARCHAR2,
                              P_COMMIT            IN          VARCHAR2,
                              P_VALIDATION_LEVEL  IN          NUMBER,
                              P_DISB_HEADER_ID    IN          NUMBER,
                              X_RETURN_STATUS     OUT NOCOPY  VARCHAR2,
                              X_MSG_COUNT         OUT NOCOPY  NUMBER,
                              X_MSG_DATA          OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SUBMIT_DISBURSEMENT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;

    TYPE DISB_LINES_TBL IS TABLE OF LNS_FUNDING_PUB.LNS_DISB_LINES_REC INDEX BY BINARY_INTEGER;
    l_DISB_LINES_TBL                DISB_LINES_TBL;

    l_loan_number                   varchar2(60);
    l_Count                         number;
    l_Count1                        number;
    l_loan_id                       number;
    l_cond_count                    number;
    l_loan_version                  number;
    l_disb_number                   number;
    l_loan_status                   VARCHAR2(30);
    l_submit_disb                   varchar2(1);
    l_status_code                   varchar2(10);
    l_funds_reserved_flag           varchar2(1);
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement line info
    CURSOR disb_line_cur(P_DISB_HEADER_ID number) IS
        select
            DISB_LINE_ID,
            DISB_HEADER_ID,
            DISB_LINE_NUMBER,
            LINE_AMOUNT,
            LINE_PERCENT,
            PAYEE_PARTY_ID,
            BANK_ACCOUNT_ID,
            PAYMENT_METHOD_CODE,
            STATUS,
            REQUEST_DATE,
            OBJECT_VERSION_NUMBER
        from LNS_DISB_LINES
        where DISB_HEADER_ID = P_DISB_HEADER_ID and
            (status is null or status = 'FUNDING_ERROR');

    -- query loan details
    CURSOR loan_detail_cur(P_DISB_HEADER_ID number) IS
        select loan.LOAN_ID,
               loan.LOAN_NUMBER,
               loan.OBJECT_VERSION_NUMBER,
               loan.LOAN_STATUS,
               head.DISBURSEMENT_NUMBER,
               nvl(loan.FUNDS_RESERVED_FLAG,'N')
        from LNS_LOAN_HEADERS_ALL loan,
            LNS_DISB_HEADERS head
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID and
            head.LOAN_ID = loan.LOAN_ID;

    -- checking for conditions
    CURSOR conditions_cur(P_DISB_HEADER_ID number) IS
        select count(1)
        from LNS_COND_ASSIGNMENTS
        where
        DISB_HEADER_ID = P_DISB_HEADER_ID and
        MANDATORY_FLAG = 'Y' and
        (CONDITION_MET_FLAG is null or CONDITION_MET_FLAG = 'N') and
        (end_date_active is null or trunc(end_date_active) > trunc(sysdate));

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Submitting disbursement header ' || P_DISB_HEADER_ID || '...');

    -- query loan details
    open loan_detail_cur(P_DISB_HEADER_ID);
    fetch loan_detail_cur into l_loan_id,
                               l_loan_number,
                               l_loan_version,
                               l_loan_status,
                               l_disb_number,
                               l_funds_reserved_flag;

    -- if no record exists - return; otherwise proceed
    if loan_detail_cur%NOTFOUND then

--        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ERROR: Loan Record is not found');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'loan header');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_DISB_HEADER_ID), 'null'));
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    close loan_detail_cur;

    -- if its 1-st disbursement and funds not already reserved, call BC to reserve funds
    if (l_disb_number = 1 and l_funds_reserved_flag <> 'Y') then

        LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Calling lns_distributions_pub.budgetary_control...');

        BEGIN
            lns_distributions_pub.budgetary_control(p_init_msg_list       => FND_API.G_FALSE
                                                ,p_commit                 => FND_API.G_FALSE
                                                ,p_loan_id                => l_loan_id
                                                ,p_budgetary_control_mode => 'R'
                                                ,x_budgetary_status_code  => l_status_code
                                                ,x_return_status          => l_return_status
                                                ,x_msg_count              => l_msg_count
                                                ,x_msg_data               => l_msg_data);
        EXCEPTION
            WHEN OTHERS THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'lns_distributions_pub.budgetary_control throws exception');
                RAISE FND_API.G_EXC_ERROR;
        END;

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to lns_distributions_pub.budgetary_control failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    VALIDATE_DISB_FOR_SUBMIT(P_API_VERSION      => 1.0,
                             P_INIT_MSG_LIST    => FND_API.G_TRUE,
                             P_COMMIT           => FND_API.G_FALSE,
                             P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                             P_DISB_HEADER_ID   => P_DISB_HEADER_ID,
                             X_RETURN_STATUS    => l_return_status,
                             X_MSG_COUNT        => l_msg_count,
                             X_MSG_DATA         => l_msg_data);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to VALIDATE_DISB_FOR_SUBMIT failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- checking for conditions
    open conditions_cur(P_DISB_HEADER_ID);
    fetch conditions_cur into l_cond_count;
    close conditions_cur;

    if l_cond_count > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_ALL_COND_MET');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- create iby external payee
    CREATE_EXT_IBY_PAYEE(P_DISB_HEADER_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching for disbursement lines to creating payment requests...');

    -- getting disbursement line info
    open disb_line_cur(P_DISB_HEADER_ID);

    l_count := 0;
    l_count1 := 0;
    LOOP

        fetch disb_line_cur into
            l_DISB_LINE_REC.DISB_LINE_ID,
            l_DISB_LINE_REC.DISB_HEADER_ID,
            l_DISB_LINE_REC.DISB_LINE_NUMBER,
            l_DISB_LINE_REC.LINE_AMOUNT,
            l_DISB_LINE_REC.LINE_PERCENT,
            l_DISB_LINE_REC.PAYEE_PARTY_ID,
            l_DISB_LINE_REC.BANK_ACCOUNT_ID,
            l_DISB_LINE_REC.PAYMENT_METHOD_CODE,
            l_DISB_LINE_REC.STATUS,
            l_DISB_LINE_REC.REQUEST_DATE,
            l_DISB_LINE_REC.OBJECT_VERSION_NUMBER;

        exit when disb_line_cur%NOTFOUND;

        l_count := l_count + 1;
        l_DISB_LINES_TBL(l_count) := l_DISB_LINE_REC;

        SUBMIT_SINGLE_PAY_REQ(P_API_VERSION      => 1.0,
                              P_INIT_MSG_LIST    => FND_API.G_FALSE,
                              P_COMMIT           => FND_API.G_FALSE,
                              P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                              P_DISB_LINE_ID     => l_DISB_LINES_TBL(l_count).DISB_LINE_ID,
                              X_RETURN_STATUS    => l_return_status,
                              X_MSG_COUNT        => l_msg_count,
                              X_MSG_DATA         => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'SUBMIT_SINGLE_PAY_REQ  return status: ' || l_return_status);

        -- counting errors
        if l_return_status <> 'S' then
            l_count1 := l_count1 + 1;
        end if;

    END LOOP;

    close disb_line_cur;

    if l_count = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No disbursement lines found to create payment request');
    else
        if l_count1 = 0 then                            -- nothing has failed
            l_DISB_HEADER_REC.STATUS := 'IN_FUNDING';
            l_loan_header_rec.SECONDARY_STATUS := 'IN_FUNDING';
        elsif l_count = l_count1 then                   -- fully failed
            l_DISB_HEADER_REC.STATUS := 'FUNDING_ERROR';
            l_loan_header_rec.SECONDARY_STATUS := 'FUNDING_ERROR';
        else                                            -- partially failed
            l_DISB_HEADER_REC.STATUS := 'FUNDING_ERROR';
            l_loan_header_rec.SECONDARY_STATUS := 'FUNDING_ERROR';
        end if;

        l_DISB_HEADER_REC.DISB_HEADER_ID := l_DISB_LINE_REC.DISB_HEADER_ID;
        UPDATE_DISB_HEADER(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
        END IF;

        l_loan_header_rec.LOAN_ID := l_loan_id;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary status: ' || l_loan_header_rec.SECONDARY_STATUS);

        LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                        P_LOAN_HEADER_REC => l_loan_header_rec,
                                        P_INIT_MSG_LIST => FND_API.G_FALSE,
                                        X_RETURN_STATUS => l_return_status,
                                        X_MSG_COUNT => l_msg_count,
                                        X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
        ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
--            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    COMMIT WORK;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');

    if l_count1 > 0 then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'SUBMIT_DISBURSEMENT returned status: ' || x_return_status);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if x_msg_count = 0 then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_SUBMIT_DISB_FAILED');
            FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'SUBMIT_DISBURSEMENT returned status: ' || x_return_status);

END;

/*========================================================================
 | PRIVATE PROCEDURE PAY_SINGLE_INVOICE
 |
 | DESCRIPTION
 |      This procedure pays single AP invoice
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_INVOICE_ID  		    IN          Check ID
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
 | 07-25-2005            scherkas          Created
 | 06-02-2006            karamach          If this is the first funding for the disb header, then update the payment_request_date to be the sysdate to fix bug5232416
 | 13-JUL-2007		 mbolli		   Bug#6169438 - If the loan dates are shifted then regenerate the Loan Agreements
 *=======================================================================*/
PROCEDURE PAY_SINGLE_INVOICE
    (P_INVOICE_ID              IN             NUMBER,
    P_COMPLETE_FLAG            IN             VARCHAR2,
    X_Return_Status            OUT     NOCOPY VARCHAR2,
    X_Msg_Count                OUT     NOCOPY NUMBER,
    X_Msg_Data                 OUT     NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PAY_SINGLE_INVOICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_disb_line_id                  number;
    l_funded_count                  number;
    l_loan_version                  number;
    l_hist_id                       number;
    l_hist_version                  number;
    l_TERM_ID                       number;
    l_TERM_VERSION_NUMBER           number;
    l_requested_amount              number;
    l_do_billing                    number;
    l_request_id                    number;
    l_inv_amount                    number;
    l_inv_paid_amount               number;
    l_MULTIPLE_FUNDING_FLAG         varchar2(1);
    l_notify                        boolean;
    l_xml_output                    BOOLEAN;
    l_iso_language                  FND_LANGUAGES.iso_language%TYPE;
    l_iso_territory                 FND_LANGUAGES.iso_territory%TYPE;
    l_last_api_called               varchar2(500);
    l_agreement_reason              varchar2(500);

    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;
    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_term_rec                      LNS_TERMS_PUB.loan_term_rec_type;
    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_event_table                   lns_distributions_pub.acc_event_tbl;
    l_funded_lines_count            number;
    l_dates_shifted_flag            varchar2(1) := 'N';
    isDisbDateChange		        varchar2(1) := 'N';
    hdrIdCnt                        NUMBER;
    l_do_conversion_bill 	        varchar2(1) := 'N';
    l_do_origination_bill  	        varchar2(1) := 'N';
    l_currency                      varchar2(15);
    l_disb_desc                     varchar2(80);

    TYPE lns_disb_hdr_id_type IS TABLE OF LNS_DISB_HEADERS.DISB_HEADER_ID%TYPE INDEX BY PLS_INTEGER;
    l_disb_hdr_id_tbl  lns_disb_hdr_id_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement line and header info
    CURSOR disb_line_cur(P_INVOICE_ID number) IS
        select
            lines.DISB_LINE_ID,
            lines.DISB_HEADER_ID,
            lines.OBJECT_VERSION_NUMBER,
            head.loan_id,
            head.OBJECT_VERSION_NUMBER,
            head.status,
            head.PAYMENT_REQUEST_DATE,
            loan.OBJECT_VERSION_NUMBER,
            loan.REQUESTED_AMOUNT + nvl(loan.ADD_REQUESTED_AMOUNT, 0),
            loan.current_phase,
            loan.OPEN_TO_TERM_FLAG,
            loan.OPEN_TO_TERM_EVENT,
            loan.loan_status,
            head.DISBURSEMENT_NUMBER,
            loan.secondary_status,
            loan.MULTIPLE_FUNDING_FLAG,
            head.phase,
            loan.LOAN_CURRENCY,
            decode(head.ACTIVITY_CODE, null, head.DESCRIPTION, lns_utility_pub.get_lookup_meaning('DISB_ACTIVITY', head.ACTIVITY_CODE))
        from LNS_DISB_LINES lines,
            LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS loan
        where lines.INVOICE_ID = P_INVOICE_ID and
            lines.DISB_HEADER_ID = head.DISB_HEADER_ID and
            lines.status is not null and lines.status <> 'FULLY_FUNDED' and
            head.LOAN_ID = loan.LOAN_ID;

    -- getting partially or fully funded lines count
    CURSOR c_funded_lines_count_cur(P_DISB_HEADER_ID number) IS
            select count(1) from LNS_DISB_LINES
            where DISB_HEADER_ID = P_DISB_HEADER_ID and STATUS IN ('FULLY_FUNDED', 'PARTIALLY_FUNDED');

    -- getting diff between total lines count and fully funded lines
    CURSOR funded_count_cur(P_DISB_HEADER_ID number) IS
        select
            (select count(1) from LNS_DISB_LINES
            where DISB_HEADER_ID = P_DISB_HEADER_ID)
           -
            (select count(1) from LNS_DISB_LINES
            where DISB_HEADER_ID = P_DISB_HEADER_ID and (STATUS is not null and STATUS = 'FULLY_FUNDED'))
        from dual;

    -- getting sum of all disbursed amount for this loan from ap_invoices_all - real situation
    CURSOR disb_amount_cur(P_LOAN_ID number) IS
        select nvl(sum(inv.amount_paid), 0)
        from LNS_DISB_LINES lines,
            LNS_DISB_HEADERS head,
            ap_invoices_all inv,
            lns_loan_headers_all loan
        where head.LOAN_ID = P_LOAN_ID and
            head.loan_id = loan.loan_id and
            --nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN') and
            lines.DISB_HEADER_ID = head.DISB_HEADER_ID and
            lines.invoice_id is not null and
            lines.invoice_id = inv.invoice_id;

    -- getting sum of all disbursed amount for this loan from lns_disb_lines - testing
    CURSOR disb_amount_cur1(P_LOAN_ID number) IS
        select nvl(sum(lines.LINE_AMOUNT), 0)
        from LNS_DISB_LINES lines,
            LNS_DISB_HEADERS head
        where head.LOAN_ID = P_LOAN_ID and
            lines.DISB_HEADER_ID = head.DISB_HEADER_ID and
            (lines.STATUS is not null and lines.STATUS = 'FULLY_FUNDED') and
            lines.DISBURSEMENT_DATE is not null;

    -- getting last history record to update status
    CURSOR last_hist_rec_cur(P_DISB_LINE_ID number) IS
        select max(DISB_HISTORY_ID), max(OBJECT_VERSION_NUMBER+1)
        from lns_disb_histories_h
        where DISB_LINE_ID = P_DISB_LINE_ID;

    -- query term version
    CURSOR term_version_cur(P_LOAN_ID number) IS
        select TERM_ID,
        OBJECT_VERSION_NUMBER
        from LNS_TERMS
        where LOAN_ID = P_LOAN_ID;

    -- check to start billing for 0-th installment
    CURSOR do_billing_cur(C_LOAN_ID number, C_PHASE varchar2) IS
        select nvl(count(1),0)
        from lns_fee_assignments
        where begin_installment_number = 0
        and end_installment_number = 0
        and end_date_active is null
        and (billing_option = 'ORIGINATION'
             -- Only for Term Pase, check the Event_conversion Fees
                OR billing_option = decode(nvl(C_PHASE, 'TERM'), 'TERM','TERM_CONVERSION', null)
              )
        and loan_id = C_LOAN_ID
	and phase = C_PHASE;

    -- get invoice payment amount
    CURSOR inv_paid_amount_cur(P_INVOICE_ID number) IS
        select INVOICE_AMOUNT, AMOUNT_PAID
        from ap_invoices_all
        where invoice_id = P_INVOICE_ID;

    -- get min payment date - fix for bug 6906841
    CURSOR payments_date_cur(P_INVOICE_ID number) IS
        select min(check_date)
        from AP_INVOICE_PAYMENTS_V
        where
        INVOICE_ID = P_INVOICE_ID;

	CURSOR c_disb_hdr_id(c_disb_hdr_id NUMBER)  IS
	select dh.disb_header_id
	from lns_disb_headers dh
	where dh.loan_id = l_loan_header_rec.loan_id
		and dh.disb_header_id >= c_disb_hdr_id;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT PAY_SINGLE_INVOICE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing payment...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_INVOICE_ID: ' || P_INVOICE_ID);

    -- getting disbursement line info
    open disb_line_cur(P_INVOICE_ID);
    fetch disb_line_cur into l_DISB_LINE_REC.DISB_LINE_ID,
                            l_DISB_HEADER_REC.DISB_HEADER_ID,
                            l_DISB_LINE_REC.OBJECT_VERSION_NUMBER,
                            l_loan_header_rec.loan_id,
                            l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER,
                            l_DISB_HEADER_REC.STATUS,
			                l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE,
                            l_loan_version,
                            l_requested_amount,
                            l_loan_header_rec.current_phase,
                            l_loan_header_rec.OPEN_TO_TERM_FLAG,
                            l_loan_header_rec.OPEN_TO_TERM_EVENT,
                            l_loan_header_rec.loan_status,
                            l_DISB_HEADER_REC.DISBURSEMENT_NUMBER,
                            l_loan_header_rec.secondary_status,
                            l_MULTIPLE_FUNDING_FLAG,
                            l_DISB_HEADER_REC.PHASE,
                            l_currency,
                            l_disb_desc;

    if disb_line_cur%NOTFOUND then
        close disb_line_cur;
        return;
    end if;

    close disb_line_cur;

    if P_COMPLETE_FLAG = 'Y' then       -- testing

        l_DISB_LINE_REC.STATUS := 'FULLY_FUNDED';
        l_DISB_LINE_REC.DISBURSEMENT_DATE := sysdate;

    else        -- real

        -- get invoice payment amount
        open inv_paid_amount_cur(P_INVOICE_ID);
        fetch inv_paid_amount_cur into l_inv_amount, l_inv_paid_amount;
        close inv_paid_amount_cur;

        if l_inv_amount = l_inv_paid_amount then
            l_DISB_LINE_REC.STATUS := 'FULLY_FUNDED';
        elsif l_inv_amount > l_inv_paid_amount then
            l_DISB_LINE_REC.STATUS := 'PARTIALLY_FUNDED';
        end if;

        -- get min payment date - fix for bug 6906841
        open payments_date_cur(P_INVOICE_ID);
        fetch payments_date_cur into l_DISB_LINE_REC.DISBURSEMENT_DATE;
        close payments_date_cur;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'L_DISB_HEADER_REC.PAYMENT_REQUEST_DATE = ' || L_DISB_HEADER_REC.PAYMENT_REQUEST_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_DISB_LINE_REC.DISBURSEMENT_DATE = ' || l_DISB_LINE_REC.DISBURSEMENT_DATE);

    IF (L_DISB_HEADER_REC.PAYMENT_REQUEST_DATE <> l_DISB_LINE_REC.DISBURSEMENT_DATE) THEN
        isDisbDateChange := 'Y';
    END IF;

    -- getting partially or fully funded lines count before updating disb lines with new status
    open c_funded_lines_count_cur(l_DISB_HEADER_REC.DISB_HEADER_ID);
    fetch c_funded_lines_count_cur into l_funded_lines_count;
    close c_funded_lines_count_cur;

    -- updating disb line
    UPDATE_DISB_LINE(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_DISB_LINE_REC         => l_DISB_LINE_REC,
        X_RETURN_STATUS		    => l_return_status,
        X_MSG_COUNT			    => l_msg_count,
        X_MSG_DATA	    	    => l_msg_data);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_LINE failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- getting diff between total lines count and fully funded lines
    open funded_count_cur(l_DISB_HEADER_REC.DISB_HEADER_ID);
    fetch funded_count_cur into l_funded_count;
    close funded_count_cur;

    if l_funded_count = 0 then
        l_DISB_HEADER_REC.STATUS := 'FULLY_FUNDED';
    else
        l_DISB_HEADER_REC.STATUS := 'PARTIALLY_FUNDED';
    end if;

    -- updating disb header
    UPDATE_DISB_HEADER(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
        X_RETURN_STATUS		    => l_return_status,
        X_MSG_COUNT			    => l_msg_count,
        X_MSG_DATA	    	    => l_msg_data);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- getting last history record to update status
    open last_hist_rec_cur(l_DISB_LINE_REC.DISB_LINE_ID);
    fetch last_hist_rec_cur into l_hist_id, l_hist_version;
    close last_hist_rec_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating history record...');
    -- calling history table handler api
    LNS_DISB_HISTORIES_H_PKG.Update_Row(
        P_DISB_HISTORY_ID       => l_hist_id,
        P_STATUS                => l_DISB_LINE_REC.STATUS,
        P_OBJECT_VERSION_NUMBER => l_hist_version);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated history record with ID: ' || l_hist_id);

    if P_COMPLETE_FLAG = 'Y' then       -- testing

        -- getting sum of all disbursed amount for this loan
        open disb_amount_cur1(l_loan_header_rec.loan_id);
        fetch disb_amount_cur1 into l_loan_header_rec.funded_amount;
        close disb_amount_cur1;

    else        -- real

        -- getting sum of all disbursed amount for this loan
        open disb_amount_cur(l_loan_header_rec.loan_id);
        fetch disb_amount_cur into l_loan_header_rec.funded_amount;
        close disb_amount_cur;

    end if;

    if l_DISB_HEADER_REC.STATUS = 'FULLY_FUNDED' then
/*
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling to lns_fee_engine.processDisbursementFees...');
        -- processing disbursement fees
        lns_fee_engine.processDisbursementFees(
            p_init_msg_list     => FND_API.G_TRUE,
            p_commit            => FND_API.G_FALSE,
            p_phase             => l_DISB_HEADER_REC.phase, --'OPEN',
            p_loan_id           => l_loan_header_rec.loan_id,
            p_disb_head_id      => l_DISB_HEADER_REC.DISB_HEADER_ID,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'return of lns_fee_engine.processDisbursementFees: ' || l_return_status);
        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to lns_fee_engine.processDisbursementFees failed');
--            RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling to LNS_DISTRIBUTIONS_PUB.create_event...');
        -- creating accounting event
        l_event_table(1).loan_id         := l_loan_header_rec.loan_id;
        l_event_table(1).EVENT_TYPE_CODE := 'DISBURSEMENT_FUNDED';
        l_event_table(1).EVENT_DATE      := l_DISB_LINE_REC.DISBURSEMENT_DATE;
        l_event_table(1).EVENT_STATUS    := 'U';
        l_event_table(1).DISB_HEADER_ID  := l_DISB_HEADER_REC.DISB_HEADER_ID;

        LNS_DISTRIBUTIONS_PUB.create_event(
            p_acc_event_tbl      => l_event_table,
            p_init_msg_list      => FND_API.G_TRUE,
            p_commit             => FND_API.G_FALSE,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'return of LNS_DISTRIBUTIONS_PUB.create_event: ' || l_return_status);
        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to LNS_DISTRIBUTIONS_PUB.create_event  failed');
--            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'current_phase: ' || l_loan_header_rec.current_phase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_STATUS: ' || l_loan_header_rec.LOAN_STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'SECONDARY_STATUS: ' || l_loan_header_rec.SECONDARY_STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'funded_amount: ' || l_loan_header_rec.funded_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'requested_amount: ' || l_requested_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISBURSEMENT_DATE: ' || l_DISB_LINE_REC.DISBURSEMENT_DATE);

    -- Retrieve agreement reason
    l_agreement_reason := null;
    FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_AGREEMENT_REASON1');
    FND_MESSAGE.SET_TOKEN('DISB', l_disb_desc);
    FND_MESSAGE.SET_TOKEN('DATE', l_DISB_LINE_REC.DISBURSEMENT_DATE);
    FND_MESSAGE.SET_TOKEN('AMOUNT', to_char(l_inv_paid_amount, FND_CURRENCY.SAFE_GET_FORMAT_MASK(l_currency,50)));
    FND_MESSAGE.SET_TOKEN('CURR', l_currency);
    FND_MSG_PUB.Add;
    l_agreement_reason := FND_MSG_PUB.Get(p_encoded => 'F');
    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

    if l_loan_header_rec.current_phase = 'OPEN' then

        if l_loan_header_rec.LOAN_STATUS = 'APPROVED' then

            l_do_origination_bill  := 'Y';

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Its first payment for OPEN phase of the loan - getting new open loan dates...');

            LNS_FINANCIALS.shiftLoanDates(p_loan_id => l_loan_header_rec.loan_id
                                        ,p_new_start_date => l_DISB_LINE_REC.DISBURSEMENT_DATE
                                        ,p_phase => 'OPEN'
                                        ,x_loan_details => l_loan_details
                                        ,x_dates_shifted_flag => l_dates_shifted_flag
                                        ,x_return_status => l_return_status
                                        ,x_msg_count => l_msg_count
                                        ,x_msg_data => l_msg_data);

            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New open start date: ' || l_loan_details.loan_start_date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New open first payment date: ' || l_loan_details.first_payment_Date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New open maturity date: ' || l_loan_details.maturity_date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_dates_shifted_flag: ' || l_dates_shifted_flag);

            -- query term version
            open term_version_cur(l_loan_header_rec.loan_id);
            fetch term_version_cur into l_TERM_ID, l_TERM_VERSION_NUMBER;
            close term_version_cur;

            -- setting term data for term update
            l_term_rec.TERM_ID := l_TERM_ID;
            l_term_rec.LOAN_ID := l_loan_header_rec.loan_id;
            l_term_rec.OPEN_FIRST_PAYMENT_DATE := l_loan_details.first_payment_Date;
            l_term_rec.OPEN_NEXT_PAYMENT_DATE := l_loan_details.first_payment_Date;

            -- setting loanHeader data for Header Update
            l_loan_header_rec.OPEN_LOAN_START_DATE := l_loan_details.loan_start_date;
            l_loan_header_rec.OPEN_MATURITY_DATE := l_loan_details.maturity_date;

            if NOT (l_loan_header_rec.funded_amount = l_requested_amount and
                   (l_loan_header_rec.OPEN_TO_TERM_FLAG = 'Y' and
                    l_loan_header_rec.OPEN_TO_TERM_EVENT = 'AUTO_FINAL_DISBURSEMENT'))
            then

                -- Bug#6313658 Shifting LoanDates for Term also
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Shifting also TERM phase dates...');

                LNS_FINANCIALS.shiftLoanDates(p_loan_id => l_loan_header_rec.loan_id
                                            ,p_new_start_date => l_loan_header_rec.OPEN_MATURITY_DATE
                                            ,p_phase => 'TERM'
                                            ,x_loan_details => l_loan_details
                                            ,x_dates_shifted_flag => l_dates_shifted_flag
                                            ,x_return_status => l_return_status
                                            ,x_msg_count => l_msg_count
                                            ,x_msg_data => l_msg_data);

                IF l_return_status <> 'S' THEN
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_term_rec.FIRST_PAYMENT_DATE := l_loan_details.first_payment_Date;
                l_term_rec.PRIN_FIRST_PAY_DATE := l_loan_details.PRIN_FIRST_PAY_DATE;   -- fix for bug 6938095
                l_term_rec.NEXT_PAYMENT_DUE_DATE := l_loan_details.first_payment_Date;

                -- setting loan data for loan update
                l_loan_header_rec.LOAN_START_DATE := l_loan_details.loan_start_date;
                l_loan_header_rec.LOAN_MATURITY_DATE := l_loan_details.maturity_date;

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New LOAN_START_DATE: ' || l_loan_details.loan_start_date);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New LOAN_MATURITY_DATE: ' || l_loan_details.maturity_date);

                if l_dates_shifted_flag = 'Y' then
                    -- Retrieve agreement reason
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_AGREEMENT_REASON2');
                    FND_MSG_PUB.Add;
                    l_agreement_reason := l_agreement_reason || FND_MSG_PUB.Get(p_encoded => 'F');
                    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);
                end if;

            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_terms w following values:');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'TERM_ID: ' || l_term_rec.TERM_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_term_rec.LOAN_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_FIRST_PAYMENT_DATE: ' || l_term_rec.OPEN_FIRST_PAYMENT_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_NEXT_PAYMENT_DATE: ' || l_term_rec.OPEN_NEXT_PAYMENT_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || l_term_rec.FIRST_PAYMENT_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_FIRST_PAY_DATE: ' || l_term_rec.PRIN_FIRST_PAY_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);

            LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_TERM_VERSION_NUMBER,
                                    p_init_msg_list => FND_API.G_FALSE,
                                    p_loan_term_rec => l_term_rec,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_TERMS');
            ELSE
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_TERMS_PUB.update_term returned error: ' || substr(l_msg_data,1,225));
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        end if;

        if l_loan_header_rec.LOAN_STATUS <> 'PENDING_CANCELLATION' and
           l_loan_header_rec.LOAN_STATUS <> 'ACTIVE' and
           l_loan_header_rec.LOAN_STATUS <> 'DEFAULT' and
           l_loan_header_rec.LOAN_STATUS <> 'DELINQUENT'
        then
            l_loan_header_rec.LOAN_STATUS := 'ACTIVE';
        end if;

        if l_loan_header_rec.funded_amount = l_requested_amount then

            if l_loan_header_rec.SECONDARY_STATUS <> 'FULLY_FUNDED' then
                l_loan_header_rec.SECONDARY_STATUS := 'FULLY_FUNDED';
            end if;

            if (l_loan_header_rec.OPEN_TO_TERM_FLAG = 'Y' and
                l_loan_header_rec.OPEN_TO_TERM_EVENT = 'AUTO_FINAL_DISBURSEMENT')
            then

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_TO_TERM_FLAG: ' || l_loan_header_rec.OPEN_TO_TERM_FLAG);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_TO_TERM_EVENT: ' || l_loan_header_rec.OPEN_TO_TERM_EVENT);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Getting new loan dates for TERM phase...');

                LNS_FINANCIALS.shiftLoanDates(p_loan_id => l_loan_header_rec.loan_id
                                            ,p_new_start_date=> l_DISB_LINE_REC.DISBURSEMENT_DATE
                                            ,p_phase => 'TERM'
                                            ,x_loan_details => l_loan_details
                                            ,x_dates_shifted_flag => l_dates_shifted_flag
                                            ,x_return_status => l_return_status
                                            ,x_msg_count => l_msg_count
                                            ,x_msg_data => l_msg_data);

                IF l_return_status <> 'S' THEN
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to LNS_FINANCIALS.shiftLoanDates failed');
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New loan_start_date: ' || l_loan_details.loan_start_date);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New first_payment_Date: ' || l_loan_details.first_payment_Date);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New PRIN_FIRST_PAY_DATE: ' || l_loan_details.PRIN_FIRST_PAY_DATE);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New maturity_date: ' || l_loan_details.maturity_date);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_dates_shifted_flag: ' || l_dates_shifted_flag);

                -- Retrieve agreement reason
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_AGREEMENT_REASON3');
                FND_MSG_PUB.Add;
                l_agreement_reason := l_agreement_reason || FND_MSG_PUB.Get(p_encoded => 'F');
                FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

                if l_dates_shifted_flag = 'Y' then
                    -- Retrieve agreement reason
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_AGREEMENT_REASON2');
                    FND_MSG_PUB.Add;
                    l_agreement_reason := l_agreement_reason || FND_MSG_PUB.Get(p_encoded => 'F');
                    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);
                end if;

                -- query term version
                open term_version_cur(l_loan_header_rec.loan_id);
                fetch term_version_cur into l_TERM_ID, l_TERM_VERSION_NUMBER;
                close term_version_cur;

                -- setting term data for do term update
                l_term_rec.TERM_ID := l_TERM_ID;
                l_term_rec.LOAN_ID := l_loan_header_rec.loan_id;
                l_term_rec.FIRST_PAYMENT_DATE := l_loan_details.first_payment_Date;
                l_term_rec.PRIN_FIRST_PAY_DATE := l_loan_details.PRIN_FIRST_PAY_DATE;   -- fix for bug 6938095
                l_term_rec.NEXT_PAYMENT_DUE_DATE := l_loan_details.first_payment_Date;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_terms w following values:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'TERM_ID: ' || l_term_rec.TERM_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_term_rec.LOAN_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || l_term_rec.FIRST_PAYMENT_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_FIRST_PAY_DATE: ' || l_term_rec.PRIN_FIRST_PAY_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);

                LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_TERM_VERSION_NUMBER,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_loan_term_rec => l_term_rec,
                                        X_RETURN_STATUS => l_return_status,
                                        X_MSG_COUNT => l_msg_count,
                                        X_MSG_DATA => l_msg_data);

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

                IF l_return_status = 'S' THEN
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_TERMS');
                ELSE
            --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_TERMS_PUB.update_term returned error: ' || substr(l_msg_data,1,225));
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- setting data for future loan update

                l_loan_header_rec.LOAN_START_DATE := l_loan_details.loan_start_date;
                l_loan_header_rec.LOAN_MATURITY_DATE := l_loan_details.maturity_date;
                l_loan_header_rec.current_phase := 'TERM';
                l_loan_header_rec.LAST_PAYMENT_NUMBER := FND_API.G_MISS_NUM;
                l_loan_header_rec.LAST_AMORTIZATION_ID := FND_API.G_MISS_NUM;
                l_loan_header_rec.secondary_status := 'CONVERTED_TO_TERM_PHASE';
				l_do_conversion_bill := 'Y';

            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_header_rec.loan_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_START_DATE: ' || l_loan_header_rec.LOAN_START_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_MATURITY_DATE: ' || l_loan_header_rec.LOAN_MATURITY_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'current_phase: ' || l_loan_header_rec.current_phase);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_PAYMENT_NUMBER: ' || l_loan_header_rec.LAST_PAYMENT_NUMBER);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_AMORTIZATION_ID: ' || l_loan_header_rec.LAST_AMORTIZATION_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'funded_amount: ' || l_loan_header_rec.funded_amount);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary_status: ' || l_loan_header_rec.secondary_status);

            LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                            P_LOAN_HEADER_REC => l_loan_header_rec,
                                            P_INIT_MSG_LIST => FND_API.G_FALSE,
                                            X_RETURN_STATUS => l_return_status,
                                            X_MSG_COUNT => l_msg_count,
                                            X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
            ELSE
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

/*	       No need to call this now, as the below method inserts records of conversionFees into feeSchds table
	       However, now the conversionFees insert into feeScheds when this fee is assigned to the loan
            lns_fee_engine.processDisbursementFees(
                p_init_msg_list     => FND_API.G_TRUE,
                p_commit            => FND_API.G_FALSE,
                p_phase             => 'TERM',
                p_loan_id           => l_loan_header_rec.loan_id,
                p_disb_head_id      => null,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);
*/

        else   -- l_loan_header_rec.funded_amount <> l_requested_amount

            if l_loan_header_rec.SECONDARY_STATUS <> 'PARTIALLY_FUNDED' then
                l_loan_header_rec.SECONDARY_STATUS := 'PARTIALLY_FUNDED';
            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'funded_amount: ' || l_loan_header_rec.funded_amount);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary_status: ' || l_loan_header_rec.secondary_status);

            LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                            P_LOAN_HEADER_REC => l_loan_header_rec,
                                            P_INIT_MSG_LIST => FND_API.G_FALSE,
                                            X_RETURN_STATUS => l_return_status,
                                            X_MSG_COUNT => l_msg_count,
                                            X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
            ELSE
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        end if;

    else   -- TERM phase

        if l_loan_header_rec.LOAN_STATUS = 'APPROVED' then

            l_do_origination_bill  := 'Y';
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Its first payment for the TERM phase of the loan - getting new loan dates...');

            LNS_FINANCIALS.shiftLoanDates(p_loan_id => l_loan_header_rec.loan_id
                                        ,p_new_start_date => l_DISB_LINE_REC.DISBURSEMENT_DATE
                                        ,p_phase => 'TERM'
                                        ,x_loan_details => l_loan_details
                                        ,x_dates_shifted_flag => l_dates_shifted_flag
                                        ,x_return_status => l_return_status
                                        ,x_msg_count => l_msg_count
                                        ,x_msg_data => l_msg_data);

            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New start date: ' || l_loan_details.loan_start_date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New first payment date: ' || l_loan_details.first_payment_Date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New principal first payment date: ' || l_loan_details.PRIN_FIRST_PAY_DATE);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New maturity date: ' || l_loan_details.maturity_date);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_dates_shifted_flag: ' || l_dates_shifted_flag);

            -- query term version
            open term_version_cur(l_loan_header_rec.loan_id);
            fetch term_version_cur into l_TERM_ID, l_TERM_VERSION_NUMBER;
            close term_version_cur;

            -- setting term data for term update
            l_term_rec.TERM_ID := l_TERM_ID;
            l_term_rec.LOAN_ID := l_loan_header_rec.loan_id;
            l_term_rec.FIRST_PAYMENT_DATE := l_loan_details.first_payment_Date;
            l_term_rec.PRIN_FIRST_PAY_DATE := l_loan_details.PRIN_FIRST_PAY_DATE;   -- fix for bug 6938095
            l_term_rec.NEXT_PAYMENT_DUE_DATE := l_loan_details.first_payment_Date;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_terms w following values:');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'TERM_ID: ' || l_term_rec.TERM_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_term_rec.LOAN_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || l_term_rec.FIRST_PAYMENT_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_FIRST_PAY_DATE: ' || l_term_rec.PRIN_FIRST_PAY_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);

            if l_dates_shifted_flag = 'Y' then
                -- Retrieve agreement reason
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_AGREEMENT_REASON2');
                FND_MSG_PUB.Add;
                l_agreement_reason := l_agreement_reason || FND_MSG_PUB.Get(p_encoded => 'F');
                FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);
            end if;

            LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_TERM_VERSION_NUMBER,
                                    p_init_msg_list => FND_API.G_FALSE,
                                    p_loan_term_rec => l_term_rec,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_TERMS');
            ELSE
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_TERMS_PUB.update_term returned error: ' || substr(l_msg_data,1,225));
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- setting loan data for loan update
            l_loan_header_rec.LOAN_START_DATE := l_loan_details.loan_start_date;
            l_loan_header_rec.LOAN_MATURITY_DATE := l_loan_details.maturity_date;

        end if;

        if l_loan_header_rec.LOAN_STATUS <> 'PENDING_CANCELLATION' and
           l_loan_header_rec.LOAN_STATUS <> 'ACTIVE' and
           l_loan_header_rec.LOAN_STATUS <> 'DEFAULT' and
           l_loan_header_rec.LOAN_STATUS <> 'DELINQUENT'
        then
            l_loan_header_rec.LOAN_STATUS := 'ACTIVE';
        end if;

        if l_loan_header_rec.funded_amount = l_requested_amount then
            if l_loan_header_rec.SECONDARY_STATUS <> 'FULLY_FUNDED' then
                l_loan_header_rec.SECONDARY_STATUS := 'FULLY_FUNDED';
            end if;
        else
            if l_loan_header_rec.SECONDARY_STATUS <> 'PARTIALLY_FUNDED' then
                l_loan_header_rec.SECONDARY_STATUS := 'PARTIALLY_FUNDED';
            end if;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_header_rec.loan_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'funded_amount: ' || l_loan_header_rec.funded_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary status: ' || l_loan_header_rec.SECONDARY_STATUS);

        LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                        P_LOAN_HEADER_REC => l_loan_header_rec,
                                        P_INIT_MSG_LIST => FND_API.G_FALSE,
                                        X_RETURN_STATUS => l_return_status,
                                        X_MSG_COUNT => l_msg_count,
                                        X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
        ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    IF (l_dates_shifted_flag = 'Y') THEN

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Correct the feeAssignment Installments for all fudningFees of this loan');

        OPEN c_disb_hdr_id(l_DISB_HEADER_REC.DISB_HEADER_ID);
        FETCH c_disb_hdr_id BULK COLLECT INTO l_disb_hdr_id_tbl;
        CLOSE c_disb_hdr_id;

        FOR hdrIdCnt in 1..l_disb_hdr_id_tbl.count
        LOOP
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loop Updating the feeInstallment for disbHdrId: '||l_disb_hdr_id_tbl(hdrIdCnt));
            LNS_FEE_ENGINE.SET_DISB_FEES_INSTALL(P_INIT_MSG_LIST => FND_API.G_FALSE
                                            ,P_DISB_HEADER_ID    => l_disb_hdr_id_tbl(hdrIdCnt)
                                            ,X_RETURN_STATUS     => l_return_status
                                            ,X_MSG_COUNT	     => l_msg_count
                                            ,X_MSG_DATA	    	 => l_msg_data);
            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to LNS_FEE_ENGINE.SET_DISB_FEES_INSTALL failed');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END LOOP;

    ELSIF (isDisbDateChange = 'Y') THEN

	    -- Update the feeInstallment of the fundingFees of this disbursement
	    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating the feeInstallment for disbHdrId: '||l_DISB_HEADER_REC.DISB_HEADER_ID);
		LNS_FEE_ENGINE.SET_DISB_FEES_INSTALL(P_INIT_MSG_LIST => FND_API.G_FALSE
                                        ,P_DISB_HEADER_ID    => l_DISB_HEADER_REC.DISB_HEADER_ID
                                        ,X_RETURN_STATUS     => l_return_status
                                        ,X_MSG_COUNT	     => l_msg_count
                                        ,X_MSG_DATA	    	 => l_msg_data);
		IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to LNS_FEE_ENGINE.SET_DISB_FEES_INSTALL failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;   --  IF (l_dates_shifted_flag = 'Y')

    if l_DISB_HEADER_REC.STATUS = 'FULLY_FUNDED' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling to lns_fee_engine.processDisbursementFees...');
        -- processing disbursement fees
        lns_fee_engine.processDisbursementFees(
            p_init_msg_list     => FND_API.G_TRUE,
            p_commit            => FND_API.G_FALSE,
            p_phase             => null,  -- processDisb...Fees modified to handle all phases withhout based on this param
            p_loan_id           => l_loan_header_rec.loan_id,
            p_disb_head_id      => l_DISB_HEADER_REC.DISB_HEADER_ID,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'return of lns_fee_engine.processDisbursementFees: ' || l_return_status);
        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to lns_fee_engine.processDisbursementFees failed');
--            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_do_origination_bill  : ' || l_do_origination_bill );
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_do_conversion_bill : ' || l_do_conversion_bill);

    LNS_REP_UTILS.STORE_LOAN_AGREEMENT_CP(l_loan_header_rec.loan_id, l_agreement_reason);

    -- Bug#9255294 - Do the 0th installment billing
    IF ((l_do_origination_bill = 'Y' ) OR (l_do_conversion_bill = 'Y')) THEN

		-- check to start billing for 0-th installment
        open do_billing_cur(l_loan_header_rec.loan_id, l_loan_header_rec.current_phase);
        fetch do_billing_cur into l_do_billing;
        close do_billing_cur;

        -- billing 0-th installment
        if l_do_billing > 0 then

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Submitting Billing Concurrent Program to bill 0-th installment...');
            FND_REQUEST.SET_ORG_ID(MO_GLOBAL.GET_CURRENT_ORG_ID());

		    -- Bug#6313716 : Invoke the function add_layout to specify the template type,code etc., before submitting request
		    SELECT
		      lower(iso_language),iso_territory
		    INTO
		      l_iso_language,l_iso_territory
		    FROM
		      FND_LANGUAGES
		    WHERE
		      language_code = USERENV('LANG');

		    l_xml_output:=  fnd_request.add_layout(
				      template_appl_name  => 'LNS',
				      template_code       => 'LNSRPTBL',  --fix for bug 8830573
				      template_language   => l_iso_language,
				      template_territory  => l_iso_territory,
				      output_format       => 'PDF'
				    );

		    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                            'LNS',
                            'LNS_BILLING',
                            '', '', FALSE,
                            null,
                            l_loan_header_rec.loan_id,
                            null,
                            null);

            if l_request_id = 0 then

        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to start Billing Concurrent Program.');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_BILLING_REQUEST_FAILED');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            else
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully submited Billing Concurrent Program to bill 0-th installment. Request id: ' || l_request_id);
            end if;

        end if;  -- if l_do_billing > 0

    END IF;   -- IF ((l_do_origination_bill = 'Y' ) OR (l_do_conversion_bill = 'Y'))

--    COMMIT WORK;
--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');

    -- END OF BODY OF API
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully processed payment');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PAY_SINGLE_INVOICE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PAY_SINGLE_INVOICE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO PAY_SINGLE_INVOICE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE SubscribeTo_Payment_Event
 |
 | DESCRIPTION
 |      This procedure called by AP to confirm payment on invoice
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_Event_Type		    IN          Event type
 |      P_Check_ID  		    IN          Check ID
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
 | 07-25-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SubscribeTo_Payment_Event
    (P_Event_Type               IN             VARCHAR2,
    P_Check_ID                 IN             NUMBER,
    P_Return_Status            OUT     NOCOPY VARCHAR2,
    P_Msg_Count                OUT     NOCOPY NUMBER,
    P_Msg_Data                 OUT     NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SubscribeTo_Payment_Event';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_invoice_id                    number;
    l_count                         number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting invoice by check id
    CURSOR get_invoice_cur(P_CHECK_ID number) IS
        select distinct(invoice_id)
        from AP_INVOICE_PAYMENTS_ALL
        where check_id = P_CHECK_ID;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT SubscribeTo_Payment_Event;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing payment event...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_Event_Type: ' || P_Event_Type);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_Check_ID: ' || P_Check_ID);

    -- getting invoice by check id
    l_count := 0;
    open get_invoice_cur(P_Check_ID);
    LOOP

        fetch get_invoice_cur into l_invoice_id;
        exit when get_invoice_cur%NOTFOUND;

        l_count := l_count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing payment for invoice #' || l_count);
        PAY_SINGLE_INVOICE
            (P_INVOICE_ID              => l_invoice_id,
            P_COMPLETE_FLAG            => 'N',
            X_Return_Status            => l_return_status,
            X_Msg_Count                => l_msg_count,
            X_Msg_Data                 => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to PAY_SINGLE_INVOICE failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;
    close get_invoice_cur;

--    COMMIT WORK;
--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');

    -- END OF BODY OF API
    P_Return_Status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully processed payment event');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => p_msg_count,
                p_data => p_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO SubscribeTo_Payment_Event;
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count, p_data => p_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SubscribeTo_Payment_Event;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count, p_data => p_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO SubscribeTo_Payment_Event;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count, p_data => p_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE COMPLETE_ALL_DISB
 |
 | DESCRIPTION
 |      This procedure is for testing purpose only.
 |      It completes all available disbursements for a loan and sets all to status fully paid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
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
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE COMPLETE_ALL_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'COMPLETE_ALL_DISB';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_invoice_id                    number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting all available disbursements
    CURSOR avail_disb_cur(P_LOAN_ID number) IS
        select line.INVOICE_ID
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head
        where head.LOAN_ID = P_LOAN_ID and
            head.DISB_HEADER_ID = line.DISB_HEADER_ID and
            line.status is not null and
            line.status = 'IN_FUNDING' and
            line.invoice_id is not null;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT COMPLETE_ALL_DISB;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Completing all disbursements...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);

    -- getting all available disbursements
    open avail_disb_cur(P_LOAN_ID);
    LOOP

        fetch avail_disb_cur into l_invoice_id;
        exit when avail_disb_cur%NOTFOUND;

        PAY_SINGLE_INVOICE
            (P_INVOICE_ID              => l_invoice_id,
            P_COMPLETE_FLAG            => 'Y',
            X_Return_Status            => l_return_status,
            X_Msg_Count                => l_msg_count,
            X_Msg_Data                 => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to PAY_SINGLE_INVOICE failed');
--            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;
    close avail_disb_cur;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully completed all disbursements for loan ' || P_LOAN_ID);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO COMPLETE_ALL_DISB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO COMPLETE_ALL_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO COMPLETE_ALL_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE CANCEL_SINGLE_DISB
 |
 | DESCRIPTION
 |      This procedure cancels single disbursement header with lines
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_INVOICE_ID  		    IN          Check ID
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
 | 07-25-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CANCEL_SINGLE_DISB(
    P_API_VERSION               IN      NUMBER,
    P_INIT_MSG_LIST             IN      VARCHAR2,
    P_COMMIT                    IN      VARCHAR2,
    P_VALIDATION_LEVEL          IN      NUMBER,
    P_DISB_HEADER_ID            IN      NUMBER,
    X_Return_Status             OUT     NOCOPY VARCHAR2,
    X_Msg_Count                 OUT     NOCOPY NUMBER,
    X_Msg_Data                  OUT     NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CANCEL_SINGLE_DISB';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_hist_id                       number;
    l_hist_version                  number;
    l_count                         number;
    l_message_name                  varchar2(30);
    l_invoice_amount                number;
    l_base_amount                   number;
    l_temp_cancelled_amount         number;
    l_cancelled_by                  number;
    l_cancelled_amount              number;
    l_cancelled_date                date;
    l_last_update_date              date;
    l_original_prepayment_amount    number;
    l_pay_curr_invoice_amount       number;
    l_Token                         varchar2(30);
    l_success                       boolean;
    l_success_str                   varchar2(10);

    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;
    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info
    CURSOR disb_hdr_cur(P_DISB_HEADER_ID number) IS
        select head.DISB_HEADER_ID,
            head.OBJECT_VERSION_NUMBER,
            (select count(1)
             from lns_disb_lines
             where DISB_HEADER_ID = head.DISB_HEADER_ID and
             status <> 'CANCELLED'),
             head.LOAN_ID
        from LNS_DISB_HEADERS head
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID;

    -- getting disbursement lines info
    CURSOR disb_lines_cur(P_DISB_HEADER_ID number) IS
        select line.DISB_LINE_ID,
            line.OBJECT_VERSION_NUMBER,
            line.STATUS,
            line.INVOICE_ID
        from LNS_DISB_LINES line
        where line.DISB_HEADER_ID = P_DISB_HEADER_ID;

    -- getting last history record to update status
    CURSOR last_hist_rec_cur(P_DISB_LINE_ID number) IS
        select max(DISB_HISTORY_ID), max(OBJECT_VERSION_NUMBER+1)
        from lns_disb_histories_h
        where DISB_LINE_ID = P_DISB_LINE_ID;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT CANCEL_SINGLE_DISB;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Canceling disbursement header ' || P_DISB_HEADER_ID || ' with lines...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input Data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_HEADER_ID: ' || P_DISB_HEADER_ID);

    -- getting disbursement lines info
    open disb_lines_cur(P_DISB_HEADER_ID);
    LOOP

        fetch disb_lines_cur into l_DISB_LINE_REC.DISB_LINE_ID,
                                  l_DISB_LINE_REC.OBJECT_VERSION_NUMBER,
                                  l_DISB_LINE_REC.STATUS,
                                  l_DISB_LINE_REC.INVOICE_ID;
        exit when disb_lines_cur%NOTFOUND;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_LINE_ID: ' || l_DISB_LINE_REC.DISB_LINE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'OBJECT_VERSION_NUMBER: ' || l_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'STATUS: ' || l_DISB_LINE_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_ID: ' || l_DISB_LINE_REC.INVOICE_ID);

        if l_DISB_LINE_REC.STATUS is null or
           l_DISB_LINE_REC.STATUS = 'FUNDING_ERROR' or
           l_DISB_LINE_REC.STATUS = 'IN_FUNDING' then

            -- if its in funding - call ap cancel invoice api
            if l_DISB_LINE_REC.STATUS = 'IN_FUNDING' then

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE...');

                l_success := AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE(
                    P_INVOICE_ID                   => l_DISB_LINE_REC.INVOICE_ID,
                    P_LAST_UPDATED_BY              => LNS_UTILITY_PUB.LAST_UPDATED_BY,
                    P_LAST_UPDATE_LOGIN            => LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
                    P_ACCOUNTING_DATE              => sysdate,
                    P_MESSAGE_NAME                 => l_message_name,
                    P_INVOICE_AMOUNT               => l_invoice_amount,
                    P_BASE_AMOUNT                  => l_base_amount,
                    P_TEMP_CANCELLED_AMOUNT        => l_temp_cancelled_amount,
                    P_CANCELLED_BY                 => l_cancelled_by,
                    P_CANCELLED_AMOUNT             => l_cancelled_amount,
                    P_CANCELLED_DATE               => l_cancelled_date,
                    P_LAST_UPDATE_DATE             => l_last_update_date,
                    P_ORIGINAL_PREPAYMENT_AMOUNT   => l_original_prepayment_amount,
                    P_PAY_CURR_INVOICE_AMOUNT      => l_pay_curr_invoice_amount,
                    P_TOKEN                        => l_Token,
                    P_CALLING_SEQUENCE             => G_PKG_NAME);

                if l_success = TRUE then
                    l_success_str := 'TRUE';
                elsif l_success = FALSE then
                    l_success_str := 'FALSE';
                else
                    l_success_str := null;
                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Return from AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_success: ' || l_success_str);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_message_name: ' || l_message_name);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_Token: ' || l_Token);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_invoice_amount: ' || l_invoice_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_base_amount: ' || l_base_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_temp_cancelled_amount: ' || l_temp_cancelled_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cancelled_by: ' || l_cancelled_by);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cancelled_amount: ' || l_cancelled_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cancelled_date: ' || l_cancelled_date);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_last_update_date: ' || l_last_update_date);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_original_prepayment_amount: ' || l_original_prepayment_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_pay_curr_invoice_amount: ' || l_pay_curr_invoice_amount);

                IF NOT l_success THEN
                    FND_MESSAGE.SET_NAME('SQLAP4', l_message_name);
                    FND_MESSAGE.SET_TOKEN('ERROR', l_Token);
                    FND_MSG_PUB.ADD;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully cancelled AP invoice');
                END IF;

            end if;

            -- getting last history record to update status
            open last_hist_rec_cur(l_DISB_LINE_REC.DISB_LINE_ID);
            fetch last_hist_rec_cur into l_hist_id, l_hist_version;
            close last_hist_rec_cur;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'hist_id: ' || l_hist_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'hist_version: ' || l_hist_version);

            if l_hist_id is not null and l_hist_version is not null then

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating history record...');
                -- calling history table handler api
                LNS_DISB_HISTORIES_H_PKG.Update_Row(
                    P_DISB_HISTORY_ID       => l_hist_id,
                    P_STATUS                => 'CANCELLED',
                    P_OBJECT_VERSION_NUMBER => l_hist_version);

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated history record with ID: ' || l_hist_id);

            end if;

            l_DISB_LINE_REC.STATUS := 'CANCELLED';

            -- updating disb line
            UPDATE_DISB_LINE(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                P_COMMIT			    => FND_API.G_FALSE,
                P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
                P_DISB_LINE_REC         => l_DISB_LINE_REC,
                X_RETURN_STATUS		    => l_return_status,
                X_MSG_COUNT			    => l_msg_count,
                X_MSG_DATA	    	    => l_msg_data);

            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_LINE failed');
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        else

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Cannot cancel this disbursement line because its already processed.');

        end if;

    END LOOP;
    close disb_lines_cur;

    -- getting disbursement header info
    open disb_hdr_cur(P_DISB_HEADER_ID);
    fetch disb_hdr_cur into l_DISB_HEADER_REC.DISB_HEADER_ID, l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER, l_count, l_DISB_HEADER_REC.LOAN_ID;
    close disb_hdr_cur;

    -- if all lines are cancelled then cancel header as well
    if l_count = 0 then

        l_DISB_HEADER_REC.STATUS := 'CANCELLED';

        -- updating disb header
        UPDATE_DISB_HEADER(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    UPDATE_LOAN_FUNDING_STATUS(l_DISB_HEADER_REC.LOAN_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully cancelled disbursement header with lines');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CANCEL_SINGLE_DISB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CANCEL_SINGLE_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO CANCEL_SINGLE_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE APPROVE_CANCEL_REM_DISB
 |
 | DESCRIPTION
 |      This procedure to be called after approval of cancelation of disbursement schedule and
 |      cancels all remaining disbursements of a loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
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
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_CANCEL_REM_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPROVE_CANCEL_REM_DISB';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_disb_header_id                number;
    l_loan_version                  number;
    l_submitted_disb_count          number;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_event_table                   lns_distributions_pub.acc_event_tbl;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting all available disbursements
    CURSOR avail_disb_cur(P_LOAN_ID number) IS
        select head.DISB_HEADER_ID,
            loan.LOAN_STATUS,
            loan.OBJECT_VERSION_NUMBER
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS loan
        where head.LOAN_ID = P_LOAN_ID and
            head.LOAN_ID = loan.LOAN_ID and
            nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN');

    -- getting number of already submitted disbursements
    CURSOR submitted_disb_cur(P_LOAN_ID number) IS
        select count(head.DISB_HEADER_ID)
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS loan
        where head.LOAN_ID = P_LOAN_ID and
            head.status <> 'CANCELLED' and
            head.LOAN_ID = loan.LOAN_ID and
            nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN');

    -- getting loan info
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select loan.OBJECT_VERSION_NUMBER
        from LNS_LOAN_HEADERS loan
        where loan.LOAN_ID = P_LOAN_ID;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT APPROVE_CANCEL_REM_DISB;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Cancelling all remaining disbursements...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);

    -- getting all available disbursements
    open avail_disb_cur(P_LOAN_ID);
    LOOP

        fetch avail_disb_cur into l_disb_header_id,
                                  l_loan_header_rec.LOAN_STATUS,
                                  l_loan_version;
        exit when avail_disb_cur%NOTFOUND;

        CANCEL_SINGLE_DISB(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_ID        => l_disb_header_id,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'CANCEL_SINGLE_DISB failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;
    close avail_disb_cur;

    -- setting status and secondary status and update loan header
    open submitted_disb_cur(P_LOAN_ID);
    fetch submitted_disb_cur into l_submitted_disb_count;
    close submitted_disb_cur;

    if l_submitted_disb_count = 0 then
        l_loan_header_rec.LOAN_STATUS := 'CANCELLED';
        l_loan_header_rec.SECONDARY_STATUS := 'ALL_DISB_CANCELLED';
    else
        if l_loan_header_rec.LOAN_STATUS <> 'ACTIVE' and
           l_loan_header_rec.LOAN_STATUS <> 'DEFAULT' and
           l_loan_header_rec.LOAN_STATUS <> 'DELINQUENT'
        then
            l_loan_header_rec.LOAN_STATUS := 'ACTIVE';
        end if;
        l_loan_header_rec.SECONDARY_STATUS := 'REMAINING_DISB_CANCELLED';
    end if;

    l_loan_header_rec.loan_id := P_LOAN_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_header_rec.loan_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary status: ' || l_loan_header_rec.SECONDARY_STATUS);

    open loan_info_cur(P_LOAN_ID);
    fetch loan_info_cur into l_loan_version;
    close loan_info_cur;

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
    ELSE
        FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'calling lns_distributions_pub.cancel_disbursements');
    -- Cancel budgetary disbursements if needed
    lns_distributions_pub.cancel_disbursements(p_init_msg_list       => FND_API.G_FALSE
                                              ,p_commit              => FND_API.G_FALSE
                                              ,p_loan_id             => P_LOAN_ID
                                              ,X_RETURN_STATUS       => l_return_status
                                              ,X_MSG_COUNT           => l_msg_count
                                              ,X_MSG_DATA            => l_msg_data);

    logMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'BUDGETARY CANCEL_FAILED');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF P_COMMIT = FND_API.G_TRUE THEN
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    END IF;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully cancelled all remaining disbursements');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPROVE_CANCEL_REM_DISB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPROVE_CANCEL_REM_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO APPROVE_CANCEL_REM_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE REJECT_CANCEL_DISB
 |
 | DESCRIPTION
 |      This procedure to be called after rejection of cancelation of disbursement schedule and
 |      reactivate disbursement schedule of a loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
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
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REJECT_CANCEL_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'REJECT_CANCEL_DISB';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_version                  number;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting loan info
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select loan.OBJECT_VERSION_NUMBER
        from LNS_LOAN_HEADERS loan
        where loan.LOAN_ID = P_LOAN_ID;

    -- getting loan previous status
    CURSOR prev_status_cur(P_LOAN_ID number) IS
        select old_value
        from lns_loan_histories_h
        where table_name = 'LNS_LOAN_HEADERS_ALL' and
            column_name = 'LOAN_STATUS' and
            new_value = 'PENDING_CANCELLATION' and
            loan_id = P_LOAN_ID and
            loan_history_id =
                (select max(loan_history_id)
                from lns_loan_histories_h
                where table_name = 'LNS_LOAN_HEADERS_ALL' and
                column_name = 'LOAN_STATUS' and
                loan_id = P_LOAN_ID);

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT REJECT_CANCEL_DISB;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Reactivation disbursement schedule...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);

    -- getting loan previous status
    open prev_status_cur(P_LOAN_ID);
    fetch prev_status_cur into l_loan_header_rec.LOAN_STATUS;
    close prev_status_cur;

    -- getting loan info
    open loan_info_cur(P_LOAN_ID);
    fetch loan_info_cur into l_loan_version;
    close loan_info_cur;

    -- setting status and update loan header
    l_loan_header_rec.loan_id := P_LOAN_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_header_rec.loan_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
    ELSE
        FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully reactivation disbursement schedule');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO REJECT_CANCEL_DISB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO REJECT_CANCEL_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO REJECT_CANCEL_DISB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE CANCEL_DISB_SCHEDULE
 |
 | DESCRIPTION
 |      This procedure only sets loan status to PENDING_CANCELLATION
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
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
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CANCEL_DISB_SCHEDULE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CANCEL_DISB_SCHEDULE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_version                  number;
    l_approve_flag                  varchar2(1);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting loan info
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select loan.OBJECT_VERSION_NUMBER
        from LNS_LOAN_HEADERS loan
        where loan.LOAN_ID = P_LOAN_ID;

    -- querying required approval flag
    CURSOR appr_flag_cur(P_LOAN_ID number) IS
        select nvl(prod.APPR_REQ_FOR_CNCL_FLAG, 'N')
        from lns_loan_products_all prod,
            lns_loan_headers_all loan
        where loan.loan_id = P_LOAN_ID and
            loan.product_id = prod.loan_product_id;
BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT CANCEL_DISB_SCHEDULE;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Cancel disbursements...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);

    -- querying required approval flag
    open appr_flag_cur(P_LOAN_ID);
    fetch appr_flag_cur into l_approve_flag;
    close appr_flag_cur;

    if l_approve_flag = 'Y' then

        -- getting loan info
        open loan_info_cur(P_LOAN_ID);
        fetch loan_info_cur into l_loan_version;
        close loan_info_cur;

        -- setting status and update loan header
        l_loan_header_rec.loan_id := P_LOAN_ID;
        l_loan_header_rec.LOAN_STATUS := 'PENDING_CANCELLATION';

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_header_rec.loan_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'status: ' || l_loan_header_rec.LOAN_STATUS);

        LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                        P_LOAN_HEADER_REC => l_loan_header_rec,
                                        P_INIT_MSG_LIST => FND_API.G_FALSE,
                                        X_RETURN_STATUS => l_return_status,
                                        X_MSG_COUNT => l_msg_count,
                                        X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
        ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    else

        APPROVE_CANCEL_REM_DISB(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_FALSE,
            P_COMMIT => FND_API.G_FALSE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID => P_LOAN_ID,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully cancel disbursements');

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CANCEL_DISB_SCHEDULE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CANCEL_DISB_SCHEDULE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO CANCEL_DISB_SCHEDULE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE CREATE_PAYEE
 |
 | DESCRIPTION
 |      This procedure creates loan payee in AP
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
 |      P_PAYEE_REC             IN          Payee record
 |      X_PAYEE_ID  		    OUT NOCOPY  Return payee id
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_PAYEE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_PAYEE_REC             IN          LNS_FUNDING_PUB.LOAN_PAYEE_REC,
    X_PAYEE_ID  		    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_PAYEE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
	l_vendor_id			            number;
	l_status			            varchar2(10);
	l_exception_msg		            varchar2(255);
--    l_supplier_number               varchar2(30);
--    l_vendor_num_code               varchar2(25);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
/*
    CURSOR vendor_num_code_cur IS
        select USER_DEFINED_VENDOR_NUM_CODE
        from FINANCIALS_SYSTEM_PARAMETERS;

    CURSOR vendor_num_cur IS
        select max(to_number(segment1)) + 1 from PO_VENDORS;
*/
BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE CREATE_PAYEE_SITE
 |
 | DESCRIPTION
 |      This procedure creates loan payee site in AP
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_PAYEE_SITE_REC        IN          Payee site record
 |      X_PAYEE_SITE_ID		    OUT NOCOPY  Returns payee site id
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_PAYEE_SITE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_PAYEE_SITE_REC       IN          LNS_FUNDING_PUB.LOAN_PAYEE_SITE_REC,
    X_PAYEE_SITE_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_PAYEE_SITE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
	l_vendor_site_id	            number;
	l_status			            varchar2(10);
	l_exception_msg		            varchar2(255);
    l_org_id                        number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/


BEGIN
    null;
END;



/*========================================================================
 | PUBLIC PROCEDURE CREATE_SITE_CONTACT
 |
 | DESCRIPTION
 |      This procedure creates site contact in AP
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_SITE_CONTACT_REC      IN          Site contact record
 |      X_SITE_CONTACT_ID	    OUT NOCOPY  Returns site contact id
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
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_SITE_CONTACT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_SITE_CONTACT_REC      IN          LNS_FUNDING_PUB.SITE_CONTACT_REC,
    X_SITE_CONTACT_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_SITE_CONTACT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
	l_site_contact_id	            number;
	l_status			            varchar2(10);
	l_exception_msg		            varchar2(255);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/


BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE CREATE_BANK_ACC_USE
 |
 | DESCRIPTION
 |      This procedure creates bank account use.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_BANK_ACC_USE_REC      IN          Bank account use record
 |      X_BANK_ACC_USE_ID	    OUT NOCOPY  Returns bank account use id
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
 | 11-12-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_BANK_ACC_USE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_BANK_ACC_USE_REC      IN          LNS_FUNDING_PUB.BANK_ACCOUNT_USE_REC,
    X_BANK_ACC_USE_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_BANK_ACC_USE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_BANK_ACC_USE_REC              LNS_FUNDING_PUB.BANK_ACCOUNT_USE_REC;
    l_bank_acc_use_id               number;
    l_primary_flag                  varchar2(1);
    l_currency                      VARCHAR2(15);


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;



/*========================================================================
 | PRIVATE PROCEDURE CREATE_AP_INVOICE
 |
 | DESCRIPTION
 |      This procedure creates AP invoice and invoice lines
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_FUNDING_ADVICE_REC    IN OUT      Funding record
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
 | 09-29-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_AP_INVOICE(P_FUNDING_ADVICE_REC   IN OUT NOCOPY  LNS_FUNDING_PUB.FUNDING_ADVICE_REC)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_AP_INVOICE';
    l_org_id                        number;
    l_invoice_line_id               number;
    l_loan_number                   varchar2(60);
    l_source                        VARCHAR2(80);
    l_description                   VARCHAR2(240);
    l_cc_id                         number;
    l_percent                       number;
    l_USSGL_TRANSACTION_CODE        VARCHAR2(30);
    l_Count                         number;
    l_running_sum                   number;
    l_sum_percent                   number;
    l_line_amount                   number;
    l_EXCHANGE_RATE_TYPE            VARCHAR2(30);
    l_EXCHANGE_DATE                 DATE;
    l_EXCHANGE_RATE                 NUMBER;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;



/*========================================================================
 | PUBLIC PROCEDURE INIT_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure init funding advice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_INIT_FUNDING_REC      IN          Init funding advice record
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INIT_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_INIT_FUNDING_REC      IN          LNS_FUNDING_PUB.INIT_FUNDING_ADVICE_REC,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'INIT_FUNDING_ADVICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_funding_advice_id             NUMBER;
    l_loan_class                    VARCHAR2(30);
    l_FUNDING_ADVICE_REC            LNS_FUNDING_PUB.FUNDING_ADVICE_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE SET_AUTOFUNDING
 |
 | DESCRIPTION
 |      This procedure sets autofunding flag for a loan.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_AUTOFUNDING_FLAG      IN          Autofunding flag
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
 | 11-15-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SET_AUTOFUNDING(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_AUTOFUNDING_FLAG      IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SET_AUTOFUNDING';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_DISB_HEADER_ID                NUMBER;
    l_OBJECT_VERSION_NUMBER         NUMBER;
    l_cond_count                    number;

    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- getting disbursement header info
    CURSOR disb_headers_cur(P_LOAN_ID number) IS
        select
            head.DISB_HEADER_ID,
            head.OBJECT_VERSION_NUMBER
        from LNS_DISB_HEADERS head,
            LNS_LOAN_HEADERS_ALL loan
        where loan.LOAN_ID = P_LOAN_ID and
            head.LOAN_ID = loan.LOAN_ID and
            head.DISBURSEMENT_NUMBER = 1 and
            nvl(loan.current_phase, 'TERM') = nvl(head.phase, 'OPEN');

    -- checking for conditions
    CURSOR conditions_cur(P_DISB_HEADER_ID number) IS
        select count(1)
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.DISB_HEADER_ID = P_DISB_HEADER_ID and
            cond_ass.MANDATORY_FLAG = 'Y' and
            cond_ass.condition_id = cond.condition_id and
            cond.CUSTOM_PROCEDURE is null and
            (cond_ass.CONDITION_MET_FLAG is null or cond_ass.CONDITION_MET_FLAG = 'N') and
            cond_ass.end_date_active is null;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT SET_AUTOFUNDING;
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

    -- getting disbursement header info
    open disb_headers_cur(P_LOAN_ID);
    fetch disb_headers_cur into l_DISB_HEADER_REC.DISB_HEADER_ID, l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER;

    -- if no record found and P_AUTOFUNDING_FLAG = Y - throw exception; otherwise return without error
    if disb_headers_cur%NOTFOUND then

        close disb_headers_cur;

        if P_AUTOFUNDING_FLAG = 'Y' then

    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No disbursement header record found');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CREATE_DISB_SCHED');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        X_RETURN_STATUS := l_return_status;
        return;

    end if;
    close disb_headers_cur;

    if P_AUTOFUNDING_FLAG = 'Y' then

        -- validate headers and lines
        VALIDATE_DISB_HEADERS(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => P_LOAN_ID,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to VALIDATE_DISB_HEADERS failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        VALIDATE_DISB_FOR_SUBMIT(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_HEADER_ID        => l_DISB_HEADER_REC.DISB_HEADER_ID,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to VALIDATE_DISB_FOR_SUBMIT failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- checking for conditions
        open conditions_cur(l_DISB_HEADER_REC.DISB_HEADER_ID);
        fetch conditions_cur into l_cond_count;
        close conditions_cur;

        if l_cond_count > 0 then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_AUTOFUND_AND_MAND_CONDIT');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        LNS_COND_ASSIGNMENT_PUB.VALIDATE_CUSTOM_CONDITIONS(
                            P_API_VERSION		    => 1.0,
                            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
                            P_COMMIT			    => FND_API.G_FALSE,
                            P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
                            P_OWNER_OBJECT_ID       => l_DISB_HEADER_REC.DISB_HEADER_ID,
                            P_CONDITION_TYPE        => 'DISBURSEMENT',
                            P_COMPLETE_FLAG         => 'N',
                            X_RETURN_STATUS		    => l_return_status,
                            X_MSG_COUNT			    => l_msg_count,
                            X_MSG_DATA	    		=> l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        end if;

    end if;

    -- getting disbursement header info again
    open disb_headers_cur(P_LOAN_ID);
    fetch disb_headers_cur into l_DISB_HEADER_REC.DISB_HEADER_ID, l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER;
    close disb_headers_cur;

    l_DISB_HEADER_REC.AUTOFUNDING_FLAG := P_AUTOFUNDING_FLAG;

    UPDATE_DISB_HEADER(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
        X_RETURN_STATUS		    => l_return_status,
        X_MSG_COUNT			    => l_msg_count,
        X_MSG_DATA	    	    => l_msg_data);

    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated record into LNS_DISB_HEADERS');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO SET_AUTOFUNDING;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SET_AUTOFUNDING;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO SET_AUTOFUNDING;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure validates funding advice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_FUNDING_ADVICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_FUNDING_ADVICE_REC            LNS_FUNDING_PUB.FUNDING_ADVICE_REC;
    l_AUTOFUNDING_FLAG              varchar2(1);
    l_loan_class                    varchar2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure validates funding advice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_FUNDING_ADVICE_REC    IN          Funding advice record
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_FUNDING_ADVICE_REC    IN          LNS_FUNDING_PUB.FUNDING_ADVICE_REC,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_FUNDING_ADVICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE CREATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure is for automatic funding advice creation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
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
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_ADVICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_FUNDING_ADVICE_REC            LNS_FUNDING_PUB.FUNDING_ADVICE_REC;
    l_AUTOFUNDING_FLAG              VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE CREATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure creates funding advice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_FUNDING_ADVICE_REC    IN          Funding advice record
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
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
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_FUNDING_ADVICE_REC    IN          LNS_FUNDING_PUB.FUNDING_ADVICE_REC,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_ADVICE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_FUNDING_ADVICE_REC            LNS_FUNDING_PUB.FUNDING_ADVICE_REC;
    l_loan_version                  number;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_BANK_ACC_USE_REC              LNS_FUNDING_PUB.BANK_ACCOUNT_USE_REC;
    l_BANK_ACC_USE_ID               number;
    l_funding_advice_id             number;
    l_loan_class                    varchar2(80);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;



/*========================================================================
 | PUBLIC FUNCTION GET_FUNDING_ADVICE_NUMBER
 |
 | DESCRIPTION
 |      This procedure generates new funding advice number.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Loan ID
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
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
FUNCTION GET_FUNDING_ADVICE_NUMBER(P_LOAN_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'GET_FUNDING_ADVICE_NUMBER';
    l_return            VARCHAR2(60);
    l_loan_number       VARCHAR2(60);
    l_count             number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;



/*========================================================================
 | PUBLIC FUNCTION GET_FUNDING_ADVICE_DESC
 |
 | DESCRIPTION
 |      This procedure generates new funding advice description.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Loan ID
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
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
FUNCTION GET_FUNDING_ADVICE_DESC(P_LOAN_ID IN NUMBER) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'GET_FUNDING_ADVICE_DESC';
    l_return            VARCHAR2(60);
    l_loan_number       VARCHAR2(60);
    l_count             number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;



/*========================================================================
 | PRIVATE PROCEDURE PROCESS_SINGLE_FUNDING
 |
 | DESCRIPTION
 |      This procedure processes single funding advice status.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_FUNDING_ADVICE_ID     IN          Funding advice id
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
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_SINGLE_FUNDING(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_FUNDING_ADVICE_ID     IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PROCESS_SINGLE_FUNDING';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_FUNDING_ADVICE_ID             number;
    l_LOAN_ID                       number;
    l_ADVICE_NUMBER                 VARCHAR2(60);
    l_SUBMISSION_DATE               DATE;
    l_AMOUNT                        number;
    l_CURRENCY                      VARCHAR2(15);
    l_DUE_DATE                      date;
    l_INVOICE_ID                    number;
    l_INVOICE_NUMBER                VARCHAR2(50);
    l_PAYMENT_METHOD                VARCHAR2(30);
    l_STATUS                        VARCHAR2(30);
    l_PAYEE_ID                      number;
    l_PAYEE_SITE_ID                 number;
    l_REQUEST_ID                    number;
    l_ADVICE_VERSION_NUMBER         number;
    l_LOAN_START_DATE               date;
    l_LOAN_VERSION_NUMBER           number;
    l_LOAN_STATUS                   VARCHAR2(30);
    l_TERM_ID                       number;
    l_TERM_VERSION_NUMBER           number;
    l_dummy                         varchar2(10);
    l_temp_id                       number;
    l_invoice_status                VARCHAR2(80);
    l_actual_invoice_id             number;
    l_last_payment_date             date;
    l_new_loan_status               VARCHAR2(30);
    l_new_funding_status            VARCHAR2(30);
    l_rphase                        varchar2(80);
    l_rstatus                       varchar2(80);
    l_dphase                        varchar2(80);
    l_dstatus                       varchar2(80);
    l_request_msg                   varchar2(240);
    l_request_status                boolean;
    l_do_billing                    number;

    l_term_rec                      LNS_TERMS_PUB.loan_term_rec_type;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE CHECK_FUNDING_STATUS
 |
 | DESCRIPTION
 |      This procedure checks for funding status of:
 |          - all funding advices or
 |          - all funding advices for particular loan or
 |          - one particular funding advice
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_FUNDING_ADVICE_ID     IN          Funding advice ID
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
 | 11-30-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CHECK_FUNDING_STATUS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_FUNDING_ADVICE_ID     IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CHECK_FUNDING_STATUS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_funding_advice_id             number;
    l_count                         number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
    null;
END;


/*========================================================================
 | PUBLIC PROCEDURE LNS_CHK_FUND_STAT_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to check funding status
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      CHECK_FUNDING_STATUS
 |      LogMessage
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      LOAN_ID             IN      Inputs loan
 |      FUNDING_ADVICE_ID   IN      Input funding advice
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
 | 12-02-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_CHK_FUND_STAT_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_ID             IN             NUMBER,
        FUNDING_ADVICE_ID   IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	number;

BEGIN
    null;
END;




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_FOR_PAYOFF
 |
 | DESCRIPTION
 |      This procedure validates disbursements for payoff process
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 12-08-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_FOR_PAYOFF(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_FOR_PAYOFF';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_in_funding_count              number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- querying disbursement lines info
    CURSOR in_fund_count_cur(P_LOAN_ID number) IS
        select nvl(count(line.DISB_LINE_ID), 0)
        from LNS_DISB_LINES line,
            LNS_DISB_HEADERS head
        where head.LOAN_ID = P_LOAN_ID and
            line.DISB_HEADER_ID = head.DISB_HEADER_ID and
            line.status is not null and
            line.status = 'IN_FUNDING';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating disbursements for payoff process...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan: ' || P_LOAN_ID);

    open in_fund_count_cur(P_LOAN_ID);
    fetch in_fund_count_cur into l_in_funding_count;
    close in_fund_count_cur;

    if l_in_funding_count > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_PAYOFF_IN_FUND');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated disbursements for payoff process');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;



/*========================================================================
 | PUBLIC PROCEDURE CHECK_FOR_VOIDED_INVOICES
 |
 | DESCRIPTION
 |      This procedure checks for voided AP invoices and cancelles appropriate disb lines and headers in Loans
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 01-25-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CHECK_FOR_VOIDED_INVOICES(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CHECK_FOR_VOIDED_INVOICES';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_count                         number;
    i                               number;
    k                               number;
    l_DISB_HEADER_ID                number;
    l_invoice_number                VARCHAR2(50);
    l_cancelled_date                date;
    l_hist_id                       number;
    l_hist_version                  number;
    l_found                         boolean;

    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;
    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_ids_tbl                       DBMS_SQL.NUMBER_TABLE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- querying disbursement lines info
    CURSOR voided_invoices_cur(P_LOAN_ID number) IS
        select lines.DISB_LINE_ID,
            lines.STATUS,
            lines.OBJECT_VERSION_NUMBER,
            head.DISB_HEADER_ID,
            inv.INVOICE_NUM,
            inv.cancelled_date
        from LNS_DISB_LINES lines,
            LNS_DISB_HEADERS head,
            ap_invoices_all inv
        where head.loan_id = P_LOAN_ID and
            head.DISB_HEADER_ID = lines.DISB_HEADER_ID and
            lines.status is not null and
            lines.status <> 'CANCELLED' and
            lines.invoice_id is not null and
            lines.invoice_id = inv.invoice_id and
            inv.cancelled_date is not null;

    -- getting disbursement header info
    CURSOR disb_hdr_cur(P_DISB_HEADER_ID number) IS
        select head.DISB_HEADER_ID,
            head.STATUS,
            head.OBJECT_VERSION_NUMBER,
            (select count(1)
             from lns_disb_lines
             where DISB_HEADER_ID = head.DISB_HEADER_ID and
             status <> 'CANCELLED')
        from LNS_DISB_HEADERS head
        where head.DISB_HEADER_ID = P_DISB_HEADER_ID;

    -- getting last history record to update status
    CURSOR last_hist_rec_cur(P_DISB_LINE_ID number) IS
        select max(DISB_HISTORY_ID), max(OBJECT_VERSION_NUMBER+1)
        from lns_disb_histories_h
        where DISB_LINE_ID = P_DISB_LINE_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan: ' || P_LOAN_ID);

    -- Standard start of API savepoint
    SAVEPOINT CHECK_FOR_VOIDED_INVOICES;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching voided AP invoices that are not cancelled in Loans yet...');

    i := 0;
    k := 0;
    open voided_invoices_cur(P_LOAN_ID);
    LOOP

        fetch voided_invoices_cur into
            l_DISB_LINE_REC.DISB_LINE_ID,
            l_DISB_LINE_REC.STATUS,
            l_DISB_LINE_REC.OBJECT_VERSION_NUMBER,
            l_DISB_HEADER_ID,
            l_invoice_number,
            l_cancelled_date;
        exit when voided_invoices_cur%NOTFOUND;

        i := i + 1;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Found invoice ' || i);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_LINE_ID: ' || l_DISB_LINE_REC.DISB_LINE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_LINE STATUS: ' || l_DISB_LINE_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'OBJECT_VERSION_NUMBER: ' || l_DISB_LINE_REC.OBJECT_VERSION_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_DISB_HEADER_ID: ' || l_DISB_HEADER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_invoice_number: ' || l_invoice_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cancelled_date: ' || l_cancelled_date);

        -- getting last history record to update status
        open last_hist_rec_cur(l_DISB_LINE_REC.DISB_LINE_ID);
        fetch last_hist_rec_cur into l_hist_id, l_hist_version;
        close last_hist_rec_cur;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'hist_id: ' || l_hist_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'hist_version: ' || l_hist_version);

        if l_hist_id is not null and l_hist_version is not null then

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating history record...');
            -- calling history table handler api
            LNS_DISB_HISTORIES_H_PKG.Update_Row(
                P_DISB_HISTORY_ID       => l_hist_id,
                P_STATUS                => 'CANCELLED',
                P_OBJECT_VERSION_NUMBER => l_hist_version);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated history record with ID: ' || l_hist_id);

        end if;

        l_DISB_LINE_REC.STATUS := 'CANCELLED';
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating disb line to status ' || l_DISB_LINE_REC.STATUS);
        UPDATE_DISB_LINE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_DISB_LINE_REC         => l_DISB_LINE_REC,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_LINE failed');
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Success');
        END IF;

        l_found := false;
        FOR j IN 1..l_ids_tbl.count LOOP
            if l_ids_tbl(j) = l_DISB_HEADER_ID then
                l_found := true;
                exit;
            end if;
        END LOOP;

        if l_found = false then
            k := k + 1;
            l_ids_tbl(k) := l_DISB_HEADER_ID;
        end if;

    END LOOP;
    close voided_invoices_cur;

    if i = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No voided AP invoices found');
    end if;

    FOR j IN 1..l_ids_tbl.count LOOP

        -- getting disbursement header info
        open disb_hdr_cur(l_ids_tbl(j));
        fetch disb_hdr_cur into l_DISB_HEADER_REC.DISB_HEADER_ID,
                                l_DISB_HEADER_REC.STATUS,
                                l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER,
                                l_count;
        close disb_hdr_cur;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Disbursement ' || j);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID: ' || l_DISB_HEADER_REC.DISB_HEADER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER STATUS: ' || l_DISB_HEADER_REC.STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_count: ' || l_count);

        -- if all lines are cancelled then cancel header as well
        if l_count = 0 then

            l_DISB_HEADER_REC.STATUS := 'CANCELLED';

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating disb header to status ' || l_DISB_HEADER_REC.STATUS);
            -- updating disb header
            UPDATE_DISB_HEADER(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                P_COMMIT			    => FND_API.G_FALSE,
                P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
                P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
                X_RETURN_STATUS		    => l_return_status,
                X_MSG_COUNT			    => l_msg_count,
                X_MSG_DATA	    	    => l_msg_data);

            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to UPDATE_DISB_HEADER failed');
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Success');
            END IF;

        end if;

    END LOOP;

    UPDATE_LOAN_FUNDING_STATUS(P_LOAN_ID);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CHECK_FOR_VOIDED_INVOICES;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CHECK_FOR_VOIDED_INVOICES;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CHECK_FOR_VOIDED_INVOICES;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;



PROCEDURE UPDATE_LOAN_FUNDING_STATUS(P_LOAN_ID number)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'UPDATE_LOAN_FUNDING_STATUS';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_funding_error_count           number;
    l_in_funding_count              number;
    l_loan_version                  number;
    l_requested_amount              number;
    l_funded_amount                 number;
    l_loan_status                   varchar2(30);
    l_SECONDARY_STATUS              varchar2(30);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_cur(P_LOAN_ID number) IS
        select
            loan.loan_id,
            loan.OBJECT_VERSION_NUMBER,
            loan.REQUESTED_AMOUNT + nvl(loan.ADD_REQUESTED_AMOUNT, 0),
            loan.loan_status,
            loan.SECONDARY_STATUS
        from LNS_LOAN_HEADERS loan
        where loan.LOAN_ID = P_LOAN_ID;

    CURSOR disb_amount_cur(P_LOAN_ID number) IS
        select nvl(sum(lines.LINE_AMOUNT), 0)
        from LNS_DISB_LINES lines,
            LNS_DISB_HEADERS head
        where head.LOAN_ID = P_LOAN_ID and
            lines.DISB_HEADER_ID = head.DISB_HEADER_ID and
            (lines.STATUS is not null and lines.STATUS = 'FULLY_FUNDED') and
            lines.DISBURSEMENT_DATE is not null;

    CURSOR disb_count_cur(P_LOAN_ID number, P_STATUS VARCHAR2) IS
        select count(1)
        from LNS_DISB_HEADERS head
        where head.LOAN_ID = P_LOAN_ID and
            (head.STATUS is not null and head.STATUS = P_STATUS);

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan: ' || P_LOAN_ID);

    open loan_cur(P_LOAN_ID);
    fetch loan_cur into l_loan_header_rec.LOAN_ID,
                        l_loan_version,
                        l_requested_amount,
                        l_loan_status,
                        l_SECONDARY_STATUS;
    close loan_cur;

    open disb_amount_cur(P_LOAN_ID);
    fetch disb_amount_cur into l_funded_amount;
    close disb_amount_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_requested_amount: ' || l_requested_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_funded_amount: ' || l_funded_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_status: ' || l_loan_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_SECONDARY_STATUS: ' || l_SECONDARY_STATUS);

    if l_funded_amount > 0 and l_requested_amount > 0 and l_funded_amount = l_requested_amount then
        l_loan_header_rec.SECONDARY_STATUS := 'FULLY_FUNDED';
    else
        open disb_count_cur(P_LOAN_ID, 'IN_FUNDING');
        fetch disb_count_cur into l_in_funding_count;
        close disb_count_cur;

        open disb_count_cur(P_LOAN_ID, 'FUNDING_ERROR');
        fetch disb_count_cur into l_funding_error_count;
        close disb_count_cur;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_in_funding_count: ' || l_in_funding_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_funding_error_count: ' || l_funding_error_count);

        if l_funding_error_count > 0 then
            l_loan_header_rec.SECONDARY_STATUS := 'FUNDING_ERROR';
        elsif l_in_funding_count > 0 then
            l_loan_header_rec.SECONDARY_STATUS := 'IN_FUNDING';
        elsif l_funded_amount > 0 and l_requested_amount > 0 then
            l_loan_header_rec.SECONDARY_STATUS := 'PARTIALLY_FUNDED';
        else
            l_loan_header_rec.SECONDARY_STATUS := FND_API.G_MISS_CHAR;
        end if;
    end if;

    if l_SECONDARY_STATUS is null or l_SECONDARY_STATUS <> l_loan_header_rec.SECONDARY_STATUS then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'secondary status: ' || l_loan_header_rec.SECONDARY_STATUS);

        LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_version,
                                        P_LOAN_HEADER_REC => l_loan_header_rec,
                                        P_INIT_MSG_LIST => FND_API.G_FALSE,
                                        X_RETURN_STATUS => l_return_status,
                                        X_MSG_COUNT => l_msg_count,
                                        X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

        IF l_return_status <> 'S' THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



/*========================================================================
 | PUBLIC PROCEDURE CREATE_DISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure creates quick disbursement
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan ID
 |      P_DESCRIPTION               IN          Descrition
 |      P_AMOUNT                    IN          Amount
 |      P_DUE_DATE                  IN          Due Date
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
 | 02-02-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_DISBURSEMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_DESCRIPTION           IN          VARCHAR2,
    P_AMOUNT                IN          NUMBER,
    P_DUE_DATE              IN          DATE,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_DISBURSEMENT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Trxn_Attributes_Rec           IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
    l_Default_Pmt_Attrs_Rec         IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;
    l_org_id                        lns_loan_headers_all.org_id%TYPE;
    l_legal_entity_id               lns_Loan_headers_all.legal_entity_id%TYPE;
    l_payment_method_code           lns_disb_lines.payment_method_code%TYPE;
    l_bank_account_id               lns_disb_lines.bank_account_id%TYPE;
    l_payee_party_id                lns_disb_lines.payee_party_id%TYPE;
    l_current_phase                 varchar2(30);
    l_currency                      varchar2(15);

    l_DISB_HEADER_REC               LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC;
    l_DISB_LINE_REC                 LNS_FUNDING_PUB.LNS_DISB_LINES_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DESCRIPTION: ' || P_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_AMOUNT: ' || P_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_DUE_DATE: ' || P_DUE_DATE);

    -- Standard start of API savepoint
    SAVEPOINT CREATE_DISBURSEMENT;
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

    IF P_LOAN_ID IS NULL THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'LOAN ID is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_ID' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF P_AMOUNT IS NULL THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'AMOUNT is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_AMOUNT' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF P_DUE_DATE IS NULL THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'DUE_DATE is missing');
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_DUE_DATE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying loan info...');
    SELECT llh.primary_borrower_id
            ,llh.org_id
            ,llh.legal_entity_id
            ,llh.current_phase
            ,llh.LOAN_CURRENCY
    INTO   l_payee_party_id
            ,l_org_id
            ,l_legal_entity_id
            ,l_current_phase
            ,l_currency
    FROM   lns_loan_headers_all llh
    WHERE  llh.loan_id = p_loan_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payee_party_id: ' || l_payee_party_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_org_id: ' || l_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_legal_entity_id: ' || l_legal_entity_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_current_phase: ' || l_current_phase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_currency: ' || l_currency);

    l_Trxn_Attributes_Rec.Application_Id            := 206;
    l_Trxn_Attributes_Rec.Payer_Legal_Entity_Id     := l_legal_entity_id;
    l_Trxn_Attributes_Rec.Payer_Org_Id              := l_org_id;
    l_Trxn_Attributes_Rec.Payer_Org_Type            := 'OPERATING_UNIT';
    l_Trxn_Attributes_Rec.Payee_Party_Id            := l_payee_party_id;
    l_Trxn_Attributes_Rec.Pay_Proc_Trxn_Type_Code   := 'LOAN_PAYMENT';
    l_Trxn_Attributes_Rec.Payment_Currency          := l_currency;
    l_Trxn_Attributes_Rec.Payment_Function          := 'LOANS_PAYMENTS';

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes...');
    IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes(
            p_api_version             => 1.0,
            p_init_msg_list           => FND_API.G_TRUE,
            p_ignore_payee_pref       => null,
            p_trxn_attributes_rec     => l_Trxn_Attributes_Rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data,
            x_default_pmt_attrs_rec   => l_Default_Pmt_Attrs_Rec);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status = 'S' THEN
        l_payment_method_code := l_Default_Pmt_Attrs_Rec.Payment_Method.Payment_Method_Code;
        l_bank_account_id := l_Default_Pmt_Attrs_Rec.Payee_BankAccount.Payee_BankAccount_Id;
    END IF;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payment_method_code: ' || l_payment_method_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_bank_account_id: ' || l_bank_account_id);

    -- create disb header
    select lns_disb_headers_s.NEXTVAL into l_DISB_HEADER_REC.DISB_HEADER_ID from dual;

    l_DISB_HEADER_REC.LOAN_ID := p_loan_id;
    l_DISB_HEADER_REC.HEADER_AMOUNT := P_AMOUNT;
    l_DISB_HEADER_REC.PAYMENT_REQUEST_DATE := P_DUE_DATE;
    l_DISB_HEADER_REC.OBJECT_VERSION_NUMBER := 1;
    l_DISB_HEADER_REC.PHASE := l_current_phase;
    l_DISB_HEADER_REC.DESCRIPTION := nvl(P_DESCRIPTION, 'Disbursement');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling INSERT_DISB_HEADER...');
    INSERT_DISB_HEADER(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_DISB_HEADER_REC       => l_DISB_HEADER_REC,
        X_RETURN_STATUS		    => l_return_status,
        X_MSG_COUNT			    => l_msg_count,
        X_MSG_DATA	    	    => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to INSERT_DISB_HEADER failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- create disb line
    select lns_disb_lines_s.NEXTVAL into l_DISB_LINE_REC.DISB_LINE_ID from dual;

    l_DISB_LINE_REC.DISB_HEADER_ID := l_DISB_HEADER_REC.DISB_HEADER_ID;
    l_DISB_LINE_REC.DISB_LINE_NUMBER := 1;
    l_DISB_LINE_REC.LINE_AMOUNT := P_AMOUNT;
    l_DISB_LINE_REC.LINE_PERCENT := 100;
    l_DISB_LINE_REC.PAYEE_PARTY_ID := l_payee_party_id;
    l_DISB_LINE_REC.BANK_ACCOUNT_ID := l_bank_account_id;
    l_DISB_LINE_REC.PAYMENT_METHOD_CODE := l_payment_method_code;
    l_DISB_LINE_REC.OBJECT_VERSION_NUMBER := 1;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling INSERT_DISB_LINE...');
    INSERT_DISB_LINE(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
        P_DISB_LINE_REC         => l_DISB_LINE_REC,
        X_RETURN_STATUS		    => l_return_status,
        X_MSG_COUNT			    => l_msg_count,
        X_MSG_DATA	    	    => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to INSERT_DISB_LINE failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_COND_ASSIGNMENT_PUB.DEFAULT_COND_ASSIGNMENTS...');
    LNS_COND_ASSIGNMENT_PUB.DEFAULT_COND_ASSIGNMENTS(
        P_API_VERSION               => 1.0,
        P_INIT_MSG_LIST             => FND_API.G_FALSE,
        P_COMMIT                    => FND_API.G_TRUE,
        P_VALIDATION_LEVEL		    => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID                   => p_loan_id,
        P_OWNER_OBJECT_ID           => l_DISB_HEADER_REC.DISB_HEADER_ID,
        P_CONDITION_TYPE            => 'DISBURSEMENT',
        X_RETURN_STATUS             => L_RETURN_STATUS,
        X_MSG_COUNT                 => L_MSG_COUNT,
        X_MSG_DATA                  => L_MSG_DATA);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status <> 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Call to LNS_COND_ASSIGNMENT_PUB.DEFAULT_COND_ASSIGNMENTS failed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_DISBURSEMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_DISBURSEMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_DISBURSEMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;



BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

    -- getting msg logging info
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

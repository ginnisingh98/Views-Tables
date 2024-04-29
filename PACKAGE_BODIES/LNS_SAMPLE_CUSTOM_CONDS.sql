--------------------------------------------------------
--  DDL for Package Body LNS_SAMPLE_CUSTOM_CONDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_SAMPLE_CUSTOM_CONDS" as
/* $Header: LNS_SMPL_CUSTOM_CONDS_B.pls 120.0.12010000.1 2010/03/22 15:30:21 scherkas noship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_SAMPLE_CUSTOM_CONDS';
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
 | PUBLIC PROCEDURE VALIDATE_INCREASE_LOAN_AMOUNT1
 |
 | DESCRIPTION
 |      This procedure implements sample validation of increase loan amount - increase of loan amount must not be greater
 |      than 10% of original loan amount.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_INCREASE_LOAN_AMOUNT1(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_INCREASE_LOAN_AMOUNT1';
    l_LOAN_ID                       NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_OWNER_OBJECT_ID               NUMBER;
    l_OWNER_TABLE                   VARCHAR2(100);
    l_REQUESTED_AMOUNT              NUMBER;
    l_column                        varchar2(100);
    l_ratio                         number;
    l_pass_ratio                    number;
    l_increase_amount               number;
    l_where_clause                  varchar2(2000);
    l_query_str                     varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond_ass.LOAN_ID,
            cond_ass.OWNER_OBJECT_ID,
            cond_ass.OWNER_TABLE,
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond.MANDATORY_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.COND_ASSIGNMENT_ID = P_COND_ASSIGNMENT_ID
        and cond.condition_id = cond_ass.condition_id;

    /* querying loan requested amount */
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select REQUESTED_AMOUNT
        from lns_loan_headers_all
        where loan_id = P_LOAN_ID;

BEGIN

    X_CONDITION_MET := 'Y';
    l_pass_ratio := 10;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
        return;
    end if;

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_LOAN_ID,
        l_OWNER_OBJECT_ID,
        l_OWNER_TABLE,
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID = ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_OBJECT_ID = ' || l_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_TABLE = ' || l_OWNER_TABLE);

    /* querying loan requested amount */
    open loan_info_cur(l_LOAN_ID);
    fetch loan_info_cur into l_REQUESTED_AMOUNT;
    close loan_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_REQUESTED_AMOUNT = ' || l_REQUESTED_AMOUNT);

    /* querying increase loan amount */
    if l_CONDITION_TYPE = 'LOAN_AMOUNT_ADJUSTMENT' then
        l_column := 'ADJUSTMENT_AMOUNT';
        l_where_clause := 'LOAN_AMOUNT_ADJ_ID';
    elsif l_CONDITION_TYPE = 'ADDITIONAL_RECEIVABLE' then
        l_column := 'REQUESTED_AMOUNT';
        l_where_clause := 'LOAN_LINE_ID';
    end if;

    l_query_str := ' Select ' || l_column || ' From ' || l_OWNER_TABLE || ' where ' || l_where_clause || ' = ' || l_OWNER_OBJECT_ID;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query_str: ' || l_query_str);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executing query...');
    Execute Immediate l_query_str into l_increase_amount;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_increase_amount = ' || l_increase_amount);

    l_ratio := 100*l_increase_amount/l_REQUESTED_AMOUNT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_ratio = ' || l_ratio);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_pass_ratio = ' || l_pass_ratio);

    if l_ratio > l_pass_ratio then
        X_CONDITION_MET := 'N';
        X_ERROR := 'Increase of loan amount must not be greater than ' || l_pass_ratio || '% of original loan amount.';
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_LOAN_APPR_COND1
 |
 | DESCRIPTION
 |      This procedure implements sample validation for loan approval.
 |      This procedure always returns success.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_LOAN_APPR_COND1(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_LOAN_APPR_COND1';

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    X_CONDITION_MET := 'Y';

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_LOAN_APPR_COND2
 |
 | DESCRIPTION
 |      This procedure implements sample validation for loan approval.
 |      This procedure always returns failure.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_LOAN_APPR_COND2(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_LOAN_APPR_COND2';

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    X_CONDITION_MET := 'N';
    X_ERROR := 'VALIDATE_LOAN_APPR_COND2 has failed';

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_AMOUNT
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement amount - disbursement amount must be greater then
 |      or equal to 20% of current loan amount.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    100%*(disbursement_amount/loan_amount) >= 20%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_AMOUNT(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB_AMOUNT';
    l_LOAN_ID                       NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_OWNER_OBJECT_ID               NUMBER;
    l_OWNER_TABLE                   VARCHAR2(100);
    l_REQUESTED_AMOUNT              NUMBER;
    l_column                        varchar2(100);
    l_ratio                         number;
    l_pass_ratio                    number;
    l_disb_amount                   number;
    l_where_clause                  varchar2(2000);
    l_query_str                     varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond_ass.LOAN_ID,
            cond_ass.DISB_HEADER_ID,
            'LNS_DISB_HEADERS',
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond.MANDATORY_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.COND_ASSIGNMENT_ID = P_COND_ASSIGNMENT_ID
        and cond.condition_id = cond_ass.condition_id;

    /* querying loan requested amount */
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select REQUESTED_AMOUNT + nvl(ADD_REQUESTED_AMOUNT, 0)
        from lns_loan_headers_all
        where loan_id = P_LOAN_ID;

BEGIN

    X_CONDITION_MET := 'Y';
    l_pass_ratio := 20;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
        return;
    end if;

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_LOAN_ID,
        l_OWNER_OBJECT_ID,
        l_OWNER_TABLE,
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID = ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_OBJECT_ID = ' || l_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_TABLE = ' || l_OWNER_TABLE);

    /* querying loan requested amount */
    open loan_info_cur(l_LOAN_ID);
    fetch loan_info_cur into l_REQUESTED_AMOUNT;
    close loan_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_REQUESTED_AMOUNT = ' || l_REQUESTED_AMOUNT);

    /* querying increase loan amount */
    if l_CONDITION_TYPE = 'DISBURSEMENT' then
        l_column := 'HEADER_AMOUNT';
        l_where_clause := 'DISB_HEADER_ID';
    end if;

    l_query_str := ' Select ' || l_column || ' From ' || l_OWNER_TABLE || ' where ' || l_where_clause || ' = ' || l_OWNER_OBJECT_ID;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query_str: ' || l_query_str);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executing query...');
    Execute Immediate l_query_str into l_disb_amount;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_disb_amount = ' || l_disb_amount);

    l_ratio := 100*l_disb_amount/l_REQUESTED_AMOUNT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_ratio = ' || l_ratio);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_pass_ratio = ' || l_pass_ratio);

    if l_ratio < l_pass_ratio then
        X_CONDITION_MET := 'N';
        X_ERROR := 'Disbursement amount must be at least ' || l_pass_ratio || '% of loan amount.';
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB1_AMOUNT
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement amount - disbursement amount must be
 |      or equal to 50% of current loan amount.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |    100%*(disbursement_amount/loan_amount) = 50%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB1_AMOUNT(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_DISB1_AMOUNT';
    l_LOAN_ID                       NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_OWNER_OBJECT_ID               NUMBER;
    l_OWNER_TABLE                   VARCHAR2(100);
    l_REQUESTED_AMOUNT              NUMBER;
    l_column                        varchar2(100);
    l_ratio                         number;
    l_pass_ratio                    number;
    l_disb_amount                   number;
    l_where_clause                  varchar2(2000);
    l_query_str                     varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond_ass.LOAN_ID,
            cond_ass.DISB_HEADER_ID,
            'LNS_DISB_HEADERS',
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond.MANDATORY_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.COND_ASSIGNMENT_ID = P_COND_ASSIGNMENT_ID
        and cond.condition_id = cond_ass.condition_id;

    /* querying loan requested amount */
    CURSOR loan_info_cur(P_LOAN_ID number) IS
        select REQUESTED_AMOUNT + nvl(ADD_REQUESTED_AMOUNT, 0)
        from lns_loan_headers_all
        where loan_id = P_LOAN_ID;

BEGIN

    X_CONDITION_MET := 'Y';
    l_pass_ratio := 50;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
        return;
    end if;

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_LOAN_ID,
        l_OWNER_OBJECT_ID,
        l_OWNER_TABLE,
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID = ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_OBJECT_ID = ' || l_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_TABLE = ' || l_OWNER_TABLE);

    /* querying loan requested amount */
    open loan_info_cur(l_LOAN_ID);
    fetch loan_info_cur into l_REQUESTED_AMOUNT;
    close loan_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_REQUESTED_AMOUNT = ' || l_REQUESTED_AMOUNT);

    /* querying increase loan amount */
    if l_CONDITION_TYPE = 'DISBURSEMENT' then
        l_column := 'HEADER_AMOUNT';
        l_where_clause := 'DISB_HEADER_ID';
    end if;

    l_query_str := ' Select ' || l_column || ' From ' || l_OWNER_TABLE || ' where ' || l_where_clause || ' = ' || l_OWNER_OBJECT_ID;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query_str: ' || l_query_str);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executing query...');
    Execute Immediate l_query_str into l_disb_amount;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_disb_amount = ' || l_disb_amount);

    l_ratio := 100*l_disb_amount/l_REQUESTED_AMOUNT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_ratio = ' || l_ratio);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_pass_ratio = ' || l_pass_ratio);

    if l_ratio <> l_pass_ratio then
        X_CONDITION_MET := 'N';
        X_ERROR := 'Disbursement amount must be equal to ' || l_pass_ratio || '% of loan amount.';
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_NUM_DISB_IN_MONTH
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement -
 |      number of disbursements in any given month cannot be greater than 1
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_NUM_DISB_IN_MONTH(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_NUM_DISB_IN_MONTH';
    l_LOAN_ID                       NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_OWNER_OBJECT_ID               NUMBER;
    l_OWNER_TABLE                   VARCHAR2(100);
    l_due_date                      DATE;
    l_column                        varchar2(100);
    l_ratio                         number;
    l_pass_ratio                    number;
    l_disb_amount                   number;
    l_where_clause                  varchar2(2000);
    l_query_str                     varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond_ass.LOAN_ID,
            cond_ass.DISB_HEADER_ID,
            'LNS_DISB_HEADERS',
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond.MANDATORY_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.COND_ASSIGNMENT_ID = P_COND_ASSIGNMENT_ID
        and cond.condition_id = cond_ass.condition_id;

    /* querying loan requested amount */
    CURSOR due_date_cur(P_DISB_HEADER_ID number) IS
        select PAYMENT_REQUEST_DATE
        from lns_disb_headers
        where disb_header_id = P_DISB_HEADER_ID;

BEGIN

    X_CONDITION_MET := 'Y';
    l_pass_ratio := 1;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
        return;
    end if;

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_LOAN_ID,
        l_OWNER_OBJECT_ID,
        l_OWNER_TABLE,
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID = ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_OBJECT_ID = ' || l_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_TABLE = ' || l_OWNER_TABLE);

    /* querying loan requested amount */
    open due_date_cur(l_OWNER_OBJECT_ID);
    fetch due_date_cur into l_due_date;
    close due_date_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_due_date = ' || l_due_date);

    /* querying increase loan amount */
    if l_CONDITION_TYPE = 'DISBURSEMENT' then
        l_column := 'count(1)';
        l_where_clause := 'loan_id = :1 and trunc(PAYMENT_REQUEST_DATE, ''MONTH'') = trunc(:2' ||
                          ', ''MONTH'') and (status is null or status <> ''CANCELLED'')';
    end if;

    l_query_str := ' Select ' || l_column || ' From ' || l_OWNER_TABLE || ' where ' || l_where_clause;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query_str: ' || l_query_str);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executing query...');
    Execute Immediate l_query_str into l_ratio USING l_LOAN_ID, l_due_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_ratio = ' || l_ratio);

    if l_ratio > l_pass_ratio then
        X_CONDITION_MET := 'N';
        X_ERROR := 'Number of disbursement in any given month cannot be greater than ' || l_pass_ratio;
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

END;



 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_NUM_DISB_IN_YEAR
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement -
 |      number of disbursements in calendar year cannot be greater than 4
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_NUM_DISB_IN_YEAR(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_NUM_DISB_IN_YEAR';
    l_LOAN_ID                       NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_OWNER_OBJECT_ID               NUMBER;
    l_OWNER_TABLE                   VARCHAR2(100);
    l_due_date                      DATE;
    l_column                        varchar2(100);
    l_ratio                         number;
    l_pass_ratio                    number;
    l_disb_amount                   number;
    l_where_clause                  varchar2(2000);
    l_query_str                     varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond_ass.LOAN_ID,
            cond_ass.DISB_HEADER_ID,
            'LNS_DISB_HEADERS',
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond.MANDATORY_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.COND_ASSIGNMENT_ID = P_COND_ASSIGNMENT_ID
        and cond.condition_id = cond_ass.condition_id;

    /* querying loan requested amount */
    CURSOR due_date_cur(P_DISB_HEADER_ID number) IS
        select PAYMENT_REQUEST_DATE
        from lns_disb_headers
        where disb_header_id = P_DISB_HEADER_ID;

BEGIN

    X_CONDITION_MET := 'Y';
    l_pass_ratio := 4;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Input:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    if P_COND_ASSIGNMENT_ID is null then
        X_CONDITION_MET := 'N';
        X_ERROR := 'P_COND_ASSIGNMENT_ID must be set';
        return;
    end if;

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_LOAN_ID,
        l_OWNER_OBJECT_ID,
        l_OWNER_TABLE,
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_LOAN_ID = ' || l_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_OBJECT_ID = ' || l_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_OWNER_TABLE = ' || l_OWNER_TABLE);

    /* querying loan requested amount */
    open due_date_cur(l_OWNER_OBJECT_ID);
    fetch due_date_cur into l_due_date;
    close due_date_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_due_date = ' || l_due_date);

    /* querying increase loan amount */
    if l_CONDITION_TYPE = 'DISBURSEMENT' then
        l_column := 'count(1)';
        l_where_clause := 'loan_id = :1 and trunc(PAYMENT_REQUEST_DATE, ''YEAR'') = trunc(:2' ||
                          ', ''YEAR'') and (status is null or status <> ''CANCELLED'')';
    end if;

    l_query_str := ' Select ' || l_column || ' From ' || l_OWNER_TABLE || ' where ' || l_where_clause;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query_str: ' || l_query_str);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executing query...');
    Execute Immediate l_query_str into l_ratio USING l_LOAN_ID, l_due_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_ratio = ' || l_ratio);

    if l_ratio > l_pass_ratio then
        X_CONDITION_MET := 'N';
        X_ERROR := 'Number of disbursements in calendar year cannot be greater than ' || l_pass_ratio;
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        X_ERROR := sqlerrm;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception. Error - ' || X_ERROR);

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

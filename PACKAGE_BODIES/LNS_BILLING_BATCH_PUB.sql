--------------------------------------------------------
--  DDL for Package Body LNS_BILLING_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_BILLING_BATCH_PUB" as
/* $Header: LNS_BILLING_B.pls 120.33.12010000.29 2010/04/28 13:54:22 scherkas ship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_BILLING_BATCH_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;
    g_org_id                        number;
    g_batch_source_id               number;
    g_days_to_bill_before_dd        number;
    g_trx_type_id                   number;
    g_day_togl_after_dd             number;
    g_multiple_lines                VARCHAR2(1);
    g_sys_opt_num                   number;
    g_int_trx_type_id               number;
    g_fee_trx_type_id               number;
    g_cr_return_status              varchar2(10);
    g_receivables_trx_id            number;
    g_USSGL_TRANSACTION_CODE        varchar2(30);
    g_last_billing_report           clob;
    g_last_all_statements           clob;
    g_forgiveness_rec_trx_id        number;
    g_set_of_books_id               number;


PROCEDURE FORGIVENESS_ADJUSTMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);

PROCEDURE REVERSE_BILLED_FEES(p_amortization_id IN NUMBER);


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CREATE_AR_INVOICES
 |      CREATE_AR_CM
 |      APPLY_RECEIPT
 |      BILL_SINGLE_LOAN
 |      CALC_SINGLE_LOAN_NEXT_DD
 |      LNS_BILLING_CONCUR
 |      LNS_RVRS_PMT_CONCUR
 |      BILL_LOANS
 |      CALC_PAST_DUE_LOANS_NEXT_DD
 |      REVERSE_LAST_AMORTIZATION
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |      CREATE_OFFCYCLE_BILLS
 |      REVERSE_OFFCYCLE_BILL
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

    if FND_GLOBAL.Conc_Request_Id is not null then
        fnd_file.put_line(FND_FILE.LOG, p_msg);
    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



/*========================================================================
 | PRIVATE PROCEDURE init
 |
 | DESCRIPTION
 |      This procedure inits data needed for processing
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BILLING_CONCUR
 |      LNS_RVRS_PMT_CONCUR
 |      BILL_LOANS
 |      CALC_PAST_DUE_LOANS_NEXT_DD
 |      REVERSE_LAST_AMORTIZATION
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |      REVERSE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      None
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
Procedure init
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'INIT';
    l_org_status                    varchar2(1);
BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    --fnd_global.apps_initialize(FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID, FND_GLOBAL.SECURITY_GROUP_ID);

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    G_MSG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    /*
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;
    */

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

    /* getting org_id */
--    g_org_id := to_number(fnd_profile.value('ORG_ID'));
    g_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'g_org_id: ' || g_org_id);
    l_org_status := MO_GLOBAL.check_valid_org(g_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.check_valid_org(' || g_org_id || '): ' || l_org_status);

    /* checking for number of system options record for giving org_id */
    select count(1) into g_sys_opt_num from LNS_SYSTEM_OPTIONS where ORG_ID = g_org_id;

    if g_sys_opt_num = 0 then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No system options found for the org ' || g_org_id);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_SYSTEM_OPTIONS');
		FND_MESSAGE.SET_TOKEN('ORG', g_org_id);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    elsif g_sys_opt_num > 1 then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Found more then 1 system options records for the org ' || g_org_id);
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MANY_SYSTEM_OPTIONS');
		FND_MESSAGE.SET_TOKEN('ORG', g_org_id);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* getting system options */
    select BATCH_SOURCE_ID,
        DAYS_TOBILL_BEFORE_DUE_DATE,
        TRX_TYPE_ID,
        DAYS_TOGL_AFTER_DUE_DATE,
        COMBINE_INT_PRIN_FLAG,
        INTEREST_TRX_TYPE_ID,
        FEE_TRX_TYPE_ID,
        RECEIVABLES_TRX_ID,
        ADJUST_USSGL_TRX_CODE,
        FORGIVENESS_REC_TRX_ID,
        SET_OF_BOOKS_ID
     into g_batch_source_id,
        g_days_to_bill_before_dd,
        g_trx_type_id,
        g_day_togl_after_dd,
        g_multiple_lines,
        g_int_trx_type_id,
        g_fee_trx_type_id,
        g_receivables_trx_id,
        g_USSGL_TRANSACTION_CODE,
        g_forgiveness_rec_trx_id,
        g_set_of_books_id
     FROM LNS_SYSTEM_OPTIONS
    WHERE ORG_ID = g_org_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'System options:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'batch_source_id: ' || g_batch_source_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'days_to_bill_before_dd: ' || g_days_to_bill_before_dd);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'trx_type_id: ' || g_trx_type_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'day_togl_after_dd: ' || g_day_togl_after_dd);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'multiple_lines: ' || g_multiple_lines);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'int_trx_type_id: ' || g_int_trx_type_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'fee_trx_type_id: ' || g_fee_trx_type_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'receivables_trx_id: ' || g_receivables_trx_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'USSGL_TRANSACTION_CODE: ' || g_USSGL_TRANSACTION_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'g_forgiveness_rec_trx_id: ' || g_forgiveness_rec_trx_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'g_set_of_books_id: ' || g_set_of_books_id);

    if g_batch_source_id is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Batch Source is not set in the system option.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_BATCH_IN_SYS_OPT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if g_trx_type_id is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Default Transaction Type is not set in the system option.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_TYPE_IN_SYS_OPT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if g_multiple_lines is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Combination Invoice is not set in the system option.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_INV_COMB_IN_SYS_OPT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



FUNCTION GET_BILLING_DATE(P_DAYS IN NUMBER) RETURN VARCHAR2 IS
    l_return    varchar2(20);
BEGIN

    if P_DAYS is not null then
        l_return := ' ( ' || (sysdate + P_DAYS) || ' )';
    end if;

    return l_return;
END;



/*========================================================================
 | PRIVATE PROCEDURE STORE_LAST_PAYMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure stores last payment number and last amortization id in lns_loan_headers_all
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_LOAN_ID       IN      Loan ID
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
 | 02-11-2005            scherkas          Created
 |
 *=======================================================================*/
Procedure STORE_LAST_PAYMENT_NUMBER(P_LOAN_ID IN NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'STORE_LAST_PAYMENT_NUMBER';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_version_number                number;
    l_loan_id                       number;
    l_Count                         number;
    l_loan_number                   varchar2(60);
    l_last_payment_number           number;
    l_amortization_id               number;
    l_old_last_payment_number       number;
    l_old_amortization_id           number;
    l_current_phase                 varchar2(30);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
    CURSOR loan_ver_cur(P_LOAN_ID NUMBER) IS
        select
        head.OBJECT_VERSION_NUMBER,
        head.loan_id,
        head.loan_number,
        head.LAST_PAYMENT_NUMBER,
        head.LAST_AMORTIZATION_ID,
        nvl(head.CURRENT_PHASE, 'TERM')
        from
        LNS_LOAN_HEADERS head
        where
        head.loan_id = P_LOAN_ID;

    CURSOR pay_number_cur(P_LOAN_ID NUMBER, P_PHASE VARCHAR2) IS
        select max(PAYMENT_NUMBER)
        from LNS_AMORTIZATION_SCHEDS
        where LOAN_ID = P_LOAN_ID
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and REAMORTIZATION_AMOUNT is null
        and nvl(PHASE, 'TERM') = nvl(P_PHASE, 'TERM');

    CURSOR amortization_cur(P_LOAN_ID NUMBER, P_PHASE VARCHAR2) IS
        select max(AMORTIZATION_SCHEDULE_ID)
        from LNS_AMORTIZATION_SCHEDS
        where LOAN_ID = P_LOAN_ID
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and nvl(PHASE, 'TERM') = nvl(P_PHASE, 'TERM')
        and PAYMENT_NUMBER =
            nvl((select max(PAYMENT_NUMBER)
            from LNS_AMORTIZATION_SCHEDS
            where LOAN_ID = P_LOAN_ID
            and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
            and REAMORTIZATION_AMOUNT is null
            and nvl(PHASE, 'TERM') = nvl(P_PHASE, 'TERM')), 0);
BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    open loan_ver_cur(P_LOAN_ID);
    fetch loan_ver_cur into
        l_version_number,
        l_loan_id,
        l_loan_number,
        l_old_last_payment_number,
        l_old_amortization_id,
        l_current_phase;
    close loan_ver_cur;

    open pay_number_cur(P_LOAN_ID, l_current_phase);
    fetch pay_number_cur into l_last_payment_number;
    close pay_number_cur;

    open amortization_cur(P_LOAN_ID, l_current_phase);
    fetch amortization_cur into l_amortization_id;
    close amortization_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Old LAST_PAYMENT_NUMBER: ' || l_old_last_payment_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'New LAST_PAYMENT_NUMBER: ' || l_last_payment_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Old LAST_AMORTIZATION_ID: ' || l_old_amortization_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'New LAST_AMORTIZATION_ID: ' || l_amortization_id);

    /* updating loan header table */
    l_loan_header_rec.loan_id := l_loan_id;

    if l_last_payment_number is null then
        l_loan_header_rec.LAST_PAYMENT_NUMBER := FND_API.G_MISS_NUM;
    else
        l_loan_header_rec.LAST_PAYMENT_NUMBER := l_last_payment_number;
    end if;

    if l_amortization_id is null then
        l_loan_header_rec.LAST_AMORTIZATION_ID := FND_API.G_MISS_NUM;
    else
        l_loan_header_rec.LAST_AMORTIZATION_ID := l_amortization_id;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
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

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



/*========================================================================
 | PUBLIC PROCEDURE PROCESS_PAID_LOANS
 |
 | DESCRIPTION
 |      This procedure sets still active paid off loans to status PAIDOFF
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
    P_API_VERSION            IN          NUMBER,
    P_INIT_MSG_LIST          IN          VARCHAR2,
    P_COMMIT                 IN          VARCHAR2,
    P_VALIDATION_LEVEL       IN          NUMBER,
    P_LOAN_ID                IN          NUMBER,
    P_PAYOFF_DATE            IN          DATE,
    X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY  NUMBER,
    X_MSG_DATA               OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PROCESS_PAID_LOANS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_version_number                number;
    l_loan_id                       number;
    l_Count                         number;
    l_loan_number                   varchar2(60);
    l_remaining_amount              number;
    l_end                           date;
    l_start                         date;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query paid off loans that are still active */
    CURSOR paidoff_loans_cur(P_LOAN_ID number) IS
        select
        head.OBJECT_VERSION_NUMBER,
        head.loan_id,
        head.loan_number
        from
        LNS_PAY_SUM_V sum,
        LNS_LOAN_HEADERS head
        where
        head.loan_id = nvl(P_LOAN_ID, head.loan_id) and
        head.loan_id = sum.loan_id and
        head.loan_status in ('ACTIVE', 'DEFAULT', 'DELINQUENT') and
        head.last_payment_number is not null and
        head.last_amortization_id is not null and
        sum.total_principal_balance <= 0 and
        (head.REQUESTED_AMOUNT + head.ADD_REQUESTED_AMOUNT) = head.FUNDED_AMOUNT;

    CURSOR validate_loan_cur(P_LOAN_ID number) IS
        select nvl(sum(total_remaining_amount),0)
        from LNS_AM_SCHEDS_V
        where loan_id = P_LOAN_ID and
              reversed_code = 'N';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Processing paid off loans...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payoff date: ' || P_PAYOFF_DATE);
    -- Standard Start of API savepoint
    SAVEPOINT PROCESS_PAID_LOANS;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- ----------------------------------------------------------------

    /* init variables */
    l_Count := 0;

    l_start := sysdate;
    open paidoff_loans_cur(P_LOAN_ID);

    LOOP

        fetch paidoff_loans_cur into
            l_version_number,
            l_loan_id,
            l_loan_number;
        exit when paidoff_loans_cur%NOTFOUND;

        l_Count := l_Count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing loan ' || l_loan_number || ' id ' || l_loan_id);

        BEGIN

            open validate_loan_cur(l_loan_id);
            fetch validate_loan_cur into l_remaining_amount;
            close validate_loan_cur;

            if l_remaining_amount = 0  then

                LNS_FUNDING_PUB.VALIDATE_DISB_FOR_PAYOFF(
                    P_API_VERSION		    => 1.0,
                    P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                    P_COMMIT			    => FND_API.G_FALSE,
                    P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
                    P_LOAN_ID               => l_loan_id,
                    X_RETURN_STATUS		    => l_return_status,
                    X_MSG_COUNT			    => l_msg_count,
                    X_MSG_DATA	    	    => l_msg_data);

                IF l_return_status <> 'S' THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_fee_assignments...');
                update lns_fee_assignments
                set end_date_active = P_PAYOFF_DATE
                where loan_id = l_loan_id
                and (end_date_active is null OR end_date_active > P_PAYOFF_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'lns_fee_assignments is updated');

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_fee_schedules...');
                update lns_fee_schedules
                set billed_flag = 'Y'
                where loan_id = l_loan_id
                and active_flag = 'Y'
                and billed_flag = 'N'
                and object_version_number = object_version_number + 1;
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'lns_fee_schedules is updated');

                /* updating loan header table */
                l_loan_header_rec.loan_id := l_loan_id;
                l_loan_header_rec.LOAN_STATUS := 'PAIDOFF';
                l_loan_header_rec.SECONDARY_STATUS := FND_API.G_MISS_CHAR;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header info w following values:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_STATUS: ' || l_loan_header_rec.LOAN_STATUS);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Secondary status: ' || l_loan_header_rec.SECONDARY_STATUS);

                LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
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

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully paid off loan ' || l_loan_number || ' id ' || l_loan_id);

            else

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Cannot pay off loan ' || l_loan_number || '. Outstanding interest and fees amount = ' || l_remaining_amount);

            end if;

        EXCEPTION
            WHEN OTHERS THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to process loan ' || l_loan_number);
        END;

    END LOOP;

    close paidoff_loans_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || l_Count || ' loan(s)');
    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Process Paid Loans Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO PROCESS_PAID_LOANS;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, sqlerrm);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO PROCESS_PAID_LOANS;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, sqlerrm);

        WHEN OTHERS THEN
             ROLLBACK TO PROCESS_PAID_LOANS;
             x_return_status := FND_API.G_RET_STS_ERROR;
             logMessage(FND_LOG.LEVEL_ERROR, sqlerrm);

END;




/*========================================================================
 | PRIVATE PROCEDURE REACTIVATE_PAID_LOANS
 |
 | DESCRIPTION
 |      This procedure sets still active paid off loans to status PAIDOFF
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      None
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
PROCEDURE REACTIVATE_PAID_LOANS(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'REACTIVATE_PAID_LOANS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_version_number                number;
    l_loan_id                       number;
    l_Count                         number;
    l_loan_number                   varchar2(60);
    l_end                           date;
    l_start                         date;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query paid off loans that must be reactivated */
    CURSOR paidoff_loans_cur IS
        select
        head.OBJECT_VERSION_NUMBER,
        head.loan_id,
        head.loan_number
        from
        LNS_LOAN_HEADERS head
        where
        head.loan_status = 'PAIDOFF' and
            ((select nvl(sum(total_remaining_amount),0)
            from LNS_AM_SCHEDS_V
            where loan_id = head.loan_id and
                reversed_code = 'N') > 0);

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reactivating paid off loans...');

    /* init variables */
    l_Count := 0;

    l_start := sysdate;
    open paidoff_loans_cur;

    LOOP

        fetch paidoff_loans_cur into
            l_version_number,
            l_loan_id,
            l_loan_number;
        exit when paidoff_loans_cur%NOTFOUND;

        l_Count := l_Count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ' || l_loan_number || ' id ' || l_loan_id);

        BEGIN
            /* updating loan header table */
            l_loan_header_rec.loan_id := l_loan_id;
            l_loan_header_rec.LOAN_STATUS := 'ACTIVE';

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header info w following values:');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_STATUS: ' || l_loan_header_rec.LOAN_STATUS);

            LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
                                            P_LOAN_HEADER_REC => l_loan_header_rec,
                                            P_INIT_MSG_LIST => FND_API.G_FALSE,
                                            X_RETURN_STATUS => l_return_status,
                                            X_MSG_COUNT => l_msg_count,
                                            X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated LNS_LOAN_HEADERS_ALL');
            ELSE
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            if P_COMMIT = FND_API.G_TRUE then
                COMMIT WORK;
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
            end if;

            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully reactivated loan ' || l_loan_number || ' id ' || l_loan_id);

        EXCEPTION
            WHEN OTHERS THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to process loan ' || l_loan_number);
        END;

    END LOOP;

    close paidoff_loans_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || l_Count || ' loan(s)');
    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reactivate Loans Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to reactivate paid off loans');

END;




/*========================================================================
 | PRIVATE PROCEDURE GET_RECEIVABLES_FUND_DESC
 |
 | DESCRIPTION
 |      This procedure gets receivable fund description for appending to AR line description
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      None
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
FUNCTION GET_RECEIVABLES_FUND_DESC(P_CC_ID number) RETURN VARCHAR2
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_RECEIVABLES_FUND_DESC';
    l_description                   varchar2(240);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query receivable fund description */
    CURSOR rec_fund_desc_cur(P_ORG_ID number, P_CC_ID number) IS
        SELECT
            FVL.DESCRIPTION
        FROM LNS_SYSTEM_OPTIONS LSO
            ,gl_sets_of_books SB
            ,FND_ID_FLEX_STRUCTURES_VL STR
            ,FND_ID_FLEX_SEGMENTS_VL SEG
            ,fnd_flex_value_sets FVS
            ,FND_FLEX_VALUES_VL FVL
            ,FND_SEGMENT_ATTRIBUTE_VALUES SAV
            ,GL_CODE_COMBINATIONS GL
        WHERE STR.APPLICATION_ID = 101  -- GENERAL LEDGER
        and lso.set_of_books_id = sb.set_of_books_id
        and sb.chart_of_accounts_id = STR.id_flex_num
        and gl.chart_of_accounts_id = sb.chart_of_accounts_id
        and SEG.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
        and FVS.FLEX_VALUE_SET_ID = FVL.FLEX_VALUE_SET_ID
        and str.id_flex_num = SEG.ID_FLEX_NUM
        and STR.id_flex_num = sav.id_flex_num
        and STR.ID_FLEX_CODE='GL#'
        and seg.id_flex_code ='GL#'
        and STR.enabled_flag = 'Y'
        and LSO.org_id = P_ORG_ID
        and gl.code_combination_id = P_CC_ID
        and fvl.flex_value = (decode(sav.application_column_name,
            'SEGMENT1', GL.segment1,
            'SEGMENT2', GL.segment2,
            'SEGMENT3', GL.segment3,
            'SEGMENT4', GL.segment4,
            'SEGMENT5', GL.segment5))
        and (('' IS NULL) OR (structured_hierarchy_level IN
                                            (SELECT h.hierarchy_id
                                                FROM fnd_flex_hierarchies_vl h
                                            WHERE h.flex_value_set_id = FVL.flex_value_set_id
                                                AND h.hierarchy_name like '')))
        and exists
        ( SELECT 1
        FROM FND_SEGMENT_ATTRIBUTE_TYPES T
        WHERE T.APPLICATION_ID = SAV.APPLICATION_ID
            AND T.ID_FLEX_CODE = SAV.ID_FLEX_CODE
            AND T.SEGMENT_ATTRIBUTE_TYPE = SAV.SEGMENT_ATTRIBUTE_TYPE
            AND GLOBAL_FLAG = 'N'
            and SAV.ID_FLEX_CODE='GL#'
            and SAV.APPLICATION_ID=101
            and sav.segment_attribute_type = 'GL_BALANCING'
            and attribute_value = 'Y'
        );


BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    l_description := null;

    open rec_fund_desc_cur(g_org_id, P_CC_ID);
    fetch rec_fund_desc_cur into l_description;
    close rec_fund_desc_cur;

    if l_description is not null then
        l_description := ' - ' || l_description;
    end if;

    return l_description;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed to get receivable fund description');
        return l_description;

END;




/*========================================================================
 | PRIVATE PROCEDURE CREATE_AR_INVOICES
 |
 | DESCRIPTION
 |      This procedure creates AR invoices.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      BILL_SINGLE_LOAN
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_LOAN_REC  IN OUT NOCOPY   Loan record
 |      P_LINES_TBL  IN OUT NOCOPY  Lines table
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
 | 03-31-2006            karamach          Revert the billing_date = due_date change in trx header since invoice api throws AR_TAPI_BFB_BILLING_DATE_INV error if billing_date is passed when bfb is disabled based on ar_bfb_utils_pvt.is_valid_billing_date
 | 03-28-2006            karamach          Pass the taxable_flag 'N' in trx line and billing_date = due_date in trx header for bug5124908
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_AR_INVOICES(P_LOAN_REC  IN OUT NOCOPY  LNS_BILLING_BATCH_PUB.LOAN_TO_BILL_REC,
                             P_LINES_TBL  IN OUT NOCOPY  LNS_BILLING_BATCH_PUB.BILL_LINES_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_AR_INVOICES';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count1                        number;
    l_Count2                        number;
    l_Count3                        number;
    l_Count4                        number;
    l_Count5                        number;
    l_Count6                        number;
    l_customer_trx_id               number;
    l_trx_number                    VARCHAR2(20);
    l_customer_trx_line_id          number;
    l_payment_schedule_id           number;
    l_due_date                      date;
    l_batch_id                      number;
    l_line_type                     varchar2(30);
    l_amount                        number;
    l_id                            number;
    l_next_line                     varchar2(5);
    l_generate_trx_number           varchar2(1);
    l_COPY_DOC_NUMBER_FLAG          varchar2(1);
    l_AUTO_TRX_NUMBERING_FLAG       varchar2(1);
    l_search_str                    varchar2(1);
    l_exit_loop                     varchar2(1);
	l_start_pos		                number;
	l_end_pos		                number;
    l_populate_dist                 varchar2(1);
    l_cc_id                         number;
    l_percent                       number;
    l_payment_order                 number;
    l_trx_header_id                 number;
    l_trx_line_id                   number;
    l_error_message                 varchar2(2000);
    l_invalid_value                 varchar2(2000);
    l_principal_trx_id              number;
    l_interest_trx_id               number;
    l_fee_trx_id                    number;
    l_prin_trx_type                 number;
    l_USSGL_TRANSACTION_CODE        VARCHAR2(30);
    l_line_desc                     VARCHAR2(240);
    l_orig_line_amount              number;
    l_split_flag                    varchar2(1);
    l_running_sum                   number;
    l_ar_error_counter              number;
    l_fee_header                    number;
    l_fee_line_num                  number;
    l_site_use_id                   number;
    l_amortization_line_id          number;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_org_status                    varchar2(1);
    l_org_id                        number;
    l_start                         date;
    l_end                           date;
    l_phase                         varchar2(10);
    l_int_header                    number;
    l_int_line_num                  number;
    l_bill_0_prin_inv               varchar2(1);

    l_batch_source_rec        ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl             ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl                ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_dist_tbl                  ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl      ar_invoice_api_pub.trx_salescredits_tbl_type;
    l_new_lines_tbl              LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;
    l_is_disable_bill		varchar2(1);
    l_feeRec_exists		varchar2(1);
    l_disb_hdr_id			NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query of batch source attributes */
    CURSOR gen_trx_num_cur(P_SOURCE_ID number) IS
        select COPY_DOC_NUMBER_FLAG,
               AUTO_TRX_NUMBERING_FLAG
        FROM RA_BATCH_SOURCES
        where BATCH_SOURCE_ID = P_SOURCE_ID;

    /* generate new trx number */
    CURSOR new_trx_num_cur IS
        select LNS_TRX_NUMBER_S.NEXTVAL
        from dual;

    /* query of meaning of PAYMENT_APPLICATION_TYPE */
    CURSOR meaning_cur(P_LOOKUP_CODE varchar2) IS
        select meaning
        from LNS_LOOKUPS
        where lookup_type = 'PAYMENT_APPLICATION_TYPE' and
              lookup_code = P_LOOKUP_CODE;

    /* query of distributions for principal dr */
    CURSOR prin_dr_dist_cur(P_LOAN_ID number) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'DR' and
            account_name = 'PRINCIPAL_RECEIVABLE' and
            line_type = 'PRIN';

    /* query of distributions for interest dr */
    CURSOR int_dr_dist_cur(P_LOAN_ID number) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'DR' and
            account_name = 'INTEREST_RECEIVABLE' and
            line_type = 'INT';

    /* query of distributions for fee dr */
    CURSOR cur_fee_dr_dist(c_loan_id NUMBER, c_fee_id NUMBER, c_disb_hdr_id NUMBER) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = c_loan_id and
	    fee_id = c_fee_id and
	    -- The below code criteria retrieves though the disb_header_id is null for fees, which are not disbFees
	    nvl(disb_header_id, -1) = nvl(c_disb_hdr_id, -1) and
            account_type = 'DR' and
            account_name = 'FEE_RECEIVABLE' and
            line_type = 'FEE';

     /* query of distributions for fee dr  based on loan
         This is used for existed disbFees(before fix bug#9054623), wihch doesn't contain FEE_RECEIVABLE for all fees.
	 These existed disbFees contains one FEE_RECEIVABLE a/c for all fees per loan  		*/
    CURSOR fee_dr_dist_cur(P_LOAN_ID number) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'DR' and
            account_name = 'FEE_RECEIVABLE' and
            line_type = 'FEE';

    /* query of distributions for principal cr */
    CURSOR prin_cr_dist_cur(P_LOAN_ID number, P_DATE date) IS
        select dist.CODE_COMBINATION_ID,
                sum(dist.DISTRIBUTION_PERCENT),
                dist.USSGL_TRANSACTION_CODE
        from lns_distributions dist
        where dist.LOAN_ID = P_LOAN_ID and
            dist.account_type = 'CR' and
            dist.account_name = 'LOAN_RECEIVABLE' and
            dist.line_type = 'PRIN' and
            nvl(dist.loan_line_id, -1) =
                nvl((select max(loan_line_id)
                from lns_loan_lines
                where status = 'APPROVED'
                and LOAN_ID = P_LOAN_ID
                and original_flag = 'N'
                and adjustment_date <= P_DATE), -1)
        group by dist.CODE_COMBINATION_ID, dist.USSGL_TRANSACTION_CODE;

    /* query of distributions for interest cr */
    CURSOR int_cr_dist_cur(P_LOAN_ID number) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'CR' and
            account_name = 'INTEREST_INCOME' and
            line_type = 'INT';

    /* query of distributions for fee cr */
    CURSOR fee_cr_dist_cur(P_LOAN_ID number, P_FEE_ID number, C_DISB_HDR_ID number) IS
        select CODE_COMBINATION_ID,
                DISTRIBUTION_PERCENT,
                USSGL_TRANSACTION_CODE
        from lns_distributions
        where LOAN_ID = P_LOAN_ID and
            account_type = 'CR' and
            account_name = 'FEE_INCOME' and
            line_type = 'FEE' and
            fee_id = P_FEE_ID and
	    nvl(disb_header_id, -1) = nvl(C_DISB_HDR_ID, -1);

    /* query of AR errors */
    CURSOR ar_invoice_err_cur IS
        SELECT trx_header_id, trx_line_id, error_message, invalid_value
        from ar_trx_errors_gt;

    /* query invoice details */
    CURSOR ar_invoices_cur(P_BATCH_ID number) IS
        select
            trx.customer_trx_id,
            trx.trx_number,
            lines.customer_trx_line_id,
            psa.payment_schedule_id,
            psa.due_date,
            lines.extended_amount,
            lines.INTERFACE_LINE_ATTRIBUTE5,
            lines.INTERFACE_LINE_ATTRIBUTE6
        from RA_CUSTOMER_TRX trx,
            RA_CUSTOMER_TRX_LINES lines,
            ar_payment_schedules_all psa
        where
            trx.batch_id = P_BATCH_ID
            and trx.customer_trx_id = lines.customer_trx_id
            and trx.customer_trx_id = psa.customer_trx_id(+)    -- outer join is for case when invoice is created incomplete
            and lines.line_type = 'LINE'
        ORDER BY lines.customer_trx_line_id;

    /* query trx_type_id */
    CURSOR trx_type_cur(P_LOAN_ID number) IS
        select REFERENCE_TYPE_ID
        from LNS_LOAN_HEADERS
        where loan_id = P_LOAN_ID;

    /* query for site_use_id */
    CURSOR site_use_id_cur(P_SITE_ID number) IS
        select site_use_id
        from hz_cust_site_uses
        where cust_acct_site_id = P_SITE_ID
        and site_use_code = 'BILL_TO'
        and status = 'A';

   CURSOR cur_get_disbHdr_id(c_fee_schd_id number) IS
       SELECT disb_header_id
       from lns_fee_schedules
       where fee_schedule_id =c_fee_schd_id;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Checking the Disable_billing_flag in '||l_api_name);
    l_is_disable_bill := IS_BILLING_DISABLED(P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_is_disable_bill is '||l_is_disable_bill);
    IF l_is_disable_bill = 'Y' THEN
    	    --  LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: BILLING is Disabled for the loan '||p_loan_rec.loan_number);
             FND_MESSAGE.SET_NAME('LNS', 'LNS_BILLING_DISABLED');
	     FND_MESSAGE.SET_TOKEN('LOAN_NUMBER', p_loan_rec.loan_number);
             FND_MSG_PUB.Add;
             LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
             RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Preparing to call AR invoice api...');


    /* init variables */
    l_generate_trx_number  := 'Y';
    l_COPY_DOC_NUMBER_FLAG := 'N';
    l_AUTO_TRX_NUMBERING_FLAG := 'N';
    l_search_str := '_';
	l_start_pos := 1;
	l_end_pos := 1;

    l_batch_source_rec.batch_source_id := g_batch_source_id;

    /* check if we need to generate trx_number */
    open gen_trx_num_cur(l_batch_source_rec.batch_source_id);
    fetch gen_trx_num_cur into l_COPY_DOC_NUMBER_FLAG, l_AUTO_TRX_NUMBERING_FLAG;
    close gen_trx_num_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_COPY_DOC_NUMBER_FLAG: ' || l_COPY_DOC_NUMBER_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_AUTO_TRX_NUMBERING_FLAG: ' || l_AUTO_TRX_NUMBERING_FLAG);

    if l_COPY_DOC_NUMBER_FLAG = 'Y' or l_AUTO_TRX_NUMBERING_FLAG = 'Y' then
        l_generate_trx_number := 'N';
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_generate_trx_number: ' || l_generate_trx_number);

    /* query trx_type_id */
    open trx_type_cur(P_LOAN_REC.LOAN_ID);
    fetch trx_type_cur into l_prin_trx_type;
    close trx_type_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'prin_trx_type: ' || l_prin_trx_type);

    /* query for site_use_id */
    open site_use_id_cur(P_LOAN_REC.BILL_TO_ADDRESS_ID);
    fetch site_use_id_cur into l_site_use_id;
    close site_use_id_cur;

    /* check exchange rate: if its User - pass exchange rate; otherwise - pass null */
    if P_LOAN_REC.EXCHANGE_RATE_TYPE is null or
       (P_LOAN_REC.EXCHANGE_RATE_TYPE is not null and P_LOAN_REC.EXCHANGE_RATE_TYPE <> 'User') then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Setting exchange rate = null');
        P_LOAN_REC.EXCHANGE_RATE := null;

    end if;

    -- setting phase for invoice reference
    if P_LOAN_REC.CURRENT_PHASE = 'OPEN' then
        l_phase := 'Disb';
    else
        l_phase := 'Term';
    end if;

    -- fix for bug 5840180: get LNS_CREATE_ZERO_PRIN_INV profile value to see if we need to bill 0 amount principal invoices
    l_bill_0_prin_inv := NVL(FND_PROFILE.VALUE('LNS_CREATE_ZERO_PRIN_INV'), 'N');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'The profile LNS_CREATE_ZERO_PRIN_INV value is : '||l_bill_0_prin_inv);

    l_Count1 := 0;  -- lines counter
    l_Count2 := 0;  -- distributions counter
    l_Count3 := 0;  -- header counter
    l_Count6 := 0;  -- returned lines table
    l_fee_header := -1;
    l_int_header := -1;
    l_exit_loop := 'N';
    l_end_pos := instr(P_LOAN_REC.PAYMENT_APPLICATION_ORDER, l_search_str, l_start_pos, 1);

	while true loop

		if l_end_pos <> 0 then
			l_next_line := substr(P_LOAN_REC.PAYMENT_APPLICATION_ORDER, l_start_pos, l_end_pos-l_start_pos);
		else
			l_next_line := substr(P_LOAN_REC.PAYMENT_APPLICATION_ORDER, l_start_pos,
                                  LENGTH(P_LOAN_REC.PAYMENT_APPLICATION_ORDER)-l_start_pos+1);
			l_exit_loop := 'Y';
		end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_next_line: ' || l_next_line);

        FOR l_Count4 IN 1..P_LINES_TBL.COUNT LOOP

            if P_LINES_TBL(l_Count4).LINE_TYPE = l_next_line and
               P_LINES_TBL(l_Count4).LINE_AMOUNT is not null and
               P_LINES_TBL(l_Count4).PAYMENT_ORDER is null and
	       (P_LINES_TBL(l_Count4).LINE_AMOUNT > 0 or
               (P_LINES_TBL(l_Count4).LINE_AMOUNT = 0 and P_LINES_TBL(l_Count4).LINE_TYPE = 'PRIN' and l_bill_0_prin_inv = 'Y')) --fix for bug 5840180

            then

                l_Count1 := l_Count1 + 1;   -- lines

                if ((g_multiple_lines = 'Y' and l_Count3 = 0) or
--                   (g_multiple_lines = 'N' and (l_next_line = 'PRIN' or l_next_line = 'INT')) or
                   (g_multiple_lines = 'N' and l_next_line = 'PRIN') or
                   (g_multiple_lines = 'N' and l_next_line = 'INT' and l_int_header = -1) or
                   (g_multiple_lines = 'N' and l_next_line = 'FEE' and l_fee_header = -1))
                then
                    l_Count3 := l_Count3 + 1;   -- header
                end if;

                /* populate line description */
                open meaning_cur(l_next_line);
                fetch meaning_cur into l_line_desc;
                close meaning_cur;

                if P_LINES_TBL(l_Count4).LINE_DESC is not null then
                    l_trx_lines_tbl(l_Count1).description := l_line_desc || ' - ' || P_LINES_TBL(l_Count4).LINE_DESC;
                else
                    l_trx_lines_tbl(l_Count1).description := l_line_desc;
                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line ' || l_Count1 || ' - ' || l_trx_lines_tbl(l_Count1).description);

                if g_multiple_lines = 'Y' then

                    if l_Count3 = 1 then

                        if l_generate_trx_number = 'Y' then
/*
                            -- generate new id for new AR invoice_number
                            open new_trx_num_cur;
                            fetch new_trx_num_cur into l_id;
                            close new_trx_num_cur;

                            l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER || '-' || l_id;
*/
                            l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER;

                        end if;

                        /* populate header info */
                        l_trx_header_tbl(l_Count3).comments := P_LOAN_REC.LOAN_DESCRIPTION;
                        l_trx_header_tbl(l_Count3).trx_header_id := 100 + l_Count3;
                        l_trx_header_tbl(l_Count3).trx_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE;
                        --l_trx_header_tbl(l_Count3).billing_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE; --karamach bug5124908
                        l_trx_header_tbl(l_Count3).gl_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE + g_day_togl_after_dd;
                        l_trx_header_tbl(l_Count3).trx_currency := P_LOAN_REC.LOAN_CURRENCY;
                        l_trx_header_tbl(l_Count3).exchange_rate_type := P_LOAN_REC.EXCHANGE_RATE_TYPE;
                        l_trx_header_tbl(l_Count3).exchange_date := P_LOAN_REC.EXCHANGE_DATE;
                        l_trx_header_tbl(l_Count3).exchange_rate := P_LOAN_REC.EXCHANGE_RATE;
                        l_trx_header_tbl(l_Count3).cust_trx_type_id := nvl(l_prin_trx_type, g_trx_type_id);
                        l_trx_header_tbl(l_Count3).bill_to_customer_id := P_LOAN_REC.CUST_ACCOUNT_ID;
                        l_trx_header_tbl(l_Count3).bill_to_address_id := P_LOAN_REC.BILL_TO_ADDRESS_ID;
                        l_trx_header_tbl(l_Count3).bill_to_site_use_id := l_site_use_id;
                        l_trx_header_tbl(l_Count3).term_id := 5; --always IMMEDIATE
                        l_trx_header_tbl(l_Count3).finance_charges := 'N';
                        l_trx_header_tbl(l_Count3).status_trx := 'OP';
                        l_trx_header_tbl(l_Count3).printing_option := null;  -- fix for bug 7714411
                        l_trx_header_tbl(l_Count3).interface_header_attribute1 :=
                            l_phase || ':Pay#' || P_LOAN_REC.NEXT_PAYMENT_NUMBER;
                        l_trx_header_tbl(l_Count3).org_id := P_LOAN_REC.ORG_ID;
                        l_trx_header_tbl(l_Count3).legal_entity_id := P_LOAN_REC.LEGAL_ENTITY_ID;

                        if P_LOAN_REC.PARENT_AMORTIZATION_ID is not null then
                            l_trx_header_tbl(l_Count3).interface_header_attribute1 := l_trx_header_tbl(l_Count3).interface_header_attribute1 || '(M)';
                        end if;

                    end if;

                    l_trx_lines_tbl(l_Count1).line_number := l_Count1;
                    l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(1).trx_header_id;

                else

--                    if l_next_line = 'PRIN' or l_next_line = 'INT' then
                    if l_next_line = 'PRIN' then

                        if l_generate_trx_number = 'Y' then
    /*
                            -- generate new id for new AR invoice_number
                            open new_trx_num_cur;
                            fetch new_trx_num_cur into l_id;
                            close new_trx_num_cur;

                            l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER || '-' || l_id;
    */
                            l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER;

                        end if;

                        /* populate rest of header info */
                        l_trx_header_tbl(l_Count3).comments := P_LOAN_REC.LOAN_DESCRIPTION;
                        l_trx_header_tbl(l_Count3).trx_header_id := 100 + l_Count3;
                        l_trx_header_tbl(l_Count3).trx_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE;
                        --l_trx_header_tbl(l_Count3).billing_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE; --karamach bug5124908
                        l_trx_header_tbl(l_Count3).gl_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE + g_day_togl_after_dd;
                        l_trx_header_tbl(l_Count3).trx_currency := P_LOAN_REC.LOAN_CURRENCY;
                        l_trx_header_tbl(l_Count3).exchange_rate_type := P_LOAN_REC.EXCHANGE_RATE_TYPE;
                        l_trx_header_tbl(l_Count3).exchange_date := P_LOAN_REC.EXCHANGE_DATE;
                        l_trx_header_tbl(l_Count3).exchange_rate := P_LOAN_REC.EXCHANGE_RATE;
                        l_trx_header_tbl(l_Count3).bill_to_customer_id := P_LOAN_REC.CUST_ACCOUNT_ID;
                        l_trx_header_tbl(l_Count3).bill_to_address_id := P_LOAN_REC.BILL_TO_ADDRESS_ID;
                        l_trx_header_tbl(l_Count3).bill_to_site_use_id := l_site_use_id;
                        l_trx_header_tbl(l_Count3).term_id := 5; --always IMMEDIATE
                        l_trx_header_tbl(l_Count3).finance_charges := 'N';
                        l_trx_header_tbl(l_Count3).status_trx := 'OP';
                        l_trx_header_tbl(l_Count3).printing_option := null;  -- fix for bug 7714411
                        l_trx_header_tbl(l_Count3).interface_header_attribute1 :=
                            l_phase || ':Pay#' || P_LOAN_REC.NEXT_PAYMENT_NUMBER || ' ' || l_line_desc;
                        l_trx_header_tbl(l_Count3).org_id := P_LOAN_REC.ORG_ID;
                        l_trx_header_tbl(l_Count3).legal_entity_id := P_LOAN_REC.LEGAL_ENTITY_ID;

                        if P_LOAN_REC.PARENT_AMORTIZATION_ID is not null then
                            l_trx_header_tbl(l_Count3).interface_header_attribute1 := l_trx_header_tbl(l_Count3).interface_header_attribute1 || '(M)';
                        end if;

                        -- set trx_type_id
                        l_trx_header_tbl(l_Count3).cust_trx_type_id := nvl(l_prin_trx_type, g_trx_type_id);
                        l_trx_lines_tbl(l_Count1).line_number := 1;
                        l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;

                    elsif l_next_line = 'INT' then

                        if l_int_header = -1 then

                            if l_generate_trx_number = 'Y' then
        /*
                                -- generate new id for new AR invoice_number
                                open new_trx_num_cur;
                                fetch new_trx_num_cur into l_id;
                                close new_trx_num_cur;

                                l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER || '-' || l_id;
        */
                                l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER;

                            end if;

                            /* populate rest of header info */
                            l_trx_header_tbl(l_Count3).comments := P_LOAN_REC.LOAN_DESCRIPTION;
                            l_trx_header_tbl(l_Count3).trx_header_id := 100 + l_Count3;
                            l_trx_header_tbl(l_Count3).trx_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE;
                            l_trx_header_tbl(l_Count3).gl_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE + g_day_togl_after_dd;
                            l_trx_header_tbl(l_Count3).trx_currency := P_LOAN_REC.LOAN_CURRENCY;
                            l_trx_header_tbl(l_Count3).exchange_rate_type := P_LOAN_REC.EXCHANGE_RATE_TYPE;
                            l_trx_header_tbl(l_Count3).exchange_date := P_LOAN_REC.EXCHANGE_DATE;
                            l_trx_header_tbl(l_Count3).exchange_rate := P_LOAN_REC.EXCHANGE_RATE;
                            l_trx_header_tbl(l_Count3).bill_to_customer_id := P_LOAN_REC.CUST_ACCOUNT_ID;
                            l_trx_header_tbl(l_Count3).bill_to_address_id := P_LOAN_REC.BILL_TO_ADDRESS_ID;
                            l_trx_header_tbl(l_Count3).bill_to_site_use_id := l_site_use_id;
                            l_trx_header_tbl(l_Count3).term_id := 5; --always IMMEDIATE
                            l_trx_header_tbl(l_Count3).finance_charges := 'N';
                            l_trx_header_tbl(l_Count3).status_trx := 'OP';
                            l_trx_header_tbl(l_Count3).printing_option := null;  -- fix for bug 7714411
                            l_trx_header_tbl(l_Count3).interface_header_attribute1 :=
                                l_phase || ':Pay#' || P_LOAN_REC.NEXT_PAYMENT_NUMBER || ' ' || l_line_desc;
                            l_trx_header_tbl(l_Count3).org_id := P_LOAN_REC.ORG_ID;
                            l_trx_header_tbl(l_Count3).legal_entity_id := P_LOAN_REC.LEGAL_ENTITY_ID;

                            if P_LOAN_REC.PARENT_AMORTIZATION_ID is not null then
                                l_trx_header_tbl(l_Count3).interface_header_attribute1 := l_trx_header_tbl(l_Count3).interface_header_attribute1 || '(M)';
                            end if;

                            /* set trx_type_id */

                            if g_int_trx_type_id is null then

    --                            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Interest transaction type is not set.');
                                FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_INT_TRX_TYPE_IN_SYS_OPT');
                                FND_MSG_PUB.Add;
                                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                                RAISE FND_API.G_EXC_ERROR;

                            end if;

                            l_trx_header_tbl(l_Count3).cust_trx_type_id := g_int_trx_type_id;
                            l_int_line_num := 1;
                            l_trx_lines_tbl(l_Count1).line_number := l_int_line_num;
                            l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;

                        else

                            l_int_line_num := l_int_line_num + 1;
                            l_trx_lines_tbl(l_Count1).line_number := l_int_line_num;
                            l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_int_header).trx_header_id;

                        end if;

                    elsif l_next_line = 'FEE' then

                        if l_fee_header = -1 then

                            if l_generate_trx_number = 'Y' then
        /*
                                -- generate new id for new AR invoice_number
                                open new_trx_num_cur;
                                fetch new_trx_num_cur into l_id;
                                close new_trx_num_cur;

                                l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER || '-' || l_id;
        */
                                l_trx_header_tbl(l_Count3).trx_number := P_LOAN_REC.LOAN_NUMBER;

                            end if;

                            /* populate rest of header info */
                            l_trx_header_tbl(l_Count3).comments := P_LOAN_REC.LOAN_DESCRIPTION;
                            l_trx_header_tbl(l_Count3).trx_header_id := 100 + l_Count3;
                            l_trx_header_tbl(l_Count3).trx_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE;
                            --l_trx_header_tbl(l_Count3).billing_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE; --karamach bug5124908
                            l_trx_header_tbl(l_Count3).gl_date := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE + g_day_togl_after_dd;
                            l_trx_header_tbl(l_Count3).trx_currency := P_LOAN_REC.LOAN_CURRENCY;
                            l_trx_header_tbl(l_Count3).exchange_rate_type := P_LOAN_REC.EXCHANGE_RATE_TYPE;
                            l_trx_header_tbl(l_Count3).exchange_date := P_LOAN_REC.EXCHANGE_DATE;
                            l_trx_header_tbl(l_Count3).exchange_rate := P_LOAN_REC.EXCHANGE_RATE;
                            l_trx_header_tbl(l_Count3).bill_to_customer_id := P_LOAN_REC.CUST_ACCOUNT_ID;
                            l_trx_header_tbl(l_Count3).bill_to_address_id := P_LOAN_REC.BILL_TO_ADDRESS_ID;
                            l_trx_header_tbl(l_Count3).bill_to_site_use_id := l_site_use_id;
                            l_trx_header_tbl(l_Count3).term_id := 5; --always IMMEDIATE
                            l_trx_header_tbl(l_Count3).finance_charges := 'N';
                            l_trx_header_tbl(l_Count3).status_trx := 'OP';
                            l_trx_header_tbl(l_Count3).printing_option := null;  -- fix for bug 7714411
                            l_trx_header_tbl(l_Count3).interface_header_attribute1 :=
                                l_phase || ':Pay#' || P_LOAN_REC.NEXT_PAYMENT_NUMBER || ' ' || l_line_desc;
                            l_trx_header_tbl(l_Count3).org_id := P_LOAN_REC.ORG_ID;
                            l_trx_header_tbl(l_Count3).legal_entity_id := P_LOAN_REC.LEGAL_ENTITY_ID;

                            if P_LOAN_REC.PARENT_AMORTIZATION_ID is not null then
                                l_trx_header_tbl(l_Count3).interface_header_attribute1 := l_trx_header_tbl(l_Count3).interface_header_attribute1 || '(M)';
                            end if;

                            /* set trx_type_id */
                            if g_fee_trx_type_id is null then

    --                            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Fee transaction type is not set.');
                                FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_FEE_TRX_TYPE_IN_SYS_OPT');
                                FND_MSG_PUB.Add;
                                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                                RAISE FND_API.G_EXC_ERROR;

                            end if;

                            l_trx_header_tbl(l_Count3).cust_trx_type_id := g_fee_trx_type_id;
                            l_fee_line_num := 1;
                            l_trx_lines_tbl(l_Count1).line_number := l_fee_line_num;
                            l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;

                        else

                            l_fee_line_num := l_fee_line_num + 1;
                            l_trx_lines_tbl(l_Count1).line_number := l_fee_line_num;
                            l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_fee_header).trx_header_id;

                        end if;

                    end if;

                end if;

                /* populate rest of line info */

                l_trx_lines_tbl(l_Count1).trx_line_id := 100 + l_Count1;
                l_trx_lines_tbl(l_Count1).taxable_flag := 'N'; --karamach bug5124908
                l_trx_lines_tbl(l_Count1).quantity_invoiced := 1;
                l_trx_lines_tbl(l_Count1).line_type := 'LINE';
                l_trx_lines_tbl(l_Count1).unit_selling_price := P_LINES_TBL(l_Count4).LINE_AMOUNT;
                l_trx_lines_tbl(l_Count1).interface_line_context := 'LOANS';
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE1 := P_LOAN_REC.LOAN_ID;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE2 := P_LOAN_REC.NEXT_AMORTIZATION_ID;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE3 := P_LOAN_REC.NEXT_PAYMENT_NUMBER;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE4 := P_LOAN_REC.LOAN_NUMBER;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE5 := l_next_line;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6 := l_Count1;
                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE7 := P_LOAN_REC.PARENT_AMORTIZATION_ID;

                /* populate new return lines table */
                l_Count6 := l_Count6 +1;
                l_new_lines_tbl(l_Count6).HEADER_ID := P_LINES_TBL(l_Count4).HEADER_ID;
                l_new_lines_tbl(l_Count6).LINE_ID := P_LINES_TBL(l_Count4).LINE_ID;
                l_new_lines_tbl(l_Count6).LINE_REF_ID := P_LINES_TBL(l_Count4).LINE_REF_ID;
                l_new_lines_tbl(l_Count6).LINE_AMOUNT := P_LINES_TBL(l_Count4).LINE_AMOUNT;
                l_new_lines_tbl(l_Count6).LINE_TYPE := P_LINES_TBL(l_Count4).LINE_TYPE;
                l_new_lines_tbl(l_Count6).LINE_DESC := P_LINES_TBL(l_Count4).LINE_DESC;
                l_new_lines_tbl(l_Count6).CASH_RECEIPT_ID := P_LINES_TBL(l_Count4).CASH_RECEIPT_ID;
                l_new_lines_tbl(l_Count6).APPLY_AMOUNT := P_LINES_TBL(l_Count4).APPLY_AMOUNT;
                l_new_lines_tbl(l_Count6).PAYMENT_ORDER := l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6;
                l_new_lines_tbl(l_Count6).FEE_SCHEDULE_ID := P_LINES_TBL(l_Count4).FEE_SCHEDULE_ID;

                P_LINES_TBL(l_Count4).PAYMENT_ORDER := l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6;

                if l_next_line = 'PRIN' then

                    /* query and populate distribution lines for principal dr */
                    open prin_dr_dist_cur(P_LOAN_REC.LOAN_ID);

                    fetch prin_dr_dist_cur into
                        l_cc_id,
                        l_percent,
                        l_USSGL_TRANSACTION_CODE;

                    if prin_dr_dist_cur%FOUND then

                        l_Count2 := l_Count2 + 1;
                        l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                        l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                        l_trx_dist_tbl(l_Count2).percent := l_percent;
                        l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REC';

                        if g_multiple_lines = 'Y' then
                            l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(1).trx_header_id;
                            --l_trx_header_tbl(1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                        else
                            l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;
                            --l_trx_header_tbl(l_Count3).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                        end if;

                    end if;
                    close prin_dr_dist_cur;

                    /* query and populate distribution lines for principal cr */
                    open prin_cr_dist_cur(P_LOAN_REC.LOAN_ID, P_LOAN_REC.NEXT_PAYMENT_DUE_DATE);

                    l_Count5 := 0;
                    l_split_flag := 'N';
                    l_running_sum := 0;
                    LOOP

                        fetch prin_cr_dist_cur into
                            l_cc_id,
                            l_percent,
                            l_USSGL_TRANSACTION_CODE;
                        exit when prin_cr_dist_cur%NOTFOUND;

                        l_Count5 := l_Count5 + 1;
                        l_Count2 := l_Count2 + 1;
                        l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                        l_trx_dist_tbl(l_Count2).trx_line_id := l_trx_lines_tbl(l_Count1).trx_line_id;
                        l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                        l_trx_dist_tbl(l_Count2).percent := l_percent;
                        l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REV';

                        /* for each distribution create seperate trx line for current trx header */
                        if l_trx_dist_tbl(l_Count2).percent < 100 then

                            if l_Count5 = 1 then
                                l_orig_line_amount := l_trx_lines_tbl(l_Count1).unit_selling_price;
                                l_split_flag := 'Y';

                                fnd_currency.GET_INFO(CURRENCY_CODE => P_LOAN_REC.LOAN_CURRENCY,
                                                      PRECISION => l_precision,
                                                      EXT_PRECISION => l_ext_precision,
                                                      MIN_ACCT_UNIT => l_min_acct_unit);

                            else

                                l_Count1 := l_Count1 + 1;
                                l_trx_lines_tbl(l_Count1).line_number := l_Count5;
                                l_trx_lines_tbl(l_Count1).trx_line_id := 100 + l_Count1;
                		        l_trx_lines_tbl(l_Count1).taxable_flag := 'N'; --karamach bug5124908
                                l_trx_lines_tbl(l_Count1).quantity_invoiced := 1;
                                l_trx_lines_tbl(l_Count1).line_type := 'LINE';
                                l_trx_lines_tbl(l_Count1).interface_line_context := 'LOANS';
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE1 := P_LOAN_REC.LOAN_ID;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE2 := P_LOAN_REC.NEXT_AMORTIZATION_ID;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE3 := P_LOAN_REC.NEXT_PAYMENT_NUMBER;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE4 := P_LOAN_REC.LOAN_NUMBER;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE5 := l_next_line;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6 := l_Count1;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE7 := P_LOAN_REC.PARENT_AMORTIZATION_ID;

                                l_Count6 := l_Count6 +1;
                                l_new_lines_tbl(l_Count6).HEADER_ID := P_LINES_TBL(l_Count4).HEADER_ID;
                                l_new_lines_tbl(l_Count6).LINE_ID := P_LINES_TBL(l_Count4).LINE_ID;
                                l_new_lines_tbl(l_Count6).LINE_REF_ID := P_LINES_TBL(l_Count4).LINE_REF_ID;
                                l_new_lines_tbl(l_Count6).LINE_TYPE := P_LINES_TBL(l_Count4).LINE_TYPE;
                                l_new_lines_tbl(l_Count6).CASH_RECEIPT_ID := P_LINES_TBL(l_Count4).CASH_RECEIPT_ID;
                                l_new_lines_tbl(l_Count6).APPLY_AMOUNT := P_LINES_TBL(l_Count4).APPLY_AMOUNT;
                                l_new_lines_tbl(l_Count6).PAYMENT_ORDER := l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6;
                                l_new_lines_tbl(l_Count6).FEE_SCHEDULE_ID := P_LINES_TBL(l_Count4).FEE_SCHEDULE_ID;

                                if g_multiple_lines = 'Y' then
                                    l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(1).trx_header_id;
                                else
                                    l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;
                                end if;

                                l_trx_dist_tbl(l_Count2).trx_line_id := l_trx_lines_tbl(l_Count1).trx_line_id;

                            end if;

                            --l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                            l_trx_lines_tbl(l_Count1).description := l_line_desc || GET_RECEIVABLES_FUND_DESC(l_cc_id);
                            l_trx_lines_tbl(l_Count1).unit_selling_price := round(l_orig_line_amount * l_trx_dist_tbl(l_Count2).percent / 100, l_precision);
                            l_trx_dist_tbl(l_Count2).percent := 100;
                            l_running_sum := l_running_sum + l_trx_lines_tbl(l_Count1).unit_selling_price;

                            l_new_lines_tbl(l_Count6).LINE_AMOUNT := l_trx_lines_tbl(l_Count1).unit_selling_price;
                            l_new_lines_tbl(l_Count6).LINE_DESC := l_trx_lines_tbl(l_Count1).description;

                        --else
                        --    l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                        end if;

                    END LOOP;

                    if l_split_flag = 'Y' then
                        l_trx_lines_tbl(l_Count1).unit_selling_price := l_orig_line_amount -
                            (l_running_sum - l_trx_lines_tbl(l_Count1).unit_selling_price);
                        l_new_lines_tbl(l_Count6).LINE_AMOUNT := l_trx_lines_tbl(l_Count1).unit_selling_price;
                    end if;

                    close prin_cr_dist_cur;

                elsif l_next_line = 'INT' then

                    if l_int_header = -1 then
                        /* query and populate distribution lines for interest dr */
                        open int_dr_dist_cur(P_LOAN_REC.LOAN_ID);

                        fetch int_dr_dist_cur into
                            l_cc_id,
                            l_percent,
                            l_USSGL_TRANSACTION_CODE;

                        if int_dr_dist_cur%FOUND then

                            l_Count2 := l_Count2 + 1;
                            l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                            l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                            l_trx_dist_tbl(l_Count2).percent := l_percent;
                            l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REC';

                            if g_multiple_lines = 'Y' then
                                l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(1).trx_header_id;
                                --l_trx_header_tbl(1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                            else
                                l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;
                                --l_trx_header_tbl(l_Count3).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                            end if;

                        end if;
                        close int_dr_dist_cur;
                    end if;

                    /* query and populate distribution lines for interest cr */
                    open int_cr_dist_cur(P_LOAN_REC.LOAN_ID);

                    l_Count5 := 0;
                    l_split_flag := 'N';
                    l_running_sum := 0;
                    LOOP

                        fetch int_cr_dist_cur into
                            l_cc_id,
                            l_percent,
                            l_USSGL_TRANSACTION_CODE;
                        exit when int_cr_dist_cur%NOTFOUND;

                        l_Count5 := l_Count5 + 1;
                        l_Count2 := l_Count2 + 1;
                        l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                        l_trx_dist_tbl(l_Count2).trx_line_id := l_trx_lines_tbl(l_Count1).trx_line_id;
                        l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                        l_trx_dist_tbl(l_Count2).percent := l_percent;
                        l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REV';

                        /* for each distribution create seperate trx line for current trx header */
                        if l_trx_dist_tbl(l_Count2).percent < 100 then

                            if l_Count5 = 1 then
                                l_orig_line_amount := l_trx_lines_tbl(l_Count1).unit_selling_price;
                                l_split_flag := 'Y';

                                fnd_currency.GET_INFO(CURRENCY_CODE => P_LOAN_REC.LOAN_CURRENCY,
                                                      PRECISION => l_precision,
                                                      EXT_PRECISION => l_ext_precision,
                                                      MIN_ACCT_UNIT => l_min_acct_unit);

                            else

                                l_Count1 := l_Count1 + 1;
                                l_trx_lines_tbl(l_Count1).line_number := l_Count5;
                                l_trx_lines_tbl(l_Count1).trx_line_id := 100 + l_Count1;
                		        l_trx_lines_tbl(l_Count1).taxable_flag := 'N'; --karamach bug5124908
                                l_trx_lines_tbl(l_Count1).quantity_invoiced := 1;
                                l_trx_lines_tbl(l_Count1).line_type := 'LINE';
                                l_trx_lines_tbl(l_Count1).interface_line_context := 'LOANS';
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE1 := P_LOAN_REC.LOAN_ID;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE2 := P_LOAN_REC.NEXT_AMORTIZATION_ID;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE3 := P_LOAN_REC.NEXT_PAYMENT_NUMBER;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE4 := P_LOAN_REC.LOAN_NUMBER;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE5 := l_next_line;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6 := l_Count1;
                                l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE7 := P_LOAN_REC.PARENT_AMORTIZATION_ID;

                                l_Count6 := l_Count6 +1;
                                l_new_lines_tbl(l_Count6).HEADER_ID := P_LINES_TBL(l_Count4).HEADER_ID;
                                l_new_lines_tbl(l_Count6).LINE_ID := P_LINES_TBL(l_Count4).LINE_ID;
                                l_new_lines_tbl(l_Count6).LINE_REF_ID := P_LINES_TBL(l_Count4).LINE_REF_ID;
                                l_new_lines_tbl(l_Count6).LINE_TYPE := P_LINES_TBL(l_Count4).LINE_TYPE;
                                l_new_lines_tbl(l_Count6).CASH_RECEIPT_ID := P_LINES_TBL(l_Count4).CASH_RECEIPT_ID;
                                l_new_lines_tbl(l_Count6).APPLY_AMOUNT := P_LINES_TBL(l_Count4).APPLY_AMOUNT;
                                l_new_lines_tbl(l_Count6).PAYMENT_ORDER := l_trx_lines_tbl(l_Count1).INTERFACE_LINE_ATTRIBUTE6;
                                l_new_lines_tbl(l_Count6).FEE_SCHEDULE_ID := P_LINES_TBL(l_Count4).FEE_SCHEDULE_ID;

                                if g_multiple_lines = 'Y' then
                                    l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(1).trx_header_id;
                                else
                                    l_trx_lines_tbl(l_Count1).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;
                                end if;

                                l_trx_dist_tbl(l_Count2).trx_line_id := l_trx_lines_tbl(l_Count1).trx_line_id;

                            end if;

                            --l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                            l_trx_lines_tbl(l_Count1).description := l_line_desc || GET_RECEIVABLES_FUND_DESC(l_cc_id);
                            l_trx_lines_tbl(l_Count1).unit_selling_price := round(l_orig_line_amount * l_trx_dist_tbl(l_Count2).percent / 100, l_precision);
                            l_trx_dist_tbl(l_Count2).percent := 100;
                            l_running_sum := l_running_sum + l_trx_lines_tbl(l_Count1).unit_selling_price;

                            l_new_lines_tbl(l_Count6).LINE_AMOUNT := l_trx_lines_tbl(l_Count1).unit_selling_price;
                            l_new_lines_tbl(l_Count6).LINE_DESC := l_trx_lines_tbl(l_Count1).description;

                        --else
                        --    l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                        end if;

--                        l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;

                    END LOOP;

                    if l_split_flag = 'Y' then
                        l_trx_lines_tbl(l_Count1).unit_selling_price := l_orig_line_amount -
                            (l_running_sum - l_trx_lines_tbl(l_Count1).unit_selling_price);
                        l_new_lines_tbl(l_Count6).LINE_AMOUNT := l_trx_lines_tbl(l_Count1).unit_selling_price;
                    end if;

                    close int_cr_dist_cur;

                    if l_int_header = -1 then
                        l_int_header := l_Count3;
                    end if;

                elsif l_next_line = 'FEE' then

                    if P_LINES_TBL(l_Count4).LINE_REF_ID is not null then

		    	        l_disb_hdr_id := null;

		    	        open cur_get_disbHdr_id(P_LINES_TBL(l_Count4).fee_schedule_id);
                        fetch cur_get_disbHdr_id into l_disb_hdr_id;
                        close cur_get_disbHdr_id;
                        LogMessage(FND_LOG.LEVEL_STATEMENT, 'disb_header_id is '||l_disb_hdr_id||' for fee_schedule_id : '||P_LINES_TBL(l_Count4).fee_schedule_id);

                        if l_fee_header = -1 then

                            l_feeRec_exists := 'N';
                            /* query and populate distribution lines for fee dr */
                            open cur_fee_dr_dist(P_LOAN_REC.LOAN_ID, P_LINES_TBL(l_Count4).LINE_REF_ID, l_disb_hdr_id);
            			    fetch cur_fee_dr_dist into
                                l_cc_id,
                                l_percent,
                                l_USSGL_TRANSACTION_CODE;

			                IF (cur_fee_dr_dist%NOTFOUND) THEN

                                /* Existed disbFees before fix of bug#9054263, contains only one FEE_RECEIVABLE
				                    for all fees in a loan */
                                /* query and populate distribution lines for fee dr */
                                open fee_dr_dist_cur(P_LOAN_REC.LOAN_ID);

                                fetch fee_dr_dist_cur into
                                    l_cc_id,
                                    l_percent,
                                    l_USSGL_TRANSACTION_CODE;

                                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Executed cursor fee_dr_dist_cur(for a LOAN)');
                                if(fee_dr_dist_cur%FOUND) THEN
                                    l_feeRec_exists := 'Y';
                                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Records found for cursor fee_dr_dist_cur(for a LOAN)');
                                end if;
                                close fee_dr_dist_cur;
                            ELSE
                                l_feeRec_exists := 'Y';
                                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Records found for cursor cur_fee_dr_dist(for each fee)');
                            end if;

                            if l_feeRec_exists = 'Y' then

                                l_Count2 := l_Count2 + 1;
                                l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                                l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                                l_trx_dist_tbl(l_Count2).percent := l_percent;
                                l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REC';

                                if g_multiple_lines = 'Y' then
                                    l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(1).trx_header_id;
                                    --l_trx_header_tbl(1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                                else
                                    l_trx_dist_tbl(l_Count2).trx_header_id := l_trx_header_tbl(l_Count3).trx_header_id;
                                    --l_trx_header_tbl(l_Count3).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;
                                end if;

                            end if;

			                close cur_fee_dr_dist;

                        end if;

                        /* query and populate distribution lines for fee cr */
                        open fee_cr_dist_cur(P_LOAN_REC.LOAN_ID, P_LINES_TBL(l_Count4).LINE_REF_ID, l_disb_hdr_id);

                        LOOP

                            fetch fee_cr_dist_cur into
                                l_cc_id,
                                l_percent,
                                l_USSGL_TRANSACTION_CODE;
                            exit when fee_cr_dist_cur%NOTFOUND;

                            l_Count2 := l_Count2 + 1;
                            l_trx_dist_tbl(l_Count2).trx_dist_id := 100 + l_Count2;
                            l_trx_dist_tbl(l_Count2).trx_line_id := l_trx_lines_tbl(l_Count1).trx_line_id;
                            l_trx_dist_tbl(l_Count2).CODE_COMBINATION_ID := l_cc_id;
                            l_trx_dist_tbl(l_Count2).percent := l_percent;
                            l_trx_dist_tbl(l_Count2).ACCOUNT_CLASS := 'REV';

                            --l_trx_lines_tbl(l_Count1).default_ussgl_transaction_code := l_USSGL_TRANSACTION_CODE;

                        END LOOP;

                        close fee_cr_dist_cur;

                    end if;

                    if l_fee_header = -1 then
                        l_fee_header := l_Count3;
                    end if;

                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Will create invoice/line for ' || l_trx_lines_tbl(l_Count1).description || ' with amount ' || l_trx_lines_tbl(l_Count1).unit_selling_price);

            end if;

        END LOOP;

        /* exit looping */
        if l_exit_loop = 'Y' then
            exit;
        end if;

        l_start_pos := l_end_pos+1;
		l_end_pos := instr(P_LOAN_REC.PAYMENT_APPLICATION_ORDER, l_search_str, l_start_pos, 1);

	end loop;

    if l_trx_header_tbl.COUNT = 0 then
	-- fix for bug 7000066: returning without error if there are no data to create invoices
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'WARNING: No data available to create invoices. Returning.');
        return;
    /*
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No data to create invoices.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_DATA_CR_INV');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
   */
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Creating AR invoices with following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_batch_source_rec.batch_source_id: ' || l_batch_source_rec.batch_source_id);

    FOR l_Count3 IN 1..l_trx_header_tbl.COUNT LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice header ' || l_Count3);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').trx_header_id: ' || l_trx_header_tbl(l_Count3).trx_header_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').trx_number: ' || l_trx_header_tbl(l_Count3).trx_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').trx_date: ' || l_trx_header_tbl(l_Count3).trx_date);
        --LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').billing_date: ' || l_trx_header_tbl(l_Count3).billing_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').trx_currency: ' || l_trx_header_tbl(l_Count3).trx_currency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').exchange_rate_type: ' || l_trx_header_tbl(l_Count3).exchange_rate_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').exchange_date: ' || l_trx_header_tbl(l_Count3).exchange_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').exchange_rate: ' || l_trx_header_tbl(l_Count3).exchange_rate);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').cust_trx_type_id: ' || l_trx_header_tbl(l_Count3).cust_trx_type_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').bill_to_customer_id: ' || l_trx_header_tbl(l_Count3).bill_to_customer_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').bill_to_address_id: ' || l_trx_header_tbl(l_Count3).bill_to_address_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').bill_to_site_use_id: ' || l_trx_header_tbl(l_Count3).bill_to_site_use_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').term_id: ' || l_trx_header_tbl(l_Count3).term_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').finance_charges: ' || l_trx_header_tbl(l_Count3).finance_charges);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').status_trx: ' || l_trx_header_tbl(l_Count3).status_trx);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').printing_option: ' || l_trx_header_tbl(l_Count3).printing_option);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').interface_header_attribute1: ' || l_trx_header_tbl(l_Count3).interface_header_attribute1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').default_ussgl_transaction_code: ' || l_trx_header_tbl(l_Count3).default_ussgl_transaction_code);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').org_id: ' || l_trx_header_tbl(l_Count3).org_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').legal_entity_id: ' || l_trx_header_tbl(l_Count3).legal_entity_id);

        -- fix for bug 8859462
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_BILLING_UTIL_PUB.VALIDATE_AND_DEFAULT_GL_DATE...');
        LNS_BILLING_UTIL_PUB.VALIDATE_AND_DEFAULT_GL_DATE(
                p_gl_date => l_trx_header_tbl(l_Count3).gl_date,
                p_trx_date => l_trx_header_tbl(l_Count3).trx_date,
                p_set_of_books_id => g_set_of_books_id,
                x_default_gl_date => l_trx_header_tbl(l_Count3).gl_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_header_tbl(' || l_Count3 || ').gl_date: ' || l_trx_header_tbl(l_Count3).gl_date);

    END LOOP;

    FOR l_Count3 IN 1..l_trx_lines_tbl.COUNT LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice line ' || l_Count3);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').trx_line_id: ' || l_trx_lines_tbl(l_Count3).trx_line_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').trx_header_id: ' || l_trx_lines_tbl(l_Count3).trx_header_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').line_number: ' || l_trx_lines_tbl(l_Count3).line_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').description: ' || l_trx_lines_tbl(l_Count3).description);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').quantity_invoiced: ' || l_trx_lines_tbl(l_Count3).quantity_invoiced);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').unit_selling_price: ' || l_trx_lines_tbl(l_Count3).unit_selling_price);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').line_type: ' || l_trx_lines_tbl(l_Count3).line_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').interface_line_context: ' || l_trx_lines_tbl(l_Count3).interface_line_context);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE1: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE2: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE2);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE3: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE3);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE4: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE4);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE5: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE5);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE6: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE6);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').INTERFACE_LINE_ATTRIBUTE7: ' || l_trx_lines_tbl(l_Count3).INTERFACE_LINE_ATTRIBUTE7);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_lines_tbl(' || l_Count3 || ').default_ussgl_transaction_code: ' || l_trx_lines_tbl(l_Count3).default_ussgl_transaction_code);

    END LOOP;

    FOR l_Count3 IN 1..l_trx_dist_tbl.COUNT LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Distribution ' || l_Count3);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').trx_dist_id: ' || l_trx_dist_tbl(l_Count3).trx_dist_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').trx_header_id: ' || l_trx_dist_tbl(l_Count3).trx_header_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').trx_line_id: ' || l_trx_dist_tbl(l_Count3).trx_line_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').ACCOUNT_CLASS: ' || l_trx_dist_tbl(l_Count3).ACCOUNT_CLASS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').percent: ' || l_trx_dist_tbl(l_Count3).percent);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_dist_tbl(' || l_Count3 || ').CODE_COMBINATION_ID: ' || l_trx_dist_tbl(l_Count3).CODE_COMBINATION_ID);

    END LOOP;

--    fnd_global.apps_initialize(FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID, FND_GLOBAL.SECURITY_GROUP_ID);

    l_batch_id := null;
    ar_invoice_api_pub.g_api_outputs.batch_id := null;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Org info just before call to invoice api');
    l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.GET_CURRENT_ORG_ID(): ' || l_org_id);
    l_org_status := MO_GLOBAL.check_valid_org(g_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.check_valid_org(' || g_org_id || '): ' || l_org_status);

    BEGIN

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Calling AR_INVOICE_API_PUB.CREATE_INVOICE...');
        l_start := sysdate;
        AR_INVOICE_API_PUB.CREATE_INVOICE(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_TRUE,
            p_commit                => FND_API.G_FALSE,
            p_batch_source_rec	    => l_batch_source_rec,
            p_trx_header_tbl        => l_trx_header_tbl,
            p_trx_lines_tbl         => l_trx_lines_tbl,
            p_trx_dist_tbl          => l_trx_dist_tbl,
            p_trx_salescredits_tbl  => l_trx_salescredits_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

    EXCEPTION
        WHEN OTHERS THEN

            l_end := sysdate;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice API timing: ' || round((l_end - l_start)*86400, 2) || ' sec');
            LogMessage(FND_LOG.LEVEL_ERROR, 'Invoice API throws exception!');

            /* query AR errors */
            l_ar_error_counter := 0;
            open ar_invoice_err_cur;

            LOOP

                fetch ar_invoice_err_cur into
                    l_trx_header_id,
                    l_trx_line_id,
                    l_error_message,
                    l_invalid_value;
                exit when ar_invoice_err_cur%NOTFOUND;

                l_ar_error_counter := l_ar_error_counter + 1;

                if l_ar_error_counter = 1 then
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_INV_FAIL');
                    FND_MESSAGE.SET_TOKEN('MSG', l_msg_data);
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
                end if;

                FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_INV_ERROR');
                FND_MESSAGE.SET_TOKEN('ERR', l_error_message);
                FND_MESSAGE.SET_TOKEN('VALUE', l_invalid_value);
                FND_MESSAGE.SET_TOKEN('HEADER', l_trx_header_id);
                FND_MESSAGE.SET_TOKEN('LINE', l_trx_line_id);
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));

            END LOOP;

            close ar_invoice_err_cur;

            if l_ar_error_counter = 0 then
                LogMessage(FND_LOG.LEVEL_ERROR, 'No AR errors found.');
            end if;

            RAISE FND_API.G_EXC_ERROR;
    END;

    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Invoice API timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    l_batch_id := ar_invoice_api_pub.g_api_outputs.batch_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_batch_id: ' || l_batch_id);

    l_ar_error_counter := 0;
    IF l_return_status = fnd_api.g_ret_sts_error OR l_return_status = fnd_api.g_ret_sts_unexp_error OR l_batch_id is null THEN

        l_ar_error_counter := 1;
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_INV_FAIL');
    	FND_MESSAGE.SET_TOKEN('MSG', l_msg_data);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    END IF;

    /* query AR errors */
    open ar_invoice_err_cur;

    LOOP

        fetch ar_invoice_err_cur into
            l_trx_header_id,
            l_trx_line_id,
            l_error_message,
            l_invalid_value;
        exit when ar_invoice_err_cur%NOTFOUND;

        l_ar_error_counter := l_ar_error_counter + 1;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_INV_ERROR');
        FND_MESSAGE.SET_TOKEN('ERR', l_error_message);
        FND_MESSAGE.SET_TOKEN('VALUE', l_invalid_value);
        FND_MESSAGE.SET_TOKEN('HEADER', l_trx_header_id);
        FND_MESSAGE.SET_TOKEN('LINE', l_trx_line_id);
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

    END LOOP;

    close ar_invoice_err_cur;

    if l_ar_error_counter > 0  then
	    RAISE FND_API.G_EXC_ERROR;
    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoices successfully created!') ;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Fetching inserted ar invoice details...');

    /* query for cust_trx_id(s) and payment_schedule_id(s) */
    open ar_invoices_cur(l_batch_id);

    l_Count2 := 0; -- counter

    LOOP

        fetch ar_invoices_cur into
            l_customer_trx_id,
            l_trx_number,
            l_customer_trx_line_id,
            l_payment_schedule_id,
            l_due_date,
            l_amount,
            l_line_type,
            l_payment_order;
        exit when ar_invoices_cur%NOTFOUND;

        l_Count2 := l_Count2+1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Trx ' || l_Count2 ||'; trx_number: ' || l_trx_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_TRX_ID: ' || l_customer_trx_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_TRX_LINE_ID: ' || l_customer_trx_line_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || l_payment_schedule_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_due_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMOUNT: ' || l_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_TYPE: ' || l_line_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_ORDER: ' || l_payment_order);

        if l_payment_schedule_id is null then
            LogMessage(FND_LOG.LEVEL_ERROR, 'WARNING: Invoice ' || l_trx_number || '(id ' || l_customer_trx_id || ') ' ||  l_line_type || ' is incomplete!');
        end if;

        if l_line_type = 'PRIN' then
            l_principal_trx_id := l_customer_trx_id;
        elsif l_line_type = 'INT' then
            l_interest_trx_id := l_customer_trx_id;
        elsif l_line_type = 'FEE' then
            l_fee_trx_id := l_customer_trx_id;
        end if;

        /* search right record in l_new_lines_tbl table and set AR info */
        FOR l_Count3 IN 1..l_new_lines_tbl.COUNT LOOP

            if l_line_type = l_new_lines_tbl(l_Count3).LINE_TYPE and l_payment_order = l_new_lines_tbl(l_Count3).PAYMENT_ORDER then

                l_new_lines_tbl(l_Count3).CUSTOMER_TRX_ID := l_customer_trx_id;
                l_new_lines_tbl(l_Count3).PAYMENT_SCHEDULE_ID := l_payment_schedule_id;
                l_new_lines_tbl(l_Count3).CUSTOMER_TRX_LINE_ID := l_customer_trx_line_id;

                /* inserting new record into LNS_AMORTIZATION_LINES */
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting new record into LNS_AMORTIZATION_LINES w following values:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_SCHEDULE_ID: ' || P_LOAN_REC.NEXT_AMORTIZATION_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_LOAN_REC.LOAN_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_TYPE: ' || l_line_type);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMOUNT: ' || l_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || l_customer_trx_id);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_LINE_ID: ' || l_customer_trx_line_id);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_ID: ' || l_new_lines_tbl(l_Count3).LINE_REF_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_SCHEDULE_ID: ' || l_new_lines_tbl(l_Count3).FEE_SCHEDULE_ID);

                l_amortization_line_id := null;
                LNS_AMORTIZATION_LINES_PKG.Insert_Row(
                    X_AMORTIZATION_LINE_ID => l_amortization_line_id
                    ,P_AMORTIZATION_SCHEDULE_ID => P_LOAN_REC.NEXT_AMORTIZATION_ID
                    ,P_LOAN_ID	=> P_LOAN_REC.LOAN_ID
                    ,P_LINE_TYPE => l_line_type
                    ,P_AMOUNT => l_amount
                    ,P_CUST_TRX_ID => l_customer_trx_id
                    ,P_CUST_TRX_LINE_ID => l_customer_trx_line_id
                    ,P_FEE_ID => l_new_lines_tbl(l_Count3).LINE_REF_ID
                    ,P_OBJECT_VERSION_NUMBER => 1
                    ,P_FEE_SCHEDULE_ID => l_new_lines_tbl(l_Count3).FEE_SCHEDULE_ID);

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_LINE_ID: ' || l_amortization_line_id);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted record into LNS_AMORTIZATION_LINES');

                exit;

            end if;

        END LOOP;

    END LOOP;

    close ar_invoices_cur;

    if l_Count2 = 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No AR invoices fetched');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_INV_FETCHED');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* Update interest and fee trxs with principal_trx_id as RELATED_CUSTOMER_TRX_ID */
    if g_multiple_lines = 'N' and l_principal_trx_id is not null then

        if l_interest_trx_id is not null then

            update RA_CUSTOMER_TRX_ALL set RELATED_CUSTOMER_TRX_ID = l_principal_trx_id where CUSTOMER_TRX_ID = l_interest_trx_id;

            if (sql%notfound) then
--                LogMessage(FND_LOG.LEVEL_ERROR, 'ERROR: Update RA_CUSTOMER_TRX_ALL with RELATED_CUSTOMER_TRX_ID failed');
            	FND_MESSAGE.SET_NAME('LNS', 'LNS_RELATE_INV_FAIL');
        		FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

        end if;

        if l_fee_trx_id is not null then

            update RA_CUSTOMER_TRX_ALL set RELATED_CUSTOMER_TRX_ID = l_principal_trx_id where CUSTOMER_TRX_ID = l_fee_trx_id;

            if (sql%notfound) then
--                LogMessage(FND_LOG.LEVEL_ERROR, 'ERROR: Update RA_CUSTOMER_TRX_ALL with RELATED_CUSTOMER_TRX_ID failed');
            	FND_MESSAGE.SET_NAME('LNS', 'LNS_RELATE_INV_FAIL');
        		FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

        end if;

    end if;

    /* Update amortization table with new principal, interest and fee ids */

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_AMORTIZATION_SCHEDS with new trx ids:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'principal_trx_id: ' || l_principal_trx_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'interest_trx_id: ' || l_interest_trx_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'fee_trx_id: ' || l_fee_trx_id);

    LNS_AMORTIZATION_SCHEDS_PKG.Update_Row(
        P_AMORTIZATION_SCHEDULE_ID  => P_LOAN_REC.NEXT_AMORTIZATION_ID
	    ,P_PRINCIPAL_TRX_ID	        => l_principal_trx_id
	    ,P_INTEREST_TRX_ID	        => l_interest_trx_id
	    ,P_FEE_TRX_ID	            => l_fee_trx_id);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Update successfull!');

    P_LINES_TBL := l_new_lines_tbl;
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
END;



/*========================================================================
 | PRIVATE PROCEDURE CREATE_AR_CM
 |
 | DESCRIPTION
 |      This procedure creates AR credit memos.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      REVERSE_LAST_AMORTIZATION
 |      REVERSE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_REVERSE_TBL  IN OUT       Table of records needs to be reversed
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
PROCEDURE CREATE_AR_CM(P_REVERSE_TBL  IN OUT NOCOPY  LNS_BILLING_BATCH_PUB.REVERSE_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_AR_CM';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_Count1                        number;
    l_Count2                        number;
    l_trx_found                     varchar2(1);
    l_request_id                    number;
    l_batch_source_name             VARCHAR2(50);
    l_cm_batch_source_name          VARCHAR2(50);
    l_cm_batch_source_id            number;
    l_Count4                        number;

    l_trx_tbl                       DBMS_SQL.NUMBER_TABLE;
    l_cm_line_tbl                   AR_CREDIT_MEMO_API_PUB.Cm_Line_Tbl_Type_Cover%type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query for batch_source_name and cm_batch_source_id */
    CURSOR batch_source_cur(P_BATCH_SOURCE_ID number) IS
        select name, CREDIT_MEMO_BATCH_SOURCE_ID
        from RA_BATCH_SOURCES
        where batch_source_id = P_BATCH_SOURCE_ID;

    /* query for cm_batch_source_name */
    CURSOR cm_batch_source_cur(P_BATCH_SOURCE_ID number) IS
        select name
        from RA_BATCH_SOURCES
        where batch_source_id = P_BATCH_SOURCE_ID;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    l_Count1 := 0;
    FOR l_Count IN 1..P_REVERSE_TBL.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Trx Line #' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_NUMBER: ' || P_REVERSE_TBL(l_Count).TRX_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_TRX_ID: ' || P_REVERSE_TBL(l_Count).CUSTOMER_TRX_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || P_REVERSE_TBL(l_Count).PAYMENT_SCHEDULE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_TRX_LINE_ID: ' || P_REVERSE_TBL(l_Count).CUSTOMER_TRX_LINE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_TYPE: ' || P_REVERSE_TBL(l_Count).LINE_TYPE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_AMOUNT: ' || P_REVERSE_TBL(l_Count).TRX_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'APPLIED_AMOUNT: ' || P_REVERSE_TBL(l_Count).APPLIED_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORG_ID: ' || P_REVERSE_TBL(l_Count).ORG_ID);

        if P_REVERSE_TBL(l_Count).APPLIED_AMOUNT <> 0 then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Cannot reverse because there are some valid activities on trx.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_REV_BILL');
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        /* searching/adding trx(s) into unique trx table */
        l_trx_found := 'N';

        FOR l_Count1 IN 1..l_trx_tbl.count LOOP

            if l_trx_tbl(l_Count1) = P_REVERSE_TBL(l_Count).CUSTOMER_TRX_ID then
                l_trx_found := 'Y';
                exit;
            end if;

        END LOOP;

        if l_trx_found = 'N' then

            l_Count1 := l_Count1 + 1;
            l_trx_tbl(l_Count1) := P_REVERSE_TBL(l_Count).CUSTOMER_TRX_ID;
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added trx ' || P_REVERSE_TBL(l_Count).CUSTOMER_TRX_ID || ' into unique trx table');

        end if;

    END LOOP;

    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total found ' || l_trx_tbl.count || ' unique trx(s)');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total found ' || P_REVERSE_TBL.count || ' trx line(s)');

    if P_REVERSE_TBL.count = 0 or l_trx_tbl.count = 0 then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No AR transactions found to reverse.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_REVERSE');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* query for batch_source_name and cm_batch_source_id */
    open batch_source_cur(g_batch_source_id);
    fetch batch_source_cur into l_batch_source_name, l_cm_batch_source_id;
    close batch_source_cur;

    if l_cm_batch_source_id is null then

    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_CM_BATCH');
      	FND_MESSAGE.SET_TOKEN('BATCH', l_batch_source_name);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* query for cm_batch_source_name */
    open cm_batch_source_cur(l_cm_batch_source_id);
    fetch cm_batch_source_cur into l_cm_batch_source_name;
    close cm_batch_source_cur;

    --l_batch_source_name := 'Credit Memo';
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'batch_source_name: ' || l_batch_source_name);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'cm_batch_source_name: ' || l_cm_batch_source_name);

    /* looping thru table of unique trx(s) */
    FOR l_Count1 IN 1..l_trx_tbl.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing trx ' || l_trx_tbl(l_Count1));

        l_cm_line_tbl.delete;
        l_Count2 := 0;
        l_Count4 := 0;

        FOR l_Count IN 1..P_REVERSE_TBL.count LOOP

            if l_trx_tbl(l_Count1) = P_REVERSE_TBL(l_Count).CUSTOMER_TRX_ID then

                l_Count2 := l_Count2 + 1;
                l_Count4 := l_Count;
                l_cm_line_tbl(l_Count2).customer_trx_line_id := P_REVERSE_TBL(l_Count).CUSTOMER_TRX_LINE_ID;
                l_cm_line_tbl(l_Count2).extended_amount := -P_REVERSE_TBL(l_Count).TRX_AMOUNT;
                l_cm_line_tbl(l_Count2).quantity_credited := 1;
                l_cm_line_tbl(l_Count2).price := -P_REVERSE_TBL(l_Count).TRX_AMOUNT;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adding a line to cm_line_tbl:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cm_line_tbl(' || l_Count2 || ').customer_trx_line_id: ' || l_cm_line_tbl(l_Count2).customer_trx_line_id);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cm_line_tbl(' || l_Count2 || ').extended_amount: ' || l_cm_line_tbl(l_Count2).extended_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cm_line_tbl(' || l_Count2 || ').quantity_credited: ' || l_cm_line_tbl(l_Count2).quantity_credited);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cm_line_tbl(' || l_Count2 || ').price: ' || l_cm_line_tbl(l_Count2).price);

            end if;

        END LOOP;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling AR_CREDIT_MEMO_API_PUB.CREATE_REQUEST for trx ' || l_trx_tbl(l_Count1));

        AR_CREDIT_MEMO_API_PUB.CREATE_REQUEST(
                P_API_VERSION => 1.0,
                P_INIT_MSG_LIST	=> FND_API.G_TRUE,
                P_COMMIT => FND_API.G_FALSE,
                P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                P_CUSTOMER_TRX_ID => l_trx_tbl(l_Count1),
                P_LINE_CREDIT_FLAG => 'Y',
                P_CM_REASON_CODE => 'CANCELLATION',
                p_cm_line_tbl => l_cm_line_tbl,
                P_SKIP_WORKFLOW_FLAG => 'Y',
                P_CREDIT_METHOD_INSTALLMENTS => null,
                P_CREDIT_METHOD_RULES => null,
                P_BATCH_SOURCE_NAME => l_cm_batch_source_name,
                P_ORG_ID => P_REVERSE_TBL(l_Count4).ORG_ID,
                X_REQUEST_ID => l_request_id,
                X_RETURN_STATUS	=> l_return_status,
                X_MSG_COUNT => l_msg_count,
                X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_request_id: ' || l_request_id);

        IF l_return_status = fnd_api.g_ret_sts_error OR l_return_status = fnd_api.g_ret_sts_unexp_error OR
           l_request_id is null OR l_request_id = -1

        THEN

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: AR_CREDIT_MEMO_API_PUB.CREATE_REQUEST raised unexpected error: ' || substr(l_msg_data,1,225));
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_CM_FAIL');
        	FND_MESSAGE.SET_TOKEN('BATCH', l_cm_batch_source_name);
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        ELSE

            if l_msg_data is not null then
                g_cr_return_status := 'WARNING';
            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'CM successfully created!') ;


        END IF;

    END LOOP;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
END;



/*========================================================================
 | PRIVATE PROCEDURE APPLY_RECEIPT
 |
 | DESCRIPTION
 |      This procedure applies cash receipt to invoice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_CASH_RECEIPT_ID   IN      Cash receipt to apply
 |      P_TRX_ID            IN      Apply receipt to this trx
 |      P_TRX_LINE_ID       IN      Apply receipt to this trx line
 |      P_APPLY_AMOUNT      IN      Apply amount
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
PROCEDURE APPLY_RECEIPT(P_CASH_RECEIPT_ID   IN      NUMBER,
                        P_TRX_ID            IN      NUMBER,
                        P_TRX_LINE_ID       IN      NUMBER,
                        P_APPLY_AMOUNT      IN      NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPLY_RECEIPT';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_receipt_rem_amount            number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR receipt_cur(P_RECEIPT_ID number) IS
        select ABS(AMOUNT_DUE_REMAINING)
        from ar_payment_schedules
        where CASH_RECEIPT_ID = P_RECEIPT_ID
        and status = 'OP'
        and class = 'PMT';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Applying cash receipt ' || P_CASH_RECEIPT_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_CASH_RECEIPT_ID: ' || P_CASH_RECEIPT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_TRX_ID: ' || P_TRX_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_TRX_LINE_ID: ' || P_TRX_LINE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_APPLY_AMOUNT: ' || P_APPLY_AMOUNT);

    /* verify input data */

    if P_CASH_RECEIPT_ID is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Cash Receipt ID is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_NOT_SET');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_TRX_ID is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Trx ID is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_TRX_NOT_SET');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_TRX_LINE_ID is null then
--        LogMessage(FND_LOG.LEVEL_ERROR, 'ERROR: Trx Line ID is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_TRX_LINE_NOT_SET');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_APPLY_AMOUNT is null or P_APPLY_AMOUNT <= 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Apply Amount is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_AMOUNT_NOT_SET');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* verifying requested qpply amount */

    open receipt_cur(P_CASH_RECEIPT_ID);
    fetch receipt_cur into l_receipt_rem_amount;

    if receipt_cur%NOTFOUND then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No receipt found to apply.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_CR_FOUND');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    close receipt_cur;

    if l_receipt_rem_amount < P_APPLY_AMOUNT then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: The receipt does not have enough funds to apply requested amount.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_CR_FUNDS');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* Applying cash receipt to invoice */
/*
    AR_RECEIPT_API_PUB.APPLY(
        P_API_VERSION => 1.0,
        P_INIT_MSG_LIST => FND_API.G_FALSE,
        P_COMMIT => FND_API.G_TRUE,
        X_RETURN_STATUS => L_RETURN_STATUS,
        X_MSG_COUNT => L_MSG_COUNT,
        X_MSG_DATA => L_MSG_DATA,
        p_cash_receipt_id => P_CASH_RECEIPT_ID,
        p_customer_trx_id => P_TRX_ID,
        p_amount_applied => P_APPLY_AMOUNT,
        p_customer_trx_line_id => P_TRX_LINE_ID);
*/
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: AR_RECEIPT_API_PUB.APPLY raised error: ' || substr(l_msg_data,1,225));
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_APPL_CR_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    ELSE
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully applied cash receipt to trx ' || P_TRX_ID || ' line ' || P_TRX_LINE_ID);
    END IF;

    -- END OF BODY OF API

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed to apply cash receipt to trx ' || P_TRX_ID || ' line ' || P_TRX_LINE_ID);

END;




/*========================================================================
 | PRIVATE PROCEDURE CREATE_AR_ADJ
 |
 | DESCRIPTION
 |      This procedure creates AR adjustment.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_TYPE                  IN      Adjustment type
 |      P_PAYMENT_SCHEDULE_ID   IN      Payment schedule ID
 |      P_RECEIVABLES_TRX_ID    IN      Receivables trx ID
 |      P_AMOUNT                IN      Adjust amount
 |      P_CUSTOMER_TRX_LINE_ID  IN      Trx line ID
 |      P_CODE_COMBINATION_ID   IN      Code combination ID
 |      P_USSGL_TRX_CODE        IN      USSGL Trx code
 |      P_REASON_CODE           IN      Adjust reason
 |      P_COMMENTS              IN      Adjust comments
 |      X_ADJ_ID                OUT     Adjust comments
 |      X_ADJ_NUMBER            OUT     Adjust comments
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
 | 03-16-2006            karamach          Always pass INVOICE for adjustment type and also pass p_check_amount 'F' to fix bug5092620 when adjusting invoice with Tax/Freight/Charges
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_AR_ADJ(P_TYPE                  IN  VARCHAR2,
                        P_PAYMENT_SCHEDULE_ID   IN  NUMBER,
                        P_RECEIVABLES_TRX_ID    IN  NUMBER,
                        P_AMOUNT                IN  NUMBER,
                        P_APPLY_DATE            IN  DATE,
                        P_GL_DATE               IN  DATE,
                        P_CUSTOMER_TRX_LINE_ID  IN  NUMBER,
                        P_CODE_COMBINATION_ID   IN  NUMBER,
                        P_USSGL_TRX_CODE        IN  VARCHAR2,
                        P_REASON_CODE           IN  VARCHAR2,
                        P_COMMENTS              IN  VARCHAR2,
                        X_ADJ_ID                OUT NOCOPY NUMBER,
                        X_ADJ_NUMBER            OUT NOCOPY VARCHAR2,
                        P_ORG_ID                IN  NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_AR_ADJ';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_adj_rec                       ar_adjustments%rowtype;
    l_adj_num                       varchar2(20);
    l_adj_id                        number;
    l_index                         number := 0;
    l_indexNo                       number := 1;
    l_msg                           varchar2(4000) := null;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/


BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adjusting invoice...');

    l_adj_rec.type := 'INVOICE'; --P_TYPE; --karamach Bug5092620
    l_adj_rec.payment_schedule_id := P_PAYMENT_SCHEDULE_ID;
    l_adj_rec.RECEIVABLES_TRX_ID := P_RECEIVABLES_TRX_ID;
    l_adj_rec.apply_date := P_APPLY_DATE;
    l_adj_rec.gl_date := P_GL_DATE;
    l_adj_rec.created_from := G_PKG_NAME;
    l_adj_rec.amount := P_AMOUNT;
    l_adj_rec.customer_trx_line_id := P_CUSTOMER_TRX_LINE_ID;
    l_adj_rec.code_combination_id := P_CODE_COMBINATION_ID;
    --l_adj_rec.ussgl_transaction_code := P_USSGL_TRX_CODE;
    l_adj_rec.reason_code := P_REASON_CODE;
    l_adj_rec.comments := P_COMMENTS;
    l_adj_rec.org_id := P_ORG_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Sending following data to adjustment api:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.type: ' || l_adj_rec.type);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.payment_schedule_id: ' || l_adj_rec.payment_schedule_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.RECEIVABLES_TRX_ID: ' || l_adj_rec.RECEIVABLES_TRX_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.apply_date: ' || l_adj_rec.apply_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.gl_date: ' || l_adj_rec.gl_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.created_from: ' || l_adj_rec.created_from);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.amount: ' || l_adj_rec.amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.customer_trx_line_id: ' || l_adj_rec.customer_trx_line_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.code_combination_id: ' || l_adj_rec.code_combination_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.ussgl_transaction_code: ' || l_adj_rec.ussgl_transaction_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.reason_code: ' || l_adj_rec.reason_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.comments: ' || l_adj_rec.comments);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_rec.org_id: ' || l_adj_rec.org_id);

    /* Adjusting invoice */

    AR_ADJUST_PUB.Create_Adjustment(
        p_api_name => 'AR_ADJUST_PUB',
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_TRUE,
        p_commit_flag => FND_API.G_FALSE,
        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_return_status => l_return_status,
        p_adj_rec => l_adj_rec,
        p_chk_approval_limits => 'F',
        p_check_amount => 'F', --karamach Bug5092620
        p_new_adjust_number => l_adj_num,
        p_new_adjust_id => l_adj_id,
        p_org_id => P_ORG_ID);


    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_id: ' || l_adj_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_adj_num: ' || l_adj_num);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS or
        l_adj_id is null or
        l_adj_num is null
    THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_ADJ_FAIL');
        if l_return_status = FND_API.G_RET_STS_SUCCESS and l_adj_id is null then
		    FND_MESSAGE.SET_TOKEN('REASON', 'p_new_adjust_id = null');
        elsif l_return_status = FND_API.G_RET_STS_SUCCESS and l_adj_num is null then
		    FND_MESSAGE.SET_TOKEN('REASON', 'p_new_adjust_number = null');
        else
		    FND_MESSAGE.SET_TOKEN('REASON', ' ');
        end if;
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_count: ' || l_msg_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

        while (l_indexNo <= l_msg_Count ) loop
            fnd_msg_pub.get(l_indexNo, 'F', l_msg, l_index);
            LogMessage(FND_LOG.LEVEL_ERROR, 'Error: ' || l_msg);
            l_indexNo := l_indexNo + 1;
        End Loop;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    X_ADJ_ID := l_adj_id;
    X_ADJ_NUMBER := l_adj_num;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;




/*========================================================================
 | PRIVATE PROCEDURE BUILD_ERROR_STATEMENT
 |
 | DESCRIPTION
 |      This procedure builds error statement.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_BORROWER_ID         IN             Bborrower ID
 |       P_LOAN_ID             IN             Loans ID
 |       P_FROM_DAYS_TO_DD     IN             From days
 |       P_TO_DAYS_TO_DD       IN             To days
 |       X_REPORT_XML          OUT NOCOPY     Return full report xml
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
 | 04-21-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE BUILD_ERROR_STATEMENT(
        P_LOAN_ID           IN              NUMBER,
        P_PAYMENT_NUMBER    IN              NUMBER,
        P_PRIN_AMOUNT_DUE   IN              NUMBER,
        P_INT_AMOUNT_DUE    IN              NUMBER,
        P_FEE_AMOUNT_DUE    IN              NUMBER,
        P_DUE_DATE          IN              DATE,
        P_ERR_COUNT			IN              NUMBER,
        X_STATEMENT_XML     OUT NOCOPY      CLOB)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name          CONSTANT VARCHAR2(30) := 'BUILD_ERROR_STATEMENT';
    l_new_line          varchar2(1);
    l_statement         varchar2(2000);
    l_borrower          VARCHAR2(360);
    l_loan              VARCHAR2(60);
    l_currency          VARCHAR2(15);
    l_f_prin_amount     varchar2(50);
    l_f_int_amount      varchar2(50);
    l_f_fee_amount      varchar2(50);
    l_f_sum_amount      varchar2(50);
    l_index             number;
    l_indexNo           number;
    l_error             varchar2(500);
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query for loan number and borrower name */
    CURSOR loan_cur(P_LOAN_ID number, P_PRIN_AMOUNT_DUE number, P_INT_AMOUNT_DUE number, P_FEE_AMOUNT_DUE number) IS
        select party.party_name,
        loan.loan_number,
        loan.LOAN_CURRENCY,
        to_char(P_PRIN_AMOUNT_DUE, FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50)),
        to_char(P_INT_AMOUNT_DUE, FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50)),
        to_char(P_FEE_AMOUNT_DUE, FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50)),
        to_char((P_PRIN_AMOUNT_DUE + P_INT_AMOUNT_DUE + P_FEE_AMOUNT_DUE), FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50))
        from lns_loan_headers loan,
        hz_parties party
        where party.party_id = loan.PRIMARY_BORROWER_ID and
        loan.loan_id = P_LOAN_ID;

BEGIN

    l_index := 0;
    l_indexNo := 1;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    l_new_line := '
';

    /* query for loan number and borrower name */
    open loan_cur(P_LOAN_ID, P_PRIN_AMOUNT_DUE, P_INT_AMOUNT_DUE, P_FEE_AMOUNT_DUE);
    fetch loan_cur into l_borrower, l_loan, l_currency, l_f_prin_amount, l_f_int_amount, l_f_fee_amount, l_f_sum_amount;
    close loan_cur;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_borrower: ' || l_borrower);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan: ' || l_loan);

    /* build error */
    l_statement := '<LOAN>';
    l_statement := l_statement || l_new_line || '<LOAN_ID>' || P_LOAN_ID || '</LOAN_ID>';
    l_statement := l_statement || l_new_line || '<BILL_DATE>' || sysdate || '</BILL_DATE>';
    l_statement := l_statement || l_new_line || '<LOAN_NUMBER>' || l_loan || '</LOAN_NUMBER>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_NUMBER>' || P_PAYMENT_NUMBER || '</NEXT_PAYMENT_NUMBER>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_DUE_DATE>' || P_DUE_DATE || '</NEXT_PAYMENT_DUE_DATE>';
    l_statement := l_statement || l_new_line || '<F_NEXT_PAYMENT_PRINCIPAL_DUE>' || l_f_prin_amount || '</F_NEXT_PAYMENT_PRINCIPAL_DUE>';
    l_statement := l_statement || l_new_line || '<F_NEXT_PAYMENT_INTEREST_DUE>' || l_f_int_amount || '</F_NEXT_PAYMENT_INTEREST_DUE>';
    l_statement := l_statement || l_new_line || '<F_NEXT_PAYMENT_FEE_DUE>' || l_f_fee_amount || '</F_NEXT_PAYMENT_FEE_DUE>';
    l_statement := l_statement || l_new_line || '<F_NEXT_PAYMENT_TOTAL_DUE>' || l_f_sum_amount || '</F_NEXT_PAYMENT_TOTAL_DUE>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_PRINCIPAL_DUE>' || P_PRIN_AMOUNT_DUE || '</NEXT_PAYMENT_PRINCIPAL_DUE>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_INTEREST_DUE>' || P_INT_AMOUNT_DUE || '</NEXT_PAYMENT_INTEREST_DUE>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_FEE_DUE>' || P_FEE_AMOUNT_DUE || '</NEXT_PAYMENT_FEE_DUE>';
    l_statement := l_statement || l_new_line || '<NEXT_PAYMENT_TOTAL_DUE>' || (P_PRIN_AMOUNT_DUE + P_INT_AMOUNT_DUE + P_FEE_AMOUNT_DUE) || '</NEXT_PAYMENT_TOTAL_DUE>';
    l_statement := l_statement || l_new_line || '<BORROWER_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_borrower) || '</BORROWER_NAME>';
    l_statement := l_statement || l_new_line || '<LOAN_CURRENCY_CODE>' || l_currency || '</LOAN_CURRENCY_CODE>';

    l_statement := l_statement || l_new_line || '<ERROR>' || l_new_line;
    while (l_indexNo <= P_ERR_COUNT ) loop
        fnd_msg_pub.get(l_indexNo, 'F', l_error, l_index);
        l_error := LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_error);
        l_statement := l_statement || l_error;
        l_indexNo := l_indexNo + 1;
    End Loop;
    l_statement := l_statement || '</ERROR>';

    l_statement := l_statement || l_new_line || '</LOAN>';
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_statement: ' || l_statement);

    /* init statement xml */
    DBMS_LOB.createtemporary(X_STATEMENT_XML, FALSE, DBMS_LOB.CALL);
    DBMS_LOB.open(X_STATEMENT_XML, DBMS_LOB.lob_readwrite);

    /* building clob */
    DBMS_LOB.write(X_STATEMENT_XML, length(l_statement), 1, l_statement);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to generate error statement for loan ' || l_loan);
END;




/*========================================================================
 | PRIVATE PROCEDURE BUILD_BILLING_REPORT
 |
 | DESCRIPTION
 |      This procedure builds billing report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_BORROWER_ID         IN             Bborrower ID
 |       P_LOAN_ID             IN             Loans ID
 |       P_FROM_DAYS_TO_DD     IN             From days
 |       P_TO_DAYS_TO_DD       IN             To days
 |       X_REPORT_XML          OUT NOCOPY     Return full report xml
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
 | 04-21-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE BUILD_BILLING_REPORT(
        P_BORROWER_ID         IN             NUMBER,
        P_LOAN_ID             IN             NUMBER,
        P_FROM_DAYS_TO_DD     IN             NUMBER,
        P_TO_DAYS_TO_DD       IN             NUMBER,
        P_STATEMENTS_XML      IN             CLOB)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_BILLING_REPORT';
    l_new_line      varchar2(1);
    l_header        varchar2(1000);
    l_footer        varchar2(100);
    l_parameters    varchar2(1000);
    l_borrower      VARCHAR2(360);
    l_loan          VARCHAR2(60);
    l_from_days     varchar2(50);
    l_to_days       varchar2(50);
    l_org_name      VARCHAR2(240);
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query for borrower name */
    CURSOR borrower_cur(P_BORROWER_ID number) IS
    select party_name from hz_parties party where party_id = P_BORROWER_ID;

    /* query for loan number */
    CURSOR loan_cur(P_LOAN_ID number) IS
    select loan_number from lns_loan_headers where loan_id = P_LOAN_ID;

    /* query for org name */
    CURSOR org_cur(P_ORG_ID number) IS
    select name
    from hr_all_organization_units_tl
    where ORGANIZATION_ID = P_ORG_ID and
    language(+) = userenv('LANG');

BEGIN

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* init report clob */
    dbms_lob.createtemporary(g_last_billing_report, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_billing_report, dbms_lob.lob_readwrite);

    l_new_line := '
';
    l_header := '<?xml version="1.0" encoding="UTF-8"?>' || l_new_line || '<BILLBATCH>';
    l_footer := l_new_line || '</BILLBATCH>' || l_new_line;
    l_parameters := l_new_line || '<PARAMETERS>';

    /* adding org name to parameter list */
    open org_cur(g_org_id);
    fetch org_cur into l_org_name;
    close org_cur;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_org_name: ' || l_org_name);
    l_parameters := l_parameters || l_new_line || '<ORG_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_org_name) || '</ORG_NAME>';

    /* adding borrower to parameter list */
    if P_BORROWER_ID is not null then
        open borrower_cur(P_BORROWER_ID);
        fetch borrower_cur into l_borrower;
        close borrower_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_borrower: ' || l_borrower);
    l_parameters := l_parameters || l_new_line || '<BORROWER_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_borrower) || '</BORROWER_NAME>';

    /* adding loan to parameter list */
    if P_LOAN_ID is not null then
        open loan_cur(P_LOAN_ID);
        fetch loan_cur into l_loan;
        close loan_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan: ' || l_loan);
    l_parameters := l_parameters || l_new_line || '<LOAN_NUMBER>' || l_loan || '</LOAN_NUMBER>';

    /* adding from days to parameter list */
    if P_FROM_DAYS_TO_DD is not null then
        l_from_days := P_FROM_DAYS_TO_DD || GET_BILLING_DATE(P_FROM_DAYS_TO_DD);
    end if;
    l_parameters := l_parameters || l_new_line || '<FROM_DAYS_TO_DD>' || l_from_days || '</FROM_DAYS_TO_DD>';

    /* adding to days to parameter list */
    if P_TO_DAYS_TO_DD is not null then
        l_to_days := P_TO_DAYS_TO_DD || GET_BILLING_DATE(P_TO_DAYS_TO_DD);
    end if;
    l_parameters := l_parameters || l_new_line || '<TO_DAYS_TO_DD>' || l_to_days || '</TO_DAYS_TO_DD>';
    l_parameters := l_parameters || l_new_line || '</PARAMETERS>' || l_new_line;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_parameters: ' || l_parameters);


    /* add header to billing report */
    DBMS_LOB.write(g_last_billing_report, length(l_header), 1, l_header);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added header to report');

    /* add parameters to billing report */
    dbms_lob.writeAppend(g_last_billing_report, length(l_parameters), l_parameters);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added parameters to report');

    /* add all statements to billing report */
    if dbms_lob.getlength(P_STATEMENTS_XML) > 0 then
        DBMS_LOB.Append(g_last_billing_report, P_STATEMENTS_XML);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added statements to report');
    end if;

    /* add footer to billing report */
    dbms_lob.writeAppend(g_last_billing_report, length(l_footer), l_footer);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added footer to report');

    /* print report to output file */
    LNS_REP_UTILS.PRINT_CLOB(g_last_billing_report);  -- fix for bug 6938098
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Printed report into output file.');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to generate billing report');
        g_cr_return_status := 'WARNING';
END;



/*========================================================================
 | PUBLIC PROCEDURE GENERATE_BILLING_STATEMENT_XML
 |
 | DESCRIPTION
 |      This procedure creates the billing statement xml for single loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      BILL_SINGLE_LOAN
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | 06-21-2006            karamach          Added cursor c_get_currency_format_mask and changed query to improve performance to fix bug5264818
 |
 *=======================================================================*/
PROCEDURE GENERATE_BILLING_STATEMENT_XML(p_loan_id IN NUMBER,
                                         p_amortization_schedule_id IN NUMBER) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GENERATE_BILLING_STATEMENT_XML';
    qry_string                      Varchar2(12000);
--    qryCtx                          DBMS_XMLGEN.ctxHandle;
    qryCtx                          DBMS_XMLQuery.ctxType;
    result                          CLOB;
    l_current_phase                 varchar2(30);
    l_currency_format_mask          varchar2(4000);
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

 CURSOR c_get_currency_format_mask(pLoanId Number) is
 select FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50) mask
 from lns_loan_headers_all loan
 where loan.loan_id = pLoanId;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Getting Currency Format Mask for loan');
    OPEN c_get_currency_format_mask(p_loan_id);
    FETCH c_get_currency_format_mask INTO l_currency_format_mask;
    CLOSE c_get_currency_format_mask;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generating billing statement...');

    qry_string := 'SELECT loan.loan_id, ' ||
        'payment_summary.next_payment_amortization_id, ' ||
        'fnd_date.date_to_chardate(sysdate) bill_date, ' ||
        'loan.loan_number, ' ||
        'loan.LOAN_DESCRIPTION, ' ||
        'am.PAYMENT_NUMBER next_payment_number, ' ||
        'fnd_date.date_to_chardate(am.DUE_DATE) next_payment_due_date, ' ||
        'to_char(am.PRINCIPAL_AMOUNT, :CURRENCY_FORMAT1) f_next_payment_principal_due, ' ||
        'to_char(am.INTEREST_AMOUNT, :CURRENCY_FORMAT2) f_next_payment_interest_due, ' ||
        'to_char(am.FEE_AMOUNT, :CURRENCY_FORMAT3) f_next_payment_fee_due, ' ||
        'to_char((am.PRINCIPAL_AMOUNT+am.INTEREST_AMOUNT+am.FEE_AMOUNT), :CURRENCY_FORMAT4) f_next_payment_total_due, ' ||
        'am.PRINCIPAL_AMOUNT next_payment_principal_due, ' ||
        'am.INTEREST_AMOUNT next_payment_interest_due, ' ||
        'am.FEE_AMOUNT next_payment_fee_due, ' ||
        '(am.PRINCIPAL_AMOUNT+am.INTEREST_AMOUNT+am.FEE_AMOUNT) next_payment_total_due, ' ||
        'party.party_name Borrower_Name, ' ||
        'loc.address1 || '' '' || loc.city || '' '' || loc.state || '' '' || loc.postal_code || '' '' || terr.TERRITORY_SHORT_NAME Primary_Address, ' ||
        'party.jgzz_fiscal_code tax_id, ' ||
        'org.name operating_unit, ' ||
        'loan_type.loan_type_name loan_type, ' ||
        'loan_class.meaning loan_class, ' ||
        'loan.loan_term || '' '' || periodlkup.meaning loan_term, ' ||
        'to_char(LNS_FIN_UTILS.getActiveRate(loan.loan_id))  current_interest_rate, ' ||
        'fnd_date.date_to_chardate(loan.loan_maturity_date) loan_maturity_date, ' ||
        'to_char(payment_summary.total_principal_balance, :CURRENCY_FORMAT5) f_remaining_balance_amount, ' ||
        'to_char(payment_summary.principal_paid_todate, :CURRENCY_FORMAT6) f_principal_paid_todate, ' ||
        'to_char(payment_summary.interest_paid_todate, :CURRENCY_FORMAT7) f_interest_paid_todate, ' ||
        'to_char(payment_summary.fee_paid_todate, :CURRENCY_FORMAT8) f_fee_paid_todate, ' ||
        'to_char(payment_summary.total_prin_paid_todate, :CURRENCY_FORMAT9) f_total_prin_paid_todate, ' ||
        'to_char(payment_summary.principal_paid_ytd, :CURRENCY_FORMAT10) f_principal_paid_ytd, ' ||
        'to_char(payment_summary.interest_paid_ytd, :CURRENCY_FORMAT11) f_interest_paid_ytd, ' ||
        'to_char(payment_summary.fee_paid_ytd, :CURRENCY_FORMAT12) f_fee_paid_ytd, ' ||
        'to_char(payment_summary.principal_overdue, :CURRENCY_FORMAT13) f_principal_overdue, ' ||
        'to_char(payment_summary.interest_overdue, :CURRENCY_FORMAT14) f_interest_overdue, ' ||
        'to_char(payment_summary.fee_overdue, :CURRENCY_FORMAT15) f_fee_overdue, ' ||
        'to_char(payment_summary.total_overdue, :CURRENCY_FORMAT16) f_total_overdue, ' ||
        'payment_summary.total_principal_balance remaining_balance_amount, ' ||
        'payment_summary.principal_paid_todate principal_paid_todate, ' ||
        'payment_summary.interest_paid_todate interest_paid_todate, ' ||
        'payment_summary.fee_paid_todate fee_paid_todate, ' ||
        'payment_summary.total_prin_paid_todate total_prin_paid_todate, ' ||
        'payment_summary.principal_paid_ytd principal_paid_ytd, ' ||
        'payment_summary.interest_paid_ytd interest_paid_ytd, ' ||
        'payment_summary.fee_paid_ytd fee_paid_ytd, ' ||
        'payment_summary.principal_overdue principal_overdue, ' ||
        'payment_summary.interest_overdue interest_overdue, ' ||
        'payment_summary.fee_overdue fee_overdue, ' ||
        'payment_summary.total_overdue total_overdue, ' ||
        'payment_summary.number_overdue_bills number_of_overdue_payments, ' ||
        'fnd_date.date_to_chardate(payment_summary.last_overdue_date) last_overdue_date, ' ||
        'to_char(payment_summary.last_payment_amount, :CURRENCY_FORMAT17) f_last_payment_amount, ' ||
        'payment_summary.last_payment_amount last_payment_amount, ' ||
        'fnd_date.date_to_chardate(payment_summary.last_payment_date) last_payment_date, ' ||
        '(LNS_FIN_UTILS.getNumberInstallments(loan.loan_id, nvl(loan.current_phase, ''TERM'')) - payment_summary.next_payment_number) remaining_number_of_payments, ' ||
        'contact_person.party_name PRIMARY_LOAN_CONTACT, ' ||
        'loan.LOAN_CURRENCY LOAN_CURRENCY_CODE, ' ||
        'curr.name LOAN_CURRENCY_MEANING, ' ||
        'loan_subtype.meaning loan_subtype, ' ||
        'nvl(loan.current_phase, ''TERM'') phase, ' ||
        'rate_type.meaning rate_type, ' ||
        'int_rate_hdr.INTEREST_RATE_NAME index_rate, ' ||
        'rate_freq.meaning floating_frequency, ' ||
        'pay_freq.meaning payment_frequency, ' ||
        'fnd_date.date_to_chardate(terms.LOCK_IN_DATE) lock_date, ' ||
        'fnd_date.date_to_chardate(terms.LOCK_TO_DATE) lock_exp_date, ' ||
        'terms.CEILING_RATE Ceiling_Rate, ' ||
        'terms.FLOOR_RATE floor_rate, ' ||
        'loan.open_to_term_flag open_to_term, ' ||
        'open_to_term.meaning open_to_term_flag, ' ||
        'product.loan_product_name loan_product, ' ||
        'decode(nvl(loan.current_phase, ''TERM''), ''OPEN'',
            fnd_date.date_to_chardate(rate_sched1.INDEX_DATE), null) open_index_date, ' ||
        'decode(nvl(loan.current_phase, ''TERM''), ''OPEN'',
            rate_sched1.CURRENT_INTEREST_RATE, null) open_interest_rate, ' ||
        'decode(nvl(loan.current_phase, ''TERM''), ''OPEN'',
            fnd_date.date_to_chardate(rate_sched2.INDEX_DATE),
            fnd_date.date_to_chardate(rate_sched1.INDEX_DATE)) term_index_date, ' ||
        'decode(nvl(loan.current_phase, ''TERM''), ''OPEN'',
            rate_sched2.CURRENT_INTEREST_RATE,
            rate_sched1.CURRENT_INTEREST_RATE) term_interest_rate, ' ||
        'loan.MULTIPLE_FUNDING_FLAG, ' ||

        -- adding disbursement schedule
        'CURSOR ' ||
        '(select head.DISB_HEADER_ID, ' ||
        'head.DISBURSEMENT_NUMBER, ' ||
        'fnd_date.date_to_chardate(head.TARGET_DATE) TARGET_DATE, ' ||
        'fnd_date.date_to_chardate(head.PAYMENT_REQUEST_DATE) PAYMENT_REQUEST_DATE, ' ||
        'head.HEADER_PERCENT, ' ||
        'to_char(head.HEADER_AMOUNT, :CURRENCY_FORMAT18) f_header_amount, ' ||
        'fnd_date.date_to_chardate((select max(DISBURSEMENT_DATE) from lns_disb_lines where DISB_HEADER_ID = head.DISB_HEADER_ID)) DISBURSEMENT_DATE, ' ||
        'fund_status.meaning status, ' ||
        'fund_act.meaning activity_name ' ||
        'from lns_disb_headers head, ' ||
        'lns_lookups fund_status, ' ||
        'lns_lookups fund_act ' ||
        'where head.loan_id = loan.loan_id and ' ||
        'fund_status.lookup_type(+) = ''FUNDING_STATUS'' and ' ||
        'fund_status.lookup_code(+) = head.STATUS and ' ||
        'fund_act.lookup_type(+) = ''DISB_ACTIVITY'' and ' ||
        'fund_act.lookup_code(+) = head.ACTIVITY_CODE) ' ||
        'AS Disbursement_Schedule, ' ||

        -- adding payment history
        'CURSOR ' ||
        '(select amortization_schedule_id, ' ||
        'loan_id, ' ||
        'payment_number, ' ||
        'fnd_date.date_to_chardate(creation_date) bill_date, ' ||
        'fnd_date.date_to_chardate(last_applied_date) paid_date, ' ||
        'fnd_date.date_to_chardate(due_date) due_date, ' ||
        'to_char(principal_amount, :CURRENCY_FORMAT19) f_principal_amount, ' ||
        'to_char(interest_amount, :CURRENCY_FORMAT20) f_interest_amount, ' ||
        'to_char(fee_amount, :CURRENCY_FORMAT21) f_fee_amount, ' ||
        'to_char(total_billed_amount, :CURRENCY_FORMAT22) f_total_billed_amount, ' ||
        'to_char((PRINCIPAL_PAID + INTEREST_PAID + FEE_PAID), :CURRENCY_FORMAT23) f_total_payment_amount, '  ||
        'principal_amount principal_amount, ' ||
        'interest_amount interest_amount, ' ||
        'fee_amount fee_amount, ' ||
        'total_billed_amount total_billed_amount, ' ||
        '(PRINCIPAL_PAID + INTEREST_PAID + FEE_PAID) total_payment_amount '  ||
        'from lns_am_scheds_v payment_history ' ||
        'where payment_history.loan_id = loan.loan_id and ' ||
        'nvl(payment_history.PHASE, ''TERM'') = nvl(loan.CURRENT_PHASE, ''TERM'') and ' ||
        'payment_history.reversed_code = ''N'' and ' ||
        '(payment_history.payment_number between (payment_summary.next_payment_number - 2) and payment_summary.next_payment_number) and ' ||
        'payment_history.AMORTIZATION_SCHEDULE_ID < payment_summary.next_payment_amortization_id ' ||
        'order by payment_history.AMORTIZATION_SCHEDULE_ID) ' ||
        'AS Recent_Payment_History ' ||

        'FROM lns_loan_headers_all_vl loan, ' ||
        'hz_parties party, ' ||
        'fnd_territories_tl terr, ' ||
        'hr_all_organization_units_tl org, ' ||
        'LNS_PAYMENTS_SUMMARY_V payment_summary, ' ||
        'lns_amortization_scheds am, ' ||
        'hz_locations loc, ' ||
        'hz_cust_acct_sites_all acct_site, ' ||
        'hz_party_sites site, ' ||
        'fnd_currencies_tl curr, ' ||
        'hz_parties contact_person, ' ||
        'lns_loan_types_vl loan_type, ' ||
        'lns_lookups loan_class, ' ||
        'lns_lookups periodlkup, ' ||
        'lns_lookups loan_subtype, ' ||
        'lns_terms terms, ' ||
        'lns_int_rate_headers_vl int_rate_hdr, ' ||
        'lns_lookups rate_type, ' ||
        'lns_lookups rate_freq, ' ||
        'lns_lookups pay_freq, ' ||
        'fnd_lookups open_to_term, ' ||
        'lns_loan_products_vl product, ' ||
        'lns_rate_schedules rate_sched1, ' ||
        'lns_rate_schedules rate_sched2 ' ||

        'WHERE party.party_id = loan.primary_borrower_id and ' ||
        'org.organization_id = loan.org_id and ' ||
        'org.language = userenv(''LANG'') and ' ||
        'acct_site.cust_acct_site_id = loan.bill_to_acct_site_id and ' ||
        'acct_site.org_id = loan.org_id and ' ||
        'site.party_site_id = acct_site.party_site_id and ' ||
        'site.location_id = loc.location_id and ' ||
        'loc.country = terr.TERRITORY_CODE and ' ||
        'terr.language = userenv(''LANG'') and ' ||
        'loan.LOAN_CURRENCY = curr.currency_code and ' ||
        'curr.language = userenv(''LANG'') and ' ||
        'loan.contact_pers_party_id = contact_person.party_id(+) and ' ||
        'loan_type.loan_type_id = loan.loan_type_id AND ' ||
        'loan_class.lookup_type = ''LOAN_CLASS'' AND ' ||
        'loan_class.lookup_code = loan.loan_class_code AND ' ||
        'periodlkup.lookup_type = ''PERIOD'' and ' ||
        'periodlkup.lookup_code = loan.loan_term_period and ' ||
        'loan_subtype.lookup_type = ''LOAN_SUBTYPE'' and ' ||
        'loan_subtype.lookup_code = loan.loan_subtype and ' ||
        'loan.loan_id = payment_summary.loan_id and ' ||
        'loan.loan_id = terms.loan_id and ' ||
        'rate_type.lookup_type = ''RATE_TYPE'' and ' ||
        'rate_type.lookup_code = terms.RATE_TYPE and ' ||
        'terms.INDEX_RATE_ID = int_rate_hdr.INTEREST_RATE_ID(+) and ' ||
        'rate_freq.lookup_type(+) = ''FREQUENCY'' and ' ||
        'rate_freq.lookup_code(+) = terms.RATE_CHANGE_FREQUENCY and ' ||
        'pay_freq.lookup_type = ''FREQUENCY'' and ' ||
        'pay_freq.lookup_code = terms.LOAN_PAYMENT_FREQUENCY and ' ||
        'open_to_term.lookup_type = ''YES_NO'' and ' ||
        'open_to_term.lookup_code = nvl(loan.open_to_term_flag, ''N'') and ' ||
        'loan.product_id = product.LOAN_PRODUCT_ID(+) and ' ||
        'rate_sched1.term_id = terms.term_id and ' ||
        'rate_sched1.PHASE = nvl(loan.current_phase, ''TERM'') and ' ||
        '(decode(am.PAYMENT_NUMBER, 0, rate_sched1.begin_installment_number, -1) = 1 or ' ||
        'am.PAYMENT_NUMBER between rate_sched1.begin_installment_number and rate_sched1.end_installment_number) and ' ||
        'rate_sched1.end_date_active is null and ' ||
        'rate_sched2.term_id = terms.term_id and ' ||
        'rate_sched2.PHASE = ''TERM'' and ' ||
        'rate_sched2.begin_installment_number = 1 and  ' ||
        'rate_sched2.end_date_active is null and ' ||
        'loan.loan_id = am.loan_id and ' ||
        'am.AMORTIZATION_SCHEDULE_ID = payment_summary.next_payment_amortization_id and ' ||
        'nvl(am.phase, ''TERM'')  = nvl(loan.current_phase, ''TERM'') and ' ||
        'loan.loan_id = :LOAN_ID';

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Before set new context');
    qryCtx := DBMS_XMLQuery.newContext(qry_string);
--    qryCtx := DBMS_XMLGEN.newContext(qry_string);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'After set new context');

    -- set the rowset header to null
    DBMS_XMLQuery.setRowSetTag(qryCtx, 'LOANSET');
--    DBMS_XMLGEN.setRowSetTag(qryCtx, 'LOANSET');

    -- set the row tag name to be LOAN
     DBMS_XMLQuery.setRowTag(qryCtx, 'LOAN');
--    DBMS_XMLGEN.setRowTag(qryCtx, 'LOAN');

    --Set bind values
    DBMS_XMLQuery.setBindValue(qryCtx, 'LOAN_ID', p_loan_id);
--    DBMS_XMLGEN.setBindValue(qryCtx, 'LOAN_ID', p_loan_id);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT1', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT2', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT3', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT4', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT5', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT6', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT7', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT8', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT9', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT10', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT11', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT12', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT13', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT14', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT15', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT16', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT17', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT18', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT19', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT20', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT21', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT22', l_currency_format_mask);
	DBMS_XMLQuery.setBindValue(qryCtx, 'CURRENCY_FORMAT23', l_currency_format_mask);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Bind value: LOAN_ID = ' || p_loan_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Bind value: CURRENCY_FORMAT = ' || l_currency_format_mask);

    -- now get the result
        result := DBMS_XMLQuery.getXml(qryCtx);
--    result := DBMS_XMLGEN.getXml(qryCtx);
--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Result xml: ' || result);

    if (result is not null) then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generated billing statement');

        /* Update amortization table */
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating record in LNS_AMORTIZATION_SCHEDS...') ;

        LNS_AMORTIZATION_SCHEDS_PKG.Update_Statement(
            P_AMORTIZATION_SCHEDULE_ID => p_amortization_schedule_id
            ,P_STATEMENT_XML => result);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Update successfull!');

    else
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --close context
    DBMS_XMLQuery.closeContext(qryCtx);
--    DBMS_XMLGEN.closeContext(qryCtx);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
    	-- Bug#8848035 - Thow the user defined exception if it fails
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_BILL_STMT_GEN_FAIL');
	FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate billing statement');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
        RAISE FND_API.G_EXC_ERROR;

END GENERATE_BILLING_STATEMENT_XML;




PROCEDURE VALIDATE_PRIN_AMOUNT(P_LOAN_ID NUMBER, P_PRIN_AMOUNT NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_valid_amount      number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR verify_amount_cur(P_LOAN_ID number) IS
        select max(head.funded_amount) - nvl(sum(am.PRINCIPAL_AMOUNT), 0)
        from
            LNS_AMORTIZATION_SCHEDS am,
            lns_loan_headers head
        where
            head.loan_id = P_LOAN_ID
            and head.loan_id = am.LOAN_ID
            and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
            and nvl(am.PHASE, 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');
BEGIN

    /* verify amount that we will bill */
    open verify_amount_cur(P_LOAN_ID);
    fetch verify_amount_cur into l_valid_amount;
    close verify_amount_cur;

    if P_PRIN_AMOUNT > l_valid_amount then
--        FND_MESSAGE.SET_ENCODED('Principal bill amount cannot be greater than ' || l_valid_amount);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_PRIN_BILL_AMOUNT');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

END;



/*========================================================================
 | PRIVATE PROCEDURE BILL_SINGLE_LOAN
 |
 | DESCRIPTION
 |      This procedure process a single loan.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      BILL_LOANS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |      CREATE_AR_INVOICES
 |
 | PARAMETERS
 |      P_LOAN_REC          IN OUT NOCOPY       Loan record to bill
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                    Author            Description of Changes
 | 01-01-2004         scherkas         Created
 |
 *=======================================================================*/
PROCEDURE BILL_SINGLE_LOAN(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_REC          IN OUT NOCOPY     LNS_BILLING_BATCH_PUB.LOAN_TO_BILL_REC,
    X_STATEMENT_XML     OUT NOCOPY  CLOB,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_SINGLE_LOAN';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_org_id                        number;
    l_Count                         number;
    l_header_id                     number;
    l_Count1                        number;
    l_prin_bal                      number;
    l_billed_0th_yn                 varchar2(1);
    l_do_billing                    number;
    l_offset                        number(38);
    l_statement_xml                 clob;
    l_prin_balance                  number;
    l_start                         date;
    l_end                           date;
--    l_floating_flag                 varchar2(1);
   l_create_zero_instal            varchar2(1);
   l_profile_name                  VARCHAR2(240);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_amortization_rec              LNS_FINANCIALS.AMORTIZATION_REC;
    l_lines_tbl                     LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;
    l_fee_tbl                       LNS_FINANCIALS.FEES_TBL;
    l_is_disable_bill		varchar2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* check to start billing for 0-th installment */
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

    /* get statement after its billed */
    CURSOR get_statement_cur(P_LOAN_ID number) IS
        select STATEMENT_XML
        from LNS_LOAN_HEADERS loan,
        lns_amortization_scheds am
        where loan.loan_id = am.loan_id	and
        am.AMORTIZATION_SCHEDULE_ID = loan.LAST_AMORTIZATION_ID	and
        am.PAYMENT_NUMBER = loan.LAST_PAYMENT_NUMBER and
        loan.loan_id = P_LOAN_ID;

    -- getting loan version
    CURSOR loan_version_cur(P_LOAN_ID number) IS
        select OBJECT_VERSION_NUMBER
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;
/*
    cursor cur_floating(p_loan_id number, p_phase varchar2, p_installment number) is
    select nvl(floating_flag, 'N')
      from lns_rate_schedules rs
          ,lns_terms t
      where t.loan_id = p_loan_id
        and t.term_id = rs.term_id
        and rs.end_date_active is null
        and rs.phase = p_phase
        and p_installment between rs.begin_installment_number and rs.end_installment_number;
*/
BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT PROCESS_SINGLE_LOAN_PVT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

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


    dbms_lob.createtemporary(X_STATEMENT_XML, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(X_STATEMENT_XML, dbms_lob.lob_readwrite);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Processing loan ' || P_LOAN_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'LOAN ID: ' || P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'LOAN DESCRIPTION: ' || P_LOAN_REC.LOAN_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || P_LOAN_REC.FUNDED_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || P_LOAN_REC.FIRST_PAYMENT_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || P_LOAN_REC.NEXT_PAYMENT_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLED_FLAG: ' || P_LOAN_REC.BILLED_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_CURRENCY: ' || P_LOAN_REC.LOAN_CURRENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_ACCOUNT_ID: ' || P_LOAN_REC.CUST_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_TO_ADDRESS_ID: ' || P_LOAN_REC.BILL_TO_ADDRESS_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG: ' || P_LOAN_REC.CUSTOM_PAYMENTS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PAYMENT_FREQUENCY: ' || P_LOAN_REC.LOAN_PAYMENT_FREQUENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUMBER_GRACE_DAYS: ' || P_LOAN_REC.NUMBER_GRACE_DAYS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_APPLICATION_ORDER: ' || P_LOAN_REC.PAYMENT_APPLICATION_ORDER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || P_LOAN_REC.EXCHANGE_RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || P_LOAN_REC.EXCHANGE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || P_LOAN_REC.EXCHANGE_RATE);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'ORG ID: ' || P_LOAN_REC.ORG_ID);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'LE ID: ' || P_LOAN_REC.LEGAL_ENTITY_ID);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'CURRENT_PHASE: ' || P_LOAN_REC.CURRENT_PHASE);

    /* Check for loan data */
    if P_LOAN_REC.PAYMENT_APPLICATION_ORDER is null or
       P_LOAN_REC.FIRST_PAYMENT_DATE is null or
       P_LOAN_REC.NEXT_PAYMENT_DUE_DATE is null or
       P_LOAN_REC.LOAN_PAYMENT_FREQUENCY is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan misses some important data. Cannot proceed with billing of this loan.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_LOAN_MISS_DATA');
    	FND_MESSAGE.SET_TOKEN('LOAN', P_LOAN_REC.LOAN_NUMBER);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* getting current payment number */
    P_LOAN_REC.NEXT_PAYMENT_NUMBER := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT_2(P_LOAN_REC.LOAN_ID);

    if P_LOAN_REC.NEXT_PAYMENT_NUMBER = -1 then

        P_LOAN_REC.NEXT_PAYMENT_NUMBER := 0;

        /* check to start billing for 0-th installment */
        open do_billing_cur(P_LOAN_REC.LOAN_ID, P_LOAN_REC.CURRENT_PHASE);
        fetch do_billing_cur into l_do_billing;
        close do_billing_cur;

        if l_do_billing > 0 then

            LNS_BILLING_BATCH_PUB.PREBILL_SINGLE_LOAN(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                P_COMMIT			    => FND_API.G_FALSE,
                P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_ID               => P_LOAN_REC.LOAN_ID,
                X_BILLED_YN             => l_billed_0th_yn,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

            if l_return_status <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
            end if;

            if l_billed_0th_yn = 'Y' then

                /* get statement after its billed */
                open get_statement_cur(P_LOAN_REC.LOAN_ID);
                fetch get_statement_cur into l_statement_xml;
                close get_statement_cur;

                /* remove xml header */
                l_offset := DBMS_LOB.INSTR(lob_loc => l_statement_xml,
                                        pattern => '>',
                                        offset => 1,
                                        nth => 1);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Have removed header from the statement');

                /* copy generated statement to output */
                dbms_lob.copy(dest_lob => X_STATEMENT_XML,
                            src_lob => l_statement_xml,
                            amount => dbms_lob.getlength(l_statement_xml)-l_offset,
                            src_offset => l_offset+1);

                x_return_status := l_return_status;  --fix for bug 8830573
                return;
            end if;

        end if;

    end if;

    /* setting next payment number */
    P_LOAN_REC.NEXT_PAYMENT_NUMBER := P_LOAN_REC.NEXT_PAYMENT_NUMBER + 1;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENT_NUMBER: ' || P_LOAN_REC.NEXT_PAYMENT_NUMBER);

    /* new principal and interest amounts from getInstallment api */

    if P_LOAN_REC.CURRENT_PHASE = 'TERM' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getInstallment...');
        l_start := sysdate;
        lns_financials.getInstallment(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            p_commit => FND_API.G_FALSE,
            p_loan_Id => P_LOAN_REC.LOAN_ID,
            p_installment_number => P_LOAN_REC.NEXT_PAYMENT_NUMBER,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        l_end := sysdate;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'getInstallment Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getOpenInstallment...');
        l_start := sysdate;
        lns_financials.getOpenInstallment(
            p_init_msg_list => FND_API.G_TRUE,
            p_loan_Id => P_LOAN_REC.LOAN_ID,
            p_installment_number => P_LOAN_REC.NEXT_PAYMENT_NUMBER,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        l_end := sysdate;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'getOpenInstallment Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Data returned from lns_financials.getInstallment:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENT_NUMBER: ' || l_amortization_rec.INSTALLMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_amortization_rec.due_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_AMOUNT: ' || l_amortization_rec.PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_AMOUNT: ' || l_amortization_rec.INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_AMOUNT: ' || l_amortization_rec.FEE_AMOUNT);

    P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT := l_amortization_rec.PRINCIPAL_AMOUNT;
    P_LOAN_REC.NEXT_INTEREST_AMOUNT  := l_amortization_rec.INTEREST_AMOUNT;
    P_LOAN_REC.NEXT_FEE_AMOUNT       := l_amortization_rec.FEE_AMOUNT;
    P_LOAN_REC.RATE_ID               := l_amortization_rec.RATE_ID;
    P_LOAN_REC.NEXT_PAYMENT_DUE_DATE := l_amortization_rec.due_date;



    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Checking the Disable_billing_flag in '||l_api_name);
    l_is_disable_bill := IS_BILLING_DISABLED(P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_is_disable_bill is '||l_is_disable_bill);
    IF l_is_disable_bill = 'Y' THEN
    	    --  LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: BILLING is Disabled for the loan '||p_loan_rec.loan_number);
             FND_MESSAGE.SET_NAME('LNS', 'LNS_BILLING_DISABLED');
	     FND_MESSAGE.SET_TOKEN('LOAN_NUMBER', p_loan_rec.loan_number);
             FND_MSG_PUB.Add;
             LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
             RAISE FND_API.G_EXC_ERROR;
    END IF;


    /* checking for returned values */
    if l_amortization_rec.INSTALLMENT_NUMBER is null and
       l_amortization_rec.due_date is null
    then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'lns_financials.getInstallment returns no data. Nothing to bill. Returning.');
	return;

    end if;

    if (P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT is null or P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT = 0) and
       (P_LOAN_REC.NEXT_INTEREST_AMOUNT is null or P_LOAN_REC.NEXT_INTEREST_AMOUNT = 0) and
       (P_LOAN_REC.NEXT_FEE_AMOUNT is null or P_LOAN_REC.NEXT_FEE_AMOUNT = 0)
    then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'All amounts returned from lns_financials.getInstallment = 0. ');

	-- fix for bug 7000066: get LNS_CREATE_ZERO_INSTAL profile value to see if we need to create 0 amount installment
        l_create_zero_instal := NVL(FND_PROFILE.VALUE('LNS_CREATE_ZERO_INSTAL'), 'N');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LNS_CREATE_ZERO_INSTAL profile: ' || l_create_zero_instal);

        if l_create_zero_instal = 'N' then

            select USER_PROFILE_OPTION_NAME into l_profile_name
            from FND_PROFILE_OPTIONS_VL
            where PROFILE_OPTION_NAME = 'LNS_CREATE_ZERO_INSTAL';

            FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_BILL_ZERO_AMOUNT');
    		FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
         --   return;
        end if;

/*
            FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_AMOUNT_INST');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
*/
    end if;

/*  -- fix for bug 8272659: floating rate calculations are now replaced by LNS: Mass Update Floating Rate Loans cp

    -- begin raverma 12-5-2005 added support for floating loans
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'check if float postprocessing needed');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_REC.CURRENT_PHASE' || P_LOAN_REC.CURRENT_PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_REC.LOAN_ID' || P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_REC.NEXT_PAYMENT_NUMBER' || P_LOAN_REC.NEXT_PAYMENT_NUMBER);

    open cur_floating(P_LOAN_REC.LOAN_ID, P_LOAN_REC.CURRENT_PHASE, P_LOAN_REC.NEXT_PAYMENT_NUMBER);
    fetch cur_floating into l_floating_flag;
    close cur_floating;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_floating_flag ' || l_floating_flag);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'interest amount ' || P_LOAN_REC.NEXT_INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_REC.NEXT_PAYMENT_DUE_DATE ' || P_LOAN_REC.NEXT_PAYMENT_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_amortization_rec.RATE_CHANGE_FREQ ' || l_amortization_rec.RATE_CHANGE_FREQ);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_amortization_rec.rate_id ' || l_amortization_rec.rate_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_amortization_rec.rate_unadj ' || l_amortization_rec.rate_unadj);

    if P_LOAN_REC.NEXT_INTEREST_AMOUNT > 0 and l_floating_flag = 'Y' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BEFORE floating postProcessing');
         lns_financials.floatingRatePostProcessing(p_loan_id                  => P_LOAN_REC.LOAN_ID
                                                  ,p_init_msg_list            => FND_API.G_FALSE
                                                  ,p_commit                   => FND_API.G_FALSE
                                                  ,p_installment_number       => P_LOAN_REC.NEXT_PAYMENT_NUMBER
                                                  ,p_period_begin_date        => P_LOAN_REC.NEXT_PAYMENT_DUE_DATE
                                                  ,p_interest_adjustment_freq => l_amortization_rec.RATE_CHANGE_FREQ
                                                  ,p_annualized_interest_rate => l_amortization_rec.rate_unadj
                                                  ,p_rate_id                  => l_amortization_rec.rate_id
                                                  ,p_phase                    => P_LOAN_REC.CURRENT_PHASE
                                                  ,X_RETURN_STATUS            => l_return_status
                                                  ,X_MSG_COUNT                => l_msg_count
                                                  ,X_MSG_DATA                 => l_msg_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'after floating postProcessing');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'copying new rate ID for insert into Amortization Schedueles' || l_amortization_rec.RATE_ID);
        P_LOAN_REC.RATE_ID               := l_amortization_rec.RATE_ID;

        if l_return_status <> 'S' then
            RAISE FND_API.G_EXC_ERROR;
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'error in floating postProcessing ' || Sqlerrm);

        end if;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));
*/

    /* adding principal and interest amounts into lines table */
    l_Count1 := 1;
    l_lines_tbl(l_Count1).LINE_TYPE := 'PRIN';
    l_lines_tbl(l_Count1).LINE_AMOUNT := P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT;
/*
    l_Count1 := l_Count1 + 1;
    l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
    l_lines_tbl(l_Count1).LINE_AMOUNT := P_LOAN_REC.NEXT_INTEREST_AMOUNT;
*/

    if l_amortization_rec.NORMAL_INT_AMOUNT > 0 or l_amortization_rec.ADD_PRIN_INT_AMOUNT > 0 or
       l_amortization_rec.ADD_INT_INT_AMOUNT > 0 or l_amortization_rec.PENAL_INT_AMOUNT > 0
    then

        if l_amortization_rec.NORMAL_INT_AMOUNT > 0 then
            l_Count1 := l_Count1 + 1;
            l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
            l_lines_tbl(l_Count1).LINE_AMOUNT := l_amortization_rec.NORMAL_INT_AMOUNT;
            l_lines_tbl(l_Count1).LINE_DESC := 'Normal Interest';
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adding ' || l_lines_tbl(l_Count1).LINE_DESC || ' = ' || l_lines_tbl(l_Count1).LINE_AMOUNT);
        end if;
        if l_amortization_rec.ADD_PRIN_INT_AMOUNT > 0 then
            l_Count1 := l_Count1 + 1;
            l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
            l_lines_tbl(l_Count1).LINE_AMOUNT := l_amortization_rec.ADD_PRIN_INT_AMOUNT;
            l_lines_tbl(l_Count1).LINE_DESC := 'Additional Interest on Unpaid Principal';
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adding ' || l_lines_tbl(l_Count1).LINE_DESC || ' = ' || l_lines_tbl(l_Count1).LINE_AMOUNT);
        end if;
        if l_amortization_rec.ADD_INT_INT_AMOUNT > 0 then
            l_Count1 := l_Count1 + 1;
            l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
            l_lines_tbl(l_Count1).LINE_AMOUNT := l_amortization_rec.ADD_INT_INT_AMOUNT;
            l_lines_tbl(l_Count1).LINE_DESC := 'Additional Interest on Unpaid Interest';
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adding ' || l_lines_tbl(l_Count1).LINE_DESC || ' = ' || l_lines_tbl(l_Count1).LINE_AMOUNT);
        end if;
        if l_amortization_rec.PENAL_INT_AMOUNT > 0 then
            l_Count1 := l_Count1 + 1;
            l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
            l_lines_tbl(l_Count1).LINE_AMOUNT := l_amortization_rec.PENAL_INT_AMOUNT;
            l_lines_tbl(l_Count1).LINE_DESC := 'Penal Interest';
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adding ' || l_lines_tbl(l_Count1).LINE_DESC || ' = ' || l_lines_tbl(l_Count1).LINE_AMOUNT);
        end if;

    else

        l_Count1 := l_Count1 + 1;
        l_lines_tbl(l_Count1).LINE_TYPE := 'INT';
        l_lines_tbl(l_Count1).LINE_AMOUNT := P_LOAN_REC.NEXT_INTEREST_AMOUNT;

    end if;

    /* adding fee amounts into lines table */
    FOR l_Count IN 1..l_fee_tbl.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Fee #' || l_Count || ' Name: ' || l_fee_tbl(l_Count).FEE_NAME || ' Amount: ' || l_fee_tbl(l_Count).FEE_AMOUNT);

        l_Count1 := l_Count1 + 1;
        l_lines_tbl(l_Count1).LINE_REF_ID := l_fee_tbl(l_Count).FEE_ID;
        l_lines_tbl(l_Count1).LINE_TYPE := 'FEE';
        l_lines_tbl(l_Count1).LINE_DESC := l_fee_tbl(l_Count).FEE_NAME;
        l_lines_tbl(l_Count1).LINE_AMOUNT := l_fee_tbl(l_Count).FEE_AMOUNT;
        l_lines_tbl(l_Count1).FEE_SCHEDULE_ID := l_fee_tbl(l_Count).FEE_SCHEDULE_ID;

        /* added fee installment validation by raverma request */
        if l_amortization_rec.INSTALLMENT_NUMBER <> l_fee_tbl(l_Count).FEE_INSTALLMENT then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_FEE_INSTAL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        /* updating LNS_FEE_SCHEDULES with billed_flag = Y */
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_FEE_SCHEDULES with billed_flag = Y ...');
        UPDATE LNS_FEE_SCHEDULES
        SET
            BILLED_FLAG                     =     'Y',
            last_update_date                =     LNS_UTILITY_PUB.LAST_UPDATE_DATE,
            last_updated_by                 =     LNS_UTILITY_PUB.LAST_UPDATED_BY,
            last_update_login               =     LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
        WHERE
            FEE_SCHEDULE_ID = l_fee_tbl(l_Count).fee_schedule_id;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_FEE_SCHEDULES');

    END LOOP;

    /* validate principal amount */
    VALIDATE_PRIN_AMOUNT(P_LOAN_REC.LOAN_ID, P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT);

    /* late date */
    P_LOAN_REC.NEXT_PAYMENT_LATE_DATE := P_LOAN_REC.NEXT_PAYMENT_DUE_DATE + nvl(P_LOAN_REC.NUMBER_GRACE_DAYS, 0);

    /* inserting new record into LNS_AMORTIZATION_SCHEDS */
    l_prin_balance := null;
    if P_LOAN_REC.CURRENT_PHASE is not null and P_LOAN_REC.CURRENT_PHASE = 'OPEN' then
        l_prin_balance := P_LOAN_REC.FUNDED_AMOUNT;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting new record into LNS_AMORTIZATION_SCHEDS w following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'PAYMENT_NUMBER: ' || P_LOAN_REC.NEXT_PAYMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'DUE_DATE: ' || P_LOAN_REC.NEXT_PAYMENT_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LATE_DATE: ' || P_LOAN_REC.NEXT_PAYMENT_LATE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_AMOUNT: ' || P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_AMOUNT: ' || P_LOAN_REC.NEXT_INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_AMOUNT: ' || P_LOAN_REC.NEXT_FEE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RATE_ID: ' || P_LOAN_REC.RATE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_BALANCE: ' || l_prin_balance);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || P_LOAN_REC.CURRENT_PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || l_amortization_rec.FUNDED_AMOUNT);

    LNS_AMORTIZATION_SCHEDS_PKG.Insert_Row(
        X_AMORTIZATION_SCHEDULE_ID => P_LOAN_REC.NEXT_AMORTIZATION_ID
        ,P_LOAN_ID => P_LOAN_REC.LOAN_ID
        ,P_PAYMENT_NUMBER => P_LOAN_REC.NEXT_PAYMENT_NUMBER
        ,P_DUE_DATE => P_LOAN_REC.NEXT_PAYMENT_DUE_DATE
        ,P_LATE_DATE => P_LOAN_REC.NEXT_PAYMENT_LATE_DATE
        ,P_PRINCIPAL_AMOUNT => P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT
        ,P_INTEREST_AMOUNT => P_LOAN_REC.NEXT_INTEREST_AMOUNT
        ,P_FEE_AMOUNT => P_LOAN_REC.NEXT_FEE_AMOUNT
        ,P_REVERSED_FLAG => 'N'
        ,P_RATE_ID => P_LOAN_REC.RATE_ID
        ,P_OBJECT_VERSION_NUMBER => 1
	    ,P_PRINCIPAL_BALANCE => l_prin_balance
	    ,P_PHASE => P_LOAN_REC.CURRENT_PHASE
	    ,P_FUNDED_AMOUNT => l_amortization_rec.FUNDED_AMOUNT);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_SCHEDULE_ID: ' || P_LOAN_REC.NEXT_AMORTIZATION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted record into LNS_AMORTIZATION_SCHEDS');

    /* creating AR invoices */
    CREATE_AR_INVOICES(P_LOAN_REC, l_lines_tbl);

    /* updating loan header table */

    -- getting loan version
    open loan_version_cur(P_LOAN_REC.LOAN_ID);
    fetch loan_version_cur into P_LOAN_REC.OBJECT_VERSION_NUMBER;
    close loan_version_cur;

    l_loan_header_rec.loan_id := P_LOAN_REC.LOAN_ID;
    l_loan_header_rec.BILLED_FLAG := 'Y';
    l_loan_header_rec.LAST_BILLED_DATE := sysdate;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header info w following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLED_FLAG: ' || l_loan_header_rec.BILLED_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_BILLED_DATE: ' || l_loan_header_rec.LAST_BILLED_DATE);

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => P_LOAN_REC.OBJECT_VERSION_NUMBER,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
    ELSE
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_LOAN_HEADER_PUB.UPDATE_LOAN returned error: ' || substr(l_msg_data,1,225));
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;
    END IF;

    STORE_LAST_PAYMENT_NUMBER(P_LOAN_REC.LOAN_ID);

    /* Generate xml for printable billing statement */
    l_start := sysdate;

    GENERATE_BILLING_STATEMENT_XML(
					p_loan_id => P_LOAN_REC.LOAN_ID,
					p_amortization_schedule_id => P_LOAN_REC.NEXT_AMORTIZATION_ID);

    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Statement generation timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    /* get statement after it stored in db */
    open get_statement_cur(P_LOAN_REC.LOAN_ID);
    fetch get_statement_cur into l_statement_xml;
    close get_statement_cur;

    /* remove xml header */
    l_offset := DBMS_LOB.INSTR(lob_loc => l_statement_xml,
                              pattern => '>',
			                  offset => 1,
			                  nth => 1);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Have removed header from the statement');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_offset: ' || l_offset);

    /* copy generated statement to output */
    dbms_lob.copy(dest_lob => X_STATEMENT_XML,
                 src_lob => l_statement_xml,
                 amount => dbms_lob.getlength(l_statement_xml)-l_offset,
                 src_offset => l_offset+1);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Have copied generated statement to output');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan ' || P_LOAN_REC.LOAN_NUMBER);
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully processed loan ' || P_LOAN_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_REC.LOAN_NUMBER);
        g_cr_return_status := 'WARNING';

        /* building error statement */
        BUILD_ERROR_STATEMENT(P_LOAN_ID => P_LOAN_REC.LOAN_ID,
                         P_PAYMENT_NUMBER => P_LOAN_REC.NEXT_PAYMENT_NUMBER,
                         P_PRIN_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT, 0),
                         P_INT_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_INTEREST_AMOUNT, 0),
                         P_FEE_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_FEE_AMOUNT, 0),
                         P_DUE_DATE => P_LOAN_REC.NEXT_PAYMENT_DUE_DATE,
                         P_ERR_COUNT => x_msg_count,
                         X_STATEMENT_XML => X_STATEMENT_XML);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_REC.LOAN_NUMBER);
        g_cr_return_status := 'WARNING';

        /* building error statement */
        BUILD_ERROR_STATEMENT(P_LOAN_ID => P_LOAN_REC.LOAN_ID,
                         P_PAYMENT_NUMBER => P_LOAN_REC.NEXT_PAYMENT_NUMBER,
                         P_PRIN_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT, 0),
                         P_INT_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_INTEREST_AMOUNT, 0),
                         P_FEE_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_FEE_AMOUNT, 0),
                         P_DUE_DATE => P_LOAN_REC.NEXT_PAYMENT_DUE_DATE,
                         P_ERR_COUNT => x_msg_count,
                         X_STATEMENT_XML => X_STATEMENT_XML);

    WHEN OTHERS THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_REC.LOAN_NUMBER);
        g_cr_return_status := 'WARNING';

        /* building error statement */
        BUILD_ERROR_STATEMENT(P_LOAN_ID => P_LOAN_REC.LOAN_ID,
                         P_PAYMENT_NUMBER => P_LOAN_REC.NEXT_PAYMENT_NUMBER,
                         P_PRIN_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_PRINCIPAL_AMOUNT, 0),
                         P_INT_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_INTEREST_AMOUNT, 0),
                         P_FEE_AMOUNT_DUE => nvl(P_LOAN_REC.NEXT_FEE_AMOUNT, 0),
                         P_DUE_DATE => P_LOAN_REC.NEXT_PAYMENT_DUE_DATE,
                         P_ERR_COUNT => x_msg_count,
                         X_STATEMENT_XML => X_STATEMENT_XML);

END;

/*========================================================================
 | PRIVATE PROCEDURE CALC_SINGLE_LOAN_NEXT_DD
 |
 | DESCRIPTION
 |      This procedure recalculates next payment due date for single loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      CALC_PAST_DUE_LOANS_NEXT_DD
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_LOAN_NEXT_DD_REC  IN      Loan record that needs new due date
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
PROCEDURE CALC_SINGLE_LOAN_NEXT_DD(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_NEXT_DD_REC  IN          LNS_BILLING_BATCH_PUB.LOAN_NEXT_DD_REC,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CALC_SINGLE_LOAN_NEXT_DD';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_next_payment_due_date         date;
    l_object_version_number         number;
    l_term_id                       number;
    l_version_number                number;
    l_prin_bal                      number;
    l_cur_phase                     varchar2(30);
    l_end                           date;
    l_start                         date;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_amortization_rec              lns_financials.AMORTIZATION_REC;
    l_term_rec                      LNS_TERMS_PUB.loan_term_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR term_version_cur(P_LOAN_ID number) IS
        select TERM_ID,
        OBJECT_VERSION_NUMBER
        from LNS_TERMS
        where LOAN_ID = P_LOAN_ID;

    /* get loan current phase */
    CURSOR loan_cur_phase_cur(P_LOAN_ID number) IS
        select nvl(CURRENT_PHASE, 'TERM')
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT SINGLE_LOAN_NEXT_DD_PVT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

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
    l_start := sysdate;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Processing loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'loan_id: ' || P_LOAN_NEXT_DD_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'object_version: ' || P_LOAN_NEXT_DD_REC.OBJECT_VERSION_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'next_payment_number: ' || P_LOAN_NEXT_DD_REC.NEXT_PAYMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG: ' || P_LOAN_NEXT_DD_REC.CUSTOM_PAYMENTS_FLAG);

    /* get loan current phase */
    open loan_cur_phase_cur(P_LOAN_NEXT_DD_REC.LOAN_ID);
    fetch loan_cur_phase_cur into l_cur_phase;
    close loan_cur_phase_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CURRENT_PHASE: ' || l_cur_phase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Getting next payment due date from lns_financials.preProcessInstallment...');

    if l_cur_phase = 'TERM' then
        lns_financials.preProcessInstallment(
                P_API_VERSION => 1.0,
                P_INIT_MSG_LIST	=> FND_API.G_FALSE,
                P_COMMIT => FND_API.G_FALSE,
                p_loan_Id => P_LOAN_NEXT_DD_REC.LOAN_ID,
                p_installment_number => P_LOAN_NEXT_DD_REC.NEXT_PAYMENT_NUMBER,
                X_AMORTIZATION_REC => l_amortization_rec,
                X_RETURN_STATUS => l_return_status,
                X_MSG_COUNT => l_msg_count,
                X_MSG_DATA => l_msg_data);
    else
        lns_financials.preProcessOpenInstallment(
--                P_API_VERSION => 1.0,
                P_INIT_MSG_LIST	=> FND_API.G_FALSE,
                P_COMMIT => FND_API.G_FALSE,
                p_loan_Id => P_LOAN_NEXT_DD_REC.LOAN_ID,
                p_installment_number => P_LOAN_NEXT_DD_REC.NEXT_PAYMENT_NUMBER,
                X_AMORTIZATION_REC => l_amortization_rec,
                X_RETURN_STATUS => l_return_status,
                X_MSG_COUNT => l_msg_count,
                X_MSG_DATA => l_msg_data);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Returns from lns_financials.preProcessInstallment:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENT_NUMBER: ' || l_amortization_rec.INSTALLMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_amortization_rec.due_date);

    l_next_payment_due_date := l_amortization_rec.due_date;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'next_payment_due_date: ' || l_next_payment_due_date);

    if l_next_payment_due_date is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Next installment date is unknown.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_INST_DUE_DATE');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    -- RAISE FND_API.G_EXC_ERROR;

    end if;

    /* Updating loan header */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_LOAN_HEADER_ALL table...');

    l_loan_header_rec.loan_id := P_LOAN_NEXT_DD_REC.LOAN_ID;
    l_loan_header_rec.BILLED_FLAG := 'N';
    l_object_version_number := P_LOAN_NEXT_DD_REC.OBJECT_VERSION_NUMBER;

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_object_version_number,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
    ELSE
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_LOAN_HEADER_PUB.UPDATE_LOAN returned error: ' || substr(l_msg_data,1,225));
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* getting terms version for future update */
    open term_version_cur(P_LOAN_NEXT_DD_REC.LOAN_ID);
    fetch term_version_cur into l_term_id, l_version_number;
    close term_version_cur;

    /* Updating terms */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_terms w following values:');

    l_term_rec.TERM_ID := l_term_id;
    l_term_rec.LOAN_ID := P_LOAN_NEXT_DD_REC.LOAN_ID;

    if l_cur_phase is null or l_cur_phase = 'TERM' then
        l_term_rec.NEXT_PAYMENT_DUE_DATE := l_next_payment_due_date;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);
    elsif l_cur_phase = 'OPEN' then
        l_term_rec.OPEN_NEXT_PAYMENT_DATE := l_next_payment_due_date;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_NEXT_PAYMENT_DATE: ' || l_term_rec.OPEN_NEXT_PAYMENT_DATE);
    end if;

    LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_version_number,
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
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully processed loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SINGLE_LOAN_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SINGLE_LOAN_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
    WHEN OTHERS THEN
      ROLLBACK TO SINGLE_LOAN_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loan ' || P_LOAN_NEXT_DD_REC.LOAN_NUMBER);
END;



/*========================================================================
 | PUBLIC PROCEDURE LNS_BILLING_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to bill loans
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CALC_PAST_DUE_LOANS_NEXT_DD
 |      BILL_LOANS
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_BILLING_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        BORROWER_ID         IN             NUMBER,
        LOAN_ID             IN             NUMBER,
        FROM_DAYS_TO_DD     IN             NUMBER,
        TO_DAYS_TO_DD       IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	        number;
    l_return            boolean;
BEGIN

    g_cr_return_status := 'NORMAL';

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Processing paid off loans...-------->>');

    PROCESS_PAID_LOANS(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID => null,
        P_PAYOFF_DATE => sysdate,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Processing paid off loans that must be reactivated...-------->>');

    REACTIVATE_PAID_LOANS(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Recalculating due date for past due loans...-------->>');

    CALC_PAST_DUE_LOANS_NEXT_DD(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Billing loans...-------->>');

    /* bill loans and stores all last billed statements in g_last_all_statements */
    BILL_LOANS(
        P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_BORROWER_ID => BORROWER_ID,
        P_LOAN_ID => LOAN_ID,
        P_FROM_DAYS_TO_DD => FROM_DAYS_TO_DD,
        P_TO_DAYS_TO_DD => TO_DAYS_TO_DD,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    /* build billing report and stores it in g_last_billing_report */
    BUILD_BILLING_REPORT(P_BORROWER_ID => BORROWER_ID,
                         P_LOAN_ID => LOAN_ID,
                         P_FROM_DAYS_TO_DD => FROM_DAYS_TO_DD,
                         P_TO_DAYS_TO_DD => TO_DAYS_TO_DD,
                         P_STATEMENTS_XML => g_last_all_statements);

    if g_cr_return_status = 'WARNING' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Not all loans were billed successfully. Please review log file.');
    elsif g_cr_return_status = 'ERROR' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Billing process has failed. Please review log file.');
    end if;

END;



/*========================================================================
 | PUBLIC PROCEDURE LNS_RVRS_PMT_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to bill loans
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      REVERSE_LAST_AMORTIZATION
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_RVRS_PMT_CONCUR(
        ERRBUF              OUT NOCOPY     VARCHAR2,
        RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_ID             IN             NUMBER,
        REBILL_FLAG         IN             VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	number;
    l_return    boolean;

BEGIN

    g_cr_return_status := 'NORMAL';

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Reversing a loans last payment...-------->>');

    REVERSE_LAST_AMORTIZATION(
        P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID => LOAN_ID,
        P_REBILL_FLAG => REBILL_FLAG,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    if g_cr_return_status = 'WARNING' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Reversing process has succeeded with warnings. Please review log file.');
    elsif g_cr_return_status = 'ERROR' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Reversing process has failed. Please review log file.');
    end if;

END;



/*========================================================================
 | PUBLIC PROCEDURE LNS_ADJUST_RECEIV_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to adjust original receivables for a loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      ADJUST_ORIGINAL_RECEIVABLE
 |      LogMessage
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
        LOAN_ID             IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	number;
    l_return    boolean;

BEGIN

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');

    ADJUST_ORIGINAL_RECEIVABLE(
        P_API_VERSION => 1.0,
        P_INIT_MSG_LIST	=> FND_API.G_TRUE,
        P_COMMIT => FND_API.G_TRUE,
        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_ID => LOAN_ID,
        X_RETURN_STATUS	=> RETCODE,
        X_MSG_COUNT	=> l_msg_count,
        X_MSG_DATA => ERRBUF);

    if RETCODE <> 'S' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'ERROR',
			            message => 'Adjustment of original receivable has failed. Please review log file.');
    end if;

END;


/*========================================================================
 | PRIVATE PROCEDURE BILL_LOANS_EXT
 |
 | DESCRIPTION
 |      This procedure process passed loans table
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BILLING_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      BILL_SINGLE_LOAN
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_LOANS_TO_BILL_TBL IN          Inputs table of loans to be billed
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
 | 27-06-2008            scherkas          Created for bug 7129399: bill passed loans table
 |
 *=======================================================================*/
PROCEDURE BILL_LOANS_EXT(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOANS_TO_BILL_TBL IN          LNS_BILLING_BATCH_PUB.LOANS_TO_BILL_TBL,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_LOANS_EXT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_Count1                        number;
    l_new_line                      varchar2(1);
    l_error_statements_xml          clob;
    l_error_header                  varchar2(20);
    l_error_footer                  varchar2(20);
    l_single_statement_xml          clob;
    l_start                         date;
    l_end                           date;
    l_start1                        date;
    l_end1                          date;

    l_loans_to_bill_tbl		        LNS_BILLING_BATCH_PUB.LOANS_TO_BILL_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT BILL_LOANS_EXT_PVT;
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

    l_loans_to_bill_tbl := P_LOANS_TO_BILL_TBL;

    dbms_lob.createtemporary(l_error_statements_xml, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(l_error_statements_xml, dbms_lob.lob_readwrite);

    /* bill all selected loans */
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Billing loans...');
    FOR l_Count1 IN 1..l_loans_to_bill_tbl.COUNT LOOP

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Processing loan #' || l_Count1);

        BEGIN

            SAVEPOINT BILL_LOANS_EXT_PVT1;

            l_start := sysdate;
            BILL_SINGLE_LOAN(
                    P_API_VERSION => 1.0,
                    P_INIT_MSG_LIST	=> FND_API.G_TRUE,
                    P_COMMIT => FND_API.G_FALSE,
                    P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                    P_LOAN_REC => l_loans_to_bill_tbl(l_Count1),
                    X_STATEMENT_XML => l_single_statement_xml,
                    X_RETURN_STATUS	=> l_return_status,
                    X_MSG_COUNT => l_msg_count,
                    X_MSG_DATA => l_msg_data);

            l_end := sysdate;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Billing timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

            IF l_return_status = 'S' THEN   /* append to all statements clob */

                -- loan forgiveness adjustment: fix for bug 7387659
                if l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG = 'Y' and
                   l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT > 0 and
                   g_forgiveness_rec_trx_id is not null then

                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Performing loan forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID || '...');
                    l_start1 := sysdate;
                    FORGIVENESS_ADJUSTMENT(
                            P_API_VERSION => 1.0,
                            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
                            P_COMMIT => FND_API.G_FALSE,
                            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                            P_LOAN_ID => l_loans_to_bill_tbl(l_Count1).LOAN_ID,
                            X_RETURN_STATUS	=> l_return_status,
                            X_MSG_COUNT => l_msg_count,
                            X_MSG_DATA => l_msg_data);

                    l_end1 := sysdate;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Forgiveness adjustment timing: ' || round((l_end1 - l_start1)*86400, 2) || ' sec');

                    IF l_return_status = 'S' THEN
                        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully performed forgiveness adjustment.');
                    ELSE
--                        g_cr_return_status := 'WARNING';
--                        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to perform forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_FORGIVENESS_FAIL');
                        FND_MSG_PUB.Add;
                        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                else
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Will not perform loan forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID);
                end if;

                dbms_lob.Append(g_last_all_statements, l_single_statement_xml);

                if P_COMMIT = FND_API.G_TRUE then
                    COMMIT WORK;
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
                end if;

            ELSE    /* otherwise append to errors clob */

                dbms_lob.Append(l_error_statements_xml, l_single_statement_xml);

            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO BILL_LOANS_EXT_PVT1;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
                g_cr_return_status := 'WARNING';

                /* building error statement */
                BUILD_ERROR_STATEMENT(P_LOAN_ID => l_loans_to_bill_tbl(l_Count1).LOAN_ID,
                                P_PAYMENT_NUMBER => l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_NUMBER,
                                P_PRIN_AMOUNT_DUE => nvl(l_loans_to_bill_tbl(l_Count1).NEXT_PRINCIPAL_AMOUNT, 0),
                                P_INT_AMOUNT_DUE => nvl(l_loans_to_bill_tbl(l_Count1).NEXT_INTEREST_AMOUNT, 0),
                                P_FEE_AMOUNT_DUE => nvl(l_loans_to_bill_tbl(l_Count1).NEXT_FEE_AMOUNT, 0),
                                P_DUE_DATE => l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_DUE_DATE,
                                P_ERR_COUNT => x_msg_count,
                                X_STATEMENT_XML => l_single_statement_xml);

                dbms_lob.Append(l_error_statements_xml, l_single_statement_xml);
        END;

    END LOOP;

    /* if there are errors, add errors section */
    if dbms_lob.getlength(l_error_statements_xml) > 0 then

        l_new_line := '
';
        l_error_header := l_new_line || '<ERRORS>' || l_new_line;
        l_error_footer := l_new_line || '</ERRORS>' || l_new_line;
        dbms_lob.writeAppend(g_last_all_statements, length(l_error_header), l_error_header);
        dbms_lob.Append(g_last_all_statements, l_error_statements_xml);
        dbms_lob.writeAppend(g_last_all_statements, length(l_error_footer), l_error_footer);

    end if;

    IF l_return_status <> 'S' THEN
	-- Above the error statements are created and now raise the error
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || l_loans_to_bill_tbl.COUNT || ' loan(s)');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loans');
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
        ROLLBACK TO BILL_LOANS_EXT_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BILL_LOANS_EXT_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN OTHERS THEN
        ROLLBACK TO BILL_LOANS_EXT_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
END;




/*========================================================================
 | PUBLIC PROCEDURE BILL_LOANS
 |
 | DESCRIPTION
 |      This procedure process all available loans
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BILLING_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      BILL_SINGLE_LOAN
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
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
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_LOANS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_Count1                        number;
    l_borrower_id                   number;
    l_loan_id                       number;
    l_from_date                     number;
    l_to_date                       number;
    l_new_line                      varchar2(1);
    l_error_statements_xml          clob;
    l_error_header                  varchar2(20);
    l_error_footer                  varchar2(20);
    l_single_statement_xml          clob;
    l_start                         date;
    l_end                           date;
    l_start1                        date;
    l_end1                          date;

    l_loans_to_bill_tbl		        LNS_BILLING_BATCH_PUB.LOANS_TO_BILL_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* get all loans to bill in all stages */
    CURSOR loans_to_bill_cur(P_BORROWER_ID number, P_LOAN_ID number, P_FROM_DAYS_TO_DD number, P_TO_DAYS_TO_DD number) IS
        select
            head.LOAN_ID,
            head.LOAN_NUMBER,
            head.LOAN_DESCRIPTION,
            head.OBJECT_VERSION_NUMBER,
            head.FUNDED_AMOUNT,
            head.BILL_TO_ACCT_SITE_ID,
            decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_FIRST_PAYMENT_DATE, term.FIRST_PAYMENT_DATE),
            decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE),
            nvl(head.BILLED_FLAG, 'N'),
            head.LOAN_CURRENCY,
            head.CUST_ACCOUNT_ID,
            decode(head.CURRENT_PHASE, 'OPEN', 'N', head.CUSTOM_PAYMENTS_FLAG),
            decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_PAYMENT_FREQUENCY, term.LOAN_PAYMENT_FREQUENCY),
            term.NUMBER_GRACE_DAYS,
            term.PAYMENT_APPLICATION_ORDER,
            head.EXCHANGE_RATE_TYPE,
            head.EXCHANGE_DATE,
            head.EXCHANGE_RATE,
            head.ORG_ID,
            head.LEGAL_ENTITY_ID,
            nvl(head.CURRENT_PHASE, 'TERM'),
            nvl(head.FORGIVENESS_FLAG, 'N'),
            nvl(head.FORGIVENESS_PERCENT, 0),
	    nvl(head.DISABLE_BILLING_FLAG, 'N')
        from LNS_LOAN_HEADERS head,
            LNS_TERMS term
        where head.LOAN_STATUS in ('ACTIVE', 'DEFAULT', 'DELINQUENT')
            and head.loan_id = term.loan_id
            and LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(head.LOAN_ID) < LNS_FIN_UTILS.getNumberInstallments(head.LOAN_ID, nvl(head.current_phase, 'TERM'))
	    and (head.BILLED_FLAG is null or head.BILLED_FLAG = 'N')
            and head.PRIMARY_BORROWER_ID = nvl(P_BORROWER_ID, head.PRIMARY_BORROWER_ID)
            and head.LOAN_ID = nvl(P_LOAN_ID, head.LOAN_ID)
            and (trunc(decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE)) - trunc(sysdate))
				>= nvl(P_FROM_DAYS_TO_DD, trunc(decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE)) - trunc(sysdate))
            and (trunc(decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE)) - trunc(sysdate))
				<= nvl(P_TO_DAYS_TO_DD, trunc(decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE)) - trunc(sysdate))
        ORDER BY head.LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT BILL_LOANS_PVT;
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

    /* init all_statements clob */
    dbms_lob.createtemporary(g_last_all_statements, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_all_statements, dbms_lob.lob_readwrite);

    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Passed input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Borrower ID: ' || P_BORROWER_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'From Days/Date: ' || P_FROM_DAYS_TO_DD || GET_BILLING_DATE(P_FROM_DAYS_TO_DD));
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'To Days/Date: ' || P_TO_DAYS_TO_DD || GET_BILLING_DATE(P_TO_DAYS_TO_DD));

    /* making decision what to do */
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Using following parameters:');

    if P_LOAN_ID is not null then   -- if loan_id is passed - ignore all other input parameters

        l_loan_id := P_LOAN_ID;
        l_borrower_id := null;
        l_from_date := null;
        l_to_date := null;

        LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Loan ID: ' || l_loan_id);

    elsif P_BORROWER_ID is null and P_FROM_DAYS_TO_DD is null and P_TO_DAYS_TO_DD is null then

        if g_days_to_bill_before_dd is null then
--          LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: At least one of the days must be set.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_BILLING_INP_PAR');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        else
            l_to_date := g_days_to_bill_before_dd;
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'To Days/Date: ' || l_to_date || GET_BILLING_DATE(l_to_date));
        end if;


    else

        l_loan_id := null;
        l_borrower_id := P_BORROWER_ID;
        l_from_date := P_FROM_DAYS_TO_DD;
        l_to_date := P_TO_DAYS_TO_DD;

        if l_borrower_id is not null then
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Borrower ID: ' || l_borrower_id);
        end if;

        if l_from_date is not null then
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'From Days/Date: ' || l_from_date || GET_BILLING_DATE(l_from_date));
        end if;

        if l_to_date is not null then
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'To Days/Date: ' || l_to_date || GET_BILLING_DATE(l_to_date));
        end if;

    end if;

    /* quering for loans */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching for not billed yet loans to process...');

    open loans_to_bill_cur(l_borrower_id, l_loan_id, l_from_date, l_to_date);

    l_Count1 := 0;

    LOOP

        l_Count1 := l_Count1+1;

        fetch loans_to_bill_cur into
            l_loans_to_bill_tbl(l_Count1).LOAN_ID,
            l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER,
            l_loans_to_bill_tbl(l_Count1).LOAN_DESCRIPTION,
            l_loans_to_bill_tbl(l_Count1).OBJECT_VERSION_NUMBER,
            l_loans_to_bill_tbl(l_Count1).FUNDED_AMOUNT,
            l_loans_to_bill_tbl(l_Count1).BILL_TO_ADDRESS_ID,
            l_loans_to_bill_tbl(l_Count1).FIRST_PAYMENT_DATE,
            l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_DUE_DATE,
            l_loans_to_bill_tbl(l_Count1).BILLED_FLAG,
            l_loans_to_bill_tbl(l_Count1).LOAN_CURRENCY,
            l_loans_to_bill_tbl(l_Count1).CUST_ACCOUNT_ID,
            l_loans_to_bill_tbl(l_Count1).CUSTOM_PAYMENTS_FLAG,
            l_loans_to_bill_tbl(l_Count1).LOAN_PAYMENT_FREQUENCY,
            l_loans_to_bill_tbl(l_Count1).NUMBER_GRACE_DAYS,
            l_loans_to_bill_tbl(l_Count1).PAYMENT_APPLICATION_ORDER,
            l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE_TYPE,
            l_loans_to_bill_tbl(l_Count1).EXCHANGE_DATE,
            l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE,
            l_loans_to_bill_tbl(l_Count1).ORG_ID,
            l_loans_to_bill_tbl(l_Count1).LEGAL_ENTITY_ID,
            l_loans_to_bill_tbl(l_Count1).CURRENT_PHASE,
            l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG,
            l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT,
	    l_loans_to_bill_tbl(l_Count1).DISABLE_BILLING_FLAG;

        exit when loans_to_bill_cur%NOTFOUND;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan #' || l_Count1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_DESCRIPTION: ' || l_loans_to_bill_tbl(l_Count1).LOAN_DESCRIPTION);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || l_loans_to_bill_tbl(l_Count1).FUNDED_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_TO_ADDRESS_ID: ' || l_loans_to_bill_tbl(l_Count1).BILL_TO_ADDRESS_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || l_loans_to_bill_tbl(l_Count1).FIRST_PAYMENT_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_DUE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLED_FLAG: ' || l_loans_to_bill_tbl(l_Count1).BILLED_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_CURRENCY: ' || l_loans_to_bill_tbl(l_Count1).LOAN_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_ACCOUNT_ID: ' || l_loans_to_bill_tbl(l_Count1).CUST_ACCOUNT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG: ' || l_loans_to_bill_tbl(l_Count1).CUSTOM_PAYMENTS_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PAYMENT_FREQUENCY: ' || l_loans_to_bill_tbl(l_Count1).LOAN_PAYMENT_FREQUENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUMBER_GRACE_DAYS: ' || l_loans_to_bill_tbl(l_Count1).NUMBER_GRACE_DAYS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_APPLICATION_ORDER: ' || l_loans_to_bill_tbl(l_Count1).PAYMENT_APPLICATION_ORDER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE_TYPE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORG_ID: ' || l_loans_to_bill_tbl(l_Count1).ORG_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LEGAL_ENTITY_ID: ' || l_loans_to_bill_tbl(l_Count1).LEGAL_ENTITY_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CURRENT_PHASE: ' || l_loans_to_bill_tbl(l_Count1).CURRENT_PHASE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG: ' || l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT: ' || l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT);
	LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISABLE_BILLING_FLAG : ' || l_loans_to_bill_tbl(l_Count1).DISABLE_BILLING_FLAG);

    END LOOP;

    close loans_to_bill_cur;

    l_Count := l_loans_to_bill_tbl.count;
    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Total found ' || l_Count || ' loan(s) to process');

    if l_Count > 0 then

        dbms_lob.createtemporary(l_error_statements_xml, FALSE, DBMS_LOB.CALL);
        dbms_lob.open(l_error_statements_xml, dbms_lob.lob_readwrite);

        /* bill all selected loans */
        FOR l_Count1 IN 1..l_loans_to_bill_tbl.COUNT LOOP

            LogMessage(FND_LOG.LEVEL_PROCEDURE, ' ');
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Processing loan #' || l_Count1);

            l_start := sysdate;
            BILL_SINGLE_LOAN(
            		P_API_VERSION => 1.0,
            		P_INIT_MSG_LIST	=> FND_API.G_FALSE,
            		P_COMMIT => P_COMMIT,
            		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                    P_LOAN_REC => l_loans_to_bill_tbl(l_Count1),
                    X_STATEMENT_XML => l_single_statement_xml,
            		X_RETURN_STATUS	=> l_return_status,
            		X_MSG_COUNT => l_msg_count,
            		X_MSG_DATA => l_msg_data);

            l_end := sysdate;
            LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Total billing timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

            IF l_return_status = 'S' THEN   /* append to all statements clob */

                dbms_lob.Append(g_last_all_statements, l_single_statement_xml);

	            -- loan forgiveness adjustment: fix for bug 7387659
	            if l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG = 'Y' and
	               l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT > 0 and
	               g_forgiveness_rec_trx_id is not null then

	                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Performing loan forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID || '...');
	                l_start1 := sysdate;
	                FORGIVENESS_ADJUSTMENT(
	                        P_API_VERSION => 1.0,
	                        P_INIT_MSG_LIST	=> FND_API.G_FALSE,
	                        P_COMMIT => P_COMMIT,
	                        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
	                        P_LOAN_ID => l_loans_to_bill_tbl(l_Count1).LOAN_ID,
	                        X_RETURN_STATUS	=> l_return_status,
	                        X_MSG_COUNT => l_msg_count,
	                        X_MSG_DATA => l_msg_data);

	                IF l_return_status = 'S' THEN
	                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully performed forgiveness adjustment.');
	                ELSE
	                    g_cr_return_status := 'WARNING';
	                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to perform forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
	                END IF;

	                l_end1 := sysdate;
	                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Forgiveness adjustment timing: ' || round((l_end1 - l_start1)*86400, 2) || ' sec');

	            else
	                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Will not perform loan forgiveness adjustment for loan ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID);
	            end if;

            ELSE    /* otherwise append to errors clob */

                dbms_lob.Append(l_error_statements_xml, l_single_statement_xml);

            END IF;

        END LOOP;

        /* if there are errors, add errors section */
        if dbms_lob.getlength(l_error_statements_xml) > 0 then

            l_new_line := '
';
            l_error_header := l_new_line || '<ERRORS>' || l_new_line;
            l_error_footer := l_new_line || '</ERRORS>' || l_new_line;
            dbms_lob.writeAppend(g_last_all_statements, length(l_error_header), l_error_header);
            dbms_lob.Append(g_last_all_statements, l_error_statements_xml);
            dbms_lob.writeAppend(g_last_all_statements, length(l_error_footer), l_error_footer);

        end if;


    END IF;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, '______________');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Total processed ' || (l_Count1-1) || ' loan(s)');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loans');
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
        ROLLBACK TO BILL_LOANS_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BILL_LOANS_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN OTHERS THEN
        ROLLBACK TO BILL_LOANS_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
END;



/*========================================================================
 | PUBLIC PROCEDURE CALC_PAST_DUE_LOANS_NEXT_DD
 |
 | DESCRIPTION
 |      This procedure recalculates next payment due date for all past due loans
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BILLING_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CALC_SINGLE_LOAN_NEXT_DD
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CALC_PAST_DUE_LOANS_NEXT_DD(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CALC_PAST_DUE_LOANS_NEXT_DD';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_org_id                        number;
    l_Count1                        number;
    l_next_payment_due_date         date;
    l_end                           date;
    l_start                         date;

    l_loans_next_dd_rec             LNS_BILLING_BATCH_PUB.LOAN_NEXT_DD_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR past_due_loans_cur IS
        select
            head.LOAN_ID,
            head.LOAN_NUMBER,
            head.OBJECT_VERSION_NUMBER,
            LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(head.LOAN_ID) + 1,
            head.CUSTOM_PAYMENTS_FLAG
        from LNS_LOAN_HEADERS head,
            LNS_TERMS term
        where head.LOAN_STATUS in ('ACTIVE', 'DEFAULT', 'DELINQUENT')
            and head.loan_id = term.loan_id
            and (head.BILLED_FLAG = 'Y' or head.BILLED_FLAG is null)  -- scherkas; fix for bug 5687852
            and LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(head.LOAN_ID) < LNS_FIN_UTILS.getNumberInstallments(head.LOAN_ID, nvl(head.current_phase, 'TERM'))
            and trunc(decode(head.CURRENT_PHASE, 'OPEN', term.OPEN_NEXT_PAYMENT_DATE, term.NEXT_PAYMENT_DUE_DATE) + nvl(term.NUMBER_GRACE_DAYS, 0)) < trunc(sysdate)
        ORDER BY head.LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT LOANS_NEXT_DD_PVT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

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

    init;

    /* quering for loans past due */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching for loans to process...');

    l_start := sysdate;
    open past_due_loans_cur;

    l_Count1 := 1;

    LOOP

            fetch past_due_loans_cur into
                l_loans_next_dd_rec.LOAN_ID,
                l_loans_next_dd_rec.LOAN_NUMBER,
                l_loans_next_dd_rec.OBJECT_VERSION_NUMBER,
                l_loans_next_dd_rec.NEXT_PAYMENT_NUMBER,
                l_loans_next_dd_rec.CUSTOM_PAYMENTS_FLAG;

            exit when past_due_loans_cur%NOTFOUND;

            l_Count1 := l_Count1+1;

            CALC_SINGLE_LOAN_NEXT_DD(
        		P_API_VERSION => 1.0,
        		P_INIT_MSG_LIST	=> FND_API.G_FALSE,
        		P_COMMIT => P_COMMIT,
        		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_NEXT_DD_REC => l_loans_next_dd_rec,
        		X_RETURN_STATUS	=> l_return_status,
        		X_MSG_COUNT => l_msg_count,
        		X_MSG_DATA => l_msg_data);

    END LOOP;

    close past_due_loans_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || (l_Count1-1) || ' loan(s)');
    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'All Recalc Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loans');
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
      ROLLBACK TO LOANS_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOANS_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
    WHEN OTHERS THEN
      ROLLBACK TO LOANS_NEXT_DD_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked loans');
END;



/*========================================================================
 | PUBLIC PROCEDURE REVERSE_LAST_AMORTIZATION
 |
 | DESCRIPTION
 |      This procedure reverses a loans last bill
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_RVRS_PMT_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CREATE_AR_CM
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 | 01-20-2006            raverma           delete row from rate_scheds for variable rate loan
 | 06-16-2006            karamach          Removed code that deleted the rate sch row from lns_rate_schedules
 | and added fix in LNS_FINANCIAL_B.pls floatingRatePostProcessing procedure to update existing row to fix bug5331888
 | 07-31-2006            karamach          Added code to update active_flag to N in lns_fee_schedules for unbilled manual fees to fix bug5397345
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
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'REVERSE_LAST_AMORTIZATION';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_LAST_PAYMENT_NUMBER           number;
    l_amortization_schedule_id      number;
    l_batch_source_name             varchar2(50);
    l_custom_payment_flag           varchar2(1);
    l_next_payment_due_date         date;
    l_term_id                       number;
    l_version_number                number;
    l_BILL_PAY_ID                   number;
    l_CUSTOMER_TRX_ID               number;
    l_PAYMENT_SCHEDULE_ID           number;
    l_CUSTOMER_TRX_LINE_ID          number;
    l_LINE_TYPE                     varchar2(30);
    l_TRX_AMOUNT                    number;
    l_APPLIED_AMOUNT                number;
    l_request_id                    number;
    l_TRX_NUMBER                    varchar2(20);
    l_loan_number                   varchar2(60);
    l_due_date                      date;
    l_ORG_ID                        number;
    l_last_rate_id                  number;
    l_rate_type                     varchar2(30);

    l_reverse_tbl                   LNS_BILLING_BATCH_PUB.REVERSE_TBL;
    l_loans_next_dd_rec             LNS_BILLING_BATCH_PUB.LOAN_NEXT_DD_REC;
    l_INSTALLMENT_REC               LNS_CUSTOM_PUB.custom_sched_type;
    l_principal                     NUMBER;
    l_interest                      NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR last_loan_amort_cur(P_LOAN_ID number) IS
        select PAYMENT_NUMBER,
            DUE_DATE,
            AMORTIZATION_SCHEDULE_ID,
            RATE_ID
        from LNS_AMORTIZATION_SCHEDS
        where LOAN_ID = P_LOAN_ID
            and AMORTIZATION_SCHEDULE_ID = LNS_BILLING_UTIL_PUB.LAST_AMORTIZATION_SCHED(LOAN_ID);

    CURSOR trx_to_reverse_cur(P_LOAN_ID number, P_AMORTIZATION_ID number) IS
        select
            trx.trx_number,
            trx.customer_trx_id,
            psa.payment_schedule_id,
            lines.CUST_TRX_LINE_ID,
            lines.LINE_TYPE,
            lines.AMOUNT,
            (psa.AMOUNT_DUE_ORIGINAL - psa.AMOUNT_DUE_REMAINING),
            trx.org_id
        from
            RA_CUSTOMER_TRX_ALL trx,
            lns_amortization_lines lines,
            ar_payment_schedules psa
        where
            trx.customer_trx_id = lines.CUST_TRX_ID and
            trx.customer_trx_id = psa.customer_trx_id and
            lines.LOAN_ID = P_LOAN_ID and
            lines.AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_ID;

    CURSOR loan_version_cur(P_LOAN_ID number) IS
        select
            LOAN_NUMBER,
            OBJECT_VERSION_NUMBER,
            CUSTOM_PAYMENTS_FLAG
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;

    CURSOR terms_cur(P_LOAN_ID number) IS
        select rate_type
        from LNS_TERMS
        where LOAN_ID = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT REVERSE_LAST_AMORTIZATION;
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

    init;

    /* getting object version and custom flag for further loan update */

    open loan_version_cur(P_LOAN_ID);
    fetch loan_version_cur into l_loan_number, l_version_number, l_custom_payment_flag;
    close loan_version_cur;

    open terms_cur(p_loan_id);
      fetch terms_cur into l_rate_type;
    close terms_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reversing loan ' || l_loan_number);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'loan_id ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'rate type ' || l_rate_type);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* quering for last loan amortization record */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying for last amortization record in LNS_AMORTIZATION_SCHEDS:');

    open last_loan_amort_cur(P_LOAN_ID);

    fetch last_loan_amort_cur into
        l_LAST_PAYMENT_NUMBER,
        l_due_date,
        l_amortization_schedule_id,
        l_last_rate_id;

    if last_loan_amort_cur%NOTFOUND then

		LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No amortization record found. Exiting');
        return;

	else

	    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amortization record found:');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'PAYMENT_NUMBER: ' || l_LAST_PAYMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'DUE_DATE: ' || l_due_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortization_schedule_id: ' || l_amortization_schedule_id);

	end if;

    close last_loan_amort_cur;

    /* Quering for invoices with lines to reverse */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Quering for trx lines to reverse...');

    l_Count := 0;
    l_principal := 0;
    l_interest := 0;
    open trx_to_reverse_cur(P_LOAN_ID, l_amortization_schedule_id);

    LOOP

        fetch trx_to_reverse_cur into
            l_TRX_NUMBER,
            l_CUSTOMER_TRX_ID,
            l_PAYMENT_SCHEDULE_ID,
            l_CUSTOMER_TRX_LINE_ID,
            l_LINE_TYPE,
            l_TRX_AMOUNT,
            l_APPLIED_AMOUNT,
            l_ORG_ID;

        exit when trx_to_reverse_cur%NOTFOUND;

        l_Count := l_Count+1;

        l_reverse_tbl(l_Count).TRX_NUMBER := l_TRX_NUMBER;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_ID := l_CUSTOMER_TRX_ID;
        l_reverse_tbl(l_Count).PAYMENT_SCHEDULE_ID := l_PAYMENT_SCHEDULE_ID;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_LINE_ID := l_CUSTOMER_TRX_LINE_ID;
        l_reverse_tbl(l_Count).LINE_TYPE := l_LINE_TYPE;
        l_reverse_tbl(l_Count).TRX_AMOUNT := l_TRX_AMOUNT;
        l_reverse_tbl(l_Count).APPLIED_AMOUNT := l_APPLIED_AMOUNT;
        l_reverse_tbl(l_Count).ORG_ID := l_ORG_ID;

        if l_LINE_TYPE = 'PRIN' then
            l_principal := l_principal + l_TRX_AMOUNT;
        elsif l_LINE_TYPE = 'INT' then
            l_interest := l_interest + l_TRX_AMOUNT;
        end if;

    END LOOP;

    close trx_to_reverse_cur;

    /* Verify count */
    if l_reverse_tbl.count = 0 then

	LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No trx lines found to reverse - will not create AR CM.');
     /*
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_LINES_TO_REV');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;
    */
    else

	/* Create credit memos */
	CREATE_AR_CM(l_reverse_tbl);

    end if;


    /* Deleting reamortize record */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleting reamortize record...');

    delete from LNS_AMORTIZATION_SCHEDS
    where loan_id = P_LOAN_ID and
    REAMORTIZE_FROM_INSTALLMENT = l_last_payment_number;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Deleted!');

    /* Update amortization table */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating record in LNS_AMORTIZATION_SCHEDS...') ;

    LNS_AMORTIZATION_SCHEDS_PKG.Update_Row(
        P_AMORTIZATION_SCHEDULE_ID => l_amortization_schedule_id
        ,P_REVERSED_FLAG => 'Y'
        ,P_REVERSED_DATE => sysdate);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Update successfull!');

    -- fix for bug 7716548: if its custom schedule call LNS_CUSTOM_PUB.addMissingInstallment to add custom row if needed
    if l_custom_payment_flag = 'Y' then

        l_INSTALLMENT_REC.LOAN_ID := P_LOAN_ID;
        l_INSTALLMENT_REC.PAYMENT_NUMBER := l_LAST_PAYMENT_NUMBER;
        l_INSTALLMENT_REC.DUE_DATE := l_due_date;
        l_INSTALLMENT_REC.PRINCIPAL_AMOUNT := l_principal;
        l_INSTALLMENT_REC.INTEREST_AMOUNT := l_interest;
        l_INSTALLMENT_REC.LOCK_PRIN := 'Y';
        l_INSTALLMENT_REC.LOCK_INT := 'Y';

        LNS_CUSTOM_PUB.addMissingInstallment(
            P_API_VERSION		=> 1.0,
            P_INIT_MSG_LIST		=> FND_API.G_FALSE,
            P_COMMIT			=> FND_API.G_FALSE,
            P_VALIDATION_LEVEL	=> FND_API.G_VALID_LEVEL_FULL,
            P_INSTALLMENT_REC   => l_INSTALLMENT_REC,
            X_RETURN_STATUS		=> l_return_status,
            X_MSG_COUNT			=> l_msg_count,
            X_MSG_DATA	    	=> l_msg_data);

        IF l_return_status <> 'S' THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to insert missing custom schedule row.');
        END IF;

    end if;


    /* recalculating next due date */
    l_loans_next_dd_rec.LOAN_ID := P_LOAN_ID;
    l_loans_next_dd_rec.LOAN_NUMBER := l_loan_number;
    l_loans_next_dd_rec.OBJECT_VERSION_NUMBER := l_version_number;
    l_loans_next_dd_rec.NEXT_PAYMENT_NUMBER := l_LAST_PAYMENT_NUMBER;
    l_loans_next_dd_rec.CUSTOM_PAYMENTS_FLAG := l_custom_payment_flag;

    CALC_SINGLE_LOAN_NEXT_DD(
        P_API_VERSION => 1.0,
        P_INIT_MSG_LIST	=> FND_API.G_FALSE,
        P_COMMIT => P_COMMIT,
        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_NEXT_DD_REC => l_loans_next_dd_rec,
        X_RETURN_STATUS	=> l_return_status,
        X_MSG_COUNT => l_msg_count,
        X_MSG_DATA => l_msg_data);


    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully calculated next payment due date.');
    ELSE
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to calculate next payment due date.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_CALC_NEXT_DUE_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    STORE_LAST_PAYMENT_NUMBER(P_LOAN_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully reversed loan ' || l_loan_number);

    /* start billing process if P_REBILL_FLAG = 'Y' */
    if P_REBILL_FLAG = 'Y' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Reprocessing Fees for loan ' || l_loan_number || ' payment number ' || l_LAST_PAYMENT_NUMBER);
        LNS_FEE_ENGINE.reprocessFees(
	        p_init_msg_list      => FND_API.G_TRUE,
            p_commit             => FND_API.G_TRUE,
            p_loan_id            => P_LOAN_ID,
            p_installment_number => l_LAST_PAYMENT_NUMBER,
	        p_phase	         =>  'TERM',  -- At present change it as 'TERM' which is null
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully reprocessed fees.');
        ELSE
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed to reprocess fees.');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Starting billing for loan ' || l_loan_number);

        BILL_LOANS(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
            P_COMMIT => FND_API.G_TRUE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_BORROWER_ID => null,
            P_LOAN_ID => P_LOAN_ID,
            P_FROM_DAYS_TO_DD => null,
            P_TO_DAYS_TO_DD => null,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done billing for loan ' || l_loan_number);

    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Before inactivating unbilled manual fees for this installment: ' || l_LAST_PAYMENT_NUMBER);
	--Bug5397345
	--Make sure unbilled manual fees for this reversed installment are inactivated
	UPDATE LNS_FEE_SCHEDULES SET ACTIVE_FLAG = 'N', LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = lns_utility_pub.last_updated_by, LAST_UPDATE_LOGIN = lns_utility_pub.last_update_login, OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
	WHERE LOAN_ID = P_LOAN_ID AND BILLED_FLAG = 'N' AND FEE_INSTALLMENT = l_LAST_PAYMENT_NUMBER;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'After inactivating unbilled manual fees by updating the active_flag in lns_fee_schedules for this loan and installment');

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
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';
    WHEN OTHERS THEN
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';
END;


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
                                     ,X_MSG_DATA          OUT NOCOPY  VARCHAR2)

is
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'CREDIT_AMORTIZATION_PARTIAL';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_LAST_PAYMENT_NUMBER           number;
    l_amortization_schedule_id      number;
    l_batch_source_name             varchar2(50);
    l_custom_payment_flag           varchar2(1);
    l_next_payment_due_date         date;
    l_term_id                       number;
    l_version_number                number;
    l_BILL_PAY_ID                   number;
    l_CUSTOMER_TRX_ID               number;
    l_PAYMENT_SCHEDULE_ID           number;
    l_CUSTOMER_TRX_LINE_ID          number;
    l_LINE_TYPE                     varchar2(30);
    l_TRX_AMOUNT                    number;
    l_APPLIED_AMOUNT                number;
    l_request_id                    number;
    l_TRX_NUMBER                    varchar2(20);
    l_loan_number                   varchar2(60);
    l_due_date                      date;
    l_ORG_ID                        number;

    l_reverse_tbl                   LNS_BILLING_BATCH_PUB.REVERSE_TBL;
    l_loans_next_dd_rec             LNS_BILLING_BATCH_PUB.LOAN_NEXT_DD_REC;


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR last_loan_amort_cur(P_LOAN_ID number) IS
        select PAYMENT_NUMBER,
            DUE_DATE,
            AMORTIZATION_SCHEDULE_ID
        from LNS_AMORTIZATION_SCHEDS
        where LOAN_ID = P_LOAN_ID
            and AMORTIZATION_SCHEDULE_ID = LNS_BILLING_UTIL_PUB.LAST_AMORTIZATION_SCHED(LOAN_ID);

    CURSOR trx_to_reverse_cur(P_LOAN_ID number, P_AMORTIZATION_ID number, p_line_type varchar2) IS
        select
            trx.trx_number,
            trx.customer_trx_id,
            psa.payment_schedule_id,
            lines.CUST_TRX_LINE_ID,
            lines.LINE_TYPE,
            lines.AMOUNT,
            (psa.AMOUNT_DUE_ORIGINAL - psa.AMOUNT_DUE_REMAINING),
            trx.org_id
        from
            RA_CUSTOMER_TRX_ALL trx,
            lns_amortization_lines lines,
            ar_payment_schedules psa
        where
            trx.customer_trx_id = lines.CUST_TRX_ID and
            trx.customer_trx_id = psa.customer_trx_id and
            lines.LOAN_ID = P_LOAN_ID and
            lines.AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_ID and
            lines.LINE_TYPE = p_line_type;

    CURSOR loan_version_cur(P_LOAN_ID number) IS
        select
            LOAN_NUMBER,
            OBJECT_VERSION_NUMBER,
            CUSTOM_PAYMENTS_FLAG
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT REVERSE_LAST_AMORTIZATION;
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

    init;

    /* getting object version and custom flag for further loan update */

    open loan_version_cur(P_LOAN_ID);
    fetch loan_version_cur into l_loan_number, l_version_number, l_custom_payment_flag;
    close loan_version_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Crediting loan ' || l_loan_number);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'loan_id ' || P_LOAN_ID);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if P_LINE_TYPE is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LINE_TYPE');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* quering for last loan amortization record */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying for last amortization record in LNS_AMORTIZATION_SCHEDS:');

    open last_loan_amort_cur(P_LOAN_ID);

    fetch last_loan_amort_cur into
        l_LAST_PAYMENT_NUMBER,
        l_due_date,
        l_amortization_schedule_id;

    if last_loan_amort_cur%NOTFOUND then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No amortization record found. Exiting');
        return;

    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amortization record found:');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'PAYMENT_NUMBER: ' || l_LAST_PAYMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'DUE_DATE: ' || l_due_date);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortization_schedule_id: ' || l_amortization_schedule_id);

    end if;

    close last_loan_amort_cur;

    /* Quering for invoices with lines to reverse */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Quering for trx lines to Credit...');

    l_Count := 0;
    open trx_to_reverse_cur(P_LOAN_ID, l_amortization_schedule_id, p_line_type);

    LOOP

        fetch trx_to_reverse_cur into
            l_TRX_NUMBER,
            l_CUSTOMER_TRX_ID,
            l_PAYMENT_SCHEDULE_ID,
            l_CUSTOMER_TRX_LINE_ID,
            l_LINE_TYPE,
            l_TRX_AMOUNT,
            l_APPLIED_AMOUNT,
            l_ORG_ID;

        exit when trx_to_reverse_cur%NOTFOUND;

        l_Count := l_Count+1;
        l_reverse_tbl(l_Count).TRX_NUMBER := l_TRX_NUMBER;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_ID := l_CUSTOMER_TRX_ID;
        l_reverse_tbl(l_Count).PAYMENT_SCHEDULE_ID := l_PAYMENT_SCHEDULE_ID;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_LINE_ID := l_CUSTOMER_TRX_LINE_ID;
        l_reverse_tbl(l_Count).LINE_TYPE := l_LINE_TYPE;
        l_reverse_tbl(l_Count).TRX_AMOUNT := l_TRX_AMOUNT;
        l_reverse_tbl(l_Count).APPLIED_AMOUNT := l_APPLIED_AMOUNT;
        l_reverse_tbl(l_Count).ORG_ID := l_ORG_ID;

    END LOOP;

    close trx_to_reverse_cur;

    /* Verify count */
    if l_reverse_tbl.count = 0 then

        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_LINES_TO_REV');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* Create credit memos */
    CREATE_AR_CM(l_reverse_tbl);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully credit loan ' || l_loan_number);

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
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';
    WHEN OTHERS THEN
        ROLLBACK TO REVERSE_LAST_AMORTIZATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
        g_cr_return_status := 'ERROR';

END CREDIT_AMORTIZATION_PARTIAL;

/*========================================================================
 | PUBLIC PROCEDURE CREATE_SINGLE_OFFCYCLE_BILL
 |
 | DESCRIPTION
 |      This procedure creates a single OFFCYCLE bill
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      CREATE_OFFCYCLE_BILLS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CREATE_AR_INVOICES
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
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
    X_MSG_DATA	    	    OUT     NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_SINGLE_OFFCYCLE_BILL';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_Count                 NUMBER;
    l_prin_balance          number;
    l_funded_amount         number;

    l_loan_header_rec   LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_loan_rec              LNS_BILLING_BATCH_PUB.LOAN_TO_BILL_REC;
    l_lines_tbl               LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_cur(P_LOAN_ID number, P_PAYMENT_NUMBER number) IS
        select
            head.LOAN_ID,
            head.LOAN_NUMBER,
            head.LOAN_DESCRIPTION,
            head.LOAN_CURRENCY,
            head.CUST_ACCOUNT_ID,
            head.BILL_TO_ACCT_SITE_ID,
            term.NUMBER_GRACE_DAYS,
            term.PAYMENT_APPLICATION_ORDER,
            decode(am.AMORTIZATION_SCHEDULE_ID, null, -1, am.AMORTIZATION_SCHEDULE_ID) AMORTIZATION_SCHEDULE_ID,
            head.EXCHANGE_RATE_TYPE,
            head.EXCHANGE_DATE,
            head.EXCHANGE_RATE,
            head.ORG_ID,
            head.LEGAL_ENTITY_ID,
            head.FUNDED_AMOUNT,
            nvl(head.CURRENT_PHASE, 'TERM'),
            nvl(head.FORGIVENESS_FLAG, 'N'),
            nvl(head.FORGIVENESS_PERCENT, 0),
            decode(am.AMORTIZATION_SCHEDULE_ID, null, head.FUNDED_AMOUNT, am.FUNDED_AMOUNT)
        from LNS_LOAN_HEADERS head,
            LNS_TERMS term,
            LNS_AMORTIZATION_SCHEDS am
        where  head.LOAN_ID = P_LOAN_ID
	-- Bug#6830765 - Enable billing for all loan status, used in Application fee 'SubmitForApproval Fee'
	 -- and head.LOAN_STATUS in ('ACTIVE', 'DEFAULT', 'DELINQUENT')
            and head.loan_id = term.loan_id
            and head.loan_id = am.loan_id(+)
            and am.PARENT_AMORTIZATION_ID(+) is null
            and am.PAYMENT_NUMBER(+) = P_PAYMENT_NUMBER
            and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
            and nvl(am.PHASE(+), 'TERM') = nvl(head.CURRENT_PHASE, 'TERM');

	-- getting loan version
	CURSOR loan_version_cur(P_LOAN_ID number) IS
		select OBJECT_VERSION_NUMBER
		from LNS_LOAN_HEADERS
		where LOAN_ID = P_LOAN_ID;


BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    l_lines_tbl := P_BILL_LINES_TBL;

    -- Standard start of API savepoint
    SAVEPOINT CREATE_SINGLE_OFFCYCLE_BILL;
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

    init;

    /* verify input parameters */

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Header data:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_BILL_HEADER_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ASSOC_PAYMENT_NUM: ' || P_BILL_HEADER_REC.ASSOC_PAYMENT_NUM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || P_BILL_HEADER_REC.DUE_DATE);

    if P_BILL_HEADER_REC.LOAN_ID is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan ID is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BILL_HEADER_REC.ASSOC_PAYMENT_NUM is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Associated Payment Number is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_NUM');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_BILL_HEADER_REC.DUE_DATE is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Bill Due Date is not set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_DUE');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_lines_tbl.count = 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No lines found for header ' || P_BILL_HEADER_REC.HEADER_ID);
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_LINES');
    	FND_MESSAGE.SET_TOKEN('HEADER', P_BILL_HEADER_REC.HEADER_ID);
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* init amounts */
    l_loan_rec.NEXT_PRINCIPAL_AMOUNT := 0;
    l_loan_rec.NEXT_INTEREST_AMOUNT := 0;
    l_loan_rec.NEXT_FEE_AMOUNT := 0;

    /* looping and suming amounts */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Lines data:');

    FOR l_Count IN 1..l_lines_tbl.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Line # ' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_ID: ' || l_lines_tbl(l_Count).LINE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_AMOUNT: ' || l_lines_tbl(l_Count).LINE_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_TYPE: ' || l_lines_tbl(l_Count).LINE_TYPE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_DESC: ' || l_lines_tbl(l_Count).LINE_DESC);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LINE_REF_ID: ' || l_lines_tbl(l_Count).LINE_REF_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CASH_RECEIPT_ID: ' || l_lines_tbl(l_Count).CASH_RECEIPT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'APPLY_AMOUNT: ' || l_lines_tbl(l_Count).APPLY_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_SCHEDULE_ID: ' || l_lines_tbl(l_Count).FEE_SCHEDULE_ID);

        /* Verifying lines data */
        if l_lines_tbl(l_Count).LINE_AMOUNT is null or l_lines_tbl(l_Count).LINE_AMOUNT <= 0 then
--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Amount for line ' || l_lines_tbl(l_Count).LINE_ID || ' is not set.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_LINE_AMOUNT');
        	FND_MESSAGE.SET_TOKEN('LINE', l_lines_tbl(l_Count).LINE_ID);
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_lines_tbl(l_Count).LINE_TYPE is null then
--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Line type for line ' || l_lines_tbl(l_Count).LINE_ID || ' is not set.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_LINE_TYPE');
        	FND_MESSAGE.SET_TOKEN('LINE', l_lines_tbl(l_Count).LINE_ID);
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;
/*
        if l_lines_tbl(l_Count).LINE_DESC is null then
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Line description for line ' || l_lines_tbl(l_Count).LINE_ID || ' is not set.');
            RAISE FND_API.G_EXC_ERROR;
        end if;
*/
        /* Suming amounts */
        if l_lines_tbl(l_Count).LINE_TYPE = 'PRIN' then
            l_loan_rec.NEXT_PRINCIPAL_AMOUNT := l_loan_rec.NEXT_PRINCIPAL_AMOUNT + l_lines_tbl(l_Count).LINE_AMOUNT;
        elsif l_lines_tbl(l_Count).LINE_TYPE = 'INT' then
            l_loan_rec.NEXT_INTEREST_AMOUNT := l_loan_rec.NEXT_INTEREST_AMOUNT + l_lines_tbl(l_Count).LINE_AMOUNT;
        elsif l_lines_tbl(l_Count).LINE_TYPE = 'FEE' then
            l_loan_rec.NEXT_FEE_AMOUNT := l_loan_rec.NEXT_FEE_AMOUNT + l_lines_tbl(l_Count).LINE_AMOUNT;
        end if;

    END LOOP;

    /* validate principal amount */
    VALIDATE_PRIN_AMOUNT(P_BILL_HEADER_REC.LOAN_ID, l_loan_rec.NEXT_PRINCIPAL_AMOUNT);

    /* quering for data needed for billing */
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Creating OFFCYCLE bill for loan ' || P_BILL_HEADER_REC.LOAN_ID);

    open loan_cur(P_BILL_HEADER_REC.LOAN_ID, P_BILL_HEADER_REC.ASSOC_PAYMENT_NUM);

    fetch loan_cur into
        l_loan_rec.LOAN_ID,
        l_loan_rec.LOAN_NUMBER,
        l_loan_rec.LOAN_DESCRIPTION,
        l_loan_rec.LOAN_CURRENCY,
        l_loan_rec.CUST_ACCOUNT_ID,
        l_loan_rec.BILL_TO_ADDRESS_ID,
        l_loan_rec.NUMBER_GRACE_DAYS,
        l_loan_rec.PAYMENT_APPLICATION_ORDER,
        l_loan_rec.PARENT_AMORTIZATION_ID,
        l_loan_rec.EXCHANGE_RATE_TYPE,
        l_loan_rec.EXCHANGE_DATE,
        l_loan_rec.EXCHANGE_RATE,
        l_loan_rec.ORG_ID,
        l_loan_rec.LEGAL_ENTITY_ID,
        l_loan_rec.FUNDED_AMOUNT,
        l_loan_rec.CURRENT_PHASE,
        l_loan_rec.FORGIVENESS_FLAG,
        l_loan_rec.FORGIVENESS_PERCENT,
        l_funded_amount;

        if loan_cur%NOTFOUND then
--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No amortization record found.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_INSTALLMENT');
        	FND_MESSAGE.SET_TOKEN('LOAN',P_BILL_HEADER_REC.LOAN_ID);
        	FND_MESSAGE.SET_TOKEN('INST', P_BILL_HEADER_REC.ASSOC_PAYMENT_NUM);
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

    close loan_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amortization record found:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_ID: ' || l_loan_rec.PARENT_AMORTIZATION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || l_loan_rec.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_DESCRIPTION: ' || l_loan_rec.LOAN_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_CURRENCY: ' || l_loan_rec.LOAN_CURRENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_ACCOUNT_ID: ' || l_loan_rec.CUST_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUMBER_GRACE_DAYS: ' || l_loan_rec.NUMBER_GRACE_DAYS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_APPLICATION_ORDER: ' || l_loan_rec.PAYMENT_APPLICATION_ORDER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_loan_rec.EXCHANGE_RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_loan_rec.EXCHANGE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_loan_rec.EXCHANGE_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORG_ID: ' || l_loan_rec.ORG_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LEGAL_ENTITY_ID: ' || l_loan_rec.LEGAL_ENTITY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || l_loan_rec.FUNDED_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CURRENT_PHASE: ' || l_loan_rec.CURRENT_PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG: ' || l_loan_rec.FORGIVENESS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT: ' || l_loan_rec.FORGIVENESS_PERCENT);

    /* setting new values */
    l_loan_rec.NEXT_PAYMENT_NUMBER := P_BILL_HEADER_REC.ASSOC_PAYMENT_NUM;
    l_loan_rec.NEXT_PAYMENT_DUE_DATE := P_BILL_HEADER_REC.DUE_DATE;
    l_loan_rec.NEXT_PAYMENT_LATE_DATE := P_BILL_HEADER_REC.DUE_DATE + nvl(l_loan_rec.NUMBER_GRACE_DAYS, 0);

    /* Inserting new record into LNS_AMORTIZATION_SCHEDS */
    l_prin_balance := null;
    if l_loan_rec.CURRENT_PHASE is not null and l_loan_rec.CURRENT_PHASE = 'OPEN' then
        l_prin_balance := l_loan_rec.FUNDED_AMOUNT;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting new record into LNS_AMORTIZATION_SCHEDS w following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_loan_rec.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || l_loan_rec.NEXT_PAYMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_loan_rec.NEXT_PAYMENT_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LATE_DATE: ' || l_loan_rec.NEXT_PAYMENT_LATE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_AMOUNT: ' || l_loan_rec.NEXT_PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_AMOUNT: ' || l_loan_rec.NEXT_INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_AMOUNT: ' || l_loan_rec.NEXT_FEE_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARENT_AMORTIZATION_ID: ' || l_loan_rec.PARENT_AMORTIZATION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_BALANCE: ' || l_prin_balance);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_loan_rec.CURRENT_PHASE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || l_funded_amount);

    LNS_AMORTIZATION_SCHEDS_PKG.Insert_Row(
        X_AMORTIZATION_SCHEDULE_ID => l_loan_rec.NEXT_AMORTIZATION_ID
        ,P_LOAN_ID => l_loan_rec.LOAN_ID
        ,P_PAYMENT_NUMBER => l_loan_rec.NEXT_PAYMENT_NUMBER
        ,P_DUE_DATE => l_loan_rec.NEXT_PAYMENT_DUE_DATE
        ,P_LATE_DATE => l_loan_rec.NEXT_PAYMENT_LATE_DATE
        ,P_PRINCIPAL_AMOUNT => l_loan_rec.NEXT_PRINCIPAL_AMOUNT
        ,P_INTEREST_AMOUNT => l_loan_rec.NEXT_INTEREST_AMOUNT
        ,P_FEE_AMOUNT => l_loan_rec.NEXT_FEE_AMOUNT
        ,P_REVERSED_FLAG => 'N'
        ,P_OBJECT_VERSION_NUMBER => 1
        ,P_PARENT_AMORTIZATION_ID => l_loan_rec.PARENT_AMORTIZATION_ID
	    ,P_PRINCIPAL_BALANCE => l_prin_balance
	    ,P_PHASE => l_loan_rec.CURRENT_PHASE
	    ,P_FUNDED_AMOUNT => l_funded_amount);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_SCHEDULE_ID: ' || l_loan_rec.NEXT_AMORTIZATION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully inserted record into LNS_AMORTIZATION_SCHEDS');

    /* Creating AR invoices */
    CREATE_AR_INVOICES(l_loan_rec, l_lines_tbl);

    /* updating loan header table */

    -- getting loan version
    open loan_version_cur(l_loan_rec.LOAN_ID);
    fetch loan_version_cur into l_loan_rec.OBJECT_VERSION_NUMBER;
    close loan_version_cur;

    l_loan_header_rec.loan_id := l_loan_rec.LOAN_ID;
    l_loan_header_rec.BILLED_FLAG := 'Y';
    l_loan_header_rec.LAST_BILLED_DATE := sysdate;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header info w following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLED_FLAG: ' || l_loan_header_rec.BILLED_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_BILLED_DATE: ' || l_loan_header_rec.LAST_BILLED_DATE);

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_loan_rec.OBJECT_VERSION_NUMBER,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL');
    ELSE
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: LNS_LOAN_HEADER_PUB.UPDATE_LOAN returned error: ' || substr(l_msg_data,1,225));
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;
    END IF;


    STORE_LAST_PAYMENT_NUMBER(l_loan_rec.LOAN_ID);

    GENERATE_BILLING_STATEMENT_XML(
					p_loan_id => l_loan_rec.LOAN_ID,
					p_amortization_schedule_id => l_loan_rec.NEXT_AMORTIZATION_ID);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully created OFFCYCLE bill');

    -- loan forgiveness adjustment for manual bills: fix for bug 7429910
    if l_loan_rec.FORGIVENESS_FLAG = 'Y' and
       l_loan_rec.FORGIVENESS_PERCENT > 0 and
       g_forgiveness_rec_trx_id is not null then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Performing loan forgiveness adjustment...');
        FORGIVENESS_ADJUSTMENT(
                P_API_VERSION => 1.0,
                P_INIT_MSG_LIST	=> FND_API.G_TRUE,
                P_COMMIT => FND_API.G_FALSE,
                P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_ID => l_loan_rec.LOAN_ID,
                X_RETURN_STATUS	=> l_return_status,
                X_MSG_COUNT => l_msg_count,
                X_MSG_DATA => l_msg_data);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully performed forgiveness adjustment.');
        ELSE
            --LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to perform forgiveness adjustment');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_FORGIVENESS_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Will not perform loan forgiveness adjustment');
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully created OFFCYCLE bill');

    /* applying cash receipts */

    FOR l_Count IN 1..l_lines_tbl.count LOOP

        if l_lines_tbl(l_Count).CASH_RECEIPT_ID is not null and
           l_lines_tbl(l_Count).APPLY_AMOUNT is not null and l_lines_tbl(l_Count).APPLY_AMOUNT > 0 then

            APPLY_RECEIPT(P_CASH_RECEIPT_ID => l_lines_tbl(l_Count).CASH_RECEIPT_ID,
                        P_TRX_ID => l_lines_tbl(l_Count).CUSTOMER_TRX_ID,
                        P_TRX_LINE_ID => l_lines_tbl(l_Count).CUSTOMER_TRX_LINE_ID,
                        P_APPLY_AMOUNT => l_lines_tbl(l_Count).APPLY_AMOUNT);

        end if;

    END LOOP;

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
        ROLLBACK TO CREATE_SINGLE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_SINGLE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_SINGLE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE CREATE_OFFCYCLE_BILLS
 |
 | DESCRIPTION
 |      This procedure creates many OFFCYCLE bills
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
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
    X_MSG_DATA	    	    OUT     NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_OFFCYCLE_BILLS';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_Count                 NUMBER;
    l_Count1                NUMBER;
    l_Count2                NUMBER;
    l_bill_lines_tbl        LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT CREATE_OFFCYCLE_BILLS;
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
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Creating OFFCYCLE bills...');

    /* Looping thru headers table */
    FOR l_Count IN 1..P_BILL_HEADERS_TBL.count LOOP

        if P_BILL_HEADERS_TBL(l_Count).HEADER_ID is null then
--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Header ID is not set.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_HEADER');
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        /* Init lines table */
        l_Count2 := 0;
        l_bill_lines_tbl.delete;

        /* Looping thru lines table */
        FOR l_Count1 IN 1..P_BILL_LINES_TBL.count LOOP

            if P_BILL_LINES_TBL(l_Count1).HEADER_ID is null then
--                LogMessage(FND_LOG.LEVEL_ERROR, 'ERROR: Header ID for line ' || P_BILL_LINES_TBL(l_Count1).LINE_ID || ' is not set.');
            	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_BILL_NO_LINE_HEADER');
            	FND_MESSAGE.SET_TOKEN('LINE', P_BILL_LINES_TBL(l_Count1).LINE_ID);
        		FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

            /* Adding current line record to lines table of current header */
            if P_BILL_HEADERS_TBL(l_Count).HEADER_ID = P_BILL_LINES_TBL(l_Count1).HEADER_ID then
                l_Count2 := l_Count2+1;
                l_bill_lines_tbl(l_Count2) := P_BILL_LINES_TBL(l_Count1);
            end if;

        END LOOP;

        /* Create a single offcycle bill */
        CREATE_SINGLE_OFFCYCLE_BILL(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
            P_COMMIT => FND_API.G_FALSE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_BILL_HEADER_REC => P_BILL_HEADERS_TBL(l_Count),
            P_BILL_LINES_TBL => l_bill_lines_tbl,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || P_BILL_HEADERS_TBL.count || ' OFFCYCLE bill(s)');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan');
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
        ROLLBACK TO CREATE_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loan');
END;



/*========================================================================
 | PUBLIC PROCEDURE REVERSE_OFFCYCLE_BILL
 |
 | DESCRIPTION
 |      This procedure reverses an offcycle bill
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      CREATE_AR_CM
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
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
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'REVERSE_OFFCYCLE_BILL';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_LOAN_ID                       number;
    l_BILL_PAY_ID                   number;
    l_CUSTOMER_TRX_ID               number;
    l_PAYMENT_SCHEDULE_ID           number;
    l_CUSTOMER_TRX_LINE_ID          number;
    l_LINE_TYPE                     varchar2(30);
    l_TRX_AMOUNT                    number;
    l_APPLIED_AMOUNT                number;
    l_PAYMENT_NUMBER                number;
    l_DUE_DATE                      date;
    l_PARENT_AMORTIZATION_ID        number;
    l_REVERSED_FLAG                 varchar2(1);
    l_TRX_NUMBER                    varchar2(20);
    l_ORG_ID                        number;

    l_reverse_tbl                   LNS_BILLING_BATCH_PUB.REVERSE_TBL;
    l_lns_status			 LNS_LOAN_HEADERS_ALL.loan_status%TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR amort_cur(P_AMORTIZATION_ID number) IS
        select LOAN_ID,
            PAYMENT_NUMBER,
            DUE_DATE,
            PARENT_AMORTIZATION_ID,
            REVERSED_CODE
        from LNS_AM_SCHEDS_V
        where AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_ID;


    CURSOR trx_to_reverse_cur(P_LOAN_ID number, P_AMORTIZATION_ID number) IS
        select
            trx.trx_number,
            trx.customer_trx_id,
            psa.payment_schedule_id,
            lines.CUST_TRX_LINE_ID,
            lines.LINE_TYPE,
            lines.AMOUNT,
            (psa.AMOUNT_DUE_ORIGINAL - psa.AMOUNT_DUE_REMAINING),
            trx.org_id
        from
            RA_CUSTOMER_TRX_ALL trx,
            lns_amortization_lines lines,
            ar_payment_schedules psa
        where
            trx.customer_trx_id = lines.CUST_TRX_ID and
            trx.customer_trx_id = psa.customer_trx_id and
            lines.LOAN_ID = P_LOAN_ID and
            lines.AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT REVERSE_OFFCYCLE_BILL;
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

    init;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reversing offcycle bill with amortization_id ' || P_AMORTIZATION_ID);

    /* verify input parameters */
    if P_AMORTIZATION_ID is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Amortization ID must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_REV_NO_AMORT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* verify is it really offcycle bill, reversed etc. */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying for details of the amortization:');

    open amort_cur(P_AMORTIZATION_ID);
    fetch amort_cur into
        l_LOAN_ID,
        l_PAYMENT_NUMBER,
        l_DUE_DATE,
        l_PARENT_AMORTIZATION_ID,
        l_REVERSED_FLAG;

    if amort_cur%NOTFOUND then

--		LogMessage(FND_LOG.LEVEL_ERROR, 'ERROR: No amortization record found.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_REV_NO_BILL_FOUND');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;

	else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_LOAN_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || l_PAYMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_DUE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARENT_AMORTIZATION_ID: ' || l_PARENT_AMORTIZATION_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REVERSED_FLAG: ' || l_REVERSED_FLAG);

        if l_PARENT_AMORTIZATION_ID is null then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: The amortization is not offcycle bill.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_REV_NOT_MAN_BILL');
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        elsif l_REVERSED_FLAG = 'Y' then

--            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: The amortization is already reversed.');
        	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_REV_ALREADY_REV');
    		FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

	end if;

    close amort_cur;

    /* Quering for invoices with lines to reverse */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Quering for trx lines to reverse...');

    open trx_to_reverse_cur(l_LOAN_ID, P_AMORTIZATION_ID);

    l_Count := 0;
    LOOP
        fetch trx_to_reverse_cur into
            l_TRX_NUMBER,
            l_CUSTOMER_TRX_ID,
            l_PAYMENT_SCHEDULE_ID,
            l_CUSTOMER_TRX_LINE_ID,
            l_LINE_TYPE,
            l_TRX_AMOUNT,
            l_APPLIED_AMOUNT,
            l_ORG_ID;
        exit when trx_to_reverse_cur%NOTFOUND;

        l_Count := l_Count+1;
        l_reverse_tbl(l_Count).TRX_NUMBER := l_TRX_NUMBER;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_ID := l_CUSTOMER_TRX_ID;
        l_reverse_tbl(l_Count).PAYMENT_SCHEDULE_ID := l_PAYMENT_SCHEDULE_ID;
        l_reverse_tbl(l_Count).CUSTOMER_TRX_LINE_ID := l_CUSTOMER_TRX_LINE_ID;
        l_reverse_tbl(l_Count).LINE_TYPE := l_LINE_TYPE;
        l_reverse_tbl(l_Count).TRX_AMOUNT := l_TRX_AMOUNT;
        l_reverse_tbl(l_Count).APPLIED_AMOUNT := l_APPLIED_AMOUNT;
        l_reverse_tbl(l_Count).ORG_ID := l_ORG_ID;

    END LOOP;

    close trx_to_reverse_cur;

    /* Check for table count */
    if l_reverse_tbl.count = 0 then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: No trx lines found to reverse.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_LINES_TO_REV');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_ERROR, FND_MSG_PUB.Get(p_encoded => 'F'));
	    RAISE FND_API.G_EXC_ERROR;

    end if;

    /* Create credit memos */
    CREATE_AR_CM(l_reverse_tbl);

    /* Updating amortization table */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating record in LNS_AMORTIZATION_SCHEDS...') ;

    LNS_AMORTIZATION_SCHEDS_PKG.Update_Row(
        P_AMORTIZATION_SCHEDULE_ID => P_AMORTIZATION_ID
        ,P_REVERSED_FLAG => 'Y'
        ,P_REVERSED_DATE => sysdate);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Update successfull!');

    SELECT  lhdr.loan_status INTO l_lns_status FROM  lns_loan_headers lhdr WHERE lhdr.loan_id = l_LOAN_ID;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The LoanStatus of loanid '||l_LOAN_ID||' is '||l_lns_status) ;

    -- If the loanStatus is INCOMPLETE, then only update the lns_fee_schedules.billed_flag = 'N' for the submitForApproval fees
    IF l_lns_status = 'INCOMPLETE' THEN
	    REVERSE_BILLED_FEES(p_amortization_id);
    END IF;

    STORE_LAST_PAYMENT_NUMBER(l_LOAN_ID);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully reversed offcycle bill');

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
        ROLLBACK TO REVERSE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO REVERSE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO REVERSE_OFFCYCLE_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE ADJUST_ORIGINAL_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure adjusts loans original receivable in AR
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
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE ADJUST_ORIGINAL_RECEIVABLE(
    P_API_VERSION		      IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			        IN          VARCHAR2,
    P_VALIDATION_LEVEL	  IN          NUMBER,
    P_LOAN_ID             IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			      OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'ADJUST_ORIGINAL_RECEIVABLE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_number                   varchar2(60);
--    l_funded_amount                 number;
    l_trx_number                    varchar2(20);
    l_payment_schedule_id           number;
    l_amount_due_remaining          number;
    l_type                          varchar2(15);
    l_loan_desc                     varchar2(250);
    l_comments                      varchar2(2000);
    l_adj_number                    varchar2(20);
    l_adj_id                        number;
--    l_version_number                number;
    l_ussgl_flag                    varchar2(3);
    l_Count                         number;
    l_requested_amount              number;
    l_line_id                       number;
    l_apply_date                    date;
    l_gl_date                       date;
    l_org_id                        number;
	l_legal_entity_id               number;

	-- for on-line accounting call
	l_err                           varchar2(50);
	l_ret                           number;
	ls_info                         xla_events_pub_pkg.t_event_source_info;
	l_accounting_batch_id           number;
	l_request_id                    number;
	l_ledger_id                     number;
    l_installment_number            number;
    l_loan_start_date               date;

		cursor c_ledger is
    SELECT  so.set_of_books_id
      FROM  lns_system_options so
           ,gl_sets_of_books sb
     WHERE sb.set_of_books_id = so.set_of_books_id;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying trx, psa and loan details */
    CURSOR orig_rec_cur(P_LOAN_ID number) IS
        select
	        loan.loan_number,
            loan.LOAN_DESCRIPTION,
            lines.REQUESTED_AMOUNT,
            lines.reference_number,
            lines.REC_ADJUSTMENT_NUMBER,
            nvl(lines.payment_schedule_id, psa.payment_schedule_id),
            psa.AMOUNT_DUE_REMAINING,
            lines.LOAN_LINE_ID,
            psa.TRX_DATE,
            psa.GL_DATE,
            trx.org_id,
    		trx.legal_entity_id,
            lines.REC_ADJUSTMENT_ID,
            nvl(lines.installment_number, 1),
            loan.LOAN_START_DATE
        from LNS_LOAN_HEADERS loan,
            RA_CUSTOMER_TRX trx,
            ar_payment_schedules psa,
            lns_loan_lines lines
        where loan.loan_id = P_LOAN_ID and
        	loan.loan_id = lines.loan_id and
            lines.reference_type = 'RECEIVABLE' and
            lines.REFERENCE_ID = trx.CUSTOMER_TRX_ID and
            lines.REFERENCE_NUMBER = trx.trx_number and
            lines.end_date is null and
            trx.CUSTOMER_TRX_ID = psa.CUSTOMER_TRX_ID and
            nvl(lines.installment_number, 1) = psa.terms_sequence_number
        order by lines.LOAN_LINE_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT ADJUST_ORIGINAL_RECEIVABLE;
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

    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id :' || P_LOAN_ID);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
	    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
				FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* checking for system options values required for adjustment */
    if g_receivables_trx_id is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Receivables activity name is not set in the system option.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_REC_TRX_IN_SYS_OPT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;


    /* based on profile USSGL_OPTION value verify value for USSGL_TRANSACTION_CODE */
    /* commented out by raverma 07-29-2005
		l_ussgl_flag := NVL(FND_PROFILE.VALUE('USSGL_OPTION'), 'N');

    if l_ussgl_flag = 'Y' then

        if g_USSGL_TRANSACTION_CODE is null then
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: USSGL Transaction Code is not set in the system option.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_TRX_CODE_IN_SYS_OPT');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

    end if;
		*/

    /* querying trx, psa, loan and loan lines details */
    l_Count := 0;
    open orig_rec_cur(P_LOAN_ID);

    LOOP

        fetch orig_rec_cur into
            l_loan_number,
            l_loan_desc,
            l_requested_amount,
            l_trx_number,
            l_adj_number,
            l_payment_schedule_id,
            l_amount_due_remaining,
            l_line_id,
            l_apply_date,
            l_gl_date,
            l_org_id,
		    l_legal_entity_id,
            l_adj_id,
            l_installment_number,
            l_loan_start_date;
        exit when orig_rec_cur%NOTFOUND;

        l_Count := l_Count + 1;

        if l_Count = 1 then
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjusting original receivables for loan ' ||  l_loan_number || ' (id ' || P_LOAN_ID || ')...');
        end if;

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjusting receivable ' || l_trx_number || '...');

        /* verify adjust amount and set adjustment type */
        if l_requested_amount > l_amount_due_remaining then
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Adjust amount cannot be greater than receivable remaining amount.');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjustment amount: -' || l_requested_amount);
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receivable remaining amount: ' || l_amount_due_remaining);
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_ADJ_AMT');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        else
            l_type := 'LINE';
        end if;

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjustment amount: -' || l_requested_amount);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receivable remaining amount: ' || l_amount_due_remaining);

        /* checking if adjustment for this loan already was made */
        if l_adj_number is not null or l_adj_id is not null then
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Attempt to duplicate adjustment. Receivable has been already adjusted for this loan by adjustment xxx' );
            FND_MESSAGE.SET_NAME('LNS', 'LNS_DUPL_ADJ_ORIG_REC');
            FND_MESSAGE.SET_TOKEN('ADJ', l_adj_number);
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        /* buld comments */
        l_comments := 'Loan ' || l_loan_number || ' - line ' || l_Count;
        /*
        if l_loan_desc is not null then
            l_comments := 'Loan ' || l_loan_number || ' - ' || l_loan_desc;
        else
            l_comments := 'Loan ' || l_loan_number;
        end if;
        */

        -- setting adj_apply_date and adj_gl_date
        /*
        if trunc(l_apply_date) < trunc(sysdate) then
            l_apply_date := sysdate;
        end if;

        if trunc(l_gl_date) < trunc(sysdate) then
            l_gl_date := sysdate;
        end if;
        */

        l_apply_date := l_loan_start_date;
        l_gl_date := l_loan_start_date;

        /* do adjustment */
        CREATE_AR_ADJ(P_TYPE => l_type,
            P_PAYMENT_SCHEDULE_ID => l_payment_schedule_id,
            P_RECEIVABLES_TRX_ID => g_receivables_trx_id,
            P_AMOUNT => -l_requested_amount,
            P_APPLY_DATE => l_apply_date,
            P_GL_DATE => l_gl_date,
            P_CUSTOMER_TRX_LINE_ID => null,
            P_CODE_COMBINATION_ID => null,
            P_USSGL_TRX_CODE => g_USSGL_TRANSACTION_CODE,
            P_REASON_CODE => 'LOAN_CONV',
            P_COMMENTS => l_comments,
            X_ADJ_ID => l_adj_id,
            X_ADJ_NUMBER => l_adj_number,
            P_ORG_ID => l_org_id);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_LOAN_LINES...');
        LNS_LOAN_LINE_PUB.UPDATE_LINE_ADJUSTMENT_NUMBER(
            p_init_msg_list             => FND_API.G_FALSE
            ,p_loan_id                  => P_LOAN_ID
            ,p_loan_line_id             => l_line_id
            ,p_rec_adjustment_number    => l_adj_number
            ,p_rec_adjustment_id        => l_adj_id
            ,P_PAYMENT_SCHEDULE_ID      => l_payment_schedule_id
            ,P_INSTALLMENT_NUMBER       => l_installment_number
            ,p_adjustment_date          => l_apply_date
            ,p_original_flag            => 'Y'
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated LNS_LOAN_LINES');
        ELSE
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully created adjustment ' || l_adj_number || ' for original receivable ' || l_trx_number);

    END LOOP;

    close orig_rec_cur;

    if l_Count = 0 then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Cannot find receivable to adjust.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_FIND_ORIG_REC');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully adjusted ' || l_Count || ' original receivable for loan ' || l_loan_number);

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
        ROLLBACK TO ADJUST_ORIGINAL_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ADJUST_ORIGINAL_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO ADJUST_ORIGINAL_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;


/*========================================================================
 | PUBLIC PROCEDURE PREBILL_SINGLE_LOAN
 |
 | DESCRIPTION
 |      This procedure prebill (do initial billing) for single loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |      CREATE_OFFCYCLE_BILLS
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PREBILL_SINGLE_LOAN';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_installment_num               number;
    l_Count                         number;
    l_Count1                        number;
    l_header_count                  number;
    l_loan_number                   varchar2(60);
    l_cur_phase                     VARCHAR2(30);


    l_amortization_rec              LNS_FINANCIALS.AMORTIZATION_REC;
    l_fee_tbl                       LNS_FINANCIALS.FEES_TBL;
    l_BILL_HEADERS_TBL              LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL;
    l_BILL_LINES_TBL                LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying loan number */
    CURSOR loan_cur(P_LOAN_ID number) IS
        select
            LOAN_NUMBER, nvl(CURRENT_PHASE, 'TERM')
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;

BEGIN

    X_BILLED_YN := 'N';

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT PREBILL_SINGLE_LOAN;
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
    l_installment_num := 0;

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* getting loan_number */
    open loan_cur(P_LOAN_ID);
    fetch loan_cur into l_loan_number, l_cur_phase;
    close loan_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Billing 0-th installment for loan ' || l_loan_number || '...');

    /* new principal and interest amounts from getInstallment api */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getInstallment...');

    if l_cur_phase = 'TERM' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getInstallment...');
        lns_financials.getInstallment(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            p_commit => FND_API.G_FALSE,
            p_loan_Id => P_LOAN_ID,
            p_installment_number => l_installment_num,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getOpenInstallment...');
        lns_financials.getOpenInstallment(
--            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
--            p_commit => FND_API.G_FALSE,
            p_loan_Id => P_LOAN_ID,
            p_installment_number => l_installment_num,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Data returned from lns_financials.getInstallment:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENT_NUMBER: ' || l_amortization_rec.INSTALLMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_amortization_rec.due_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_AMOUNT: ' || l_amortization_rec.PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_AMOUNT: ' || l_amortization_rec.INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_AMOUNT: ' || l_amortization_rec.FEE_AMOUNT);

    l_header_count := 101;
    l_BILL_HEADERS_TBL(1).HEADER_ID := l_header_count;
    l_BILL_HEADERS_TBL(1).LOAN_ID := P_LOAN_ID;
    l_BILL_HEADERS_TBL(1).ASSOC_PAYMENT_NUM := l_installment_num;
    l_BILL_HEADERS_TBL(1).DUE_DATE := l_amortization_rec.due_date;

    /* checking for returned values */

    if l_amortization_rec.INSTALLMENT_NUMBER is null and
       l_amortization_rec.due_date is null
    then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'lns_financials.getInstallment returns no data. Nothing to bill. Returning.');
        return;

    end if;

    if (l_amortization_rec.PRINCIPAL_AMOUNT is null or l_amortization_rec.PRINCIPAL_AMOUNT = 0) and
       (l_amortization_rec.INTEREST_AMOUNT is null or l_amortization_rec.INTEREST_AMOUNT = 0) and
       (l_amortization_rec.FEE_AMOUNT is null or l_amortization_rec.FEE_AMOUNT = 0)
    then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'All amounts returned from lns_financials.getInstallment = 0. Nothing to bill.');
        return;

    end if;

    l_Count1 := 0;

    /* adding principal and interest amounts into lines table */

    if l_amortization_rec.PRINCIPAL_AMOUNT > 0 then

        l_Count1 := l_Count1 + 1;
        l_BILL_LINES_TBL(l_Count1).LINE_ID := 100 + l_Count1;
        l_BILL_LINES_TBL(l_Count1).HEADER_ID := l_header_count;
        l_BILL_LINES_TBL(l_Count1).LINE_AMOUNT := l_amortization_rec.PRINCIPAL_AMOUNT;
        l_BILL_LINES_TBL(l_Count1).LINE_TYPE := 'PRIN';

    end if;

    if l_amortization_rec.INTEREST_AMOUNT > 0 then

        l_Count1 := l_Count1 + 1;
        l_BILL_LINES_TBL(l_Count1).LINE_ID := 100 + l_Count1;
        l_BILL_LINES_TBL(l_Count1).HEADER_ID := l_header_count;
        l_BILL_LINES_TBL(l_Count1).LINE_AMOUNT := l_amortization_rec.INTEREST_AMOUNT;
        l_BILL_LINES_TBL(l_Count1).LINE_TYPE := 'INT';

    end if;

    /* adding fee amounts into lines table */
    FOR l_Count IN 1..l_fee_tbl.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Fee #' || l_Count || ' Name: ' || l_fee_tbl(l_Count).FEE_NAME || ' Amount: ' || l_fee_tbl(l_Count).FEE_AMOUNT);

        l_Count1 := l_Count1 + 1;
        l_BILL_LINES_TBL(l_Count1).LINE_ID := 100 + l_Count1;
        l_BILL_LINES_TBL(l_Count1).HEADER_ID := l_header_count;
        l_BILL_LINES_TBL(l_Count1).LINE_AMOUNT := l_fee_tbl(l_Count).FEE_AMOUNT;
        l_BILL_LINES_TBL(l_Count1).LINE_TYPE := 'FEE';
        l_BILL_LINES_TBL(l_Count1).LINE_REF_ID := l_fee_tbl(l_Count).FEE_ID;
        l_BILL_LINES_TBL(l_Count1).LINE_DESC := l_fee_tbl(l_Count).FEE_NAME;
        l_BILL_LINES_TBL(l_Count1).FEE_SCHEDULE_ID := l_fee_tbl(l_Count).FEE_SCHEDULE_ID;

        /* added fee installment validation by raverma request */
        if l_amortization_rec.INSTALLMENT_NUMBER <> l_fee_tbl(l_Count).FEE_INSTALLMENT then

            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_FEE_INSTAL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        end if;

        /* updating LNS_FEE_SCHEDULES with billed_flag = Y */
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_FEE_SCHEDULES with billed_flag = Y ...');
        UPDATE LNS_FEE_SCHEDULES
        SET
            BILLED_FLAG                     =     'Y',
            last_update_date                =     LNS_UTILITY_PUB.LAST_UPDATE_DATE,
            last_updated_by                 =     LNS_UTILITY_PUB.LAST_UPDATED_BY,
            last_update_login               =     LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
        WHERE
            FEE_SCHEDULE_ID = l_fee_tbl(l_Count).fee_schedule_id;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_FEE_SCHEDULES');

    END LOOP;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS...');

    LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
        P_BILL_HEADERS_TBL      => l_BILL_HEADERS_TBL,
        P_BILL_LINES_TBL        => l_BILL_LINES_TBL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully billed 0-th installment for loan ' || l_loan_number);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    X_BILLED_YN := 'Y';

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PREBILL_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PREBILL_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO PREBILL_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;


/*========================================================================
 | PUBLIC PROCEDURE GET_FORGIVENESS_AMOUNT
 |
 | DESCRIPTION
 |      This procedure returns forgiveness amount based on forgiveness settings and passed amount
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
    X_REMAINING_AMOUNT      OUT NOCOPY  NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_FORGIVENESS_AMOUNT';
    l_forgiveness_flag              varchar2(1);
    l_forgiveness_percent           number;
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_currency                      VARCHAR2(15);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying psa and loan details */
    CURSOR details_cur(P_LOAN_ID number) IS
        select
            nvl(loan.FORGIVENESS_FLAG, 'N'),
            nvl(loan.FORGIVENESS_PERCENT, 0),
            loan.LOAN_CURRENCY
        from LNS_LOAN_HEADERS loan
        where
            loan.loan_id = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- START OF BODY OF API
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_AMOUNT = ' || P_AMOUNT);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;
    if P_AMOUNT is null then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'P_AMOUNT is null');
        RAISE FND_API.G_EXC_ERROR;

    end if;

    init;

    X_FORGIVENESS_AMOUNT := 0;
    X_REMAINING_AMOUNT := P_AMOUNT;

    /* checking for system options values required for adjustment */
    if g_forgiveness_rec_trx_id is null then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan Forgiveness receivables activity name is not set in the system option. Exiting.');
        return;
    end if;

    /* querying psa, loan details */
    open details_cur(P_LOAN_ID);
    fetch details_cur into
        l_forgiveness_flag,
        l_forgiveness_percent,
        l_currency;
    close details_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_forgiveness_flag = ' || l_forgiveness_flag);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_forgiveness_percent = ' || l_forgiveness_percent);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_currency = ' || l_currency);

    if l_forgiveness_flag = 'N' then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan is not part of loan forgiveness program. Exiting.');
        return;
    end if;

    if l_forgiveness_percent = 0 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Forgiveness percent = 0. Exiting.');
        return;
    end if;

    fnd_currency.GET_INFO(CURRENCY_CODE => l_currency,
                        PRECISION => l_precision,
                        EXT_PRECISION => l_ext_precision,
                        MIN_ACCT_UNIT => l_min_acct_unit);
    X_FORGIVENESS_AMOUNT := round(P_AMOUNT * (l_forgiveness_percent/100), l_precision);
    X_REMAINING_AMOUNT := P_AMOUNT - X_FORGIVENESS_AMOUNT;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'X_FORGIVENESS_AMOUNT = ' || X_FORGIVENESS_AMOUNT);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'X_REMAINING_AMOUNT = ' || X_REMAINING_AMOUNT);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, l_api_name || ' - In exception');
END;


/*========================================================================
 | PRIVATE PROCEDURE FORGIVENESS_ADJUSTMENT
 |
 | DESCRIPTION
 |      This procedure make adjustment to just billed principal as loan forgiveness program
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
 | 09-01-2008            scherkas          Created for bug 7387659
 |
 *=======================================================================*/
PROCEDURE FORGIVENESS_ADJUSTMENT(
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

    l_api_name                      CONSTANT VARCHAR2(30) := 'FORGIVENESS_ADJUSTMENT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_number                   varchar2(60);
    l_trx_id                        number;
    l_payment_schedule_id           number;
    l_original_amount               number;
    l_type                          varchar2(15);
    l_loan_desc                     varchar2(250);
    l_comments                      varchar2(2000);
    l_adj_number                    varchar2(20);
    l_adj_id                        number;
    l_requested_amount              number;
    l_apply_date                    date;
    l_gl_date                       date;
    l_forgiveness_flag              varchar2(1);
    l_forgiveness_percent           number;
    l_payment_number                number;
    l_org_id			    number;
    l_phase			    VARCHAR2(30);
    l_precision                     number;
    l_ext_precision                 number;
    l_min_acct_unit                 number;
    l_currency                      VARCHAR2(15);
    l_remaining_amount              NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying psa and loan details */
    CURSOR details_cur(P_LOAN_ID number) IS
        select
            loan.loan_number,
            loan.LOAN_DESCRIPTION,
            nvl(loan.FORGIVENESS_FLAG, 'N'),
            nvl(loan.FORGIVENESS_PERCENT, 0),
            am.PAYMENT_NUMBER,
            am.PRINCIPAL_TRX_ID,
            psa.payment_schedule_id,
            nvl(psa.AMOUNT_DUE_ORIGINAL, 0),
            psa.TRX_DATE,
            psa.GL_DATE,
            nvl(loan.CURRENT_PHASE, 'TERM'),
			psa.org_id,
            loan.LOAN_CURRENCY
        from LNS_LOAN_HEADERS loan,
            lns_amortization_scheds am,
            ar_payment_schedules psa
        where
            loan.loan_id = P_LOAN_ID and
            loan.LAST_AMORTIZATION_ID = am.AMORTIZATION_SCHEDULE_ID and
            loan.loan_id = am.loan_id and
            am.PRINCIPAL_TRX_ID = psa.CUSTOMER_TRX_ID(+);

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT FORGIVENESS_ADJUSTMENT;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* checking for system options values required for adjustment */
    if g_forgiveness_rec_trx_id is null then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan Forgiveness receivables activity name is not set in the system option. Exiting.');
        return;
    end if;

    /* querying psa, loan details */
    open details_cur(P_LOAN_ID);
    fetch details_cur into
        l_loan_number,
        l_loan_desc,
        l_forgiveness_flag,
        l_forgiveness_percent,
        l_payment_number,
        l_trx_id,
        l_payment_schedule_id,
        l_original_amount,
        l_apply_date,
        l_gl_date,
        l_phase,
	l_org_id,
        l_currency;
    close details_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_number = ' || l_loan_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_desc = ' || l_loan_desc);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_forgiveness_flag = ' || l_forgiveness_flag);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_forgiveness_percent = ' || l_forgiveness_percent);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payment_number = ' || l_payment_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_trx_id = ' || l_trx_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_payment_schedule_id = ' || l_payment_schedule_id);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_original_amount = ' || l_original_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_apply_date = ' || l_apply_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_gl_date = ' || l_gl_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_phase = ' || l_phase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_org_id = ' || l_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_currency = ' || l_currency);

    if l_trx_id is null then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Nothing to adjust - principal invoice does not exist for payment number ' || l_payment_number || '. Exiting.');
        return;
    end if;

    if l_payment_schedule_id is null then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Cannot create adjustment - principal invoice is INCOMPLETE!');
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_forgiveness_flag = 'N' then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan is not part of loan forgiveness program. Exiting.');
        return;
    end if;

    if l_forgiveness_percent = 0 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Forgiveness percent = 0. Will not perform forgiveness adjustment. Exiting.');
        return;
    end if;

    if l_original_amount = 0 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Principal amount = 0. Will not perform forgiveness adjustment. Exiting.');
        return;
    end if;

    l_type := 'LINE';

    GET_FORGIVENESS_AMOUNT(
        P_LOAN_ID               => P_LOAN_ID,
        P_AMOUNT                => l_original_amount,
        X_FORGIVENESS_AMOUNT    => l_requested_amount,
        X_REMAINING_AMOUNT      => l_remaining_amount);
/*
    -- fix for bug 7712669
    fnd_currency.GET_INFO(CURRENCY_CODE => l_currency,
                        PRECISION => l_precision,
                        EXT_PRECISION => l_ext_precision,
                        MIN_ACCT_UNIT => l_min_acct_unit);
    l_requested_amount := round(l_original_amount * (l_forgiveness_percent/100), l_precision);
*/
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjustment amount: -' || l_requested_amount);

    if l_requested_amount = 0 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Forgiveness amount = 0. Will not perform forgiveness adjustment. Exiting.');
        return;
    end if;

    /* buld comments */
    l_comments := 'Loan Forgiveness Program for loan ' || l_loan_number;

    /* do adjustment */
    CREATE_AR_ADJ(P_TYPE => l_type,
        P_PAYMENT_SCHEDULE_ID => l_payment_schedule_id,
        P_RECEIVABLES_TRX_ID => g_forgiveness_rec_trx_id,
        P_AMOUNT => -l_requested_amount,
        P_APPLY_DATE => l_apply_date,
        P_GL_DATE => l_gl_date,
        P_CUSTOMER_TRX_LINE_ID => null,
        P_CODE_COMBINATION_ID => null,
        P_USSGL_TRX_CODE => null,
        P_REASON_CODE => null,
        P_COMMENTS => l_comments,
        X_ADJ_ID => l_adj_id,
        X_ADJ_NUMBER => l_adj_number,
		P_ORG_ID => l_org_id);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_adj_number = ' || l_adj_number || ' (l_adj_id = ' || l_adj_id || ')');

    if l_adj_id is null and l_adj_number is null then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully adjusted payment ' || l_payment_number || ' for loan ' || l_loan_number);

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
        ROLLBACK TO FORGIVENESS_ADJUSTMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO FORGIVENESS_ADJUSTMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO FORGIVENESS_ADJUSTMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE GET_NEXT_INSTAL_TO_BILL
 |
 | DESCRIPTION
 |      This procedure returns next installment to be billed in LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL format
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_NEXT_INSTAL_TO_BILL';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_NEXT_PAYMENT_NUMBER           NUMBER;
    l_create_zero_instal            varchar2(1);
    l_invoice_number                varchar2(20);
    l_profile_name                  VARCHAR2(240);
    i                               number;
    l_currency                      varchar2(15);
    l_exchange_rate                 number;
    l_prin_trx_type_id              number;
    l_current_phase                 varchar2(30);

    l_amortization_rec              LNS_FINANCIALS.AMORTIZATION_REC;
    l_fee_tbl                       LNS_FINANCIALS.FEES_TBL;
    l_invoices_tbl                  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

     cursor c_loanInfo(p_loan_id number) is
     select loan_number, LOAN_CURRENCY, nvl(EXCHANGE_RATE, 1), nvl(CURRENT_PHASE, 'TERM')
       from lns_loan_headers_all
      where loan_id = p_loan_id;

    /* query trx_type_id */
    CURSOR prin_trx_type_cur(P_LOAN_ID number) IS
        select REFERENCE_TYPE_ID
        from LNS_LOAN_HEADERS_ALL
        where loan_id = P_LOAN_ID;

    CURSOR trx_type_cur(p_trx_type_id number) IS
        select NAME
        from RA_CUST_TRX_TYPES_ALL
        where cust_trx_type_id = p_trx_type_id;


BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT GET_NEXT_INSTAL_TO_BILL;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if CAN_BILL_NEXT_INSTAL(P_LOAN_ID) = false then
        -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan is not ready to bill next installment. Returning.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_READY_BILL_NEXT_INSTAL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Bug#6830765 - Added new procedure ..EXT_1, which returns '0' if 0th installment is scheduled and it solves
    -- the case if there is no '0th installment' and wants '1st 'installment
    l_NEXT_PAYMENT_NUMBER := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT_1(P_LOAN_ID) + 1;

    open c_loanInfo(P_LOAN_ID);
    fetch c_loanInfo into l_invoice_number, l_currency, l_exchange_rate, l_current_phase;
    close c_loanInfo;

    if l_current_phase = 'TERM' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getInstallment...');
        lns_financials.getInstallment(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            p_commit => FND_API.G_FALSE,
            p_loan_Id => P_LOAN_ID,
            p_installment_number => l_NEXT_PAYMENT_NUMBER,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

    else

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling lns_financials.getOpenInstallment...');
        lns_financials.getOpenInstallment(
            p_init_msg_list => FND_API.G_TRUE,
            p_loan_Id => P_LOAN_ID,
            p_installment_number => l_NEXT_PAYMENT_NUMBER,
            x_amortization_rec => l_amortization_rec,
            x_fees_tbl => l_fee_tbl,
            X_RETURN_STATUS => l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- remove any msg from the stack
    FND_MSG_PUB.initialize;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Data returned:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INSTALLMENT_NUMBER: ' || l_amortization_rec.INSTALLMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_amortization_rec.due_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRINCIPAL_AMOUNT: ' || l_amortization_rec.PRINCIPAL_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_AMOUNT: ' || l_amortization_rec.INTEREST_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FEE_AMOUNT: ' || l_amortization_rec.FEE_AMOUNT);

    /* checking for returned values */
    if l_amortization_rec.INSTALLMENT_NUMBER is null and
       l_amortization_rec.due_date is null
    then

        -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'lns_financials.getInstallment returns no data. Nothing to bill. Returning.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_BILLING_DATA');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if l_amortization_rec.PRINCIPAL_AMOUNT = 0 and
       l_amortization_rec.INTEREST_AMOUNT = 0 and
       l_amortization_rec.FEE_AMOUNT = 0
    then

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'All amounts returned from lns_financials.getInstallment = 0.');

        -- fix for bug 7000066: get LNS_CREATE_ZERO_INSTAL profile value to see if we need to create 0 amount installment
        l_create_zero_instal := NVL(FND_PROFILE.VALUE('LNS_CREATE_ZERO_INSTAL'), 'N');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LNS_CREATE_ZERO_INSTAL profile: ' || l_create_zero_instal);

        if l_create_zero_instal = 'N' then

            select USER_PROFILE_OPTION_NAME into l_profile_name
            from FND_PROFILE_OPTIONS_VL
            where PROFILE_OPTION_NAME = 'LNS_CREATE_ZERO_INSTAL';

            --LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Billing of zero amount installments is disallowed by profile LNS: Create Zero Amount Installments.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_BILL_ZERO_AMOUNT');
    		FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
--            return;
        end if;

    end if;

    i := 0;

    if (l_amortization_rec.PRINCIPAL_AMOUNT = 0 and NVL(FND_PROFILE.VALUE('LNS_CREATE_ZERO_PRIN_INV'), 'N') = 'Y') or
       l_amortization_rec.PRINCIPAL_AMOUNT > 0
    then
        i := i + 1;
        l_invoices_tbl(i).CUST_TRX_ID        := null;
        l_invoices_tbl(i).PAYMENT_SCHEDULE_ID := null;
        l_invoices_tbl(i).INSTALLMENT_NUMBER := l_amortization_rec.INSTALLMENT_NUMBER;
        l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
        l_invoices_tbl(i).ORIGINAL_AMOUNT    := l_amortization_rec.PRINCIPAL_AMOUNT;
        l_invoices_tbl(i).DUE_DATE           := l_amortization_rec.due_date;
        l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', 'PRIN');
        l_invoices_tbl(i).BILLED_FLAG        := 'N';
        l_invoices_tbl(i).INVOICE_CURRENCY   := l_currency;
        l_invoices_tbl(i).EXCHANGE_RATE      := l_exchange_rate;

        /* query trx_type_id */
        open prin_trx_type_cur(P_LOAN_ID);
        fetch prin_trx_type_cur into l_prin_trx_type_id;
        close prin_trx_type_cur;

        if l_prin_trx_type_id is null then
            l_prin_trx_type_id := g_trx_type_id;
        end if;

        open trx_type_cur(l_prin_trx_type_id);
        fetch trx_type_cur into l_invoices_tbl(i).TRANSACTION_TYPE;
        close trx_type_cur;

        l_invoices_tbl(i).GL_DATE            := l_invoices_tbl(i).DUE_DATE + nvl(g_day_togl_after_dd, 0);
        LNS_BILLING_UTIL_PUB.VALIDATE_AND_DEFAULT_GL_DATE(
                p_gl_date => l_invoices_tbl(i).GL_DATE,
                p_trx_date => l_invoices_tbl(i).DUE_DATE,
                p_set_of_books_id => g_set_of_books_id,
                x_default_gl_date => l_invoices_tbl(i).GL_DATE);

        GET_FORGIVENESS_AMOUNT(
            P_LOAN_ID               => P_LOAN_ID,
            P_AMOUNT                => l_invoices_tbl(i).ORIGINAL_AMOUNT,
            X_FORGIVENESS_AMOUNT    => l_invoices_tbl(i).FORGIVENESS_AMOUNT,
            X_REMAINING_AMOUNT      => l_invoices_tbl(i).REMAINING_AMOUNT);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added principal ' || l_amortization_rec.PRINCIPAL_AMOUNT);
    end if;

    if l_amortization_rec.INTEREST_AMOUNT > 0 then
        i := i + 1;
        l_invoices_tbl(i).CUST_TRX_ID        := null;
        l_invoices_tbl(i).PAYMENT_SCHEDULE_ID := null;
        l_invoices_tbl(i).INSTALLMENT_NUMBER := l_amortization_rec.INSTALLMENT_NUMBER;
        l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
        l_invoices_tbl(i).TRANSACTION_TYPE   := lns_utility_pub.getDocumentName('INT');
        l_invoices_tbl(i).ORIGINAL_AMOUNT    := l_amortization_rec.INTEREST_AMOUNT;
        l_invoices_tbl(i).REMAINING_AMOUNT   := l_amortization_rec.INTEREST_AMOUNT;
        l_invoices_tbl(i).FORGIVENESS_AMOUNT := 0;
        l_invoices_tbl(i).DUE_DATE           := l_amortization_rec.due_date;
        l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', 'INT');
        l_invoices_tbl(i).BILLED_FLAG        := 'N';
        l_invoices_tbl(i).INVOICE_CURRENCY   := l_currency;
        l_invoices_tbl(i).EXCHANGE_RATE      := l_exchange_rate;
        l_invoices_tbl(i).GL_DATE            := l_invoices_tbl(i).DUE_DATE + nvl(g_day_togl_after_dd, 0);

        LNS_BILLING_UTIL_PUB.VALIDATE_AND_DEFAULT_GL_DATE(
                p_gl_date => l_invoices_tbl(i).GL_DATE,
                p_trx_date => l_invoices_tbl(i).DUE_DATE,
                p_set_of_books_id => g_set_of_books_id,
                x_default_gl_date => l_invoices_tbl(i).GL_DATE);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added interest ' || l_amortization_rec.INTEREST_AMOUNT);
    end if;

    if l_amortization_rec.FEE_AMOUNT > 0 then
        i := i + 1;
        l_invoices_tbl(i).CUST_TRX_ID        := null;
        l_invoices_tbl(i).PAYMENT_SCHEDULE_ID := null;
        l_invoices_tbl(i).INSTALLMENT_NUMBER := l_amortization_rec.INSTALLMENT_NUMBER;
        l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
        l_invoices_tbl(i).TRANSACTION_TYPE   := lns_utility_pub.getDocumentName('FEE');
        l_invoices_tbl(i).ORIGINAL_AMOUNT    := l_amortization_rec.FEE_AMOUNT;
        l_invoices_tbl(i).REMAINING_AMOUNT   := l_amortization_rec.FEE_AMOUNT;
        l_invoices_tbl(i).FORGIVENESS_AMOUNT := 0;
        l_invoices_tbl(i).DUE_DATE           := l_amortization_rec.due_date;
        l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', 'FEE');
        l_invoices_tbl(i).BILLED_FLAG        := 'N';
        l_invoices_tbl(i).INVOICE_CURRENCY   := l_currency;
        l_invoices_tbl(i).EXCHANGE_RATE      := l_exchange_rate;
        l_invoices_tbl(i).GL_DATE            := l_invoices_tbl(i).DUE_DATE + nvl(g_day_togl_after_dd, 0);

        LNS_BILLING_UTIL_PUB.VALIDATE_AND_DEFAULT_GL_DATE(
                p_gl_date => l_invoices_tbl(i).GL_DATE,
                p_trx_date => l_invoices_tbl(i).DUE_DATE,
                p_set_of_books_id => g_set_of_books_id,
                x_default_gl_date => l_invoices_tbl(i).GL_DATE);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added fee ' || l_amortization_rec.FEE_AMOUNT);
    end if;

    x_invoices_tbl := l_invoices_tbl;

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
        ROLLBACK TO GET_NEXT_INSTAL_TO_BILL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO GET_NEXT_INSTAL_TO_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO GET_NEXT_INSTAL_TO_BILL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE BILL_AND_PAY_NEXT_INSTAL
 |
 | DESCRIPTION
 |      This procedure bills and pays next scheduled installment
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_AND_PAY_NEXT_INSTAL';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count1                        NUMBER;

    l_am_sched_tbl                  LNS_BILLING_BATCH_PUB.AMORTIZATION_SCHED_TBL;
    l_loans_to_bill_tbl		        LNS_BILLING_BATCH_PUB.LOANS_TO_BILL_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_to_bill_cur(P_LOAN_ID number) IS
        select
            head.LOAN_ID,
            head.LOAN_NUMBER,
            head.LOAN_DESCRIPTION,
            head.OBJECT_VERSION_NUMBER,
            head.FUNDED_AMOUNT,
            head.BILL_TO_ACCT_SITE_ID,
            term.FIRST_PAYMENT_DATE,
            term.NEXT_PAYMENT_DUE_DATE,
            nvl(head.BILLED_FLAG, 'N'),
            head.LOAN_CURRENCY,
            head.CUST_ACCOUNT_ID,
            head.CUSTOM_PAYMENTS_FLAG,
            term.LOAN_PAYMENT_FREQUENCY,
            term.NUMBER_GRACE_DAYS,
            term.PAYMENT_APPLICATION_ORDER,
            head.EXCHANGE_RATE_TYPE,
            head.EXCHANGE_DATE,
            head.EXCHANGE_RATE,
            nvl(head.FORGIVENESS_FLAG, 'N'),
            nvl(head.FORGIVENESS_PERCENT, 0),
            nvl(head.CURRENT_PHASE,'TERM')
        from LNS_LOAN_HEADERS_all head,
            LNS_TERMS term
        where head.loan_id = term.loan_id
            and head.LOAN_ID = P_LOAN_ID;

    CURSOR get_last_am_cur(P_LOAN_ID number) IS
        select loan.LAST_AMORTIZATION_ID
        from LNS_LOAN_HEADERS_all loan
        where loan.loan_id = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT BILL_AND_PAY_NEXT_INSTAL;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);

    if CAN_BILL_NEXT_INSTAL(P_LOAN_ID) = false then
        -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan is not ready to bill next installment. Returning.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_READY_BILL_NEXT_INSTAL');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    l_Count1 := 1;
    open loan_to_bill_cur(P_LOAN_ID);
    fetch loan_to_bill_cur into
        l_loans_to_bill_tbl(l_Count1).LOAN_ID,
        l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER,
        l_loans_to_bill_tbl(l_Count1).LOAN_DESCRIPTION,
        l_loans_to_bill_tbl(l_Count1).OBJECT_VERSION_NUMBER,
        l_loans_to_bill_tbl(l_Count1).FUNDED_AMOUNT,
        l_loans_to_bill_tbl(l_Count1).BILL_TO_ADDRESS_ID,
        l_loans_to_bill_tbl(l_Count1).FIRST_PAYMENT_DATE,
        l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_DUE_DATE,
        l_loans_to_bill_tbl(l_Count1).BILLED_FLAG,
        l_loans_to_bill_tbl(l_Count1).LOAN_CURRENCY,
        l_loans_to_bill_tbl(l_Count1).CUST_ACCOUNT_ID,
        l_loans_to_bill_tbl(l_Count1).CUSTOM_PAYMENTS_FLAG,
        l_loans_to_bill_tbl(l_Count1).LOAN_PAYMENT_FREQUENCY,
        l_loans_to_bill_tbl(l_Count1).NUMBER_GRACE_DAYS,
        l_loans_to_bill_tbl(l_Count1).PAYMENT_APPLICATION_ORDER,
        l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE_TYPE,
        l_loans_to_bill_tbl(l_Count1).EXCHANGE_DATE,
        l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE,
        l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG,
        l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT,
        l_loans_to_bill_tbl(l_Count1).CURRENT_PHASE;
    close loan_to_bill_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_loans_to_bill_tbl(l_Count1).LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || l_loans_to_bill_tbl(l_Count1).LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_DESCRIPTION: ' || l_loans_to_bill_tbl(l_Count1).LOAN_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNDED_AMOUNT: ' || l_loans_to_bill_tbl(l_Count1).FUNDED_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_TO_ADDRESS_ID: ' || l_loans_to_bill_tbl(l_Count1).BILL_TO_ADDRESS_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE: ' || l_loans_to_bill_tbl(l_Count1).FIRST_PAYMENT_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_DUE_DATE: ' || l_loans_to_bill_tbl(l_Count1).NEXT_PAYMENT_DUE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLED_FLAG: ' || l_loans_to_bill_tbl(l_Count1).BILLED_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_CURRENCY: ' || l_loans_to_bill_tbl(l_Count1).LOAN_CURRENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_ACCOUNT_ID: ' || l_loans_to_bill_tbl(l_Count1).CUST_ACCOUNT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG: ' || l_loans_to_bill_tbl(l_Count1).CUSTOM_PAYMENTS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PAYMENT_FREQUENCY: ' || l_loans_to_bill_tbl(l_Count1).LOAN_PAYMENT_FREQUENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUMBER_GRACE_DAYS: ' || l_loans_to_bill_tbl(l_Count1).NUMBER_GRACE_DAYS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_APPLICATION_ORDER: ' || l_loans_to_bill_tbl(l_Count1).PAYMENT_APPLICATION_ORDER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_loans_to_bill_tbl(l_Count1).EXCHANGE_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG: ' || l_loans_to_bill_tbl(l_Count1).FORGIVENESS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT: ' || l_loans_to_bill_tbl(l_Count1).FORGIVENESS_PERCENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CURRENT_PHASE: ' || l_loans_to_bill_tbl(l_Count1).CURRENT_PHASE);

    /* do all needed inits */
    dbms_lob.createtemporary(g_last_all_statements, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_all_statements, dbms_lob.lob_readwrite);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Calling BILL_LOANS_EXT...');
    BILL_LOANS_EXT(
        P_API_VERSION => 1.0,
        P_INIT_MSG_LIST	=> FND_API.G_TRUE,
        P_COMMIT => FND_API.G_FALSE,
        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_LOANS_TO_BILL_TBL => l_loans_to_bill_tbl,
        X_RETURN_STATUS	=> l_return_status,
        X_MSG_COUNT => l_msg_count,
        X_MSG_DATA => l_msg_data);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully billed next due installment.');
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if P_CASH_RECEIPTS_TBL.count > 0 then

        open get_last_am_cur(P_LOAN_ID);
        fetch get_last_am_cur into l_am_sched_tbl(1);
        close get_last_am_cur;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling PAY_INSTALLMENTS...');
        PAY_INSTALLMENTS(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
            P_COMMIT => FND_API.G_FALSE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID => P_LOAN_ID,
            P_AM_SCHED_TBL => l_am_sched_tbl,
            P_CASH_RECEIPTS_TBL => P_CASH_RECEIPTS_TBL,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully applied cash receipts.');
        ELSE
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

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
        ROLLBACK TO BILL_AND_PAY_NEXT_INSTAL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BILL_AND_PAY_NEXT_INSTAL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO BILL_AND_PAY_NEXT_INSTAL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC PROCEDURE PAY_INSTALLMENTS
 |
 | DESCRIPTION
 |      This procedure applies cash receipts to given installments
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
 |      P_AM_SCHED_TBL          IN          LNS_BILLING_BATCH_PUB.AMORTIZATION_SCHED_TBL,
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PAY_INSTALLMENTS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_Count1                        number;
    l_order                         varchar2(30);
    l_search_str                    varchar2(1);
	l_start_pos		                number;
	l_end_pos		                number;
    l_receipt                       number;
    l_exit_loop                     varchar2(1);
    l_quit                          varchar2(1);
    l_apply_amount                  number;
    l_application                   number;
    l_trans_to_receipt_rate         number;
    l_receipt_amount_from           number;  -- in receipt currency
    l_rc_precision                  number;
    l_rc_ext_precision              number;
    l_rc_min_acct_unit              number;
    l_inv_precision                 number;
    l_inv_ext_precision             number;
    l_inv_min_acct_unit             number;
    l_apply_date                    date;
    l_inv_am_in_rec_cur             number;
    l_inv_count                     number;
    l_rc_count                      number;
    l_error                         varchar2(32767);
    l_total_applied_amount          number;

    l_INVOICE_REC                   LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_REC;
    L_INVOICES_TBL                  LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_TBL;
    l_order_tbl                     DBMS_SQL.VARCHAR2_TABLE;
    l_CASH_RECEIPTS_TBL             LNS_BILLING_BATCH_PUB.CASH_RECEIPT_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get payment application order
    CURSOR order_cur(P_LOAN_ID number) IS
        select PAYMENT_APPLICATION_ORDER
        from lns_terms
        where loan_id = P_LOAN_ID;

    -- fetching open invoices in payment order
    CURSOR invoices_cur(P_LOAN_ID number, P_AMORTIZATION_SCHED_ID number, P_INVOICE_TYPE varchar2) IS
        select
            decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID),
            psa.PAYMENT_SCHEDULE_ID,
            psa.trx_number,
            psa.due_date,
            psa.gl_date,
            psa.amount_due_remaining,
            P_INVOICE_TYPE,
            psa.invoice_currency_code,
            nvl(loan.EXCHANGE_RATE, 1)
        from
            lns_amortization_scheds am,
            lns_loan_headers loan,
            ar_payment_schedules psa,
            lns_lookups look
        where
            am.loan_id = P_LOAN_ID and
            am.amortization_schedule_id = P_AMORTIZATION_SCHED_ID and
            loan.loan_id = am.loan_id and
            am.reversed_flag = 'N' and
            psa.customer_trx_id = decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID) and
            psa.amount_due_remaining > 0 and
            psa.status = 'OP' and
            (am.INTEREST_TRX_ID is not null or am.principal_trx_id is not null or am.FEE_TRX_ID is not null) and
            look.lookup_type = 'PAYMENT_APPLICATION_TYPE' and
            look.lookup_code = P_INVOICE_TYPE;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT PAY_INSTALLMENTS;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amortization schedules:');
    for i in 1..P_AM_SCHED_TBL.count loop
        LogMessage(FND_LOG.LEVEL_STATEMENT, P_AM_SCHED_TBL(i));
    end loop;

    l_CASH_RECEIPTS_TBL := P_CASH_RECEIPTS_TBL;
    l_total_applied_amount := 0;
    for i in 1..l_CASH_RECEIPTS_TBL.count loop
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Cash receipt #' || i);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_NUMBER: ' || l_CASH_RECEIPTS_TBL(i).RECEIPT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CASH_RECEIPT_ID: ' || l_CASH_RECEIPTS_TBL(i).CASH_RECEIPT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_AMOUNT: ' || l_CASH_RECEIPTS_TBL(i).RECEIPT_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_CURRENCY: ' || l_CASH_RECEIPTS_TBL(i).RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_CASH_RECEIPTS_TBL(i).EXCHANGE_RATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_CASH_RECEIPTS_TBL(i).EXCHANGE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_CASH_RECEIPTS_TBL(i).EXCHANGE_RATE_TYPE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORIGINAL_CURRENCY: ' || l_CASH_RECEIPTS_TBL(i).ORIGINAL_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'APPLY_DATE: ' || l_CASH_RECEIPTS_TBL(i).APPLY_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'GL_DATE: ' || l_CASH_RECEIPTS_TBL(i).GL_DATE);
        l_total_applied_amount := l_total_applied_amount + l_CASH_RECEIPTS_TBL(i).RECEIPT_AMOUNT;
    end loop;

    if l_CASH_RECEIPTS_TBL.count = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No cash receipts are passed - nothing to apply. Returning.');
        return;
    end if;

    if l_total_applied_amount = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total applied amount = 0 - nothing to apply. Returning.');
        return;
    end if;

    -- get payment application order
    open order_cur(P_LOAN_ID);
    fetch order_cur into l_order;
    close order_cur;

    l_count := 0;
    l_search_str := '_';
	l_start_pos := 1;
    l_end_pos := instr(l_order, l_search_str, l_start_pos, 1);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment application order:' || l_order);
	LOOP
        l_count := l_count + 1;
		if l_end_pos <> 0 then
			l_order_tbl(l_count) := substr(l_order, l_start_pos, l_end_pos-l_start_pos);
            --LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_count: ' || l_order_tbl(l_count));
		else
			l_order_tbl(l_count) := substr(l_order, l_start_pos, LENGTH(l_order)-l_start_pos+1);
            --LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_count: ' || l_order_tbl(l_count));
			exit;
		end if;
        l_start_pos := l_end_pos+1;
		l_end_pos := instr(l_order, l_search_str, l_start_pos, 1);
    END LOOP;

    l_Count1 := 0;

    -- looping thru payment application order table and fetch invoices in order to be applied
    FOR l_Count IN 1..l_order_tbl.count LOOP
        for i in 1..P_AM_SCHED_TBL.count loop

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Amortization_schedule_id = ' || P_AM_SCHED_TBL(i));

            l_INVOICE_REC := null;
            open invoices_cur(P_LOAN_ID, P_AM_SCHED_TBL(i), l_order_tbl(l_Count));
            fetch invoices_cur into l_INVOICE_REC.CUST_TRX_ID,
                                    l_INVOICE_REC.PAYMENT_SCHEDULE_ID,
                                    l_INVOICE_REC.INVOICE_NUMBER,
                                    l_INVOICE_REC.DUE_DATE,
                                    l_INVOICE_REC.GL_DATE,
                                    l_INVOICE_REC.REMAINING_AMOUNT,
                                    l_INVOICE_REC.PURPOSE,
                                    l_INVOICE_REC.INVOICE_CURRENCY,
                                    l_INVOICE_REC.EXCHANGE_RATE;
            close invoices_cur;

            if l_INVOICE_REC.CUST_TRX_ID is not null then

                l_Count1 := l_Count1 + 1;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count1);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || l_INVOICE_REC.PAYMENT_SCHEDULE_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || l_INVOICE_REC.CUST_TRX_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_NUMBER: ' || l_INVOICE_REC.INVOICE_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_INVOICE_REC.DUE_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'GL_DATE: ' || l_INVOICE_REC.GL_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || l_INVOICE_REC.REMAINING_AMOUNT);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PURPOSE: ' || l_INVOICE_REC.PURPOSE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || l_INVOICE_REC.INVOICE_CURRENCY);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_INVOICE_REC.EXCHANGE_RATE);

                L_INVOICES_TBL(l_Count1) := l_INVOICE_REC;

            end if;

        END LOOP;
    END LOOP;

    if L_INVOICES_TBL.count = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No open invoices to pay. Returning.');
        return;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Applying receipts...');

    l_receipt := 1;
    l_quit := 'N';
    l_application := 0;
    l_inv_count := 0;
    l_rc_count := 0;

    -- looping thru invoices and apply receipts
    FOR l_Count IN 1..L_INVOICES_TBL.count LOOP

        l_inv_count := l_inv_count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, '-------------');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || L_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || L_INVOICES_TBL(l_Count).CUST_TRX_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_NUMBER: ' || L_INVOICES_TBL(l_Count).INVOICE_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || L_INVOICES_TBL(l_Count).DUE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'GL_DATE: ' || L_INVOICES_TBL(l_Count).GL_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || L_INVOICES_TBL(l_Count).REMAINING_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PURPOSE: ' || L_INVOICES_TBL(l_Count).PURPOSE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || L_INVOICES_TBL(l_Count).INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || L_INVOICES_TBL(l_Count).EXCHANGE_RATE);

        FOR l_Count1 IN l_receipt..l_CASH_RECEIPTS_TBL.count LOOP

            l_rc_count := l_receipt;
            LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Receipt #' || l_Count1);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_NUMBER: ' || l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_NUMBER);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'CASH_RECEIPT_ID: ' || l_CASH_RECEIPTS_TBL(l_Count1).CASH_RECEIPT_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_AMOUNT: ' || l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_CURRENCY: ' || l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_RATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_DATE: ' || l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE_TYPE: ' || l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_RATE_TYPE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORIGINAL_CURRENCY: ' || l_CASH_RECEIPTS_TBL(l_Count1).ORIGINAL_CURRENCY);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'APPLY_DATE: ' || l_CASH_RECEIPTS_TBL(l_Count1).APPLY_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'GL_DATE: ' || l_CASH_RECEIPTS_TBL(l_Count1).GL_DATE);

            BEGIN

                -- calculate amounts using curencies
                if l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY = L_INVOICES_TBL(l_Count).INVOICE_CURRENCY then

                    if L_INVOICES_TBL(l_Count).REMAINING_AMOUNT > l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT then

                        l_apply_amount := l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT;
                        l_exit_loop := 'N';

                    elsif L_INVOICES_TBL(l_Count).REMAINING_AMOUNT <= l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT then

                        l_apply_amount := L_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_exit_loop := 'Y';

                    end if;

                    l_receipt_amount_from := null;
                    l_trans_to_receipt_rate := null;

                else    -- if trx currency <> receipt currency

                    -- get rc/functional currency precision
                    fnd_currency.GET_INFO(CURRENCY_CODE => l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY,
                                        PRECISION => l_rc_precision,
                                        EXT_PRECISION => l_rc_ext_precision,
                                        MIN_ACCT_UNIT => l_rc_min_acct_unit);

                    -- get invoice currency precision
                    fnd_currency.GET_INFO(CURRENCY_CODE => L_INVOICES_TBL(l_Count).INVOICE_CURRENCY,
                                        PRECISION => l_inv_precision,
                                        EXT_PRECISION => l_inv_ext_precision,
                                        MIN_ACCT_UNIT => l_inv_min_acct_unit);

                    if l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_RATE is not null then
                        logMessage(FND_LOG.LEVEL_STATEMENT, 'using receipt exchange rate ' || l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_RATE);
                        l_trans_to_receipt_rate := l_CASH_RECEIPTS_TBL(l_Count1).EXCHANGE_RATE;
                    else
                        logMessage(FND_LOG.LEVEL_PROCEDURE, 'using loan exchange rate ' || L_INVOICES_TBL(l_Count).EXCHANGE_RATE);
                        l_trans_to_receipt_rate := L_INVOICES_TBL(l_Count).EXCHANGE_RATE;
                    end if;

                    l_inv_am_in_rec_cur := round(L_INVOICES_TBL(l_Count).REMAINING_AMOUNT * l_trans_to_receipt_rate, l_rc_precision);

                    if l_inv_am_in_rec_cur > l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT then

                        l_receipt_amount_from := l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT;
                        l_apply_amount := round(l_receipt_amount_from / l_trans_to_receipt_rate, l_inv_precision);
                        l_exit_loop := 'N';

                    elsif l_inv_am_in_rec_cur < l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT then

                        l_apply_amount := L_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_receipt_amount_from := round(l_apply_amount * l_trans_to_receipt_rate, l_rc_precision);
                        l_exit_loop := 'Y';

                    else

                        l_apply_amount := L_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_receipt_amount_from := l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT;
                        l_exit_loop := 'Y';

                    end if;

                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling AR_RECEIPT_API_PUB.APPLY with following parameters:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_cash_receipt_id: ' || l_CASH_RECEIPTS_TBL(l_Count1).CASH_RECEIPT_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_applied_payment_schedule_id: ' || L_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_apply_date: ' || l_CASH_RECEIPTS_TBL(l_Count1).APPLY_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_apply_gl_date: ' || l_CASH_RECEIPTS_TBL(l_Count1).GL_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_amount_applied: ' || l_apply_amount); -- in loan currency
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_amount_applied_from: ' || l_receipt_amount_from); -- in receipt currency
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_trans_to_receipt_rate: ' || l_trans_to_receipt_rate);

                BEGIN

                    l_error := null;
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling AR_RECEIPT_API_PUB.APPLY...');
                    AR_RECEIPT_API_PUB.APPLY(P_API_VERSION                 => 1.0
                                            ,P_INIT_MSG_LIST               => FND_API.G_TRUE
                                            ,P_COMMIT                      => FND_API.G_FALSE
                                            ,X_RETURN_STATUS               => l_return_status
                                            ,X_MSG_COUNT                   => l_msg_count
                                            ,X_MSG_DATA                    => l_msg_data
                                            ,p_cash_receipt_id             => l_CASH_RECEIPTS_TBL(l_Count1).CASH_RECEIPT_ID
                                            ,p_applied_payment_schedule_id => L_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID
                                            ,p_apply_date                  => l_CASH_RECEIPTS_TBL(l_Count1).APPLY_DATE
                                            ,p_apply_gl_date               => l_CASH_RECEIPTS_TBL(l_Count1).GL_DATE
                                            ,p_amount_applied              => l_apply_amount
                                            ,p_amount_applied_from         => l_receipt_amount_from
                                            ,p_trans_to_receipt_rate       => l_trans_to_receipt_rate);

                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_error := FND_MSG_PUB.Get(p_encoded => 'F');
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;
                        l_error := SQLERRM;
                END;

                if l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY = L_INVOICES_TBL(l_Count).INVOICE_CURRENCY then
                    l_receipt_amount_from := l_apply_amount;
                end if;

                l_application := l_application + 1;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_APPL_CR_FAIL');
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reported error: ' || l_error);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                L_INVOICES_TBL(l_Count).REMAINING_AMOUNT := L_INVOICES_TBL(l_Count).REMAINING_AMOUNT - l_apply_amount;
                l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT := l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT - l_receipt_amount_from;

                if  l_CASH_RECEIPTS_TBL(l_Count1).RECEIPT_AMOUNT = 0 then

                    if l_receipt = l_CASH_RECEIPTS_TBL.count then
                        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Last receipt has been exhausted - exiting receipts loop');
                        l_quit := 'Y';
                        exit;
                    else
                        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Receipt #' || l_receipt || ' has been exhausted - continue with next receipt');
                        l_quit := 'N';
                        l_receipt := l_receipt + 1;
                    end if;

                end if;

                if l_exit_loop = 'Y' then
                    exit;
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count || ' has been fully paid - going to next invoice');
                end if;

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE FND_API.G_EXC_ERROR;
            END;

        END LOOP;

        if l_quit = 'Y' then
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Exiting invoices loop');
            exit;
        end if;

    END LOOP;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully applied ' || l_rc_count || ' receipts to ' || l_inv_count || ' invoices');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Number of applications: ' || l_application);

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
        ROLLBACK TO PAY_INSTALLMENTS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PAY_INSTALLMENTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO PAY_INSTALLMENTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




/*========================================================================
 | PUBLIC FUNCTION CAN_BILL_NEXT_INSTAL
 |
 | DESCRIPTION
 |      This function returns true/false is loan ready to bill next installment
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
 | 03-17-2009            scherkas          Created for bug
 |
 *=======================================================================*/
FUNCTION CAN_BILL_NEXT_INSTAL(P_LOAN_ID IN NUMBER) return BOOLEAN
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CAN_BILL_NEXT_INSTAL';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_return                            BOOLEAN;
    l_value                             varchar2(1);
    l_is_disable_bill		   VARCHAR2(1);

    l_loans_next_dd_rec             LNS_BILLING_BATCH_PUB.LOAN_NEXT_DD_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loans_cur(P_LOAN_ID NUMBER) IS
        select
            head.LOAN_ID,
            head.LOAN_NUMBER,
            head.OBJECT_VERSION_NUMBER,
            LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(head.LOAN_ID) + 1,
            head.CUSTOM_PAYMENTS_FLAG
        from LNS_LOAN_HEADERS head,
            LNS_TERMS term
        where head.LOAN_STATUS in ('ACTIVE', 'DEFAULT', 'DELINQUENT')
            and head.loan_id = term.loan_id
            and (head.BILLED_FLAG = 'Y' or head.BILLED_FLAG is null)
            and nvl(head.LAST_PAYMENT_NUMBER, 0) < (select max(END_INSTALLMENT_NUMBER) from lns_rate_schedules
                where term_id = term.term_id and phase = nvl(head.CURRENT_PHASE, 'TERM'))
            and trunc(term.NEXT_PAYMENT_DUE_DATE + nvl(term.NUMBER_GRACE_DAYS, 0)) < trunc(sysdate)
            and head.LOAN_ID = P_LOAN_ID;

    CURSOR can_bill_cur(P_LOAN_ID NUMBER) IS
        select 'x'
        from LNS_LOAN_HEADERS head,
            LNS_TERMS term
        where head.LOAN_STATUS in ('ACTIVE', 'DEFAULT', 'DELINQUENT')
            and head.loan_id = term.loan_id
            and (head.BILLED_FLAG is null or head.BILLED_FLAG = 'N')
            and nvl(head.LAST_PAYMENT_NUMBER, 0) < (select max(END_INSTALLMENT_NUMBER) from lns_rate_schedules
                where term_id = term.term_id and phase = nvl(head.CURRENT_PHASE, 'TERM'))
            and head.LOAN_ID = P_LOAN_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);
    l_return := false;

    /* verify input parameters */
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Checking the Disable_billing_flag in '||l_api_name);

    l_is_disable_bill := IS_BILLING_DISABLED(P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_is_disable_bill is '||l_is_disable_bill);
    IF l_is_disable_bill = 'Y' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILLING is Disabled for the loan : '||p_loan_id);
        return l_return;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Getting loan details...');
    open loans_cur(P_LOAN_ID);
    fetch loans_cur into
        l_loans_next_dd_rec.LOAN_ID,
        l_loans_next_dd_rec.LOAN_NUMBER,
        l_loans_next_dd_rec.OBJECT_VERSION_NUMBER,
        l_loans_next_dd_rec.NEXT_PAYMENT_NUMBER,
        l_loans_next_dd_rec.CUSTOM_PAYMENTS_FLAG;
    close loans_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER = ' || l_loans_next_dd_rec.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'NEXT_PAYMENT_NUMBER = ' || l_loans_next_dd_rec.NEXT_PAYMENT_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG = ' || l_loans_next_dd_rec.CUSTOM_PAYMENTS_FLAG);

    if l_loans_next_dd_rec.LOAN_ID is not null then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling CALC_SINGLE_LOAN_NEXT_DD...');
        CALC_SINGLE_LOAN_NEXT_DD(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
            P_COMMIT => FND_API.G_FALSE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_NEXT_DD_REC => l_loans_next_dd_rec,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully calculated next payment due date.');
        ELSE
    --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to calculate next payment due date.');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CALC_NEXT_DUE_FAIL');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    open can_bill_cur(P_LOAN_ID);
    fetch can_bill_cur into l_value;
    close can_bill_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_value = ' || l_value);
    if l_value is not null then
        l_return := true;
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

    return l_return;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception of ' || l_api_name);
        return l_return;
END;



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
 | 04-27-2009            scherkas          Created for bug
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_BILLED_INSTALLMENT';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    i                               number;

    l_invoice_rec                   LNS_BILLING_BATCH_PUB.INVOICE_DETAILS_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- fetching open invoices in payment order
    CURSOR invoices_cur(P_LOAN_ID number, P_AMORTIZATION_SCHED_ID number) IS
        select
            psa.customer_trx_id,
            psa.PAYMENT_SCHEDULE_ID,
            psa.trx_number,
            am.payment_number,
            decode(psa.customer_trx_id, am.principal_trx_id, 'PRIN', am.interest_trx_id, 'INT', am.fee_trx_id, 'FEE'),
            decode(psa.customer_trx_id, am.principal_trx_id, am.principal_amount, am.interest_trx_id, am.interest_amount, am.fee_trx_id, am.fee_amount),
            psa.amount_due_remaining,
            psa.due_date,
            psa.GL_DATE,
            psa.invoice_currency_code,
            nvl(loan.EXCHANGE_RATE, 1),
            trx_type.name
        from
            lns_amortization_scheds am,
            lns_loan_headers loan,
            ar_payment_schedules psa,
            RA_CUST_TRX_TYPES_ALL trx_type
        where
            am.loan_id = P_LOAN_ID and
            am.amortization_schedule_id = P_AMORTIZATION_SCHED_ID and
            loan.loan_id = am.loan_id and
            psa.customer_trx_id in (am.principal_trx_id, am.interest_trx_id, am.fee_trx_id) and
            (am.INTEREST_TRX_ID is not null or am.principal_trx_id is not null or am.FEE_TRX_ID is not null) and
            psa.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT GET_BILLED_INSTALLMENT;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_AM_SCHED_ID = ' || P_AM_SCHED_ID);

    /* verify input parameters */
    if P_LOAN_ID is null or P_AM_SCHED_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    i := 0;
    open invoices_cur(P_LOAN_ID, P_AM_SCHED_ID);
    LOOP

        fetch invoices_cur into
            l_invoice_rec.CUST_TRX_ID,
            l_invoice_rec.PAYMENT_SCHEDULE_ID,
            l_invoice_rec.INVOICE_NUMBER,
            l_invoice_rec.INSTALLMENT_NUMBER,
            l_invoice_rec.PURPOSE,
            l_invoice_rec.ORIGINAL_AMOUNT,
            l_invoice_rec.REMAINING_AMOUNT,
            l_invoice_rec.DUE_DATE,
            l_invoice_rec.GL_DATE,
            l_invoice_rec.INVOICE_CURRENCY,
            l_invoice_rec.EXCHANGE_RATE,
            l_invoice_rec.TRANSACTION_TYPE;
        exit when invoices_cur%NOTFOUND;

        i := i + 1;
        x_invoices_tbl(i) := l_invoice_rec;

        --x_invoices_tbl(i).TRANSACTION_TYPE := lns_utility_pub.getDocumentName(x_invoices_tbl(i).PURPOSE);
        x_invoices_tbl(i).PURPOSE := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', x_invoices_tbl(i).PURPOSE);
        x_invoices_tbl(i).FORGIVENESS_AMOUNT := 0;
        x_invoices_tbl(i).BILLED_FLAG := 'Y';

    END LOOP;
    close invoices_cur;

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
        ROLLBACK TO GET_BILLED_INSTALLMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO GET_BILLED_INSTALLMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO GET_BILLED_INSTALLMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE BILL_AND_PAY_OFFCYCLE_BILLS
 |
 | DESCRIPTION
 |      This procedure bills and pays manual (offcycle) installments
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_AND_PAY_OFFCYCLE_BILLS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_last_am_id                    NUMBER;
    l_new_am_id                     NUMBER;
    i                               NUMBER;

    l_am_scheds_tbl                 LNS_BILLING_BATCH_PUB.AMORTIZATION_SCHED_TBL;
    l_loans_to_bill_tbl		    LNS_BILLING_BATCH_PUB.LOANS_TO_BILL_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_last_am_cur(P_LOAN_ID number) IS
        select loan.LAST_AMORTIZATION_ID
        from LNS_LOAN_HEADERS_all loan
        where loan.loan_id = P_LOAN_ID;

    CURSOR get_new_am_cur(P_LOAN_ID number, P_LAST_AM_SCHED number) IS
        select AMORTIZATION_SCHEDULE_ID
        from LNS_AMORTIZATION_SCHEDS
        where loan_id = P_LOAN_ID and
        AMORTIZATION_SCHEDULE_ID > P_LAST_AM_SCHED and
        (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        order by AMORTIZATION_SCHEDULE_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT BILL_AND_PAY_OFFCYCLE_BILLS;
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
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API
    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);

    /* verify input parameters */
    if P_LOAN_ID is null or P_BILL_HEADERS_TBL.count = 0 then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- get last billed amortization_schedule_id
    open get_last_am_cur(P_LOAN_ID);
    fetch get_last_am_cur into l_last_am_id;
    close get_last_am_cur;

    if l_last_am_id is null then
        l_last_am_id := 0;
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Calling CREATE_OFFCYCLE_BILLS...');
    LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
        P_BILL_HEADERS_TBL      => P_BILL_HEADERS_TBL,
        P_BILL_LINES_TBL        => P_BILL_LINES_TBL,
        X_RETURN_STATUS	        => l_return_status,
        X_MSG_COUNT             => l_msg_count,
        X_MSG_DATA              => l_msg_data);

    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully billed offcycle bills.');
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if P_CASH_RECEIPTS_TBL.count > 0 then

        -- fetch all created manual bills
        i := 0;
        open get_new_am_cur(P_LOAN_ID, l_last_am_id);
        LOOP

            fetch get_new_am_cur into l_new_am_id;
            exit when get_new_am_cur%NOTFOUND;

            i := i + 1;
            l_am_scheds_tbl(i) := l_new_am_id;

        END LOOP;
        close get_new_am_cur;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling PAY_INSTALLMENTS...');
        PAY_INSTALLMENTS(
            P_API_VERSION => 1.0,
            P_INIT_MSG_LIST	=> FND_API.G_TRUE,
            P_COMMIT => FND_API.G_FALSE,
            P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID => P_LOAN_ID,
            P_AM_SCHED_TBL => l_am_scheds_tbl,
            P_CASH_RECEIPTS_TBL => P_CASH_RECEIPTS_TBL,
            X_RETURN_STATUS	=> l_return_status,
            X_MSG_COUNT => l_msg_count,
            X_MSG_DATA => l_msg_data);

        IF l_return_status = 'S' THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully applied cash receipts.');
        ELSE
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

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
        ROLLBACK TO BILL_AND_PAY_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BILL_AND_PAY_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO BILL_AND_PAY_OFFCYCLE_BILLS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;


/*========================================================================
 | PUBLIC PROCEDURE BILL_SING_LOAN_SUBMIT_APPR_FEE
 |
 | DESCRIPTION
 |      This procedure bills all the 'At Submit for Approval' fees for single loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |      CREATE_OFFCYCLE_BILLS
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT		    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID		    IN          Loan ID
 |	X_BILLED_YN		    OUT NOCOPY  Signifies whether loan billed
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT		    OUT NOCOPY  Standard out parameter
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
 | 07-JUL-2009           mbolli		Bug#6830765 -   Created
 |
 *=======================================================================*/
PROCEDURE BILL_SING_LOAN_SUBMIT_APPR_FEE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		    IN          NUMBER,
    P_LOAN_ID			    IN          NUMBER,
    X_BILLED_YN			    OUT NOCOPY  VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BILL_SING_LOAN_SUBMIT_APPR_FEE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_installment_num               number;
    l_Count                         number;
    l_Count1                        number;
    l_header_count                  number;
    l_loan_number                   varchar2(60);
    l_tot_fee_amt		    NUMBER;
    l_loan_start_date		    DATE;

    l_fee_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_BILL_HEADERS_TBL              LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL;
    l_BILL_LINES_TBL                LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying loan number */
    CURSOR loan_cur(P_LOAN_ID number) IS
        select
            LOAN_NUMBER, decode(current_phase, 'OPEN', OPEN_LOAN_START_DATE, LOAN_START_DATE)
        from LNS_LOAN_HEADERS
        where LOAN_ID = P_LOAN_ID;

BEGIN



    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT BILL_SING_LOAN_SUBMIT_APPR_FEE;
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
    l_installment_num := 0;

    X_BILLED_YN := 'N';

    /* verify input parameters */
    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* getting loan_number */
    open loan_cur(P_LOAN_ID);
    fetch loan_cur into l_loan_number, l_loan_start_date;
    close loan_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Billing At Submit for Approval fee at 0-th installment for loan ' || l_loan_number || '...');

    /* get UnBilled 'Submit For Approval' Fees  using getSubmitForApprFeeSchedule*/
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_FEES_ENGINE.getSubmitForApprFeeSchedule for Unbilled fees...');

    LNS_FEE_ENGINE.getSubmitForApprFeeSchedule(p_init_msg_list => FND_API.G_TRUE,
		    p_loan_Id => P_LOAN_ID,
		    p_billed_flag => 'N',
		    x_fees_tbl => l_fee_tbl,
		    X_RETURN_STATUS => l_return_status,
		    X_MSG_COUNT => l_msg_count,
		    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || substr(l_msg_data,1,225));

    if l_return_status <> 'S' then
	LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed in API LNS_FEES_ENGINE.getSubmitForApprFeeSchedule');
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Toal No. of UnBilled SubmitApproval Fees are: ' || l_fee_tbl.count);

    l_header_count := 101;
    l_BILL_HEADERS_TBL(1).HEADER_ID := l_header_count;
    l_BILL_HEADERS_TBL(1).LOAN_ID := P_LOAN_ID;
    l_BILL_HEADERS_TBL(1).ASSOC_PAYMENT_NUM := l_installment_num;

    -- Bug#8898777
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Start Date is: ' ||l_loan_start_date);
    if ( l_loan_start_date  < sysdate) then
    	l_BILL_HEADERS_TBL(1).DUE_DATE := l_loan_start_date;
    else
	    l_BILL_HEADERS_TBL(1).DUE_DATE := sysdate;
    end if;

    l_Count1 := 0;
    l_tot_fee_amt := 0;

    /* adding fee amounts into lines table */
    FOR l_Count IN 1..l_fee_tbl.count LOOP

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Fee #' || l_Count || ' Name: ' || l_fee_tbl(l_Count).FEE_NAME || ' Amount: ' || l_fee_tbl(l_Count).FEE_AMOUNT);

        l_Count1 := l_Count1 + 1;
        l_BILL_LINES_TBL(l_Count1).LINE_ID := 100 + l_Count1;
        l_BILL_LINES_TBL(l_Count1).HEADER_ID := l_header_count;
        l_BILL_LINES_TBL(l_Count1).LINE_AMOUNT := l_fee_tbl(l_Count).FEE_AMOUNT;
        l_BILL_LINES_TBL(l_Count1).LINE_TYPE := 'FEE';
        l_BILL_LINES_TBL(l_Count1).LINE_REF_ID := l_fee_tbl(l_Count).FEE_ID;
        l_BILL_LINES_TBL(l_Count1).LINE_DESC := l_fee_tbl(l_Count).FEE_NAME;
        l_BILL_LINES_TBL(l_Count1).FEE_SCHEDULE_ID := l_fee_tbl(l_Count).FEE_SCHEDULE_ID;
	    l_tot_fee_amt := l_tot_fee_amt + l_fee_tbl(l_Count).FEE_AMOUNT;

        /* updating LNS_FEE_SCHEDULES with billed_flag = Y */
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_FEE_SCHEDULES with billed_flag = Y ...');
        UPDATE LNS_FEE_SCHEDULES
        SET
            BILLED_FLAG                     =     'Y',
            last_update_date                =     LNS_UTILITY_PUB.LAST_UPDATE_DATE,
            last_updated_by                 =     LNS_UTILITY_PUB.LAST_UPDATED_BY,
            last_update_login               =     LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
        WHERE
            FEE_SCHEDULE_ID = l_fee_tbl(l_Count).fee_schedule_id;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_FEE_SCHEDULES');

    END LOOP;

    IF (l_tot_fee_amt = 0) THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'SubmitForApproval Fee Amount = 0. Nothing to bill.');
        return;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS...');

    LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_TRUE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
        P_BILL_HEADERS_TBL      => l_BILL_HEADERS_TBL,
        P_BILL_LINES_TBL        => l_BILL_LINES_TBL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully billed At Submit For Approval Fee at 0-th installment for loan ' || l_loan_number);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    X_BILLED_YN := 'Y';

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BILL_SING_LOAN_SUBMIT_APPR_FEE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BILL_SING_LOAN_SUBMIT_APPR_FEE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO BILL_SING_LOAN_SUBMIT_APPR_FEE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;

PROCEDURE REVERSE_BILLED_FEES(p_amortization_id IN NUMBER)
IS
	l_api_name                CONSTANT VARCHAR2(30) := 'REVERSE_BILLED_FEES';
	l_fee_schedule_id	LNS_FEE_SCHEDULES.fee_schedule_id%TYPE;
	l_obj_ver_num		NUMBER;
	l_count			NUMBER;

	-- At present Reversing only SubmitForApproval Fees
	CURSOR c_billed_submitAppFee(c_amortization_id  NUMBER)     IS
	SELECT lines.fee_schedule_id, feeSchd.object_version_number
	FROM   LNS_AMORTIZATION_SCHEDS  scheds,lns_amortization_lines lines, lns_fees_all fee, lns_fee_schedules feeSchd
	WHERE  scheds.amortization_schedule_id = lines.amortization_schedule_id
	AND    scheds.amortization_schedule_id = C_AMORTIZATION_ID
	AND    lines.line_type = 'FEE'
	AND    fee.fee_id = lines.fee_id
	AND    fee.billing_option = 'SUBMIT_FOR_APPROVAL'
	AND    feeSchd.fee_schedule_id = lines.fee_schedule_id
	AND    feeSchd.billed_flag = 'Y'
	AND    feeSchd.active_flag = 'Y';

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* verify input parameters */
    if P_AMORTIZATION_ID is null then
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_MAN_REV_NO_AMORT');
	FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;


    l_count := 0;
    OPEN c_billed_submitAppFee(P_AMORTIZATION_ID);
    LOOP
    FETCH c_billed_submitAppFee into l_fee_schedule_id, l_obj_ver_num;
    EXIT WHEN c_billed_submitAppFee%NOTFOUND;
	LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The fee_schedule_id is '||l_fee_schedule_id);

	LNS_FEE_SCHEDULES_PKG.UPDATE_ROW(P_FEE_SCHEDULE_ID              => l_fee_schedule_id
                                  		,P_FEE_ID               => null
						,P_LOAN_ID              => null
						,P_FEE_AMOUNT           => null
						,P_FEE_INSTALLMENT      => null
						,P_FEE_DESCRIPTION      => null
						,P_ACTIVE_FLAG          => null
						,P_BILLED_FLAG          => 'N'  -- Make BilledFlag to 'N'
						,P_FEE_WAIVABLE_FLAG    => null
						,P_WAIVED_AMOUNT        => null
						,P_LAST_UPDATED_BY      => LNS_UTILITY_PUB.LAST_UPDATED_BY
						,P_LAST_UPDATE_DATE     => LNS_UTILITY_PUB.LAST_UPDATE_DATE
						,P_LAST_UPDATE_LOGIN    => LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
						,P_PROGRAM_ID           => null
						,P_REQUEST_ID           => null
						,P_OBJECT_VERSION_NUMBER => l_obj_ver_num + 1);
	l_count := l_count + 1;
	LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Updated fee_schedule_id '||l_fee_schedule_id||' successfully');

      END LOOP;

      LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Total No. of submitForApprFee fee_schedule records updated are '||l_count);
    CLOSE c_billed_submitAppFee;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END REVERSE_BILLED_FEES;


/*========================================================================
 | PUBLIC FUNCTION IS_BILLING_DISABLED
 |
 | DESCRIPTION
 |      This function returns Y/N is loan is ready to bill or not
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
FUNCTION IS_BILLING_DISABLED(P_LOAN_ID IN NUMBER) return VARCHAR2 IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'IS_BILLING_DISABLED';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_return                            BOOLEAN;
    l_disable_bill_flag              VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   								 |
 +-----------------------------------------------------------------------*/

    CURSOR cur_disable_bill(C_LOAN_ID NUMBER) IS
        SELECT head.DISABLE_BILLING_FLAG
        FROM   LNS_LOAN_HEADERS_ALL head
	where head.loan_id = C_LOAN_ID;
BEGIN

    --LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- START OF BODY OF API
    --init;

    --LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input loan_id = ' || P_LOAN_ID);
    --l_disable_bill_flag := 'N';

    /* verify input parameters */
    if P_LOAN_ID is null then

    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
       -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

   -- LogMessage(FND_LOG.LEVEL_STATEMENT, 'Getting loan details...');
    open cur_disable_bill(P_LOAN_ID);
    fetch cur_disable_bill into  l_disable_bill_flag;
    if l_disable_bill_flag IS NULL then
        l_disable_bill_flag := 'N';
    end if;
    close cur_disable_bill;

    --LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISABLE_FLAG = ' || l_disable_bill_flag);

   -- LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

    return l_disable_bill_flag;

EXCEPTION
    WHEN OTHERS THEN
       -- LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In exception of ' || l_api_name);
       l_disable_bill_flag := NULL;
        return l_disable_bill_flag;
END;



/*========================================================================
 | PUBLIC PROCEDURE ADJUST_ADD_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure adjusts loans additional receivable in AR
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
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'ADJUST_ADD_RECEIVABLE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_number                   varchar2(60);
    l_trx_number                    varchar2(20);
    l_payment_schedule_id           number;
    l_amount_due_remaining          number;
    l_type                          varchar2(15);
    l_loan_desc                     varchar2(250);
    l_comments                      varchar2(2000);
    l_adj_number                    varchar2(20);
    l_adj_id                        number;
    l_ussgl_flag                    varchar2(3);
    l_requested_amount              number;
    l_line_id                       number;
    l_apply_date                    date;
    l_gl_date                       date;
    l_org_id                        number;
	l_legal_entity_id               number;
    l_installment_number            number;
    l_loan_id                       number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying trx, psa and loan details */
    CURSOR add_rec_cur(P_LOAN_LINE_ID number) IS
        select
            loan.loan_id,
	        loan.loan_number,
            loan.LOAN_DESCRIPTION,
            lines.REQUESTED_AMOUNT,
            lines.reference_number,
            lines.REC_ADJUSTMENT_NUMBER,
            nvl(lines.payment_schedule_id, psa.payment_schedule_id),
            psa.AMOUNT_DUE_REMAINING,
            lines.LOAN_LINE_ID,
            lines.ADJUSTMENT_DATE,
            psa.GL_DATE,
            trx.org_id,
    		trx.legal_entity_id,
            lines.REC_ADJUSTMENT_ID,
            nvl(lines.installment_number, 1)
        from LNS_LOAN_HEADERS loan,
            RA_CUSTOMER_TRX trx,
            ar_payment_schedules psa,
            lns_loan_lines lines
        where lines.LOAN_LINE_ID = P_LOAN_LINE_ID and
        	loan.loan_id = lines.loan_id and
            lines.reference_type = 'RECEIVABLE' and
            lines.REFERENCE_ID = trx.CUSTOMER_TRX_ID and
            lines.REFERENCE_NUMBER = trx.trx_number and
            lines.end_date is null and
            trx.CUSTOMER_TRX_ID = psa.CUSTOMER_TRX_ID and
            nvl(lines.installment_number, 1) = psa.terms_sequence_number;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT ADJUST_ADD_RECEIVABLE;
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

    init;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input P_LOAN_LINE_ID = ' || P_LOAN_LINE_ID);

    /* verify input parameters */
    if P_LOAN_LINE_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_LINE_ID' );
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* checking for system options values required for adjustment */
    if g_receivables_trx_id is null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Receivables activity name is not set in the system option.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_REC_TRX_IN_SYS_OPT');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* querying trx, psa, loan and loan lines details */
    open add_rec_cur(P_LOAN_LINE_ID);
    fetch add_rec_cur into
        l_loan_id,
        l_loan_number,
        l_loan_desc,
        l_requested_amount,
        l_trx_number,
        l_adj_number,
        l_payment_schedule_id,
        l_amount_due_remaining,
        l_line_id,
        l_apply_date,
        l_gl_date,
        l_org_id,
        l_legal_entity_id,
        l_adj_id,
        l_installment_number;
    close add_rec_cur;

    if l_payment_schedule_id is null then
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_CANT_FIND_ORIG_REC');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjusting additional receivable ' || l_trx_number || 'for loan ' ||  l_loan_number || '...');

    /* verify adjust amount and set adjustment type */
    if l_requested_amount > l_amount_due_remaining then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Adjust amount cannot be greater than receivable remaining amount.');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjustment amount: -' || l_requested_amount);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receivable remaining amount: ' || l_amount_due_remaining);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_ADJ_AMT');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    else
        l_type := 'LINE';
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Adjustment amount = -' || l_requested_amount);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receivable remaining amount = ' || l_amount_due_remaining);

    /* checking if adjustment for this loan already was made */
    if l_adj_number is not null or l_adj_id is not null then
--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Attempt to duplicate adjustment. Receivable has been already adjusted for this loan by adjustment xxx' );
        FND_MESSAGE.SET_NAME('LNS', 'LNS_DUPL_ADJ_ORIG_REC');
        FND_MESSAGE.SET_TOKEN('ADJ', l_adj_number);
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* buld comments */
    l_comments := 'Loan ' || l_loan_number;

    /* do adjustment */
    CREATE_AR_ADJ(P_TYPE => l_type,
        P_PAYMENT_SCHEDULE_ID => l_payment_schedule_id,
        P_RECEIVABLES_TRX_ID => g_receivables_trx_id,
        P_AMOUNT => -l_requested_amount,
        P_APPLY_DATE => l_apply_date,
        P_GL_DATE => l_apply_date,
        P_CUSTOMER_TRX_LINE_ID => null,
        P_CODE_COMBINATION_ID => null,
        P_USSGL_TRX_CODE => g_USSGL_TRANSACTION_CODE,
        P_REASON_CODE => 'LOAN_CONV',
        P_COMMENTS => l_comments,
        X_ADJ_ID => l_adj_id,
        X_ADJ_NUMBER => l_adj_number,
        P_ORG_ID => l_org_id);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating LNS_LOAN_LINES...');
    LNS_LOAN_LINE_PUB.UPDATE_LINE_ADJUSTMENT_NUMBER(
        p_init_msg_list             => FND_API.G_FALSE
        ,p_loan_id                  => l_loan_id
        ,p_loan_line_id             => l_line_id
        ,p_rec_adjustment_number    => l_adj_number
        ,p_rec_adjustment_id        => l_adj_id
        ,P_PAYMENT_SCHEDULE_ID      => l_payment_schedule_id
        ,P_INSTALLMENT_NUMBER       => l_installment_number
        ,p_adjustment_date          => l_apply_date
        ,p_original_flag            => 'N'
        ,x_return_status            => l_return_status
        ,x_msg_count                => l_msg_count
        ,x_msg_data                 => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
    IF l_return_status = 'S' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully updated LNS_LOAN_LINES');
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully created adjustment ' || l_adj_number || ' for additional receivable ' || l_trx_number);

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
        ROLLBACK TO ADJUST_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ADJUST_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO ADJUST_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
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

END;


/

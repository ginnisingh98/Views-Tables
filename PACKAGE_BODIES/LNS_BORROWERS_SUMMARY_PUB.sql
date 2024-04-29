--------------------------------------------------------
--  DDL for Package Body LNS_BORROWERS_SUMMARY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_BORROWERS_SUMMARY_PUB" as
/* $Header: LNS_BORR_SUM_B.pls 120.7 2006/07/11 23:09:48 karamach noship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_BORROWERS_SUMMARY_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BORR_SUM_CONCUR
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
    if (p_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

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
 | PRIVATE PROCEDURE init
 |
 | DESCRIPTION
 |      This procedure inits data needed for processing
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      GENERATE_BORROWER_SUMMARY
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
 | 04-14-2004            scherkas          Created
 |
 *=======================================================================*/
Procedure init
IS
BEGIN

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

END;



/*========================================================================
 | PRIVATE PROCEDURE GET_BORROWER_OVERVIEW
 |
 | DESCRIPTION
 |      This procedure generates borrower overview part.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      GEN_SINGLE_BORROWER_SUMMARY
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_BORROWER_TBL IN OUT NOCOPY  borrower table
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
PROCEDURE GET_BORROWER_OVERVIEW(P_BORROWER_TBL IN OUT NOCOPY  LNS_BORROWERS_SUMMARY_PUB.BORROWER_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_BORROWER_OVERVIEW';
    l_Count                         number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR party1_cur(P_PARTY_ID number) IS
        select
            party.party_name BORROWER_NAME,
            party.JGZZ_FISCAL_CODE,
            ass.CLASS_CODE,
            party.SIC_CODE,
            party.YEAR_ESTABLISHED,
            null PRIMARY_CONTACT_NAME,
            party.PRIMARY_PHONE_COUNTRY_CODE,
            party.PRIMARY_PHONE_AREA_CODE,
            party.PRIMARY_PHONE_NUMBER,
            party.PRIMARY_PHONE_EXTENSION,
            party.CURR_FY_POTENTIAL_REVENUE
        from hz_parties party,
            HZ_CODE_ASSIGNMENTS ass
        where party.party_id = P_PARTY_ID and
            ass.OWNER_TABLE_NAME(+) = 'HZ_PARTIES' and
            ass.OWNER_TABLE_ID(+) = party.party_id and
            ass.CLASS_CATEGORY(+) = 'CUSTOMER_CATEGORY'and
            ass.PRIMARY_FLAG(+) = 'Y' and
            ass.START_DATE_ACTIVE(+) <= sysdate and
            nvl(ass.END_DATE_ACTIVE(+), sysdate) >= sysdate;

    CURSOR party2_cur(P_PARTY_ID number) IS
        select
            loc.COUNTRY,
            loc.address1,
            loc.address2,
            loc.address3,
            loc.address4,
            loc.city,
            loc.postal_code,
            loc.state
        from hz_party_sites site,
            hz_locations loc,
            HZ_PARTY_SITE_USES use
        where site.party_id = P_PARTY_ID and
            site.PARTY_SITE_ID = use.PARTY_SITE_ID(+) and
            use.SITE_USE_TYPE(+) = 'BILL_TO' and
            use.PRIMARY_PER_TYPE(+) = 'Y' and
            use.status(+) = 'A' and
            site.location_id = loc.location_id
        order by use.PRIMARY_PER_TYPE;

    CURSOR customer_since_cur(P_PARTY_ID number) IS
        select min(account_established_date)
        from hz_cust_accounts_all
        where
            account_established_date is not null and
            party_id = P_PARTY_ID;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    open party1_cur(P_BORROWER_TBL(1).BORROWER_PARTY_ID);
    fetch party1_cur into
            P_BORROWER_TBL(1).BORROWER_NAME,
            P_BORROWER_TBL(1).tax_payer_code,
            P_BORROWER_TBL(1).CUSTOMER_CLASSIFICATION,
            P_BORROWER_TBL(1).INDUSTRIAL_CLASSIFICATION,
            P_BORROWER_TBL(1).YEAR_ESTABLISHED,
            P_BORROWER_TBL(1).PRIMARY_CONTACT_NAME,
            P_BORROWER_TBL(1).PRIMARY_PHONE_COUNTRY_CODE,
            P_BORROWER_TBL(1).PRIMARY_PHONE_AREA_CODE,
            P_BORROWER_TBL(1).PRIMARY_PHONE_NUMBER,
            P_BORROWER_TBL(1).PRIMARY_PHONE_EXTENSION,
            P_BORROWER_TBL(1).ANNUAL_REVENUE;
    close party1_cur;

    open party2_cur(P_BORROWER_TBL(1).BORROWER_PARTY_ID);
    fetch party2_cur into
            P_BORROWER_TBL(1).COUNTRY,
            P_BORROWER_TBL(1).ADDRESS1,
            P_BORROWER_TBL(1).ADDRESS2,
            P_BORROWER_TBL(1).ADDRESS3,
            P_BORROWER_TBL(1).ADDRESS4,
            P_BORROWER_TBL(1).CITY,
            P_BORROWER_TBL(1).POSTAL_CODE,
            P_BORROWER_TBL(1).STATE;
    close party2_cur;

    open customer_since_cur(P_BORROWER_TBL(1).BORROWER_PARTY_ID);
    fetch customer_since_cur into P_BORROWER_TBL(1).CUSTOMER_SINCE;
    close customer_since_cur;

    FOR l_Count IN 2..P_BORROWER_TBL.COUNT LOOP
        P_BORROWER_TBL(l_Count).BORROWER_NAME := P_BORROWER_TBL(1).BORROWER_NAME;
        P_BORROWER_TBL(l_Count).tax_payer_code := P_BORROWER_TBL(1).tax_payer_code;
        P_BORROWER_TBL(l_Count).CUSTOMER_CLASSIFICATION := P_BORROWER_TBL(1).CUSTOMER_CLASSIFICATION;
        P_BORROWER_TBL(l_Count).INDUSTRIAL_CLASSIFICATION := P_BORROWER_TBL(1).INDUSTRIAL_CLASSIFICATION;
        P_BORROWER_TBL(l_Count).YEAR_ESTABLISHED := P_BORROWER_TBL(1).YEAR_ESTABLISHED;
        P_BORROWER_TBL(l_Count).COUNTRY := P_BORROWER_TBL(1).COUNTRY;
        P_BORROWER_TBL(l_Count).ADDRESS1 := P_BORROWER_TBL(1).ADDRESS1;
        P_BORROWER_TBL(l_Count).ADDRESS2 := P_BORROWER_TBL(1).ADDRESS2;
        P_BORROWER_TBL(l_Count).ADDRESS3 := P_BORROWER_TBL(1).ADDRESS3;
        P_BORROWER_TBL(l_Count).ADDRESS4 := P_BORROWER_TBL(1).ADDRESS4;
        P_BORROWER_TBL(l_Count).CITY := P_BORROWER_TBL(1).CITY;
        P_BORROWER_TBL(l_Count).POSTAL_CODE := P_BORROWER_TBL(1).POSTAL_CODE;
        P_BORROWER_TBL(l_Count).STATE := P_BORROWER_TBL(1).STATE;
        P_BORROWER_TBL(l_Count).PRIMARY_CONTACT_NAME := P_BORROWER_TBL(1).PRIMARY_CONTACT_NAME;
        P_BORROWER_TBL(l_Count).PRIMARY_PHONE_COUNTRY_CODE := P_BORROWER_TBL(1).PRIMARY_PHONE_COUNTRY_CODE;
        P_BORROWER_TBL(l_Count).PRIMARY_PHONE_AREA_CODE := P_BORROWER_TBL(1).PRIMARY_PHONE_AREA_CODE;
        P_BORROWER_TBL(l_Count).PRIMARY_PHONE_NUMBER := P_BORROWER_TBL(1).PRIMARY_PHONE_NUMBER;
        P_BORROWER_TBL(l_Count).PRIMARY_PHONE_EXTENSION := P_BORROWER_TBL(1).PRIMARY_PHONE_EXTENSION;
        P_BORROWER_TBL(l_Count).ANNUAL_REVENUE := P_BORROWER_TBL(1).ANNUAL_REVENUE;
    END LOOP;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate borrower overview');
END;




/*========================================================================
 | PRIVATE PROCEDURE GET_LOAN_SUMMARY
 |
 | DESCRIPTION
 |      This procedure generates loans summary part.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      GEN_SINGLE_BORROWER_SUMMARY
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_BORROWER_TBL IN OUT NOCOPY  borrower table
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
PROCEDURE GET_LOAN_SUMMARY(P_BORROWER_TBL IN OUT NOCOPY  LNS_BORROWERS_SUMMARY_PUB.BORROWER_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_LOAN_SUMMARY';
    l_total_paid_principal          NUMBER;
    l_Count                         number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loans_cur(P_PARTY_ID number, P_ORG_ID number, P_CURRENCY varchar2) IS
        select
            nvl(count(head.loan_id), 0),
            nvl(sum(decode(head.LOAN_CURRENCY, P_CURRENCY, head.REQUESTED_AMOUNT, (head.REQUESTED_AMOUNT*head.EXCHANGE_RATE))), 0),
            nvl(sum(decode(head.LOAN_CURRENCY, P_CURRENCY, head.FUNDED_AMOUNT, (head.FUNDED_AMOUNT*head.EXCHANGE_RATE))), 0)
        from
            lns_participants par,
            lns_loan_headers_all head
        where
            par.hz_party_id = P_PARTY_ID and
            par.loan_id = head.loan_id and
            par.loan_participant_type in ('PRIMARY_BORROWER', 'COBORROWER') and
            head.loan_status in ('ACTIVE', 'APPROVED', 'DEFAULT', 'DELINQUENT', 'IN_FUNDING', 'PAIDOFF', 'PENDING_CANCELLATION') and
            head.org_id = P_ORG_ID;

    CURSOR func_curr_cur(P_ORG_ID number) IS
        select books.currency_code
        from lns_system_options_all sys,
            gl_sets_of_books books
        where sys.org_id = P_ORG_ID and
            sys.set_of_books_id = books.set_of_books_id;

    CURSOR amount_ytd_cur(P_PARTY_ID number, P_LINE_TYPE VARCHAR2, P_TIME_FLAG VARCHAR2, P_ORG_ID number) IS
          select
            nvl(sum(rec.ACCTD_AMOUNT_APPLIED_TO), 0)
          from
            lns_loan_headers_ALL loan,
            LNS_AMORTIZATION_SCHEDS am,
            ar_receivable_applications_ALL rec,
            lns_participants par
          where
            par.hz_party_id = P_PARTY_ID and
            par.loan_participant_type in ('PRIMARY_BORROWER', 'COBORROWER') and
            par.loan_id = loan.loan_id and
            loan.loan_status in ('ACTIVE', 'APPROVED', 'DEFAULT', 'DELINQUENT', 'IN_FUNDING', 'PAIDOFF', 'PENDING_CANCELLATION') and
            loan.loan_id = am.loan_id and
            loan.org_id = P_ORG_ID and
            rec.org_id = loan.org_id and
            rec.APPLIED_CUSTOMER_TRX_ID =
                decode(P_LINE_TYPE, 'PRIN', am.principal_trx_id, 'INT', am.interest_trx_id, 'FEE', am.fee_trx_id) and
            rec.application_type = 'CASH' and
            trunc(rec.APPLY_DATE) >= decode(P_TIME_FLAG, 'YTD', trunc(sysdate, 'YYYY'), trunc(rec.APPLY_DATE)) and
            trunc(rec.APPLY_DATE) <= decode(P_TIME_FLAG, 'YTD', trunc(add_months(sysdate, 12), 'YYYY')-1, trunc(rec.APPLY_DATE));

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    FOR l_Count IN 1..P_BORROWER_TBL.COUNT LOOP

        open func_curr_cur(P_BORROWER_TBL(l_Count).ORG_ID);
        fetch func_curr_cur into P_BORROWER_TBL(l_Count).FUNCTIONAL_CURRENCY;
        close func_curr_cur;

        open loans_cur(P_BORROWER_TBL(l_Count).BORROWER_PARTY_ID, P_BORROWER_TBL(l_Count).ORG_ID,P_BORROWER_TBL(l_Count).FUNCTIONAL_CURRENCY);
        fetch loans_cur into
            P_BORROWER_TBL(l_Count).NUM_ACTIVE_LOANS,
            P_BORROWER_TBL(l_Count).TOTAL_REQUESTED_LOAN_AMOUNT,
            P_BORROWER_TBL(l_Count).TOTAL_APPROVED_LOAN_AMOUNT;
        close loans_cur;

        open amount_ytd_cur(P_BORROWER_TBL(l_Count).BORROWER_PARTY_ID, 'PRIN', 'YTD', P_BORROWER_TBL(l_Count).ORG_ID);
        fetch amount_ytd_cur into P_BORROWER_TBL(l_Count).TOTAL_PRINCIPAL_PAID_YTD;
        close amount_ytd_cur;

        open amount_ytd_cur(P_BORROWER_TBL(l_Count).BORROWER_PARTY_ID, 'INT', 'YTD', P_BORROWER_TBL(l_Count).ORG_ID);
        fetch amount_ytd_cur into P_BORROWER_TBL(l_Count).TOTAL_INTEREST_PAID_YTD;
        close amount_ytd_cur;

        open amount_ytd_cur(P_BORROWER_TBL(l_Count).BORROWER_PARTY_ID, 'FEE', 'YTD', P_BORROWER_TBL(l_Count).ORG_ID);
        fetch amount_ytd_cur into P_BORROWER_TBL(l_Count).TOTAL_FEE_PAID_YTD;
        close amount_ytd_cur;

        open amount_ytd_cur(P_BORROWER_TBL(l_Count).BORROWER_PARTY_ID, 'PRIN', 'ALL', P_BORROWER_TBL(l_Count).ORG_ID);
        fetch amount_ytd_cur into l_total_paid_principal;
        close amount_ytd_cur;

        P_BORROWER_TBL(l_Count).TOTAL_REMAINING_PRINCIPAL := P_BORROWER_TBL(l_Count).TOTAL_APPROVED_LOAN_AMOUNT - l_total_paid_principal;

        P_BORROWER_TBL(l_Count).PLEDGED_COLL_AMOUNT := 0;
        P_BORROWER_TBL(l_Count).LAST_COLL_VALUATION_DATE := null;

    END LOOP;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate loans summary');
END;



/*========================================================================
 | PRIVATE PROCEDURE GET_CREDIT_SUMMARY
 |
 | DESCRIPTION
 |      This procedure generates credit summary part.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      GEN_SINGLE_BORROWER_SUMMARY
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_BORROWER_TBL IN OUT NOCOPY  borrower table
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
PROCEDURE GET_CREDIT_SUMMARY(P_BORROWER_TBL IN OUT NOCOPY  LNS_BORROWERS_SUMMARY_PUB.BORROWER_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_CREDIT_SUMMARY';
    l_Count                         number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR credit_cur(P_PARTY_ID number) IS
        select
            CREDIT_CLASSIFICATION,
            REVIEW_CYCLE,
            LAST_CREDIT_REVIEW_DATE,
            CREDIT_RATING,
            CREDIT_HOLD,
            CREDIT_CHECKING,
            TOLERANCE
        from HZ_CUSTOMER_PROFILES
        where party_id = P_PARTY_ID and
            cust_account_id = -1 and
            site_use_id is null;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    open credit_cur(P_BORROWER_TBL(1).BORROWER_PARTY_ID);
    fetch credit_cur into
            P_BORROWER_TBL(1).CREDIT_CLASSIFICATION,
            P_BORROWER_TBL(1).REVIEW_CYCLE,
            P_BORROWER_TBL(1).LAST_CREDIT_REVIEW_DATE,
            P_BORROWER_TBL(1).CREDIT_RATING,
            P_BORROWER_TBL(1).CREDIT_HOLD,
            P_BORROWER_TBL(1).CREDIT_CHECKING,
            P_BORROWER_TBL(1).TOLERANCE;
    close credit_cur;

    FOR l_Count IN 2..P_BORROWER_TBL.COUNT LOOP
        P_BORROWER_TBL(l_Count).CREDIT_CLASSIFICATION := P_BORROWER_TBL(1).CREDIT_CLASSIFICATION;
        P_BORROWER_TBL(l_Count).REVIEW_CYCLE := P_BORROWER_TBL(1).REVIEW_CYCLE;
        P_BORROWER_TBL(l_Count).LAST_CREDIT_REVIEW_DATE := P_BORROWER_TBL(1).LAST_CREDIT_REVIEW_DATE;
        P_BORROWER_TBL(l_Count).CREDIT_RATING := P_BORROWER_TBL(1).CREDIT_RATING;
        P_BORROWER_TBL(l_Count).CREDIT_HOLD := P_BORROWER_TBL(1).CREDIT_HOLD;
        P_BORROWER_TBL(l_Count).CREDIT_CHECKING := P_BORROWER_TBL(1).CREDIT_CHECKING;
        P_BORROWER_TBL(l_Count).TOLERANCE := P_BORROWER_TBL(1).TOLERANCE;
    END LOOP;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate credit summary');
END;




/*========================================================================
 | PRIVATE PROCEDURE GEN_SINGLE_BORROWER_SUMMARY
 |
 | DESCRIPTION
 |      This procedure generates a single borrower summary.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      GENERATE_BORROWERS_SUMMARY
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 | Date                  Author            Description of Changes
 | 04-14-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE GEN_SINGLE_BORROWER_SUMMARY(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_BORROWER_PARTY_ID IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GEN_SINGLE_BORROWER_SUMMARY';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_borrower_id                   number;
    l_ORG_ID                        NUMBER;
    l_ORG_NAME                      VARCHAR2(240);
    l_LEGAL_ENTITY_ID               NUMBER;
    l_LEGAL_ENTITY_NAME             VARCHAR2(240);
    l_Count                         number;

    l_borrower_tbl                  LNS_BORROWERS_SUMMARY_PUB.BORROWER_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR orgs_cur IS
        select org.ORGANIZATION_ID,
            org.name,
            null,
            null
        from lns_system_options_all sys,
            hr_operating_units org
        where sys.ORG_ID = org.ORGANIZATION_ID;

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

    l_Count := 0;
    open orgs_cur;
    LOOP

        fetch orgs_cur into l_ORG_ID,
                            l_ORG_NAME,
                            l_LEGAL_ENTITY_ID,
                            l_LEGAL_ENTITY_NAME;
        exit when orgs_cur%NOTFOUND;

        l_Count := l_Count + 1;
        l_borrower_tbl(l_Count).ORG_ID := l_ORG_ID;
        l_borrower_tbl(l_Count).ORG_NAME := l_ORG_NAME;
        l_borrower_tbl(l_Count).LEGAL_ENTITY_ID := l_LEGAL_ENTITY_ID;
        l_borrower_tbl(l_Count).LEGAL_ENTITY_NAME := l_LEGAL_ENTITY_NAME;
        l_borrower_tbl(l_Count).BORROWER_PARTY_ID := P_BORROWER_PARTY_ID;

    END LOOP;
    close orgs_cur;

    /* generate borrower overview part */
    GET_BORROWER_OVERVIEW(l_borrower_tbl);

    /* generate loans summary part */
    GET_LOAN_SUMMARY(l_borrower_tbl);

    /* generate credit summary part */
    GET_CREDIT_SUMMARY(l_borrower_tbl);

    delete from LNS_BORROWER_SUMMARIES
    where BORROWER_PARTY_ID = P_BORROWER_PARTY_ID;

    -- borrower summary
    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Borrower summary');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_PARTY_ID: ' || l_BORROWER_TBL(l_Count).BORROWER_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_NAME: ' || l_BORROWER_TBL(l_Count).BORROWER_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'tax_payer_code: ' || l_BORROWER_TBL(l_Count).tax_payer_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_CLASSIFICATION: ' || l_BORROWER_TBL(l_Count).CUSTOMER_CLASSIFICATION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INDUSTRIAL_CLASSIFICATION: ' || l_BORROWER_TBL(l_Count).INDUSTRIAL_CLASSIFICATION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'YEAR_ESTABLISHED: ' || l_BORROWER_TBL(l_Count).YEAR_ESTABLISHED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'COUNTRY: ' || l_BORROWER_TBL(l_Count).COUNTRY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ADDRESS1: ' || l_BORROWER_TBL(l_Count).ADDRESS1);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ADDRESS2: ' || l_BORROWER_TBL(l_Count).ADDRESS2);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ADDRESS3: ' || l_BORROWER_TBL(l_Count).ADDRESS3);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ADDRESS4: ' || l_BORROWER_TBL(l_Count).ADDRESS4);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CITY: ' || l_BORROWER_TBL(l_Count).CITY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'POSTAL_CODE: ' || l_BORROWER_TBL(l_Count).POSTAL_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'STATE: ' || l_BORROWER_TBL(l_Count).STATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIMARY_CONTACT_NAME: ' || l_BORROWER_TBL(l_Count).PRIMARY_CONTACT_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIMARY_PHONE_COUNTRY_CODE: ' || l_BORROWER_TBL(l_Count).PRIMARY_PHONE_COUNTRY_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIMARY_PHONE_AREA_CODE: ' || l_BORROWER_TBL(l_Count).PRIMARY_PHONE_AREA_CODE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIMARY_PHONE_NUMBER: ' || l_BORROWER_TBL(l_Count).PRIMARY_PHONE_NUMBER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIMARY_PHONE_EXTENSION: ' || l_BORROWER_TBL(l_Count).PRIMARY_PHONE_EXTENSION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ANNUAL_REVENUE: ' || l_BORROWER_TBL(l_Count).ANNUAL_REVENUE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOMER_SINCE: ' || l_BORROWER_TBL(l_Count).CUSTOMER_SINCE);

    -- loans summary
    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loans Summary');
    FOR l_Count IN 1..l_borrower_tbl.COUNT LOOP
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Record #' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORG_ID: ' || l_BORROWER_TBL(l_Count).ORG_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORG_NAME: ' || l_BORROWER_TBL(l_Count).ORG_NAME);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LEGAL_ENTITY_ID: ' || l_BORROWER_TBL(l_Count).LEGAL_ENTITY_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LEGAL_ENTITY_NAME: ' || l_BORROWER_TBL(l_Count).LEGAL_ENTITY_NAME);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUM_ACTIVE_LOANS: ' || l_BORROWER_TBL(l_Count).NUM_ACTIVE_LOANS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_REMAINING_PRINCIPAL: ' || l_BORROWER_TBL(l_Count).TOTAL_REMAINING_PRINCIPAL);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_PRINCIPAL_PAID_YTD: ' || l_BORROWER_TBL(l_Count).TOTAL_PRINCIPAL_PAID_YTD);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_INTEREST_PAID_YTD: ' || l_BORROWER_TBL(l_Count).TOTAL_INTEREST_PAID_YTD);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_FEE_PAID_YTD: ' || l_BORROWER_TBL(l_Count).TOTAL_FEE_PAID_YTD);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_REQUESTED_LOAN_AMOUNT: ' || l_BORROWER_TBL(l_Count).TOTAL_REQUESTED_LOAN_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOTAL_APPROVED_LOAN_AMOUNT: ' || l_BORROWER_TBL(l_Count).TOTAL_APPROVED_LOAN_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PLEDGED_COLL_AMOUNT: ' || l_BORROWER_TBL(l_Count).PLEDGED_COLL_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_COLL_VALUATION_DATE: ' || l_BORROWER_TBL(l_Count).LAST_COLL_VALUATION_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FUNCTIONAL_CURRENCY: ' || l_BORROWER_TBL(l_Count).FUNCTIONAL_CURRENCY);
    END LOOP;

    -- credit summary
    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Credit Summary');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CREDIT_CLASSIFICATION: ' || l_BORROWER_TBL(l_Count).CREDIT_CLASSIFICATION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'REVIEW_CYCLE: ' || l_BORROWER_TBL(l_Count).REVIEW_CYCLE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LAST_CREDIT_REVIEW_DATE: ' || l_BORROWER_TBL(l_Count).LAST_CREDIT_REVIEW_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CREDIT_RATING: ' || l_BORROWER_TBL(l_Count).CREDIT_RATING);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CREDIT_HOLD: ' || l_BORROWER_TBL(l_Count).CREDIT_HOLD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CREDIT_CHECKING: ' || l_BORROWER_TBL(l_Count).CREDIT_CHECKING);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'TOLERANCE: ' || l_BORROWER_TBL(l_Count).TOLERANCE);

    FOR l_Count IN 1..l_borrower_tbl.COUNT LOOP
        insert into LNS_BORROWER_SUMMARIES(
            BORROWER_PARTY_ID,
            BORROWER_NAME,
            tax_payer_code,
            CUSTOMER_CLASSIFICATION,
            INDUSTRIAL_CLASSIFICATION,
            YEAR_ESTABLISHED,
            COUNTRY,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            ADDRESS4,
            CITY,
            POSTAL_CODE,
            STATE,
            PRIMARY_CONTACT_NAME,
            PRIMARY_PHONE_COUNTRY_CODE,
            PRIMARY_PHONE_AREA_CODE,
            PRIMARY_PHONE_NUMBER,
            PRIMARY_PHONE_EXTENSION,
            ANNUAL_REVENUE,
            CUSTOMER_SINCE,
            NUM_ACTIVE_LOANS,
            TOTAL_REMAINING_PRINCIPAL,
            TOTAL_PRINCIPAL_PAID_YTD,
            TOTAL_INTEREST_PAID_YTD,
            TOTAL_FEE_PAID_YTD,
            TOTAL_REQUESTED_LOAN_AMOUNT,
            TOTAL_APPROVED_LOAN_AMOUNT,
            PLEDGED_COLL_AMOUNT,
            LAST_COLL_VALUATION_DATE,
            CREDIT_CLASSIFICATION,
            REVIEW_CYCLE,
            LAST_CREDIT_REVIEW_DATE,
            CREDIT_RATING,
            CREDIT_HOLD,
            CREDIT_CHECKING,
            TOLERANCE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            ORG_NAME,
            LEGAL_ENTITY_ID,
            LEGAL_ENTITY_NAME,
            FUNCTIONAL_CURRENCY)
         values(
            l_BORROWER_TBL(l_Count).BORROWER_PARTY_ID,
            l_BORROWER_TBL(l_Count).BORROWER_NAME,
            l_BORROWER_TBL(l_Count).tax_payer_code,
            l_BORROWER_TBL(l_Count).CUSTOMER_CLASSIFICATION,
            l_BORROWER_TBL(l_Count).INDUSTRIAL_CLASSIFICATION,
            l_BORROWER_TBL(l_Count).YEAR_ESTABLISHED,
            l_BORROWER_TBL(l_Count).COUNTRY,
            l_BORROWER_TBL(l_Count).ADDRESS1,
            l_BORROWER_TBL(l_Count).ADDRESS2,
            l_BORROWER_TBL(l_Count).ADDRESS3,
            l_BORROWER_TBL(l_Count).ADDRESS4,
            l_BORROWER_TBL(l_Count).CITY,
            l_BORROWER_TBL(l_Count).POSTAL_CODE,
            l_BORROWER_TBL(l_Count).STATE,
            l_BORROWER_TBL(l_Count).PRIMARY_CONTACT_NAME,
            l_BORROWER_TBL(l_Count).PRIMARY_PHONE_COUNTRY_CODE,
            l_BORROWER_TBL(l_Count).PRIMARY_PHONE_AREA_CODE,
            l_BORROWER_TBL(l_Count).PRIMARY_PHONE_NUMBER,
            l_BORROWER_TBL(l_Count).PRIMARY_PHONE_EXTENSION,
            l_BORROWER_TBL(l_Count).ANNUAL_REVENUE,
            l_BORROWER_TBL(l_Count).CUSTOMER_SINCE,
            l_BORROWER_TBL(l_Count).NUM_ACTIVE_LOANS,
            l_BORROWER_TBL(l_Count).TOTAL_REMAINING_PRINCIPAL,
            l_BORROWER_TBL(l_Count).TOTAL_PRINCIPAL_PAID_YTD,
            l_BORROWER_TBL(l_Count).TOTAL_INTEREST_PAID_YTD,
            l_BORROWER_TBL(l_Count).TOTAL_FEE_PAID_YTD,
            l_BORROWER_TBL(l_Count).TOTAL_REQUESTED_LOAN_AMOUNT,
            l_BORROWER_TBL(l_Count).TOTAL_APPROVED_LOAN_AMOUNT,
            l_BORROWER_TBL(l_Count).PLEDGED_COLL_AMOUNT,
            l_BORROWER_TBL(l_Count).LAST_COLL_VALUATION_DATE,
            l_BORROWER_TBL(l_Count).CREDIT_CLASSIFICATION,
            l_BORROWER_TBL(l_Count).REVIEW_CYCLE,
            l_BORROWER_TBL(l_Count).LAST_CREDIT_REVIEW_DATE,
            l_BORROWER_TBL(l_Count).CREDIT_RATING,
            l_BORROWER_TBL(l_Count).CREDIT_HOLD,
            l_BORROWER_TBL(l_Count).CREDIT_CHECKING,
            l_BORROWER_TBL(l_Count).TOLERANCE,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.Conc_Request_Id,
            FND_GLOBAL.PROG_APPL_ID,
            sysdate,
            1,
            l_BORROWER_TBL(l_Count).ORG_ID,
            l_BORROWER_TBL(l_Count).ORG_NAME,
            l_BORROWER_TBL(l_Count).LEGAL_ENTITY_ID,
            l_BORROWER_TBL(l_Count).LEGAL_ENTITY_NAME,
            l_BORROWER_TBL(l_Count).FUNCTIONAL_CURRENCY);

    END LOOP;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Success!');

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited borrower');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully processed borrower');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked borrower');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked borrower');
    WHEN OTHERS THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked borrower');
END;




/*========================================================================
 | PUBLIC PROCEDURE LNS_BORR_SUM_CONCUR
 |
 | DESCRIPTION
 |      This procedure gets called from CM to start borrower summary generation program.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
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
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-14-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_BORR_SUM_CONCUR(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    BORROWER_PARTY_ID   IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	number;

BEGIN

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, '<<--------Generating borrowers summary...-------->>');

    GENERATE_BORROWERS_SUMMARY(
        P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_BORROWER_PARTY_ID => BORROWER_PARTY_ID,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

END;



/*========================================================================
 | PUBLIC PROCEDURE GENERATE_BORROWERS_SUMMARY
 |
 | DESCRIPTION
 |      This procedure generates summary info for all available borrowers
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_BORR_SUM_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |      init
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
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'GENERATE_BORROWERS_SUMMARY';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;
    l_Count1                        number;
    l_party_id                      number;
    l_party_number                  VARCHAR2(30);
    l_party_name                    VARCHAR2(360);

    l_borrowers_tbl                 DBMS_SQL.NUMBER_TABLE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR borrowers_cur(P_BORROWER_ID number) IS
        select
            distinct party.party_id,
            party.PARTY_NUMBER,
            party.party_name
        from
            lns_participants par,
            hz_parties party,
            lns_loan_headers_all head
        where
            party.party_id = nvl(P_BORROWER_ID, party.party_id) and
            party.party_id = par.hz_party_id and
            par.loan_id = head.loan_id and
            par.loan_participant_type in ('PRIMARY_BORROWER', 'COBORROWER');

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT GENERATE_BORR_SUM;
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

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_PARTY_ID: ' || P_BORROWER_PARTY_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Query for all available borrowers...');

    open borrowers_cur(P_BORROWER_PARTY_ID);

    l_Count1 := 0;

    LOOP

        fetch borrowers_cur into
            l_party_id,
            l_party_number,
            l_party_name;

        exit when borrowers_cur%NOTFOUND;

        l_Count1 := l_Count1 + 1;
        l_borrowers_tbl(l_Count1) := l_party_id;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Borrower #' || l_Count1);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARTY_ID: ' || l_borrowers_tbl(l_Count1));
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NUMBER: ' || l_party_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'NAME: ' || l_party_name);

    END LOOP;

    close borrowers_cur;

    l_Count := l_borrowers_tbl.count;
    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total found ' || l_Count || ' borrowers');

    if l_Count > 0 then

        /* bill all selected loans */
        FOR l_Count1 IN 1..l_Count LOOP

            LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing borrower #' || l_Count1);

            GEN_SINGLE_BORROWER_SUMMARY(
            		P_API_VERSION => 1.0,
            		P_INIT_MSG_LIST	=> FND_API.G_FALSE,
            		P_COMMIT => P_COMMIT,
            		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                    P_BORROWER_PARTY_ID => l_borrowers_tbl(l_Count1),
            		X_RETURN_STATUS	=> l_return_status,
            		X_MSG_COUNT => l_msg_count,
            		X_MSG_DATA => l_msg_data);

        END LOOP;

    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total processed ' || l_Count || ' borrowers');

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
        ROLLBACK TO GENERATE_BORR_SUM;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO GENERATE_BORR_SUM;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO GENERATE_BORR_SUM;
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

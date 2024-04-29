--------------------------------------------------------
--  DDL for Package Body LNS_APPL_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_APPL_ENGINE_PUB" as
/* $Header: LNS_APPL_ENG_B.pls 120.2.12010000.5 2010/03/10 16:19:58 scherkas ship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_APPL_ENGINE_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;
    g_org_id                        number;
    g_cr_return_status              varchar2(10);
    g_day_togl_after_dd             number;
    g_last_rc_appl_report           clob;
    g_last_all_appl_stmt            clob;

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
 | 21-10-2005            scherkas          Created
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
 | PRIVATE PROCEDURE init
 |
 | DESCRIPTION
 |      This procedure inits data needed for processing
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
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
 | 21-10-2005            scherkas          Created
 |
 *=======================================================================*/
Procedure init
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'INIT';
    l_org_status                    varchar2(1);

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

    /* getting org_id */
--    g_org_id := to_number(fnd_profile.value('ORG_ID'));
    g_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'g_org_id: ' || g_org_id);
    l_org_status := MO_GLOBAL.check_valid_org(g_org_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'MO_GLOBAL.check_valid_org(' || g_org_id || '): ' || l_org_status);

    /* getting system options */
    select DAYS_TOGL_AFTER_DUE_DATE
    into g_day_togl_after_dd
    FROM LNS_SYSTEM_OPTIONS
    WHERE ORG_ID = g_org_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'System options:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'day_togl_after_dd: ' || g_day_togl_after_dd);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



/*========================================================================
 | PRIVATE PROCEDURE BUILD_RC_APPL_REPORT
 |
 | DESCRIPTION
 |      This procedure builds receipts applications report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_SEARCH_REC            IN          Search record
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
 | 11-02-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE BUILD_RC_APPL_REPORT(
        P_SEARCH_REC            IN          LNS_APPL_ENGINE_PUB.SEARCH_REC)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_RC_APPL_REPORT';
    l_new_line      varchar2(1);
    l_header        varchar2(1000);
    l_footer        varchar2(100);
    l_parameters    varchar2(1000);
    l_borrower      VARCHAR2(360);
    l_loan          VARCHAR2(60);
    l_org_name      VARCHAR2(240);
    l_product       VARCHAR2(80);
    l_unapply_flag  VARCHAR2(80);
    l_receipt       VARCHAR2(30);
    l_receipt_match_criteria VARCHAR2(250);
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query for borrower name */
    CURSOR borrower_cur(P_BORROWER_ID number) IS
    select party_name from hz_parties party where party_id = P_BORROWER_ID;

    /* query for product name */
    CURSOR product_cur(P_PRODUCT_ID number) IS
    select LOAN_PRODUCT_NAME from lns_loan_products_vl where loan_product_id = P_PRODUCT_ID;

    /* query for loan number */
    CURSOR loan_cur(P_LOAN_ID number) IS
    select loan_number from lns_loan_headers where loan_id = P_LOAN_ID;

    /* query for flag meaning */
    CURSOR unapply_flag_cur(P_UNAPPLY_FLAG varchar2) IS
    select meaning from fnd_lookups where lookup_type = 'YES_NO' and lookup_code = P_UNAPPLY_FLAG;

    /* query for flag meaning */
    CURSOR receipt_cur(P_RECEIPT_ID number) IS
    select receipt_number from ar_cash_receipts where cash_receipt_id = P_RECEIPT_ID;

    /* query for flag meaning */
    CURSOR receipt_match_cur(P_RECEIPT_MATCH_CRITERIA varchar2) IS
    select meaning from FND_LOOKUP_VALUES where lookup_type = 'LNS_RECEIPT_MATCH_CRITERIA' and lookup_code = P_RECEIPT_MATCH_CRITERIA;


    /* query for org name */
    CURSOR org_cur(P_ORG_ID number) IS
    select name
    from hr_all_organization_units_tl
    where ORGANIZATION_ID = P_ORG_ID and
    language(+) = userenv('LANG');

    l_fr_date_s varchar2(20);
    l_to_date_s varchar2(20);

    l_fr_date date;
    l_to_date date;

BEGIN

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* init report clob */
    dbms_lob.createtemporary(g_last_rc_appl_report, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_rc_appl_report, dbms_lob.lob_readwrite);

    l_new_line := '
';
    l_header := '<?xml version="1.0" encoding="UTF-8"?>' || l_new_line || '<RCAPPLBATCH>';
    l_footer := l_new_line || '</LOANSET>' || l_new_line || '</RCAPPLBATCH>' || l_new_line;
    l_parameters := l_new_line || '<PARAMETERS>';

    /* adding org name to parameter list */
    open org_cur(g_org_id);
    fetch org_cur into l_org_name;
    close org_cur;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_org_name: ' || l_org_name);
    l_parameters := l_parameters || l_new_line || '<ORG_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_org_name) || '</ORG_NAME>';

    /* adding borrower to parameter list */
    if P_SEARCH_REC.LOAN_BORROWER_ID is not null then
        open borrower_cur(P_SEARCH_REC.LOAN_BORROWER_ID);
        fetch borrower_cur into l_borrower;
        close borrower_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_borrower: ' || l_borrower);
    l_parameters := l_parameters || l_new_line || '<BORROWER_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_borrower) || '</BORROWER_NAME>';

    /* adding loan product to parameter list */
    if P_SEARCH_REC.LOAN_PRODUCT_ID is not null then
        open product_cur(P_SEARCH_REC.LOAN_PRODUCT_ID);
        fetch product_cur into l_product;
        close product_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_product: ' || l_product);
    l_parameters := l_parameters || l_new_line || '<PRODUCT_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_product) || '</PRODUCT_NAME>';

    /* adding loan to parameter list */
    if P_SEARCH_REC.LOAN_ID is not null then
        open loan_cur(P_SEARCH_REC.LOAN_ID);
        fetch loan_cur into l_loan;
        close loan_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan: ' || l_loan);
    l_parameters := l_parameters || l_new_line || '<LOAN_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_loan) || '</LOAN_NUMBER>';

    /* adding receipt to parameter list */
    if P_SEARCH_REC.RECEIPT_ID is not null then
        open receipt_cur(P_SEARCH_REC.RECEIPT_ID);
        fetch receipt_cur into l_receipt;
        close receipt_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_receipt: ' || l_receipt);
    l_parameters := l_parameters || l_new_line || '<RECEIPT_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_receipt) || '</RECEIPT_NUMBER>';

    /* adding receipt match criteria to parameter list */
    if P_SEARCH_REC.RECEIPT_MATCH_CRITERIA is not null then
        open receipt_match_cur(P_SEARCH_REC.RECEIPT_MATCH_CRITERIA);
        fetch receipt_match_cur into l_receipt_match_criteria;
        close receipt_match_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_receipt_match_criteria: ' || l_receipt_match_criteria);
    l_parameters := l_parameters || l_new_line || '<RECEIPT_MATCH_CRITERIA>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(l_receipt_match_criteria) || '</RECEIPT_MATCH_CRITERIA>';

    --Converting the date format from YYYY/MM/DD to DD-MON-YYYY format in the report
    l_fr_date :=  to_date(substr(P_SEARCH_REC.RC_FROM_DATE, 1, 10), 'YYYY/MM/DD');
    l_to_date :=  to_date(substr(P_SEARCH_REC.RC_TO_DATE, 1, 10), 'YYYY/MM/DD');
    l_fr_date_s := to_char(l_fr_date, 'DD-MON-YYYY');
    l_to_date_s := to_char(l_to_date, 'DD-MON-YYYY');


    /* adding from receipt date to parameter list */
    l_parameters := l_parameters || l_new_line || '<RC_FROM_DATE>' || l_fr_date_s || '</RC_FROM_DATE>';

    /* adding to receipt date to parameter list */
    l_parameters := l_parameters || l_new_line || '<RC_TO_DATE>' || l_to_date_s || '</RC_TO_DATE>';

    /* adding unapply flag to parameter list */
    if P_SEARCH_REC.UNAPPLY_FLAG is not null then
        open unapply_flag_cur(P_SEARCH_REC.UNAPPLY_FLAG);
        fetch unapply_flag_cur into l_unapply_flag;
        close unapply_flag_cur;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_unapply_flag: ' || l_unapply_flag);
--    Not required to show Unapply flag, as we are not using this flag
--    l_parameters := l_parameters || l_new_line || '<UNAPPLY_FLAG>' || l_unapply_flag || '</UNAPPLY_FLAG>';

    l_parameters := l_parameters || l_new_line || '</PARAMETERS>' || l_new_line || '<LOANSET>' || l_new_line;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_parameters: ' || l_parameters);

    /* add header to report */
    DBMS_LOB.write(g_last_rc_appl_report, length(l_header), 1, l_header);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added header to report');

    /* add parameters to report */
    dbms_lob.writeAppend(g_last_rc_appl_report, length(l_parameters), l_parameters);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added parameters to report');

    /* add all statements to report */
    if dbms_lob.getlength(g_last_all_appl_stmt) > 0 then
        DBMS_LOB.Append(g_last_rc_appl_report, g_last_all_appl_stmt);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added statements to report');
    end if;

    /* add footer to report */
    dbms_lob.writeAppend(g_last_rc_appl_report, length(l_footer), l_footer);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added footer to report');

    /* print report to output file */
    LNS_REP_UTILS.PRINT_CLOB(g_last_rc_appl_report);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Saved output file');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate receipts application report');
END;



/*========================================================================
 | PRIVATE PROCEDURE ADD_LOAN_TAG
 |
 | DESCRIPTION
 |      This procedure adds loan info to statement.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_LOAN_REC              IN      Loan record
 |       P_OPEN_CLOSE_FLAG       IN      Open or close flag
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
 | 11-02-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE ADD_LOAN_TAG(
        P_LOAN_REC              IN      LNS_APPL_ENGINE_PUB.LOAN_REC,
        P_OPEN_CLOSE_FLAG       IN      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'ADD_LOAN_TAG';
    l_new_line                      varchar2(1);
    l_data                          varchar2(1000);
    l_statement_xml                 clob;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* init statement clob */
    dbms_lob.createtemporary(l_statement_xml, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(l_statement_xml, dbms_lob.lob_readwrite);

    l_new_line := '
';
    if P_OPEN_CLOSE_FLAG = 'OPEN' then
        l_data := l_new_line || '<LOAN num="' || P_LOAN_REC.SEQUENCE_NUMBER || '">' ||
                  l_new_line || '<LOAN_ID>' || P_LOAN_REC.LOAN_ID || '</LOAN_ID>' ||
                  l_new_line || '<LOAN_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_REC.LOAN_NUMBER) || '</LOAN_NUMBER>' ||
                  l_new_line || '<LOAN_BORROWER_ID>' || P_LOAN_REC.LOAN_BORROWER_ID || '</LOAN_BORROWER_ID>' ||
                  l_new_line || '<BORROWER_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_REC.BORROWER_NAME) || '</BORROWER_NAME>' ||
                  l_new_line || '<LOAN_PRODUCT_ID>' || P_LOAN_REC.LOAN_PRODUCT_ID || '</LOAN_PRODUCT_ID>' ||
                  l_new_line || '<PRODUCT_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_REC.PRODUCT_NAME) || '</PRODUCT_NAME>' ||
                  l_new_line || '<LOAN_CURRENCY>' || P_LOAN_REC.LOAN_CURRENCY || '</LOAN_CURRENCY>';
    elsif P_OPEN_CLOSE_FLAG = 'CLOSE' then
        l_data := l_new_line || '</LOAN>';
    end if;

    /* add header to stmt */
    DBMS_LOB.write(l_statement_xml, length(l_data), 1, l_data);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added loan to stmt');

    /* add statements to all statement */
    if dbms_lob.getlength(l_statement_xml) > 0 then
        DBMS_LOB.Append(g_last_all_appl_stmt, l_statement_xml);
	LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added stmt to all statement');
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to add loan to all statement');
        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PRIVATE PROCEDURE ADD_APPL_UNAPPL_TAGS
 |
 | DESCRIPTION
 |      This procedure adds apply unapply group tags.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_ACTION                IN      Action
 |       P_OPEN_CLOSE_FLAG       IN      Open or close flag
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
 | 11-02-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE ADD_APPL_UNAPPL_TAGS(
        P_ACTION_FLAG           IN      VARCHAR2,
        P_OPEN_CLOSE_FLAG       IN      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'ADD_APPL_UNAPPL_TAGS';
    l_new_line                      varchar2(1);
    l_data                          varchar2(1000);
    l_statement_xml                 clob;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* init statement clob */
    dbms_lob.createtemporary(l_statement_xml, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(l_statement_xml, dbms_lob.lob_readwrite);

    l_new_line := '
';
    if P_ACTION_FLAG = 'APPLY' then
        if P_OPEN_CLOSE_FLAG = 'OPEN' then
            l_data := l_new_line || '<APPLICATIONS>';
        elsif P_OPEN_CLOSE_FLAG = 'CLOSE' then
            l_data := l_new_line || '</APPLICATIONS>';
        end if;
    elsif P_ACTION_FLAG = 'UNAPPLY' then
        if P_OPEN_CLOSE_FLAG = 'OPEN' then
            l_data := l_new_line || '<UNAPPLICATIONS>';
        elsif P_OPEN_CLOSE_FLAG = 'CLOSE' then
            l_data := l_new_line || '</UNAPPLICATIONS>';
        end if;
    end if;

    /* add header to stmt */
    DBMS_LOB.write(l_statement_xml, length(l_data), 1, l_data);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added stmt');

    /* add statements to all statement */
    if dbms_lob.getlength(l_statement_xml) > 0 then
        DBMS_LOB.Append(g_last_all_appl_stmt, l_statement_xml);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added stmt to all statement');
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to add apply/unapply group tags loan to all statement');
        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PRIVATE PROCEDURE BUILD_STMT
 |
 | DESCRIPTION
 |      This procedure builds single apply/unapply statement and add this to final all statement.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |       P_LOAN_INVOICES_REC         IN      Invoice record
 |       P_RECEIPT_REC               IN      Receipt record
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
 | 11-02-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE BUILD_STMT(
        P_LOAN_INVOICES_REC         IN      LNS_APPL_ENGINE_PUB.LOAN_INVOICE_REC,
        P_RECEIPT_REC               IN      LNS_APPL_ENGINE_PUB.RECEIPT_REC,
        P_SEQUENCE_NUMBER           IN      NUMBER,
        P_INV_APPLY_AMOUNT          IN      NUMBER,
        P_RC_APPLY_AMOUNT           IN      NUMBER,
        P_ERROR                     IN      VARCHAR2,
        P_ACTION                    IN      VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'BUILD_STMT';
    l_new_line                      varchar2(1);
    l_header                        varchar2(1000);
    l_footer                        varchar2(100);
    l_statement_xml                 clob;
    l_application                   varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* init statement clob */
    dbms_lob.createtemporary(l_statement_xml, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(l_statement_xml, dbms_lob.lob_readwrite);

    l_new_line := '
';
    if P_ACTION = 'APPLY' then
        l_header := l_new_line || '<APPLICATION num="' || P_SEQUENCE_NUMBER || '">';
        l_footer := l_new_line || '</APPLICATION>' || l_new_line;
    elsif P_ACTION = 'UNAPPLY' then
        l_header := l_new_line || '<UNAPPLICATION num="' || P_SEQUENCE_NUMBER || '">';
        l_footer := l_new_line || '</UNAPPLICATION>' || l_new_line;
    end if;
--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Step1');

    l_application := l_application || l_new_line || '<LOAN_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.LOAN_NUMBER) ||'</LOAN_NUMBER>' ||
                                     l_new_line || '<PHASE>' || P_LOAN_INVOICES_REC.PHASE ||'</PHASE>' ||
                                     l_new_line || '<PAYMENT_NUMBER>' || P_LOAN_INVOICES_REC.PAYMENT_NUMBER ||'</PAYMENT_NUMBER>' ||
                                     l_new_line || '<INVOICE_TYPE_CODE>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.INVOICE_TYPE_CODE) ||'</INVOICE_TYPE_CODE>' ||
                                     l_new_line || '<INVOICE_TYPE_DESC>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.INVOICE_TYPE_DESC) ||'</INVOICE_TYPE_DESC>' ||
                                     l_new_line || '<CUST_TRX_ID>' || P_LOAN_INVOICES_REC.CUST_TRX_ID || '</CUST_TRX_ID>' ||
                                     l_new_line || '<PAYMENT_SCHEDULE_ID>' || P_LOAN_INVOICES_REC.PAYMENT_SCHEDULE_ID || '</PAYMENT_SCHEDULE_ID>' ||
                                     l_new_line || '<TRX_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.TRX_NUMBER) || '</TRX_NUMBER>' ||
                                     l_new_line || '<LOAN_BORROWER_ID>' || P_LOAN_INVOICES_REC.LOAN_BORROWER_ID ||'</LOAN_BORROWER_ID>' ||
                                     l_new_line || '<BORROWER_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.BORROWER_NAME) ||'</BORROWER_NAME>' ||
                                     l_new_line || '<LOAN_PRODUCT_ID>' || P_LOAN_INVOICES_REC.LOAN_PRODUCT_ID ||'</LOAN_PRODUCT_ID>' ||
                                     l_new_line || '<PRODUCT_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_LOAN_INVOICES_REC.PRODUCT_NAME) ||'</PRODUCT_NAME>' ||
                                     l_new_line || '<LOAN_ID>' || P_LOAN_INVOICES_REC.LOAN_ID ||'</LOAN_ID>' ||
                                     l_new_line || '<AMORTIZATION_ID>' || P_LOAN_INVOICES_REC.AMORTIZATION_ID ||'</AMORTIZATION_ID>' ||
                                     l_new_line || '<DUE_DATE>' || fnd_date.date_to_chardate(P_LOAN_INVOICES_REC.DUE_DATE) ||'</DUE_DATE>' ||
                                     l_new_line || '<BILL_DATE>' || fnd_date.date_to_chardate(P_LOAN_INVOICES_REC.BILL_DATE) ||'</BILL_DATE>' ||
                                     l_new_line || '<INVOICE_CURRENCY>' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY ||'</INVOICE_CURRENCY>' ||
                                     l_new_line || '<EXCHANGE_RATE>' || P_LOAN_INVOICES_REC.EXCHANGE_RATE ||'</EXCHANGE_RATE>' ||
                                     l_new_line || '<RECEIPT_ID>' || P_RECEIPT_REC.RECEIPT_ID ||'</RECEIPT_ID>' ||
                                     l_new_line || '<RECEIPT_NUMBER>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_RECEIPT_REC.RECEIPT_NUMBER) ||'</RECEIPT_NUMBER>' ||
                                     l_new_line || '<RECEIPT_DATE>' || fnd_date.date_to_chardate(P_RECEIPT_REC.RECEIPT_DATE) ||'</RECEIPT_DATE>' ||
                                     l_new_line || '<PARTY_NAME>' || LNS_REP_UTILS.REPLACE_SPECIAL_CHARS(P_RECEIPT_REC.PARTY_NAME) ||'</PARTY_NAME>' ||
                                     l_new_line || '<RECEIPT_CURRENCY>' || P_RECEIPT_REC.RECEIPT_CURRENCY || '</RECEIPT_CURRENCY>';

--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Step2');
    if P_ACTION = 'APPLY' then
        l_application := l_application || l_new_line || '<INV_APPLY_AMOUNT>' || to_char(P_INV_APPLY_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</INV_APPLY_AMOUNT>' ||
                                          l_new_line || '<RC_APPLY_AMOUNT>' || to_char(P_RC_APPLY_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</RC_APPLY_AMOUNT>' ||
                                          l_new_line || '<BEGIN_INV_BALANCE>' || to_char(P_LOAN_INVOICES_REC.REMAINING_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</BEGIN_INV_BALANCE>' ||
                                          l_new_line || '<END_INV_BALANCE>' || to_char((P_LOAN_INVOICES_REC.REMAINING_AMOUNT - P_INV_APPLY_AMOUNT), FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</END_INV_BALANCE>' ||
                                          l_new_line || '<BEGIN_RC_BALANCE>' || to_char(P_RECEIPT_REC.REMAINING_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</BEGIN_RC_BALANCE>' ||
                                          l_new_line || '<END_RC_BALANCE>' || to_char((P_RECEIPT_REC.REMAINING_AMOUNT - P_RC_APPLY_AMOUNT), FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</END_RC_BALANCE>';

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Application #' || P_SEQUENCE_NUMBER);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt: ' || P_RECEIPT_REC.RECEIPT_NUMBER || '(id ' || P_RECEIPT_REC.RECEIPT_ID || ')');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt date: ' || P_RECEIPT_REC.RECEIPT_DATE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt balance before application: ' || P_RECEIPT_REC.REMAINING_AMOUNT || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt balance after application: ' || (P_RECEIPT_REC.REMAINING_AMOUNT - P_RC_APPLY_AMOUNT) || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice ' || P_LOAN_INVOICES_REC.TRX_NUMBER || '(id ' || P_LOAN_INVOICES_REC.CUST_TRX_ID || ')');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Installment # ' || P_LOAN_INVOICES_REC.PAYMENT_NUMBER || ' ' || P_LOAN_INVOICES_REC.INVOICE_TYPE_DESC);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Phase: ' || P_LOAN_INVOICES_REC.PHASE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Due date: ' || P_LOAN_INVOICES_REC.DUE_DATE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice balance before application: ' || P_LOAN_INVOICES_REC.REMAINING_AMOUNT || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice balance after application: ' || (P_LOAN_INVOICES_REC.REMAINING_AMOUNT - P_INV_APPLY_AMOUNT) || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Applied amount in invoice currency: ' || P_INV_APPLY_AMOUNT || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Applied amount in receipt currency: ' || P_RC_APPLY_AMOUNT || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);

    elsif P_ACTION = 'UNAPPLY' then
        l_application := l_application || l_new_line || '<INV_UNAPPLY_AMOUNT>' || to_char(P_INV_APPLY_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</INV_UNAPPLY_AMOUNT>' ||
                                          l_new_line || '<RC_UNAPPLY_AMOUNT>' || to_char(P_RC_APPLY_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</RC_UNAPPLY_AMOUNT>' ||
                                          l_new_line || '<BEGIN_INV_BALANCE>' || to_char(P_LOAN_INVOICES_REC.REMAINING_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</BEGIN_INV_BALANCE>' ||
                                          l_new_line || '<END_INV_BALANCE>' || to_char((P_LOAN_INVOICES_REC.REMAINING_AMOUNT + P_INV_APPLY_AMOUNT), FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_LOAN_INVOICES_REC.INVOICE_CURRENCY,50)) || '</END_INV_BALANCE>' ||
                                          l_new_line || '<BEGIN_RC_BALANCE>' || to_char(P_RECEIPT_REC.REMAINING_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</BEGIN_RC_BALANCE>' ||
                                          l_new_line || '<END_RC_BALANCE>' || to_char((P_RECEIPT_REC.REMAINING_AMOUNT + P_RC_APPLY_AMOUNT), FND_CURRENCY.SAFE_GET_FORMAT_MASK(P_RECEIPT_REC.RECEIPT_CURRENCY,50)) || '</END_RC_BALANCE>';

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Unapplication #' || P_SEQUENCE_NUMBER);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt: ' || P_RECEIPT_REC.RECEIPT_NUMBER || '(id ' || P_RECEIPT_REC.RECEIPT_ID || ')');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt date: ' || P_RECEIPT_REC.RECEIPT_DATE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt balance before application: ' || P_RECEIPT_REC.REMAINING_AMOUNT || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt balance after application: ' || (P_RECEIPT_REC.REMAINING_AMOUNT + P_RC_APPLY_AMOUNT) || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice ' || P_LOAN_INVOICES_REC.TRX_NUMBER || '(id ' || P_LOAN_INVOICES_REC.CUST_TRX_ID || ')');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Installment # ' || P_LOAN_INVOICES_REC.PAYMENT_NUMBER || ' ' || P_LOAN_INVOICES_REC.INVOICE_TYPE_DESC);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Phase: ' || P_LOAN_INVOICES_REC.PHASE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Due date: ' || P_LOAN_INVOICES_REC.DUE_DATE);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice balance before application: ' || P_LOAN_INVOICES_REC.REMAINING_AMOUNT || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Invoice balance after application: ' || (P_LOAN_INVOICES_REC.REMAINING_AMOUNT + P_INV_APPLY_AMOUNT) || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Applied amount in invoice currency: ' || P_INV_APPLY_AMOUNT || ' ' || P_LOAN_INVOICES_REC.INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Applied amount in receipt currency: ' || P_RC_APPLY_AMOUNT || ' ' || P_RECEIPT_REC.RECEIPT_CURRENCY);

    end if;

--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Step3');
    l_application := l_application || l_new_line || '<ERROR>' || P_ERROR ||'</ERROR>';
--    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Step4');

    /* add header to stmt */
    DBMS_LOB.write(l_statement_xml, length(l_header), 1, l_header);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added header to stmt');

    /* add data to stmt */
    dbms_lob.writeAppend(l_statement_xml, length(l_application), l_application);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added data to stmt');

    /* add footer to stmt */
    dbms_lob.writeAppend(l_statement_xml, length(l_footer), l_footer);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added footer to stmt');

    /* add statements to all statement */
    if dbms_lob.getlength(l_statement_xml) > 0 then
        DBMS_LOB.Append(g_last_all_appl_stmt, l_statement_xml);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Added statement to all statement');
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to generate application statement');
        RAISE FND_API.G_EXC_ERROR;
END;




/*========================================================================
 | PRIVATE PROCEDURE UNAPPLY_RECEIPTS
 |
 | DESCRIPTION
 |      This procedure unapplies incorrect applications from loan invoices
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_RECEIPTS_TBL              OUT NOCOPY  Receipts table
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UNAPPLY_RECEIPTS(
    P_LOAN_INVOICES_TBL         IN      LNS_APPL_ENGINE_PUB.LOAN_INVOICES_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'UNAPPLY_RECEIPTS';
    l_Count                         NUMBER;
    l_next_inv_appl_ok              varchar2(1);
    l_Count1                        number;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_amount_applied                number;
    l_amount_applied_from           number;
    l_receivable_application_id     number;
    l_application                   number;
    l_inv_count                     number;
    l_error                         varchar2(32767);

    l_RECEIPT_REC                   LNS_APPL_ENGINE_PUB.RECEIPT_REC;
    l_RECEIPTS_TBL                  LNS_APPL_ENGINE_PUB.RECEIPTS_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- search for receipts to unapply
    CURSOR receipts_cur(P_PAYMENT_SCHEDULE_ID number) IS
        select
            ra.RECEIVABLE_APPLICATION_ID,
            ps.CASH_RECEIPT_ID,
            ps.trx_number,
            ps.trx_date,
            abs(ps.amount_due_remaining),
            ps.invoice_currency_code,
            party.party_name,
            ra.AMOUNT_APPLIED,
            nvl(ra.amount_applied_from, ra.AMOUNT_APPLIED)
        from ar_receivable_applications ra,
            ar_payment_schedules ps,
            hz_cust_accounts cust,
            hz_parties party
        where
            ra.APPLIED_PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID and
            ra.application_type = 'CASH' and
            ra.display = 'Y' and
            ra.cash_receipt_id = ps.cash_receipt_id and
            ps.class = 'PMT' and
            ps.customer_id = cust.cust_account_id and
            cust.status = 'A' and
            cust.party_id = party.party_id
        order by ra.APPLY_DATE desc;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Unapplying receipts...');

    l_Count1 := 0;
    l_next_inv_appl_ok := 'Y';
    l_application := 0;
    l_inv_count := 0;

    LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
            P_ACTION_FLAG           => 'UNAPPLY',
            P_OPEN_CLOSE_FLAG       => 'OPEN');

    -- looping thru invoices and apply receipts
    FOR l_Count IN 1..P_LOAN_INVOICES_TBL.count LOOP

        if l_next_inv_appl_ok = 'Y' then
            if P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT = 0 then
                l_next_inv_appl_ok := 'Y';
            else
                l_next_inv_appl_ok := 'N';
            end if;
        else

            open receipts_cur(P_LOAN_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
            LOOP

                fetch receipts_cur into l_receivable_application_id,
                                        l_RECEIPT_REC.RECEIPT_ID,
                                        l_RECEIPT_REC.RECEIPT_NUMBER,
                                        l_RECEIPT_REC.RECEIPT_DATE,
                                        l_RECEIPT_REC.REMAINING_AMOUNT,
                                        l_RECEIPT_REC.RECEIPT_CURRENCY,
                                        l_RECEIPT_REC.PARTY_NAME,
                                        l_amount_applied,
                                        l_amount_applied_from;

                exit when receipts_cur%NOTFOUND;

                l_Count1 := l_Count1+1;

                LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice to unapply #' || l_Count1);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || P_LOAN_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || P_LOAN_INVOICES_TBL(l_Count).CUST_TRX_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).TRX_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_BORROWER_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_BORROWER_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_NAME: ' || P_LOAN_INVOICES_TBL(l_Count).BORROWER_NAME);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PRODUCT_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_PRODUCT_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRODUCT_NAME: ' || P_LOAN_INVOICES_TBL(l_Count).PRODUCT_NAME);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_ID: ' || P_LOAN_INVOICES_TBL(l_Count).AMORTIZATION_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).PAYMENT_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || P_LOAN_INVOICES_TBL(l_Count).DUE_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_DATE: ' || P_LOAN_INVOICES_TBL(l_Count).BILL_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || P_LOAN_INVOICES_TBL(l_Count).PHASE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_CODE: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_TYPE_CODE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_DESC: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_TYPE_DESC);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_CURRENCY);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE);

                LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Receipt to unapply #' || l_Count1);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_ID: ' || l_RECEIPT_REC.RECEIPT_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_NUMBER: ' || l_RECEIPT_REC.RECEIPT_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_DATE: ' || l_RECEIPT_REC.RECEIPT_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || l_RECEIPT_REC.REMAINING_AMOUNT);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_CURRENCY: ' || l_RECEIPT_REC.RECEIPT_CURRENCY);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARTY_NAME: ' || l_RECEIPT_REC.PARTY_NAME);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_receivable_application_id: ' || l_receivable_application_id);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_amount_applied: ' || l_amount_applied);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_amount_applied_from: ' || l_amount_applied_from);

                l_application := l_application + 1;

                BEGIN

                    l_error := null;
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling ar_receipt_api_pub.unapply...');
                    ar_receipt_api_pub.unapply(
                                p_api_version               => 1.0,
                                p_init_msg_list             => FND_API.G_TRUE,
                                p_commit                    => FND_API.G_FALSE,
                                p_receivable_application_id => l_receivable_application_id,
                                x_return_status             => l_return_status,
                                x_msg_count                 => l_msg_count,
                                x_msg_data                  => l_msg_data);

                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_error := FND_MSG_PUB.Get(p_encoded => 'F');
                    end if;

                EXCEPTION
                    WHEN OTHERS THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;
                        l_error := SQLERRM;
                END;

                LNS_APPL_ENGINE_PUB.BUILD_STMT(
                        P_LOAN_INVOICES_REC         => P_LOAN_INVOICES_TBL(l_Count),
                        P_RECEIPT_REC               => l_RECEIPT_REC,
                        P_SEQUENCE_NUMBER           => l_application,
                        P_INV_APPLY_AMOUNT          => l_amount_applied,
                        P_RC_APPLY_AMOUNT           => l_amount_applied_from,
                        P_ERROR                     => l_error,
                        P_ACTION                    => 'UNAPPLY');

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ar_receipt_api_pub.unapply failed');
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reported error: ' || l_error);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_inv_count := l_inv_count + 1;
                l_next_inv_appl_ok := 'N';

            END LOOP;
            close receipts_cur;

        end if;

    END LOOP;

    LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
            P_ACTION_FLAG           => 'UNAPPLY',
            P_OPEN_CLOSE_FLAG       => 'CLOSE');

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully unapplied ' || l_Count1 || ' receipts from ' || l_inv_count || ' invoices for loan ' || P_LOAN_INVOICES_TBL(l_inv_count).LOAN_NUMBER);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In ' || l_api_name || ' exception handling');

        LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
                P_ACTION_FLAG           => 'UNAPPLY',
                P_OPEN_CLOSE_FLAG       => 'CLOSE');

        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PRIVATE PROCEDURE APPLY_RECEIPTS
 |
 | DESCRIPTION
 |      This procedure applies receipts to loan invoices
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_RECEIPTS_TBL              OUT NOCOPY  Receipts table
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPLY_RECEIPTS(
    P_LOAN_INVOICES_TBL         IN OUT NOCOPY LNS_APPL_ENGINE_PUB.LOAN_INVOICES_TBL,
    P_RECEIPTS_TBL              IN OUT NOCOPY LNS_APPL_ENGINE_PUB.RECEIPTS_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPLY_RECEIPTS';
    l_Count                         number;
    l_Count1                        number;
    l_receipt                       number;
    l_exit_loop                     varchar2(1);
    l_quit                          varchar2(1);
    l_apply_amount                  number;
    l_application                   number;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_trans_to_receipt_rate         number;
    l_receipt_amount_from           number;  -- in receipt currency
    l_rc_precision                  number;
    l_rc_ext_precision              number;
    l_rc_min_acct_unit              number;
    l_inv_precision                 number;
    l_inv_ext_precision             number;
    l_inv_min_acct_unit             number;
    l_apply_date                    date;
    l_inv_am_in_funct_cur           number;
    l_inv_count                     number;
    l_rc_count                      number;
    l_error                         varchar2(32767);


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Applying receipts...');

    LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
            P_ACTION_FLAG           => 'APPLY',
            P_OPEN_CLOSE_FLAG       => 'OPEN');

    l_receipt := 1;
    l_quit := 'N';
    l_application := 0;
    l_inv_count := 0;
    l_rc_count := 0;
    -- looping thru invoices and apply receipts
    FOR l_Count IN 1..P_LOAN_INVOICES_TBL.count LOOP

        l_inv_count := l_inv_count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || P_LOAN_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || P_LOAN_INVOICES_TBL(l_Count).CUST_TRX_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).TRX_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_BORROWER_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_BORROWER_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_NAME: ' || P_LOAN_INVOICES_TBL(l_Count).BORROWER_NAME);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PRODUCT_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_PRODUCT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRODUCT_NAME: ' || P_LOAN_INVOICES_TBL(l_Count).PRODUCT_NAME);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).LOAN_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_ID: ' || P_LOAN_INVOICES_TBL(l_Count).AMORTIZATION_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || P_LOAN_INVOICES_TBL(l_Count).PAYMENT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || P_LOAN_INVOICES_TBL(l_Count).DUE_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_DATE: ' || P_LOAN_INVOICES_TBL(l_Count).BILL_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || P_LOAN_INVOICES_TBL(l_Count).PHASE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_CODE: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_TYPE_CODE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_DESC: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_TYPE_DESC);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || P_LOAN_INVOICES_TBL(l_Count).INVOICE_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE);

        FOR l_Count1 IN l_receipt..P_RECEIPTS_TBL.count LOOP

            l_rc_count := l_receipt;
            LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Receipt #' || l_Count1);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_ID: ' || P_RECEIPTS_TBL(l_Count1).RECEIPT_ID);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_NUMBER: ' || P_RECEIPTS_TBL(l_Count1).RECEIPT_NUMBER);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_DATE: ' || P_RECEIPTS_TBL(l_Count1).RECEIPT_DATE);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_CURRENCY: ' || P_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARTY_NAME: ' || P_RECEIPTS_TBL(l_Count1).PARTY_NAME);

            BEGIN

                -- calculate amounts using curencies
                if P_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY = P_LOAN_INVOICES_TBL(l_Count).INVOICE_CURRENCY then

                    if P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT > P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT then

                        l_apply_amount := P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT;
                        l_exit_loop := 'N';

                    elsif P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT < P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT then

                        l_apply_amount := P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_exit_loop := 'Y';

                    else

                        l_apply_amount := P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_exit_loop := 'Y';

                    end if;

                    l_receipt_amount_from := null;
                    l_trans_to_receipt_rate := null;

                else    -- if trx currency <> receipt currency then receipt in functional currency

                    -- get rc/functional currency precision
                    fnd_currency.GET_INFO(CURRENCY_CODE => P_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY,
                                        PRECISION => l_rc_precision,
                                        EXT_PRECISION => l_rc_ext_precision,
                                        MIN_ACCT_UNIT => l_rc_min_acct_unit);

                    -- get invoice currency precision
                    fnd_currency.GET_INFO(CURRENCY_CODE => P_LOAN_INVOICES_TBL(l_Count).INVOICE_CURRENCY,
                                        PRECISION => l_inv_precision,
                                        EXT_PRECISION => l_inv_ext_precision,
                                        MIN_ACCT_UNIT => l_inv_min_acct_unit);


                    l_inv_am_in_funct_cur := round(P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT * P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE, l_rc_precision);

                    if l_inv_am_in_funct_cur > P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT then

                        l_receipt_amount_from := P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT;
                        l_apply_amount := round(l_receipt_amount_from / P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE, l_inv_precision);
                        l_exit_loop := 'N';

                    elsif l_inv_am_in_funct_cur < P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT then

                        l_apply_amount := P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_receipt_amount_from := round(l_apply_amount * P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE, l_rc_precision);
                        l_exit_loop := 'Y';

                    else

                        l_apply_amount := P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT;
                        l_receipt_amount_from := P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT;
                        l_exit_loop := 'Y';

                    end if;

                    l_trans_to_receipt_rate := P_LOAN_INVOICES_TBL(l_Count).EXCHANGE_RATE;

                end if;
/*
                if trunc(sysdate) > trunc(P_RECEIPTS_TBL(l_Count1).RECEIPT_DATE) and
                   trunc(sysdate) > trunc(P_LOAN_INVOICES_TBL(l_Count).DUE_DATE) then
                    l_apply_date := sysdate;
                elsif trunc(P_LOAN_INVOICES_TBL(l_Count).DUE_DATE) > trunc(P_RECEIPTS_TBL(l_Count1).RECEIPT_DATE) then
*/
                if trunc(P_LOAN_INVOICES_TBL(l_Count).DUE_DATE) > trunc(P_RECEIPTS_TBL(l_Count1).RECEIPT_DATE) then
                    l_apply_date := P_LOAN_INVOICES_TBL(l_Count).DUE_DATE;
                else
                    l_apply_date := P_RECEIPTS_TBL(l_Count1).RECEIPT_DATE;
                end if;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling AR_RECEIPT_API_PUB.APPLY with following parameters:');
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_cash_receipt_id: ' || P_RECEIPTS_TBL(l_Count1).RECEIPT_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_applied_payment_schedule_id: ' || P_LOAN_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_apply_date: ' || l_apply_date);
                --LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_apply_gl_date: ' || (l_apply_date + nvl(g_day_togl_after_dd, 0)));
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_amount_applied: ' || l_apply_amount);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'p_amount_applied_from: ' || l_receipt_amount_from);
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
                                            ,p_cash_receipt_id             => P_RECEIPTS_TBL(l_Count1).RECEIPT_ID
                                            ,p_applied_payment_schedule_id => P_LOAN_INVOICES_TBL(l_Count).PAYMENT_SCHEDULE_ID
                                            ,p_apply_date                  => l_apply_date
                                            ,p_apply_gl_date               => null --l_apply_date + nvl(g_day_togl_after_dd, 0)
                                            ,p_amount_applied              => l_apply_amount
                                            ,p_amount_applied_from         => l_receipt_amount_from
                                            ,p_trans_to_receipt_rate       => l_trans_to_receipt_rate);

                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_msg_data: ' || l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --l_error := FND_MSG_PUB.Get(p_encoded => 'F');
			l_error := l_msg_data;
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;
                        l_error := SQLERRM;
                END;

                if P_RECEIPTS_TBL(l_Count1).RECEIPT_CURRENCY = P_LOAN_INVOICES_TBL(l_Count).INVOICE_CURRENCY then
                    l_receipt_amount_from := l_apply_amount;
                end if;

                l_application := l_application + 1;
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_application #' || l_application);
                LNS_APPL_ENGINE_PUB.BUILD_STMT(
                        P_LOAN_INVOICES_REC         => P_LOAN_INVOICES_TBL(l_Count),
                        P_RECEIPT_REC               => P_RECEIPTS_TBL(l_Count1),
                        P_SEQUENCE_NUMBER           => l_application,
                        P_INV_APPLY_AMOUNT          => l_apply_amount,
                        P_RC_APPLY_AMOUNT           => l_receipt_amount_from,
                        P_ERROR                     => l_error,
                        P_ACTION                    => 'APPLY');

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'AR_RECEIPT_API_PUB.APPLY failed');
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Reported error: ' || l_error);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT := P_LOAN_INVOICES_TBL(l_Count).REMAINING_AMOUNT - l_apply_amount;
                P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT := P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT - l_receipt_amount_from;

                if  P_RECEIPTS_TBL(l_Count1).REMAINING_AMOUNT = 0 then

                    if l_receipt = P_RECEIPTS_TBL.count then
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
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count || ' has been fully paid - exiting receipts loop');
                    exit;
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


    LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
            P_ACTION_FLAG           => 'APPLY',
                P_OPEN_CLOSE_FLAG       => 'CLOSE');

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully applied ' || l_rc_count || ' receipts to ' || l_inv_count || ' invoices for loan ' || P_LOAN_INVOICES_TBL(l_inv_count).LOAN_NUMBER);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In ' || l_api_name || ' exception handling');

        LNS_APPL_ENGINE_PUB.ADD_APPL_UNAPPL_TAGS(
                P_ACTION_FLAG           => 'APPLY',
                P_OPEN_CLOSE_FLAG       => 'CLOSE');

        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PUBLIC PROCEDURE SEARCH_RECEIPTS
 |
 | DESCRIPTION
 |      This procedure searches for receipts using passed search criteria record
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_SEARCH_RECEIPTS_REC       IN          Search record
 |      X_RECEIPTS_TBL              OUT NOCOPY  Receipts table
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_RECEIPTS(
    P_SEARCH_RECEIPTS_REC       IN          LNS_APPL_ENGINE_PUB.SEARCH_RECEIPTS_REC,
    X_RECEIPTS_TBL              OUT NOCOPY  LNS_APPL_ENGINE_PUB.RECEIPTS_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SEARCH_RECEIPTS';
    l_Count                         number;

    l_RECEIPT_REC                   LNS_APPL_ENGINE_PUB.RECEIPT_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- search for receipts
    TYPE receipts_cur_type IS REF CURSOR;
    receipts_cur receipts_cur_type;
--    CURSOR receipts_cur(P_LOAN_ID number, P_RECEIPT_ID number, P_RECEIPT_MATCH_REFERENCE varchar2, P_FROM_RC_DATE date, P_TO_RC_DATE date) IS
    l_query VARCHAR2(32767);
    l_input varchar2(1000);
--bug 8998192 - parse varchar2 date format to to_date
    l_from_date date;
    l_to_date date;

BEGIN

   l_query := 'select
            ps.cash_receipt_id,
            ps.trx_number,
            ps.trx_date,
            abs(ps.amount_due_remaining),
            ps.invoice_currency_code,
            party.party_name
        from
            lns_participants par,
            lns_loan_headers loan,
            hz_cust_accounts cust,
            ar_payment_schedules ps,
            lns_system_options sys,
            gl_sets_of_books books,
            hz_parties party,
            AR_SYSTEM_PARAMETERS arsys,
	    ar_cash_receipts cr
        where
            loan.loan_id = :1 and
            loan.loan_id = par.loan_id and
            (par.loan_participant_type  = ''PRIMARY_BORROWER'' or
			 par.loan_participant_type = decode(arsys.pay_unrelated_invoices_flag, ''N'', ''PRIMARY_BORROWER'', ''Y'', ''COBORROWER'') or
			 par.loan_participant_type = decode(arsys.pay_unrelated_invoices_flag, ''N'', ''PRIMARY_BORROWER'', ''Y'', ''GUARANTOR'')) and
            cust.party_id = par.hz_party_id and
            cust.status = ''A'' and
            ps.customer_id = cust.cust_account_id and
            ps.class = ''PMT'' and
            ps.status = ''OP'' and
            ps.amount_due_remaining <> 0 and
            ps.org_id = loan.org_id and
            trunc(ps.trx_date) >= trunc(nvl(:2, ps.trx_date)) and
            trunc(ps.trx_date) <= trunc(nvl(:3, ps.trx_date)) and
            ps.cash_receipt_id = nvl(:4, ps.cash_receipt_id) and
            (ps.invoice_currency_code = loan.loan_currency or
            ps.invoice_currency_code = books.currency_code) and
            sys.set_of_books_id = books.set_of_books_id and
            par.hz_party_id = party.party_id and
            ps.cash_receipt_id = cr.cash_receipt_id';

if(P_SEARCH_RECEIPTS_REC.RECEIPT_MATCH_CRITERIA IS NOT NULL) then
  l_input := 'cr.'||P_SEARCH_RECEIPTS_REC.RECEIPT_MATCH_CRITERIA;
end if;

    l_from_date :=  to_date(substr(P_SEARCH_RECEIPTS_REC.RC_FROM_DATE, 1, 10), 'YYYY/MM/DD');
    l_to_date :=  to_date(substr(P_SEARCH_RECEIPTS_REC.RC_TO_DATE, 1, 10), 'YYYY/MM/DD');


    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching receipts...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_SEARCH_RECEIPTS_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_ID: ' || P_SEARCH_RECEIPTS_REC.RECEIPT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_MATCH_CRITERIA: ' || P_SEARCH_RECEIPTS_REC.RECEIPT_MATCH_CRITERIA);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RC_FROM_DATE: ' || P_SEARCH_RECEIPTS_REC.RC_FROM_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RC_TO_DATE: ' || P_SEARCH_RECEIPTS_REC.RC_TO_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'L_FROM_DATE: ' || l_from_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'L_TO_DATE: ' || l_to_date);

    if(l_input IS NOT NULL) then
        l_query := l_query || ' and loan.loan_number = '||l_input||'  order by '||l_input||' ,ps.trx_date, ps.cash_receipt_id';
    else
	l_query := l_query ||' order by ps.trx_date, ps.cash_receipt_id';
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_query: ' || l_query);

    if P_SEARCH_RECEIPTS_REC.LOAN_ID is null then

    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- search for receipts
    if P_SEARCH_RECEIPTS_REC.RECEIPT_ID is null then
	open receipts_cur for l_query using P_SEARCH_RECEIPTS_REC.LOAN_ID,  l_from_date, l_to_date, to_number(null);
    else
	open receipts_cur for l_query using P_SEARCH_RECEIPTS_REC.LOAN_ID, to_date(null), to_date(null), P_SEARCH_RECEIPTS_REC.RECEIPT_ID;
    end if;

    l_Count := 0;
    LOOP

        fetch receipts_cur into l_RECEIPT_REC.RECEIPT_ID,
                                l_RECEIPT_REC.RECEIPT_NUMBER,
                                l_RECEIPT_REC.RECEIPT_DATE,
                                l_RECEIPT_REC.REMAINING_AMOUNT,
                                l_RECEIPT_REC.RECEIPT_CURRENCY,
                                l_RECEIPT_REC.PARTY_NAME;

        exit when receipts_cur%NOTFOUND;

        l_Count := l_Count+1;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Receipt #' || l_Count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_ID: ' || l_RECEIPT_REC.RECEIPT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_NUMBER: ' || l_RECEIPT_REC.RECEIPT_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_DATE: ' || l_RECEIPT_REC.RECEIPT_DATE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || l_RECEIPT_REC.REMAINING_AMOUNT);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'RECEIPT_CURRENCY: ' || l_RECEIPT_REC.RECEIPT_CURRENCY);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'PARTY_NAME: ' || l_RECEIPT_REC.PARTY_NAME);

        X_RECEIPTS_TBL(l_Count) := l_RECEIPT_REC;

    END LOOP;
    close receipts_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total found ' || X_RECEIPTS_TBL.count || ' receipts');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In ' || l_api_name || ' exception handling');
        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PUBLIC PROCEDURE SEARCH_LOAN_INVOICES
 |
 | DESCRIPTION
 |      This procedure searches for available loan invoices
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan
 |      X_LOAN_INVOICES_TBL         OUT NOCOPY  Table of loan invoices
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
 | 25-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_LOAN_INVOICES(
    P_LOAN_ID                   IN          NUMBER,
    P_FOR_ACTION                IN          VARCHAR2,
    X_LOAN_INVOICES_TBL         OUT NOCOPY  LNS_APPL_ENGINE_PUB.LOAN_INVOICES_TBL)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SEARCH_LOAN_INVOICES';
    l_Count                         number;
    l_order                         varchar2(30);
    l_search_str                    varchar2(1);
	l_start_pos		                number;
	l_end_pos		                number;
    l_Count1                        number;
    l_scope                         varchar2(30);
    l_amortization_sched_id         number;

    l_LOAN_INVOICE_REC              LNS_APPL_ENGINE_PUB.LOAN_INVOICE_REC;
    l_order_tbl                     DBMS_SQL.VARCHAR2_TABLE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get payment application order
    CURSOR order_cur(P_LOAN_ID number) IS
        select PAYMENT_APPLICATION_ORDER,
            nvl(PMT_APPL_ORDER_SCOPE, 'ACROSS_INSTALLMENTS')
        from lns_terms
        where loan_id = P_LOAN_ID;

    -- get all amortizations
    CURSOR am_scheds_cur(P_LOAN_ID number) IS
        select amortization_schedule_id
        from lns_amortization_scheds
        where loan_id = P_LOAN_ID and
            reversed_flag = 'N'
        order by phase, payment_number, amortization_schedule_id;

    -- search for invoices 1 - all interest, then all principal, the all fee
    CURSOR invoices1_cur(P_LOAN_ID number, P_INVOICE_TYPE varchar2, P_FOR_ACTION varchar2) IS
        select
            decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID),
            ps.PAYMENT_SCHEDULE_ID,
            ps.trx_number,
            loan.primary_borrower_id,
            party.party_name,
            loan.product_id,
            product.loan_product_name,
            loan.loan_id,
            loan.loan_number,
            am.amortization_schedule_id,
            am.payment_number,
            am.due_date,
            am.creation_date,
            am.phase,
            P_INVOICE_TYPE,
            look.meaning,
            ps.amount_due_remaining,
            ps.invoice_currency_code,
            loan.EXCHANGE_RATE
        from
            lns_amortization_scheds am,
            lns_loan_headers loan,
            ar_payment_schedules ps,
            hz_parties party,
            lns_loan_products_vl product,
            lns_lookups look
        where
            am.loan_id = P_LOAN_ID and
            loan.loan_id = am.loan_id and
            am.reversed_flag = 'N' and
            ps.customer_trx_id = decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID) and
            ps.amount_due_remaining > decode(P_FOR_ACTION, 'APPLY', 0, 'UNAPPLY', 0) and
            ps.status = decode(P_FOR_ACTION, 'APPLY', 'OP', 'UNAPPLY', 'OP') and
            (am.INTEREST_TRX_ID is not null or am.principal_trx_id is not null or am.FEE_TRX_ID is not null) and
            party.party_id = loan.primary_borrower_id and
            product.loan_product_id = loan.product_id and
            look.lookup_type = 'PAYMENT_APPLICATION_TYPE' and
            look.lookup_code = P_INVOICE_TYPE
        order by am.phase, am.payment_number, am.amortization_schedule_id;

    -- search for invoices 2 - interest, then principal, then fee for single installment then next installment
    CURSOR invoices2_cur(P_LOAN_ID number, P_AMORTIZATION_SCHED_ID number, P_INVOICE_TYPE varchar2, P_FOR_ACTION varchar2) IS
        select
            decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID),
            ps.PAYMENT_SCHEDULE_ID,
            ps.trx_number,
            loan.primary_borrower_id,
            party.party_name,
            loan.product_id,
            product.loan_product_name,
            loan.loan_id,
            loan.loan_number,
            am.amortization_schedule_id,
            am.payment_number,
            am.due_date,
            am.creation_date,
            am.phase,
            P_INVOICE_TYPE,
            look.meaning,
            ps.amount_due_remaining,
            ps.invoice_currency_code,
            loan.EXCHANGE_RATE
        from
            lns_amortization_scheds am,
            lns_loan_headers loan,
            ar_payment_schedules ps,
            hz_parties party,
            lns_loan_products_vl product,
            lns_lookups look
        where
            am.loan_id = P_LOAN_ID and
            am.amortization_schedule_id = P_AMORTIZATION_SCHED_ID and
            loan.loan_id = am.loan_id and
            am.reversed_flag = 'N' and
            ps.customer_trx_id = decode(P_INVOICE_TYPE, 'INT', am.INTEREST_TRX_ID, 'PRIN', am.principal_trx_id, 'FEE', am.FEE_TRX_ID) and
            ps.amount_due_remaining > decode(P_FOR_ACTION, 'APPLY', 0, 'UNAPPLY', 0) and
            ps.status = decode(P_FOR_ACTION, 'APPLY', 'OP', 'UNAPPLY', 'OP') and
            (am.INTEREST_TRX_ID is not null or am.principal_trx_id is not null or am.FEE_TRX_ID is not null) and
            party.party_id = loan.primary_borrower_id and
            product.loan_product_id = loan.product_id and
            look.lookup_type = 'PAYMENT_APPLICATION_TYPE' and
            look.lookup_code = P_INVOICE_TYPE;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching loan invoices...');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_FOR_ACTION: ' || P_FOR_ACTION);

    if P_LOAN_ID is null then

    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- get payment application order
    open order_cur(P_LOAN_ID);
    fetch order_cur into l_order, l_scope;
    close order_cur;

    l_count := 0;
    l_search_str := '_';
	l_start_pos := 1;
    l_end_pos := instr(l_order, l_search_str, l_start_pos, 1);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment application order:');
	LOOP
        l_count := l_count + 1;
		if l_end_pos <> 0 then
			l_order_tbl(l_count) := substr(l_order, l_start_pos, l_end_pos-l_start_pos);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_count: ' || l_order_tbl(l_count));
		else
			l_order_tbl(l_count) := substr(l_order, l_start_pos, LENGTH(l_order)-l_start_pos+1);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_count: ' || l_order_tbl(l_count));
			exit;
		end if;
        l_start_pos := l_end_pos+1;
		l_end_pos := instr(l_order, l_search_str, l_start_pos, 1);
    END LOOP;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Payment application order scope: ' || l_scope);

    if l_scope = 'ACROSS_INSTALLMENTS' then

        l_Count1 := 0;
        -- looping thru payment application order table and fetch invoices in order to be applied
        FOR l_Count IN 1..l_order_tbl.count LOOP

            open invoices1_cur(P_LOAN_ID, l_order_tbl(l_Count), P_FOR_ACTION);
            LOOP

                fetch invoices1_cur into l_LOAN_INVOICE_REC.CUST_TRX_ID,
                                        l_LOAN_INVOICE_REC.PAYMENT_SCHEDULE_ID,
                                        l_LOAN_INVOICE_REC.TRX_NUMBER,
                                        l_LOAN_INVOICE_REC.LOAN_BORROWER_ID,
                                        l_LOAN_INVOICE_REC.BORROWER_NAME,
                                        l_LOAN_INVOICE_REC.LOAN_PRODUCT_ID,
                                        l_LOAN_INVOICE_REC.PRODUCT_NAME,
                                        l_LOAN_INVOICE_REC.LOAN_ID,
                                        l_LOAN_INVOICE_REC.LOAN_NUMBER,
                                        l_LOAN_INVOICE_REC.AMORTIZATION_ID,
                                        l_LOAN_INVOICE_REC.PAYMENT_NUMBER,
                                        l_LOAN_INVOICE_REC.DUE_DATE,
                                        l_LOAN_INVOICE_REC.BILL_DATE,
                                        l_LOAN_INVOICE_REC.PHASE,
                                        l_LOAN_INVOICE_REC.INVOICE_TYPE_CODE,
                                        l_LOAN_INVOICE_REC.INVOICE_TYPE_DESC,
                                        l_LOAN_INVOICE_REC.REMAINING_AMOUNT,
                                        l_LOAN_INVOICE_REC.INVOICE_CURRENCY,
                                        l_LOAN_INVOICE_REC.EXCHANGE_RATE;

                exit when invoices1_cur%NOTFOUND;

                l_Count1 := l_Count1 + 1;

                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count1);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || l_LOAN_INVOICE_REC.PAYMENT_SCHEDULE_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || l_LOAN_INVOICE_REC.CUST_TRX_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_NUMBER: ' || l_LOAN_INVOICE_REC.TRX_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_BORROWER_ID: ' || l_LOAN_INVOICE_REC.LOAN_BORROWER_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_NAME: ' || l_LOAN_INVOICE_REC.BORROWER_NAME);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PRODUCT_ID: ' || l_LOAN_INVOICE_REC.LOAN_PRODUCT_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRODUCT_NAME: ' || l_LOAN_INVOICE_REC.PRODUCT_NAME);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_LOAN_INVOICE_REC.LOAN_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || l_LOAN_INVOICE_REC.LOAN_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_ID: ' || l_LOAN_INVOICE_REC.AMORTIZATION_ID);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || l_LOAN_INVOICE_REC.PAYMENT_NUMBER);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_LOAN_INVOICE_REC.DUE_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_DATE: ' || l_LOAN_INVOICE_REC.BILL_DATE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_LOAN_INVOICE_REC.PHASE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_CODE: ' || l_LOAN_INVOICE_REC.INVOICE_TYPE_CODE);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_DESC: ' || l_LOAN_INVOICE_REC.INVOICE_TYPE_DESC);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || l_LOAN_INVOICE_REC.REMAINING_AMOUNT);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || l_LOAN_INVOICE_REC.INVOICE_CURRENCY);
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_LOAN_INVOICE_REC.EXCHANGE_RATE);

                X_LOAN_INVOICES_TBL(l_Count1) := l_LOAN_INVOICE_REC;

            END LOOP;
            close invoices1_cur;

        END LOOP;

    elsif l_scope = 'WITHIN_INSTALLMENT' then

        l_Count1 := 0;

        -- get all amortizations
        open am_scheds_cur(P_LOAN_ID);

        LOOP

            fetch am_scheds_cur into l_amortization_sched_id;
            exit when am_scheds_cur%NOTFOUND;

            -- looping thru payment application order table and fetch invoices in order to be applied
            FOR l_Count IN 1..l_order_tbl.count LOOP

                open invoices2_cur(P_LOAN_ID, l_amortization_sched_id, l_order_tbl(l_Count), P_FOR_ACTION);
                fetch invoices2_cur into l_LOAN_INVOICE_REC.CUST_TRX_ID,
                                        l_LOAN_INVOICE_REC.PAYMENT_SCHEDULE_ID,
                                        l_LOAN_INVOICE_REC.TRX_NUMBER,
                                        l_LOAN_INVOICE_REC.LOAN_BORROWER_ID,
                                        l_LOAN_INVOICE_REC.BORROWER_NAME,
                                        l_LOAN_INVOICE_REC.LOAN_PRODUCT_ID,
                                        l_LOAN_INVOICE_REC.PRODUCT_NAME,
                                        l_LOAN_INVOICE_REC.LOAN_ID,
                                        l_LOAN_INVOICE_REC.LOAN_NUMBER,
                                        l_LOAN_INVOICE_REC.AMORTIZATION_ID,
                                        l_LOAN_INVOICE_REC.PAYMENT_NUMBER,
                                        l_LOAN_INVOICE_REC.DUE_DATE,
                                        l_LOAN_INVOICE_REC.BILL_DATE,
                                        l_LOAN_INVOICE_REC.PHASE,
                                        l_LOAN_INVOICE_REC.INVOICE_TYPE_CODE,
                                        l_LOAN_INVOICE_REC.INVOICE_TYPE_DESC,
                                        l_LOAN_INVOICE_REC.REMAINING_AMOUNT,
                                        l_LOAN_INVOICE_REC.INVOICE_CURRENCY,
                                        l_LOAN_INVOICE_REC.EXCHANGE_RATE;
                close invoices2_cur;

                if l_LOAN_INVOICE_REC.CUST_TRX_ID is not null then

                    l_Count1 := l_Count1 + 1;

                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Invoice #' || l_Count1);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_SCHEDULE_ID: ' || l_LOAN_INVOICE_REC.PAYMENT_SCHEDULE_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUST_TRX_ID: ' || l_LOAN_INVOICE_REC.CUST_TRX_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'TRX_NUMBER: ' || l_LOAN_INVOICE_REC.TRX_NUMBER);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_BORROWER_ID: ' || l_LOAN_INVOICE_REC.LOAN_BORROWER_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BORROWER_NAME: ' || l_LOAN_INVOICE_REC.BORROWER_NAME);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PRODUCT_ID: ' || l_LOAN_INVOICE_REC.LOAN_PRODUCT_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRODUCT_NAME: ' || l_LOAN_INVOICE_REC.PRODUCT_NAME);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_ID: ' || l_LOAN_INVOICE_REC.LOAN_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_NUMBER: ' || l_LOAN_INVOICE_REC.LOAN_NUMBER);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'AMORTIZATION_ID: ' || l_LOAN_INVOICE_REC.AMORTIZATION_ID);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_NUMBER: ' || l_LOAN_INVOICE_REC.PAYMENT_NUMBER);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DUE_DATE: ' || l_LOAN_INVOICE_REC.DUE_DATE);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'BILL_DATE: ' || l_LOAN_INVOICE_REC.BILL_DATE);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PHASE: ' || l_LOAN_INVOICE_REC.PHASE);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_CODE: ' || l_LOAN_INVOICE_REC.INVOICE_TYPE_CODE);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_TYPE_DESC: ' || l_LOAN_INVOICE_REC.INVOICE_TYPE_DESC);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'REMAINING_AMOUNT: ' || l_LOAN_INVOICE_REC.REMAINING_AMOUNT);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INVOICE_CURRENCY: ' || l_LOAN_INVOICE_REC.INVOICE_CURRENCY);
                    LogMessage(FND_LOG.LEVEL_STATEMENT, 'EXCHANGE_RATE: ' || l_LOAN_INVOICE_REC.EXCHANGE_RATE);

                    X_LOAN_INVOICES_TBL(l_Count1) := l_LOAN_INVOICE_REC;

                end if;

            END LOOP;

        END LOOP;
        close am_scheds_cur;

    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, '______________');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total found ' || X_LOAN_INVOICES_TBL.count || ' invoices');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'In ' || l_api_name || ' exception handling');
        RAISE FND_API.G_EXC_ERROR;
END;



/*========================================================================
 | PUBLIC PROCEDURE SEARCH_AND_APPLY
 |
 | DESCRIPTION
 |      This procedure applies receipts to loan invoices based on passed search criteria
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      LNS_RC_APPL_ENG_CONCUR
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		IN          Standard in parameter
 |      P_INIT_MSG_LIST		IN          Standard in parameter
 |      P_COMMIT			IN          Standard in parameter
 |      P_VALIDATION_LEVEL	IN          Standard in parameter
 |      P_SEARCH_REC        IN          Search record
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
 | 26-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SEARCH_AND_APPLY(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_SEARCH_REC            IN          LNS_APPL_ENGINE_PUB.SEARCH_REC,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'SEARCH_AND_APPLY';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_Count                         number;

    l_LOAN_INVOICES_TBL             LNS_APPL_ENGINE_PUB.LOAN_INVOICES_TBL;
    l_SEARCH_RECEIPTS_REC           LNS_APPL_ENGINE_PUB.SEARCH_RECEIPTS_REC;
    l_RECEIPTS_TBL                  LNS_APPL_ENGINE_PUB.RECEIPTS_TBL;
    l_LOAN_REC                      LNS_APPL_ENGINE_PUB.LOAN_REC;
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get loans to pay
    CURSOR loans_cur(P_BORROWER_ID number, P_PRODUCT_ID number, P_LOAN_ID number, P_UNAPPLY_FLAG varchar2) IS
        select loan.loan_id,
            loan.loan_number,
            loan.primary_borrower_id,
            party.party_name,
            loan.product_id,
            product.loan_product_name,
            loan.loan_currency
        from lns_loan_headers loan,
            hz_parties party,
            lns_loan_products_vl product
        where
            loan.primary_borrower_id = nvl(P_BORROWER_ID, loan.primary_borrower_id) and
            loan.product_id = nvl(P_PRODUCT_ID, loan.product_id) and
            loan.loan_id = nvl(P_LOAN_ID, loan.loan_id) and
            party.party_id = loan.primary_borrower_id and
            product.loan_product_id = loan.product_id and
            ((select count(1)
            from
            lns_amortization_scheds am,
            ar_payment_schedules ps
            where
            am.loan_id = loan.loan_id and
            (am.reversed_flag is null or am.reversed_flag = 'N') and
            ps.customer_trx_id in (am.principal_trx_id, am.interest_trx_id, am.fee_trx_id) and
            ps.amount_due_remaining > decode(P_UNAPPLY_FLAG, 'Y', -1, 'N', 0) and
            ps.status = decode(P_UNAPPLY_FLAG, 'Y', ps.status, 'N', 'OP')) > 0)
        order by trunc(nvl(loan.open_loan_start_date, loan.loan_start_date)), loan.loan_id;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT SEARCH_AND_APPLY;
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

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Input parameters:');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan Borrower ID: ' || P_SEARCH_REC.LOAN_BORROWER_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan Product ID: ' || P_SEARCH_REC.LOAN_PRODUCT_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Loan ID: ' || P_SEARCH_REC.LOAN_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt ID: ' || P_SEARCH_REC.RECEIPT_ID);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Receipt Match Criteria: ' || P_SEARCH_REC.RECEIPT_MATCH_CRITERIA);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'From Receipt Date: ' || P_SEARCH_REC.RC_FROM_DATE);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'To Receipt Date: ' || P_SEARCH_REC.RC_TO_DATE);
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Fix Incorrect Applications: ' || P_SEARCH_REC.UNAPPLY_FLAG);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching for loan to pay...');

    /* init all statement clob */
    dbms_lob.createtemporary(g_last_all_appl_stmt, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_all_appl_stmt, dbms_lob.lob_readwrite);

    l_Count := 0;
    open loans_cur(P_SEARCH_REC.LOAN_BORROWER_ID, P_SEARCH_REC.LOAN_PRODUCT_ID, P_SEARCH_REC.LOAN_ID, P_SEARCH_REC.UNAPPLY_FLAG);
    LOOP

        fetch loans_cur into l_LOAN_REC.LOAN_ID,
                             l_LOAN_REC.LOAN_NUMBER,
                             l_LOAN_REC.LOAN_BORROWER_ID,
                             l_LOAN_REC.BORROWER_NAME,
                             l_LOAN_REC.LOAN_PRODUCT_ID,
                             l_LOAN_REC.PRODUCT_NAME,
                             l_LOAN_REC.LOAN_CURRENCY;
        exit when loans_cur%NOTFOUND;

        l_Count := l_Count + 1;

        LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Processing loan ' || l_LOAN_REC.LOAN_NUMBER || '(' || l_LOAN_REC.LOAN_ID || ')...');

        l_LOAN_REC.SEQUENCE_NUMBER := l_Count;
        LNS_APPL_ENGINE_PUB.ADD_LOAN_TAG(
                P_LOAN_REC              => l_LOAN_REC,
                P_OPEN_CLOSE_FLAG       => 'OPEN');

        BEGIN

            SAVEPOINT PAY_SINGLE_LOAN;

            -- do unapply
            if P_SEARCH_REC.UNAPPLY_FLAG = 'Y' then

                l_LOAN_INVOICES_TBL.delete;
                LNS_APPL_ENGINE_PUB.SEARCH_LOAN_INVOICES(
                    P_LOAN_ID           => l_LOAN_REC.LOAN_ID,
                    P_FOR_ACTION        => 'UNAPPLY',
                    X_LOAN_INVOICES_TBL => l_LOAN_INVOICES_TBL);

                if l_LOAN_INVOICES_TBL.count > 0 then
                    LNS_APPL_ENGINE_PUB.UNAPPLY_RECEIPTS(
                        P_LOAN_INVOICES_TBL => l_LOAN_INVOICES_TBL);
                end if;

            end if;

            -- do apply
            l_LOAN_INVOICES_TBL.delete;
            LNS_APPL_ENGINE_PUB.SEARCH_LOAN_INVOICES(
                P_LOAN_ID           => l_LOAN_REC.LOAN_ID,
                P_FOR_ACTION        => 'APPLY',
                X_LOAN_INVOICES_TBL => l_LOAN_INVOICES_TBL);

            if l_LOAN_INVOICES_TBL.count > 0 then

                l_SEARCH_RECEIPTS_REC.LOAN_ID := l_LOAN_REC.LOAN_ID;
                l_SEARCH_RECEIPTS_REC.RECEIPT_ID := P_SEARCH_REC.RECEIPT_ID;
		        l_SEARCH_RECEIPTS_REC.RECEIPT_MATCH_CRITERIA := P_SEARCH_REC.RECEIPT_MATCH_CRITERIA;
                l_SEARCH_RECEIPTS_REC.RC_FROM_DATE := P_SEARCH_REC.RC_FROM_DATE;
                l_SEARCH_RECEIPTS_REC.RC_TO_DATE := P_SEARCH_REC.RC_TO_DATE;

                l_RECEIPTS_TBL.delete;
                LNS_APPL_ENGINE_PUB.SEARCH_RECEIPTS(
                    P_SEARCH_RECEIPTS_REC => l_SEARCH_RECEIPTS_REC,
                    X_RECEIPTS_TBL        => l_RECEIPTS_TBL);

                if l_RECEIPTS_TBL.count > 0 then

                    LNS_APPL_ENGINE_PUB.APPLY_RECEIPTS(
                        P_LOAN_INVOICES_TBL => l_LOAN_INVOICES_TBL,
                        P_RECEIPTS_TBL      => l_RECEIPTS_TBL);


                else
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No receipts found.');
                end if;

            else
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'No invoices found.');
            end if;

            if P_COMMIT = FND_API.G_TRUE then
                COMMIT WORK;
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited loan ' || l_LOAN_REC.LOAN_NUMBER);
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO PAY_SINGLE_LOAN;
                g_cr_return_status := 'WARNING';
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollback loan ' || l_LOAN_REC.LOAN_NUMBER);
        END;

        LNS_APPL_ENGINE_PUB.ADD_LOAN_TAG(
                P_LOAN_REC              => l_LOAN_REC,
                P_OPEN_CLOSE_FLAG       => 'CLOSE');

    END LOOP;
    close loans_cur;

    if l_Count = 0 then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total found ' || l_Count || ' loans');
    else
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || l_Count || ' loans');
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
        ROLLBACK TO SEARCH_AND_APPLY;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SEARCH_AND_APPLY;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
    WHEN OTHERS THEN
        ROLLBACK TO SEARCH_AND_APPLY;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked loans');
        g_cr_return_status := 'ERROR';
END;



/*========================================================================
 | PUBLIC PROCEDURE LNS_APPL_RC_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to apply receipts to loan invoices
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
 |      LOAN_BORROWER_ID    IN      Loan primary borrower id
 |      LOAN_PRODUCT_ID     IN      Loan product id
 |      LOAN_ID             IN      Loan id
 |      RECEIPT_ID          IN      Receipt id
 |      RECEIPT_MATCH_CRITERIA IN   Receipt Matching Criteria
 |      RC_FROM_DATE        IN      From receipt date
 |      RC_TO_DATE          IN      To receipt date
 |      --UNAPPLY_FLAG        IN      Fix incorrect applications
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
 | 24-10-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_APPL_RC_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_BORROWER_ID    IN             NUMBER,
        LOAN_PRODUCT_ID     IN             NUMBER,
        LOAN_ID             IN             NUMBER,
        RECEIPT_ID          IN             NUMBER,
	RECEIPT_MATCH_CRITERIA IN         VARCHAR2,
        RC_FROM_DATE        IN             VARCHAR2,
        RC_TO_DATE          IN             VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
	l_msg_count	        number;
    l_return            boolean;
    l_SEARCH_REC        LNS_APPL_ENGINE_PUB.SEARCH_REC;
    l_matching_ref      varchar2(250);

BEGIN

    g_cr_return_status := 'NORMAL';

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '<<--------Applying AR cash receipts to loan invoices...-------->>');

    l_SEARCH_REC.LOAN_BORROWER_ID := LOAN_BORROWER_ID;
    l_SEARCH_REC.LOAN_PRODUCT_ID := LOAN_PRODUCT_ID;
    l_SEARCH_REC.LOAN_ID := LOAN_ID;
    l_SEARCH_REC.RECEIPT_ID := RECEIPT_ID;
    l_SEARCH_REC.RECEIPT_MATCH_CRITERIA := RECEIPT_MATCH_CRITERIA;
    l_SEARCH_REC.RC_FROM_DATE := RC_FROM_DATE;
    l_SEARCH_REC.RC_TO_DATE := RC_TO_DATE;
    l_SEARCH_REC.UNAPPLY_FLAG := 'N'; --Hard coding the incorrect application to No always.

    LNS_APPL_ENGINE_PUB.SEARCH_AND_APPLY(
        P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
        P_SEARCH_REC => l_SEARCH_REC,
    	X_RETURN_STATUS	=> RETCODE,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => ERRBUF);

    LNS_APPL_ENGINE_PUB.BUILD_RC_APPL_REPORT(
        P_SEARCH_REC => l_SEARCH_REC);

    if g_cr_return_status = 'WARNING' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Not all applications were successfully. Please review log file.');
    elsif g_cr_return_status = 'ERROR' then
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
			            message => 'Application process has failed. Please review log file.');
    end if;

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

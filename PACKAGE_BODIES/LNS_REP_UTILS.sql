--------------------------------------------------------
--  DDL for Package Body LNS_REP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_REP_UTILS" as
/* $Header: LNS_REP_UTILS_B.pls 120.29.12010000.15 2010/04/15 12:40:50 scherkas ship $ */

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
 |
 *=======================================================================*/


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_REP_UTILS';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;
    g_org_id                        number;

/*========================================================================+
   Function which returns the global variable g_loan_start_date_from
     ========================================================================*/

     FUNCTION get_loan_start_date_from return DATE is
     BEGIN
         return lns_rep_utils.g_loan_start_date_from;
     END get_loan_start_date_from;

/*========================================================================+
   Function which returns the global variable g_loan_start_date_to
     ========================================================================*/

     FUNCTION get_loan_start_date_to return DATE is
     BEGIN
         return lns_rep_utils.g_loan_start_date_to;
     END get_loan_start_date_to;
/*========================================================================+
   Function which returns the global variable g_bill_due_date_from
     ========================================================================*/

     FUNCTION get_bill_due_date_from return DATE is
     BEGIN
         return lns_rep_utils.g_bill_due_date_from;
     END get_bill_due_date_from;

/*========================================================================+
   Function which returns the global variable g_bill_due_date_to
     ========================================================================*/

     FUNCTION get_bill_due_date_to return DATE is
     BEGIN
         return lns_rep_utils.g_bill_due_date_to;
     END get_bill_due_date_to;
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
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
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



PROCEDURE PRINT_CLOB (lob_loc                in  clob) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30) := 'PRINT_CLOB';
   l_api_version                   CONSTANT NUMBER := 1.0;
   c_endline                       CONSTANT VARCHAR2 (1) := '
';
   c_endline_len                   CONSTANT NUMBER       := LENGTH (c_endline);
   l_start                         NUMBER          := 1;
   l_end                           NUMBER;
   l_one_line                      VARCHAR2 (17000);
   l_charset	                   VARCHAR2(100);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   LOOP
      l_end :=
            DBMS_LOB.INSTR (lob_loc      => lob_loc,
                            pattern      => c_endline,
                            offset       => l_start,
                            nth          => 1
                           );

      IF (NVL (l_end, 0) < 1)
      THEN
         EXIT;
      END IF;

      l_one_line :=
            DBMS_LOB.SUBSTR (lob_loc      => lob_loc,
                             amount       => l_end - l_start,
                             offset       => l_start
                            );
      l_start := l_end + c_endline_len;
      --Fnd_File.PUT_line(Fnd_File.LOG,l_one_line);
      Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);

   END LOOP;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
END PRINT_CLOB;

FUNCTION REPLACE_SPECIAL_CHARS(P_XML_DATA IN VARCHAR2)
			   RETURN VARCHAR2
IS

   l_api_name              CONSTANT VARCHAR2(30) := 'REPLACE_SPECIAL_CHARS';
   l_xml		   VARCHAR2(32767);

BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   l_xml := REPLACE(P_XML_DATA,'&','&amp;');
   l_xml := REPLACE(l_xml,'&amp;amp;','&amp;');
   RETURN l_xml;

EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' -');
      RAISE;
END REPLACE_SPECIAL_CHARS;


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
                                  ) IS
   l_api_name                      CONSTANT VARCHAR2(30) := 'PROCESS_PORTFOLIO_REPORT';
   l_api_version                   CONSTANT NUMBER := 1.0;
   ctx DBMS_XMLQUERY.ctxType;
   result CLOB;
   qryCtx                  DBMS_XMLGEN.ctxHandle;
   l_result                CLOB;
   tempResult              CLOB;
   l_version               varchar2(20);
   l_compatibility         varchar2(20);
   l_suffix                varchar2(2);
   l_majorVersion          number;
   l_resultOffset          number;
   l_xml_header            varchar2(3000);
   l_xml_header_length     number;
   l_errNo                 NUMBER;
   l_errMsg                VARCHAR2(200);
   queryCtx                DBMS_XMLquery.ctxType;
   l_xml_query             VARCHAR2(32767);
   TYPE ref_cur IS REF CURSOR;
   l_xml_stmt              ref_cur;
   l_rows_processed        NUMBER;
   l_new_line              VARCHAR2(1);
   l_org_id                hr_operating_units.organization_id%TYPE;
   l_org_name              hr_operating_units.NAME%TYPE;
   l_borrower_name         hz_parties.party_name%TYPE;
   l_account_number        hz_cust_accounts.account_number%TYPE;
   l_cust_account_id       hz_cust_accounts.cust_account_id%TYPE;
   l_start_date_from       lns_loan_headers_all.loan_start_date%TYPE;
   l_start_date_to         lns_loan_headers_all.loan_start_date%TYPE;
   l_loan_type_desc        lns_loan_types.loan_type_desc%TYPE;
   l_loan_type_id          lns_loan_types.loan_type_id%TYPE;
   l_legal_entity_id       xle_entity_profiles.legal_entity_id%TYPE;
   l_legal_entity_name     xle_entity_profiles.name%TYPE;
   l_loan_product_name     lns_loan_products_all.loan_product_name%TYPE;
   l_loan_officer          jtf_rs_resource_extns.source_name%TYPE;
   l_loan_status1_desc     lns_lookups.meaning%TYPE;
   l_loan_status2_desc     lns_lookups.meaning%TYPE;
   l_include_charts        VARCHAR2(30);
   l_close_tag             VARCHAR2(100);
   l_query  		   VARCHAR2(5000) :=
'select ' ||
'lh.LOAN_ID, ' ||
'lh.loan_number ' ||
',hp.party_name customer ' ||
',llk.meaning || decode(lh.secondary_status,null,'''','': '') || llks.meaning loan_status_meaning ' ||
',lh.loan_status || decode(lh.secondary_status,null,'''','': '') || lh.secondary_status loan_status ' ||
',lh.loan_status primary_loan_status ' ||
',lh.secondary_status secondary_loan_status ' ||
',pay.TOTAL_PRINCIPAL_BALANCE loan_amount ' ||
',(CASE
	WHEN
                 (
                      lh.LOAN_STATUS  = ''ACTIVE''
                    OR lh.LOAN_STATUS = ''DEFAULT''
                    OR lh.LOAN_STATUS = ''DELINQUENT''
		    OR lh.LOAN_STATUS = ''PAIDOFF''
                )
	THEN
		pay.TOTAL_PRINCIPAL_BALANCE
	ELSE
		lh.REQUESTED_AMOUNT
      END
    ) loan_req_bal_amount' ||
',lh.loan_description ' ||
',to_char(lh.loan_maturity_date, ''MM/DD/YYYY'') loan_maturity_date ' ||
',lh.loan_term || '' '' || llktt.meaning loan_length ' ||
',to_char(lh.LOAN_APPLICATION_DATE, ''MM/DD/YYYY'') LOAN_APPLICATION_DATE ' ||
',lh.ORG_ID ' ||
',lh.LOAN_TYPE ' ||
',lh.LOAN_CLASS_CODE ' ||
',lh.LOAN_CURRENCY ' ||
',LNS_FINANCIALS.getActiveRate(lh.LOAN_ID) current_interest_rate ' ||
', llkrt.meaning interest_type ' ||
',lh.LOAN_SUBTYPE ' ||
',(select max(last_update_date) from LNS_APPROVAL_ACTIONS  ' ||
'where loan_id = lh.LOAN_ID  ' ||
'and ACTION_TYPE = ''SUBMIT_FOR_APPR'') submit_for_approval_date ' ||
',lh.LAST_BILLED_DATE ' ||
',(lh.REQUESTED_AMOUNT + lh.ADD_REQUESTED_AMOUNT) original_requested_amount ' ||
',lh.LOAN_APPROVAL_DATE ' ||
',pay.TOTAL_PRIN_PAID_TODATE principal_paid ' ||
',pay.INTEREST_PAID_TODATE interest_paid ' ||
',pay.FEE_PAID_TODATE fees_paid ' ||
',pay.NEXT_PAYMENT_DUE_DATE next_payment_due_date ' ||
',pay.NEXT_PAYMENT_PRINCIPAL_DUE next_principal_due ' ||
',pay.NEXT_PAYMENT_INTEREST_DUE next_interest_due ' ||
',pay.NEXT_PAYMENT_FEE_DUE next_fees_due ' ||
',pay.NEXT_PAYMENT_TOTAL_DUE next_payment_due ' ||
',account.ACCOUNT_NUMBER ' ||
', CURSOR (select ' ||
'REQUESTED_AMOUNT loan_requested_amount, ' ||
'REFERENCE_AMOUNT original_rec_balance, ' ||
'REFERENCE_NUMBER original_rec_desc ' ||
'from LNS_LOAN_LINES ' ||
'where loan_id = lh.LOAN_ID ' ||
'and   end_date is null) AS ORIGINAL_RECEIVABLES ' ||
'from ' ||
'lns_loan_headers_all lh, ' ||
'hz_parties hp, ' ||
'lns_terms t, ' ||
'lns_lookups llk, ' ||
'LNS_PAY_SUM_V pay, ' ||
'hz_cust_accounts_all account, ' ||
'lns_lookups llkrt, ' ||
'lns_lookups llktt, ' ||
'lns_lookups llks ' ||
'where ' ||
'lh.primary_borrower_id = hp.party_id and ' ||
'lh.loan_id = pay.loan_id and ' ||
'lh.loan_id = t.loan_id and ' ||
'llk.lookup_code = lh.loan_status and ' ||
'llk.lookup_type = ''LOAN_STATUS'' and ' ||
'llktt.lookup_code = lh.loan_term_period and ' ||
'llktt.lookup_type = ''PERIOD'' and ' ||
'llkrt.lookup_code = t.rate_type and ' ||
'llkrt.lookup_type = ''RATE_TYPE'' and ' ||
'llks.lookup_code(+) = lh.secondary_status and ' ||
'llks.lookup_type(+) = ''SECONDARY_STATUS'' and ' ||
'lh.loan_status <> ''DELETED'' and ' ||
'lh.CUST_ACCOUNT_ID = account.CUST_ACCOUNT_ID and ' ||
'lh.loan_class_code = :LOAN_CLASS and ' ||
'lh.loan_type_id = :LOAN_TYPE_ID and ' ||
'lh.loan_currency = :CURRENCY_CODE and ' ||
'lh.org_id = :ORG_ID';
   l_temp_where_clause VARCHAR2(200);
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   l_loan_type_id := loan_type_id;
   l_legal_entity_id := legal_entity_id;
   g_loan_start_date_from := trunc(fnd_date.canonical_to_date(loan_start_date_from));
   g_loan_start_date_to := trunc(fnd_date.canonical_to_date(loan_start_date_to));
   l_cust_account_id := cust_account_id;
   l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
   IF nvl(INCLUDE_CHARTS, 'N') = 'Y' THEN
      l_include_charts := 'Yes';
   ELSE
      l_include_charts := 'No';
   END IF;
   BEGIN
      SELECT loan_type_desc
      into   l_loan_type_desc
      from   lns_loan_types_vl
      where  loan_type_id = l_loan_type_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN null;
   END;
   -- Build Bind Placeholders for all non-mandatory parameters

   IF loan_number IS NOT NULL
   THEN
      l_query := l_query || ' and lh.loan_number like :LOAN_NUMBER';
   END IF;
   IF borrower_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.primary_borrower_id  = :BORROWER_ID';
   END IF;
   IF cust_account_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.cust_account_id  = :CUST_ACCOUNT_ID';
   END IF;
   IF loan_start_date_from IS NOT NULL and loan_start_date_to is NULL THEN
      l_query := l_query || ' and trunc(lh.loan_start_date)  >= lns_rep_utils.get_loan_start_date_from()';
   END IF;
   IF loan_start_date_to IS NOT NULL and loan_start_date_from is NULL THEN
      l_query := l_query || ' and trunc(lh.loan_start_date)  <= lns_rep_utils.get_loan_start_date_to()';
   END IF;
   IF loan_start_date_from IS NOT NULL and loan_start_date_to is NOT NULL THEN
      l_query := l_query || ' and trunc(lh.loan_start_date)  between lns_rep_utils.get_loan_start_date_from() and lns_rep_utils.get_loan_start_date_to()';
   END IF;
   IF legal_entity_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.legal_entity_id  = :LEGAL_ENTITY_ID';
   END IF;
   IF product_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.product_id  = :PRODUCT_ID';
   END IF;
   IF loan_assigned_to IS NOT NULL
   THEN
      l_query := l_query || ' and lh.loan_assigned_to  = :LOAN_ASSIGNED_TO';
   END IF;
   IF loan_status1 IS NOT NULL and loan_status2 IS NULL
   THEN
      l_query := l_query || ' and lh.loan_status = ''' || LOAN_STATUS1 ||'''';
   END IF;
   IF loan_status2 IS NOT NULL and loan_status1 IS NULL
   THEN
      l_query := l_query || ' and lh.loan_status = ''' || LOAN_STATUS2 ||'''';
   END IF;
   IF loan_status1 IS NOT NULL and loan_status2 IS NOT NULL
   THEN
      --l_query := l_query || ' and (lh.loan_status = :LOAN_STATUS1 or lh.loan_status = :LOAN_STATUS2)';
      l_query := l_query || ' and (lh.loan_status = ''' || LOAN_STATUS1 ||''' or lh.loan_status = ''' || LOAN_STATUS2 ||''')';
   END IF;

   -- Start Getting Parameter Display Values
   SELECT name
   INTO   l_org_name
   FROM   HR_ALL_ORGANIZATION_UNITS_TL
   WHERE  organization_id = l_org_id
   AND language = userenv('LANG');

   IF borrower_id is NOT NULL
   THEN
      SELECT PARTY_NAME
      INTO   l_borrower_name
      FROM   hz_parties
      WHERE  party_id = borrower_id;
   END IF;

   IF cust_account_id is NOT NULL
   THEN
      SELECT account_number
      into   l_account_number
      FROM   hz_cust_accounts
      WHERE  cust_account_id =  l_cust_account_id;
   END IF;
   IF loan_status1 is NOT NULL
   THEN
      SELECT meaning
      into   l_loan_status1_desc
      from   lns_lookups
      where  lookup_type = 'LOAN_STATUS'
      and    lookup_code = loan_status1;
   END IF;
   IF loan_status2 is NOT NULL
   THEN
      SELECT meaning
      into   l_loan_status2_desc
      from   lns_lookups
      where  lookup_type = 'LOAN_STATUS'
      and    lookup_code = loan_status2;
   END IF;
   IF legal_entity_id is NOT NULL
   THEN
      SELECT NAME
      INTO   l_legal_entity_name
      FROM   xle_entity_profiles
      WHERE  legal_entity_id = l_legal_entity_id;
   END IF;
   IF product_id is NOT NULL
   THEN
      SELECT loan_product_name
      INTO   l_loan_product_name
      FROM   lns_loan_products_all_vl
      WHERE  loan_product_id = product_id;
   END IF;
   IF loan_assigned_to is NOT NULL
   THEN
      SELECT source_name
      INTO   l_loan_officer
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = loan_assigned_to;
   END IF;
   ctx := DBMS_XMLQUERY.newContext(l_query);
     -- Bind Mandatory Variables
     DBMS_XMLQuery.setBindValue(ctx, 'LOAN_CLASS', loan_class);
     DBMS_XMLQuery.setBindValue(ctx, 'LOAN_TYPE_ID', loan_type_id);
     DBMS_XMLQuery.setBindValue(ctx, 'CURRENCY_CODE', currency_code);
     DBMS_XMLQuery.setBindValue(ctx, 'ORG_ID', l_org_id);

     -- Bind Optional Variables if they are NOT NULL
     IF borrower_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'BORROWER_ID', borrower_id);
     END IF;
     IF loan_number is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LOAN_NUMBER', loan_number);
     END IF;
     IF cust_account_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'CUST_ACCOUNT_ID', cust_account_id);
     END IF;
     IF legal_entity_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LEGAL_ENTITY_ID', legal_entity_id);
     END IF;
     IF loan_assigned_to is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LOAN_ASSIGNED_TO', loan_assigned_to);
     END IF;
     IF product_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'PRODUCT_ID', product_id);
     END IF;

     -- now get the result
     BEGIN
        l_result := DBMS_XMLQUERY.getXML(ctx);
	DBMS_XMLQuery.closeContext(ctx);
	l_rows_processed := 1;
     EXCEPTION
     WHEN OTHERS THEN
        DBMS_XMLQuery.getExceptionContent(ctx,l_errNo,l_errMsg);
        IF l_errNo = 1403 THEN
           l_rows_processed := 0;
        END IF;
        DBMS_XMLQuery.closeContext(ctx);
     END;
     -- We are adding the LNSPORTFOLIO and PARAMETERS TAGs so we have
     -- to offset the first line.
     IF l_rows_processed <> 0 THEN
         l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
         tempResult       := l_result;
     ELSE
         l_resultOffset   := 0;
     END IF;

     l_new_line := '
';
   /* Prepare the tag for the report heading */
   l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<LNSPORTFOLIO>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORG_NAME>'||REPLACE_SPECIAL_CHARS(l_org_name)||'</ORG_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_CLASS_CODE>' ||REPLACE_SPECIAL_CHARS(loan_class) ||'</LOAN_CLASS_CODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_TYPE_DESC>' ||REPLACE_SPECIAL_CHARS(l_loan_type_desc) ||'</LOAN_TYPE_DESC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CURRENCY_CODE>' ||REPLACE_SPECIAL_CHARS(currency_code) ||'</CURRENCY_CODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_NUMBER>' ||REPLACE_SPECIAL_CHARS(loan_number) ||'</LOAN_NUMBER>';
   l_xml_header     := l_xml_header ||l_new_line||'        <BORROWER_NAME>' ||REPLACE_SPECIAL_CHARS(l_borrower_name) ||'</BORROWER_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ACCOUNT_NUMBER>' ||l_account_number ||'</ACCOUNT_NUMBER>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_START_DATE_FROM>' || loan_start_date_from ||'</LOAN_START_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_START_DATE_TO>' || loan_start_date_to ||'</LOAN_START_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_STATUS1_DESC>' ||REPLACE_SPECIAL_CHARS(l_loan_status1_desc) ||'</LOAN_STATUS1_DESC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_STATUS2_DESC>' ||REPLACE_SPECIAL_CHARS(l_loan_status2_desc) ||'</LOAN_STATUS2_DESC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LEGAL_ENTITY_NAME>' ||REPLACE_SPECIAL_CHARS(l_legal_entity_name) ||'</LEGAL_ENTITY_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_PRODUCT_NAME>' ||REPLACE_SPECIAL_CHARS(l_loan_product_name) ||'</LOAN_PRODUCT_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_OFFICER>' ||REPLACE_SPECIAL_CHARS(l_loan_officer) ||'</LOAN_OFFICER>';
   l_xml_header     := l_xml_header ||l_new_line||'        <INCLUDE_CHARTS>' ||l_include_charts ||'</INCLUDE_CHARTS>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_close_tag      := l_new_line||'</LNSPORTFOLIO>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result
                   ,dbms_lob.getlength(l_result)-l_resultOffset
                   ,l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
   print_clob(lob_loc => tempResult);
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' -');
      RAISE;
END PROCESS_PORTFOLIO_REPORT;
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
                                  ) IS
   l_api_name              CONSTANT VARCHAR2(30) := 'PROCESS_RECON_REPORT';
   l_api_version           CONSTANT NUMBER := 1.0;
   ctx                     DBMS_XMLQUERY.ctxType;
   result                  CLOB;
   qryCtx                  DBMS_XMLGEN.ctxHandle;
   l_result                CLOB;
   tempResult              CLOB;
   l_version               varchar2(20);
   l_compatibility         varchar2(20);
   l_suffix                varchar2(2);
   l_majorVersion          number;
   l_resultOffset          number;
   l_xml_header            varchar2(3000);
   l_xml_header_length     number;
   l_errNo                 NUMBER;
   l_errMsg                VARCHAR2(200);
   queryCtx                DBMS_XMLquery.ctxType;
   l_xml_query             VARCHAR2(32767);
   TYPE ref_cur IS REF CURSOR;
   l_xml_stmt              ref_cur;
   l_rows_processed        NUMBER;
   l_new_line              VARCHAR2(1);
   l_org_id                hr_operating_units.organization_id%TYPE;
   l_org_name              hr_operating_units.NAME%TYPE;
   l_borrower_name         hz_parties.party_name%TYPE;
   l_account_number        hz_cust_accounts.account_number%TYPE;
   l_cust_account_id       hz_cust_accounts.cust_account_id%TYPE;
   l_start_date_from       lns_loan_headers_all.loan_start_date%TYPE;
   l_start_date_to         lns_loan_headers_all.loan_start_date%TYPE;
   l_loan_type_desc        lns_loan_types.loan_type_desc%TYPE;
   l_loan_type_id          lns_loan_types.loan_type_id%TYPE;
   l_legal_entity_id       xle_entity_profiles.legal_entity_id%TYPE;
   l_legal_entity_name     xle_entity_profiles.name%TYPE;
   l_loan_officer          jtf_rs_resource_extns.source_name%TYPE;
   l_loan_status1_desc     lns_lookups.meaning%TYPE;
   l_loan_status2_desc     lns_lookups.meaning%TYPE;
   l_close_tag             VARCHAR2(100);
   l_query  		   VARCHAR2(11000) :=
'select   ' ||
'lh.LOAN_ID,  ' ||
'lh.loan_number  ' ||
',hp.party_name customer  ' ||
',llk.meaning loan_status_meaning  ' ||
',lh.loan_status  ' ||
',pay.TOTAL_PRINCIPAL_BALANCE loan_balance  ' ||
',lh.loan_description  ' ||
',account.ACCOUNT_NUMBER  ' ||
',lh.FUNDED_AMOUNT original_loan_amount  ' ||
',to_char(lh.loan_maturity_date, ''MM/DD/YYYY'') loan_maturity_date  ' ||
',lh.ORG_ID  ' ||
',lot.loan_type_name loan_type  ' ||
',lh.LOAN_CLASS_CODE  ' ||
',lh.LOAN_CURRENCY  ' ||
',(loc.address1 || '' '' || loc.city || '' '' || loc.state || '' '' ||   ' ||
'loc.postal_code || '' '' || terr.TERRITORY_SHORT_NAME) Address  ' ||
',ou.name operating_unit ' ||
',lh.LEGAL_ENTITY_ID ' ||
',le.NAME LEGAL_ENTITY_NAME ' ||
',lh.product_id ' ||
',product.loan_product_name loan_product ' ||
',nvl((select sum(line.line_amount) ' ||
'    from lns_disb_lines line, ' ||
'    lns_disb_headers head ' ||
'    where head.loan_id = lh.LOAN_ID and ' ||
'    head.disb_header_id = line.disb_header_id and ' ||
'    line.status = ''FULLY_FUNDED''), 0) disbursed_amount ' ||
',nvl(lh.CURRENT_PHASE, ''TERM'') current_phase ' ||
', CURSOR (select   ' ||
'	LOAN_ID loan_id,  ' ||
'	REFERENCE_NUMBER original_rec_number,  ' ||
'	REFERENCE_AMOUNT original_rec_balance,   ' ||
'	REQUESTED_AMOUNT loan_requested_amount,  ' ||
'	REFERENCE_NUMBER original_rec_desc   ' ||
'	from LNS_LOAN_LINES   ' ||
'	where loan_id = lh.LOAN_ID  ' ||
'	and   end_date is null  ' ||
') AS ORIGINAL_RECEIVABLES  ' ||
', CURSOR (  ' ||
'       select   ' ||
'       max(amv.loan_id) loan_id,  ' ||
'       sum(amv.PRINCIPAL_AMOUNT) prin_amortization_amount,  ' ||
'       sum(amv.PRIN_CASH) prin_receipt_payments,  ' ||
'       sum(amv.PRIN_NET_CREDIT) prin_credit_netting,  ' ||
'       sum(amv.PRIN_LOAN_PMT_CREDIT) prin_credit_payments,  ' ||
'       sum(amv.PRIN_OTHER_CREDIT) prin_credit_non_payments,  ' ||
'       sum(amv.PRIN_ADJ) prin_adjustments,  ' ||
'       sum(amv.PRINCIPAL_REMAINING) prin_remaining_amount,  ' ||
'       sum(amv.INTEREST_AMOUNT) int_amortization_amount,  ' ||
'       sum(amv.INT_CASH) int_receipt_payments,  ' ||
'       sum(amv.INT_NET_CREDIT) int_credit_netting,  ' ||
'       sum(amv.INT_LOAN_PMT_CREDIT) int_credit_payments,  ' ||
'       sum(amv.INT_OTHER_CREDIT) int_credit_non_payments,  ' ||
'       sum(amv.INT_ADJ) int_adjustments,  ' ||
'       sum(amv.INTEREST_REMAINING) int_remaining_amount,  ' ||
'       sum(amv.FEE_AMOUNT) fee_amortization_amount,  ' ||
'       sum(amv.FEE_CASH) fee_receipt_payments,  ' ||
'       sum(amv.FEE_NET_CREDIT) fee_credit_netting,  ' ||
'       sum(amv.FEE_LOAN_PMT_CREDIT) fee_credit_payments,  ' ||
'       sum(amv.FEE_OTHER_CREDIT) fee_credit_non_payments,  ' ||
'       sum(amv.FEE_ADJ) fee_adjustments,  ' ||
'       sum(amv.FEE_REMAINING) fee_remaining_amount  ' ||
'       from   ' ||
'       LNS_AM_SCHEDS_DTL_V amv ' ||
'       where amv.loan_id = lh.LOAN_ID and  ' ||
'       amv.REVERSED_CODE = ''N'' and  ' ||
'     trunc(amv.DUE_DATE)  between dateparameters.from_dt and  dateparameters.to_dt  ' ||
') AS BILL_PAY_SUMMARY  ' ||
', CURSOR (  ' ||
'	select   ' ||
'	am.PAYMENT_NUMBER,  ' ||
'	lok.MEANING purpose,  ' ||
'	decode(trx.customer_trx_id,   ' ||
'		   am.PRINCIPAL_TRX_ID, am.PRINCIPAL_AMOUNT,   ' ||
'		   am.INTEREST_TRX_ID, am.INTEREST_AMOUNT,   ' ||
'		   am.FEE_TRX_ID, am.FEE_AMOUNT) amortization_amount,  ' ||
'	psa.AMOUNT_DUE_ORIGINAL ar_trx_amount,  ' ||
'	(decode(trx.customer_trx_id,   ' ||
'		   am.PRINCIPAL_TRX_ID, am.PRINCIPAL_AMOUNT,   ' ||
'		   am.INTEREST_TRX_ID, am.INTEREST_AMOUNT,   ' ||
'		   am.FEE_TRX_ID, am.FEE_AMOUNT)  ' ||
'	- psa.AMOUNT_DUE_ORIGINAL) difference,  ' ||
'	trx.INTERFACE_HEADER_ATTRIBUTE1 ar_trx_reference  ' ||
'	from   ' ||
'	lns_amortization_scheds am,  ' ||
'	ar_payment_schedules_all psa,  ' ||
'    RA_CUSTOMER_TRX_ALL trx,  ' ||
'	LNS_LOOKUPS lok  ' ||
'	where am.loan_id = lh.LOAN_ID and  ' ||
'	(am.REVERSED_FLAG is null or am.REVERSED_FLAG = ''N'') and  ' ||
'     trunc(am.DUE_DATE)  between dateparameters.from_dt and  dateparameters.to_dt  and  ' ||
'	(trx.customer_trx_id = am.PRINCIPAL_TRX_ID or  ' ||
'	trx.customer_trx_id = am.INTEREST_TRX_ID or  ' ||
'	trx.customer_trx_id = am.FEE_TRX_ID) and   ' ||
'	psa.customer_trx_id = trx.customer_trx_id and  ' ||
'	lok.lookup_type = ''PAYMENT_APPLICATION_TYPE'' and  ' ||
'	lok.lookup_code = decode(trx.customer_trx_id, am.PRINCIPAL_TRX_ID,   ' ||
'	''PRIN'', am.INTEREST_TRX_ID, ''INT'', am.FEE_TRX_ID, ''FEES'') and  ' ||
'	(decode(trx.customer_trx_id,   ' ||
'		   am.PRINCIPAL_TRX_ID, am.PRINCIPAL_AMOUNT,   ' ||
'		   am.INTEREST_TRX_ID, am.INTEREST_AMOUNT,   ' ||
'		   am.FEE_TRX_ID, am.FEE_AMOUNT) <> psa.AMOUNT_DUE_ORIGINAL)  ' ||
') AS EXCEPTION_FLAGS ,  ' ||
'CURSOR (  ' ||
'     select  ' ||
'     amv.PAYMENT_NUMBER,  ' ||
'     amv.BILL_TYPE_DESC meaning,  ' ||
'     amv.PRINCIPAL_AMOUNT billed_principal_amount,  ' ||
'     amv.PRIN_CASH prin_receipt_payments,  ' ||
'     amv.PRIN_NET_CREDIT prin_credit_netting,  ' ||
'     amv.PRIN_LOAN_PMT_CREDIT prin_credit_payments,  ' ||
'     amv.PRIN_OTHER_CREDIT prin_credit_non_payments,  ' ||
'     amv.PRIN_ADJ prin_adjustments,  ' ||
'     amv.PRINCIPAL_REMAINING prin_remaining_amount,  ' ||
'     amv.INTEREST_AMOUNT billed_int_amount,  ' ||
'     amv.INT_CASH int_receipt_payments,  ' ||
'     amv.INT_NET_CREDIT int_credit_netting,  ' ||
'     amv.INT_LOAN_PMT_CREDIT int_credit_payments,  ' ||
'     amv.INT_OTHER_CREDIT int_credit_non_payments,  ' ||
'     amv.INT_ADJ int_adjustments,  ' ||
'     amv.INTEREST_REMAINING int_remaining_amount,  ' ||
'     amv.FEE_AMOUNT billed_fee_amount,  ' ||
'     amv.FEE_CASH fee_receipt_payments,  ' ||
'     amv.FEE_NET_CREDIT fee_credit_netting,  ' ||
'     amv.FEE_LOAN_PMT_CREDIT fee_credit_payments,  ' ||
'     amv.FEE_OTHER_CREDIT fee_credit_non_payments,  ' ||
'     amv.FEE_ADJ fee_adjustments,  ' ||
'     amv.FEE_REMAINING fee_remaining_amount,  ' ||
'     to_char(amv.DUE_DATE,''MM/DD/YYYY'') due_date, ' ||
'     amv.PHASE, ' ||
'     CURSOR (  ' ||
'          select  ' ||
'          rec.PAYMENT_NUMBER,  ' ||
'          rec.line_type_desc,  ' ||
'          rec.line_desc,  ' ||
'          rec.activity_desc,  ' ||
'          rec.activity_amount,  ' ||
'          rec.activity_number,  ' ||
'          to_char(rec.activity_date,''MM/DD/YYYY'') activity_date,  ' ||
'          rec.trx_currency,  ' ||
'          rec.receipt_amt_applied_from,  ' ||
'          rec.receipt_currency,  ' ||
'          rec.trx_to_receipt_rate  ' ||
'          from  ' ||
'          LNS_REC_ACT_CASH_CM_V rec  ' ||
'          where  ' ||
'          amv.loan_id = rec.loan_id and  ' ||
'          amv.AMORTIZATION_SCHEDULE_ID = rec.LOAN_AMORTIZATION_ID  ' ||
'     ) AS PAYMENT_ACTIVITY_CASH_CM, ' ||
'     CURSOR (  ' ||
'          select  ' ||
'          rec.PAYMENT_NUMBER,  ' ||
'          rec.line_type_desc,  ' ||
'          rec.line_desc,  ' ||
'          rec.activity_desc,  ' ||
'          rec.activity_amount,  ' ||
'          rec.activity_number,  ' ||
'          to_char(rec.activity_date,''MM/DD/YYYY'') activity_date,  ' ||
'          rec.trx_currency,  ' ||
'          rec.receipt_amt_applied_from,  ' ||
'          rec.receipt_currency,  ' ||
'          rec.trx_to_receipt_rate  ' ||
'          from  ' ||
'          LNS_REC_ACT_ADJ_V rec  ' ||
'          where  ' ||
'          amv.loan_id = rec.loan_id and  ' ||
'          amv.AMORTIZATION_SCHEDULE_ID = rec.LOAN_AMORTIZATION_ID  ' ||
'     ) AS PAYMENT_ACTIVITY_ADJ ' ||
'     from  ' ||
'     LNS_AM_SCHEDS_DTL_V amv ' ||
'     where amv.loan_id = lh.LOAN_ID and  ' ||
'     amv.REVERSED_CODE = ''N'' and  ' ||
'     trunc(amv.DUE_DATE)  between dateparameters.from_dt and  dateparameters.to_dt  ' ||
') AS BILL_PAY_DTL_BY_PAY_NUM, ' ||
'CURSOR( ' ||
'    select head.DISB_HEADER_ID, ' ||
'    head.DISBURSEMENT_NUMBER, ' ||
'    to_char(head.TARGET_DATE, ''MM/DD/YYYY'') target_date, ' ||
'    to_char(head.PAYMENT_REQUEST_DATE, ''MM/DD/YYYY'') payment_request_date, ' ||
'    head.HEADER_PERCENT, ' ||
'    head.HEADER_AMOUNT, ' ||
'    fund_status.meaning status, ' ||
'    fund_act.meaning activity_name, ' ||
'    (select to_char(max(DISBURSEMENT_DATE),''MM/DD/YYYY'') from lns_disb_lines where DISB_HEADER_ID = head.DISB_HEADER_ID) DISBURSEMENT_DATE ' ||
'    from lns_disb_headers head, ' ||
'    lns_lookups fund_status, ' ||
'    lns_lookups fund_act ' ||
'    where head.loan_id = lh.loan_id and ' ||
'    fund_status.lookup_type(+) = ''FUNDING_STATUS'' and ' ||
'    fund_status.lookup_code(+) = head.STATUS and ' ||
'    fund_act.lookup_type(+) = ''DISB_ACTIVITY'' and ' ||
'    fund_act.lookup_code(+) = head.ACTIVITY_CODE) ' ||
'AS Disbursement_Schedule ' ||
'from   ' ||
'lns_loan_headers_all lh,   ' ||
'(select lns_rep_utils.get_bill_due_date_from() from_dt,  ' ||
'        lns_rep_utils.get_bill_due_date_to() to_dt  ' ||
' from   dual) dateparameters,  ' ||
'hz_parties hp,  ' ||
'lns_lookups llk,  ' ||
'LNS_PAY_SUM_V pay,  ' ||
'hz_cust_accounts_all account,  ' ||
'hz_locations loc,   ' ||
'fnd_territories_vl terr,  ' ||
'hz_party_sites site,  ' ||
'hz_cust_acct_sites_all acct_site, ' ||
'lns_loan_products_vl product, ' ||
'xle_entity_profiles le, ' ||
'hr_operating_units ou, ' ||
'lns_loan_types_vl lot ' ||
'where   ' ||
'lh.primary_borrower_id = hp.party_id and  ' ||
'lh.loan_id = pay.loan_id and  ' ||
'llk.lookup_code = lh.loan_status and  ' ||
'llk.lookup_type = ''LOAN_STATUS'' and  ' ||
'lh.loan_status <> ''DELETED'' and  ' ||
'lh.CUST_ACCOUNT_ID = account.CUST_ACCOUNT_ID and  ' ||
'acct_site.cust_acct_site_id = lh.bill_to_acct_site_id and   ' ||
'acct_site.org_id = lh.org_id and   ' ||
'site.party_site_id = acct_site.party_site_id and   ' ||
'site.location_id = loc.location_id and   ' ||
'loc.country = terr.TERRITORY_CODE and  ' ||
'lh.loan_class_code = :LOAN_CLASS and  ' ||
'lh.loan_type_id = :LOAN_TYPE_ID and  ' ||
'lh.loan_currency = :CURRENCY_CODE and  ' ||
'lh.product_id = product.LOAN_PRODUCT_ID(+) and ' ||
'le.LEGAL_ENTITY_ID = lh.LEGAL_ENTITY_ID and ' ||
'ou.organization_id = lh.org_id and ' ||
'lh.org_id = :ORG_ID  and  ' ||
'lot.loan_type_id = lh.loan_type_id  and  ' ||
'EXISTS   ' ||
'	(select loan_id   ' ||
'	from lns_amortization_scheds  am  ' ||
'	where am.loan_id = lh.loan_id and  ' ||
'	(REVERSED_FLAG is null or REVERSED_FLAG = ''N'') and  ' ||
'	trunc(am.DUE_DATE) between lns_rep_utils.get_bill_due_date_from()   ' ||
'	and lns_rep_utils.get_bill_due_date_to())';
   l_temp_where_clause VARCHAR2(200);
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   l_loan_type_id := loan_type_id;
   l_legal_entity_id := legal_entity_id;
   g_bill_due_date_from := trunc(fnd_date.canonical_to_date(bill_due_date_from));
   g_bill_due_date_to := trunc(fnd_date.canonical_to_date(bill_due_date_to));
   l_cust_account_id := cust_account_id;
   l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
   BEGIN
      SELECT loan_type_desc
      into   l_loan_type_desc
      from   lns_loan_types_vl
      where  loan_type_id = l_loan_type_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN null;
   END;
   -- Build Bind Placeholders for all non-mandatory parameters

   IF loan_number IS NOT NULL
   THEN
      l_query := l_query || ' and lh.loan_number like :LOAN_NUMBER';
   END IF;
   IF borrower_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.primary_borrower_id  = :BORROWER_ID';
   END IF;
   IF cust_account_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.cust_account_id  = :CUST_ACCOUNT_ID';
   END IF;
   IF legal_entity_id IS NOT NULL
   THEN
      l_query := l_query || ' and lh.legal_entity_id  = :LEGAL_ENTITY_ID';
   END IF;
   IF loan_assigned_to IS NOT NULL
   THEN
      l_query := l_query || ' and lh.loan_assigned_to  = :LOAN_ASSIGNED_TO';
   END IF;

   -- Start Getting Parameter Display Values
   SELECT name
   INTO   l_org_name
   FROM   HR_ALL_ORGANIZATION_UNITS_TL
   WHERE  organization_id = l_org_id
   AND language = userenv('LANG');

   IF borrower_id is NOT NULL
   THEN
      SELECT PARTY_NAME
      INTO   l_borrower_name
      FROM   hz_parties
      WHERE  party_id = borrower_id;
   END IF;

   IF cust_account_id is NOT NULL
   THEN
      SELECT account_number
      into   l_account_number
      FROM   hz_cust_accounts
      WHERE  cust_account_id =  l_cust_account_id;
   END IF;
   IF legal_entity_id is NOT NULL
   THEN
      SELECT NAME
      INTO   l_legal_entity_name
      FROM   xle_entity_profiles
      WHERE  legal_entity_id = l_legal_entity_id;
   END IF;
   IF loan_assigned_to is NOT NULL
   THEN
      SELECT source_name
      INTO   l_loan_officer
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = loan_assigned_to;
   END IF;
   ctx := DBMS_XMLQUERY.newContext(l_query);
   DBMS_XMLQuery.setRaiseNoRowsException(ctx,TRUE);
     -- Bind Mandatory Variables
     DBMS_XMLQuery.setBindValue(ctx, 'LOAN_CLASS', loan_class);
     DBMS_XMLQuery.setBindValue(ctx, 'LOAN_TYPE_ID', loan_type_id);
     DBMS_XMLQuery.setBindValue(ctx, 'CURRENCY_CODE', currency_code);
     DBMS_XMLQuery.setBindValue(ctx, 'ORG_ID', l_org_id);

     -- Bind Optional Variables if they are NOT NULL
     IF borrower_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'BORROWER_ID', borrower_id);
     END IF;
     IF loan_number is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LOAN_NUMBER', loan_number);
     END IF;
     IF cust_account_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'CUST_ACCOUNT_ID', cust_account_id);
     END IF;
     IF legal_entity_id is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LEGAL_ENTITY_ID', legal_entity_id);
     END IF;
     IF loan_assigned_to is NOT NULL
     THEN
        DBMS_XMLQuery.setBindValue(ctx, 'LOAN_ASSIGNED_TO', loan_assigned_to);
     END IF;

     -- now get the result
     BEGIN
        l_result := DBMS_XMLQUERY.getXML(ctx);
	DBMS_XMLQuery.closeContext(ctx);
	l_rows_processed := 1;
     EXCEPTION
     WHEN OTHERS THEN
        DBMS_XMLQuery.getExceptionContent(ctx,l_errNo,l_errMsg);
        IF l_errNo = 1403 THEN
           l_rows_processed := 0;
        END IF;
        DBMS_XMLQuery.closeContext(ctx);
     END;
     -- We are adding the LNSPORTFOLIO and PARAMETERS TAGs so we have
     -- to offset the first line.
     IF l_rows_processed <> 0 THEN
         l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
         tempResult       := l_result;
     ELSE
         l_resultOffset   := 0;
     END IF;

     l_new_line := '
';
   /* Prepare the tag for the report heading */
   l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<LNSRECONCILIATION>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORG_NAME>'||REPLACE_SPECIAL_CHARS(l_org_name)||'</ORG_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_CLASS_CODE>' ||REPLACE_SPECIAL_CHARS(loan_class) ||'</LOAN_CLASS_CODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_TYPE_DESC>' ||REPLACE_SPECIAL_CHARS(l_loan_type_desc) ||'</LOAN_TYPE_DESC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CURRENCY_CODE>' ||REPLACE_SPECIAL_CHARS(currency_code) ||'</CURRENCY_CODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <BILL_DUE_DATE_FROM>' || bill_due_date_from ||'</BILL_DUE_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <BILL_DUE_DATE_TO>' || bill_due_date_to ||'</BILL_DUE_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LEGAL_ENTITY_NAME>' ||REPLACE_SPECIAL_CHARS(l_legal_entity_name) ||'</LEGAL_ENTITY_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_NUMBER>' ||REPLACE_SPECIAL_CHARS(loan_number) ||'</LOAN_NUMBER>';
   l_xml_header     := l_xml_header ||l_new_line||'        <BORROWER_NAME>' ||REPLACE_SPECIAL_CHARS(l_borrower_name) ||'</BORROWER_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ACCOUNT_NUMBER>' ||l_account_number ||'</ACCOUNT_NUMBER>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_OFFICER>' ||REPLACE_SPECIAL_CHARS(l_loan_officer) ||'</LOAN_OFFICER>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_close_tag      := l_new_line||'</LNSRECONCILIATION>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result
                   ,dbms_lob.getlength(l_result)-l_resultOffset
                   ,l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
   print_clob(lob_loc => tempResult);
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' -');
      RAISE;
END PROCESS_RECON_REPORT;

PROCEDURE GEN_AGREEMENT_XML(p_AgreementXML OUT NOCOPY CLOB
                           ,p_LOAN_ID IN NUMBER
                           ,p_based_on_terms IN VARCHAR2)
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'GEN_AGREEMENT_XML';
   l_api_version           CONSTANT NUMBER := 1.0;
   ctx                     DBMS_XMLQUERY.ctxType;
   result                  CLOB;
   qryCtx                  DBMS_XMLGEN.ctxHandle;
   l_result                CLOB;
   tempResult              CLOB;
   l_version               varchar2(20);
   l_compatibility         varchar2(20);
   l_suffix                varchar2(2);
   l_majorVersion          number;
   l_resultOffset          number;
   l_xml_header            varchar2(3000);
   l_xml_header_length     number;
   l_close_tag             VARCHAR2(100);
   l_errNo                 NUMBER;
   l_errMsg                VARCHAR2(200);
   queryCtx                DBMS_XMLquery.ctxType;
   l_xml_query             VARCHAR2(32767);
   TYPE ref_cur IS REF CURSOR;
   l_xml_stmt              ref_cur;
   l_rows_processed        NUMBER;
   l_new_line              VARCHAR2(1);
   l_org_id                hr_operating_units.organization_id%TYPE;
   l_org_name              hr_operating_units.NAME%TYPE;
   l_sob_currency_code     gl_sets_of_books.CURRENCY_CODE%TYPE;
   l_amort_tbl      LNS_FINANCIALS.AMORTIZATION_TBL;
   l_return_status  VARCHAR2(10);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(32767);

   type INSTALLMENT_NUMBER_tab_t is table of lns_amort_scheds_gt.INSTALLMENT_NUMBER%TYPE
      index by pls_integer;
   v_INSTALLMENT_NUMBER INSTALLMENT_NUMBER_tab_t;
   type DUE_DATE_tab_t is table of lns_amort_scheds_gt.DUE_DATE%TYPE
      index by pls_integer;
   v_DUE_DATE DUE_DATE_tab_t;
   type PRINCIPAL_AMOUNT_tab_t is table of lns_amort_scheds_gt.PRINCIPAL_AMOUNT%TYPE
      index by pls_integer;
   v_PRINCIPAL_AMOUNT PRINCIPAL_AMOUNT_tab_t;
   type INTEREST_AMOUNT_tab_t is table of lns_amort_scheds_gt.INTEREST_AMOUNT%TYPE
      index by pls_integer;
   v_INTEREST_AMOUNT INTEREST_AMOUNT_tab_t;
   type FEE_AMOUNT_tab_t is table of lns_amort_scheds_gt.FEE_AMOUNT%TYPE
      index by pls_integer;
   v_FEE_AMOUNT FEE_AMOUNT_tab_t;
   type OTHER_AMOUNT_tab_t is table of lns_amort_scheds_gt.OTHER_AMOUNT%TYPE
      index by pls_integer;
   v_OTHER_AMOUNT OTHER_AMOUNT_tab_t;
   type BEGIN_BALANCE_tab_t is table of lns_amort_scheds_gt.BEGIN_BALANCE%TYPE
      index by pls_integer;
   v_BEGIN_BALANCE BEGIN_BALANCE_tab_t;
   type END_BALANCE_tab_t is table of lns_amort_scheds_gt.END_BALANCE%TYPE
      index by pls_integer;
   v_END_BALANCE END_BALANCE_tab_t;
   type TOTAL_tab_t is table of lns_amort_scheds_gt.TOTAL%TYPE
      index by pls_integer;
   v_TOTAL TOTAL_tab_t;
   type INTEREST_CUMULATIVE_tab_t is table of lns_amort_scheds_gt.INTEREST_CUMULATIVE%TYPE
      index by pls_integer;
   v_INTEREST_CUMULATIVE INTEREST_CUMULATIVE_tab_t;
   type PRINCIPAL_CUMULATIVE_tab_t is table of lns_amort_scheds_gt.PRINCIPAL_CUMULATIVE%TYPE
      index by pls_integer;
   v_PRINCIPAL_CUMULATIVE PRINCIPAL_CUMULATIVE_tab_t;
   type FEES_CUMULATIVE_tab_t is table of lns_amort_scheds_gt.FEES_CUMULATIVE%TYPE
      index by pls_integer;
   v_FEES_CUMULATIVE FEES_CUMULATIVE_tab_t;
   type OTHER_CUMULATIVE_tab_t is table of lns_amort_scheds_gt.OTHER_CUMULATIVE%TYPE
      index by pls_integer;
   v_OTHER_CUMULATIVE OTHER_CUMULATIVE_tab_t;
   type RATE_ID_tab_t is table of lns_amort_scheds_gt.RATE_ID%TYPE
      index by pls_integer;
   v_RATE_ID RATE_ID_tab_t;
   type SOURCE_tab_t is table of lns_amort_scheds_gt.SOURCE%TYPE
      index by pls_integer;
   v_SOURCE SOURCE_tab_t;
   type GRAND_TOTAL_FLAG_tab_t is table of lns_amort_scheds_gt.GRAND_TOTAL_FLAG%TYPE
      index by pls_integer;
   v_GRAND_TOTAL_FLAG GRAND_TOTAL_FLAG_tab_t;

--Bug5262505 --karamach
l_total_principal_balance NUMBER;
CURSOR c_get_principal_balance(pLoanId Number) IS
select pay.TOTAL_PRINCIPAL_BALANCE loan_amount
from LNS_PAY_SUM_V pay
where pay.loan_id = pLoanId;

CURSOR C_agreement (X_Loan_Id NUMBER
                   ,X_Org_Id  NUMBER
				   ,pTotalPrincipalBalance Number) IS
select sys_XMLGen(
XMLELEMENT("ROW", XMLATTRIBUTES (1 AS "num"),
                XMLFOREST (
lh.LOAN_ID,
lh.loan_number
,lh.multiple_funding_flag
,xle.name lending_org_name
,hp.party_name borrower_name
,(lh.REQUESTED_AMOUNT + lh.ADD_REQUESTED_AMOUNT) loan_requested_amount
,lh.LOAN_CURRENCY
,llklc.meaning LOAN_CLASS
,llt.loan_type_name LOAN_TYPE
,to_char(lh.LOAN_APPLICATION_DATE, 'MM/DD/YYYY') LOAN_APPLICATION_DATE
,to_char(lh.LOAN_START_DATE, 'MM/DD/YYYY') LOAN_START_DATE
,lh.loan_term || ' ' || llktt.meaning loan_term
,ratesch.current_interest_rate initial_interest_rate
,to_char(t.first_payment_date, 'MM/DD/YYYY') payment_start_date
,t.loan_payment_frequency payment_frequency_code
,llkfq.meaning payment_frequency
, llkrt.meaning interest_type
,res.source_name loan_officer
,llkst.meaning loan_subtype
,nvl(lh.collateral_percent,0) COLLATERAL_PERCENTAGE
,llkp.meaning loan_purpose
,intrt.interest_rate_name index_name
,llkdc.meaning day_count_method
,llkic.meaning interest_calculation_method
,t.calculation_method int_calc_method_code
,t.day_count_method day_count_method_code
,t.delinquency_threshold_amount delinquency_overdue_amount
,nvl(t.reamortize_over_payment,'N') reamortize_over_payment
,t.ceiling_rate
,t.floor_rate
,to_char(t.lock_in_date,'MM/DD/YYYY') lock_in_date
,to_char(t.lock_to_date,'MM/DD/YYYY') lock_expiration_date
,llkfqf.meaning floating_frequency
,llkfqf.meaning open_payment_frequency
,to_char(t.open_first_payment_date,'MM/DD/YYYY') open_first_payment_date
,to_char(ldh.target_date,'MM/DD/YYYY') first_disbursement_date
,ldh.header_percent first_disbursement_percent
,ldh.header_amount first_disbursement_amount
,lh.open_to_term_flag
,decode(nvl(lh.open_to_term_flag,'N'),'Y','with','without') open_to_term_str
,nvl(lh.funded_amount,lh.requested_amount) * nvl(lh.collateral_percent,0)
       / 100 collateral_required
,lh.collateral_percent loan_to_value_ratio
,lh.loan_status
--,pay.TOTAL_PRINCIPAL_BALANCE loan_amount --Bug5262505
,pTotalPrincipalBalance loan_amount
,lh.loan_description
,to_char(lh.loan_maturity_date, 'MM/DD/YYYY') loan_maturity_date
,lh.ORG_ID
,lh.LOAN_TYPE LOAN_TYPE_CODE
,lh.LOAN_CLASS_CODE
,LNS_FINANCIALS.getActiveRate(lh.LOAN_ID) current_interest_rate
,lh.LOAN_SUBTYPE
,lh.LAST_BILLED_DATE
,to_char(lh.LOAN_APPROVAL_DATE, 'MM/DD/YYYY') LOAN_APPROVAL_DATE
,loc.address1 || ' ' || loc.city || ' ' || loc.state || ' ' ||
loc.postal_code || ' ' || terr.TERRITORY_SHORT_NAME primary_borrower_addr
,xle.ADDRESS_LINE_1 || ' ' || xle.ADDRESS_LINE_2 || ' ' || xle.ADDRESS_LINE_3 || ' ' ||
xle.POSTAL_CODE || ' ' ||xle.COUNTRY Lender_address
,to_char(lh.loan_approval_date, 'MM/DD/YYYY') loan_approval_date
,lh.exchange_rate_type
,lh.exchange_rate
,to_char(lh.exchange_date, 'MM/DD/YYYY') exchange_date
,product.loan_product_name loan_product
),
-- Loan_Participants
                (select
                   XMLELEMENT("LOAN_PARTICIPANTS",
                      XMLAGG(
                        XMLELEMENT("LOAN_PARTICIPANTS_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                        party.party_name participant_name,
                                        party.JGZZ_FISCAL_CODE participant_tax_id,
                                        lkup.meaning participant_type,
                                        party.party_type participant_type_code,
                                        party.party_number participant_number,
                                        lnslkup.meaning participant_role,
                                        lp.LOAN_PARTICIPANT_TYPE participant_role_code,
                                        party.address1 || ' ' || party.address2 || ' '
					|| party.address3 || ' ' ||  party.address4 || ' '
					|| party.city || ' ' || party.state || ' ' ||
                                        party.postal_code || ' ' || party.county || ' ' ||
                                        ter.territory_short_name participant_address,
                                        party.email_address participant_email_address,
                                        party.URL participant_url,
                                        cp.raw_phone_number primary_phone_number,
                                        contact_person.party_name contact_person_name,
                                        contact_party.email_address contact_email_address,
                                        con_phone.raw_phone_number contact_phone_number
                                    )
                                )
                           )
                    )
FROM LNS_PARTICIPANTS lp, HZ_PARTIES party, AR_LOOKUPS lkup, LNS_LOOKUPS lnslkup,
     FND_TERRITORIES_TL ter, HZ_CONTACT_POINTS cp, HZ_PARTIES contact_person,
     HZ_PARTIES contact_party, HZ_CONTACT_POINTS con_phone
WHERE party.party_id =lp.HZ_PARTY_ID
AND party.party_type = lkup.lookup_code
AND lkup.lookup_type = 'PARTY_TYPE'
AND lp.LOAN_PARTICIPANT_TYPE = lnslkup.lookup_code
AND lnslkup.lookup_type = 'LNS_PARTICIPANT_TYPE'
AND party.country = ter.TERRITORY_CODE(+)
AND ter.LANGUAGE(+) = userenv('LANG')
AND party.party_id = cp.owner_table_id(+)
AND cp.owner_table_name(+) = 'HZ_PARTIES'
AND cp.contact_point_type(+) = 'PHONE'
AND cp.primary_flag(+) = 'Y'
AND contact_person.party_id(+) =lp.contact_pers_party_id
AND contact_party.party_id(+) =lp.contact_rel_party_id
AND con_phone.owner_table_name(+) = 'HZ_PARTIES'
AND con_phone.owner_table_id(+) =lp.contact_rel_party_id
AND con_phone.primary_flag(+) = 'Y'
AND con_phone.status(+) = 'A'
AND con_phone.contact_point_type(+) = 'PHONE'
AND LOAN_ID = lh.loan_id
 ), -- end of LOAN_PARTICIPANTS
-- DISB_RATE_SCHEDULE
                (select
                   XMLELEMENT("DISB_RATE_SCHEDULE",
                      XMLAGG(
                        XMLELEMENT("DISB_RATE_SCHEDULE_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       BEGIN_INSTALLMENT_NUMBER installment_from
                                       ,END_INSTALLMENT_NUMBER installment_to
                                       ,to_char(index_date, 'MM/DD/YYYY') index_date
                                       ,current_interest_rate interest_rate
                                    )
                                )
                           )
                    )
from lns_rate_schedules rsh
where rsh.term_id = t.term_id
and   rsh.end_date_active is null
and   nvl(rsh.phase,'TERM') = 'OPEN'
 ), -- end of DISB_RATE_SCHEDULE
-- RATE_SCHEDULE
                (select
                   XMLELEMENT("RATE_SCHEDULE",
                      XMLAGG(
                        XMLELEMENT("RATE_SCHEDULE_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       BEGIN_INSTALLMENT_NUMBER installment_from
                                       ,END_INSTALLMENT_NUMBER installment_to
                                       ,to_char(index_date, 'MM/DD/YYYY') index_date
                                       ,current_interest_rate interest_rate
                                    )
                                )
                           )
                    )
from lns_rate_schedules rsh
where rsh.term_id = t.term_id
and   rsh.end_date_active is null
and   nvl(rsh.phase,'TERM') = 'TERM'
 ), -- end of RATE_SCHEDULE
-- COLLATERAL
                (select
                   XMLELEMENT("COLLATERAL",
                      XMLAGG(
                        XMLELEMENT("COLLATERAL_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                        assetassign.PLEDGED_AMOUNT,
                                        assetassign.START_DATE_ACTIVE,
                                        assetassign.END_DATE_ACTIVE,
                                        lkps1.meaning participant_role,
                                        party.party_name participant_name,
                                        lkps2.meaning asset_class,
                                        lkps3.meaning asset_type,
                                        asset.quantity || ' ' || lkps4.meaning asset_quantity,
                                        lkps5.meaning || ': ' || asset.reference_name reference,
                                        asset.appraiser_name,
                                        asset.next_evaluation_date,
                                        lkps6.meaning valuation_method,
                                        asset.lien_amount,
                                        asset.description, asset.currency_code,
                                        asset.valuation, asset.start_date_active acquired_date
                                    )
                                )
                           )
                    )
FROM LNS_ASSET_ASSIGNMENTS assetassign,
LNS_ASSETS asset,
LNS_LOOKUPS lkps1,
LNS_LOOKUPS lkps2,
LNS_LOOKUPS lkps3,
LNS_LOOKUPS lkps4,
LNS_LOOKUPS lkps5,
LNS_LOOKUPS lkps6,
HZ_PARTIES party,
LNS_PARTICIPANTS par
WHERE assetassign.asset_id = asset.asset_id and
asset.asset_owner_id = par.hz_party_id and
party.party_id = par.hz_party_id and
assetassign.loan_id = par.loan_id and
par.loan_participant_type = lkps1.lookup_code and
lkps1.lookup_type = 'LNS_PARTICIPANT_TYPE' and
asset.asset_class_code = lkps2.lookup_code and
lkps2.lookup_type = 'ASSET_CLASSES' and
asset.asset_type_code = lkps3.lookup_code and
lkps3.lookup_type = asset.asset_class_code and
asset.uom_code = lkps4.lookup_code and
lkps4.lookup_type = 'ASSET_QNT_'||asset.asset_class_code and
asset.reference_type = lkps5.lookup_code and
lkps5.lookup_type = 'ASSET_REF_'||asset.asset_class_code and
asset.valuation_method_code = lkps6.lookup_code and
lkps6.lookup_type = 'VALUATION_METHOD' and
assetassign.loan_id = lh.loan_id
 ), -- end of COLLATERAL
-- FEES
                (select
                   XMLELEMENT("FEES",
                      XMLAGG(
                        XMLELEMENT("FEES_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                        lfa.FEE, lfa.FEE_TYPE, lfa.FEE_BASIS, lfa.RATE_TYPE,
                                        lfa.BILLING_OPTION BILLING_OPTION_CODE,
                                        llkbo.meaning BILLING_OPTION,
                                        lf.FEE_NAME,
                                        lf.FEE_CATEGORY FEE_CATEGORY_CODE,
                                        llkfc.meaning FEE_CATEGORY,
                                        lf.rate_type method_code,
                                        llkrt.meaning Fee_method,
                                        fl.meaning update_allowed,
                                        lf.FEE_DESCRIPTION,
                                        decode(lf.RATE_TYPE, 'FIXED',
					 to_char(lf.FEE,FND_CURRENCY.SAFE_GET_FORMAT_MASK
                                            (nvl(lf.CURRENCY_CODE,'USD'),25))
					, to_char(lf.FEE) || '%' ||
                                          decode(lf.FEE_BASIS, null, '', ', ')
					   || lkps1.meaning) FEE_VAR_AMOUNT_PERCENT
                                    )
                                )
                           )
                    )
FROM LNS_FEE_ASSIGNMENTS lfa, LNS_FEES_ALL lf, LNS_LOOKUPS lkps1,
LNS_LOOKUPS llkbo,
LNS_LOOKUPS llkrt,
LNS_LOOKUPS llkfc,
fnd_lookups fl
WHERE lfa.FEE_ID = lf.FEE_ID AND
lfa.loan_id = lh.loan_id and
llkfc.lookup_type = 'FEE_CATEGORY' and
llkfc.lookup_code = lf.fee_category and
lkps1.lookup_code(+) = lf.FEE_BASIS AND lkps1.lookup_type(+) = 'FEE_BASIS' and
llkbo.lookup_code(+) = lf.BILLING_OPTION AND
llkbo.lookup_type(+) = 'FEE_BILLING_OPTIONS' AND
llkrt.lookup_code(+) = lf.RATE_TYPE AND llkrt.lookup_type(+) = 'RATE_TYPE' AND
fl.lookup_code(+) = lf.FEE_EDITABLE_FLAG AND fl.lookup_type(+) = 'YES_NO'
 ), -- end of FEES
-- CONDITIONS
                (select
                   XMLELEMENT("CONDITIONS",
                      XMLAGG(
                        XMLELEMENT("CONDITIONS_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       lc.CONDITION_NAME,
                                       lca.CONDITION_DESCRIPTION,
                                       lc.CONDITION_TYPE CONDITION_TYPE_CODE,
                                       lkps1.meaning CONDITION_TYPE, fl.meaning MANDATORY_FLAG
                                    )
                                )
                           )
                    )
FROM LNS_COND_ASSIGNMENTS_VL lca, LNS_CONDITIONS_VL lc,
LNS_LOOKUPS lkps1 , fnd_lookups fl
WHERE lca.CONDITION_ID = lc.CONDITION_ID
AND lkps1.lookup_type = 'CONDITION_TYPE'
AND lkps1.lookup_code = lc.CONDITION_TYPE
AND fl.lookup_type = 'YES_NO'
AND fl.lookup_code = lca.MANDATORY_FLAG
AND nvl(lca.start_date_active, sysdate) <= sysdate
AND nvl(lca.end_date_active, sysdate) >= sysdate
AND lca.LOAN_ID = lh.loan_id
 ), -- end of CONDITIONS
-- ORIGINAL_RECEIVABLES
                (select
                   XMLELEMENT("ORIGINAL_RECEIVABLES",
                      XMLAGG(
                        XMLELEMENT("ORIGINAL_RECEIVABLES_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       lll.REFERENCE_NUMBER original_rec_number,
                                       lll.REFERENCE_AMOUNT original_rec_balance,
                                       lll.REQUESTED_AMOUNT loan_requested_amount,
                                       lll.REFERENCE_NUMBER original_rec_desc,
                                       to_char(cust_trx.term_due_date,'MM/DD/YYYY')
				                                       INVOICE_DUE_DATE,
                                       trx_type.name || ' - ' || trx_type_lkup.meaning
				                                       inv_trx_type
                                    )
                                )
                           )
                    )
from LNS_LOAN_LINES lll,
RA_CUSTOMER_TRX_ALL cust_trx,
RA_CUST_TRX_TYPES_ALL trx_type,
ar_lookups trx_type_lkup
where lll.loan_id = lh.LOAN_ID and
lll.end_date is null and
cust_trx.cust_trx_type_id = trx_type.CUST_TRX_TYPE_ID and
trx_type.org_id = lh.org_id and
trx_type_lkup.lookup_type = 'INV/CM' and
trx_type_lkup.lookup_code = trx_type.type and
cust_trx.customer_trx_id = lll.reference_id
 ), -- end of ORIGINAL_RECEIVABLES
-- DISBURSEMENTS
                (select
                   XMLELEMENT("DISBURSEMENTS",
                      XMLAGG(
                        XMLELEMENT("DISBURSEMENTS_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       disbursement_number
                                       ,llkac.meaning disbursement_activity
                                       ,to_char(ldih.target_date,'MM/DD/YYYY') target_date
                                       ,ldih.header_percent disbursement_percent
                                       ,ldih.header_amount amount_of_disbursement
                                    ),
-- PAYEES
                (select
                   XMLELEMENT("PAYEES",
                      XMLAGG(
                        XMLELEMENT("PAYEES_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                                       party.party_name payee_name
                                       ,party.ADDRESS1 || ' ' || party.ADDRESS2 || ' ' ||
                                        party.ADDRESS3 || ' ' || party.STATE || ' ' ||
                                        party.POSTAL_CODE || ' ' ||party.COUNTRY payee_address
                                       ,ibypm.payment_method_name
                                       ,line_percent payee_percent
                                       ,line_amount payee_amount
                                    )
                                )
                           )
                    )
                 from   lns_disb_lines ldl
                       ,hz_parties party
                       ,IBY_PAYMENT_METHODS_TL ibypm
                 where  ldl.disb_header_id = ldih.disb_header_id
                 and    party.party_id = ldl.payee_party_id and
                 ibypm.payment_method_code (+) = ldl.payment_method_code and
                 ibypm.LANGUAGE (+) = userenv('LANG')
 ),-- end of PAYEES
-- DISBFEES
                (select
                   XMLELEMENT("DISBFEES",
                      XMLAGG(
                        XMLELEMENT("DISBFEES_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                 lfa.FEE, lfa.FEE_TYPE,
                 lfa.FEE_BASIS,
                 lfa.RATE_TYPE,
                 lfa.BILLING_OPTION BILLING_OPTION_CODE,
                 llkbo.meaning BILLING_OPTION,
                 lf.FEE_NAME,
                 lf.FEE_CATEGORY FEE_CATEGORY_CODE,
                 llkfc.meaning FEE_CATEGORY,
                 lf.rate_type method_code,
                 llkrt.meaning Fee_method,
                 fl.meaning update_allowed,
                 lf.FEE_DESCRIPTION,
                 decode(lf.RATE_TYPE, 'FIXED', to_char(lf.FEE,FND_CURRENCY.SAFE_GET_FORMAT_MASK
                     (nvl(lf.CURRENCY_CODE,'USD'),25)), to_char(lf.FEE) || '%' ||
                     decode(lf.FEE_BASIS, null, '', ', ') || lkps1.meaning)
		                                           FEE_VAR_AMOUNT_PERCENT
                                                     )
                                                 )
                                            )
                                     )
                 FROM LNS_FEE_ASSIGNMENTS lfa,
                      LNS_FEES_ALL lf,
                      LNS_LOOKUPS lkps1,
                      LNS_LOOKUPS llkbo,
                      LNS_LOOKUPS llkrt,
                      LNS_LOOKUPS llkfc,
                      fnd_lookups fl
                 WHERE lfa.FEE_ID = lf.FEE_ID AND
                      lfa.disb_header_id = ldih.disb_header_id and
                      llkfc.lookup_type = 'FEE_CATEGORY' and
                      llkfc.lookup_code = lf.fee_category and
                      lkps1.lookup_code(+) = lf.FEE_BASIS AND lkps1.lookup_type(+) = 'FEE_BASIS' and
                      llkbo.lookup_code(+) = lf.BILLING_OPTION AND
                      llkbo.lookup_type(+) = 'FEE_BILLING_OPTIONS' AND
                      llkrt.lookup_code(+) = lf.RATE_TYPE AND llkrt.lookup_type(+) = 'RATE_TYPE' AND
                      fl.lookup_code(+) = lf.FEE_EDITABLE_FLAG AND fl.lookup_type(+) = 'YES_NO'
 ), -- end of DISBFEES
-- DISBCOND
                (select
                   XMLELEMENT("DISBCOND",
                      XMLAGG(
                        XMLELEMENT("DISBCOND_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                        lc.CONDITION_NAME,
                        lca.CONDITION_DESCRIPTION,
                        lc.CONDITION_TYPE CONDITION_TYPE_CODE,
                        lkps1.meaning CONDITION_TYPE, fl.meaning MANDATORY_FLAG
                                    )
                                )
                           )
                    )
                 FROM LNS_COND_ASSIGNMENTS_VL lca, LNS_CONDITIONS_VL lc,
                 LNS_LOOKUPS lkps1 , fnd_lookups fl
                 WHERE lca.CONDITION_ID = lc.CONDITION_ID
                       AND lkps1.lookup_type = 'CONDITION_TYPE'
                       AND lkps1.lookup_code = lc.CONDITION_TYPE
                       AND fl.lookup_type = 'YES_NO'
                       AND fl.lookup_code = lca.MANDATORY_FLAG
                       AND nvl(lca.start_date_active, sysdate) <= sysdate
                       AND nvl(lca.end_date_active, sysdate) >= sysdate
                       AND lca.disb_header_id = ldih.disb_header_id
 ) -- end of DISBCOND
                                )
                           )
                    )
FROM lns_disb_headers ldih
,lns_lookups llkac
WHERE ldih.loan_id = lh.loan_id and
llkac.lookup_code = ldih.activity_code
 ), -- end of DISBURSEMENTS
-- AMORTIZATION
                (select
                   XMLELEMENT("AMORTIZATION",
                      XMLAGG(
                        XMLELEMENT("AMORTIZATION_ROW", XMLATTRIBUTES (rownum AS "num"),
                            XMLFOREST(
                        INSTALLMENT_NUMBER PAYMENT_NUMBER
                        ,to_char(DUE_DATE, 'MM/DD/YYYY') DUE_DATE
                        ,PRINCIPAL_AMOUNT PAYMENT_PRINCIPAL
                        ,INTEREST_AMOUNT PAYMENT_INTEREST
                        ,FEE_AMOUNT PAYMENT_FEES
                        ,(PRINCIPAL_AMOUNT+INTEREST_AMOUNT+FEE_AMOUNT) PAYMENT_TOTAL
                        ,OTHER_AMOUNT
                        ,BEGIN_BALANCE BEGINNING_BALANCE
                        ,END_BALANCE ENDING_BALANCE
                        ,INTEREST_CUMULATIVE
                        ,PRINCIPAL_CUMULATIVE
                        ,FEES_CUMULATIVE
                        ,OTHER_CUMULATIVE
                        ,SOURCE
                                    )
                                )
                           )
                    )
                  FROM lns_amort_scheds_gt agt
                  where agt.loan_id = lh.loan_id
 ) -- end of AMORTIZATION
 ), XMLFormat.createformat('ROWSET')).getClobVal()
from
lns_loan_headers_all lh,
hz_parties hp,
lns_terms t,
lns_int_rate_headers intrt,
lns_rate_schedules ratesch,
hz_locations loc,
fnd_territories_tl terr,
hz_party_sites site,
hz_cust_acct_sites_all acct_site,
--LNS_PAY_SUM_V pay, --Bug5262505
xle_firstparty_information_v xle,
lns_lookups llkrt,
lns_lookups llktt,
lns_loan_types_vl llt,
lns_lookups llklc,
lns_lookups llkp,
lns_lookups llkst,
lns_lookups llkdc,
lns_lookups llkfq,
lns_lookups llkfqf,
lns_lookups llkic,
jtf_rs_resource_extns res,
lns_disb_headers ldh,
lns_loan_products_all_vl product
where
lh.primary_borrower_id = hp.party_id and
--lh.loan_id = pay.loan_id and --Bug5262505
lh.loan_id = t.loan_id and
ldh.loan_id(+) = lh.loan_id and
ldh.disbursement_number(+) = 1 and
product.loan_product_id(+) = lh.product_id and
t.term_id = ratesch.term_id and
ratesch.begin_installment_number = 1 and
ratesch.end_date_active is null and
((lh.multiple_funding_flag = 'Y' and lh.open_to_term_flag = 'N' and
ratesch.phase = 'OPEN') OR ( ratesch.phase = 'TERM')) and
intrt.interest_rate_id = t.index_rate_id and
xle.legal_entity_id = lh.legal_entity_id and
llktt.lookup_code = lh.loan_term_period and
llktt.lookup_type = 'PERIOD' and
llkrt.lookup_code = t.rate_type and
llkrt.lookup_type = 'RATE_TYPE' and
llkic.lookup_code = t.calculation_method and
llkic.lookup_type = 'INTEREST_CALCULATION_METHOD' and
llklc.lookup_code = lh.loan_class_code and
llklc.lookup_type = 'LOAN_CLASS' and
llt.loan_type_id = lh.loan_type_id and
llkdc.lookup_code = t.day_count_method and
llkdc.lookup_type = 'DAY_COUNT_METHOD' and
llkp.lookup_code (+) = lh.loan_purpose_code and
llkp.lookup_type (+) = 'LOAN_PURPOSE' and
llkst.lookup_code (+) = lh.loan_subtype and
llkst.lookup_type (+) = 'LOAN_SUBTYPE' and
lh.loan_assigned_to = res.resource_id and
llkfq.lookup_code (+) = t.loan_payment_frequency and
llkfq.lookup_type (+) = 'FREQUENCY' and
llkfqf.lookup_code (+) = t.open_payment_frequency and
llkfqf.lookup_type (+) = 'FREQUENCY' and
res.category = 'EMPLOYEE' and
lh.loan_status <> 'DELETED' and
acct_site.cust_acct_site_id = lh.bill_to_acct_site_id and
acct_site.org_id = lh.org_id and
site.party_site_id = acct_site.party_site_id and
site.location_id = loc.location_id and
loc.country = terr.TERRITORY_CODE and
terr.language = userenv('LANG') and
lh.loan_id = X_Loan_Id and
lh.org_id = X_Org_Id;
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'org_id =  ' || l_org_id);
   lns_financials.runAmortization(p_api_version => 1.0
                                     ,p_init_msg_list  => 'T'
                                     ,p_commit         => 'F'
                                     ,p_loan_ID        => p_loan_id
                                     ,p_based_on_terms => p_based_on_terms --'CURRENT'
                                     ,x_amort_tbl      => l_amort_tbl
                                     ,x_return_status  => l_return_Status
                                     ,x_msg_count      => l_msg_count
                                     ,x_msg_data       => l_msg_data);
   LogMessage(FND_LOG.LEVEL_STATEMENT, 'Returned amortization schedule count: ' || l_amort_tbl.count);


   FOR j in 1..l_amort_tbl.count
   LOOP
      v_INSTALLMENT_NUMBER(j) := l_amort_tbl(j).INSTALLMENT_NUMBER;
      v_DUE_DATE(j) := l_amort_tbl(j).DUE_DATE;
      v_PRINCIPAL_AMOUNT(j) := l_amort_tbl(j).PRINCIPAL_AMOUNT;
      v_INTEREST_AMOUNT(j) := l_amort_tbl(j).INTEREST_AMOUNT;
      v_FEE_AMOUNT(j) := l_amort_tbl(j).FEE_AMOUNT;
      v_OTHER_AMOUNT(j) := l_amort_tbl(j).OTHER_AMOUNT;
      v_BEGIN_BALANCE(j) := l_amort_tbl(j).BEGIN_BALANCE;
      v_END_BALANCE(j) := l_amort_tbl(j).END_BALANCE;
      v_TOTAL(j) := l_amort_tbl(j).TOTAL;
      v_INTEREST_CUMULATIVE(j) := l_amort_tbl(j).INTEREST_CUMULATIVE;
      v_PRINCIPAL_CUMULATIVE(j) := l_amort_tbl(j).PRINCIPAL_CUMULATIVE;
      v_FEES_CUMULATIVE(j) := l_amort_tbl(j).FEES_CUMULATIVE;
      v_OTHER_CUMULATIVE(j) := l_amort_tbl(j).OTHER_CUMULATIVE;
      v_RATE_ID(j) := l_amort_tbl(j).RATE_ID;
      v_SOURCE(j) := l_amort_tbl(j).SOURCE;
      v_GRAND_TOTAL_FLAG(j) := l_amort_tbl(j).GRAND_TOTAL_FLAG;
   END LOOP;

   LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting into lns_amort_scheds_gt...');
   IF  (v_INSTALLMENT_NUMBER.first iS NOT NULL) THEN
   FORALL j in v_INSTALLMENT_NUMBER.first..v_INSTALLMENT_NUMBER.last
   insert into lns_amort_scheds_gt
   (
    LOAN_ID
   ,INSTALLMENT_NUMBER
   ,DUE_DATE
   ,PRINCIPAL_AMOUNT
   ,INTEREST_AMOUNT
   ,FEE_AMOUNT
   ,OTHER_AMOUNT
   ,BEGIN_BALANCE
   ,END_BALANCE
   ,TOTAL
   ,INTEREST_CUMULATIVE
   ,PRINCIPAL_CUMULATIVE
   ,FEES_CUMULATIVE
   ,OTHER_CUMULATIVE
   ,RATE_ID
   ,SOURCE
   ,GRAND_TOTAL_FLAG
   )
   VALUES (
    p_loan_id
   ,v_INSTALLMENT_NUMBER(j)
   ,v_DUE_DATE(j)
   ,v_PRINCIPAL_AMOUNT(j)
   ,v_INTEREST_AMOUNT(j)
   ,v_FEE_AMOUNT(j)
   ,v_OTHER_AMOUNT(j)
   ,v_BEGIN_BALANCE(j)
   ,v_END_BALANCE(j)
   ,v_TOTAL(j)
   ,v_INTEREST_CUMULATIVE(j)
   ,v_PRINCIPAL_CUMULATIVE(j)
   ,v_FEES_CUMULATIVE(j)
   ,v_OTHER_CUMULATIVE(j)
   ,v_RATE_ID(j)
   ,v_SOURCE(j)
   ,v_GRAND_TOTAL_FLAG(j)
   );
   end IF;

   -- Start Getting Parameter Display Values
   SELECT hou.name, gsb.currency_code
   INTO   l_org_name,
          l_sob_currency_code
   FROM   hr_operating_units hou,
          gl_sets_of_books gsb
   WHERE  hou.organization_id = l_org_id
   AND    gsb.set_of_books_id = hou.set_of_books_id;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Opening c_get_principal_balance');
   open c_get_principal_balance(p_loan_id);
   fetch c_get_principal_balance into l_total_principal_balance;
   close c_get_principal_balance;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Opening C_agreement');
   OPEN   C_agreement(X_Loan_Id => p_loan_id,
                    X_Org_Id  => l_org_id,
					pTotalPrincipalBalance => l_total_principal_balance);
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Fetching  C_agreement');
   FETCH  C_agreement INTO l_result;
   IF     C_agreement%ROWCOUNT <> 0
   THEN
     l_rows_processed := 1;
   END IF;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'C_agreement%ROWCOUNT ' || C_agreement%ROWCOUNT);
   CLOSE C_agreement;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'l_rows_processed ' || l_rows_processed);
     -- We are adding the LNSAGREEMENT and PARAMETERS TAGs so we have
     -- to offset the first line.
     IF l_rows_processed <> 0 THEN
         l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
     ELSE
         l_resultOffset   := 0;
     END IF;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'l_resultOffset  ' || l_resultOffset);

     l_new_line := '
';
   /* Prepare the tag for the report heading */
   l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<LNSAGREEMENT>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORG_NAME>'||REPLACE_SPECIAL_CHARS(l_org_name)||'</ORG_NAME>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SET_OF_BOOKS_CURRENCY_CODE>'||REPLACE_SPECIAL_CHARS(l_sob_currency_code)||'</SET_OF_BOOKS_CURRENCY_CODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <LOAN_ID>' ||p_loan_id ||'</LOAN_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_close_tag      := l_new_line||'</LNSAGREEMENT>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, ' l_xml_header_length  ' || l_xml_header_length);
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);

      LogMessage(FND_LOG.LEVEL_PROCEDURE, ' before dbms_lob.copy  ' );
      dbms_lob.copy(tempResult,l_result
                   ,dbms_lob.getlength(l_result)-l_resultOffset
                   ,l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
   p_AgreementXML := tempResult;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION

   WHEN OTHERS THEN
      RAISE;
END GEN_AGREEMENT_XML;
PROCEDURE CLOB_TO_FILE( p_clob IN CLOB )
IS
  l_clob_size   NUMBER;
  l_offset      NUMBER;
  l_res_offset  NUMBER;
  l_chunk_size  INTEGER;
  l_chunk_limit_size  INTEGER;
  l_chunk       VARCHAR2(32767);
  l_new_line              VARCHAR2(1);
  l_api_name              CONSTANT VARCHAR2(30) := 'CLOB_TO_FILE';

BEGIN

  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
  -- get length of internal lob and open the dest. file.
  l_clob_size := dbms_lob.getlength(p_clob);

  IF (l_clob_size = 0) THEN
    LogMessage(FND_LOG.LEVEL_PROCEDURE,'CLOB is empty');
    RETURN;
  END IF;

  l_offset     := 1;
  l_chunk_size := 3000;
  l_chunk_limit_size := l_chunk_size;

  -- To get the maximum value which should be multiple of l_chunk_size and also less than 32767
  WHILE(l_chunk_limit_size < 32767)
  LOOP
    l_chunk_limit_size := l_chunk_limit_size + l_chunk_size;
  END  LOOP;
  l_chunk_limit_size := l_chunk_limit_size - l_chunk_size;

  LogMessage(FND_LOG.LEVEL_PROCEDURE,'chunk limit size is '||l_chunk_limit_size);

     l_new_line := '
';

  LogMessage(FND_LOG.LEVEL_PROCEDURE,'Unloading... '  || l_clob_size);

  WHILE (l_clob_size > 0) LOOP

    -- LogMessage(FND_LOG.LEVEL_PROCEDURE,'Off Set: ' || l_offset);

    l_chunk := dbms_lob.substr (p_clob, l_chunk_size, l_offset);

     --LogMessage(FND_LOG.LEVEL_PROCEDURE,'Off Set: ' || l_offset);
     --LogMessage(FND_LOG.LEVEL_PROCEDURE,'l_chunk ' || l_chunk);

    -- There should be one new line character(chr(10)) for every 32k when
    -- writing into the file using 'utl_file' package.

     if((mod(l_offset,l_chunk_limit_size) = 1) AND (l_offset <> 1)) then
     LogMessage(FND_LOG.LEVEL_PROCEDURE,'Reached into the Limit Size');

      -- Inserting new line character(chr(10)) after the first appearing
      -- closing XML tag
      l_res_offset := instr(l_chunk,'>');

      LogMessage(FND_LOG.LEVEL_PROCEDURE,'result Offset is '||l_res_offset);

      if(l_res_offset > 0) then
        l_chunk := substr(l_chunk,1,l_res_offset)||l_new_line||substr(l_chunk,(l_res_offset+1),length(l_chunk));
      end if;
     end if;

    fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk);

    l_clob_size := l_clob_size - l_chunk_size;
    l_offset := l_offset + l_chunk_size;

  END LOOP;

  fnd_file.new_line(fnd_file.output,1);
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

EXCEPTION
  WHEN OTHERS THEN
    LogMessage(FND_LOG.LEVEL_PROCEDURE,'EXCEPTION: OTHERS clob_to_file');
    LogMessage(FND_LOG.LEVEL_PROCEDURE,sqlcode);
    LogMessage(FND_LOG.LEVEL_PROCEDURE,sqlerrm);
    RAISE;

END;

-- Bug#6169438, Added new parameter P_GENERATE_AGREEMENT which forces the API to regenerate the loan
-- agreement ,if the value is 'Y',  and also create the history record in loans schema.

PROCEDURE PROCESS_AGREEMENT_REPORT(ERRBUF                  OUT NOCOPY VARCHAR2
                                  ,RETCODE                 OUT NOCOPY VARCHAR2
                                  ,LOAN_ID                 IN         NUMBER
                                  ,P_GENERATE_AGREEMENT      IN         VARCHAR2 DEFAULT 'N'
				  ,P_REASON                IN         VARCHAR2 DEFAULT NULL
				  ) IS
   l_api_name              CONSTANT VARCHAR2(30) := 'PROCESS_AGREEMENT_REPORT';
   l_api_version           CONSTANT NUMBER := 1.0;
   l_result_xml            CLOB;
   l_loan_id               LNS_LOAN_HEADERS_ALL.LOAN_ID%TYPE;
   l_loan_status           LNS_LOAN_HEADERS_ALL.LOAN_STATUS%TYPE;
   l_document_id           LNS_LOAN_DOCUMENTS.DOCUMENT_ID%TYPE;
   l_version               LNS_LOAN_DOCUMENTS.VERSION%TYPE := -1;
   l_reason                LNS_LOAN_DOCUMENTS.REASON%TYPE;
   l_object_version_number NUMBER;
   l_count                 NUMBER;
   l_agreement_exist_flag  VARCHAR2(1) := 'Y';

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    l_loan_id := LOAN_ID;

    select lh.loan_status into l_loan_status
    from lns.lns_loan_headers_all lh
    where lh.loan_id = l_loan_id;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Id = ' || LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'REASON = ' || P_REASON);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_STATUS =  ' || l_loan_status);

    IF (l_loan_status <> 'DELETED' AND l_loan_status <> 'PAIDOFF' AND l_loan_status <> 'REJECTED') THEN

        select max(version) into l_version
        from   lns_loan_documents
        where  source_table = 'LNS_LOAN_HEADERS_ALL'
        and    source_id = l_loan_id
        and    document_type = 'LOAN_AGREEMENT';

        IF (l_version is null or l_version = 0 or l_loan_status = 'INCOMPLETE' or l_loan_status = 'PENDING') then
            l_version := 1;
            l_object_version_number := 1;
        else
            l_version := l_version+1;
            l_object_version_number := l_version;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Version = ' || l_version);

        IF(P_REASON IS NULL OR P_REASON = '') THEN
            -- Retrieve default agreement reason
            FND_MESSAGE.SET_NAME('LNS', 'LNS_ORIG_AGR_REASON');
            FND_MSG_PUB.Add;
            l_reason := FND_MSG_PUB.Get(p_encoded => 'F');
            FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);
        ELSE
            l_reason := P_REASON;
        END IF;

        IF(l_loan_status = 'INCOMPLETE' or l_loan_status = 'PENDING') THEN

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generating agreement report1...in process agreement report');
            GEN_AGREEMENT_XML(p_AgreementXML=> l_result_xml,
                                p_loan_id => l_loan_id,
                                p_based_on_terms => 'ORIGINAL');

            select  count(*) into l_count
            from lns_loan_documents
            where source_id = l_loan_id;

            IF(l_count = 0) THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT,'For incomplete loan, inserting loan agreement for first time');
                LNS_LOAN_DOCUMENTS_PKG.Insert_Row(X_DOCUMENT_ID => l_document_id
                                                ,P_SOURCE_ID   => l_loan_id
                                                ,P_SOURCE_TABLE =>'LNS_LOAN_HEADERS_ALL'
                                                ,P_DOCUMENT_TYPE => 'LOAN_AGREEMENT'
                                                ,P_VERSION       => l_version
                                                ,P_DOCUMENT_XML  => l_result_xml
                                                ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                                                ,P_REASON => l_reason);
            ELSE
                LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating the existing agreement instead of creating a new record in DB');
                LNS_LOAN_DOCUMENTS_PKG.Update_Row(X_DOCUMENT_ID => l_document_id
                                                ,P_SOURCE_ID   => l_loan_id
                                                ,P_SOURCE_TABLE =>'LNS_LOAN_HEADERS_ALL'
                                                ,P_DOCUMENT_TYPE => 'LOAN_AGREEMENT'
                                                ,P_VERSION       => l_version
                                                ,P_DOCUMENT_XML  => l_result_xml
                                                ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                                                ,P_REASON => l_reason);
            END IF;

        ELSE

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generating agreement report2...in process agreement report');
            GEN_AGREEMENT_XML(p_AgreementXML=> l_result_xml,
                                p_loan_id => l_loan_id,
                                p_based_on_terms => 'CURRENT');

            LogMessage(FND_LOG.LEVEL_STATEMENT,'Creating a new Agreement record in DB');
            LNS_LOAN_DOCUMENTS_PKG.Insert_Row(X_DOCUMENT_ID => l_document_id
                                        ,P_SOURCE_ID   => l_loan_id
                                        ,P_SOURCE_TABLE =>'LNS_LOAN_HEADERS_ALL'
                                        ,P_DOCUMENT_TYPE => 'LOAN_AGREEMENT'
                                        ,P_VERSION       => l_version
                                        ,P_DOCUMENT_XML  => l_result_xml
                                        ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                                        ,P_REASON => l_reason);
        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Printing...');
        clob_to_file(l_result_xml);

    ELSE
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No agreement report will be generated');
    END IF;
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' - In exception');
      RAISE;
END PROCESS_AGREEMENT_REPORT;

PROCEDURE STORE_LOAN_AGREEMENT    (P_LOAN_ID                 IN         NUMBER
				  ,P_AGREEMENT_REASON        IN         VARCHAR2 DEFAULT NULL) IS
   l_api_name              CONSTANT VARCHAR2(30) := 'STORE_LOAN_AGREEMENT_REPORT';
   l_api_version           CONSTANT NUMBER := 1.0;
   l_result_xml            CLOB;
   l_document_id           LNS_LOAN_DOCUMENTS.DOCUMENT_ID%TYPE;
   l_reason                LNS_LOAN_DOCUMENTS.REASON%TYPE;
   l_loan_status           LNS_LOAN_HEADERS_ALL.LOAN_STATUS%TYPE;
   l_version               NUMBER;
   l_object_version_number NUMBER;

   cursor csr_loan_agreement IS
   select document_xml
   from   lns_loan_documents
   where  source_table = 'LNS_LOAN_HEADERS_ALL'
   and    source_id = p_loan_id
   and    version = 1
   and    document_type = 'LOAN_AGREEMENT';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    select lh.loan_status into l_loan_status
    from lns.lns_loan_headers_all lh
    where lh.loan_id = P_LOAN_ID;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID =  ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_AGREEMENT_REASON =  ' || P_AGREEMENT_REASON);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_STATUS =  ' || l_loan_status);

    IF(P_AGREEMENT_REASON IS NULL OR P_AGREEMENT_REASON = '') THEN
        -- Retrieve default agreement reason
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ORIG_AGR_REASON');
        FND_MSG_PUB.Add;
        l_reason := FND_MSG_PUB.Get(p_encoded => 'F');
        FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);
    ELSE
        l_reason := P_AGREEMENT_REASON;
    END IF;
    l_version := 1;
    l_object_version_number := 1;

    OPEN  csr_loan_agreement;
    FETCH csr_loan_agreement
    INTO  l_result_xml;

    IF(l_loan_status = 'INCOMPLETE' or l_loan_status = 'PENDING') THEN

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generating agreement report1...');
        GEN_AGREEMENT_XML(p_AgreementXML=> l_result_xml,
                            p_loan_id => p_loan_id,
                            p_based_on_terms => 'ORIGINAL');

    ELSE

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Generating agreement report2...');
        GEN_AGREEMENT_XML(p_AgreementXML=> l_result_xml,
                            p_loan_id => p_loan_id,
                            p_based_on_terms => 'CURRENT');

    END IF;

    IF csr_loan_agreement%NOTFOUND THEN

        LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting loan agreement for first time...');
        LNS_LOAN_DOCUMENTS_PKG.Insert_Row(X_DOCUMENT_ID => l_document_id
                                        ,P_SOURCE_ID   => p_loan_id
                                        ,P_SOURCE_TABLE =>'LNS_LOAN_HEADERS_ALL'
                                        ,P_DOCUMENT_TYPE => 'LOAN_AGREEMENT'
                                        ,P_VERSION       => 1
                                        ,P_DOCUMENT_XML  => l_result_xml
                                        ,P_OBJECT_VERSION_NUMBER => 1
                                        ,P_REASON => l_reason);

    ELSE

        LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating the existing agreement...');
        LNS_LOAN_DOCUMENTS_PKG.Update_Row(X_DOCUMENT_ID => l_document_id
                                        ,P_SOURCE_ID   => p_loan_id
                                        ,P_SOURCE_TABLE =>'LNS_LOAN_HEADERS_ALL'
                                        ,P_DOCUMENT_TYPE => 'LOAN_AGREEMENT'
                                        ,P_VERSION       => l_version
                                        ,P_DOCUMENT_XML  => l_result_xml
                                        ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                                        ,P_REASON => l_reason);

    END IF;
    CLOSE csr_loan_agreement;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
   WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
	                                                              || ' -');
         RAISE;
END STORE_LOAN_AGREEMENT;


PROCEDURE STORE_LOAN_AGREEMENT_CP (P_LOAN_ID                 IN         NUMBER
				                  ,P_AGREEMENT_REASON        IN         VARCHAR2)
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'STORE_LOAN_AGREEMENT_CP';
    l_xml_output                    BOOLEAN;
    l_iso_language                  FND_LANGUAGES.iso_language%TYPE;
    l_iso_territory                 FND_LANGUAGES.iso_territory%TYPE;
    l_notify                        boolean;
    l_request_id                    number;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID =  ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_AGREEMENT_REASON =  ' || P_AGREEMENT_REASON);

    /* verify input parameters */
    if P_LOAN_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_ID' );
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if P_AGREEMENT_REASON is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_AGREEMENT_REASON' );
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    /* begin submit request to generate Loan Agreement Report */
    l_notify := FND_REQUEST.ADD_NOTIFICATION(FND_GLOBAL.USER_NAME);

    FND_REQUEST.SET_ORG_ID(MO_GLOBAL.GET_CURRENT_ORG_ID());

    SELECT
    lower(iso_language),iso_territory
    INTO
    l_iso_language,l_iso_territory
    FROM
    FND_LANGUAGES
    WHERE
    language_code = USERENV('LANG');

    logMessage(FND_LOG.LEVEL_STATEMENT, 'Calling fnd_request.add_layout...');
    l_xml_output:=  fnd_request.add_layout(
            template_appl_name  => 'LNS',
            template_code       => 'LNSRPTAG',
            template_language   => l_iso_language,
            template_territory  => l_iso_territory,
            output_format       => 'PDF'
            );

    logMessage(FND_LOG.LEVEL_STATEMENT, 'l_iso_language = ' || l_iso_language);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'l_iso_territory = ' || l_iso_territory);

    logMessage(FND_LOG.LEVEL_STATEMENT, 'Submitting LNS_AGREEMENT cp...');
    l_request_id := FND_REQUEST.SUBMIT_REQUEST('LNS'
                                            ,'LNS_AGREEMENT'
                                            ,'', '', FALSE
                                            ,P_LOAN_ID
                                            ,'Y'
                                            ,P_AGREEMENT_REASON);

    if l_request_id = 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_AGREEMENT_REQUEST_FAILED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully submited Loan Agreement Report Generation Concurrent Program. Request id: ' || l_request_id);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
   WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' -');
END;



/*========================================================================
 | PUBLIC PROCEDURE LNS_TRANSFER_LOANS_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to change loan agent for loans.
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
 |      P_FROM_LOAN_OFFICER   IN      Inputs from loan officer
 |      P_TO_LOAN_OFFICER     IN      Inputs to loan officer
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
 | 24-04-2009            gparuchu          Created
 |
 *=======================================================================*/
PROCEDURE LNS_TRANSFER_LOANS_CONCUR(
	ERRBUF                  OUT NOCOPY     VARCHAR2,
	RETCODE                 OUT NOCOPY     VARCHAR2,
    P_FROM_LOAN_OFFICER     IN             NUMBER,
    P_TO_LOAN_OFFICER       IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'LNS_TRANSFER_LOANS_CONCUR';
    l_msg_count	        NUMBER;
    l_msg_data          VARCHAR2(32767);
    l_return            BOOLEAN;
    l_count             NUMBER;
    l_loan_id           NUMBER;
    l_loan_number       VARCHAR2(60);
    l_version_number    NUMBER;
    l_start             DATE;
    l_end               DATE;
    l_return_status     VARCHAR2(1);
    g_cr_return_status  VARCHAR2(10);

    l_loan_header_rec   LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query all the loans that are with a given loan officer */
    CURSOR loans_to_be_transferred_cur IS
        select
	    head.OBJECT_VERSION_NUMBER,
        head.loan_id,
        head.loan_number
        from
        LNS_LOAN_HEADERS head
        where
        head.loan_assigned_to = p_from_loan_officer;
BEGIN

    g_cr_return_status := 'NORMAL';

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_FROM_LOAN_OFFICER = ' || P_FROM_LOAN_OFFICER);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_TO_LOAN_OFFICER = ' || P_TO_LOAN_OFFICER);

    if P_FROM_LOAN_OFFICER is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_FROM_LOAN_OFFICER');
        FND_MESSAGE.SET_TOKEN('VALUE', P_FROM_LOAN_OFFICER);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_TO_LOAN_OFFICER is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_TO_LOAN_OFFICER');
        FND_MESSAGE.SET_TOKEN('VALUE', P_TO_LOAN_OFFICER);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* init variables */
    l_count := 0;
    l_start := sysdate;

    open loans_to_be_transferred_cur;

    LOOP

        fetch loans_to_be_transferred_cur into
            l_version_number,
            l_loan_id,
            l_loan_number;
        exit when loans_to_be_transferred_cur%NOTFOUND;

        l_count := l_count + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Processing Loan ' || l_loan_number || ' id ' || l_loan_id);

        BEGIN
            /* updating loan header table */
            l_loan_header_rec.loan_id := l_loan_id;
	        l_loan_header_rec.loan_assigned_to := P_TO_LOAN_OFFICER;

            LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
                                            P_LOAN_HEADER_REC => l_loan_header_rec,
                                            P_INIT_MSG_LIST => FND_API.G_FALSE,
                                            X_RETURN_STATUS => l_return_status,
                                            X_MSG_COUNT => l_msg_count,
                                            X_MSG_DATA => l_msg_data);


            IF l_return_status <> 'S' THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'l_return_status: ' || l_return_status);
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Everything successful here then go ahead and commit the updates
	        COMMIT WORK;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully processed loan ' || l_loan_number);


        EXCEPTION
            WHEN OTHERS THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed to process loan ' || l_loan_number);
                g_cr_return_status := 'WARNING';
                l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                                status => g_cr_return_status,
                                message => 'Not all loans were transfered successfully. Please review log file.');
        END;

    END LOOP;

    close loans_to_be_transferred_cur;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '______________');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Total processed ' || l_count || ' loan(s)');
    l_end := sysdate;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Timing: ' || round((l_end - l_start)*86400, 2) || ' sec');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to Transfer Loans');
        g_cr_return_status := 'ERROR';
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => g_cr_return_status,
                        message => 'Failed to Transfer Loans. Please review log file.');

END LNS_TRANSFER_LOANS_CONCUR;

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
END LNS_REP_UTILS;

/

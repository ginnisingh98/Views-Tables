--------------------------------------------------------
--  DDL for Package Body PSA_BC_XML_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_BC_XML_REPORT_PUB" AS
/*  $Header: PSAXMLRB.pls 120.63.12010000.8 2010/02/02 10:19:07 vensubra ship $ */

    --===========================FND_LOG.START=====================================
    g_state_level NUMBER          :=    FND_LOG.LEVEL_STATEMENT;
    g_proc_level  NUMBER          :=    FND_LOG.LEVEL_PROCEDURE;
    g_event_level NUMBER          :=    FND_LOG.LEVEL_EVENT;
    g_excep_level NUMBER          :=    FND_LOG.LEVEL_EXCEPTION;
    g_error_level NUMBER          :=    FND_LOG.LEVEL_ERROR;
    g_unexp_level NUMBER          :=    FND_LOG.LEVEL_UNEXPECTED;
    g_full_path   VARCHAR2(50)    :=    'psa.plsql.psaxmlrb.psa_bc_xml_report_pub.';
    --===========================FND_LOG.END=======================================
------------------------------------------------------------------------------
-- PROCEDURE create_bc_report
-- Start of Comments
-- Purpose:
-- This is the Main program that is invoked from Concurrent Program. This procedure
-- has call to build_report_query procedure that builds the SQL query
-- End of Comments
------------------------------------------------------------------------------
PROCEDURE create_bc_report (errbuf                    OUT NOCOPY VARCHAR2,
                           retcode                   OUT NOCOPY NUMBER,
                           p_ledger_id               IN NUMBER DEFAULT NULL,
                           p_period_from             IN VARCHAR2 DEFAULT NULL,
                           p_period_to               IN VARCHAR2 DEFAULT NULL,
                           p_chart_of_accts_id       IN NUMBER,
                           p_ccid_low                IN VARCHAR2 DEFAULT NULL,
                           p_ccid_high               IN VARCHAR2 DEFAULT NULL,
                           p_application_short_name  IN VARCHAR2 DEFAULT NULL,
                           p_funds_check_status      IN VARCHAR2 DEFAULT NULL,
                           p_order_by                IN VARCHAR2 DEFAULT NULL
) IS

l_api_name        VARCHAR2(240);
l_return_status   VARCHAR2(20);
l_application_id  NUMBER(15);
l_para_rec        PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type;
x_report_query    VARCHAR2(32000) DEFAULT NULL;
l_query           VARCHAR2(32000) DEFAULT NULL;
l_trxs            CLOB;

BEGIN
    l_api_name := g_full_path||'create_bc_report';
    errbuf := NULL;
    retcode := 0;

    -- Save the IN parameters in fnd log file
    psa_utils.debug_other_string(g_state_level,l_api_name, 'BEGIN of procedure create_bc_report' );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_ledger_id' || ' = ' || p_ledger_id );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_period_from' || ' = ' || p_period_from );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_period_to' || ' = ' || p_period_to );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_chart_of_accts_id' || ' = ' || p_chart_of_accts_id );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_ccid_low' || ' = ' || p_ccid_low );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_ccid_high' || ' = ' || p_ccid_high );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_application_short_name' || ' = ' || p_application_short_name );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_funds_check_status' || ' = ' || p_funds_check_status );
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_order_by' || ' = ' || p_order_by );


    -- Get the Application Id for the Application Short Name paramater
    IF p_application_short_name <> 'ALL' THEN
        SELECT application_id INTO l_application_id
        FROM psa_bc_application_v
        WHERE application_short_name = p_application_short_name;
    ELSE
        l_application_id := 999999;
    END IF;


    -- Initialize funds_check_report_rec_type record
    psa_utils.debug_other_string(g_state_level,l_api_name,'Initialize funds_check_report_rec_type record' );

    l_para_rec.ledger_id                := p_ledger_id;
    l_para_rec.period_from              := p_period_from;
    l_para_rec.period_to                := p_period_to;
    l_para_rec.chart_of_accts_id        := p_chart_of_accts_id;
    l_para_rec.ccid_low                 := p_ccid_low;
    l_para_rec.ccid_high                := p_ccid_high;
    l_para_rec.application_short_name   := p_application_short_name;
    l_para_rec.bc_funds_check_status    := p_funds_check_status;
    l_para_rec.bc_funds_check_order_by  := p_order_by;
    l_para_rec.application_id           := l_application_id;


    -- Build the query to get the data from PSA_BC_REPORT_V
    psa_utils.debug_other_string(g_state_level,l_api_name,'Call build_report_query Procedure' );
    psa_utils.debug_other_string(g_state_level,l_api_name,'l_return_status: ' || l_return_status );

    build_report_query(x_return_status           => l_return_status,
                       x_source                  => 'CP',
                       p_para_rec                => l_para_rec,
                       p_application_short_name  => l_para_rec.application_short_name,
                       x_report_query            => l_query);


    -- Get the XML data source --
    psa_utils.debug_other_string(g_state_level,l_api_name,'Call Get_XML Procedure' );

    get_xml(x_return_status => l_return_status,
            p_query         => l_query,
            p_rowset_tag    => 'TRANSACTIONS',
            p_row_tag       => 'ACCOUNTING_LINE',
            x_xml           => l_trxs);

   -- Manipulate XML data source to XML Publisher compatiable format and save it to output file --
   psa_utils.debug_other_string(g_state_level,l_api_name,'Call construct_bc_report_output' );

   construct_bc_report_output(x_return_status => l_return_status,
                              x_source        => 'CP',
                              p_para_rec      => l_para_rec,
                              p_trxs          => l_trxs);


   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure create_bc_report' );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        retcode := 2;
        psa_utils.debug_other_string(g_unexp_level,l_api_name,'ERROR: Unexpected Error in create_bc_report Procedure' );

    WHEN FND_API.G_EXC_ERROR THEN
        retcode := 2;
        psa_utils.debug_other_string(g_error_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
        psa_utils.debug_other_string(g_error_level,l_api_name,'Error in create_bc_report Procedure' );

    WHEN OTHERS THEN
        retcode := 2;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'Error in create_bc_report Procedure' );

END create_bc_report;

------------------------------------------------------------------------------
-- PROCEDURE create_bc_transaction_report
-- Start of Comments
-- Purpose:
-- This procedure is invoked when the BC Report is invoked from
-- individual Transaction Forms
-- has call to build_report_query procedure that builds the SQL query
-- End of Comments
------------------------------------------------------------------------------
PROCEDURE create_bc_transaction_report(
    errbuf                       OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY NUMBER,
    P_LEDGER_ID                  IN NUMBER DEFAULT NULL,
    P_APPLICATION_ID             IN NUMBER DEFAULT NULL,
    P_PACKET_EVENT_FLAG          IN VARCHAR2 DEFAULT NULL,
    P_SEQUENCE_ID                IN NUMBER DEFAULT NULL
) IS

l_api_name         VARCHAR2(240);
l_return_status    VARCHAR2(20);
l_application_id   NUMBER(15);
l_sequence_id      NUMBER(15);
l_para_rec         PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type;
x_report_query     VARCHAR2(32000) DEFAULT NULL;
l_query            VARCHAR2(32000) DEFAULT NULL;
l_trxs             CLOB;

-- Cursor is used to print data from psa_bc_report_events_gt
-- as entered by product teams. This is useful for debugging.

CURSOR get_report_events_gt IS
SELECT event_id,
       packet_id,
       source_distribution_type,
       source_distribution_id_num_1,
       source_distribution_id_num_2,
       source_distribution_id_num_3,
       source_distribution_id_num_4,
       source_distribution_id_num_5
FROM   psa_bc_report_events_gt;

BEGIN
    l_api_name := g_full_path||'create_bc_transaction_report';
    errbuf     := NULL;
    retcode    := 0;

    -- Save the IN parameters in fnd log file
    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure create_bc_transaction_report');
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_ledger_id' || ' = ' || p_ledger_id);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_application_id' || ' = ' || p_application_id);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_packet_event_flag' || ' = ' || p_packet_event_flag);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_sequence_id' || ' = ' || p_sequence_id);

    psa_utils.debug_other_string(g_state_level,l_api_name, 'PSA_BC_REPORT_EVENTS_GT');
    psa_utils.debug_other_string(g_state_level,l_api_name, '========================');

    FOR x in get_report_events_gt
    LOOP
       psa_utils.debug_other_string(g_state_level,l_api_name, 'EVENT_ID = '||x.event_id);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'PACKET_ID = '||x.packet_id);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_TYPE = '||x.source_distribution_type);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_1 = '||x.source_distribution_id_num_1);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_2 = '||x.source_distribution_id_num_2);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_3 = '||x.source_distribution_id_num_3);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_4 = '||x.source_distribution_id_num_4);
       psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_5 = '||x.source_distribution_id_num_5);
    END LOOP;

    -- Get the Application Id for the Application Short Name paramater
    l_application_id := p_application_id;

    -- initialize funds_check_report_rec_type record
    psa_utils.debug_other_string(g_state_level,l_api_name, 'Initialize funds_check_report_rec_type record');

    l_para_rec.ledger_id                 := p_ledger_id;
    l_para_rec.application_id            := l_application_id;
    l_para_rec.packet_event_flag         := p_packet_event_flag;
    l_para_rec.sequence_id               := p_sequence_id;

    -- Build the query to get the data from PSA_BC_REPORT_V
    psa_utils.debug_other_string(g_state_level,l_api_name,'Call build_report_query Procedure');

    build_report_query(x_return_status          => l_return_status,
                       x_source                 => 'FORM',
                       p_para_rec               => l_para_rec,
                       p_application_short_name => l_para_rec.application_short_name,
                       x_report_query           => l_query);

    psa_utils.debug_other_string(g_state_level,l_api_name,'l_return_status: ' || l_return_status);

    -- Get the XML data source
    psa_utils.debug_other_string(g_state_level,l_api_name,'Call Get_XML Procedure');

    -- Call to GET_XML procedure
    get_xml(x_return_status => l_return_status,
            p_query         => l_query,
            p_rowset_tag    => 'TRANSACTIONS',
            p_row_tag       => 'ACCOUNTING_LINE',
            x_xml           => l_trxs);

    -- Call to construct_bc_report_output procedure
    -- Manipulate XML data source to XML Publisher compatiable format and save it to output file
    psa_utils.debug_other_string(g_state_level,l_api_name,'Call construct_bc_report_output');

    construct_bc_report_output(x_return_status => l_return_status,
                               x_source        => 'FORM',
                               p_para_rec      => l_para_rec,
                               p_trxs          => l_trxs);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure create_bc_transaction_report');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        retcode := 2;
        psa_utils.debug_other_string(g_unexp_level,l_api_name, 'ERROR: Unexpected Error in create_bc_report Procedure');

    WHEN FND_API.G_EXC_ERROR THEN
        retcode := 2;
        psa_utils.debug_other_string(g_error_level,l_api_name,'ERROR: ' || SQLERRM(sqlcode));
        psa_utils.debug_other_string(g_error_level,l_api_name,'Error in create_bc_report Procedure');

    WHEN OTHERS THEN
        retcode := 2;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: Unknown Error in create_bc_report Procedure');
END create_bc_transaction_report;


-------------------------------------------------------------------------------
-- PROCEDURE build_report_query
-- Start of Comments
-- Purpose:
-- Build the SQL Query from PSA_BC_REPORT_V view
-- The query is build based on the report paramaters
-- End of Comments
-------------------------------------------------------------------------------

PROCEDURE build_report_query(
    x_return_status             OUT NOCOPY VARCHAR2,
    x_source                    IN VARCHAR2,
    p_para_rec                  IN PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type,
    p_application_short_name    IN VARCHAR2,
    x_report_query              OUT NOCOPY VARCHAR2
) IS

  l_api_name          VARCHAR2(240);
  l_coaid             GL_LEDGERS.CHART_OF_ACCOUNTS_ID%TYPE;
  l_period_start_num  GL_PERIOD_STATUSES.PERIOD_NUM%TYPE;
  l_period_end_num    GL_PERIOD_STATUSES.PERIOD_NUM%TYPE;
  l_period_year       GL_PERIOD_STATUSES.PERIOD_YEAR%TYPE;  -- Bug 8966506
  l_period_year_temp  GL_PERIOD_STATUSES.PERIOD_YEAR%TYPE;  -- Bug 8966506
  l_sla_uptake_prod   VARCHAR2(1);
  l_gl_balancing_segment      NUMBER;
  l_document_status   VARCHAR2(1);
  l_meaning           VARCHAR2(240);

  CURSOR get_report_events_gt IS
  SELECT event_id,
         packet_id,
         source_distribution_type,
         source_distribution_id_num_1,
         source_distribution_id_num_2,
         source_distribution_id_num_3,
         source_distribution_id_num_4,
         source_distribution_id_num_5
  FROM   psa_bc_report_events_gt;

  CURSOR get_coaid (p_ledgerid IN NUMBER) IS
  SELECT chart_of_accounts_id
  FROM   gl_ledgers
  WHERE  ledger_id = p_ledgerid;

  -- Bug 8966506 : Modified get_period_num to fetch the period_year
  CURSOR get_period_num (p_period_name IN VARCHAR2) IS
  SELECT period_num,
         period_year
  FROM   gl_period_statuses ps
  WHERE  ps.ledger_id = p_para_rec.ledger_id AND
         ps.application_id = decode(p_para_rec.application_id,
                                   200, 200,
                                   201, 201,
                                   275, 275,
                                   101) AND
         ps.period_name = p_period_name;

  CURSOR get_event_class_codes (p_application_id NUMBER) IS
  SELECT sum(decode(event_class_code, 'INVOICES', 1, 0)) INVOICES,
         sum(decode(event_class_code, 'CREDIT MEMOS', 1, 0)) CREDIT_MEMOS,
         sum(decode(event_class_code, 'DEBIT MEMOS', 1, 0)) DEBIT_MEMOS,
         sum(decode(event_class_code, 'PREPAYMENTS', 1, 0)) PREPAYMENTS,
         sum(decode(event_class_code, 'PREPAYMENT APPLICATIONS', 1, 0)) PREPAYMENT_APPS,
         sum(decode(event_class_code, 'PO_PA', 1, 0)) PO_PA,
         sum(decode(event_class_code, 'REQUISITION', 1, 0)) REQ,
         sum(decode(event_class_code, 'RELEASE', 1, 0)) RELEASE
  FROM ( SELECT distinct xdl.event_class_code
         FROM psa_bc_report_events_gt psagt,
             xla_distribution_links xdl
         WHERE xdl.application_id = p_para_rec.application_id AND
               xdl.event_id = psagt.event_id
	);

  -- get CCID segments for a ledger
  CURSOR c_seg_info (p_ledger_id NUMBER) IS
  SELECT
      application_column_name
  FROM fnd_id_flex_segments
  WHERE id_flex_num =
      (
      SELECT
          chart_of_accounts_id
      FROM gl_ledgers
      WHERE ledger_id = p_ledger_id
      )
      AND id_flex_code = 'GL#'
      AND application_id = 101
      AND enabled_flag = 'Y';

   TYPE name_type IS TABLE OF VARCHAR2(30);
   segment_name_tab     name_type;
   segment_low_tab      name_type;
   segment_high_tab     name_type;
   l_length             NUMBER;
   l_compt              NUMBER;
   l_pos                NUMBER;
   l_counter            NUMBER;
   l_delimiter          VARCHAR2(1);

--Modified for Bug 9100984
  CURSOR c_xla_accounting_errors IS
  SELECT    PBA.APPLICATION_ID,
            PBA.APPLICATION_SHORT_NAME,
            PBA.APPLICATION_NAME,
            XAE.EVENT_ID,
            XAE.LEDGER_ID,
            NULL,
            NULL,
            PS.PERIOD_NAME                          GL_PERIOD_NAME,
            NULL,
            NULL                                    BUDGET_TYPE,
            NULL,
            NULL,
            NULL                                    JE_CATEGORY_NAME,
            NULL                                    BUDGET_LEVEL,
            NULL,
            NULL                                    TREASURY_SYMBOL,
            NULL,
            NULL,
            NULL,
            NULL                                    JOURNAL_LINE_NUMBER,
            NULL                                    CCID,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL                                    BALANCE_TYPE,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL                                    CURRENCY,
            'Z'                                     FUNDS_CHECK_STATUS_CODE,
            'Accounting could not be created'       FUNDS_CHECK_STATUS,
            NULL,
            NULL,
            NULL                                    FUNDS_CHECK_LEVEL_MEANING,
            NULL,
            XAE.ENCODED_MSG                     RESULT_MESSAGE,
            NULL,
            NULL                                    BOUNDARY,
            NULL                                    DEBIT_CREDIT_INDICATOR,
            NULL                                    AMOUNT,
            NULL                                    DEBIT_AMOUNT_ACCOUNTED,
            NULL                                    CREDT_AMOUNT_ACCOUNTED,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL                                    ENCUMBRANCE_POSTED_BALANCE,
            NULL                                    ENCUMBRANCE_APPROVED_BALANCE,
            NULL                                    ENCUMBRANCE_PENDING_BALANCE,
            NULL                                    ENCUMBRANCE_TOTAL_BALANCE,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL                                    AVAILABLE_POSTED_BALANCE,
            NULL                                    AVAILABLE_APPROVED_BALANCE,
            NULL                                    AVAILABLE_PENDING_BALANCE,
            NULL                                    AVAILABLE_TOTAL_BALANCE,
            NULL                                    SOURCE_DISTRIBUTION_TYPE,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            XAE.TRANSACTION_NUMBER                  DOCUMENT_REFERENCE,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL                                     PARTY_ID,
            NULL                                     PARTY_SITE_ID,
            NULL                                     VENDOR_NAME,
            NULL                                     VENDOR_SITE_NAME,
            NULL                                     PAYMENT_FORECAST_LINE_NUMBER,
            NULL                                     PA_FLAG,
            NULL                                     ACCOUNTING_FLEXFIELD,
            NULL                                     SUMMARY_ACCOUNT_INDICATOR,
            NULL                                     PO_LINE_NUMBER,
            NULL                                     PO_DIST_LINE_NUMBER,
            NULL                                     PO_SHIP_LINE_NUMBER,
            NULL                                     REQ_LINE_NUMBER,
            NULL                                     REQ_DIST_LINE_NUMBER,
            NULL                                     INV_LINE_NUMBER,
            NULL                                     DOCUMENT_SEQUENCE_NUMBER,
            XAE.AE_HEADER_ID                         AE_HEADER_ID,
            XAE.AE_LINE_NUM                          AE_LINE_NUM,
            PS.PERIOD_NUM,
            PS.PERIOD_YEAR,
            PS.QUARTER_NUM,
            NULL                                    COMM_ENCUM_POSTED_BAL,
            NULL                                    COMM_ENCUM_APPROVED_BAL,
            NULL                                    COMM_ENCUM_PENDING_BAL,
            NULL                                    COMM_ENCUM_TOTAL_BAL,
            NULL                                    OBLI_ENCUM_POSTED_BAL,
            NULL                                    OBLI_ENCUM_APPROVED_BAL,
            NULL                                    OBLI_ENCUM_PENDING_BAL,
            NULL                                    OBLI_ENCUM_TOTAL_BAL,
            'X' ERROR_SOURCE,
            NULL                                    CURRENT_FUNDS_AVAILABLE,
            NULL                                    DOCUMENT_STATUS
  FROM
        PSA_XLA_ACCOUNTING_ERRORS XAE,
        PSA_BC_APPLICATION_V  PBA,
        GL_PERIOD_STATUSES PS
  WHERE PBA.application_id = p_para_rec.application_id AND
        XAE.ledger_id = p_para_rec.ledger_id AND
        PS.ledger_id = p_para_rec.ledger_id AND
        PS.application_id = p_para_rec.application_id AND
       (XAE.event_date between PS.start_date AND PS.end_date) AND
        ((x_source = 'FORM' AND
        EXISTS (SELECT 'x'
                  FROM PSA_BC_REPORT_EVENTS_GT PSAGT
                 WHERE PSAGT.event_id = XAE.event_id))
        OR (x_source = 'CP' AND (PS.period_year = l_period_year) AND PS.period_num BETWEEN l_period_start_num AND l_period_end_num)); -- Bug 8966506

  -- This Cursor has been added for performance reasons. Query for summary rows is complex and takes time to execute.
  -- This Cursor decides whether the query should be executed. With relatively lesser tables and good use of indexes
  -- the query below helps reduce the overhead for non-summary transactions.

  CURSOR c_is_summary_used IS
  SELECT min('Y')
    FROM (SELECT packet_id
          FROM   gl_bc_packets
          WHERE  template_id IS NOT NULL
          UNION ALL
          SELECT packet_id
          FROM   gl_bc_packets_hists
          WHERE  template_id IS NOT NULL) bc
   WHERE bc.packet_id IN (SELECT packet_id FROM psa_bc_results_gt);

   CURSOR c_document_status IS
   SELECT application_name,
          batch_reference,
          document_reference,
          vendor_name,
          vendor_site_name,
          sum(decode(funds_check_status_code, 'A', 1, 0)) approved_count,
          sum(decode(funds_check_status_code, 'R', 1, 0)) reject_count,
          sum(decode(funds_check_status_code, 'S', 1, 0)) success_count,
          sum(decode(funds_check_status_code, 'F', 1, 0)) fail_count,
          sum(decode(funds_check_status_code, 'T', 1, 0)) fatal_count,
          sum(decode(funds_check_status_code, 'C', 1, 0)) checking_count,
          sum(decode(funds_check_status_code, 'P', 1, 0)) reserving_count,
          count(*) total_count
   FROM psa_bc_results_gt
   GROUP BY application_name, batch_reference, document_reference, vendor_name, vendor_site_name;


  TYPE bc_rpt_type IS TABLE OF PSA_BC_RESULTS_GT%ROWTYPE INDEX BY BINARY_INTEGER;
  l_bc_results_rpt    bc_rpt_type;
  l_dump              bc_rpt_type;
  l_bc_summary_rpt    bc_rpt_type;
  l_sum_dump          bc_rpt_type;
  l_event_class_codes get_event_class_codes%rowtype;
  l_summary_used      VARCHAR2(1);
  l_event_id          NUMBER;

  -- Bug 5711972
  Type get_tsymbol IS TABLE OF FV_TREASURY_SYMBOLS.TREASURY_SYMBOL%TYPE INDEX BY VARCHAR2(30);
  rc_tsymbol get_tsymbol;

  -- Populate Tab is used since BULK Collect Overwrites the current collection.
  -- Since we do not have an APPEND clause in BULK COLLECT, we have used 2
  -- collection objects as below:
  -- l_dump : is a temporary object which is used to dump every query result
  -- l_bc_results_rpt : this is the actual object whose data is later inserted in
  --                    psa_bc_results_rpt_gt table
  -- Populate Tab simply adds what it finds in the dump object (l_dump) in l_bc_results_rpt
  -- This is a workaround to bulk collect append.

 -- Bug 5711972: This function retreive the value of Treasury Symbol against the fund value

 function get_treasury_symbol(p_ccid Number) return varchar2
  is
   l_result	      BOOLEAN;
   l_fund_value      VARCHAR2(30);
   l_treasury_symbol VARCHAR2(100);
  begin
  l_api_name := g_full_path||'get_treasury_symbol';
  psa_utils.debug_other_string(g_state_level,l_api_name,'p_ccid ='||p_ccid);

  IF p_ccid IS NULL THEN
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_ccid IS NULL. Return NULL.');
    return NULL;
  END IF;

  l_result :=   FND_FLEX_KEYVAL.validate_ccid (
                        appl_short_name   => 'SQLGL',
                        key_flex_code     => 'GL#',
                        structure_number  =>  l_coaid,
                        combination_id    =>  p_ccid);

  l_fund_value := FND_FLEX_KEYVAL.segment_value(l_gl_balancing_segment);
  if rc_tsymbol.exists(l_fund_value) then
     return rc_tsymbol(l_fund_value);
  ELSE
  BEGIN
  SELECT treasury_symbol
    INTO l_treasury_symbol
    FROM fv_treasury_symbols
   WHERE treasury_symbol_id in (SELECT treasury_symbol_id
                                  FROM fv_fund_parameters
				 WHERE fund_value = l_fund_value
				   AND set_of_books_id = p_para_rec.ledger_id)
     AND set_of_books_id = p_para_rec.ledger_id;

  EXCEPTION
   WHEN others THEN
    psa_utils.debug_other_string(g_state_level,l_api_name,'When Other Exception raised while retreiving Treasury Symbol');
   l_treasury_symbol := null;

   END;
  END IF;
     rc_tsymbol(l_fund_value) := l_treasury_symbol;
  RETURN l_treasury_symbol;

  END get_treasury_symbol;



  PROCEDURE populate_tab is
     l_curr_cnt number;
  BEGIN
     l_curr_cnt := l_bc_results_rpt.count;


     IF (l_curr_cnt = 0) AND (l_dump.count > 0) THEN
       FOR x in 1..l_dump.count
        LOOP

           IF FV_INSTALL.ENABLED THEN -- Bug 9147639
               l_dump(x).treasury_symbol := get_treasury_symbol(l_dump(x).ccid);
           ELSE
               l_dump(x).treasury_symbol := NULL;
           END IF;

           l_bc_results_rpt(x) := l_dump(x);
        END LOOP;

     ELSIF (l_dump.count > 0) THEN
        FOR x in 1..l_dump.count
        LOOP
            IF FV_INSTALL.ENABLED THEN -- Bug 9147639
                l_dump(x).treasury_symbol := get_treasury_symbol(l_dump(x).ccid);
            ELSE
                l_dump(x).treasury_symbol := NULL;
            END IF;
           l_bc_results_rpt(l_curr_cnt + x) := l_dump(x);
        END LOOP;
     END IF;
  END populate_tab;

  -- This Procedure is used to populate the Summary record in one shot using Bulk fetch
  -- Bug 5711972

  PROCEDURE populate_sum_tabs is
  BEGIN
       IF FV_INSTALL.ENABLED THEN -- Bug 9147639
           FOR x in 1..l_sum_dump.count
            LOOP

            l_sum_dump(x).treasury_symbol := get_treasury_symbol(l_sum_dump(x).ccid);

            END LOOP;
       ELSE
           psa_utils.debug_other_string(g_state_level,l_api_name,'populate_sum_tabs -- FV not enabled');
       END IF;
                l_bc_summary_rpt := l_sum_dump;

  END populate_sum_tabs;

BEGIN

    l_api_name := g_full_path||'build_report_query';

    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure build_report_query');


    -- Get the current chart of accounts id
    OPEN get_coaid(p_para_rec.ledger_id);
    FETCH get_coaid INTO l_coaid;
    CLOSE get_coaid;
    psa_utils.debug_other_string(g_state_level,l_api_name,'l_coaid' || ' = ' || l_coaid);

    -- Fetch and store the period_num value for period_from and period_to
    OPEN get_period_num(p_para_rec.period_from);
    FETCH get_period_num INTO l_period_start_num,l_period_year;         -- Bug 8966506
    CLOSE get_period_num;
    psa_utils.debug_other_string(g_state_level,l_api_name,'L_Period_Start_Num' || ' = ' || l_period_start_num);
    psa_utils.debug_other_string(g_state_level,l_api_name,'L_Period_Year' || ' = ' || l_period_year);

    OPEN get_period_num(p_para_rec.period_to);
    FETCH get_period_num INTO l_period_end_num,l_period_year_temp;      -- Bug 8966506
    CLOSE get_period_num;
    psa_utils.debug_other_string(g_state_level,l_api_name,'L_Period_End_Num' || ' = ' || l_period_end_num);
    psa_utils.debug_other_string(g_state_level,l_api_name,'L_Period_Year_Temp' || ' = ' || l_period_year_temp);

    -- Ideally l_period_year and l_period_year_temp must be the same if called from CP
    -- This is enforced in the CP parameters and thus a check here is optional

    IF (p_para_rec.application_id IN (200, 201)) AND (x_source = 'FORM') THEN
       OPEN get_event_class_codes(p_para_rec.application_id);
       FETCH get_event_class_codes into l_event_class_codes;
       CLOSE get_event_class_codes;

       psa_utils.debug_other_string(g_state_level,l_api_name,'Event Class Codes:');
       psa_utils.debug_other_string(g_state_level,l_api_name,'Invoices' || ' = ' || l_event_class_codes.invoices);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Debit Memos' || ' = ' || l_event_class_codes.debit_memos);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Credit Memos' || ' = ' || l_event_class_codes.credit_memos);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Prepayments' || ' = ' || l_event_class_codes.prepayments);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Prepay Apps' || ' = ' || l_event_class_codes.prepayment_apps);
       psa_utils.debug_other_string(g_state_level,l_api_name,'PO_PA' || ' = ' || l_event_class_codes.po_pa);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Requisition' || ' = ' || l_event_class_codes.req);
       psa_utils.debug_other_string(g_state_level,l_api_name,'Release' || ' = ' || l_event_class_codes.release);
    END IF;

    -- Has the product uptaken SLA?
    IF p_para_rec.application_id IN (101, 8401) THEN
       l_sla_uptake_prod := 'N';
    ELSE
       l_sla_uptake_prod := 'Y';
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'Product Uptaken SLA: '||l_sla_uptake_prod);

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Build query string for all products
    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin SQL Query String');
    psa_utils.debug_other_string(g_state_level,l_api_name,'x_return_status: ' || x_return_status);
    psa_utils.debug_other_string(g_state_level,l_api_name,'Source' || ' = ' || x_source);


    IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(APPL_ID           => 101,
                                                   KEY_FLEX_CODE     => 'GL#',
                                                   STRUCTURE_NUMBER  => l_coaid,
                                                   FLEX_QUAL_NAME    => 'GL_BALANCING',
                                                   SEGMENT_NUMBER    => l_gl_balancing_segment))  THEN

             --Raise GET_QUALIFIER_SEGNUM_EXCEP;
             NULL;
      END IF;

    -- Bug 9200360 : Populating PSA_BC_REPORT_EVENTS_GT when the x_source is CP
    IF x_source = 'CP' THEN

        -- The following should ideally return no records in the fnd_logs
        FOR x_rep_eve in get_report_events_gt
        LOOP
           psa_utils.debug_other_string(g_state_level,l_api_name, 'EVENT_ID = '||x_rep_eve.event_id);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'PACKET_ID = '||x_rep_eve.packet_id);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_TYPE = '||x_rep_eve.source_distribution_type);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_1 = '||x_rep_eve.source_distribution_id_num_1);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_2 = '||x_rep_eve.source_distribution_id_num_2);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_3 = '||x_rep_eve.source_distribution_id_num_3);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_4 = '||x_rep_eve.source_distribution_id_num_4);
           psa_utils.debug_other_string(g_state_level,l_api_name, 'SOURCE_DISTRIBUTION_ID_NUM_5 = '||x_rep_eve.source_distribution_id_num_5);
        END LOOP;

        psa_utils.debug_other_string(g_state_level,l_api_name, 'Fetching records from GL_BC_PACKETS');

        INSERT INTO PSA_BC_REPORT_EVENTS_GT (packet_id)
        SELECT DISTINCT packet_id
        FROM GL_BC_PACKETS pkts
        WHERE pkts.period_year = l_period_year
          AND pkts.period_num BETWEEN l_period_start_num AND l_period_end_num;

        psa_utils.debug_other_string(g_state_level,l_api_name, 'Fetching records from GL_BC_PACKETS_HISTS');

        INSERT INTO PSA_BC_REPORT_EVENTS_GT (packet_id)
        SELECT DISTINCT packet_id
        FROM GL_BC_PACKETS_HISTS pkts
        WHERE pkts.period_year = l_period_year
          AND pkts.period_num BETWEEN l_period_start_num AND l_period_end_num;

        psa_utils.debug_other_string(g_state_level,l_api_name, 'Completed fetching records from GL_BC_PACKETS_HISTS');

    END IF;


    -- Process for GL
    IF p_para_rec.application_id = 101 THEN


       SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                 PBRV.APPLICATION_SHORT_NAME,
                 PBRV.APPLICATION_NAME,
                 PBRV.EVENT_ID,
                 PBRV.LEDGER_ID,
                 PBRV.ROW_ID,
                 PBRV.PACKET_ID,
                 PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                 PBRV.FUNDING_BUDGET_NAME,
                 NULL                                    BUDGET_TYPE,
                 PBRV.BUDGET_VERSION_ID,
                 PBRV.JE_SOURCE_NAME,
                 PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                 NULL                                    BUDGET_LEVEL,
                 PBRV.BATCH_NAME,
                 NULL                                    TREASURY_SYMBOL,
                 PBRV.JE_BATCH_ID,
                 PBRV.JE_HEADER_ID,
                 PBRV.HEADER_NAME,
                 'Summary'                               JOURNAL_LINE_NUMBER,
                 PBRV.CODE_COMBINATION_ID                CCID,
                 PBRV.USSGL_TRANSACTION_CODE,
                 PBRV.ACCOUNT_TYPE,
                 PBRV.ACCOUNT_TYPE_MEANING,
                 PBRV.ACCOUNT_CATEGORY_CODE,
                 PBRV.ACCOUNT_SEGMENT_VALUE,
                 PBRV.ACTUAL_FLAG,
                 PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                 PBRV.AMOUNT_TYPE,
                 PBRV.AMOUNT_TYPE_MEANING,
                 PBRV.ENCUMBRANCE_TYPE,
                 PBRV.TEMPLATE_ID,
                 PBRV.CURRENCY_CODE                      CURRENCY,
                 PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                 PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                 PBRV.EFFECTIVE_STATUS,
                 PBRV.FUNDS_CHECK_LEVEL_CODE,
                 PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                 PBRV.RESULT_CODE,
                 PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                 PBRV.BOUNDARY_CODE,
                 PBRV.BOUNDARY_MEANING                   BOUNDARY,
                 PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                 PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                 PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                 PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                 PBRV.BUDGET_POSTED_BALANCE,
                 PBRV.BUDGET_APPROVED_BALANCE,
                 PBRV.BUDGET_PENDING_BALANCE,
                 PBRV.BUDGET_TOTAL_BALANCE,
                 PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                 PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                 PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                 PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                 PBRV.ACTUAL_POSTED_BALANCE,
                 PBRV.ACTUAL_APPROVED_BALANCE,
                 PBRV.ACTUAL_PENDING_BALANCE,
                 PBRV.ACTUAL_TOTAL_BALANCE,
                 PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                 PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                 PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                 PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                 PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                 PBRV.HEADER_NAME                        DOCUMENT_REFERENCE,
                 TO_CHAR(PBRV.JE_LINE_NUM)               LINE_REFERENCE,
                 PBRV.BATCH_NAME                         BATCH_REFERENCE,
                 PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                 PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                 NULL                                    PARTY_ID,
                 NULL                                    PARTY_SITE_ID,
                 NULL                                    VENDOR_NAME,
                 NULL                                    VENDOR_SITE_NAME,
                 NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                 NULL                                    PA_FLAG,
                 FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)      ACCOUNTING_FLEXFIELD,
                 'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                 NULL                                    PO_LINE_NUMBER,
                 NULL                                    PO_DIST_LINE_NUMBER,
                 NULL                                    PO_SHIP_LINE_NUMBER,
                 NULL                                    REQ_LINE_NUMBER,
                 NULL                                    REQ_DIST_LINE_NUMBER,
                 NULL                                    INV_LINE_NUMBER,
                 JH.DOC_SEQUENCE_VALUE                   DOCUMENT_SEQUENCE_NUMBER,
                 PBRV.AE_HEADER_ID,
                 PBRV.AE_LINE_NUM,
                 PBRV.PERIOD_NUM,
                 PBRV.PERIOD_YEAR,
                 PBRV.QUARTER_NUM,

                 PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                 PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                 PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                 PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                 PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                 PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                 PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                 PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                 'O' ERROR_SOURCE,
		 PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                 NULL                                    DOCUMENT_STATUS
       BULK COLLECT INTO l_dump
       FROM  PSA_BC_REPORT_V PBRV,
             GL_JE_HEADERS JH,
             PSA_BC_REPORT_EVENTS_GT PBRE
       WHERE PBRV.je_header_id   = JH.je_header_id(+) AND
             PBRV.ledger_id      = p_para_rec.ledger_id AND
             --PBRV.application_id = 101 AND  -- Bug 9138667 : Commented out the filter by application id
             PBRV.template_id IS NULL AND
             PBRV.packet_id = PBRE.packet_id; -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

       psa_utils.debug_other_string(g_state_level,l_api_name,'GL Query returned '||sql%rowcount||' rows.');

       populate_tab;

       psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

    -- Process for AP
    ELSIF p_para_rec.application_id = 200 THEN

        -- Select information for INVOICES, CREDIT MEMOS, DEBIT MEMOS, PREPAYMENTS
        -- UNION ALL
        -- Select information for PREPAYMENT APPLICATIONS
        IF (l_event_class_codes.invoices = 1) OR (l_event_class_codes.credit_memos = 1) OR
           (l_event_class_codes.debit_memos = 1) OR (l_event_class_codes.prepayments = 1) OR (x_source = 'CP') THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          PBRV.JE_LINE_NUM                        JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          AI.INVOICE_NUM                          DOCUMENT_REFERENCE,
                          AIL.LINE_NUMBER||' - '||
                          AID.DISTRIBUTION_LINE_NUMBER            LINE_REFERENCE,
                          APB.BATCH_NAME                          BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          PV.VENDOR_NAME                          VENDOR_NAME,
                          PVS.VENDOR_SITE_CODE                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#',l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          AIL.LINE_NUMBER                         INV_LINE_NUMBER,
                          AI.DOC_SEQUENCE_VALUE                   DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      AP_INVOICE_DISTRIBUTIONS AID,
                      AP_BATCHES APB,
                      XLA_DISTRIBUTION_LINKS XDL,
                      AP_INVOICES AI,
                      AP_INVOICE_LINES AIL,
                      PO_VENDORS PV,
                      PO_VENDOR_SITES PVS,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.source_distribution_id_num_1 = AID.invoice_distribution_id AND
                      AID.invoice_id = AI.invoice_id AND
                      AID.batch_id = APB.batch_id(+) AND
                      AI.vendor_id = PV.vendor_id(+) AND
                      AI.vendor_site_id = PVS.vendor_site_id(+) AND
                      AID.invoice_id = AIL.invoice_id AND
                      AID.invoice_line_number = AIL.line_number AND
                      PBRV.event_id = XDL.event_id AND
                      PBRV.application_id = XDL.application_id AND
                      PBRV.ae_header_id = XDL.ae_header_id AND
                      PBRV.ae_line_num = XDL.ae_line_num AND
                      XDL.event_class_code IN ('INVOICES', 'CREDIT MEMOS', 'DEBIT MEMOS', 'PREPAYMENTS') AND
                      PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.application_id = 200 AND
                      AIL.line_type_lookup_code IN ('ITEM','FREIGHT','MISCELLANEOUS','PREPAY','TAX') AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause


                      psa_utils.debug_other_string(g_state_level,l_api_name,'AP Query 1 returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
        END IF;

        IF (l_event_class_codes.prepayment_apps = 1) OR (x_source = 'CP') THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          NULL                                    JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          AI.INVOICE_NUM                          DOCUMENT_REFERENCE,
                          TO_CHAR(AIL.LINE_NUMBER)                LINE_REFERENCE,
                          APB.BATCH_NAME                          BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          PV.VENDOR_NAME                          VENDOR_NAME,
                          PVS.VENDOR_SITE_CODE                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          AIL.LINE_NUMBER                         INV_LINE_NUMBER,
                          AI.DOC_SEQUENCE_VALUE                   DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      AP_INVOICE_DISTRIBUTIONS AID,
                      AP_PREPAY_APP_DISTS APD,
                      AP_BATCHES APB,
                      XLA_DISTRIBUTION_LINKS XDL,
                      AP_INVOICES AI,
                      AP_INVOICE_LINES AIL,
                      PO_VENDORS PV,
                      PO_VENDOR_SITES PVS,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.source_distribution_id_num_1 = APD.prepay_app_distribution_id AND
                      AID.invoice_distribution_id = APD.invoice_distribution_id AND
                      AID.invoice_id = AI.invoice_id AND
                      AID.batch_id = APB.batch_id(+) AND
                      AI.vendor_id = PV.vendor_id(+) AND
                      AI.vendor_site_id = PVS.vendor_site_id(+) AND
                      AI.invoice_id = AIL.invoice_id AND
                      PBRV.application_id = XDL.application_id AND
                      PBRV.event_id = XDL.event_id AND
                      PBRV.ae_header_id = XDL.ae_header_id AND
                      PBRV.ae_line_num = XDL.ae_line_num AND
                      XDL.event_class_code IN ('PREPAYMENT APPLICATIONS') AND
                      PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.application_id = 200 AND
                      AIL.line_type_lookup_code IN ('ITEM','FREIGHT','MISCELLANEOUS','PREPAY','TAX') AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                      psa_utils.debug_other_string(g_state_level,l_api_name,'AP Query 2 returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
        END IF;

    -- Process for PO
    ELSIF p_para_rec.application_id = 201 THEN

        -- For Bug 4958840,  added event_class_code PO_PA along with REQUISITIONS in the second query in union
        -- Select PO, PA
        -- UNION ALL
        -- Select Requisition
        -- UNION ALL
        -- Select Releases

        IF (l_event_class_codes.po_pa = 1) OR (x_source = 'CP') THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          NULL                                    JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          PH.SEGMENT1                             DOCUMENT_REFERENCE,
                          PL.LINE_NUM||'-'||
                          PLL.SHIPMENT_NUM||'-'||
                          PD.DISTRIBUTION_NUM                     LINE_REFERENCE,
                          NULL                                    BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          PV.VENDOR_NAME                          VENDOR_NAME,
                          PVS.VENDOR_SITE_CODE                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          PL.LINE_NUM                             PO_LINE_NUMBER,
                          PD.DISTRIBUTION_NUM                     PO_DIST_LINE_NUMBER,
                          PLL.SHIPMENT_NUM                        PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      PO_BC_DISTRIBUTIONS PBD,
                      XLA_DISTRIBUTION_LINKS XDL,
                      PO_VENDORS PV,
                      PO_VENDOR_SITES PVS,
                      PO_HEADERS PH,
                      PO_LINES PL,
                      PO_DISTRIBUTIONS PD,
                      PO_LINE_LOCATIONS PLL,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.source_distribution_id_num_1 = PBD.distribution_id AND
                      PBRV.event_id = PBD.ae_event_id AND
                      PBRV.application_id = XDL.application_id AND
                      PBRV.event_id = XDL.event_id AND
                      PBRV.ae_header_id = XDL.ae_header_id AND
                      PBRV.ae_line_num = XDL.ae_line_num AND
                      XDL.event_class_code IN ('PO_PA') AND
                      PBD.header_id = PH.po_header_id AND
                      PBD.reference_number = PH.segment1 AND
                      PH.vendor_id = PV.vendor_id(+) AND
                      PH.vendor_site_id = PVS.vendor_site_id(+) AND
                      PBD.distribution_id = PD.po_distribution_id AND
                      PD.po_line_id = PL.po_line_id(+) AND
                      PD.line_location_id = PLL.line_location_id(+) AND
                      PBRV.application_id = 201 AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                      psa_utils.debug_other_string(g_state_level,l_api_name,'PO Query 1 returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
        END IF;

        IF (l_event_class_codes.po_pa = 1) OR (l_event_class_codes.req = 1) OR (x_source = 'CP') THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          NULL                                    JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          PRH.SEGMENT1                            DOCUMENT_REFERENCE,
                          PRL.LINE_NUM||'-'||
                          PRD.DISTRIBUTION_NUM                    LINE_REFERENCE,
                          NULL                                    BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          PV.VENDOR_NAME                          VENDOR_NAME,
                          PVS.VENDOR_SITE_CODE                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          PRL.LINE_NUM                            REQ_LINE_NUMBER,
                          PRD.DISTRIBUTION_NUM                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'  ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      PO_BC_DISTRIBUTIONS PBD,
                      XLA_DISTRIBUTION_LINKS XDL,
                      PO_VENDORS PV,
                      PO_VENDOR_SITES PVS,
                      PO_REQUISITION_HEADERS PRH,
                      PO_REQUISITION_LINES PRL,
                      PO_REQ_DISTRIBUTIONS PRD,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.source_distribution_id_num_1 = PBD.distribution_id AND
                      PBRV.event_id = PBD.ae_event_id AND
                      PBRV.application_id = XDL.application_id AND
                      PBRV.event_id = XDL.event_id AND
                      PBRV.ae_header_id = XDL.ae_header_id AND
                      PBRV.ae_line_num = XDL.ae_line_num AND
                      XDL.event_class_code IN ('PO_PA','REQUISITION') AND
                      PBD.header_id = PRH.requisition_header_id AND
                      PRL.vendor_id = PV.vendor_id(+) AND
                      PRL.vendor_site_id = PVS.vendor_site_id(+) AND
                      PBD.distribution_id = PRD.distribution_id AND
                      PRD.requisition_line_id = PRL.requisition_line_id AND
                      PBRV.application_id = 201 AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                      psa_utils.debug_other_string(g_state_level,l_api_name,'PO Query 2 returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
       END IF;

       IF (l_event_class_codes.release = 1) OR (x_source = 'CP') THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          NULL                                    JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          DECODE(PBD.MAIN_OR_BACKING_CODE,
                                 'M', PH.SEGMENT1 || '-'|| TO_CHAR(PR.RELEASE_NUM),
                                 PH.SEGMENT1)                     DOCUMENT_REFERENCE,
                          CASE WHEN (PBD.MAIN_OR_BACKING_CODE = 'M') THEN
                                   PL.LINE_NUM||'-'||PLL.SHIPMENT_NUM ||'-'||PD.DISTRIBUTION_NUM
                               WHEN (PBD.MAIN_OR_BACKING_CODE <> 'M') AND (PBD.DISTRIBUTION_TYPE = 'PLANNED') THEN
                                   PL.LINE_NUM||'-'||PLL.SHIPMENT_NUM ||'-'||PD.DISTRIBUTION_NUM
                               ELSE
                                   NULL
                          END CASE,
                          NULL                                    BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          PV.VENDOR_NAME                          VENDOR_NAME,
                          PVS.VENDOR_SITE_CODE                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      PO_BC_DISTRIBUTIONS PBD,
                      XLA_DISTRIBUTION_LINKS XDL,
                      PO_VENDORS PV,
                      PO_VENDOR_SITES PVS,
                      PO_HEADERS PH,
                      PO_RELEASES PR,
                      PO_LINES PL,
                      PO_DISTRIBUTIONS PD,
                      PO_LINE_LOCATIONS PLL,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.source_distribution_id_num_1 = PBD.distribution_id AND
                      decode(pbd.distribution_type,
                             'REQUISITION', 'PO_REQ_DISTRIBUTIONS_ALL',
                             'PO_DISTRIBUTIONS_ALL') = xdl.source_distribution_type AND
                      pbd.ae_event_id = xdl.event_id AND
                       NVL(PBD.applied_to_dist_id_2, pbd.distribution_id) = XDL.ALLOC_TO_DIST_ID_NUM_1 AND
                      PBRV.event_id = PBD.ae_event_id AND
                      PBRV.application_id = XDL.application_id AND
                      PBRV.event_id = XDL.event_id AND
                      PBRV.ae_header_id = XDL.ae_header_id AND
                      PBRV.ae_line_num = XDL.ae_line_num AND
                      XDL.event_class_code IN ('RELEASE') AND
                      PBD.po_release_id = PR.po_release_id(+) AND
                      PBD.header_id = PH.po_header_id AND
                      PH.vendor_id = PV.vendor_id(+) AND
                      PH.vendor_site_id = PVS.vendor_site_id(+) AND
                      PBD.distribution_id = PD.po_distribution_id AND
                      PD.po_line_id = PL.po_line_id(+) AND
                      PD.line_location_id = PLL.line_location_id(+) AND
                      PBRV.application_id = 201 AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                      psa_utils.debug_other_string(g_state_level,l_api_name,'PO Query 3 returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
        END IF;

        -- Following query has been added as requested by PO Team in Bug 5253878

        SELECT   NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 text_line,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 segment1,
                 CASE WHEN (DISTRIBUTION_TYPE='STANDARD') OR
                           (DISTRIBUTION_TYPE='PLANNED')  OR
                           (DISTRIBUTION_TYPE='AGREEMENT') THEN
                         line_num||'-'||shipment_num||'-'||distribution_num
                      WHEN (DISTRIBUTION_TYPE='REQUISITION')THEN
                         line_num||'-'||distribution_num
                     ELSE
                         TO_CHAR(line_num)
                 END CASE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 'O',
		 NULL,
                 NULL
         bulk collect INTO    l_dump
         FROM    po_online_report_text
         WHERE   online_report_id = PO_DOCUMENT_FUNDS_GRP.get_online_report_id
                 AND nvl(show_in_psa_flag, 'N') = 'Y';

         psa_utils.debug_other_string(g_state_level,l_api_name,'PO Query 4 returned '||sql%rowcount||' rows.');

         populate_tab;

         psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

    -- Process for FV
    ELSIF p_para_rec.application_id = 8901 THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          'Federal Budget'                      BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          PBRV.JE_CATEGORY_NAME                   BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          PBRV.JE_BATCH_NAME                      TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          NULL                                    JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          DECODE(XLADIST.event_class_code,
                          'BUDGET_EXECUTION', BE.doc_number,
                          'RPR_BUDGET_EXECUTION',
                          RPR.doc_number)                         DOCUMENT_REFERENCE,
                          BET.REVISION_NUM                        LINE_REFERENCE,
                          NULL                                    BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          NULL                                    PARTY_ID,
                          NULL                                    PARTY_SITE_ID,
                          NULL                                    VENDOR_NAME,
                          NULL                                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      XLA_DISTRIBUTION_LINKS XLADIST,
                      FV_BE_TRX_HDRS BE,
                      FV_BE_TRX_DTLS BET,
                      FV_BE_RPR_TRANSACTIONS RPR,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.application_id = 8901 AND
                      PBRV.application_id = XLADIST.application_id AND
                      PBRV.source_distribution_id_num_1 = XLADIST.source_distribution_id_num_1 AND
                      PBRV.source_distribution_type = XLADIST.source_distribution_type AND
                      PBRV.ae_header_id = XLADIST.ae_header_id AND
                      PBRV.ae_line_num = XLADIST.ae_line_num AND
                      PBRV.source_distribution_id_num_1 = BET.transaction_id (+) AND
                      BE.doc_id = BET.doc_id AND
                      PBRV.source_distribution_id_num_1 = RPR.transaction_id (+) AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                      psa_utils.debug_other_string(g_state_level,l_api_name,'FV Query returned '||sql%rowcount||' rows.');

                      populate_tab;

                      psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

    -- Process for PSB
    ELSIF (p_para_rec.application_id = 8401) THEN

                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          PBRV.JE_LINE_NUM                        JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_1      DOCUMENT_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_2      LINE_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_3      BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          PBRV.REFERENCE1                         PARTY_ID,
                          PBRV.REFERENCE2                         PARTY_SITE_ID,
                          NULL                                    VENDOR_NAME,
                          NULL                                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          DECODE(PBRV.TEMPLATE_ID,
                          NULL, 'N', 'Y')                         SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O'   ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.application_id = p_para_rec.application_id AND
                      PBRV.packet_id = PBRE.packet_id; -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause


                psa_utils.debug_other_string(g_state_level,l_api_name,'PSB Query returned '||sql%rowcount||' rows.');

                populate_tab;

                psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

    -- For all other products
    ELSE
                SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                          PBRV.APPLICATION_SHORT_NAME,
                          PBRV.APPLICATION_NAME,
                          PBRV.EVENT_ID,
                          PBRV.LEDGER_ID,
                          PBRV.ROW_ID,
                          PBRV.PACKET_ID,
                          PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                          PBRV.FUNDING_BUDGET_NAME,
                          NULL                                    BUDGET_TYPE,
                          PBRV.BUDGET_VERSION_ID,
                          PBRV.JE_SOURCE_NAME,
                          PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                          NULL                                    BUDGET_LEVEL,
                          PBRV.BATCH_NAME,
                          NULL                                    TREASURY_SYMBOL,
                          PBRV.JE_BATCH_ID,
                          PBRV.JE_HEADER_ID,
                          PBRV.HEADER_NAME,
                          PBRV.JE_LINE_NUM                        JOURNAL_LINE_NUMBER,
                          PBRV.CODE_COMBINATION_ID                CCID,
                          PBRV.USSGL_TRANSACTION_CODE,
                          PBRV.ACCOUNT_TYPE,
                          PBRV.ACCOUNT_TYPE_MEANING,
                          PBRV.ACCOUNT_CATEGORY_CODE,
                          PBRV.ACCOUNT_SEGMENT_VALUE,
                          PBRV.ACTUAL_FLAG,
                          PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                          PBRV.AMOUNT_TYPE,
                          PBRV.AMOUNT_TYPE_MEANING,
                          PBRV.ENCUMBRANCE_TYPE,
                          PBRV.TEMPLATE_ID,
                          PBRV.CURRENCY_CODE                      CURRENCY,
                          PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                          PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                          PBRV.EFFECTIVE_STATUS,
                          PBRV.FUNDS_CHECK_LEVEL_CODE,
                          PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                          PBRV.RESULT_CODE,
                          PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                          PBRV.BOUNDARY_CODE,
                          PBRV.BOUNDARY_MEANING                   BOUNDARY,
                          PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                          PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                          PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                          PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                          PBRV.BUDGET_POSTED_BALANCE,
                          PBRV.BUDGET_APPROVED_BALANCE,
                          PBRV.BUDGET_PENDING_BALANCE,
                          PBRV.BUDGET_TOTAL_BALANCE,
                          PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                          PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                          PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                          PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                          PBRV.ACTUAL_POSTED_BALANCE,
                          PBRV.ACTUAL_APPROVED_BALANCE,
                          PBRV.ACTUAL_PENDING_BALANCE,
                          PBRV.ACTUAL_TOTAL_BALANCE,
                          PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                          PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                          PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                          PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                          PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_1      DOCUMENT_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_2      LINE_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_3      BATCH_REFERENCE,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                          PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                          NULL                                    PARTY_ID,
                          NULL                                    PARTY_SITE_ID,
                          NULL                                    VENDOR_NAME,
                          NULL                                    VENDOR_SITE_NAME,
                          NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                          NULL                                    PA_FLAG,
                          FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)               ACCOUNTING_FLEXFIELD,
                          DECODE(PBRV.TEMPLATE_ID,
                          NULL, 'N', 'Y')                         SUMMARY_ACCOUNT_INDICATOR,
                          NULL                                    PO_LINE_NUMBER,
                          NULL                                    PO_DIST_LINE_NUMBER,
                          NULL                                    PO_SHIP_LINE_NUMBER,
                          NULL                                    REQ_LINE_NUMBER,
                          NULL                                    REQ_DIST_LINE_NUMBER,
                          NULL                                    INV_LINE_NUMBER,
                          NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                          PBRV.AE_HEADER_ID,
                          PBRV.AE_LINE_NUM,
                          PBRV.PERIOD_NUM,
                          PBRV.PERIOD_YEAR,
                          PBRV.QUARTER_NUM,

                          PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                          PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                          PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                          PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                          PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                          PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                          PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                          PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                          'O' ERROR_SOURCE,
			  PBRV.CURRENT_FUNDS_AVAILABLE,
                          NULL                                    DOCUMENT_STATUS
                BULK COLLECT INTO l_dump
                FROM  PSA_BC_REPORT_V PBRV,
                      PSA_BC_REPORT_EVENTS_GT PBRE
                WHERE PBRV.ledger_id = p_para_rec.ledger_id AND
                      PBRV.application_id = p_para_rec.application_id AND
                      (((p_para_rec.packet_event_flag = 'P' OR x_source = 'CP') AND
                      PBRV.packet_id = PBRE.packet_id)
                      OR
                       (p_para_rec.packet_event_flag = 'E' AND
                        PBRE.event_id = PBRV.event_id AND
                        NVL(PBRE.source_distribution_id_num_1,0) = NVL(PBRV.source_distribution_id_num_1,0) AND
                        NVL(PBRE.source_distribution_id_num_2,0) = NVL(PBRV.source_distribution_id_num_2,0) AND
                        NVL(PBRE.source_distribution_id_num_3,0) = NVL(PBRV.source_distribution_id_num_3,0) AND
                        NVL(PBRE.source_distribution_id_num_4,0) = NVL(PBRV.source_distribution_id_num_4,0) AND
                        NVL(PBRE.source_distribution_id_num_5,0) = NVL(PBRV.source_distribution_id_num_5,0))
                       );  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

                psa_utils.debug_other_string(g_state_level,l_api_name,'Other Query returned '||sql%rowcount||' rows.');

                populate_tab;

                psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');
    END IF;

    -- If product has uptaken SLA then insert errors from PSA_BC_ACCOUNTING_ERRORS
    -- in the plsql table which will be inserted in psa_bc_results_rpt_gt

    IF l_sla_uptake_prod = 'Y' AND p_para_rec.packet_event_flag = 'E' THEN
       OPEN c_xla_accounting_errors;
       FETCH c_xla_accounting_errors BULK COLLECT INTO l_dump;
       psa_utils.debug_other_string(g_state_level,l_api_name,'SLA Accounting Errors Query returned '||sql%rowcount||' rows.');
       populate_tab;
       CLOSE c_xla_accounting_errors;
    END IF;

    -- XLA Manual journals Query

    l_event_id := NULL;
    IF x_source = 'FORM' THEN
        IF p_para_rec.packet_event_flag = 'P' THEN
            select EVENT_ID
            into   l_event_id
            from   gl_bc_packets
            where  packet_id in (select packet_id from psa_bc_report_events_gt)
            and    template_id is NULL
            and    rownum = 1;
        END IF;
        psa_utils.debug_other_string(g_state_level,l_api_name,'l_event_id = ' || l_event_id);
    END IF;

    IF l_sla_uptake_prod = 'Y' THEN
        IF l_event_id = -1 THEN
            SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
                     PBRV.APPLICATION_SHORT_NAME,
                     PBRV.APPLICATION_NAME,
                     PBRV.EVENT_ID,
                     PBRV.LEDGER_ID,
                     PBRV.ROW_ID,
                     PBRV.PACKET_ID,
                     PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                     PBRV.FUNDING_BUDGET_NAME,
                     NULL                                    BUDGET_TYPE,
                     PBRV.BUDGET_VERSION_ID,
                     PBRV.JE_SOURCE_NAME,
                     PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                     NULL                                    BUDGET_LEVEL,
                     PBRV.BATCH_NAME,
                     NULL                                    TREASURY_SYMBOL,
                     PBRV.JE_BATCH_ID,
                     PBRV.JE_HEADER_ID,
                     PBRV.HEADER_NAME,
                     PBRV.JE_LINE_NUM                        JOURNAL_LINE_NUMBER,
                     PBRV.CODE_COMBINATION_ID                CCID,
                     PBRV.USSGL_TRANSACTION_CODE,
                     PBRV.ACCOUNT_TYPE,
                     PBRV.ACCOUNT_TYPE_MEANING,
                     PBRV.ACCOUNT_CATEGORY_CODE,
                     PBRV.ACCOUNT_SEGMENT_VALUE,
                     PBRV.ACTUAL_FLAG,
                     PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                     PBRV.AMOUNT_TYPE,
                     PBRV.AMOUNT_TYPE_MEANING,
                     PBRV.ENCUMBRANCE_TYPE,
                     PBRV.TEMPLATE_ID,
                     PBRV.CURRENCY_CODE                      CURRENCY,
                     PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                     PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                     PBRV.EFFECTIVE_STATUS,
                     PBRV.FUNDS_CHECK_LEVEL_CODE,
                     PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                     PBRV.RESULT_CODE,
                     PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                     PBRV.BOUNDARY_CODE,
                     PBRV.BOUNDARY_MEANING                   BOUNDARY,
                     PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                     PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                     PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                     PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                     PBRV.BUDGET_POSTED_BALANCE,
                     PBRV.BUDGET_APPROVED_BALANCE,
                     PBRV.BUDGET_PENDING_BALANCE,
                     PBRV.BUDGET_TOTAL_BALANCE,
                     PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                     PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                     PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                     PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                     PBRV.ACTUAL_POSTED_BALANCE,
                     PBRV.ACTUAL_APPROVED_BALANCE,
                     PBRV.ACTUAL_PENDING_BALANCE,
                     PBRV.ACTUAL_TOTAL_BALANCE,
                     PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                     PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                     PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                     PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                     PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                     PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                     PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                     PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                     PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                     PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                     PBRV.HEADER_NAME                        DOCUMENT_REFERENCE,              -- Bug 5579424
                     TO_CHAR(PBRV.AE_HEADER_ID) || '-' ||
                     TO_CHAR(PBRV.AE_LINE_NUM)               LINE_REFERENCE,
                     PBRV.BATCH_NAME                         BATCH_REFERENCE,
                     PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                     PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                     NULL                                    PARTY_ID,
                     NULL                                    PARTY_SITE_ID,
                     NULL                                    VENDOR_NAME,
                     NULL                                    VENDOR_SITE_NAME,
                     NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                     NULL                                    PA_FLAG,
                     FND_FLEX_EXT.GET_SEGS('SQLGL',
                              'GL#', l_coaid,
                              PBRV.code_combination_id)      ACCOUNTING_FLEXFIELD,
                     'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                     NULL                                    PO_LINE_NUMBER,
                     NULL                                    PO_DIST_LINE_NUMBER,
                     NULL                                    PO_SHIP_LINE_NUMBER,
                     NULL                                    REQ_LINE_NUMBER,
                     NULL                                    REQ_DIST_LINE_NUMBER,
                     NULL                                    INV_LINE_NUMBER,
                     NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                     PBRV.AE_HEADER_ID,
                     PBRV.AE_LINE_NUM,
                     PBRV.PERIOD_NUM,
                     PBRV.PERIOD_YEAR,
                     PBRV.QUARTER_NUM,

                     PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                     PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                     PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                     PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                     PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                     PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                     PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                     PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                     'O' ERROR_SOURCE,
    		     PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                     NULL                                    DOCUMENT_STATUS
           BULK COLLECT INTO l_dump
           FROM  PSA_BC_REPORT_V PBRV,
                 PSA_BC_REPORT_EVENTS_GT PBRE
           WHERE PBRV.packet_id = PBRE.packet_id
           and   template_id is NULL;  -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

           psa_utils.debug_other_string(g_state_level,l_api_name,'XLA Manual journals Query1 returned '||sql%rowcount||' rows.');

           populate_tab;

           psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

	ELSE
	   SELECT /*+ leading(PBRE) */ PBRV.APPLICATION_ID,
	             PBRV.APPLICATION_SHORT_NAME,
                 PBRV.APPLICATION_NAME,
               	 PBRV.EVENT_ID,
                 PBRV.LEDGER_ID,
       	         PBRV.ROW_ID,
                 PBRV.PACKET_ID,
       	         PBRV.PERIOD_NAME                        GL_PERIOD_NAME,
                 PBRV.FUNDING_BUDGET_NAME,
                 NULL                                    BUDGET_TYPE,
       	         PBRV.BUDGET_VERSION_ID,
                 PBRV.JE_SOURCE_NAME,
       	         PBRV.JE_CATEGORY_NAME                   JE_CATEGORY_NAME,
                 NULL                                    BUDGET_LEVEL,
       	         PBRV.BATCH_NAME,
                 NULL                                    TREASURY_SYMBOL,
       	         PBRV.JE_BATCH_ID,
               	 PBRV.JE_HEADER_ID,
                 PBRV.HEADER_NAME,
       	         PBRV.JE_LINE_NUM                        JOURNAL_LINE_NUMBER,
               	 PBRV.CODE_COMBINATION_ID                CCID,
                 PBRV.USSGL_TRANSACTION_CODE,
                 PBRV.ACCOUNT_TYPE,
                 PBRV.ACCOUNT_TYPE_MEANING,
                 PBRV.ACCOUNT_CATEGORY_CODE,
                 PBRV.ACCOUNT_SEGMENT_VALUE,
                 PBRV.ACTUAL_FLAG,
                 PBRV.ACTUAL_FLAG_MEANING                BALANCE_TYPE,
                 PBRV.AMOUNT_TYPE,
                 PBRV.AMOUNT_TYPE_MEANING,
                 PBRV.ENCUMBRANCE_TYPE,
                 PBRV.TEMPLATE_ID,
                 PBRV.CURRENCY_CODE                      CURRENCY,
                 PBRV.STATUS_CODE                        FUNDS_CHECK_STATUS_CODE,
                 PBRV.STATUS_CODE_MEANING                FUNDS_CHECK_STATUS,
                 PBRV.EFFECTIVE_STATUS,
                 PBRV.FUNDS_CHECK_LEVEL_CODE,
                 PBRV.LEVEL_MEANING                      FUNDS_CHECK_LEVEL_MEANING,
                 PBRV.RESULT_CODE,
                 PBRV.RESULT_CODE_MEANING                RESULT_MESSAGE,
                 PBRV.BOUNDARY_CODE,
                 PBRV.BOUNDARY_MEANING                   BOUNDARY,
                 PBRV.DR_CR_CODE                         DEBIT_CREDIT_INDICATOR,
                 PBRV.TRANSACTION_AMOUNT                 AMOUNT,
                 PBRV.ACCOUNTED_DR                       DEBIT_AMOUNT_ACCOUNTED,
                 PBRV.ACCOUNTED_CR                       CREDT_AMOUNT_ACCOUNTED,
                 PBRV.BUDGET_POSTED_BALANCE,
                 PBRV.BUDGET_APPROVED_BALANCE,
                 PBRV.BUDGET_PENDING_BALANCE,
                 PBRV.BUDGET_TOTAL_BALANCE,
                 PBRV.ENC_POSTED_BALANCE                 ENCUMBRANCE_POSTED_BALANCE,
                 PBRV.ENC_APPROVED_BALANCE               ENCUMBRANCE_APPROVED_BALANCE,
                 PBRV.ENC_PENDING_BALANCE                ENCUMBRANCE_PENDING_BALANCE,
                 PBRV.ENC_TOTAL_BALANCE                  ENCUMBRANCE_TOTAL_BALANCE,
                 PBRV.ACTUAL_POSTED_BALANCE,
                 PBRV.ACTUAL_APPROVED_BALANCE,
                 PBRV.ACTUAL_PENDING_BALANCE,
                 PBRV.ACTUAL_TOTAL_BALANCE,
                 PBRV.AVAIL_POSTED_BALANCE               AVAILABLE_POSTED_BALANCE,
                 PBRV.AVAIL_APPROVED_BALANCE             AVAILABLE_APPROVED_BALANCE,
                 PBRV.AVAIL_PENDING_BALANCE              AVAILABLE_PENDING_BALANCE,
                 PBRV.AVAIL_TOTAL_BALANCE                AVAILABLE_TOTAL_BALANCE,
                 PBRV.SOURCE_DISTRIBUTION_TYPE           SOURCE_DISTRIBUTION_TYPE,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_1,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_2,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_3,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_4,
                 PBRV.SOURCE_DISTRIBUTION_ID_NUM_5,
                 XAH.DESCRIPTION                         DOCUMENT_REFERENCE,              -- Bug 5579424
                 TO_CHAR(PBRV.AE_HEADER_ID) || '-' ||
                 TO_CHAR(PBRV.AE_LINE_NUM)               LINE_REFERENCE,
                 PBRV.BATCH_NAME                         BATCH_REFERENCE,
                 PBRV.SOURCE_DISTRIBUTION_ID_CHAR_4,
                 PBRV.SOURCE_DISTRIBUTION_ID_CHAR_5,
                 NULL                                    PARTY_ID,
                 NULL                                    PARTY_SITE_ID,
                 NULL                                    VENDOR_NAME,
                 NULL                                    VENDOR_SITE_NAME,
                 NULL                                    PAYMENT_FORECAST_LINE_NUMBER,
                 NULL                                    PA_FLAG,
                 FND_FLEX_EXT.GET_SEGS('SQLGL',
                          'GL#', l_coaid,
                          PBRV.code_combination_id)      ACCOUNTING_FLEXFIELD,
                 'N'                                     SUMMARY_ACCOUNT_INDICATOR,
                 NULL                                    PO_LINE_NUMBER,
                 NULL                                    PO_DIST_LINE_NUMBER,
                 NULL                                    PO_SHIP_LINE_NUMBER,
                 NULL                                    REQ_LINE_NUMBER,
                 NULL                                    REQ_DIST_LINE_NUMBER,
                 NULL                                    INV_LINE_NUMBER,
                 NULL                                    DOCUMENT_SEQUENCE_NUMBER,
                 PBRV.AE_HEADER_ID,
                 PBRV.AE_LINE_NUM,
                 PBRV.PERIOD_NUM,
                 PBRV.PERIOD_YEAR,
                 PBRV.QUARTER_NUM,

                 PBRV.COMM_ENC_POSTED_BAL                COMM_ENCUM_POSTED_BAL,
                 PBRV.COMM_ENC_APPROVED_BAL                COMM_ENCUM_APPROVED_BAL,
                 PBRV.COMM_ENC_PENDING_BAL               COMM_ENCUM_PENDING_BAL,
                 PBRV.COMM_ENC_TOTAL_BAL                 COMM_ENCUM_TOTAL_BAL,

                 PBRV.OBLI_ENC_POSTED_BAL                OBLI_ENCUM_POSTED_BAL,
                 PBRV.OBLI_ENC_APPROVED_BAL                OBLI_ENCUM_APPROVED_BAL,
                 PBRV.OBLI_ENC_PENDING_BAL               OBLI_ENCUM_PENDING_BAL,
                 PBRV.OBLI_ENC_TOTAL_BAL                 OBLI_ENCUM_TOTAL_BAL,

                 'O' ERROR_SOURCE,
		 PBRV.CURRENT_FUNDS_AVAILABLE            CURRENT_FUNDS_AVAILABLE,
                 NULL                                    DOCUMENT_STATUS
	   BULK COLLECT INTO l_dump
	   FROM  PSA_BC_REPORT_V PBRV,
	         XLA_AE_HEADERS XAH,
             XLA_DISTRIBUTION_LINKS XDL,
             PSA_BC_REPORT_EVENTS_GT PBRE
	   WHERE PBRV.application_id = XDL.application_id AND
             PBRV.event_id        = XDL.event_id AND
             PBRV.ae_header_id    = XDL.ae_header_id AND
             PBRV.ae_line_num     = XDL.ae_line_num AND
             XDL.event_class_code = 'MANUAL' AND
	     PBRV.application_id  = XAH.application_id AND
	     PBRV.ae_header_id    = XAH.ae_header_id  AND
             PBRV.ledger_id       = p_para_rec.ledger_id AND
             PBRV.application_id  = p_para_rec.application_id AND
             PBRV.packet_id = PBRE.packet_id; -- Bug 9200360 : Moved PSA_BC_REPORT_EVENTS_GT to the FROM clause

           psa_utils.debug_other_string(g_state_level,l_api_name,'XLA Manual journals Query2 returned '||sql%rowcount||' rows.');

           populate_tab;

           psa_utils.debug_other_string(g_state_level,l_api_name,'Populate_Tab Executed');

     END IF;     -- if l_event_id = -1
    END IF;

    -- Purge the GT table if it already holds rows. This is possible if report
    -- is reinvoked in the same session.

    DELETE from PSA_BC_RESULTS_GT;

    -- Insert all records from PLSQL table l_bc_results_rpt INTO psa_bc_results_rpt_gt

    FORALL i IN 1..l_bc_results_rpt.count
       INSERT INTO PSA_BC_RESULTS_GT
       VALUES l_bc_results_rpt(i);

   --delete
   IF x_source = 'CP' THEN
     psa_utils.debug_other_string(g_state_level,l_api_name,'Deleting unwanted rows from PSA_BC_RESULTS_GT to retain the latest Budgetary Control Transaction only');

     DELETE PSA_BC_RESULTS_GT GT1
     WHERE  (GT1.batch_reference, GT1.document_reference , GT1.line_reference, GT1.packet_id) NOT IN
        (SELECT GT2.batch_reference, GT2.document_reference, GT2.line_reference, max(GT2.packet_id)
         FROM PSA_BC_RESULTS_GT GT2
         GROUP BY GT2.batch_reference, GT2.document_reference, GT2.line_reference);
     psa_utils.debug_other_string(g_state_level,l_api_name,'Deleted '||sql%rowcount||' rows from psa_bc_results_gt.');
   END IF;


   IF p_para_rec.application_id IN (200, 201, 8901, 101) THEN
      OPEN c_is_summary_used;
      FETCH c_is_summary_used INTO l_summary_used;
      CLOSE c_is_summary_used;
      psa_utils.debug_other_string(g_state_level,l_api_name,'l_summary_used' || ' = ' || l_summary_used);
   END IF;

    -- Insert Summary Records seperately if product is AP, PO, FV
    -- Since the queries for these products have joins with respective
    -- product team tables, summary rows get filtered out.

    IF (p_para_rec.application_id IN (200, 201, 8901, 101)) AND (l_summary_used = 'Y') THEN

    -- Bug 5711972
    SELECT MIN(PBRG.APPLICATION_ID),
           MIN(PBRG.APPLICATION_SHORT_NAME),
           MIN(PBRG.APPLICATION_NAME),
           MIN(PBRG.EVENT_ID),
           MIN(PBRG.LEDGER_ID),
           MIN(PBRG.ROW_ID),
           MIN(PBRG.PACKET_ID),
           MIN(PBRV.PERIOD_NAME),
           MIN(BV.BUDGET_NAME),
           MIN(BV.BUDGET_TYPE),
           MIN(PBRV.BUDGET_VERSION_ID),
           MIN(PBRV.JE_SOURCE_NAME),
           MIN(PBRV.JE_CATEGORY_NAME),
           MIN(PBRG.BUDGET_LEVEL),
           MIN(PBRG.JE_BATCH_NAME),
           NULL,
           MIN(PBRG.JE_BATCH_ID),
           MIN(PBRG.JE_HEADER_ID),
           MIN(PBRG.JE_HEADER_NAME),
           'Summary',
           AH.SUMMARY_CODE_COMBINATION_ID,
           NULL,
           MIN(PBRG.ACCOUNT_TYPE),
           MIN(PBRG.ACCOUNT_TYPE_MEANING),
           MIN(PBRV.ACCOUNT_CATEGORY_CODE),
           MIN(PBRV.ACCOUNT_SEGMENT_VALUE),
           MIN(PBRV.ACTUAL_FLAG),
           MIN(PBRV.ACTUAL_FLAG_MEANING),
           MIN(PBRV.AMOUNT_TYPE),
           MIN(PBRV.AMOUNT_TYPE_MEANING),
           MIN(PBRV.ENCUMBRANCE_TYPE),
           MIN(SB.TEMPLATE_ID),
           MIN(PBRV.CURRENCY_CODE),
           MIN(PBRV.STATUS_CODE),
           MIN(PBRV.STATUS_CODE_MEANING),
           MIN(PBRV.EFFECTIVE_STATUS),
           MIN(PBRV.FUNDS_CHECK_LEVEL_CODE),
           MIN(PBRV.LEVEL_MEANING),
           MIN(PBRV.RESULT_CODE),
           MIN(PBRV.RESULT_CODE_MEANING),
           MIN(PBRV.BOUNDARY_CODE),
           MIN(PBRV.BOUNDARY_MEANING),
           MIN(PBRV.DR_CR_CODE),
           MIN(PBRV.TRANSACTION_AMOUNT),
           MIN(PBRV.ACCOUNTED_DR),
           MIN(PBRV.ACCOUNTED_CR),
           MIN(PBRV.BUDGET_POSTED_BALANCE),
           MIN(PBRV.BUDGET_APPROVED_BALANCE),
           MIN(PBRV.BUDGET_PENDING_BALANCE),
           MIN(PBRV.BUDGET_TOTAL_BALANCE),
           MIN(PBRV.ENC_POSTED_BALANCE),
           MIN(PBRV.ENC_APPROVED_BALANCE),
           MIN(PBRV.ENC_PENDING_BALANCE),
           MIN(PBRV.ENC_TOTAL_BALANCE),
           MIN(PBRV.ACTUAL_POSTED_BALANCE),
           MIN(PBRV.ACTUAL_APPROVED_BALANCE),
           MIN(PBRV.ACTUAL_PENDING_BALANCE),
           MIN(PBRV.ACTUAL_TOTAL_BALANCE),
           MIN(PBRV.AVAIL_POSTED_BALANCE),
           MIN(PBRV.AVAIL_APPROVED_BALANCE),
           MIN(PBRV.AVAIL_PENDING_BALANCE),
           MIN(PBRV.AVAIL_TOTAL_BALANCE),
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           PBRG.DOCUMENT_REFERENCE,
           'Summary',
           PBRG.BATCH_REFERENCE,
           NULL,
           NULL,
           MIN(PBRG.PARTY_ID),
           MIN(PBRG.PARTY_SITE_ID),
           PBRG.VENDOR_NAME,
           PBRG.VENDOR_SITE_NAME,
           NULL,
           MIN(PBRG.PA_FLAG),
           MIN(FND_FLEX_EXT.GET_SEGS('SQLGL', 'GL#', l_coaid, pbrv.code_combination_id)),
           'Y',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           MIN(PBRV.PERIOD_NUM),
           MIN(PBRV.PERIOD_YEAR),
           MIN(PBRV.QUARTER_NUM),
           MIN(PBRV.COMM_ENC_POSTED_BAL),
           MIN(PBRV.COMM_ENC_APPROVED_BAL),
           MIN(PBRV.COMM_ENC_PENDING_BAL),
           MIN(PBRV.COMM_ENC_TOTAL_BAL),
           MIN(PBRV.OBLI_ENC_POSTED_BAL),
           MIN(PBRV.OBLI_ENC_APPROVED_BAL),
           MIN(PBRV.OBLI_ENC_PENDING_BAL),
           MIN(PBRV.OBLI_ENC_TOTAL_BAL),
           MIN(PBRG.ERROR_SOURCE),
	   MIN(PBRV.CURRENT_FUNDS_AVAILABLE),
           NULL
     BULK COLLECT INTO l_sum_dump
    FROM PSA_BC_RESULTS_GT PBRG,
         GL_PERIOD_STATUSES PS,
         GL_SUMMARY_TEMPLATES ST,
         GL_ACCOUNT_HIERARCHIES AH,
         GL_BUDGETS B,
         GL_BUDGET_VERSIONS BV,
         GL_SUMMARY_BC_OPTIONS SB,
         GL_PERIOD_STATUSES PS2,
         PSA_BC_REPORT_V PBRV
    WHERE pbrg.ccid IS NOT NULL
      AND ah.ledger_id =   p_para_rec.ledger_id
      AND ah.detail_code_combination_id = PBRG.CCID
      AND ps2.ledger_id = p_para_rec.ledger_id
      AND ps2.application_id = 101
      AND PS2.period_name = pbrg.period_name
      AND PS2.start_date >= (SELECT P1.start_date
                             FROM   GL_PERIOD_STATUSES P1
                             WHERE  P1.application_id = ps2.application_id
                               AND  P1.ledger_id = ps2.ledger_id
                               AND  P1.period_name = B.first_valid_period_name)
      AND PS2.end_date <= (SELECT P2.end_date
                           FROM   GL_PERIOD_STATUSES P2
                           WHERE  P2.application_id = ps2.application_id
                             AND  P2.ledger_id = ps2.ledger_id
                             AND  P2.period_name = B.last_valid_period_name)
      AND st.status = 'F'
      AND st.template_id = ah.template_id
      AND sb.funding_budget_version_id = BV.budget_version_id
      AND st.account_category_code = decode(pbrg.account_type, 'D', 'B', 'C', 'B', 'P')
      AND ps.ledger_id = p_para_rec.ledger_id
      AND ps.application_id = 101
      AND ps.period_name = st.start_actuals_period_name
      AND (ps.period_year * 10000 + ps.period_num) <=
          (pbrg.period_year * 10000 + pbrg.period_num)
      AND SB.template_id = ST.template_id
      AND SB.funding_budget_version_id = BV.budget_version_id
      AND BV.budget_name = B.budget_name
      AND pbrv.code_combination_id = ah.summary_code_combination_id
      AND pbrv.packet_id = pbrg.packet_id
    GROUP BY AH.SUMMARY_CODE_COMBINATION_ID, PBRG.DOCUMENT_REFERENCE, PBRG.BATCH_REFERENCE, PBRV.PERIOD_NAME,
             PBRG.VENDOR_NAME, PBRG.VENDOR_SITE_NAME;

     -- Bug 5711972
    populate_sum_tabs;

     FORALL i IN 1..l_bc_summary_rpt.count
       INSERT INTO PSA_BC_RESULTS_GT
       VALUES l_bc_summary_rpt(i);

    END IF;

    -- Bug 9200360 : Deleting the populated records in PSA_BC_REPORT_EVENTS_GT
    IF x_source = 'CP' THEN

        psa_utils.debug_other_string(g_state_level,l_api_name, 'Deleting records in PSA_BC_REPORT_EVENTS_GT');

        DELETE FROM PSA_BC_REPORT_EVENTS_GT;

        psa_utils.debug_other_string(g_state_level,l_api_name, 'End of deleting records in PSA_BC_REPORT_EVENTS_GT');

    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'Summary Query returned '||sql%rowcount||' rows.');

    -- Bug 5512107 : Section added to compute overall document budgetary status

    for x in c_document_status
    loop

       IF (x.total_count = x.approved_count) THEN
          l_document_status := 'A';
       ELSIF (x.total_count = x.reject_count) THEN
          l_document_status := 'R';
       ELSIF (x.total_count = (x.approved_count + x.reject_count)) THEN
          l_document_status := 'Y';
       ELSIF (x.total_count = x.success_count) THEN
          l_document_status := 'S';
       ELSIF (x.total_count = x.fail_count) THEN
          l_document_status := 'F';
       ELSIF (x.total_count = (x.success_count + x.fail_count)) THEN
          l_document_status := 'X';
       ELSIF (x.total_count = x.fatal_count) THEN
          l_document_status := 'T';
       END IF;

       IF l_document_status IS NOT NULL THEN

          SELECT description into l_meaning
          FROM gl_lookups
          WHERE lookup_type = 'FUNDS_CHECK_STATUS_CODE' and
                lookup_code = l_document_status;

       END IF;

       UPDATE psa_bc_results_gt
       SET document_status = l_meaning
       WHERE nvl(APPLICATION_NAME, '-99') = nvl(x.application_name, '-99') AND
             nvl(batch_reference, '-99')  = nvl(x.batch_reference, '-99') AND
             nvl(document_reference, '-99') = nvl(x.document_reference, '-99') AND
             nvl(vendor_name, '-99') = nvl(x.vendor_name, '-99') AND
             nvl(vendor_site_name, '-99') = nvl(x.vendor_site_name, '-99');

    end loop;

    -- End of Section added to compute overall document budgetary status

    -- Bug 5713831, Added statement below to update lookup values

    UPDATE psa_bc_results_gt rg
    SET actual_flag_meaning = (SELECT description
                               FROM gl_lookups
                               WHERE lookup_code = rg.actual_flag
                                 AND lookup_type = 'BATCH_TYPE');

    UPDATE psa_bc_results_gt rg
    SET funds_check_status = nvl((SELECT meaning
                              FROM gl_lookups
                              WHERE lookup_code = rg.funds_check_status_code
                                AND lookup_type = 'FUNDS_CHECK_STATUS_CODE'),
                                decode(rg.funds_check_status_code, 'Z', 'Accounting could not be created', ' '))  ;

    UPDATE psa_bc_results_gt rg
    SET result_message = (SELECT description
                          FROM gl_lookups
                          WHERE lookup_code = rg.result_code
                            AND lookup_type = 'FUNDS_CHECK_RESULT_CODE')
    WHERE result_message IS NULL;

    UPDATE psa_bc_results_gt rg
    SET amount_type_meaning = (SELECT meaning
                               FROM gl_lookups
                               WHERE lookup_code = rg.amount_type
                                 AND lookup_type = 'PTD_YTD');

    UPDATE psa_bc_results_gt rg
    SET boundary = (SELECT meaning
                    FROM gl_lookups
                    WHERE lookup_code = rg.boundary_code
                      AND lookup_type = 'BOUNDARY_TYPE');

    UPDATE psa_bc_results_gt rg
    SET funds_check_level_meaning = (SELECT meaning
                                     FROM gl_lookups
                                    WHERE lookup_code = rg.funds_check_level_code
                                      AND lookup_type = 'FUNDS_CHECK_LEVEL');

    UPDATE psa_bc_results_gt rg
    SET account_type_meaning = (SELECT description
                                FROM gl_lookups
                                WHERE lookup_code = rg.account_type
                                  AND lookup_type = 'ACCOUNT TYPE');

    -- End Bug 5713831

    x_report_query := 'SELECT PBRG.* FROM psa_bc_results_gt PBRG, GL_CODE_COMBINATIONS GLCC
                       WHERE PBRG.ccid = GLCC.code_combination_id(+) ';

    -- Dynamic WHERE clause
    psa_utils.debug_other_string(g_state_level,l_api_name,'Before Dynamic WHERE clause');
    psa_utils.debug_other_string(g_state_level,l_api_name,'x_return_status: ' || x_return_status);

    IF x_source = 'CP' THEN

        IF p_para_rec.BC_funds_check_status = 'P' THEN
            x_report_query :=  x_report_query ||
            ' AND PBRG.funds_check_status_code IN (''S'', ''A'') AND
              PBRG.result_code not in (''P20'', ''P22'', ''P25'', ''P27'', ''P29'', ''P31'', ''P35'', ''P36'', ''P37'', ''P38'', ''P39'' )
              AND PBRG.result_code like ''P%'' ';
        END IF;

        IF p_para_rec.BC_funds_check_status = 'W' THEN
            x_report_query :=  x_report_query ||
            ' AND PBRG.funds_check_status_code IN (''S'', ''A'') AND
            PBRG.result_code in(''P20'', ''P22'', ''P25'',''P27'', ''P29'', ''P31'', ''P35'', ''P36'', ''P37'', ''P38'', ''P39'')'|| '';
        END IF;

        IF p_para_rec.BC_funds_check_status = 'F' THEN
            x_report_query :=  x_report_query ||
            ' AND PBRG.funds_check_status_code in (''F'', ''R'', ''T'') AND (PBRG.result_code BETWEEN ''F00'' AND ''F75'')';
        END IF;

        IF p_para_rec.BC_funds_check_status = 'X' THEN
            x_report_query :=  x_report_query || ' AND PBRG.funds_check_status_code = ''X'' ';
        END IF;

        IF p_para_rec.ccid_low IS NOT NULL THEN

             -- Initialize the collection
             segment_name_tab  :=  name_type();
             segment_low_tab   :=  name_type();
             segment_high_tab  :=  name_type();

             -- Select individual segment information for this ledger
             FOR a IN c_seg_info(p_para_rec.ledger_id)
             LOOP
                segment_name_tab.extend;
                segment_name_tab(c_seg_info%ROWCOUNT) := a.application_column_name;
             END LOOP;

             SELECT FND_FLEX_APIS.get_segment_delimiter(101, 'GL#', p_para_rec.chart_of_accts_id) INTO l_delimiter
             FROM DUAL;
             psa_utils.debug_other_string(g_state_level,l_api_name,'CCID Segment Delimiter: ' || l_delimiter);

             -- select ccid low segments
             l_length  := LENGTH(p_para_rec.ccid_low);
             l_compt   := 1;
             l_counter := 1;
             l_pos     := 1;
             WHILE (l_compt <= l_length) LOOP
                l_pos := INSTR(p_para_rec.ccid_low,l_delimiter,l_compt,1);
                IF (l_pos = 0) THEN
                   segment_low_tab.extend;
                   segment_low_tab(l_counter) := SUBSTR(p_para_rec.ccid_low, l_compt, l_length);
                   EXIT;
                END IF;
                segment_low_tab.extend;
                segment_low_tab(l_counter) := SUBSTR(p_para_rec.ccid_low, l_compt, l_pos-l_compt);
                l_compt   := l_pos + 1;
                l_counter := l_counter + 1;
             END LOOP;

             -- select ccid high segments
             l_length  := LENGTH(p_para_rec.ccid_high);
             l_compt   := 1;
             l_counter := 1;
             l_pos     := 1;
             WHILE (l_compt <= l_length) LOOP
                l_pos := INSTR(p_para_rec.ccid_high,l_delimiter,l_compt,1);
                IF (l_pos = 0) THEN
                   segment_high_tab.extend;
                   segment_high_tab(l_counter) := SUBSTR(p_para_rec.ccid_high, l_compt, l_length);
                   EXIT;
                END IF;
                segment_high_tab.extend;
                segment_high_tab(l_counter) := SUBSTR(p_para_rec.ccid_high, l_compt, l_pos-l_compt);
                l_compt   := l_pos + 1;
                l_counter := l_counter + 1;
             END LOOP;

             FOR d IN 1..segment_name_tab.count
             LOOP
                x_report_query := x_report_query || ' AND GLCC.' || segment_name_tab(d)||' BETWEEN '
                                  || '''' || segment_low_tab(d) || '''' || ' AND '
                                  || '''' || segment_high_tab(d) || '''' ;
             END LOOP;

        END IF;


        psa_utils.debug_other_string(g_state_level,l_api_name,' After Dynamic WHERE clause');
        psa_utils.debug_other_string(g_state_level,l_api_name,' ' || x_return_status);

        -- Dynamic ORDER BY clause
        psa_utils.debug_other_string(g_state_level,l_api_name,' Before Dynamic ORDER BY clause');
        psa_utils.debug_other_string(g_state_level,l_api_name,' '|| x_return_status);

        IF p_para_rec.bc_funds_check_order_by is null or p_para_rec.bc_funds_check_order_by = 'A' THEN
            x_report_query :=  x_report_query||' ORDER BY PBRG.accounting_flexfield';
        END IF;

        IF p_para_rec.bc_funds_check_order_by = 'P' THEN
            x_report_query :=  x_report_query ||' ORDER BY PBRG.period_name';
        END IF;

        IF p_para_rec.bc_funds_check_order_by = 'L' THEN
            x_report_query :=  x_report_query ||' ORDER BY PBRG.line_reference';
        END IF;

        IF p_para_rec.bc_funds_check_order_by = 'S' THEN
            x_report_query :=  x_report_query ||' ORDER BY PBRG.funds_check_status_code';
        END IF;

        IF p_para_rec.bc_funds_check_order_by = 'R' THEN
            x_report_query :=  x_report_query ||' ORDER BY PBRG.result_code';
        END IF;

    END IF; -- End IF x_source='CP'

    IF x_source = 'FORM' THEN
       -- Adding ORDER BY clause
       x_report_query :=  x_report_query||' ORDER BY PBRG.ACCOUNTING_FLEXFIELD';
    END IF; -- End IF x_source='FORM'

    psa_utils.debug_other_string(g_state_level,l_api_name,'x_report_query = ' || x_report_query);
    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure build_report_query');

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: ' || SQLERRM(sqlcode));
        RAISE;
        psa_utils.debug_other_string(g_excep_level,l_api_name,' ' || x_return_status);
        psa_utils.debug_other_string(g_excep_level,l_api_name,'x_report_query' || ' = ' ||x_report_query);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        psa_utils.debug_other_string(g_error_level,l_api_name,' ' || x_return_status);
        psa_utils.debug_other_string(g_error_level,l_api_name,' ERROR IN QUERY STRING');
        RAISE FND_API.G_EXC_ERROR;

    ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_unexp_level,l_api_name,' ' || x_return_status);
        psa_utils.debug_other_string(g_unexp_level,l_api_name,'UNEXPECTED ERROR IN QUERY STRING');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END build_report_query;
-------------------------------------------------------------------------------
-- PROCEDURE get_xml
-- Start of Comments
-- Purpose:
-- Returns XML data for the query string
-- Also change XML data to given rowset tag and row tag
--
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_query         IN VARCHAR2,
    p_rowset_tag    IN VARCHAR2 DEFAULT NULL,
    p_row_tag       IN VARCHAR2 DEFAULT NULL,
    x_xml           OUT NOCOPY CLOB
) IS
l_api_name  VARCHAR2(240);
l_ctx       DBMS_XMLQUERY.ctxtype;
retcode     NUMBER;
l_len       NUMBER;
l_start     NUMBER:=1;
l_char_set  VARCHAR2(120);


BEGIN
    l_api_name := g_full_path||'get_xml';
    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure get_xml');

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- The value below is currently hard coded as a workaround. Hard coding should be removed later.
    -- l_char_set := 'UTF-8'; Removed for bug 6445210

    l_ctx := DBMS_XMLQUERY.newcontext(p_query);
    psa_utils.debug_other_string(g_state_level,l_api_name,'l_ctx type fetched successfully');

   -- DBMS_XMLQUERY.SetEncodingTag(l_ctx, l_char_set);
   -- psa_utils.debug_other_string(g_state_level,l_api_name,'Encoding set to '||l_char_set);

    -- change rowset tag
    IF p_rowset_tag IS NOT NULL THEN
        DBMS_XMLQUERY.setRowSetTag(l_ctx,  p_rowset_tag);
    END IF;

    -- change row tag
    IF p_row_tag IS NOT NULL THEN
        DBMS_XMLQUERY.setRowTag(l_ctx, p_row_tag);
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'p_rowset_tag' || ' = ' || p_rowset_tag);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_row_tag' || ' = ' || p_row_tag);

    l_len := length(p_query);
    while (l_start <= l_len)
    loop
        psa_utils.debug_other_string(g_state_level,l_api_name,'p_query' || ' = ' ||  substr(p_query,l_start,3500));
        l_start := l_start + 3500;
    end loop;

    DBMS_XMLQUERY.UseNullAttributeIndicator(l_ctx, TRUE);

    x_xml := DBMS_XMLQUERY.getXML(l_ctx);

    DBMS_XMLQUERY.closecontext(l_ctx);
    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure get_xml');


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        DBMS_XMLGEN.closecontext(l_ctx);
          psa_utils.debug_other_string(g_unexp_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
        RAISE;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        psa_utils.debug_other_string(g_error_level,l_api_name,' ' || x_return_status);
        psa_utils.debug_other_string(g_error_level,l_api_name,'ERROR IN GET_XML');
        RAISE FND_API.G_EXC_ERROR;
   ELSE x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_unexp_level,l_api_name,' ' || x_return_status);
        psa_utils.debug_other_string(g_unexp_level,l_api_name,' UNEXPECTED ERROR IN GET_XML');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END get_xml;

-------------------------------------------------------------------------------
-- PROCEDURE construct_bc_report_output
-- Start of Comments
-- Purpose:
-- Construct XML data source based on report parameters, XML data of
-- GL/IGC, format the data source to be XML Publisher compatible
--
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE construct_bc_report_output(
    x_return_status OUT NOCOPY VARCHAR2,
    x_source        IN VARCHAR2,
    p_para_rec      IN PSA_BC_XML_REPORT_PUB.funds_check_report_rec_type,
    p_trxs          IN CLOB
) IS
l_api_name                VARCHAR2(240);
l_para_meaning_list       VARCHAR2(2000);
l_ledger_name             GL_LEDGERS.name%TYPE;
l_application_short_name  VARCHAR2(8);
l_funds_check_status      PSA_LOOKUP_CODES.meaning%TYPE;
l_funds_check_order_by    PSA_LOOKUP_CODES.meaning%TYPE;
l_offset                  INTEGER;

BEGIN
    l_api_name := g_full_path||'construct_bc_report_output';

    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure construct_bc_report_output');

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Construct the parameter list section
    psa_utils.debug_other_string(g_state_level, l_api_name, 'Save the IN parameters in fnd log file');

    BEGIN
        -- Construct the output for the paramaters list of report
        IF x_source = 'CP' THEN
            IF p_para_rec.ledger_id IS NOT NULL THEN
                SELECT name
                  INTO l_ledger_name
                FROM   gl_ledgers
                WHERE  ledger_id = p_para_rec.ledger_id;
            END IF;
            IF p_para_rec.bc_funds_check_status IS NOT NULL THEN
                SELECT meaning
                  INTO l_funds_check_status
                FROM   PSA_LOOKUP_CODES
                WHERE  lookup_type = 'PSA_BC_FUNDS_CHECK_STATUS'
                  AND  lookup_code = p_para_rec.bc_funds_check_status;
            END IF;
            IF p_para_rec.BC_funds_check_order_by IS NOT NULL THEN
                SELECT meaning
                  INTO l_funds_check_order_by
                FROM   PSA_LOOKUP_CODES
               WHERE   lookup_type = 'PSA_BC_FUNDS_CHECK_ORDER_BY'
                 AND   lookup_code = p_para_rec.bc_funds_check_order_by;
            END IF;

            l_para_meaning_list :=
                '<?xml version="1.0"?>' ||
                '<REPORT_ROOT>' ||
                '<PARAMETERS>' ||
                '<PARA_LEDGER>'||p_para_rec.ledger_id||'</PARA_LEDGER>'||
                '<PARA_PERIOD_FROM>'||p_para_rec.period_from||'</PARA_PERIOD_FROM>'||
                '<PARA_PERIOD_TO>'||p_para_rec.period_to||'</PARA_PERIOD_TO>'||
                '<PARA_APPLICATION_SHORT_NAME>'||p_para_rec.application_short_name||'</PARA_APPLICATION_SHORT_NAME>'||
                '<PARA_FUNDS_CHECK_STATUS>'||p_para_rec.bc_funds_check_status||'</PARA_FUNDS_CHECK_STATUS>'||
                '<PARA_FUNDS_CHECK_ORDER_BY>'||p_para_rec.BC_funds_check_order_by||'</PARA_FUNDS_CHECK_ORDER_BY>'||
                '<URL>'||fnd_profile.value('APPS_FRAMEWORK_AGENT')||'</URL>'||
                '<REQUEST_ID>'||fnd_global.conc_request_id||'</REQUEST_ID>'||
                '</PARAMETERS>';
            END IF;

            IF x_source = 'FORM' THEN
                IF p_para_rec.application_id IS NOT NULL THEN
                    SELECT application_short_name
                      INTO l_application_short_name
                    FROM psa_bc_application_v
                    WHERE application_id = p_para_rec.application_id;
                END IF;

            l_para_meaning_list :=
                '<?xml version="1.0"?>' ||
                '<REPORT_ROOT>' ||
                '<PARAMETERS>' ||
                '<PARA_LEDGER>'||p_para_rec.ledger_id||'</PARA_LEDGER>'||
                '<PARA_APPLICATION_ID>'||p_para_rec.application_id||'</PARA_APPLICATION_ID>'||
                '<PARA_APPLICATION_SHORT_NAME>'||l_application_short_name||'</PARA_APPLICATION_SHORT_NAME>'||
                '<PARA_PACKET_EVENT>'||p_para_rec.packet_event_flag||'</PARA_PACKET_EVENT>'||
                '<PARA_SEQUENCE_ID>'||p_para_rec.sequence_id||'</PARA_SEQUENCE_ID>'||
                '</PARAMETERS>';
            END IF;
        EXCEPTION
        WHEN OTHERS THEN
            psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: ' || SQLERRM(sqlcode));
    END;


    -- Save the parameter list to output file

    FND_FILE.put_line(FND_FILE.output, l_para_meaning_list);

    psa_utils.debug_other_string(g_state_level,l_api_name,'xml_parameters' || ' = ' || l_para_meaning_list);

    -- Process the XML data source and save to output file
    psa_utils.debug_other_string(g_state_level,l_api_name,'construct both');

    IF DBMS_LOB.getlength(p_trxs) IS NULL THEN
        psa_utils.debug_other_string(g_state_level,l_api_name,' NO DATA FOUND - No XML Output Generated');
    ELSE
        -- trim header of  trxs
        -- save trxs
        l_offset := DBMS_LOB.instr (lob_loc => p_trxs,
                                    pattern => '?>',
                                    offset  => 1,
                                    nth     => 1);
        psa_utils.debug_other_string(g_state_level,l_api_name,'l_offset' || ' = ' || l_offset);
        -- Call to save_xml -
        psa_utils.debug_other_string(g_state_level,l_api_name,'Call to save_xml procedure');

        save_xml(x_return_status  => x_return_status,
                 x_source         => x_source,
                 p_application_id => p_para_rec.application_id,
                 p_sequence_id    => p_para_rec.sequence_id,
                 p_trxs           => p_trxs,
                 p_offset         => l_offset+2);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_FILE.put_line(FND_FILE.output, '</REPORT_ROOT>');
    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure construct_bc_report_output');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_unexp_level,l_api_name,'ERROR: ' || 'Unexpected Error in construct_bc_report_output Procedure');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        psa_utils.debug_other_string(g_error_level,l_api_name,'ERROR: ' || 'Error in construct_bc_report_output Procedure');
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION:' || SQLERRM(sqlcode));
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END construct_bc_report_output;

-------------------------------------------------------------------------------
-- PROCEDURE save_xml
-- Start of Comments
-- Purpose:
-- Save CLOB to concurrent program output file given CLOB offset
--
-- End of Comments
------------------------------------------------------------------------------
PROCEDURE save_xml(
    x_return_status   OUT NOCOPY VARCHAR2,
    x_source          IN VARCHAR2,
    p_application_id  IN NUMBER,
    p_sequence_id     IN NUMBER,
    p_trxs            IN CLOB,
    p_offset          IN INTEGER DEFAULT 1
) IS
l_api_name    VARCHAR2(240);
l_length      INTEGER;
l_buffer      VARCHAR2(32766);
l_amount      BINARY_INTEGER ;
l_pos         INTEGER;

BEGIN
    l_api_name := g_full_path||'save_xml';
    l_pos := p_offset;


    -- added for bug #5996038 by ks
    select  decode(userenv('LANG') ,'US', 32766 , 16332)
    into l_amount from dual;

    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure save_xml');

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_length := DBMS_LOB.getlength(p_trxs);

    psa_utils.debug_other_string(g_state_level,l_api_name,'l_amount' || ' = ' || l_amount);
    psa_utils.debug_other_string(g_state_level,l_api_name,'l_length' || ' = ' || l_length);
    psa_utils.debug_other_string(g_state_level,l_api_name,'l_pos' || ' = ' || l_pos);

    -- Inserting the XML CLOB value into PSA_BC_XML_CLOB table

    IF x_source = 'FORM' THEN
        save_xml_to_db(x_return_status   =>   x_return_status,
                       p_application_id  =>   p_application_id,
                       p_sequence_id     =>   p_sequence_id,
                       p_trxs            =>   p_trxs);

    ELSIF x_source = 'CP' THEN

        /* commit;  remove this */
        WHILE (l_pos <= l_length)
        LOOP
            DBMS_LOB.read(p_trxs, l_amount, l_pos, l_buffer);
            FND_FILE.put(FND_FILE.output, l_buffer);
            l_pos := l_pos + l_amount;
        END LOOP;

    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        psa_utils.debug_other_string(g_state_level,l_api_name ,'"SUCCESSFUL" creation of XML Data Output');
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure save_xml');

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
        RAISE;
END save_xml;

----------------------------------------------------------------------------------------------
PROCEDURE save_xml_to_db(
    x_return_status    OUT   NOCOPY VARCHAR2,
    p_application_id   IN NUMBER,
    p_sequence_id      IN NUMBER,
    p_trxs             IN CLOB
) IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name      VARCHAR2(240);
l_pos           INTEGER;
l_session_id    NUMBER;
l_serial_id     NUMBER;

BEGIN
    l_api_name := g_full_path||'save_xml_to_db';
    psa_utils.debug_other_string(g_state_level,l_api_name,'BEGIN of procedure save_xml_to_db');

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- delete old data i.e. data for older expired sessions or created 1 day earlier

    DELETE FROM psa_bc_xml_clob pbxc
    WHERE (((SYSDATE - pbxc.creation_date) > 1) OR
                      (NOT EXISTS (SELECT 'x'
                                   FROM v$session
                                   WHERE audsid = pbxc.session_id
                                   AND   Serial# = pbxc.serial_id)));

    psa_utils.debug_other_string(g_state_level,l_api_name,
	'No of rows deleted from psa_bc_xml_clob: '||SQL%ROWCOUNT);


    SELECT s.audsid, s.serial#
    INTO   l_session_id, l_serial_id
    FROM   v$session s, v$process p
    WHERE  s.paddr = p.addr
    AND    audsid = USERENV('SESSIONID');

    -- Inserting the XML CLOB value into PSA_BC_XML_CLOB table
    INSERT INTO psa_bc_xml_clob(sequence_id, application_id, session_id, serial_id, creation_date, xml)
    VALUES (p_sequence_id, p_application_id, l_session_id, l_serial_id, sysdate, p_trxs);

    psa_utils.debug_other_string(g_state_level,l_api_name,
	'No of rows inserted into psa_bc_xml_clob: '||SQL%ROWCOUNT);

    COMMIT;

    psa_utils.debug_other_string(g_state_level,l_api_name,'end of procedure save_xml_to_db');

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
        RAISE;
END save_xml_to_db;
END PSA_BC_XML_REPORT_PUB;

/

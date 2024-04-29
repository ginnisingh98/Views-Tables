--------------------------------------------------------
--  DDL for Package Body CST_UNINVOICEDRECEIPTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_UNINVOICEDRECEIPTS_PVT" AS
/* $Header: CSTVURRB.pls 120.7.12010000.7 2010/04/23 13:48:16 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='CST_UninvoicedReceipts_PVT';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_GL_APPLICATION_ID CONSTANT NUMBER       := 101;
G_PO_APPLICATION_ID CONSTANT NUMBER       := 201;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Start_Process
-- DESCRIPTION  :   Starting point for Uninvoiced Receipt Report
-----------------------------------------------------------------------------
PROCEDURE Start_Process
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER,

    p_title                         IN      VARCHAR2,
    p_accrued_receipts              IN      VARCHAR2,
    p_inc_online_accruals           IN      VARCHAR2,
    p_inc_closed_pos                IN      VARCHAR2,
    p_struct_num                    IN      NUMBER,
    p_category_from                 IN      VARCHAR2,
    p_category_to                   IN      VARCHAR2,
    p_min_accrual_amount            IN      NUMBER,
    p_period_name                   IN      VARCHAR2,
    p_vendor_from                   IN      VARCHAR2,
    p_vendor_to                     IN      VARCHAR2,
    p_orderby                       IN      NUMBER,
    p_qty_precision                 IN      NUMBER
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Start_Process';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    /* Log Severities*/
    /* 6- UNEXPECTED */
    /* 5- ERROR      */
    /* 4- EXCEPTION  */
    /* 3- EVENT      */
    /* 2- PROCEDURE  */
    /* 1- STATEMENT  */

    /* In general, we should use the following:
    G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
    */

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(240);

    l_header_ref_cur                SYS_REFCURSOR;
    l_body_ref_cur                  SYS_REFCURSOR;
    l_row_tag                       VARCHAR2(100);
    l_row_set_tag                   VARCHAR2(100);
    l_xml_header                    CLOB;
    l_xml_body                      CLOB;
    l_xml_report                    CLOB;

    l_conc_status                   BOOLEAN;
    l_return                        BOOLEAN;
    l_status                        VARCHAR2(1);
    l_industry                      VARCHAR2(1);
    l_schema                        VARCHAR2(30);
    l_application_id                NUMBER;
    l_legal_entity                  NUMBER;
    l_end_date                      DATE;
    l_sob_id                        NUMBER;
    l_order_by                      VARCHAR2(15);
    l_multi_org_flag                VARCHAR2(1);

    l_stmt_num                      NUMBER;
    l_row_count                     NUMBER;

BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS=''.,''';
    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start_Process <<' ||
               'p_title = '                 || p_title               ||','||
               'p_accrued_receipts = '      || p_accrued_receipts    ||','||
               'p_inc_online_accruals = '   || p_inc_online_accruals ||','||
               'p_inc_closed_pos = '        || p_inc_closed_pos      ||','||
               'p_struct_num = '            || p_struct_num          ||','||
               'p_category_from = '         || p_category_from       ||','||
               'p_category_to = '           || p_category_to         ||','||
               'p_min_accrual_amount = '    || p_min_accrual_amount  ||','||
               'p_period_name = '           || p_period_name         ||','||
               'p_vendor_from = '           || p_vendor_from         ||','||
               'p_vendor_to = '             || p_vendor_to           ||','||
               'p_orderby = '               || p_orderby             ||','||
               'p_qty_precision = '         || p_qty_precision
               );
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether GL is installed
    l_stmt_num := 10;
    l_return := FND_INSTALLATION.GET_APP_INFO (
                    'SQLGL',
                    l_status,
                    l_industry,
                    l_schema
                    );

    IF (l_status = 'I') THEN
        l_application_id := G_GL_APPLICATION_ID;
    ELSE
        l_application_id := G_PO_APPLICATION_ID;
    END IF;

    -- Convert Accrual Cutoff date from Legal entity timezone to
    -- Server timezone
    l_stmt_num := 20;

    SELECT set_of_books_id
    INTO   l_sob_id
    FROM   financials_system_parameters;

    SELECT  TO_NUMBER(org_information2)
    INTO    l_legal_entity
    FROM    hr_organization_information
    WHERE   organization_id = MO_GLOBAL.GET_CURRENT_ORG_ID
    AND     org_information_context = 'Operating Unit Information';

    l_stmt_num := 30;
    SELECT  INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE (gps.end_date,
                                                            l_legal_entity)
    INTO    l_end_date
    FROM    gl_period_statuses gps
    WHERE   gps.application_id = l_application_id
    AND     gps.set_of_books_id = l_sob_id
    AND     gps.period_name = NVL(p_period_name,
                                  (SELECT  gp.period_name
                                  FROM    gl_periods gp,
                                          gl_sets_of_books sob
                                  WHERE   sob.set_of_books_id = l_sob_id
                                  AND     sob.period_set_name = gp.period_set_name
                                  AND     sob.accounted_period_type = gp.period_type
                                  AND     gp.start_date <= TRUNC(SYSDATE)
                                  AND     gp.end_date >= TRUNC(SYSDATE))
                                  );

    ---------------------------------------------------------------------
    -- Call the common API CST_PerEndAccruals_PVT.Create_PerEndAccruals
    -- This API creates period end accrual entries in the temporary
    -- table CST_PER_END_ACCRUALS_TEMP.
    ---------------------------------------------------------------------
    l_stmt_num := 60;
    CST_PerEndAccruals_PVT.Create_PerEndAccruals (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_min_accrual_amount    => p_min_accrual_amount,
        p_vendor_from           => p_vendor_from,
        p_vendor_to             => p_vendor_to,
        p_category_from         => p_category_from,
        p_category_to           => p_category_to,
        p_end_date              => l_end_date,
        p_accrued_receipt       => NVL(p_accrued_receipts, 'N'),
        p_online_accruals       => NVL(p_inc_online_accruals, 'N'),
        p_closed_pos            => NVL(p_inc_closed_pos, 'N'),
        p_calling_api           => CST_PerEndAccruals_PVT.G_UNINVOICED_RECEIPT_REPORT
    );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed generating Period End Accrual information';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_stmt_num := 90;
    DBMS_LOB.createtemporary(l_xml_header, TRUE);
    DBMS_LOB.createtemporary(l_xml_body, TRUE);
    DBMS_LOB.createtemporary(l_xml_report, TRUE);

    -- Count the no. of rows in the accrual temp table
    -- l_row_count will be part of report header information
    l_stmt_num := 100;
    SELECT  COUNT('X')
    INTO    l_row_count
    FROM    CST_PER_END_ACCRUALS_TEMP
    WHERE   ROWNUM = 1;

    IF(p_orderby = 1) THEN
        l_order_by := 'Category';
    ELSIF(p_orderby = 2) THEN
        l_order_by := 'Vendor';
    ELSE
        l_order_by := ' ';
    END IF;

    -------------------------------------------------------------------------
    -- Open reference cursor for fetching data related to report header
    -------------------------------------------------------------------------
    l_stmt_num := 110;
    OPEN l_header_ref_cur FOR
        'SELECT gsb.name                        company_name,
                :p_title                        report_title,
                SYSDATE                         report_date,
                DECODE(:p_accrued_receipts,
                        ''Y'', ''Yes'',
                        ''N'', ''No'')          accrued_receipt,
                DECODE(:p_inc_online_accruals,
                        ''Y'', ''Yes'',
                        ''N'', ''No'')          include_online_accruals,
                DECODE(:p_inc_closed_pos,
                        ''Y'', ''Yes'',
                        ''N'', ''No'')          include_closed_pos,
                :p_category_from                category_from,
                :p_category_to                  category_to,
                :p_min_accrual_amount           minimum_accrual_amount,
                :p_period_name                  period_name,
                :p_vendor_from                  vendor_from,
                :p_vendor_to                    vendor_to,
                :l_order_by                     order_by,
                :l_row_count                    row_count
        FROM    gl_sets_of_books gsb
        WHERE   gsb.set_of_books_id = :l_sob_id'
        USING
                p_title,
                p_accrued_receipts,
                p_inc_online_accruals,
                p_inc_closed_pos,
                p_category_from,
                p_category_to,
                p_min_accrual_amount,
                p_period_name,
                p_vendor_from,
                p_vendor_to,
                l_order_by,
                l_row_count,
                l_sob_id;

    -- Set row_tag as HEADER for report header data
    l_row_tag := 'HEADER';
    l_row_set_tag := NULL;

    -- Generate XML data for header part
    l_stmt_num := 120;
    Generate_XML (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_ref_cur               => l_header_ref_cur,
        p_row_tag               => l_row_tag,
        p_row_set_tag           => l_row_set_tag,
        x_xml_data              => l_xml_header
    );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed generating XML data to the report output' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If row_count is 0, no need to open body_ref_cursor
    IF (l_row_count > 0) THEN

        ---------------------------------------------------------------------
        -- Open reference cursor for fetching data related to report body
        ---------------------------------------------------------------------
        l_stmt_num := 140;
        OPEN l_body_ref_cur FOR
            'SELECT NVL(poh.CLM_DOCUMENT_NUMBER,poh.SEGMENT1) po_number,--Changed as a part of CLM
                    porl.release_num                        po_release_number,
                    poh.po_header_id                        po_header_id,
                    pol.po_line_id                          po_line_id,
                    cpea.shipment_id                        po_shipment_id,
                    cpea.distribution_id                    po_distribution_id,
                    plt.line_type                           line_type,
                     nvl(POL.LINE_NUM_DISPLAY, to_char(POL.LINE_NUM)) line_num,--Changed as a part of CLM
                    msi.concatenated_segments               item_name,
                    mca.concatenated_segments               category,
                    pol.item_description                    item_description,
                    pov.vendor_name                         vendor_name,
                    fnc2.currency_code                      accrual_currency_code,
                    poll.shipment_num                       shipment_number,
                    poll.unit_meas_lookup_code              uom_code,
                    pod.distribution_num                    distribution_num,
                    cpea.quantity_received                  quantity_received,
                    cpea.quantity_billed                    quantity_billed,
                    cpea.accrual_quantity                   quantity_accrued,
                    ROUND(cpea.unit_price,
                            NVL(fnc2.extended_precision, 2))         po_unit_price,
                    cpea.currency_code                      po_currency_code,
                    ROUND(DECODE(NVL(fnc1.minimum_accountable_unit, 0),
                                     0, cpea.unit_price * cpea.currency_conversion_rate,
                                     (cpea.unit_price / fnc1.minimum_accountable_unit)
                                        * cpea.currency_conversion_rate
                                        * fnc1.minimum_accountable_unit),
                                          NVL(fnc1.extended_precision, 2))
                                                            func_unit_price,
                    gcc1.concatenated_segments              charge_account,
                    gcc2.concatenated_segments              accrual_account,
                    cpea.accrual_amount                     accrual_amount,
                    ROUND(DECODE(NVL(fnc1.minimum_accountable_unit, 0),
                                     0, cpea.accrual_amount * cpea.currency_conversion_rate,
                                     (cpea.accrual_amount / fnc1.minimum_accountable_unit)
                                        * cpea.currency_conversion_rate
                                        * fnc1.minimum_accountable_unit), NVL(fnc1.precision, 2))
                                                            func_accrual_amount,
                  nvl(fnc2.extended_precision,2)  PO_PRECISION,
                  nvl(fnc1.extended_precision,2)  PO_FUNC_PRECISION,
                  nvl(fnc1.precision,2)           ACCR_PRECISION
            FROM    cst_per_end_accruals_temp   cpea,
                    po_headers_all              poh,
                    po_lines_all                pol,
                    po_line_locations_all       poll,
                    po_distributions_all        pod,
                    po_vendors                  pov,
                    po_line_types               plt,
                    po_releases_all             porl,
                    mtl_system_items_kfv        msi,
                    fnd_currencies              fnc1,
                    fnd_currencies              fnc2,
                    mtl_categories_kfv          mca,
                    gl_code_combinations_kfv    gcc1,
                    gl_code_combinations_kfv    gcc2,
                    gl_sets_of_books sob
            WHERE   pod.po_distribution_id = cpea.distribution_id
            AND     poh.po_header_id = pol.po_header_id
            AND     pol.po_line_id = poll.po_line_id
            AND     poll.line_location_id = pod.line_location_id
            AND     pol.line_type_id = plt.line_type_id
            AND     porl.po_release_id (+)  = poll.po_release_id
            AND     poh.vendor_id = pov.vendor_id
            AND     msi.inventory_item_id (+)  = pol.item_id
            AND     (msi.organization_id IS NULL
                    OR
                    (msi.organization_id = poll.ship_to_organization_id AND msi.organization_id IS NOT NULL))
            AND     fnc1.currency_code =  cpea.currency_code
            AND     fnc2.currency_code = sob.currency_code
            AND     cpea.category_id = mca.category_id
            AND     gcc1.code_combination_id = pod.code_combination_id
            AND     gcc2.code_combination_id = pod.accrual_account_id
            AND     sob.set_of_books_id = :l_sob_id
            ORDER BY DECODE(:l_order_by,
                            ''Category'', mca.concatenated_segments,
                            ''Vendor'', pov.vendor_name),
                     NVL(poh.CLM_DOCUMENT_NUMBER,poh.SEGMENT1),
                     nvl(POL.LINE_NUM_DISPLAY, to_char(POL.LINE_NUM)),
                    poll.shipment_num,
                    pod.distribution_num'
            USING   l_sob_id, l_order_by
            ;

        l_row_tag := 'BODY';
        l_row_set_tag := 'ACCRUAL_INFO';

        -- Generate XML data for report body
        l_stmt_num := 150;
        Generate_XML (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_ref_cur               => l_body_ref_cur,
            p_row_tag               => l_row_tag,
            p_row_set_tag           => l_row_set_tag,
            x_xml_data              => l_xml_body
        );
        -- If return status is not success, add message to the log
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed generating XML data to the report output' ;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    -- Merge the header part with the body part.
    -- 'ACR_REPORT' will be used as root tag for resultant XML data
    l_stmt_num := 160;
    Merge_XML
    (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_xml_src1              => l_xml_header,
        p_xml_src2              => l_xml_body,
        p_root_tag              => 'ACR_REPORT',
        x_xml_doc               => l_xml_report
    );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed generating XML data to the report output' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Print the XML data to the report output
    l_stmt_num := 170;
    Print_ClobOutput(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_xml_data              => l_xml_report
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed writing XML data to the report output' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Write log messages to request log
    l_stmt_num := 180;
    CST_UTILITY_PUB.writelogmessages (
        p_api_version   => 1.0,
        p_msg_count     => l_msg_count,
        p_msg_data      => l_msg_data,
        x_return_status => l_return_status
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed writing log messages' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Start_Process >>'
               );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        -- Write log messages to request log
        CST_UTILITY_PUB.writelogmessages (
            p_api_version   => 1.0,
            p_msg_count     => l_msg_count,
            p_msg_data      => l_msg_data,
            x_return_status => l_return_status
            );

        -- Set concurrent program status to error
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_msg_data);

    WHEN OTHERS THEN

        -- Unexpected level log message for FND log
        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        -- Write log messages to request log
        CST_UTILITY_PUB.writelogmessages (
            p_api_version   => 1.0,
            p_msg_count     => l_msg_count,
            p_msg_data      => l_msg_data,
            x_return_status => l_return_status
            );

        -- Set concurrent program status to error
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                         'An unexpected error has occurred, please contact System Administrator. ');

END Start_Process;


-----------------------------------------------------------------------------
-- PROCEDURE    :   Generate_XML
-- DESCRIPTION  :   The procedure generates and returns the XML data for
--                  the reference cursor passed by the calling API.
-----------------------------------------------------------------------------
PROCEDURE Generate_XML
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_ref_cur                       IN      SYS_REFCURSOR,
    p_row_tag                       IN      VARCHAR2,
    p_row_set_tag                   IN      VARCHAR2,

    x_xml_data                      OUT     NOCOPY CLOB
)
IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Generate_XML';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);
    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_ctx                           DBMS_XMLGEN.CTXHANDLE;

BEGIN

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Generate_XML <<');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    l_return_status     := FND_API.G_RET_STS_SUCCESS;

    -- create a new context with the SQL query
    l_stmt_num := 10;
    l_ctx := DBMS_XMLGEN.newContext (p_ref_cur);

    -- Add tag names for rows and row sets
    l_stmt_num := 20;
    DBMS_XMLGEN.setRowSetTag(l_ctx, p_row_tag);
    DBMS_XMLGEN.setRowTag(l_ctx, p_row_set_tag);

    -- generate XML data
    l_stmt_num := 30;
    x_xml_data := DBMS_XMLGEN.getXML (l_ctx);

    -- close the context
    l_stmt_num := 40;
    DBMS_XMLGEN.CLOSECONTEXT(l_ctx);

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Generate_XML >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Unexpected level log message
        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Generate_XML;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Merge_XML
-- DESCRIPTION  :   The procedure merges data from two XML objects into a
--                  single XML object and adds a root tag to the resultant
--                  XML data.
-----------------------------------------------------------------------------
PROCEDURE Merge_XML
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_xml_src1                      IN      CLOB,
    p_xml_src2                      IN      CLOB,
    p_root_tag                      IN      VARCHAR2,

    x_xml_doc                       OUT     NOCOPY CLOB
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Merge_XML';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);
    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_ctx                           DBMS_XMLGEN.CTXHANDLE;
    l_offset                        NUMBER;
    l_stmt_num                      NUMBER;
    l_length_src1                   NUMBER;
    l_length_src2                   NUMBER;
    /*Bug 7282242*/
    l_encoding             VARCHAR2(20);
    l_xml_header           VARCHAR2(100);

BEGIN

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Merge_XML <<');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num := 10;
    l_length_src1 := DBMS_LOB.GETLENGTH(p_xml_src1);
    l_length_src2 := DBMS_LOB.GETLENGTH(p_xml_src2);

    l_stmt_num := 20;
    DBMS_LOB.createtemporary(x_xml_doc, TRUE);

    IF (l_length_src1 > 0) THEN

        -- Get the first occurence of XML header
        l_stmt_num := 30;
        l_offset := DBMS_LOB.instr (lob_loc => p_xml_src1,
                                    pattern => '>',
                                    offset  => 1,
                                    nth     => 1);

        -- Copy XML header part to the destination XML doc
        l_stmt_num := 40;

        /*Bug 7282242*/
        /*Remove the header (21 characters)*/
        --DBMS_LOB.copy (x_xml_doc, p_xml_src1, l_offset + 1);

        /*The following 3 lines of code ensures that XML data generated here uses the right encoding*/
        l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
        DBMS_LOB.writeappend (x_xml_doc, length(l_xml_header), l_xml_header);

        -- Append the root tag to the XML doc
        l_stmt_num := 50;
        DBMS_LOB.writeappend (x_xml_doc, LENGTH(p_root_tag) + 2, '<' || p_root_tag || '>');

        -- Append the 1st XML doc to the destination XML doc
        l_stmt_num := 60;
        DBMS_LOB.copy ( x_xml_doc,
                        p_xml_src1,
                        l_length_src1 - l_offset,
                        DBMS_LOB.GETLENGTH(x_xml_doc) + 1,
                        l_offset + 1
                        );

        -- Append the 2nd XML doc to the destination XML doc
        IF (l_length_src2 > 0) THEN
            l_stmt_num := 70;
            DBMS_LOB.copy ( x_xml_doc,
                            p_xml_src2,
                            l_length_src2 - l_offset,
                            DBMS_LOB.GETLENGTH(x_xml_doc) + 1,
                            l_offset + 1
                            );
        END IF;

        -- Append the root tag to the end of XML doc
        l_stmt_num := 80;
        DBMS_LOB.writeappend (x_xml_doc, LENGTH(p_root_tag) + 3, '</' || p_root_tag || '>');

    END IF;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Merge_XML >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Unexpected level log message
        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Merge_XML;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Merge_XML
-- DESCRIPTION  :   The procedure writes the XML data to the report output
--                  file. The XML publisher picks the data from this output
--                  file to display the data in user specified format.
-----------------------------------------------------------------------------
PROCEDURE Print_ClobOutput
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,
    p_xml_data                      IN      CLOB
)
IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Print_ClobOutput';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);
    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_amount                        NUMBER;
    l_offset                        NUMBER;
    l_length                        NUMBER;
    l_data                          VARCHAR2(32767);

BEGIN

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Print_ClobOutput <<');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get length of the CLOB p_xml_data
    l_stmt_num := 10;
    l_length := nvl(DBMS_LOB.getlength(p_xml_data), 0);

    -- Set the offset point to be the start of the CLOB data
    l_offset := 1;

    -- l_amount will be used to read 32KB of data once at a time
    l_amount := 16383;  --Changed for bug 6954937

  -- Loop until the length of CLOB data is zero
  l_stmt_num := 20;
  LOOP

    EXIT WHEN l_length <= 0;

    -- Read 32 KB of data and print it to the report output
    DBMS_LOB.read (p_xml_data, l_amount, l_offset, l_data);

    FND_FILE.PUT(FND_FILE.OUTPUT, l_data);

    l_length := l_length - l_amount;
    l_offset := l_offset + l_amount;

  END LOOP;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Print_ClobOutput >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Unexpected level log message
        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Print_ClobOutput;

END CST_UninvoicedReceipts_PVT;

/

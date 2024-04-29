--------------------------------------------------------
--  DDL for Package Body CST_RECEIPTACCRUALPEREND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_RECEIPTACCRUALPEREND_PVT" AS
/* $Header: CSTVRAPB.pls 120.12.12010000.6 2010/01/19 17:18:46 hyu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='CST_ReceiptAccrualPerEnd_PVT';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_GL_APPLICATION_ID CONSTANT NUMBER       := 101;
G_PO_APPLICATION_ID CONSTANT NUMBER       := 201;
G_CST_APPLICATION_ID CONSTANT NUMBER      := 707;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Start_Process
-- DESCRIPTION  :   Starting point for Receipt Accruals - Period End
--                  Concurrent Program.
-----------------------------------------------------------------------------
PROCEDURE Start_Process
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER,

    p_min_accrual_amount            IN      NUMBER,
    p_vendor_id                     IN      NUMBER,
    p_struct_num                    IN      NUMBER,
    p_category_id                   IN      NUMBER,
    p_period_name                   IN      VARCHAR2
)

IS
    l_api_name    CONSTANT          VARCHAR2(30) :='Start_process';
    l_api_version CONSTANT          NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(240);

    l_full_name   CONSTANT          VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module      CONSTANT          VARCHAR2(60) := 'cst.plsql.'||l_full_name;

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

    l_conc_status                   BOOLEAN;
    l_return                        BOOLEAN;
    l_status                        VARCHAR2(1);
    l_industry                      VARCHAR2(1);
    l_schema                        VARCHAR2(30);

    l_stmt_num                      NUMBER;
    l_sys_setup_rec                 CST_SYS_SETUP_REC_TYPE;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Start_Process_PVT;

    g_counter := 0;
    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start_Process <<'  ||
               'p_min_accrual_amount = '  || p_min_accrual_amount ||','||
               'p_vendor_id = '           || p_vendor_id          ||','||
               'p_struct_num = '          || p_struct_num         ||','||
               'p_category_id = '         || p_category_id        ||','||
               'p_period_name = '         || p_period_name
               );
    END IF;

    -- Initialize message list.
    FND_MSG_PUB.initialize;

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- Get system set-up information e.g. set_of_books, chart_of_accounts
    -- purchase_encumbrance_flag etc.
    -------------------------------------------------------------------------
    l_stmt_num := 20;
    Get_SystemSetup (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_period_name           => p_period_name,
        x_sys_setup_rec         => l_sys_setup_rec
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed getting system setup' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Call the common API CST_PerEndAccruals_PVT.Create_PerEndAccruals()
    -- This API creates period end accrual entries in the temporary table
    -- CST_PER_END_ACCRUALS_TEMP.
    -------------------------------------------------------------------------
    l_stmt_num := 40;
    CST_PerEndAccruals_PVT.Create_PerEndAccruals (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_min_accrual_amount    => p_min_accrual_amount,
        p_vendor_id             => p_vendor_id,
        p_category_id           => p_category_id,
        p_end_date              => l_sys_setup_rec.period_end_date,
        p_accrued_receipt       => 'N',
        p_online_accruals       => 'N',
        p_closed_pos            => 'N',
        p_calling_api           => CST_PerEndAccruals_PVT.G_RECEIPT_ACCRUAL_PER_END
    );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed generating Period End Accrual information';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Create events in RCV_ACCOUNTING_EVENTS
    -------------------------------------------------------------------------
    l_stmt_num := 50;
    Seed_RcvAccountingEvents (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_sys_setup_rec         => l_sys_setup_rec
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed creating event in RCV_ACCOUNTING_EVENTS' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Create accounting entries in RCV_RECEIVING_SUB_LEDGER
    -------------------------------------------------------------------------
    l_stmt_num := 60;
    Create_AccrualAccount (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_sys_setup_rec         => l_sys_setup_rec
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed creating Period End Accrual entries ' ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Update the Accrued PO distribution, and mark accrued_flag as 'Y'
    -------------------------------------------------------------------------
    l_stmt_num := 70;
    FORALL l_ctr IN g_accrued_dist_id_tbl.FIRST..g_accrued_dist_id_tbl.LAST
        UPDATE po_distributions_all pod
        SET    pod.accrued_flag = 'Y'
        WHERE  pod.po_distribution_id = g_accrued_dist_id_tbl(l_ctr);

    -- Clear the PL/SQL table
    g_accrued_dist_id_tbl.DELETE;

    -- Write log messages to request log
    l_stmt_num := 80;
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

    COMMIT WORK;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Start_Process_PVT;

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
        ROLLBACK TO Start_Process_PVT;

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
-- PROCEDURE    :   Seed_RcvAccountingEvents
-- DESCRIPTION  :   The procedure created events in RCV_ACCOUNTING_EVENTS table
--
--                  The procedure generates data and creates PL/SQL table for
--                  RAE, which will be used for bulk inserting the data in
--                  RAE
-----------------------------------------------------------------------------
PROCEDURE Seed_RcvAccountingEvents
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Seed_RcvAccountingEvents';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(70) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);
    l_ctr                           NUMBER;

    l_org_id                        NUMBER;
    l_user_id                       NUMBER;
    l_login_id                      NUMBER;
    l_conc_request_id               NUMBER;
    l_prog_appl_id                  NUMBER;
    l_conc_program_id               NUMBER;
    l_inv_org_id                    NUMBER;
    l_po_number                     VARCHAR2(20);

    -- Cursor for fetching data from temp table CST_PER_END_ACCRUALS_TEMP
    CURSOR l_accounting_events_csr IS
        SELECT  shipment_id,
                distribution_id,
                quantity_received,
                quantity_billed,
                accrual_quantity,
                encum_quantity,
                unit_price,
                accrual_amount,
                encum_amount,
                currency_code,
                currency_conversion_type,
                currency_conversion_rate,
                currency_conversion_date
        FROM    cst_per_end_accruals_temp;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Seed_RcvAccountingEvents_PVT;

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Insert_AccrualSubLedger <<');
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

    l_stmt_num := 10;
    l_user_id           := FND_GLOBAL.USER_ID;
    l_login_id          := FND_GLOBAL.LOGIN_ID;
    l_conc_request_id   := FND_GLOBAL.CONC_REQUEST_ID;
    l_prog_appl_id      := FND_GLOBAL.PROG_APPL_ID;
    l_conc_program_id   := FND_GLOBAL.CONC_PROGRAM_ID;
    /*l_org_id            := FND_GLOBAL.ORG_ID;
      Getting org_id from purchasing option
      Bug6987381*/
    l_org_id            := p_sys_setup_rec.org_id;

    -- Loop for each record in tem table
    l_stmt_num := 20;
    FOR l_accounting_events_rec IN l_accounting_events_csr LOOP

        l_stmt_num := 20;
        SELECT  poll.ship_to_organization_id,
                poh.segment1
        INTO    l_inv_org_id,
                l_po_number
        FROM    po_line_locations_all poll,
                po_headers_all poh
        WHERE   poll.line_location_id = l_accounting_events_rec.shipment_id
        AND     poh.po_header_id = poll.po_header_id;

        l_ctr := g_rae_event_id_tbl.COUNT + 1;
        -- Get accounting_event_id and accounting_event_type_id
        l_stmt_num := 30;
        SELECT  rcv_accounting_event_s.nextval,
                raet.event_type_id
        INTO    g_rae_event_id_tbl(l_ctr),
                g_rae_event_type_id_tbl(l_ctr)
        FROM    rcv_accounting_event_types raet
        WHERE   raet.event_type_name = 'PERIOD_END_ACCRUAL';

        g_rae_distribution_id_tbl(l_ctr):= l_accounting_events_rec.distribution_id;
        g_rae_inv_org_id_tbl(l_ctr)     := l_inv_org_id;
        g_rae_po_number_tbl(l_ctr)      := l_po_number;
        g_rae_qty_received_tbl(l_ctr)   := l_accounting_events_rec.quantity_received;
        g_rae_qty_invoiced_tbl(l_ctr)   := l_accounting_events_rec.quantity_billed;
        g_rae_unit_pice_tbl(l_ctr)      := l_accounting_events_rec.unit_price;
        g_rae_currency_code_tbl(l_ctr)  := l_accounting_events_rec.currency_code;
        g_rae_cur_conv_type_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_type;
        g_rae_cur_conv_rate_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_rate;
        g_rae_cur_conv_date_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_date;

        -- Transaction quantity and amount
        g_rae_txn_qty_tbl(l_ctr)        := l_accounting_events_rec.accrual_quantity;
        g_rae_txn_amount_tbl(l_ctr)     := l_accounting_events_rec.accrual_amount;

        ---------------------------------------------------------------------
        -- The PL/SQL table g_accrual_index_tbl works as a index table for
        -- accrual event_id PL/SQL table g_rae_event_id_tbl.
        -- e.g. g_accrual_index_tbl(po_distribution_id) stores position of
        -- accounting_event_id stored in PL/SQL table g_rae_event_id_tbl,
        -- corresponding to po_distribution_id.
        --
        -- This index table will be used to map the accounting_event_id and
        -- po_distribution_id, while creating accounting entries
        -- RCV_RECEIVING_SUB_LEDGER
        ---------------------------------------------------------------------
        g_accrual_index_tbl(l_accounting_events_rec.distribution_id) := l_ctr;
	/*Bug6987381: g_rae_pnt_event_id_tbl to be used only for encumbrance
	  reversal events
	*/
	g_rae_pnt_event_id_tbl(l_ctr) := null;

        -- Generate events for encumbrance reversals
        IF (p_sys_setup_rec.purch_encumbrance_flag = 'Y') THEN

            l_ctr := g_rae_event_id_tbl.COUNT + 1;

            -- Get accounting_event_id and accounting_event_type_id
            l_stmt_num := 40;
            SELECT  rcv_accounting_event_s.nextval,
                    raet.event_type_id
            INTO    g_rae_event_id_tbl(l_ctr),
                    g_rae_event_type_id_tbl(l_ctr)
            FROM    rcv_accounting_event_types raet
            WHERE   raet.event_type_name = 'ENCUMBRANCE_REVERSAL';

            g_rae_distribution_id_tbl(l_ctr):= l_accounting_events_rec.distribution_id;
            g_rae_inv_org_id_tbl(l_ctr)     := l_inv_org_id;
            g_rae_qty_received_tbl(l_ctr)   := l_accounting_events_rec.quantity_received;
            g_rae_qty_invoiced_tbl(l_ctr)   := l_accounting_events_rec.quantity_billed;
            g_rae_unit_pice_tbl(l_ctr)      := l_accounting_events_rec.unit_price;
            g_rae_currency_code_tbl(l_ctr)  := l_accounting_events_rec.currency_code;
            g_rae_cur_conv_type_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_type;
            g_rae_cur_conv_rate_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_rate;
            g_rae_cur_conv_date_tbl(l_ctr)  := l_accounting_events_rec.currency_conversion_date;
            g_rae_txn_qty_tbl(l_ctr)        := l_accounting_events_rec.encum_quantity;
            g_rae_txn_amount_tbl(l_ctr)     := l_accounting_events_rec.encum_amount;

           -----------------------------------------------------------------
            -- The PL/SQL table g_encum_index_tbl works as a index table for
            -- PL/SQL table g_rae_event_id_tbl for encumbrance reversals.
            -----------------------------------------------------------------
            g_encum_index_tbl(l_accounting_events_rec.distribution_id) := l_ctr;
	    /*Bug6987381*/
	    g_rae_pnt_event_id_tbl(l_ctr) := g_rae_event_id_tbl(g_accrual_index_tbl(l_accounting_events_rec.distribution_id));
	    g_rae_po_number_tbl(l_ctr)    := l_po_number;
        END IF;

    END LOOP;

    -------------------------------------------------------------------------
    -- Bulk insert the data in RCV_ACCOUNTING_EVENTS
    -------------------------------------------------------------------------
    l_stmt_num := 60;
    FORALL l_ctr IN g_rae_event_id_tbl.FIRST..g_rae_event_id_tbl.LAST
        INSERT into RCV_ACCOUNTING_EVENTS (
            accounting_event_id,
            last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            request_id,
            program_application_id,
            program_id,
            program_udpate_date,
            rcv_transaction_id,
            event_type_id,
            event_source,
            event_source_id,
            set_of_books_id,
            org_id,
            organization_id,
            debit_account_id,
            credit_account_id,
            transaction_date,
            source_doc_quantity,
            transaction_quantity,
            primary_quantity,
            source_doc_unit_of_measure,
            transaction_unit_of_measure,
            primary_unit_of_measure,
            po_header_id,
            po_release_id,
            po_line_id,
            po_line_location_id,
            po_distribution_id,
            inventory_item_id,
            unit_price,
            intercompany_pricing_option,
            transaction_amount,
            quantity_received,
            quantity_invoiced,
            amount_received,
            amount_invoiced,
            nr_tax,
            rec_tax,
            nr_tax_amount,
            rec_tax_amount,
            currency_code,
            currency_conversion_type,
            currency_conversion_rate,
            currency_conversion_date,
            accounted_flag,
            cross_ou_flag
            )
        SELECT
            g_rae_event_id_tbl(l_ctr),
            SYSDATE,
            l_user_id,
            l_login_id,
            sysdate,
            l_user_id,
            l_conc_request_id,
            l_prog_appl_id,
            l_conc_program_id,
            sysdate,
            0,
            g_rae_event_type_id_tbl(l_ctr),
            'PERIOD_END_ACCRUAL',
            g_rae_distribution_id_tbl(l_ctr),
            p_sys_setup_rec.set_of_books_id,
            l_org_id,
            poll.ship_to_organization_id,
            pod.code_combination_id,
            pod.accrual_account_id,
            p_sys_setup_rec.transaction_date,
            DECODE (poll.matching_basis,
                    'QUANTITY', g_rae_txn_qty_tbl(l_ctr) ),
            DECODE (poll.matching_basis,
                    'QUANTITY', g_rae_txn_qty_tbl(l_ctr) ),
            DECODE (poll.matching_basis,
                    'QUANTITY', g_rae_txn_qty_tbl(l_ctr) *
                                    inv_convert.inv_um_convert(
                                            NVL(pol.item_id, 0),
                                            10,
                                            NULL,
                                            NULL,
                                            NULL,
                                            poll.unit_meas_lookup_code,
                                            NVL(msi.primary_unit_of_measure, puom.unit_of_measure))
                    ),
            poll.unit_meas_lookup_code,
            poll.unit_meas_lookup_code,
            NVL(msi.primary_unit_of_measure, puom.unit_of_measure),
            poh.po_header_id,
            poll.po_release_id,
            pol.po_line_id,
            poll.line_location_id,
            pod.po_distribution_id,
            pol.item_id,
            g_rae_unit_pice_tbl(l_ctr),
            1,
            DECODE (poll.matching_basis,
                    'AMOUNT', g_rae_txn_amount_tbl(l_ctr)),
            DECODE (poll.matching_basis,
                    'QUANTITY', g_rae_qty_received_tbl(l_ctr)),
            DECODE (poll.matching_basis,
                    'QUANTITY', g_rae_qty_invoiced_tbl(l_ctr)),
            DECODE (poll.matching_basis,
                    'AMOUNT', g_rae_qty_received_tbl(l_ctr)),
            DECODE (poll.matching_basis,
                    'AMOUNT', g_rae_qty_invoiced_tbl(l_ctr)),
            DECODE (poll.matching_basis,
                    'QUANTITY', pod.recoverable_tax / pod.quantity_ordered),
            DECODE (poll.matching_basis,
                    'QUANTITY', pod.nonrecoverable_tax / pod.quantity_ordered),
            DECODE (poll.matching_basis,
                    'AMOUNT', pod.recoverable_tax * g_rae_txn_qty_tbl(l_ctr)
                                / pod.amount_ordered),
            DECODE (poll.matching_basis,
                    'AMOUNT', pod.nonrecoverable_tax * g_rae_txn_qty_tbl(l_ctr)
                                / pod.amount_ordered),
            g_rae_currency_code_tbl(l_ctr),
            g_rae_cur_conv_type_tbl(l_ctr),
            g_rae_cur_conv_rate_tbl(l_ctr),
            g_rae_cur_conv_date_tbl(l_ctr),
            'N',
            DECODE( poh.org_id,
                    cod.operating_unit, 'N',
                    'Y')
        FROM
            po_headers_all                  poh,
            po_lines_all                    pol,
            po_line_locations_all           poll,
            po_distributions_all            pod,
            cst_organization_definitions    cod,
            mtl_system_items                msi,
            mtl_units_of_measure            tuom,
            mtl_units_of_measure            puom
        WHERE
            pod.po_distribution_id = g_rae_distribution_id_tbl(l_ctr)
            AND poh.po_header_id = pol.po_header_id
            AND pol.po_line_id = poll.po_line_id
            AND poll.line_location_id = pod.line_location_id
            AND cod.organization_id = poll.ship_to_organization_id
            AND msi.inventory_item_id (+)  = pol.item_id
            AND (msi.organization_id IS NULL
                OR
                (msi.organization_id = poll.ship_to_organization_id AND msi.organization_id IS NOT NULL))
            AND tuom.unit_of_measure(+) = decode(poll.matching_basis, 'QUANTITY', poll.unit_meas_lookup_code, NULL)
            AND puom.uom_class(+) = tuom.uom_class
            AND puom.base_uom_flag(+)   = 'Y';

    ------------------------------------------------------------------------
    -- Clear the PL/SQL tables,
    -- Do not clear the table g_rae_event_id_tbl, since we need the
    -- accounting_event_ids while creating accounting entries in
    -- RCV_RECEIVING_SUB_LEDGER.
    ------------------------------------------------------------------------
    l_stmt_num := 70;
    g_rae_distribution_id_tbl.DELETE;
    g_rae_qty_received_tbl.DELETE;
    g_rae_qty_invoiced_tbl.DELETE;
    g_rae_unit_pice_tbl.DELETE;
    g_rae_txn_qty_tbl.DELETE;
    g_rae_txn_amount_tbl.DELETE;
    g_rae_currency_code_tbl.DELETE;
    g_rae_cur_conv_type_tbl.DELETE;
    g_rae_cur_conv_rate_tbl.DELETE;
    g_rae_cur_conv_date_tbl.DELETE;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Insert_AccrualSubLedger >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Seed_RcvAccountingEvents_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Seed_RcvAccountingEvents_PVT;
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

END Seed_RcvAccountingEvents;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Create_AccrualAccount
-- DESCRIPTION  :   The procedure fetches data from temp table
--                  CST_PER_END_ACCRUALS_TEMP, and populates PL/SQL tables
--                  with the corresponding accrual info for RCV_RECEIVING_SUB_LEDGER
-----------------------------------------------------------------------------
PROCEDURE Create_AccrualAccount
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
)
IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Create_AccrualAccount';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(70) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);

    l_accrual_info_rec              CST_ACCRUAL_INFO_REC_TYPE;
    l_trx_rec                       CST_XLA_PVT.T_XLA_RCV_TRX_INFO;
    l_func_currency_code            VARCHAR2(15);
    l_accounted_dr                  NUMBER;
    l_accounted_cr                  NUMBER;
    l_accounted_encum_dr            NUMBER;
    l_accounted_encum_cr            NUMBER;
    l_accounted_nr_tax              NUMBER;
    l_accounted_rec_tax             NUMBER;
    l_user_curr_conv_type           VARCHAR2(30);
    l_ctr                           NUMBER;
    /*Bug6987381 Start */
    l_reference_date_1              DATE;
    l_batch                         NUMBER;
    l_errbuf                        VARCHAR2(1000);
    l_retcode                       NUMBER;
    l_bc_status                     VARCHAR2(2000);
    l_packet_id                     NUMBER;
    l_user_id                       NUMBER;
    l_resp_id                       NUMBER;
    l_resp_appl_id                  NUMBER;
    /*Bug6987381 End */
    -- Accrual cursor
    CURSOR l_accrual_csr IS
        SELECT  cpea.shipment_id                        shipment_id,
                cpea.distribution_id                    distribution_id,
                cpea.accrual_quantity                   accrual_quantity,
                cpea.encum_quantity                     encum_quantity,
                cpea.accrual_amount                     entered_dr,
                cpea.accrual_amount                     entered_cr,
                cpea.encum_amount                       entered_encum_dr,
                cpea.encum_amount                       entered_encum_cr,
                poh.segment1                            po_number,
                NVL(fnc1.minimum_accountable_unit,0)    min_func_acct_unit,
                fnc1.precision                          func_currency_precision,
                NVL(fnc2.minimum_accountable_unit,0)    min_acct_unit,
                fnc2.precision                          currency_precision,
                poh.po_header_id                        po_header_id,
                cpea.currency_code                      currency_code,
                cpea.currency_conversion_rate           currency_rate,
                NVL(NVL(pod.rate,poh.rate),1)           encum_currency_rate,
		pod.rate_date                           encum_currency_conv_date,
		glct.user_conversion_type               user_curr_conv_type,
                cpea.currency_conversion_date           currency_conv_date,
                pod.recoverable_tax * cpea.accrual_quantity
                    / DECODE(poll.matching_basis,
                            'AMOUNT', pod.amount_ordered,
                             pod.quantity_ordered )     entered_rec_tax,
                pod.nonrecoverable_tax * cpea.accrual_quantity
                    / DECODE(poll.matching_basis,
                            'AMOUNT', pod.amount_ordered,
                             pod.quantity_ordered )     entered_nr_tax,
                pod.code_combination_id                 act_debit_ccid,
                pod.accrual_account_id                  act_credit_ccid,
                pod.budget_account_id                   enc_credit_ccid
        FROM    cst_per_end_accruals_temp   cpea,
                po_headers_all              poh,
                po_line_locations_all       poll,
                po_distributions_all        pod,
                fnd_currencies              fnc1,
                fnd_currencies              fnc2,
                gl_daily_conversion_types   glct
        WHERE   pod.po_distribution_id = cpea.distribution_id
        AND     pod.po_header_id = poh.po_header_id
        AND     pod.line_location_id = poll.line_location_id
        AND     fnc1.currency_code = l_func_currency_code
        AND     fnc2.currency_code = cpea.currency_code
        AND     cpea.currency_conversion_type = glct.conversion_type(+)
        ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Create_AccrualAccount_PVT;

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Create_AccrualAccount <<');
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

    l_func_currency_code := p_sys_setup_rec.functional_currency_code;

    -- Loop for each row of accrual cursor
    l_stmt_num := 20;
    FOR l_accrual_rec IN l_accrual_csr LOOP

        -- Convert the accounting values in base currency
        l_stmt_num := 30;
        IF (l_accrual_rec.min_acct_unit = 0) THEN
            l_accounted_dr      := ROUND(l_accrual_rec.entered_dr,l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.currency_rate ;
            l_accounted_cr      := ROUND(l_accrual_rec.entered_cr,l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.currency_rate ;
            l_accounted_encum_dr := ROUND(l_accrual_rec.entered_encum_dr,l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.encum_currency_rate ;
            l_accounted_encum_cr := ROUND(l_accrual_rec.entered_encum_cr,l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.encum_currency_rate ;
            l_accounted_nr_tax  := ROUND(l_accrual_rec.entered_nr_tax , l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.currency_rate ;
            l_accounted_rec_tax := ROUND(l_accrual_rec.entered_rec_tax , l_accrual_rec.currency_precision)
                                                                        * l_accrual_rec.currency_rate ;
        ELSE
            l_accounted_dr      := ROUND(l_accrual_rec.entered_dr/l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.currency_rate;
            l_accounted_cr      := ROUND(l_accrual_rec.entered_cr/l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.currency_rate;
            l_accounted_encum_dr := ROUND(l_accrual_rec.entered_encum_dr/l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.encum_currency_rate;
            l_accounted_encum_cr := ROUND(l_accrual_rec.entered_encum_cr/l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.encum_currency_rate;
            l_accounted_nr_tax  := ROUND(l_accrual_rec.entered_nr_tax / l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.currency_rate;
            l_accounted_rec_tax := ROUND(l_accrual_rec.entered_rec_tax / l_accrual_rec.min_acct_unit)
                                            * l_accrual_rec.min_acct_unit * l_accrual_rec.currency_rate;
        END IF;

        ---------------------------------------------------------------------
        -- g_accrual_index_tbl(po_distribution_id) stores position of
        -- accounting_event_id stored in PL/SQL table g_rae_event_id_tbl,
        -- corresponding to po_distribution_id.
        ---------------------------------------------------------------------
        l_stmt_num := 40;
        IF (g_accrual_index_tbl.EXISTS(l_accrual_rec.distribution_id)) THEN
            l_accrual_info_rec.rcv_acc_event_id :=
                        g_rae_event_id_tbl(g_accrual_index_tbl(l_accrual_rec.distribution_id));

            -- This will be used only for encum reversal entries
            l_accrual_info_rec.parent_rcv_acc_event_id := NULL;
        ELSE
            l_msg_data := 'Failed getting corresponding RCV_ACCOUNTING_EVENT_ID for distribution_id :'
                          || l_accrual_rec.distribution_id;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Populate the accrual_info_rec record
        l_stmt_num := 70;
        l_accrual_info_rec.actual_flag := 'A';
        l_accrual_info_rec.accrual_method_flag := 'P';

        l_accrual_info_rec.currency_code := l_accrual_rec.currency_code;
        l_accrual_info_rec.currency_conversion_date := l_accrual_rec.currency_conv_date;
        l_accrual_info_rec.user_currency_conversion_type := l_accrual_rec.user_curr_conv_type;
        l_accrual_info_rec.currency_conversion_rate := l_accrual_rec.currency_rate;
        l_accrual_info_rec.po_header_id := l_accrual_rec.po_header_id;
        l_accrual_info_rec.distribution_id := l_accrual_rec.distribution_id;
        l_accrual_info_rec.po_number := l_accrual_rec.po_number;
        l_accrual_info_rec.source_doc_quantity := l_accrual_rec.accrual_quantity;

        l_accrual_info_rec.entered_rec_tax := l_accrual_rec.entered_rec_tax;
        l_accrual_info_rec.entered_nr_tax := l_accrual_rec.entered_nr_tax;
        l_accrual_info_rec.accounted_rec_tax := l_accounted_rec_tax;
        l_accrual_info_rec.accounted_nr_tax :=  l_accounted_nr_tax;

        ---------------------------------------------------------------------
        -- Accrual information for debit entries
        ---------------------------------------------------------------------
        IF (l_accrual_rec.act_debit_ccid >= 0) THEN

            l_accrual_info_rec.code_combination_id := l_accrual_rec.act_debit_ccid;
            l_accrual_info_rec.accounting_line_type := 'Charge';

            IF (l_accrual_rec.min_acct_unit <= 0) THEN
                l_accrual_info_rec.entered_dr := ROUND(l_accrual_rec.entered_dr,l_accrual_rec.currency_precision);
            ELSE
                l_accrual_info_rec.entered_dr := ROUND( l_accrual_rec.entered_dr
                                                    / l_accrual_rec.min_acct_unit)
                                                    * l_accrual_rec.min_acct_unit;
            END IF;

            IF (l_accrual_rec.min_func_acct_unit <= 0) THEN
                l_accrual_info_rec.accounted_dr := ROUND(l_accounted_dr,l_accrual_rec.func_currency_precision);
            ELSE
                l_accrual_info_rec.accounted_dr := ROUND( l_accounted_dr
                                                    / l_accrual_rec.min_func_acct_unit)
                                                    * l_accrual_rec.min_func_acct_unit;
            END IF;

            l_accrual_info_rec.accounted_cr := NULL;
            l_accrual_info_rec.entered_cr := NULL;

            -- Add a new row to the PL/SQL tables for the accrual_info_rec
            l_stmt_num := 90;
            Insert_Account (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_accrual_info_rec      => l_accrual_info_rec,
                p_sys_setup_rec         => p_sys_setup_rec
                );
            -- If return status is not success, add message to the log
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                l_msg_data := 'Failed inserting data in Accrual table';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;

        ---------------------------------------------------------------------
        -- Accrual information for credit entries
        ---------------------------------------------------------------------
        IF( l_accrual_rec.act_credit_ccid >= 0) THEN

            l_accrual_info_rec.code_combination_id := l_accrual_rec.act_credit_ccid;
            l_accrual_info_rec.accounting_line_type := 'Accrual';

            IF (l_accrual_rec.min_acct_unit <= 0 ) THEN
                l_accrual_info_rec.entered_cr := ROUND(l_accrual_rec.entered_cr,l_accrual_rec.currency_precision);
            ELSE
                l_accrual_info_rec.entered_cr := ROUND( l_accrual_rec.entered_cr
                                                    / l_accrual_rec.min_acct_unit)
                                                    * l_accrual_rec.min_acct_unit;
            END IF;

            IF (l_accrual_rec.min_func_acct_unit <= 0 ) THEN
                l_accrual_info_rec.accounted_cr := ROUND(l_accounted_cr,l_accrual_rec.func_currency_precision);
            ELSE
                l_accrual_info_rec.accounted_cr := ROUND( l_accounted_cr
                                                    / l_accrual_rec.min_func_acct_unit)
                                                    * l_accrual_rec.min_func_acct_unit;
            END IF;

            l_accrual_info_rec.accounted_dr := NULL;
            l_accrual_info_rec.entered_dr := NULL;

            -- Add a new row to the PL/SQL tables for the accrual_info_rec
            l_stmt_num := 110;
            Insert_Account (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_accrual_info_rec      => l_accrual_info_rec,
                p_sys_setup_rec         => p_sys_setup_rec
                );
            -- If return status is not success, add message to the log
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                l_msg_data := 'Failed inserting data in Accrual table';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;


        ---------------------------------------------------------------------
        -- Accrual information for encumbrance reversals
        ---------------------------------------------------------------------
        IF (p_sys_setup_rec.purch_encumbrance_flag = 'Y') THEN

            l_stmt_num := 120;
            IF (g_encum_index_tbl.EXISTS(l_accrual_rec.distribution_id)) THEN

                l_accrual_info_rec.rcv_acc_event_id :=
                        g_rae_event_id_tbl(g_encum_index_tbl(l_accrual_rec.distribution_id));

                -- Get the accounting event id of correspoding accrual entry
                l_accrual_info_rec.parent_rcv_acc_event_id :=
                        g_rae_event_id_tbl(g_accrual_index_tbl(l_accrual_rec.distribution_id));
            ELSE

                l_msg_data := 'Failed getting corresponding RCV_ACCOUNTING_EVENT_ID for distribution_id :'
                              || l_accrual_rec.distribution_id;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            l_accrual_info_rec.code_combination_id := l_accrual_rec.enc_credit_ccid;
            l_accrual_info_rec.actual_flag := 'E';
            l_accrual_info_rec.currency_code := l_accrual_rec.currency_code;
	    l_accrual_info_rec.currency_conversion_date := l_accrual_rec.encum_currency_conv_date;
            l_accrual_info_rec.currency_conversion_rate := l_accrual_rec.encum_currency_rate;
	    /*Bug 6987381 : Passing the Accounting Line Type as 'Encumbrance Reversal' */
            l_accrual_info_rec.accounting_line_type := 'Encumbrance Reversal';
            l_accrual_info_rec.entered_cr := l_accounted_encum_cr/l_accrual_rec.encum_currency_rate;

	    IF (l_accrual_rec.min_func_acct_unit <= 0 ) THEN
                l_accrual_info_rec.accounted_cr := ROUND(l_accounted_encum_cr,l_accrual_rec.func_currency_precision);
            ELSE
                l_accrual_info_rec.accounted_cr := ROUND( l_accounted_encum_cr
                                                    / l_accrual_rec.min_func_acct_unit)
                                                    * l_accrual_rec.min_func_acct_unit;
            END IF;

            l_accrual_info_rec.accounted_dr := NULL;
            l_accrual_info_rec.entered_dr := NULL;

            l_accrual_info_rec.entered_rec_tax := NULL;
            l_accrual_info_rec.entered_nr_tax := NULL;
            l_accrual_info_rec.accounted_rec_tax := NULL;
            l_accrual_info_rec.accounted_nr_tax := NULL;

            l_accrual_info_rec.accrual_method_flag := NULL;

            -- Add a new row to the PL/SQL tables for the accrual_info_rec
            -- corresponding to the encumbrance reversals
            l_stmt_num := 140;
            Insert_Account (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_accrual_info_rec      => l_accrual_info_rec,
                p_sys_setup_rec         => p_sys_setup_rec
                );
            -- If return status is not success, add message to the log
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                l_msg_data := 'Failed inserting data in Accrual table';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;

    END LOOP;

    -------------------------------------------------------------------------
    -- Insert the data in RCV_RECEIVING_SUB_LEDGER table
    -------------------------------------------------------------------------
    l_stmt_num := 160;
    Insert_AccrualSubLedger (
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_sys_setup_rec         => p_sys_setup_rec
        );
    -- If return status is not success, add message to the log
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed inserting data in RCV_RECEIVING_SUB_LEDGER';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_counter = 0) THEN
       GOTO END_PROCEDURE;
    END IF;

    -------------------------------------------------------------------------
    -- Raise SLA Event for Period End Accruals (EVENT_TYPE_ID = 14)
    -- In case of ENCUMBRANCE_REVERSAL, no need to Raise SLA Event
    -------------------------------------------------------------------------
    l_stmt_num := 180;

    /*Bug6987381 Start */
    l_reference_date_1 := INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
                                       p_sys_setup_rec.transaction_date,
                                       p_sys_setup_rec.org_id);
    l_stmt_num := 200;
    DELETE FROM XLA_EVENTS_INT_GT;
    l_stmt_num := 220;

    FOR l_ctr IN g_rae_event_id_tbl.FIRST..g_rae_event_id_tbl.LAST LOOP
      IF (g_rae_event_type_id_tbl(l_ctr) = 14) THEN
         INSERT INTO XLA_EVENTS_INT_GT
               (  application_id,
                  ledger_id,
                  entity_code,
                  source_id_int_1,
                  source_id_int_2,
                  source_id_int_3,
                  event_class_code,
                  event_type_code,
                  event_date,
                  event_status_code,
                  security_id_int_1,
                  security_id_int_2,
                  transaction_date,
                  reference_date_1,
                  transaction_number,
		  budgetary_control_flag
               )
	       VALUES (
	        707,
                p_sys_setup_rec.set_of_books_id,
                'RCV_ACCOUNTING_EVENTS',
                0,
                decode(g_rae_event_type_id_tbl(l_ctr),
		         13,g_rae_pnt_event_id_tbl(l_ctr),
		         g_rae_event_id_tbl(l_ctr)),
                g_rae_inv_org_id_tbl(l_ctr),
                'PERIOD_END_ACCRUAL',
                'PERIOD_END_ACCRUAL',
                p_sys_setup_rec.transaction_date,
                XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
                g_rae_inv_org_id_tbl(l_ctr),
                p_sys_setup_rec.org_id,
                p_sys_setup_rec.transaction_date,
                l_reference_date_1,
                g_rae_po_number_tbl(l_ctr),
                NULL
	        );
      END IF;
   END LOOP;

    -------------------------------------------------------------------------
    -- Clear the data in the PL/SQL tables corresponding to the
    -- accounting events
    -------------------------------------------------------------------------
       g_rae_event_id_tbl.DELETE;
       g_rae_event_type_id_tbl.DELETE;
       g_rae_inv_org_id_tbl.DELETE;
       g_rae_po_number_tbl.DELETE;
       g_accrual_index_tbl.DELETE;
       g_encum_index_tbl.DELETE;
       g_rae_pnt_event_id_tbl.DELETE;
       /* Call XLA API to create event in bulk mode */
       l_stmt_num := 240;
       xla_events_pub_pkg.create_bulk_events(p_application_id => 707,
                                      p_ledger_id => p_sys_setup_rec.set_of_books_id,
                                      p_entity_type_code => 'RCV_ACCOUNTING_EVENTS',
                                      p_source_application_id => 201);

     /*Bug6987381 End */
    <<END_PROCEDURE>>
    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Create_AccrualAccount >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_AccrualAccount_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Create_AccrualAccount_PVT;
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

END Create_AccrualAccount;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Insert_Account
-- DESCRIPTION  :   The procedure adds a new row to the PL/SQL tables for
--                  each accrual_info_rec record.
-----------------------------------------------------------------------------
PROCEDURE Insert_Account
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_accrual_info_rec              IN      CST_ACCRUAL_INFO_REC_TYPE,
    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Insert_Account';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Insert_Account_PVT;

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Insert_Account <<');
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

    -- Get the position of the new row to be added
    g_counter := g_distribution_id_tbl.COUNT + 1;

    -------------------------------------------------------------------------
    -- Add the record values to the PL/SQL tables
    -------------------------------------------------------------------------
    l_stmt_num := 20;
    g_rcv_acc_event_id_tbl(g_counter)       :=  p_accrual_info_rec.rcv_acc_event_id;
    g_actual_flag_tbl(g_counter)            :=  p_accrual_info_rec.actual_flag;
    g_currency_code_tbl(g_counter)          :=  p_accrual_info_rec.currency_code;
    g_code_combination_id_tbl(g_counter)    :=  p_accrual_info_rec.code_combination_id;
    g_entered_dr_tbl(g_counter)             :=  p_accrual_info_rec.entered_dr;
    g_entered_cr_tbl(g_counter)             :=  p_accrual_info_rec.entered_cr;
    g_accounted_dr_tbl(g_counter)           :=  p_accrual_info_rec.accounted_dr;
    g_accounted_cr_tbl(g_counter)           :=  p_accrual_info_rec.accounted_cr;
    g_curr_conversion_date_tbl(g_counter)   :=  p_accrual_info_rec.currency_conversion_date;
    g_user_curr_conversion_tbl(g_counter)   :=  p_accrual_info_rec.user_currency_conversion_type;
    g_curr_conversion_rate_tbl(g_counter)   :=  p_accrual_info_rec.currency_conversion_rate;
    g_po_header_id_tbl(g_counter)           :=  p_accrual_info_rec.po_header_id;
    g_distribution_id_tbl(g_counter)        :=  p_accrual_info_rec.distribution_id;
    g_po_number_tbl(g_counter)              :=  p_accrual_info_rec.po_number;
    g_source_doc_quantity_tbl(g_counter)    :=  p_accrual_info_rec.source_doc_quantity;
    g_entered_rec_tax_tbl(g_counter)        :=  p_accrual_info_rec.entered_rec_tax;
    g_entered_nr_tax_tbl(g_counter)         :=  p_accrual_info_rec.entered_nr_tax;
    g_accounted_rec_tax_tbl(g_counter)      :=  p_accrual_info_rec.accounted_rec_tax;
    g_accounted_nr_tax_tbl(g_counter)       :=  p_accrual_info_rec.accounted_nr_tax;
    g_accrual_method_flag_tbl(g_counter)    :=  p_accrual_info_rec.accrual_method_flag;
    g_accounting_line_type_tbl(g_counter)   :=  p_accrual_info_rec.accounting_line_type;

    -- To be used for to map the encum reversal entries with corresponding accrual entries
    g_pnt_rcv_acc_event_id_tbl(g_counter)   :=  p_accrual_info_rec.parent_rcv_acc_event_id;

    -------------------------------------------------------------------------
    -- Check for number of records in l_accrual_info_tbl
    -- If number of records is more then 1000, insert the data in database
    -- and clear the pl/sql tables, this will help in saving memory.
    -------------------------------------------------------------------------
    IF (g_counter >= 1000) THEN

        -------------------------------------------------------------------------
        -- Insert the data in RCV_RECEIVING_SUB_LEDGER table
        -------------------------------------------------------------------------
        l_stmt_num := 40;
        Insert_AccrualSubLedger (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_sys_setup_rec         => p_sys_setup_rec
            );
        -- If return status is not success, add message to the log
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed inserting data in RCV_RECEIVING_SUB_LEDGER';
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Insert_Account >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Insert_Account_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Insert_Account_PVT;
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

END Insert_Account;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Insert_AccrualSubLedger
-- DESCRIPTION  :   Insert accounting entries in RCV_RECEIVING_SUB_LEDGER
----------------------------------------------------------------------------
PROCEDURE Insert_AccrualSubLedger
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Insert_AccrualSubLedger';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(70) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);
    l_ctr                           NUMBER;

    l_user_id                       NUMBER;
    l_login_id                      NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Insert_AccrualSubLedger_PVT;

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Insert_AccrualSubLedger <<');
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
    l_user_id     := FND_GLOBAL.USER_ID;
    l_login_id    := FND_GLOBAL.LOGIN_ID;

    -------------------------------------------------------------------------
    -- Bulk insert the values in RCV_RECEIVING_SUB_LEDGER
    -------------------------------------------------------------------------
    l_stmt_num := 20;
    FORALL l_ctr IN g_distribution_id_tbl.FIRST..g_distribution_id_tbl.LAST
        INSERT INTO rcv_receiving_sub_ledger (
            rcv_sub_ledger_id,
            rcv_transaction_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            actual_flag,
            currency_code,
            je_source_name,
            je_category_name,
            set_of_books_id,
            accounting_date,
            code_combination_id,
            entered_dr,
            entered_cr,
            accounted_dr,
            accounted_cr,
            currency_conversion_date,
            user_currency_conversion_type,
            currency_conversion_rate,
            transaction_date,
            period_name,
            chart_of_accounts_id,
            functional_currency_code,
            reference1,
            reference2,
            reference3,
            reference4,
            reference9,
            source_doc_quantity,
            entered_rec_tax,
            entered_nr_tax,
            accounted_rec_tax,
            accounted_nr_tax,
            accrual_method_flag,
            accounting_event_id,
            accounting_line_type
            )
        VALUES (
           DECODE( g_actual_flag_tbl(l_ctr),'E',-1,1) *  rcv_receiving_sub_ledger_s.nextval,
            0,
            SYSDATE,
            l_user_id,
            SYSDATE,
            l_user_id,
            l_login_id,
            g_actual_flag_tbl(l_ctr),
            g_currency_code_tbl(l_ctr),
            p_sys_setup_rec.user_je_source_name,
            p_sys_setup_rec.user_je_category_name,
            p_sys_setup_rec.set_of_books_id,
            p_sys_setup_rec.accrual_effect_date,
            g_code_combination_id_tbl(l_ctr),
            g_entered_dr_tbl(l_ctr),
            g_entered_cr_tbl(l_ctr),
            g_accounted_dr_tbl(l_ctr),
            g_accounted_cr_tbl(l_ctr),
            g_curr_conversion_date_tbl(l_ctr),
            g_user_curr_conversion_tbl(l_ctr),
            g_curr_conversion_rate_tbl(l_ctr),
            p_sys_setup_rec.transaction_date,
            p_sys_setup_rec.period_name,
            p_sys_setup_rec.chart_of_accounts_id,
            p_sys_setup_rec.functional_currency_code,
            'PO',
            TO_CHAR(g_po_header_id_tbl(l_ctr)),
            TO_CHAR(g_distribution_id_tbl(l_ctr)),
            g_po_number_tbl(l_ctr),
            g_pnt_rcv_acc_event_id_tbl(l_ctr),
            g_source_doc_quantity_tbl(l_ctr),
            g_entered_rec_tax_tbl(l_ctr),
            g_entered_nr_tax_tbl(l_ctr),
            g_accounted_rec_tax_tbl(l_ctr),
            g_accounted_nr_tax_tbl(l_ctr),
            g_accrual_method_flag_tbl(l_ctr),
            g_rcv_acc_event_id_tbl(l_ctr),
            g_accounting_line_type_tbl(l_ctr)
          );

    -------------------------------------------------------------------------
    -- Clear the PL/SQL tables
    -------------------------------------------------------------------------
    l_stmt_num := 30;
    g_rcv_acc_event_id_tbl.DELETE;
    g_actual_flag_tbl.DELETE;
    g_currency_code_tbl.DELETE;
    g_code_combination_id_tbl.DELETE;
    g_entered_dr_tbl.DELETE;
    g_entered_cr_tbl.DELETE;
    g_accounted_dr_tbl.DELETE;
    g_accounted_cr_tbl.DELETE;
    g_curr_conversion_date_tbl.DELETE;
    g_user_curr_conversion_tbl.DELETE;
    g_curr_conversion_rate_tbl.DELETE;
    g_po_header_id_tbl.DELETE;
    g_distribution_id_tbl.DELETE;
    g_po_number_tbl.DELETE;
    g_source_doc_quantity_tbl.DELETE;
    g_entered_rec_tax_tbl.DELETE;
    g_entered_nr_tax_tbl.DELETE;
    g_accounted_rec_tax_tbl.DELETE;
    g_accounted_nr_tax_tbl.DELETE;
    g_accrual_method_flag_tbl.DELETE;
    g_accounting_line_type_tbl.DELETE;
    g_pnt_rcv_acc_event_id_tbl.DELETE;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Insert_AccrualSubLedger >>'
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Insert_AccrualSubLedger_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Insert_AccrualSubLedger_PVT;
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

END Insert_AccrualSubLedger;

----------------------------------------------------------------------------
-- PROCEDURE    :   Get_SystemSetup
-- DESCRIPTION  :   Get system set-up information e.g. set_of_books,
--                  functional_currency, chart_of_accounts,
--                  purchase_encumbrance_flag etc.
-----------------------------------------------------------------------------
PROCEDURE Get_SystemSetup
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_period_name                   IN      VARCHAR2,
    x_sys_setup_rec                 OUT     NOCOPY CST_SYS_SETUP_REC_TYPE
)
IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Get_SystemSetup';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);

    l_application_id                NUMBER;
    l_gl_installed                  BOOLEAN;
    l_status                        VARCHAR2(1);
    l_industry                      VARCHAR2(1);
    l_schema                        VARCHAR2(30);
    l_legal_entity                  NUMBER;
    l_multi_org_flag                VARCHAR2(1);

    l_batch_no                      NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Get_SystemSetup_PVT;

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Get_SystemSetup <<' ||
               'p_period_name ='    || p_period_name);
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

    -- Check whether GL is installed
    l_stmt_num := 20;
    l_gl_installed := FND_INSTALLATION.GET_APP_INFO ( 'SQLGL',
                                                      l_status,
                                                      l_industry,
                                                      l_schema);
    IF (l_status = 'I') THEN
        l_application_id := G_GL_APPLICATION_ID;
    ELSE
        l_application_id := G_PO_APPLICATION_ID;
    END IF;

    x_sys_setup_rec.period_name := p_period_name;

    -------------------------------------------------------------------------
    -- Get system set-up information
    -------------------------------------------------------------------------
    l_stmt_num := 30;
    /*Bug6987381 : Added Org_id */
    SELECT  NVL(fsp.set_of_books_id, 0),
            NVL(sob.chart_of_accounts_id, 0),
            sob.currency_code,
            NVL(fsp.purch_encumbrance_flag, 'N'),
            DECODE( SIGN(acr.start_date - SYSDATE),
                    1, acr.start_date,
                    DECODE( SIGN(SYSDATE - acr.end_date),
                            1, acr.end_date,
                            SYSDATE)),
            acr.end_date,
	    fsp.org_id
    INTO    x_sys_setup_rec.set_of_books_id,
            x_sys_setup_rec.chart_of_accounts_id,
            x_sys_setup_rec.functional_currency_code,
            x_sys_setup_rec.purch_encumbrance_flag,
            x_sys_setup_rec.accrual_effect_date,
            x_sys_setup_rec.accrual_cutoff_date,
            x_sys_setup_rec.org_id
    FROM    gl_period_statuses acr,
            financials_system_parameters fsp,
            gl_sets_of_books sob
    WHERE   acr.application_id =  l_application_id
    AND     acr.set_of_books_id = fsp.set_of_books_id
    AND     acr.period_name = p_period_name
    AND     fsp.set_of_books_id = sob.set_of_books_id
    AND     acr.adjustment_period_flag = 'N';

    -------------------------------------------------------------------------
    -- Convert Accrual Cutoff date from Legal entity timezone to
    -- Server timezone
    -------------------------------------------------------------------------
    l_stmt_num := 40;
    SELECT  TO_NUMBER(org_information2)
    INTO    l_legal_entity
    FROM    hr_organization_information
    WHERE   organization_id = MO_GLOBAL.GET_CURRENT_ORG_ID
    AND     org_information_context = 'Operating Unit Information';

    l_stmt_num := 50;
    x_sys_setup_rec.period_end_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                                        x_sys_setup_rec.accrual_cutoff_date,
                                        l_legal_entity
                                        );

    l_stmt_num := 60;
    x_sys_setup_rec.transaction_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                                        x_sys_setup_rec.accrual_effect_date,
                                        l_legal_entity
                                        );

    -- User GL Source Name and Category. These are mandatory columns in RCV_RECEIVING_SUB_LEGDER
    l_stmt_num := 70;
    SELECT  user_je_category_name
    INTO    x_sys_setup_rec.user_je_category_name
    FROM    gl_je_categories
    WHERE   je_category_name = 'Accrual';

    l_stmt_num := 80;
    SELECT  user_je_source_name
    INTO    x_sys_setup_rec.user_je_source_name
    FROM    gl_je_sources
    WHERE   je_source_name = 'Purchasing';

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Get_SystemSetup >> ' ||
               'set_of_books_id = '          || x_sys_setup_rec.set_of_books_id          ||','||
               'chart_of_accounts_id = '     || x_sys_setup_rec.chart_of_accounts_id     ||','||
               'functional_currency_code = ' || x_sys_setup_rec.functional_currency_code ||','||
               'purch_encumbrance_flag = '   || x_sys_setup_rec.purch_encumbrance_flag   ||','||
               'period_name = '              || x_sys_setup_rec.period_name              ||','||
               'accrual_effect_date = '      || x_sys_setup_rec.accrual_effect_date      ||','||
               'accrual_cutoff_date = '      || x_sys_setup_rec.accrual_cutoff_date      ||','||
               'period_end_date = '          || x_sys_setup_rec.period_end_date
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_SystemSetup_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Get_SystemSetup_PVT;
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

END Get_SystemSetup;

END CST_ReceiptAccrualPerEnd_PVT;

/

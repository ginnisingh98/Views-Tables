--------------------------------------------------------
--  DDL for Package Body CST_XLA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_XLA_PVT" AS
/* $Header: CSTVXLAB.pls 120.43.12010000.13 2010/04/14 11:53:16 akhadika ship $ */

/* FND Logging Constants */
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'CST_XLA_PVT';
G_DEBUG              CONSTANT VARCHAR2(1)  :=  NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD           CONSTANT VARCHAR2(40) := 'cst.plsql.'||G_PKG_NAME;
G_LOG_LEVEL          CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/* Global Constants */
G_CST_APPLICATION_ID CONSTANT NUMBER       := 707;
G_INV_APPLICATION_ID CONSTANT NUMBER       := 401;
G_PO_APPLICATION_ID  CONSTANT NUMBER       := 201;
G_WIP_APPLICATION_ID CONSTANT NUMBER       := 706;
G_RES_ABS_EVENT      CONSTANT VARCHAR2(30) := 'RESOURCE_ABSORPTION';
G_OVH_ABS_EVENT      CONSTANT VARCHAR2(30) := 'OVERHEAD_ABSORPTION';
G_OSP_EVENT          CONSTANT VARCHAR2(30) := 'OSP';
G_IPV_TRANSFER_EVENT CONSTANT VARCHAR2(30) := 'IPV_TRANSFER_WO';
G_COGS_REC_EVENT     CONSTANT VARCHAR2(30) := 'COGS_RECOGNITION';
G_COGS_REC_ADJ_EVENT CONSTANT VARCHAR2(30) := 'COGS_RECOGNITION_ADJ';

PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'cst.plsql.cst_security_policy_pkg';
C_DEFAULT_PREDICAT    CONSTANT VARCHAR2(240) := ' 1=1 ';


--------------------------------------------------------------------------------------
-- Local routines section : BEGIN
--------------------------------------------------------------------------------------
   /*----------------------------------------------------------------------------*
    | PRIVATE FUNCTION                                                           |
    |    blueprint_SLA_hook_wrap                                                 |
    |                                                                            |
    | DESCRIPTION                                                                |
    |    This is a wrapper call to blueprint_sla_hook when this is being         |
    |    called from one of the bulk insert statements since the function        |
    |     blueprint_sla_hook has out parameters, this wrapper should not         |
    |    be modified or customized                                               |
    |                                                                            |
    | PARAMETERS:                                                                |
    |       INPUT:                                                               |
    |       -p_wrap_txn_id     Transaction ID                                    |
    |       -p_wrap_tb_source       String identifying the source table of the   |
    |                             transaction that is calling the hook, the two  |
    |                             possible values are:                           |
    |                             "MMT" for transaction belonging to table       |
    |                              MTL_MATERIAL_TRANSACTIONS                     |
    |                             "WT"  for transactions belonging to table      |
    |                              WIP_TRANSACTIONS                              |
    | CALLED FROM                                                                |
    |       CST_XLA_PVT.CreateBulk_WIPXLAEvent                                   |
    |   CST_XLA.PVT.Create_WIPUpdateXLAEvent                                     |
    |   CST_XLA.Create_CostUpdateXLAEvent                                        |
    |                                                                            |
    | RETURN VALUES                                                              |
    |       integer    1   Create SLA events in blue print org for this txn      |
    |                 -1   Error in the hook                                     |
    |                  0 or any other number                                     |
    |                      Do not create SLA events in blue print org for this   |
    |                      transaction  (Default)                                |
    | HISTORY                                                                    |
    |       04-Jan-2010   Ivan Pineda   Created                                  |
    *----------------------------------------------------------------------------*/
    FUNCTION   blueprint_sla_hook_wrap(p_wrap_txn_id                          NUMBER,
                                        p_wrap_tb_source                  VARCHAR2)
     RETURN integer IS
     l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count            NUMBER := 0;
     l_msg_data             VARCHAR2(8000);
     l_return_val           NUMBER := 0;
     BEGIN
        l_return_val := NVL(CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook(p_transaction_id => p_wrap_txn_id,
                                                                    p_table_source   => p_wrap_tb_source,
                                                                    x_return_status  => l_return_status,
                                                                    x_msg_count      => l_msg_count,
                                                                    x_msg_data       => l_msg_data),0);

        IF (l_return_status <> 'S' OR l_return_val = -1) THEN
           RAISE FND_API.g_exc_unexpected_error;
        ELSIF (l_return_val = 0) THEN
           return 0;
        ELSIF (l_return_val = 1) THEN
         RETURN 1;
        END IF;
     EXCEPTION
        -- WHEN FND_API.g_exc_unexpected_error THEN
        --    ROLLBACK TO Create_INVXLAEvent;
         WHEN OTHERS THEN
         --raise;
              raise_application_error(-20200, 'Error in: CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook');
        --    ROLLBACK TO Create_INVXLAEvent;
     END  blueprint_sla_hook_wrap;

PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT 'CST_XLA_PVT',
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_msg_prefix     VARCHAR2(64);
  l_msg_level      NUMBER;
  l_msg_module     VARCHAR2(256);
  l_beg_end_suffix VARCHAR2(15);
  l_org_cnt        NUMBER;
  l_line           VARCHAR2(32767);
BEGIN

  l_line       := line;
  l_msg_prefix := msg_prefix;
  l_msg_level  := msg_level;
  l_msg_module := msg_module;

  IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0) THEN
    l_msg_level  := FND_LOG.LEVEL_EXCEPTION;
  END IF;

  IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND PG_DEBUG = 'N' THEN
    RETURN;
  END IF;

  IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(l_msg_level, l_msg_module, SUBSTRB(l_line,1,4000));
  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END debug;


PROCEDURE clean_xla_gt IS
BEGIN
  debug('clean_xla_gt +');
  DELETE FROM XLA_AE_HEADERS_GT;
    debug( '1 XLA_AE_HEADERS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_AE_LINES_GT;
    debug( '2 XLA_AE_LINES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_VALIDATION_HDRS_GT;
    debug( '3 XLA_VALIDATION_HDRS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_VALIDATION_LINES_GT;
    debug( '4 XLA_VALIDATION_LINES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_CTRL_CTRBS_GT;
    debug( '5 XLA_BAL_CTRL_CTRBS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_PERIOD_STATS_GT;
    debug( '6 XLA_BAL_PERIOD_STATS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_RECREATE_GT;
    debug( '7 XLA_BAL_RECREATE_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_ANACRI_LINES_GT;
    debug( '8 XLA_BAL_ANACRI_LINES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_ANACRI_CTRBS_GT;
    debug( '9 XLA_BAL_ANACRI_CTRBS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_SYNCHRONIZE_GT;
    debug( '10 XLA_BAL_SYNCHRONIZE_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_STATUSES_GT;
    debug( '11 XLA_BAL_STATUSES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_CTRL_LINES_GT;
    debug( '12 XLA_BAL_CTRL_LINES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVENTS_GT;
    debug( '13 XLA_EVENTS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVT_CLASS_SOURCES_GT;
    debug( '14 XLA_EVT_CLASS_SOURCES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVT_CLASS_ORDERS_GT;
    debug( '15 XLA_EVT_CLASS_ORDERS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TAB_ERRORS_GT;
    debug( '16 XLA_TAB_ERRORS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_SEQ_JE_HEADERS_GT;
    debug( '17 XLA_SEQ_JE_HEADERS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TAB_NEW_CCIDS_GT;
    debug( '18 XLA_TAB_NEW_CCIDS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EXTRACT_OBJECTS_GT;
    debug( '19 XLA_EXTRACT_OBJECTS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_REFERENCE_OBJECTS_GT;
    debug( '20 XLA_REFERENCE_OBJECTS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TRANSACTION_ACCTS_GT;
    debug( '21 XLA_TRANSACTION_ACCTS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_UPG_LINE_CRITERIA_GT;
    debug( '22 XLA_UPG_LINE_CRITERIA_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TRIAL_BALANCES_GT;
    debug( '23 XLA_TRIAL_BALANCES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_ACCT_PROG_EVENTS_GT;
    debug( '24 XLA_ACCT_PROG_EVENTS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_ACCT_PROG_DOCS_GT;
    debug( '25 XLA_ACCT_PROG_DOCS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_MERGE_SEG_MAPS_GT;
    debug( '26 XLA_MERGE_SEG_MAPS_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVENTS_INT_GT;
    debug( '27 XLA_EVENTS_INT_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_REPORT_BALANCES_GT;
    debug( '28 XLA_REPORT_BALANCES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TB_BALANCES_GT;
    debug( '29 XLA_TB_BALANCES_GT row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_AC_CTRBS_GT;
    debug( '30 XLA_BAL_AC_CTRBS_GT row count :'||SQL%ROWCOUNT);
  debug('clean_xla_gt -');
END clean_xla_gt;


PROCEDURE standard_source_type
 (p_source_type_id IN NUMBER,
  p_action_id      IN NUMBER,
  x_list_result    OUT NOCOPY VARCHAR2,
  x_source_type_id OUT NOCOPY NUMBER)
IS
BEGIN
  debug('standard_source_type +');
  debug('  p_source_type_id :'||p_source_type_id);
  debug('  p_action_id      :'||p_action_id);

  IF p_action_id NOT IN (
     1 , --ISSUE
     2 , --INTRATXFR
     3 , --DIR_INTERORG_SHIP
    21 , --INTRANSIT_INTERORG_SHIP
    24 , --COST_UPDATE
    27 ) --RECEIPT
  THEN
     -- If Action ID is outside this range no custom inv txn allowed
     -- hence always in the standard list
     x_list_result := 'Y';
  ELSE
    IF p_source_type_id IN (
       1 , --PO
       2 , --SO
       3 , --ACCT
       4 , --MV_ORD
       5 , --JOB_SCHED
       6 , --ACCT_ALIAS
       7 , --INT_REQ
       8 , --INT_ORD
       9 , --CY_CNT
      10 , --PHYS_INV
      11 , --STD_CU
      12 , --RMA
      13 , --INV
      15 , --LAY_CU
      16 ) --PROJ_CONTRACT
   THEN
      --Although the p_action_id is in the customizable list
      --the txn_source_type is in the predefined cost list
      --hence standard combination
      x_list_result := 'Y';
   ELSE
      x_list_result := 'N';
   END IF;
  END IF;

  IF x_list_result = 'Y' THEN
    -- If the combination action ID and Txn Scr Type ID is standard
    -- x_source_type_id will have the same value as the Txn Scr Type ID
    x_source_type_id := p_source_type_id;
  ELSE
    -- If the combination action ID and Txn Scr Type ID is not standard
    -- x_source_type_id is -999 for User specified transaction Source Type
    x_source_type_id := -999;
  END IF;

  debug('  x_list_result    :'||x_list_result);
  debug('  x_source_type_id :'||x_source_type_id);
  debug('standard_source_type -');
EXCEPTION
  WHEN OTHERS THEN
    debug('OTHERS EXCEPTION in standard_source_type:'|| SQLERRM);
   RAISE;
END standard_source_type;

PROCEDURE dump_trx_info
(p_trx_info  IN t_xla_inv_trx_info,
 msg_prefix  IN VARCHAR2  DEFAULT 'CST',
 msg_module  IN VARCHAR2  DEFAULT 'CST_XLA_PVT',
 msg_level   IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
BEGIN
  debug( 'dump_trx_info +'                                                  ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.transaction_date     :'||p_trx_info.transaction_date ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TRANSACTION_ID       :'||p_trx_info.TRANSACTION_ID   ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TXN_TYPE_ID          :'||p_trx_info.TXN_TYPE_ID      ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TXN_SRC_TYPE_ID      :'||p_trx_info.TXN_SRC_TYPE_ID  ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TXN_ACTION_ID        :'||p_trx_info.TXN_ACTION_ID    ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.FOB_POINT            :'||p_trx_info.FOB_POINT        ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.ATTRIBUTE            :'||p_trx_info.ATTRIBUTE        ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TXN_ORGANIZATION_ID  :'||p_trx_info.TXN_ORGANIZATION_ID  ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TXFR_ORGANIZATION_ID :'||p_trx_info.TXFR_ORGANIZATION_ID ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.TP                   :'||p_trx_info.TP               ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.ENCUMBRANCE_FLAG     :'||p_trx_info.ENCUMBRANCE_FLAG ,msg_prefix,msg_module,msg_level);
  debug( '  p_trx_info.PRIMARY_QUANTITY     :'||p_trx_info.PRIMARY_QUANTITY ,msg_prefix,msg_module,msg_level);
  debug( 'dump_trx_info -'                                                  ,msg_prefix,msg_module,msg_level);
END dump_trx_info;


  FUNCTION exist_enc_dist (p_transaction_id IN NUMBER, p_organization_id IN NUMBER)
  RETURN VARCHAR2
  IS
    CURSOR c IS
    SELECT 'Y'
      FROM mtl_transaction_accounts
     WHERE transaction_id       = p_transaction_id
       AND organization_id      = p_organization_id
       AND accounting_line_type = 15;
    l_res   VARCHAR2(1);
  BEGIN
    debug('exist_enc_dist + : p_transaction_id-p_organization_id :'||p_transaction_id||'-'||p_organization_id);
    IF p_transaction_id IS NULL THEN
      l_res := 'N';
    ELSE
      OPEN c;
      FETCH c INTO l_res;
      IF c%NOTFOUND THEN
        l_res := 'N';
      END IF;
      CLOSE c;
    END IF;
    debug('   l_res :'||l_res);
    debug('exist_enc_dist -');
    RETURN l_res;
  END;


--------------------------------------------------------------------------------------
-- Local routines section : END
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--      API name        : Create_RCVXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--				p_trx_info              IN t_xla_rcv_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           : The API is called from the Receiving Transactions Processor
--                        (RCVVACCB.pls)
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_RCVXLAEvent  (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_trx_info          IN          t_xla_rcv_trx_info
            ) IS
  l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_RCVXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);

  -- SLA Data Structures
  l_source_data           XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_reference_data        XLA_EVENTS_PUB_PKG.t_event_reference_info;
  l_security_data         XLA_EVENTS_PUB_PKG.t_security;


  l_event_id             NUMBER;
  l_bc_event_id          NUMBER;
  l_event_type_code      CST_XLA_RCV_EVENT_MAP.EVENT_TYPE_CODE%TYPE;
  l_event_type_id        RCV_ACCOUNTING_EVENTS.EVENT_TYPE_ID%TYPE;

  l_parent_txn_type      RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
  l_parent_rcv_txn_id    NUMBER;
  /*l_pjm_blueprint        PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;*/


  /* Budgetary Control */
  l_bc_status               VARCHAR2(2000);
  l_packet_id               NUMBER;
  l_user_id                 NUMBER;
  l_resp_id                 NUMBER;
  l_resp_appl_id            NUMBER;

  l_accounting_option       NUMBER;
  l_batch                   NUMBER;
  l_errbuf                  VARCHAR2(1000);
  l_retcode                 NUMBER;
  l_request_id              NUMBER;

  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
  SAVEPOINT Create_RCVXLAEvent;
  l_stmt_num := 0;

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin'
             ,'Create_RCVXLAEvent <<');
  END IF;
  IF l_stmtLog THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Transaction: '||p_trx_info.TRANSACTION_ID||
                   ': Accounting Event: '||p_trx_info.ACCT_EVENT_ID );
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* Bug 6987381 : Receiving transactions should create accounting for
                   Blue Print Organization too
  l_stmt_num := 5;
  BEGIN
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_trx_info.inv_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;
  IF ( l_pjm_blueprint = 'Y' ) THEN
    IF l_procLog THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_RCVXLAEvent >>');
    END IF;
    return;
  END IF;
  */
  l_stmt_num := 10;

  l_source_data.ledger_id := p_trx_info.LEDGER_ID;
  -- Initialize other Source Data Attributes
  l_source_data.entity_type_code      := 'RCV_ACCOUNTING_EVENTS';
  l_source_data.application_id        := G_CST_APPLICATION_ID;
  l_source_data.source_application_id := G_PO_APPLICATION_ID;
  l_source_data.source_id_int_1       := p_trx_info.TRANSACTION_ID;
  l_source_data.source_id_int_2       := p_trx_info.ACCT_EVENT_ID;
  l_source_data.source_id_int_3       := p_trx_info.inv_organization_id;

  -- For Period End Accruals, transaction_number will be PO Number
  -- In all other cases it will be transaction_id
  IF (p_trx_info.acct_event_type_id = 14) THEN
   l_source_data.transaction_number    := p_trx_info.transaction_number;
  ELSE
   l_source_data.transaction_number    := p_trx_info.transaction_id;
  END IF;

  -- Initialize Security Information
  l_security_data.security_id_int_1 := p_trx_info.INV_ORGANIZATION_ID;
  l_security_data.security_id_int_2 := p_trx_info.OPERATING_UNIT;

  -- Initialize Reference Data
  l_reference_data.reference_date_1 := INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
                                       p_trx_info.transaction_date,
                                       p_trx_info.operating_unit);

  -- Get Event Type

  IF p_trx_info.ACCT_EVENT_TYPE_ID <> 13 THEN
    IF p_trx_info.ATTRIBUTE IS NOT NULL THEN
      l_stmt_num := 20;
      SELECT
        EVENT_TYPE_CODE
      INTO
        l_event_type_code
      FROM
        CST_XLA_RCV_EVENT_MAP
      WHERE TRANSACTION_TYPE_ID = p_trx_info.ACCT_EVENT_TYPE_ID
      AND   ATTRIBUTE           = p_trx_info.ATTRIBUTE;
    ELSE
      l_stmt_num := 30;
      SELECT
        EVENT_TYPE_CODE
      INTO
        l_event_type_code
      FROM
        CST_XLA_RCV_EVENT_MAP
      WHERE TRANSACTION_TYPE_ID = p_trx_info.ACCT_EVENT_TYPE_ID
      AND   ATTRIBUTE is NULL;
    END IF;
    IF l_stmtLog THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Event Type Code: '||l_event_type_code );
    END IF;
    -- SLA API to generate the event
    l_stmt_num := 40;

    l_event_id := XLA_EVENTS_PUB_PKG.create_event
                ( p_event_source_info => l_source_data,
                  p_event_type_code   => l_event_type_code,
                  -- Bug#7566005: Event_date is the accounting_date
                  p_event_date        => l_reference_data.reference_date_1,
                  --p_event_date        => p_trx_info.TRANSACTION_DATE,
                  p_event_status_code => xla_events_pub_pkg.C_EVENT_UNPROCESSED,
                  p_event_number      => NULL,
                  p_transaction_date  => p_trx_info.TRANSACTION_DATE,
                  p_reference_info    => l_reference_data,
                  p_valuation_method  => NULL,
                  p_security_context  => l_security_data
                );

    IF l_stmtLog THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Event ID: '||l_event_id );
    END IF;

    IF l_event_id is NULL THEN
      IF l_unexpLog THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Event creation failed for: Transaction ID: '||
		                to_char(p_trx_info.TRANSACTION_ID)||'Accounting Event ID: '||to_char(p_trx_info.ACCT_EVENT_ID));
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;




    FND_PROFILE.get('CST_RCV_ACCT_OPTION', l_accounting_option);



--
-- 8915988:
--     The following changes is a temporary fix for Encumbrance Accounting
--     waiting for the final fix from XLA.
--     If the customer has setup online receiving accounting option
--       Create accounting post to GL will created and post to GL
--     If Encumbrance accounting will not enforce the online accounting
--       post to GL
--



/*
Commented online accounting code flow for encumbrance enhancement.
Referred doc MED_PSA_CST_XLA_GL.doc
*/

--    IF (     l_accounting_option = 1) THEN

--	 OR  p_trx_info.ENCUMBRANCE_FLAG = 'Y' ) THEN

--      clean_xla_gt;

--      l_stmt_num := 270;

--      INSERT into XLA_ACCT_PROG_EVENTS_GT (Event_Id) VALUES (l_event_id);

--      l_stmt_num := 300;

--      xla_accounting_pub_pkg.accounting_program_events
--                    ( p_application_id       => 707
--                     ,p_accounting_mode      => 'FINAL'
                    -------------------------------------------------------------------------------
                    --BUG#6884519 We need to post to GL in final mode to activate Budgetary Control
                    -------------------------------------------------------------------------------
--                     ,p_gl_posting_flag      => 'Y'
--                    ,p_accounting_batch_id  => l_batch
--                     ,p_errbuf               => l_errbuf
--                     ,p_retcode              => l_retcode
--                     );


--    IF l_retcode <> 0 THEN
--       debug(' xla_accounting_pub_pkg.accounting_program_events Create_AccountingEntry :'||l_stmt_num);
--       debug(' l_event_type_code :'||l_event_type_code);
--       debug(' error buffer:'||SUBSTRB(l_errbuf,1,1000));
--{BUG#6879721
--       debug(' error code:'||l_retcode);
--       IF l_retcode = 2 THEN
--         IF l_retcode = 'XLA_UPG_HIST_RUNNING' THEN
--            FND_MESSAGE.set_name('XLA', 'XLA_UPG_HIST_RUNNING');
--            FND_MSG_PUB.ADD;
--         ELSE
--            FND_MESSAGE.set_name('XLA', 'XLA_ONLINE_ACCT_WARNING');
--            FND_MSG_PUB.ADD;
--         END IF;
--         RAISE FND_API.G_EXC_ERROR;
--       ELSE
--}
--         RAISE FND_API.g_exc_unexpected_error;
--       END IF; /*End  l_retcode = 2*/

--   END IF; /*End l_retcode <> 0*/

--   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
--       FND_MESSAGE.set_name('XLA', 'XLA_ONLINE_ACCT_SUCCESS');
--       FND_MSG_PUB.ADD;
--   END IF;

--   END IF; /* End  l_accounting_option = 1*/

  END IF; /*End p_trx_info.ACCT_EVENT_TYPE_ID <> 13*/





  /* If Encumbrance is enabled,
     - Create a separate encumbrance event
     - Insert this event into PSA_BC_XLA_EVENTS_GT
     - Call the Budgetary Control API to create the BC accounting entries */


  /* For the DELIVER and RTR events, we do not have the encumbrance amount populated in
   * RRS. This information is populated against the ENCUMBRANCE_REVERSAL event.
   * For the ENCUMBRANCE_REVERSAL event, the event that created this encumbrance
   * reversal is the event type that is created in SLA. This event is created
   * with a BUDGETARY_CONTROL_FLAG = 'Y' to distinguish it
   * The accounting for this BC event is done by PSA through the BC API
   * Note accounting_event_type_id = 13 mains "Encumbrance Reversal" */

/*
Commented whole encumbrance accounting code flow for encumbrance enhancement.
Referred doc MED_PSA_CST_XLA_GL.doc
*/

--  IF ( p_trx_info.ENCUMBRANCE_FLAG = 'Y' AND p_trx_info.ACCT_EVENT_TYPE_ID = 13 ) THEN

  --  l_stmt_num := 45;


--    SELECT ACCOUNTING_EVENT_ID,
--           EVENT_TYPE_ID
 --   INTO   l_source_data.SOURCE_ID_INT_2,
   --        l_event_type_id
--    FROM   RCV_ACCOUNTING_EVENTS
--    WHERE  RCV_TRANSACTION_ID = p_trx_info.TRANSACTION_ID
  --  AND    EVENT_TYPE_ID in (2, 3, 5);



  --  IF l_event_type_id = 2 THEN
  --    l_event_type_code := 'DELIVER_EXPENSE';
   -- ELSIF l_event_type_id = 5 THEN
   --   l_event_type_code := 'RETURN_TO_RECEIVING';
   -- ELSE
        /* Correction to Deliver or Return */
    --  l_stmt_num := 47;
    --  SELECT nvl(PARENT_TRANSACTION_ID, -1)
    --  INTO   l_parent_rcv_txn_id
    --  FROM   RCV_TRANSACTIONS
     -- WHERE  transaction_id = p_trx_info.TRANSACTION_ID;
     -- l_stmt_num := 48;
     -- IF (l_parent_rcv_txn_id <> -1) THEN
      --  SELECT TRANSACTION_TYPE
      --  INTO   l_parent_txn_type
      --  FROM   RCV_TRANSACTIONS
      --  WHERE  transaction_id = l_parent_rcv_txn_id;
      --END IF;
     -- l_stmt_num := 49;
     -- SELECT event_type_code
     -- INTO   l_event_type_code
     -- FROM   CST_XLA_RCV_EVENT_MAP
     -- WHERE  transaction_type_id = l_event_type_id
     -- AND    attribute = l_parent_txn_type;
   -- END IF;

--    l_stmt_num := 50;
    /* Create the encumbrance event for this transaction */
  --  l_bc_event_id := XLA_EVENTS_PUB_PKG.create_event
  --              ( p_event_source_info => l_source_data,
  --                p_event_type_code   => l_event_type_code,
                  -- Bug#7566005: Event_date is the accounting_date (already commented)
--                  p_event_date        => l_reference_data.reference_date_1,
                  -- p_event_date        => p_trx_info.TRANSACTION_DATE, (already commented)
--                  p_event_status_code => xla_events_pub_pkg.C_EVENT_UNPROCESSED,
 --                 p_event_number      => NULL,
--                  p_transaction_date  => p_trx_info.TRANSACTION_DATE,
 --                 p_reference_info    => l_reference_data,
  --                p_valuation_method  => NULL,
   --               p_security_context  => l_security_data,
    --              p_budgetary_control_flag => 'Y'
    --            );

  --  IF l_stmtLog THEN
   --     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Encumbrance Event ID: '||l_bc_event_id );
 --    END IF;

    -- IF l_bc_event_id is NULL THEN
  --     IF l_unexpLog THEN
   --      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Encumbrance Event creation failed for: Transaction ID: '||
 --	  	                to_char(p_trx_info.TRANSACTION_ID)||'Accounting Event ID: '||to_char(p_trx_info.ACCT_EVENT_ID));
 --      END IF;
  --     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  --  END IF;


  --  l_stmt_num := 55;

--    DELETE PSA_BC_XLA_EVENTS_GT;

  --  l_stmt_num := 60;
  --  INSERT INTO PSA_BC_XLA_EVENTS_GT (
 --     EVENT_ID,
 --     RESULT_CODE )
 --   VALUES (
 --     l_bc_event_id,
 --     'UNPROCESSED' );

  --  l_stmt_num := 60;

   -- FND_PROFILE.get('USER_ID', l_user_id);
   -- FND_PROFILE.get('RESP_ID', l_resp_id);
   -- FND_PROFILE.get('RESP_APPL_ID', l_resp_appl_id);


--    PSA_BC_XLA_PUB.Budgetary_Control (
--        p_api_version    => 1.0,
--        p_init_msg_list  => FND_API.G_FALSE,
--        x_return_status  => l_return_status,
--        x_msg_count      => x_msg_count,
--        x_msg_data       => x_msg_data,
--        p_application_id => G_CST_APPLICATION_ID,
--        p_bc_mode        => 'F', /* Force Mode */
--        p_override_flag  => NULL,
--        p_user_id        => l_user_id,
--        p_user_resp_id   => l_resp_id,
--        x_status_code    => l_bc_status,
--        x_packet_id      => l_packet_id );

--    IF ( l_bc_status in ('XLA_ERROR', 'FATAL') OR
--         l_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
--      l_api_message := 'Error in Encumbrance Accounting/Budgetory Control';
--      IF G_DEBUG = 'Y' THEN
--        IF l_unexpLog THEN
--          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Budgetary Control Failed for Event with BC Status Code: '||l_bc_status);
--        END IF;
--      END IF;
--      RAISE FND_API.g_exc_unexpected_error;
--    END IF;

--    IF ( l_bc_status = 'XLA_NO_JOURNAL') THEN
--      l_api_message := 'Journal Lines could not be created for the Encumbrance Event. Please inform your Administrator';
--      IF G_DEBUG = 'Y' THEN
--        IF l_unexpLog THEN
--          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Journal Lines could not be created for the Encumbrance Event. Please inform your Administrator. BC Status Code: '||l_bc_status);
--        END IF;
--      END IF;
--    END IF;

--  END IF;
/* Encumbrance Reversal
*/

/*
Changes for encumbrance enhancement are over.
Referred  doc MED_PSA_CST_XLA_GL.doc
*/

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module, ': Transaction ID: '|| to_char(p_trx_info.TRANSACTION_ID)||': Accounting Event ID: '||to_char(p_trx_info.ACCT_EVENT_ID));
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module, ': Event Id: '||to_char(l_event_id));
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_RCVXLAEvent >>');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Create_RCVXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)||': '||l_api_message
        );
     end if;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_RCVXLAEvent;
    x_msg_data := l_api_message || ': SQL Error: '||SQLERRM;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)||': '||x_msg_data
        );
    end if;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_RCVXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    x_msg_data := SQLERRM;

    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,l_module||' '||l_stmt_num
                ,'Create_RCVXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)||': '||x_msg_data
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );

END Create_RCVXLAEvent;

--------------------------------------------------------------------------------------
--      API name        : Create_INVXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_trx_info              IN t_xla_inv_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           : The API is called from Cost Processors (Std - inltcp.lpc,
--                        Avg - CSTACINB.pls, FIFO/LIFO - CSTLCINB.pls)
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_INVXLAEvent  (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_trx_info          IN          t_xla_inv_trx_info

          ) IS
  l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_INVXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);
  l_mta_exists           NUMBER;

  -- SLA Data Structures
  l_source_data           XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_reference_data        XLA_EVENTS_PUB_PKG.t_event_reference_info;
  l_security_data         XLA_EVENTS_PUB_PKG.t_security;

  l_events                CST_XLA_PVT.t_cst_inv_events;
  l_event_id              NUMBER;
  l_index                 pls_integer;
  l_txfr_process_flag     MTL_PARAMETERS.PROCESS_ENABLED_FLAG%TYPE;
  l_pjm_blueprint         PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;

  /* Budgetary Control */
  l_bc_status               VARCHAR2(2000);
  l_bc_event_id             NUMBER;
  l_packet_id               NUMBER;
  l_user_id                 NUMBER;
  l_resp_id                 NUMBER;
  l_resp_appl_id            NUMBER;

  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   --BUG#6125007
   l_psa_ins_flag         VARCHAR2(1) := 'N';

   --Blue Print client extension
   l_post_option          NUMBER;

   --User defined transaction type
   l_txn_src_type_id      NUMBER;
   l_in_list_result       VARCHAR2(1);

BEGIN
  SAVEPOINT Create_INVXLAEvent;
  l_stmt_num := 0;
  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin','Create_INVXLAEvent <<');
  END IF;

  --Display the content of p_trx_info
  dump_trx_info(p_trx_info  => p_trx_info,
                msg_prefix  => 'CST',
                msg_module  => 'Create_INVXLAEvent',
                msg_level   => FND_LOG.LEVEL_STATEMENT);

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_stmt_num := 10;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Check if any entries exist for this transaction in MTA.
     No Events would be raised for transactions without any MTA entries
     This might change later when SLA supports processing an event without
     any extracts
   */

  l_stmt_num := 15;

  SELECT count(*)
  INTO   l_mta_exists
  FROM   MTL_TRANSACTION_ACCOUNTS
  WHERE  TRANSACTION_ID = p_trx_info.transaction_id
  AND    rownum=1;

  l_stmt_num := 17;
  BEGIN
    /* Bug6987381 : Check PA_POSTING_FLAG only when the txn is physical
                    txn or it is a logical PO receipt in case of true
		    drop shipment.
     */
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_trx_info.txn_organization_id
      AND EXISTS ( SELECT 'X'
              FROM MTL_MATERIAL_TRANSACTIONS MMT
               WHERE MMT.TRANSACTION_ID = p_trx_info.transaction_id
                 AND ( (NVL(MMT.LOGICAL_TRANSACTION,2) = 2)
                      OR( (NVL(MMT.LOGICAL_TRANSACTION,2) = 1)
                          AND MMT.TRANSACTION_TYPE_ID = 19
                          AND MMT.TRANSACTION_ACTION_ID = 26
                          AND MMT.TRANSACTION_SOURCE_TYPE_ID = 1
                          AND NVL(MMT.LOGICAL_TRX_TYPE_CODE,5) = 2
                          AND EXISTS ( SELECT 'X'
			                FROM rcv_transactions rt
                                        WHERE rt.transaction_id =
                                          mmt.rcv_transaction_id
					  AND rt.organization_id =
					      p_trx_info.txn_organization_id
                                      )
                          )
                      )
              );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;

     IF ( l_mta_exists = 0) THEN
       IF l_procLog THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_INVXLAEvent >>');
       END IF;
       return;
     END IF;

     IF (l_pjm_blueprint = 'Y') THEN
      /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Changes for Blue Print organization enabling the creation of SLA events
       based on the value of new client extension cst_blueprint_create_SLA on
       package CST_PRJMFG_ACCT_HOOK where the custom code must be extended
       For more information visit 9145770
       +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        IF l_stmtLog THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'Calling the client extension CST_Blueprint_create_SLA'||
                         ' for Inventory Transaction: '||p_trx_info.TRANSACTION_ID);
        END IF;
        l_post_option := NVL(CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook(
                                   p_transaction_id   => p_trx_info.transaction_id,
                                   p_table_source     => 'MMT',
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data),0);
        IF (l_return_status <> 'S' OR l_post_option = -1) THEN
           x_msg_count := l_msg_count;
           x_msg_data  := l_msg_data;
           RAISE FND_API.g_exc_unexpected_error;
        ELSIF (l_post_option = 1) THEN
           IF l_stmtLog THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'Hook was used, events will be created for Inventory Transaction: '||
                      p_trx_info.TRANSACTION_ID );
           END IF;
        ELSE
           IF l_stmtLog THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'Hook was not used, events will not be created for Inventory Transaction: '||
                      p_trx_info.TRANSACTION_ID );
           END IF;
           IF l_procLog THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_INVXLAEvent >>');
           END IF;
           return;
        END IF;
      END IF;

  IF ( p_trx_info.txn_action_id = 36 and p_trx_info.txn_src_type_id = 2 ) THEN
    /* COGS Recognition or Adjustment Event */
    /* Check with CST_COGS_EVENT table to confirm event type */
    l_events(1).transaction_id  := p_trx_info.transaction_id;
    l_events(1).organization_id := p_trx_info.txn_organization_id;
    l_events(1).txn_src_type_id := p_trx_info.txn_src_type_id;

    l_stmt_num := 20;
    SELECT DECODE( EVENT_TYPE, 3, G_COGS_REC_EVENT, G_COGS_REC_ADJ_EVENT)
    INTO   l_events(1).event_type_code
    FROM   CST_COGS_EVENTS
    WHERE  MMT_TRANSACTION_ID = p_trx_info.transaction_id;

  ELSIF p_trx_info.txn_action_id = 3 THEN

  --User defined transaction type
   standard_source_type
   (p_source_type_id => p_trx_info.txn_src_type_id,
    p_action_id      => p_trx_info.txn_action_id,
    x_list_result    => l_in_list_result,
    x_source_type_id => l_txn_src_type_id);


    l_stmt_num := 30;
    SELECT nvl(process_enabled_flag, 'N')
    INTO   l_txfr_process_flag
    FROM   MTL_PARAMETERS
    WHERE  organization_id = p_trx_info.txfr_organization_id;

    IF ( p_trx_info.ATTRIBUTE = 'BOTH' AND l_txfr_process_flag <> 'Y' ) THEN
      /*
       * Standard Costing to Standard Costing
       * Sending Organization Creates both the events
       */
      /* Bug6792259 : Added the condition for including
                      transaction_source_type =7 when creating
		      the event for action =3 and source type = 8
		      in the case of std to std. As only shipment
		      transaction (action =3 and src_type =8) will
		      be accounted but we need to raise event for the
		      shipment transaction with event type of receipt
		      ( action = 3 and source type = 7) too.
      */



      l_stmt_num := 40;
      SELECT p_trx_info.transaction_id,
             decode(organization, 'TRANSFER', p_trx_info.txfr_organization_id,
                                            p_trx_info.txn_organization_id ),
             -- Leave this transaction src type ID to initial in source_id_int_3
             nvl( p_trx_info.txn_src_type_id, -1),
             event_type_code
      BULK COLLECT INTO l_events
      FROM   cst_xla_inv_event_map
      WHERE  transaction_action_id      = p_trx_info.txn_action_id
      AND   ( ( transaction_source_type_id = l_txn_src_type_id  )  --p_trx_info.txn_src_type_id
            /* Added following OR condition for Bug6792259 */
	    OR (l_txn_src_type_id = 8 AND transaction_source_type_id = 7)
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
      AND   ( ( p_trx_info.tp is null and tp = 'N' ) or
              ( p_trx_info.tp is not null and tp = p_trx_info.tp ) )
      AND NOT  (organization = 'SAME' AND transfer_type = 'RCPT');

    ELSE

      /* This is a discrete - OPM transfer */
      l_stmt_num := 50;
      SELECT p_trx_info.transaction_id,
             p_trx_info.txn_organization_id,
             --Leave this value in source_id_int_3
             nvl( p_trx_info.txn_src_type_id, -1),
             event_type_code
      INTO
             l_events(1).transaction_id,
             l_events(1).organization_id,
             l_events(1).txn_src_type_id,
             l_events(1).event_type_code
      FROM   cst_xla_inv_event_map
      WHERE  transaction_action_id      = p_trx_info.txn_action_id
      AND    transfer_type = DECODE(SIGN(p_trx_info.primary_quantity),-1,'SHIP','RCPT')
      AND   ( ( transaction_source_type_id = l_txn_src_type_id ) --p_trx_info.txn_src_type_id
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
      AND    organization                 = p_trx_info.attribute
      AND   ( ( p_trx_info.tp is null and tp = 'N' ) or
              ( p_trx_info.tp is not null and tp = p_trx_info.tp ) );
    END IF;
  ELSIF p_trx_info.txn_action_id = 24 AND p_trx_info.attribute = 'VARIANCE TRF' THEN

    l_stmt_num := 60;

  --User defined transaction type
   standard_source_type
   (p_source_type_id => p_trx_info.txn_src_type_id,
    p_action_id      => p_trx_info.txn_action_id,
    x_list_result    => l_in_list_result,
    x_source_type_id => l_txn_src_type_id);


    SELECT p_trx_info.transaction_id,
           p_trx_info.txn_organization_id,
           nvl ( p_trx_info.txn_src_type_id, -1),
           event_type_code
    INTO
           l_events(1).transaction_id,
           l_events(1).organization_id,
           l_events(1).txn_src_type_id,
           l_events(1).event_type_code
    FROM   cst_xla_inv_event_map
    WHERE  transaction_action_id      = p_trx_info.txn_action_id
    AND     ( ( transaction_source_type_id = l_txn_src_type_id) --p_trx_info.txn_src_type_id
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
    AND    attribute                  = p_trx_info.attribute;

  ELSIF  p_trx_info.txn_action_id IN (12, 21) THEN

    l_stmt_num := 70;

  --User defined transaction type
   standard_source_type
   (p_source_type_id => p_trx_info.txn_src_type_id,
    p_action_id      => p_trx_info.txn_action_id,
    x_list_result    => l_in_list_result,
    x_source_type_id => l_txn_src_type_id);


    SELECT nvl(process_enabled_flag, 'N')
    INTO   l_txfr_process_flag
    FROM   MTL_PARAMETERS
    WHERE  organization_id = p_trx_info.txfr_organization_id;

    IF l_txfr_process_flag <> 'Y' THEN
      l_stmt_num := 80;
      SELECT p_trx_info.transaction_id,
             decode(organization, 'TRANSFER', p_trx_info.txfr_organization_id,
                                              p_trx_info.txn_organization_id ),
             nvl( p_trx_info.txn_src_type_id, -1),
             event_type_code
      BULK COLLECT INTO l_events
      FROM   cst_xla_inv_event_map
      WHERE  transaction_action_id      = p_trx_info.txn_action_id
      AND   ( ( transaction_source_type_id = l_txn_src_type_id) --p_trx_info.txn_src_type_id )
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
      AND    fob_point = p_trx_info.fob_point
      AND    ( tp is null or ( tp is not null and tp = p_trx_info.tp ));
    ELSE
      /* Discrete to Process Transfer. Seed the event in the discrete org only*/
      l_stmt_num := 90;

  --User defined transaction type
   standard_source_type
   (p_source_type_id => p_trx_info.txn_src_type_id,
    p_action_id      => p_trx_info.txn_action_id,
    x_list_result    => l_in_list_result,
    x_source_type_id => l_txn_src_type_id);



      SELECT p_trx_info.transaction_id,
             p_trx_info.txn_organization_id,
             nvl( p_trx_info.txn_src_type_id, -1),
             event_type_code
      INTO   l_events(1).transaction_id,
             l_events(1).organization_id,
             l_events(1).txn_src_type_id,
             l_events(1).event_type_code
      FROM   cst_xla_inv_event_map
      WHERE  transaction_action_id      = p_trx_info.txn_action_id
      AND   ( ( transaction_source_type_id = l_txn_src_type_id) --p_trx_info.txn_src_type_id )
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
      AND    fob_point = p_trx_info.fob_point
      AND    ( tp is null or ( tp is not null and tp = p_trx_info.tp ))
      AND    organization =  'SAME';
    END IF;

  ELSIF ( p_trx_info.txn_type_id = 92 AND p_trx_info.txn_action_id = 30 AND
          p_trx_info.txn_src_type_id = 5 ) THEN

    l_events(1).transaction_id  := p_trx_info.transaction_id;
    l_events(1).organization_id := p_trx_info.txn_organization_id;
    l_events(1).txn_src_type_id := p_trx_info.txn_src_type_id;
    l_events(1).event_type_code := 'WIP_EST_SCRAP_REVERSAL';



  ELSIF ( ( p_trx_info.txn_action_id = 1 AND p_trx_info.txn_src_type_id = 8 ) OR
          ( p_trx_info.txn_action_id = 17  AND p_trx_info.txn_src_type_id = 7 )) THEN
    --
    -- src type ID 7 or 8 are for internal requisition and internal order
    -- For now no user defined transaction type is expected
    --
    l_stmt_num := 95;
    SELECT p_trx_info.transaction_id,
           p_trx_info.txn_organization_id,
           nvl( p_trx_info.txn_src_type_id, -1),
           event_type_code
    INTO   l_events(1).transaction_id,
           l_events(1).organization_id,
           l_events(1).txn_src_type_id,
           l_events(1).event_type_code
    FROM   cst_xla_inv_event_map
    WHERE  transaction_action_id      = p_trx_info.txn_action_id
    AND     ( ( transaction_source_type_id = p_trx_info.txn_src_type_id )
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             )
    AND   ( tp is null or ( tp is not null and tp = p_trx_info.tp ));
  ELSE /* Other Transactions */
    l_stmt_num := 100;

  --User defined transaction type
   standard_source_type
   (p_source_type_id => p_trx_info.txn_src_type_id,
    p_action_id      => p_trx_info.txn_action_id,
    x_list_result    => l_in_list_result,
    x_source_type_id => l_txn_src_type_id);

    SELECT p_trx_info.transaction_id,
           p_trx_info.txn_organization_id,
           nvl( p_trx_info.txn_src_type_id, -1),
           event_type_code
    INTO   l_events(1).transaction_id,
           l_events(1).organization_id,
           l_events(1).txn_src_type_id,
           l_events(1).event_type_code
    FROM   cst_xla_inv_event_map
    WHERE  transaction_action_id      = p_trx_info.txn_action_id
    AND    attribute is null
    AND     ( ( transaction_source_type_id = l_txn_src_type_id) --p_trx_info.txn_src_type_id )
            OR(     transaction_source_type_id is null
                AND NOT EXISTS (
                    SELECT 1
                    FROM   cst_xla_inv_event_map
                    WHERE  transaction_source_type_id = l_txn_src_type_id --p_trx_info.txn_src_type_id
                    AND    transaction_action_id      = p_trx_info.txn_action_id )
               )
             );

  END IF;

  -- Src type Id = 5 <=> Job Or Scheduled jobs for WIP
  -- Issue from Job Schedule of WIP <=> Inventory Issue
  --  IF (  p_trx_info.txn_action_id = 1 AND p_trx_info.txn_src_type_id = 5  AND p_trx_info.attribute = 'CITW' ) THEN
  IF (   p_trx_info.txn_action_id = 1
      AND l_txn_src_type_id       IN (5 ,-999)
      AND p_trx_info.attribute    = 'CITW' )
  THEN
    l_events(2).transaction_id  := p_trx_info.transaction_id;
    l_events(2).organization_id := p_trx_info.txn_organization_id;
    l_events(2).txn_src_type_id := 13;
    l_events(2).event_type_code := 'CG_TXFR';
  END IF;

  /* Clear the PSA GT table
     Inserts are done into the table in the following loop */

  l_stmt_num := 115;

  --DELETE PSA_BC_XLA_EVENTS_GT;

  FOR l_index IN l_events.FIRST .. l_events.LAST LOOP
    l_stmt_num := 120;
    SELECT
            ledger_id,
            operating_unit
    INTO
            l_source_data.ledger_id,
            l_security_data.security_id_int_2
    FROM  CST_ACCT_INFO_V
    WHERE organization_id = l_events(l_index).ORGANIZATION_ID;

    -- Initialize other Source Data Attributes
    l_source_data.entity_type_code      := 'MTL_ACCOUNTING_EVENTS';
    l_source_data.application_id        := G_CST_APPLICATION_ID;
    l_source_data.source_application_id := G_INV_APPLICATION_ID;
    l_source_data.source_id_int_1       := l_events(l_index).TRANSACTION_ID;
    l_source_data.source_id_int_2       := l_events(l_index).ORGANIZATION_ID;
    l_source_data.source_id_int_3       := l_events(l_index).TXN_SRC_TYPE_ID;
    l_source_data.transaction_number    := l_events(l_index).TRANSACTION_ID;
    -- Initialize Security Information
    l_security_data.security_id_int_1 := l_events(l_index).ORGANIZATION_ID;
    -- Initialize Reference Data
    l_reference_data.reference_date_1 := INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
                                         p_trx_info.transaction_date,
                                         l_security_data.security_id_int_2);

    l_stmt_num := 130;
    l_event_id := XLA_EVENTS_PUB_PKG.create_event
                ( p_event_source_info => l_source_data,
                  p_event_type_code   => l_events(l_index).event_type_code,
                  -- Bug#7566005: Event_date is the accounting_date
                  p_event_date        => l_reference_data.reference_date_1,
                  --p_event_date        => p_trx_info.TRANSACTION_DATE,
                  p_event_status_code => xla_events_pub_pkg.C_EVENT_UNPROCESSED,
                  p_event_number      => NULL,
                  p_transaction_date  => p_trx_info.TRANSACTION_DATE,
                  p_reference_info    => l_reference_data,
                  p_valuation_method  => NULL,
                  p_security_context  => l_security_data
                );
    IF l_stmtLog THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Transaction:
     '||p_trx_info.TRANSACTION_ID||' : Source Type ID:
     '||p_trx_info.TXN_SRC_TYPE_ID||' : Event Type:
     '||l_events(l_index).event_type_code||' :Event ID: '||l_event_id);
    END IF;
    IF l_event_id is NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    --User Defined transaction type with Encumbrance Accounting
    --Need to discuss with PSA
    --

 /* { bug 9356654- Commented for single event -Inventory starts */
--    /* If Encumbrance is enabled,
--       - Create BC Events in SLA
--       - Insert these events into PSA_BC_XLA_EVENTS_GT */
--    IF     ( P_TRX_INFO.ENCUMBRANCE_FLAG = 'Y')
      --{BUG#6125007
--       AND  l_events(l_index).event_type_code IN
--            (
             ---------------------------
			 -- Class DIR_INTERORG_RCPT
             ---------------------------
--             'DIR_INTERORG_RCPT' ,'DIR_INTERORG_RCPT_NO_TP' ,'DIR_INTERORG_RCPT_TP',
--             ---------------------------
--             -- Class PURCHASE_ORDER
             ---------------------------
--             'LOG_PO_DEL_ADJ','LOG_PO_DEL_INV','LOG_RET_RI_INV',
--             'PO_DEL_ADJ'    ,'PO_DEL_INV'    ,'RET_RI_INV'    ,
             ---------------------------
             -- Class FOB_RCPT_RECIPIENT_RCPT
             ---------------------------
  --           'FOB_RCPT_RECIPIENT_RCPT_NO_TP','FOB_RCPT_RECIPIENT_RCPT_TP',
             ---------------------------
             -- Class FOB_SHIP_RECIPIENT_SHIP
             ---------------------------
--             'FOB_SHIP_RECIPIENT_SHIP_NO_TP'   ,'FOB_SHIP_RECIPIENT_SHIP_TP' ,
             -----------------------------------
             --6611359 Internal order to expense
             -----------------------------------
  --           'EXP_REQ_RCPT_NO_TP','EXP_REQ_RCPT_TP')
       --}
  --  THEN

  --   IF (exist_enc_dist(l_events(l_index).TRANSACTION_ID,l_events(l_index).ORGANIZATION_ID) = 'Y') THEN

 --     --BUG#6125007
 --      IF l_psa_ins_flag = 'N' THEN
 --         l_psa_ins_flag  := 'Y';
 --      END IF;

 --      IF l_stmtLog THEN
  --        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'MMT PSA event event_type_code: '||l_events(l_index).event_type_code );
 --      END IF;


 --      /* Create the encumbrance event for this transaction */
  --     l_bc_event_id := XLA_EVENTS_PUB_PKG.create_event
  --               ( p_event_source_info => l_source_data,
  --                 p_event_type_code   => l_events(l_index).event_type_code,
                  -- Bug#7566005: Event_date is the accounting_date
 --                  p_event_date        => l_reference_data.reference_date_1,
                  --p_event_date        => p_trx_info.TRANSACTION_DATE,
  --                 p_event_status_code => xla_events_pub_pkg.C_EVENT_UNPROCESSED,
  --                 p_event_number      => NULL,
  --                 p_transaction_date  => p_trx_info.TRANSACTION_DATE,
  --                 p_reference_info    => l_reference_data,
  --                 p_valuation_method  => NULL,
   --                p_security_context  => l_security_data,
   --                p_budgetary_control_flag => 'Y'
    --             );
   --      IF l_stmtLog THEN
 --          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Encumbrance Event ID: '||l_bc_event_id );
  --       END IF;

 --        IF l_bc_event_id is NULL THEN
 --           IF l_unexpLog THEN
  --            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Encumbrance Event creation failed for: Transaction ID: '||
 --	  	                to_char(p_trx_info.TRANSACTION_ID));
 --            END IF;
 --            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 --         END IF;

 --         l_stmt_num := 140;
 --         INSERT INTO PSA_BC_XLA_EVENTS_GT (
 --           EVENT_ID,
 --           RESULT_CODE )
  --         VALUES (
  --           l_bc_event_id,
  --          'UNPROCESSED' );
  --     END IF;

  -- END IF; /* P_TRX_INFO.ENCUMBRANCE_FLAG = 'Y'*/

   /*Commented for single event -Inventory ends }*/

  END LOOP;

  /* Call Budgetary Control API for certain Events.
   * Support for other events would be added later */

   /*bug 9356654 Commented for single event -Inventory starts }*/

  --IF      ( P_TRX_INFO.ENCUMBRANCE_FLAG = 'Y'
     --{BUG#6125007
 --     AND   l_psa_ins_flag  = 'Y' )
--  THEN

--    FND_PROFILE.get('USER_ID', l_user_id);
--    FND_PROFILE.get('RESP_ID', l_resp_id);
--    FND_PROFILE.get('RESP_APPL_ID', l_resp_appl_id);

--    l_stmt_num := 150;
--    PSA_BC_XLA_PUB.Budgetary_Control (
--        p_api_version    => 1.0,
--        p_init_msg_list  => FND_API.G_FALSE,
--        x_return_status  => l_return_status,
 --       x_msg_count      => x_msg_count,
 --       x_msg_data       => x_msg_data,
--        p_application_id => G_CST_APPLICATION_ID,
--        p_bc_mode        => 'F', /* Force Mode */
--        p_override_flag  => NULL,
--        p_user_id        => l_user_id,
--        p_user_resp_id   => l_resp_id,
--        x_status_code    => l_bc_status,
--        x_packet_id      => l_packet_id );

--    IF ( l_bc_status in ('XLA_ERROR', 'FATAL') OR
        -- l_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
 --     l_api_message := 'Error in Encumbrance Accounting/Budgetory Control';
 --     IF G_DEBUG = 'Y' THEN
 --       IF l_unexpLog THEN
 --         FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,'Budgetary Control Failed for Event with BC Status Code: '||l_bc_status);
--        END IF;
--      END IF;
--      RAISE FND_API.g_exc_unexpected_error;
--    END IF;

 -- END IF; /* ENCUMBRANCE_FLAG = 'Y' */

 /*Commented for single event -Inventory ends }*/

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_INVXLAEvent >>');
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Create_INVXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_INVXLAEvent;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_INVXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||':'||l_stmt_num ,'Create_INVXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
END Create_INVXLAEvent;

--------------------------------------------------------------------------------------
--      API name        : Create_WIPXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_trx_info              IN t_xla_wip_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_WIPXLAEvent  (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_trx_info          IN          t_xla_wip_trx_info

          ) IS
  l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_WIPXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);
  l_pjm_blueprint        PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;

  -- SLA Data Structures
  l_source_data           XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_reference_data        XLA_EVENTS_PUB_PKG.t_event_reference_info;
  l_security_data         XLA_EVENTS_PUB_PKG.t_security;

  l_event_id             NUMBER;
  l_event_type_code      VARCHAR2(30);

  --Blue Print client extension
  l_post_option          NUMBER;

  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


BEGIN
  SAVEPOINT Create_WIPXLAEvent;
  l_stmt_num := 0;

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin'
             ,' Create_WIPXLAEvent <<');
  END IF;
  IF l_stmtLog THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                  ': Transaction ID: '|| p_trx_info.TRANSACTION_ID||
                  ': Transaction Type: '|| p_trx_info.TXN_TYPE_ID||
                  ': Resource ID: '|| p_trx_info.WIP_RESOURCE_ID ||
                  ': Basis Type: '||p_trx_info.WIP_BASIS_TYPE_ID ||
		  ': Organization ID: '||p_trx_info.INV_ORGANIZATION_ID);
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 5;
  BEGIN
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_trx_info.inv_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;

  IF ( l_pjm_blueprint = 'Y' ) THEN
    /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Changes for Blue Print organization enabling the creation of SLA events
       based on the value of new client extension cst_blueprint_create_SLA on
       package CST_PRJMFG_ACCT_HOOK where the custom code must be extended
       For more information visit 9145770
       +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        IF l_stmtLog THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'Calling the client extension CST_Blueprint_create_SLA'||
                         ' for WCTI Transaction: '||p_trx_info.TRANSACTION_ID);
        END IF;
        l_post_option := NVL(CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook(
                                   p_transaction_id  => p_trx_info.transaction_id,
                                   p_table_source    => 'WCTI',
                                   x_return_status   => l_return_status,
                                   x_msg_count       => l_msg_count,
                                   x_msg_data        => l_msg_data) ,0);
        IF (l_return_status <> 'S' OR l_post_option = -1) THEN
           x_msg_count := l_msg_count;
           x_msg_data  := l_msg_data;
           RAISE FND_API.g_exc_unexpected_error;
        ELSIF (l_post_option = 1) THEN
           IF l_stmtLog THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'Hook was used, events will be created for WCTI Transaction: '||
                      p_trx_info.TRANSACTION_ID );
           END IF;
        ELSE
           IF l_stmtLog THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'Hook was not used, events will not be created for WCTI Transaction: '||
                      p_trx_info.TRANSACTION_ID );
           END IF;
           IF l_procLog THEN
               FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_WIPXLAEvent >>');
           END IF;
           return;
        END IF;
   END IF;

  l_stmt_num := 10;
  -- Get the Legal Entity and Ledger Information
  SELECT
	  ledger_id,
          operating_unit
  INTO
	  l_source_data.ledger_id,
          l_security_data.security_id_int_2
  FROM  CST_ACCT_INFO_V
  WHERE organization_id = p_trx_info.INV_ORGANIZATION_ID;
  -- Initialize other Source Data Attributes
  l_source_data.entity_type_code      := 'WIP_ACCOUNTING_EVENTS';
  l_source_data.application_id        := G_CST_APPLICATION_ID;
  l_source_data.source_application_id := G_WIP_APPLICATION_ID;
  l_source_data.source_id_int_1       := p_trx_info.TRANSACTION_ID;
  l_source_data.source_id_int_2       := p_trx_info.WIP_RESOURCE_ID;
  l_source_data.source_id_int_3       := p_trx_info.WIP_BASIS_TYPE_ID;
  l_source_data.transaction_number    := p_trx_info.TRANSACTION_ID;

  -- Initialize Security Information
  l_security_data.security_id_int_1 := p_trx_info.INV_ORGANIZATION_ID;

  -- Initialize Reference Data
  l_reference_data.reference_date_1 := INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
                                       p_trx_info.transaction_date,
                                       l_security_data.security_id_int_2);

  -- Get Event Type

  IF p_trx_info.ATTRIBUTE IS NOT NULL THEN
    l_stmt_num := 20;
    SELECT
      EVENT_TYPE_CODE
    INTO
      l_event_type_code
    FROM
      CST_XLA_WIP_EVENT_MAP
    WHERE TRANSACTION_TYPE_ID = p_trx_info.TXN_TYPE_ID
    AND   ATTRIBUTE           = p_trx_info.ATTRIBUTE;
  ELSE
    l_stmt_num := 30;
    SELECT
      EVENT_TYPE_CODE
    INTO
      l_event_type_code
    FROM
      CST_XLA_WIP_EVENT_MAP
    WHERE TRANSACTION_TYPE_ID = p_trx_info.TXN_TYPE_ID
    AND   ATTRIBUTE IS NULL;
  END IF;
  IF l_stmtLog THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Event Type: '||l_event_type_code);
  END IF;
	-- SLA API to generate the event
  l_stmt_num := 40;

  l_event_id := XLA_EVENTS_PUB_PKG.create_event
                  ( p_event_source_info => l_source_data,
                    p_event_type_code   => l_event_type_code,
                    -- Bug#7566005: Event_date is the accounting_date
                    p_event_date        => l_reference_data.reference_date_1,
                    --p_event_date        => p_trx_info.TRANSACTION_DATE,
                    p_event_status_code => xla_events_pub_pkg.C_EVENT_UNPROCESSED,
                    p_event_number      => NULL,
                    p_transaction_date  => p_trx_info.TRANSACTION_DATE,
                    p_reference_info    => l_reference_data,
                    p_valuation_method  => NULL,
                    p_security_context  => l_security_data
                  );

  IF l_stmtLog THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, 'Event ID: '||l_event_id);
  END IF;
  IF l_event_id is NULL THEN
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module, 'Event creation failed for: Transaction ID: '||to_char(p_trx_info.TRANSACTION_ID)||': Organization ID: '||to_char(p_trx_info.INV_ORGANIZATION_ID));
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_WIPXLAEvent >>');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Create_WIPXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_WIPXLAEvent;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_WIPXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||':'||l_stmt_num
                ,'Create_WIPXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );

END Create_WIPXLAEvent;

--------------------------------------------------------------------------------------
--      API name        : CreateBulk_WIPXLAEvent
--      Type            : Private
--      Function        : To create WIP accounting events in bulk for a
--                        WIP transaction group and Organization
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--			        p_wcti_group_id         IN NUMBER
--				p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a WCTI group_id and creates events
--                        for all the transactions within that group
--                        Called from cmlwrx.lpc, cmlwsx.lpc, CSTPEACB.pls
--                        and CSTGWJVB.pls
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE CreateBulk_WIPXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_wcti_group_id     IN          NUMBER,
            p_organization_id   IN          NUMBER ) IS

  l_api_name    CONSTANT VARCHAR2(30)   := 'CreateBulk_WIPXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);

  l_ledger_id      NUMBER;
  l_operating_unit NUMBER;
  l_index          NUMBER;
  l_pjm_blueprint        PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;


  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


BEGIN

  SAVEPOINT CreateBulk_WIPXLAEvent;
  l_stmt_num := 0;

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin' ,' CreateBulk_WIPXLAEvent <<');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 5;
  BEGIN
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;
 /* Modified to call the Blue Print hook
  IF ( l_pjm_blueprint = 'Y' ) THEN
    IF l_procLog THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','CreateBulk_WIPXLAEvent >>');
    END IF;
    return;
  END IF;
 */
  -- Get Ledger
  l_stmt_num := 10;
  SELECT ledger_id,
         operating_unit
  INTO   l_ledger_id,
         l_operating_unit
  FROM   CST_ACCT_INFO_V
  WHERE  ORGANIZATION_ID = p_organization_id;

  l_stmt_num := 20;
  /* Purge Temp Table */
  DELETE XLA_EVENTS_INT_GT;
  INSERT INTO xla_events_int_gt(
      application_id,
      ledger_id,
      entity_code,
      source_id_int_1,
      source_id_int_2,
      source_id_int_3,
      transaction_number,
      event_class_code,
      event_type_code,
      event_date,
      event_status_code,
      security_id_int_1,
      security_id_int_2,
      transaction_date,
      reference_date_1
    )
  SELECT DISTINCT
    G_CST_APPLICATION_ID,
    l_ledger_id,
    'WIP_ACCOUNTING_EVENTS',
    WTA.TRANSACTION_ID,
    WTA.RESOURCE_ID,
    WTA.BASIS_TYPE,
    WTA.TRANSACTION_ID,
    'ABSORPTION',
    DECODE( WTA.COST_ELEMENT_ID, 3, G_RES_ABS_EVENT,
                                 4, DECODE (WCTI.SOURCE_CODE, 'IPV',
                                              G_IPV_TRANSFER_EVENT,
                                              DECODE(WCTI.AUTOCHARGE_TYPE, 3, G_OSP_EVENT,
                                                                           4, G_OSP_EVENT, G_RES_ABS_EVENT)),
                                 5, G_OVH_ABS_EVENT ),
  --BUG#7566005 synch event_date with accounting_date
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
    WCTI.TRANSACTION_DATE,
    l_operating_unit),
  --WCTI.TRANSACTION_DATE,
    XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
    WCTI.ORGANIZATION_ID,
    l_operating_unit,
    WCTI.TRANSACTION_DATE,
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
      WCTI.TRANSACTION_DATE,
      l_operating_unit)
  FROM
    WIP_TRANSACTION_ACCOUNTS WTA,
    WIP_COST_TXN_INTERFACE WCTI
  WHERE
      WCTI.TRANSACTION_ID = WTA.TRANSACTION_ID
  AND WCTI.GROUP_ID       = p_wcti_group_id
  AND WCTI.TRANSACTION_TYPE in (1, 2, 3)
  AND DECODE(l_pjm_blueprint,'N',1,
      NVL(blueprint_sla_hook_wrap(WTA.transaction_id, 'WCTI'),0)) = 1
  UNION ALL
  SELECT
    G_CST_APPLICATION_ID,
    l_ledger_id,
    'WIP_ACCOUNTING_EVENTS',
    WCTI.TRANSACTION_ID,
    -1,
    /* Bug 9088305: NVL(WCTI.BASIS_TYPE, -1), */
    Decode(WCTI.BASIS_TYPE, NULL, Decode(WCTI.TRANSACTION_TYPE, 17, 1, -1), WCTI.BASIS_TYPE),
    WCTI.TRANSACTION_ID,
    CXWEM.EVENT_CLASS_CODE,
    CXWEM.EVENT_TYPE_CODE,
  --BUG#7566005 synch event_date with accounting_date
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
    WCTI.TRANSACTION_DATE,
    l_operating_unit),
  --WCTI.TRANSACTION_DATE,
    XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
    WCTI.ORGANIZATION_ID,
    l_operating_unit,
    WCTI.TRANSACTION_DATE,
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
      WCTI.TRANSACTION_DATE,
      l_operating_unit)
  FROM
    WIP_COST_TXN_INTERFACE   WCTI,
    CST_XLA_WIP_EVENT_MAP    CXWEM
  WHERE
      WCTI.GROUP_ID         = p_wcti_group_id
  AND WCTI.TRANSACTION_TYPE = CXWEM.TRANSACTION_TYPE_ID
/* Modified for bug 9088305
  AND WCTI.TRANSACTION_TYPE in (5, 6, 17) */
  AND (WCTI.TRANSACTION_TYPE in (5, 6)
    OR (WCTI.TRANSACTION_TYPE = 17 AND
        ((WCTI.SOURCE_CODE = 'IPV' AND
          CXWEM.ATTRIBUTE = 'IPV')
          OR
         (WCTI.SOURCE_CODE = 'RCV' AND
          CXWEM.ATTRIBUTE IS NULL))))
--{BUG#6916164
  AND EXISTS (SELECT NULL
              FROM WIP_TRANSACTION_ACCOUNTS WTA
              WHERE wta.transaction_id = WCTI.TRANSACTION_ID
                AND DECODE(l_pjm_blueprint,'N',1,
                      NVL(blueprint_sla_hook_wrap(wta.transaction_id, 'WCTI'),0)) = 1);
--}
  l_stmt_num := 30;

  xla_events_pub_pkg.create_bulk_events(
    p_source_application_id => G_WIP_APPLICATION_ID,
    p_application_id        => G_CST_APPLICATION_ID,
    p_ledger_id             => l_ledger_id,
    p_entity_type_code      => 'WIP_ACCOUNTING_EVENTS');


  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end','CreateBulk_WIPXLAEvent >>');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO CreateBulk_WIPXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO CreateBulk_WIPXLAEvent;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO CreateBulk_WIPXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||':'||l_stmt_num ,'CreateBulk_WIPXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );


END CreateBulk_WIPXLAEvent;


--------------------------------------------------------------------------------------
--      API name        : Create_CostUpdateXLAEvent
--      Type            : Private
--      Function        : To create Standard Cost Update accounting events in bulk
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_update_id         IN NUMBER
--                              p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a Standard Cost Update ID and organization_id
--                        and creates all events associated with it.
--                        Called from cmlicu.lpc
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE Create_CostUpdateXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_update_id         IN          NUMBER,
            p_organization_id   IN          NUMBER ) IS

  l_api_name    CONSTANT VARCHAR2(30)   := 'Create_CostUpdateXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);

  l_ledger_id      NUMBER;
  l_operating_unit NUMBER;
  l_index          NUMBER;
  l_pjm_blueprint        PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;


  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

  SAVEPOINT Create_CostUpdateXLAEvent;
  l_stmt_num := 0;

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin' ,' Create_CostUpdateXLAEvent <<');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 5;
  BEGIN
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;
 /* Modified to enable the call to the blue print hook
  IF ( l_pjm_blueprint = 'Y' ) THEN
    IF l_procLog THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_CostUpdateXLAEvent >>');
    END IF;
    return;
  END IF;
*/
  -- Get Ledger
  l_stmt_num := 10;
  SELECT ledger_id,
         operating_unit
  INTO   l_ledger_id,
         l_operating_unit
  FROM   CST_ACCT_INFO_V
  WHERE  ORGANIZATION_ID = p_organization_id;

  l_stmt_num := 20;

  /* Purge Temp Table */
  DELETE XLA_EVENTS_INT_GT;


  INSERT INTO xla_events_int_gt
    (
      application_id,
      ledger_id,
      entity_code,
      source_id_int_1,
      source_id_int_2,
      source_id_int_3,
      transaction_number,
      event_class_code,
      event_type_code,
      event_date,
      event_status_code,
      security_id_int_1,
      security_id_int_2,
      transaction_date,
      reference_date_1
    )
    SELECT
      G_CST_APPLICATION_ID,
      l_ledger_id,
      'MTL_ACCOUNTING_EVENTS',
      mmt.TRANSACTION_ID,            -- SOURCE_ID_INT_1
      mmt.ORGANIZATION_id,           -- SOURCE_ID_INT_2 (ORGANIZATION)
      mmt.TRANSACTION_SOURCE_TYPE_ID,-- SOURCE_ID_INT_3 (TRANSACTION_SOURCE_TYPE_ID)
      mmt.TRANSACTION_ID,
      'MTL_COST_UPD',
      'STD_COST_UPD',
  --BUG#7566005 synch event_date with accounting_date
    --  mmt.TRANSACTION_DATE,
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
    mmt.TRANSACTION_DATE,
    l_operating_unit),
      --{BUG#7505874
      DECODE(mta.slid,NULL,XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION, XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED),
      --}
      mmt.ORGANIZATION_ID,
      l_operating_unit,
      mmt.TRANSACTION_DATE,
      INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
        mmt.TRANSACTION_DATE,
        l_operating_unit)
    FROM
      MTL_MATERIAL_TRANSACTIONS  mmt
      --{BUG#7505874
    ,(SELECT MAX(inv_sub_ledger_id)  slid
             ,transaction_id         trx_id
         FROM mtl_transaction_accounts
        GROUP BY transaction_id) mta
      --}
    WHERE
          mmt.TRANSACTION_SOURCE_ID      = p_update_id
      AND mmt.TRANSACTION_TYPE_ID        = 24
      AND mmt.TRANSACTION_ACTION_ID      = 24
      AND mmt.TRANSACTION_SOURCE_TYPE_ID = 11
      AND mmt.ORGANIZATION_ID            = p_organization_id
      AND mmt.transaction_id             = mta.trx_id(+)   --BUG#7505874
      AND DECODE(l_pjm_blueprint,'N',1,
           NVL(blueprint_sla_hook_wrap(MMT.transaction_id, 'MMT'),0)) = 1;





  l_stmt_num := 30;

  xla_events_pub_pkg.create_bulk_events(
    p_source_application_id => G_INV_APPLICATION_ID,
    p_application_id        => G_CST_APPLICATION_ID,
    p_ledger_id             => l_ledger_id,
    p_entity_type_code      => 'MTL_ACCOUNTING_EVENTS');


  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_CostUpdateXLAEvent >>');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Create_CostUpdateXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_CostUpdateXLAEvent;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_CostUpdateXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||':'||l_stmt_num ,'Create_CostUpdateXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );


END Create_CostUpdateXLAEvent;
--------------------------------------------------------------------------------------
--      API name        : Create_WIPUpdateXLAEvent
--      Type            : Private
--      Function        : To create WIP Cost Update accounting events in bulk
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_update_id         IN NUMBER
--                              p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a WIP Cost Update ID and organization_id
--                        and creates all events associated with it.
--                        Called from cmlwcu.lpc
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE Create_WIPUpdateXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_update_id         IN          NUMBER,
            p_organization_id   IN          NUMBER ) IS

  l_api_name    CONSTANT VARCHAR2(30)   := 'Create_WIPUpdateXLAEvent';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000);
  l_stmt_num             NUMBER := 0;
  l_api_message          VARCHAR2(1000);


  l_ledger_id      NUMBER;
  l_operating_unit NUMBER;
  l_index          NUMBER;

  l_pjm_blueprint        PJM_ORG_PARAMETERS.PA_POSTING_FLAG%TYPE;

  /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

  SAVEPOINT Create_WIPUpdateXLAEvent;
  l_stmt_num := 0;

  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.begin' ,' Create_WIPUpdateXLAEvent <<');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 5;
  BEGIN
    SELECT NVL(PA_POSTING_FLAG, 'N')
    INTO   l_pjm_blueprint
    FROM   PJM_ORG_PARAMETERS
    WHERE  ORGANIZATION_ID = p_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pjm_blueprint := 'N';
  END;

 /* Modified to enable the call to the blue print hook
  IF ( l_pjm_blueprint = 'Y' ) THEN
    IF l_procLog THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_WIPUpdateXLAEvent >>');
    END IF;
    return;
  END IF;
*/
  -- Get Ledger
  l_stmt_num := 10;
  SELECT ledger_id,
         operating_unit
  INTO   l_ledger_id,
         l_operating_unit
  FROM   CST_ACCT_INFO_V
  WHERE  ORGANIZATION_ID = p_organization_id;

  l_stmt_num := 20;

  /* Purge Temp Table */
  DELETE XLA_EVENTS_INT_GT;

  INSERT INTO xla_events_int_gt
    (
      application_id,
      ledger_id,
      entity_code,
      source_id_int_1,
      source_id_int_2,
      source_id_int_3,
      transaction_number,
      event_class_code,
      event_type_code,
      event_date,
      event_status_code,
      security_id_int_1,
      security_id_int_2,
      transaction_date,
      reference_date_1
    )
    SELECT
      G_CST_APPLICATION_ID,
      l_ledger_id,
      'WIP_ACCOUNTING_EVENTS',
      TRANSACTION_ID, -- SOURCE_ID_INT_1
      -1,                       -- SOURCE_ID_INT_2 (WIP_RESOURCE_ID)
      -1,                       -- SOURCE_ID_INT_3 (WIP_BASIS_TYPE_ID)
      TRANSACTION_ID,
      'WIP_COST_UPD',
      'WIP_COST_UPD',
      TRANSACTION_DATE,
      XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
      organization_id,
      l_operating_unit,
  --BUG#7566005 synch event_date with accounting_date
    --  TRANSACTION_DATE,
    INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
    TRANSACTION_DATE,
    l_operating_unit),
      INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
        TRANSACTION_DATE,
        l_operating_unit)
    FROM
      WIP_TRANSACTIONS
    WHERE
          COST_UPDATE_ID   = p_update_id
      AND ORGANIZATION_ID  = p_organization_id
      AND DECODE(l_pjm_blueprint,'N',1,
           NVL(blueprint_sla_hook_wrap(Transaction_id, 'WT'),0)) = 1;


  l_stmt_num := 30;

  xla_events_pub_pkg.create_bulk_events(
    p_source_application_id => G_WIP_APPLICATION_ID,
    p_application_id        => G_CST_APPLICATION_ID,
    p_ledger_id             => l_ledger_id,
    p_entity_type_code      => 'WIP_ACCOUNTING_EVENTS');


  IF l_procLog THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module||'.end','Create_WIPUpdateXLAEvent >>');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Create_WIPUpdateXLAEvent;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get
      (  p_count => x_msg_count,
         p_data  => x_msg_data
       );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_WIPUpdateXLAEvent;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_WIPUpdateXLAEvent;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF l_unexpLog THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||':'||l_stmt_num
      ,'Create_WIPUpdateXLAEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg
        (  G_PKG_NAME,
           l_api_name || 'Statement -'||to_char(l_stmt_num)
        );
    END IF;
    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count,
         p_data   => x_msg_data
      );


END Create_WIPUpdateXLAEvent;







------------------------
-- CST Security Policy
------------------------
--------------------------------------------------------------------------------------
--      API name        : Standard_policy
--      Type            : Public
--      Function        : Standard policy
--      Pre-reqs        :
--      Parameters      :
--      IN              :
--      OUT             : predicate 1=1
--      Version :
--                        Initial version       1.0
--      Notes           : No security
--      History
--      27-DEC-2007    Herve Yu     Created
--------------------------------------------------------------------------------------
FUNCTION standard_policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   RETURN '1 = 1';
END standard_policy;


--------------------------------------------------------------------------------------
--      API name        : Mo_policy
--      Type            : Public
--      Function        : MOAC policy
--      Pre-reqs        :
--      Parameters      :
--      IN              :
--      OUT             : predicate
--      Version :
--                        Initial version       1.0
--      Notes           : Security OU access MOAC leverage
--      History
--      27-DEC-2007    Herve Yu     Created
--------------------------------------------------------------------------------------
FUNCTION MO_Policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS
  l_mo_policy   VARCHAR2(4000);
  l_log_module  VARCHAR2(240);
BEGIN
  debug('CST_XLA_PVT.MO_Policy+');

  l_mo_policy := mo_global.org_security
     ( obj_schema => null
      ,obj_name   => null
     );

  debug(SUBSTRB('l_mo_policy after calling  mo_global.org_security = ' || l_mo_policy,1,500));

  l_mo_policy := REGEXP_REPLACE(l_mo_policy, 'org_id', 'security_id_int_2',1,1);

  -- Security identifiers are not populated. In case of, manual journal entires
  -- or third party merge events.
  -- bug 4717192, add the if condition
  IF(l_mo_policy is not null) THEN
    l_mo_policy := l_mo_policy || ' OR security_id_int_2 IS NULL ';
  END IF;

  debug('   l_mo_policy after replace = ' || l_mo_policy);
  debug('CST_XLA_PVT.MO_Policy-');

  RETURN(l_mo_policy);
END MO_Policy;


--------------------------------------------------------------------------------------
--      API name        : INV_ORG_POLICY
--      Type            : Public
--      Function        : INV PRG policy
--      Pre-reqs        :
--      Parameters      :
--      IN              :
--      OUT             : predicate on INV ORG
--      Version :
--                        Initial version       1.0
--      Notes           : Security INV ORG context
--      History
--      27-DEC-2007    Herve Yu     Created
--------------------------------------------------------------------------------------
FUNCTION INV_ORG_Policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS
  l_mo_policy     VARCHAR2(4000);
  l_log_module    VARCHAR2(240);
  l_inv_org_id    VARCHAR2(30);
  CURSOR c IS
  SELECT SUBSTRB(p.argument_text,
               INSTRB(p.argument_text,',',1,32)+1,
			   INSTRB(p.argument_text,',',1,33)-INSTRB(p.argument_text,',',1,32)-1)
    FROM fnd_concurrent_requests c,
         fnd_concurrent_requests p
   WHERE c.request_id =   fnd_global.conc_request_id
     AND c.parent_request_id = p.request_id;
BEGIN
   debug('CST_XLA_PVT.INV_ORG_Policy+');

   OPEN c;
   FETCH c    INTO l_inv_org_id;

    debug(' Inventory found l_inv_org_id:'||l_inv_org_id);

    IF c%FOUND AND l_inv_org_id IS NOT NULL THEN
      l_inv_org_id := translate(l_inv_org_id,'ABCDEFGHIGKLMNOPQRSTUVWXYZ','UUUUUUUUUUUUUUUUUUUUUUUUUU');
      l_inv_org_id := translate(l_inv_org_id,'abcdefghijklmnopqrstuvwxyz','llllllllllllllllllllllllll');
      l_inv_org_id := translate(l_inv_org_id,';,?@$#%^&*()+_-!=:/\|[]{}<>','ccccccccccccccccccccccccccc');
      IF INSTRB(l_inv_org_id,'U') <> 0 OR
	     INSTRB(l_inv_org_id,'l') <> 0 OR
		 INSTRB(l_inv_org_id,'c') <> 0
      THEN
         debug('  Using C_DEFAULT_PREDICAT 1');
         l_mo_policy :=  C_DEFAULT_PREDICAT ;
      ELSE
         debug('  Setting security_id_int_1 for inv_org:'||l_inv_org_id);
         l_mo_policy := ' SECURITY_ID_INT_1 = '||l_inv_org_id|| ' OR SECURITY_ID_INT_1 IS NULL ';
      END IF;
   ELSE
      debug('  Using C_DEFAULT_PREDICAT 2');
      l_mo_policy :=  C_DEFAULT_PREDICAT ;
   END IF;
   CLOSE c;

   debug('  l_mo_policy for inv org = ' || l_mo_policy);
   debug('CST_XLA_PVT.INV_ORG_Policy-');

   RETURN(l_mo_policy);
END INV_ORG_Policy;



/*
--No releasing it for now as the MFG_ORGANIZATION_ID IS ALWAYS SET BASED ON MY TESTING
--If User wants this one will revisite
FUNCTION INV_OR_MO_POLICY
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS
  l_mo_policy   VARCHAR2(4000);
  l_log_module  VARCHAR2(240);
  l_return      VARCHAR2(4000);
BEGIN
   debug('CST_XLA_PVT.INV_OR_MO_MO_POLICY+');

   debug(' Calling INV_ORG_Policy');
   l_mo_policy:= INV_ORG_Policy
       (p_obj_schema
       ,p_obj_name  );
   debug(' l_mo_policy after calling INV_ORG_Policy:'||l_mo_policy);

   IF  l_mo_policy = C_DEFAULT_PREDICAT THEN

     debug(' calling MO_Policy');
     l_mo_policy :=  MO_Policy(p_obj_schema
                              ,p_obj_name  );
     debug(' l_mo_policy after calling INV_Policy:'||l_mo_policy);

   END IF;

   debug('  l_mo_policy final:'||l_mo_policy);
   debug('CST_XLA_PVT.INV_OR_MO_Policy-');

   RETURN(l_mo_policy);
END INV_OR_MO_Policy;
*/


END CST_XLA_PVT;

/

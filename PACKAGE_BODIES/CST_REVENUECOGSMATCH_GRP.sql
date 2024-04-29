--------------------------------------------------------
--  DDL for Package Body CST_REVENUECOGSMATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_REVENUECOGSMATCH_GRP" AS
/* $Header: CSTRCMGB.pls 120.3.12010000.2 2008/08/08 12:32:44 smsasidh ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_RevenueCogsMatch_GRP';
G_DEBUG CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'cst.plsql.'||G_PKG_NAME;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Receive_CloseLineEvent  The Order Management module will call this     --
--                          procedure during line closure when they need   --
--                          to notify Costing of a revenue line ID that    --
--                          will not be invoiced in AR.  By calling this   --
--                          procedure they are essentially telling Costing --
--                          that revenue is recognized at 100% for this    --
--                          order line.                                    --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- STANDARD PARAMETERS                                                     --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- API SPECIFIC PARAMETERS                                                 --
--  P_REVENUE_EVENT_LINE_ID  Order Line ID for which COGS will be matched  --
--                           against, but for which there was no invoicing --
--  P_EVENT_DATE             Date that the order line is closed            --
--  P_OU_ID                  Operating Unit ID                             --
--  P_INVENTORY_ITEM_ID      Inventory Item ID                             --
--                                                                         --
-- HISTORY:                                                                --
--    04/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Receive_CloseLineEvent(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_revenue_event_line_id IN          NUMBER,
                p_event_date            IN          DATE,
                p_ou_id                 IN          NUMBER,
                p_inventory_item_id     IN          NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Receive_CloseLineEvent';
   l_api_version         CONSTANT NUMBER    := 1.0;
   l_api_message         VARCHAR2(1000);

   l_stmt_num            NUMBER         := 0;
   l_ledger_id           NUMBER;

   l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_RevenueCogsMatch_GRP.Receive_CloseLineEvent';
   l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
   l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
   l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
   l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
   l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
BEGIN
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CST_RevenueCogsMatch_GRP.Receive_CloseLineEvent with '||
        'p_api_version = '||p_api_version||','||
        'p_revenue_event_line_id = '||p_revenue_event_line_id||','||
        'p_event_date = '||p_event_date||','||
        'p_ou_id = '||p_ou_id||','||
        'p_inventory_item_id = '||p_inventory_item_id
      );
    END IF;

-- Standard start of API savepoint
   SAVEPOINT Receive_CloseLineEvent_GRP;

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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   -- All of the parameters passed in are NOT NULL columns in the CRRL table.
   -- If any of them were missing, it would fail validation automatically.
   -- But these are all required parameters anyway so it cannot happen.
   -- Other than that I won't do any validation on the values that are passed
   -- in to this procedure.

   l_stmt_num := 10;
   l_ledger_id := OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID', p_ou_id); -- defined in OESYSPAB.pls and OEXVSPMB.pls

   l_stmt_num := 20;
   INSERT INTO cst_revenue_recognition_lines (
                REVENUE_OM_LINE_ID,
                ACCT_PERIOD_NUM,
                POTENTIALLY_UNMATCHED_FLAG,
                REVENUE_RECOGNITION_PERCENT,
                LAST_EVENT_DATE,
                INVENTORY_ITEM_ID,
                OPERATING_UNIT_ID,
                LEDGER_ID,
                -- WHO COLUMNS
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE
               )
   SELECT p_revenue_event_line_id,
          gps.effective_period_num,
          'U', -- when OM inserts, put a value of 'U'.  This will get changed to 'Y' at the beginning of the concurrent request.  New rows coming in won't interfere.
          1,
          trunc(p_event_date),
          p_inventory_item_id,
          p_ou_id,
          l_ledger_id,
          -- WHO COLUMNS
          sysdate,
          FND_GLOBAL.user_id,
          sysdate,
          FND_GLOBAL.user_id,
          FND_GLOBAL.login_id,
          FND_GLOBAL.conc_request_id,
          FND_GLOBAL.PROG_APPL_ID,
          FND_GLOBAL.CONC_PROGRAM_ID,
          sysdate
   FROM gl_period_statuses gps
   WHERE gps.application_id = 101 -- used GL instead of OM or AR in case they are not using GPS
         --BUG#7211401: Truncation of the event date for last date of the period
   AND   TRUNC(p_event_date) BETWEEN gps.start_date AND gps.end_date
   AND   gps.set_of_books_id = l_ledger_id;

-- End API Body

-- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;


   FND_MSG_PUB.count_and_get
     (  p_count  => x_msg_count
      , p_data   => x_msg_data
      , p_encoded => FND_API.g_false
     );

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CST_RevenueCogsMatch_GRP.Receive_CloseLineEvent with '||
        'x_return_status = '||x_return_status||','||
        'x_msg_count = '||x_msg_count||','||
        'x_msg_data = '||x_msg_data
      );
    END IF;

EXCEPTION
    WHEN dup_val_on_index THEN
       IF l_eventLog THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num,
                         'Row already exists in cst_revenue_recognition_lines.');
       END IF;

       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
                fnd_msg_pub.add_exc_msg(
                   p_pkg_name => 'CST_RevenueCogsMatch_GRP',
                   p_procedure_name => 'Receive_CloseLineEvent',
                   p_error_text => 'Row already exists in cst_revenue_recognition_lines.'
                );
       END IF;

       FND_MSG_PUB.count_and_get
           (  p_count  => x_msg_count
             , p_data   => x_msg_data
             , p_encoded => FND_API.g_false
            );

    WHEN OTHERS THEN

          ROLLBACK TO Receive_CloseLineEvent_GRP;
          x_return_status := fnd_api.g_ret_sts_unexp_error ;

          IF fnd_log.level_unexpected >= fnd_log.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,'Receive_CloseLineEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
          END IF;

          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
                fnd_msg_pub.add_exc_msg(
                   p_pkg_name => 'CST_RevenueCogsMatch_GRP',
                   p_procedure_name => 'Receive_CloseLineEvent',
                   p_error_text => 'An exception has occurred in statement '||to_char(l_stmt_num)||': '||substr(SQLERRM,1,200)
                );
          END IF;

          FND_MSG_PUB.count_and_get
           (  p_count  => x_msg_count
             , p_data   => x_msg_data
             , p_encoded => FND_API.g_false
            );

END Receive_CloseLineEvent;



-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Return_PeriodStatuses   Oracle Receivables will call this procedure    --
--                          whenever they attempt to reopen one of their   --
--                          accounting periods for a given set of books.   --
--                          This procedure will check the Costing period   --
--                          for all of the organizations that belong to    --
--                          that set of books.  If any are closed, it will --
--                          indicate this upon return.                     --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- STANDARD PARAMETERS                                                     --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- API SPECIFIC PARAMETERS                                                 --
--  P_SET_OF_BOOKS_ID         Set of Books Unique Identifier               --
--  P_EFFECTIVE_PERIOD_NUM    Period Year * 10000 + Period Num             --
--  X_CLOSED_CST_PERIODS      'Y' if any of the organizations in the set   --
--                            of books passed in have a closed period,     --
--                            'N' otherwise                                --
--                                                                         --
-- HISTORY:                                                                --
--    05/09/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Return_PeriodStatuses(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_set_of_books_id       IN          NUMBER,
                p_effective_period_num  IN          NUMBER,
                x_closed_cst_periods    OUT NOCOPY  VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Return_PeriodStatuses';
   l_api_version         CONSTANT NUMBER    := 1.0;
   l_api_message         VARCHAR2(1000);

   l_stmt_num            NUMBER         := 0;
   l_closed_cst_periods  NUMBER;

   l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_RevenueCogsMatch_GRP.Return_PeriodStatuses';
   l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
   l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
   l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
   l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
   l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CST_RevenueCogsMatch_GRP.Return_PeriodStatuses with '||
        'p_api_version = '||p_api_version||','||
        'p_set_of_books_id = '||p_set_of_books_id||','||
        'p_effective_period_num = '||p_effective_period_num
      );
    END IF;

-- Standard start of API savepoint
   SAVEPOINT Return_PeriodStatuses_GRP;

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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   l_stmt_num := 10;
   SELECT count(*)
   INTO l_closed_cst_periods
   FROM org_acct_periods oap,
        gl_period_statuses gps,
        hr_organization_information hoi
   WHERE oap.organization_id = hoi.organization_id
   AND oap.period_name = gps.period_name
   AND oap.open_flag = 'N'
   AND gps.application_id = 222
   AND gps.effective_period_num = p_effective_period_num
   AND gps.set_of_books_id = p_set_of_books_id
   AND hoi.org_information1 = to_char(p_set_of_books_id)
   AND hoi.org_information_context = 'Accounting Information';

   IF (l_closed_cst_periods > 0) THEN
      x_closed_cst_periods := 'Y';
   ELSE
      x_closed_cst_periods := 'N';
   END IF;


-- End API Body

-- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;


   FND_MSG_PUB.count_and_get
     (  p_count  => x_msg_count
      , p_data   => x_msg_data
     );

   IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CST_RevenueCogsMatch_GRP.Return_PeriodStatuses with '||
        'x_return_status = '||x_return_status||','||
        'x_msg_count = '||x_msg_count||','||
        'x_msg_data = '||x_msg_data||','||
        'x_closed_cst_periods = '||x_closed_cst_periods
      );
   END IF;

EXCEPTION
    WHEN OTHERS THEN

          ROLLBACK TO Return_PeriodStatuses_GRP;
          x_return_status := fnd_api.g_ret_sts_unexp_error ;

          IF fnd_log.level_unexpected >= fnd_log.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,'Return_PeriodStatuses '||l_stmt_num||' : '||substr(SQLERRM,1,200));
          END IF;

          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) -- *** check this w/ API standards!
          THEN
                FND_MSG_PUB.add_exc_msg
                  (  G_PKG_NAME,
                     l_api_name || '  Statement - '||to_char(l_stmt_num)
                  );
          END IF;

          FND_MSG_PUB.count_and_get
           (  p_count  => x_msg_count
             , p_data   => x_msg_data
            );

END Return_PeriodStatuses;


END CST_RevenueCogsMatch_GRP;

/

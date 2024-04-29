--------------------------------------------------------
--  DDL for Package Body CST_REVENUECOGSMATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_REVENUECOGSMATCH_PVT" AS
/* $Header: CSTRCMVB.pls 120.45.12010000.17 2010/04/30 15:39:19 vkatakam ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'CST_RevenueCogsMatch_PVT';
G_DEBUG        CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD     CONSTANT VARCHAR2(40) := 'cst.plsql.'||G_PKG_NAME;
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_module_name  VARCHAR2(255) := G_LOG_HEAD;

--BUG#7463298
g_ledger_id    NUMBER := -1;

--------------------------------------------------------------------------------------
-- Local routines section : BEGIN
--------------------------------------------------------------------------------------
-- 1 set g_module_name
-- 2 call debug only with line
PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT g_module_name,
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT);

-- Ensure the MMT transaction_date and the acct_period_id match
PROCEDURE ensure_mmt_per_and_date
(x_return_status   OUT NOCOPY     VARCHAR2,
 x_msg_count       OUT NOCOPY     NUMBER,
 x_msg_data        OUT NOCOPY     VARCHAR2);

--{BUG#7387575
PROCEDURE crrl_preparation
(p_batch_size   IN NUMBER  DEFAULT 1000
,p_ledger_id    IN NUMBER  DEFAULT NULL);

PROCEDURE nb_req_active;

PROCEDURE updation_potential_crrl
(p_batch_size   IN NUMBER  DEFAULT 1000
,p_ledger_id    IN NUMBER);
--}

--
-- PROCEDURE check_program_running
--   p_prg_name    IN VARCHAR2     program short name
--   p_app_id      IN NUMBER       program app id
--   p_ledger_id   IN VARCHAR2     ledger parameter
--   x_running OUT NOCOPY  VARCHAR2
--            Y if the program is running
--            N if the program is not running
--   x_status  OUT NOCOPY  VARCHAR2
--            S if no exception found
--            E no program exist exception
--            U other exception
--
PROCEDURE check_program_running
(   p_prg_name    IN          VARCHAR2
,   p_app_id      IN          NUMBER
,   p_ledger_id   IN          NUMBER
,   x_running     OUT NOCOPY  VARCHAR2
,   x_status      OUT NOCOPY  VARCHAR2
,   x_out_msg     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Match_RevenueCOGS This API is the outer wrapper for the concurrent     --
--                    request that matches COGS to revenue for OM lines.   --
--                    It is run in four phases, each followed by a         --
--                    commit:                                              --
--                    1) Record any sales order issues and RMA receipts    --
--                       that have not yet been inserted into CRCML and    --
--                       CCE.                                              --
--                    2) Process incoming revenue events and insert        --
--                       revenue recognition per period by OM line into    --
--                       CRRL.                                             --
--                    3) Compare CRRL to CCE (via CRCML) and create new    --
--                       COGS recognition events where they don't match.   --
--                    4) Cost all of the Cogs Recogntion Events that were  --
--                       just created in bulk.                             --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--                                                                         --
--  P_LOW_DATE         Lower bound for the date range.                     --
--  P_HIGH_DATE        Upper bound for the date range.                     --
--  P_PHASE            Set to a number, this parameter indicates that only --
--                     that phase # should be run.  Otherwise all phases   --
--                     should be run.                                      --
--                                                                         --
-- HISTORY:                                                                --
--    04/20/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Match_RevenueCOGS(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_dummy_out             OUT NOCOPY  NUMBER,
                p_api_version           IN          NUMBER,
                p_phase                 IN          NUMBER,
                p_ledger_id             IN          NUMBER DEFAULT NULL,--BUG#5726230
                p_low_date              IN          VARCHAR2,
                p_high_date             IN          VARCHAR2,
                p_neg_req_id            IN          NUMBER DEFAULT NULL--HYU
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Match_RevenueCOGS';
   l_api_version         CONSTANT NUMBER        := 1.0;
   l_api_message         VARCHAR2(1000);

   l_return_status       VARCHAR2(1)        := FND_API.G_RET_STS_SUCCESS;
   l_dummy_status        VARCHAR2(1);  /* not sure why AR needs this, hopefully can remove it ... */
   l_msg_count           NUMBER             := 0;
   l_msg_data            VARCHAR2(8000)     := '';
   l_stmt_num            NUMBER             := 0;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   program_exception     EXCEPTION;
   CONC_STATUS           BOOLEAN;            -- variable for concurrent request completion status

   l_request_id          NUMBER;             -- FND global settings
   l_user_id             NUMBER;
   l_login_id            NUMBER;
   l_pgm_app_id          NUMBER;
   l_pgm_id              NUMBER;

   l_schema VARCHAR2(30);                    -- variables for fnd_stats
   l_status VARCHAR2(1);
   l_industry VARCHAR2(1);

   l_low_date            DATE;
   l_high_date           DATE;
   l_prg_name            VARCHAR2(30);
   x_running             VARCHAR2(1);
   x_out_msg             VARCHAR2(2000);
   l_control_id          NUMBER;
   already_running       EXCEPTION;

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Match_RevenueCOGS_PVT;

   l_stmt_num := 0;

   debug('Match_RevenueCOGS+');
   debug('  p_api_version:'||p_api_version);
   debug('  p_phase     : '|| p_phase);
   debug('  p_low_date  : '|| p_low_date);
   debug('  p_high_date : '|| p_high_date);
   debug('  p_ledger_id : '|| p_ledger_id);
   debug('  p_neg_req_id: '|| p_neg_req_id);


/*   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'p_low_date = '||p_low_date||','||
        'p_high_date = '||p_high_date||','||
        'p_phase = '||p_phase);
   END IF;
*/
-- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
   FND_MSG_PUB.initialize;

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API Body

   -- Populate WHO column variables
   l_request_id := FND_GLOBAL.conc_request_id;
   l_user_id    := FND_GLOBAL.user_id;
   l_login_id   := FND_GLOBAL.login_id;
   l_pgm_app_id := FND_GLOBAL.PROG_APPL_ID;
   l_pgm_id     := FND_GLOBAL.CONC_PROGRAM_ID;


   -- Avoid multiple submission
   IF     p_phase = 1 THEN l_prg_name := 'CSTRCMCR1';
   ELSIF  p_phase = 2 THEN l_prg_name := 'CSTRCMCR';
   ELSIF  p_phase = 3 THEN l_prg_name := 'CSTRCMCR3';
   END IF;

   debug(' Program submitted :'||l_prg_name);

   check_program_running(   p_prg_name    => l_prg_name
                        ,   p_app_id      => 702
                        ,   p_ledger_id   => p_ledger_id
                        ,   x_running     => x_running
                        ,   x_status      => x_return_status
                        ,   x_out_msg     => x_out_msg);

   debug(' x_running :' ||x_running);

   IF x_return_status <> 'S' THEN
     RAISE program_exception;
   END IF;

   IF x_running = 'Y' THEN
     RAISE already_running;
   END IF;




  /********************************************************************************
   * Phase 1 - Record any sales order issues and RMA receipts that have not yet   *
   *           been inserted into the Revenue/COGS matching data model (CRCML and *
   *           CCE).                                                              *
   ********************************************************************************/

   IF ( p_phase = 1 ) THEN

      --{BUG#7463298
      IF p_ledger_id IS NOT NULL THEN
        g_ledger_id := p_ledger_id;
      END IF;
      debug(' g_ledger_id : ' ||g_ledger_id);
      --}

      l_stmt_num := 10;
      debug(l_stmt_num);

      Insert_SoIssues(p_request_id    => l_request_id,
                      p_user_id       => l_user_id,
                      p_login_id      => l_login_id,
                      p_pgm_app_id    => l_pgm_app_id,
                      p_pgm_id        => l_pgm_id,
                      x_return_status => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,substr(SQLERRM,1,250));
         END IF;
         raise program_exception;
      END IF;

      l_stmt_num := 20;
      debug(l_stmt_num);
      insert_RmaReceipts(p_request_id    => l_request_id,
                         p_user_id       => l_user_id,
                         p_login_id      => l_login_id,
                         p_pgm_app_id    => l_pgm_app_id,
                         p_pgm_id        => l_pgm_id,
                         x_return_status => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,substr(SQLERRM,1,250));
         END IF;
         raise program_exception;
      END IF;

      IF l_eventLog THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT,l_module||'.20'
                 ,'Completed phase 1 successfully.');
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
         FND_MESSAGE.set_name('BOM', 'CST_SUCCESSFUL_PHASE');
         FND_MESSAGE.set_token('PHASE', '1');
         FND_MSG_PUB.ADD;
      END IF;

      Print_MessageStack;

      -- Commit phase 1 insertions
      COMMIT;
      SAVEPOINT Match_RevenueCOGS_PVT;

   END IF;  -- phase 1

  /********************************************************************************
   * Phase 2 - Process incoming revenue events and insert revenue recognition per *
   *           period by OM line into CRRL                                        *
   ********************************************************************************/

   IF ( p_phase = 2 ) THEN

      -- convert input parameters to dates
      l_low_date := fnd_date.canonical_to_date(p_low_date);
      l_high_date := trunc(fnd_date.canonical_to_date(p_high_date))+0.99999;
      IF (l_low_date IS NULL) THEN
         l_low_date := sysdate - (365*20); -- go back 20 years
      END IF;
      -- prevent the collection of future revenue recognition events
      IF (l_high_date IS NULL OR l_high_date > sysdate) THEN
         l_high_date := sysdate;
      END IF;

      -- Call AR's procedure to populate CRRL with revenue recognition event data
      -- by OM line and accounting period.
      l_stmt_num := 30;

      IF l_stmtLog THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module||'.'||l_stmt_num,
        'Calling AR_MATCH_REV_COGS_GRP.populate_cst_tables with '||
        'p_from_gl_date = '||l_low_date||','||
        'p_to_gl_date = '||l_high_date||',');
      END IF;

      ar_match_rev_cogs_grp.populate_cst_tables (
               p_api_version   => 1,
               p_from_gl_date  => l_low_date,
               p_to_gl_date    => l_high_date,
               --{BUG#7533570 add ledger_id
               p_ledger_id     => p_ledger_id,
               --}
               x_status        => l_dummy_status,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data
               );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,substr(SQLERRM,1,250));
         END IF;
         raise program_exception;
      END IF;

      IF l_eventLog THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,l_module||'.20'
                ,'Completed phase 2 successfully.');
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
         FND_MESSAGE.set_name('BOM', 'CST_SUCCESSFUL_PHASE');
         FND_MESSAGE.set_token('PHASE', '2');
         FND_MSG_PUB.ADD;
      END IF;

      Print_MessageStack;

     --
     -- -1 for all ledgers, this is unexpected as ledger is mandatory
     -- nevertheless, we support the -1 concept for customer to make the ledger_id not madatory
     -- otherwise control_id will be ledger_id
     --
     IF p_ledger_id IS NULL THEN
       l_control_id := -1;
     ELSE
       l_control_id := p_ledger_id;
     END IF;

      -- Update the "Process Upto Date" in the revenue / COGS control table
      UPDATE cst_revenue_cogs_control
      SET last_process_upto_date = l_high_date,
          last_update_date       = sysdate,
          last_updated_by        = l_user_id,
          last_update_login      = l_login_id,
          request_id             = l_request_id
      WHERE control_id           = l_control_id;


     IF (SQL%ROWCOUNT = 0) THEN
         INSERT INTO cst_revenue_cogs_control (
                       CONTROL_ID,
                       LAST_PROCESS_UPTO_DATE,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       REQUEST_ID,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE)
         VALUES ( l_control_id,
                  l_high_date,
                  sysdate,
                  l_user_id,
                  sysdate,
                  l_user_id,
                  l_login_id,
                  l_request_id,
                  l_pgm_app_id,
                  l_pgm_id,
                  sysdate);
      END IF;

      -- Commit phase 2 inserts and updates
      COMMIT;
      SAVEPOINT Match_RevenueCOGS_PVT;

      -- Now we should gather statistics on CRRL since the above call to
      -- ar_match_rev_cogs_grp.populate_cst_tables would have added a bunch of rows
      -- with potentially_unmatched_flag = 'Y'.  This column is a histogram, so we
      -- need to gather stats before running phase 3, which relies heavily on this
      -- column.
      IF NOT FND_INSTALLATION.GET_APP_INFO('BOM', l_status, l_industry, l_schema) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_schema IS NOT NULL THEN
         l_stmt_num := 37;
         FND_STATS.GATHER_TABLE_STATS(l_schema, 'CST_REVENUE_RECOGNITION_LINES');
      END IF;
      SAVEPOINT Match_RevenueCOGS_PVT; -- necessary because of commit within gather_table_stats

   END IF; -- phase 2


   IF ( p_phase = 3 ) THEN

     /********************************************************************************
      * Phase 3 - Compare CRRL to CCE (via CRCML) and create new COGS recognition    *
      *           events where they don't match.                                     *
      ********************************************************************************/

      -- Update all rows from OM so that any OLTP rows coming in during the
      -- concurrent request will not get picked up in this run.
      l_stmt_num := 40;
      UPDATE cst_revenue_recognition_lines crrl
         SET potentially_unmatched_flag = 'Y'
       WHERE potentially_unmatched_flag = 'U';

      l_stmt_num := 50;
      Create_CogsRecognitionEvents(p_request_id    => l_request_id,
                                   p_user_id       => l_user_id,
                                   p_login_id      => l_login_id,
                                   p_pgm_app_id    => l_pgm_app_id,
                                   p_pgm_id        => l_pgm_id,
                                   x_return_status => l_return_status,
                                   p_ledger_id     => p_ledger_id    -- BUG#5726230
                                  ,p_neg_req_id    => p_neg_req_id); -- BUG#7387575

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,substr(SQLERRM,1,250));
         END IF;
         raise program_exception;
      END IF;

      -- Any rows marked as potentially mismatched would have been picked up for
      -- comparison this time.  For such rows to be mismatched at this point would
      -- require a new initiating event.  That event will reset the flag to 'Y' at
      -- that time, so fow now we set it to NULL indicating it is matched.
      l_stmt_num := 60;

      /*
      IF p_neg_req_id IS NULL THEN

        UPDATE cst_revenue_recognition_lines crrl
        SET potentially_unmatched_flag = NULL,
            last_update_date           = sysdate,
            last_updated_by            = l_user_id,
            last_update_login          = l_login_id,
            request_id                 = l_request_id,
            program_application_id     = l_pgm_app_id,
            program_id                 = l_pgm_id,
            program_update_date        = sysdate
        WHERE potentially_unmatched_flag = 'Y'
        AND ledger_id                  = NVL(p_ledger_id,ledger_id);  --BUG5726230

      ELSE

        UPDATE cst_revenue_recognition_lines crrl
        SET potentially_unmatched_flag = NULL,
            last_update_date           = sysdate,
            last_updated_by            = l_user_id,
            last_update_login          = l_login_id,
            request_id                 = l_request_id,
            program_application_id     = l_pgm_app_id,
            program_id                 = l_pgm_id,
            program_update_date        = sysdate
        WHERE potentially_unmatched_flag = 'Y'
        AND ledger_id                  = NVL(p_ledger_id,ledger_id)  --BUG5726230
        AND request_id                 = p_neg_req_id;               --BUG7387575

      END IF;
      */

      IF l_eventLog THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,l_module||'.20'
                ,'Completed phase 3 successfully.');
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
         FND_MESSAGE.set_name('BOM', 'CST_SUCCESSFUL_PHASE');
         FND_MESSAGE.set_token('PHASE', '3');
         FND_MSG_PUB.ADD;
      END IF;

      Print_MessageStack;

      -- Commit phase 3 work
      COMMIT;
      SAVEPOINT Match_RevenueCOGS_PVT;

     /********************************************************************************
      * Phase 4 - Cost all of the Cogs Recogntion Events that were just created in   *
      *           bulk.  The cost manager would never be able to handle this.        *
      ********************************************************************************/

      l_stmt_num := 70;
      Cost_BulkCogsRecTxns(p_request_id    => l_request_id,
                           p_user_id       => l_user_id,
                           p_login_id      => l_login_id,
                           p_pgm_app_id    => l_pgm_app_id,
                           p_pgm_id        => l_pgm_id,
                           x_return_status => l_return_status,
                           p_ledger_id     => p_ledger_id   --BUG5726230
                           ,p_neg_req_id   => p_neg_req_id);--BUG7387575

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,substr(SQLERRM,1,250));
         END IF;
         raise program_exception;
      END IF;

      IF l_eventLog THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,l_module||'.20'
                ,'Completed phase 4 successfully.');
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
         FND_MESSAGE.set_name('BOM', 'CST_SUCCESSFUL_PHASE');
         FND_MESSAGE.set_token('PHASE', '4');
         FND_MSG_PUB.ADD;
      END IF;

      -- Print the message stack to the log file
      Print_MessageStack;

      -- Commit phase 4 work
      COMMIT;

   END IF;  -- phases 3 and 4

-- End API Body
/*
   IF l_proclog THEN
      fnd_log.string(fnd_log.level_procedure,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status||
        'x_dummy_out = '||x_dummy_out
      );
   END IF;
 */
   debug('  x_return_status : '||x_return_status);
   debug('  x_dummy_out     : '||x_dummy_out );
   debug('Match_RevenueCOGS-');

EXCEPTION
   WHEN already_running THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, x_out_msg);

   WHEN program_exception THEN
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.set_name('BOM', 'CST_PLSQL_ERROR');
      FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
      FND_MESSAGE.set_token('PROCEDURE',l_api_name);
      FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         FND_MSG_PUB.ADD;
      END IF;

      IF l_errorLog THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,TRUE);
      END IF;

      CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_module||' failed to complete.');

      DECLARE
         l_cnt   NUMBER;
         l_data  VARCHAR2(2000);
      BEGIN
          fnd_msg_pub.Count_And_Get
           (p_encoded => 'T',
            p_count	  => l_cnt,
            p_data	  => l_data);
          FND_FILE.put_line
           (fnd_file.log,
            'PROGRAM_EXCEPTION IN Match_RevenueCOGS at ('||l_stmt_num||'): '||
             SUBSTRB(l_data,1,400) );
      END;

      Print_MessageStack;

   WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,substrb(SQLERRM,1,250));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Match_RevenueCOGS:'||substrb(SQLERRM,1,250) );

         CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_module||' failed to complete.');

         Print_MessageStack;

END Match_RevenueCOGS;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_SoIssues   This procedure handles the insertion of sales order  --
--                    issue transactions in batch into the matching data   --
--                    model.  Most sales orders will be inserted into the  --
--                    matching data model by the Cost Processor. Any that  --
--                    are not processed at that time (e.g. - OPM orgs)     --
--                    will be inserted here.                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    04/22/05     Bryan Kuntz      Created using cursor                   --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_SoIssues(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Insert_SoIssues';
   l_api_message         VARCHAR2(100);
   l_stmt_num            NUMBER         := 0;
   l_return_status       VARCHAR2(1)        := FND_API.G_RET_STS_SUCCESS;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   CURSOR c_sales_order_issues IS
      SELECT mmt.trx_source_line_id cogs_om_line_id,
             mmt.distribution_account_id cogs_acct_id,
             mp.deferred_cogs_account def_cogs_acct_id,
             mmt.transaction_id mmt_txn_id,
             mmt.organization_id,
             mmt.inventory_item_id,
             mmt.transaction_date,
             mmt.cost_group_id,
             (-1*mmt.primary_quantity) quantity
      FROM mtl_material_transactions mmt,
           mtl_parameters            mp,
           mtl_secondary_inventories msi,
           mtl_system_items_b        item
          ,cst_acct_info_v           caiv  --BUG#7463298
      WHERE mmt.transaction_action_id in (1,7)
      /* do not pick up physical SO issue in a drop shipment flow */
      AND NVL(mmt.parent_transaction_id, -1) = DECODE(mmt.transaction_action_id,1,-1,mmt.parent_transaction_id)
      AND mmt.transaction_type_id            IN (33, 30)
      AND mmt.transaction_source_type_id     = 2
      AND mmt.costed_flag     = 'N'
      AND mmt.COGS_RECOGNITION_PERCENT       IS NULL
      AND mmt.SO_ISSUE_ACCOUNT_TYPE          = 2 /* deferred COGS */
      AND mp.organization_id                 = mmt.organization_id
      --{BUG#7463298
      AND mp.organization_id                 = caiv.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'N'        /*BUG#9306124 - Ristricted this qry for Discrete orgs*/
      AND DECODE(g_ledger_id,-1
                ,caiv.ledger_id,g_ledger_id) = caiv.ledger_id
      --}
      AND mmt.subinventory_code              = msi.secondary_inventory_name (+) /* Logical txn  does not have sub code */
      AND mmt.organization_id                = msi.organization_id (+)
      AND NVL(msi.asset_inventory,1)         = 1
      AND item.inventory_item_id             = mmt.inventory_item_id
      AND item.organization_id               = mmt.organization_id
      AND item.inventory_asset_flag          = 'Y'
      /* BUG#9306124 - Seperated query for Process orgs with this union(Start)*/
      UNION ALL
      SELECT mmt.trx_source_line_id cogs_om_line_id,
             mmt.distribution_account_id cogs_acct_id,
             mp.deferred_cogs_account def_cogs_acct_id,
             mmt.transaction_id mmt_txn_id,
             mmt.organization_id,
             mmt.inventory_item_id,
             mmt.transaction_date,
             mmt.cost_group_id,
             (-1*mmt.primary_quantity) quantity
      FROM mtl_material_transactions mmt,
           mtl_parameters            mp,
           mtl_secondary_inventories msi,
           mtl_system_items_b        item
          ,cst_acct_info_v           caiv  --BUG#7463298
      WHERE mmt.transaction_action_id in (1,7)
      /* do not pick up physical SO issue in a drop shipment flow */
      AND NVL(mmt.parent_transaction_id, -1) = DECODE(mmt.transaction_action_id,1,-1,mmt.parent_transaction_id)
      AND mmt.transaction_type_id            IN (33, 30)
      AND mmt.transaction_source_type_id     = 2
      AND mmt.opm_costed_flag IS NOT NULL
      AND mmt.COGS_RECOGNITION_PERCENT       IS NULL
      AND mmt.SO_ISSUE_ACCOUNT_TYPE          = 2 /* deferred COGS */
      AND mp.organization_id                 = mmt.organization_id
      --{BUG#7463298
      AND mp.organization_id                 = caiv.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'Y'        /*BUG#9306124 - Process org */
      AND DECODE(g_ledger_id,-1
                ,caiv.ledger_id,g_ledger_id) = caiv.ledger_id
      --}
      AND mmt.subinventory_code              = msi.secondary_inventory_name (+) /* Logical txn  does not have sub code */
      AND mmt.organization_id                = msi.organization_id (+)
      AND NVL(msi.asset_inventory,1)         = 1
      AND item.inventory_item_id             = mmt.inventory_item_id
      AND item.organization_id               = mmt.organization_id
      AND item.inventory_asset_flag          = 'Y'
      /* BUG#9306124 - Seperated query for Process orgs with this union (End)*/
      ;

   l_so_count               pls_integer := 0;

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Insert_SoIssues_PVT;

   l_stmt_num := 0;

   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name
     );
   END IF;

-- Initialize return values
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API Body

   debug('  g_ledger_id : '||g_ledger_id);

   -- Loop through all sales order issues that have not yet been inserted into the Deferred COGS data model.
   -- Most of them would have been inserted by the cost processor during the course of normal processing.
   l_stmt_num := 10;
   <<all_sales_orders_loop>>
   FOR cv_so_issues IN c_sales_order_issues LOOP

      Insert_OneSoIssue(
                p_api_version      => 1.0,
                p_user_id          => p_user_id,
                p_login_id         => p_login_id,
                p_request_id       => p_request_id,
                p_pgm_app_id       => p_pgm_app_id,
                p_pgm_id           => p_pgm_id,
                x_return_status    => l_return_status,
                p_cogs_om_line_id  => cv_so_issues.cogs_om_line_id,
                p_cogs_acct_id     => cv_so_issues.cogs_acct_id,
                p_def_cogs_acct_id => cv_so_issues.def_cogs_acct_id,
                p_mmt_txn_id       => cv_so_issues.mmt_txn_id,
                p_organization_id  => cv_so_issues.organization_id,
                p_item_id          => cv_so_issues.inventory_item_id,
                p_transaction_date => cv_so_issues.transaction_date,
                p_cost_group_id    => cv_so_issues.cost_group_id,
                p_quantity         => cv_so_issues.quantity
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         FND_MESSAGE.set_name('BOM', 'CST_FAILED_DEFCOGS_SO_INSERT');
         FND_MESSAGE.set_token('COGS_OM_LINE', to_char(cv_so_issues.cogs_om_line_id));
         FND_MESSAGE.set_token('MMT_TXN_ID',to_char(cv_so_issues.mmt_txn_id));
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.ADD;
         END IF;
         IF l_errorLog THEN
            FND_LOG.message(FND_LOG.LEVEL_ERROR, l_module||'.10',TRUE);
         END IF;
      ELSE
         l_so_count := l_so_count + 1;
      END IF;

   END LOOP all_sales_orders_loop;

   IF l_eventLog THEN
      l_api_message :=  'Inserted '||to_char(l_so_count)||' sales order issues into CCE.';
      FND_LOG.string(FND_LOG.LEVEL_EVENT, G_LOG_HEAD ||'.'|| l_api_name || '.10', l_api_message);
   END IF;

-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

EXCEPTION

   WHEN OTHERS THEN
         ROLLBACK TO Insert_SoIssues_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Insert_SoIssues ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Insert_SoIssues:'||substrb(SQLERRM,1,250) );


END Insert_SoIssues;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_RmaReceipts  This procedure handles the insertion of RMA        --
--                      receipt transactions in batch into the matching    --
--                      data model.  Most RMA receipts will be inserted    --
--                      by the Cost Processor.  This bulk procedure will   --
--                      pick up the rest.                                  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    05/06/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_RmaReceipts(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Insert_RmaReceipts';
   l_api_message         VARCHAR2(1000);
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_stmt_num            NUMBER         := 0;

   CURSOR c_rma_receipts IS
      SELECT /* LEADING(mmt) */
             mmt.trx_source_line_id    rma_om_line_id,
             ool.reference_line_id     cogs_om_line_id,
             mmt.transaction_id        mmt_txn_id,
             mmt.transaction_date      transaction_date,
             (-1*mmt.primary_quantity) event_quantity,
             cce.parent_event_id       prior_event_id,
             cce.cogs_percentage       cogs_percentage,
             sum(cce.event_quantity)   prior_event_quantity
      FROM mtl_material_transactions    mmt,
           oe_order_lines_all           ool,
           cst_revenue_cogs_match_lines crcml,
           cst_cogs_events              cce,
           mtl_secondary_inventories    msi,
           mtl_system_items_b           item
          ,cst_acct_info_v              caiv  --BUG#7463298
          ,mtl_parameters               mp    --BUG#9306124
      WHERE mmt.transaction_source_type_id = 12
      AND mmt.transaction_action_id       in (26,27) -- UT: see if this forces index use, otherwise take it out since repeated below
      AND mmt.costed_flag    = 'N'
      AND mmt.cogs_recognition_percent    IS NULL
      AND mmt.trx_source_line_id          = ool.line_id -- this line and the next will cause this query to
      AND ool.reference_line_id           = crcml.cogs_om_line_id -- return rows only if crcml has a row for the orig SO
      AND ((mmt.transaction_action_id = 27
            AND mmt.subinventory_code = msi.SECONDARY_INVENTORY_NAME
            AND mmt.organization_id   = msi.organization_id
            AND msi.asset_inventory   = 1)   OR   mmt.transaction_action_id  = 26)
      AND item.inventory_item_id          = mmt.inventory_item_id
      AND item.organization_id            = mmt.organization_id
      AND item.inventory_asset_flag       = 'Y'
      --{BUG#7463298
      AND mp.organization_id                 = mmt.organization_id
      AND mp.organization_id                 = caiv.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'N'        /*BUG#9306124 - Ristricted this qry for Discrete orgs*/
      AND DECODE(g_ledger_id,-1
                ,caiv.ledger_id,g_ledger_id) = caiv.ledger_id
      --}
      AND crcml.cogs_om_line_id           = cce.cogs_om_line_id
      AND cce.event_date                 <= mmt.transaction_date
      AND NOT EXISTS (SELECT 'X'
                      FROM cst_cogs_events
                      WHERE event_date   <= mmt.transaction_date
                      AND cogs_om_line_id = crcml.cogs_om_line_id
                      AND prior_event_id  = cce.parent_event_id)
      GROUP BY cce.parent_event_id   , ool.reference_line_id,
               mmt.transaction_id    , cce.cogs_percentage,
               mmt.trx_source_line_id, mmt.organization_id,
               mmt.inventory_item_id , mmt.transaction_date,
               mmt.primary_quantity

      /* BUG#9306124 - Seperated query for Process orgs with this union (Start)*/
      UNION ALL
      SELECT /* LEADING(mmt) */
             mmt.trx_source_line_id    rma_om_line_id,
             ool.reference_line_id     cogs_om_line_id,
             mmt.transaction_id        mmt_txn_id,
             mmt.transaction_date      transaction_date,
             (-1*mmt.primary_quantity) event_quantity,
             cce.parent_event_id       prior_event_id,
             cce.cogs_percentage       cogs_percentage,
             sum(cce.event_quantity)   prior_event_quantity
      FROM mtl_material_transactions    mmt,
           oe_order_lines_all           ool,
           cst_revenue_cogs_match_lines crcml,
           cst_cogs_events              cce,
           mtl_secondary_inventories    msi,
           mtl_system_items_b           item
          ,cst_acct_info_v              caiv  --BUG#7463298
          ,mtl_parameters               mp    --BUG#9306124
      WHERE mmt.transaction_source_type_id = 12
      AND mmt.transaction_action_id       in (26,27) -- UT: see if this forces index use, otherwise take it out since repeated below
      AND mmt.opm_costed_flag IS NOT NULL
      AND mmt.cogs_recognition_percent    IS NULL
      AND mmt.trx_source_line_id          = ool.line_id -- this line and the next will cause this query to
      AND ool.reference_line_id           = crcml.cogs_om_line_id -- return rows only if crcml has a row for the orig SO
      AND ((mmt.transaction_action_id = 27
            AND mmt.subinventory_code = msi.SECONDARY_INVENTORY_NAME
            AND mmt.organization_id   = msi.organization_id
            AND msi.asset_inventory   = 1)   OR   mmt.transaction_action_id  = 26)
      AND item.inventory_item_id          = mmt.inventory_item_id
      AND item.organization_id            = mmt.organization_id
      AND item.inventory_asset_flag       = 'Y'
      --{BUG#7463298
      AND mp.organization_id                 = mmt.organization_id
      AND mp.organization_id                 = caiv.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'Y'        /*BUG#9306124 - Process org */
      AND DECODE(g_ledger_id,-1
                ,caiv.ledger_id,g_ledger_id) = caiv.ledger_id
      --}
      AND crcml.cogs_om_line_id           = cce.cogs_om_line_id
      AND cce.event_date                 <= mmt.transaction_date
      AND NOT EXISTS (SELECT 'X'
                      FROM cst_cogs_events
                      WHERE event_date   <= mmt.transaction_date
                      AND cogs_om_line_id = crcml.cogs_om_line_id
                      AND prior_event_id  = cce.parent_event_id)
      GROUP BY cce.parent_event_id   , ool.reference_line_id,
               mmt.transaction_id    , cce.cogs_percentage,
               mmt.trx_source_line_id, mmt.organization_id,
               mmt.inventory_item_id , mmt.transaction_date,
               mmt.primary_quantity
      /* BUG#9306124 - Seperated query for Process orgs with this union (End)*/
      ORDER BY cogs_om_line_id, transaction_date;

   l_rma_om_line_id_tbl      number_table;
   l_cogs_om_line_id_tbl     number_table;
   l_mmt_txn_id_tbl          number_table;
   l_txn_date_tbl            date_table;
   l_event_quantity_tbl      number_table;
   l_prior_event_id_tbl      number_table;
   l_prior_percent_tbl       number_table;
   l_prior_event_qty_tbl     number_table;

   l_parent_event_id_tbl     number_table;
   l_prior_event_id          NUMBER;
   l_marker                  number_table;

   l_rma_count               pls_integer := 0;
   l_last_fetch              BOOLEAN;

   -- Inventory's API to insert MMT events returns these 3 parameters
   l_return_num              NUMBER;
   l_error_code              VARCHAR2(240);
   l_error_message           VARCHAR2(2000);
   program_exception         EXCEPTION;

   -- The following stores the source code from an OE system parameter.
   l_source_code             VARCHAR2(40);

BEGIN
   debug('Insert_RmaReceipts+');
   debug('   g_ledger_id :'||g_ledger_id);

-- Standard start of API savepoint
   SAVEPOINT Insert_RmaReceipts_PVT;

   l_stmt_num := 0;

/*   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name
     );
   END IF;
*/
-- Initialize return values
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API Body

   l_last_fetch := FALSE; -- initialize boolean variable

   OPEN c_rma_receipts;

   <<all_rma_receipts_loop>>
   LOOP
      l_stmt_num := 10;

      debug(l_stmt_num);

      FETCH c_rma_receipts BULK COLLECT INTO
         l_rma_om_line_id_tbl ,
         l_cogs_om_line_id_tbl,
         l_mmt_txn_id_tbl     ,
         l_txn_date_tbl       ,
         l_event_quantity_tbl ,
         l_prior_event_id_tbl ,
         l_prior_percent_tbl  ,
         l_prior_event_qty_tbl
      LIMIT C_max_bulk_fetch_size;

      IF c_rma_receipts%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF (l_cogs_om_line_id_tbl.COUNT = 0 AND l_last_fetch) THEN
         CLOSE c_rma_receipts;
         EXIT all_rma_receipts_loop;
      END IF;

      /* For each RMA Receipt, insert 2 rows in cce - one goes in
       * the string of events and the other is the quantity adjustment
       * to that parent event.
       */

      l_stmt_num := 20;
      debug(l_stmt_num);

      FOR i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST LOOP
         l_marker(i) := 1;
         IF ( (i > l_cogs_om_line_id_tbl.FIRST) AND
              (l_prior_event_id_tbl(i) = l_prior_event_id_tbl(i-1)) ) THEN
            l_prior_event_id := l_parent_event_id_tbl(i-1);
            l_marker(i-1) := 0;
         ELSE
            l_prior_event_id := l_prior_event_id_tbl(i);
         END IF;

         -- Insert the RMA marker
         INSERT INTO cst_cogs_events (
                  event_id,
                  cogs_om_line_id,
                  event_date,
                  mmt_transaction_id,
                  cogs_percentage,
                  prior_cogs_percentage,
                  prior_event_id,
                  event_type,
                  event_om_line_id,
                  event_quantity,
                  costed,
                  parent_event_id,
                  -- WHO COLUMNS
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date)
         VALUES ( cst_cogs_events_s.nextval,
                  l_cogs_om_line_id_tbl(i),
                  l_txn_date_tbl(i),
                  NULL, -- Quantity placeholder - no MMT transaction
                  l_prior_percent_tbl(i),
                  l_prior_percent_tbl(i),
                  l_prior_event_id,
                  RMA_RECEIPT_PLACEHOLDER,
                  l_rma_om_line_id_tbl(i),
                  l_prior_event_qty_tbl(i),
                  NULL, -- This event is a quantity placeholder, thus is never costed
                  cst_cogs_events_s.currval,
                  -- WHO COLUMNS
                  sysdate,
                  p_user_id,
                  sysdate,
                  p_user_id,
                  p_login_id,
                  p_request_id,
                  p_pgm_app_id,
                  p_pgm_id,
                  sysdate)
         RETURNING event_id INTO l_parent_event_id_tbl(i);
      END LOOP;

      l_stmt_num := 30;
      debug(l_stmt_num);
      FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
         -- Insert the RMA receipts as quantity events (as opposed to % events)
         INSERT INTO cst_cogs_events (
                  event_id,
                  cogs_om_line_id,
                  event_date,
                  mmt_transaction_id,
                  cogs_percentage,
                  prior_cogs_percentage,
                  prior_event_id,
                  event_type,
                  event_om_line_id,
                  event_quantity,
                  costed,
                  parent_event_id,
                  -- WHO COLUMNS
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date)
         VALUES ( cst_cogs_events_s.nextval,
                  l_cogs_om_line_id_tbl(i),
                  l_txn_date_tbl(i),
                  l_mmt_txn_id_tbl(i),
                  l_prior_percent_tbl(i), -- COGS percentage
                  l_prior_percent_tbl(i), -- prior COGS percentage
                  NULL,
                  RMA_RECEIPT,
                  l_rma_om_line_id_tbl(i),
                  l_event_quantity_tbl(i),
                  'N',
                  l_parent_event_id_tbl(i),
                  -- WHO COLUMNS
                  sysdate,
                  p_user_id,
                  sysdate,
                  p_user_id,
                  p_login_id,
                  p_request_id,
                  p_pgm_app_id,
                  p_pgm_id,
                  sysdate);

      l_rma_count := l_rma_count + l_cogs_om_line_id_tbl.COUNT;

      -- Mark the cogs percentage column in the MMT transaction, thus indicating that it has been added
      -- to the revenue / COGS matching data model.
      l_stmt_num := 40;
      debug(l_stmt_num);
      FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
         UPDATE mtl_material_transactions
         SET cogs_recognition_percent = l_prior_percent_tbl(i),
             last_update_date = sysdate,
             last_updated_by = p_user_id,
             last_update_login = p_login_id,
             request_id = p_request_id,
             program_application_id = p_pgm_app_id,
             program_id = p_pgm_id,
             program_update_date = sysdate
         WHERE transaction_id = l_mmt_txn_id_tbl(i);


      /* If there are events after this RMA (that is, if it's backdated)
       * adjust the quantity for each of these events by either updating
       * CCE / MMT directly if the parent is uncosted, or inserting new
       * events in CCE and MMT in the case that the parent is costed.
       */

      -- First insert this new event into the linked list by setting the prior event ID of the
      -- next event to this new one.
      l_stmt_num := 50;
      debug(l_stmt_num);
      FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
         UPDATE cst_cogs_events
         SET PRIOR_EVENT_ID = l_parent_event_id_tbl(i),
             last_update_date = sysdate,
             last_updated_by = p_user_id,
             last_update_login = p_login_id,
             request_id = p_request_id
         WHERE cogs_om_line_id = l_cogs_om_line_id_tbl(i)
         AND   prior_event_id = l_prior_event_id_tbl(i)
         AND   event_date > l_txn_date_tbl(i)
         AND   l_marker(i) = 1;

      -- Now create quantity adjustment events for all future COGS Rec events
      -- First populate the global temp table with all future events that require
      -- quantity adjustment children.
      l_stmt_num := 60;
      debug(l_stmt_num);
      FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
         INSERT INTO cst_cogs_qty_adj_events_temp (
                        adj_event_id,
                        adj_mmt_txn_id,
                        adj_cogs_om_line_id,
                        adj_rma_om_line_id,
                        adj_event_date,
                        adj_new_cogs_percentage,
                        adj_prior_cogs_percentage,
                        adj_event_quantity,
                        parent_event_id,
                        inventory_item_id,
                        primary_uom,
                        organization_id,
                        cost_group_id,
                        cogs_acct_id,
                        opm_org_flag,
                        acct_period_id
                        )
         SELECT cst_cogs_events_s.nextval,
                decode(event_type, COGS_RECOGNITION_EVENT, mtl_material_transactions_s.nextval,
                                   COGS_REC_PERCENT_ADJUSTMENT, mtl_material_transactions_s.nextval,
                                   NULL),
                cce.cogs_om_line_id,
                l_rma_om_line_id_tbl(i),
                cce.event_date,
                cogs_percentage, -- could also use cce.prior_cogs_percentage
                prior_cogs_percentage,
                l_event_quantity_tbl(i),
                event_id,
                crcml.inventory_item_id,
                msi.primary_uom_code,
                crcml.organization_id,
                crcml.cost_group_id,
                crcml.cogs_acct_id,
                nvl(mp.process_enabled_flag,'N'),
                oap.acct_period_id -- acct period ID, I should store this in CCE so I don't keep having to go back to OAP
         FROM cst_cogs_events cce,
              cst_revenue_cogs_match_lines crcml,
              mtl_parameters mp,
              org_acct_periods oap,
              cst_acct_info_v caiv,
              mtl_system_items msi
         WHERE cce.cogs_om_line_id = l_cogs_om_line_id_tbl(i)
         AND   cce.event_date > l_txn_date_tbl(i)
         AND   cce.event_id = cce.parent_event_id
         AND   cce.cogs_om_line_id = crcml.cogs_om_line_id
         AND   crcml.pac_cost_type_id IS NULL
         AND   crcml.organization_id = mp.organization_id
         AND   crcml.organization_id = oap.organization_id
         AND   crcml.inventory_item_id = msi.inventory_item_id
         AND   crcml.organization_id = msi.organization_id
         AND   crcml.organization_id = caiv.organization_id
         AND   inv_le_timezone_pub.get_le_day_time_for_ou(cce.event_date, caiv.operating_unit)
               BETWEEN oap.period_start_date AND oap.schedule_close_date+.99999;

      l_stmt_num := 70;
      debug(l_stmt_num);
      -- Now insert the quantity adjustment child events
      INSERT INTO cst_cogs_events (
             event_id,
             cogs_om_line_id,
             event_date,
             mmt_transaction_id,
             cogs_percentage,
             prior_cogs_percentage,
             prior_event_id,
             event_type,
             event_om_line_id,
             event_quantity,
             costed,
             parent_event_id,
             -- WHO COLUMNS
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date)
      SELECT adj_event_id,
             adj_cogs_om_line_id,
             adj_event_date,
             adj_mmt_txn_id,
             adj_new_cogs_percentage,
             adj_prior_cogs_percentage,
             NULL,
             COGS_REC_QTY_ADJUSTMENT,
             adj_rma_om_line_id,
             adj_event_quantity,
             decode(adj_mmt_txn_id, NULL, NULL, 'N'),
             parent_event_id,
             -- WHO COLUMNS
             sysdate,
             p_user_id,
             sysdate,
             p_user_id,
             p_login_id,
             p_request_id,
             p_pgm_app_id,
             p_pgm_id,
             sysdate
      FROM cst_cogs_qty_adj_events_temp;

      -- Get the source code from the OE profile system parameter.
      -- It can be overridden by the user but most likely uses the default
      -- called 'ORDER ENTRY' and will most likely never change.
      l_stmt_num := 80;
      debug(l_stmt_num);

      l_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE'); -- borrowed from OEXVSCHB.pls
      debug('  l_source_code : '||l_source_code);

      l_stmt_num := 90;
      debug(l_stmt_num);

      -- Insert their quantity adjustments into MMT
      INSERT INTO MTL_COGS_RECOGNITION_TEMP (
                     TRANSACTION_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     COST_GROUP_ID,
                     TRANSACTION_TYPE_ID,
                     TRANSACTION_ACTION_ID,
                     TRANSACTION_SOURCE_TYPE_ID,
                     TRANSACTION_SOURCE_ID,
                     TRANSACTION_QUANTITY,
                     TRANSACTION_UOM,
                     PRIMARY_QUANTITY,
                     TRANSACTION_DATE,
                     ACCT_PERIOD_ID,
                     DISTRIBUTION_ACCOUNT_ID,
                     COSTED_FLAG,
                     OPM_COSTED_FLAG,
                     ACTUAL_COST,
                     TRANSACTION_COST,
                     PRIOR_COST,
                     NEW_COST,
                     TRX_SOURCE_LINE_ID,
                     RMA_LINE_ID,
                     LOGICAL_TRANSACTION,
                     COGS_RECOGNITION_PERCENT)
      SELECT
                     ccqa.adj_mmt_txn_id,
                     sysdate,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     ccqa.inventory_item_id,
                     ccqa.organization_id,
                     ccqa.cost_group_id,
                     10008,
                     36,
                     2,
                     mso.sales_order_id,
                     ccqa.adj_event_quantity,
                     ccqa.primary_uom, -- Txn UOM
                     ccqa.adj_event_quantity,
                     ccqa.adj_event_date,
                     ccqa.acct_period_id,
                     ccqa.cogs_acct_id,
                     decode(ccqa.opm_org_flag, 'N', 'N', NULL),
                     decode(ccqa.opm_org_flag, 'Y', 'N', NULL),
                     NULL, -- Actual Cost
                     NULL, -- Txn Cost
                     NULL, -- Prior Cost
                     NULL, -- New Cost
                     ccqa.adj_cogs_om_line_id,
                     ccqa.adj_rma_om_line_id, -- RMA Line ID
                     1, -- Logical Txn
                     ccqa.adj_new_cogs_percentage
      FROM  cst_cogs_qty_adj_events_temp ccqa,
            mtl_sales_orders mso,
            oe_order_lines_all ool,
            oe_order_headers_all ooh,
            oe_transaction_types_tl ott
      WHERE ool.line_id = ccqa.adj_cogs_om_line_id
      AND   ool.header_id = ooh.header_id
      AND   TO_CHAR(ooh.order_number) = mso.segment1
      AND   ooh.order_type_id = ott.transaction_type_id
      AND   ott.name = mso.segment2
      AND   ott.language = (SELECT language_code
                            FROM   fnd_languages
                            WHERE  installed_flag = 'B')
      AND   mso.segment3 = l_source_code
      AND   ccqa.adj_mmt_txn_id IS NOT NULL;

      -- Now Call Inventory API to populate MMT from the above global temp table
      l_stmt_num := 100;
      debug(l_stmt_num);

      INV_LOGICAL_TRANSACTIONS_PUB.create_cogs_recognition(x_return_status => l_return_num,
                                                           x_error_code    => l_error_code,
                                                           x_error_message => l_error_message);

      IF (l_return_num <> 0) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         FND_MESSAGE.set_name('BOM', 'CST_FAILED_COGSREC_MMT_INSERT');
         FND_MESSAGE.set_token('ERROR_CODE', l_error_code);
         FND_MESSAGE.set_token('ERROR_MESSAGE',substr(l_error_message,1,500));
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.ADD;
         END IF;
         IF l_errorLog THEN
            FND_LOG.message(FND_LOG.LEVEL_ERROR, l_module||'.'||to_char(l_stmt_num),TRUE);
         END IF;
         raise program_exception;
      END IF;

      l_stmt_num := 90;
      debug(l_stmt_num);
      commit;  --delete from cst_cogs_qty_adj_events_temp;
      SAVEPOINT Insert_RmaReceipts_PVT;

   END LOOP all_rma_receipts_loop;

   IF l_eventLog THEN
      l_api_message :=  'Inserted '||to_char(l_rma_count)||' RMA Receipts into CCE.';
      FND_LOG.string(FND_LOG.LEVEL_EVENT, G_LOG_HEAD ||'.'|| l_api_name || '.'||l_stmt_num, l_api_message);
   END IF;

-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;
   debug('   x_return_status = '||x_return_status);
   debug('Insert_RmaReceipts-');
EXCEPTION
   WHEN program_exception THEN
      ROLLBACK TO Insert_RmaReceipts_PVT;
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
         ROLLBACK TO Insert_RmaReceipts_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Insert_RmaReceipts ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;
         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Insert_RmaReceipts:'||substrb(SQLERRM,1,250) );

END Insert_RmaReceipts;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Create_CogsRecognitionEvents                                           --
--       This procedure is the main procedure for phase 3 of the program   --
--       to Match COGS to Revenue. It compares the latest Revenue % with   --
--       the latest COGS percentage and, where different, creates new      --
--       COGS recognition events to bring the COGS percentage up to date.  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    04/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Create_CogsRecognitionEvents(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER,
                p_ledger_id       IN   NUMBER DEFAULT NULL --BUG#5726230
               ,p_neg_req_id      IN   NUMBER DEFAULT NULL --BUG#7387575
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Create_CogsRecognitionEvents';
   l_api_message         VARCHAR2(1000);
   l_return_status       VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num            NUMBER         := 0;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   --{BUG#5726230
   -- Add cursor for ledger access
   CURSOR cu_ledger(p_ledger_id IN NUMBER)
   IS
   SELECT DISTINCT set_of_books_id
     FROM gl_sets_of_books
    WHERE set_of_books_id = NVL(p_ledger_id,set_of_books_id);


   -- CRRL.last_event_date corresponds to the Revenue Recognition date that AR pass to CST.
   -- Since AR does not store time component, we can assume that the recognition takes place at the end of the day.
   CURSOR c_mismatched_lines(p_sob_id                  NUMBER,
                             p_process_acct_period_num NUMBER,
                             p_cogs_acct_period_num    NUMBER,
                             p_neg_req_id              NUMBER   -- HYU
							 ) IS
      SELECT crcml.cogs_om_line_id,
             crrl.last_event_date + .99999 + clt.number_1,
             crrl.revenue_recognition_percent new_percentage,
             cce.cogs_percentage prior_percentage,
             cce.parent_event_id prior_event_id,
             sum(cce.event_quantity) event_quantity,
             crcml.cogs_acct_id,
             crcml.inventory_item_id,
             msi.primary_uom_code,
             crcml.organization_id,
             crcml.cost_group_id,
             nvl(mp.process_enabled_flag,'N') opm_org,
             (select oap.acct_period_id
              from org_acct_periods oap
              where oap.organization_id = crcml.organization_id
              and oap.period_name = gps.period_name) acct_period_id,
             clt.number_1 date_offset
             --{BUG#6809034 use CCE event_date if mmt trx after rev recog
             ,MAX(mmt.transaction_id)                     mmt_transaction_id
             ,MAX(mmt.transaction_date) + clt.number_1    mmt_transaction_date
             ,MAX(mmt.acct_period_id)                     mmt_period_id
             --}
      FROM   cst_revenue_cogs_match_lines  crcml,
             cst_revenue_recognition_lines crrl,
             cst_cogs_events               cce,
             mtl_parameters                mp,
             gl_period_statuses            gps,
	     gl_period_statuses            gps1,
             cst_lists_temp                clt,
             mtl_system_items              msi
             --{BUG#6809034
             ,mtl_material_transactions     mmt
             --}
      WHERE  crrl.ledger_id       = p_sob_id
        AND  crrl.acct_period_num = p_process_acct_period_num
        AND  crrl.potentially_unmatched_flag = 'Y' -- Indexed column should substantially reduce the rows
        --{BUG#7387575
        AND  DECODE(p_neg_req_id,NULL,
                    NVL(crrl.request_id,-99),p_neg_req_id) = NVL(crrl.request_id,-99)
        --}
        AND  crrl.revenue_om_line_id = crcml.revenue_om_line_id
        AND  crcml.organization_id = mp.organization_id
        AND  crcml.organization_id = msi.organization_id
        AND  crcml.inventory_item_id = msi.inventory_item_id
        AND  crcml.pac_cost_type_id IS NULL
        AND  gps.application_id = 101
        AND  gps.set_of_books_id = p_sob_id
        AND  gps.effective_period_num = p_cogs_acct_period_num
        AND  gps1.application_id = 101
        AND  gps1.set_of_books_id = p_sob_id
        AND  gps1.effective_period_num = p_process_acct_period_num
        AND  cce.event_date <= gps1.end_date +.99999 + clt.number_1
        AND  clt.list_id = crcml.organization_id
        AND  crcml.cogs_om_line_id = cce.cogs_om_line_id
        --{BUG#6809034
        AND  cce.mmt_transaction_id          = mmt.transaction_id(+)
        --}
        AND  NOT EXISTS (select 'X'
                         from cst_cogs_events
                         where event_date <= gps1.end_date + .99999 + clt.number_1
                         and cogs_om_line_id = crcml.cogs_om_line_id
                         and prior_event_id = cce.parent_event_id)
        AND  cce.cogs_percentage <> crrl.revenue_recognition_percent
      GROUP BY cce.cogs_percentage,
               cce.parent_event_id,
               crcml.cogs_om_line_id,
               crcml.cogs_acct_id,
               crcml.inventory_item_id,
               crcml.cost_group_id,
               msi.primary_uom_code,
               crrl.last_event_date,
               crrl.revenue_recognition_percent,
               clt.number_1,
               crcml.organization_id,
               mp.process_enabled_flag,
               gps.period_name
UNION
select
	     crcml.cogs_om_line_id,
             crrl.last_event_date + .99999 + clt.number_1,
             crrl.revenue_recognition_percent new_percentage,
             cce.cogs_percentage prior_percentage,
             cce.parent_event_id prior_event_id,
             sum(cce.event_quantity) event_quantity,
             crcml.cogs_acct_id,
             crcml.inventory_item_id,
             msi.primary_uom_code,
             crcml.organization_id,
             crcml.cost_group_id,
             nvl(mp.process_enabled_flag,'N') opm_org,
	     (select oap.acct_period_id
              from org_acct_periods oap
              where oap.organization_id = crcml.organization_id
              and oap.period_name = gps.period_name) acct_period_id,
             clt.number_1 date_offset,
	     max(mmt.transaction_id)	mmt_transaction_id,
	     max(mmt.transaction_date)  mmt_transaction_date,
	     MAX(mmt.acct_period_id)       mmt_period_id
	from cst_cogs_events cce,
	 cst_revenue_recognition_lines crrl,
	 cst_revenue_cogs_match_lines crcml,
	 mtl_system_items msi,
	 cst_lists_temp                clt,
	 gl_period_statuses            gps,
	 gl_period_statuses		gps1,
	 mtl_parameters mp,
	 mtl_material_transactions mmt
	where crrl.ledger_id       = p_sob_id
        AND  crrl.acct_period_num = p_process_acct_period_num
        AND  crrl.potentially_unmatched_flag = 'Y'
	AND  DECODE(p_neg_req_id,NULL,
                    NVL(crrl.request_id,-99),p_neg_req_id) = NVL(crrl.request_id,-99)
        AND  crrl.revenue_om_line_id = crcml.revenue_om_line_id
	AND  crcml.organization_id = mp.organization_id
        AND  crcml.organization_id = msi.organization_id
        AND  crcml.inventory_item_id = msi.inventory_item_id
        AND  crcml.pac_cost_type_id IS NULL
        AND  crcml.organization_id = mp.organization_id
        AND  crcml.organization_id = msi.organization_id
        AND  crcml.inventory_item_id = msi.inventory_item_id
	AND cce.event_type = 1
	AND cce.cogs_om_line_id=crcml.cogs_om_line_id
	AND  clt.list_id = crcml.organization_id
	and mmt.transaction_id = cce.mmt_transaction_id
        AND  gps.application_id = 101
        AND  gps.set_of_books_id = p_sob_id
        AND  gps.effective_period_num = p_cogs_acct_period_num
        AND  gps1.application_id = 101
        AND  gps1.set_of_books_id = p_sob_id
        AND  gps1.effective_period_num = p_process_acct_period_num
	AND  not exists
	 (select 1 from cst_cogs_events cce3
	  where cce3.event_date<=gps1.end_date + .99999 + clt.number_1
    AND cce3.cogs_om_line_id=crcml.cogs_om_line_id)
        GROUP BY
               cce.cogs_percentage,
               cce.parent_event_id,
               crcml.cogs_om_line_id,
               crcml.cogs_acct_id,
               crcml.inventory_item_id,
               crcml.cost_group_id,
               msi.primary_uom_code,
               crrl.last_event_date,
               crrl.revenue_recognition_percent,
               clt.number_1,
               crcml.organization_id,
               mp.process_enabled_flag,
               gps.period_name;




   l_revenue_acct_period_num   NUMBER   := NULL;
   l_cogs_acct_period_num      NUMBER   := NULL;
   l_gl_period_status          VARCHAR2(1);
   l_alternate_event_date      DATE;
   l_dummy_date                DATE;
   l_period_name               gl_period_statuses.period_name%type;

   l_last_fetch                BOOLEAN;
   l_cce_count                 PLS_INTEGER := 0;

   l_new_event_id_tbl            number_table;
   l_new_mmt_txn_id_tbl          number_table;
   l_cogs_om_line_id_tbl         number_table;
   l_event_date_tbl              date_table;
   l_date_offset_tbl             number_table;
   l_new_percentage_tbl          number_table;
   l_prior_percentage_tbl        number_table;
   l_prior_event_id_tbl          number_table;
   l_event_quantity_tbl          number_table;
   l_cogs_acct_id_tbl            number_table;
   l_item_id_tbl                 number_table;
   l_primary_uom_tbl             char3_table;
   l_organization_id_tbl         number_table;
   l_cost_group_id_tbl           number_table;
   l_opm_org_flg_tbl             flag_table;
   l_acct_period_id_tbl          number_table;
   l_parent_event_id_tbl         number_table;

   l_adj_mmt_txn_id_tbl          number_table;
   l_adj_event_id_tbl            number_table;
   l_adj_prior_event_id_tbl      number_table;

   --BUG5726230
   l_ledger_id_tab               number_table;

   -- Inventory's API to insert MMT events returns these 3 parameters
   l_return_num              NUMBER;
   l_error_code              VARCHAR2(240);
   l_error_message           VARCHAR2(2000);
   program_exception         EXCEPTION;

   -- The following stores the source code from an OE system parameter.
   l_source_code             VARCHAR2(40);

--BUG#6809034
   l_mmt_transaction_id          number_table;
   l_mmt_transaction_date        date_table;
   l_mmt_period_id               number_table;
   l_msg_count                   NUMBER;
--}

   --{BUG#7438582
   l_gl_adj_flag                 VARCHAR2(1);
   --}

   l_sob                         NUMBER;
   end_of_program                EXCEPTION; --BUG#5726230
BEGIN
  debug('Create_CogsRecognitionEvents+');

-- Standard start of API savepoint
   SAVEPOINT Create_CogsRecEvents_PVT;

   l_stmt_num := 0;

   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name
     );
   END IF;

   debug(' p_ledger_id :'||p_ledger_id);

-- Initialize return values
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API Body

   -- Populate offset for each organization that might be affected

   l_dummy_date := sysdate;

   l_stmt_num := 1;

   DELETE cst_lists_temp;


   --{BUG#5726230
   IF p_ledger_id IS NULL THEN

     --BUG#5726230 Current behaviour across multiple Ledgers
     --
     INSERT
     INTO   cst_lists_temp (
              list_id,
              number_1
            )
     SELECT organization_id,
            inv_le_timezone_pub.get_server_day_time_for_le(
              l_dummy_date,
              legal_entity
            ) - l_dummy_date
     FROM   (  SELECT
               DISTINCT caiv.organization_id,
                        caiv.legal_entity
               FROM     cst_revenue_recognition_lines crrl,
                        cst_revenue_cogs_match_lines crcml,
                        cst_acct_info_v caiv
               WHERE    crrl.potentially_unmatched_flag='Y'
               AND      DECODE(p_neg_req_id,NULL,NVL(crrl.request_id,-99),p_neg_req_id) = NVL(crrl.request_id,-99)
                         -- BUG#7387575
               AND      crcml.revenue_om_line_id = crrl.revenue_om_line_id
               AND      crcml.pac_cost_type_id IS NULL
               AND      caiv.organization_id = crcml.organization_id
           );
   ELSE

     --BUG#5726230 Restrict to a single ledger
     --
     INSERT
     INTO   cst_lists_temp (
              list_id,
              number_1
            )
     SELECT organization_id,
            inv_le_timezone_pub.get_server_day_time_for_le(
              l_dummy_date,
              legal_entity
            ) - l_dummy_date
     FROM   (  SELECT
               DISTINCT caiv.organization_id,
                        caiv.legal_entity
               FROM     cst_revenue_recognition_lines crrl,
                        cst_revenue_cogs_match_lines crcml,
                        cst_acct_info_v caiv
               WHERE    crrl.potentially_unmatched_flag='Y'
               AND      crcml.revenue_om_line_id       =crrl.revenue_om_line_id
               AND      DECODE(p_neg_req_id,NULL,NVL(crrl.request_id,-99),p_neg_req_id) = NVL(crrl.request_id,-99)
                        -- BUG#7387575
               AND      crcml.pac_cost_type_id         IS NULL
               AND      caiv.organization_id           =crcml.organization_id
               AND      caiv.ledger_id                 =p_ledger_id
           );
  END IF;


   -- For a given revenue line, AR only populates a record in CRRL if there
   -- is a revenue event in that period. To assist us in recognizing COGS
   -- in periods in which there are no revenue events (hence no CRRL from AR),
   -- we will create placeholder records with the revenue recognition percent
   -- from the latest period prior to that period.

   -- Insert placeholder CRRL records

--------------------------
--  This is for the case REV line being inserted in the previous accounting period
--  But not being COGS recognized.
--  We try to recover the missing COGS in the current month
--  This is nice to have but it causes dramatically perofmance issue as the volum of CRRL increases
--  and it is for a user mistake where the simple work around would be to recollect revenue
--  information for the missing period
--------------------------
--  Commented out this SQL for now as it is very expensive
--  Confirm with AR in the bug#7438582
--------------------------
--   l_stmt_num := 4;
--   MERGE
--   INTO   cst_revenue_recognition_lines target_crrl
--   USING  (
--            SELECT crcml.revenue_om_line_id,
--                   gps.effective_period_num,
--                   crrl.revenue_recognition_percent,
--                   TRUNC(MAX(cce.event_date-clt.number_1)) last_event_date,
--                   crrl.operating_unit_id,
--                   crrl.ledger_id,
--                   crrl.inventory_item_id
--            FROM   cst_revenue_cogs_match_lines   crcml,
--                   cst_lists_temp                 clt,
--                   gl_period_statuses             gps,
--                   cst_cogs_events                cce,
--                   cst_revenue_recognition_lines  crrl
--            WHERE  crcml.pac_cost_type_id IS NULL
--            AND    clt.list_id            = crcml.organization_id
--            AND    gps.application_id     = 222
--            AND    gps.set_of_books_id    = crrl.ledger_id
                   -- pick the last cogs event in this period
--            AND    cce.cogs_om_line_id    = crcml.cogs_om_line_id
--            AND    DECODE(p_neg_req_id,NULL,NVL(crrl.request_id,-99),p_neg_req_id) = NVL(crrl.request_id,-99) -- HYU
--            AND    cce.event_date
--                   BETWEEN gps.start_date + clt.number_1
--                   AND     gps.end_date   + .99999 + clt.number_1
                   -- pick the last rev rec percent prior to this period
--            AND    crrl.revenue_om_line_id = crcml.revenue_om_line_id
--            AND    crrl.last_event_date    = (
--                     SELECT /*+ no_unnest */   MAX(last_event_date)   -- Add hint for bug#6697330
--                       FROM  cst_revenue_recognition_lines
--                      WHERE  revenue_om_line_id = crcml.revenue_om_line_id
--                        AND  last_event_date    < gps.start_date
--                   )
--            GROUP
--            BY     crcml.revenue_om_line_id,
--                   gps.effective_period_num,
--                   crrl.revenue_recognition_percent,
--                   crrl.operating_unit_id,
--                   crrl.ledger_id,
--                   crrl.inventory_item_id
--          ) X
--   ON     (
--                target_crrl.revenue_om_line_id = X.revenue_om_line_id
--            AND target_crrl.acct_period_num    = X.effective_period_num
--          )
--   WHEN MATCHED THEN
--     UPDATE
--     SET    revenue_recognition_percent = X.revenue_recognition_percent,
--            potentially_unmatched_flag  = 'Y',
--            last_update_date            = SYSDATE,
--            last_updated_by             = p_user_id,
--            last_update_login           = p_login_id,
--            request_id                  = p_request_id,
--            program_application_id      = p_pgm_app_id,
--            program_id                  = p_pgm_id,
--            program_update_date         = SYSDATE
--     WHERE  revenue_recognition_percent <> X.revenue_recognition_percent
--     AND    created_by                  <> -7 -- don't update records that AR inserted / updated
--   WHEN NOT MATCHED THEN
--     INSERT (
--              revenue_om_line_id,           acct_period_num,
--              potentially_unmatched_flag,   revenue_recognition_percent,
--              last_event_date,              operating_unit_id,
--              ledger_id,                    inventory_item_id,
--              customer_trx_line_id,         last_update_date,
--              last_updated_by,              creation_date,
--              created_by,                   last_update_login,
--              request_id,                   program_application_id,
--              program_id,                   program_update_date
--            )
--     VALUES (
--              X.revenue_om_line_id,         X.effective_period_num,
--              'Y',                          X.revenue_recognition_percent,
--              X.last_event_date,            X.operating_unit_id,
--              X.ledger_id,                  X.inventory_item_id,
--              NULL,                         SYSDATE,
--              p_user_id,                    SYSDATE,
--              -7, /* mark as placeholder */ p_login_id,
--              p_request_id,                 p_pgm_app_id,
--              p_pgm_id,                     SYSDATE
--            );
------------------------------------------

   -- Loop through all the ledgers defined in the instance
   -- We match Revenue to COGS one ledger at a time because each ledger could have a different
   -- calendar, and we need to perform the matching sequentially by period.  Thus we guarantee
   -- consistency of period endpoints (calendars) by working with one ledger at a time.
   --{BUG#5726230: Needs to restrict the access to Ledger based on p_ledger_id parameter
   OPEN cu_ledger(p_ledger_id);
   FETCH cu_ledger BULK COLLECT INTO l_ledger_id_tab;
   CLOSE cu_ledger;

   IF l_ledger_id_tab.COUNT = 0 THEN
      RAISE end_of_program;
   END IF;

   <<sob_loop>> -- for each ledger defined in the instance
   --FOR l_sob IN (SELECT distinct set_of_books_id
   --              FROM gl_sets_of_books) LOOP
   FOR i IN l_ledger_id_tab.FIRST .. l_ledger_id_tab.LAST LOOP
   --}
      l_sob   := l_ledger_id_tab(i);
      debug(' processing for the ledger_id :'||l_sob);

      <<acct_period_loop>> -- loop in chronological order for each mismatched period in this ledger
      LOOP

         l_stmt_num := 10;
         debug(l_stmt_num);
         -- For each ledger, find the minimum accounting period where there exists mismatched
         -- Revenue and COGS.

         -- BUG#6809034
         -- In the case of some AR recognition on Sales Order Issue in JAN-XX and some in FEB-XX
         -- and all Sales Order Issue in FEB-XX
         -- in CRRL has a mix of accting period and last event in JAN-XX and FEB-XX
         -- in CCE event date and CRCML for all Sales Order Issue are in FEB-XX
         -- min(crrl.acct_period_num) verifying the condition will be in JAN-XX period
         -- but the l_revenue_acct_period_num will be in both FEB-XX and JAN-XX
         -- and Sales Order Issue COGS Recognition will be using JAN-XX period but
         -- transaction date matching to AR last event date in JAN-XX and FEB-XX
         -- and the CRRL acct period will be only FEB-XX
       debug('  p_neg_req_id : '||p_neg_req_id);
       IF p_neg_req_id IS NULL THEN

         SELECT /*+ LEADING( CRRL ) */ min(crrl.acct_period_num)
         INTO l_revenue_acct_period_num
         FROM cst_revenue_recognition_lines crrl,
              cst_revenue_cogs_match_lines  crcml,
           --   cst_cogs_events               cce,
              cst_lists_temp                clt,
              gl_period_statuses            gps
              --{
            -- , cst_cogs_events               cce2
              --}
         WHERE crrl.ledger_id                =  l_sob  --l_sob.set_of_books_id
         AND crrl.potentially_unmatched_flag = 'Y'
         AND crrl.revenue_om_line_id         = crcml.revenue_om_line_id
      --   AND crcml.cogs_om_line_id           = cce.cogs_om_line_id
         --{
         --If Revenue recognition before shiping use shiping date as it is the DCOGS date
         AND crrl.last_event_date BETWEEN gps.start_date AND gps.end_date + .99999
       --  AND crcml.cogs_om_line_id           = cce2.cogs_om_line_id
       --  AND cce2.event_type                 = 1  -- Sales Order Issue
       --  AND DECODE(SIGN(crrl.last_event_date - cce2.event_date), 1,
       --             crrl.last_event_date,                 -- Rev After Shiping use Revenue date
       --             cce2.event_date) BETWEEN gps.start_date AND gps.end_date + .99999
         --}
         AND gps.application_id              = 222
         AND gps.set_of_books_id             = l_sob  --l_sob.set_of_books_id
         /*AND cce.event_date                 <= gps.end_date + .99999 + clt.number_1
         AND clt.list_id                     = crcml.organization_id
         AND NOT EXISTS (select 'X'
                           from cst_cogs_events
                          where event_date     <= gps.end_date + .99999 + clt.number_1
                            and cogs_om_line_id = crcml.cogs_om_line_id
                            and prior_event_id  = cce.parent_event_id)
         AND cce.cogs_percentage <> (
               SELECT SUM(revenue_recognition_percent)
                 FROM cst_revenue_recognition_lines
                WHERE revenue_om_line_id = crrl.revenue_om_line_id
                  AND last_event_date   <= crrl.last_event_date
             )*/
         AND    clt.list_id = crcml.organization_id
         AND    NOT EXISTS
                (SELECT 1
                FROM    cst_cogs_events cce
                WHERE   cce.event_date       <= gps.end_date + .99999 + clt.number_1
                AND     crcml.cogs_om_line_id = cce.cogs_om_line_id
                AND     NOT EXISTS
                        (SELECT 'X'
                        FROM    cst_cogs_events cce2
                        WHERE   cce2.event_date     <= gps.end_date + .99999 + clt.number_1
                        AND     cce2.cogs_om_line_id = cce.cogs_om_line_id
                        AND     cce2.prior_event_id  = cce.parent_event_id
                        )
                AND     cce.cogs_percentage =
                        ( SELECT SUM(revenue_recognition_percent)
                        FROM    cst_revenue_recognition_lines
                        WHERE   revenue_om_line_id = crrl.revenue_om_line_id
                        AND     last_event_date   <= crrl.last_event_date
                        )
                )
         AND    crcml.pac_cost_type_id IS NULL;

       ELSE

         SELECT min(crrl.acct_period_num)
         INTO l_revenue_acct_period_num
         FROM cst_revenue_recognition_lines crrl,
              cst_revenue_cogs_match_lines  crcml,
          --    cst_cogs_events               cce,
              cst_lists_temp                clt,
              gl_period_statuses            gps
         WHERE crrl.ledger_id                =  l_sob  --l_sob.set_of_books_id
         AND crrl.potentially_unmatched_flag = 'Y'
         AND crrl.request_id                 = p_neg_req_id  --BUG#7387575
         AND crrl.revenue_om_line_id         = crcml.revenue_om_line_id
       --  AND crcml.cogs_om_line_id           = cce.cogs_om_line_id
         AND crrl.last_event_date BETWEEN gps.start_date AND gps.end_date + .99999
         AND gps.application_id              = 222
         AND gps.set_of_books_id             = l_sob  --l_sob.set_of_books_id
        /* AND cce.event_date                 <= gps.end_date + .99999 + clt.number_1
         AND clt.list_id                     = crcml.organization_id
         AND NOT EXISTS (select 'X'
                           from cst_cogs_events
                          where event_date     <= gps.end_date + .99999 + clt.number_1
                            and cogs_om_line_id = crcml.cogs_om_line_id
                            and prior_event_id  = cce.parent_event_id)
         AND cce.cogs_percentage <> (
               SELECT SUM(revenue_recognition_percent)
                 FROM cst_revenue_recognition_lines
                WHERE revenue_om_line_id = crrl.revenue_om_line_id
                  AND last_event_date   <= crrl.last_event_date
             )*/
         AND    clt.list_id = crcml.organization_id
         AND    NOT EXISTS
                (SELECT 1
                FROM    cst_cogs_events cce
                WHERE   cce.event_date       <= gps.end_date + .99999 + clt.number_1
                AND     crcml.cogs_om_line_id = cce.cogs_om_line_id
                AND     NOT EXISTS
                        (SELECT 'X'
                        FROM    cst_cogs_events cce2
                        WHERE   cce2.event_date     <= gps.end_date + .99999 + clt.number_1
                        AND     cce2.cogs_om_line_id = cce.cogs_om_line_id
                        AND     cce2.prior_event_id  = cce.parent_event_id
                        )
                AND     cce.cogs_percentage =
                        ( SELECT SUM(revenue_recognition_percent)
                        FROM    cst_revenue_recognition_lines
                        WHERE   revenue_om_line_id = crrl.revenue_om_line_id
                        AND     last_event_date   <= crrl.last_event_date
                        )
                )
         AND    crcml.pac_cost_type_id IS NULL;

     END IF;


         EXIT acct_period_loop WHEN l_revenue_acct_period_num IS NULL;

         IF l_stmtLog THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module||'.10',
--                 'Ledger ID.Min Acct Per Num = '||to_char(l_sob.set_of_books_id)||'.'||to_char(l_revenue_acct_period_num));
                 'Ledger ID.Min Acct Per Num = '||l_sob||'.'||l_revenue_acct_period_num);
         END IF;

         l_stmt_num := 20;
      debug(l_stmt_num);

         -- Check the GL period.  If it is closed, create these events in the next open period
         -- BUG#9809034
         -- Now suppose JAN-XX is still opened
         SELECT closing_status,
	        period_name,
                adjustment_period_flag     --BUG7438582 UTSTAR
           INTO l_gl_period_status,
                l_period_name,
                l_gl_adj_flag              --BUG7438582 UTSTAR
           FROM gl_period_statuses
         WHERE application_id       = 101
           AND ledger_id            = l_sob   --l_sob.set_of_books_id
           AND effective_period_num = l_revenue_acct_period_num;

         --
         -- If the GL period is closed, need to get the next open period
         -- BUG7438582  UTSTAR.COM
         -- Allow Cogs Reco in Futur not adjustment periods
         --
         IF (      l_gl_period_status <> 'O'
             AND  (l_gl_period_status <> 'F' OR l_gl_adj_flag <> 'N')
            )
         THEN

            l_stmt_num := 30;
            debug(l_stmt_num);
            SELECT min(effective_period_num)
              INTO l_cogs_acct_period_num
              FROM gl_period_statuses
             WHERE application_id       = 101
               AND ledger_id            = l_sob   --l_sob.set_of_books_id
               AND effective_period_num > l_revenue_acct_period_num
               AND (closing_status       = 'O'
               --{BUG#7438582 UTSTAR - Allow Cogs Reco in Futur not adjustment periods
                     OR (closing_status = 'F' AND adjustment_period_flag = 'N')
                   );
               --}
            -- Use the start date of the next open period as the event date
            -- for all these new COGS Rec events.
            l_stmt_num := 40;
            BEGIN
               l_stmt_num := 40;
               debug(l_stmt_num);
               SELECT start_date
                 INTO l_alternate_event_date
                 FROM  gl_period_statuses
                WHERE application_id       = 101
                  AND ledger_id            = l_sob  --l_sob.set_of_books_id
                  AND effective_period_num = l_cogs_acct_period_num;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                     FND_MESSAGE.set_name('BOM', 'CST_NO_OPEN_GL_PERIOD');
                     FND_MESSAGE.set_token('LEDGER', l_sob); -- to_char(l_sob.set_of_books_id)
                     FND_MESSAGE.set_token('PERIOD_NAME',l_period_name);
                     FND_MSG_PUB.ADD;
                     IF l_errorLog THEN
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,TRUE);
                     END IF;
                  END IF;
                  raise no_data_found;
            END;

         ELSE
            -- The period is open, so COGS and Revenue will be matched in this period
            -- and we can use the AR date as the event date (instead of alternate event date).
            --BUG#6809034
            -- If JAN-XX is still opened this is portion all code executed
            --
            l_cogs_acct_period_num := l_revenue_acct_period_num;
            l_alternate_event_date := NULL;


         END IF;

         l_last_fetch := FALSE; -- initialize boolean variable


--         OPEN c_mismatched_lines(l_sob.set_of_books_id, l_revenue_acct_period_num, l_cogs_acct_period_num);
         OPEN c_mismatched_lines(l_sob,
	                         l_revenue_acct_period_num,
                                 l_cogs_acct_period_num,
                                 p_neg_req_id   --BUG#7387575
								 );
         <<mismatched_lines_loop>>
         LOOP
               l_stmt_num := 50;
               debug(l_stmt_num);

               -- Fetch 1000 mismatched COGS and Revenue records for processing
               FETCH c_mismatched_lines BULK COLLECT INTO
                  l_cogs_om_line_id_tbl,
                  l_event_date_tbl,
                  l_new_percentage_tbl,
                  l_prior_percentage_tbl,
                  l_prior_event_id_tbl,
                  l_event_quantity_tbl,
                  l_cogs_acct_id_tbl,
                  l_item_id_tbl,
                  l_primary_uom_tbl,
                  l_organization_id_tbl,
                  l_cost_group_id_tbl,
                  l_opm_org_flg_tbl,
                  l_acct_period_id_tbl,
                  l_date_offset_tbl ,
             --{BUG#6809034
                  l_mmt_transaction_id,
                  l_mmt_transaction_date,
                  l_mmt_period_id
             --}
               LIMIT C_max_bulk_fetch_size;

               IF c_mismatched_lines%NOTFOUND THEN
                  l_last_fetch := TRUE;
               END IF;

               IF (l_cogs_om_line_id_tbl.COUNT = 0 AND l_last_fetch) THEN
                  CLOSE c_mismatched_lines;
                  EXIT mismatched_lines_loop;
               END IF;

               l_stmt_num := 60;
               debug(l_stmt_num);
               -- create COGS events in cst_cogs_events
               FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
                  INSERT INTO cst_cogs_events (
                     event_id,
                     cogs_om_line_id,
                     event_date,
                     mmt_transaction_id,
                     cogs_percentage,
                     prior_cogs_percentage,
                     prior_event_id,
                     event_type,
                     event_om_line_id,
                     event_quantity,
                     costed,
                     parent_event_id,
                     -- WHO COLUMNS
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date)
                  VALUES(
                     cst_cogs_events_s.nextval,
                     l_cogs_om_line_id_tbl(i),
                     --BUG#6809034 -- As JAN-XX is opened the transaction_date is AR recognition event date
                     --But as the bug is only on the material transaction, this COGS event event_date remains
                     --untouch to avoid breaking the current logic based on the CCE,CRCML,CRRL for CCE creation
                     --If the problem is hitting the accounting unproper such as to much COGS recognized or not enough
                     --this can be the starting point
                     --nvl(l_alternate_event_date+.99999+l_date_offset_tbl(i),l_event_date_tbl(i)),
		     l_event_date_tbl(i),
                     mtl_material_transactions_s.nextval,
                     l_new_percentage_tbl(i),
                     l_prior_percentage_tbl(i),
                     l_prior_event_id_tbl(i),
                     COGS_RECOGNITION_EVENT,
                     NULL, -- event OM line ID
                     l_event_quantity_tbl(i),
                     'N',
                     cst_cogs_events_s.currval,
                     -- WHO COLUMNS
                     sysdate,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     p_login_id,
                     p_request_id,
                     p_pgm_app_id,
                     p_pgm_id,
                     sysdate
                  )
                  RETURNING event_id, mmt_transaction_id
                  BULK COLLECT INTO l_new_event_id_tbl, l_new_mmt_txn_id_tbl;

               l_cce_count := l_cce_count + l_new_event_id_tbl.COUNT;
               debug('  l_cce_count  : '||l_cce_count);
               l_stmt_num := 70;
               debug(l_stmt_num);
               -- Insert MMT transactions into the global temp table
               FORALL i IN l_new_mmt_txn_id_tbl.FIRST .. l_new_mmt_txn_id_tbl.LAST
                  INSERT INTO mtl_cogs_recognition_temp (
                     TRANSACTION_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     COST_GROUP_ID,
                     TRANSACTION_TYPE_ID,
                     TRANSACTION_ACTION_ID,
                     TRANSACTION_SOURCE_TYPE_ID,
                     TRANSACTION_QUANTITY,
                     TRANSACTION_UOM,
                     PRIMARY_QUANTITY,
                     TRANSACTION_DATE,
                     ACCT_PERIOD_ID,
                     DISTRIBUTION_ACCOUNT_ID,
                     COSTED_FLAG,
                     OPM_COSTED_FLAG,
                     ACTUAL_COST,
                     TRANSACTION_COST,
                     PRIOR_COST,
                     NEW_COST,
                     TRX_SOURCE_LINE_ID,
                     RMA_LINE_ID,
                     LOGICAL_TRANSACTION,
                     COGS_RECOGNITION_PERCENT,
                     transaction_set_id      -- BUG#7387575
					 )
                  VALUES (
                     l_new_mmt_txn_id_tbl(i),
                     sysdate,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     l_item_id_tbl(i),
                     l_organization_id_tbl(i),
                     l_cost_group_id_tbl(i),
                     10008,
                     36,
                     2,
                     l_event_quantity_tbl(i),
                     l_primary_uom_tbl(i), -- Txn UOM
                     l_event_quantity_tbl(i),
                --BUG#6809034
                     --nvl(l_alternate_event_date+.99999+l_date_offset_tbl(i),l_event_date_tbl(i)),
                     -- In the scenario JAN-XX is still opened
					 -- the l_alternate_event_date is NULL hence the AR last event date will be used
                     -- but the c_mismatched_lines the acct period id will be dictated by CRCML
                     -- and it will be for the month of FEB as all Sales Order Issue are created in FEB-XX
                     -- creating COGS event date can be out of synch with MMT
                     -- Plus in the Case of GSI the Rev Rec can be done without Sales Order Issue
                     -- We need to make sure not to recognition COGS before DCOGS is being hit
                     DECODE(l_mmt_transaction_date(i), NULL,
                           NVL(l_alternate_event_date+.99999+l_date_offset_tbl(i),l_event_date_tbl(i)),
                           DECODE(SIGN(l_mmt_transaction_date(i) - l_event_date_tbl(i)), -1, --Sales Order Issue before RR
                                  NVL(l_alternate_event_date+.99999+l_date_offset_tbl(i),l_event_date_tbl(i)), --Use AR event
                                  --BUG#7828709
                                  --Case Sales Order Issue after RR
                                  -- If the l_mmt_transaction_date > AR event date Then use l_mmt_transaction_date
                                  -- else use AR event date
                                  DECODE(SIGN(l_mmt_transaction_date(i)
                                               - NVL(l_alternate_event_date+.99999+l_date_offset_tbl(i),
                                                                                  l_event_date_tbl(i))), -1,
	                                       NVL(l_alternate_event_date+.99999+l_date_offset_tbl(i),
                                               l_event_date_tbl(i)),
                                  l_mmt_transaction_date(i)))),-- Use SO DCOGS transaction date
                --}
                --{BUG#6809034
                     -- In order to be consitent with the approach, the acct_period_id has to follow the same path
                     --l_acct_period_id_tbl(i),
                    DECODE(l_mmt_period_id(i), NULL,
                           l_acct_period_id_tbl(i),
                           DECODE(SIGN(l_mmt_transaction_date(i) - l_event_date_tbl(i)), -1, --Sales Order Issue before RR
                                  l_acct_period_id_tbl(i),
                                  --BUG#7828709
                                  --Case Sales Order Issue after RR
                                  -- If the l_mmt_transaction_date > AR event date Then use l_mmt_transaction_date
                                  -- else use AR event date
                                  DECODE(SIGN(l_mmt_transaction_date(i)
                                                - NVL(l_alternate_event_date+.99999+l_date_offset_tbl(i),
                                                         l_event_date_tbl(i))),-1,
                                                         l_acct_period_id_tbl(i),
                                  l_mmt_period_id(i)))),
                --}
                     l_cogs_acct_id_tbl(i),
                     decode(l_opm_org_flg_tbl(i), 'N', 'N', NULL),
                     decode(l_opm_org_flg_tbl(i), 'Y', 'N', NULL),
                     NULL, -- Actual Cost
                     NULL, -- Txn Cost
                     NULL, -- Prior Cost
                     NULL, -- New Cost
                     l_cogs_om_line_id_tbl(i),
                     NULL, -- RMA Line ID
                     1, -- Logical Txn
                     l_new_percentage_tbl(i)
                    ,p_neg_req_id              --BUG#7387575
					 );

               -- Don't call Inventory's API to create MMT transactions from these temporary events
               -- until after the next insertion into the global temp table (below).

               -- Adjustment Processing
               -- First adjust all future events by simply updating those directly that have not been costed yet
               l_stmt_num := 80;
               debug(l_stmt_num);
               FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
                  UPDATE cst_cogs_events
                  SET PRIOR_COGS_PERCENTAGE = l_new_percentage_tbl(i),
                      PRIOR_EVENT_ID        = l_new_event_id_tbl(i),
                      last_update_date      = sysdate,
                      last_updated_by       = p_user_id,
                      last_update_login     = p_login_id,
                      request_id            = p_request_id
                  WHERE cogs_om_line_id      = l_cogs_om_line_id_tbl(i)
                  AND   prior_event_id       = l_prior_event_id_tbl(i)
                  AND   event_id            <> l_new_event_id_tbl(i)
                  AND   l_opm_org_flg_tbl(i) = 'N'
                  AND   costed               = 'N';

               -- Otherwise, for future events that are not directly updatable, insert adjustment events
               -- between the newly created events (above) and the future events.
               -- It is necessary to first insert these events into a global temp table because a placeholder
               -- is required for the update statement below (stmt 170).
               -- This portion is for Revenue Recognition adjustment activity for the bug#6809034 remain untouched
               l_stmt_num := 90;
               debug(l_stmt_num);
               FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
                  INSERT INTO cst_cogs_pct_adj_events_temp (
                                   adj_event_id,
                                   adj_mmt_txn_id,
                                   adj_cogs_om_line_id,
                                   adj_event_date,
                                   adj_new_cogs_percentage,
                                   adj_prior_cogs_percentage,
                                   adj_prior_event_id,
                                   adj_event_quantity,
                                   ftr_event_id,
                                   inventory_item_id,
                                   primary_uom,
                                   organization_id,
                                   cost_group_id,
                                   cogs_acct_id,
                                   opm_org_flag,
                                   acct_period_id
                                   )
                  SELECT cst_cogs_events_s.nextval,
                         mtl_material_transactions_s.nextval,
                         cogs_om_line_id,
                         event_date,
                         l_prior_percentage_tbl(i), -- could also use cce.prior_cogs_percentage
                         l_new_percentage_tbl(i),
                         l_new_event_id_tbl(i),
                         event_quantity,
                         event_id,
                         l_item_id_tbl(i),
                         l_primary_uom_tbl(i),
                         l_organization_id_tbl(i),
                         l_cost_group_id_tbl(i),
                         l_cogs_acct_id_tbl(i),
                         l_opm_org_flg_tbl(i),
                         oap.acct_period_id
                  FROM cst_cogs_events cce,
                       org_acct_periods oap
                  WHERE cogs_om_line_id =  l_cogs_om_line_id_tbl(i)
                  AND   prior_event_id  =  l_prior_event_id_tbl(i)
                  AND   event_id        <> l_new_event_id_tbl(i)
                  AND   cce.event_date
                        BETWEEN oap.period_start_date + l_date_offset_tbl(i)
                            AND oap.schedule_close_date + .99999 + l_date_offset_tbl(i)
                  AND   oap.organization_id = l_organization_id_tbl(i);

               -- Now load the events into CCE from the temp table
               l_stmt_num := 100;
               debug(l_stmt_num);
               INSERT INTO cst_cogs_events (
                     event_id,
                     cogs_om_line_id,
                     event_date,
                     mmt_transaction_id,
                     cogs_percentage,
                     prior_cogs_percentage,
                     prior_event_id,
                     event_type,
                     event_om_line_id,
                     event_quantity,
                     costed,
                     parent_event_id,
                     -- WHO COLUMNS
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date)
               SELECT adj_event_id,
                      adj_cogs_om_line_id,
                      adj_event_date,
                      adj_mmt_txn_id,
                      adj_new_cogs_percentage,
                      adj_prior_cogs_percentage,
                      adj_prior_event_id,
                      COGS_REC_PERCENT_ADJUSTMENT,
                      NULL,
                      adj_event_quantity,
                      'N',
                      adj_event_id,
                      -- WHO COLUMNS
                      sysdate,
                      p_user_id,
                      sysdate,
                      p_user_id,
                      p_login_id,
                      p_request_id,
                      p_pgm_app_id,
                      p_pgm_id,
                      sysdate
               FROM cst_cogs_pct_adj_events_temp;

               l_cce_count := l_cce_count + SQL%ROWCOUNT;
               debug('   l_cce_count : '|| l_cce_count);
               l_stmt_num := 110;
               debug(l_stmt_num);
               -- Now create these events in Inventory's table
               -- Use the Inventory Temp Table for new MMT txns
               INSERT INTO MTL_COGS_RECOGNITION_TEMP (
                     TRANSACTION_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     COST_GROUP_ID,
                     TRANSACTION_TYPE_ID,
                     TRANSACTION_ACTION_ID,
                     TRANSACTION_SOURCE_TYPE_ID,
                     TRANSACTION_QUANTITY,
                     TRANSACTION_UOM,
                     PRIMARY_QUANTITY,
                     TRANSACTION_DATE,
                     ACCT_PERIOD_ID,
                     DISTRIBUTION_ACCOUNT_ID,
                     COSTED_FLAG,
                     OPM_COSTED_FLAG,
                     ACTUAL_COST,
                     TRANSACTION_COST,
                     PRIOR_COST,
                     NEW_COST,
                     TRX_SOURCE_LINE_ID,
                     LOGICAL_TRANSACTION,
                     COGS_RECOGNITION_PERCENT
                    ,transaction_set_id      --BUG#7387575
					 )
               SELECT
                     adj_mmt_txn_id,
                     sysdate,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     inventory_item_id,
                     organization_id,
                     cost_group_id,
                     10008,
                     36,
                     2,
                     adj_event_quantity,
                     primary_uom, -- Txn UOM
                     adj_event_quantity,
                     adj_event_date,
                     acct_period_id,
                     cogs_acct_id,
                     decode(opm_org_flag, 'N', 'N', NULL),
                     decode(opm_org_flag, 'Y', 'N', NULL),
                     NULL, -- Actual Cost
                     NULL, -- Txn Cost
                     NULL, -- Prior Cost
                     NULL, -- New Cost
                     adj_cogs_om_line_id,
                     1, -- Logical Txn
                     adj_new_cogs_percentage
                    ,p_neg_req_id                 --BUG#7387575
               FROM cst_cogs_pct_adj_events_temp;

               -- Next update MTL_COGS_RECOGNITION_TEMP to populate transaction_source_id with the
               -- sales_order_id from mtl_sales_orders.

               -- Get the source code from the OE profile system parameter.
               -- It can be overridden by the user but most likely uses the default
               -- called 'ORDER ENTRY' and will most likely never change.
               l_stmt_num := 145;
               debug(l_stmt_num);

               l_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE'); -- borrowed from OEXVSCHB.pls
               debug('  l_source_code : '||l_source_code);

               l_stmt_num := 150;
               debug(l_stmt_num);

               UPDATE mtl_cogs_recognition_temp mcr
               SET (transaction_source_id) = (
                  SELECT mkts.sales_order_id
                  FROM mtl_sales_orders mkts,
                       oe_order_lines_all ool,
                       oe_order_headers_all ooh,
                       oe_transaction_types_tl ott
                  WHERE ool.line_id               = mcr.trx_source_line_id
                  AND   ool.header_id             = ooh.header_id
                  AND   to_char(ooh.order_number) = mkts.segment1
                  AND   ooh.order_type_id         = ott.transaction_type_id
                  AND   ott.name                  = mkts.segment2
                  AND   ott.language = (select language_code
                                          from fnd_languages
                                         where installed_flag = 'B')
                  AND   mkts.segment3             = l_source_code);



               --{BUG#6809034
               --All the effort has been put in the MMT transaction date, we now ensure the synchronization between
               -- transaction_date and acct_period_id before the call to INV transactions
               l_stmt_num := 155;
               debug(l_stmt_num);

               ensure_mmt_per_and_date(x_return_status   => l_return_status,
                                       x_msg_count       => l_msg_count,
                                       x_msg_data        => l_error_message);

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  debug(FND_LOG.LEVEL_ERROR, l_module||'.'||to_char(l_stmt_num));
                  raise program_exception;
               END IF;
               --}


               -- Now insert into MMT by calling INV API
               l_stmt_num := 160;
               debug(l_stmt_num);

               INV_LOGICAL_TRANSACTIONS_PUB.create_cogs_recognition(x_return_status => l_return_num,
                                                                    x_error_code    => l_error_code,
                                                                    x_error_message => l_error_message);

               IF (l_return_num <> 0) THEN
                  x_return_status := fnd_api.g_ret_sts_error;
                  FND_MESSAGE.set_name('BOM', 'CST_FAILED_COGSREC_MMT_INSERT');
                  FND_MESSAGE.set_token('ERROR_CODE', l_error_code);
                  FND_MESSAGE.set_token('ERROR_MESSAGE',substr(l_error_message,1,500));
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                     FND_MSG_PUB.ADD;
                  END IF;
                  IF l_errorLog THEN
                     FND_LOG.message(FND_LOG.LEVEL_ERROR, l_module||'.'||to_char(l_stmt_num),TRUE);
                  END IF;
                  raise program_exception;
               END IF;

               -- Update the prior event ID in the future event in CCE using the temp table CCPAET
               l_stmt_num := 170;
               debug(l_stmt_num);

               UPDATE (
                  SELECT cce.prior_event_id,
                         cba.adj_event_id
                    FROM cst_cogs_events              cce,
                         cst_cogs_pct_adj_events_temp cba
                   WHERE cce.event_id = cba.ftr_event_id)
               SET prior_event_id = adj_event_id;

               l_stmt_num := 180;
               debug(l_stmt_num);


               COMMIT;  --also deletes from cst_cogs_pct_adj_events_temp;
               SAVEPOINT Create_CogsRecEvents_PVT;

         END LOOP mismatched_lines_loop; -- c_mismatched_lines bulk fetches

         IF l_stmtLog THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module||'.100',
                 'Ledger.PerNum.InsertedEvents = '||l_sob||'.'||     --to_char(l_sob.set_of_books_id)||'.'||
                  l_cogs_acct_period_num||'.'||l_cce_count);
         END IF;

         -- Now update the mismatched revenue lines in CRRL in case a future SOB/period iteration fails
         l_stmt_num := 190;
         debug(l_stmt_num);

          IF p_neg_req_id IS NULL THEN
           -- FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
            UPDATE cst_revenue_recognition_lines crrl
            SET potentially_unmatched_flag = NULL,
                last_update_date           = sysdate,
                last_updated_by            = p_user_id,
                last_update_login          = p_login_id,
                request_id                 = p_request_id,
                program_application_id     = p_pgm_app_id,
                program_id                 = p_pgm_id,
                program_update_date        = sysdate
          WHERE potentially_unmatched_flag = 'Y'
            AND ledger_id                  = l_sob   -- l_sob.set_of_books_id
            AND acct_period_num            = l_revenue_acct_period_num
            AND EXISTS
                   (SELECT 1 FROM cst_revenue_cogs_match_lines crcml,
                    cst_cogs_events  cce, gl_period_statuses gps
                     WHERE cce.event_type=3
                      AND cce.cogs_om_line_id=crcml.cogs_om_line_id
                     -- AND crcml.cogs_om_line_id=l_cogs_om_line_id_tbl(i)
                      AND  gps.application_id = 101
                      AND  gps.set_of_books_id = l_sob
                      AND  gps.effective_period_num = l_revenue_acct_period_num
                      AND cce.event_date BETWEEN gps.start_date and gps.end_date
		      and crcml.revenue_om_line_id=crrl.revenue_om_line_id
                      );

        ELSE
	-- FORALL i IN l_cogs_om_line_id_tbl.FIRST..l_cogs_om_line_id_tbl.LAST
            UPDATE cst_revenue_recognition_lines crrl
            SET potentially_unmatched_flag = NULL,
                last_update_date           = sysdate,
                last_updated_by            = p_user_id,
                last_update_login          = p_login_id,
                request_id                 = p_request_id,
                program_application_id     = p_pgm_app_id,
                program_id                 = p_pgm_id,
                program_update_date        = sysdate
          WHERE potentially_unmatched_flag = 'Y'
            AND request_id                 = p_neg_req_id
            AND ledger_id                  = l_sob   -- l_sob.set_of_books_id
            AND acct_period_num            = l_revenue_acct_period_num
                        AND EXISTS
                   (SELECT 1 FROM cst_revenue_cogs_match_lines crcml,
                    cst_cogs_events cce, gl_period_statuses gps
                     WHERE cce.event_type=3
                      AND cce.cogs_om_line_id=crcml.cogs_om_line_id
                    --  AND crcml.cogs_om_line_id=l_cogs_om_line_id_tbl(i)
                      AND  gps.application_id = 101
                      AND  gps.set_of_books_id = l_sob
                      AND  gps.effective_period_num = l_revenue_acct_period_num
                      AND cce.event_date BETWEEN gps.start_date and gps.end_date
		      and crcml.revenue_om_line_id=crrl.revenue_om_line_id
                      );

        END IF;

        commit;  -- Need to save this update as well
        SAVEPOINT Create_CogsRecEvents_PVT;

      END LOOP acct_period_loop;
   END LOOP sob_loop;

   IF l_eventLog THEN
      l_api_message :=  'Inserted '||to_char(l_cce_count)||' new COGS Recognition Events into CCE.';
      FND_LOG.string(FND_LOG.LEVEL_EVENT, G_LOG_HEAD ||'.'|| l_api_name || '.10', l_api_message);
   END IF;

-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

   debug('  x_return_status : '||x_return_status);
   debug('Create_CogsRecognitionEvents-');

EXCEPTION
   WHEN end_of_program THEN
       ROLLBACK TO Create_CogsRecEvents_PVT;
       -- Let the program end normally
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       debug('EXCEPTION end_of_program Create_CogsRecognitionEvents '||l_stmt_num||' : no ledger found - p_ledger_id :'||p_ledger_id);

   WHEN program_exception THEN
      ROLLBACK TO Create_CogsRecEvents_PVT;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_FILE.put_line(fnd_file.log, 'program_exception EXCEPTION IN Create_CogsRecognitionEvents');

   WHEN OTHERS THEN
         ROLLBACK TO Create_CogsRecEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Create_CogsRecognitionEvents ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;
         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Create_CogsRecognitionEvents:'||substrb(SQLERRM,1,250) );

END Create_CogsRecognitionEvents;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_OneSoIssue    This procedure is very similar to the             --
--             Insert_SoIssues() procedure above.  It differs in that the  --
--             above procedure handles bulk inserts and is called during   --
--             one of the phases of the concurrent request, while this     --
--             version inserts one sales order at a time into the data     --
--             model, and is called from the Cost Processor.               --
--                                                                         --
--             This procedure should only get called for issues out of     --
--             asset subinventories.                                       --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    Line_ID of the sales order issue from OM table    --
--  P_COGS_ACCT_ID       GL Code Combination for the COGS account          --
--  P_DEF_COGS_ACCT_ID   GCC for the deferred COGS account                 --
--  P_MMT_TXN_ID         Transaction ID from MMT table                     --
--  P_ORGANIZATION_ID    Organization ID                                   --
--  P_ITEM_ID            Inventory Item ID                                 --
--  P_TRANSACTION_DATE   Event Date                                        --
--  P_COGS_GROUP_ID      Cost Group ID                                     --
--  P_QUANTITY           Sales Order Issue Quantity as a POSITIVE value    --
--                                                                         --
-- HISTORY:                                                                --
--    05/13/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_OneSoIssue(
                p_api_version           IN  NUMBER,
                p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_cogs_acct_id          IN  NUMBER,
                p_def_cogs_acct_id      IN  NUMBER,
                p_mmt_txn_id            IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_transaction_date      IN  DATE,
                p_cost_group_id         IN  NUMBER,
                p_quantity              IN  NUMBER
) IS

   l_api_name               CONSTANT VARCHAR2(30)  := 'Insert_OneSoIssue';
   l_api_message            VARCHAR2(1000);
   l_api_version            CONSTANT NUMBER        := 1.0;
   l_return_status          VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
   l_msg_count           NUMBER             := 0;
   l_msg_data            VARCHAR2(8000)     := '';
   l_stmt_num               NUMBER                 := 0;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name||'.';
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_revenue_om_line_id     NUMBER;
   l_parent_cce_id          NUMBER;
   l_operating_unit_id      NUMBER;
   l_ledger_id              NUMBER;

   program_exception        EXCEPTION;

BEGIN
   debug('Insert_OneSoIssue_PVT+');
   debug('  p_api_version     : '||p_api_version);
   debug('  p_cogs_om_line_id : '||p_cogs_om_line_id);
   debug('  p_cogs_acct_id    : '||p_cogs_acct_id);
   debug('  p_def_cogs_acct_id: '||p_def_cogs_acct_id);
   debug('  p_mmt_txn_id      : '||p_mmt_txn_id);
   debug('  p_organization_id : '||p_organization_id);
   debug('  p_item_id         : '||p_item_id);
   debug('  p_transaction_date: '||to_char(p_transaction_date,'MM-DD-YYYY'));
   debug('  p_cost_group_id   : '||p_cost_group_id);
   debug('  p_quantity        : '||p_quantity);


-- Standard start of API savepoint
   SAVEPOINT Insert_OneSoIssue_PVT;

   l_stmt_num := 0;
   debug(l_stmt_num);
/*
   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'p_cogs_om_line_id = '||p_cogs_om_line_id||','||
        'p_cogs_acct_id = '||p_cogs_acct_id||','||
        'p_def_cogs_acct_id = '||p_def_cogs_acct_id||','||
        'p_mmt_txn_id = '||p_mmt_txn_id||','||
        'p_organization_id = '||p_organization_id||','||
        'p_item_id = '||p_item_id||','||
        'p_transaction_date = '||to_char(p_transaction_date,'MM-DD-YYYY')||','||
        'p_cost_group_id = '||p_cost_group_id||','||
        'p_quantity = '||p_quantity
      );
   END IF;
*/
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

-- API Body

   -- initialize
   l_revenue_om_line_id := NULL;
   l_parent_cce_id := NULL;

   l_stmt_num := 10;
   debug(l_stmt_num);
   -- get the operating unit
   SELECT decode(fpg.multi_org_flag,'Y',TO_NUMBER(hoi.org_information3),TO_NUMBER(NULL)),
          TO_NUMBER(hoi.org_information1)
   INTO l_operating_unit_id,
        l_ledger_id
   FROM hr_organization_information hoi,
        fnd_product_groups fpg
   WHERE hoi.organization_id = p_organization_id
   AND hoi.org_information_context = 'Accounting Information';

   l_stmt_num := 20;
   debug(l_stmt_num);
   -- Using the sales order line ID, find the invoicable line ID by calling OM's view/API
   OE_COGS_GRP.get_revenue_event_line(p_shippable_line_id => p_cogs_om_line_id,
                                      x_revenue_event_line_id => l_revenue_om_line_id,
                                      x_return_status => l_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data => l_msg_data);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.set_name('BOM', 'CST_NO_REVENUE_OM_LINE');
      FND_MESSAGE.set_token('COGS_LINE_ID', to_char(p_cogs_om_line_id));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         FND_MSG_PUB.ADD;
      END IF;

      debug('  CST_NO_REVENUE_OM_LINE for p_cogs_om_line_id : '||p_cogs_om_line_id);

      IF l_errorLog THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,G_LOG_HEAD||'.'||l_api_name||'.20',TRUE);
      END IF;
      raise program_exception;
   END IF;

   -- Insert a new row into CRCML - if it already has this row, the unique index will be violated (DUP_VAL_ON_INDEX)
   BEGIN
      l_stmt_num := 30;
      debug(l_stmt_num);
      INSERT INTO cst_revenue_cogs_match_lines (
               cogs_om_line_id,
               revenue_om_line_id,
               cogs_acct_id,
               deferred_cogs_acct_id,
               sales_order_issue_date,
               organization_id,
               inventory_item_id,
               operating_unit_id,
               ledger_id,
               cost_group_id,
               -- WHO COLUMNS
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
      VALUES (
               p_cogs_om_line_id,
               l_revenue_om_line_id,
               p_cogs_acct_id,
               p_def_cogs_acct_id,
               p_transaction_date,
               p_organization_id,
               p_item_id,
               l_operating_unit_id,
               l_ledger_id,
               p_cost_group_id,
               -- WHO COLUMNS
               sysdate,
               p_user_id,
               sysdate,
               p_user_id,
               p_login_id,
               p_request_id,
               p_pgm_app_id,
               p_pgm_id,
               sysdate
             );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         l_stmt_num := 40;
         -- The existing event is the parent; this new sales order issue
         -- becomes the child of this existing one.
         SELECT event_id
         INTO l_parent_cce_id
         FROM cst_cogs_events
         WHERE cogs_om_line_id = p_cogs_om_line_id
         AND parent_event_id = event_id
	 AND event_type = 1;
   END;

   l_stmt_num := 50;
   debug(l_stmt_num);
   -- Now update CRRL to mark any lines that may be unmatched due to this SO insert
   UPDATE cst_revenue_recognition_lines
   SET potentially_unmatched_flag = 'Y',
       last_update_date = sysdate,
       last_updated_by = p_user_id,
       last_update_login = p_login_id,
       request_id = p_request_id
   WHERE revenue_om_line_id = l_revenue_om_line_id;

   l_stmt_num := 60;
   debug(l_stmt_num);
   -- Insert the sales order issue as the first event in the linked list of COGS
   -- events with a recognition % of 0.
   INSERT INTO cst_cogs_events (
                  event_id,
                  cogs_om_line_id,
                  event_date,
                  mmt_transaction_id,
                  cogs_percentage,
                  prior_cogs_percentage,
                  event_type,
                  event_om_line_id,
                  event_quantity,
                  costed,
                  parent_event_id,
                  -- WHO COLUMNS
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date)
   VALUES (
                  cst_cogs_events_s.nextval,
                  p_cogs_om_line_id,
                  p_transaction_date,
                  p_mmt_txn_id,
                  0, -- COGS %
                  0, -- prior COGS %
                  SO_ISSUE,
                  p_cogs_om_line_id,
                  p_quantity,
                  'N',
                  nvl(l_parent_cce_id,cst_cogs_events_s.currval),
                  -- WHO COLUMNS
                  sysdate,
                  p_user_id,
                  sysdate,
                  p_user_id,
                  p_login_id,
                  p_request_id,
                  p_pgm_app_id,
                  p_pgm_id,
                  sysdate
          );

   l_stmt_num := 70;
   debug(l_stmt_num);
   -- Mark the cogs percentage column in the MMT transaction, thus indicating that it has been added
   -- to the revenue / COGS matching data model.
   UPDATE mtl_material_transactions
   SET cogs_recognition_percent = 0,
       last_update_date = sysdate,
       last_updated_by = p_user_id,
       last_update_login = p_login_id,
       request_id = p_request_id,
       program_application_id = p_pgm_app_id,
       program_id = p_pgm_id,
       program_update_date = sysdate
   WHERE transaction_id = p_mmt_txn_id;

-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;
   debug('   x_return_status : '||x_return_status);
   debug('Insert_OneSoIssue-');

EXCEPTION
   WHEN program_exception THEN
      ROLLBACK TO Insert_OneSoIssue_PVT; /*Bug 7384398*/
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
         ROLLBACK TO Insert_OneSoIssue_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Insert_OneSoIssue ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;
         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Insert_OneSoIssue:'||substrb(SQLERRM,1,250) );
END Insert_OneSoIssue;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_OneRmaReceipt   This procedure is very similar to the           --
--           Insert_RmaReceipts() procedure above.  It differs in that the --
--           above procedure handles bulk inserts and is called during one --
--           of the phases of the concurrent request, while this version   --
--           inserts one RMA receipt at a time into the data model, and is --
--           called from the Cost Processor.                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_RMA_OM_LINE_ID     Line_ID of the RMA from OM table                  --
--  P_COGS_OM_LINE_ID    Line_ID of the Original Sales Order Issue         --
--                       referrred to by this RMA Receipt.                 --
--  P_MMT_TXN_ID         Transaction ID from MMT table                     --
--  P_ORGANIZATION_ID    Organization ID                                   --
--  P_ITEM_ID            Inventory Item ID                                 --
--  P_TRANSACTION_DATE   Event Date                                        --
--  P_QUANTITY           Event Quantity                                    --
--  X_COGS_PERCENTAGE    Returns the % at which this RMA will be applied   --
--                       to COGS.                                          --
--                                                                         --
-- HISTORY:                                                                --
--    05/13/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_OneRmaReceipt(
                p_api_version           IN  NUMBER,
                p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_rma_om_line_id        IN  NUMBER,
                p_cogs_om_line_id       IN  NUMBER,
                p_mmt_txn_id            IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_transaction_date      IN  DATE,
                p_quantity              IN  NUMBER,
                x_event_id              OUT NOCOPY  NUMBER,
                x_cogs_percentage       OUT NOCOPY  NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Insert_OneRmaReceipt';
   l_api_message         VARCHAR2(1000);
   l_api_version         CONSTANT NUMBER        := 1.0;
   l_stmt_num            NUMBER                 := 0;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_parent_event_id         NUMBER;
   l_prior_event_id          NUMBER;
   l_cogs_percentage         NUMBER;
   l_prior_event_quantity    NUMBER;

   -- Inventory's API to insert MMT events returns these 3 parameters
   l_return_num              NUMBER;
   l_error_code              VARCHAR2(240);
   l_error_message           VARCHAR2(2000);
   program_exception         EXCEPTION;

   -- The following stores the source code from an OE system parameter.
   l_source_code             VARCHAR2(40);

BEGIN
   debug('Insert_OneRmaReceipt_PVT+');
   debug('  p_api_version      : '||p_api_version);
   debug('  p_rma_om_line_id   : '||p_rma_om_line_id);
   debug('  p_cogs_om_line_id  : '||p_cogs_om_line_id);
   debug('  p_mmt_txn_id       : '||p_mmt_txn_id);
   debug('  p_organization_id  : '||p_organization_id);
   debug('  p_item_id          : '||p_item_id);
   debug('  p_transaction_date : '||to_char(p_transaction_date,'MM-DD-YYYY'));
   debug('  p_quantity         : '||p_quantity);
-- Standard start of API savepoint
   SAVEPOINT Insert_OneRmaReceipt_PVT;

   l_stmt_num := 0;
   debug(l_stmt_num);
/*
   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'p_rma_om_line_id = '||p_rma_om_line_id||','||
        'p_cogs_om_line_id = '||p_cogs_om_line_id||','||
        'p_mmt_txn_id = '||p_mmt_txn_id||','||
        'p_organization_id = '||p_organization_id||','||
        'p_item_id = '||p_item_id||','||
        'p_transaction_date = '||to_char(p_transaction_date,'MM-DD-YYYY')||','||
        'p_quantity = '||p_quantity
      );
   END IF;
*/
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

   x_event_id := NULL;

   l_stmt_num := 10;
   debug(l_stmt_num);
   -- Retrieve basic information about the original sales order issue
   -- and the latest COGS recognition percentage for that sales order
   SELECT cce.parent_event_id prior_event_id,
          cce.cogs_percentage,
          sum(cce.event_quantity) prior_event_quantity
   INTO  l_prior_event_id,
         l_cogs_percentage,
         l_prior_event_quantity
   FROM cst_cogs_events cce
   WHERE p_cogs_om_line_id = cce.cogs_om_line_id
   AND cce.event_date <= p_transaction_date
   AND cce.parent_event_id NOT IN (SELECT prior_event_id
                                   FROM cst_cogs_events
                                   WHERE event_date <= p_transaction_date
                                   AND cogs_om_line_id <= p_cogs_om_line_id
                                   AND prior_event_id IS NOT NULL)
   GROUP BY cce.parent_event_id,
            cce.cogs_percentage;

   /* For an RMA Receipt, insert 2 rows in cce - one goes in
    * the string of events and the other is the quantity adjustment
    * to that parent event.
    */

   l_stmt_num := 20;
   debug(l_stmt_num);
   INSERT INTO cst_cogs_events (
            event_id,
            cogs_om_line_id,
            event_date,
            mmt_transaction_id,
            cogs_percentage,
            prior_cogs_percentage,
            prior_event_id,
            event_type,
            event_om_line_id,
            event_quantity,
            costed,
            parent_event_id,
            -- WHO COLUMNS
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date)
   VALUES ( cst_cogs_events_s.nextval,
            p_cogs_om_line_id,
            p_transaction_date,
            NULL, -- Quantity Placeholder event - no corresponding MMT txn
            l_cogs_percentage,
            l_cogs_percentage,
            l_prior_event_id,
            RMA_RECEIPT_PLACEHOLDER,
            p_rma_om_line_id,
            l_prior_event_quantity,
            NULL, -- RMA quantity placeholders are not costed
            cst_cogs_events_s.currval,
            -- WHO COLUMNS
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_login_id,
            p_request_id,
            p_pgm_app_id,
            p_pgm_id,
            sysdate)
   RETURNING event_id INTO l_parent_event_id;

   l_stmt_num := 30;
   debug(l_stmt_num);
   -- Now insert the actual RMA event
   INSERT INTO cst_cogs_events (
            event_id,
            cogs_om_line_id,
            event_date,
            mmt_transaction_id,
            cogs_percentage,
            prior_cogs_percentage,
            prior_event_id,
            event_type,
            event_om_line_id,
            event_quantity,
            costed,
            parent_event_id,
            -- WHO COLUMNS
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date)
   VALUES ( cst_cogs_events_s.nextval,
            p_cogs_om_line_id,
            p_transaction_date,
            p_mmt_txn_id,
            l_cogs_percentage,
            l_cogs_percentage,
            NULL,
            RMA_RECEIPT,
            p_rma_om_line_id,
            p_quantity,
            'N',
            l_parent_event_id,
            -- WHO COLUMNS
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_login_id,
            p_request_id,
            p_pgm_app_id,
            p_pgm_id,
            sysdate)
   RETURNING event_id INTO x_event_id;

   -- Mark the cogs percentage column in the MMT transaction, thus indicating that it has been added
   -- to the revenue / COGS matching data model.
   l_stmt_num := 40;
   debug(l_stmt_num);
   UPDATE mtl_material_transactions
   SET cogs_recognition_percent = l_cogs_percentage,
       last_update_date = sysdate,
       last_updated_by = p_user_id,
       last_update_login = p_login_id,
       request_id = p_request_id
   WHERE transaction_id = p_mmt_txn_id;

   /* If there are events after this RMA (that is, if it's backdated)
    * adjust the quantity for each of these events by either updating
    * CCE / MMT directly if the parent is uncosted, or inserting new
    * events in CCE and MMT in the case that the parent is costed.
    */

   -- First insert this new event into the linked list by setting the prior event ID of the
   -- next event to this new one.
   l_stmt_num := 50;
   debug(l_stmt_num);
   UPDATE cst_cogs_events
   SET PRIOR_EVENT_ID = l_parent_event_id,
       last_update_date = sysdate,
       last_updated_by = p_user_id,
       last_update_login = p_login_id,
       request_id = p_request_id
   WHERE cogs_om_line_id = p_cogs_om_line_id
   AND   prior_event_id = l_prior_event_id
   AND   event_date > p_transaction_date;

   -- Now create quantity adjustment events for all future COGS Rec events
   -- This is a 2 step process, first insert into the global temp table
   l_stmt_num := 60;
   debug(l_stmt_num);
   INSERT INTO cst_cogs_qty_adj_events_temp (
                        adj_event_id,
                        adj_mmt_txn_id,
                        adj_cogs_om_line_id,
                        adj_rma_om_line_id,
                        adj_event_date,
                        adj_new_cogs_percentage,
                        adj_prior_cogs_percentage,
                        adj_event_quantity,
                        parent_event_id,
                        inventory_item_id,
                        primary_uom,
                        organization_id,
                        cost_group_id,
                        cogs_acct_id,
                        opm_org_flag,
                        acct_period_id
                        )
   SELECT cst_cogs_events_s.nextval,
          decode(event_type, COGS_RECOGNITION_EVENT, mtl_material_transactions_s.nextval,
                             COGS_REC_PERCENT_ADJUSTMENT, mtl_material_transactions_s.nextval,
                             NULL),
          cce.cogs_om_line_id,
          p_rma_om_line_id,
          cce.event_date,
          cogs_percentage, -- could also use cce.prior_cogs_percentage
          prior_cogs_percentage,
          p_quantity,
          cce.event_id,
          crcml.inventory_item_id,
          msi.primary_uom_code,
          crcml.organization_id,
          crcml.cost_group_id,
          crcml.cogs_acct_id,
          nvl(mp.process_enabled_flag,'N'),
          oap.acct_period_id
   FROM cst_cogs_events cce,
        cst_revenue_cogs_match_lines crcml,
        mtl_parameters mp,
        org_acct_periods oap,
        cst_acct_info_v caiv,
        mtl_system_items msi
   WHERE cce.cogs_om_line_id = p_cogs_om_line_id
   AND   cce.event_date > p_transaction_date
   AND   cce.event_id = cce.parent_event_id
   AND   cce.cogs_om_line_id = crcml.cogs_om_line_id
   AND   crcml.pac_cost_type_id IS NULL
   AND   crcml.organization_id = mp.organization_id
   AND   crcml.organization_id = msi.organization_id
   AND   crcml.inventory_item_id = msi.inventory_item_id
   AND   crcml.organization_id = oap.organization_id
   AND   crcml.organization_id = caiv.organization_id
   AND   inv_le_timezone_pub.get_le_day_time_for_ou(cce.event_date, caiv.operating_unit)
         BETWEEN oap.period_start_date AND oap.schedule_close_date+.99999;

   -- Then insert from the global temp table into CCE
   l_stmt_num := 70;
   debug(l_stmt_num);
   INSERT INTO cst_cogs_events (
             event_id,
             cogs_om_line_id,
             event_date,
             mmt_transaction_id,
             cogs_percentage,
             prior_cogs_percentage,
             prior_event_id,
             event_type,
             event_om_line_id,
             event_quantity,
             costed,
             parent_event_id,
             -- WHO COLUMNS
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date)
   SELECT adj_event_id,
          adj_cogs_om_line_id,
          adj_event_date,
          adj_mmt_txn_id,
          adj_new_cogs_percentage,
          adj_prior_cogs_percentage,
          NULL,
          COGS_REC_QTY_ADJUSTMENT,
          adj_rma_om_line_id,
          adj_event_quantity,
          decode(adj_mmt_txn_id, NULL, NULL, 'N'),
          parent_event_id,
          -- WHO COLUMNS
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          p_login_id,
          p_request_id,
          p_pgm_app_id,
          p_pgm_id,
          sysdate
   FROM cst_cogs_qty_adj_events_temp;

   -- Get the source code from the OE profile system parameter.
   -- It can be overridden by the user but most likely uses the default
   -- called 'ORDER ENTRY' and will most likely never change.
   l_stmt_num := 80;
   debug(l_stmt_num);
   l_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE'); -- borrowed from OEXVSCHB.pls

   debug('  l_source_code : '||l_source_code);
   -- Insert MMT event here (from one global temp table to another)
   l_stmt_num := 90;
   debug(l_stmt_num);

   INSERT INTO mtl_cogs_recognition_temp (
                     TRANSACTION_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     COST_GROUP_ID,
                     TRANSACTION_TYPE_ID,
                     TRANSACTION_ACTION_ID,
                     TRANSACTION_SOURCE_TYPE_ID,
                     TRANSACTION_SOURCE_ID,
                     TRANSACTION_QUANTITY,
                     TRANSACTION_UOM,
                     PRIMARY_QUANTITY,
                     TRANSACTION_DATE,
                     ACCT_PERIOD_ID,
                     DISTRIBUTION_ACCOUNT_ID,
                     COSTED_FLAG,
                     OPM_COSTED_FLAG,
                     ACTUAL_COST,
                     TRANSACTION_COST,
                     PRIOR_COST,
                     NEW_COST,
                     TRX_SOURCE_LINE_ID,
                     RMA_LINE_ID,
                     LOGICAL_TRANSACTION,
                     COGS_RECOGNITION_PERCENT)
   SELECT
                     ccqa.adj_mmt_txn_id,
                     sysdate,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     ccqa.inventory_item_id,
                     ccqa.organization_id,
                     ccqa.cost_group_id,
                     10008,
                     36,
                     2,
                     mso.sales_order_id,
                     ccqa.adj_event_quantity,
                     ccqa.primary_uom, -- Txn UOM
                     ccqa.adj_event_quantity,
                     ccqa.adj_event_date,
                     ccqa.acct_period_id,
                     ccqa.cogs_acct_id,
                     decode(ccqa.opm_org_flag, 'N', 'N', NULL),
                     decode(ccqa.opm_org_flag, 'Y', 'N', NULL),
                     NULL, -- Actual Cost
                     NULL, -- Txn Cost
                     NULL, -- Prior Cost
                     NULL, -- New Cost
                     ccqa.adj_cogs_om_line_id,
                     ccqa.adj_rma_om_line_id, -- RMA Line ID
                     1, -- Logical Txn
                     ccqa.adj_new_cogs_percentage
   FROM  cst_cogs_qty_adj_events_temp ccqa,
         mtl_sales_orders mso,
         oe_order_lines_all ool,
         oe_order_headers_all ooh,
         oe_transaction_types_tl ott
   WHERE ool.line_id = ccqa.adj_cogs_om_line_id
   AND   ool.header_id = ooh.header_id
   AND   TO_CHAR(ooh.order_number) = mso.segment1
   AND   ooh.order_type_id = ott.transaction_type_id
   AND   ott.name = mso.segment2
   AND   ott.language = (SELECT language_code
                         FROM   fnd_languages
                         WHERE  installed_flag = 'B')
   AND   mso.segment3 = l_source_code
  --{BUG#6909721
  -- Ensure the place holder COGS event is not inserted in MMT as not effect on Cost and Accounting
   AND   ccqa.adj_mmt_txn_id IS NOT NULL;
  --}

   -- Now insert into MMT by calling INV API
   l_stmt_num := 100;
   debug(l_stmt_num);

   INV_LOGICAL_TRANSACTIONS_PUB.create_cogs_recognition(x_return_status => l_return_num,
                                                        x_error_code    => l_error_code,
                                                        x_error_message => l_error_message);

   IF (l_return_num <> 0) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.set_name('BOM', 'CST_FAILED_COGSREC_MMT_INSERT');
      FND_MESSAGE.set_token('ERROR_CODE', l_error_code);
      FND_MESSAGE.set_token('ERROR_MESSAGE',substr(l_error_message,1,500));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.ADD;
      END IF;
      IF l_errorLog THEN
         FND_LOG.message(FND_LOG.LEVEL_ERROR, l_module||'.'||to_char(l_stmt_num),TRUE);
      END IF;
      raise program_exception;
   END IF;

   -- Set the value of the return paramter
   x_cogs_percentage := l_cogs_percentage;

-- End API Body

   FND_MSG_PUB.count_and_get
    (  p_count  => x_msg_count
     , p_data   => x_msg_data
    );

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status||','||
        'x_event_id = '||x_event_id||','||
        'x_cogs_percentage = '||x_cogs_percentage
      );
   END IF;
   debug('   x_msg_count : '||x_msg_count);
   debug('   x_msg_data  : '||x_msg_data);
   debug('Insert_OneRmaReceipt-');
EXCEPTION
   WHEN program_exception THEN
      ROLLBACK TO Insert_OneRmaReceipt_PVT;
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
         ROLLBACK TO Insert_OneRmaReceipt_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Insert_OneRmaReceipt '||to_char(l_stmt_num)||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );
         FND_FILE.put_line(fnd_file.log, 'OTHERS EXCEPTION IN Insert_OneRmaReceipt:'||substrb(SQLERRM,1,250) );
END Insert_OneRmaReceipt;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Record_SoIssueCost                                                     --
--           This procedure is called by the distribution processors to    --
--           record the outgoing cost of the item at the time of the sales --
--           order issue.  The logic is standard across cost methods so    --
--           it can be called for all perpetual and PAC types.             --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order issue               --
--  P_PAC_COST_TYPE_ID   Periodic Cost Type, Leave NULL for perpetual      --
--  P_UNIT_MATERIAL_COST
--  P_UNIT_MOH_COST
--  P_UNIT_RESOURCE_COST
--  P_UNIT_OP_COST
--  P_UNIT_OVERHEAD_COST
--  P_UNIT_COST
--  P_TXN_QUANTITY
--                                                                         --
-- HISTORY:                                                                --
--    05/16/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Record_SoIssueCost(
                p_api_version           IN  NUMBER,
                p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_pac_cost_type_id      IN  NUMBER,
                p_unit_material_cost    IN  NUMBER,
                p_unit_moh_cost         IN  NUMBER,
                p_unit_resource_cost    IN  NUMBER,
                p_unit_op_cost          IN  NUMBER,
                p_unit_overhead_cost    IN  NUMBER,
                p_unit_cost             IN  NUMBER,
                p_txn_quantity          IN  NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Record_SoIssueCost';
   l_api_message         VARCHAR2(1000);
   l_stmt_num            NUMBER         := 0;
   l_api_version         CONSTANT NUMBER        := 1.0;

   l_return_status          VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Record_SoIssueCost_PVT;

   l_stmt_num := 0;

   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
       'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
       'p_api_version = '||p_api_version||','||
       'p_cogs_om_line_id = '||p_cogs_om_line_id||','||
       'p_pac_cost_type_id = '||p_pac_cost_type_id||','||
       'p_unit_material_cost = '||p_unit_material_cost||','||
       'p_unit_moh_cost = '||p_unit_moh_cost||','||
       'p_unit_resource_cost = '||p_unit_resource_cost||','||
       'p_unit_op_cost = '||p_unit_op_cost||','||
       'p_unit_overhead_cost = '||p_unit_overhead_cost||','||
       'p_unit_cost = '||p_unit_cost||','||
       'p_txn_quantity = '||p_txn_quantity
     );
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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   l_stmt_num := 10;
   -- It's possible that two or more MMT transactions get created for the same sales
   -- order line, that's why it is necessary to first check whether the quantity
   -- already has a value and, if so, perform an average of the new parameters
   -- and whatever is already in the table already for these columns.
   UPDATE cst_revenue_cogs_match_lines crcml
   SET unit_material_cost = decode(original_shipped_qty, NULL, p_unit_material_cost,
                                   ((unit_material_cost*original_shipped_qty) +
                                    (p_unit_material_cost*p_txn_quantity)) /
                                   (original_shipped_qty + p_txn_quantity)),
       unit_moh_cost = decode(original_shipped_qty, NULL, p_unit_moh_cost,
                              ((unit_moh_cost*original_shipped_qty) +
                               (p_unit_moh_cost*p_txn_quantity)) /
                              (original_shipped_qty + p_txn_quantity)),
       unit_resource_cost = decode(original_shipped_qty, NULL, p_unit_resource_cost,
                                   ((unit_resource_cost*original_shipped_qty) +
                                    (p_unit_resource_cost*p_txn_quantity)) /
                                   (original_shipped_qty + p_txn_quantity)),
       unit_op_cost = decode(original_shipped_qty, NULL, p_unit_op_cost,
                             ((unit_op_cost*original_shipped_qty) +
                              (p_unit_op_cost*p_txn_quantity)) /
                             (original_shipped_qty + p_txn_quantity)),
       unit_overhead_cost = decode(original_shipped_qty, NULL, p_unit_overhead_cost,
                                   ((unit_overhead_cost*original_shipped_qty) +
                                    (p_unit_overhead_cost*p_txn_quantity)) /
                                   (original_shipped_qty + p_txn_quantity)),
       original_shipped_qty = nvl(original_shipped_qty,0) + p_txn_quantity,
       unit_cost = decode(original_shipped_qty, NULL, p_unit_cost,
                              ((unit_cost*original_shipped_qty) +
                               (p_unit_cost*p_txn_quantity)) /
                              (original_shipped_qty + p_txn_quantity)),
       last_update_date = sysdate,
       last_updated_by = p_user_id,
       last_update_login = p_login_id,
       request_id = p_request_id,
       program_application_id = p_pgm_app_id,
       program_id = p_pgm_id,
       program_update_date = sysdate
   WHERE crcml.cogs_om_line_id = p_cogs_om_line_id
   AND   nvl(pac_cost_type_id,0) = nvl(p_pac_cost_type_id,0);

-- End API Body

   FND_MSG_PUB.count_and_get
     (  p_count  => x_msg_count
      , p_data   => x_msg_data
      , p_encoded => FND_API.g_false
     );

   x_return_status := l_return_status;

   IF l_proclog THEN
      fnd_log.string(fnd_log.level_procedure,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;
EXCEPTION

   WHEN OTHERS THEN
         ROLLBACK TO Record_SoIssueCost_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Record_SoIssueCost '||to_char(l_stmt_num)||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
            , p_encoded => FND_API.g_false
           );

END Record_SoIssueCost;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_RmaReceipt                                                     --
--           This procedure is called by the distribution processors for   --
--           all perpetual cost methods to create the accounting entries   --
--           for RMAs that are linked to forward flow sales orders with    --
--           COGS deferral.                                                --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_RMA_OM_LINE_ID     OM Line ID of the RMA Receipt                     --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order Issue, not the RMA  --
--  P_COST_TYPE_ID       Cost Type if Periodic, Cost Method if perpetual   --
--  P_TXN_QUANTITY       RMA Receipt quantity                              --
--  P_COGS_PERCENTAGE    Latest COGS Percentage reported for this OM line  --
--                                                                         --
-- HISTORY:                                                                --
--    05/16/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Process_RmaReceipt(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_rma_om_line_id        IN  NUMBER,
                p_cogs_om_line_id       IN  NUMBER,
                p_cost_type_id          IN  NUMBER,
                p_txn_quantity          IN  NUMBER,
                p_cogs_percentage       IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_transaction_id        IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_sob_id                IN  NUMBER,
                p_txn_date              IN  DATE,
                p_txn_src_id            IN  NUMBER,
                p_src_type_id           IN  NUMBER,
                p_pri_curr              IN  VARCHAR2,
                p_alt_curr              IN  VARCHAR2,
                p_conv_date             IN  DATE,
                p_conv_rate             IN  NUMBER,
                p_conv_type             IN  VARCHAR2,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_req_id                IN  NUMBER,
                p_prg_appl_id           IN  NUMBER,
                p_prg_id                IN  NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Process_RmaReceipt';
   l_api_message         VARCHAR2(1000);
   l_stmt_num            NUMBER         := 0;
   l_return_status       VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
   l_msg_count           NUMBER             := 0;
   l_msg_data            VARCHAR2(8000)     := '';

   l_elemental_cost      number_table;
   l_unit_cost           NUMBER;
   l_def_cogs_acct_id    NUMBER;
   l_cogs_acct_id        NUMBER;

   l_cogs_percentage     NUMBER;
   l_cogs_credit_amount  NUMBER;
   l_dcogs_credit_amount NUMBER;

   l_rma_cce_id          NUMBER := NULL;

   l_err_num             NUMBER;
   l_err_code            VARCHAR2(240);
   l_err_msg             VARCHAR2(240);

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
   program_exception     EXCEPTION;

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Process_RmaReceipt_PVT;

   l_stmt_num := 0;

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_rma_om_line_id = '||p_rma_om_line_id||','||
        'p_cogs_om_line_id = '||p_cogs_om_line_id||','||
        'p_cost_type_id = '||p_cost_type_id||','||
        'p_txn_quantity = '||p_txn_quantity||','||
        'p_cogs_percentage = '||p_cogs_percentage||','||
        'p_organization_id = '||p_organization_id||','||
        'p_transaction_id = '||p_transaction_id||','||
        'p_item_id = '||p_item_id||','||
        'p_sob_id = '||p_sob_id||','||
        'p_txn_date = '||to_char(p_txn_date,'MM-DD-YYYY')||','||
        'p_txn_src_id = '||p_txn_src_id||','||
        'p_src_type_id = '||p_src_type_id||','||
        'p_pri_curr = '||p_pri_curr||','||
        'p_alt_curr = '||p_alt_curr||','||
        'p_conv_date = '||to_char(p_conv_date,'MM-DD-YYYY')||','||
        'p_conv_rate = '||p_conv_rate||','||
        'p_conv_type = '||p_conv_type
      );
   END IF;

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   -- Initialize COGS percentage to passed value
   l_cogs_percentage := p_cogs_percentage;

   l_stmt_num := 10;
   IF (l_cogs_percentage IS NULL) THEN
   /* Insert the RMA Receipt into the Revenue / COGS Matching data model *
    * retrieving the current cogs percentage in the process.             */

      Insert_OneRmaReceipt(
                p_api_version      => 1,
                p_user_id          => p_user_id,
                p_login_id         => p_login_id,
                p_request_id       => p_req_id,
                p_pgm_app_id       => p_prg_appl_id,
                p_pgm_id           => p_prg_id,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_rma_om_line_id   => p_rma_om_line_id,
                p_cogs_om_line_id  => p_cogs_om_line_id,
                p_mmt_txn_id       => p_transaction_id,
                p_organization_id  => p_organization_id,
                p_item_id          => p_item_id,
                p_transaction_date => p_txn_date,
                p_quantity         => p_txn_quantity,
                x_event_id         => l_rma_cce_id,
                x_cogs_percentage  => l_cogs_percentage
                );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         FND_MESSAGE.set_name('BOM', 'CST_FAILED_DEFCOGS_RMA_INSERT');
         FND_MESSAGE.set_token('COGS_OM_LINE', to_char(p_cogs_om_line_id));
         FND_MESSAGE.set_token('MMT_TXN_ID',to_char(p_transaction_id));
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.ADD;
         END IF;
         IF l_errorLog THEN
            FND_LOG.message(FND_LOG.LEVEL_ERROR, l_module||'.10',TRUE);
         END IF;
         raise program_exception;
      END IF;

   END IF;

   l_stmt_num := 20;
   /* Get the unit elemental costs and accounts for this sales order line ID */
   SELECT unit_material_cost,
          unit_moh_cost,
          unit_resource_cost,
          unit_op_cost,
          unit_overhead_cost,
          unit_cost,
          deferred_cogs_acct_id,
          cogs_acct_id
   INTO l_elemental_cost(1),
        l_elemental_cost(2),
        l_elemental_cost(3),
        l_elemental_cost(4),
        l_elemental_cost(5),
        l_unit_cost,
        l_def_cogs_acct_id,
        l_cogs_acct_id
   FROM cst_revenue_cogs_match_lines crcml
   WHERE cogs_om_line_id = p_cogs_om_line_id
   AND   pac_cost_type_id IS NULL;

   IF l_stmtLog THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit Material Cost = '||to_char(l_elemental_cost(1)));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit MOH Cost = '||to_char(l_elemental_cost(2)));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit Resource Cost = '||to_char(l_elemental_cost(3)));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit OSP Cost = '||to_char(l_elemental_cost(4)));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit OVHD Cost = '||to_char(l_elemental_cost(5)));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Unit Cost = '||to_char(l_unit_cost));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','p_txn_quantity = '||to_char(p_txn_quantity));
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','l_cogs_percentage = '||to_char(l_cogs_percentage));
   END IF;

   FOR i IN 1..5 LOOP

   /* Bug# 9499282 */
   IF l_elemental_cost(i) IS NOT NULL THEN

      l_stmt_num := 40;
      l_cogs_credit_amount := l_elemental_cost(i) * -1 * p_txn_quantity * l_cogs_percentage;
      l_dcogs_credit_amount := (l_elemental_cost(i) * -1 * p_txn_quantity) - l_cogs_credit_amount;

      IF l_stmtLog THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.40','Cost Element '||to_char(i)||' COGS Credit Amount = '||to_char(l_cogs_credit_amount));
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.40','Cost Element '||to_char(i)||' Deferred COGS Credit Amount = '||to_char(l_dcogs_credit_amount));
      END IF;

      IF (l_cogs_credit_amount <> 0 OR l_cogs_percentage > 0) THEN
         l_stmt_num := 50;
         -- Create COGS distribution
         CSTPACDP.insert_account(p_organization_id, p_transaction_id, p_item_id, -1 * l_cogs_credit_amount,
                                 p_txn_quantity, l_cogs_acct_id, p_sob_id, COGS_LINE_TYPE,
                                 i, NULL,
                                 p_txn_date, p_txn_src_id, p_src_type_id,
                                 p_pri_curr, p_alt_curr, p_conv_date, p_conv_rate, p_conv_type,
                                 1,p_user_id, p_login_id, p_req_id, p_prg_appl_id,p_prg_id,
                                 l_err_num, l_err_code, l_err_msg);
      END IF;

      IF (l_dcogs_credit_amount <> 0 OR l_cogs_percentage < 1) THEN
         l_stmt_num := 60;

         CSTPACDP.insert_account(p_organization_id, p_transaction_id, p_item_id, -1 * l_dcogs_credit_amount,
                                 p_txn_quantity, l_def_cogs_acct_id, p_sob_id, DEF_COGS_LINE_TYPE,
                                 i, NULL,
                                 p_txn_date, p_txn_src_id, p_src_type_id,
                                 p_pri_curr, p_alt_curr, p_conv_date, p_conv_rate, p_conv_type,
                                 1,p_user_id, p_login_id, p_req_id, p_prg_appl_id,p_prg_id,
                                 l_err_num, l_err_code, l_err_msg);
      END IF;
    /* Bug# 9499282 */
    END IF; -- End of l_elemental_cost(i)
   END LOOP;

   l_stmt_num := 70;
   -- Mark the RMA event in CCE as costed
   UPDATE cst_cogs_events
   SET costed = NULL
   WHERE mmt_transaction_id = p_transaction_id;

-- End API Body

   FND_MSG_PUB.count_and_get
     (  p_count  => x_msg_count
      , p_data   => x_msg_data
      , p_encoded => FND_API.g_false
     );

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

EXCEPTION

   WHEN program_exception THEN
         ROLLBACK TO Process_RmaReceipt_PVT;
         x_return_status := fnd_api.g_ret_sts_error ;

         FND_MESSAGE.set_name('BOM', 'CST_PLSQL_ERROR');
         FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
         FND_MESSAGE.set_token('PROCEDURE',l_api_name);
         FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            FND_MSG_PUB.ADD;
         END IF;

         IF l_errorLog THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,l_module||'.'||l_stmt_num,TRUE);
         END IF;

         FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count,
            p_data   => x_msg_data,
            p_encoded => FND_API.g_false
         );

   WHEN OTHERS THEN
         ROLLBACK TO Process_RmaReceipt_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,l_module||'.'||l_stmt_num
                ,'Process_RmaReceipt '||to_char(l_stmt_num)||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
            , p_encoded => FND_API.g_false
           );

END Process_RmaReceipt;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_CogsRecognitionTxn                                             --
--           This procedure is called by the distribution processors for   --
--           all perpetual cost methods to create the accounting entries   --
--           for COGS Recognition Events.                                  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order issue               --
--  All other parameters are pretty standard for Cost Processing           --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Process_CogsRecognitionTxn(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_transaction_id        IN  NUMBER,
                p_txn_quantity          IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_sob_id                IN  NUMBER,
                p_txn_date              IN  DATE,
                p_txn_src_id            IN  NUMBER,
                p_src_type_id           IN  NUMBER,
                p_pri_curr              IN  VARCHAR2,
                p_alt_curr              IN  VARCHAR2,
                p_conv_date             IN  DATE,
                p_conv_rate             IN  NUMBER,
                p_conv_type             IN  VARCHAR2,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_req_id                IN  NUMBER,
                p_prg_appl_id           IN  NUMBER,
                p_prg_id                IN  NUMBER
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Process_CogsRecognitionTxn';
   l_api_message         VARCHAR2(1000);
   l_stmt_num            NUMBER         := 0;
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_new_percentage      NUMBER;
   l_prior_percentage    NUMBER;

   l_elemental_cost      number_table;
   l_def_cogs_acct_id    NUMBER;
   l_cogs_acct_id        NUMBER;

   l_adjustment_amount   NUMBER;

   l_err_num             NUMBER;
   l_err_code            VARCHAR2(240);
   l_err_msg             VARCHAR2(240);

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Process_CogsRecognitionTxn_PVT;

   l_stmt_num := 0;

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_cogs_om_line_id = '||p_cogs_om_line_id||','||
        'p_transaction_id = '||p_transaction_id||','||
        'p_txn_quantity = '||p_txn_quantity||','||
        'p_organization_id = '||p_organization_id||','||
        'p_item_id = '||p_item_id||','||
        'p_sob_id = '||p_sob_id||','||
        'p_txn_date = '||to_char(p_txn_date,'MM-DD-YYYY')||','||
        'p_txn_src_id = '||p_txn_src_id||','||
        'p_src_type_id = '||p_src_type_id||','||
        'p_pri_curr = '||p_pri_curr||','||
        'p_alt_curr = '||p_alt_curr||','||
        'p_conv_date = '||to_char(p_conv_date,'MM-DD-YYYY')||','||
        'p_conv_rate = '||p_conv_rate||','||
        'p_conv_type = '||p_conv_type
      );
   END IF;

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   -- Retrieve the COGS percentage and prior COGS percentage for this
   -- event while marking it as costed
   l_stmt_num := 10;
   UPDATE cst_cogs_events
   SET  costed = NULL
   WHERE mmt_transaction_id = p_transaction_id
   RETURNING cogs_percentage,
             prior_cogs_percentage
   INTO l_new_percentage,
        l_prior_percentage;


   -- Need the [elemental] unit costs, as well as the accounts from the
   -- original sales order to make the COGS adjustment
   l_stmt_num := 20;
   SELECT unit_material_cost,
          unit_moh_cost,
          unit_resource_cost,
          unit_op_cost,
          unit_overhead_cost,
          cogs_acct_id,
          deferred_cogs_acct_id
   INTO l_elemental_cost(1),
        l_elemental_cost(2),
        l_elemental_cost(3),
        l_elemental_cost(4),
        l_elemental_cost(5),
        l_cogs_acct_id,
        l_def_cogs_acct_id
   FROM cst_revenue_cogs_match_lines crcml
   WHERE cogs_om_line_id = p_cogs_om_line_id
   AND   pac_cost_type_id IS NULL;

   FOR i IN 1..5 LOOP
      l_stmt_num := 30;
      l_adjustment_amount := l_elemental_cost(i) * p_txn_quantity * (l_new_percentage - l_prior_percentage);

      IF (l_adjustment_amount <> 0) THEN
         -- Dr. COGS
         l_stmt_num := 40;
         CSTPACDP.insert_account(p_organization_id, p_transaction_id, p_item_id, l_adjustment_amount,
                                 p_txn_quantity, l_cogs_acct_id, p_sob_id, COGS_LINE_TYPE,
                                 i, NULL,
                                 p_txn_date, p_txn_src_id, p_src_type_id,
                                 p_pri_curr, p_alt_curr, p_conv_date, p_conv_rate, p_conv_type,
                                 1,p_user_id, p_login_id, p_req_id, p_prg_appl_id,p_prg_id,
                                 l_err_num, l_err_code, l_err_msg);

         l_stmt_num := 50;
         -- Cr. Deferred COGS
         CSTPACDP.insert_account(p_organization_id, p_transaction_id, p_item_id, -1 * l_adjustment_amount,
                                 -1 * p_txn_quantity, l_def_cogs_acct_id, p_sob_id, DEF_COGS_LINE_TYPE,
                                 i, NULL,
                                 p_txn_date, p_txn_src_id, p_src_type_id,
                                 p_pri_curr, p_alt_curr, p_conv_date, p_conv_rate, p_conv_type,
                                 1,p_user_id, p_login_id, p_req_id, p_prg_appl_id,p_prg_id,
                                 l_err_num, l_err_code, l_err_msg);
      END IF;

   END LOOP;


-- End API Body

   FND_MSG_PUB.count_and_get
     (  p_count  => x_msg_count
      , p_data   => x_msg_data
      , p_encoded => FND_API.g_false
     );

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

EXCEPTION
   WHEN OTHERS THEN
         ROLLBACK TO Process_CogsRecognitionTxn_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Process_CogsRecognitionTxn ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
            , p_encoded => FND_API.g_false
           );

END Process_CogsRecognitionTxn;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Cost_BulkCogsRecTxns                                                   --
--           This procedure is called in phase 4 of the concurrent request --
--           to create the accounting distributions for all of the COGS    --
--           Recognition Events that were created during this run of the   --
--           concurrent request.                                           --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--     Standard return status and Who columns                              --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Cost_BulkCogsRecTxns(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER,
                p_ledger_id       IN   NUMBER DEFAULT NULL   --BUG5726230
               ,p_neg_req_id      IN   NUMBER DEFAULT NULL   --BUG7387575
) IS

   l_api_name            CONSTANT VARCHAR2(30)  := 'Cost_BulkCogsRecTxns';
   l_api_message         VARCHAR2(1000);
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_return_status       VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num            NUMBER         := 0;

   CURSOR c_uncosted_cogs_events(p_sob_id  IN NUMBER) IS
      SELECT cce.cogs_om_line_id,
             cce.mmt_transaction_id,
             cce.cogs_percentage,
             cce.prior_cogs_percentage,
             cce.event_quantity,
            --{BUG#6980119
            -- cce.event_date,
             mmt.transaction_date,
            --}
             cce.event_id,
             cce.event_type,
             crcml.operating_unit_id,
             crcml.organization_id,
             crcml.cogs_acct_id,
             crcml.deferred_cogs_acct_id,
             crcml.inventory_item_id,
             crcml.unit_material_cost,
             crcml.unit_moh_cost,
             crcml.unit_resource_cost,
             crcml.unit_op_cost,
             crcml.unit_overhead_cost,
             crcml.unit_cost,
             sob.currency_code,
	     NVL(mmt.transaction_source_id, -1)
      FROM cst_cogs_events              cce,
           cst_revenue_cogs_match_lines crcml,
           mtl_parameters               mp,
           gl_sets_of_books             sob,
           mtl_material_transactions    mmt -- joining here to use the index on costed_flag
      WHERE
            cce.mmt_transaction_id         = mmt.transaction_id
      AND   mmt.costed_flag                = 'N'
      AND   mmt.transaction_action_id      = 36
      AND   mmt.transaction_source_type_id = 2
      ---------------------------------------
      -- When the Cogs Recognition program reaches this point the MMT for COGS Regnition are commited to the DB
      -- The COGS Recognition program is still running and the Cost Manager should not start as it is incompatible
      -- with the Cogs Recognition program. Hence normally the MMT will not be picked up by the Cost Worker
      -- But in the case this phase of insertion into MTA stops by user action or by env issue
      -- Next time the Cost Manager could have launch the cost worker and during its run the COGS regnition
      -- program can start causing the MMT being costed by both program
      -- We add the condition transaction_group_id IS NULL as this is the first action the Cost Manager does
      -- stamping the transaction_group_id before assigning the job to cost worker and goes back to pending
      -- If the MMT is selected by Cost Manager, COGS recognition program should not pick it up
      ---------------------------------------
      AND   mmt.transaction_group_id         IS NULL --BUG#6730436
      AND   cce.costed                        = 'N'
      AND   cce.event_type                   IN (COGS_RECOGNITION_EVENT,
                                                 COGS_REC_PERCENT_ADJUSTMENT,
                                                 COGS_REC_QTY_ADJUSTMENT)
      AND   crcml.cogs_om_line_id             = cce.cogs_om_line_id
      AND   crcml.pac_cost_type_id           IS NULL
      AND   crcml.ledger_id                   = p_sob_id
      AND   crcml.original_shipped_qty       IS NOT NULL -- indicator of whether the SO Issue was costed.
      AND   crcml.organization_id             = mp.organization_id
      AND   nvl(mp.process_enabled_flag, 'N') = 'N'  -- Cost only discrete orgs
      AND   crcml.ledger_id                   = sob.set_of_books_id
      AND   DECODE(p_neg_req_id,NULL,-99,p_neg_req_id)
	           =    DECODE(p_neg_req_id,NULL,-99,mmt.transaction_set_id); --BUG#7387575


    --{BUG#5726230
    CURSOR cu_ledger(p_ledger_id IN NUMBER) IS
    SELECT DISTINCT set_of_books_id
      FROM gl_sets_of_books
	 WHERE set_of_books_id = NVL(p_ledger_id, set_of_books_id);

   l_ledger_id_tab               number_table;
   l_sob                         NUMBER;
   --}
   l_cogs_om_line_id_tbl         number_table;
   l_mmt_txn_id_tbl              number_table;
   l_cogs_percentage_tbl         number_table;
   l_prior_percentage_tbl        number_table;
   l_event_quantity_tbl          number_table;
   l_event_date_tbl              date_table;
   l_event_id_tbl                number_table;
   l_event_type_tbl              number_table;
   l_ou_id_tbl                   number_table;
   l_organization_id_tbl         number_table;
   l_cogs_acct_id_tbl            number_table;
   l_def_cogs_acct_id_tbl        number_table;
   l_item_id_tbl                 number_table;
   l_e1_tbl                      number_table;
   l_e2_tbl                      number_table;
   l_e3_tbl                      number_table;
   l_e4_tbl                      number_table;
   l_e5_tbl                      number_table;
   l_unit_cost_tbl               number_table;
   l_currency_code_tbl           char15_table;
   l_ou_offset_tbl               number_table;
   l_le_date_tbl                 date_table;
   l_transaction_source_id       number_table;

   l_last_fetch                  BOOLEAN;
   end_of_program                EXCEPTION;
BEGIN

-- Standard start of API savepoint
   SAVEPOINT Cost_BulkCogsRecTxns_PVT;

   l_stmt_num := 0;

   IF l_procLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name
     );
   END IF;

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API Body
   -- Need to loop by set of books (ledger) because the call to the SLA
   -- API requires the ledger as an input parameter.  So we'll have to
   -- cost the events ledger by ledger.

   debug('  p_ledger_id :'||p_ledger_id);

   --{BUG5726230
   OPEN cu_ledger(p_ledger_id);
   FETCH cu_ledger BULK COLLECT INTO l_ledger_id_tab;
   CLOSE cu_ledger;

   IF l_ledger_id_tab.COUNT = 0 THEN
      RAISE end_of_program;
   END IF;

   <<ledger_loop>>
--   FOR l_sob_id IN (SELECT distinct set_of_books_id FROM gl_sets_of_books) LOOP
   FOR i IN l_ledger_id_tab.FIRST .. l_ledger_id_tab.LAST LOOP
   --}
      l_sob  := l_ledger_id_tab(i);
      debug(' processing for the ledger:'||l_sob);
      l_last_fetch := FALSE; -- initialize boolean variable

      OPEN c_uncosted_cogs_events(l_sob);  --(l_sob_id.set_of_books_id);

      <<uncosted_events_loop>>
      LOOP
         -- Get 1000 rows or less from the uncosted events cursor
         l_stmt_num := 10;
         FETCH c_uncosted_cogs_events BULK COLLECT INTO
            l_cogs_om_line_id_tbl,
            l_mmt_txn_id_tbl,
            l_cogs_percentage_tbl,
            l_prior_percentage_tbl,
            l_event_quantity_tbl,
            l_event_date_tbl,
            l_event_id_tbl,
            l_event_type_tbl,
            l_ou_id_tbl,
            l_organization_id_tbl,
            l_cogs_acct_id_tbl,
            l_def_cogs_acct_id_tbl,
            l_item_id_tbl,
            l_e1_tbl,
            l_e2_tbl,
            l_e3_tbl,
            l_e4_tbl,
            l_e5_tbl,
            l_unit_cost_tbl,
            l_currency_code_tbl,
            l_transaction_source_id
         LIMIT C_max_bulk_fetch_size;

         IF c_uncosted_cogs_events%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF (l_cogs_om_line_id_tbl.COUNT = 0 AND l_last_fetch) THEN
            CLOSE c_uncosted_cogs_events;
            EXIT uncosted_events_loop;
         END IF;

         -- Populate the legal entity dates table using each OU from above
         FOR i IN l_event_id_tbl.FIRST..l_event_id_tbl.LAST LOOP

           IF NOT l_ou_offset_tbl.EXISTS(l_ou_id_tbl(i)) THEN

             l_ou_offset_tbl(l_ou_id_tbl(i)) := INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(
                                                  SYSDATE, l_ou_id_tbl(i)) - SYSDATE;

           END IF;

           l_le_date_tbl(i) := l_event_date_tbl(i) + l_ou_offset_tbl(l_ou_id_tbl(i));

         END LOOP;

         l_stmt_num := 20;
         -- To help create debits and credits in bulk, insert 2 simple rows in
         -- cst_lists_temp with opposite signs
         -- These insertions are inside the loop because the commit at stmt 80
         -- blows these away.
         -- Keeping these inserts inside the loop (instead of doing once outside
         -- the loop) in case the definition of the cst_lists_temp table ever
         -- changes from session to txn based.  If the definition changes, there
         -- is no need to change it here since I'm deleting and reinserting each
         -- commit cycle.
         DELETE cst_lists_temp;

         INSERT INTO cst_lists_temp (list_id)
         VALUES (1); -- Dr.

         INSERT INTO cst_lists_temp (list_id)
         VALUES (-1); -- Cr.

         -- The following statement will create elemental distributions for all source rows returned
         -- by the above cursor.
         l_stmt_num := 30;
         FORALL i IN l_event_id_tbl.FIRST..l_event_id_tbl.LAST
            INSERT INTO mtl_transaction_accounts mta (
                         TRANSACTION_ID,
                         REFERENCE_ACCOUNT,
                         INVENTORY_ITEM_ID,
                         ORGANIZATION_ID,
                         TRANSACTION_DATE,
                         TRANSACTION_SOURCE_ID,
                         GL_BATCH_ID,
                         ACCOUNTING_LINE_TYPE,
                         BASE_TRANSACTION_VALUE,
                         CONTRA_SET_ID,
                         TRANSACTION_SOURCE_TYPE_ID,
                         PRIMARY_QUANTITY,
                         RATE_OR_AMOUNT,
                         BASIS_TYPE,
                         COST_ELEMENT_ID,
                         INV_SUB_LEDGER_ID,
                         -- WHO COLUMNS
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE)
            SELECT  l_mmt_txn_id_tbl(i),
                    decode(clt.list_id, 1, l_cogs_acct_id_tbl(i), -1, l_def_cogs_acct_id_tbl(i), NULL),
                    l_item_id_tbl(i),
                    l_organization_id_tbl(i),
                    l_event_date_tbl(i),
                    l_transaction_source_id(i), -- txn_source_id is not necessary, this column is NOT NULL by mistake
                    NULL, -- GL batch ID
                    decode(clt.list_id, 1, COGS_LINE_TYPE, -1, DEF_COGS_LINE_TYPE, NULL),
                    decode(fc.minimum_accountable_unit, NULL,
                       ROUND(clt.list_id * l_event_quantity_tbl(i) * (l_cogs_percentage_tbl(i) - l_prior_percentage_tbl(i)) *
                             decode(cce.cost_element_id, 1, l_e1_tbl(i),  2, l_e2_tbl(i),  3, l_e3_tbl(i),
                                                         4, l_e4_tbl(i),  5, l_e5_tbl(i),  0), fc.precision),
                       ROUND(clt.list_id * l_event_quantity_tbl(i) * (l_cogs_percentage_tbl(i) - l_prior_percentage_tbl(i)) *
                             decode(cce.cost_element_id, 1, l_e1_tbl(i),  2, l_e2_tbl(i),  3, l_e3_tbl(i),
                                                         4, l_e4_tbl(i),  5, l_e5_tbl(i),  0) / fc.minimum_accountable_unit)
                          * fc.minimum_accountable_unit),
                    1, -- contra set ID
                    2, -- transaction source type ID for COGS Recognition Events
                    clt.list_id * l_event_quantity_tbl(i),
                    clt.list_id * (l_cogs_percentage_tbl(i) - l_prior_percentage_tbl(i)) *
                                          decode(cce.cost_element_id,
                                                 1, l_e1_tbl(i),
                                                 2, l_e2_tbl(i),
                                                 3, l_e3_tbl(i),
                                                 4, l_e4_tbl(i),
                                                 5, l_e5_tbl(i),
                                                 0),
                    1, -- basis type
                    cce.cost_element_id,
                    cst_inv_sub_ledger_id_s.nextval,
                    -- WHO COLUMNS
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    p_login_id,
                    p_request_id,
                    p_pgm_app_id,
                    p_pgm_id,
                    sysdate
            FROM  cst_cost_elements cce,
                  cst_lists_temp    clt,
                  fnd_currencies    fc
            WHERE fc.currency_code         = l_currency_code_tbl(i)
            AND   l_event_quantity_tbl(i)  <> 0
            AND   l_cogs_percentage_tbl(i) <> l_prior_percentage_tbl(i)
            AND   nvl(decode(cce.cost_element_id,
                         1, l_e1_tbl(i),
                         2, l_e2_tbl(i),
                         3, l_e3_tbl(i),
                         4, l_e4_tbl(i),
                         5, l_e5_tbl(i),
                         0),0) <> 0;

         l_stmt_num := 40;
         -- Update the costed flag in cst_cogs_events
         FORALL i IN l_event_id_tbl.FIRST..l_event_id_tbl.LAST
            UPDATE cst_cogs_events
            SET costed            = NULL,
                last_update_date  = sysdate,
                last_updated_by   = p_user_id,
                last_update_login = p_login_id,
                request_id        = p_request_id
            WHERE event_id = l_event_id_tbl(i);

         l_stmt_num := 50;
         -- Update the costed flag in MMT
         FORALL i IN l_event_id_tbl.FIRST..l_event_id_tbl.LAST
            UPDATE mtl_material_transactions
            SET costed_flag            = NULL,
                last_update_date       = sysdate,
                last_updated_by        = p_user_id,
                last_update_login      = p_login_id,
                request_id             = p_request_id,
                program_application_id = p_pgm_app_id,
                program_id             = p_pgm_id,
                program_update_date    = sysdate
            WHERE transaction_id = l_mmt_txn_id_tbl(i);

         -- Pass events to SLA via a bulk insertion into their Global Temp Table

         l_stmt_num := 60;
         FORALL i IN l_event_id_tbl.FIRST..l_event_id_tbl.LAST
            INSERT INTO xla_events_int_gt
               (
                  application_id,
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
                  transaction_number
               )
            SELECT
                  707,
                  l_sob,  --l_sob_id.set_of_books_id,
                  'MTL_ACCOUNTING_EVENTS',
                  l_mmt_txn_id_tbl(i),
                  l_organization_id_tbl(i),
                  2, -- source type ID for sales order related txns
                  'SALES_ORDER',
                  decode(l_event_type_tbl(i), COGS_RECOGNITION_EVENT     , 'COGS_RECOGNITION',
                                              COGS_REC_PERCENT_ADJUSTMENT, 'COGS_RECOGNITION_ADJ',
                                              COGS_REC_QTY_ADJUSTMENT    , 'COGS_RECOGNITION_ADJ',
                                              NULL),
                  l_event_date_tbl(i),
                  XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
                  l_organization_id_tbl(i),
                  l_ou_id_tbl(i),
                  l_event_date_tbl(i),
                  l_le_date_tbl(i),
                  l_mmt_txn_id_tbl(i)
            FROM
                  mtl_parameters mp,
                  pjm_org_parameters pop
            WHERE mp.organization_id           = l_organization_id_tbl(i)
            AND   pop.organization_id (+)      = mp.organization_id
            AND   NVL(pop.pa_posting_flag,'N') <> 'Y'
            --{BUG#5207666
            AND   EXISTS (SELECT NULL
                            FROM mtl_transaction_accounts mta
                           WHERE mta.transaction_id = l_mmt_txn_id_tbl(i));
            --}

         l_stmt_num := 70;
         -- Call this API to instruct SLA to create these events from
         -- the data just populated in the global temp table.
         xla_events_pub_pkg.create_bulk_events(p_application_id        => 707,
                                               p_ledger_id             => l_sob,   --l_sob_id.set_of_books_id,
                                               p_entity_type_code      => 'MTL_ACCOUNTING_EVENTS',
                                               p_source_application_id => 401);

         l_stmt_num := 80;
         commit; -- commit the processing of 1000 input rows at a time
         SAVEPOINT Cost_BulkCogsRecTxns_PVT;

      END LOOP uncosted_events_loop;
   END LOOP ledger_loop;


-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

EXCEPTION
   WHEN end_of_program THEN
       ROLLBACK TO Cost_BulkCogsRecTxns_PVT;
       -- Let the program end normally
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       debug('EXCEPTION end_of_program - Cost_BulkCogsRecTxns '||l_stmt_num||' : no ledger found - p_ledger_id :'||p_ledger_id);

   WHEN OTHERS THEN
         ROLLBACK TO Cost_BulkCogsRecTxns_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Cost_BulkCogsRecTxns '||to_char(l_stmt_num)||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

END Cost_BulkCogsRecTxns;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_PacSoIssue    This is the PAC version of Insert_OneSoIssue().   --
--             It creates a new row in CRCML for the given OM Line ID and  --
--             PAC cost type ID.  The purpose is to record the SO issue    --
--             cost so that future related events (e.g. COGS Recognition)  --
--             can query this row and create accting with these amounts.   --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_TRANSACTION_ID     MMT Transaction ID                                --
--  P_LAYER_ID           PAC Cost Layer ID (CPIC, CPICD)                   --
--  P_COST_TYPE_ID       PAC Cost Type ID                                  --
--  P_COST_GROUP_ID      PAC Cost Group ID                                 --
--                                                                         --
-- HISTORY:                                                                --
--    06/27/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_PacSoIssue(
                p_api_version      IN  NUMBER,
                p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY NUMBER,
                x_msg_data         OUT NOCOPY VARCHAR2,
                p_transaction_id   IN  NUMBER,
                p_layer_id         IN  NUMBER,
                p_cost_type_id     IN  NUMBER,
                p_cost_group_id    IN  NUMBER,
                p_user_id          IN  NUMBER,
                p_login_id         IN  NUMBER,
                p_request_id       IN  NUMBER,
                p_pgm_app_id       IN  NUMBER,
                p_pgm_id           IN  NUMBER
) IS

   l_api_name               CONSTANT VARCHAR2(30)  := 'Insert_PacSoIssue';
   l_api_version            CONSTANT NUMBER        := 1.0;
   l_stmt_num               NUMBER                 := 0;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name||'.';
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_cogs_om_line_id   NUMBER;

   l_mat_cost NUMBER;
   l_moh_cost NUMBER;
   l_res_cost NUMBER;
   l_osp_cost NUMBER;
   l_ovh_cost NUMBER;
   l_tot_cost NUMBER;
   l_cost     NUMBER;/*bug 9146453*/

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Insert_PacSoIssue_PVT;

   l_stmt_num := 0;

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'p_transaction_id = '||p_transaction_id||','||
        'p_layer_id = '||p_layer_id||','||
        'p_cost_type_id = '||p_cost_type_id||','||
        'p_cost_group_id = '||p_cost_group_id
      );
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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body

   l_stmt_num := 10;
   -- Get the OM Line ID of this sales order issue transaction
   -- but only if the event was inserted into the COGS Events
   -- table.  For example, expense item shipments would not have
   -- been inserted into CCE, and should not be inserted into CRCML.
   BEGIN
     SELECT mmt.trx_source_line_id
     INTO   l_cogs_om_line_id
     FROM   mtl_material_transactions mmt,
            cst_cogs_events cce
     WHERE  mmt.transaction_id = p_transaction_id
     AND    cce.mmt_transaction_id = mmt.transaction_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     -- Either no records is supposed to be in CCE (undeferred SOs,
     -- SOs for expense items), or the transaction has not been
     -- costed in perpetual and the Collect Order Management Transaction
     -- request has not pick up the transaction. For the latter, it is
     -- assummed that PAC process will be run again for this transaction
     -- after the transaction is costed (and hence CCE is created) in
     -- the future before the PAC period is closed.
     IF l_stmtLog THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.10','No COGS Events found for transaction '||to_char(p_transaction_id));
     END IF;
   END;

   l_stmt_num := 20;

 /* Removed for Bug 9146453 */

 /* SELECT  NVL(SUM(DECODE(cost_element_id,1,NVL(actual_cost,0),0)),0),
           NVL(SUM(DECODE(cost_element_id,2,NVL(actual_cost,0),0)),0),
           NVL(SUM(DECODE(cost_element_id,3,NVL(actual_cost,0),0)),0),
           NVL(SUM(DECODE(cost_element_id,4,NVL(actual_cost,0),0)),0),
           NVL(SUM(DECODE(cost_element_id,5,NVL(actual_cost,0),0)),0)
   INTO    l_mat_cost,
           l_moh_cost,
           l_res_cost,
           l_osp_cost,
           l_ovh_cost
   FROM    mtl_pac_actual_cost_details
   WHERE   transaction_id=p_transaction_id
   AND     cost_type_id = p_cost_type_id; */

   /* Added for Bug 9146453 */
    FOR i IN 1..5 LOOP

      l_cost := NULL;

      SELECT  SUM(actual_cost)
      INTO    l_cost
      FROM    mtl_pac_actual_cost_details
      WHERE   transaction_id=p_transaction_id
      AND     cost_type_id = p_cost_type_id
      AND     cost_element_id = i;

      IF i = 1 THEN
	l_mat_cost := l_cost;
      ELSIF i = 2 THEN
	l_moh_cost := l_cost;
      ELSIF i = 3  THEN
	l_res_cost := l_cost;
      ELSIF i = 4  THEN
	l_osp_cost := l_cost;
      ELSIF i = 5  THEN
	l_ovh_cost := l_cost;
      END IF;

    END LOOP;

    /* Modified for Bug 9146453 */
    l_tot_cost := nvl(l_mat_cost,0) + nvl(l_moh_cost,0) + nvl(l_res_cost,0) + nvl(l_osp_cost,0) + nvl(l_ovh_cost,0);

   IF l_stmtLog THEN
     FND_LOG.string(
       FND_LOG.LEVEL_STATEMENT,
       l_module||'.20',
       'MAT:'||l_mat_cost||' MOH:'||l_moh_cost||' RES:'||l_res_cost||
       ' OSP:'||l_osp_cost||' OVH:'||l_ovh_cost
     );
   END IF;

   MERGE
   INTO   cst_revenue_cogs_match_lines crcml
   USING  (
            SELECT cogs_om_line_id,
                   p_cost_type_id pac_cost_type_id,
                   revenue_om_line_id,
                   deferred_cogs_acct_id,
                   cogs_acct_id,
                   organization_id,
                   inventory_item_id,
                   operating_unit_id,
                   ledger_id,
                   sales_order_issue_date,
                   original_shipped_qty
            FROM   cst_revenue_cogs_match_lines
            WHERE  cogs_om_line_id = l_cogs_om_line_id
            AND    pac_cost_type_id IS NULL
          ) X
   ON     (
                crcml.cogs_om_line_id = X.cogs_om_line_id
            AND crcml.pac_cost_type_id = X.pac_cost_type_id
          )
   WHEN MATCHED THEN
     UPDATE
     SET    unit_material_cost = l_mat_cost,       unit_moh_cost = l_moh_cost,
            unit_resource_cost = l_res_cost,       unit_op_cost = l_osp_cost,
            unit_overhead_cost = l_ovh_cost,       unit_cost = l_tot_cost,
            last_update_date = sysdate,            last_updated_by = p_user_id,
            last_update_login = p_login_id,        request_id = p_request_id,
            program_application_id = p_pgm_app_id, program_id = p_pgm_id,
            program_update_date = sysdate

   WHEN NOT MATCHED THEN
     INSERT (
              COGS_OM_LINE_ID,        PAC_COST_TYPE_ID,        REVENUE_OM_LINE_ID,
              DEFERRED_COGS_ACCT_ID,  COGS_ACCT_ID,            ORGANIZATION_ID,
              INVENTORY_ITEM_ID,      OPERATING_UNIT_ID,       COST_GROUP_ID,
              LEDGER_ID,              SALES_ORDER_ISSUE_DATE,  UNIT_MATERIAL_COST,
              UNIT_MOH_COST,          UNIT_RESOURCE_COST,      UNIT_OP_COST,
              UNIT_OVERHEAD_COST,     UNIT_COST,               ORIGINAL_SHIPPED_QTY,
              LAST_UPDATE_DATE,       LAST_UPDATED_BY,         CREATION_DATE,
              CREATED_BY,             LAST_UPDATE_LOGIN,       REQUEST_ID,
              PROGRAM_APPLICATION_ID, PROGRAM_ID,              PROGRAM_UPDATE_DATE
            )
     VALUES (
              X.cogs_om_line_id,      X.pac_cost_type_id,      X.revenue_om_line_id,
              X.deferred_cogs_acct_id,X.cogs_acct_id,          X.organization_id,
              X.inventory_item_id,    X.operating_unit_id,     p_cost_group_id,
              X.ledger_id,            X.sales_order_issue_date,l_mat_cost,
              l_moh_cost,             l_res_cost,              l_osp_cost,
              l_ovh_cost,             l_tot_cost,              X.original_shipped_qty,
              sysdate,                p_user_id,               sysdate,
              p_user_id,              p_login_id,              p_request_id,
              p_pgm_app_id,           p_pgm_id,                sysdate
            );

-- End API Body

   IF l_procLog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

   FND_MSG_PUB.count_and_get
   (  p_count  => x_msg_count
    , p_data   => x_msg_data
    , p_encoded => FND_API.g_false
   );



EXCEPTION

   WHEN OTHERS THEN
         ROLLBACK TO Insert_PacSoIssue_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Insert_PacSoIssue ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
            FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
            FND_MESSAGE.set_token('PROCEDURE',l_api_name);
            FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
            FND_MSG_PUB.ADD;
         END IF;

         FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
          , p_encoded => FND_API.g_false
         );

END Insert_PacSoIssue;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_PacRmaReceipt  The PAC equivalent of Process_OneRmaRecipt()    --
--            This procedure creates the distributions for RMAs that refer --
--            to an original sales order for which COGS was deferred.  It  --
--            creates credits to Deferred COGS and COGS as appropriate.    --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_AE_TXN_REC       Transaction Record used throughout PAC processor    --
--  P_AE_CURR_REC      Currency Record used throughout PAC processor       --
--  P_DR_FLAG          Debit = True / Credit = False                       --
--  P_COGS_OM_LINE_ID  OM Line ID of the sales order to which this RMA refers
--  L_AE_LINE_TBL      Table where the distributions are built             --
--                                                                         --
-- HISTORY:                                                                --
--    06/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_PacRmaReceipt(
                p_ae_txn_rec       IN  CSTPALTY.cst_ae_txn_rec_type,
                p_ae_curr_rec      IN  CSTPALTY.cst_ae_curr_rec_type,
                p_dr_flag          IN  BOOLEAN,
                p_cogs_om_line_id  IN  NUMBER,
                l_ae_line_tbl      IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
                x_ae_err_rec       OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
) IS

   l_api_name               CONSTANT VARCHAR2(30)  := 'Process_PacRmaReceipt';
   l_api_version            CONSTANT NUMBER        := 1.0;
   l_stmt_num               NUMBER                 := 0;
   process_error            EXCEPTION;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name||'.';
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_ae_line_rec             CSTPALTY.cst_ae_line_rec_type;
   l_err_rec                 CSTPALTY.cst_ae_err_rec_type;

   l_elemental_cost      number_table;
   l_def_cogs_acct_id    NUMBER;
   l_cogs_acct_id        NUMBER;

BEGIN

-- Standard start of API savepoint
   SAVEPOINT Process_PacRmaReceipt_PVT;

   l_stmt_num := 0;

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_cogs_om_line_id = '||p_cogs_om_line_id
      );
   END IF;

-- API Body

   l_stmt_num := 10;
   /* Get the unit elemental costs and accounts for this sales order line ID */
   SELECT unit_material_cost,
          unit_moh_cost,
          unit_resource_cost,
          unit_op_cost,
          unit_overhead_cost,
          deferred_cogs_acct_id,
          cogs_acct_id
   INTO l_elemental_cost(1),
        l_elemental_cost(2),
        l_elemental_cost(3),
        l_elemental_cost(4),
        l_elemental_cost(5),
        l_def_cogs_acct_id,
        l_cogs_acct_id
   FROM cst_revenue_cogs_match_lines crcml
   WHERE cogs_om_line_id = p_cogs_om_line_id
   AND   pac_cost_type_id = p_ae_txn_rec.cost_type_id;


   -- Create distributions for each cost element
   FOR i IN 1..5 LOOP

   /* Added for Bug 9146453 */
   IF l_elemental_cost(i) IS NOT NULL THEN

      -- COGS distribution = elemental cost * quantity * cogs percentage

       l_ae_line_rec.transaction_value := abs(l_elemental_cost(i) * p_ae_txn_rec.primary_quantity * Nvl(p_ae_txn_rec.cogs_percentage,0)); /* Modified for Bug 9146453 */

      IF l_stmtLog THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.40','Cost Element '||to_char(i)||' COGS Credit Amount = '||to_char(l_ae_line_rec.transaction_value));
      END IF;
	/* Bug# 9499282 */
      IF (l_ae_line_rec.transaction_value <> 0 OR Nvl(p_ae_txn_rec.cogs_percentage,0) > 0) THEN
         -- Create COGS distribution

         l_ae_line_rec.account := l_cogs_acct_id;
         l_ae_line_rec.resource_id := NULL;
         l_ae_line_rec.cost_element_id := i;
         l_ae_line_rec.ae_line_type := 35;

         CSTPAPBR.insert_account (p_ae_txn_rec,
                         p_ae_curr_rec,
                         p_dr_flag,
                         l_ae_line_rec,
                         l_ae_line_tbl,
                         l_err_rec);
         -- check error
         if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
            raise process_error;
         end if;

      END IF;

      -- Deferred COGS distribution = (elemental cost * quantity) - COGS distribution
      l_ae_line_rec.transaction_value := abs(l_elemental_cost(i) * p_ae_txn_rec.primary_quantity) - l_ae_line_rec.transaction_value;

      IF l_stmtLog THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.40','Cost Element '||to_char(i)||' Deferred COGS Credit Amount = '||to_char(l_ae_line_rec.transaction_value));
      END IF;

       /* Modified for Bug 9146453 */
       /* Bug# 9499282 */
        IF (l_ae_line_rec.transaction_value <> 0 OR Nvl(p_ae_txn_rec.cogs_percentage,0) < 1) THEN
         -- Create Deferred COGS distribution

         l_ae_line_rec.account := l_def_cogs_acct_id;
         l_ae_line_rec.resource_id := NULL;
         l_ae_line_rec.cost_element_id := i;
         l_ae_line_rec.ae_line_type := 36;

         CSTPAPBR.insert_account (p_ae_txn_rec,
                         p_ae_curr_rec,
                         p_dr_flag,
                         l_ae_line_rec,
                         l_ae_line_tbl,
                         l_err_rec);
         -- check error
         if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
            raise process_error;
         end if;

      END IF;
      END IF; --l_elemental_cost(i) IS NOT NULL

   END LOOP;

-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name
      );
   END IF;

EXCEPTION

  when process_error then
     ROLLBACK TO Process_PacRmaReceipt_PVT;
     x_ae_err_rec.l_err_num := l_err_rec.l_err_num;
     x_ae_err_rec.l_err_code := l_err_rec.l_err_code;
     x_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

     IF l_errorLog THEN
        FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Process_PacRmaReceipt ('||to_char(l_stmt_num)||') : '||substr(l_err_rec.l_err_msg,1,200));
     END IF;

  when others then
     ROLLBACK TO Process_PacRmaReceipt_PVT;
     x_ae_err_rec.l_err_num := SQLCODE;
     x_ae_err_rec.l_err_code := '';
     x_ae_err_rec.l_err_msg := 'CSTPAPBR.Process_PacRmaReceipt()' ||
                               to_char(l_stmt_num) || substr(SQLERRM,1,180);

     IF l_unexpLog THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Process_PacRmaReceipt ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,180));
     END IF;

END Process_PacRmaReceipt;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_PacCogsRecTxn  PAC equivalent of Process_CogsRecognitionTxn()  --
--            This procedure is called from the PAC distribution processor --
--            to create the accounting entries for COGS Recognition events --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_AE_TXN_REC       Transaction Record used throughout PAC processor    --
--  P_AE_CURR_REC      Currency Record used throughout PAC processor       --
--  L_AE_LINE_TBL      Table where the distributions are built             --
--                                                                         --
-- HISTORY:                                                                --
--    06/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_PacCogsRecTxn(
                p_ae_txn_rec       IN  CSTPALTY.cst_ae_txn_rec_type,
                p_ae_curr_rec      IN  CSTPALTY.cst_ae_curr_rec_type,
                l_ae_line_tbl      IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
                x_ae_err_rec       OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
) IS

   l_api_name               CONSTANT VARCHAR2(30)  := 'Process_PacCogsRecTxn';
   l_api_version            CONSTANT NUMBER        := 1.0;
   l_stmt_num               NUMBER                 := 0;
   process_error            EXCEPTION;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name||'.';
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

   l_ae_line_rec             CSTPALTY.cst_ae_line_rec_type;
   l_err_rec                 CSTPALTY.cst_ae_err_rec_type;
   l_dr_flag                 BOOLEAN;

   l_elemental_cost      number_table;
   l_def_cogs_acct_id    NUMBER;
   l_cogs_acct_id        NUMBER;
   l_new_percentage      NUMBER;
   l_prior_percentage    NUMBER;



BEGIN

-- Standard start of API savepoint
   SAVEPOINT Process_PacCogsRecTxn_PVT;

   l_stmt_num := 0;

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
        'Entering '||G_PKG_NAME||'.'||l_api_name
      );
   END IF;

-- API Body

   l_stmt_num := 10;
   -- Get the unit elemental costs and accounts for this sales order line ID
   SELECT unit_material_cost,
          unit_moh_cost,
          unit_resource_cost,
          unit_op_cost,
          unit_overhead_cost,
          deferred_cogs_acct_id,
          cogs_acct_id
   INTO l_elemental_cost(1),
        l_elemental_cost(2),
        l_elemental_cost(3),
        l_elemental_cost(4),
        l_elemental_cost(5),
        l_def_cogs_acct_id,
        l_cogs_acct_id
   FROM cst_revenue_cogs_match_lines crcml
   WHERE cogs_om_line_id = p_ae_txn_rec.om_line_id
   AND   pac_cost_type_id = p_ae_txn_rec.cost_type_id;

   l_stmt_num := 20;
   -- Get the COGS percentage and prior COGS percentage for this event
   SELECT cogs_percentage,
          prior_cogs_percentage
   INTO l_new_percentage,
        l_prior_percentage
   FROM cst_cogs_events
   WHERE mmt_transaction_id = p_ae_txn_rec.transaction_id;


   -- Loop for each cost element
   FOR i IN 1..5 LOOP
    /* Added Nvl for Bug 9146453 */
    l_ae_line_rec.transaction_value := Nvl(l_elemental_cost(i),0) * p_ae_txn_rec.primary_quantity * (l_new_percentage - l_prior_percentage);

      IF l_stmtLog THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.20','Cost Element '||to_char(i)||' COGS Adjustment Amount = '||to_char(l_ae_line_rec.transaction_value));
      END IF;

      IF (l_ae_line_rec.transaction_value <> 0) THEN
         -- Create COGS distribution (debit if percentage increase, credit otherwise)

         l_ae_line_rec.account := l_cogs_acct_id;
         l_ae_line_rec.resource_id := NULL;
         l_ae_line_rec.cost_element_id := i;
         l_ae_line_rec.ae_line_type := 35;

         l_dr_flag := (sign(l_ae_line_rec.transaction_value) > 0);
         l_ae_line_rec.transaction_value := abs(l_ae_line_rec.transaction_value);

         CSTPAPBR.insert_account (p_ae_txn_rec,
                         p_ae_curr_rec,
                         l_dr_flag,
                         l_ae_line_rec,
                         l_ae_line_tbl,
                         l_err_rec);
         -- check error
         if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
            raise process_error;
         end if;

         -- Create Deferred COGS distribution (credit if percentage increase, debit otherwise)

         l_ae_line_rec.account := l_def_cogs_acct_id;
         l_ae_line_rec.ae_line_type := 36;
         l_dr_flag := not l_dr_flag;

         CSTPAPBR.insert_account (p_ae_txn_rec,
                         p_ae_curr_rec,
                         l_dr_flag,
                         l_ae_line_rec,
                         l_ae_line_tbl,
                         l_err_rec);
         -- check error
         if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
            raise process_error;
         end if;

      END IF;

   END LOOP;


-- End API Body

   IF l_proclog THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name
      );
   END IF;


EXCEPTION

  when process_error then
     ROLLBACK TO Process_PacCogsRecTxn_PVT;
     x_ae_err_rec.l_err_num := l_err_rec.l_err_num;
     x_ae_err_rec.l_err_code := l_err_rec.l_err_code;
     x_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

     IF l_errorLog THEN
        FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Process_PacCogsRecTxn ('||to_char(l_stmt_num)||') : '||substr(l_err_rec.l_err_msg,1,200));
     END IF;

  when others then
     ROLLBACK TO Process_PacCogsRecTxn_PVT;
     x_ae_err_rec.l_err_num := SQLCODE;
     x_ae_err_rec.l_err_code := '';
     x_ae_err_rec.l_err_msg := 'CSTPAPBR.Process_PacCogsRecTxn(' ||
                               to_char(l_stmt_num)||') -' || substr(SQLERRM,1,180);

     IF l_unexpLog THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Process_PacCogsRecTxn ('||to_char(l_stmt_num)||') : '||substr(SQLERRM,1,180));
     END IF;

END Process_PacCogsRecTxn;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Print_MessageStack                                                     --
--           This procedure is called from Match_RevenueCogs() to spit out --
--           the contents of the message stack to the log file.            --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--     none                                                                --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
procedure Print_MessageStack IS
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(8000);
BEGIN
   FND_MSG_PUB.count_and_get
    ( p_count  => l_msg_count,
      p_data   => l_msg_data,
      p_encoded => FND_API.g_false
    );
   IF (l_msg_count > 1) THEN
      FOR i IN 1..l_msg_count LOOP
         l_msg_data := FND_MSG_PUB.get(i, FND_API.g_false);
         FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
      END LOOP;
   ELSIF (l_msg_count = 1) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
   END IF;

   -- Reinitialize the message list
   FND_MSG_PUB.initialize;

END Print_MessageStack;

 /*===========================================================================*/
 --      API name        : Generate_DefCOGSXml
 --      Type            : Private
 --      Function        : Generate XML Data for Deferred COGS Report
 --                        Report
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_cost_method           in number
 --          		 : p_ledger_id             in number     (Only used in perpetual)
 --          		 : p_pac_legal_entity      in number     (Only used in PAC)
 --                      : p_pac_cost_type         in number     (Only used in PAC)
 --          		 : p_pac_cost_group        in number     (Only used in PAC)
 --                      : p_period_name           in varchar2
 --                      : p_sales_order_date_low  in varchar2
 --                      : p_sales_order_date_high in varchar2
 --          		 : p_all_lines             in varchar2
 --                      : p_api_version           in number
 --
 --      out             :
 --                      : errcode                 OUT varchar2
 --                      : errno                   OUT number
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005    David Gottlieb  Created
 --      Notes           : This Procedure is called by the Deferred COGS Report
 --                        This is the wrapper procedure that calls the other
 --                        procedures to generate XML data according to report parameters.
 -- End of comments
 /*===========================================================================*/

 procedure Generate_DefCOGSXml (
   errcode			out nocopy	varchar2,
   err_code 			out nocopy	number,
   p_cost_method		in		number,
   p_ledger_id			in		number,
   p_pac_legal_entity		in		number,
   p_pac_cost_type		in		number,
   p_pac_cost_group		in		number,
   p_period_name 	  	in		varchar2,
   p_sales_order_date_low  	in		varchar2,
   p_sales_order_date_high 	in		varchar2,
   p_all_lines			in		varchar2,
   p_api_version      	     	in 		number) is

   l_operating_unit		number;
   l_sales_order_date_low	date;
   l_sales_order_date_high	date;
   l_qryCtx                     number;
   l_ref_cur                    sys_refcursor;
   l_xml_doc                    clob;
   l_amount                     number;
   l_offset                     number;
   l_buffer                     varchar2(32767);
   l_length                     number;

   l_api_name      		constant varchar2(100)   := 'Generate_DefCOGSXml';
   l_api_version   		constant number          := 1.0;

   l_return_status              varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(2000);
   l_stmt_num                   number;
   l_success                    boolean;

   l_full_name     		constant varchar2(2000)  := G_PKG_NAME || '.' || l_api_name;
   l_module        		constant varchar2(2000)  := 'cst.plsql.' || l_full_name;
   l_uLog          		constant boolean         := (fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND
                                                    fnd_log.test(fnd_log.LEVEL_UNEXPECTED, l_module);
   l_errorLog      		constant boolean         := l_uLog and (fnd_log.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog      		constant boolean         := l_errorLog and (fnd_log.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog          		constant boolean         := l_eventLog and (fnd_log.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   /*Bug 7305146*/
   l_encoding                   VARCHAR2(20);
   l_xml_header                 VARCHAR2(100);

 begin

   -- Initialize variables

   l_amount         := 16383;
   l_offset         := 1;
   l_return_status  := fnd_api.g_ret_sts_success;
   l_msg_count      := 0;
   if(p_cost_method = 1) then
     l_operating_unit := mo_global.get_current_org_id;
   else
     l_operating_unit := -1; /* Operating Unit not used in PAC */
   end if; /* p_cost_method = 1 */

   -- Write the module name and user parameters to fnd log file

   IF l_pLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
       'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
       'p_cost_method = '||p_cost_method||','||
       'p_ledger_id = '||p_ledger_id||','||
       'l_operating_unit ='||l_operating_unit||','||
       'p_pac_legal_entity = '||p_pac_legal_entity||','||
       'p_pac_cost_type = '||p_pac_cost_type||','||
       'p_pac_cost_group = '||p_pac_cost_group||','||
       'p_period_name = '||p_period_name||','||
       'p_sales_order_date_low = '||p_sales_order_date_low||','||
       'p_sales_order_date_high = '||p_sales_order_date_high||','||
       'p_all_lines = '||p_all_lines||','||
       'p_api_version = '||p_api_version
     );
   END IF;

   -- Initialze variables for storing XML Data

   dbms_lob.createtemporary(l_xml_doc, TRUE);

   /*Bug 7305146*/
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
   DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

   dbms_lob.writeappend (l_xml_doc, 8, '<REPORT>');

   -- Initialize message stack

   fnd_msg_pub.initialize;

   -- Standard call to get message count and if count is 1, get message info.

   fnd_msg_pub.Count_And_Get
   (       p_count    =>      l_msg_count,
           p_data     =>      l_msg_data
   );

   -- Standard call to check the API version

   if(not fnd_api.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)) then
     raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_stmt_num := 10;

   --set the date parameters if the user has not

   if(p_sales_order_date_low is not null) then
     l_sales_order_date_low := trunc(fnd_date.canonical_to_date(p_sales_order_date_low));
   else
     l_sales_order_date_low := sysdate - 7200;
   end if;

   if(p_sales_order_date_high is not null) then
     l_sales_order_date_high := trunc(fnd_date.canonical_to_date(p_sales_order_date_high));
   else
     l_sales_order_date_high := sysdate + 1;
   end if;

   /*========================================================================*/
   -- Call to Procedure Add Parameters. To Add user entered Parameters to
   -- XML data
   /*========================================================================*/

   Add_Parameters ( p_api_version           => 1.0,
                    p_init_msg_list         => fnd_api.G_FALSE,
                    p_validation_level      => fnd_api.G_VALID_LEVEL_FULL,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    i_cost_method           => p_cost_method,
                    i_operating_unit	    => l_operating_unit,
		    i_ledger_id	      	    => p_ledger_id,
		    i_pac_legal_entity      => p_pac_legal_entity,
   		    i_pac_cost_type         => p_pac_cost_type,
                    i_pac_cost_group	    => p_pac_cost_group,
                    i_period_name	    => p_period_name,
 		    i_sales_order_date_low  => p_sales_order_date_low,
		    i_sales_order_date_high => p_sales_order_date_high,
                    i_all_lines	      	    => p_all_lines,
                    x_xml_doc               => l_xml_doc);

   -- Standard call to check the return status from API called

   if(l_return_status <> fnd_api.G_RET_STS_SUCCESS) then
     raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   end if;


   l_stmt_num := 20;

   /*========================================================================*/
   -- Call to Procedure Add Parameters. To Add AP and PO data to XML data
   /*========================================================================*/

   Add_DefCOGSData (p_api_version           => 1.0,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    i_cost_method	    => p_cost_method,
                    i_operating_unit	    => l_operating_unit,
		    i_ledger_id	            => p_ledger_id,
		    i_pac_legal_entity      => p_pac_legal_entity,
                    i_pac_cost_type	    => p_pac_cost_type,
                    i_pac_cost_group  	    => p_pac_cost_group,
                    i_period_name	    => p_period_name,
 		    i_sales_order_date_low  => l_sales_order_date_low,
		    i_sales_order_date_high => l_sales_order_date_high,
                    i_all_lines	            => p_all_lines,
                    x_xml_doc               => l_xml_doc);

   -- Standard call to check the return status from API called

   if(l_return_status <> fnd_api.G_RET_STS_SUCCESS) then
     raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- write the closing tag to the XML data

   dbms_lob.writeappend (l_xml_doc, 9, '</REPORT>');

   -- write xml data to the output file

   l_length := nvl(dbms_lob.getlength(l_xml_doc),0);
   loop
     exit when l_length <= 0;
     dbms_lob.read (l_xml_doc, l_amount, l_offset, l_buffer);
     fnd_file.put(fnd_file.output, l_buffer);
     l_length := l_length - l_amount;
     l_offset := l_offset + l_amount;
   end loop;

   dbms_xmlgen.closeContext(l_qryCtx);

   -- Write the event log to fnd log file

   if(l_eventLog) then
     fnd_log.string(fnd_log.LEVEL_EVENT,
     l_module || '.' || l_stmt_num, 'Completed writing to output file');
   end if;

   -- free temporary memory

   dbms_lob.freetemporary(l_xml_doc);

   l_success := fnd_concurrent.set_completion_status('NORMAL', 'Request Completed Successfully');

   -- Write the module name to fnd log file

   IF l_pLog THEN
      fnd_log.string(fnd_log.level_procedure,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'errcode = '||errcode||','||
        'err_code = '||err_code
      );
   END IF;

   exception
     when fnd_api.G_EXC_ERROR then
       l_return_status := fnd_api.G_RET_STS_ERROR ;
       fnd_msg_pub.Count_And_Get
       (       p_count     =>      l_msg_count,
               p_data      =>      l_msg_data
       );

     when fnd_api.G_EXC_UNEXPECTED_ERROR then
       fnd_msg_pub.Count_And_Get
       (       p_count => l_msg_count,
               p_data  => l_msg_data
       );

       cst_utility_pub.writelogmessages
       (       p_api_version   => 1.0,
               p_msg_count     => l_msg_count,
               p_msg_data      => l_msg_data,
               x_return_status => l_return_status
       );

       l_msg_data      := substrb(SQLERRM,1,240);
       l_success       := fnd_concurrent.set_completion_status('ERROR', l_msg_data);

     when others then
       if(fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
                        l_module || '.' || l_stmt_num,
                        substrb(SQLERRM , 1 , 240));
       end if;

       if(fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)) then
         fnd_msg_pub.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       end if;

       fnd_msg_pub.Count_And_Get
       (       p_count  =>  l_msg_count,
               p_data   =>  l_msg_data
       );

       cst_utility_pub.writelogmessages
       (       p_api_version   => 1.0,
               p_msg_count     => l_msg_count,
               p_msg_data      => l_msg_data,
               x_return_status => l_return_status
       );

       l_msg_data      := substrb(SQLERRM,1,240);
       l_success       := fnd_concurrent.set_completion_status('ERROR', l_msg_data);

 end Generate_DefCOGSXml;


 /*===========================================================================*/
 --      API name        : add_parameters
 --      Type            : Private
 --      Function        : Generate XML data for Parameters and append it to
 --                        output
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_api_version           in number
 --                      : p_init_msg_list         in varchar2
 --                      : p_validation_level      in number
 --          		 : p_cost_method           in number
 --              	 : p_operating_unit        in number
 --          		 : p_ledger_id             in number
 --          		 : p_pac_legal_entity      in number
 --                      : p_pac_cost_type         in number
 --          		 : p_pac_cost_group        in number
 --                      : p_period_name           in varchar2
 --                      : p_sales_order_date_low  in varchar2
 --                      : p_sales_order_date_high in varchar2
 --          		 : p_all_lines             in varchar2
 --
 --      out             :
 --                      : x_return_status         out nocopy varchar2
 --                      : x_msg_count             out nocopy number
 --                      : x_msg_data              out nocopy varchar2
 --
 --      in out          :
 --                      : x_xml_doc               in out nocopy clob
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005    David Gottlieb  Created
 --      Notes           : This Procedure is called by Generate_DefCOSXml
 --                        procedure. The procedure generates XML data for the
 --                        report parameters and appends it to the report
 --                        output.
 -- End of comments
 /*===========================================================================*/
 procedure Add_Parameters (
   p_api_version           in              number,
   p_init_msg_list         in              varchar2,
   p_validation_level      in              number,
   x_return_status         out nocopy      varchar2,
   x_msg_count             out nocopy      number,
   x_msg_data              out nocopy      varchar2,
   i_cost_method	   in              number,
   i_operating_unit	   in		   number,
   i_ledger_id		   in		   number,
   i_pac_legal_entity	   in		   number,
   i_pac_cost_type	   in		   number,
   i_pac_cost_group	   in		   number,
   i_period_name           in              varchar2,
   i_sales_order_date_low  in              varchar2,
   i_sales_order_date_high in              varchar2,
   i_all_lines             in		   varchar2,
   x_xml_doc               in out nocopy   clob) is

   l_api_name      constant varchar2(30)    := 'ADD_PARAMETERS';
   l_api_version   constant number          := 1.0;
   l_full_name     constant varchar2(2000)  := G_PKG_NAME || '.' || l_api_name;
   l_module        constant varchar2(2000)  := 'cst.plsql.' || l_full_name;

   l_ref_cur       sys_refcursor;
   l_qryCtx        number;
   l_xml_temp      clob;
   l_age_option    number;
   l_offset        pls_integer;
   l_org_code      CST_ORGANIZATION_DEFINITIONS.ORGANIZATION_CODE%TYPE;
   l_cost_type     CST_COST_TYPES.COST_TYPE%TYPE;
   l_cost_group    CST_COST_GROUPS.COST_GROUP%TYPE;
   l_period_name   CST_PAC_PERIODS.PERIOD_NAME%TYPE;
   l_meaning       FND_LOOKUPS.MEANING%TYPE;
   l_stmt_num      number;

   l_uLog          constant boolean         := (fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND fnd_log.test(fnd_log.LEVEL_UNEXPECTED, l_module);
   l_errorLog      constant boolean         := l_uLog and (fnd_log.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog      constant boolean         := l_errorLog and (fnd_log.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog          constant boolean         := l_eventLog and (fnd_log.LEVEL_PROCEDURE >= G_LOG_LEVEL);

 begin

   -- Write the module name to fnd log file

   IF l_pLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
       'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'i_cost_method = '||i_cost_method||','||
        'i_operating_unit = '||i_operating_unit||','||
        'i_ledger_id = '||i_ledger_id||','||
        'i_pac_legal_entity = '||i_pac_legal_entity||','||
        'i_pac_cost_type = '||i_pac_cost_type||','||
        'i_pac_cost_group = '||i_pac_cost_group||','||
        'i_period_name = '||i_period_name||','||
        'i_sales_order_date_low = '||i_sales_order_date_low||','||
        'i_sales_order_date_high = '||i_sales_order_date_high||','||
        'i_all_lines = '||i_all_lines
     );
   END IF;

   -- Standard call to check for call compatibility.

   if(not fnd_api.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )) then
     raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if(fnd_api.to_boolean( p_init_msg_list )) then
     fnd_msg_pub.initialize;
   end if;

   --  Initialize API return status to success

   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   -- Initialize temporary variable to hold xml data

   dbms_lob.createtemporary(l_xml_temp, TRUE);
   l_offset := 21;

   -- Get the proile value to determine the aging basis

   fnd_profile.get('CST_ACCRUAL_AGE_IN_DAYS', l_age_option);

   l_stmt_num := 10;

   -- Open Ref Cursor to collect the report parameters

   /* Perpetual */
   if(i_cost_method = 1) then
     open l_ref_cur for 'select :i_cost_method		 cost_method,
				haou.name		 operating_unit,
	  	                gsb.name		 ledger,
			        :i_period_name 		 period_name,
			        :i_sales_order_date_low	 sales_order_date_from,
			        :i_sales_order_date_high sales_order_date_to,
			        fl.meaning		 all_lines
                         from   hr_all_organization_units haou,
			        gl_sets_of_books 	  gsb,
			        fnd_lookups     	  fl
                         where  haou.organization_id  = :i_operating_unit
		         and    gsb.set_of_books_id   = :i_ledger_id
 		         and    fl.lookup_code	      = :i_all_lines
		         and    fl.lookup_type        = ''YES_NO'''
                         using  i_cost_method,
				i_period_name,
			        i_sales_order_date_low,
			        i_sales_order_date_high,
			        i_operating_unit,
			        i_ledger_id,
			        i_all_lines;

   /* Periodic */
   elsif(i_cost_method = 3) then
     SELECT cost_type
     INTO   l_cost_type
     FROM   cst_cost_types
     WHERE  cost_type_id = i_pac_cost_type;

     SELECT cost_group
     INTO   l_cost_group
     FROM   cst_cost_groups
     WHERE  cost_group_id = i_pac_cost_group;

     SELECT period_name
     INTO   l_period_name
     FROM   cst_pac_periods
     WHERE  pac_period_id = TO_NUMBER(i_period_name);

     SELECT meaning
     INTO   l_meaning
     FROM   fnd_lookups
     WHERE  lookup_type = 'YES_NO'
     AND    lookup_code = i_all_lines;

     open l_ref_cur for 'select :i_cost_method		 cost_method,
				xle.name		 legal_entity,
				:l_cost_type		 cost_type,
				:l_cost_group		 cost_group,
			        :l_period_name 	         period_name,
			        :i_sales_order_date_low	 sales_order_date_from,
			        :i_sales_order_date_high sales_order_date_to,
			        :l_meaning		 all_lines
                         from   xle_firstparty_information_v	xle
			 where  xle.legal_entity_id = :i_pac_legal_entity'
                         using  i_cost_method,
                                l_cost_type,
                                l_cost_group,
                                l_period_name,
			        i_sales_order_date_low,
			        i_sales_order_date_high,
                                l_meaning,
				i_pac_legal_entity;

   end if; /* p_cost_method = 1, p_cost_method = 3*/

       -- create new context

       l_stmt_num := 20;

       l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
       dbms_xmlgen.setRowSetTag (l_qryCtx,'PARAMETERS');
       dbms_xmlgen.setRowTag (l_qryCtx,NULL);

       l_stmt_num := 30;

       -- get XML into the temporary clob variable

       dbms_xmlgen.getXML (l_qryCtx, l_xml_temp, dbms_xmlgen.none);

       -- remove the header (21 characters) and append the rest to xml output

       if(dbms_xmlgen.getNumRowsProcessed(l_qryCtx) > 0) then
         dbms_lob.erase (l_xml_temp, l_offset,1);
         dbms_lob.append (x_xml_doc, l_xml_temp);
       end if;

       -- close context and free memory

       dbms_xmlgen.closeContext(l_qryCtx);
     close l_ref_cur;

   dbms_lob.freetemporary(l_xml_temp);

   -- Standard call to get message count and if count is 1, get message info.

   fnd_msg_pub.Count_And_Get
   (    p_count         =>       x_msg_count,
        p_data          =>       x_msg_data
   );

   -- Write the module name to fnd log file
   IF l_plog THEN
      fnd_log.string(fnd_log.level_procedure,l_module||'.end',
        'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
        'x_return_status = '||x_return_status
      );
   END IF;

   exception
     when fnd_api.G_EXC_ERROR then
       x_return_status := fnd_api.G_RET_STS_ERROR;
       fnd_msg_pub.Count_And_Get
       (       p_count         =>      x_msg_count,
               p_data          =>      x_msg_data
       );

     when fnd_api.G_EXC_UNEXPECTED_ERROR then
       x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.Count_And_Get
       (       p_count         =>      x_msg_count,
               p_data          =>      x_msg_data
       );

     when others then
       x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
       if(fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
                        l_module || '.' || l_stmt_num,
                        substrb(SQLERRM , 1 , 240));
       end if;

       if(fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)) then
         fnd_msg_pub.Add_Exc_Msg
         (       G_PKG_NAME,
                 l_api_name
         );
       end if;

       fnd_msg_pub.Count_And_Get
       (       p_count         =>      x_msg_count,
               p_data          =>      x_msg_data
       );

 end Add_Parameters;


 /*===========================================================================*/
 --      API name        : Add_DefCOGSData
 --      Type            : Private
 --      Function        : Generate XML data from sql query and append it to
 --                        output
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_api_version           in number
 --                      : p_init_msg_list         in varchar2
 --                      : p_validation_level      in number
 --          		 : i_cost_method           in number
 --          		 : i_operating_unit    	   in number
 --          		 : i_ledger_id         	   in number
 --              	 : i_pac_legal_entity      in number
 --              	 : i_pac_cost_type     	   in number
 --          		 : i_pac_cost_group    	   in number
 --                      : i_period_name       	   in varchar2
 --                      : i_sales_order_date_low  in date
 --                      : i_sales_order_date_high in date
 --          		 : i_all_lines         	   in varchar2
 --
 --      out             : x_return_status         out nocopy varchar2
 --                      : x_msg_count             out nocopy number
 --                      : x_msg_data              out nocopy varchar2
 --
 --      in out          : x_xml_doc               in out nocopy clob
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005    David Gottlieb  Created
 --      Notes           : This Procedure is called by Generate_DefCOGSXml
 --                        procedure. The procedure generates XML data from
 --                        sql query and appends it to the report output.
 -- End of comments
 /*===========================================================================*/
 procedure Add_DefCOGSData (
   p_api_version           in              number,
   p_init_msg_list         in              varchar2,
   p_validation_level      in              number,
   x_return_status         out nocopy      varchar2,
   x_msg_count             out nocopy      number,
   x_msg_data              out nocopy      varchar2,
   i_cost_method           in              number,
   i_operating_unit	   in		   number,
   i_ledger_id		   in		   number,
   i_pac_legal_entity      in		   number,
   i_pac_cost_type	   in 		   number,
   i_pac_cost_group	   in		   number,
   i_period_name           in              varchar2,
   i_sales_order_date_low  in              date,
   i_sales_order_date_high in              date,
   i_all_lines             in              varchar2,
   x_xml_doc               in out nocopy   clob) is

   l_api_name      	constant varchar2(100)   := 'ADD_DEFCOGSDATA';
   l_api_version	constant number          := 1.0;

   l_ref_cur            sys_refcursor;
   l_qryCtx             number;
   l_xml_temp           clob;
   l_offset             pls_integer;
   l_count              number;
   l_stmt_num           number;
   l_dummy_date         date;
   l_date_offset        number;

   l_full_name     	constant varchar2(2000)  := G_PKG_NAME || '.' || l_api_name;
   l_module        	constant varchar2(2000)  := 'cst.plsql.' || l_full_name;
   l_uLog          	constant boolean         := (fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND fnd_log.test(fnd_log.LEVEL_UNEXPECTED, l_module);
   l_errorLog      	constant boolean         := l_uLog AND (fnd_log.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog     	constant boolean         := l_errorLog and (fnd_log.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog          	constant boolean         := l_eventLog and (fnd_log.LEVEL_PROCEDURE >= G_LOG_LEVEL);

 begin

   -- Write the module name to fnd log file

   IF l_pLog THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_module||'.begin',
       'Entering '||G_PKG_NAME||'.'||l_api_name||' with '||
        'p_api_version = '||p_api_version||','||
        'i_cost_method = '||i_cost_method||','||
        'i_operating_unit = '||i_operating_unit||','||
        'i_ledger_id = '||i_ledger_id||','||
        'i_pac_legal_entity = '||i_pac_legal_entity||','||
        'i_pac_cost_type = '||i_pac_cost_type||','||
        'i_pac_cost_group = '||i_pac_cost_group||','||
        'i_period_name = '||i_period_name||','||
        'i_sales_order_date_low = '||to_char(i_sales_order_date_low,'DD-MON-YYYY HH24:MI:SS')||','||
        'i_sales_order_date_high = '||to_char(i_sales_order_date_high,'DD-MON-YYYY HH24:MI:SS')||','||
        'i_all_lines = '||i_all_lines
     );
   END IF;

   -- Standard call to check for call compatibility.

   if(not fnd_api.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)) then
     raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if(fnd_api.to_boolean(p_init_msg_list)) then
     fnd_msg_pub.initialize;
   end if;

   --  Initialize API return status to success

   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   -- Initialize temporary variable to hold xml data

   dbms_lob.createtemporary(l_xml_temp, TRUE);
   l_offset := 21;

   -- open ref cur to fetch Deferred COGS data

   l_stmt_num := 10;

   if(i_cost_method = 1) then
----------------------------------------------------------------------------------------------
-- Perpetual report
----------------------------------------------------------------------------------------------

     l_dummy_date := SYSDATE;
     l_date_offset := inv_le_timezone_pub.get_le_day_time_for_ou(
                        l_dummy_date,
                        i_operating_unit
                      ) - l_dummy_date;

     open l_ref_cur for '
      with Z AS
       (
        SELECT /* index(srclines RA_CUSTOMER_TRX_LINES_N9) LEADING (Q, srclines) use_nl(Q, srclines) */
            Q.ORDER_NUMBER                                      order_number,
            Q.booked_date   /* maybe ordered_date? */           order_date,
            (select substrb(PARTY.PARTY_NAME,1,50)
             from HZ_PARTIES party
             where CUST_ACCT.PARTY_ID = PARTY.PARTY_ID) customer_name,
            Q.transactional_curr_code                           currency,
            Q.line_number                                       sales_order_line,
            Q.REVENUE_OM_LINE_ID                                   sales_order_line_id,
            msi.concatenated_segments                             item,
            srclines.line_number                                  invoice_line,
            srclines.customer_trx_line_id,
            srclines.customer_trx_id,
            -------------------------
            sum(cce1.EVENT_QUANTITY)                              total_line_quantity,
            Q.COGS_BALANCE                                        Earned_COGS,
            Q2.COGS_BALANCE                                       Total_Earned_COGS,
            Q.DEF_COGS_BALANCE                                    Deferred_COGS,
            Q2.DEF_COGS_BALANCE                                   Total_Deferred_COGS,
            cogs_acct.concatenated_segments                       COGS_account,
            dcogs_acct.concatenated_segments                      Deferred_COGS_account
        FROM
        (
         SELECT /*+ leading(crcml), index(crcml CST_REV_COGS_MATCH_LINES_N2) */
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.COGS_OM_LINE_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.inventory_item_id,
           CRCML.UNIT_COST,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID,
           sum(decode(mta.accounting_line_type, 35, MTA.BASE_TRANSACTION_VALUE,0)) COGS_BALANCE,
           sum(decode(mta.accounting_line_type, 36, MTA.BASE_TRANSACTION_VALUE,0)) DEF_COGS_BALANCE
         FROM
           CST_REVENUE_COGS_MATCH_LINES CRCML,
           CST_COGS_EVENTS CCE,
           GL_PERIOD_STATUSES GPS,
           OE_ORDER_LINES_ALL OOL,
           OE_ORDER_HEADERS_ALL OOH,
           MTL_TRANSACTION_ACCOUNTS MTA
         WHERE
             CRCML.SALES_ORDER_ISSUE_DATE BETWEEN :i_sales_order_date_low AND :i_sales_order_date_high
         AND CRCML.OPERATING_UNIT_ID = :i_operating_unit
         AND CRCML.PAC_COST_TYPE_ID IS NULL
         AND GPS.APPLICATION_ID = 101
         AND GPS.SET_OF_BOOKS_ID = :i_ledger_id
         AND GPS.PERIOD_NAME = :i_period_name
         AND CCE.EVENT_DATE <= GPS.END_DATE + .99999 - :l_date_offset
         AND CCE.COGS_OM_LINE_ID = CRCML.COGS_OM_LINE_ID
         AND OOL.HEADER_ID = OOH.HEADER_ID
         AND OOL.LINE_ID  = CRCML.COGS_OM_LINE_ID
         AND mta.transaction_id (+) = cce.mmt_transaction_id
         GROUP BY
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.COGS_OM_LINE_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.inventory_item_id,
           CRCML.UNIT_COST,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID
        ) Q,
              (
         SELECT /*+ leading(crcml), index(crcml CST_REV_COGS_MATCH_LINES_N2) */
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID,
           sum(decode(mta.accounting_line_type, 35, MTA.BASE_TRANSACTION_VALUE,0)) COGS_BALANCE,
           sum(decode(mta.accounting_line_type, 36, MTA.BASE_TRANSACTION_VALUE,0)) DEF_COGS_BALANCE
         FROM
           CST_REVENUE_COGS_MATCH_LINES CRCML,
           CST_COGS_EVENTS CCE,
           GL_PERIOD_STATUSES GPS,
           OE_ORDER_LINES_ALL OOL,
           OE_ORDER_HEADERS_ALL OOH,
           MTL_TRANSACTION_ACCOUNTS MTA
         WHERE
             CRCML.SALES_ORDER_ISSUE_DATE BETWEEN :i_sales_order_date_low AND :i_sales_order_date_high
         AND CRCML.OPERATING_UNIT_ID = :i_operating_unit
         AND CRCML.PAC_COST_TYPE_ID IS NULL
         AND GPS.APPLICATION_ID = 101
         AND GPS.SET_OF_BOOKS_ID = :i_ledger_id
         AND GPS.PERIOD_NAME = :i_period_name
         AND CCE.EVENT_DATE <= GPS.END_DATE + .99999 - :l_date_offset
         AND CCE.COGS_OM_LINE_ID = CRCML.COGS_OM_LINE_ID
         AND OOL.HEADER_ID = OOH.HEADER_ID
         AND OOL.LINE_ID  = CRCML.COGS_OM_LINE_ID
         AND mta.transaction_id (+) = cce.mmt_transaction_id
         GROUP BY
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID
        ) Q2,
          MTL_SYSTEM_ITEMS_KFV MSI,
          gl_code_combinations_kfv cogs_acct,
          gl_code_combinations_kfv dcogs_acct,
          ra_customer_trx_lines_all   srclines,
          HZ_CUST_ACCOUNTS cust_acct,
          cst_cogs_events cce1
        WHERE
            MSI.INVENTORY_ITEM_ID = Q.INVENTORY_ITEM_ID
        AND MSI.ORGANIZATION_ID = Q.ORGANIZATION_ID
        AND Q2.ORGANIZATION_ID = Q.ORGANIZATION_ID
        AND cogs_acct.code_combination_id = Q.cogs_acct_id
        AND Q2.cogs_acct_id = Q.cogs_acct_id
        AND dcogs_acct.code_combination_id = Q.deferred_cogs_acct_id
        AND Q2.deferred_cogs_acct_id = Q.deferred_cogs_acct_id
        AND Q.sold_to_org_id = cust_acct.CUST_ACCOUNT_ID (+)
        AND Q2.sold_to_org_id = Q.sold_to_org_id
        AND srclines.line_type                 (+) = ''LINE''
        AND srclines.interface_line_context    (+) = ''ORDER ENTRY''
        AND srclines.interface_line_attribute6 (+) = to_char(Q.revenue_om_line_id)
        AND Q2.revenue_om_line_id = Q.revenue_om_line_id
        AND srclines.sales_order               (+) = to_char(Q.order_number)
        AND Q2.order_number = Q.order_number
        AND cce1.cogs_om_line_id = Q.cogs_om_line_id
        AND cce1.event_type in (1,2)
        GROUP BY
            Q.ORDER_NUMBER,
            Q.booked_date,
            CUST_ACCT.PARTY_ID,
            Q.transactional_curr_code,
            Q.line_number,
            Q.REVENUE_OM_LINE_ID,
            msi.concatenated_segments,
            srclines.line_number,
            srclines.customer_trx_line_id,
            srclines.customer_trx_id,
            Q.COGS_BALANCE,
            Q2.COGS_BALANCE,
            Q.DEF_COGS_BALANCE,
            Q2.DEF_COGS_BALANCE,
            cogs_acct.concatenated_segments,
            dcogs_acct.concatenated_segments
       )
       SELECT :i_all_lines          all_lines,
         Z.order_number        order_number,
         Z.order_date          order_date,
         Z.customer_name       customer,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE), Z.currency, NULL), NULL)            currency,
         Z.sales_order_line    order_line,
               Z.sales_order_line_id order_line_id,
         trx.trx_number        invoice_number,
         Z.invoice_line        invoice_line,
         Z.item                item_number,
         ROUND(SUM ( DECODE(dist.account_class, ''UNEARN'', 0,
            ''UNBILL'', 0, dist.acctd_amount) )
            *DECODE(Z.earned_cogs, Z.total_earned_cogs,1,Z.earned_cogs/Z.total_earned_cogs), 2)       earned_revenue,
         ROUND(SUM ( DECODE(dist.account_class, ''REV'', 0,
            ''UNBILL'', 0, dist.acctd_amount) )
            *DECODE(Z.deferred_cogs, Z.total_deferred_cogs,1,Z.deferred_cogs/Z.total_deferred_cogs), 2)       unearned_revenue,
         ROUND(SUM ( DECODE(dist.account_class, ''REV'', 0,
            ''UNEARN'', 0, dist.acctd_amount) )
            *DECODE(Z.deferred_cogs, Z.total_deferred_cogs,1,Z.deferred_cogs/Z.total_deferred_cogs), 2)       unbilled_revenue,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE),Z.total_line_quantity,NULL),NULL) order_quantity,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE),Z.Earned_COGS,NULL),NULL)         earned_cogs,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE),Z.Deferred_COGS,NULL),NULL)       deferred_cogs,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE),Z.COGS_account,NULL),NULL)        cogs_account,
         Decode(trx.TRX_NUMBER,Min(lines1.TRX_NUMBER),Decode(Z.INVOICE_LINE,Min(lines1.MIN_INV_LINE),Z.Deferred_COGS_account,NULL),NULL) deferred_cogs_account
       FROM
         Z,
         GL_PERIOD_STATUSES GPS1,
         ra_cust_trx_line_gl_dist_all   dist,
         ra_customer_trx_lines_all      lines,
         ra_customer_trx_all            trx,
         (SELECT rctla.INTERFACE_LINE_ATTRIBUTE1,rctla.INTERFACE_LINE_ATTRIBUTE6,rcta.TRX_NUMBER,min(rctla.LINE_NUMBER) MIN_INV_LINE
          FROM RA_CUSTOMER_TRX_LINES_ALL rctla,RA_CUSTOMER_TRX_ALL rcta
          WHERE rctla.INTERFACE_LINE_CONTEXT=''ORDER ENTRY''
          AND rctla.LINE_TYPE=''LINE''
          AND rctla.CUSTOMER_TRX_ID=rcta.CUSTOMER_TRX_ID
          AND rctla.CUSTOMER_TRX_ID=(SELECT Min(CUSTOMER_TRX_ID)
                                  FROM RA_CUSTOMER_TRX_LINES_ALL rctla1
                                   WHERE rctla.INTERFACE_LINE_ATTRIBUTE6=rctla1.INTERFACE_LINE_ATTRIBUTE6
                                   AND rctla1.INTERFACE_LINE_CONTEXT=''ORDER ENTRY''
                                   AND rctla1.LINE_TYPE=''LINE'')
          GROUP BY rctla.INTERFACE_LINE_ATTRIBUTE1,rctla.INTERFACE_LINE_ATTRIBUTE6,rcta.TRX_NUMBER) lines1
       WHERE (Z.customer_trx_line_id = lines.customer_trx_line_id
              OR Z.customer_trx_line_id = lines.previous_customer_trx_line_id)
       AND Z.customer_trx_id = trx.customer_trx_id
       AND GPS1.APPLICATION_ID = 101
       AND GPS1.SET_OF_BOOKS_ID = :i_ledger_id
       AND GPS1.PERIOD_NAME = :i_period_name
       AND    dist.customer_trx_line_id        = lines.customer_trx_line_id
       AND    dist.account_set_flag            = ''N''
       AND    dist.account_class               IN  (''REV'', ''UNEARN'', ''UNBILL'')
       AND    dist.gl_date <= GPS1.END_DATE + .99999-- or AS OF DATE
       AND Z.SALES_ORDER_LINE_ID=LINES.INTERFACE_LINE_ATTRIBUTE6
       AND Z.SALES_ORDER_LINE_ID=LINES1.INTERFACE_LINE_ATTRIBUTE6
       GROUP BY
         Z.ORDER_NUMBER,
         Z.order_date,
         Z.customer_name,
         Z.currency,
         Z.sales_order_line,
           Z.sales_order_line_id,
         lines1.INTERFACE_LINE_ATTRIBUTE6,
         trx.trx_number,
         Z.invoice_line,
         Z.item,
         Z.total_line_quantity,
         Z.Earned_COGS,
         Z.Total_Earned_COGS,
         Z.Deferred_COGS,
         Z.Total_Deferred_COGS,
         Z.COGS_account,
         Z.Deferred_COGS_account
       HAVING :i_all_lines = ''Y''
         or decode(sum(lines.revenue_amount),0,1,
                round(sum(decode(dist.account_class, ''UNEARN'', 0,
                                 ''UNBILL'', 0, dist.acctd_amount))  /
                      (sum(lines.revenue_amount) /
                       count(dist.cust_trx_line_gl_dist_id)), 3))
                 <>
            decode(z.earned_cogs, 0, decode(z.deferred_cogs,0,1,0),
                round((z.earned_cogs /
                       decode(z.deferred_cogs + z.earned_cogs,0,1,
                       z.deferred_cogs + z.earned_cogs)), 3))
       UNION
       SELECT :i_all_lines           all_lines,
         Z.order_number         order_number,
         Z.order_date           order_date,
         Z.customer_name        customer,
         Z.currency             currency,
         Z.sales_order_line     order_line,
           Z.sales_order_line_id  order_line_id,
         NULL     invoice_number,
         NULL     invoice_line,
         Z.item   item_number,
         NULL     earned_revenue,
         NULL     unearned_revenue,
         NULL     unbilled_revenue,
         Z.total_line_quantity order_quantity,
         Z.Earned_COGS   earned_cogs,
         Z.Deferred_COGS deferred_cogs,
         Z.COGS_account cogs_account,
         Z.Deferred_COGS_account deferred_cogs_account
       FROM
         Z
       WHERE Z.customer_trx_line_id IS NULL
          OR Z.customer_trx_id IS NULL'
     using i_sales_order_date_low,
           i_sales_order_date_high,
           i_operating_unit,
           i_ledger_id,
           i_period_name,
           l_date_offset,
           i_sales_order_date_low,
           i_sales_order_date_high,
           i_operating_unit,
           i_ledger_id,
           i_period_name,
           l_date_offset,
           i_all_lines,
           i_ledger_id,
           i_period_name,
           i_all_lines,
           i_all_lines;

       elsif(i_cost_method = 3) then
----------------------------------------------------------------------------------------------
-- PAC report
----------------------------------------------------------------------------------------------
         l_dummy_date := SYSDATE;

         SELECT inv_le_timezone_pub.get_server_day_time_for_le(
                  l_dummy_date,
                  legal_entity
                ) - l_dummy_date
         INTO   l_date_offset
         FROM   cst_cost_groups
         WHERE  cost_group_id = i_pac_cost_group;

         open l_ref_cur for 'with Z AS
       (
        SELECT /* index(srclines RA_CUSTOMER_TRX_LINES_N9) LEADING (Q, srclines) use_nl(Q, srclines) */
            Q.ORDER_NUMBER                                      order_number,
            Q.booked_date   /* maybe ordered_date? */           order_date,
            (select substrb(PARTY.PARTY_NAME,1,50)
             from HZ_PARTIES party
             where CUST_ACCT.PARTY_ID = PARTY.PARTY_ID) customer_name,
            Q.transactional_curr_code                           currency,
            Q.line_number                                       sales_order_line,
            msi.concatenated_segments                             item,
            srclines.line_number                                  invoice_line,
            srclines.customer_trx_line_id,
            srclines.customer_trx_id,
            -------------------------
            sum(cce1.EVENT_QUANTITY)                              total_line_quantity,
            Q.COGS_BALANCE                                        Earned_COGS,
            Q.DEF_COGS_BALANCE                                    Deferred_COGS,
            cogs_acct.concatenated_segments                       COGS_account,
            dcogs_acct.concatenated_segments                      Deferred_COGS_account
        FROM
        (
         SELECT /* LEADING(CCGA) */
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.COGS_OM_LINE_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.inventory_item_id,
           CRCML.UNIT_COST,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID,
           sum(decode(CAL.ae_line_type_code, 35, nvl(CAL.accounted_dr,0) - nvl(CAL.accounted_cr,0),0)) COGS_BALANCE,
           sum(decode(CAL.ae_line_type_code, 36, nvl(CAL.accounted_dr,0) - nvl(CAL.accounted_cr,0),0)) DEF_COGS_BALANCE
         FROM
           CST_REVENUE_COGS_MATCH_LINES CRCML,
           CST_COGS_EVENTS CCE,
           OE_ORDER_LINES_ALL OOL,
           OE_ORDER_HEADERS_ALL OOH,
           CST_COST_GROUP_ASSIGNMENTS CCGA,
           CST_PAC_PERIODS CPP,
           CST_AE_HEADERS CAH,
           CST_AE_LINES CAL
         WHERE
             CRCML.SALES_ORDER_ISSUE_DATE BETWEEN :i_sales_order_date_low AND :i_sales_order_date_high
         AND CRCML.ORGANIZATION_ID = CCGA.ORGANIZATION_ID
         AND CRCML.PAC_COST_TYPE_ID IS NULL -- Want to pick up all events, not just PAC-costed events
         AND CCGA.COST_GROUP_ID = :i_pac_cost_group
         AND CPP.PAC_PERIOD_ID = TO_NUMBER(:i_period_name)
         AND CCE.EVENT_DATE <= CPP.PERIOD_END_DATE + .99999 + :l_date_offset
         AND CCE.COGS_OM_LINE_ID = CRCML.COGS_OM_LINE_ID
         AND OOL.HEADER_ID = OOH.HEADER_ID
         AND OOL.LINE_ID  = CRCML.COGS_OM_LINE_ID
         AND CCE.MMT_TRANSACTION_ID = CAH.ACCOUNTING_EVENT_ID (+)
         AND CAH.AE_HEADER_ID = CAL.AE_HEADER_ID (+)
         GROUP BY
           OOH.ORDER_NUMBER,
           OOH.BOOKED_DATE,
           OOH.transactional_curr_code,
           OOL.LINE_NUMBER,
           OOL.SOLD_TO_ORG_ID,
           CRCML.COGS_OM_LINE_ID,
           CRCML.REVENUE_OM_LINE_ID,
           CRCML.ORGANIZATION_ID,
           CRCML.inventory_item_id,
           CRCML.UNIT_COST,
           CRCML.COGS_ACCT_ID,
           CRCML.DEFERRED_COGS_ACCT_ID
        ) Q,
          MTL_SYSTEM_ITEMS_KFV MSI,
          gl_code_combinations_kfv cogs_acct,
          gl_code_combinations_kfv dcogs_acct,
          ra_customer_trx_lines_all   srclines,
          HZ_CUST_ACCOUNTS cust_acct,
          cst_cogs_events cce1
        WHERE
            MSI.INVENTORY_ITEM_ID = Q.INVENTORY_ITEM_ID
        AND MSI.ORGANIZATION_ID = Q.ORGANIZATION_ID
        AND cogs_acct.code_combination_id = Q.cogs_acct_id
        AND dcogs_acct.code_combination_id = Q.deferred_cogs_acct_id
        AND Q.sold_to_org_id = cust_acct.CUST_ACCOUNT_ID (+)
        AND srclines.line_type                 (+) = ''LINE''
        AND srclines.interface_line_context    (+) = ''ORDER ENTRY''
        AND srclines.interface_line_attribute6 (+) = to_char(Q.revenue_om_line_id)
        AND srclines.sales_order               (+) = to_char(Q.order_number)
        AND cce1.cogs_om_line_id = Q.cogs_om_line_id
        AND cce1.event_type in (1,2)
        GROUP BY
            Q.ORDER_NUMBER,
            Q.booked_date,
            CUST_ACCT.PARTY_ID,
            Q.transactional_curr_code,
            Q.line_number,
            msi.concatenated_segments,
            srclines.line_number,
            srclines.customer_trx_line_id,
            srclines.customer_trx_id,
            Q.COGS_BALANCE,
            Q.DEF_COGS_BALANCE,
            cogs_acct.concatenated_segments,
            dcogs_acct.concatenated_segments
       )
       SELECT :i_all_lines          all_lines,
         Z.order_number        order_number,
         Z.order_date          order_date,
         Z.customer_name       customer,
         Z.currency            currency,
         Z.sales_order_line    order_line,
         trx.trx_number        invoice_number,
         Z.invoice_line        invoice_line,
         Z.item                item_number,
         ROUND(SUM ( DECODE(dist.account_class, ''UNEARN'', 0,
            ''UNBILL'', 0, dist.acctd_amount) ), 2)       earned_revenue,
         ROUND(SUM ( DECODE(dist.account_class, ''REV'', 0,
            ''UNBILL'', 0, dist.acctd_amount) ), 2)       unearned_revenue,
         ROUND(SUM ( DECODE(dist.account_class, ''REV'', 0,
            ''UNEARN'', 0, dist.acctd_amount) ), 2)       unbilled_revenue,
         Z.total_line_quantity order_quantity,
         Z.Earned_COGS         earned_cogs,
         Z.Deferred_COGS       deferred_cogs,
         Z.COGS_account        cogs_account,
         Z.Deferred_COGS_account deferred_cogs_account
       FROM
         Z,
         cst_pac_periods cpp,
         ra_cust_trx_line_gl_dist_all   dist,
         ra_customer_trx_lines_all      lines,
         ra_customer_trx_all            trx
       WHERE (Z.customer_trx_line_id = lines.customer_trx_line_id
              OR Z.customer_trx_line_id = lines.previous_customer_trx_line_id)
       AND Z.customer_trx_id = trx.customer_trx_id
       AND cpp.pac_period_id = TO_NUMBER(:i_period_name)
       AND    dist.customer_trx_line_id        = lines.customer_trx_line_id
       AND    dist.account_set_flag            = ''N''
       AND    dist.account_class               IN  (''REV'', ''UNEARN'', ''UNBILL'')
       AND    dist.gl_date <= cpp.period_end_date + .99999-- or AS OF DATE
       GROUP BY
         Z.ORDER_NUMBER,
         Z.order_date,
         Z.customer_name,
         Z.currency,
         Z.sales_order_line,
         trx.trx_number,
         Z.invoice_line,
         Z.item,
         Z.total_line_quantity,
         Z.Earned_COGS,
         Z.Deferred_COGS,
         Z.COGS_account,
         Z.Deferred_COGS_account
       HAVING :i_all_lines = ''Y''
         or decode(sum(lines.revenue_amount),0,1,
                round(sum(decode(dist.account_class, ''UNEARN'', 0,
                                 ''UNBILL'', 0, dist.acctd_amount))  /
                      (sum(lines.revenue_amount) /
                       count(dist.cust_trx_line_gl_dist_id)), 3))
                 <>
            decode(z.earned_cogs, 0, decode(z.deferred_cogs,0,1,0),
                round((z.earned_cogs /
                       (z.deferred_cogs + z.earned_cogs)), 3))
       UNION
       SELECT :i_all_lines           all_lines,
         Z.order_number         order_number,
         Z.order_date           order_date,
         Z.customer_name        customer,
         Z.currency             currency,
         Z.sales_order_line     order_line,
         NULL     invoice_number,
         NULL     invoice_line,
         Z.item   item_number,
         NULL     earned_revenue,
         NULL     unearned_revenue,
         NULL     unbilled_revenue,
         Z.total_line_quantity order_quantity,
         Z.Earned_COGS   earned_cogs,
         Z.Deferred_COGS deferred_cogs,
         Z.COGS_account cogs_account,
         Z.Deferred_COGS_account deferred_cogs_account
       FROM
         Z
       WHERE Z.customer_trx_line_id IS NULL
          OR Z.customer_trx_id IS NULL'
		         using
				  i_sales_order_date_low,
				  i_sales_order_date_high,
				  i_pac_cost_group,
				  i_period_name,
                                  l_date_offset,
                                  i_all_lines,
				  i_period_name,
				  i_all_lines,
				  i_all_lines;

       end if; /* i_cost_method = 1, i_cost_method = 3 */

       -- create new context

       l_stmt_num := 20;

       l_qryCtx := dbms_xmlgen.newContext(l_ref_cur);
       dbms_xmlgen.setRowSetTag(l_qryCtx,'DEF_COGS_DATA');
       dbms_xmlgen.setRowTag(l_qryCtx,'DEF_COGS');

       -- get XML into the temporary clob variable

       l_stmt_num := 70;

       dbms_xmlgen.getXML(l_qryCtx, l_xml_temp, dbms_xmlgen.none);

       -- remove the header (21 characters) and append the rest to xml output

       l_count := dbms_xmlgen.getNumRowsProcessed(l_qryCtx);

       if(dbms_xmlgen.getNumRowsProcessed(l_qryCtx) > 0) then
         dbms_lob.erase(l_xml_temp, l_offset,1);
         dbms_lob.append(x_xml_doc, l_xml_temp);
       end if;

       -- close context and free memory

       dbms_xmlgen.closeContext(l_qryCtx);
     close l_ref_cur;
     dbms_lob.freetemporary(l_xml_temp);

     -- to add number of rows processed

     dbms_lob.createtemporary(l_xml_temp, TRUE);

     -- open ref cursor to get the number of rows processed

     l_stmt_num := 80;

     open l_ref_cur for ' select :l_count l_count
                          from dual'
                        using l_count;

       -- create new context

       l_stmt_num := 90;

       l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
       dbms_xmlgen.setRowSetTag (l_qryCtx,'RECORD_NUM');
       dbms_xmlgen.setRowTag (l_qryCtx,NULL);

       -- get XML to add the number of rows processed

       l_stmt_num := 100;

       dbms_xmlgen.getXML (l_qryCtx, l_xml_temp, dbms_xmlgen.none);

       -- remove the header (21 characters) and append the rest to xml output

       if(dbms_xmlgen.getNumRowsProcessed(l_qryCtx) > 0 ) then
         dbms_lob.erase (l_xml_temp, l_offset,1);
         dbms_lob.append (x_xml_doc, l_xml_temp);
       end if;

       -- close context and free memory

       dbms_xmlgen.closeContext(l_qryCtx);
     close l_ref_cur;
     dbms_lob.freetemporary(l_xml_temp);

     -- Standard call to get message count and if count is 1, get message info.

     fnd_msg_pub.Count_And_Get
     (       p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
     );

     -- Write the module name to fnd log file
     IF l_pLog THEN
        fnd_log.string(fnd_log.level_procedure,l_module||'.end',
          'Exiting '||G_PKG_NAME||'.'||l_api_name||' with '||
          'x_return_status = '||x_return_status
        );
     END IF;

     exception
       when fnd_api.G_EXC_ERROR then
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.Count_And_Get
         (       p_count         =>      x_msg_count,
                 p_data          =>      x_msg_data
         );

       when fnd_api.G_EXC_UNEXPECTED_ERROR then
         x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.Count_And_Get
         (       p_count         =>      x_msg_count,
                 p_data          =>      x_msg_data
         );

       when others then
         x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
         if(fnd_log.LEVEL_UNEXPECTED >= G_LOG_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
                                        l_module || '.' || l_stmt_num,
                                        substrb(SQLERRM , 1 , 240));
         end if;

         if(fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)) then
           fnd_msg_pub.Add_Exc_Msg (G_PKG_NAME, l_api_name);
         end if;

         fnd_msg_pub.Count_And_Get
         (     p_count         =>      x_msg_count,
               p_data          =>      x_msg_data
         );

  end Add_DefCOGSData;


  PROCEDURE debug
  ( line       IN VARCHAR2,
    msg_prefix IN VARCHAR2  DEFAULT 'CST',
    msg_module IN VARCHAR2  DEFAULT g_module_name,
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
    IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND G_DEBUG = 'N' THEN
      RETURN;
    END IF;
    IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(l_msg_level, l_msg_module, SUBSTRB(l_line,1,4000));
    END IF;
  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END debug;






PROCEDURE ensure_mmt_per_and_date
(x_return_status   OUT NOCOPY     VARCHAR2,
 x_msg_count       OUT NOCOPY     NUMBER,
 x_msg_data        OUT NOCOPY     VARCHAR2)
IS
  CURSOR ctrx IS
  SELECT  mmtt.rowid
         ,mmtt.transaction_id
         ,mmtt.transaction_date
         ,mmtt.acct_period_id
         ,oap.open_flag
         ,oap.period_start_date
         ,oap.schedule_close_date
         ,oap2.acct_period_id
         ,oap2.open_flag
         ,mmtt.organization_id
    FROM mtl_cogs_recognition_temp       mmtt,
         org_acct_periods                oap,
         (SELECT period_start_date,
                 schedule_close_date,
                 acct_period_id,
                 organization_id,
                 open_flag
            FROM org_acct_periods)       oap2
  WHERE mmtt.acct_period_id   = oap.acct_period_id
    AND mmtt.organization_id  = oap.organization_id
    AND oap2.organization_id  = mmtt.organization_id
--
--BUG#6873037 : Just check the inventory period mismatch
--
    AND oap2.acct_period_id   <> oap.acct_period_id
    AND mmtt.transaction_date BETWEEN oap2.period_start_date AND oap2.schedule_close_date
    AND ( mmtt.transaction_date < oap.period_start_date   OR
          mmtt.transaction_date > oap.schedule_close_date );
--BUG#6873037
-- No need to verify inventory period status
--OR  oap.open_flag         = 'N');
--
  l_mmtt_rowid_tab             DBMS_SQL.VARCHAR2_TABLE;
  l_transaction_id_tab         DBMS_SQL.NUMBER_TABLE;
  l_transaction_date_tab       DBMS_SQL.DATE_TABLE;
  l_acct_period_id_tab         DBMS_SQL.NUMBER_TABLE;
  l_open_flag                  DBMS_SQL.VARCHAR2_TABLE;
  l_period_start_date_tab      DBMS_SQL.DATE_TABLE;
  l_schedule_close_date_tab    DBMS_SQL.DATE_TABLE;
  l_good_acct_period_id_tab    DBMS_SQL.NUMBER_TABLE;
  l_good_open_flag_tab         DBMS_SQL.VARCHAR2_TABLE;
  l_organization_id_tab        DBMS_SQL.VARCHAR2_TABLE;


  CURSOR next_inv_period(p_organization_id    IN NUMBER
                        ,p_transaction_date   IN DATE)
  IS
    SELECT MIN(acct_period_id),
           MIN(period_start_date)
      FROM org_acct_periods
     WHERE organization_id    = p_organization_id
       AND open_flag          = 'Y'
       AND period_start_date >= p_transaction_date;
  l_next_acct_period_id        NUMBER;
  l_next_transaction_date      DATE;

  l_upd_transaction_date_tab   DBMS_SQL.DATE_TABLE;
  l_upd_acct_period_id_tab     DBMS_SQL.NUMBER_TABLE;
  g_bulk_fetch_size            NUMBER             := 9999;
  l_last_fetch                 BOOLEAN            := FALSE;
  l_msg_count                  NUMBER             := 0;
  l_msg_data                   VARCHAR2(8000)     := '';
  l_stmt_num                   NUMBER             := 0;
BEGIN
  g_module_name := 'CST_RevenueCogsMatch_PVT.Ensure_mmt_PER_and_DATE';
  debug('ensure_mmt_per_and_date+');
  SAVEPOINT ensure_mmt_per_and_date;
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN ctrx;
  LOOP
    l_stmt_num := 1;
    FETCH ctrx BULK COLLECT INTO
          l_mmtt_rowid_tab
         ,l_transaction_id_tab
         ,l_transaction_date_tab
         ,l_acct_period_id_tab
         ,l_open_flag
         ,l_period_start_date_tab
         ,l_schedule_close_date_tab
         ,l_good_acct_period_id_tab
         ,l_good_open_flag_tab
         ,l_organization_id_tab
    LIMIT g_bulk_fetch_size;

    IF ctrx%NOTFOUND THEN
       l_last_fetch := TRUE;
    END IF;

    IF l_last_fetch AND l_mmtt_rowid_tab.COUNT = 0 THEN
       EXIT;
    END IF;

    FOR i IN l_mmtt_rowid_tab.FIRST .. l_mmtt_rowid_tab.LAST LOOP
      l_stmt_num := 2;

      debug
(l_stmt_num||'----------------------:
l_transaction_id_tab    :'||l_transaction_id_tab(i)||'
l_transaction_date_tab   :'||l_transaction_date_tab(i)||'
l_acct_period_id_tab     :'||l_acct_period_id_tab(i)||'
l_open_flag              :'||l_open_flag(i)||'
l_period_start_date_tab  :'||l_period_start_date_tab(i)||'
l_schedule_close_date_tab:'||l_schedule_close_date_tab(i)||'
l_good_acct_period_id_tab:'||l_good_acct_period_id_tab(i)||'
l_good_open_flag_tab     :'||l_good_open_flag_tab(i)||'
l_organization_id_tab    :'||l_organization_id_tab(i));

      IF        (l_acct_period_id_tab(i) <> l_good_acct_period_id_tab(i))
      THEN
         -- Update the acct_period_id with the l_good_acct_period_id_tab
         l_stmt_num := 21;
         l_upd_transaction_date_tab(i) := l_transaction_date_tab(i);
         l_upd_acct_period_id_tab(i)   := l_good_acct_period_id_tab(i);
         debug(l_stmt_num||': l_upd_transaction_date_tab:'|| l_upd_transaction_date_tab(i));
         debug(l_stmt_num||': l_upd_acct_period_id_tab  :'|| l_upd_acct_period_id_tab(i));
      ELSE
         -- Update the acct_period and transaction_date to the next opened inventory
         -- log a message
         l_stmt_num := 22;
         -- COGS transaction should not care about the status of inventory period as per design
         -- If GL is closed the problem will happen at GL post. Use needs to reopen GL period
         -- Not inventory Cst issue
         debug('Inventory period and COGS Inventory transaction date are in synchi but
Inventory period has been closed');
         l_upd_transaction_date_tab(i) := l_transaction_date_tab(i);
         l_upd_acct_period_id_tab(i)   := l_good_acct_period_id_tab(i);

      END IF;
    END LOOP;

    l_stmt_num := 3;
    debug(l_stmt_num||': UPDATING mtl_cogs_recognition_temp transaction_date and acct_period_id');
    FORALL i IN l_mmtt_rowid_tab.FIRST .. l_mmtt_rowid_tab.LAST
      UPDATE mtl_cogs_recognition_temp
         SET transaction_date = l_upd_transaction_date_tab(i)
            ,acct_period_id   = l_upd_acct_period_id_tab(i)
       WHERE rowid = l_mmtt_rowid_tab(i);
  END LOOP;
  CLOSE ctrx;
  debug('ensure_mmt_per_and_date-');
EXCEPTION
  WHEN OTHERS THEN
    --log a message
     ROLLBACK TO ensure_mmt_per_and_date;
     IF ctrx%ISOPEN THEN CLOSE ctrx; END IF;
     IF next_inv_period%ISOPEN THEN CLOSE next_inv_period; END IF;
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
     debug('OTHERS EXCEPTION ensure_mmt_per_and_date:'||SQLERRM);
     fnd_message.set_name('BOM', 'CST_UNEXP_ERROR');
     fnd_message.set_token('PACKAGE', 'CST_REVENUECOGSMATCH_PVT');
     fnd_message.set_token('PROCEDURE','ensure_mmt_per_and_date');
     fnd_message.set_token('STATEMENT',to_char(l_stmt_num));
     fnd_msg_pub.ADD;
     fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
END ensure_mmt_per_and_date;

--BUG#7387575
-- Multi worker Development for performance
-- Coordination of updation in CRRL
--
PROCEDURE crrl_preparation
(p_batch_size   IN NUMBER  DEFAULT 1000
,p_ledger_id    IN NUMBER  DEFAULT NULL)
IS

 CURSOR c_no_ledger IS
 SELECT COUNT(*)
      , ledger_id
   FROM cst_revenue_recognition_lines crrl
  WHERE potentially_unmatched_flag = 'Y'
  GROUP BY ledger_id
  HAVING COUNT(*) > 0;

  l_cnt_tab   DBMS_SQL.NUMBER_TABLE;
  l_lgr_tab   DBMS_SQL.NUMBER_TABLE;
  lafin       EXCEPTION;
BEGIN
  debug('crrl_preparation +');
  debug('   p_batch_size :'||p_batch_size);
  debug('   p_ledger_id  :'||p_ledger_id);
  IF p_ledger_id IS NULL THEN
    OPEN c_no_ledger;
    FETCH c_no_ledger BULK COLLECT
          INTO l_cnt_tab
              ,l_lgr_tab;
    CLOSE c_no_ledger;
    IF l_lgr_tab.COUNT = 0 THEN
      debug('Nothing to run non potential unmatch');
      RAISE lafin;
    END IF;
    FOR i IN l_lgr_tab.FIRST .. l_lgr_tab.LAST LOOP
       debug(' Case ledger entered is null - determining ledger_id '||l_lgr_tab(i)||' and calling updation_potential_crrl');
       updation_potential_crrl
        (p_batch_size   => p_batch_size
        ,p_ledger_id    => l_lgr_tab(i));
    END LOOP;
  ELSE
    debug(' Case ledger entered is'||p_ledger_id||' calling updation_potential_crrl');
    updation_potential_crrl
        (p_batch_size   => p_batch_size
        ,p_ledger_id    => p_ledger_id);
  END IF;
  debug('crrl_preparation -');
EXCEPTION
  WHEN lafin THEN NULL;
  WHEN OTHERS THEN
     debug('EXCEPTION OTHERS crrl_preparation:'||SQLERRM);
     RAISE;
END crrl_preparation;


------------------
-- PROCEDURE grouping cst_revenue_recognition_lines to be processed
-- by a request
-- Using the request_id column of the table CRRL
-- This needs to be evaluated but for now we avoid schema changes
-- At the end of the process the request_id in CRRL should back to the
-- concurrent request submitting the process
--------------------
PROCEDURE updation_potential_crrl
(p_batch_size   IN NUMBER  DEFAULT 1000
,p_ledger_id    IN NUMBER)
IS
  CURSOR c IS
  SELECT ROWID,
         revenue_om_line_id
    FROM cst_revenue_recognition_lines crrl
   WHERE potentially_unmatched_flag = 'Y'
     AND ledger_id = p_ledger_id
   ORDER BY revenue_om_line_id ASC;

  l_rowid_tab      DBMS_SQL.VARCHAR2_TABLE;
  l_upd_rowid_tab  DBMS_SQL.VARCHAR2_TABLE;
  clear_tab        DBMS_SQL.VARCHAR2_TABLE;
  l_romlid_tab     DBMS_SQL.NUMBER_TABLE;
  l_oml_upd_tab    DBMS_SQL.NUMBER_TABLE;
  l_last_fetch     BOOLEAN := FALSE;
  l_last_om_id     NUMBER := -9999;
  cnt              NUMBER := 0;
  l_bulk_size      NUMBER := 9999;

  PROCEDURE update_one_set_crrl
   (p_rowid_tab  IN DBMS_SQL.VARCHAR2_TABLE) IS
    l_gp_id        NUMBER;
  BEGIN
    SELECT cst_cogs_events_s.nextval
    INTO l_gp_id
    FROM dual;

    FORALL j IN p_rowid_tab.FIRST .. p_rowid_tab.LAST
    UPDATE cst_revenue_recognition_lines
    SET request_id = -1 * l_gp_id
    WHERE rowid = p_rowid_tab(j);
    COMMIT;
    debug(' CST_REV_REC_LINES updated with request_ID ='|| -1 * l_gp_id ||' for the ledger '||p_ledger_id ||
          ' Number of records CRRL updated is '|| l_upd_rowid_tab.COUNT);

    INSERT INTO cst_lists_temp
    ( list_id
     ,number_1
     ,VARCHAR_1) VALUES (p_ledger_id
                        , -1 * l_gp_id
                        , 'INSERTED');
    debug(' CST_LISTS_TEMP.list_id  = ledger_id                  : '||p_ledger_id);
    debug(' CST_LISTS_TEMP.number_1 = CRRL.request_id for process: '||-1 * l_gp_id);
    debug(' CST_LISTS_TEMP.varchar_1= STATUS of Request          : INSERTED');
  END update_one_set_crrl;

  PROCEDURE add_rowid
  ( p_rowid     IN VARCHAR2
   ,x_rowid_tab IN OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE)
  IS
  BEGIN
    x_rowid_tab(x_rowid_tab.COUNT+1) := p_rowid;
  END add_rowid;

BEGIN
  debug('updation_potential_crrl +');
  debug('   p_batch_size :'||p_batch_size);
  debug('   p_ledger_id  :'||p_ledger_id);

  OPEN c;
  LOOP
    FETCH c BULK COLLECT INTO
     l_rowid_tab  ,
     l_romlid_tab
    LIMIT l_bulk_size;

    cnt := 0;

    IF c%NOTFOUND THEN
      l_last_fetch := TRUE;
    END IF;

    IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
      IF l_upd_rowid_tab.COUNT > 0 THEN
          update_one_set_crrl(l_upd_rowid_tab);
          l_upd_rowid_tab := clear_tab;
      END IF;
      debug('COUNT = 0 and LAST FETCH ');
      EXIT;
    END IF;

    FOR i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST LOOP
       IF l_last_om_id  <> l_romlid_tab(i) THEN
          l_last_om_id  := l_romlid_tab(i);
          IF (    l_upd_rowid_tab.COUNT > p_batch_size
              AND i <> l_rowid_tab.LAST)
          THEN
             update_one_set_crrl(l_upd_rowid_tab);
             l_upd_rowid_tab := clear_tab;
          END IF;
       END IF;
       add_rowid(l_rowid_tab(i),l_upd_rowid_tab);
       cnt := cnt + 1;
    END LOOP;

  END LOOP;
  CLOSE c;
  debug('updation_potential_crrl -');
EXCEPTION
WHEN OTHERS THEN
   debug('EXCEPTION OTHERS updation_potential_crrl:'||SQLERRM);
   RAISE;
END updation_potential_crrl;



---------------------
-- Procedure Master ordonnancer of the COGS recognition programs
--
---------------------
PROCEDURE ordonnancer
(errbuf         OUT  NOCOPY   VARCHAR2
,retcode        OUT  NOCOPY   VARCHAR2
,p_batch_size   IN   NUMBER  DEFAULT 1000
,p_nb_worker    IN   NUMBER  DEFAULT 4
,p_api_version  IN   NUMBER
,p_phase        IN   NUMBER
,p_low_date     IN   VARCHAR2
,p_high_date    IN   VARCHAR2
,p_ledger_id    IN   NUMBER  DEFAULT NULL)
IS
  CURSOR c_ins IS
  SELECT list_id   -- ledger_id
        ,number_1  -- process_negative_request_id
        ,rowid
    FROM cst_lists_temp
   WHERE VARCHAR_1 = 'INSERTED';

  CURSOR c_cpt IS
  SELECT COUNT(*)
    FROM cst_lists_temp
   WHERE VARCHAR_1 = 'SUBMITTED';

  l_ledger_id    NUMBER;
  l_neg_req_id   NUMBER;
  l_rowid        VARCHAR2(200);
  l_nb_req_sub   NUMBER := 0;
  l_from_date    VARCHAR2(30);
  l_to_date      VARCHAR2(30);
  l_req_id       NUMBER;
BEGIN
  debug('Ordonnancer +');
  debug('   p_batch_size :'||p_batch_size);
  debug('   p_ledger_id  :'||p_ledger_id);
  debug('   p_nb_worker  :'||p_nb_worker);
  debug('   p_api_version:'||p_api_version);
  debug('   p_phase      :'||p_phase);
  debug('   p_low_date   :'||p_low_date);
  debug('   p_high_date  :'||p_high_date);
  debug('   p_ledger_id  :'||p_ledger_id);
  crrl_preparation
     (p_batch_size => p_batch_size
     ,p_ledger_id  => p_ledger_id);

  OPEN  c_ins;
  LOOP
     FETCH c_ins INTO l_ledger_id
                    ,l_neg_req_id
                    ,l_rowid;
     EXIT WHEN c_ins%NOTFOUND;
     -----------------------
     -- submit_req_cogs_reco
     -----------------------
     l_req_id := FND_REQUEST.SUBMIT_REQUEST
	         (application => 'BOM'
                 ,program     => 'CSTRCMCR3S'
                 ,description => 'Phase 3 of the concurrent requests for matching COGS to revenue Child'
                 ,start_time  => NULL
                 ,sub_request => FALSE
                 ,argument1   => p_api_version
                 ,argument2   => p_phase
                 ,argument3   => l_ledger_id
                 ,argument4   => p_low_date
                 ,argument5   => p_high_date
                 ,argument6   => l_neg_req_id);
     IF l_req_id > 0 THEN
       debug(' Submitted Concurrent request for CSTRCMCR3S  with ledger_id '||l_ledger_id||
             ' and process_request_id '||l_neg_req_id);
       UPDATE cst_lists_temp
          SET number_2  = l_req_id
             ,VARCHAR_1 = 'SUBMITTED'
        WHERE ROWID    = l_rowid;
       COMMIT;
     END IF;
     l_nb_req_sub := l_nb_req_sub + 1;
     debug(' Number of request launched before verification :'||l_nb_req_sub);
     IF l_nb_req_sub >= p_nb_worker THEN
        LOOP
          debug(' Verifying number of active requests');
          nb_req_active;
          SELECT COUNT(*)
            INTO l_nb_req_sub
            FROM cst_lists_temp
           WHERE VARCHAR_1 = 'SUBMITTED';

          debug(' Number of request active after verification :'||l_nb_req_sub);
          IF l_nb_req_sub < p_nb_worker THEN
             EXIT;
          END IF;
        END LOOP;
     END IF;
  END LOOP;
  CLOSE c_ins;

  debug('Ordonnancer -');
EXCEPTION
WHEN OTHERS THEN
   debug('EXCEPTION OTHERS Ordonnancer:'||SQLERRM);
   RAISE;
END ordonnancer;


---------------------
-- Procedure Checking active request
---------------------
PROCEDURE nb_req_active
IS
  CURSOR c_activity IS
  SELECT number_2
        ,rowid
    FROM cst_lists_temp
   WHERE varchar_1 = 'SUBMITTED';

  l_req_id_tab  DBMS_SQL.NUMBER_TABLE;
  l_rowid_tab   DBMS_SQL.VARCHAR2_TABLE;
  l_res         BOOLEAN;
  l_phase       VARCHAR2(30);
  l_status      VARCHAR2(30);
  l_dev_phase   VARCHAR2(30);
  l_dev_status  VARCHAR2(30);
  l_message     VARCHAR2(2000);
  l_request_id  NUMBER;

BEGIN
  debug('nb_req_active +');
--  DBMS_LOCK.sleep (2);
  OPEN c_activity;
  FETCH c_activity BULK COLLECT INTO l_req_id_tab
                                    ,l_rowid_tab;
  CLOSE c_activity;
  FOR i IN l_req_id_tab.FIRST .. l_req_id_tab.LAST LOOP
      debug(' Status verification for the request '||l_req_id_tab(i));
      l_res := FND_CONCURRENT.GET_REQUEST_STATUS
           (request_id     => l_req_id_tab(i)
           ,phase          => l_phase
           ,status         => l_status
           ,dev_phase      => l_dev_phase
           ,dev_status     => l_dev_status
           ,message        => l_message);
      debug(' Request Status:'||l_dev_phase);
      IF l_dev_phase = 'COMPLETE' THEN
         IF     l_dev_status  = 'NORMAL' THEN
           debug('The process '||l_req_id_tab(i)||' completed successfully');
           debug(l_message);
         ELSIF  l_dev_status  = 'ERROR' THEN
           debug('The process '||l_req_id_tab(i)||' completed with error');
           debug(l_message);
         ELSIF  l_dev_status  = 'WARNING' THEN
           debug('The process '||l_req_id_tab(i)||' completed with warning');
           debug(l_message);
         ELSIF  l_dev_status  = 'CANCELLED' THEN
           debug('User has aborted the process '||l_req_id_tab(i));
           debug(l_message);
         ELSIF  l_dev_status  = 'TERMINATED' THEN
           debug('User has aborted the process '||l_req_id_tab(i));
           debug(l_message);
         END IF;
         --
         debug(' Updating the request as COMPLETED');
         UPDATE cst_lists_temp
            SET varchar_1 = l_dev_phase
          WHERE rowid  = l_rowid_tab(i);
     END IF;
  END LOOP;
  debug('nb_req_active -');
EXCEPTION
WHEN OTHERS THEN
   debug('EXCEPTION OTHERS nb_req_active:'||SQLERRM);
   RAISE;
END nb_req_active ;


PROCEDURE check_program_running
(   p_prg_name    IN          VARCHAR2
,   p_app_id      IN          NUMBER
,   p_ledger_id   IN          NUMBER
,   x_running     OUT NOCOPY  VARCHAR2
,   x_status      OUT NOCOPY  VARCHAR2
,   x_out_msg     OUT NOCOPY  VARCHAR2)
IS
  CURSOR cu_program_id IS
  SELECT concurrent_program_id
    FROM fnd_concurrent_programs
   WHERE application_id          = p_app_id
     AND concurrent_program_name = p_prg_name;

   CURSOR cu_exec(p_prg_id IN NUMBER) IS
   SELECT NULL
     FROM fnd_concurrent_requests FCR
    WHERE FCR.program_application_id = 702
      AND FCR.concurrent_program_id  = p_prg_id
      AND (FCR.argument3  = TO_CHAR(p_ledger_id) OR
   -- User submits a request for ledger A and CP for all ledger is running
           FCR.argument3  IS NULL)
      AND FCR.phase_code             = 'R'
      AND FCR.request_id             <> FND_GLOBAL.CONC_REQUEST_ID
      AND ROWNUM                     = 1;

   -- User submits CP for all ledgers and CP for ledger A is running
   CURSOR cu_exec_all(p_prg_id IN NUMBER) IS
   SELECT NULL
     FROM fnd_concurrent_requests FCR
    WHERE FCR.program_application_id = 702
      AND FCR.concurrent_program_id  = p_prg_id
      AND FCR.phase_code             = 'R'
      AND FCR.request_id             <> FND_GLOBAL.CONC_REQUEST_ID
      AND ROWNUM                     = 1;


  l_prg_id    NUMBER;
  l_res       VARCHAR2(1);
  no_program  EXCEPTION;
BEGIN
   debug ('check_program_running(+)');
   debug (' p_prg_name   : '||p_prg_name);
   debug (' p_app_id     : '||p_app_id);
   debug (' p_ledger_id  : '||p_ledger_id);

  x_status     := 'S';
  x_out_msg    := '';

  OPEN cu_program_id;
  FETCH cu_program_id INTO l_prg_id;
  IF cu_program_id%NOTFOUND THEN
    l_prg_id := -1;
  END IF;
  CLOSE cu_program_id;

  IF l_prg_id = -1 THEN
    RAISE no_program;
  END IF;

  IF p_ledger_id IS NOT NULL THEN
    OPEN cu_exec(l_prg_id);
     FETCH cu_exec INTO l_res;
     IF cu_exec%NOTFOUND THEN
       --No program running
       x_running := 'N';
       x_out_msg := 'Program '||p_prg_name||' with the ledger_id '||p_ledger_id||' is not running.';
     ELSE
       --Program is running
       x_running := 'Y';
       x_out_msg := 'Program '||p_prg_name||' with the ledger_id '||p_ledger_id||' is running.';
     END IF;
    CLOSE cu_exec;

  ELSE

    OPEN cu_exec_all(l_prg_id);
     FETCH cu_exec_all INTO l_res;
     IF cu_exec_all%NOTFOUND THEN
       --No program running
       x_running := 'N';
       x_out_msg := 'Program '||p_prg_name||' is not running.';
     ELSE
       --Program is running
       x_running := 'Y';
       x_out_msg := 'Program '||p_prg_name||' is running ';
     END IF;
    CLOSE cu_exec_all;

   END IF;
  debug(' x_running :' ||x_running);
  debug (line  => 'check_program_running(-)');
EXCEPTION
  WHEN no_program THEN
    x_status  := 'E';
    x_out_msg := 'EXCEPTION PROGRAM DOES NOT EXIST FOR PRG_NAME :'||p_prg_name||' AND APP_ID :'||p_app_id;
    debug(x_out_msg);
  WHEN OTHERS THEN
    x_status  := 'U';
    x_out_msg := 'EXCEPTION OTHERS:'||SQLERRM;
    debug(x_out_msg);
END;




END CST_RevenueCogsMatch_PVT;


/

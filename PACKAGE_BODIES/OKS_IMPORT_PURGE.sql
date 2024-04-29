--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_PURGE" AS
-- $Header: OKSPKIMPPRGB.pls 120.1 2007/08/20 14:00:07 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPPRGS.pls   Created By Vamshi Mutyala                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Purge Package		                  |
--|                                                                       |
--+========================================================================
--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_PURGE';

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_NAME     CONSTANT VARCHAR2(50) := 'oks.plsql.import.' || G_PKG_NAME;
G_WORKER_REQ_ID   CONSTANT NUMBER       := FND_GLOBAL.conc_request_id;
G_MODULE_HEAD     CONSTANT VARCHAR2(200) := G_MODULE_NAME || '(Req Id = '||G_WORKER_REQ_ID||').';
G_LOG_LEVEL       CONSTANT NUMBER       := fnd_log.G_CURRENT_RUNTIME_LEVEL;
G_UNEXPECTED_LOG  CONSTANT BOOLEAN      := fnd_log.level_unexpected >= G_LOG_LEVEL AND
                                            fnd_log.TEST(fnd_log.level_unexpected, G_MODULE_HEAD);
G_ERROR_LOG       CONSTANT BOOLEAN      := G_UNEXPECTED_LOG AND fnd_log.level_error >= G_LOG_LEVEL;
G_EXCEPTION_LOG   CONSTANT BOOLEAN      := G_ERROR_LOG AND fnd_log.level_exception >= G_LOG_LEVEL;
G_EVENT_LOG       CONSTANT BOOLEAN      := G_EXCEPTION_LOG AND fnd_log.level_event >= G_LOG_LEVEL;
G_PROCEDURE_LOG   CONSTANT BOOLEAN      := G_EVENT_LOG AND fnd_log.level_procedure >= G_LOG_LEVEL;
G_STMT_LOG        CONSTANT BOOLEAN      := G_PROCEDURE_LOG AND fnd_log.level_statement >= G_LOG_LEVEL;

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
--========================================================================
-- PROCEDURE : clear_ad_cache       PRIVATE
-- PARAMETERS: P_batch_id       in    Batch Number
-- COMMENT   : This procedure will clear the AD Cache for current batch id
--=========================================================================
PROCEDURE clear_ad_cache (  P_batch_id	     IN  NUMBER)
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'clear_ad_cache';
  l_product               varchar2(30) := 'OKS';
  l_table_name            varchar2(30) := 'OKS_HEADERS_INTERFACE';
  l_update_name           varchar2(30);
  l_status                varchar2(30);
  l_industry              varchar2(30);
  l_retstatus             boolean;
  l_table_owner           varchar2(30);
BEGIN
--
-- Clear AD cache for the current batch id
--
 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
		        'P_batch_id = ' || P_batch_id);
 END IF;

	 l_retstatus := fnd_installation.get_app_info(l_product,
						      l_status,
						      l_industry,
						      l_table_owner);

         IF ((l_retstatus = FALSE)  OR (l_table_owner is null)) then
		IF G_ERROR_LOG THEN
			fnd_log.string(fnd_log.level_error,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			'Cannot get schema name for product : '||l_product);
		END IF;
		raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
	 END IF;

	 l_update_name := 'Import'||P_batch_id;
	 ad_parallel_updates_pkg.purge_processed_units(l_table_owner,
	                                               l_table_name,
	   	                                       l_update_name);

         DELETE FROM AD_PARALLEL_UPDATES
	 WHERE OWNER = l_table_owner AND TABLE_NAME = l_table_name AND script_name = l_update_name;


 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
 END clear_ad_cache;

--========================================================================
-- PROCEDURE : Purge       PRIVATE
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--             P_batch_id       in    Batch Id
--             P_Num_Workers    in    Number of workers
--  	       P_commit_size    in    Work unit size
-- COMMENT   : This procedure is the manager in AD parallel framework
--             to trigger workers for purge process
--=========================================================================
PROCEDURE Purge (X_errbuf         OUT NOCOPY VARCHAR2,
                 X_retcode        OUT NOCOPY VARCHAR2,
                 P_batch_id       IN  NUMBER,
	         P_Num_Workers    IN  NUMBER,
	  	 P_commit_size    IN  NUMBER)
IS

  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Purge';
  l_msg_data                 VARCHAR2(2000);
  l_msg_count NUMBER;
  l_row_count		  NUMBER := 0;
BEGIN
--
-- Manager processing for OKS_HEADERS_INTERFACE table
--
 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
		        'P_batch_id = ' || P_batch_id ||','||
		        'P_Num_Workers = ' || P_Num_Workers ||','||
		        'P_commit_size = ' || P_commit_size );
 END IF;

 l_stmt_num := 10;

    SELECT count(1) INTO l_row_count FROM OKS_HEADERS_INTERFACE
    WHERE  BATCH_ID = P_batch_id
      AND  INTERFACE_STATUS = 'S'
      AND  rownum = 1;

    IF l_row_count > 0 THEN

	l_stmt_num := 20;
        clear_ad_cache(P_batch_id);

	l_stmt_num := 30;
	AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf,
                                             X_retcode,
                                             'OKS',
                                             'OKSIMPPURGWRKR',
					     P_commit_size,
					     P_Num_Workers,
					     P_batch_id
                                             );
    ELSE
         DELETE FROM OKS_IMPORT_STATISTICS WHERE BATCH_ID = P_batch_id;
    END IF;
  IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit with ' ||
			'X_errbuf = ' || X_errbuf ||','||
			'X_retcode = ' || X_retcode);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    FND_MSG_PUB.Count_And_Get
      (p_encoded  => FND_API.G_FALSE
      ,p_count    => l_msg_count
      ,p_data     => l_msg_data
      );
    X_retcode := '2';
    X_errbuf  := l_msg_data;

    IF G_EXCEPTION_LOG THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , l_msg_data);
    END IF;

  WHEN OTHERS THEN
    X_errbuf        := 'Stmt no '||l_stmt_num||' '|| SQLCODE || substr(SQLERRM, 1, 200);
    X_retcode := '2';
    FND_MSG_PUB.Count_And_Get
        (p_encoded  => FND_API.G_FALSE
        ,p_count    => l_msg_count
        ,p_data     => l_msg_data
        );

    IF G_EXCEPTION_LOG THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others: ' || X_errbuf || '  ' || substr(l_msg_data, 1,250)
                    );
    END IF;

 END Purge;


END OKS_IMPORT_PURGE;

/

--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_PURGE_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_PURGE_WORKER" AS
-- $Header: OKSPKIMPPRGWRB.pls 120.1 2007/08/20 14:00:59 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPPRGWRB.pls   Created By Vamshi Mutyala                    |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Purge Worker Package	                  |
--|                                                                       |
--+========================================================================
--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_PURGE_WORKER';

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
-- PROCEDURE : Worker_purge       PRIVATE
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--  	       P_commit_size    in    Work unit size
--	       P_worker_id	in    Worker Id
--             P_Num_Workers    in    Number of workers
--             P_batch_id       in    Batch Id
-- COMMENT   : This procedure is the worker in AD parallel framework
--             to delete interface records
--=========================================================================
PROCEDURE Worker_purge (X_errbuf         OUT NOCOPY VARCHAR2,
                        X_retcode        OUT NOCOPY VARCHAR2,
			P_commit_size    IN  NUMBER,
			P_worker_id      IN  NUMBER,
			P_Num_Workers    IN  NUMBER,
			P_batch_id	 IN  NUMBER)
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Worker_purge';
  l_product               varchar2(30) := 'OKS';
  l_table_name            varchar2(30) := 'OKS_HEADERS_INTERFACE';
  l_update_name           varchar2(30);
  l_status                varchar2(30);
  l_industry              varchar2(30);
  l_retstatus             boolean;
  l_table_owner           varchar2(30);
  l_any_rows_to_process   boolean;
  l_start_rowid           rowid;
  l_end_rowid             rowid;
  l_rows_processed        number;
  l_msg_data              VARCHAR2(2000);
  l_msg_count		  NUMBER;
  l_row_count		  NUMBER := 0;
BEGIN
--
-- Worker processing for OKS_HEADERS_INTERFACE table
--
 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
		        'P_batch_id = ' || P_batch_id ||','||
		        'P_Num_Workers = ' || P_Num_Workers ||','||
		        'P_commit_size = ' || P_commit_size ||','||
			'P_worker_id = ' || P_worker_id);
 END IF;

 l_update_name := 'Purge'||P_batch_id;

 l_stmt_num := 10;

--
-- get schema name of the table for ROWID range processing
--
    l_retstatus := fnd_installation.get_app_info(l_product,
                                                 l_status,
                                                 l_industry,
                                                 l_table_owner);

    if ((l_retstatus = FALSE)  OR (l_table_owner is null)) then
         IF G_ERROR_LOG THEN
		fnd_log.string(fnd_log.level_error,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Cannot get schema name for product : '||l_product);
	 END IF;
         raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
    end if;

    IF G_STMT_LOG THEN
          fnd_log.string(fnd_log.level_statement,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			'Table Owner ' || l_table_owner);
    END IF;

  l_stmt_num := 20;

    ad_parallel_updates_pkg.initialize_rowid_range(ad_parallel_updates_pkg.ROWID_RANGE,
                                                   l_table_owner,
                                                   l_table_name,
                                                   l_update_name,
                                                   P_worker_id,
                                                   P_num_workers,
                                                   P_commit_size,
                                                   0);
  l_stmt_num := 30;
    ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                             l_end_rowid,
                                             l_any_rows_to_process,
                                             P_commit_size,
                                             TRUE);

    WHILE (l_any_rows_to_process = TRUE)
         LOOP

	      SELECT count(1) INTO l_row_count FROM OKS_HEADERS_INTERFACE
	      WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
	        AND  BATCH_ID = P_batch_id
                AND  INTERFACE_STATUS = 'S'
		AND  rownum = 1;

	      IF l_row_count > 0 THEN

		   l_stmt_num := 40;

		   DELETE FROM OKS_SALES_CREDITS_INTERFACE
		   WHERE HEADER_INTERFACE_ID IN (SELECT HEADER_INTERFACE_ID FROM OKS_HEADERS_INTERFACE
		                                 WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
						   AND  BATCH_ID = P_batch_id
						   AND  INTERFACE_STATUS = 'S');
		   l_stmt_num := 50;

		   DELETE FROM OKS_NOTES_INTERFACE
		   WHERE HEADER_INTERFACE_ID IN (SELECT HEADER_INTERFACE_ID FROM OKS_HEADERS_INTERFACE
		                                 WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
						   AND  BATCH_ID = P_batch_id
						   AND  INTERFACE_STATUS = 'S')
                      OR LINE_INTERFACE_ID IN (SELECT OLI.LINE_INTERFACE_ID
		                                 FROM OKS_LINES_INTERFACE OLI, OKS_HEADERS_INTERFACE OHI
						WHERE OHI.ROWID BETWEEN l_start_rowid AND l_end_rowid
						  AND OHI.BATCH_ID = P_batch_id
						  AND OHI.INTERFACE_STATUS = 'S'
						  AND OLI.HEADER_INTERFACE_ID = OHI.HEADER_INTERFACE_ID);
		   l_stmt_num := 60;

		   DELETE FROM OKS_COVERED_LEVELS_INTERFACE
                   WHERE LINE_INTERFACE_ID IN (SELECT OLI.LINE_INTERFACE_ID
		                                 FROM OKS_LINES_INTERFACE OLI, OKS_HEADERS_INTERFACE OHI
						WHERE OHI.ROWID BETWEEN l_start_rowid AND l_end_rowid
						  AND OHI.BATCH_ID = P_batch_id
						  AND OHI.INTERFACE_STATUS = 'S'
						  AND OLI.HEADER_INTERFACE_ID = OHI.HEADER_INTERFACE_ID);
		   l_stmt_num := 70;

		   DELETE FROM OKS_USAGE_COUNTERS_INTERFACE
                   WHERE LINE_INTERFACE_ID IN (SELECT OLI.LINE_INTERFACE_ID
		                                 FROM OKS_LINES_INTERFACE OLI, OKS_HEADERS_INTERFACE OHI
						WHERE OHI.ROWID BETWEEN l_start_rowid AND l_end_rowid
						  AND OHI.BATCH_ID = P_batch_id
						  AND OHI.INTERFACE_STATUS = 'S'
						  AND OLI.HEADER_INTERFACE_ID = OHI.HEADER_INTERFACE_ID);

		   l_stmt_num := 80;

		   DELETE FROM OKS_LINES_INTERFACE
		   WHERE HEADER_INTERFACE_ID IN (SELECT HEADER_INTERFACE_ID FROM OKS_HEADERS_INTERFACE
		                                 WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
						   AND  BATCH_ID = P_batch_id
						   AND  INTERFACE_STATUS = 'S');

		   l_stmt_num := 90;

		   DELETE FROM OKS_HEADERS_INTERFACE
		   WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
		     AND  BATCH_ID = P_batch_id
		     AND  INTERFACE_STATUS = 'S';

	      ELSE
                   l_rows_processed := 0;
	      END IF;

	      ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                            l_end_rowid);

              commit;

	      ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
                                                      l_end_rowid,
                                                      l_any_rows_to_process,
                                                      P_commit_size,
                                                      FALSE);
         END LOOP;

    X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
    X_errbuf  := ' ';

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
 END Worker_purge;

END OKS_IMPORT_PURGE_WORKER;

/

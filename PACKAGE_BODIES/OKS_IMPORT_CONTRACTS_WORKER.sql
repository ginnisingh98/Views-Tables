--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_CONTRACTS_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_CONTRACTS_WORKER" AS
-- $Header: OKSPKIMPWRB.pls 120.3.12010000.2 2009/03/20 11:15:32 harlaksh ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPWRB.pls   Created By Vamshi Mutyala                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Worker Package		                  |
--|  Bug:8222469 CAN IMPORT ACTIVE CONTRACT WITH NO CONTRACT SUBLINES     |                                                                |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_CONTRACTS_WORKER';

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
-- PROCEDURE : PreInsert_Rollup_errors       PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure is to roll up the validation errors to
--             headers staging table before the insert phase
--=========================================================================

PROCEDURE PreInsert_Rollup_errors
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'PreInsert_Rollup_errors';
BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering.');
 END IF;

 l_stmt_num := 10;

 UPDATE OKS_INT_HEADER_STG_TEMP hst
    SET hst.INTERFACE_STATUS = (CASE WHEN EXISTS (SELECT 'X' FROM OKS_INT_ERROR_STG_TEMP
                                                  WHERE hst.HEADER_INTERFACE_ROWID = HEADER_INTERFACE_ROWID)
                                     THEN 'E'
				     ELSE 'S'
				END);

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
 END PreInsert_Rollup_errors;

--========================================================================
-- PROCEDURE : Rollup_errors       PRIVATE
-- PARAMETERS: P_mode           in    Validate Only, Import flag
--             P_batch_id       in    Batch Id
--	       P_start_rowid    in    start rowid
--	       P_end_rowid      in    end rowid
--             X_rows_processed OUT   number of rows processed in headers interface
-- COMMENT   : This procedure is to roll up the validation errors to corresponding
--	       records in the interface tables and finally to the headers interface
--=========================================================================
PROCEDURE Rollup_errors ( P_mode           IN  VARCHAR2,
                          P_batch_id	   IN  NUMBER,
			  P_parent_request_id IN NUMBER,
			  P_start_rowid    IN  rowid,
			  P_end_rowid      IN  rowid,
			  X_rows_processed OUT NOCOPY NUMBER)
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Rollup_errors';
BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
			'P_mode = ' || P_mode ||','||
			'P_parent_request_id = ' || P_parent_request_id ||','||
		        'P_batch_id = ' || P_batch_id ||','||
		        'P_start_rowid = ' || P_start_rowid ||','||
		        'P_end_rowid = ' || P_end_rowid);
 END IF;

 l_stmt_num := 10;

 INSERT INTO OKS_IMP_ERRORS
    (REQUEST_ID,
     PARENT_REQUEST_ID,
     INTERFACE_TABLE,
     HEADER_INTERFACE_ID,
     INTERFACE_ID,
     ERROR_MESSAGE)
 SELECT  OIES.CONCURRENT_REQUEST_ID,
         P_parent_request_id,
         OIES.INTERFACE_SOURCE_TABLE,
         OHI.HEADER_INTERFACE_ID,
         OIES.INTERFACE_ID,
         OIES.ERROR_MSG
 FROM    OKS_INT_ERROR_STG_TEMP OIES, OKS_HEADERS_INTERFACE OHI
 WHERE   OIES.HEADER_INTERFACE_ROWID = OHI.ROWID;

 l_stmt_num := 20;

UPDATE OKS_HEADERS_INTERFACE ohi
    SET ohi.INTERFACE_STATUS = (CASE WHEN EXISTS (SELECT 'X' FROM OKS_INT_ERROR_STG_TEMP WHERE ohi.ROWID = HEADER_INTERFACE_ROWID)
                                     THEN 'E'
				     WHEN P_mode = 'I' THEN 'S'
				     ELSE NULL
				END),
       ohi.PARENT_REQUEST_ID = P_parent_request_id
 WHERE ohi.rowid between P_start_rowid and P_end_rowid
   AND ohi.batch_id = P_batch_id
   AND (ohi.interface_status IS NULL OR ohi.interface_status  = 'R');

  X_rows_processed := SQL%ROWCOUNT;

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit with ' ||
			'X_rows_processed = '|| X_rows_processed);
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
 END Rollup_errors;

--========================================================================
-- PROCEDURE : Gather_Statistics       PRIVATE
-- PARAMETERS: P_mode                 in    Validate Only, Import flag
--             P_batch_id             in    Batch Id
--             P_parent_request_id    in    Parent Request Id
-- COMMENT   : This procedure is to insert records into statistics table
--=========================================================================
PROCEDURE Gather_Statistics ( P_mode               IN  VARCHAR2,
	                      P_batch_id	   IN  NUMBER,
			      P_parent_request_id  IN NUMBER)
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Gather_Statistics';

BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
			'P_mode = ' || P_mode ||','||
			'P_parent_request_id = ' || P_parent_request_id ||','||
		        'P_batch_id = ' || P_batch_id);
 END IF;

/* The statistic type is decided by FND lookup 'OKS_IMPORT_STAT_TYPE' */
 l_stmt_num := 10;

INSERT ALL
WHEN (STAT_TYPE = 1) THEN
	INTO OKS_IMPORT_STATISTICS
	     (BATCH_ID,
	      PARENT_REQUEST_ID,
	      REQUEST_ID,
	      STATISTIC_TYPE_ID,
	      HEADERS_STAT,
	      LINES_STAT,
	      COVERED_LEVELS_STAT,
	      USAGE_COUNTERS_STAT,
	      SALES_CREDITS_STAT,
	      NOTES_STAT)
	VALUES(
	      P_batch_id,
	      P_parent_request_id,
	      G_WORKER_REQ_ID,
	      1,
	      HEADERS_SELECTED,
	      LINES_SELECTED,
	      COVERED_LEVELS_SELECTED,
	      USAGE_COUNTERS_SELECTED,
	      SALES_CREDITS_SELECTED,
	      NOTES_SELECTED)
WHEN (STAT_TYPE = 2) THEN
	INTO OKS_IMPORT_STATISTICS
	     (BATCH_ID,
	      PARENT_REQUEST_ID,
	      REQUEST_ID,
	      STATISTIC_TYPE_ID,
	      HEADERS_STAT,
	      LINES_STAT,
	      COVERED_LEVELS_STAT,
	      USAGE_COUNTERS_STAT,
	      SALES_CREDITS_STAT,
	      NOTES_STAT)
	VALUES(
	      P_batch_id,
	      P_parent_request_id,
	      G_WORKER_REQ_ID,
	      decode(P_mode, 'I', 3, 4),
	      HEADERS_IMPORTED,
	      LINES_IMPORTED,
	      COVERED_LEVELS_IMPORTED,
	      USAGE_COUNTERS_IMPORTED,
	      SALES_CREDITS_IMPORTED,
	      NOTES_IMPORTED)
SELECT  SUM(COUNT_Q.HEADERS_COUNT)				HEADERS_SELECTED,
        SUM(COUNT_Q.LINES_COUNT)				LINES_SELECTED,
        SUM(COUNT_Q.COVERED_LEVELS_COUNT)			COVERED_LEVELS_SELECTED,
        SUM(COUNT_Q.USAGE_COUNTERS_COUNT)			USAGE_COUNTERS_SELECTED,
        SUM(COUNT_Q.SALES_CREDITS_COUNT)			SALES_CREDITS_SELECTED,
        SUM(COUNT_Q.NOTES1_COUNT) + SUM(COUNT_Q.NOTES2_COUNT)	NOTES_SELECTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.HEADERS_COUNT,0))        HEADERS_IMPORTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.LINES_COUNT,0))          LINES_IMPORTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.COVERED_LEVELS_COUNT,0)) COVERED_LEVELS_IMPORTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.USAGE_COUNTERS_COUNT,0)) USAGE_COUNTERS_IMPORTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.SALES_CREDITS_COUNT,0))  SALES_CREDITS_IMPORTED,
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.NOTES1_COUNT,0)) +
        SUM(decode(nvl(COUNT_Q.INTERFACE_STATUS,'S'), 'S', COUNT_Q.NOTES2_COUNT,0))         NOTES_IMPORTED,
	FL.STAT_TYPE							    STAT_TYPE
FROM   (SELECT rownum STAT_TYPE from dual connect by level <= 2) FL,
       (SELECT distinct OHST.INTERFACE_STATUS,
		count(distinct OHST.rowid) over (partition by OHST.INTERFACE_STATUS) HEADERS_COUNT,
		count(distinct OLST.rowid) over (partition by OHST.INTERFACE_STATUS) LINES_COUNT,
		count(distinct OCLST.rowid) over (partition by OHST.INTERFACE_STATUS) COVERED_LEVELS_COUNT,
		count(distinct OUCST.rowid) over (partition by OHST.INTERFACE_STATUS) USAGE_COUNTERS_COUNT,
		count(distinct OSCST.rowid) over (partition by OHST.INTERFACE_STATUS) SALES_CREDITS_COUNT,
		count(distinct ONI1.rowid) over (partition by OHST.INTERFACE_STATUS) NOTES1_COUNT,
		count(distinct ONI2.rowid) over (partition by OHST.INTERFACE_STATUS) NOTES2_COUNT
	 FROM   OKS_INT_HEADER_STG_TEMP OHST,
		OKS_INT_LINE_STG_TEMP OLST,
		OKS_INT_SALES_CREDIT_STG_TEMP OSCST,
		OKS_INT_COVERED_LEVEL_STG_TEMP OCLST,
		OKS_INT_USAGE_COUNTER_STG_TEMP OUCST,
		OKS_NOTES_INTERFACE ONI1,
		OKS_NOTES_INTERFACE ONI2
	 WHERE  OHST.HEADER_INTERFACE_ID = OLST.HEADER_INTERFACE_ID (+)
	   AND  OHST.HEADER_INTERFACE_ID = OSCST.HEADER_INTERFACE_ID (+)
	   AND  OLST.LINE_INTERFACE_ID = OCLST.LINE_INTERFACE_ID (+)
	   AND  OLST.LINE_INTERFACE_ID = OUCST.LINE_INTERFACE_ID (+)
	   AND  OHST.HEADER_INTERFACE_ID = ONI1.HEADER_INTERFACE_ID (+)
	   AND  ONI1.LINE_INTERFACE_ID (+) IS NULL
	   AND  OLST.LINE_INTERFACE_ID = ONI2.LINE_INTERFACE_ID (+)) COUNT_Q
GROUP BY FL.STAT_TYPE;

 l_stmt_num := 20;

INSERT INTO OKS_IMPORT_STATISTICS
	     (BATCH_ID,
	      PARENT_REQUEST_ID,
	      REQUEST_ID,
	      STATISTIC_TYPE_ID,
	      HEADERS_STAT,
	      LINES_STAT,
	      COVERED_LEVELS_STAT,
	      USAGE_COUNTERS_STAT,
	      SALES_CREDITS_STAT,
	      NOTES_STAT)
     SELECT   P_batch_id               BATCH_ID,
	      P_parent_request_id      PARENT_REQUEST_ID,
	      G_WORKER_REQ_ID	       REQUEST_ID,
	      2			       STATISTIC_TYPE_ID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_HEADERS_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) HEADERS_INVALID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_LINES_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) LINES_INVALID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_COVERED_LEVELS_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) COVERED_LEVELS_INVALID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_USAGE_COUNTERS_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) USAGE_COUNTERS_INVALID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_SALES_CREDITS_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) SALES_CREDITS_INVALID,
	      nvl(SUM(decode(INVALID_Q.INTERFACE_SOURCE_TABLE, 'OKS_NOTES_INTERFACE', INVALID_Q.INVALID_COUNT, 0)), 0) NOTES_INVALID
     FROM    (SELECT distinct INTERFACE_SOURCE_TABLE,
  	             count(distinct INTERFACE_ID) over (partition by INTERFACE_SOURCE_TABLE) INVALID_COUNT
              FROM   OKS_INT_ERROR_STG_TEMP) INVALID_Q;

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
 END Gather_Statistics;

--========================================================================
-- PROCEDURE : Truncate_stg_tables       PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure is to truncate staging tables so that next
--             rowid range can be processed by the same concurrent request
--=========================================================================
PROCEDURE Truncate_stg_tables
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Truncate_stg_tables';
BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering.');
 END IF;

 l_stmt_num := 10;

/* Replace with TRUNCATE statement */
DELETE FROM OKS_INT_HEADER_STG_TEMP;
DELETE FROM OKS_INT_LINE_STG_TEMP;
DELETE FROM OKS_COVERED_INSTANCE_STG_TEMP;
DELETE FROM OKS_COVERED_ITEM_STG_TEMP;
DELETE FROM OKS_COVERED_PARTY_STG_TEMP;
DELETE FROM OKS_COVERED_ACCOUNT_STG_TEMP;
DELETE FROM OKS_COVERED_SITE_STG_TEMP;
DELETE FROM OKS_COVERED_SYSTEM_STG_TEMP;
DELETE FROM OKS_INT_COVERED_LEVEL_STG_TEMP;
DELETE FROM OKS_INT_USAGE_COUNTER_STG_TEMP;
DELETE FROM OKS_INT_ERROR_STG_TEMP;
DELETE FROM OKS_INT_SALES_CREDIT_STG_TEMP;

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
 END Truncate_stg_tables;

--========================================================================
-- PROCEDURE : Worker_process       PRIVATE
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--  	       P_commit_size    in    Work unit size
--	       P_worker_id	in    Worker Id
--             P_Num_Workers    in    Number of workers
--             P_mode           in    Validate Only, Import flag
--             P_batch_id       in    Batch Id
-- COMMENT   : This procedure is the worker in AD parallel framework
--             to validate and import interface records
--=========================================================================
PROCEDURE Worker_process (X_errbuf         OUT NOCOPY VARCHAR2,
                          X_retcode        OUT NOCOPY VARCHAR2,
                          P_commit_size    IN  NUMBER,
			  P_worker_id	   IN  NUMBER,
			  P_Num_Workers    IN  NUMBER,
			  P_mode           IN  VARCHAR2,
                          P_batch_id	   IN  NUMBER,
			  P_parent_request_id IN NUMBER)
IS
  l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Worker_process';
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
CURSOR process(q_batch_id Number)  is                                        /*BUG:8222469*/
SELECT OHI.header_interface_id ,OHI.category,OLI.line_interface_id,
  NVL(osci.header_interface_id,-1) Sales_Credits,
  DECODE(UPPER(ohi.category),'WARRANTY',NVL(OCLI.line_interface_id,NVL2(OLI.line_interface_id,-2,-1))
  	                 ,'SERVICE',DECODE(OLI.line_interface_id, NULL,-1
                                                                  ,DECODE (UPPER(OLI.LINE_TYPE),'USAGE',NVL(OUCI.LINE_INTERFACE_ID,-3)
                                                                                           ,NVL(OCLI.LINE_INTERFACE_ID,-2)))
     		         ,'SUBSCRIPTION',NVL(OLI.line_interface_id,-1) ) line_flow
   FROM OKS_HEADERS_INTERFACE OHI
       ,OKS_LINES_INTERFACE  OLI
       ,OKS_COVERED_LEVELS_INTERFACE OCLI
       ,OKS_USAGE_COUNTERS_INTERFACE OUCI
       ,OKS_SALES_CREDITS_INTERFACE OSCI
      WHERE OHI.batch_id = q_batch_id
    AND OLI.HEADER_INTERFACE_ID(+) = OHI.HEADER_INTERFACE_ID
    AND OCLI.LINE_INTERFACE_ID(+) =  OLI.line_interface_id
    AND OUCI.LINE_INTERFACE_ID(+) =  OLI.line_interface_id
    AND OHI.HEADER_INTERFACE_ID = OSCI.HEADER_INTERFACE_ID(+);

BEGIN
--
-- Worker processing for OKS_HEADERS_INTERFACE table
--
 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
			'P_mode = ' || P_mode ||','||
			'P_parent_request_id = ' || P_parent_request_id ||','||
		        'P_batch_id = ' || P_batch_id ||','||
		        'P_Num_Workers = ' || P_Num_Workers ||','||
		        'P_commit_size = ' || P_commit_size ||','||
			'P_worker_id = ' || P_worker_id);
 END IF;

 l_update_name := 'Import'||P_batch_id;

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
	      l_stmt_num := 40;
	      SELECT count(1) INTO l_row_count FROM OKS_HEADERS_INTERFACE
	      WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
	        AND  BATCH_ID = P_batch_id
                AND (INTERFACE_STATUS IS NULL OR INTERFACE_STATUS  = 'R')
		AND rownum = 1;

	      IF l_row_count > 0 THEN                    /*BUG:8222469*/
  FOR process_rec IN process(p_batch_id)
    LOOP
    IF(process_rec.sales_credits = -1)THEN

    UPDATE oks_headers_interface
       SET interface_status ='E'
     WHERE header_interface_id =process_rec.HEADER_INTERFACE_ID;

    INSERT INTO OKS_IMP_ERRORS
                (REQUEST_ID,
                 PARENT_REQUEST_ID,
                 INTERFACE_TABLE,
                 HEADER_INTERFACE_ID,
                 INTERFACE_ID,
                 ERROR_MESSAGE)
          VALUES
                 (G_WORKER_REQ_ID,
                  P_parent_request_id,
                 'OKS_HEADERS_INTERFACE',
                 process_rec.HEADER_INTERFACE_ID,
                 process_rec.HEADER_INTERFACE_ID,
                 'OKS_IMP_HDR_SAL_CREDIT' );
    END IF;
   IF(process_rec.line_flow = -1)THEN
        UPDATE oks_headers_interface
         SET interface_status ='E'
       WHERE header_interface_id =process_rec.HEADER_INTERFACE_ID;

       INSERT INTO OKS_IMP_ERRORS
                (REQUEST_ID,
                 PARENT_REQUEST_ID,
                 INTERFACE_TABLE,
                 HEADER_INTERFACE_ID,
                 INTERFACE_ID,
                 ERROR_MESSAGE)
         VALUES
                 (G_WORKER_REQ_ID,
                  P_parent_request_id,
                 'OKS_HEADERS_INTERFACE',
                 process_rec.HEADER_INTERFACE_ID,
                 process_rec.HEADER_INTERFACE_ID,
                 'OKS_IMP_HDR_INVALID_LINE' );
    END IF;
   IF(process_rec.line_flow =-2)THEN
         UPDATE oks_headers_interface
         SET interface_status ='E'
       WHERE header_interface_id =process_rec.HEADER_INTERFACE_ID;

       INSERT INTO OKS_IMP_ERRORS
                (REQUEST_ID,
                 PARENT_REQUEST_ID,
                 INTERFACE_TABLE,
                 HEADER_INTERFACE_ID,
                 INTERFACE_ID,
                 ERROR_MESSAGE)
         VALUES
                 (G_WORKER_REQ_ID,
                  P_parent_request_id,
                 'OKS_LINES_INTERFACE',
                 process_rec.HEADER_INTERFACE_ID,
                 process_rec.LINE_INTERFACE_ID,
                 'OKS_IMP_LINE_INVALID_COVL' );
    END IF;
   IF(process_rec.line_flow =-3)THEN
          UPDATE oks_headers_interface
             SET interface_status ='E'
           WHERE header_interface_id =process_rec.HEADER_INTERFACE_ID;
        INSERT INTO OKS_IMP_ERRORS
                (REQUEST_ID,
                 PARENT_REQUEST_ID,
                 INTERFACE_TABLE,
                 HEADER_INTERFACE_ID,
                 INTERFACE_ID,
                 ERROR_MESSAGE)
         VALUES
                 (G_WORKER_REQ_ID,
                  P_parent_request_id,
                 'OKS_LINES_INTERFACE',
                 process_rec.HEADER_INTERFACE_ID,
                 process_rec.LINE_INTERFACE_ID,
                 'OKS_IMP_LINE_INVALID_USAGE' );
    END IF;
   END LOOP;
		--call the validation APIs
		     l_stmt_num := 50;
 	           OKS_IMPORT_VALIDATE.Validate_Contracts(P_batch_id,
				 	                  l_start_rowid,
				  	                  l_end_rowid);
                   l_stmt_num := 60;
	           PreInsert_Rollup_errors;
                   l_stmt_num := 70;
                   Gather_Statistics (P_mode,
	                              P_batch_id,
			              P_parent_request_id  );

                   IF P_mode = 'I' THEN
		      l_stmt_num := 80;
		      OKS_IMPORT_INSERT.Insert_Contracts;

				-- Invoking Post Insert Routines
				  l_stmt_num := 85;
			OKS_IMPORT_POST_INSERT.Import_Post_Insert;

		       l_stmt_num := 86;

			-- Invoking Post Processing Routine
		       OKS_IMPORT_POST_PROCESS.Import_Post_Process;
		   END IF;
		     l_stmt_num := 90;
	           Rollup_errors( P_mode,
                                  P_batch_id,
				  P_parent_request_id,
 			          l_start_rowid,
			          l_end_rowid,
			          l_rows_processed);
		     l_stmt_num := 100;
		   Truncate_stg_tables;
	      ELSE
                   l_rows_processed := 0;
	      END IF;
                l_stmt_num := 110;
	      ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                            l_end_rowid);

              commit;
                l_stmt_num := 120;
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
	    FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
    X_errbuf        :=     FND_MESSAGE.GET;
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
 END Worker_process;

END OKS_IMPORT_CONTRACTS_WORKER;

/

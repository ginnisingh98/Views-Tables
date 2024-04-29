--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_REPORT" AS
-- $Header: OKSPKIMPRPTB.pls 120.1 2007/09/06 11:19:50 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPRPTB.pls   Created By Vamshi Mutyala                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Statistics and Error Report Package       |
--|                                                                       |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_REPORT';

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
-- PROCEDURE : Print_Statistics     PUBLIC
-- PARAMETERS: P_batch_id              IN   Batch Id
--             P_parent_request_id     IN   Import Process Request Id
-- COMMENT   : This procedure will print statistics part of the report.
--=========================================================================
PROCEDURE Print_Statistics(P_batch_id	        IN VARCHAR2,
			   P_parent_request_id  IN NUMBER)
IS

CURSOR statistics_cur (c_parent_request_id IN NUMBER,
                       c_batch_id          IN NUMBER)
IS
SELECT FL.Meaning		    Statistic_Name,
       INNER_Q.Headers_Stat         Headers_Stat,
       INNER_Q.Lines_Stat           Lines_Stat,
       INNER_Q.Covered_Levels_Stat  Covered_Levels_Stat,
       INNER_Q.Usage_Counters_Stat  Usage_Counters_Stat,
       INNER_Q.Sales_Credits_Stat   Sales_Credits_Stat,
       INNER_Q.Notes_Stat           Notes_Stat
FROM   FND_LOOKUPS  FL,
       (SELECT  OIS.STATISTIC_TYPE_ID        Statistic_type,
                SUM(OIS.HEADERS_STAT)	     Headers_Stat,
                SUM(OIS.LINES_STAT)	     Lines_Stat,
                SUM(OIS.COVERED_LEVELS_STAT) Covered_Levels_Stat,
	        SUM(OIS.USAGE_COUNTERS_STAT) Usage_Counters_Stat,
                SUM(OIS.SALES_CREDITS_STAT)  Sales_Credits_Stat,
	        SUM(OIS.NOTES_STAT)          Notes_Stat
        FROM   OKS_IMPORT_STATISTICS OIS
       WHERE   OIS.PARENT_REQUEST_ID = c_parent_request_id
         AND   OIS.BATCH_ID = c_batch_id
       GROUP BY OIS.STATISTIC_TYPE_ID) INNER_Q
WHERE  FL.LOOKUP_TYPE = 'OKS_IMPORT_STAT_TYPE'
  AND  FL.LOOKUP_CODE = INNER_Q.Statistic_type
ORDER BY INNER_Q.Statistic_type;

TYPE stats_table IS TABLE OF statistics_cur%ROWTYPE INDEX BY BINARY_INTEGER;

  l_statistics_tab	stats_table;
  l_stmt_num           NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Print_Statistics';
  l_stats_message      VARCHAR2(200);
  l_parent_request_id  NUMBER;
  l_loop_count		NUMBER := 0;
BEGIN

  IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
		        'P_batch_id = ' || P_batch_id ||','||
			'P_parent_request_id = ' || P_parent_request_id);
  END IF;

  l_stmt_num := 10;
  OPEN statistics_cur(P_parent_request_id, P_batch_id);

  l_stmt_num := 20;
  FETCH statistics_cur BULK COLLECT INTO l_statistics_tab;

  l_loop_count := l_statistics_tab.count;

  IF l_loop_count = 0 THEN
     RAISE G_NO_DATA_FOUND_EXC;
  END IF;
  FND_FILE.put_line(FND_FILE.OUTPUT, 'Interface Records Processed:');

  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');
  FND_FILE.put_line(FND_FILE.OUTPUT, rpad('Interface Tables->', 36) ||
                                     'Headers' ||
				     lpad('Lines', 10) ||
				     lpad('Covered Levels', 20) ||
				     lpad('Usage Counters', 20) ||
				     lpad('Sales Credits', 20) ||
				     lpad('Notes', 10));
  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');
  FOR i IN 1..l_loop_count
  LOOP
      FND_FILE.put_line(FND_FILE.OUTPUT, rpad(l_statistics_tab(i).Statistic_Name, 36) ||
                                         lpad(l_statistics_tab(i).Headers_Stat, 7) ||
					 lpad(l_statistics_tab(i).Lines_Stat, 10) ||
					 lpad(l_statistics_tab(i).Covered_Levels_Stat, 20) ||
					 lpad(l_statistics_tab(i).Usage_Counters_Stat, 20) ||
					 lpad(l_statistics_tab(i).Sales_Credits_Stat, 20) ||
					 lpad(l_statistics_tab(i).Notes_Stat, 10));
  END LOOP;

  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');
  FND_FILE.put_line(FND_FILE.OUTPUT, fnd_global.local_chr(10) || fnd_global.local_chr(10) || fnd_global.local_chr(10));
  IF G_PROCEDURE_LOG THEN
 	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
  END IF;
 EXCEPTION
  WHEN G_NO_DATA_FOUND_EXC THEN
     RAISE G_NO_DATA_FOUND_EXC;
  WHEN FND_API.G_EXC_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
 END Print_Statistics;

--========================================================================
-- PROCEDURE : Print_Error_Messages   PUBLIC
-- PARAMETERS: P_batch_id              IN   Batch Id
--             P_parent_request_id     IN   Import Process Request Id
--             P_mode                  IN   Validate Only, Import flag
-- COMMENT   : This procedure will print error messages in the report output.
--=========================================================================

PROCEDURE Print_Error_Messages(P_batch_id	     IN VARCHAR2,
			       P_parent_request_id   IN NUMBER,
			       P_mode                IN VARCHAR2)
IS

CURSOR error_messages_cur (c_parent_request_id IN NUMBER)
IS
  SELECT OIE.INTERFACE_TABLE, OIE.INTERFACE_ID, nvl(FNM.MESSAGE_TEXT, OIE.ERROR_MESSAGE) ERROR_MESSAGE
    FROM OKS_IMP_ERRORS OIE,
         (SELECT FM.* FROM FND_NEW_MESSAGES FM, FND_APPLICATION FA
	  WHERE FM.LANGUAGE_CODE = USERENV('LANG')
            AND FA.APPLICATION_SHORT_NAME = 'OKS' AND FM.APPLICATION_ID = FA.APPLICATION_ID) FNM
   WHERE OIE.ERROR_MESSAGE = FNM.MESSAGE_NAME (+)
     AND PARENT_REQUEST_ID = c_parent_request_id;

  TYPE error_messages_tab IS TABLE OF error_messages_cur%rowtype INDEX BY BINARY_INTEGER;
  l_err_msg_tab        error_messages_tab;

  l_stmt_num           NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Print_Error_Messages';
  l_threshold_count    NUMBER := 201;
  l_error_count        NUMBER := 0;
  l_loop_count         NUMBER := 0;
BEGIN
  IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
			'P_mode = ' || P_mode ||','||
		        'P_batch_id = ' || P_batch_id ||','||
			'P_parent_request_id = ' || P_parent_request_id);
  END IF;
  FND_FILE.put_line(FND_FILE.OUTPUT, 'Error Messages:');
  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');
  FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Interface Table', 16) ||
                                     lpad('Interface Id', 28) ||
				     lpad('Error Message', 25));
  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');

  l_stmt_num := 10;
  OPEN error_messages_cur (P_parent_request_id);
  l_stmt_num := 20;
  FETCH error_messages_cur BULK COLLECT INTO l_err_msg_tab LIMIT l_threshold_count;

  l_error_count := l_err_msg_tab.count;

  IF l_error_count = l_threshold_count THEN
	l_loop_count := l_error_count - 1;
  ELSE
	l_loop_count := l_error_count;
  END IF;

  FOR i IN 1..l_loop_count
  LOOP
	  FND_FILE.put_line(FND_FILE.OUTPUT, rpad(l_err_msg_tab(i).INTERFACE_TABLE, 35) ||
	                                     rpad(l_err_msg_tab(i).INTERFACE_ID, 15) ||
					     l_err_msg_tab(i).ERROR_MESSAGE);
  END LOOP;
  FND_FILE.put_line(FND_FILE.OUTPUT,    '___________________________________________________________________________________________________________________________');

  CLOSE error_messages_cur;

  IF l_error_count = l_threshold_count THEN
        FND_MESSAGE.Set_Name('OKS', 'OKS_IMP_RPT_TOO_MANY_ERRORS');
        FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET);
  END IF;

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
 END Print_Error_Messages;

--========================================================================
-- PROCEDURE : Process_Error_Reporting     PUBLIC
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--             P_batch_id              IN   Batch Id
--             P_parent_request_id     IN   Import Process Request Id
--             P_mode                  IN   Validate Only, Import flag
--             P_Num_Workers           IN    Number of workers
--  	       P_commit_size           IN    Work unit size
-- COMMENT   : This procedure will report statistics and errors if any in
--             output for a batch processed by a parent Import request.
--=========================================================================

PROCEDURE Process_Error_Reporting(X_errbuf         OUT NOCOPY VARCHAR2,
                                  X_retcode        OUT NOCOPY VARCHAR2,
			          P_batch_id	        IN VARCHAR2,
				  P_parent_request_id   IN NUMBER,
				  P_mode                IN VARCHAR2,
				  P_Num_Workers         IN NUMBER,
				  P_commit_size         IN NUMBER)
IS
  l_stmt_num           NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Process_Error_Reporting';
  l_msg_data           VARCHAR2(2000);
  l_msg_count          NUMBER;
  l_start_date         VARCHAR2(30);
  l_end_date           VARCHAR2(30);
  l_report_date        VARCHAR2(30);
  l_mode	       VARCHAR2(30);
BEGIN
IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering with ' ||
			'P_mode = ' || P_mode ||','||
		        'P_batch_id = ' || P_batch_id ||','||
			'P_parent_request_id = ' || P_parent_request_id ||','||
		        'P_Num_Workers = ' || P_Num_Workers ||','||
		        'P_commit_size = ' || P_commit_size );
 END IF;

 l_stmt_num := 10;

 select to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS'),
        to_char(actual_completion_date, 'DD-MON-YYYY HH24:MI:SS'),
        to_char(sysdate, 'DD-MON-YYYY HH24:MI')
 into   l_start_date, l_end_date, l_report_date
 from fnd_concurrent_requests
 where request_id = P_parent_request_id;

 l_stmt_num := 20;

 select meaning into l_mode from fnd_lookups where lookup_type = 'OKS_IMPORT_MODE' and lookup_code = P_mode;

 FND_FILE.put_line(FND_FILE.OUTPUT, fnd_global.local_chr(10) || fnd_global.local_chr(10) || fnd_global.local_chr(10));
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Import Execution Report', 70) || lpad('Date: ', 32) || l_report_date);
 FND_FILE.put_line(FND_FILE.OUTPUT, fnd_global.local_chr(10));
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Import Process Request Id: ', 35) || P_parent_request_id);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Request Start Date: ', 35) || l_start_date);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Request End Date: ', 35) || l_end_date);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Batch Number: ', 35) || P_batch_id);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Mode: ', 35) || l_mode);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Number of Workers: ', 35) || P_Num_Workers);
 FND_FILE.put_line(FND_FILE.OUTPUT, lpad('Commit Size : ', 35) || P_commit_size);
 FND_FILE.put_line(FND_FILE.OUTPUT, fnd_global.local_chr(10));


 l_stmt_num := 30;
 Print_Statistics(P_batch_id,
	          P_parent_request_id);

 l_stmt_num := 40;
 Print_Error_Messages(P_batch_id,
	              P_parent_request_id,
		      P_mode);

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit with ' ||
			'X_errbuf = ' || X_errbuf ||','||
			'X_retcode = ' || X_retcode);
 END IF;
EXCEPTION
  WHEN G_NO_DATA_FOUND_EXC THEN
   FND_MESSAGE.Set_Name('OKS', 'OKS_IMP_RPT_NO_DATA');
   FND_MESSAGE.set_token('REQUEST', P_parent_request_id);
   l_msg_data := FND_MESSAGE.GET;
   FND_FILE.put_line(FND_FILE.OUTPUT, l_msg_data);
   X_errbuf := l_msg_data;
  WHEN no_data_found THEN
   FND_MESSAGE.Set_Name('OKS', 'OKS_IMP_RPT_NO_REQUEST');
   FND_MESSAGE.set_token('REQUEST', P_parent_request_id);
   FND_MESSAGE.set_token('STMT', l_stmt_num);
   l_msg_data := FND_MESSAGE.GET;
   FND_FILE.put_line(FND_FILE.OUTPUT, l_msg_data);
   X_errbuf := l_msg_data;
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
    X_errbuf        := 'Stmt no '||l_stmt_num||' '||SQLCODE || substr(SQLERRM, 1, 200);
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

 END Process_Error_Reporting;

END OKS_IMPORT_REPORT;

/

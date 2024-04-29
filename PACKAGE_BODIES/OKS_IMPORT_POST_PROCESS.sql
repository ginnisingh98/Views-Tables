--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_POST_PROCESS" AS
-- $Header: OKSPKIMPPOPB.pls 120.0 2007/09/11 11:42:18 mkarra noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OKSPKIMPPOPB.pls   Created By Mihira Karra                         |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Post Processing Routines Package          |
--|                                                                       |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_POST_PROCESS';

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_NAME     CONSTANT VARCHAR2(50) := 'oks.plsql.import.' || G_PKG_NAME;
G_WORKER_REQ_ID   CONSTANT NUMBER       := FND_GLOBAL.conc_request_id;
G_MODULE_HEAD     CONSTANT VARCHAR2(60) := G_MODULE_NAME || '(Req Id = '||G_WORKER_REQ_ID||').';
G_LOG_LEVEL       CONSTANT NUMBER       := fnd_log.G_CURRENT_RUNTIME_LEVEL;
G_UNEXPECTED_LOG  CONSTANT BOOLEAN      := fnd_log.level_unexpected >= G_LOG_LEVEL AND
                                            fnd_log.TEST(fnd_log.level_unexpected, G_MODULE_HEAD);
G_ERROR_LOG       CONSTANT BOOLEAN      := G_UNEXPECTED_LOG AND fnd_log.level_error >= G_LOG_LEVEL;
G_EXCEPTION_LOG   CONSTANT BOOLEAN      := G_ERROR_LOG AND fnd_log.level_exception >= G_LOG_LEVEL;
G_EVENT_LOG       CONSTANT BOOLEAN      := G_EXCEPTION_LOG AND fnd_log.level_event >= G_LOG_LEVEL;
G_PROCEDURE_LOG   CONSTANT BOOLEAN      := G_EVENT_LOG AND fnd_log.level_procedure >= G_LOG_LEVEL;
G_STMT_LOG        CONSTANT BOOLEAN      := G_PROCEDURE_LOG AND fnd_log.level_statement >= G_LOG_LEVEL;

--==========================
-- PROCEDURES AND FUNCTIONS
--==========================

--========================================================================
-- PROCEDURE : 	Instantiate_workflow_process     PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure will invoke the procedures to
--             Instantiate Work Flow
--=========================================================================

PROCEDURE Instantiate_workflow_process
IS

 l_stmt_num  NUMBER := 0;
 l_routine   CONSTANT VARCHAR2(30) := 'Instantiate_workflow_process';
 l_errbuf    VARCHAR2(200);
 l_retcode   NUMBER;

BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                         'Entering  .' );
 END IF;

 FND_MSG_PUB.initialize;

 l_stmt_num :=10;

	OKS_WF_K_PROCESS_PVT. launch_wf_conc_prog(l_errbuf,l_retcode) ;

	IF G_STMT_LOG THEN
		fnd_log.string(fnd_log.level_statement,
				G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
				'Successully instantiated Workflow ');
	END IF;

	IF G_EXCEPTION_LOG THEN

		FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , 'Error Code '|| l_errbuf);

	END IF;


 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Instantiate_workflow_process ;


--========================================================================
-- PROCEDURE : 	Import_Post_Process     PUBLIC
-- PARAMETERS:
-- COMMENT   : This procedure will invoke the procedures to
--             Instantiate Work Flow
--=========================================================================

PROCEDURE Import_Post_Process
IS

 l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Import_Post_Process';
BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                         'Entering  .' );
 END IF;

 FND_MSG_PUB.initialize;

 l_stmt_num :=10;

		Instantiate_workflow_process ;

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Import_Post_Process ;

END OKS_IMPORT_POST_PROCESS ;

/

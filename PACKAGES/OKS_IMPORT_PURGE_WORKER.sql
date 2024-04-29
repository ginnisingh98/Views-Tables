--------------------------------------------------------
--  DDL for Package OKS_IMPORT_PURGE_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_PURGE_WORKER" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPPRGWRS.pls 120.0 2007/07/12 13:17:56 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPPRGWRS.pls   Created By Vamshi Mutyala                    |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Purge Worker Package	                  |
--|                                                                       |
--+========================================================================
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
			P_batch_id	 IN  NUMBER);

END OKS_IMPORT_PURGE_WORKER;

/

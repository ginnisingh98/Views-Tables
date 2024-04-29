--------------------------------------------------------
--  DDL for Package OKS_IMPORT_CONTRACTS_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_CONTRACTS_WORKER" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPWRS.pls 120.1 2007/08/20 14:01:54 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPWRS.pls   Created By Vamshi Mutyala                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Worker Package		                  |
--|                                                                       |
--+========================================================================
--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

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
--             to validate and insert interface records
--=========================================================================
PROCEDURE Worker_process (X_errbuf         OUT NOCOPY VARCHAR2,
                          X_retcode        OUT NOCOPY VARCHAR2,
                          P_commit_size    IN  NUMBER,
			  P_worker_id	   IN  NUMBER,
			  P_Num_Workers    IN  NUMBER,
			  P_mode           IN  VARCHAR2,
                          P_batch_id	   IN  NUMBER,
			  P_parent_request_id IN NUMBER);

END OKS_IMPORT_CONTRACTS_WORKER;

/

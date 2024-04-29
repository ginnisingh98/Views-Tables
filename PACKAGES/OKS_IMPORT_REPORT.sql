--------------------------------------------------------
--  DDL for Package OKS_IMPORT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_REPORT" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPRPTS.pls 120.0 2007/08/29 14:14:43 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPRPTS.pls   Created By Vamshi Mutyala                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Statistics and Error Report Package       |
--|                                                                       |
--+========================================================================
--=========================
-- GLOBALS
--=========================

G_NO_DATA_FOUND_EXC EXCEPTION;
--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
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
				  P_commit_size         IN NUMBER);
END OKS_IMPORT_REPORT;

/

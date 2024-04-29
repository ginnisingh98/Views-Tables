--------------------------------------------------------
--  DDL for Package OKS_IMPORT_CONTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_CONTRACTS" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPS.pls 120.1 2007/08/20 13:58:13 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPS.pls   Created By Vamshi Mutyala                         |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Package			                  |
--|                                                                       |
--+========================================================================

--=========================
-- GLOBAL VARIABLES
--=========================


--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--========================================================================
-- PROCEDURE : Import_contracts       PRIVATE
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--             P_mode           in    Validate Only, Import flag
--             P_batch_id       in    Batch Number
--             P_Num_Workers    in    Number of workers
--  	       P_commit_size    in    Work unit size
-- COMMENT   : This procedure is the manager in AD parallel framework
--             to trigger workers for import process
--=========================================================================
PROCEDURE Import_contracts (X_errbuf         OUT NOCOPY VARCHAR2,
                            X_retcode        OUT NOCOPY VARCHAR2,
                            P_mode           IN  VARCHAR2,
                            P_batch_id	     IN  NUMBER,
                            P_Num_Workers    IN  NUMBER,
	  		    P_commit_size    IN  NUMBER);

END OKS_IMPORT_CONTRACTS;

/

--------------------------------------------------------
--  DDL for Package OKS_IMPORT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_PURGE" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPPRGS.pls 120.0 2007/07/12 13:19:18 vmutyala noship $
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
--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

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
	  	 P_commit_size    IN  NUMBER);

END OKS_IMPORT_PURGE;

/

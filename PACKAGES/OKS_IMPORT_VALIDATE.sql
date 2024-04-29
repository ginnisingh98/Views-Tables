--------------------------------------------------------
--  DDL for Package OKS_IMPORT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_VALIDATE" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPVALS.pls 120.0 2007/07/12 13:30:11 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPVALS.pls   Created By Vamshi Mutyala                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Validations Package                       |
--|                                                                       |
--+========================================================================

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
--========================================================================
-- PROCEDURE : Validate_Contracts     PUBLIC
-- PARAMETERS: P_batch_id              IN   Batch Id
--             P_rowid_from            IN   AD worker start rowid
--             P_rowid_to              IN   AD worker end rowid
-- COMMENT   : This procedure will perform the validation needed
--             on the interface records before importing service contracts
--=========================================================================

PROCEDURE Validate_Contracts(P_batch_id	        IN VARCHAR2,
			     P_rowid_from	IN ROWID,
 			     P_rowid_to	        IN ROWID);
END OKS_IMPORT_VALIDATE;

/

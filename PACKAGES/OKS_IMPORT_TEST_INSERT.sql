--------------------------------------------------------
--  DDL for Package OKS_IMPORT_TEST_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_TEST_INSERT" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPUTS.pls 120.0 2007/08/20 14:07:39 vmutyala noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPUTS.pls   Created By Vamshi Mutyala                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import QA Test facilitator Package               |
--|                                                                       |
--+========================================================================

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
--========================================================================
-- PROCEDURE : Insert_Interface_Records     PUBLIC
-- PARAMETERS: X_errbuf         out   Error message buffer
--             X_retcode        out   Return status code
--             p_contract_number          IN   Model contract number
--             p_num_scenarios            IN   Number of copies to be made
-- COMMENT   : This procedure will insert records into Service Contracts
--	       interface tables with data from model contract with unique
--             interface ids and modifier number.
--=========================================================================
PROCEDURE Insert_Interface_Records (X_errbuf          OUT NOCOPY VARCHAR2,
                                    X_retcode         OUT NOCOPY VARCHAR2,
				    p_contract_number IN VARCHAR2,
   				    p_contract_modifier IN VARCHAR2,
				    p_target_contract IN VARCHAR2,
                                    p_num_scenarios IN NUMBER);

END OKS_IMPORT_TEST_INSERT;

/

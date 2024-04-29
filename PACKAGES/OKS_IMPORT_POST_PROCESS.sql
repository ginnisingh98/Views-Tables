--------------------------------------------------------
--  DDL for Package OKS_IMPORT_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_POST_PROCESS" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPPOPS.pls 120.0 2007/09/11 11:56:05 mkarra noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPPOPS.pls   Created By Mihira Karra			  |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Post Process Routines Package             |
--|							                  |
--+========================================================================

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--==========================================================================
-- PROCEDURE : Import_Post_Process     PUBLIC
-- PARAMETERS:
-- COMMENT   : This procedure will invoke API's for Instantiating
--	       Work Flows
--===========================================================================

PROCEDURE Import_Post_Process ;

END OKS_IMPORT_POST_PROCESS ;

/

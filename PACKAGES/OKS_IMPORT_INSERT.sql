--------------------------------------------------------
--  DDL for Package OKS_IMPORT_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_INSERT" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPINSS.pls 120.0 2007/08/21 12:40:53 mkarra noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPINSS.pls   Created By Mihira Karra			  |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Insert Routines Package                   |
--|							                  |
--+========================================================================

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
--==========================================================================
-- PROCEDURE : Insert_Contracts     PUBLIC
-- PARAMETERS:
-- COMMENT   : This procedure will insert the successfully
--	       validated/processed Contract records from interface
--	       tables into actual base tables.
--===========================================================================

PROCEDURE Insert_Contracts ;

END OKS_IMPORT_INSERT;

/

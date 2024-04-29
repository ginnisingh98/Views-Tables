--------------------------------------------------------
--  DDL for Package OKS_IMPORT_POST_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IMPORT_POST_INSERT" AUTHID CURRENT_USER AS
-- $Header: OKSPKIMPPOIS.pls 120.0 2007/09/11 10:56:38 mkarra noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OKSPKIMPPOIS.pls   Created By Mihira Karra			  |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Post Insert Routines Package              |
--|							                  |
--+========================================================================

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--==========================================================================
-- PROCEDURE : Import_Post_Insert     PUBLIC
-- PARAMETERS:
-- COMMENT   : This procedure will generate/invoke API's for processing of
--	       Various Post_insert Routines : 1.Generate_billing_schedules
--					      2.Generate_PM_schedules
--					      3.Create_JTF_notes
--					      4.Instantiate_srvc_ctr_events
--					      5.Rollup_amounts
--
--===========================================================================

PROCEDURE Import_Post_Insert ;

END OKS_IMPORT_POST_INSERT;

/

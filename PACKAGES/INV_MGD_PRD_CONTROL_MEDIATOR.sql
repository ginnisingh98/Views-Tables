--------------------------------------------------------
--  DDL for Package INV_MGD_PRD_CONTROL_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_PRD_CONTROL_MEDIATOR" AUTHID CURRENT_USER AS
/*  $Header: INVMOCLS.pls 120.1 2006/03/09 03:56:12 vmutyala noship $ */

--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMOCLS                                                          |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of    INV_MGD_OPEN_CLOSE_MEDIATOR                    |
--|                                                                       |
--| HISTORY                                                               |
--|     25-Sep-2000  rajkrish            Created                          |
--|     12-DEc-2000  rajkrish            Updated    Hier origin           |
--|     12/04/2001   vjavli              updated with new APIs for        |
--|                                      performance improvement          |
--|     09/09/2003   vjavli              NOCOPY added as per standard     |
--+=======================================================================+


--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs):
RETCODE_SUCCESS				VARCHAR2(10)	:= '0';
RETCODE_WARNING				VARCHAR2(10)	:= '1';
RETCODE_ERROR		  		VARCHAR2(10)	:= '2';

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Period_Control

-- COMMENT   : This is the Wrapper program mediator that invokes the
--             Inventory API for Open and Close periods

--=======================================================================
PROCEDURE Period_Control
        ( x_retcode              OUT   NOCOPY VARCHAR2
        , x_errbuff              OUT   NOCOPY VARCHAR2
        , p_org_hierarchy_origin IN    NUMBER
   	, p_org_hierarchy_id	 IN    NUMBER
        , p_close_period_name    IN    VARCHAR2
	, p_close_if_res_recmd   IN    VARCHAR2
        , p_open_period_count    IN    NUMBER
        , p_open_or_close_flag   IN    VARCHAR2
        , p_requests_count       IN    NUMBER
        );



END INV_MGD_PRD_CONTROL_MEDIATOR ;


 

/

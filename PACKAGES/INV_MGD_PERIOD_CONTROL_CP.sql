--------------------------------------------------------
--  DDL for Package INV_MGD_PERIOD_CONTROL_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_PERIOD_CONTROL_CP" AUTHID CURRENT_USER AS
/* $Header: INVCPOPS.pls 120.1 2006/03/09 03:43:28 vmutyala noship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCPOPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_OPEN_PERIODS_CP                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     08/28/00 rajkrish        Created                                  |
--|     12/DEc/2000        rajkrish   hierarchy_orign                     |
--|     12/05/2001     vjavli  updated with new apis for performance      |
--|                            improvement                                |
--|     03-FEB-2004  nkamaraj   x_errbuff and x_retcode should be in order|
--|                           according to AOL standards inorder to       |
--|                           display warning and error messages.         |
--|                           Otherwise, conc. manager will consider as   |
--|                           completed normal eventhough exception raised|

--+======================================================================*/


--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs)
RETCODE_SUCCESS				VARCHAR2(10)	:= '0';
RETCODE_WARNING				VARCHAR2(10)	:= '1';
RETCODE_ERROR				VARCHAR2(10)	:= '2';


--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--========================================================================
-- PROCEDURE : Run_Open_Periods        PUBLIC
-- PARAMETERS: x_retcode               return status
--             x_errbuf                return error messages
--             p_org_hierarchy_origin  IN    NUMBER
--             p_org_hierarchy_id      IN    NUMBER
--             p_close_period_name     IN    VARCHAR2
--             p_open_period_count     IN    NUMBER
--             p_open_or_close_flag    IN    VARCHAR2
--             p_requests_count        IN    NUMBER
--
-- COMMENT   : The concurrent program to Open / Close periods for
--              each organization in
--              organization hierarchy level list.

--=========================================================================
PROCEDURE Run_Period_Control
	(	     x_errbuf	         OUT NOCOPY  VARCHAR2
        ,        x_retcode             OUT NOCOPY  VARCHAR2
        ,        p_org_hierarchy_origin	 IN    NUMBER
   	,	 p_org_hierarchy_id	 IN    NUMBER
        ,        p_close_period_name     IN    VARCHAR2
	,        p_close_if_res_recmd    IN    VARCHAR2
        ,        p_open_period_count     IN    NUMBER
        ,        p_open_or_close_flag    IN    VARCHAR2
        ,        p_requests_count        IN    NUMBER
        );


END INV_MGD_PERIOD_CONTROL_CP ;


 

/

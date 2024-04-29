--------------------------------------------------------
--  DDL for Package HZ_MGD_MASS_UPDATE_REP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MGD_MASS_UPDATE_REP_GEN" AUTHID CURRENT_USER AS
/* $Header: ARHCMURS.pls 115.1 2002/11/27 22:01:42 tsimmond noship $ */

/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      ARHCMURS.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to generate output report for Mass uopdate       |
--|                                                                       |
--| HISTORY                                                               |
--|     05/22/2002 tsimmond    Created                                    |
--|     11/27/2002 tsimmond    Updated   Added WHENEVER OSERROR EXIT      |
--|                                      FAILURE ROLLBACK                 |
--+======================================================================*/


--===================
-- CONSTANTS
--===================

G_RPT_PAGE_COL           CONSTANT INTEGER  :=130;
G_FORMAT_SPACE           CONSTANT INTEGER  :=2;
--
G_LOG_ERROR              CONSTANT NUMBER := 5;
G_LOG_EXCEPTION          CONSTANT NUMBER := 4;
G_LOG_EVENT              CONSTANT NUMBER := 3;
G_LOG_PROCEDURE          CONSTANT NUMBER := 2;
G_LOG_STATEMENT          CONSTANT NUMBER := 1;

G_PROF_NUMBER    NUMBER;

--===================
-- PROCEDURE : Initialize                  PUBLIC
-- PARAMETERS:
-- COMMENT   : This is the procedure to initialize pls/sql tables
--             for recording action information of vendor conversion.
--===================
PROCEDURE Initialize;


--========================================================================
-- PROCEDURE : Log      PUBLIC
-- PARAMETERS: p_level  IN  priority of the message -
--                      from highest to lowest:
--                      G_LOG_ERROR
--                      G_LOG_EXCEPTION
--                      G_LOG_EVENT
--                      G_LOG_PROCEDURE
--                      G_LOG_STATEMENT
--             p_msg    IN  message to be print on the log file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
);



--==========================================================================
-- PROCEDURE : Add_Exp_Item          PUBLIC
-- PARAMETERS: p_party               name of the party not updated
--             p_customer            name of the customer  not updated
--             p_site                name of the customer site not updated
--
-- COMMENT   : This is the procedure to record exception information into g_exp_table.
--
--==========================================================================
PROCEDURE Add_Exp_Item
( p_party       IN VARCHAR2
, p_customer    IN VARCHAR2
, p_site        IN VARCHAR2
);


--====================
-- PROCEDURE : Generate_Report             PUBLIC
-- PARAMETERS: p_cust_prof_class           Name of the profile class
--             p_currency_code             Profile currency
--             p_rule_set                  Name of the rule set
--
-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_prof_class_id             IN NUMBER
, p_currency_code             IN VARCHAR2
, p_profile_class_amount_id   IN NUMBER
);


END HZ_MGD_MASS_UPDATE_REP_GEN;

 

/

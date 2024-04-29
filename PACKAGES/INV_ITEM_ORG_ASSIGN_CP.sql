--------------------------------------------------------
--  DDL for Package INV_ITEM_ORG_ASSIGN_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_ORG_ASSIGN_CP" AUTHID CURRENT_USER AS
/* $Header: INVCOSGS.pls 115.13 2004/07/07 10:21:56 nesoni ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCOSGS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_ITEM_ORG_ASSIGN_CP                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     09/01/00 vjavli        Created                                    |
--|     09/12/00 vjavli        Updated with category_id                   |
--|     09/28/00 vjavli        Updated with parameters category set,      |
--|                            category structure                         |
--|     12/11/00 vjavli        signature updated to p_org_hier_level_id   |
--|     05/28/01 pjuvara       Added p_request_count parameter            |
--|     11/20/01 vjavli        modified according to new api's to         |
--|                            improve the performance                    |
--|     01/20/04 nkilleda   >  modified the Item_Org_Assignment procedure |
--|                            to accept a new input parameter source org |
--|                            id of type number for bug# 3306087         |
--|                         >  x_errbuff, x_retcode should be in order    |
--|                            according to AOL standards                 |
--|     06/22/2004 nesoni      Bug 2642331. Interface of procedure        |
--|                            Item_Org_Assignment is modified to accept  |
--|                            parameter p_category_set_name as NUMERIC.  |
--|                            Earlier it was VARCHAR2. Parameter text    |
--|                            is replaced from p_category_set_name to    |
--|                            p_category_set_id.                         |
--+======================================================================*/

--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs):
RETCODE_SUCCESS				VARCHAR2(10)	:= '0';
RETCODE_WARNING				VARCHAR2(10)	:= '1';
RETCODE_ERROR		  		VARCHAR2(10)	:= '2';

-- =======================================================================
-- Global PL/SQL table to store GL Account Info,starting revision and
-- GL valid flag of organizations in the Organization List
-- =======================================================================
TYPE g_org_gl_rev_rec_type IS RECORD
( organization_id       NUMBER
, cost_of_sales_account NUMBER
, encumbrance_account   NUMBER
, sales_account         NUMBER
, expense_account       NUMBER
, starting_revision     VARCHAR2(3)
, valid_flag            VARCHAR2(1)
);

TYPE g_org_gl_rev_table_type IS TABLE OF g_org_gl_rev_rec_type
INDEX BY BINARY_INTEGER;

G_ORG_GL_REV_TBL   g_org_gl_rev_table_type;

--========================================================================
-- FUNCTION  : Get_cost_of_sales_account  PUBLIC
-- COMMENT   : This function is to get the Cost of Sales Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_cost_of_sales_account(p_organization_id  IN NUMBER)
RETURN NUMBER;


--========================================================================
-- FUNCTION  : Get_encumbrance_account  PUBLIC
-- COMMENT   : This function is to get the Encumbrance Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization_id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_encumbrance_account(p_organization_id  IN NUMBER)
RETURN NUMBER;


--========================================================================
-- FUNCTION  : Get_sales_account  PUBLIC
-- COMMENT   : This function is to get the Sales Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_sales_account(p_organization_id  IN NUMBER)
RETURN NUMBER;


--========================================================================
-- FUNCTION  : Get_expense_account  PUBLIC
-- COMMENT   : This function is to get the Expense Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_expense_account(p_organization_id  IN NUMBER)
RETURN NUMBER;


--========================================================================
-- FUNCTION  : Get_start_revision  PUBLIC
-- COMMENT   : This function is to get the starting revision from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_start_revision(p_organization_id  IN NUMBER )
RETURN VARCHAR2;

--========================================================================
-- PROCEDURE : Set_Unit_Test_Mode      PUBLIC
-- COMMENT   : This procedure sets the unit test mode that prevents the
--             program from attempting to submit concurrent requests and
--             enables it to run it from SQL*Plus. The Item Interface will
--             not be run.
--=========================================================================
PROCEDURE  Set_Unit_Test;


--========================================================================
-- PROCEDURE : Item_Org_Assignment     PUBLIC
-- PARAMETERS: x_errbuff               return error message
--             x_retcode               return status
--             p_source_org_id         IN Source Org. : # Bug 3306087
--             p_org_hier_origin_id    IN Organization Hierarchy
--                                        Origin Id
--             p_org_hierarchy_id      IN Organization Hierarchy Id
--             where all the organizations for the selected hierarchy origin in
--             each hierarchy share the same item master.
--             p_category_set_name     IN Category set name
--             p_category_struct       IN Category Structure used by category pair
--             p_category_from         IN Item Category name from
--             p_category_to           IN Item Category name to
--             p_item_from             IN From Item Number
--             p_item_to               IN To Item Number
--             p_request_count         IN Maximum number of workers
--
-- COMMENT   : This is a procedure which creates new items for all the
--             organizations in an hierarchy origin. This also include the
--             hierarchy level itself.
--=========================================================================
/* Bug 2642331. Interface of procedure Item_Org_Assignment is modified to accept
 * parameter p_category_set_name as NUMERIC.Earlier it was VARCHAR2. Parameter text
 * is replaced from p_category_set_name to p_category_set_id
 */
PROCEDURE  Item_Org_Assignment
( x_errbuff            OUT   NOCOPY VARCHAR2
, x_retcode            OUT   NOCOPY VARCHAR2
, p_source_org_id      IN    NUMBER -- new parameter added for #3306087
, p_org_hier_origin_id IN    NUMBER
, p_org_hierarchy_id   IN    NUMBER
--, p_category_set_name  IN    VARCHAR2  made it numeric from varchar.
--Parameter text is replaced from p_category_set_name to p_category_set_id Bug:2642331
, p_category_set_id    IN    NUMBER
, p_category_struct    IN    NUMBER
, p_category_from      IN    VARCHAR2
, p_category_to        IN    VARCHAR2
, p_item_from          IN    VARCHAR2
, p_item_to            IN    VARCHAR2
, p_request_count      IN    NUMBER   DEFAULT 1
);

END INV_ITEM_ORG_ASSIGN_CP;

 

/

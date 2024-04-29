--------------------------------------------------------
--  DDL for Package CST_MGD_MSTR_BOOK_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_MSTR_BOOK_RPT" AUTHID CURRENT_USER AS
	-- $Header: CSTGMBKS.pls 120.0.12010000.13 2009/10/13 17:52:27 rapulla ship $
	--+=======================================================================+
	--|               Copyright (c) 1999 Oracle Corporation                   |
	--|                       Redwood Shores, CA, USA                         |
	--|                         All rights reserved.                          |
	--+=======================================================================+
	--| FILENAME                                                              |
	--|     CSTGMBKS.pls                                                      |
	--|                                                                       |
	--| DESCRIPTION                                                           |
	--|     Spec. for Inventory Master Book Report data generation            |
	--|                                                                       |
	--| HISTORY                                                               |
	--|     07/16/1999 ksaini      Created from CSTRIADS.pls                  |
	--|     08/30/1999 ksaini      Remove ABC Class Name and Assignment       |
	--|                            Group name from the temp table             |
	--|     06/22/2003 vjavli      Procedure Create_Infl_Adj_Rpt removed      |
	--|                            since this api is not invoked by any       |
	--|                            of the inflation reports                   |
	--|                            This has removed inter dependency          |
	--|                            between master book and inflation reports  |
	--|                                                                       |
	--|     06/01/2009   vputchal  Italy and China Enhancements from SSI      |
	--|                            localization team. Package re-designed     |
	--|     09/07/2009   ppandit   Changed datatypes for p_legal_entity,      |
        --|                            p_ledger_id and p_inventory_org in Italy - |
        --|                            China Enhancements from SSI. Added function|
        --|                            get_date_from and get_date_to, improved    |
        --|                            get_po_number. Used REF CURSOR for table   |
        --|                            insertion logic. Added p_dummy,            |
        --|                            p_all_or_single, get_org_details           |
	--|     09/16/2009   ppandit   Added following functions for XML elements |
        --|                            get_inv_org,                               |
        --|                            get_subinv_org_from,                       |
        --|                            get_subinv_org_to,                         |
        --|                            get_category_set_from,                     |
        --|                            get_category_set_to,                       |
        --|                            get_category_from,                         |
        --|                            get_category_to,                           |
        --|                            get_item_from,                             |
        --|                            get_item_to,                               |
        --|                            get_abc_class,                             |
        --|                            get_break_by_desc,                         |
        --|                            get_all_or_one,                            |
        --|                            get_icx_date,                              |
        --|                            get_page_penultimate,                      |
        --|                            get_suborg_details                         |
        --|     09/29/2009   ppandit   Added get_begin_columns, get_end_columns   |
        --|     10/05/2009   ppandit   Added get_summ_beg_cols, get_summ_end_cols |
	--+=======================================================================+

/* These are the parameters given in the concurrent program definition */

	  P_DETAIL                VARCHAR2(10);
	  P_DATE_FROM             VARCHAR2(25);
	  P_DATE_TO               VARCHAR2(25);
          P_BREAK_BY              VARCHAR2(100);
	  P_FISCAL_YEAR           VARCHAR2(100);
	  P_PAGE_NUMBER           VARCHAR2(100);
	  P_ITEM_CODE_FROM        VARCHAR2(2400);
	  P_ITEM_CODE_TO          VARCHAR2(2400);
	  P_LEGAL_ENTITY          NUMBER;        -- Changed by ppandit for Italy and China JF Project
          P_LEDGER_ID             NUMBER;        -- Changed by ppandit for Italy and China JF Project
	  P_INVENTORY_ORG         NUMBER;        -- Changed by ppandit for Italy and China JF Project
	  P_DUMMY                 VARCHAR2 (30); -- Added by ppandit for Italy and China JF Project
	  P_ALL_OR_SINGLE         VARCHAR2 (30); -- Added by ppandit for Italy and China JF Project
	  P_CATEGORY_SET_ID_FROM  NUMBER;        -- Added by ppandit for Italy and China JF Project
	  P_CATEGORY_SET_ID_TO    NUMBER;        -- Added by ppandit for Italy and China JF Project
          P_CATEGORY_STRUCTURE    VARCHAR2(240);
	  P_CATEGORY_FROM         VARCHAR2(240);
	  P_CATEGORY_TO           VARCHAR2(240);
	  P_SUBINV_FROM           VARCHAR2(100);
	  P_ABC_CLASS_ID          NUMBER;
	  P_INCLUDE_ITEM_COST     VARCHAR2(1);
	  P_ABC_GROUP_ID          NUMBER;
	  P_SUBINV_TO             VARCHAR2(100);
 	  P_ORG_ID                NUMBER;
	  P_DATE_FROM_FORMATTING  VARCHAR2(25);
	  P_DATE_TO_FORMATTING    VARCHAR2(25);

     /* Global Variables */
	  GN_PRECISION_VAL        NUMBER;
          GN_ROW_COUNT            NUMBER := -1;
  	  GC_REQUEST_TIME         VARCHAR2(30);
          GC_RESPONSIBILITY       VARCHAR2(100);
	  GC_APPLICATION          VARCHAR2(240);
	  GC_REQUESTED_BY         VARCHAR2(100);
	  GC_INCLUDE_COST         VARCHAR2(80);
	  GC_DETAIL               VARCHAR2(80);
	  GC_BREAK                VARCHAR2(100);
	  GC_ABC_GROUP_NAME       VARCHAR2(40);
	  GC_ABC_CLASS_NAME       VARCHAR2(40);
	  GC_CATEGORY_SET_NAME_1  VARCHAR2(30);
	  GC_CATEGORY_SET_NAME_2  VARCHAR2(30);
	  GC_CURRENCY_CODE        VARCHAR2(3);
	  GD_RPT_DATE_FROM        DATE;
	  GD_RPT_DATE_TO          DATE;

	--===================
	-- PUBLIC PROCEDURES
	--===================

-- +==========================================================================+
-- PROCEDURE: create_inv_msbk_rpt
-- PARAMETERS:
--   p_org_id                IN  NUMBER
--   p_category_set_id_from  IN  NUMBER
--   p_category_set_id_to    IN  NUMBER
--   p_category_from         IN  VARCHAR2
--   p_category_to           IN  VARCHAR2
--   p_subinv_from           IN  VARCHAR2
--   p_subinv_to             IN  VARCHAR2
--   p_abc_group_id          IN  NUMBER
--   p_abc_class_id          IN  NUMBER
--   p_item_from_code        IN  VARCHAR2
--   p_item_to_code          IN  VARCHAR2
--   p_rpt_from_date         IN  VARCHAR2
--   p_rpt_to_date           IN  VARCHAR2
-- COMMENT:
-- This procedure is called by Inventory Master Book Report
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
PROCEDURE create_inv_msbk_rpt (
                               p_org_id               IN  NUMBER
                              ,p_category_set_id_from IN  NUMBER
                              ,p_category_set_id_to   IN  NUMBER
                              ,p_category_from        IN  VARCHAR2
                              ,p_category_to          IN  VARCHAR2
                              ,p_subinv_from          IN  VARCHAR2
                              ,p_subinv_to            IN  VARCHAR2
                              ,p_abc_group_id         IN  NUMBER
                              ,p_abc_class_id         IN  NUMBER
                              ,p_item_from_code       IN  VARCHAR2
                              ,p_item_to_code         IN  VARCHAR2
                              ,p_rpt_from_date        IN  VARCHAR2
                              ,p_rpt_to_date          IN  VARCHAR2
                              );

/* Added for Italy Joint Project  */
-- +==========================================================================+
-- FUNCTION: get_org_details
-- PARAMETERS:
-- p_org_id     IN NUMBER
-- p_number     IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Org details
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_org_details (p_org_id IN NUMBER, p_number IN NUMBER)
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_suborg_details
-- PARAMETERS:
-- p_subinvname IN VARCHAR2
-- p_org_id     IN NUMBER
-- p_number     IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Sub Org details
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_suborg_details (
                             p_subinvname IN VARCHAR2
                            ,p_org_id     IN NUMBER
                            ,p_number     IN NUMBER
                            )
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_begin_columns
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Begin Cost, Quantity and Value when Break By is Item
-- and report is running for ALL Inventory Organizations
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_begin_columns (
                            p_inventory_item_id  IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_end_columns
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the End Cost, Quantity and Value when Break By is Item
-- and report is running for ALL Inventory Organizations
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_end_columns (
                          p_inventory_item_id  IN NUMBER
                         ,p_type               IN NUMBER
                         )
RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_summ_beg_cols
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_organization_id    IN NUMBER
-- p_sub_inv_org_name   IN VARCHAR2
-- p_sub_inv_org_id     IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Begin Cost, Quantity and Value when report is running for
-- detail as Summary
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_summ_beg_cols (
                            p_inventory_item_id  IN NUMBER
                           ,p_organization_id    IN NUMBER
                           ,p_sub_inv_org_name   IN VARCHAR2
                           ,p_sub_inv_org_id     IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_summ_end_cols
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_organization_id    IN NUMBER
-- p_sub_inv_org_name   IN VARCHAR2
-- p_sub_inv_org_id     IN NUMBER
-- p_type               IN NUMBER
--
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the End Cost, Quantity and Value when report is running for
-- detail as Summary
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_summ_end_cols (
                            p_inventory_item_id  IN NUMBER
                           ,p_organization_id    IN NUMBER
                           ,p_sub_inv_org_name   IN VARCHAR2
                           ,p_sub_inv_org_id     IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_break_by
-- PARAMETERS: NONE
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the break by details
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_break_by
RETURN NUMBER;

--========================================================================
-- FUNCTION : get_detail_param         Public
-- PARAMETERS: None
-- RETURN :    VARCHAR2
-- COMMENT   : This function is called by Inventory Master Book Report to gets p_detail
-- EXCEPTIONS: no_data_found
--========================================================================
FUNCTION get_detail_param
RETURN VARCHAR2;

--========================================================================
-- FUNCTION : get_include_item_cost         Public
-- PARAMETERS: None
-- RETURN :    VARCHAR2
-- COMMENT   : This Function is called by Inventory Master Book Report to gets the break by p_include_item_cost
-- EXCEPTIONS: no_data_found
--========================================================================
FUNCTION get_include_item_cost
RETURN VARCHAR2;

-- +========================================================================+
-- FUNCTION: beforereport
-- PARAMETERS: NONE
-- RETURN: BOOLEAN
-- COMMENT:
-- This function is called by XML of Inventory Master Book Report
-- PRE-COND:    none
-- EXCEPTIONS:  none
-- +==========================================================================+
FUNCTION beforereport
RETURN BOOLEAN;

-- +==========================================================================+
-- FUNCTION: get_abc_group_name
-- PARAMETERS: None
-- Return : VARCHAR2
-- COMMENT:
-- This function is called by Inventory Master Book Report for getting the ABC Group Name
-- for a given ABC Group
-- PRE-COND:    none
-- EXCEPTIONS:  none
-- +==========================================================================+
FUNCTION get_abc_group_name
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_shipment_num
-- PARAMETERS:
-- p_transaction_id  IN  NUMBER
-- COMMENT:
-- This procedure is called by Inventory Master Book Report
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_shipment_num (p_transaction_id NUMBER)
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_waybill
-- PARAMETERS:
-- p_transaction_id  IN  NUMBER
-- COMMENT:
-- This procedure is called by the Inventory Master Book Report
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_waybill (p_transaction_id NUMBER)
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_po_number
-- PARAMETERS:
-- p_transaction_id IN NUMBER
-- p_type           IN VARCHAR2
-- COMMENT:
-- This procedure is called by Inventory Master Book Report
-- RETURN:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_po_number (p_transaction_id IN NUMBER, p_type IN VARCHAR2) -- Added p_type by ppandit for Italy - China Enhancements
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_detail_level
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the Inventory Master Book Report to get the detail level
-- like Summary, Detail, Intermidiate
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_detail_level
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_date_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Lower of Date Range
-- Added by ppandit for Italy and China JF Project
-- RETURN: VARCHAR2
-- +==========================================================================+
FUNCTION get_date_from
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_date_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Higher of Date Range
--
-- RETURN: VARCHAR2
-- +==========================================================================+
FUNCTION get_date_to
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_trx_action
-- PARAMETERS: p_transaction_id
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Higher of Date Range
-- Added by ppandit for Italy and China JF Project
-- RETURN: VARCHAR2
-- +==========================================================================+
FUNCTION get_trx_action (p_transaction_id IN NUMBER)
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_include_cost
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the Inventory Master Book Report which returns 'Y/N'
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_include_cost
RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: getledger_name
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get the name of the Ledger
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION getledger_name RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_inv_org
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Inventory Org
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_inv_org RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_subinv_org_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Subinventory From
-- RETURN: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_subinv_org_from RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_subinv_org_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Subinventory To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_subinv_org_to RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_category_set_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Category Set From
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_set_from RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_category_set_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Category Set To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_set_to RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_category_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Category From
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_from RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_category_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get to get Category To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_to RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_item_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Item Code From
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_item_from RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_item_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Item Code To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_item_to RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_abc_class
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get ABC Class
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_abc_class RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_break_by_desc
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Break By meaning
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_break_by_desc RETURN VARCHAR2;
-- +==========================================================================+
-- FUNCTION: get_all_or_one
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- All or One parameter
--
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_all_or_one RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_icx_date
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Sysdate as per ICX Date Format
--
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_icx_date RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_page_penultimate
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Page Numbering minus one
--
-- Return: NUMBER
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_page_penultimate RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_row_count
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get record count
--
-- Return: NUMBER
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_row_count RETURN NUMBER;

-- +==========================================================================+
-- FUNCTION: get_category_structure
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Item or Category Flexfields segments
--
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_structure (
                                 p_type          IN VARCHAR2
                                ,p_cat_struct_id IN NUMBER
                                )
  RETURN VARCHAR2;

-- +==========================================================================+
-- FUNCTION: get_structure_id
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Category Structure ID
--
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_structure_id (p_category_set_id IN NUMBER) RETURN NUMBER;

END CST_MGD_MSTR_BOOK_RPT;

/

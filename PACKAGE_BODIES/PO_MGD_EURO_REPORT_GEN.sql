--------------------------------------------------------
--  DDL for Package Body PO_MGD_EURO_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MGD_EURO_REPORT_GEN" AS
/* $Header: POXREURB.pls 115.12 2002/11/23 02:07:42 sbull ship $ */

/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      POXREURB.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to generate output report for Euro conversion    |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Initialize                                                        |
--|     Log                                                               |
--|     Add_Item                                                          |
--|     Generate_Report                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     10/21/99 tsimmond        Created                                  |
--|     01/24/2000 tsimmond      Updated                                  |
--|     02/13/2001 tsimmond      Updated                                  |
--|    11/28/2001 tsimmond  updated, added dbrv and set verify off        |
--|    03/25/2002 tsimmond updated, code removed for patch 'H' remove     |
--+======================================================================*/
--===================
-- COMMENT : PL/SQL Table definition. This table will be used to record
--           log information.
--===================
TYPE EURO_REPORT_REC IS RECORD
( action          VARCHAR2(15)
, object_ref      VARCHAR2(30)
, copy_object_ref VARCHAR2(30)
, reason          VARCHAR2(40)
);


TYPE EURO_REPORT_TABLE IS TABLE OF EURO_REPORT_REC
     INDEX BY BINARY_INTEGER;


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_MGD_EURO_REPORT_GEN';


--===================
-- PUBLIC VARIABLES
--===================
g_program_type     VARCHAR2(30);
g_rec_no           NUMBER:=0;

-- BUG 2040015
g_mode             VARCHAR2(15);
g_log_level        NUMBER      := 5 ;
g_log_mode         VARCHAR2(240) :=
        NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_CONCURRENT_ON'),'N') ;

g_vendor_table     PO_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_ven_site_table   PO_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_ven_bank_table   PO_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_po_table         PO_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;

--===================
-- PRIVATE PROCEDURES AND FUNCTIONS
--===================

--===================
-- PROCEDURE : Initialize                  PUBLIC
-- PARAMETERS:
-- COMMENT   : This is the procedure to initialize pls/sql tables
--             for recording action information of vendor conversion.
--===================
PROCEDURE Initialize
IS
BEGIN

  NULL;

END Initialize;

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
)
IS
BEGIN

  NULL;

END Log;


--===================
-- PROCEDURE : Add_Item              PUBLIC
-- PARAMETERS: p_object_type         converted object
--             p_action_code         convert,ignore,copy
--             p_object_ref          name of the converted object
--             p_copy_object_ref     name of the new object after convertion
--             p_reason_code         why object wasn't converted
-- COMMENT   : This is the procedure to record action information.
--====================
PROCEDURE Add_Item
( p_object_type        IN VARCHAR2
, p_action_code        IN VARCHAR2
, p_object_ref         IN VARCHAR2
, p_copy_object_ref    IN VARCHAR2 DEFAULT NULL
, p_reason_code        IN VARCHAR2 DEFAULT NULL
)
IS
BEGIN

  NULL;

END Add_Item;


--====================
-- PROCEDURE : Generate_Report             PUBLIC
-- PARAMETERS: p_vendor_id                 Supplier ID
--             p_vendor_site_code          Supplier Site ID
--             p_site_conversion_ncu       supplier site initial currency
--             p_convert_standard_flag     Y/N convert Standard POs?
--             p_convert_blanket_flag      Y/N convert Blanket POs?
--             p_convert_planned_flag      Y/N convert Planned POs?
--             p_convert_contract_flag     Y/N convert Contract POs?
--             p_po_conversion_ncu         PO initial currency
--             p_conv_partial              Indicates if partially transacted
--                                         PO need to be converted
--             p_upd_db_flag               Y/N update db with supplier conversion?
--
-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_vendor_id                 IN NUMBER
, p_vendor_site_id            IN NUMBER   DEFAULT NULL
, p_vsite_conversion_ncu      IN VARCHAR2 DEFAULT NULL
, p_convert_standard_flag     IN VARCHAR2 DEFAULT 'N'
, p_convert_blanket_flag      IN VARCHAR2 DEFAULT 'N'
, p_convert_planned_flag      IN VARCHAR2 DEFAULT 'N'
, p_convert_contract_flag     IN VARCHAR2 DEFAULT 'N'
, p_po_conversion_ncu         IN VARCHAR2 DEFAULT NULL
, p_conv_partial              IN VARCHAR2 DEFAULT 'N'
, p_upd_db_flag               IN VARCHAR2 DEFAULT 'N'
)
IS
BEGIN

  NULL;

END Generate_Report;


END PO_MGD_EURO_REPORT_GEN;

/

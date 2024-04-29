--------------------------------------------------------
--  DDL for Package Body ONT_MGD_EURO_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_MGD_EURO_REPORT_GEN" AS
-- $Header: ONTREURB.pls 120.0 2005/06/01 00:19:43 appldev noship $
---=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      ONTREURB.pls                                                     |
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
--|     17-Aug-2000           Created
--|     Jul-20-2001 rajkrish BUG 1881301 tca table
--|     03-APR-2002  tsimmond   removed code                              |
--+======================================================================-

--===================
-- COMMENT : PL/SQL Table definition. This table will be used to record
--           log information.
--===================
TYPE EURO_REPORT_REC IS RECORD
( action          VARCHAR2(100)
, object_ref      VARCHAR2(30)
, copy_object_ref VARCHAR2(30)
, reason          VARCHAR2(100)
);


TYPE EURO_REPORT_TABLE IS TABLE OF EURO_REPORT_REC
     INDEX BY BINARY_INTEGER;


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ONT_MGD_EURO_REPORT_GEN';


--===================
-- PUBLIC VARIABLES
--===================
g_program_type     VARCHAR2(30);
g_rec_no           NUMBER :=0;
g_mode             VARCHAR2(15);
g_log_level        NUMBER      :=
       NVL(FND_PROFILE.VALUE('ONT_DEBUG_LEVEL'),5) ;

g_log_mode         VARCHAR2(3) := 'OFF'; -- possible values: OFF, SQL, SRS
g_customer_table   ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_cust_site_table  ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_price_list_table ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_modifiers_table  ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_so_table         ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;
g_formulas_table   ONT_MGD_EURO_REPORT_GEN.EURO_REPORT_TABLE;



--===================
--PROCEDURES AND FUNCTIONS
--===================

--===================
-- PROCEDURE : Initialize                  PUBLIC
-- PARAMETERS: p_program_type              customer or vendor program
-- COMMENT   : This is the procedure to initialize pls/sql tables
--             for recording action information.
--===================
PROCEDURE Initialize
IS
BEGIN

  NULL;
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

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
( p_priority                    IN  NUMBER := 10
, p_msg                         IN  VARCHAR2
)
IS
BEGIN

  NULL;
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

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
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Add_Item;

--====================
-- PROCEDURE : Generate_Report             PUBLIC
-- PARAMETERS: p_customer_num              customer number
--             p_customer_address_id       customer site address
--             p_convert_so_flag           Y/N convert SOs?
--             p_so_conversion_ncu         SO initial currency
--             p_convert_partial_so        Y/N convert SO with partial shipment
--             p_line_invoice_to_org_id    Line level Bill to site
--             p_so_reprice_flag           Reiprice flag

-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_customer_num             IN VARCHAR2
, p_customer_name            IN VARCHAR2
, p_customer_id              IN NUMBER
, p_customer_address_id      IN NUMBER
, p_so_conversion_ncu        IN VARCHAR2
, p_convert_so_flag          IN VARCHAR2
, p_convert_partial_so       IN VARCHAR2
, p_line_invoice_to_org_id   IN NUMBER
, p_so_reprice_flag          IN VARCHAR2
)
IS
BEGIN

  NULL;
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Generate_Report;


END ONT_MGD_EURO_REPORT_GEN ;

/

--------------------------------------------------------
--  DDL for Package Body ONT_MGD_EURO_OE_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_MGD_EURO_OE_MEDIATOR" AS
/*  $Header: ONTMSOXB.pls 120.0 2005/06/01 01:09:43 appldev noship $ */

---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ONTMSOXB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package Body  of  Euro Sales Order Conversion                      |
--|                                                                       |
--| HISTORY                                                               |
--|     10-Jul-2000  rajkrish            Created
--|     06-Jan-2000  rajkrish            Updated   reprice flag
--|     06-Apr-2000  rajkrish            convert new col, PATCH E
--|     Jan-17-2002  4PM rajkrish BUG 2185432
--|     Manufacturing Globalization Team
--|     03-APR-2002  tsimmond   removed code                              |
--+======================================================================

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ONT_MGD_EURO_OE_MEDIATOR' ;


  -- Global variable to hold the reason code if the
  -- Order conversion fails. This code is used for the
  -- Output report generation.

G_IGNORE_REASON     VARCHAR2(100) := NULL ;
G_rate              NUMBER;
G_HEADER_EURO_LIST_ID NUMBER;
G_HEADER_NCU_LIST_ID NUMBER;

TYPE EURO_LINE_REPORT_REC IS RECORD
( order_number       NUMBER
, line_id            NUMBER
, Line_nu            NUMBER
, action             VARCHAR2(100)
, reason             VARCHAR2(100)
);


TYPE EURO_LINE_REPORT_TABLE IS TABLE OF EURO_LINE_REPORT_REC
INDEX BY BINARY_INTEGER;

G_EURO_LINE_REPORT_TABLE   EURO_LINE_REPORT_TABLE ;

--===========================
-- PROCEDURES AND FUNCTIONS
--===========================

--========================================================================
-- PROCEDURE : Convert_sales_orders

-- COMMENT   : Main Logic to Convert the Sales Orders to Euro
--             This package converts the Open Sales Order to Euro
--=======================================================================
PROCEDURE Convert_sales_orders
( p_customer_id              IN NUMBER
, p_header_invoice_to_org_id IN NUMBER
, p_line_invoice_to_org_id   IN NUMBER
, p_so_conversion_ncu        IN VARCHAR2
, p_convert_partial_so       IN VARCHAR2
, p_so_reprice_flag          IN VARCHAR2
)
IS
BEGIN

  NULL;
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Convert_sales_orders;


END ONT_MGD_EURO_OE_MEDIATOR;


/

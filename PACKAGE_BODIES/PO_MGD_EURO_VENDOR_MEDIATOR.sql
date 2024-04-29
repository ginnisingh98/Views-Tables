--------------------------------------------------------
--  DDL for Package Body PO_MGD_EURO_VENDOR_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MGD_EURO_VENDOR_MEDIATOR" AS
-- $Header: POXMVENB.pls 115.15 2002/11/23 03:27:27 sbull ship $
--+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     POXMVENB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|              Create_Vendor_Mirror        PRIVATE                      |
--|              Create_Vendor_Site_Mirror   PRIVATE                      |
--|              Vendor_Conversion           PUBLIC                       |
--|              Sites_Conversion            PUBLIC                       |
--|              All_Vendor_Conversion       PUBLIC                       |
--|                                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|                                                                       |
--|     26-Dec-1999   rajkrish     Created                                |
--|     01-Feb-2000   rajkrish     Updated                                |
--|     04/30/2001    tsimmond     added procedure all_vendor_conversion  |
--|     10/22/2001    vto          bug 2048490, 2040015,indicate supplier |
--|                                already in EURO.                       |
--|     12/06/2001    tsimmond     added check for org_id before sites    |
--|                                conversion, R11.5 implementation of    |
--|                                bug fix #2110056 for R11               |
--|    03/25/2002 tsimmond updated, code removed for patch 'H' remove     |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Vendor_Conversion       PUBLIC
-- PARAMETERS: p_vendor_ID        Vendor to be converted
--             p_update_DB_Flag   Commit the Conversion
--             p_vendor_number    Vendor Number for Report Gen
--
--
-- COMMENT   : Main Logic to Process the Vendor Conversion
--
--=======================================================================
PROCEDURE Vendor_Conversion
( p_vendor_id            IN  NUMBER
, p_update_db_flag       IN  VARCHAR2
)
IS
BEGIN

  NULL;

END Vendor_Conversion;

--========================================================================
-- PROCEDURE : Sites_Conversion         PUBLIC
-- PARAMETERS: p_vendor_id              Vednor ID
--             p_vendor_site_id         Specific Site to be Processed
--             p_site_conv_from_ncu     NCU Sites to be Converted
--             p_conv_standard_po_flag  Flag to indicate conversion of
--                                      Standard PO
--             p_conv_blanket_po_flag   Flag to indicate conversion of
--                                      Blanket PO
--             p_conv_planned_po_flag   Flag to indicate conversion of
--                                      Planned PO
--             p_conv_contract_po_flag  Flag to indicate conversion of
--                                      Contract PO
--             p_po_conv_from_ncu       Site NCU to be converted
--             p_update_db_flag         Commit Flag
--
--
-- COMMENT   : Main Logic to Process the Supplier Sites Conversion
--
--=======================================================================
PROCEDURE Sites_Conversion
( p_vendor_id              IN  NUMBER
, p_vendor_site_id         IN  NUMBER
, p_site_conv_from_ncu     IN  VARCHAR2
, p_conv_standard_po_flag  IN  VARCHAR2 := 'N'
, p_conv_blanket_po_flag   IN  VARCHAR2 := 'N'
, p_conv_planned_po_flag   IN  VARCHAR2 := 'N'
, p_conv_contract_po_flag  IN  VARCHAR2 := 'N'
, p_po_conv_from_ncu       IN  VARCHAR2
, p_conv_partial           IN  VARCHAR2
, p_update_db_flag         IN  VARCHAR2 := 'N'
)
IS
BEGIN

  NULL;

END Sites_Conversion;

--========================================================================
-- PROCEDURE : All_Vendor_Conversion       PUBLIC
-- PARAMETERS: p_standard_po_flag       Indicate if Standard PO needs to be converted
--             p_blanket_po_flag        Indicate if Blanket PO needs to be converted
--             p_planned_po_flag        Indicate if Planned PO needs to be converted
--             p_contract_po_flag       Indicate if Contract PO needs to be converted
--             p_po_from_ncu            NCU POs to be converted
--             p_convert_partial        Indicates if partially transacted PO need
--                                      to be converted
--
-- COMMENT   : Main Logic to Process the All Vendor Conversion
--
--=======================================================================
PROCEDURE All_Vendor_Conversion
( p_standard_po_flag  IN  VARCHAR2 DEFAULT 'N'
, p_blanket_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_planned_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_contract_po_flag  IN  VARCHAR2 DEFAULT 'N'
, p_po_from_ncu       IN  VARCHAR2 DEFAULT NULL
, p_convert_partial   IN  VARCHAR2 DEFAULT 'N'
)
IS
BEGIN

  NULL;

END All_Vendor_Conversion;

END  PO_MGD_EURO_VENDOR_MEDIATOR;


/

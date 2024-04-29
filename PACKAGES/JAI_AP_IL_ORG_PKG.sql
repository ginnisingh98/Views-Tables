--------------------------------------------------------
--  DDL for Package JAI_AP_IL_ORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_IL_ORG_PKG" AUTHID CURRENT_USER AS
--$Header: jaiaporgs.pls 120.0 2008/01/21 14:22:03 eaggarwa noship $

--+=======================================================================+
--|               Copyright (c) 2007 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     jaiaporgs.pls
--|
--| DESCRIPTION
--|
--|     This package contains the PL/SQL tables/procedures/functions
--|     used by the APXINWKB.fmb form for calling India Localization form
--|
--|
--|
--|
--|
--| TYPE LIEST
--|
--|
--| PROCEDURE LIST
--|
--|
--|
--| HISTORY
--|
--|
--+======================================================================*/


--==========================================================================
--  PROCEDURE NAME:
--
--    FUN_IL_ORG               Public
--
--  DESCRIPTION:
--
--      This procedure checks whether India Localisation is implemented
--      or not
--

--
--===========================================================================

FUNCTION FUN_IL_ORG (P_CURRENCY VARCHAR2) RETURN BOOLEAN;


--==========================================================================
--  PROCEDURE NAME:
--
--    FUN_MISC_LINE               Public
--
--  DESCRIPTION:
--
--      This procedure retruns true if the invoice has MISC lines created
--      by IL procedure  call
--
--===========================================================================



FUNCTION FUN_MISC_LINE (P_INVOICE_ID NUMBER,
                        P_LOOKUP_CODE VARCHAR2,
			P_LINE_NUMBER NUMBER ) RETURN BOOLEAN;

--==========================================================================
--  PROCEDURE NAME:
--
--   FUN_TDS_INVOICE            Public
--
--  DESCRIPTION:
--
--      This procedure tells is whether the invoice is TDS invoice or not
--
--  PARAMETERS:
--
--
--===========================================================================


FUNCTION FUN_TDS_INVOICE( P_INVOICE_ID NUMBER) RETURN BOOLEAN;

--==========================================================================
--  PROCEDURE NAME:
--
--   FUN_MISC_PO            Public
--
--  DESCRIPTION:
--
--      This procedure tells is whether the invoice is MISc lines or not
--
--  PARAMETERS:
--
--
--===========================================================================

FUNCTION FUN_MISC_PO (P_INVOICE_ID NUMBER) RETURN BOOLEAN;




--==========================================================================
--  PROCEDURE NAME:
--
--   FUN_TAX_CAT_ID            Public
--
--  DESCRIPTION:
--
--      This procedure is used get the tax category id for the supplier
--
--  PARAMETERS:
--
--
--===========================================================================
FUNCTION fun_tax_cat_id ( p_supplier_id number , p_supplier_site_id number ,p_invoice_id NUMBER ,
 p_line_number NUMBER ) RETURN NUMBER;


END JAI_AP_IL_ORG_PKG;

/

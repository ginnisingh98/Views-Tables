--------------------------------------------------------
--  DDL for Package JAI_AVLIST_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AVLIST_VALIDATE_PKG" AUTHID CURRENT_USER AS
--$Header: Jai_AvList_Validate.pls 120.0.12010000.3 2009/06/27 04:24:08 jijili noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     Jai_Avlist_Validate.pls                                           |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Validate if there is more than one Item-UOM combination existing  |
--|     in used AV list for the Item selected in the transaction.         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Check_AvList_Validation                                |
--|                                                                       |
--| HISTORY                                                               |
--|     2009/06/08   Jia Li     Created                                   |
--|                                                                       |
--+======================================================================*/

-- Declare global variable for package name
GV_MODULE_PREFIX VARCHAR2(50) :='jai.plsql.Jai_AvList_Validate_Pkg';

-- Public function and procedure declarations
--==========================================================================
--  PROCEDURE NAME:
--
--    Check_AvList_Validation                      Public
--
--  DESCRIPTION:
--
--    This is a validation procedure which will be used to check
--    whether there is more than one Item-UOM combination existing
--    in used AV list for the Item selected in the transaction.
--
--  PARAMETERS:
--      In:  pn_party_id            Identifier of Customer id or Vendor id
--           pn_party_site_id       Identifier of Customer/Vendor site id
--           pn_inventory_item_id   Identifier of Inventory item id
--           pd_ordered_date        Identifier of Ordered date
--           pv_party_type          Identifier of Party type, 'C' is mean customer, 'V' is mean vendor
--           pn_pricing_list_id     Identifier of vat/excise assessable price id, for base form used.
--
--
--  DESIGN REFERENCES:
--    FDD_R12i_Advanced_Pricing_V1.0.doc
--
--  CHANGE HISTORY:
--
--           08-Jun-2009   Jia Li   created
--==========================================================================
 PROCEDURE Check_AvList_Validation
 ( pn_party_id          IN NUMBER
 , pn_party_site_id     IN NUMBER
 , pn_inventory_item_id IN NUMBER
 , pd_ordered_date      IN DATE
 , pv_party_type        IN VARCHAR2
 , pn_pricing_list_id   IN NUMBER
 );

END JAI_AVLIST_VALIDATE_PKG;

/

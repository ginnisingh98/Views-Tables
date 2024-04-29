--------------------------------------------------------
--  DDL for Package PO_MGD_EURO_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MGD_EURO_CP" AUTHID CURRENT_USER AS
-- $Header: POXCEURS.pls 115.7 2002/11/23 03:31:17 sbull ship $
/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    POXCEURS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of concurrent program package PO_MGD_EURO_CP.               |
--|     Supplier Conversion.                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     12/02/1999 tsimmond        Created                                |
--|     04/30/2001 tsimmond        Added new public procedure             |
--|                                Run_All_Vendor_Conversion              |
--|    11/28/2001 tsimmond  updated, added  set verify off                |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Run_Vendor_Conversion    PUBLIC
-- PARAMETERS: x_errbuf                 error buffer
--             x_retcode                0 success, 1 warning, 2 error
--             p_vend_id                Supplier ID
--             p_vend_site_id           Supplier Site ID
--             p_site_from_ncu          NCU address sites to be converted
--             p_standard_po_flag       Indicate if Standard PO needs to be converted
--             p_blanket_po_flag        Indicate if Blanket PO needs to be converted
--             p_planned_po_flag        Indicate if Planned PO needs to be converted
--             p_contract_po_flag       Indicate if Contract PO needs to be converted
--             p_po_from_ncu            NCU POs to be converted
--             p_convert_partial        Indicates if partially transacted PO need to be converted
--             p_db_flag                Indicate if database needs to be updated
--
-- COMMENT   : This is the concurrent program for EURO conversion of
--             supplier and supplier sites,
--             Including different types of Purchase Orders.
--
--========================================================================
PROCEDURE Run_Vendor_Conversion
( x_errbuf            OUT NOCOPY VARCHAR2
, x_retcode           OUT NOCOPY VARCHAR2
, p_vend_id           IN  NUMBER
, p_vend_site_id      IN  NUMBER   DEFAULT NULL
, p_site_from_ncu     IN  VARCHAR2 DEFAULT NULL
, p_standard_po_flag  IN  VARCHAR2 DEFAULT 'N'
, p_blanket_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_planned_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_contract_po_flag  IN  VARCHAR2 DEFAULT 'N'
, p_po_from_ncu       IN  VARCHAR2 DEFAULT NULL
, p_convert_partial   IN  VARCHAR2 DEFAULT 'N'
, p_db_flag           IN  VARCHAR2 DEFAULT 'N'
);


--========================================================================
-- PROCEDURE : Run_All_Vendor_Conversion    PUBLIC
-- PARAMETERS: x_errbuf           error buffer
--             x_retcode          0 success, 1 warning, 2 error
--             p_st_po_flag       Indicate if Standard PO needs to be converted
--             p_bl_po_flag       Indicate if Blanket PO needs to be converted
--             p_pl_po_flag       Indicate if Planned PO needs to be converted
--             p_ct_po_flag       Indicate if Contract PO needs to be converted
--             p_po_from_cur      NCU POs to be converted
--             p_convert_part     Indicates if partially transacted PO need
--                                to be converted
--
-- COMMENT   : This is the concurrent program for EURO conversion of
--             ALL Suppliers and Suppliers sites,
--             including the Purchase Orders.
--
--========================================================================
PROCEDURE Run_All_Vendor_Conversion
( x_retcode      OUT NOCOPY VARCHAR2
, x_errbuf       OUT NOCOPY VARCHAR2
, p_st_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_bl_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_pl_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_ct_po_flag   IN  VARCHAR2 DEFAULT 'N'
, p_po_from_cur  IN  VARCHAR2 DEFAULT NULL
, p_convert_part IN  VARCHAR2 DEFAULT 'N'
);

END PO_MGD_EURO_CP;


 

/

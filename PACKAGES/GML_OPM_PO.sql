--------------------------------------------------------
--  DDL for Package GML_OPM_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OPM_PO" AUTHID CURRENT_USER AS
/* $Header: GMLOPMPS.pls 120.0 2005/05/25 16:20:24 appldev noship $ */
	FUNCTION CHECK_OPM_PO    (p_po_header_id in 	po_headers_all.po_header_id%TYPE)
		RETURN NUMBER;

	FUNCTION CHECK_OPM_ITEM_BY_ORA_ID(p_inventory_item_id in mtl_system_items_b.inventory_item_id%TYPE,p_organization_id in mtl_system_items_b.organization_id%TYPE)
		RETURN NUMBER;

	PRAGMA RESTRICT_REFERENCES (CHECK_OPM_PO, WNDS);
END GML_OPM_PO;

 

/

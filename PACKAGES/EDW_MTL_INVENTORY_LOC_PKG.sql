--------------------------------------------------------
--  DDL for Package EDW_MTL_INVENTORY_LOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MTL_INVENTORY_LOC_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIILFKS.pls 120.1 2005/06/07 01:48:12 appldev  $  */
-- ------------------------
-- Public Functions
-- ------------------------
	FUNCTION get_locator_fk (p_inventory_location_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_subinventory_code IN VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_stock_room_fk (p_secondary_inventory_name IN VARCHAR2,
                                  p_organization_id IN NUMBER) RETURN VARCHAR2;
	FUNCTION get_locator_fk (p_inventory_location_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_subinventory_code IN VARCHAR2,
                               p_whse_loct_ctl IN NUMBER,
                               P_item_loct_ctl IN NUMBER,
                               p_location_code IN VARCHAR2,
                               p_organization_code IN VARCHAR2,
                               p_instance_code  IN VARCHAR2) RETURN VARCHAR2;

	PRAGMA RESTRICT_REFERENCES (get_locator_fk, WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_stock_room_fk, WNDS, WNPS, RNPS);

end;

 

/

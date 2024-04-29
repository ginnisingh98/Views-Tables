--------------------------------------------------------
--  DDL for Package GML_PROCESS_FLAGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PROCESS_FLAGS" AUTHID CURRENT_USER AS
/* $Header: GMLOPMFS.pls 115.3 2003/07/31 15:48:32 mchandak noship $ */

   	opmitem_flag      NUMBER := 0;
	process_orgn	  NUMBER := 0;
	opm_installed	  NUMBER := 0;
	FUNCTION CHECK_OPM_ITEM(p_inventory_item_id in mtl_system_items_b.inventory_item_id%TYPE)
		RETURN NUMBER;

	FUNCTION CHECK_PROCESS_ORGN
        (p_organization_id IN mtl_parameters.organization_id%TYPE)
         RETURN NUMBER;

	PRAGMA RESTRICT_REFERENCES (CHECK_OPM_ITEM, WNDS);
	PRAGMA RESTRICT_REFERENCES (CHECK_PROCESS_ORGN, WNDS);
END GML_PROCESS_FLAGS;

 

/

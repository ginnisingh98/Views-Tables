--------------------------------------------------------
--  DDL for Package Body GML_OPM_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OPM_PO" AS
/* $Header: GMLOPMPB.pls 120.1 2005/09/30 13:41:18 pbamb noship $ */
	FUNCTION CHECK_OPM_PO    (p_po_header_id in 	po_headers_all.po_header_id%TYPE)
		RETURN NUMBER IS

		v_result	NUMBER;
	BEGIN
		v_result := 0;
		SELECT count(*) into v_result
		FROM cpg_oragems_mapping
		WHERE po_header_id = p_po_header_id;

		IF v_result > 0 THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END CHECK_OPM_PO;

FUNCTION CHECK_OPM_ITEM_BY_ORA_ID
      ( p_inventory_item_id IN mtl_system_items_b.inventory_item_id%TYPE,
        p_organization_id IN mtl_system_items_b.organization_id%TYPE
      ) RETURN NUMBER IS

   v_item_no	mtl_system_items_b.segment1%TYPE;
   opmitem      NUMBER;

   CURSOR item_cur IS
     SELECT segment1
     FROM   mtl_system_items_b
     WHERE  inventory_item_id = p_inventory_item_id AND
	    organization_id = p_organization_id;

BEGIN

   opmitem       := 0;

   OPEN  item_cur;
   FETCH item_cur into v_item_no;
   IF item_cur%NOTFOUND THEN
      CLOSE item_cur;
      return 0;
   END IF;

   IF item_cur%ISOPEN THEN
        CLOSE item_cur;
   END IF;


  opmitem := GMF_OPM_ITEM.check_opm_item (v_item_no);

  IF opmitem = 1 THEN
     return 1;
  ELSE
     return 0;
  END IF;

END CHECK_OPM_ITEM_BY_ORA_ID;

END; /* of package */

/

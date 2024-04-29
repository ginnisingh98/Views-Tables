--------------------------------------------------------
--  DDL for Package Body GML_PROCESS_FLAGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PROCESS_FLAGS" AS
/* $Header: GMLOPMFB.pls 115.3 2003/07/31 15:48:48 mchandak noship $ */

FUNCTION CHECK_OPM_ITEM
      ( p_inventory_item_id IN mtl_system_items_b.inventory_item_id%TYPE
      ) RETURN NUMBER IS

   v_item_no	mtl_system_items_b.segment1%TYPE;
   opmitem      NUMBER;

   CURSOR item_distinct_cur IS
     SELECT distinct segment1
     FROM   mtl_system_items_b
     WHERE  inventory_item_id = nvl(p_inventory_item_id,-99);

   CURSOR opm_item IS
	SELECT count(*)
                FROM ic_item_mst
                WHERE item_no = v_item_no;

BEGIN

   opmitem       := 0;
   GML_PROCESS_FLAGS.opmitem_flag := 0;

   OPEN item_distinct_cur;
   FETCH item_distinct_cur into v_item_no;
   If item_distinct_cur%NOTFOUND THEN
	CLOSE item_distinct_cur;
  	return 0;
   END IF;

   IF item_distinct_cur%ISOPEN THEN
        CLOSE item_distinct_cur;
   END IF;

   OPEN  opm_item;
   FETCH opm_item into opmitem;
   CLOSE opm_item;

   IF opmitem >= 1 THEN
     GML_PROCESS_FLAGS.opmitem_flag := 1;
     return 1;
   ELSE
     return 0;
   END IF;

END CHECK_OPM_ITEM;

FUNCTION CHECK_PROCESS_ORGN
        (p_organization_id IN mtl_parameters.organization_id%TYPE)
         RETURN NUMBER IS

   process_enabled mtl_parameters.process_enabled_flag%TYPE;
   CURSOR process_org IS
     SELECT process_enabled_flag
     FROM   mtl_parameters
     WHERE  organization_id = nvl(p_organization_id,-99);
  BEGIN
	process_enabled := 'N';
	GML_PROCESS_FLAGS.process_orgn := 0;
	OPEN process_org;
	FETCH process_org into process_enabled;
	CLOSE process_org;

	If process_enabled = 'Y'
	Then
		GML_PROCESS_FLAGS.process_orgn := 1;
		return 1;
	Else
		return 0;
	End If;
END CHECK_PROCESS_ORGN;

END GML_PROCESS_FLAGS; /* of package */

/

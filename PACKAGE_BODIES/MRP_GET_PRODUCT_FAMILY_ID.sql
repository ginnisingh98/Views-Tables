--------------------------------------------------------
--  DDL for Package Body MRP_GET_PRODUCT_FAMILY_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_PRODUCT_FAMILY_ID" AS
/* $Header: MRPGPFIB.pls 115.0 2002/03/26 03:58:23 pkm ship        $  */

FUNCTION p_family(ITEM_ID IN NUMBER,ORG_ID IN NUMBER) RETURN NUMBER IS
pfid      NUMBER;
BEGIN

select product_family_item_id into pfid from mtl_system_items
where inventory_item_id = ITEM_ID and
organization_id = ORG_ID;

return pfid;

END;
END;

/

--------------------------------------------------------
--  DDL for Package Body B_RTG_REVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."B_RTG_REVS_PKG" as
/* $Header: bompirrb.pls 115.3 2003/04/01 10:21:52 djebar ship $ */

  PROCEDURE Check_Order (X_Effectivity_Date 	   	DATE,
			 X_Inventory_Item_Id		NUMBER,
			 X_Organization_Id		NUMBER,
			 X_Process_Revision		VARCHAR2) IS
  dummy NUMBER;
  BEGIN
    SELECT 1
      INTO dummy
      FROM dual
     WHERE X_Effectivity_Date >
                (SELECT nvl(max(effectivity_date), X_Effectivity_Date-1)
                   FROM mtl_rtg_item_revisions
                  WHERE inventory_item_id = X_Inventory_Item_Id
	            AND organization_id   = X_Organization_Id
                    AND process_revision  < X_Process_Revision)
       AND X_Effectivity_Date <
                (SELECT nvl(min(effectivity_date), X_Effectivity_Date+1)
                   FROM mtl_rtg_item_revisions
                  WHERE inventory_item_id = X_Inventory_Item_Id
                    and organization_id   = X_Organization_Id
                    and process_revision  > X_Process_Revision);
  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('BOM','BOM_REVISION_ORDER');
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Check_Order;

  PROCEDURE Check_Unique(X_Organization_Id              NUMBER,
			 X_Inventory_Item_Id		NUMBER,
			 X_Process_Revision		VARCHAR2) IS
  dummy NUMBER;
  BEGIN
    SELECT 1
      INTO dummy
      FROM dual
     WHERE not exists (SELECT 1 from mtl_rtg_item_revisions
                        WHERE organization_id   = X_Organization_Id
                          AND inventory_item_id = X_Inventory_Item_Id
			  AND process_revision  = X_Process_Revision
                       );
  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('MRP','GEN-DUPLICATE NAME');
      FND_MESSAGE.SET_TOKEN('ENTITY','revision',TRUE);
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Check_Unique;

END B_RTG_REVS_PKG;

/

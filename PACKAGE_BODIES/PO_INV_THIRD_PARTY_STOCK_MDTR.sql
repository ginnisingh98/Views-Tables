--------------------------------------------------------
--  DDL for Package Body PO_INV_THIRD_PARTY_STOCK_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INV_THIRD_PARTY_STOCK_MDTR" AS
-- $Header: POXMTPSB.pls 120.1.12010000.2 2012/09/03 09:55:44 jozhong ship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     POXMTPSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consigned inventory PO/INV dependency wrapper API                 |
--|     This mediator package is used to access INV objects from          |
--|     PO product.                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     consumption_trans_exist                                           |
--|                                                                       |
--| HISTORY                                                               |
--|     12/09/02 vchu    Created                                          |
--|                      Contains empty stub of consumption_trans_exist() |
--|                      in order to avoid dependency of PO on INV        |
--|     12/09/02 vchu    Modified                                         |
--|                      Replaced empty stub of consumption_trans_exist() |
--|                      with actual implmentation which has dependencies |
--|                      on MTL_MATERIAL_TRANSACTIONS and                 |
--|                      MTL_CONSUMPTION_TRANSACTIONS tables              |
--|     12/12/02 vma     Added empty stub of two functions                |
--|                      Supplier_Owns_Tps and Sup_Site_Owns_Tps          |
--|     12/12/02 vma     Replace empty stub of Supplier_Owns_Tps and      |
--|                      Sup_Site_Owns_Tps with actual implementation     |
--|     10/29/03 vma     Bug fix for performance bug #3131113             |
--+=======================================================================+

--=========================================================================
-- PROCEDURES AND FUNCTIONS
--=========================================================================

--=========================================================================
-- FUNCTION  : consumption_trans_exist
-- PARAMETERS: p_transaction_source_id      ID of the parent blanket
--                                          agreement
--             p_inventory_item_id          Item ID of the transaction.
--                                          This field
-- RETURNS   : Return 'Y' if there exists a consumption transaction
--             that is in process for the passed in transaction source
--             agreement ID and and item ID.  The value 'Y' is returned
--             if the passed in item ID is null and if there exists
--             consumption transactions that are in process and match
--             with the passed in transaction source ID.  The value 'N'
--             is returned if no corresponding consumption transactions
--             that are in process are found.
-- COMMENT   : This function is called by PO Summary form to decide
--             whether it can provide the "Finally Close" and "Cancel"
--             actions in the the list of control actions for a PO
--             Header or a PO Line.
--=========================================================================

FUNCTION consumption_trans_exist
( p_transaction_source_id IN NUMBER
, p_item_id               IN NUMBER
)
RETURN VARCHAR2
IS

l_count_cons_trans NUMBER := 0;

  CURSOR c_item_id IS
    SELECT /*+FIRST_ROWS */ 1
    FROM   mtl_consumption_transactions mct,
           mtl_material_transactions mmt
    WHERE  mmt.transaction_id = mct.transaction_id
           AND mmt.transaction_source_id = p_transaction_source_id
           AND mmt.inventory_item_id = p_item_id
           AND Nvl(mct.consumption_processed_flag,'N') <> 'Y';

  CURSOR c_item_id_null IS
    SELECT /*+FIRST_ROWS */ 1
    FROM   mtl_consumption_transactions mct,
           mtl_material_transactions mmt
    WHERE  mmt.transaction_id = mct.transaction_id
           AND mmt.transaction_source_id = p_transaction_source_id
           AND Nvl(mct.consumption_processed_flag,'N') <> 'Y';


BEGIN
  IF(p_item_id IS NOT NULL)
  THEN
  /* Bug 14541173 Used cursors c_item_id, c_item_id_null and 'FIRST_ROWS' optimizer hint to improve performance */
    open c_item_id;
    fetch c_item_id into l_count_cons_trans;
    close c_item_id;
  ELSE
    open c_item_id_null;
    fetch c_item_id_null into l_count_cons_trans;
    close c_item_id_null;
  END IF;


  /* Bug 14541173 Commented the below code */

  /*
      SELECT count('Y')
    INTO   l_count_cons_trans
    FROM   dual
    WHERE  EXISTS(SELECT 'Y'
                  FROM   MTL_CONSUMPTION_TRANSACTIONS MCT,
                         MTL_MATERIAL_TRANSACTIONS    MMT
                  WHERE  MMT.TRANSACTION_ID = MCT.TRANSACTION_ID
                  AND    MMT.TRANSACTION_SOURCE_ID = p_transaction_source_id
                  AND    MMT.INVENTORY_ITEM_ID = p_item_id
		  AND    nvl(MCT.CONSUMPTION_PROCESSED_FLAG, 'N') <> 'Y');
  ELSE
    SELECT count('Y')
    INTO   l_count_cons_trans
    FROM   dual
    WHERE  EXISTS(SELECT 'Y'
                  FROM   MTL_CONSUMPTION_TRANSACTIONS MCT,
                         MTL_MATERIAL_TRANSACTIONS    MMT
                  WHERE  MMT.TRANSACTION_ID = MCT.TRANSACTION_ID
                  AND    MMT.TRANSACTION_SOURCE_ID = p_transaction_source_id
		  AND    nvl(MCT.CONSUMPTION_PROCESSED_FLAG, 'N') <> 'Y');


  END IF;  */

  IF(l_count_cons_trans > 0)
  THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    RAISE;

END consumption_trans_exist;


--========================================================================
-- FUNCTION     : Supplier_Owns_Tps PUBLIC
-- PARAMETERS   : p_vendor_id IN NUMBER
-- RETURN       : TRUE if on hand consigned stock exist for the supplier;
--                FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned stock exists for a given
--                supplier. The function checks whether any supplier site
--                of this supplier owns on hand consigned stock.
--
-- CHANGE HISTORY :
--   18-Nov-2002      Created by VMA
--   30-Oct-2003      Bug fix for bug #3131113:
--                    1. Added query to PO_APPROVED_SUPPLIER_LIST to make
--                       use of index on MTL_ONHAND_QUANTITIES_DETAIL.
--                    2. Updated logic to check for existance of onhand
--                       consigned stock. Old logic checked existence of
--                       any record in MOQD. This is replaced with new logic
--                       that checks the sum of primary_transaction_quantity
--                       for an item owned by a supplier in MOQD.
--========================================================================
FUNCTION Supplier_Owns_Tps (p_vendor_id IN NUMBER) RETURN BOOLEAN IS

l_onhand_qty mtl_onhand_quantities_detail.primary_transaction_quantity%TYPE;

BEGIN

  IF p_vendor_id IS NOT NULL
  THEN
    -- Start Bug 4459947
    -- Do not hardcode schema names
    -- GSCC checker parses asl as schema name even though in this case
    -- it is just an alias. Changing the alias name from asl to po_asl.
    FOR po_asl IN (SELECT item_id, vendor_site_id
                     FROM po_asl_attributes
                    WHERE vendor_id = p_vendor_id
                      AND vendor_site_id IS NOT NULL
                      AND consigned_from_supplier_flag IS NOT NULL
                 ORDER BY consigned_from_supplier_flag DESC)
    LOOP
      SELECT SUM(primary_transaction_quantity)
        INTO l_onhand_qty
        FROM mtl_onhand_quantities_detail
       WHERE inventory_item_id = po_asl.item_id
         AND owning_organization_id = po_asl.vendor_site_id
         AND owning_tp_type = 1;

      IF l_onhand_qty > 0
      THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    -- End Bug 4459947
  END IF;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END Supplier_Owns_Tps;


--========================================================================
-- FUNCTION     : Sup_Site_Owns_Tps PUBLIC
-- PARAMETERS   : p_vendor_site_id IN NUMBER
-- RETURN       : TRUE if on hand consigned or VMI stock exist for the
--                supplier site; FALSE otherwise. If p_vendor_site_id
--                is null, FALSE is returned.
-- DESCRIPTION  : Check whether on hand consigned or VMI stock exists for
--                a given supplier site.
--
-- CHANGE HISTORY :
--   18-Nov-2002     Created by VMA
--   30-Oct-2003     Bug fix for bug #3131113:
--                    1. Added query PO_APPROVED_SUPPLIER_LIST to use
--                       index on MTL_ONHAND_QUANTITIES_DETAIL.
--                    2. Updated logic to check for existance of onhand
--                       consigned stock. Old logic checked existence of
--                       any record in MOQD. This is replaced with new logic
--                       that checks the sum of primary_transaction_quantity
--                       for an item owned by a supplier site in MOQD.
--========================================================================
FUNCTION Sup_Site_Owns_Tps(p_vendor_site_id IN Number) RETURN BOOLEAN IS

l_onhand_qty mtl_onhand_quantities_detail.primary_transaction_quantity%TYPE;

TYPE item_id_tbl_type IS TABLE OF po_asl_attributes_val_v.item_id%TYPE
  INDEX BY BINARY_INTEGER;

item_id_tbl item_id_tbl_type;

BEGIN

  IF p_vendor_site_id IS NOT NULL
  THEN

    SELECT item_id BULK COLLECT INTO item_id_tbl
      FROM po_asl_attributes
     WHERE vendor_site_id = p_vendor_site_id
       AND consigned_from_supplier_flag IS NOT NULL
     ORDER BY consigned_from_supplier_flag DESC;

    FOR i IN item_id_tbl.FIRST..item_id_tbl.LAST
    LOOP
      SELECT SUM(primary_transaction_quantity)
        INTO l_onhand_qty
        FROM mtl_onhand_quantities_detail
       WHERE inventory_item_id = item_id_tbl(i)
         AND ((owning_organization_id = p_vendor_site_id
         AND   owning_tp_type = 1)
          OR  (planning_organization_id = p_vendor_site_id
         AND   planning_tp_type = 1));

      IF l_onhand_qty > 0
      THEN
        RETURN TRUE;
      END IF;
    END LOOP;
  END IF;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END Sup_Site_Owns_Tps;

END PO_INV_THIRD_PARTY_STOCK_MDTR;


/

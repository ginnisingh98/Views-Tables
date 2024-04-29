--------------------------------------------------------
--  DDL for Package Body INV_CONSIGNED_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSIGNED_VALIDATIONS" AS
/* $Header: INVVMILB.pls 120.4.12010000.3 2008/12/03 11:05:15 rkatoori ship $ */

/*****************
 * Private API   *
 *****************/

-- This api queries the global temp table based on different levels
-- Level 1 = no query
-- Level 2 = query all CONSIGNED_VMI
-- Level 3 = query VMI at revsion
-- Level 4 = query VMI at Lot
-- Level 5 = query VMI at Sub
-- Level 6 = query VMI at locator
-- Level 7 equals VMI at cost group level

--Variable indicating whether debugging is turned on
g_debug NUMBER := NULL;

PROCEDURE debug_print( p_message IN VARCHAR2
                     , p_title   IN VARCHAR2 DEFAULT 'INV_VMI_QT'
                     , p_level   IN NUMBER := 9)
IS
BEGIN
   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF (g_debug = 1) THEN
      inv_log_util.trace(p_message, p_title, p_level);
   END IF;
   --dbms_output.put_line(p_message);
END debug_print;

PROCEDURE query_vmi_consigned
  ( x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY VARCHAR2
  , x_msg_data              OUT NOCOPY VARCHAR2
  , p_organization_id       IN NUMBER
  , p_planning_org_id       IN NUMBER
  , p_owning_org_id            NUMBER
  , p_inventory_item_id     IN NUMBER
  , p_tree_mode             IN NUMBER
  , p_is_revision_control   IN BOOLEAN
  , p_is_lot_control        IN BOOLEAN
  , p_is_serial_control     IN BOOLEAN
  , p_demand_source_line_id IN NUMBER
  , p_revision              IN VARCHAR2
  , p_lot_number            IN VARCHAR2
  , p_lot_expiration_date   IN DATE
  , p_subinventory_code     IN VARCHAR2
  , p_locator_id            IN NUMBER
  , p_cost_group_id         IN NUMBER
  , x_qoh                   OUT NOCOPY NUMBER
  , x_sqoh                  OUT NOCOPY NUMBER     -- invConv change
  ) IS

l_table_count NUMBER := 0;
l_count       NUMBER := 0;
-- l_total_qty   NUMBER := 0;  -- not used !!!
l_level       NUMBER := 1;
l_qoh         NUMBER := 0;
l_sqoh        NUMBER := 0;    -- invConv change
l_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

-- invConv changes begin
l_uom_ind    VARCHAR2(3);
l_lot_ctl    NUMBER;
l_grade_ctl  VARCHAR2(1);


CURSOR get_item_info( l_org_id IN NUMBER
                    , l_item_id  IN NUMBER) IS
SELECT tracking_quantity_ind
, lot_control_code
, grade_control_flag
FROM mtl_system_items
WHERE inventory_item_id = l_item_id
AND organization_id = l_org_id;
-- invConv changes end

BEGIN

	IF (l_debug = 1) THEN
   	inv_log_util.trace('In Query_VMI_Consigned','CONSIGNED_VALIDATIONS',9);
	END IF;

   x_return_status:= fnd_api.g_ret_sts_success;

   -- invConv changes begin
   -- Validations : DUOM item
   OPEN get_item_info( p_organization_id, p_inventory_item_id);
   FETCH get_item_info
    INTO l_uom_ind
       , l_lot_ctl
       , l_grade_ctl;
   CLOSE get_item_info;
   -- invConv changes end

   -- query the temp table and first check if any rows exists
   --SELECT COUNT(*)INTO l_table_count FROM mtl_consigned_qty_temp
   -- WHERE inventory_item_id = p_inventory_item_id
   --AND organization_id = p_organization_id;
	-- Use Exists to check existance
	l_table_count := 0;
	BEGIN
		SELECT 1 INTO l_table_count FROM dual
		WHERE EXISTS (SELECT 1 FROM mtl_consigned_qty_temp
	              WHERE inventory_item_id = p_inventory_item_id
	              AND organization_id = p_organization_id);
	EXCEPTION
		WHEN others THEN
			l_table_count := 0;
	END;

   IF (l_table_count = 0) THEN
   	  IF (l_debug = 1) THEN
      	  inv_log_util.trace('No record found in mtl_consigned_qty_temp, return 0','CONSIGNED_VALIDATIONS',9);
   	  END IF;
      x_qoh := 0;

     -- invConv changes begin
     IF (l_uom_ind = 'PS')
     THEN
         x_sqoh := 0;
     ELSE
         x_sqoh := NULL;
     END IF;
     -- invConv changes end

      x_return_status:= fnd_api.g_ret_sts_success;
      RETURN;
   END IF;

   -- compute level

     IF(p_revision is null) THEN
	l_level := 2;
     END IF;
     IF (p_revision IS NOT NULL) THEN
	l_level:=3;
     END IF;
     IF((l_level=2)  AND (p_lot_number IS null)) then
	l_level:= 2;
     END IF;
     IF((l_level=3)  AND (p_lot_number IS null)) then
	l_level:= 3;
     END IF;
     IF((l_level=2 OR l_level=3)  AND (p_lot_number IS NOT NULL)) THEN
	l_level:= 4;
     END IF;
     IF((l_level=2) AND (p_subinventory_code IS NULL)) THEN
	l_level:= 2;
     END IF;
     IF((l_level=3) AND (p_subinventory_code IS NULL)) THEN
	l_level:= 3;
     END IF;
     IF((l_level=4) AND (p_subinventory_code IS NULL)) THEN
	l_level:= 4;
     END IF;
     IF((l_level=2 OR l_level =3 or l_level =4) AND (p_subinventory_code IS NOT NULL)) THEN
	l_level:= 5;
     END IF;
     IF((l_level = 5) AND ( p_locator_id IS NULL)) THEN
	l_level:= 5;
     END IF;
     IF((l_level = 5) AND (p_locator_id IS NOT NULL)) THEN
	l_level:= 6;
     END IF;
     IF((l_level = 6) AND ( p_cost_group_id IS NULL)) THEN
	l_level:= 6;
     END IF;
     IF((l_level = 6) AND ( p_cost_group_id IS NOT NULL)) THEN
	l_level:= 7;
     END IF;

   IF (l_debug = 1) THEN
      inv_log_util.trace('Final Level= '||L_LEVEL,'CONSIGNED_VALIDATIONS',9);
   END IF;


   IF (l_level =2) THEN
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
        WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND
	DECODE(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	DECODE(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND Nvl(planning_organization_id, -999) =
	NVL(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  NVL(owning_organization_id, -999) =
	NVL(p_owning_org_id,Nvl(owning_organization_id, -999));
   END IF;
   IF (l_level=3)then
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND
	DECODE(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	DECODE(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND NVL(planning_organization_id, -999) =
	NVL(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  Nvl(owning_organization_id, -999) =
	NVL(p_owning_org_id,Nvl(owning_organization_id, -999))
	AND revision = p_revision;
   END IF;
   IF (l_level =4) THEN
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND Nvl(planning_organization_id, -999) =
	NVL(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  Nvl(owning_organization_id, -999) =
	NVL(p_owning_org_id,Nvl(owning_organization_id, -999))
	AND
	DECODE(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	DECODE(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND Nvl(revision,'@@@') = Nvl(p_revision,Nvl(revision,'@@@'))
	AND Nvl(lot_number,'@@@')=Nvl(p_lot_number,Nvl(lot_number,'@@@'));
   END IF;
   IF(l_level =5)THEN
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND Nvl(planning_organization_id, -999) =
	NVL(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  Nvl(owning_organization_id, -999) =
	NVL(p_owning_org_id,Nvl(owning_organization_id, -999))
	AND
	DECODE(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	DECODE(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND Nvl(revision,'@@@') = Nvl(p_revision,Nvl(revision,'@@@'))
	AND Nvl(lot_number,'@@@')=Nvl(p_lot_number,Nvl(lot_number,'@@@'))
	AND subinventory_code = p_subinventory_code;
   END IF;
   IF(l_LEVEL=6)THEN
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND Nvl(planning_organization_id, -999) =
	Nvl(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  Nvl(owning_organization_id, -999) =
	Nvl(p_owning_org_id,Nvl(owning_organization_id, -999))
	AND
	DECODE(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	DECODE(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND Nvl(revision,'@@@') = Nvl(p_revision,Nvl(revision,'@@@'))
	AND Nvl(lot_number,'@@@')=Nvl(p_lot_number,Nvl(lot_number,'@@@'))
	AND subinventory_code = p_subinventory_code
	AND locator_id = p_locator_id ;
   END IF;
   IF(l_level=7) THEN
      -- invConv change : added secondary quantity
      SELECT Nvl(sum(primary_quantity),0)
           , Nvl(sum(secondary_quantity),0)
      INTO l_qoh, l_sqoh
	FROM mtl_consigned_qty_temp
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND Nvl(planning_organization_id, -999) =
	Nvl(p_planning_org_id,Nvl(planning_organization_id, -999))
	AND  Nvl(owning_organization_id, -999) =
	Nvl(p_owning_org_id,Nvl(owning_organization_id, -999))
	AND
	Decode(p_tree_mode,INV_Quantity_Tree_PUB.g_loose_only_mode,containerized,'-1')=
	Decode(p_tree_mode,inv_quantity_tree_pub.g_loose_only_mode,0,'-1')
	AND Nvl(revision,'@@@') = Nvl(p_revision,Nvl(revision,'@@@'))
	AND Nvl(lot_number,'@@@')=Nvl(p_lot_number,Nvl(lot_number,'@@@'))
	AND subinventory_code = p_subinventory_code
	AND locator_id = p_locator_id
	AND cost_group_id = p_cost_group_id;
   END IF;

   debug_print('After Querying mtl_consigned_qty_temp, qoh='||l_qoh||', sqoh='||l_sqoh||', item_type='||l_uom_ind);

   x_qoh := l_qoh;
   -- invConv changes begin
   IF (l_uom_ind = 'PS')
   THEN
       x_sqoh := l_sqoh;
   ELSE
       x_sqoh := NULL;
    END IF;
    -- invConv changes end

EXCEPTION
   when others THEN
      IF (l_debug = 1) THEN
         inv_log_util.trace('When others in query CONSIGNED/VMI ','CONSIGNED_VALIDATIONS',9);
      END IF;
      x_return_status := 'E';
      x_qoh := 0;
      -- invConv changes begin
      IF (l_uom_ind = 'PS')
      THEN
          x_sqoh := 0;
      ELSE
          x_sqoh := NULL;
       END IF;
       -- invConv changes end
      RAISE fnd_api.g_exc_unexpected_error;
END query_vmi_consigned;


-------------------------------------------------------------------------------
-- Procedure                                                                 --
--   build_sql                                                               --
--                                                                           --
-- Description                                                               --
--   build the sql statement for the tree creation                           --
--                                                                           --
-- Notes                                                                     --
--   This procedure is also used by the pick and put away engine to build    --
--   the picking base sql                                                    --
--                                                                           --
-- Input Parameters                                                          --
--   p_mode                                                                  --
--     equals inv_quantity_tree_pvt.g_reservation_mode or                    --
--     inv_quantity_tree_pvt.g_transaction_mode                              --
--   p_is_lot_control                                                        --
--     true or false                                                         --
--   p_asset_sub_only                                                        --
--     true or false                                                         --
--   p_include_suggestion                                                    --
--     always true now
--   p_lot_expiration_date                                                   --
--     if not null, only consider lots that will not expire at the date      --
--     or ealier                                                             --
--                                                                           --
-- Output Parameters                                                         --
--   x_return_status                                                         --
--     standard output parameter. Possible values are                        --
--     1. fnd_api.g_ret_sts_success     for success                          --
--     2. fnd_api.g_ret_sts_exc_error   for expected error                   --
--     3. fnd_api.g_ret_sts_unexp_error for unexpected error                 --
-------------------------------------------------------------------------------


PROCEDURE build_sql
   ( x_return_status       OUT NOCOPY VARCHAR2
   , p_mode                IN  INTEGER
   , p_grade_code          IN  VARCHAR2          -- invConv change
   , p_is_lot_control      IN  BOOLEAN
   , p_asset_sub_only      IN  BOOLEAN
   , p_lot_expiration_date IN  DATE
   , p_onhand_source       IN  NUMBER
   , p_pick_release        IN  NUMBER
   , x_sql_statement       OUT NOCOPY long
   , p_is_revision_control IN  BOOLEAN
   ) IS


l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
   --
   l_stmt                 long;
   l_asset_sub_where      long;
   l_revision_select      long;
   l_lot_select           long;
   l_lot_select2          long;
   l_lot_from             long;
   l_lot_where            long;
   l_lot_expiration_where long;
   l_lot_group            long;
   l_onhand_source_where  long;
   l_onhand_stmt          long;
   l_pending_txn_stmt     long;
   l_onhand_qty_part      VARCHAR2(3000);
   l_mmtt_qty_part        VARCHAR2(3000);
   l_mtlt_qty_part        VARCHAR2(3000);
   p_n NUMBER;
   p_v VARCHAR2(1);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

-- invConv changes begin
l_onhand_sqty_part  VARCHAR2(1000);
l_mmtt_sqty_part    VARCHAR2(1000);
l_mtlt_sqty_part    VARCHAR2(1000);
-- invConv changes end
BEGIN

   -- Bug 2824557, Remove the reference to demand_source_line_id
   -- Because consign quantity does not care of PJM unit numbers
   -- Therefore onhand quantity only query from MOQD
   -- pjm support
   --
   /*IF g_unit_eff_enabled IS NULL THEN
		-- To improve performance, avoid using select from dual;
		g_unit_eff_enabled := pjm_unit_eff.enabled;
      --SELECT pjm_unit_eff.enabled INTO g_unit_eff_enabled FROM dual;
   END IF; */
   --IF g_unit_eff_enabled <> 'Y' THEN
      l_onhand_qty_part := ' moq.primary_transaction_quantity ';
      l_mmtt_qty_part := ' mmtt.primary_quantity ';
      l_mtlt_qty_part := ' mtlt.primary_quantity ';

      -- invConv changes begin
      l_onhand_sqty_part := ' moq.secondary_transaction_quantity ';
      l_mmtt_sqty_part := ' mmtt.secondary_transaction_quantity ';
      l_mtlt_sqty_part := ' mtlt.secondary_quantity ';
      -- invConv changes end
   /* ELSE
      l_onhand_qty_part := ' decode(:demand_source_line_id, NULL, moq.primary_transaction_quantity, nvl(pjm_ueff_onhand.onhand_quantity
	(:demand_source_line_id,moq.inventory_item_id,moq.organization_id
	 ,moq.revision,moq.subinventory_code,moq.locator_id,moq.lot_number)
	,moq.primary_transaction_quantity)) ';
      l_mmtt_qty_part := ' decode(:demand_source_line_id, NULL, mmtt.primary_quantity, Nvl(pjm_ueff_onhand.txn_quantity(:demand_source_line_id,mmtt.transaction_temp_id,mmtt.lot_number,
	''N'',mmtt.inventory_item_id, mmtt.organization_id, mmtt.transaction_source_type_id,
	mmtt.transaction_source_id, mmtt.rcv_transaction_id,
	sign(mmtt.primary_quantity)
        ),mmtt.primary_quantity)) ';
      l_mtlt_qty_part := ' decode(:demand_source_line_id, NULL, mtlt.primary_quantity, Nvl(pjm_ueff_onhand.txn_quantity(:demand_source_line_id,mmtt.transaction_temp_id,mtlt.lot_number,
	''N'',mmtt.inventory_item_id, mmtt.organization_id, mmtt.transaction_source_type_id,
	mmtt.transaction_source_id, mmtt.rcv_transaction_id,
	sign(mmtt.primary_quantity)
	) ,mtlt.primary_quantity)) ';
   END IF; */


   -- deal with onhand quantities
   -- if containerized_flag is 1, then quantity is in container(s)

   -- invConv changes begin : added 2nd qty management in the query.
   l_onhand_stmt := '

     -- onhand quantities
     SELECT
          moq.organization_id                  organization_id
        , moq.inventory_item_id                inventory_item_id
        , moq.revision                         revision
        , moq.lot_number                       lot_number
        , moq.subinventory_code                subinventory_code
        , moq.locator_id                       locator_id
        , ' || l_onhand_qty_part || '          primary_quantity
        , ' || l_onhand_sqty_part || '         secondary_quantity
        , nvl(moq.orig_date_received,
              moq.date_received)               date_received
        , 1                                    quantity_type
	, moq.cost_group_id                    cost_group_id
        , decode(moq.containerized_flag,
		 1, 1, 0)		       containerized
     , moq.planning_organization_id            planning_organization_id
     , moq.owning_organization_id              owning_organization_id
     FROM
     mtl_onhand_quantities_detail       moq
     WHERE moq.organization_id <> Nvl(moq.planning_organization_id,moq.organization_id)
       OR  moq.organization_id <> nvl(moq.owning_organization_id, moq.organization_id) ';

   -- dealing with pending transactions in mmtt
   -- and picking suggestions
   --
   -- Notes: the put away suggestions are not considered either
   -- as reservation nor as pending transactions because of the
   -- way the integration between reservation and suggestion
   -- is currently implemented. A put away suggestion with transaction_status
   -- as 2, is not a reservation since the corresponding quantity
   -- has not been moved to the destination; it is not a pending
   -- transaction because the quantity that will be moved from source
   -- location to destination location is not available as onhand.
   -- The reason is that once it is moved, the pick confirm process might transfer
   -- an existing reservation for that quantity to the new destination.
   --
   -- WARNING: the value of transaction_action_id is used to
   -- decide whether a suggestion is a picking or it is a
   -- put away, so any changes to the transaction id
   -- should be reflected in the decode portion in the where clause

/* we are not considering pending transaction, blocking it

	IF p_is_lot_control THEN
      -- here we assume that even there is only one lot number
      -- involved in a transaction, a child record would be
      -- created in the mtl_transaction_lots_temp table.
      l_pending_txn_stmt := '
       UNION ALL
	-- pending transactions and picking suggestions
	-- in mmtt with lot number in mmtt
	--added 1 to decode statement so that we make sure the
	--issue qtys in mmtt are seen as negative.
	--added decode stmt to quantity_type.  If record is a
	--suggestion, qty-type is 5 (txn suggestion).  If it is
	--a pending txn, qty_type is 1 (quantity on hand).
        --also, added another decode stmt to primary qty.  If the
	--record is a suggestion, we want the primary_qty to be positive,
	--like a reservation
        -- if quantity is in an lpn, then it is containerized
        -- packed mmtt recs can have either lpn_id or
        -- content lpn_id populated. To handle this, changed
        -- how containerized is determined for MMTT recs. Assuming
        -- that lpn_Id and content_lpn_id are always positive,
        -- the existence of either causes containerized to be 1 (since
        -- lpn_id will be greater than 1).  If both are null,
        -- containerized will be 0 (0 is less than 1).
       SELECT
            mmtt.organization_id                 organization_id
          , mmtt.inventory_item_id               inventory_item_id
          , mmtt.revision                        revision
          , mmtt.lot_number                      lot_number
          , mmtt.subinventory_code               subinventory_code
          , mmtt.locator_id                      locator_id
          , Decode (mmtt.transaction_status, 2, 1
	     , Decode(mmtt.transaction_action_id
	       , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.primary_quantity))
	    )
	    * Abs('|| l_mmtt_qty_part || ')
          , Decode (mmtt.transaction_status, 2, 1
	     , Decode(mmtt.transaction_action_id
	       , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.secondary_transaction_quantity))
	    )
	    * Abs('|| l_mmtt_sqty_part || ')
          , Decode(mmtt.transaction_action_id
             , 1, To_date(NULL)
             , 2, To_date(NULL)
             , 28, To_date(NULL)
             , 3, To_date(NULL)
             , Decode(Sign(mmtt.primary_quantity)
                  , -1, To_date(NULL)
                  , mmtt.transaction_date))      date_received
          , Decode(mmtt.transaction_status, 2, 5, 1)  quantity_type
          , mmtt.cost_group_id		         cost_group_id
	, least(1,NVL(mmtt.lpn_id,0)+NVL(mmtt.content_lpn_id,0))
	containerized
	, planning_organization_id      planning_organziation_id
	, owning_organization_id        owning_organization_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = ''Y''
	 AND mmtt.lot_number IS NOT NULL
	 AND mmtt.subinventory_code IS NOT NULL
	 AND (Nvl(mmtt.transaction_status,0) <> 2 OR -- pending txns
	      -- only picking side of the suggested transactions are used
	      Nvl(mmtt.transaction_status,0) = 2 AND
	      mmtt.transaction_action_id IN (1,2,28,3,5,21,29,32,34)
	      )
         -- dont look at scrap and costing txns
         AND mmtt.transaction_action_id NOT IN (24,30)
            AND(  (mmtt.organization_id <> Nvl(mmtt.planning_organization_id,mmtt.organization_id))
                OR(mmtt.organization_id <> Nvl(mmtt.owning_organization_id,mmtt.organization_id)))
       UNION ALL
        -- pending transactions and suggestions in mmtt with lot numbers in lots_temp
	--added 1 to decode statement so that we make sure the
	--issue qtys in mmtt are seen as negative.
        -- if quantity is in an lpn, then it is containerized.
        -- packed mmtt recs can have either lpn_id or
        -- content lpn_id populated. To handle this, changed
        -- how containerized is determined for MMTT recs. Assuming
        -- that lpn_Id and content_lpn_id are always positive,
        -- the existence of either causes containerized to be 1 (since
        -- lpn_id will be greater than 1).  If both are null,
        -- containerized will be 0 (0 is less than 1).
       SELECT
            mmtt.organization_id                 organization_id
          , mmtt.inventory_item_id               inventory_item_id
          , mmtt.revision                        revision
          , mtlt.lot_number                      lot_number
          , mmtt.subinventory_code               subinventory_code
          , mmtt.locator_id                      locator_id
          , Decode(mmtt.transaction_status, 2, 1
 	    , Decode(mmtt.transaction_action_id
	      , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.transaction_quantity))
            )
	    * Abs('||l_mtlt_qty_part||')
          , Decode(mmtt.transaction_status, 2, 1
 	    , Decode(mmtt.transaction_action_id
	      , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.secondary_transaction_quantity))
            )
	    * Abs('||l_mtlt_sqty_part||')
          , Decode(mmtt.transaction_action_id
             , 1, To_date(NULL)
             , 2, To_date(NULL)
             , 28, To_date(NULL)
             , 3, To_date(NULL)
             , Decode(Sign(mmtt.primary_quantity)
                  , -1, To_date(NULL)
                  , mmtt.transaction_date))      date_received
          , Decode(mmtt.transaction_status, 2, 5, 1)  quantity_type
          , mmtt.cost_group_id			 cost_group_id
	   , least(1,NVL(mmtt.lpn_id,0)+NVL(mmtt.content_lpn_id,0))
	   containerized
	   , mmtt.planning_organization_id  planning_organization_id
	   , mmtt.owning_organization_id    owning_organization_id
       FROM
            mtl_material_transactions_temp mmtt
          , mtl_transaction_lots_temp      mtlt
       WHERE
              mmtt.posting_flag = ''Y''
	  AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
	  AND mmtt.lot_number IS NULL
	  AND mmtt.subinventory_code IS NOT NULL
 	  AND (Nvl(mmtt.transaction_status,0) <> 2 OR -- pending txns
	      -- only picking side of the suggested transactions are used
	      Nvl(mmtt.transaction_status,0) = 2 AND
	      mmtt.transaction_action_id IN (1,2,28,3,5,21,29,32,34)
	      )
         -- dont look at scrap and costing txns
	    AND mmtt.transaction_action_id NOT IN (24,30)
	    AND (  (mmtt.organization_id <>Nvl(mmtt.planning_organization_id,mmtt.organization_id))
	         OR(mmtt.organization_id <>Nvl(mmtt.owning_organization_id,mmtt.organization_id))) ';

	    ELSE  -- without lot control
      l_pending_txn_stmt := '
	UNION ALL
       -- pending transactions in mmtt
	--changed by jcearley on 12/8/99
	--added 1 to decode statement so that we make sure the
	--issue qtys in mmtt are seen as negative.
       -- if quantity is in an lpn, then it is containerized
        -- packed mmtt recs can have either lpn_id or
        -- content lpn_id populated. To handle this, changed
        -- how containerized is determined for MMTT recs. Assuming
        -- that lpn_Id and content_lpn_id are always positive,
        -- the existence of either causes containerized to be 1 (since
        -- lpn_id will be greater than 1).  If both are null,
        -- containerized will be 0 (0 is less than 1).
       SELECT
            mmtt.organization_id                 organization_id
          , mmtt.inventory_item_id               inventory_item_id
          , mmtt.revision                        revision
          , NULL                                 lot_number
          , mmtt.subinventory_code               subinventory_code
          , mmtt.locator_id                      locator_id
          , Decode(mmtt.transaction_status, 2, 1
	    , Decode(mmtt.transaction_action_id
		     , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.primary_quantity))
	    )
	    * Abs('|| l_mmtt_qty_part || ')
          , Decode(mmtt.transaction_status, 2, 1
	    , Decode(mmtt.transaction_action_id
		     , 1, -1, 2, -1, 28, -1, 3, 5,-1,-1, Sign(mmtt.secondary_transaction_quantity))
	    )
	    * Abs('|| l_mmtt_sqty_part || ')
          , Decode(mmtt.transaction_action_id
             , 1, To_date(NULL)
             , 2, To_date(NULL)
             , 28, To_date(NULL)
             , 3, To_date(NULL)
             , Decode(Sign(mmtt.primary_quantity)
                  , -1, To_date(NULL)
                  , mmtt.transaction_date))      date_received
          , Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , mmtt.cost_group_id		 cost_group_id
	, least(1,NVL(mmtt.lpn_id,0)+NVL(mmtt.content_lpn_id,0))
	containerized
	, mmtt.planning_organization_id planning_organization_id
	, mmtt.owning_organization_id   owning_organization_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
              mmtt.posting_flag = ''Y''
	  AND mmtt.subinventory_code IS NOT NULL
 	  AND (Nvl(mmtt.transaction_status,0) <> 2 OR -- pending txns
	      -- only picking side of the suggested transactions are used
	      Nvl(mmtt.transaction_status,0) = 2 AND
	       mmtt.transaction_action_id IN (1,2,28,3,5,21,29,32,34)
	      )
	    -- dont look at scrap and costing txns
	    AND mmtt.transaction_action_id NOT IN (24,30)
	    AND (  (mmtt.organization_id <> Nvl(mmtt.planning_organization_id,mmtt.organization_id))
	         OR(mmtt.organization_id <> Nvl(mmtt.owning_organization_id,mmtt.organization_id))) ';

   END IF;

	*/

   -- common restrictions
   IF p_asset_sub_only THEN
      l_asset_sub_where := '
        AND Nvl(sub.asset_inventory,1) = 1';
    ELSE
      l_asset_sub_where := NULL;
   END IF;

   IF (p_onhand_source = g_atpable_only) THEN
	l_onhand_source_where := '
	 AND Nvl(sub.inventory_atp_code, 1) = 1';
   ELSIF (p_onhand_source = g_nettable_only) THEN
	l_onhand_source_where := '
	 AND Nvl(sub.availability_type, 1) = 1';
   ELSE	--do nothing if g_all_subs
	l_onhand_source_where := NULL;
   END IF;

   --bug 1384720 - performanc improvements
   -- need 2 lot selects - one for inner query, one for outer
   IF p_is_lot_control THEN
      l_lot_select := '
        , x.lot_number            lot_number ';
      l_lot_select2 := '
        , lot.expiration_date     lot_expiration_date';
      l_lot_from := '
        , mtl_lot_numbers  lot';
      l_lot_where := '
        AND x.organization_id   = lot.organization_id   (+)
        AND x.inventory_item_id = lot.inventory_item_id (+)
        AND x.lot_number        = lot.lot_number        (+) ';

      -- invConv changes begin
      -- odab added the grade in the query :
      IF (p_grade_code IS NOT NULL)
      THEN
         l_lot_where := l_lot_where || ' AND lot.grade_code = :grade_code ';
      END IF;
      -- invConv changes end

      l_lot_group := '
        , x.lot_number ';
    ELSE
      l_lot_select := '
        , NULL                    lot_number';
      l_lot_select2 := '
        , To_date(NULL)           lot_expiration_date';
      l_lot_from := NULL;
      l_lot_where := NULL;
      l_lot_group := NULL;
   END IF;

   IF p_is_lot_control AND p_lot_expiration_date IS NOT NULL THEN
      l_lot_expiration_where := '
        AND (lot.expiration_date IS NULL OR
             lot.expiration_date > :lot_expiration_date) ';
    ELSE
      l_lot_expiration_where := NULL;
   END IF;

   --Bug 1830809 - If revision control is passed in a No, set
   -- revision to be NULL.
   IF p_is_revision_control THEN
      l_revision_select := '
        , x.revision            revision';
   ELSE
      l_revision_select := '
        , NULL                  revision';
   END IF;


   --bug 1384720
   -- Moved group by statement into subquery.  This minimizes
   -- the number of joins to the lot and sub tables.
   l_stmt := '
     SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
	, x.lot_number		  lot_number '
        || l_lot_select2 || '
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.date_received         date_received
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
     , x.containerized	  containerized
     , x.planning_organization_id    planning_organization_id
     , x.owning_organization_id      owning_organization_id
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id '
         || l_revision_select || l_lot_select || '
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , MIN(x.date_received)    date_received
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
	   , x.containerized	  containerized
	    , x.planning_organization_id    planning_organization_id
	    , x.owning_organization_id      owning_organization_id
        FROM ('
	       || l_onhand_stmt      || '
	       ) x
        WHERE x.organization_id    = :organization_id
          AND x.inventory_item_id  = :inventory_item_id
        GROUP BY
           x.organization_id, x.inventory_item_id, x.revision '
          || l_lot_group || '
          , x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.containerized
          , x.planning_organization_id, x.owning_organization_id
       ) x
        , mtl_secondary_inventories sub '
        || l_lot_from || '
     WHERE
        x.organization_id    = sub.organization_id          (+)
        AND x.subinventory_code  = sub.secondary_inventory_name (+) '
        || l_lot_where || l_lot_expiration_where || l_asset_sub_where
        || l_onhand_source_where  ;

   x_return_status := l_return_status;
   x_sql_statement := l_stmt;

   -- This prints the above SQL
   /*dbms_output.put_line(x_return_status);
     dbms_output.put_line('1'||l_lot_group);
     dbms_output.put_line('2'||l_lot_from);
     dbms_output.put_line('3'||l_lot_where);
     dbms_output.put_line('4'||l_asset_sub_where);
     dbms_output.put_line('5'||l_onhand_source_where);
     dbms_output.put_line('6'||l_lot_expiration_where);


     dbms_output.enable(5000000);
     FOR p_n IN 1..length(x_sql_statement) LOOP
     p_v := Substr( x_sql_statement,p_n,1);
     IF p_v = Chr(10) THEN
     dbms_output.new_line;
     ELSE
     dbms_output.put(p_v);
     END IF;
     END LOOP;
     dbms_output.new_line;*/



     EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
         inv_log_util.trace('When Others Ex. in build sql','CONSIGNED_VALIDATIONS',9);
      END IF;
END build_sql;


-- Procedure
--   build_cursor
-- Description
--   this procedure calls the build_sql procedure to get the sql statment and
--   parse it, bind variables, and return the cursor
PROCEDURE build_cursor
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_organization_id         IN  NUMBER
   , p_inventory_item_id       IN  NUMBER
   , p_mode                    IN  INTEGER
   , p_grade_code              IN  VARCHAR2                        -- invConv change
   , p_demand_source_line_id   IN  NUMBER
   , p_is_lot_control          IN  BOOLEAN
   , p_asset_sub_only          IN  BOOLEAN
   , p_lot_expiration_date     IN  DATE
   , p_onhand_source	       IN  NUMBER
   , p_pick_release	       IN  NUMBER
   , x_cursor                  OUT NOCOPY NUMBER
   , p_is_revision_control     IN  BOOLEAN
   ) IS
      l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_cursor              NUMBER;
      l_sql                 LONG;
      l_last_error_pos      NUMBER;
      l_temp_str            VARCHAR2(30);
      l_err                 VARCHAR2(240);
      l_pos                 NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_cursor := dbms_sql.open_cursor;
   IF (l_debug = 1) THEN
      inv_log_util.trace('Inside Build Cursor','CONSIGNED_VALIDATIONS',9);
   END IF;

   build_sql
    ( x_return_status       => l_return_status
    , p_mode                => p_mode
    , p_grade_code          => p_grade_code              -- invConv change
    , p_is_lot_control      => p_is_lot_control
    , p_asset_sub_only      => p_asset_sub_only
    , p_lot_expiration_date => p_lot_expiration_date
    , p_onhand_source       => p_onhand_source
    , p_pick_release        => p_pick_release
    , x_sql_statement       => l_sql
    , p_is_revision_control => p_is_revision_control);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   BEGIN
      dbms_sql.parse(l_cursor,l_sql,dbms_sql.v7);
   EXCEPTION
      WHEN OTHERS THEN
         l_last_error_pos := dbms_sql.last_error_position();
         l_temp_str := Substr(l_sql, l_last_error_pos-5, 30);
         RAISE;
   END;
   dbms_sql.bind_variable(l_cursor, ':organization_id', p_organization_id);
   dbms_sql.bind_variable(l_cursor, ':inventory_item_id', p_inventory_item_id);

   -- invConv changes begin
   IF (p_grade_code IS NOT NULL AND p_grade_code <> '')
   THEN
     dbms_sql.bind_variable(l_cursor, ':grade_code', p_grade_code);
   END IF;
   -- invConv changes end

   -- Bug 2824557, Remove the reference to demand_source_line_id
   -- Because consign quantity does not care of PJM unit numbers
   /*IF p_mode IN (g_loose_only_mode) OR
     g_unit_eff_enabled = 'Y' THEN
      dbms_sql.bind_variable(l_cursor, ':demand_source_line_id'
                             , p_demand_source_line_id);
   END IF;*/

   IF p_is_lot_control AND p_lot_expiration_date IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':lot_expiration_date'
                             , p_lot_expiration_date);
   END IF;
   x_cursor := l_cursor;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Build_Cursor'
              );
      END IF;
END build_cursor;


-------------------------------------------------------------------------------
-- Procedure                                                                 --
--   populate_consigned_qty_temp                                             --
--                                                                           --
-- Description                                                               --
--   This is a server side test procedure for build_sql. It calls            --
--   build_sql with the input values to build a sql statement. Then          --
--   it execute the statement to print out query result to dbms_output.      --
--   You should turn on serveroutput to see the output.                      --
--                                                                           --
-- Input Parameters                                                          --
--   p_mode                                                                  --
--     equals inv_quantity_tree_pvt.g_loose_mode or                          --
--     inv_quantity_tree_pvt.g_transaction_mode                              --
--   p_organization_id                                                       --
--     organization_id                                                       --
--   p_inventory_item_id                                                     --
--     inventory_item_id                                                     --
--   p_is_lot_control                                                        --
--     true or false                                                         --
--   p_asset_sub_only                                                        --
--     true or false                                                         --
--   p_include_suggestion                                                    --
--     true or false     should be true only for pick/put engine             --
--   p_lot_expiration_date                                                   --
--     if not null, only consider lots that will not expire before           --
--     or at the date                                                        --
--   p_demand_source_type_id                                                 --
--     demand_source_type_id                                                 --
-------------------------------------------------------------------------------
PROCEDURE populate_consigned_qty_temp
  (
     p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_mode                     IN  INTEGER
   , p_grade_code               IN  VARCHAR2                  -- invConv change
   , p_is_lot_control           IN  BOOLEAN
   , p_is_revision_control      IN BOOLEAN
   , p_asset_sub_only           IN  BOOLEAN
   , p_lot_expiration_date      IN  DATE
   , p_demand_source_line_id    IN  NUMBER
   , p_onhand_source		IN  NUMBER
   , p_qty_tree_att             IN NUMBER
   , p_qty_tree_satt            IN  NUMBER                   -- invConv change
   , x_return_status            OUT NOCOPY VARCHAR2
   ) IS
     l_cursor NUMBER;
     l_return_status VARCHAR2(1);
     l_revision VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number VARCHAR2(80);
     l_subinventory_code VARCHAR2(10);
     l_lot_expiration_date DATE;
     l_reservable_type NUMBER;
     l_primary_quantity NUMBER;
     l_secondary_quantity NUMBER;  -- InvConv change
     l_date_received DATE;
     l_quantity_type NUMBER;
     l_dummy INTEGER;
     l_locator_id NUMBER;
     l_inventory_item_id NUMBER;
     l_organization_id NUMBER;
     l_cost_group_id NUMBER;
     l_containerized NUMBER;
     l_planning_organization_id NUMBER;
     l_owning_organization_id NUMBER;
     ll_transactable_vmi NUMBER;
     ll_transactable_secondary_vmi NUMBER;   -- InvConv change
     ---- Variabls to get values from cursor
     lL_revision VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     lL_lot_number VARCHAR2(80);
     lL_subinventory_code VARCHAR2(10);
     lL_lot_expiration_date DATE;
     ll_reservable_type NUMBER;
     ll_primary_quantity NUMBER;
     ll_secondary_quantity NUMBER;           -- InvConv change
     ll_date_received DATE;
     ll_quantity_type NUMBER;
     ll_locator_id NUMBER;
     ll_inventory_item_id NUMBER;
     ll_organization_id NUMBER;
     ll_cost_group_id NUMBER;
     ll_containerized NUMBER;
     ll_planning_organization_id NUMBER;
     ll_owning_organization_id NUMBER;
     --------------------------------------
     l_count NUMBER := 0;
     l_temp NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   build_cursor
      ( x_return_status           => l_return_status
      , p_organization_id         => p_organization_id
      , p_inventory_item_id       => p_inventory_item_id
      , p_mode                    => p_mode
      , p_grade_code              => p_grade_code            -- invConv change
      , p_demand_source_line_id   => p_demand_source_line_id
      , p_is_lot_control          => p_is_lot_control
      , p_is_revision_control     => p_is_revision_control
      , p_asset_sub_only          => p_asset_sub_only
      , p_lot_expiration_date     => p_lot_expiration_date
      , p_onhand_source		  => p_onhand_source
      , p_pick_release		  => 0
      , x_cursor                  => l_cursor
      );

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      l_return_status:= fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;



   dbms_sql.define_column(l_cursor, 1,l_organization_id);
   dbms_sql.define_column(l_cursor, 2,l_inventory_item_id);
   dbms_sql.define_column(l_cursor, 3,l_revision,3);
   dbms_sql.define_column(l_cursor, 4,l_lot_number,30);
   dbms_sql.define_column(l_cursor, 5,l_lot_expiration_date);
   dbms_sql.define_column(l_cursor, 6,l_subinventory_code,10);
   dbms_sql.define_column(l_cursor, 7,l_reservable_type);
   dbms_sql.define_column(l_cursor, 8,l_locator_id);
   dbms_sql.define_column(l_cursor, 9,l_primary_quantity);
   dbms_sql.define_column(l_cursor,10,l_secondary_quantity);     -- invConv change
   dbms_sql.define_column(l_cursor,11,l_date_received);               -- invConv renamed order number
   dbms_sql.define_column(l_cursor,12,l_quantity_type);               -- invConv renamed order number
   dbms_sql.define_column(l_cursor,13,l_cost_group_id);               -- invConv renamed order number
   dbms_sql.define_column(l_cursor,14,l_containerized);               -- invConv renamed order number
   dbms_sql.define_column(l_cursor,15,l_planning_organization_id);    -- invConv renamed order number
   dbms_sql.define_column(l_cursor,16,l_owning_organization_id);      -- invConv renamed order number

   l_dummy := dbms_sql.execute(l_cursor);
   LOOP
      IF dbms_sql.fetch_rows(l_cursor) = 0 THEN
         EXIT;
      END IF;

      l_count := l_count + 1;
      ll_transactable_vmi:= 0;
      ll_transactable_secondary_vmi:= 0;           -- invConv change

      dbms_sql.column_value(l_cursor, 1,ll_organization_id);
      dbms_sql.column_value(l_cursor, 2,ll_inventory_item_id);
      dbms_sql.column_value(l_cursor, 3,ll_revision);
      dbms_sql.column_value(l_cursor, 4,ll_lot_number);
      dbms_sql.column_value(l_cursor, 5,ll_lot_expiration_date);
      dbms_sql.column_value(l_cursor, 6,ll_subinventory_code);
      dbms_sql.column_value(l_cursor, 7,ll_reservable_type);
      dbms_sql.column_value(l_cursor, 8,ll_locator_id);
      dbms_sql.column_value(l_cursor, 9,ll_primary_quantity);
      dbms_sql.column_value(l_cursor,10,ll_secondary_quantity);    -- InvConv change
      dbms_sql.column_value(l_cursor,11,ll_date_received);               -- invConv renamed order number
      dbms_sql.column_value(l_cursor,12,ll_quantity_type);               -- invConv renamed order number
      dbms_sql.column_value(l_cursor,13,ll_cost_group_id);               -- invConv renamed order number
      dbms_sql.column_value(l_cursor,14,ll_containerized);               -- invConv renamed order number
      dbms_sql.column_value(l_cursor,15,ll_planning_organization_id);    -- invConv renamed order number
      dbms_sql.column_value(l_cursor,16,ll_owning_organization_id);      -- invConv renamed order number

      IF (p_qty_tree_att<=ll_primary_quantity)THEN
	 ll_transactable_vmi:=p_qty_tree_att;
	 ll_transactable_secondary_vmi:=p_qty_tree_satt;    -- InvConv change
       ELSE
	 ll_transactable_vmi:=ll_primary_quantity;
	 ll_transactable_secondary_vmi:=ll_secondary_quantity;    -- InvConv change
      END IF;

      INSERT INTO mtl_consigned_qty_temp (organization_id,
					   inventory_item_id,
					   revision,
					   lot_number,
					   lot_expiration_date,
					   subinventory_code,
					   reservable_type,
					   locator_id,
					   grade_code,                     -- invConv change
					   primary_quantity,
					   secondary_quantity,             -- invConv change
					   transactable_vmi,
					   transactable_secondary_vmi,     -- invConv change
					   date_received,
					   quantity_type,
					   cost_group_id,
					   containerized,
					   planning_organization_id,
					   owning_organization_id)
	VALUES
	(
	  ll_organization_id,
	  ll_inventory_item_id,
	  ll_revision,
	  ll_lot_number,
	  ll_lot_expiration_date,
	  ll_subinventory_code,
	  ll_reservable_type,
	  ll_locator_id,
          p_grade_code,                      -- invConv change
	  ll_primary_quantity,
	  ll_secondary_quantity,             -- invConv change
	  ll_transactable_vmi,
	  ll_transactable_secondary_vmi,      -- invConv change
	  ll_date_received,
	  ll_quantity_type,
	  ll_cost_group_id,
	  ll_containerized,
	  ll_planning_organization_id,
	  ll_owning_organization_id);
   END LOOP;
   dbms_sql.close_cursor(l_cursor);
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         inv_log_util.trace('When others Ex. in Inserting in temp table','CONSIGNED_VALIDATIONS',9);
      END IF;
END populate_consigned_qty_temp;

/* invconv changes begin : this procedure is now obsolete
             and replaced by check_is_reservable :
-- Procedure
--  check_is_reservable_sub
-- Description
--  check from db tables whether the sub specified in
--  the input is a reservable sub or not.
PROCEDURE check_is_reservable_sub
  (   x_return_status       OUT NOCOPY VARCHAR2
      , p_organization_id     IN  VARCHAR2
      , p_subinventory_code   IN  VARCHAR2
      , x_is_reservable_sub   OUT NOCOPY BOOLEAN
      ) IS
         l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
         l_reservable_type  NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SELECT reservable_type INTO l_reservable_type
     FROM mtl_secondary_inventories
     WHERE organization_id = p_organization_id
     AND secondary_inventory_name = p_subinventory_code;
   IF (l_reservable_type = 1) THEN
      x_is_reservable_sub := TRUE;
    ELSE
      x_is_reservable_sub := FALSE;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (l_debug = 1) THEN
         inv_log_util.trace('check_is_reservable_sub','CONSIGNED_VALIDATIONS',9);
      END IF;

END check_is_reservable_sub;
invConv changes end. */

-- invConv change begin : new procedure in replacement of check_is_reservable_sub:
-- Procedure
--  check_is_reservable
-- Description
--  check from db tables whether the sub specified in
--  the input is a reservable sub or not.
PROCEDURE check_is_reservable
  (   x_return_status       OUT NOCOPY VARCHAR2
    , p_node_level          IN  INTEGER    DEFAULT NULL
    , p_inventory_item_id   IN  NUMBER
    , p_organization_id     IN  NUMBER
    , p_subinventory_code   IN  VARCHAR2
    , p_locator_id          IN  NUMBER
    , p_lot_number          IN  VARCHAR2
    , x_is_reservable       OUT NOCOPY BOOLEAN
      ) IS

l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_reservable_type  NUMBER;

CURSOR is_RSV_subInv( org_id IN NUMBER
                    , subinv IN VARCHAR2) IS
SELECT reservable_type
FROM mtl_secondary_inventories
WHERE organization_id = org_id
AND secondary_inventory_name = subinv;

--SELECT TO_NUMBER(NVL(attribute1, '0'))
CURSOR is_RSV_loct( org_id IN NUMBER
                  , loct_id IN NUMBER) IS
SELECT '1'
FROM mtl_item_locations mil
WHERE mil.status_id IN
  (SELECT mms.status_id
   FROM mtl_material_statuses mms
   WHERE NVL(mms.attribute1, '1') = '1'
   AND mms.locator_control = 1)
AND mil.organization_id = org_id
AND mil.inventory_location_id = loct_id;

--SELECT TO_NUMBER(NVL(attribute1, '0'))
CURSOR is_RSV_lot( org_id IN NUMBER
                 , item_id IN NUMBER
                 , lot IN VARCHAR2) IS
SELECT '1'
FROM mtl_lot_numbers mln
WHERE mln.status_id IN
  (SELECT mms.status_id
   FROM mtl_material_statuses mms
   WHERE NVL(mms.attribute1, '1') = '1'
AND mms.lot_control = 1)
AND mln.inventory_item_id = item_id
AND mln.organization_id = org_id
AND mln.lot_number = lot;

l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
IF (l_debug = 1) THEN
  inv_log_util.trace('in check_is_reservable. node_level='||p_node_level||', subinv='||p_subinventory_code||', loct='||p_locator_id||', lot='||p_lot_number, 'CONSIGNED_VALIDATIONS',9);
END IF;

-- lot level = 4
-- subinv level = 5
-- locator level = 6
IF (NVL(p_node_level,0) = 4)
  OR (p_lot_number IS NOT NULL)
THEN
   OPEN is_RSV_lot( p_organization_id, p_inventory_item_id, p_lot_number);
   FETCH is_RSV_lot
    INTO l_reservable_type;
   IF (is_RSV_lot%NOTFOUND)
   THEN
      l_reservable_type := '0';
   END IF;
   CLOSE is_RSV_lot;

   IF (l_debug = 1) THEN
      inv_log_util.trace('in RSV reservable='||l_reservable_type||', for lot='||p_lot_number, 'CONSIGNED_VALIDATIONS',9);
   END IF;

ELSIF (NVL(p_node_level, 0) = 6)
  OR (p_locator_id IS NOT NULL)
THEN
   OPEN is_RSV_loct( p_organization_id, p_locator_id);
   FETCH is_RSV_loct
    INTO l_reservable_type;
   IF (is_RSV_loct%NOTFOUND)
   THEN
      l_reservable_type := '0';
   END IF;
   CLOSE is_RSV_loct;

IF (l_debug = 1) THEN
   inv_log_util.trace('in RSV reservable='||l_reservable_type||', for locator='||p_locator_id, 'CONSIGNED_VALIDATIONS',9);
END IF;

ELSIF (NVL(p_node_level, 0) = 5)
  OR (p_subinventory_code IS NOT NULL)
THEN
   OPEN is_RSV_subInv( p_organization_id, p_subinventory_code);
   FETCH is_RSV_subInv
    INTO l_reservable_type;
   CLOSE is_RSV_subInv;

IF (l_debug = 1) THEN
   inv_log_util.trace('in RSV reservable='||l_reservable_type||', for subInv='||p_subinventory_code, 'CONSIGNED_VALIDATIONS',9);
END IF;

END IF;

IF (l_reservable_type = 1) THEN
   x_is_reservable := TRUE;
   IF (l_debug = 1) THEN
      inv_log_util.trace('in RSV reservable=TRUE', 'CONSIGNED_VALIDATIONS',9);
   END IF;
ELSE
   x_is_reservable := FALSE;
   IF (l_debug = 1) THEN
      inv_log_util.trace('in RSV reservable=FALSE', 'CONSIGNED_VALIDATIONS',9);
   END IF;
END IF;

x_return_status := l_return_status;

EXCEPTION

     WHEN OTHERS THEN
IF (l_debug = 1) THEN
   inv_log_util.trace('in check_is_reservable, OTHERS Error='||SQLERRM, 'CONSIGNED_VALIDATIONS',9);
END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Check_Is_Reservable'
              );
        END IF;

END check_is_reservable;
-- invConv changes end.

-- This API is to be called to delete the existing
-- cache of the global temporary table.
-- This will also delete the cache of the quantity tree
PROCEDURE clear_vmi_cache
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_quantity_tree_pub.clear_quantity_cache;
   DELETE FROM mtl_consigned_qty_temp;
END clear_vmi_cache;

/********************
 * Public API       *
 ********************/

/*------------------------*
 * GET_CONSIGNED_QUANTITY *
 *------------------------*/
/** This API will return VMI/consigned Quantity */


PROCEDURE GET_CONSIGNED_QUANTITY(
	x_return_status       OUT NOCOPY VARCHAR2,
	x_return_msg          OUT NOCOPY VARCHAR2,
	p_tree_mode           IN NUMBER,
	p_organization_id     IN NUMBER,
	p_owning_org_id       IN NUMBER,
	p_planning_org_id     IN NUMBER,
	p_inventory_item_id   IN NUMBER,
	p_is_revision_control IN VARCHAR2,
	p_is_lot_control      IN VARCHAR2,
	p_is_serial_control   IN VARCHAR2,
	p_revision            IN VARCHAR2,
	p_lot_number          IN VARCHAR2,
	p_lot_expiration_date IN  DATE,
	p_subinventory_code   IN  VARCHAR2,
	p_locator_id          IN NUMBER,
	p_source_type_id      IN NUMBER,
	p_demand_source_line_id IN NUMBER,
	p_demand_source_header_id IN NUMBER,
	p_demand_source_name  IN  VARCHAR2,
	p_onhand_source       IN NUMBER,
	p_cost_group_id       IN NUMBER,
	p_query_mode          IN NUMBER,
	x_qoh                 OUT NOCOPY NUMBER,
	x_att                 OUT NOCOPY NUMBER) IS

l_sqoh    NUMBER;    -- invConv change
l_satt    NUMBER;    -- invConv change

BEGIN
debug_print('entering old get_consigned_quantity');

-- invConv changes begin:
-- Calling the new get_consigned_quantity:
INV_CONSIGNED_VALIDATIONS.get_consigned_quantity
	( x_return_status       => x_return_status
	, x_return_msg          => x_return_msg
	, p_tree_mode           => p_tree_mode
	, p_organization_id     => p_organization_id
	, p_owning_org_id       => p_owning_org_id
	, p_planning_org_id     => p_planning_org_id
	, p_inventory_item_id   => p_inventory_item_id
	, p_is_revision_control => p_is_revision_control
	, p_is_lot_control      => p_is_lot_control
	, p_is_serial_control   => p_is_serial_control
	, p_revision            => p_revision
	, p_lot_number          => p_lot_number
	, p_lot_expiration_date => p_lot_expiration_date
	, p_subinventory_code   => p_subinventory_code
	, p_locator_id          => p_locator_id
	, p_grade_code          => NULL                      -- invConv change
	, p_source_type_id      => p_source_type_id
	, p_demand_source_line_id => p_demand_source_line_id
	, p_demand_source_header_id => p_demand_source_header_id
	, p_demand_source_name  => p_demand_source_name
	, p_onhand_source       => p_onhand_source
	, p_cost_group_id       => p_cost_group_id
	, p_query_mode          => p_query_mode
	, x_qoh                 => x_qoh
	, x_att                 => x_att
	, x_sqoh                => l_sqoh                    -- invConv change
	, x_satt                => l_satt);                  -- invConv change

END get_consigned_quantity;


-- invConv changes begin:
-- Overloaded procedure (entry point).
PROCEDURE get_consigned_quantity(
	x_return_status       OUT NOCOPY VARCHAR2,
	x_return_msg          OUT NOCOPY VARCHAR2,
	p_tree_mode           IN NUMBER,
	p_organization_id     IN NUMBER,
	p_owning_org_id       IN NUMBER,
	p_planning_org_id     IN NUMBER,
	p_inventory_item_id   IN NUMBER,
	p_is_revision_control IN VARCHAR2,
	p_is_lot_control      IN VARCHAR2,
	p_is_serial_control   IN VARCHAR2,
	p_revision            IN VARCHAR2,
	p_lot_number          IN VARCHAR2,
	p_lot_expiration_date IN  DATE,
	p_subinventory_code   IN  VARCHAR2,
	p_locator_id          IN NUMBER,
	p_grade_code          IN VARCHAR2,               -- invConv change
	p_source_type_id      IN NUMBER,
	p_demand_source_line_id IN NUMBER,
	p_demand_source_header_id IN NUMBER,
	p_demand_source_name  IN  VARCHAR2,
	p_onhand_source       IN NUMBER,
	p_cost_group_id       IN NUMBER,
	p_query_mode          IN NUMBER,
	x_qoh                 OUT NOCOPY NUMBER,
	x_att                 OUT NOCOPY NUMBER,
	x_sqoh                OUT NOCOPY NUMBER,         -- invConv change
	x_satt                OUT NOCOPY NUMBER) IS      -- invConv change

	l_msg_count VARCHAR2(100);
	l_msg_data VARCHAR2(1000);
	l_is_revision_control BOOLEAN := FALSE;
	l_is_lot_control BOOLEAN := FALSE;
	l_is_serial_control BOOLEAN := FALSE;
	l_tree_mode NUMBER;
	l_table_count NUMBER := 0;

	l_qoh NUMBER;
	l_rqoh NUMBER;
	l_qr NUMBER;
	l_qs NUMBER;
	l_atr NUMBER;
	l_att NUMBER;
	l_vcoh NUMBER;
	l_sqoh NUMBER;       -- invConv change
	l_srqoh NUMBER;      -- invConv change
	l_sqr NUMBER;        -- invConv change
	l_sqs NUMBER;        -- invConv change
	l_satr NUMBER;       -- invConv change
	l_satt NUMBER;       -- invConv change
	l_svcoh NUMBER;      -- invConv change
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

	IF (l_debug = 1) THEN
   	debug_print('****** GET_CONSIGNED_QUANTITIES *******','CONSIGNED_VALIDATIONS',9);
   	debug_print(' Org, Owning_org, planning_org='|| p_organization_id ||','
		|| p_owning_org_id ||','||p_planning_org_id,'CONSIGNED_VALIDATIONS',9);
   	debug_print(' Item, Is Rev, Lot, Serial controlled: '||p_inventory_item_id|| ','||
		p_is_revision_control ||','|| p_is_lot_control ||','|| p_is_serial_control,'CONSIGNED_VALIDATIONS',9);
   	debug_print(' Rev, Lot, LotExpDate: '|| p_revision ||','||p_lot_number ||','|| p_lot_expiration_date,'CONSIGNED_VALIDATIONS',9);
   	debug_print(' grade='||p_grade_code||'...','CONSIGNED_VALIDATIONS',9);
   	debug_print(' Sub, Loc: '||p_subinventory_code||','||p_locator_id,'CONSIGNED_VALIDATIONS',9);
   	debug_print(' SourceTypeID, DemdSrcLineID, DemdSrcHdrID, DemdSrcName: ' ||
		p_source_type_id ||',' ||p_demand_source_line_id || ','||
		p_demand_source_header_id || ',' || p_demand_source_name,'CONSIGNED_VALIDATIONS',9);
   	debug_print(' OnhandSource, CstGroupID, QueryMode: '|| p_onhand_source || ','||
		p_cost_group_id ||',' ||p_query_mode,'CONSIGNED_VALIDATIONS',9);
        END IF;

	x_return_status:= fnd_api.g_ret_sts_success;

	IF p_tree_mode IS NULL THEN
		l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
	ELSE l_tree_mode := p_tree_mode;
	END IF ;

	-- validate demand source info
	IF p_tree_mode IN (g_transaction_mode, g_loose_only_mode) THEN
		IF p_source_type_id IS NULL THEN
			fnd_message.set_name('INV', 'INV-MISSING DEMAND SOURCE TYPE');
			fnd_msg_pub.ADD;
			x_return_msg := fnd_message.get;
			RAISE fnd_api.g_exc_error;
		END IF;

		IF p_demand_source_header_id IS NULL THEN
			IF p_demand_source_name IS NULL THEN
			fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
			fnd_msg_pub.ADD;
			x_return_msg := fnd_message.get;
			RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		IF p_demand_source_header_id IS NULL
			AND p_demand_source_line_id IS NOT NULL THEN
			fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
			fnd_msg_pub.ADD;
			x_return_msg := fnd_message.get;
			RAISE fnd_api.g_exc_error;
		END IF;
	END IF;

	IF (Upper(p_is_revision_control) = 'TRUE') OR (Upper(p_is_revision_control)=fnd_api.g_true) THEN
		l_is_revision_control := TRUE;
	END IF;

	IF (Upper(p_is_lot_control) = 'TRUE') OR (Upper(p_is_lot_control)=fnd_api.g_true) THEN
		l_is_lot_control := TRUE;
	END IF;

	IF (Upper(p_is_serial_control) = 'TRUE') OR (Upper(p_is_serial_control) = fnd_api.g_true) THEN
 		l_is_serial_control := TRUE;
	END IF;

	/* Validate input parameters */
	IF (p_inventory_item_id IS NULL) THEN
		fnd_message.set_name('INV', 'INV_INT_ITMCODE');
		fnd_msg_pub.ADD;
		x_return_msg := fnd_message.get;
		RAISE fnd_api.g_exc_unexpected_error;
	END IF ;

	IF (p_query_mode = G_TXN_MODE) THEN
		IF  (p_owning_org_id IS NULL AND p_planning_org_id IS NULL) THEN
			fnd_message.set_name('INV', 'INV_OWN_PLAN_ORG_REQUIRED');
			fnd_msg_pub.ADD;
			x_return_msg := fnd_message.get;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF ;
	ELSIF (p_query_mode = G_REG_MODE) THEN
		IF  (p_owning_org_id IS NULL) THEN
			fnd_message.set_name('INV', 'INV_OWN_ORG_REQUIRED');
			fnd_msg_pub.ADD;
			x_return_msg := fnd_message.get;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF ;
	END IF;

	IF (l_debug = 1) THEN
   	inv_log_util.trace('Done validation','CONSIGNED_VALIDATIONS',9);
	END IF;
	IF (p_query_mode = G_REG_MODE) THEN

		IF (l_debug = 1) THEN
   		inv_log_util.trace('Transfer regular to consigned','CONSIGNED_VALIDATIONS',9);
		END IF;
                -- invConv changes begin : added secondary quantities :
		SELECT Nvl(sum(primary_transaction_quantity),0)
                , Nvl(sum(secondary_transaction_quantity),0)
                INTO x_att
                   , x_satt
		FROM mtl_onhand_quantities_detail
		WHERE owning_organization_id = organization_id
		AND organization_id = p_organization_id
		AND owning_organization_id <> p_owning_org_id
		AND inventory_item_id = p_inventory_item_id
		AND nvl(revision,'@@@') = nvl(p_revision, nvl(revision,'@@@'))
		AND nvl(lot_number, '@@@') = nvl(p_lot_number, nvl(lot_number, '@@@'))
		AND subinventory_code = nvl(p_subinventory_code, subinventory_code)
		AND nvl(locator_id, -999) = nvl(p_locator_id, nvl(locator_id, -999))
		AND nvl(cost_group_id, -999) = nvl(p_cost_group_id, nvl(cost_group_id, -999));

		x_qoh := x_att;
		x_sqoh := x_satt;                   -- invConv change
		IF (l_debug = 1) THEN
   		inv_log_util.trace('Got qty, x_qoh=x_att='||x_att,'CONSIGNED_VALIDATIONS',9);
		END IF;

		RETURN;
	END IF;


	--SELECT COUNT(*)INTO l_table_count FROM mtl_consigned_qty_temp
	--WHERE inventory_item_id = p_inventory_item_id
	--AND organization_id = p_organization_id;
	--Use Exists to check existance
	l_table_count := 0;
	BEGIN
	SELECT 1 INTO l_table_count FROM dual
	WHERE EXISTS (SELECT 1 FROM mtl_consigned_qty_temp
	              WHERE inventory_item_id = p_inventory_item_id
	              AND organization_id = p_organization_id);
	EXCEPTION
		WHEN others THEN
			l_table_count:=0;
	END;

	-- Clear the already existing cache only if for this item and org no table
	-- exists.
	IF (l_table_count = 0) THEN
		IF (l_debug = 1) THEN
   		inv_log_util.trace('Going to build SQL','CONSIGNED_VALIDATIONS',9);
		END IF;

		populate_consigned_qty_temp(
			p_organization_id      =>  p_organization_id
		,	p_inventory_item_id    =>  p_inventory_item_id
		,	p_mode                 =>  l_tree_mode
		,	p_grade_code           =>  p_grade_code                -- invConv change
		,	p_is_lot_control       =>  l_is_lot_control
		,	p_is_revision_control  =>  l_is_revision_control
		,	p_asset_sub_only       =>  null
		,	p_lot_expiration_date  =>  null
		,	p_demand_source_line_id => p_demand_source_line_id
		,	p_onhand_source	       =>  p_onhand_source
		,	p_qty_tree_att         =>  x_att
		, 	p_qty_tree_satt        =>  x_satt                       -- invConv change
		,	x_return_status        =>  x_return_status) ;

		IF x_return_status <> fnd_api.g_ret_sts_success THEN
			IF (l_debug = 1) THEN
   			inv_log_util.trace('populate consigned temp Failed','CONSIGNED_VALIDATIONS',9);
			END IF;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END IF;

	IF (l_debug = 1) THEN
   	inv_log_util.trace('Query consigned temp table for l_vcoh','CONSIGNED_VALIDATIONS',9);
	END IF;
 	inv_consigned_validations.query_vmi_consigned(
		x_return_status        =>   x_return_status
	,	x_msg_count            =>   l_msg_count
	,	x_msg_data             =>   l_msg_data
	,	p_organization_id      =>   p_organization_id
	,	p_planning_org_id      =>   p_planning_org_id
	,	p_owning_org_id        =>   p_owning_org_id
	,	p_inventory_item_id    =>   p_inventory_item_id
	,	p_tree_mode            =>   l_tree_mode
	,	p_is_revision_control  =>   l_is_revision_control
	,	p_is_lot_control       =>   l_is_lot_control
	,	p_is_serial_control    =>   l_is_serial_control
	,	p_demand_source_line_id =>  p_demand_source_line_id
	,	p_revision             =>   p_revision
	,	p_lot_number           =>   p_lot_number
	,	p_lot_expiration_date  =>   NULL
	,	p_subinventory_code    =>   p_subinventory_code
	,	p_locator_id           =>   p_locator_id
	,	p_cost_group_id        =>   p_cost_group_id
	,	x_qoh                  =>   l_vcoh
	,	x_sqoh                 =>   l_svcoh                -- invConv change
	);

	IF x_return_status <> fnd_api.g_ret_sts_success THEN
		IF (l_debug = 1) THEN
   		inv_log_util.trace('CONSIGNED_VMI table query Failed'||l_msg_data,'CONSIGNED_VALIDATIONS',9);
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	IF (l_debug = 1) THEN
   	inv_log_util.trace('Got l_vcoh='||l_vcoh,'CONSIGNED_VALIDATIONS',9);
	END IF;

	IF (p_query_mode = G_TXN_MODE) THEN

		-- Call the quantity tree
		-- This API calls the public qty tree api to create and query the tree
		--togethor. The created tree is stored in the memory as a PL/SQL table.
		IF (l_debug = 1) THEN
   		inv_log_util.trace('Transaction Mode, calling quantity tree','CONSIGNED_VALIDATIONS',9);
		END IF;
		inv_quantity_tree_pub.query_quantities(
			p_api_version_number     =>   1.0
		,	p_init_msg_lst         =>   fnd_api.g_false
		,	x_return_status        =>   x_return_status
		,	x_msg_count            =>   l_msg_count
		,	x_msg_data             =>   l_msg_data
		,	p_organization_id      =>   p_organization_id
		,	p_inventory_item_id    =>   p_inventory_item_id
		,	p_tree_mode            =>   l_tree_mode
		,	p_grade_code           =>   p_grade_code         -- invConv change
		,	p_is_revision_control  =>   l_is_revision_control
		,	p_is_lot_control       =>   l_is_lot_control
		,	p_is_serial_control    =>   l_is_serial_control
		,	p_demand_source_type_id =>   p_source_type_id
		,	p_demand_source_line_id => p_demand_source_line_id
		,	p_demand_source_header_id=> p_demand_source_header_id
		,	p_demand_source_name   => p_demand_source_name
		,	p_revision             =>   p_revision
		,	p_lot_number           =>   p_lot_number
		,	p_lot_expiration_date  =>   NULL --for bug# 2219136
		,	p_subinventory_code    =>   p_subinventory_code
		,	p_locator_id           =>   p_locator_id
		,	p_cost_group_id        =>   p_cost_group_id
		,	x_qoh                  =>   l_qoh
		,	x_rqoh                 =>   l_rqoh
		,	x_qr                   =>   l_qr
		,	x_qs                   =>   l_qs
		,	x_att                  =>   l_att
		,	x_atr                  =>   l_atr
		,	x_sqoh                 =>   l_sqoh       -- invConv change
		,	x_srqoh                =>   l_srqoh      -- invConv change
		,	x_sqr                  =>   l_sqr        -- invConv change
		,	x_sqs                  =>   l_sqs        -- invConv change
		,	x_satt                 =>   l_satt       -- invConv change
		,	x_satr                 =>   l_satr       -- invConv change
		);

		-- If the qty tree returns and error raise an exception.
		IF x_return_status <> fnd_api.g_ret_sts_success THEN
			IF (l_debug = 1) THEN
   			inv_log_util.trace('Qty Tree Failed'||l_msg_data,'CONSIGNED_VALIDATIONS',9);
			END IF;
			x_return_msg:= l_msg_data;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		IF (l_debug = 1) THEN
   		debug_print('Called qty tree, l_qoh='||l_qoh||', sqoh='||l_sqoh||',l_att='||l_att||', satt='||l_satt,'CONSIGNED_VALIDATIONS',9);
   		debug_print('Comparing with l_vcoh='||l_vcoh||', svcoh='||l_svcoh,'CONSIGNED_VALIDATIONS',9);
		END IF;
		--consign/VMI att is min of qty tree att and vmi/consigned onhand.
		IF (l_vcoh <= l_att) THEN
			x_att:= l_vcoh;
			x_satt:= l_svcoh;         -- invConv change
		ELSE
			x_att:= l_att;
			x_satt:= l_satt;         -- invConv change
		END IF;
		x_qoh := l_vcoh;
		x_sqoh := l_svcoh;         -- invConv change

	ELSIF (p_query_mode = G_XFR_MODE) THEN
		x_att := l_vcoh;
		x_qoh := x_att;
		x_satt := l_svcoh;       -- invConv change
		x_sqoh := x_satt;        -- invConv change
		IF (l_debug = 1) THEN
   		debug_print('Transfer mode, x_qoh=x_att=l_vcoh='||x_att||', x_satt='||x_satt,'CONSIGNED_VALIDATIONS',9);
		END IF;

	END IF;

	x_return_status:= fnd_api.g_ret_sts_success;
debug_print('Normal end of get_consigned_quantity2.');

EXCEPTION
	when others THEN
		IF (l_debug = 1) THEN
   		inv_log_util.trace('When others Exception in get_consigned_quantity','CONSIGNED_VALIDATIONS',9);
		END IF;
		x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
		RETURN;
END get_consigned_quantity;







-- This API will allow update of the existing temp table.
---This API needs to be called after a transaction is commited or
-- when moving onto the next line for the same transaction without a
--commit.

PROCEDURE update_consigned_quantities
   ( x_return_status      OUT NOCOPY varchar2
   , x_msg_count          OUT NOCOPY varchar2
   , x_msg_data           OUT NOCOPY varchar2
   , p_organization_id    IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_revision           IN VARCHAR2
   , p_lot_number         IN VARCHAR
   , p_subinventory_code  IN VARCHAR2
   , p_locator_id         IN NUMBER
   , p_grade_code         IN VARCHAR2 DEFAULT NULL    -- invConv change
   , p_primary_quantity   IN NUMBER
   , p_secondary_quantity IN NUMBER   DEFAULT NULL    -- invConv change
   , p_cost_group_id      IN NUMBER
   , p_containerized      IN NUMBER
   , p_planning_organization_id IN NUMBER
   , p_owning_organization_id IN number
   ) IS

      -- l_is_reservable_sub    BOOLEAN;   -- invConv change : not used anymore
      b_reservable              BOOLEAN;   -- invConv change
      l_reservable_type         NUMBER;
      -- l_update_quantity      NUMBER;    -- not used
      -- l_quantity_type        NUMBER;    -- not used
      -- l_containerized        NUMBER;    -- not used
      -- l_table_count          NUMBER := 0; -- not used
      -- l_att_vmi              NUMBER;    -- not used
      -- l_new_att_vmi          NUMBER;    -- not used
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;


   IF (p_inventory_item_id IS NULL) THEN
      fnd_message.set_name('INV', 'INV_INT_ITMCODE');
      fnd_msg_pub.ADD;
      x_msg_data := fnd_message.get;
      x_return_status :='E';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF ;
   IF (p_organization_id IS NULL) THEN
      fnd_message.set_name('INV', 'INV-NO ORG INFORMATION');
      fnd_msg_pub.ADD;
      x_msg_data := fnd_message.get;
      x_return_status :='E';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF ;

   -- We assume that this API is only invoked for VMI related transactions.

   -- The update quantity API should have minimum level of Subinventory
   --level.

   IF (p_subinventory_code IS NULL) THEN
      fnd_message.set_name('INV', 'INV-WRONG_LEVEL');
      fnd_msg_pub.ADD;
      x_msg_data := fnd_message.get;
      x_return_status :='E';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF ;


   -- need to find out whether the sub is reservable or not
   -- to appropriate update the vmi_temp table.
   -- This is currently not being used, but in the future we may
   -- consider reservations seperately from the qty tree

   /* invConv change begin : check_is_reservable_sub becomes obsolete.
      this is replace by check_is_reservable :
   check_is_reservable_sub
     (
      x_return_status     => x_return_status
      , p_organization_id   => p_organization_id
      , p_subinventory_code => p_subinventory_code
      , x_is_reservable_sub => l_is_reservable_sub
      );
   */
   check_is_reservable
              ( x_return_status     => x_return_status
              , p_node_level        => NULL
              , p_inventory_item_id => p_inventory_item_id
              , p_organization_id   => p_organization_id
              , p_subinventory_code => p_subinventory_code
              , p_locator_id        => p_locator_id
              , p_lot_number        => p_lot_number
              , x_is_reservable     => b_reservable);

   IF b_reservable
   THEN
     IF (l_debug = 1) THEN
       inv_log_util.trace('in update_consigned_quantities is_rsv=TRUE', 'CONSIGNED_VALIDATIONS',9);
     END IF;
   ELSE
     IF (l_debug = 1) THEN
       inv_log_util.trace('in update_consigned_quantities is_rsv=FALSE', 'CONSIGNED_VALIDATIONS',9);
     END IF;
   END IF;
   -- invConv changes end.

   IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;
   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   -- invConv change : replaced l_is_reservable_sub by b_reservable
   -- IF (l_is_reservable_sub) THEN
   IF (b_reservable) THEN
      l_reservable_type := 1;
    ELSE
      l_reservable_type := 2;
   END IF;


   -- At this point we can insert another row into the vmi
   -- temp table.

   INSERT INTO mtl_consigned_qty_temp ( organization_id,
					inventory_item_id,
					revision,
					lot_number,
					lot_expiration_date,
					subinventory_code,
					reservable_type,
					locator_id,
					grade_code,                     -- invConv change
					primary_quantity,
					secondary_quantity,             -- invConv change
					transactable_vmi,
					transactable_secondary_vmi,     -- invConv change
					date_received,
					quantity_type,
					cost_group_id,
					containerized,
					planning_organization_id,
					owning_organization_id)
     VALUES
     (p_organization_id,
      p_inventory_item_id,
      p_revision,
      p_lot_number,
      NULL,
      p_subinventory_code,
      l_reservable_type,
      p_locator_id,
      p_grade_code,               -- invConv change
      p_primary_quantity,
      p_secondary_quantity,       -- invConv change
      p_primary_quantity,
      p_secondary_quantity,       -- invConv change
      NULL,
      1,
      p_cost_group_id,
      p_containerized,
      p_planning_organization_id,
      p_owning_organization_id);

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (l_debug = 1) THEN
         inv_log_util.trace('Ex in update_vmi_quantities','CONSIGNED_VALIDATIONS',9);
      END IF;


END update_consigned_quantities;




PROCEDURE CHECK_CONSUME
  (
   P_TRANSACTION_TYPE_ID        IN     NUMBER,
   P_ORGANIZATION_ID            IN     NUMBER ,
   P_SUBINVENTORY_CODE          IN     VARCHAR2,
   P_XFER_SUBINVENTORY_CODE     IN     VARCHAR2,
   p_from_locator_id            IN     NUMBER,
   p_TO_locator_id              IN     NUMBER,
   P_INVENTORY_ITEM_ID          IN     NUMBER,
   P_OWNING_ORGANIZATION_ID     IN     NUMBER,
   P_PLANNING_ORGANIZATION_ID   IN     NUMBER,
   X_RETURN_STATUS              OUT    NOCOPY VARCHAR2,
   X_MSG_COUNT                  OUT    NOCOPY NUMBER,
   X_MSG_DATA                   OUT    NOCOPY VARCHAR2,
   X_CONSUME_CONSIGNED          OUT    NOCOPY NUMBER,
   X_CONSUME_VMI                OUT    NOCOPY NUMBER) IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_weight NUMBER;
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   SELECT decode(consume_consigned_flag,'Y',1,0), decode(consume_vmi_flag,'Y',1,0),weight
     INTO x_consume_consigned, x_consume_vmi,l_weight from
      (SELECT nvl(consume_consigned_flag,'N') consume_consigned_flag, nvl(consume_vmi_flag,'N') consume_vmi_flag,weight
     FROM MTL_CONSUMPTION_DEFINITION
     WHERE TRANSACTION_TYPE_ID  = P_TRANSACTION_TYPE_ID
     and nvl(ORGANIZATION_ID,  nvl(P_ORGANIZATION_ID,-999) )= nvl(P_ORGANIZATION_ID,-999)
     and  nvl(SUBINVENTORY_CODE, nvl(P_SUBINVENTORY_CODE,-999) )   = nvl(P_SUBINVENTORY_CODE,-999)
     and  nvl( XFER_SUBINVENTORY_CODE, nvl(P_XFER_SUBINVENTORY_CODE, -999) )
                      = nvl(P_XFER_SUBINVENTORY_CODE, -999)
     and  nvl( FROM_LOCATOR_ID, nvl(P_FROM_LOCATOR_ID, -999) ) = nvl(P_FROM_LOCATOR_ID, -999)
     and  nvl( TO_LOCATOR_ID, nvl(P_TO_LOCATOR_ID, -999) ) = nvl(P_TO_LOCATOR_ID, -999)
     and nvl( INVENTORY_ITEM_ID , nvl( P_INVENTORY_ITEM_ID ,-999)) =   nvl( P_INVENTORY_ITEM_ID , -999)
     and  nvl(OWNING_ORGANIZATION_ID, nvl(P_OWNING_ORGANIZATION_ID, -999) ) = nvl(P_OWNING_ORGANIZATION_ID, -999)
     and  nvl(PLANNING_ORGANIZATION_ID, nvl( P_PLANNING_ORGANIZATION_ID, -999))
     = nvl( P_PLANNING_ORGANIZATION_ID, -999)
     ORDER BY Nvl(weight,-1) DESC )
     where ROWNUM < 2;

   IF (l_debug = 1) THEN
      inv_log_util.trace('x_consume_consigned:'||x_consume_consigned||'x_consume_vmi :'||x_consume_vmi||'weight:'||l_weight,'CONSIGNED_VALIDATIONS',9);
   END IF;
EXCEPTION
	WHEN no_data_found THEN
		x_consume_consigned := 0;
		x_consume_vmi := 0;
		x_return_status := fnd_api.g_ret_sts_success;
	WHEN others THEN
		x_return_status := fnd_api.G_RET_STS_ERROR;
END check_consume;


--VALUE RETURNED:
--If there are pending transactions - 'Y'
--otherwise - 'N'

FUNCTION check_pending_transactions(
 P_ORGANIZATION_ID         IN     NUMBER,
 P_SUBINVENTORY_CODE       IN     VARCHAR2,
 p_locator_id              IN     VARCHAR2,
 p_item_id		   IN     NUMBER,
 p_lpn_id		   IN     NUMBER) RETURN VARCHAR2 IS

l_pending_txn_cnt NUMBER:=0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_locator_id IS NOT NULL THEN

      IF p_item_id IS NOT NULL AND p_lpn_id IS NULL THEN

	 SELECT 1 INTO l_pending_txn_cnt FROM dual
	   WHERE exists (select 1 from mtl_material_transactions_temp
			 where organization_id = P_ORGANIZATION_ID
			 and Nvl(transaction_status,1) in (1,3) --pending txn
			 AND inventory_item_id = p_item_id
			 and SUBINVENTORY_CODE = P_SUBINVENTORY_CODE
			 and LOCATOR_ID = p_locator_id);

       ELSIF p_lpn_id IS NOT NULL AND p_item_id IS NULL THEN

	 SELECT 1 INTO l_pending_txn_cnt FROM dual
	   WHERE exists (select 1 from mtl_material_transactions_temp
			 where organization_id = P_ORGANIZATION_ID
			 and Nvl(transaction_status,1) in (1,3) --pending txn
			 AND ((transfer_lpn_id = p_lpn_id)
			      OR (content_lpn_id = p_lpn_id)
			      OR (lpn_id = p_lpn_id)
			      OR (allocated_lpn_id = p_lpn_id))
			 and SUBINVENTORY_CODE = P_SUBINVENTORY_CODE
			 and LOCATOR_ID = p_locator_id);
      END IF;

    ELSE--p_locator_id IS NULL

      IF p_item_id IS NOT NULL AND p_lpn_id IS NULL THEN

	 SELECT 1 INTO l_pending_txn_cnt FROM dual
	   WHERE exists (select 1 from mtl_material_transactions_temp
			 where organization_id = P_ORGANIZATION_ID
			 and Nvl(transaction_status,1) in (1,3) --pending txn
			 AND inventory_item_id = p_item_id
			 and SUBINVENTORY_CODE = P_SUBINVENTORY_CODE);

       ELSIF p_lpn_id IS NOT NULL AND p_item_id IS NULL THEN

	 SELECT 1 INTO l_pending_txn_cnt FROM dual
	   WHERE exists (select 1 from mtl_material_transactions_temp
			 where organization_id = P_ORGANIZATION_ID
			 and Nvl(transaction_status,1) in (1,3) --pending txn
			 AND ((transfer_lpn_id = p_lpn_id)
			      OR (content_lpn_id = p_lpn_id)
			      OR (lpn_id = p_lpn_id)
			      OR (allocated_lpn_id = p_lpn_id))
			 and SUBINVENTORY_CODE = P_SUBINVENTORY_CODE);
      END IF;


   END IF;

   IF l_pending_txn_cnt = 0 THEN
      RETURN 'N'; --THERE ARE NO PENDING TXN
    ELSE
      RETURN 'Y';
   END IF;
EXCEPTION
   WHEN others THEN
      IF (l_debug = 1) THEN
         inv_log_util.trace('Other error in inv_consigned_validations.check_pending_transactions','CONSIGNED_VALIDATIONS',9);
      END IF;
      RETURN 'N';
END check_pending_transactions ;

-- This API returns the onhand quantity for planning purpose
-- When it is called for Subinventory level query, it includes VMI quantity, because replenishment within the warehouse should not distinguish VMI stocks
-- When it is called for Organization level query, it does not include VMI quantity, because relenishment for the whole warehouse should affect VMI stock
-- The quantity is calculated with onhand quantity from
-- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
-- MTL_MATERIAL_TRANSACTIONS_TEMP
-- The quantities does not include suggestions
-- Input Parameters
--  P_INCLUDE_NONNET: Whether include non-nettable subinventories
--      Values: 1 => Include non-nettable subinventories
--              2 => Only include nettabel subinventores
--  P_LEVEL: Query onhand at Organization level (1)
--                        or Subinventory level (2)
--  P_ORG_ID: Organization ID
--  P_SUBINV: Subinventory
--  P_ITEM_ID: Item ID

-- Note that this may includes pending transactions that
-- will keep the VMI attributes of inventory stock
FUNCTION GET_PLANNING_QUANTITY(
     P_INCLUDE_NONNET  NUMBER
   , P_LEVEL           NUMBER
   , P_ORG_ID          NUMBER
   , P_SUBINV          VARCHAR2
   , P_ITEM_ID         NUMBER
) RETURN NUMBER IS

     l_qoh             NUMBER := 0;
     l_sqoh            NUMBER := NULL;
     l_debug           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    IF (l_debug=1) THEN
        inv_log_util.trace('p_include_nonnet: ' || to_char(p_include_nonnet)   ||
                  ', p_level: '        || to_char(p_level)            ||
                  ', p_org_id: '       || to_char(p_org_id)           ||
                  ', p_subinv: '       || p_subinv                    ||
                  ', p_item_id: '      || to_char(p_item_id)
                  , 'GET_PLANNING_ONHAND_QTY'
                  , 9);
    END IF;

-- invConv changes begin :
-- Calling the new GET_PLANNING_QUANTITY procedure
GET_PLANNING_QUANTITY(
     P_INCLUDE_NONNET  => P_INCLUDE_NONNET
   , P_LEVEL           => P_LEVEL
   , P_ORG_ID          => P_ORG_ID
   , P_SUBINV          => P_SUBINV
   , P_ITEM_ID         => P_ITEM_ID
   , P_GRADE_CODE      => NULL                        -- invConv change
   , X_QOH             => l_qoh                       -- invConv change
   , X_SQOH            => l_sqoh);                    -- invConv change
-- invConv changes end.


    IF(l_debug=1) THEN
        inv_log_util.trace('Total quantity on-hand: ' || to_char(l_qoh), 'GET_PLANNING_ONHAND_QTY', 9);
    END IF;
    RETURN(l_qoh);


EXCEPTION
    WHEN OTHERS THEN
        IF(l_debug=1) THEN
            inv_log_util.trace(sqlcode || ', ' || sqlerrm, 'GET_PLANNING_ONHAND_QTY', 1);
        END IF;
        RETURN(0);

END GET_PLANNING_QUANTITY;

-- invConv changes begin : new procedure because GET_PLANNING_QUANTITY only returns one value.
PROCEDURE GET_PLANNING_QUANTITY(
     P_INCLUDE_NONNET  IN NUMBER
   , P_LEVEL           IN NUMBER
   , P_ORG_ID          IN NUMBER
   , P_SUBINV          IN VARCHAR2
   , P_ITEM_ID         IN NUMBER
   , P_GRADE_CODE      IN VARCHAR2                       -- invConv change
   , X_QOH             OUT NOCOPY NUMBER                         -- invConv change
   , X_SQOH            OUT NOCOPY NUMBER                         -- invConv change
) IS

     x_return_status   VARCHAR2(30);
     l_qoh              NUMBER := 0;
     l_moq_qty          NUMBER := 0;
     l_mmtt_qty_src     NUMBER := 0;
     l_mmtt_qty_dest    NUMBER := 0;
     l_sqoh             NUMBER := 0;         -- invConv change
     l_moq_sqty         NUMBER := 0;         -- invConv change
     l_mmtt_sqty_src    NUMBER := 0;         -- invConv change
     l_mmtt_sqty_dest   NUMBER := 0;         -- invConv change
     l_lot_control     NUMBER := 1;
     l_debug           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_lpn_qty         NUMBER := 0;    -- Bug 4209192
     l_default_status_id  number:= -1; -- Added for 6633612

-- invConv changes begin
l_uom_ind        VARCHAR2(4);

CURSOR get_item_info( l_org_id IN NUMBER
                    , l_item_id  IN NUMBER) IS
SELECT tracking_quantity_ind
, lot_control_code
FROM mtl_system_items_b
WHERE inventory_item_id = l_item_id
AND organization_id = l_org_id;
-- invConv changes end

BEGIN

    IF (l_debug=1) THEN
        debug_print('p_include_nonnet: ' || to_char(p_include_nonnet)   ||
                  ', p_level: '        || to_char(p_level)            ||
                  ', p_org_id: '       || to_char(p_org_id)           ||
                  ', p_subinv: '       || p_subinv                    ||
                  ', p_grade_code: '   || p_grade_code            ||
                  ', p_item_id: '      || to_char(p_item_id)
                  , 'GET_PLANNING_ONHAND_QTY'
                  , 9);
    END IF;

   -- invConv changes begin
   -- Only run this function when DUOM item.
   OPEN get_item_info( p_org_id, p_item_id);
   FETCH get_item_info
    INTO l_uom_ind
       , l_lot_control;
   CLOSE get_item_info;

    -- invConv change : this is included in the above cursor.
    -- SELECT lot_control_code
    -- into l_lot_control
    -- from  mtl_system_items_b
    -- where inventory_item_id = p_item_id
    -- and   organization_id = p_org_id;

-- Added the below for 6633612
     if inv_cache.set_org_rec(p_org_id) then
     l_default_status_id := inv_cache.org_rec.default_status_id;
        if l_default_status_id is null then
	   l_default_status_id := -1;
	end if;
     end if;

    IF (p_level = 1) THEN
    -- Organization Level

/* nsinghi MIN-MAX INVCONV start */

        IF p_include_nonnet = 1 THEN

        -- invConv change : replaced primary by secondary qty field.

            SELECT SUM(moq.primary_transaction_quantity)
                 , SUM( NVL(moq.secondary_transaction_quantity, 0))
            INTO   l_moq_qty
                 , l_moq_sqty
            FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_secondary_inventories msi
            WHERE  moq.organization_id = p_org_id
            AND    moq.inventory_item_id = p_item_id
            AND    msi.organization_id = moq.organization_id
            AND    msi.secondary_inventory_name = moq.subinventory_code
            AND    moq.organization_id = nvl(moq.planning_organization_id, moq.organization_id)
            AND    moq.lot_number = mln.lot_number(+)
            AND    moq.organization_id = mln.organization_id(+)
            AND    moq.inventory_item_id = mln.inventory_item_id(+)
            AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
            AND    nvl(moq.planning_tp_type,2) = 2;


        ELSE /* include nettable */

           SELECT SUM(mon.primary_transaction_quantity)
                , SUM( NVL(mon.secondary_transaction_quantity, 0))
           INTO   l_moq_qty
                , l_moq_sqty
           FROM   mtl_onhand_net mon, mtl_lot_numbers mln
           WHERE  mon.organization_id = p_org_id
           AND    mon.inventory_item_id = p_item_id
           AND    mon.organization_id = nvl(mon.planning_organization_id, mon.organization_id)
           AND    mon.lot_number = mln.lot_number(+)
           AND    mon.organization_id = mln.organization_id(+)
           AND    mon.inventory_item_id = mln.inventory_item_id(+)
           AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
           AND    nvl(mon.planning_tp_type,2) = 2;

        END IF;

        IF(l_debug=1) THEN
            debug_print('Total MOQ Org level: qty='||l_moq_qty||', qty2='||l_moq_sqty, 'GET_PLANNING_ONHAND_QTY', 9);
        END IF;


/* nsinghi MIN-MAX INVCONV end */

        IF (l_lot_control = 2) THEN /* Lot - Full Control*/

	   -- Added the below if for 6633612
	 IF l_default_status_id = -1 THEN

           IF(l_debug=1) THEN
             debug_print('In the lot controlled non onhand status enabled:', 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.secondary_transaction_quantity)) * Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id NOT IN (24,30)
           AND    EXISTS (SELECT 'x' FROM mtl_secondary_inventories msi
                  WHERE msi.organization_id = mmtt.organization_id
                  AND   msi.secondary_inventory_name = mmtt.subinventory_code
                  AND    msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))
           AND    mmtt.planning_organization_id IS NULL
           AND    EXISTS (SELECT 'x' FROM mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                          WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                          AND    mtlt.lot_number = mln.lot_number(+)
                          AND    p_org_id = mln.organization_id(+)
                          AND    p_item_id = mln.inventory_item_id(+)
/* nsinghi MIN-MAX INVCONV start */
                          AND    nvl(mln.availability_type,2) = decode(p_include_nonnet,1,nvl(mln.availability_type,2),1)
                          AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),SYSDATE+1))> trunc(sysdate))
           AND (mmtt.locator_id IS NULL OR
                    (mmtt.locator_id IS NOT NULL AND
                     EXISTS (SELECT 'x' FROM mtl_item_locations mil
                            WHERE mmtt.organization_id = mil.organization_id
                            AND   mmtt.locator_id = mil.inventory_location_id
                            AND   mmtt.subinventory_code = mil.subinventory_code
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1))))
/* nsinghi MIN-MAX INVCONV end */

	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Source Org level (lot Controlled): qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Abs(mmtt.primary_quantity))
                , SUM(Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3)
           AND
           (
              (mmtt.transfer_subinventory IS NULL)
              OR
              (
                 mmtt.transfer_subinventory IS NOT NULL
                 AND    EXISTS
                 (
                    SELECT 'x' FROM mtl_secondary_inventories msi
                    WHERE msi.organization_id = decode(mmtt.transaction_action_id,
                          3, mmtt.transfer_organization,mmtt.organization_id)
                       AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
                       AND   msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1)
                 )
              )
           )
           AND    mmtt.planning_organization_id IS NULL
           AND    EXISTS
           (
              SELECT 'x' FROM mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                 AND    mtlt.lot_number = mln.lot_number (+)
                 AND    decode(mmtt.transaction_action_id,
                                    3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
                 AND    p_item_id = mln.inventory_item_id(+)
/* nsinghi MIN-MAX INVCONV start */
                  AND    nvl(mln.availability_type,2) = decode(p_include_nonnet,1,nvl(mln.availability_type,2),1)
                  AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate)
           )
           AND
           (
              mmtt.transfer_to_location IS NULL OR
              (
                 mmtt.transfer_to_location IS NOT NULL AND
                 EXISTS
                 (
                    SELECT 'x' FROM mtl_item_locations mil
                    WHERE decode(mmtt.transaction_action_id,
                                     3, mmtt.transfer_organization,mmtt.organization_id) = mil.organization_id
                       AND   mmtt.transfer_to_location = mil.inventory_location_id
                       AND   mmtt.transfer_subinventory = mil.subinventory_code
                       AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)
                 )
              )
           )
/* nsinghi MIN-MAX INVCONV end */
	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Dest Org level (lot controlled): qty='||l_mmtt_qty_dest||', qty2='||l_mmtt_sqty_dest, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

         ELSE /* default material status enabled of the org */

           IF(l_debug=1) THEN
             debug_print('In the lot contolled onhand status enabled:', 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

	   SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mtlt.primary_quantity)) * Abs( mtlt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mtlt.secondary_quantity)) * Abs( NVL(mtlt.secondary_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt,mtl_transaction_lots_temp mtlt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
	   AND    mtlt.transaction_temp_id = mmtt.transaction_temp_id
           AND    mmtt.subinventory_code IS NOT NULL
	   AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id NOT IN (24,30)
           AND    EXISTS (SELECT 'x' FROM mtl_secondary_inventories msi
                  WHERE msi.organization_id = mmtt.organization_id
                  AND   msi.secondary_inventory_name = mmtt.subinventory_code
                  )
           AND    mmtt.planning_organization_id IS NULL
	   AND    EXISTS (SELECT 'x' FROM mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                          WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                          AND    mtlt.lot_number = mln.lot_number(+)
                          AND    p_org_id = mln.organization_id(+)
                          AND    p_item_id = mln.inventory_item_id(+)
                          AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),SYSDATE+1))> trunc(sysdate))
           AND (mmtt.locator_id IS NULL OR
                    (mmtt.locator_id IS NOT NULL AND
                     EXISTS (SELECT 'x' FROM mtl_item_locations mil
                            WHERE mmtt.organization_id = mil.organization_id
                            AND   mmtt.locator_id = mil.inventory_location_id
                            AND   mmtt.subinventory_code = mil.subinventory_code)))
	   AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		       WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
	                                                        mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            mtlt.lot_number,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                       AND mms.availability_type =1)
	   AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Source Org level (lot Controlled): qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;


           SELECT SUM(Abs(mtlt.primary_quantity))
                , SUM(Abs( NVL(mtlt.secondary_quantity, 0) ))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt,mtl_transaction_lots_temp mtlt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3)
   	   AND    mtlt.transaction_temp_id = mmtt.transaction_temp_id
           AND
           (
              (mmtt.transfer_subinventory IS NULL)
              OR
              (
                 mmtt.transfer_subinventory IS NOT NULL
                 AND    EXISTS
                 (
                    SELECT 'x' FROM mtl_secondary_inventories msi
                    WHERE msi.organization_id = decode(mmtt.transaction_action_id,
                          3, mmtt.transfer_organization,mmtt.organization_id)
                       AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
                 )
              )
           )
           AND    mmtt.planning_organization_id IS NULL
           AND    EXISTS
           (
              SELECT 'x' FROM mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                 AND    mtlt.lot_number = mln.lot_number (+)
                 AND    decode(mmtt.transaction_action_id,
                                    3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
                 AND    p_item_id = mln.inventory_item_id(+)
/* nsinghi MIN-MAX INVCONV start */
                  AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate)
           )
           AND
           (
              mmtt.transfer_to_location IS NULL OR
              (
                 mmtt.transfer_to_location IS NOT NULL AND
                 EXISTS
                 (
                    SELECT 'x' FROM mtl_item_locations mil
                    WHERE decode(mmtt.transaction_action_id,
                                     3, mmtt.transfer_organization,mmtt.organization_id) = mil.organization_id
                       AND   mmtt.transfer_to_location = mil.inventory_location_id
                       AND   mmtt.transfer_subinventory = mil.subinventory_code
                 )
              )
           )
           AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		       WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         mtlt.lot_number,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         mtlt.lot_number,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
                       AND mms.availability_type =1)
/* nsinghi MIN-MAX INVCONV end */
	        AND  nvl(mmtt.planning_tp_type,2) = 2;

-- Rkatoori, For sub inventory transfer type, transfer_organization is null, so we have to do testing in that aspect..
-- If there are any issues, need to add decode for that..
	  END IF; /* End of IF l_default_status_id = -1 */

        ELSE /* non lot controlled */
	 -- Added the below if for 6633612
	 IF l_default_status_id = -1 THEN

           IF(l_debug=1) THEN
             debug_print('In non lot controlled non onhand status enabled:', 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

	   SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.secondary_transaction_quantity)) * Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id NOT IN (24,30)
           AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                  WHERE msi.organization_id = mmtt.organization_id
                  AND   msi.secondary_inventory_name = mmtt.subinventory_code
                  AND    msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))
           AND    mmtt.planning_organization_id IS NULL

/* nsinghi MIN-MAX INVCONV start */
           AND (mmtt.locator_id IS NULL OR
                    (mmtt.locator_id IS NOT NULL AND
                     EXISTS (select 'x' from mtl_item_locations mil
                            WHERE mmtt.organization_id = mil.organization_id
                            AND   mmtt.locator_id = mil.inventory_location_id
                            AND   mmtt.subinventory_code = mil.subinventory_code
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1))))
/* nsinghi MIN-MAX INVCONV end */

	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
              debug_print('Total MMTT Trx qty Source Org level: qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Abs(mmtt.primary_quantity))
                , SUM(Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3)
           AND    ((mmtt.transfer_subinventory IS NULL) OR
                   (mmtt.transfer_subinventory IS NOT NULL
           AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                     WHERE msi.organization_id = decode(mmtt.transaction_action_id,
                                                  3, mmtt.transfer_organization,mmtt.organization_id)
                     AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
                     AND   msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))))
           AND    mmtt.planning_organization_id IS NULL

/* nsinghi MIN-MAX INVCONV start */
           AND (mmtt.transfer_to_location IS NULL OR
                    (mmtt.transfer_to_location IS NOT NULL AND
                     EXISTS (select 'x' from mtl_item_locations mil
                            WHERE decode(mmtt.transaction_action_id,
                                     3, mmtt.transfer_organization,mmtt.organization_id) = mil.organization_id
                            AND   mmtt.transfer_to_location = mil.inventory_location_id
                            AND   mmtt.transfer_subinventory = mil.subinventory_code
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1))))
/* nsinghi MIN-MAX INVCONV end */

	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Dest Org level: qty=' ||l_mmtt_qty_dest||', qty2='||l_mmtt_sqty_dest, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

	  ELSE	 /* default material status enabled of the org */

	   IF(l_debug=1) THEN
             debug_print('In non lot controlled onhand status enabled:', 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

	   SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                  Sign(mmtt.secondary_transaction_quantity)) * Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id NOT IN (24,30)
           AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                  WHERE msi.organization_id = mmtt.organization_id
                  AND   msi.secondary_inventory_name = mmtt.subinventory_code)
           AND    mmtt.planning_organization_id IS NULL

/* nsinghi MIN-MAX INVCONV start */
           AND (mmtt.locator_id IS NULL OR
                    (mmtt.locator_id IS NOT NULL AND
                     EXISTS (select 'x' from mtl_item_locations mil
                            WHERE mmtt.organization_id = mil.organization_id
                            AND   mmtt.locator_id = mil.inventory_location_id
                            AND   mmtt.subinventory_code = mil.subinventory_code)))
/* nsinghi MIN-MAX INVCONV end */
	   AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		       WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
	                                                        mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            mmtt.lot_number,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                       AND mms.availability_type =1)
	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
              debug_print('Total MMTT Trx qty Source Org level: qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Abs(mmtt.primary_quantity))
                , SUM(Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3)
           AND    ((mmtt.transfer_subinventory IS NULL) OR
                   (mmtt.transfer_subinventory IS NOT NULL
           AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                     WHERE msi.organization_id = decode(mmtt.transaction_action_id,
                                                  3, mmtt.transfer_organization,mmtt.organization_id)
                     AND   msi.secondary_inventory_name = mmtt.transfer_subinventory)))
           AND    mmtt.planning_organization_id IS NULL

/* nsinghi MIN-MAX INVCONV start */
           AND (mmtt.transfer_to_location IS NULL OR
                    (mmtt.transfer_to_location IS NOT NULL AND
                     EXISTS (select 'x' from mtl_item_locations mil
                            WHERE decode(mmtt.transaction_action_id,
                                     3, mmtt.transfer_organization,mmtt.organization_id) = mil.organization_id
                            AND   mmtt.transfer_to_location = mil.inventory_location_id
                            AND   mmtt.transfer_subinventory = mil.subinventory_code)))
/* nsinghi MIN-MAX INVCONV end */
           AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		       WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         mmtt.lot_number,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         mmtt.lot_number,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
                       AND mms.availability_type =1)

	        AND  nvl(mmtt.planning_tp_type,2) = 2;

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Dest Org level: qty=' ||l_mmtt_qty_dest||', qty2='||l_mmtt_sqty_dest, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

	   END IF; /* End of IF l_default_status_id = -1 */

        END IF;

    -- Bug 4209192, adding below query to account for undelivered LPNs for WIP assembly completions.
     SELECT SUM(inv_decimals_pub.get_primary_quantity( p_org_id
                                                         ,p_item_id
                                                         ,mtrl.uom_code
                                                         ,mtrl.quantity - NVL(mtrl.quantity_delivered,0))
                                                        )
        INTO  l_lpn_qty
        FROM  mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh, mtl_transaction_types mtt
        where mtrl.organization_id = p_org_id
        AND   mtrl.inventory_item_id = p_item_id
        AND   mtrl.header_id = mtrh.header_id
        AND   mtrh.move_order_type = 6 -- Putaway Move Order
        AND   mtrl.transaction_source_type_id = 5 -- Wip
        AND   mtt.transaction_action_id = 31 -- WIP Assembly Completion
        AND   mtt.transaction_type_id   = mtrl.transaction_type_id
        AND   mtrl.line_status = 7 -- Pre Approved
        AND   mtrl.lpn_id is not null;

     IF(l_debug=1) THEN
           inv_log_util.trace('Total MTRL undelivered LPN quantity for WIP completions: ' || to_char(l_lpn_qty), 'GET_PLANNING_ONHAND_QTY', 9);
     END IF;


    ELSIF (p_level = 2) THEN

/* nsinghi MIN-MAX INVCONV start */

/* If Min-Max Planning is run at sub-inventory level, value for include-nonnettable is always
assumned to be 1. Thus no need to check for nettablity when run at sub-inv level. */

/* nsinghi MIN-MAX INVCONV end */

    -- Subinventory level
       SELECT SUM(moq.primary_transaction_quantity)
            , SUM( NVL(moq.secondary_transaction_quantity, 0))
       INTO   l_moq_qty
            , l_moq_sqty
       FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln
       WHERE  moq.organization_id = p_org_id
       AND    moq.inventory_item_id = p_item_id
       AND    moq.subinventory_code = p_subinv
       AND    moq.lot_number = mln.lot_number(+)
       AND    moq.organization_id = mln.organization_id(+)
       AND    moq.inventory_item_id = mln.inventory_item_id(+)
       AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate);

       IF(l_debug=1) THEN
          debug_print('Total MOQ qty Sub Level: qty='||l_moq_qty||', qty2='||l_moq_sqty, 'GET_PLANNING_ONHAND_QTY', 9);
       END IF;

       IF (l_lot_control = 2) THEN

           SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                      Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                Sign(mmtt.secondary_transaction_quantity)) * Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.subinventory_code = p_subinv
           AND    mmtt.posting_flag = 'Y'
           AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                          WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                          AND    mtlt.lot_number = mln.lot_number (+)
                          AND    p_org_id = mln.organization_id(+)
                          AND    p_item_id = mln.inventory_item_id(+)
                          AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
           AND    mmtt.transaction_action_id NOT IN (24,30);

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Source Org Sub(lot controlled): qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Abs(mmtt.primary_quantity))
                , SUM(Abs( NVL(mmtt.secondary_transaction_quantity, 0)))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                   mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.transfer_subinventory = p_subinv
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                         WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                         AND    mtlt.lot_number = mln.lot_number (+)
                         AND    decode(mmtt.transaction_action_id,3,
                                      mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
                         AND    p_item_id = mln.inventory_item_id(+)
                         AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
           AND    mmtt.transaction_action_id  in (2,28,3);

           IF(l_debug=1) THEN
            debug_print('Total MMTT Trx qty Dest Org Sub(lot controlled): qty='||l_mmtt_qty_dest||', qty2='||l_mmtt_sqty_dest, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;
       ELSE
           SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                      Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
                , SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                Sign(mmtt.secondary_transaction_quantity)) * Abs( NVL(mmtt.secondary_transaction_quantity, 0) ))
           INTO   l_mmtt_qty_src
                , l_mmtt_sqty_src
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.organization_id = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.subinventory_code = p_subinv
           AND    mmtt.posting_flag = 'Y'
           AND    mmtt.subinventory_code IS NOT NULL
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id NOT IN (24,30);

           IF(l_debug=1) THEN
               debug_print('Total MMTT Trx qty Source Org Sub: qty='||l_mmtt_qty_src||', qty2='||l_mmtt_sqty_src, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;

           SELECT SUM(Abs(mmtt.primary_quantity))
                , SUM(Abs( NVL(mmtt.secondary_transaction_quantity, 0)))
           INTO   l_mmtt_qty_dest
                , l_mmtt_sqty_dest
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                   mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.transfer_subinventory = p_subinv
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3);

           IF(l_debug=1) THEN
             debug_print('Total MMTT Trx qty Dest Org Sub: qty='||l_mmtt_qty_dest||', qty2='||l_mmtt_sqty_dest, 'GET_PLANNING_ONHAND_QTY', 9);
           END IF;
       END IF;

    END IF;

    -- Bug 4209192, adding undelivered LPN l_lpn_qty for WIP assembly completions in total onhand.
       l_qoh :=  nvl(l_moq_qty,0) + nvl(l_mmtt_qty_src,0) + nvl(l_mmtt_qty_dest,0) + nvl(l_lpn_qty,0);

    -- invConv change
    l_sqoh :=  nvl(l_moq_sqty,0) + nvl(l_mmtt_sqty_src,0) + nvl(l_mmtt_sqty_dest,0);

    If(l_debug=1) THEN
        debug_print('Total quantity on-hand: qty='||l_qoh||', qty2='||l_sqoh, 'GET_PLANNING_ONHAND_QTY', 9);
    END IF;

   x_qoh   := l_qoh;

   -- invConv changes begin
   IF (l_uom_ind = 'P')
   THEN
      -- This is not a DUOM item.
      IF(l_debug=1) THEN
          debug_print('Total secondary quantity on-hand: NULL', 'GET_PLANNING_ONHAND_QTY', 9);
      END IF;
      x_sqoh   := NULL;
   ELSE
      x_sqoh   := l_sqoh;
   END IF;
   -- invConv changes end


EXCEPTION
    WHEN OTHERS THEN
        IF(l_debug=1) THEN
            debug_print(sqlcode || ', ' || sqlerrm, 'GET_PLANNING_ONHAND_QTY', 1);
        END IF;
        x_qoh   := NULL;
        x_sqoh  := NULL;

END GET_PLANNING_QUANTITY;

-- Bug 4247148: Added a new function to get the onhand qty
-- This API returns the onhand quantity for planning purpose based on ATPable/Nettable/All subs
-- When it is called for Organization level query, it does not include VMI quantity, because relenishment for the whole warehouse should affect VMI stock
-- The quantity is calculated with onhand quantity from
-- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
-- MTL_MATERIAL_TRANSACTIONS_TEMP
-- The quantities does not include suggestions
-- Input Parameters
--  P_ONHAND_SOURCE: Whether include atpable/non-nettable subinventories
--      Values: g_atpable_only  => Only include atpable subinventories
--              g_nettable_only => Only include nettable subinventores
--              g_all_subs => Include all subinventores
--  P_ORG_ID: Organization ID
--  P_ITEM_ID: Item ID

-- Note that this may includes pending transactions that
-- will keep the VMI attributes of inventory stock
FUNCTION get_planning_sd_quantity
  (
    P_ONHAND_SOURCE   NUMBER
    , P_ORG_ID          NUMBER
    , P_ITEM_ID         NUMBER
    ) RETURN NUMBER IS

       x_return_status   VARCHAR2(30);
       l_moq_qty         NUMBER := 0;
       l_mmtt_qty_src    NUMBER := 0;
       l_mmtt_qty_dest   NUMBER := 0;
       l_qoh             NUMBER := 0;
       l_lot_control     NUMBER := 1;
       l_lpn_qty         NUMBER := 0;  -- bug 4189319
       l_default_status_id  NUMBER := -1; /* Added for bug 7193862 */
       l_debug           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug=1) THEN
      inv_log_util.trace
	('p_onhand_source: ' || to_char(p_onhand_source)   ||
	 ', p_org_id: '       || to_char(p_org_id)           ||
	 ', p_item_id: '      || to_char(p_item_id)
	 , 'GET_PLANNING_SD_QTY'
	 , 9);
   END IF;
   SELECT lot_control_code
     into l_lot_control
     from  mtl_system_items_b
     where inventory_item_id = p_item_id
     and   organization_id = p_org_id;

     /* Added the below for bug 7193862 */

       IF inv_cache.set_org_rec(p_org_id) THEN
          l_default_status_id := inv_cache.org_rec.default_status_id;

	IF l_default_status_id IS NULL THEN
	      l_default_status_id := -1;
	END IF;
       END IF;

 IF l_default_status_id = -1 THEN

      IF(l_debug=1) THEN
	 debug_print('Inside non onhand status organization ', 'GET_PLANNING_SD_QTY', 9);
      END IF;

   IF (p_onhand_source = g_atpable_only) THEN
      SELECT SUM(moq.primary_transaction_quantity)
	INTO   l_moq_qty
	FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln
	WHERE  moq.organization_id = p_org_id
	AND    moq.inventory_item_id = p_item_id
	AND    EXISTS (select 'x' from mtl_secondary_inventories msi
		       WHERE  msi.organization_id = moq.organization_id and
		       msi.secondary_inventory_name = moq.subinventory_code
		       AND    nvl(msi.inventory_atp_code,1) = 1)
	AND    moq.organization_id = nvl(moq.planning_organization_id, moq.organization_id)
	AND    moq.lot_number = mln.lot_number(+)
	AND    moq.organization_id = mln.organization_id(+)
	AND    moq.inventory_item_id = mln.inventory_item_id(+)
	AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
	AND    nvl(moq.planning_tp_type,2) = 2;
    ELSE
      SELECT SUM(moq.primary_transaction_quantity)
	INTO   l_moq_qty
	FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln
	WHERE  moq.organization_id = p_org_id
	AND    moq.inventory_item_id = p_item_id
	AND    EXISTS
	(select 'x' from mtl_secondary_inventories msi
	 WHERE  msi.organization_id = moq.organization_id and
	 msi.secondary_inventory_name = moq.subinventory_code
	 AND    msi.availability_type = decode(p_onhand_source,g_all_subs,msi.availability_type,1))
	AND    moq.organization_id = nvl(moq.planning_organization_id, moq.organization_id)
	AND    moq.lot_number = mln.lot_number(+)
	AND    moq.organization_id = mln.organization_id(+)
	AND    moq.inventory_item_id = mln.inventory_item_id(+)
	AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
	AND    nvl(moq.planning_tp_type,2) = 2;
   END IF;

   IF(l_debug=1) THEN
      inv_log_util.trace('Total MOQ quantity Org level: ' || to_char(l_moq_qty), 'GET_PLANNING_SD_QTY', 9);
   END IF;

   IF (l_lot_control = 2) THEN

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code
			    AND   nvl(msi.inventory_atp_code,1) = 1)
	     AND    mmtt.planning_organization_id IS NULL
               AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                              AND    mtlt.lot_number = mln.lot_number(+)
                              AND    p_org_id = mln.organization_id(+)
                              AND    p_item_id = mln.inventory_item_id(+)
                              AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
               AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS
	     (select 'x' from mtl_secondary_inventories msi
	      WHERE msi.organization_id = mmtt.organization_id
	      AND   msi.secondary_inventory_name = mmtt.subinventory_code
	      AND    msi.availability_type = decode(p_onhand_source,g_all_subs,msi.availability_type,1))
	     AND    mmtt.planning_organization_id IS NULL
               AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                              AND    mtlt.lot_number = mln.lot_number(+)
                              AND    p_org_id = mln.organization_id(+)
                              AND    p_item_id = mln.inventory_item_id(+)
                              AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
               AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Source Org level (lot Controlled): ' || to_char(l_mmtt_qty_src), 'GET_PLANNING_SD_QTY', 9);
      END IF;

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS
		    (select 'x' from mtl_secondary_inventories msi
		     WHERE msi.organization_id = decode(mmtt.transaction_action_id,
							3, mmtt.transfer_organization,mmtt.organization_id)
		     AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
		     AND   nvl(msi.inventory_atp_code,1) = 1)))
		     AND    mmtt.planning_organization_id IS NULL
		       AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
				      WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
				      AND    mtlt.lot_number = mln.lot_number (+)
				      AND    decode(mmtt.transaction_action_id,
						    3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
				      AND    p_item_id = mln.inventory_item_id(+)
				      AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate))
		       AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
				   AND   msi.availability_type = decode(p_onhand_source,g_all_subs,msi.availability_type,1))))
		     AND    mmtt.planning_organization_id IS NULL
		       AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
				      WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
				      AND    mtlt.lot_number = mln.lot_number (+)
				      AND    decode(mmtt.transaction_action_id,
                                        3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
				      AND    p_item_id = mln.inventory_item_id(+)
				      AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate))
		       AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Dest Org level (lot controlled): ' || to_char(l_mmtt_qty_dest), 'GET_PLANNING_SD_QTY', 9);
      END IF;
    ELSE

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code
			    AND   nvl(msi.inventory_atp_code,1) = 1)
	     AND    mmtt.planning_organization_id IS NULL
               AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code
			    AND    msi.availability_type = decode(p_onhand_source,g_all_subs,msi.availability_type,1))
	     AND    mmtt.planning_organization_id IS NULL
               AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Source Org level: ' || to_char(l_mmtt_qty_src), 'GET_PLANNING_SD_QTY', 9);
      END IF;

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
				   AND   nvl(msi.inventory_atp_code,1) = 1)))
		     AND    mmtt.planning_organization_id IS NULL
		       AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
				   AND   msi.availability_type = decode(p_onhand_source,g_all_subs,msi.availability_type,1))))
		     AND    mmtt.planning_organization_id IS NULL
		       AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Dest Org level: ' || to_char(l_mmtt_qty_dest), 'GET_PLANNING_SD_QTY', 9);
      END IF;
    END IF;

  ELSE /* onhand material status check */


      IF(l_debug=1) THEN
	 debug_print('Inside onhand status organization ', 'GET_PLANNING_SD_QTY', 9);
      END IF;

     IF (p_onhand_source = g_atpable_only) THEN
      SELECT SUM(moq.primary_transaction_quantity)
	INTO   l_moq_qty
	FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln
	WHERE  moq.organization_id = p_org_id
	AND    moq.inventory_item_id = p_item_id
	AND    EXISTS (select 'x' from mtl_secondary_inventories msi
		       WHERE  msi.organization_id = moq.organization_id and
		       msi.secondary_inventory_name = moq.subinventory_code
		       )
	AND    moq.organization_id = nvl(moq.planning_organization_id, moq.organization_id)
	AND    moq.lot_number = mln.lot_number(+)
	AND    moq.organization_id = mln.organization_id(+)
	AND    moq.inventory_item_id = mln.inventory_item_id(+)
	AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
	AND    nvl(moq.planning_tp_type,2) = 2
	AND    ((moq.status_id IS NOT NULL
                 AND EXISTS (SELECT 1 FROM mtl_material_statuses mms
                             WHERE status_id = moq.status_id
                             and mms.inventory_atp_code = 1
                             )
		)
                OR
		moq.status_id IS NULL
	       );
    ELSE
      SELECT SUM(moq.primary_transaction_quantity)
	INTO   l_moq_qty
	FROM   mtl_onhand_quantities_detail moq, mtl_lot_numbers mln
	WHERE  moq.organization_id = p_org_id
	AND    moq.inventory_item_id = p_item_id
	AND    EXISTS
	(select 'x' from mtl_secondary_inventories msi
	 WHERE  msi.organization_id = moq.organization_id and
	 msi.secondary_inventory_name = moq.subinventory_code)
	AND    moq.organization_id = nvl(moq.planning_organization_id, moq.organization_id)
	AND    moq.lot_number = mln.lot_number(+)
	AND    moq.organization_id = mln.organization_id(+)
	AND    moq.inventory_item_id = mln.inventory_item_id(+)
	AND    trunc(nvl(mln.expiration_date, sysdate+1)) > trunc(sysdate)
	AND    nvl(moq.planning_tp_type,2) = 2
	AND    ((moq.status_id IS NOT NULL
                 AND EXISTS (SELECT 1 FROM mtl_material_statuses mms
                             WHERE status_id = moq.status_id
                             and mms.availability_type = decode(p_onhand_source,g_all_subs,mms.availability_type,1)
                             )
		)
                OR
		moq.status_id IS NULL
	       );

   END IF;

   IF(l_debug=1) THEN
      inv_log_util.trace('Total MOQ quantity Org level: ' || to_char(l_moq_qty), 'GET_PLANNING_SD_QTY', 9);
   END IF;

   IF (l_lot_control = 2) THEN

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code)
	     AND    mmtt.planning_organization_id IS NULL
               AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                              AND    mtlt.lot_number = mln.lot_number(+)
                              AND    p_org_id = mln.organization_id(+)
                              AND    p_item_id = mln.inventory_item_id(+)
                              AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
	       AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		           WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
	                                                        mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            mtlt.lot_number,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                           AND mms.inventory_atp_code =1)
               AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS
	     (select 'x' from mtl_secondary_inventories msi
	      WHERE msi.organization_id = mmtt.organization_id
	      AND   msi.secondary_inventory_name = mmtt.subinventory_code)
	     AND    mmtt.planning_organization_id IS NULL
               AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
                              WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                              AND    mtlt.lot_number = mln.lot_number(+)
                              AND    p_org_id = mln.organization_id(+)
                              AND    p_item_id = mln.inventory_item_id(+)
                              AND    trunc(nvl(nvl(mtlt.lot_expiration_date,mln.expiration_Date),sysdate+1))> trunc(sysdate))
	       AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		           WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
	                                                        mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            mtlt.lot_number,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                           AND mms.availability_type = decode(p_onhand_source,g_all_subs,mms.availability_type,1))
               AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Source Org level (lot Controlled): ' || to_char(l_mmtt_qty_src), 'GET_PLANNING_SD_QTY', 9);
      END IF;

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt , mtl_transaction_lots_temp mtlt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
   	   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS
		    (select 'x' from mtl_secondary_inventories msi
		     WHERE msi.organization_id = decode(mmtt.transaction_action_id,
							3, mmtt.transfer_organization,mmtt.organization_id)
		     AND   msi.secondary_inventory_name = mmtt.transfer_subinventory )))
		     AND    mmtt.planning_organization_id IS NULL
		     AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
				      WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
				      AND    mtlt.lot_number = mln.lot_number (+)
				      AND    decode(mmtt.transaction_action_id,
						    3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
				      AND    p_item_id = mln.inventory_item_id(+)
				      AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate))
                     AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		                 WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         mtlt.lot_number,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         mtlt.lot_number,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
				 AND mms.inventory_atp_code =1)
    	             AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
   	   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory)))
		     AND    mmtt.planning_organization_id IS NULL
		       AND    EXISTS (select 'x' from mtl_transaction_lots_temp mtlt, mtl_lot_numbers mln
				      WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
				      AND    mtlt.lot_number = mln.lot_number (+)
				      AND    decode(mmtt.transaction_action_id,
                                        3, mmtt.transfer_organization,mmtt.organization_id) = mln.organization_id(+)
				      AND    p_item_id = mln.inventory_item_id(+)
				      AND    trunc(nvl(nvl(mtlt.lot_expiration_Date,mln.expiration_date),sysdate+1))> trunc(sysdate))
                       AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		                   WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
  							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         mtlt.lot_number,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         mtlt.lot_number,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
                                   AND  mms.availability_type = decode(p_onhand_source,g_all_subs,mms.availability_type,1))
 		      AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Dest Org level (lot controlled): ' || to_char(l_mmtt_qty_dest), 'GET_PLANNING_SD_QTY', 9);
      END IF;
    ELSE

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code)
	     AND    mmtt.planning_organization_id IS NULL
  	     AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		         WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
                                                            mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            null,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                         AND mms.inventory_atp_code =1)
             AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
			   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
	   INTO   l_mmtt_qty_src
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.organization_id = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    mmtt.subinventory_code IS NOT NULL
	     AND    Nvl(mmtt.transaction_status,0) <> 2
	     AND    mmtt.transaction_action_id NOT IN (24,30)
	     AND    EXISTS (select 'x' from mtl_secondary_inventories msi
			    WHERE msi.organization_id = mmtt.organization_id
			    AND   msi.secondary_inventory_name = mmtt.subinventory_code)
	     AND    mmtt.planning_organization_id IS NULL
  	     AND    EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		            WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
	                                                    mmtt.inventory_item_id,
		                                            mmtt.subinventory_code,
				       		            mmtt.locator_id,
						            null,
          					            mmtt.lpn_id,  mmtt.transaction_action_id), mms.status_id)
                           AND mms.availability_type = decode(p_onhand_source,g_all_subs,mms.availability_type,1))
             AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Source Org level: ' || to_char(l_mmtt_qty_src), 'GET_PLANNING_SD_QTY', 9);
      END IF;

      IF (p_onhand_source = g_atpable_only) THEN

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory)))
		    AND    mmtt.planning_organization_id IS NULL
                    AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		                 WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         null,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         null,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
	                	AND mms.inventory_atp_code =1)
       		     AND  nvl(mmtt.planning_tp_type,2) = 2;

       ELSE

	 SELECT SUM(Abs(mmtt.primary_quantity))
	   INTO   l_mmtt_qty_dest
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  decode(mmtt.transaction_action_id,3,
			 mmtt.transfer_organization,mmtt.organization_id) = p_org_id
	   AND    mmtt.inventory_item_id = p_item_id
	   AND    mmtt.posting_flag = 'Y'
	   AND    Nvl(mmtt.transaction_status,0) <> 2
	   AND    mmtt.transaction_action_id  in (2,28,3)
	   AND    ((mmtt.transfer_subinventory IS NULL) OR
		   (mmtt.transfer_subinventory IS NOT NULL
		    AND    EXISTS (select 'x' from mtl_secondary_inventories msi
				   WHERE msi.organization_id = decode(mmtt.transaction_action_id,
								      3, mmtt.transfer_organization,mmtt.organization_id)
				   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory)))
		     AND    mmtt.planning_organization_id IS NULL
                     AND EXISTS (SELECT 'x' FROM mtl_material_statuses mms
		                 WHERE mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(decode(mmtt.transaction_action_id,3, mmtt.transfer_organization,mmtt.organization_id),
  							                                 mmtt.inventory_item_id,
											 mmtt.transfer_subinventory,
										         mmtt.transfer_to_location,
										         null,
          										 mmtt.lpn_id,  mmtt.transaction_action_id,
											 INV_MATERIAL_STATUS_GRP.get_default_status(mmtt.organization_id,
					                                                 mmtt.inventory_item_id,
						                                         mmtt.subinventory_code,
								       		         mmtt.locator_id,
										         null,
				          					         mmtt.lpn_id,  mmtt.transaction_action_id)), mms.status_id)
                                   AND  mms.availability_type = decode(p_onhand_source,g_all_subs,mms.availability_type,1))
		       AND  nvl(mmtt.planning_tp_type,2) = 2;

      END IF;

      IF(l_debug=1) THEN
	 inv_log_util.trace('Total MMTT Trx quantity Dest Org level: ' || to_char(l_mmtt_qty_dest), 'GET_PLANNING_SD_QTY', 9);
      END IF;

   END IF;

  END IF;
   /* End of changes for bug 7193862 */

   -- Bug 4189319, adding below query to account for undelivered LPNs for WIP assembly completions.
   SELECT SUM(inv_decimals_pub.get_primary_quantity( p_org_id
                                                            ,p_item_id
						     ,mtrl.uom_code
						     ,mtrl.quantity - NVL(mtrl.quantity_delivered,0))
	      )
     INTO  l_lpn_qty
     FROM  mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh, mtl_transaction_types mtt
     where mtrl.organization_id = p_org_id
     AND   mtrl.inventory_item_id = p_item_id
     AND   mtrl.header_id = mtrh.header_id
     AND   mtrh.move_order_type = 6 -- Putaway Move Order
     AND   mtrl.transaction_source_type_id = 5 -- Wip
     AND   mtt.transaction_action_id = 31 -- WIP Assembly Completion
     AND   mtt.transaction_type_id   = mtrl.transaction_type_id
     AND   mtrl.line_status = 7 -- Pre Approved
     AND   mtrl.lpn_id is not null;

     IF(l_debug=1) THEN
	inv_log_util.trace('Total MTRL undelivered LPN quantity for WIP completions: ' || to_char(l_lpn_qty), 'GET_PLANNING_SD_QTY', 9);
     END IF;

     -- Bug 4189319, adding undelivered LPN l_lpn_qty for WIP assembly completions in total onhand.
     l_qoh :=  nvl(l_moq_qty,0) + nvl(l_mmtt_qty_src,0) + nvl(l_mmtt_qty_dest,0) + nvl(l_lpn_qty,0);

     IF(l_debug=1) THEN
	inv_log_util.trace('Total quantity on-hand: ' || to_char(l_qoh), 'GET_PLANNING_SD_QTY', 9);
     END IF;
     RETURN(l_qoh);


EXCEPTION
   WHEN OTHERS THEN
      IF(l_debug=1) THEN
	 inv_log_util.trace(sqlcode || ', ' || sqlerrm, 'GET_PLANNING_SD_QTY', 1);
      END IF;
      RETURN(0);

END GET_PLANNING_SD_QUANTITY;

--Bug#7001958. This procedure is forbuilding cursor with LPN
 	 --as a bind variable.
 	 PROCEDURE build_lpn_sql
 	   (
 	      x_return_status       OUT NOCOPY VARCHAR2
 	    , p_mode                IN  INTEGER
 	    , p_is_lot_control      IN  BOOLEAN
 	    , p_asset_sub_only      IN  BOOLEAN
 	    , p_lot_expiration_date IN  DATE
 	    , p_onhand_source       IN  NUMBER
 	    , p_pick_release        IN  NUMBER
 	    , x_sql_statement       OUT NOCOPY long
 	    , p_is_revision_control IN  BOOLEAN
 	    ) IS


 	 l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
 	    --
 	    l_stmt                 long;
 	    l_asset_sub_where      long;
 	    l_revision_select      long;
 	    l_lot_select           long;
 	    l_lot_select2          long;
 	    l_lot_from             long;
 	    l_lot_where            long;
 	    l_lot_expiration_where long;
 	    l_lot_group            long;
 	    l_onhand_source_where  long;
 	    l_onhand_stmt          long;
 	    l_pending_txn_stmt     long;
 	    l_onhand_qty_part      VARCHAR2(3000);
 	    l_mmtt_qty_part        VARCHAR2(3000);
 	    l_mtlt_qty_part        VARCHAR2(3000);
 	    p_n NUMBER;
 	    p_v VARCHAR2(1);
 	     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 	 BEGIN


 	       l_onhand_qty_part := ' moq.primary_transaction_quantity ';
 	       l_mmtt_qty_part := ' mmtt.primary_quantity ';
 	       l_mtlt_qty_part := ' mtlt.primary_quantity ';


 	       l_onhand_stmt := '

 	      -- onhand quantities
 	      SELECT
 	           moq.organization_id                  organization_id
 	         , moq.inventory_item_id                inventory_item_id
 	         , moq.revision                         revision
 	         , moq.lot_number                       lot_number
 	         , moq.subinventory_code                subinventory_code
 	         , moq.locator_id                       locator_id
 	         , ' || l_onhand_qty_part || '          primary_quantity
 	         , nvl(moq.orig_date_received,
 	               moq.date_received)               date_received
 	         , 1                                    quantity_type
 	         , moq.cost_group_id                    cost_group_id
 	         , decode(moq.containerized_flag,
 	                  1, 1, 0)                       containerized
 	      , moq.planning_organization_id            planning_organization_id
 	      , moq.owning_organization_id              owning_organization_id
 	      , moq.lpn_id                              lpn_id
 	      FROM
 	      mtl_onhand_quantities_detail       moq
 	      WHERE moq.organization_id <> Nvl(moq.planning_organization_id,moq.organization_id)
 	        OR  moq.organization_id <> nvl(moq.owning_organization_id, moq.organization_id) ';

 	      -- common restrictions
 	    IF p_asset_sub_only THEN
 	       l_asset_sub_where := '
 	         AND Nvl(sub.asset_inventory,1) = 1';
 	     ELSE
 	       l_asset_sub_where := NULL;
 	    END IF;

 	    IF (p_onhand_source = g_atpable_only) THEN
 	         l_onhand_source_where := '
 	          AND Nvl(sub.inventory_atp_code, 1) = 1';
 	    ELSIF (p_onhand_source = g_nettable_only) THEN
 	         l_onhand_source_where := '
 	          AND Nvl(sub.availability_type, 1) = 1';
 	    ELSE --do nothing if g_all_subs
 	         l_onhand_source_where := NULL;
 	    END IF;


 	    IF p_is_lot_control THEN
 	       l_lot_select := '
 	         , x.lot_number            lot_number ';
 	       l_lot_select2 := '
 	         , lot.expiration_date     lot_expiration_date';
 	       l_lot_from := '
 	         , mtl_lot_numbers  lot';
 	       l_lot_where := '
 	         AND x.organization_id   = lot.organization_id   (+)
 	         AND x.inventory_item_id = lot.inventory_item_id (+)
 	         AND x.lot_number        = lot.lot_number        (+) ';
 	       l_lot_group := '
 	         , x.lot_number ';
 	     ELSE
 	       l_lot_select := '
 	         , NULL                    lot_number';
 	       l_lot_select2 := '
 	         , To_date(NULL)           lot_expiration_date';
 	       l_lot_from := NULL;
 	       l_lot_where := NULL;
 	       l_lot_group := NULL;
 	    END IF;


 	    IF p_is_lot_control AND p_lot_expiration_date IS NOT NULL THEN
 	       l_lot_expiration_where := '
 	         AND (lot.expiration_date IS NULL OR
 	              lot.expiration_date > :lot_expiration_date) ';
 	     ELSE
 	       l_lot_expiration_where := NULL;
 	    END IF;

 	    IF p_is_revision_control THEN
 	       l_revision_select := '
 	         , x.revision            revision';
 	    ELSE
 	       l_revision_select := '
 	         , NULL                  revision';
 	    END IF;


 	    l_stmt := '
 	      SELECT
 	           x.organization_id       organization_id
 	         , x.inventory_item_id     inventory_item_id
 	         , x.revision              revision
 	         , x.lot_number                  lot_number '
 	         || l_lot_select2 || '
 	         , x.subinventory_code     subinventory_code
 	         , sub.reservable_type     reservable_type
 	         , x.locator_id            locator_id
 	         , x.primary_quantity      primary_quantity
 	         , x.date_received         date_received
 	         , x.quantity_type         quantity_type
 	         , x.cost_group_id         cost_group_id
 	      , x.containerized    containerized
 	      , x.planning_organization_id    planning_organization_id
 	      , x.owning_organization_id      owning_organization_id
 	      FROM (
 	        SELECT
 	            x.organization_id       organization_id
 	          , x.inventory_item_id     inventory_item_id '
 	          || l_revision_select || l_lot_select || '
 	          , x.subinventory_code     subinventory_code
 	          , x.locator_id            locator_id
 	          , SUM(x.primary_quantity) primary_quantity
 	          , MIN(x.date_received)    date_received
 	          , x.quantity_type         quantity_type
 	          , x.cost_group_id         cost_group_id
 	            , x.containerized          containerized
 	             , x.planning_organization_id    planning_organization_id
 	             , x.owning_organization_id      owning_organization_id
 	         FROM ('
 	                || l_onhand_stmt      || '
 	                ) x
 	         WHERE x.organization_id    = :organization_id
 	           AND x.inventory_item_id  = :inventory_item_id
 	           AND x.lpn_id             = :lpn_id
 	         GROUP BY
 	            x.organization_id, x.inventory_item_id, x.revision '
 	           || l_lot_group || '
 	           , x.subinventory_code, x.locator_id
 	           , x.quantity_type, x.cost_group_id, x.containerized
 	           , x.planning_organization_id, x.owning_organization_id
 	        ) x
 	         , mtl_secondary_inventories sub '
 	         || l_lot_from || '
 	      WHERE
 	         x.organization_id    = sub.organization_id          (+)
 	         AND x.subinventory_code  = sub.secondary_inventory_name (+) '
 	         || l_lot_where || l_lot_expiration_where || l_asset_sub_where
 	         || l_onhand_source_where  ;

 	    x_return_status := l_return_status;
 	    x_sql_statement := l_stmt;


 	  EXCEPTION
 	    WHEN OTHERS THEN
 	       x_return_status := fnd_api.g_ret_sts_unexp_error;
 	       IF (l_debug = 1) THEN
 	          inv_log_util.trace('When Others Ex. in build_lpn_sql','CONSIGNED_VALIDATIONS',9);
 	       END IF;
 	 END build_lpn_sql;


 	 --Bug#7001958.This is overloaded with addition of lpn_id.
 	 PROCEDURE build_lpn_cursor
 	   (
 	      x_return_status           OUT NOCOPY VARCHAR2
 	    , p_organization_id         IN  NUMBER
 	    , p_inventory_item_id       IN  NUMBER
 	    , p_mode                    IN  INTEGER
 	    , p_demand_source_line_id   IN  NUMBER
 	    , p_is_lot_control          IN  BOOLEAN
 	    , p_asset_sub_only          IN  BOOLEAN
 	    , p_lot_expiration_date     IN  DATE
 	    , p_onhand_source           IN  NUMBER
 	    , p_pick_release            IN  NUMBER
 	    , p_lpn_id                  IN  NUMBER
 	    , x_cursor                  OUT NOCOPY NUMBER
 	    , p_is_revision_control     IN  BOOLEAN
 	    ) IS
 	       l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
 	       l_cursor              NUMBER;
 	       l_sql                 LONG;
 	       l_last_error_pos      NUMBER;
 	       l_temp_str            VARCHAR2(30);
 	       l_err                 VARCHAR2(240);
 	       l_pos                 NUMBER;
 	     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 	 BEGIN
 	    l_cursor := dbms_sql.open_cursor;
 	    IF (l_debug = 1) THEN
 	       inv_log_util.trace('Inside  build_lpn_cursor','CONSIGNED_VALIDATIONS',9);
 	    END IF;

 	    build_lpn_sql
 	      (l_return_status,
 	       p_mode,
 	       p_is_lot_control,
 	       p_asset_sub_only,
 	       p_lot_expiration_date,
 	       p_onhand_source,
 	       p_pick_release,
 	       l_sql,
 	       p_is_revision_control);

 	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
 	       RAISE fnd_api.g_exc_unexpected_error;
 	    END IF;

 	    BEGIN
 	       dbms_sql.parse(l_cursor,l_sql,dbms_sql.v7);
 	    EXCEPTION
 	       WHEN OTHERS THEN
 	          l_last_error_pos := dbms_sql.last_error_position();
 	          l_temp_str := Substr(l_sql, l_last_error_pos-5, 30);
 	          RAISE;
 	    END;

 	   IF (l_debug = 1) THEN
 	     inv_log_util.trace('p_lpn_id:'||p_lpn_id||',org :'||p_organization_id ||',item:'|| p_inventory_item_id,'CONSIGNED_VALIDATIONS',9);
 	   END IF;
 	    dbms_sql.bind_variable(l_cursor, ':organization_id', p_organization_id);
 	    dbms_sql.bind_variable(l_cursor, ':inventory_item_id', p_inventory_item_id);
 	    dbms_sql.bind_variable(l_cursor, ':lpn_id', p_lpn_id );

 	   IF p_is_lot_control AND p_lot_expiration_date IS NOT NULL THEN
 	       dbms_sql.bind_variable(l_cursor, ':lot_expiration_date'
 	                              , p_lot_expiration_date);
 	    END IF;
 	    x_cursor := l_cursor;
 	    x_return_status := l_return_status;

 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       x_return_status := fnd_api.g_ret_sts_unexp_error ;
 	       IF (l_debug = 1) THEN
 	          inv_log_util.trace('When Others Ex. in build_lpn_cursor','CONSIGNED_VALIDATIONS',9);
 	       END IF;

 	       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
 	         THEN
 	          fnd_msg_pub.add_exc_msg
 	            (  g_pkg_name
 	               , 'Build_Cursor'
 	               );
 	       END IF;
 	 END build_lpn_cursor;


 	 --Bug#7001958. This proc populates mtl_consigned_qty_temp for LPN.
 	 PROCEDURE populate_lpn_temp
 	   (
 	      p_organization_id          IN  NUMBER
 	    , p_inventory_item_id        IN  NUMBER
 	    , p_mode                     IN  INTEGER
 	    , p_is_lot_control           IN  BOOLEAN
 	    , p_is_revision_control      IN  BOOLEAN
 	    , p_asset_sub_only           IN  BOOLEAN
 	    , p_lot_expiration_date      IN  DATE
 	    , p_demand_source_line_id    IN  NUMBER
 	    , p_onhand_source            IN  NUMBER
 	    , p_qty_tree_att             IN  NUMBER
 	    , p_lpn_id                   IN  NUMBER
 	    , x_return_status            OUT NOCOPY VARCHAR2
 	    ) IS
 	      l_cursor NUMBER;
 	      l_return_status VARCHAR2(1);
 	      l_revision VARCHAR2(3);
 	      l_lot_number VARCHAR2(30);
 	      l_subinventory_code VARCHAR2(10);
 	      l_lot_expiration_date DATE;
 	      l_reservable_type NUMBER;
 	      l_primary_quantity NUMBER;
 	      l_date_received DATE;
 	      l_quantity_type NUMBER;
 	      l_dummy INTEGER;
 	      l_locator_id NUMBER;
 	      l_inventory_item_id NUMBER;
 	      l_organization_id NUMBER;
 	      l_cost_group_id NUMBER;
 	      l_containerized NUMBER;
 	      l_planning_organization_id NUMBER;
 	      l_owning_organization_id NUMBER;
 	      ll_transactable_vmi NUMBER;
 	      ---- Variabls to get values from cursor
 	      lL_revision VARCHAR2(3);
 	      lL_lot_number VARCHAR2(30);
 	      lL_subinventory_code VARCHAR2(10);
 	      lL_lot_expiration_date DATE;
 	      ll_reservable_type NUMBER;
 	      ll_primary_quantity NUMBER;
 	      ll_date_received DATE;
 	      ll_quantity_type NUMBER;
 	      ll_locator_id NUMBER;
 	      ll_inventory_item_id NUMBER;
 	      ll_organization_id NUMBER;
 	      ll_cost_group_id NUMBER;
 	      ll_containerized NUMBER;
 	      ll_planning_organization_id NUMBER;
 	      ll_owning_organization_id NUMBER;
 	      --------------------------------------
 	      l_count NUMBER := 0;
 	      l_temp NUMBER := 0;
 	     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 	 BEGIN

 	    build_lpn_cursor
 	      (
 	         x_return_status           => l_return_status
 	       , p_organization_id         => p_organization_id
 	       , p_inventory_item_id       => p_inventory_item_id
 	       , p_mode                    => p_mode
 	       , p_demand_source_line_id   => p_demand_source_line_id
 	       , p_is_lot_control          => p_is_lot_control
 	       , p_is_revision_control     => p_is_revision_control
 	       , p_asset_sub_only          => p_asset_sub_only
 	       , p_lot_expiration_date     => p_lot_expiration_date
 	       , p_onhand_source           => p_onhand_source
 	       , p_pick_release            => 0
 	       , p_lpn_id                  => p_lpn_id
 	       , x_cursor                  => l_cursor
 	       );

 	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
 	       l_return_status:= fnd_api.g_ret_sts_error;
 	       RAISE fnd_api.g_exc_unexpected_error;
 	    END IF;

 	    dbms_sql.define_column(l_cursor,1,l_organization_id);
 	    dbms_sql.define_column(l_cursor,2,l_inventory_item_id);
 	    dbms_sql.define_column(l_cursor,3,l_revision,3);
 	    dbms_sql.define_column(l_cursor,4,l_lot_number,30);
 	    dbms_sql.define_column(l_cursor,5,l_lot_expiration_date);
 	    dbms_sql.define_column(l_cursor,6,l_subinventory_code,10);
 	    dbms_sql.define_column(l_cursor,7,l_reservable_type);
 	    dbms_sql.define_column(l_cursor,8,l_locator_id);
 	    dbms_sql.define_column(l_cursor,9,l_primary_quantity);
 	    dbms_sql.define_column(l_cursor,10,l_date_received);
 	    dbms_sql.define_column(l_cursor,11,l_quantity_type);
 	    dbms_sql.define_column(l_cursor,12,l_cost_group_id);
 	    dbms_sql.define_column(l_cursor,13,l_containerized);
 	    dbms_sql.define_column(l_cursor,14,l_planning_organization_id);
 	    dbms_sql.define_column(l_cursor,15,l_owning_organization_id);

 	    l_dummy := dbms_sql.execute(l_cursor);

 	    LOOP

 	       IF dbms_sql.fetch_rows(l_cursor) = 0 THEN
 	          EXIT;
 	       END IF;

 	       l_count := l_count + 1;
 	       ll_transactable_vmi:= 0;

 	       dbms_sql.column_value(l_cursor,1,ll_organization_id);
 	       dbms_sql.column_value(l_cursor,2,ll_inventory_item_id);
 	       dbms_sql.column_value(l_cursor,3,ll_revision);
 	       dbms_sql.column_value(l_cursor,4,ll_lot_number);
 	       dbms_sql.column_value(l_cursor,5,ll_lot_expiration_date);
 	       dbms_sql.column_value(l_cursor,6,ll_subinventory_code);
 	       dbms_sql.column_value(l_cursor,7,ll_reservable_type);
 	       dbms_sql.column_value(l_cursor,8,ll_locator_id);
 	       dbms_sql.column_value(l_cursor,9,ll_primary_quantity);
 	       dbms_sql.column_value(l_cursor,10,ll_date_received);
 	       dbms_sql.column_value(l_cursor,11,ll_quantity_type);
 	       dbms_sql.column_value(l_cursor,12,ll_cost_group_id);
 	       dbms_sql.column_value(l_cursor,13,ll_containerized);
 	       dbms_sql.column_value(l_cursor,14,ll_planning_organization_id);
 	       dbms_sql.column_value(l_cursor,15,ll_owning_organization_id);

 	       IF (p_qty_tree_att<=ll_primary_quantity)THEN
 	          ll_transactable_vmi:=p_qty_tree_att;
 	        ELSE
 	          ll_transactable_vmi:=ll_primary_quantity;
 	       END IF;

 	       INSERT INTO mtl_consigned_qty_temp (organization_id,
 	                                            inventory_item_id,
 	                                            revision,
 	                                            lot_number,
 	                                            lot_expiration_date,
 	                                            subinventory_code,
 	                                            reservable_type,
 	                                            locator_id,
 	                                            primary_quantity,
 	                                            transactable_vmi,
 	                                            date_received,
 	                                            quantity_type,
 	                                            cost_group_id,
 	                                            containerized,
 	                                            planning_organization_id,
 	                                            owning_organization_id)
 	         VALUES
 	         (
 	           ll_organization_id,
 	           ll_inventory_item_id,
 	           ll_revision,
 	           ll_lot_number,
 	           ll_lot_expiration_date,
 	           ll_subinventory_code,
 	           ll_reservable_type,
 	           ll_locator_id,
 	           ll_primary_quantity,
 	           ll_transactable_vmi,
 	           ll_date_received,
 	           ll_quantity_type,
 	           ll_cost_group_id,
 	           ll_containerized,
 	           ll_planning_organization_id,
 	           ll_owning_organization_id);
 	    END LOOP;

 	    IF (l_debug = 1) THEN
 	          inv_log_util.trace('#of records inserted into mtl_consigned_qty_temp :'||l_count,'CONSIGNED_VALIDATIONS',9);
 	    END IF;
 	    dbms_sql.close_cursor(l_cursor);
 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       IF (l_debug = 1) THEN
 	          inv_log_util.trace('When others Ex. in populate_lpn_temp','CONSIGNED_VALIDATIONS',9);
 	       END IF;
 	 END populate_lpn_temp;


 	 --Bug#7001958. This procedure calculates the consigned qty at LPN level.
 	 PROCEDURE GET_CONSIGNED_LPN_QUANTITY(
 	         x_return_status       OUT NOCOPY VARCHAR2,
 	         x_return_msg          OUT NOCOPY VARCHAR2,
 	         p_tree_mode           IN NUMBER,
 	         p_organization_id     IN NUMBER,
 	         p_owning_org_id       IN NUMBER,
 	         p_planning_org_id     IN NUMBER,
 	         p_inventory_item_id   IN NUMBER,
 	         p_is_revision_control IN VARCHAR2,
 	         p_is_lot_control      IN VARCHAR2,
 	         p_is_serial_control   IN VARCHAR2,
 	         p_revision            IN VARCHAR2,
 	         p_lot_number          IN VARCHAR2,
 	         p_lot_expiration_date IN  DATE,
 	         p_subinventory_code   IN  VARCHAR2,
 	         p_locator_id          IN NUMBER,
 	         p_source_type_id      IN NUMBER,
 	         p_demand_source_line_id IN NUMBER,
 	         p_demand_source_header_id IN NUMBER,
 	         p_demand_source_name  IN  VARCHAR2,
 	         p_onhand_source       IN NUMBER,
 	         p_cost_group_id       IN NUMBER,
 	         p_query_mode          IN NUMBER,
 	         p_lpn_id              IN NUMBER,
 	         x_qoh                 OUT NOCOPY NUMBER,
 	         x_att                 OUT NOCOPY NUMBER) IS

 	         l_msg_count VARCHAR2(100);
 	         l_msg_data VARCHAR2(1000);
 	         l_is_revision_control BOOLEAN := FALSE;
 	         l_is_lot_control BOOLEAN := FALSE;
 	         l_is_serial_control BOOLEAN := FALSE;
 	         l_tree_mode NUMBER;
 	         l_table_count NUMBER := 0;

 	         l_qoh NUMBER;
 	         l_rqoh NUMBER;
 	         l_qr NUMBER;
 	         l_qs NUMBER;
 	         l_atr NUMBER;
 	         l_att NUMBER;
 	         l_vcoh NUMBER;
 	     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 	 BEGIN

 	         IF (l_debug = 1) THEN
 	         inv_log_util.trace('****** GET_CONSIGNED_LPN_QUANTITIES *******','CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' Org, Owning_org, planning_org='|| p_organization_id ||','
 	                 || p_owning_org_id ||','||p_planning_org_id,'CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' Item, Is Rev, Lot, Serial controlled: '||p_inventory_item_id|| ','||
 	                 p_is_revision_control ||','|| p_is_lot_control ||','|| p_is_serial_control,'CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' Rev, Lot, LotExpDate: '|| p_revision ||','||p_lot_number ||','|| p_lot_expiration_date,'CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' Sub, Loc: '||p_subinventory_code||','||p_locator_id,'CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' SourceTypeID, DemdSrcLineID, DemdSrcHdrID, DemdSrcName: ' ||
 	                 p_source_type_id ||',' ||p_demand_source_line_id || ','||
 	                 p_demand_source_header_id || ',' || p_demand_source_name,'CONSIGNED_VALIDATIONS',9);
 	         inv_log_util.trace(' OnhandSource, CstGroupID, QueryMode: '|| p_onhand_source || ','||
 	                 p_cost_group_id ||',' ||p_query_mode||',p_lpn_id :'||p_lpn_id,'CONSIGNED_VALIDATIONS',9);
 	         END IF;

 	         x_return_status:= fnd_api.g_ret_sts_success;

 	         l_tree_mode := p_tree_mode;

 	         -- validate demand source info
 	         IF p_tree_mode IN (g_transaction_mode, g_loose_only_mode) THEN
 	                 IF p_source_type_id IS NULL THEN
 	                         fnd_message.set_name('INV', 'INV-MISSING DEMAND SOURCE TYPE');
 	                         fnd_msg_pub.ADD;
 	                         x_return_msg := fnd_message.get;
 	                         RAISE fnd_api.g_exc_error;
 	                 END IF;

 	                 IF p_demand_source_header_id IS NULL THEN
 	                         IF p_demand_source_name IS NULL THEN
 	                         fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
 	                         fnd_msg_pub.ADD;
 	                         x_return_msg := fnd_message.get;
 	                         RAISE fnd_api.g_exc_error;
 	                         END IF;
 	                 END IF;

 	                 IF p_demand_source_header_id IS NULL
 	                         AND p_demand_source_line_id IS NOT NULL THEN
 	                         fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
 	                         fnd_msg_pub.ADD;
 	                         x_return_msg := fnd_message.get;
 	                         RAISE fnd_api.g_exc_error;
 	                 END IF;
 	         END IF;

 	         IF (Upper(p_is_revision_control) = 'TRUE') OR (Upper(p_is_revision_control)=fnd_api.g_true) THEN
 	                 l_is_revision_control := TRUE;
 	         END IF;

 	         IF (Upper(p_is_lot_control) = 'TRUE') OR (Upper(p_is_lot_control)=fnd_api.g_true) THEN
 	                 l_is_lot_control := TRUE;
 	         END IF;

 	         IF (Upper(p_is_serial_control) = 'TRUE') OR (Upper(p_is_serial_control) = fnd_api.g_true) THEN
 	                 l_is_serial_control := TRUE;
 	         END IF;

 	         /* Validate input parameters */
 	         IF (p_inventory_item_id IS NULL) THEN
 	                 fnd_message.set_name('INV', 'INV_INT_ITMCODE');
 	                 fnd_msg_pub.ADD;
 	                 x_return_msg := fnd_message.get;
 	                 RAISE fnd_api.g_exc_unexpected_error;
 	         END IF ;

 	         IF (p_query_mode = G_TXN_MODE) THEN
 	                 IF  (p_owning_org_id IS NULL AND p_planning_org_id IS NULL) THEN
 	                         fnd_message.set_name('INV', 'INV_OWN_PLAN_ORG_REQUIRED');
 	                         fnd_msg_pub.ADD;
 	                         x_return_msg := fnd_message.get;
 	                         RAISE fnd_api.g_exc_unexpected_error;
 	                 END IF ;
 	         ELSIF (p_query_mode = G_REG_MODE) THEN
 	                 IF  (p_owning_org_id IS NULL) THEN
 	                         fnd_message.set_name('INV', 'INV_OWN_ORG_REQUIRED');
 	                         fnd_msg_pub.ADD;
 	                         x_return_msg := fnd_message.get;
 	                         RAISE fnd_api.g_exc_unexpected_error;
 	                 END IF ;
 	         END IF;

 	         IF (l_debug = 1) THEN
 	             inv_log_util.trace('Done with validations','CONSIGNED_VALIDATIONS',9);
 	         END IF;
 	         IF (p_query_mode = G_REG_MODE) THEN

 	                 IF (l_debug = 1) THEN
 	                 inv_log_util.trace('Transfer regular to consigned','CONSIGNED_VALIDATIONS',9);
 	                 END IF;
 	                 SELECT Nvl(sum(primary_transaction_quantity),0) INTO x_att
 	                 FROM mtl_onhand_quantities_detail
 	                 WHERE owning_organization_id = organization_id
 	                 AND organization_id = p_organization_id
 	                 AND owning_organization_id <> p_owning_org_id
 	                 AND inventory_item_id = p_inventory_item_id
 	                 AND nvl(revision,'@@@') = nvl(p_revision, nvl(revision,'@@@'))
 	                 AND nvl(lot_number, '@@@') = nvl(p_lot_number, nvl(lot_number, '@@@'))
 	                 AND subinventory_code = nvl(p_subinventory_code, subinventory_code)
 	                 AND nvl(locator_id, -999) = nvl(p_locator_id, nvl(locator_id, -999))
 	                 AND nvl(lpn_id , -999)  =  nvl(p_lpn_id , -999)
 	                 AND nvl(cost_group_id, -999) = nvl(p_cost_group_id, nvl(cost_group_id, -999));

 	                 x_qoh := x_att;
 	                 IF (l_debug = 1) THEN
 	                 inv_log_util.trace('Got qty, x_qoh=x_att='||x_att,'CONSIGNED_VALIDATIONS',9);
 	                 END IF;

 	                 RETURN;
 	         END IF;

 	         --Use Exists to check existance
 	         l_table_count := 0;
 	         BEGIN
 	         SELECT 1 INTO l_table_count FROM dual
 	         WHERE EXISTS (SELECT 1 FROM mtl_consigned_qty_temp
 	                       WHERE inventory_item_id = p_inventory_item_id
 	                       AND organization_id = p_organization_id);
 	         EXCEPTION
 	         WHEN others THEN
 	                         l_table_count:=0;
 	         END;

 	         -- Clear the already existing cache only if for this item and org no table
 	         -- exists.
 	         IF (l_table_count = 0) THEN
 	                 IF (l_debug = 1) THEN
 	                     inv_log_util.trace('calling populate_lpn_temp','CONSIGNED_VALIDATIONS',9);
 	                 END IF;

 	                 populate_lpn_temp(
 	                         p_organization_id       =>  p_organization_id
 	                 ,        p_inventory_item_id     =>  p_inventory_item_id
 	                 ,        p_mode                  =>  l_tree_mode
 	                 ,        p_is_lot_control        =>  l_is_lot_control
 	                 ,        p_is_revision_control   =>  l_is_revision_control
 	                 ,        p_asset_sub_only        =>  null
 	                 ,        p_lot_expiration_date   =>  null
 	                 ,        p_demand_source_line_id =>  p_demand_source_line_id
 	                 ,        p_onhand_source                =>  p_onhand_source
 	                 ,       p_lpn_id                =>  p_lpn_id
 	                 ,        p_qty_tree_att          =>  x_att
 	                 ,        x_return_status         =>  x_return_status) ;

 	                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
 	                         IF (l_debug = 1) THEN
 	                         inv_log_util.trace('populate_lpn_temp Failed','CONSIGNED_VALIDATIONS',9);
 	                         END IF;
 	                         RAISE fnd_api.g_exc_unexpected_error;
 	                 END IF;
 	                 IF (l_debug = 1) THEN
 	                         inv_log_util.trace('after populate_lpn_temp x_att'||x_att,'CONSIGNED_VALIDATIONS',9);
 	                 END IF;

 	         END IF;

 	         IF (l_debug = 1) THEN
 	            inv_log_util.trace('Query consigned temp table for l_vcoh','CONSIGNED_VALIDATIONS',9);
 	         END IF;

 	        SELECT Nvl(sum(primary_quantity),0) INTO l_vcoh
 	         FROM mtl_consigned_qty_temp
 	         WHERE organization_id = p_organization_id
 	         AND inventory_item_id = p_inventory_item_id
 	         AND Nvl(planning_organization_id, -999) = Nvl(p_planning_org_id,Nvl(planning_organization_id, -999))
 	         AND Nvl(owning_organization_id, -999) = Nvl(p_owning_org_id,Nvl(owning_organization_id, -999))
 	         AND containerized =  1
 	         AND Nvl(revision,'@@@') = Nvl(p_revision,'@@@')
 	         AND Nvl(lot_number,'@@@')=Nvl(p_lot_number,'@@@')
 	         AND subinventory_code = p_subinventory_code
 	         AND locator_id = p_locator_id        ;

 	         IF (l_debug = 1) THEN
 	            inv_log_util.trace('Got l_vcoh='||l_vcoh,'CONSIGNED_VALIDATIONS',9);
 	         END IF;

 	         IF (p_query_mode = G_TXN_MODE) THEN

 	                 -- Call the quantity tree
 	                 -- This API calls the public qty tree api to create and query the tree
 	                 --togethor. The created tree is stored in the memory as a PL/SQL table.
 	                 IF (l_debug = 1) THEN
 	                    inv_log_util.trace('Transaction Mode, calling quantity tree','CONSIGNED_VALIDATIONS',9);
 	                 END IF;
 	                 inv_quantity_tree_pub.query_quantities(
 	                         p_api_version_number      =>   1.0
 	                 ,        p_init_msg_lst            =>   fnd_api.g_false
 	                 ,        x_return_status           =>   x_return_status
 	                 ,        x_msg_count               =>   l_msg_count
 	                 ,        x_msg_data                =>   l_msg_data
 	                 ,        p_organization_id         =>   p_organization_id
 	                 ,        p_inventory_item_id       =>   p_inventory_item_id
 	                 ,        p_tree_mode               =>   l_tree_mode
 	                 ,        p_is_revision_control     =>   l_is_revision_control
 	                 ,        p_is_lot_control          =>   l_is_lot_control
 	                 ,        p_is_serial_control       =>   l_is_serial_control
 	                 ,        p_demand_source_type_id   =>   p_source_type_id
 	                 ,        p_demand_source_line_id   =>   p_demand_source_line_id
 	                 ,        p_demand_source_header_id =>   p_demand_source_header_id
 	                 ,        p_demand_source_name      =>   p_demand_source_name
 	                 ,        p_revision                =>   p_revision
 	                 ,        p_lot_number              =>   p_lot_number
 	                 ,        p_lot_expiration_date     =>   NULL
 	                 ,        p_subinventory_code       =>   p_subinventory_code
 	                 ,        p_locator_id              =>   p_locator_id
 	                 ,       p_lpn_id                  =>   p_lpn_id
 	                 ,        p_cost_group_id           =>   p_cost_group_id
 	                 ,        x_qoh                     =>   l_qoh
 	                 ,        x_rqoh                    =>   l_rqoh
 	                 ,        x_qr                      =>   l_qr
 	                 ,        x_qs                      =>   l_qs
 	                 ,        x_att                     =>   l_att
 	                 ,        x_atr                     =>   l_atr
 	                 );

 	                 -- If the qty tree returns and error raise an exception.
 	                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
 	                         IF (l_debug = 1) THEN
 	                         inv_log_util.trace('Qty Tree Failed'||l_msg_data,'CONSIGNED_VALIDATIONS',9);
 	                         END IF;
 	                         x_return_msg:= l_msg_data;
 	                         RAISE fnd_api.g_exc_unexpected_error;
 	                 END IF;

 	                 IF (l_debug = 1) THEN
 	                   inv_log_util.trace('Called qty tree, l_qoh='||l_qoh||',l_att='||l_att,'CONSIGNED_VALIDATIONS',9);
 	                   inv_log_util.trace('Comparing with l_vcoh='||l_vcoh,'CONSIGNED_VALIDATIONS',9);
 	                 END IF;
 	                 --consign/VMI att is min of qty tree att and vmi/consigned onhand.
 	                 IF (l_vcoh <= l_att) THEN
 	                         x_att:= l_vcoh;
 	                 ELSE
 	                         x_att:= l_att;
 	                 END IF;
 	                 x_qoh := l_vcoh;

 	         ELSIF (p_query_mode = G_XFR_MODE) THEN
 	                 x_att := l_vcoh;
 	                 x_qoh := x_att;
 	                 IF (l_debug = 1) THEN
 	                 inv_log_util.trace('Transfer mode, x_qoh=x_att=l_vcoh='||x_att,'CONSIGNED_VALIDATIONS',9);
 	                 END IF;

 	         END IF;

 	         x_return_status:= fnd_api.g_ret_sts_success;

 	 EXCEPTION
 	   when others THEN
 	                 IF (l_debug = 1) THEN
 	                 inv_log_util.trace('When others Exception in GET_CONSIGNED_LPN_QUANTITY','CONSIGNED_VALIDATIONS',9);
 	                 END IF;
 	                 x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
 	                 RETURN;
 	 END GET_CONSIGNED_LPN_QUANTITY;


END INV_CONSIGNED_VALIDATIONS;

/

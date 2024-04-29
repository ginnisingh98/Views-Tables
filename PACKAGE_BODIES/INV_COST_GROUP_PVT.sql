--------------------------------------------------------
--  DDL for Package Body INV_COST_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COST_GROUP_PVT" AS
/* $Header: INVVDCGB.pls 120.3 2007/08/19 00:31:22 mchemban ship $ */


is_debug BOOLEAN := TRUE;

--Bug 5214608 ( FP of 2879206 ) constant identifying the current transaction getting processed
g_current_txn_temp_id NUMBER := NULL;

INV_COMINGLE_ERROR     Exception;


--  Start of Comments
--  API name    Assign_Cost_Group
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  End of Comments

PROCEDURE print_debug(p_message IN VARCHAR2) IS
   --Bug 3559334 fix. Need not call the fnd_api again here since
   --this procedure is invoked only if the Inv:Debug Trace is enabled
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (is_debug = TRUE) THEN
      --IF (l_debug = 1) THEN
         inv_log_util.trace(p_message, 'INV_COST_GROUP_PVT', 9);
      --END IF;
    END IF;
END;

-- added the average_cost_var_account as a parameter

PROCEDURE get_default_cost_group(x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data  OUT NOCOPY VARCHAR2,
				 x_cost_group_id OUT NOCOPY NUMBER,
				 p_material_account IN NUMBER,
				 p_material_overhead_account IN NUMBER,
				 p_resource_account IN NUMBER,
				 p_overhead_account IN NUMBER,
				 p_outside_processing_account IN NUMBER,
				 p_expense_account IN NUMBER,
				 p_encumbrance_account IN NUMBER,
				 p_average_cost_var_account IN NUMBER DEFAULT NULL,
				 p_organization_id IN NUMBER,
                                 p_cost_group IN VARCHAR2 DEFAULT NULL)
  IS
     l_cost_group_id_tbl cstpcgut.cost_group_tbl;
     l_count number;
     l_found boolean := FALSE;
     l_cost_group  varchar2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   cstpcgut.get_cost_group
     (
      x_return_status     		=> x_return_status
      , x_msg_count         		=> x_msg_count
      , x_msg_data          		=> x_msg_data
      , x_cost_group_id_tbl 		=> l_cost_group_id_tbl
      , x_count             		=> l_count
      , p_material_account         	=> p_material_account
      , p_material_overhead_account  	=> p_material_overhead_account
      , p_resource_account           	=> p_resource_account
      , p_overhead_account           	=> p_overhead_account
      , p_outside_processing_account 	=> p_outside_processing_account
      , p_expense_account            	=> p_expense_account
      , p_encumbrance_account        	=> p_encumbrance_account
      , p_average_cost_var_account      => p_average_cost_var_account
      , p_organization_id		=> p_organization_id
      , p_cost_group_type_id          => 3);

   if (l_count > 0) then
      for i in 1..l_count
      loop
	select cost_group
	into l_cost_group
	from cst_cost_groups
	where cost_group_id = l_cost_group_id_tbl(i);

	if l_cost_group = p_cost_group then
      		x_cost_group_id := l_cost_group_id_tbl(i);
		l_found := TRUE;
		exit;
	end if;
      end loop;
    end if;

    if NOT(l_found) then
      cstpcgut.create_cost_group
	(
	 x_return_status     		=> x_return_status
	 , x_msg_count         		=> x_msg_count
	 , x_msg_data          		=> x_msg_data
	 , x_cost_group_id 		=> x_cost_group_id
	 , p_cost_group             	=> p_cost_group
	 , p_material_account         	=> p_material_account
	 , p_material_overhead_account  => p_material_overhead_account
	 , p_resource_account           => p_resource_account
	 , p_overhead_account           => p_overhead_account
	 , p_outside_processing_account => p_outside_processing_account
	 , p_expense_account            => p_expense_account
	 , p_encumbrance_account        => p_encumbrance_account
	 , p_organization_id		=> p_organization_id
	 , p_average_cost_var_account   => p_average_cost_var_account
	 , p_cost_group_type_id         => 3);
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
				 p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
				 p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME, 'INV_COST_GROUP_PUB');
      END IF;

END get_default_cost_group;

--Bug#6343400.Added the following procedure
PROCEDURE Calculate_Transfer_Cost
(
    p_mmtt_temp_id                      IN  NUMBER
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
) IS
    l_interorg_xfer_code   mtl_interorg_parameters.matl_interorg_transfer_code%type;
    l_interorg_charge_prct mtl_interorg_parameters.interorg_trnsfr_charge_percent%type;
    l_transfer_cost        NUMBER ;
    l_item_cost            NUMBER := 0 ;
    l_item_id              NUMBER ;
    l_org_id               NUMBER ;
    l_xfer_org_id          NUMBER ;
    l_cg_id                NUMBER ;
    l_pri_qty              NUMBER ;
    l_trx_action_id        NUMBER ;
    l_primary_cost_method  NUMBER := 1 ;
    l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SAVEPOINT Calculate_Transfer_Cost_SP;
   x_return_status := fnd_api.g_ret_sts_success;

   IF ( l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost : Entered with temp id:'  ||p_mmtt_temp_id );
   END IF;

   SELECT inventory_item_id, organization_id,transfer_organization,cost_group_id, nvl(transfer_cost,0),
          abs(primary_quantity), transaction_action_id
   INTO l_item_id,l_org_id,l_xfer_org_id, l_cg_id,l_transfer_cost,l_pri_qty, l_trx_action_id
   FROM Mtl_Material_Transactions_Temp
   WHERE transaction_temp_id = p_mmtt_temp_id;

   IF ( l_debug = 1) THEN
       print_debug('item id:'||l_item_id||'org id:'|| l_org_id ||', xfer org id :'|| l_xfer_org_id ||',CG:'||l_cg_id||',xfrcost:'||l_transfer_cost);
   END IF;

   SELECT NVL(primary_cost_method,1) INTO l_primary_cost_method
   FROM MTL_PARAMETERS
   WHERE organization_id = l_org_id ;

   IF (l_primary_cost_method = 1 ) THEN
     IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost :This org uses primary cost method..so exiting'  );
     END IF;
     RETURN ;
   END IF;

   IF (l_trx_action_id not in ( INV_GLOBALS.G_ACTION_ORGXFR , INV_GLOBALS.G_ACTION_INTRANSITSHIPMENT  ) ) THEN
     IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost :This is not an org xfer, so no need of calculating transfer cost..exiting'  );
     END IF;
     RETURN ;
   END IF;

   SELECT NVL(matl_interorg_transfer_code,1)  , interorg_trnsfr_charge_percent
     INTO l_interorg_xfer_code  , l_interorg_charge_prct
   FROM mtl_interorg_parameters
   WHERE from_organization_id = l_org_id
   AND to_organization_id = l_xfer_org_id ;

   IF (l_interorg_xfer_code NOT IN (4, 3 )  ) THEN
     IF (l_debug = 1) THEN
       print_debug('Calculate_Transfer_Cost :matl_interorg_transfer_code ='|| l_interorg_xfer_code||' , so exiting' );
     END IF;
     RETURN ;
   END IF;

   IF (l_interorg_xfer_code = 3 ) THEN
       l_interorg_charge_prct  := l_transfer_cost * 100 / l_pri_qty ;
   END IF;

  IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost : mtl_interorg_transfer_code : ' ||l_interorg_xfer_code|| ',interorg_trnsfr_charge_percent:'||l_interorg_charge_prct );
  END IF;

   SELECT NVL(ccicv.item_cost, 0) INTO l_item_cost
      FROM cst_cg_item_costs_view ccicv
   WHERE ccicv.inventory_item_id= l_item_id
   AND   ccicv.organization_id= l_org_id
   AND  ccicv.cost_group_id = l_cg_id ;

   l_transfer_cost :=  l_interorg_charge_prct / 100 * l_item_cost *  l_pri_qty ;

  IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost : item_cost :'|| l_item_cost  || ',transfer_cost :'||l_transfer_cost);
  END IF;

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
  SET TRANSFER_COST = l_transfer_cost
  WHERE TRANSACTION_TEMP_ID = p_mmtt_temp_id;

  IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost : Updated MMTT with transfer cost ..Exiting API.');
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  ROLLBACK TO Calculate_Transfer_Cost_SP;
  IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost :No Data found !!!! ');
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
	                      p_data => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK TO Calculate_Transfer_Cost_SP;
  IF (l_debug = 1) THEN
      print_debug('Calculate_Transfer_Cost :Others Exception !!!! ');
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
	                      p_data => x_msg_data);
END Calculate_Transfer_Cost;


PROCEDURE Assign_Cost_Group
(
    p_api_version_number	    IN  NUMBER
,   p_init_msg_list	 	    IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit			    IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
,   p_transaction_header_id         IN  NUMBER
)
IS
   l_transaction_header_id NUMBER := p_transaction_header_id;
   l_organization_id NUMBER;
   l_cost_Group_id NUMBER;
   l_transfer_cost_Group_id NUMBER;
   l_process_txn           VARCHAR2(1) := 'Y';
   l_fob_point             mtl_interorg_parameters.fob_point%TYPE;
   l_to_project_id NUMBER := NULL;
   l_comingling_occurs    VARCHAR2(1) := 'N';
   cursor trx_cursor is
         select mmtt.*
         from mtl_material_transactions_temp mmtt
	   WHERE
	   transaction_header_id = p_transaction_header_id
	   AND PROCESS_FLAG = 'Y'
	   AND NVL(TRANSACTION_STATUS,1) <> 2 ;  /* 2STEP */
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SAVEPOINT assign_cost_group_hdr;

   g_failure_txn_temp_id := NULL; -- Bug 5214602

   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug('In assign cost group pass with header id ' || l_transaction_header_id);
   END IF;

   --    l_process_txn := 'Y';   -- Process the transaction otherwise skip it, since it already has
   -- Cost group populated.
   --  Moved the assignment inside the for loop for bug 2233573


   -- Update all the rows which have null transaction_temp_id for this
   -- transaction_header_id
   UPDATE mtl_material_transactions_temp
     SET transaction_temp_id = mtl_material_transactions_s.NEXTVAL
     WHERE transaction_header_id = p_transaction_header_id
     AND transaction_temp_id IS NULL;



     FOR rec_trx_cursor IN trx_cursor
       LOOP
          g_current_txn_temp_id := rec_trx_cursor.transaction_temp_id; --5214602 : FP of Bug 2879206
	  inv_cost_group_pvt.assign_cost_group
	    (x_return_status   => x_return_status,
	     x_msg_data        => x_msg_data,
	     x_msg_count       => x_msg_count,
	     p_mmtt_rec        => rec_trx_cursor,
	     p_fob_point       => null,
	     p_line_id         => rec_trx_cursor.transaction_temp_id,
	     p_organization_id => rec_trx_cursor.organization_id,
	     p_input_type      => INV_COST_GROUP_PUB.G_INPUT_MMTT,
	     x_cost_group_id   => l_cost_group_id,
	     x_transfer_cost_group_id => l_transfer_cost_Group_id);

	  if( x_return_status = INV_COST_GROUP_PVT.G_COMINGLE_ERROR ) then
	     RAISE inv_comingle_error;
	   elsif( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	     raise FND_API.G_EXC_UNEXPECTED_ERROR;
	   elsif( x_return_status = FND_API.G_RET_STS_ERROR ) then
	     raise FND_API.G_EXC_ERROR;
	  end if;
       END LOOP;

EXCEPTION
   WHEN inv_comingle_error THEN
      ROLLBACK TO assign_cost_group_hdr;
      x_return_status := FND_API.G_RET_STS_ERROR;
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO assign_cost_group_hdr;
        x_return_status := FND_API.G_RET_STS_ERROR;
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO assign_cost_group_hdr;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO assign_cost_group_hdr;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME, 'INV_COST_GROUP_PUB');
      end if;
END;

PROCEDURE Assign_Cost_Group
  (
   x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                     OUT NOCOPY NUMBER
   ,x_msg_data                      OUT NOCOPY VARCHAR2
   ,p_organization_id               IN  NUMBER
   ,p_mmtt_rec                      IN  mtl_material_transactions_temp%ROWTYPE  DEFAULT NULL
   ,p_fob_point                     IN  mtl_interorg_parameters.fob_point%TYPE  DEFAULT NULL
   ,p_line_id		            IN  NUMBER
   ,p_input_type		    IN  VARCHAR2
   ,x_cost_group_id                 OUT NOCOPY NUMBER
   ,x_transfer_cost_group_id        OUT NOCOPY NUMBER
) IS
   l_organization_id NUMBER := p_organization_id;
   l_transfer_organization_id NUMBER;
   l_transaction_action_id NUMBER;
   l_line_id NUMBER := p_line_id;
   l_wms_org_flag boolean;
   l_transfer_wms_org_flag boolean;
   l_cost_Group_id NUMBER;
   l_org_cost_Group_id NUMBER;
   l_tfr_org_cost_Group_id NUMBER;
   l_transfer_cost_group_id NUMBER;
   l_subinventory_code VARCHAR2(10);
   l_transfer_subinventory VARCHAR2(10);
   l_primary_cost_method NUMBER;
   l_tfr_primary_cost_method NUMBER;
   l_from_project_id NUMBER := null;
   l_to_project_id   NUMBER := null;
   l_from_locator_id NUMBER := null;
   l_to_locator_id   NUMBER := null;

   l_process_txn VARCHAR2(1) := 'Y';
   l_comingling_occurs VARCHAR2(1) := 'N';
   l_fob_point   mtl_interorg_parameters.fob_point%TYPE := p_mmtt_rec.fob_point;
   --assign mmttvalue to variable FOB_POINT Changes
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   --Bug 5214602 : FP of 2879206
   g_current_txn_temp_id := p_mmtt_rec.transaction_temp_id;
   /****************Code added*********************/

   SAVEPOINT assign_cost_group;

   IF (p_input_type = G_INPUT_MMTT) THEN

      l_process_txn := 'Y';

      IF (l_debug = 1) THEN
         print_debug('transaction_header_id : ' || p_mmtt_rec.transaction_header_id);
         print_debug('transaction_temp_id : ' || p_mmtt_rec.transaction_Temp_id);
         print_debug('organization_id : ' || p_mmtt_rec.organization_id);
         print_debug('transaction_action_id : ' || p_mmtt_rec.transaction_action_id);
      END IF;

      -- If the MMTT line is for a LPN transaction then (in which case
      -- item_id = -1) we do not process those transactions. In some of
      -- the transactions the item_id <> -1
      -- even though they are LPN triggered transactions. We have to
      -- account FOR them specifically
      IF (p_mmtt_rec.inventory_item_id = -1) THEN

	 x_return_status := fnd_api.g_ret_sts_success;
	 RETURN;

      -- Bug: 4959753: The WIP phantom items are not transactable items
      -- but are still inserted into MMTT. No onhand or MMT is created for these items
      -- and Hence no cost group processing is required for these items.
      -- if the source type is 5 (WIP) and wip_supply_type is 6, we do not
      -- process such record. Took this condition from INVTXGGB.pls
       ELSIF ((p_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID = 5) AND
	      (nvl(p_mmtt_rec.OPERATION_SEQ_NUM,1) < 0) AND (nvl(p_mmtt_rec.WIP_SUPPLY_TYPE,0) = 6)) THEN
	 IF (l_debug = 1) THEN
	    print_debug ('Phantom item, Hence skipping processing');
	 END IF;
	 x_return_status := fnd_api.g_ret_sts_success;
	 RETURN;

	 -- If the transaction is a logical receipt or a logical delivery
	 -- adjustment, we will not go through the cost group logic. We will
	 -- get the org's default cost group for both the organization
	 -- and the transafer organization.
	 -- IDS: lot serial support
       ELSIF (p_mmtt_rec.transaction_source_type_id =
	      INV_Globals.G_SOURCETYPE_PURCHASEORDER AND
	      (p_mmtt_rec.transaction_action_id =
	       INV_Globals.G_ACTION_LOGICALRECEIPT OR
	       p_mmtt_rec.transaction_action_id =
	       INV_Globals.g_action_logicaldeladj
	       )
	      ) THEN

	 print_debug('Inside get cost group for logical transactions');
	 print_debug('Transaction Action' || p_mmtt_rec.transaction_action_id );

	 SELECT default_cost_group_id
	   INTO l_org_cost_group_id
	   FROM mtl_parameters
	   WHERE organization_id = p_mmtt_rec.organization_id;

	 print_debug('After selecting the default cost group');
	 print_debug('Cost Group ID' || l_org_cost_group_id);

	 IF (p_mmtt_rec.transfer_organization IS NOT NULL) THEN
	    print_debug('Transfer Org. is being populated');
	    SELECT default_cost_group_id
	      INTO l_tfr_org_cost_group_id
	      FROM mtl_parameters
	      WHERE organization_id = p_mmtt_rec.transfer_organization;
	 END IF;

	 print_debug('After selecting the default transfer cost group');
	   print_debug('Transfer cost group ID' || l_tfr_org_cost_group_id);
	 print_debug('Return Status before update' ||x_return_status );

	 UPDATE mtl_material_transactions_temp
	   SET cost_group_id = l_org_cost_group_id,
	   transfer_cost_group_id = l_tfr_org_cost_group_id
	   WHERE transaction_temp_id = p_mmtt_rec.transaction_temp_id;

	 print_debug('Return Status after update' ||x_return_status );

	 x_return_status := fnd_api.g_ret_sts_success;
	 RETURN;

       ELSE
	 IF p_mmtt_rec.transaction_action_id IN (INV_Globals.G_Action_IntransitShipment,
						 INV_Globals.G_Action_IntransitReceipt ) THEN


	    IF l_fob_point IS NULL THEN

            BEGIN
	       SELECT fob_point
		 INTO l_fob_point
		 FROM mtl_interorg_parameters
		 WHERE from_organization_id =
		 Decode(p_mmtt_rec.transaction_action_id,
			inv_globals.g_action_intransitreceipt,
			p_mmtt_rec.transfer_organization,
			p_mmtt_rec.organization_id)
		 AND to_organization_id =
		 Decode(p_mmtt_rec.transaction_action_id,
			inv_globals.g_action_intransitreceipt,
			p_mmtt_rec.organization_id,
			p_mmtt_rec.transfer_organization);

	       IF l_fob_point IS NULL THEN
		  IF (l_debug = 1) THEN
		     print_debug ('l_fob_point is null:INV_FOB_NOT_DEFINED');
		  END IF;
		  FND_MESSAGE.SET_NAME('INV', 'INV_FOB_NOT_DEFINED');
		  fnd_message.set_token('ENTITY1',p_mmtt_rec.organization_id );
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    EXCEPTION
	       WHEN NO_DATA_FOUND  THEN
		  IF (l_debug = 1) THEN
		     print_debug ('no_data_found:INV_FOB_NOT_DEFINED');
		  END IF;
		  FND_MESSAGE.SET_NAME('INV', 'INV_FOB_NOT_DEFINED');
		  fnd_message.set_token('ENTITY1',p_mmtt_rec.organization_id );
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	    END;
	       END IF;-- l_fob_point is null
	 END IF;--actions

	IF (l_debug = 1) THEN
   	print_debug('l_fob_point is ' || l_fob_point);
	END IF;
	 -- l_fob_point = 1 (shipment) = 2 (Receipt)

	 IF (l_debug = 1) THEN
   	 print_debug('p_mmtt_rec.cost_group_id : ' || p_mmtt_rec.cost_group_id);
   	 print_debug('p_mmtt_rec.transfer_cost_group_id : ' || p_mmtt_rec.transfer_cost_group_id);
	 END IF;


	 IF l_process_txn = 'N' THEN
	    NULL;

	 ELSIF p_mmtt_rec.cost_group_id IS NOT NULL THEN

	    IF p_mmtt_rec.transaction_action_id IN  (INV_Globals.G_Action_Subxfr,INV_Globals.g_action_planxfr,
						     INV_Globals.G_Action_Stgxfr,
						     INV_Globals.g_action_orgxfr,
						     INV_Globals.g_action_ownxfr)  THEN
	       IF  (p_mmtt_rec.cost_group_id IS NULL OR
		    p_mmtt_rec.transfer_cost_group_id IS NULL) THEN

		  l_process_txn := 'Y';

		  --Bug 2392914 fix
		  --Most probably we don't need the below code
		  ELSIF p_mmtt_rec.transaction_action_id = INV_Globals.g_action_stgxfr then

		  IF (p_mmtt_rec.transfer_to_location IS NOT NULL AND
		      p_mmtt_rec.transfer_to_location > 0 AND
		      p_mmtt_rec.transfer_organization IS NOT NULL AND
		      p_mmtt_rec.transfer_organization > 0) THEN

		    BEGIN
		      SELECT project_id INTO l_to_project_id
		        FROM mtl_item_locations
		        WHERE inventory_location_id = p_mmtt_rec.transfer_to_location
		        AND organization_id = p_mmtt_rec.transfer_organization;
		    EXCEPTION
		       WHEN  OTHERS THEN
			  IF (l_debug = 1) THEN
   			  print_debug('exception in getting to project: ' || Sqlerrm);
			  END IF;
			  RAISE fnd_api.g_exc_unexpected_error;
		    END;
		   ELSE
			l_to_project_id := NULL;
		  END IF;

		  IF l_to_project_id IS NOT NULL THEN
		     IF (l_debug = 1) THEN
   		     print_debug('to project is not null');
   		     print_debug('setting l_process_txn to N');
		     END IF;
		     --p_mmtt_rec.transfer_cost_group_id := NULL;
		     --Commenting out the above line because we don't
		     --process this RECORD anymore l_process_txn := 'N'
		     --after updating the transfer_cost_group_id as null
		     l_process_txn := 'N';

		     BEGIN
		      UPDATE mtl_material_transactions_temp
		        SET transfer_cost_group_id = NULL
		        WHERE
			transaction_temp_id = p_mmtt_rec.transaction_temp_id;
		     EXCEPTION
			WHEN OTHERS THEN
			   IF (l_debug = 1) THEN
   			   print_debug('exception updating the xfr cost group-null');
   			   print_debug('Error :'||Sqlerrm);
			   END IF;
		     END;

		     IF (l_debug = 1) THEN
   		     print_debug('Setting transfer cost group as null');
		     END IF;
		  END IF;

		  IF (l_debug = 1) THEN
   		  print_debug('setting l_process_txn to N');
		  END IF;
		  l_process_txn := 'N';

		  --Bug 2392914 fix

		ELSE
		     l_process_txn := 'N';

	       END IF;

	     ELSIF p_mmtt_rec.transaction_action_id = INV_Globals.G_Action_IntransitShipment  THEN
	       IF l_fob_point = 1  THEN
		  IF  (p_mmtt_rec.cost_group_id IS NULL OR
		       p_mmtt_rec.transfer_cost_group_id IS NULL) THEN
		     l_process_txn := 'Y';
		   ELSE
		    l_process_txn := 'N';
		  END IF;
		ELSE
		  IF  (p_mmtt_rec.cost_group_id IS NULL ) THEN
		     l_process_txn := 'Y';
		   ELSE
		     l_process_txn := 'N';
		  END IF;
	       END IF;
	     ELSIF p_mmtt_rec.transaction_action_id = INV_Globals.G_Action_IntransitReceipt THEN
	       IF l_fob_point = 1  THEN
		  IF  (p_mmtt_rec.cost_group_id IS NULL OR
		       p_mmtt_rec.transfer_cost_group_id IS NULL) THEN
		     l_process_txn := 'Y';
		   ELSE
		     l_process_txn := 'N';
		  END IF;
		ELSE
		  IF  (p_mmtt_rec.cost_group_id IS NULL ) THEN
		     l_process_txn := 'Y';
		   ELSE
		     l_process_txn := 'N';
		  END IF;
	       END IF;
	     ELSE  -- for all other transaction actions, transfer_cost_group_id will always be null
	       l_process_txn := 'N';
	    END IF;
	 END IF;
	 IF (l_debug = 1) THEN
   	 print_debug('l_process_txn.: ' || l_process_txn);
	 END IF;

	 IF  l_process_txn = 'N' THEN
	    inv_comingling_utils.comingle_check
	      (x_return_status                 => x_return_status
	       , x_msg_count                   => x_msg_count
	       , x_msg_data                    => x_msg_data
	       , x_comingling_occurs           => l_comingling_occurs
	       , p_mmtt_rec                    => p_mmtt_rec);

	    IF x_return_status <> fnd_api.g_ret_sts_success THEN
	       RAISE fnd_api.g_exc_unexpected_error;
	    ELSIF l_comingling_occurs = 'Y' THEN
	       IF (l_debug = 1) THEN
   	       print_debug('assign_cost_group comingling occurs : ' );
	       END IF;
	       RAISE inv_comingle_error;
	    END IF;
	 END IF;
      END IF;

      l_line_id :=  p_mmtt_rec.transaction_temp_id;
      l_organization_id := p_mmtt_rec.organization_id;

   END IF; --  IF (p_input_type = G_INPUT_MMTT) THEN
   /****************Code added*********************/

   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('in inv_cost_group_pub.assign_cost_group');
      print_debug('l_line_id : ' || l_line_id);
      print_debug('l_organization_id : ' || l_organization_id);
      print_debug('p_input_type : ' || p_input_type);
      print_debug('l_fob_point : ' || l_fob_point);
   END IF;

   l_transfer_organization_id:= NULL;
   l_transaction_action_id   := NULL;
   l_wms_org_flag            := FALSE;
   l_transfer_wms_org_flag   := FALSE;
   l_cost_Group_id           := NULL;
   l_org_cost_Group_id       := NULL;
   l_tfr_org_cost_Group_id   := NULL;
   l_transfer_cost_group_id  := NULL;
   l_subinventory_code       := NULL;
   l_transfer_subinventory   := NULL;
   l_primary_cost_method     := NULL;
   l_tfr_primary_cost_method := NULL;

   l_wms_org_flag := wms_install.check_install
			(x_return_status   => x_return_status,
			 x_msg_count       => x_msg_count,
			 x_msg_data        => x_msg_data,
                         p_organization_id => l_organization_id);
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (p_input_type = G_INPUT_MMTT) THEN
       l_cost_group_id               :=  p_mmtt_rec.cost_group_id;
       l_transfer_cost_group_id      :=  p_mmtt_rec.transfer_cost_Group_id;
       l_subinventory_code           :=  p_mmtt_rec.subinventory_code;
       l_transfer_subinventory       :=  p_mmtt_rec.transfer_subinventory;
       l_transaction_action_id       :=  p_mmtt_rec.transaction_action_id;
       l_transfer_organization_id    :=  p_mmtt_rec.transfer_organization;
       IF p_mmtt_rec.transaction_action_id IN (INV_Globals.G_Action_Subxfr,INV_Globals.G_Action_Planxfr,
                                    INV_Globals.g_action_stgxfr,INV_Globals.g_action_ownxfr) THEN
          l_transfer_organization_id    :=  p_mmtt_rec.organization_id;
       END IF;

        IF(p_mmtt_rec.locator_id IS NOT NULL) then
          BEGIN
	     SELECT project_id INTO l_from_project_id
	       FROM mtl_item_locations
	       WHERE inventory_location_id = p_mmtt_rec.locator_id
	       AND organization_id = p_mmtt_rec.organization_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
   		print_debug('exception in getting from project: ' || Sqlerrm);
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	  END;
	END IF;

	IF(p_mmtt_rec.transfer_to_location IS NOT NULL) then

         BEGIN
	    SELECT project_id INTO l_to_project_id
	      FROM mtl_item_locations
	      WHERE inventory_location_id = p_mmtt_rec.transfer_to_location
	      AND organization_id = l_transfer_organization_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       print_debug('exception in getting to project: ' || Sqlerrm);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	 END;
       END IF;

       IF (l_debug = 1) THEN
          print_debug('l_from_project_id : ' || l_from_project_id);
          print_debug('l_to_project_id  : ' || l_to_project_id);
       END IF;


    ELSIF (p_input_type = G_INPUT_MOLINE) THEN
       SELECT from_cost_group_id,
	      to_cost_group_id,
	      from_subinventory_code,
	      to_subinventory_code,
	      from_locator_id,
	      to_locator_id
       INTO l_cost_Group_id,
            l_transfer_cost_group_id,
            l_subinventory_code,
	    l_transfer_subinventory,
	    l_from_locator_id,
	    l_to_locator_id
       FROM mtl_txn_request_lines
       WHERE line_id = l_line_id;
    END IF;

    IF l_transfer_organization_id IS NOT NULL THEN
      l_transfer_wms_org_flag := wms_install.check_install
			(x_return_status   => x_return_status,
			 x_msg_count       => x_msg_count,
			 x_msg_data        => x_msg_data,
                         p_organization_id => l_transfer_organization_id);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      SELECT default_cost_group_id,
	     primary_cost_method
	INTO l_tfr_org_cost_group_id,
           l_tfr_primary_cost_method
	FROM mtl_parameters
	WHERE organization_id = l_transfer_organization_id;
       IF( l_from_locator_id IS NOT NULL) then
        BEGIN
	  SELECT project_id INTO l_from_project_id
	    FROM mtl_item_locations
	    WHERE inventory_location_id = l_from_locator_id AND
	    organization_id = l_organization_id;
	EXCEPTION
	   WHEN OTHERS THEN
	      IF (l_debug = 1) THEN
   	      print_debug('exception in getting from project: ' || Sqlerrm);
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
	END;
       END IF;

      IF( l_to_locator_id IS NOT NULL) then
        IF (l_debug = 1) THEN
           print_debug(' l_transfer_organization_id '||l_transfer_organization_id);
        END IF;
        BEGIN
	   SELECT project_id INTO l_to_project_id
	     FROM mtl_item_locations
	     WHERE inventory_location_id = l_to_locator_id AND
	           organization_id = l_transfer_organization_id;
	EXCEPTION
	   WHEN OTHERS THEN
	      IF (l_debug = 1) THEN
   	      print_debug('exception in getting to project: ' || Sqlerrm);
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
	END;
      END IF;

       IF (l_debug = 1) THEN
          print_debug('l_from_project_id : ' || l_from_project_id);
          print_debug('l_to_project_id  : ' || l_to_project_id);
       END IF;

    END IF;
    IF (l_debug = 1) THEN
       print_debug('l_tfr_org_cost_group_id: ' || l_tfr_org_cost_group_id);
       print_debug('l_tfr_primary_cost_method: ' || l_tfr_primary_cost_method);
       print_debug('l_transfer_organization_id: ' || l_transfer_organization_id);
    END IF;

    IF (l_debug = 1) THEN
       print_debug('l_cost_group_id : ' || l_cost_group_id);
       print_debug('l_subinventory_code : ' || l_subinventory_code);
       print_debug('l_transfer_cost_group_id : ' || l_transfer_cost_group_id);
       print_debug('l_transfer_subinventory : ' || l_transfer_subinventory);
    END IF;

    SELECT default_cost_group_id,
           primary_cost_method
    INTO l_org_cost_group_id,
         l_primary_cost_method
    FROM mtl_parameters
    WHERE organization_id = l_organization_id;

    IF (l_debug = 1) THEN
       print_debug('l_org_cost_group_id: ' || l_org_cost_group_id);
       print_debug('l_primary_cost_method: ' || l_primary_cost_method);
       print_debug('l_organization_id: ' || l_organization_id);
    END IF;

    IF l_transaction_action_id = inv_globals.g_action_intransitreceipt AND
      p_mmtt_rec.transfer_cost_group_id IS NULL THEN
       SELECT cost_group_id
	 INTO l_transfer_cost_group_id
	 FROM rcv_shipment_lines rsl,
	      rcv_transactions rt
	 WHERE rsl.shipment_line_id = rt.shipment_line_id
	 AND rt.transaction_id = p_mmtt_rec.source_line_id;
       IF (l_debug = 1) THEN
          print_debug('Intransit transfer cost group ID: ' || l_transfer_cost_group_id);
       END IF;
    END IF; -- action = intransit receipt

    IF NOT l_wms_org_flag THEN
       IF (l_debug = 1) THEN
          print_debug('l_wms_flag is false ');
       END IF;

       -- derive cost group from the default cost group in the subinventory
       IF (l_debug = 1) THEN
          print_debug('l_transfer_cost_group_id: ' || l_transfer_cost_group_id);
       END IF;
       if (l_cost_Group_id is null and l_subinventory_code is not null) then
	  IF (l_debug = 1) THEN
   	  print_debug('cost group is null , get the default from sub or org');
	  END IF;
            IF l_primary_cost_method = 1
            THEN                                  -- costing method is standard)
               BEGIN
                   SELECT default_cost_group_id
                   INTO l_cost_group_id
                   FROM mtl_secondary_inventories
                   WHERE secondary_inventory_name = l_subinventory_code
                   AND organization_id = l_organization_id
                   AND default_cost_group_id IS NOT NULL;
                   IF (l_debug = 1) THEN
                      print_debug('l_cost_group of subinventory ' || l_subinventory_code ||
                               ' is ' || l_cost_group_id);
                   END IF;
               EXCEPTION
               WHEN no_data_found THEN
                       l_cost_group_id := l_org_cost_group_id;
                       IF (l_debug = 1) THEN
                          print_debug('default cost group of org ' || l_organization_id ||
                               ' is ' || l_cost_group_id);
                       END IF;
               END;
            ELSE                      -- costing method is not standard)
               l_cost_group_id := l_org_cost_group_id;
               IF (l_debug = 1) THEN
                  print_debug('non-standard org: default cost group of org ' || l_organization_id ||
                               ' is ' || l_cost_group_id);
		END IF;
            END IF;
        ELSE
	   IF (l_debug = 1) THEN
   	   print_debug('l_cost_group_id is not null in mmtt');
	   END IF;
        END IF;
        IF (l_debug = 1) THEN
           print_debug('l_cost_group_id : ' || l_cost_group_id);
           print_debug('l_transfer_cost_group_id : ' || l_transfer_cost_group_id);
        END IF;
    END IF; -- end of not l_wms_org_flag


    /* l_transfer_wms_org_flag will be false even when transfer org is null as in sub/stg tfr*/
    IF (NOT l_wms_org_flag) AND (NOT l_transfer_wms_org_flag) THEN
        IF (l_debug = 1) THEN
           print_debug('transfer org is not wms enabled  ');
        END IF;

	-- check if transaction is intransit issue
	IF l_transaction_Action_id = inv_globals.g_action_intransitshipment THEN
	   IF l_fob_point = 1 THEN -- shipment
	      -- We do not care about the costing method of the org
	      l_transfer_cost_group_id := l_tfr_org_cost_group_id;
	      IF (l_debug = 1) THEN
   	          print_debug('default cost group of org ' ||  p_mmtt_rec.transfer_organization ||
			  ' : ' || l_transfer_cost_group_id);
	      END IF;
	    ELSIF l_fob_point = 2 THEN -- receipt
	      l_transfer_cost_group_id := l_cost_group_id;
	   END IF;
	END IF;

	IF (l_transfer_cost_Group_id IS NULL AND l_transfer_subinventory IS
	    NOT NULL) AND l_transaction_action_id <> inv_globals.g_action_intransitreceipt THEN
            IF (l_debug = 1) THEN
               print_debug('transfer cost group is null , get the default from sub or org');
            END IF;

            IF l_tfr_primary_cost_method = 1
            THEN                               -- costing method is standard)
                BEGIN
                  select default_cost_group_id
                  into l_transfer_cost_group_id
                  from mtl_secondary_inventories
                  where secondary_inventory_name = l_transfer_subinventory
                  and organization_id = l_transfer_organization_id
                  and default_cost_group_id is not null;
                  IF (l_debug = 1) THEN
                     print_debug('l_transfer_cost_group of  sub  ' || l_transfer_subinventory ||
                              ' is ' || l_transfer_cost_group_id);
                  END IF;
                EXCEPTION
                WHEN no_data_found THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      l_transfer_cost_group_id := l_tfr_org_cost_group_id;
                      IF (l_debug = 1) THEN
                         print_debug('default cost group of org ' || p_mmtt_rec.transfer_organization ||
                                  ' is ' || l_transfer_cost_group_id);
                      END IF;
                END;
            ELSE                               -- costing method is not standard)
               l_transfer_cost_group_id := l_tfr_org_cost_group_id;
               IF (l_debug = 1) THEN
                  print_debug('default cost group of org ' ||  p_mmtt_rec.transfer_organization ||
                                  ' : ' || l_transfer_cost_group_id);
                  END IF;
            END IF;
	 ELSIF l_transfer_cost_Group_id is null AND
  	       l_transfer_subinventory is null AND
	       l_transaction_Action_id = INV_Globals.G_Action_Orgxfr THEN
	       /* case where trfr sub is null for a direct org transfer */
               l_transfer_cost_group_id := l_tfr_org_cost_group_id;
        else
          IF (l_debug = 1) THEN
             print_debug('l_transfer_cost_group is not null or tfr cost group is not to be populated ');
          END IF;
        end if;

        IF (l_debug = 1) THEN
           print_debug('l_cost_group_id : ' || l_cost_group_id);
           print_debug('l_transfer_cost_group_id : ' || l_transfer_cost_group_id);
        END IF;
        IF p_input_type = g_input_mmtt then
            IF (l_debug = 1) THEN
               print_debug('update the mmtt with cost group');
            END IF;
            update mtl_material_transactions_temp
            set cost_Group_id = l_cost_group_id,
                transfer_cost_group_id = Nvl(transfer_cost_group_id, l_transfer_cost_group_id)
            where transaction_temp_id = l_line_id;
	 ELSIF  p_input_type = G_INPUT_MOLINE THEN
             IF (l_debug = 1) THEN
                print_debug('update the mtl_txn_request_lines with cost group ' ||
                          l_cost_group_id || ' and ' || l_transfer_cost_group_id);
             END IF;
             update mtl_txn_request_lines
             set from_cost_Group_id = l_cost_group_id,
	         to_cost_group_id = Nvl(to_cost_group_id, l_transfer_cost_group_id)
             where line_id = l_line_id;
        end if;
   END IF; -- end of not l_transfer_wms_org

   -- Inventory to WMS transfers and WMS to INV transfers
   IF (NOT l_wms_org_flag) AND l_transfer_wms_org_flag THEN
      IF (l_debug = 1) THEN
         print_debug('INV to WMS transfer');
      END IF;
      -- check if transaction is intransit issue
      IF l_transaction_action_id IN (inv_globals.g_action_intransitshipment,
				     inv_globals.g_action_orgxfr)
	THEN
	 IF (l_fob_point = 1 AND l_transaction_action_id =
	     inv_globals.g_action_intransitshipment)  -- shipment
	   OR (l_transaction_action_id = inv_globals.g_action_orgxfr) THEN

	    -- updating the transfer cost group to null for direct org transfers,
	    -- if the destination is wms org and dest loc is proj enabled
	    IF( l_to_project_id IS NOT NULL AND
		l_transaction_action_id  = inv_globals.g_action_orgxfr) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Org transfer to a WMS org ..Dest is project locator');
	       END IF;
	       IF p_input_type = G_INPUT_MMTT THEN
		  IF (l_debug = 1) THEN
   		  print_debug('update the mmtt with transfer cost group null');
		  END IF;
		  UPDATE mtl_material_transactions_temp
		    SET transfer_cost_group_id = NULL
		    WHERE transaction_temp_id = l_line_id;
		ELSIF p_input_type = G_INPUT_MOLINE THEN
		  IF (l_debug = 1) THEN
   		  print_debug('update the mtl_txn_request_lines with to cost group null');
		  END IF;
		  UPDATE mtl_txn_request_lines
		    SET to_cost_group_id = null
		    WHERE line_id = l_line_id;
	       END IF;
	     ELSE
	       -- change till here
	       IF (l_debug = 1) THEN
   	       print_debug('Calling the Rules Engine: ');
	       END IF;
	       wms_costgroupengine_pvt.assign_cost_group
		 (p_api_version => 1.0,
		  p_init_msg_list => fnd_api.g_false,
		  p_commit => fnd_api.g_false,
		  p_validation_level => fnd_api.g_valid_level_full,
		  x_return_status => x_return_status,
		  x_msg_count => x_msg_count,
		  x_msg_data => x_msg_data,
		  p_line_id  => l_line_id,
		  p_input_type => wms_costgroupengine_pvt.g_input_mmtt);
	       IF (x_return_status = fnd_api.g_ret_sts_error) THEN
		  IF (l_debug = 1) THEN
   		  print_debug('return error from wms_costgroupengine_pvt');
		  END IF;
		  RAISE fnd_api.g_exc_error;
		ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		  IF (l_debug = 1) THEN
   		  print_debug('return unexpected error from wms_costgroupengine_pvt');
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       IF p_input_type = G_INPUT_MMTT THEN
		  IF (l_debug = 1) THEN
   		  print_debug('update the mmtt with cost group');
		  END IF;
		  UPDATE mtl_material_transactions_temp
		    SET cost_group_id = l_cost_group_id
		    WHERE transaction_temp_id = l_line_id;
		ELSIF p_input_type = G_INPUT_MOLINE THEN
		  IF (l_debug = 1) THEN
   		      print_debug('update the mtl_txn_request_lines with cost group ' ||
			     l_cost_group_id || ' and ' || l_transfer_cost_group_id);
		  END IF;
		  UPDATE mtl_txn_request_lines
		    SET from_cost_group_id = l_cost_group_id
		    WHERE line_id = l_line_id;
	       END IF;
	    END IF;-- for org transfer ,dest locator is project


	  ELSIF (l_fob_point = 2 AND l_transaction_action_id =
		 inv_globals.g_action_intransitshipment) THEN -- receipt
	    IF (l_debug = 1) THEN
   	    print_debug('Setting transfer cost group = cost group');
	    END IF;
	    l_transfer_cost_group_id := l_cost_group_id;
	    IF p_input_type = G_INPUT_MMTT THEN
	       IF (l_debug = 1) THEN
   	       print_debug('update the mmtt with cost group');
	       END IF;
	       UPDATE mtl_material_transactions_temp
		 SET cost_Group_id = l_cost_group_id,
		 transfer_cost_group_id = l_transfer_cost_group_id
		 WHERE transaction_temp_id = l_line_id;
	    END IF;
	 END IF;
      END IF;



      IF l_transaction_action_id IN (inv_globals.g_action_intransitreceipt,
				     inv_globals.g_action_orgxfr)
	THEN
	 --Newly added code for PJM-WMS
	 IF( l_to_project_id IS NOT NULL AND
	     l_transaction_action_id  = inv_globals.g_action_orgxfr) THEN
	    IF (l_debug = 1) THEN
   	    print_debug('Org transfer to a WMS org ..Dest is project locator');
	    END IF;
	    --We don't want to fill the transfer cost group with l_transfer_cost_group_id
	    --if the previous code has stamped it as null for the case of
	    --org transfer to wms + dest locator is project enabled
	    IF p_input_type = G_INPUT_MMTT THEN
	       IF (l_debug = 1) THEN
   	       print_debug('update the mmtt with cost group '|| l_cost_group_id);
	       END IF;
	       UPDATE mtl_material_transactions_temp
		 SET cost_group_id = l_cost_group_id
		 --transfer_cost_group_id = Nvl(transfer_cost_group_id, l_transfer_cost_group_id)
		 WHERE transaction_temp_id = l_line_id;
	     ELSIF p_input_type = G_INPUT_MOLINE THEN
	       IF (l_debug = 1) THEN
   	       print_debug('update the mtl_txn_request_lines with cost group ' || l_cost_group_id);
	       END IF;
	       UPDATE mtl_txn_request_lines
		 SET from_cost_group_id = l_cost_group_id
		 --to_cost_group_id = Nvl(to_cost_group_id, l_transfer_cost_group_id)
		 WHERE line_id = l_line_id;
	    END IF;
	  ELSE
	     --Newly added code for PJM-WMS
	    IF (l_debug = 1) THEN
   	    print_debug('Receipt side of the interorg transfer...');
	    END IF;
	    IF p_input_type = G_INPUT_MMTT THEN
	       IF (l_debug = 1) THEN
   	       print_debug('update the mmtt with cost group');
	       END IF;
	       UPDATE mtl_material_transactions_temp
		 SET cost_group_id = l_cost_group_id,
		 transfer_cost_group_id = Nvl(transfer_cost_group_id, l_transfer_cost_group_id)
		 WHERE transaction_temp_id = l_line_id;
	     ELSIF p_input_type = G_INPUT_MOLINE THEN
	       IF (l_debug = 1) THEN
   	           print_debug('update the mtl_txn_request_lines with cost group ' ||
			   l_cost_group_id || ' and ' || l_transfer_cost_group_id);
	       END IF;
	       UPDATE mtl_txn_request_lines
		 SET from_cost_group_id = l_cost_group_id,
		 to_cost_group_id = Nvl(to_cost_group_id, l_transfer_cost_group_id)
		 WHERE line_id = l_line_id;
	    END IF;
	 END IF; --Newly added code for PJM-WMS
      END IF;


   END IF; -- INV --> WMS, WMS --> INV

   IF (l_debug = 1) THEN
      print_debug('l_org_cost_group_id: ' || l_org_cost_group_id);
      print_debug('l_primary_cost_method: ' || l_primary_cost_method);
      print_debug('l_organization_id: ' || l_organization_id);
      print_debug('l_tfr_org_cost_group_id: ' || l_tfr_org_cost_group_id);
      print_debug('l_tfr_primary_cost_method: ' || l_tfr_primary_cost_method);
      print_debug('l_transfer_organization_id: ' || l_transfer_organization_id);
   END IF;

   IF (l_debug = 1) THEN
      print_debug('l_cost_group_id : ' || l_cost_group_id);
      print_debug('l_subinventory_code : ' || l_subinventory_code);
      print_debug('l_transfer_cost_group_id : ' || l_transfer_cost_group_id);
      print_debug('l_transfer_subinventory : ' || l_transfer_subinventory);
      print_debug('l_transfer_organization : ' || l_transfer_organization_id);
      print_debug('l_transaction_action_id : ' || l_transaction_action_id);
   END IF;

   IF (l_wms_org_flag) THEN
      IF (l_debug = 1) THEN
         print_Debug('l_wms_org_flag is true');
      END IF;

      /*** WMS-PJM changes *********/
      IF(l_from_project_id IS NOT NULL AND
	 l_to_project_id IS NOT NULL AND
	 l_transaction_action_id IN (inv_globals.g_action_subxfr,
				     inv_globals.g_action_stgxfr)) then

	 IF (l_debug = 1) THEN
   	 print_debug('Source and destination locators are not project enabled');
   	 print_debug('Stamping null cost groups for source and destination');
	 END IF;

	 IF p_input_type = G_INPUT_MMTT THEN
	    IF (l_debug = 1) THEN
   	    print_debug('update the mmtt with from cost group of null');
   	    print_debug('update the mmtt with tfr cost group of null');
	    END IF;
	    UPDATE mtl_material_transactions_temp
	      SET cost_group_id = NULL,
	          transfer_cost_group_id = null
	      WHERE transaction_temp_id = l_line_id;

	  ELSIF p_input_type = G_INPUT_MOLINE THEN
	    IF (l_debug = 1) THEN
   	    print_debug('update the mtl_txn_request_lines with from cost group null');
   	    print_debug('update the mtl_txn_request_lines with tfr cost group null');
	    END IF;

	    UPDATE mtl_txn_request_lines
	      SET to_cost_group_id = NULL,
	          from_cost_group_id = null
	      WHERE line_id = l_line_id;
	 END IF;

       ELSIF(l_from_project_id IS NOT NULL AND
	     l_to_project_id IS NULL AND
	     l_transaction_action_id IN (inv_globals.g_action_subxfr,
					 inv_globals.g_action_stgxfr)) then

	 IF (l_debug = 1) THEN
   	 print_debug('Source locator is project enabled');
   	 print_debug('Dest locator is not project enabled');
	 END IF;

	 IF (p_input_type = g_input_moline) THEN -- Input type is MMTT
	    IF (l_debug = 1) THEN
   	    print_debug('before calling wms_costgroupengine_pvt for mtl_txn_request_lines record');
	    END IF;
	    wms_costgroupengine_pvt.assign_cost_group
	      (p_api_version => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit => fnd_api.g_false,
	       p_validation_level => fnd_api.g_valid_level_full,
	       x_return_status => x_return_status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       p_line_id  => l_line_id,
	       p_input_type => wms_costgroupengine_pvt.g_input_mtrl);
            IF (x_return_status = fnd_api.g_ret_sts_error) then
	       IF (l_debug = 1) THEN
   	       print_debug('return error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	     elsif( x_return_status = fnd_api.g_ret_sts_unexp_error) then
	       IF (l_debug = 1) THEN
   	       print_debug('return unexpected error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
            end if;

	    IF (l_debug = 1) THEN
   	    print_debug('Setting from cost group as null ');
	    END IF;

	    UPDATE mtl_txn_request_lines
	      SET
	      from_cost_group_id = null
	      WHERE line_id = l_line_id;

	  ELSE  -- Input type is MMTT
	    IF (l_debug = 1) THEN
   	    print_debug('Calling Rules Engine : ');
	    END IF;
	    wms_costgroupengine_pvt.assign_cost_group
	      (p_api_version => 1.0,
	       p_init_msg_list => FND_API.G_FALSE,
	       p_commit => FND_API.G_FALSE,
	       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	       x_return_status => x_return_Status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       p_line_id  => l_line_id,
	       p_input_type => WMS_CostGroupEngine_PVT.G_INPUT_MMTT);

	    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('return error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	     ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('return unexpected error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    IF (l_debug = 1) THEN
   	    print_debug('Setting from cost group as null ');
	    END IF;

	    UPDATE mtl_material_transactions_temp
	      SET cost_group_id = NULL
	      WHERE transaction_temp_id = l_line_id;
	 end if; -- input type

       ELSIF(l_from_project_id IS NOT NULL AND
	     l_transaction_action_id IN (inv_globals.g_action_receipt,
					 inv_globals.G_Action_IntransitReceipt,
					 inv_globals.g_action_AssyComplete )) then

	 IF (l_debug = 1) THEN
   	 print_debug('Receipt or assy completion transaction');
   	 print_debug('rec locator is project enabled');
	 END IF;

	 IF (p_input_type = g_input_moline) THEN -- Input type is MMTT

	    IF (l_debug = 1) THEN
   	    print_debug('Setting cost group as null ');
	    END IF;

	    UPDATE mtl_txn_request_lines
	      SET
	      from_cost_group_id = null
	      WHERE line_id = l_line_id;

	  ELSE  -- Input type is MMTT

	    IF (l_debug = 1) THEN
   	    print_debug('Setting cost group as null ');
	    END IF;

	    UPDATE mtl_material_transactions_temp
	      SET cost_group_id = NULL
	      WHERE transaction_temp_id = l_line_id;
	 end if; -- input type

	 -- updating the transfer cost group to null for direct org transfers,
	 -- if the destination is wms org an dest loc is proj enabled
	 -- Added by cjandhya
       ELSIF l_transfer_wms_org_flag
	 AND l_transaction_action_id = inv_globals.g_action_orgxfr
	 AND l_to_project_id IS NOT NULL THEN

	 IF (l_debug = 1) THEN
   	 print_debug('Org transfer WMS to WMS org ..Dest is project locator');
	 END IF;
	 IF p_input_type = G_INPUT_MMTT THEN
	    IF (l_debug = 1) THEN
   	    print_debug('update the mmtt with transfer cost group null');
	    END IF;
	    UPDATE mtl_material_transactions_temp
	      SET transfer_cost_group_id = NULL
	      WHERE transaction_temp_id = l_line_id;
	  ELSIF p_input_type = G_INPUT_MOLINE THEN
	    IF (l_debug = 1) THEN
   	    print_debug('update the mtl_txn_request_lines with transfer cost group null');
	    END IF;
	    UPDATE mtl_txn_request_lines
	      SET to_cost_group_id = null
	      WHERE line_id = l_line_id;
	 END IF;
	 -- Added by cjandhya

       ELSE
	 -- Direct org transfer WMS --> INV
	 IF (NOT l_transfer_wms_org_flag)
	   AND l_transaction_action_id = inv_globals.g_action_orgxfr THEN
	    IF l_tfr_primary_cost_method = 1
	      THEN                                  -- costing method is standard)
               BEGIN
		  SELECT default_cost_group_id
		    INTO l_transfer_cost_group_id
		    FROM mtl_secondary_inventories
		    WHERE secondary_inventory_name = l_transfer_subinventory
		    AND organization_id = l_transfer_organization_id
		    AND default_cost_group_id IS NOT NULL;
		    IF (l_debug = 1) THEN
   		    print_debug('l_cost_group of subinventory ' || l_transfer_subinventory ||
				' is ' || l_transfer_subinventory);
		    END IF;
               EXCEPTION
		  WHEN no_data_found THEN
		     l_transfer_cost_group_id := l_tfr_org_cost_group_id;
		     IF (l_debug = 1) THEN
   		     print_debug('default cost group of org ' || l_transfer_organization_id ||
				 ' is ' || l_transfer_cost_group_id);
		    END IF;
               END;
	     ELSE                      -- costing method is not standard)
		     l_transfer_cost_group_id := l_tfr_org_cost_group_id;
		     IF (l_debug = 1) THEN
   		     print_debug('non-standard org: default cost group of org ' || l_transfer_organization_id ||
				 ' is ' || l_transfer_cost_group_id);
		     END IF;
	    END IF;

	    IF p_input_type = G_INPUT_MMTT THEN
	       IF (l_debug = 1) THEN
   	       print_debug('update the mmtt with cost group');
	       END IF;
	       UPDATE mtl_material_transactions_temp
		 SET transfer_cost_group_id = l_transfer_cost_group_id
		 WHERE transaction_temp_id = l_line_id;
	     ELSIF p_input_type = G_INPUT_MOLINE THEN
	       IF (l_debug = 1) THEN
   	          print_debug('update the mtl_txn_request_lines with cost group ' ||
			   l_cost_group_id || ' and ' || l_transfer_cost_group_id);
	       END IF;
	       UPDATE mtl_txn_request_lines
		 SET to_cost_group_id = l_transfer_cost_group_id
		 WHERE line_id = l_line_id;
	    END IF;
	 END IF;

	 IF (p_input_type = G_INPUT_MMTT) THEN
	    IF (l_debug = 1) THEN
   	    print_debug('input type is mmtt record');
	    END IF;


	    -- All Issue transactions or transfer transactions or transactions
	    -- whose status is yet to be determined.
	    IF inv_globals.is_issue_xfr_transaction(l_transaction_action_id)
	      OR (l_transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
					      inv_globals.g_type_physical_count_adj,
					      inv_globals.g_action_deliveryadj))
	      THEN
	       IF l_cost_group_id IS NULL OR l_transfer_cost_group_id IS NULL
		 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('calling inv_cost_group_update.cost_group_update');
		  END IF;
		  inv_cost_group_update.cost_group_update
		    (p_transaction_rec         => p_mmtt_rec,
		     p_fob_point               => l_fob_point,
		     p_transfer_wms_org        => l_transfer_wms_org_flag,
		     p_tfr_primary_cost_method => l_tfr_primary_cost_method,
		     p_tfr_org_cost_group_id   => l_tfr_org_cost_group_id,
		     p_from_project_id         => l_from_project_id,
		     p_to_project_id           => l_to_project_id,
		     x_return_status           => x_return_status,
		     x_msg_count               => x_msg_count,
		     x_msg_data                => x_msg_data);
		   if( x_return_status = INV_COST_GROUP_PVT.G_COMINGLE_ERROR ) then
		      RAISE inv_comingle_error;
		    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) then
		     RAISE FND_API.G_EXC_ERROR;
		   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		  END IF;
	       END IF;
	       -- Container transactions
	     ELSIF (l_transaction_action_id = inv_globals.g_action_containerpack) OR
	       (l_transaction_action_id = inv_globals.g_action_containerunpack) OR
	       (l_transaction_action_id = inv_globals.g_action_containersplit)  THEN
	       IF (l_cost_group_id IS NULL AND l_transfer_cost_group_id IS NULL) THEN
		  IF (l_debug = 1) THEN
   		  print_debug('calling inv_cost_group_update.cost_group_update');
		  END IF;
		  inv_cost_group_update.cost_group_update
		    (p_transaction_rec         => p_mmtt_rec,
		     p_fob_point               => l_fob_point,
		     p_transfer_wms_org        => l_transfer_wms_org_flag,
		     p_tfr_primary_cost_method => l_tfr_primary_cost_method,
		     p_tfr_org_cost_group_id   => l_tfr_org_cost_group_id,
		     p_from_project_id         => l_from_project_id,
		     p_to_project_id           => l_to_project_id,
		     x_return_status           => x_return_status,
		     x_msg_count               => x_msg_count,
		     x_msg_data                => x_msg_data);
		  if( x_return_status = INV_COST_GROUP_PVT.G_COMINGLE_ERROR ) then
		     RAISE inv_comingle_error;
		   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) then
		     RAISE fnd_api.g_exc_error;
		   ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) then
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;
	       END IF;
	     ELSE
	       -- Receipt transactions
	       IF ((l_transaction_action_id NOT IN (inv_globals.g_action_intransitshipment,
						    inv_globals.g_action_intransitreceipt))
		   AND (l_cost_group_id is null AND l_transfer_cost_group_id IS NULL))
		     OR (l_transaction_action_id = inv_globals.g_action_intransitreceipt AND
			 l_cost_group_id IS NULL) THEN

		  IF l_transaction_action_id = inv_globals.g_action_intransitreceipt AND
		    p_mmtt_rec.transfer_cost_group_id IS NULL THEN
		     IF (l_debug = 1) THEN
   		     print_debug('update the mmtt with cost group');
		     END IF;
		     UPDATE mtl_material_transactions_temp
		       SET transfer_cost_group_id = l_transfer_cost_group_id
		       WHERE transaction_temp_id = l_line_id;
		  END IF;

		  IF (l_debug = 1) THEN
   		  print_debug('Calling Rules Engine : ');
		  END IF;
		  wms_costgroupengine_pvt.assign_cost_group
		    (p_api_version => 1.0,
		     p_init_msg_list => FND_API.G_FALSE,
		     p_commit => FND_API.G_FALSE,
		     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		     x_return_status => x_return_Status,
		     x_msg_count => x_msg_count,
		     x_msg_data => x_msg_data,
		     p_line_id  => l_line_id,
		     p_input_type => WMS_CostGroupEngine_PVT.G_INPUT_MMTT);

		  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
		     IF (l_debug = 1) THEN
   		     print_debug('return error from wms_costgroupengine_pvt');
		     END IF;
		     RAISE fnd_api.g_exc_error;
		   ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		     IF (l_debug = 1) THEN
   		     print_debug('return unexpected error from wms_costgroupengine_pvt');
		     END IF;
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;
	       END IF;
	    END IF;
	  ELSIF (p_input_type = g_input_moline) THEN
	    IF (l_debug = 1) THEN
   	    print_debug('before calling wms_costgroupengine_pvt for mtl_txn_request_lines record');
	    END IF;
	    wms_costgroupengine_pvt.assign_cost_group
	      (
	       p_api_version => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit => fnd_api.g_false,
	       p_validation_level => fnd_api.g_valid_level_full,
	       x_return_status => x_return_status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       p_line_id  => l_line_id,
	       p_input_type => wms_costgroupengine_pvt.g_input_mtrl);
            IF (x_return_status = fnd_api.g_ret_sts_error) then
	       IF (l_debug = 1) THEN
   	       print_debug('return error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	     elsif( x_return_status = fnd_api.g_ret_sts_unexp_error) then
	       IF (l_debug = 1) THEN
   	       print_debug('return unexpected error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
            end if;

            x_cost_group_id := NULL;
            x_transfer_cost_group_id := NULL;
	 end if; -- input type
      END IF;-- from_project or to_project is not null
   end if; -- wms org

   print_debug('calling comingling for temp_id '||p_mmtt_rec.transaction_temp_id );
   IF (p_input_type = G_INPUT_MMTT) THEN
      inv_comingling_utils.comingle_check
	(x_return_status                 => x_return_status
	 , x_msg_count                   => x_msg_count
	 , x_msg_data                    => x_msg_data
	 , x_comingling_occurs           => l_comingling_occurs
	 , p_transaction_temp_id         => p_mmtt_rec.transaction_temp_id);

      IF l_comingling_occurs = 'Y' THEN
	 IF (l_debug = 1) THEN
   	 print_debug('assign_cost_group comingling occurs : ' );
	 END IF;
	 RAISE inv_comingle_error;
      END IF;

       --Bug#6343400.Added code to call Calculate_transfer_cost
      IF (l_wms_org_flag) THEN
         IF (l_debug = 1) THEN
   	   print_debug('Calling Calculate_transfer_cost : ' );
          END IF;

         Calculate_transfer_cost
         (   p_mmtt_temp_id                => p_mmtt_rec.transaction_temp_id
            , x_return_status              => x_return_status
	    , x_msg_count                  => x_msg_count
	    , x_msg_data                   => x_msg_data );

          IF ( x_return_status <>  FND_API.g_ret_sts_success ) THEN
           IF (l_debug = 1) THEN
   	      print_debug('Error while executing Calculate_transfer_cost : ' );
           END IF;
           RAISE FND_API.G_EXC_ERROR;
          END IF;
         END IF ;  --End of Bug#6343400
   END IF;

EXCEPTION
   WHEN inv_comingle_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO assign_cost_group;
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
      --Commenting these because this message is getting added
      --in INVCOMUB.pls
      --fnd_message.set_name('INV', 'INV_COMINGLE_ERROR');
      --fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      --Bug 5214602 : FP of 2879206
      g_failure_txn_temp_id := g_current_txn_temp_id;
      print_debug('Failed Txn Temp Id : ' || g_failure_txn_temp_id );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME, 'INV_COST_GROUP_PVT');
        end if;
END;

PROCEDURE get_cost_group(x_cost_group_id      OUT NOCOPY NUMBER,
			 x_cost_group         OUT NOCOPY VARCHAR2,
			 x_return_status      OUT NOCOPY VARCHAR2,
			 x_msg_count          OUT NOCOPY NUMBER,
			 x_msg_data           OUT NOCOPY VARCHAR2,
			 p_organization_id    IN  NUMBER,
			 p_lpn_id             IN  NUMBER,
			 p_inventory_item_id  IN  NUMBER,
			 p_revision           IN  VARCHAR2,
			 p_subinventory_code  IN  VARCHAR2,
			 p_locator_id         IN  NUMBER,
			 p_lot_number         IN  VARCHAR2,
			 p_serial_number      IN  VARCHAR2) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF p_lpn_id IS NULL THEN
      IF p_serial_number IS NULL THEN
	 SELECT ccg.cost_group_id, ccg.cost_group
	   INTO x_cost_group_id, x_cost_group
	   FROM cst_cost_groups ccg, mtl_onhand_quantities_detail moq
	   WHERE ccg.cost_group_id = moq.cost_group_id
	   AND (moq.lot_number = p_lot_number
		OR (p_lot_number IS NULL AND moq.lot_number IS NULL))
	   AND (moq.revision = p_revision
		OR (p_revision IS NULL AND moq.revision IS NULL))
	   AND moq.inventory_item_id = p_inventory_item_id
	   AND ( (p_locator_id IS NOT NULL AND moq.locator_id = p_locator_id)
               OR (p_locator_id IS NULL AND moq.locator_id IS NULL))
	   AND moq.subinventory_code = p_subinventory_code
	   AND moq.organization_id = p_organization_id
	   /* Bug 4662985 -Modifying the condition to fetch records with containerized_flag as null also
           AND moq.containerized_flag = 2  --  Loose Items only */
           AND NVL(moq.containerized_flag, 2) = 2  --  Loose Items only
	   /*End of fix for Bug 4662985 */
	   GROUP BY ccg.cost_group_id, ccg.cost_group;
       ELSE
	 SELECT ccg.cost_group_id, ccg.cost_group
	   INTO x_cost_group_id, x_cost_group
	   FROM cst_cost_groups ccg, mtl_serial_numbers msn
	   WHERE ccg.cost_group_id = msn.cost_group_id
	   AND (msn.lot_number = p_lot_number
		OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
	   AND (msn.revision = p_revision
		OR (p_revision IS NULL AND msn.revision IS NULL))
	   AND msn.inventory_item_id = p_inventory_item_id
	   AND ( (p_locator_id IS NOT NULL AND msn.current_locator_id = p_locator_id)
             OR (p_locator_id IS NULL AND msn.current_locator_id IS NULL))
	   AND msn.current_subinventory_code = p_subinventory_code
           AND msn.current_organization_id = p_organization_id
           --Bug 4248777- Added the condition to check for the serial number also.
           AND msn.serial_number=p_serial_number
           AND msn.lpn_id is null --Added this to restrict the query.
           --End of fix for Bug 4248777
	   GROUP BY ccg.cost_group_id, ccg.cost_group;
      END IF;
    ELSE
      IF p_serial_number IS NULL THEN
	 SELECT ccg.cost_group_id, ccg.cost_group
	   INTO x_cost_group_id, x_cost_group
	   FROM cst_cost_groups ccg, wms_lpn_contents wlc,
	   wms_license_plate_numbers wlpn
	   WHERE ccg.cost_group_id = wlc.cost_group_id
	   AND (wlc.lot_number = p_lot_number
		OR (p_lot_number IS NULL AND wlc.lot_number IS NULL))
	   AND (wlc.revision = p_revision
		OR (p_revision IS NULL AND wlc.revision IS NULL))
	   AND wlc.inventory_item_id = p_inventory_item_id
	   AND wlc.parent_lpn_id = wlpn.lpn_id
	   AND wlpn.locator_id = p_locator_id
	   AND wlpn.subinventory_code = p_subinventory_code
           AND wlpn.organization_id = p_organization_id
	   AND wlpn.lpn_id = p_lpn_id
	   GROUP BY ccg.cost_group_id, ccg.cost_group;
       ELSE
	 SELECT ccg.cost_group_id, ccg.cost_group
	   INTO x_cost_group_id, x_cost_group
	   FROM cst_cost_groups ccg, mtl_serial_numbers msn
	   WHERE ccg.cost_group_id = msn.cost_group_id
	   AND (msn.lot_number = p_lot_number
		OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
	   AND (msn.revision = p_revision
		OR (p_revision IS NULL AND msn.revision IS NULL))
	   AND msn.lpn_id = p_lpn_id
	   AND msn.inventory_item_id = p_inventory_item_id
	   AND msn.current_locator_id = p_locator_id
	   AND msn.current_subinventory_code = p_subinventory_code
	   AND msn.current_organization_id = p_organization_id
           --Bug 4248777-Added the condition for the serial number also
           AND msn.serial_number = p_serial_number
           --End of fix for Bug 4248777
	   GROUP BY ccg.cost_group_id, ccg.cost_group;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION
   WHEN too_many_rows THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_COMMINGLE_EXISTS'); /*bug#2795266*/
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
				p_data	=> x_msg_data);

WHEN NO_DATA_FOUND THEN
 x_return_status := FND_API.g_ret_sts_success;
 /* BUG 2657862
 In this Procedure ,the costgroup is taken from the MOQD
    If there is no system quantity ,then this procedure will fails.
    So  if no record is there ,we need to return sucess and transaction Manager
    has to stamp the exact costgroup.
 */
  x_cost_group_id   :=NULL;
  x_cost_group	 :=NULL;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
				p_data	=> x_msg_data);
END get_cost_group;


END INV_COST_GROUP_PVT;

/

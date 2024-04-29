--------------------------------------------------------
--  DDL for Package Body INV_COMINGLING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COMINGLING_UTILS" AS
/* $Header: INVCOMUB.pls 120.4 2005/12/06 11:32:34 arsawant noship $ */



PROCEDURE print_debug(p_message IN VARCHAR2) IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      IF (l_debug = 1) THEN
         inv_log_util.trace(p_message, 'INV_COMINGLING_UTILS', 9);
      END IF;
END;


/*
** -------------------------------------------------------------------------
** Procedure:   comingle_check
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**      x_comingling_occurs
**              Y: Co-mingling occurs as a result of transaction
**              N: Co-mingling does not occur as a result of transaction
** 	x_count
**		Minimum Number of co-mingling instances for given data
** Input:
**      p_organization_id  number
**              Organization where cost group assignment/transaction occurs
**		For receipts, this will be the source organization,
**		For subinventory and staging transfers, this will be the source organization.
**		(Source Organization = Destination Organization)
**		For inter-organization transfers, this will be transfer organization
**		(Source Organization  <> Destination Organization)
** 	p_inventory_item_id	 number
**		Identifier of item involved in cost group assignment/transaction
** 	p_revision	 varchar2
**		Revision of item involved
**	p_lot_number	 varchar2
**		Lot number of item
**	p_subinventory_code	 varchar2
**		Subinventory where the transaction occurs
**		For receipts, this will be source subinventory
**		For subinventory, staging and inter-organization transfers,
**		this will be transfer subinventory
**	p_locator_id	 number
**		Locator where the transaction occurs
**		For receipts, this will be source locator
**		For subinventory, staging and inter-organization transfers,
**		this will be transfer locator
**	p_lpn_id	 number
**		LPN into which material is packed
** 	p_cost_group_id	 number
**		identifier of cost group that is used in the transaction
**
**
** 	transaction actions
**
** 	Issue from stores           1 inv_globals.G_Action_Issue
** 	Subinventory Xfers          2 inv_globals.G_Action_Subxfr
** 	Direct Org Xfers            3 inv_globals.G_Action_Orgxfr
** 	Intransit Shipment         21 inv_globals.G_Action_IntransitShipment
** 	Staging Xfers              28 inv_globals.G_Action_Stgxfr
** 	Delivery Adjustments       29 inv_globals.G_Action_DeliveryAdj
** 	Assembly Return            32 inv_globals.G_Action_AssyReturn
** 	Negative Component Return  34 inv_globals.G_Action_NegCompReturn
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure comingle_check(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_comingling_occurs           OUT NOCOPY VARCHAR2
, x_count                       OUT NOCOPY NUMBER
, p_organization_id             IN  NUMBER
, p_inventory_item_id           IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, p_subinventory_code           IN  VARCHAR2
, p_locator_id                  IN  NUMBER
, p_lpn_id                      IN  NUMBER
, p_cost_group_id               IN  NUMBER)
as
-- l_moq_count			number := 0;
-- l_mmtt_receipts_count        number := 0;
-- l_mmtt_transfers_count	number := 0;
-- l_lpn_contents_count		number := 0;
-- l_mmtt_lpn_receipts_count	number := 0;
-- l_serial_count                 number := 0;
--BUG 2921882 Changing the count(*) to existence for performance improvement
l_moq_exist                    VARCHAR2(1) := 'N';
l_mmtt_receipts_exist		VARCHAR2(1) := 'N';
l_mmtt_transfers_exist		VARCHAR2(1) := 'N';
l_lpn_contents_exist	        VARCHAR2(1) := 'N';
l_mmtt_lpn_receipts_exist       VARCHAR2(1) := 'N';
l_serial_item                   VARCHAR2(1) := 'N';
begin
   x_return_status := fnd_api.g_ret_sts_success;

   if p_cost_group_id is null then
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   end if;

   BEGIN
      SELECT 'Y' INTO l_serial_item
	FROM dual
	WHERE
	exists
	(--select count(*)
	 --into l_serial_count
	 SELECT inventory_item_id
	 from mtl_system_items
	 where organization_id = p_organization_id
	 and inventory_item_id = p_inventory_item_id
	 and serial_number_control_code NOT IN (1, 6)); --serial controlled items
   EXCEPTION
      WHEN no_data_found THEN
	 l_serial_item	:= 'N';
   END;

   if l_serial_item = 'Y' then
      x_comingling_occurs    := 'N';
      return;
   end if;

 if (p_lpn_id is null) then	/* Non LPN transaction */
 		/*
  		** Look at MTL_ONHAND_QUANTIES, the on hand table
		  */
          BEGIN
	 SELECT 'Y' INTO l_moq_exist
	   FROM dual
	   WHERE
	   exists
	   (SELECT organization_id
	    --BUG 2921882
	    --Changing the count(*) to existence for performance improvement
	    --select
	    --count(*)
	    --into l_moq_count
	    from mtl_onhand_quantities_detail
	    where organization_id = p_organization_id
	    AND inventory_item_id  = p_inventory_item_id
	    AND (revision = p_revision
		 OR revision is null and p_revision is null)
	    AND (lot_number = p_lot_number
		 OR lot_number is null and p_lot_number is null)
	    AND subinventory_code = p_subinventory_code
	    AND  (locator_id = p_locator_id
		  OR locator_id is null and  p_locator_id is null)
	    AND cost_group_id is not null
	    AND cost_group_id <> p_cost_group_id
	    AND containerized_flag = 2 --  (loose material)
	    );
      EXCEPTION
	 WHEN no_data_found THEN
	    l_moq_exist := 'N';
      END;

      if (l_moq_exist = 'Y') then
	 x_count := 1;
	 x_comingling_occurs := 'Y';
	 return;
      end if;

 /*
 ** Look at MTL_MATERIAL_TRANSACTIONS_TEMP, Pending transactions and Suggestions table
 **
 ** For MTL_MATERIAL_TRANSACTIONS_TEMP records - Suggestions and Pending Transactions,
 ** only receipts are considered.
 */

 /*
 ** Suggestions, Pending Transactions - Receipts
 **
 ** Following Transactions Actions are Issues
 ** Issue from stores          	1
 ** Subinventory Xfers       	2
 ** Direct Org Xfers           	3
 ** Intransit Shipment         	21
 ** Staging Xfers              	28
 ** Delivery Adjustments       	29
 ** Assembly Return            	32
 ** Negative Component Return  	34
 **
   */
    if (p_lot_number is null) then
      BEGIN
	 SELECT 'Y' INTO
	   l_mmtt_receipts_exist FROM dual
	   WHERE
	   exists
	   (SELECT organization_id
	    --BUG 2921882
	    --Changing the count(*) to existence for performance improvement
	    --select
	    --count(*)
	    --into l_mmtt_receipts_count
	    from mtl_material_transactions_temp
	    where organization_id = p_organization_id
	    AND inventory_item_id = p_inventory_item_id
	    AND (revision = p_revision
		 OR revision is null and p_revision is null)
	    AND lot_number is null
	    AND subinventory_code = p_subinventory_code
	    AND (locator_id = p_locator_id
		 OR locator_id is null and p_locator_id is null)
	    AND cost_group_id is not null
	    AND cost_group_id <> p_cost_group_id
	    AND transaction_action_id not in (inv_globals.G_Action_Issue,
					      inv_globals.G_Action_Subxfr,
					      inv_globals.G_Action_Orgxfr,
					      inv_globals.G_Action_IntransitShipment,
					      inv_globals.G_Action_Stgxfr,
					      inv_globals.G_Action_DeliveryAdj,
					      inv_globals.G_Action_AssyReturn,
					      inv_globals.G_Action_NegCompReturn)
		 AND posting_flag = 'Y');
	   EXCEPTION
	      WHEN no_data_found THEN
		 l_mmtt_receipts_exist := 'N';
	   END;


     else /* Lot Controlled Item transaction */

         BEGIN
	    SELECT 'Y' INTO l_mmtt_receipts_exist
	      FROM dual
	      WHERE
	      exists
	      (SELECT mmtt.organization_id --Bug 4496965
	       --BUG 2921882
	       --Changing the count(*) to existence for performance improvement
	       --select
	       --count(*)
	       --into l_mmtt_receipts_count
	       from mtl_material_transactions_temp mmtt,
	       mtl_transaction_lots_temp mtlt
	       where mmtt.organization_id = p_organization_id
	       AND mmtt.inventory_item_id = p_inventory_item_id
	       AND (mmtt.revision = p_revision
		    OR mmtt.revision is null and p_revision is null)
	       AND (mtlt.lot_number = p_lot_number
		    and mtlt.transaction_temp_id = mmtt.transaction_temp_id)
	       AND mmtt.subinventory_code = p_subinventory_code
	       AND (mmtt.locator_id = p_locator_id
		    OR mmtt.locator_id is null and  p_locator_id is null)
	       AND mmtt.cost_group_id is not null
	       AND mmtt.cost_group_id <> p_cost_group_id
	       AND transaction_action_id not in (inv_globals.G_Action_Issue,
						 inv_globals.G_Action_Subxfr,
						 inv_globals.G_Action_Orgxfr,
						 inv_globals.G_Action_IntransitShipment,
						 inv_globals.G_Action_Stgxfr,
						 inv_globals.G_Action_DeliveryAdj,
						 inv_globals.G_Action_AssyReturn,
						 inv_globals.G_Action_NegCompReturn)
			 AND mmtt.posting_flag = 'Y');
		 EXCEPTION
		    WHEN no_data_found THEN
		       l_mmtt_receipts_exist := 'N';
	 END;

    end if;

    IF (l_mmtt_receipts_exist = 'Y') THEN
       x_count 		:= 1;--l_mmtt_receipts_count
       x_comingling_occurs 	:= 'Y';
       return;
    END IF;

 /*
 ** Suggestions, Pending Transactions - Transfers - Destination Side
 **
 ** Following Transactions Actions are Transfers
 ** Subinventory Xfers       	2
 ** Direct Org Xfers           	3
 ** Staging Xfers              	28
 **
   */

   	  IF (p_lot_number is null) THEN
	     --Splitting the query for bug 2921882
	     IF p_locator_id IS NULL THEN
		BEGIN
		   SELECT 'Y' INTO l_mmtt_transfers_exist
		     FROM dual
		     WHERE
		     exists
		     (SELECT organization_id
		      --BUG 2921882
		      --Changing the count(*) to existence for performance improvement
		      --select
		      --count(*)
		      --into l_mmtt_transfers_count
		      from mtl_material_transactions_temp
		      where decode(transaction_action_id, inv_globals.G_Action_Orgxfr, transfer_organization, organization_id)= p_organization_id
		      and inventory_item_id = p_inventory_item_id
		      and (revision = p_revision
			   OR revision is null and p_revision is null)
		      AND lot_number is null
		      AND transfer_subinventory = p_subinventory_code
		      AND transfer_to_location IS null
		      AND transfer_cost_group_id is not null
		      AND transfer_cost_group_id <> p_cost_group_id
		      AND transaction_action_id in (inv_globals.G_Action_Subxfr,
						    inv_globals.G_Action_Orgxfr,
						    inv_globals.G_Action_Stgxfr)
		      AND posting_flag = 'Y');
		EXCEPTION
		   WHEN no_data_found THEN
		      l_mmtt_transfers_exist := 'N';
		END;
	      ELSE
		   BEGIN
		      SELECT 'Y' INTO l_mmtt_transfers_exist
			FROM dual
			WHERE
			exists
			(SELECT organization_id
			 --BUG 2921882
			 --Changing the count(*) to existence for performance improvement
			 --select
			 --count(*)
			 --into l_mmtt_transfers_count
			 from mtl_material_transactions_temp
			 where decode(transaction_action_id, inv_globals.G_Action_Orgxfr, transfer_organization, organization_id)= p_organization_id
			 and inventory_item_id = p_inventory_item_id
			 and (revision = p_revision
			      OR revision is null and p_revision is null)
			 AND lot_number is null
			 AND transfer_subinventory = p_subinventory_code
			 AND transfer_to_location = p_locator_id
			 AND transfer_cost_group_id is not null
			 AND transfer_cost_group_id <> p_cost_group_id
			 AND transaction_action_id in (inv_globals.G_Action_Subxfr,
						       inv_globals.G_Action_Orgxfr,
						       inv_globals.G_Action_Stgxfr)
			 AND posting_flag = 'Y');
		   EXCEPTION
		      WHEN no_data_found THEN
			 l_mmtt_transfers_exist := 'N';
		   END;
	     END IF;

	   else /* Lot Controlled Item transaction */

     		      IF p_locator_id IS NULL then
                         BEGIN
			    SELECT 'Y' INTO l_mmtt_transfers_exist
			      FROM dual
			      WHERE
			      exists
			      (SELECT mmtt.organization_id --Bug 4496965
			       --BUG 2921882
			       --Changing the count(*) to existence for performance improvement
			       --select
			       --count(*)
			       --into l_mmtt_transfers_count
			       from mtl_material_transactions_temp mmtt,
			       mtl_transaction_lots_temp mtlt
			       where decode(transaction_action_id, inv_globals.G_Action_Orgxfr, transfer_organization, mmtt.organization_id)= p_organization_id
			       AND mmtt.inventory_item_id = p_inventory_item_id
			       AND (mmtt.revision = p_revision
				    OR mmtt.revision is null and p_revision is null)
			       AND (mtlt.lot_number = p_lot_number
				    AND mtlt.transaction_temp_id = mmtt.transaction_temp_id)
			       AND mmtt.transfer_subinventory = p_subinventory_code
			       AND mmtt.transfer_to_location IS null
			       AND mmtt.transfer_cost_group_id is not null
			       AND mmtt.transfer_cost_group_id <> p_cost_group_id
			       AND transaction_action_id in (inv_globals.G_Action_Subxfr,
							       inv_globals.G_Action_Orgxfr,
							     inv_globals.G_Action_Stgxfr)
				 AND posting_flag = 'Y');
			 EXCEPTION
			    WHEN no_data_found THEN
			       l_mmtt_transfers_exist := 'N';
			 END;
		       ELSE
			       BEGIN
				  SELECT 'Y' INTO l_mmtt_transfers_exist
				    FROM dual
				    WHERE
				    exists
				    (SELECT mmtt.organization_id --Bug 4496965
				     --BUG 2921882
				     --Changing the count(*) to existence for performance improvement
				     --select
				     --count(*)
				     --into l_mmtt_transfers_count
				     from mtl_material_transactions_temp mmtt,
				     mtl_transaction_lots_temp mtlt
				     where decode(transaction_action_id, inv_globals.G_Action_Orgxfr, transfer_organization, mmtt.organization_id)= p_organization_id
				     AND mmtt.inventory_item_id = p_inventory_item_id
				     AND (mmtt.revision = p_revision
					  OR mmtt.revision is null and p_revision is null)
				     AND (mtlt.lot_number = p_lot_number
					  AND mtlt.transaction_temp_id = mmtt.transaction_temp_id)
				     AND mmtt.transfer_subinventory = p_subinventory_code
				     AND mmtt.transfer_to_location = p_locator_id
				     AND mmtt.transfer_cost_group_id is not null
				     AND mmtt.transfer_cost_group_id <> p_cost_group_id
				     AND transaction_action_id in (inv_globals.G_Action_Subxfr,
								   inv_globals.G_Action_Orgxfr,
								   inv_globals.G_Action_Stgxfr)
				       AND posting_flag = 'Y');
			       EXCEPTION
				  WHEN no_data_found THEN
				     l_mmtt_transfers_exist := 'N';
			       END;
		      END IF;
	  END IF;

	  IF (l_mmtt_transfers_exist = 'Y') THEN
	     x_count 		:= 1;--l_mmtt_transfers_count;
	     x_comingling_occurs 	:= 'Y';
	     return;
	  END IF;

 else /* LPN transaction */
 	/*
 	** Look at WMS_LPN_CONTENTS, lpn content details table
	  */

	     BEGIN
			SELECT 'Y' INTO l_lpn_contents_exist
			  FROM dual
			  WHERE
			  exists
			  (SELECT organization_id
			   --BUG 2921882
			   --Changing the count(*) to existence for performance improvement
			   --select
			   --count(*)
			   --into l_lpn_contents_count
			   from wms_lpn_contents
			   where organization_id = p_organization_id
			   AND inventory_item_id  = p_inventory_item_id
			   AND (revision = p_revision
				OR revision is null and p_revision is null)
			   AND (lot_number = p_lot_number
				OR lot_number is null and p_lot_number is null)
			   AND cost_group_id is not null
			   AND cost_group_id <> p_cost_group_id
			   AND parent_lpn_id = p_lpn_id);
		     EXCEPTION
			WHEN no_data_found THEN
			   l_lpn_contents_exist  := 'N';
		     END;

		     IF ( l_lpn_contents_exist = 'Y') THEN
			x_count 		:= 1;--l_lpn_contents_count
			x_comingling_occurs 	:= 'Y';
			return;
		     END IF;

 /*
 ** Look at MTL_MATERIAL_TRANSACTIONS_TEMP, Pending transactions and Suggestions table
 ** for pending pack transactions and suggestions.
 **
 ** For MTL_MATERIAL_TRANSACTIONS_TEMP LPN records - Suggestions and Pending
 ** Transactions, only pack transactions are considered.
 */

   		       IF (p_lot_number is null) THEN
			  BEGIN
			     SELECT 'Y' INTO l_mmtt_lpn_receipts_exist
			       FROM dual
			       WHERE
			       exists
			       (SELECT organization_id
				--BUG 2921882
				--Changing the count(*) to existence for performance improvement
				--select
				--count(*)
				--into l_mmtt_lpn_receipts_count
				from mtl_material_transactions_temp
				where organization_id = p_organization_id
				AND inventory_item_id = p_inventory_item_id
				AND (revision = p_revision
				     OR revision is null and p_revision is null)
				AND lot_number is null
				and subinventory_code = p_subinventory_code
				and (locator_id = p_locator_id
				     OR locator_id is null and  p_locator_id is null)
				AND cost_group_id is not null
				AND cost_group_id <> p_cost_group_id
				AND posting_flag = 'Y'
				AND transfer_lpn_id is not null
				AND transfer_lpn_id = p_lpn_id);
			  EXCEPTION
			     WHEN no_data_found THEN
				l_mmtt_lpn_receipts_exist := 'N';
			  END;

			ELSE /* Lot Controlled LPN transaction */
				BEGIN
				   SELECT 'Y' INTO l_mmtt_lpn_receipts_exist
				     FROM dual
				     WHERE
				     exists
				     (SELECT mmtt.organization_id --Bug 4496965
				      --BUG 2921882
				      --Changing the count(*) to existence for performance improvement
				      --select
				      --count(*)
				      --into
				      --l_mmtt_lpn_receipts_count
				      from mtl_material_transactions_temp mmtt,
				      mtl_transaction_lots_temp mtlt
				      where mmtt.organization_id = p_organization_id
				      AND mmtt.inventory_item_id = p_inventory_item_id
				      AND (mmtt.revision = p_revision
					   OR mmtt.revision is null and p_revision is null)
				      AND (mtlt.lot_number = p_lot_number
					   AND mtlt.transaction_temp_id = mmtt.transaction_temp_id)
				      AND mmtt.subinventory_code = p_subinventory_code
				      AND (mmtt.locator_id = p_locator_id
					   OR mmtt.locator_id is null and p_locator_id is null)
				      AND mmtt.cost_group_id is not null
				      AND mmtt.cost_group_id <> p_cost_group_id
				      AND mmtt.posting_flag = 'Y'
				      AND mmtt.transfer_lpn_id is not null
				      AND mmtt.transfer_lpn_id = p_lpn_id);
				EXCEPTION
				   WHEN no_data_found THEN
				      l_mmtt_lpn_receipts_exist := 'N';
				END;
		       END IF;

		       IF (l_mmtt_lpn_receipts_exist = 'Y') THEN
			  x_count 		:= 1; --l_mmtt_lpn_receipts_count;
			  x_comingling_occurs 	:= 'Y';
			  return;
		       END IF;
 end if;

		 x_comingling_occurs := 'N';

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
   --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
   WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
          );
   --dbms_output.put_line(replace(x_msg_data,chr(0),' '));

   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg ('inv_comingling_utils'
              , 'comingle_check'
              );
        END IF;
   --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
     fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
          );
end comingle_check;

procedure comingle_check
  (x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , x_comingling_occurs           OUT NOCOPY VARCHAR2
   , p_transaction_temp_id         IN NUMBER)
  IS
     cursor mmtt_cur IS
	SELECT * FROM
	  mtl_material_transactions_temp
	  WHERE
	  transaction_temp_id = p_transaction_temp_id;
BEGIN

   FOR mmtt_rec IN mmtt_cur LOOP
      --below procedure is called only once
      --because one temp_id corresponds to only one record
      inv_comingling_utils.comingle_check
	(x_return_status        =>  x_return_status
	 , x_msg_count          =>  x_msg_count
	 , x_msg_data           =>  x_msg_data
	 , x_comingling_occurs  =>  x_comingling_occurs
	 , p_mmtt_rec           =>  mmtt_rec);
   END LOOP;

   IF mmtt_cur%isopen  THEN
      CLOSE mmtt_cur;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg ('inv_comingling_utils'
				  , 'comingle_check'
				  );
      END IF;
      --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data);
      IF mmtt_cur%isopen  THEN
	 CLOSE mmtt_cur;
      END IF;
END;



procedure comingle_check
  (x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                   OUT NOCOPY NUMBER
   ,x_msg_data                    OUT NOCOPY VARCHAR2
   ,x_comingling_occurs           OUT NOCOPY VARCHAR2
   ,p_mmtt_rec                    IN  mtl_material_transactions_temp%ROWTYPE)
  IS

     CURSOR mtlt_cur IS
	SELECT
	  mtlt.lot_number lot
	  FROM
	  mtl_transaction_lots_temp mtlt
	  WHERE mtlt.transaction_temp_id = p_mmtt_rec.transaction_temp_id;

     l_serials_exist     VARCHAR2(1) := 'N';
     l_return_status     VARCHAR2(1) := NULL;
     l_msg_data          VARCHAR2(255) := NULL;
     l_msg_count         NUMBER        := NULL;
     l_comingling_occurs VARCHAR2(1) := 'N';
     l_count             NUMBER        := NULL;
     l_lot_number        VARCHAR2(255) := NULL;

     l_wms_org_flag     BOOLEAN := FALSE;
     l_comingle_sub    VARCHAR2(30) := NULL;
     l_comingle_org    NUMBER       := NULL;
     l_comingle_loc   NUMBER        := NULL;
     l_comingle_cg    NUMBER        := NULL;

     l_lpn_id NUMBER := NULL;
     l_content_lpn_id NUMBER := NULL;
     l_transfer_lpn_id NUMBER := NULL;
     l_lpn_controlled_flag NUMBER := NULL;
     l_check_done     BOOLEAN := FALSE; --4576727

BEGIN

   x_return_status := fnd_api.g_ret_sts_success;
   x_comingling_occurs := 'N';


   IF p_mmtt_rec.transaction_temp_id IS NULL THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   /***
   --If serials are involved, comingling cannot occur
   ***/

   BEGIN
      SELECT 'Y' INTO l_serials_exist
	FROM dual
	WHERE exists
	( SELECT 1
	  FROM mtl_serial_numbers_temp
	  WHERE transaction_temp_id = p_mmtt_rec.transaction_temp_id);
   EXCEPTION
      WHEN no_data_found THEN
         BEGIN
	    SELECT 'Y' INTO l_serials_exist
	      FROM dual
	      WHERE exists
	      (SELECT msnt.transaction_temp_id
	       FROM
	       mtl_serial_numbers_temp msnt,
	       mtl_transaction_lots_temp mtlt
	       WHERE mtlt.transaction_temp_id = p_mmtt_rec.transaction_temp_id
	       AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id);
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_serials_exist := 'N';
	 END;
   END;

   IF l_serials_exist = 'Y' THEN
       print_debug('serials exist - no comingle');
      x_comingling_occurs := 'N';
      RETURN;
   END IF;



   l_comingle_sub := p_mmtt_rec.subinventory_code;
   l_comingle_org := p_mmtt_rec.organization_id;
   l_comingle_loc := p_mmtt_rec.locator_id;
   l_comingle_cg := p_mmtt_rec.cost_group_id;
   -- For transfer transactions, pass the attributes of the transfer(receipt)
   -- side to comingle check.
   if (p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_SUBXFR)
     OR (p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_PLANXFR)
     OR (p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_ORGXFR)
     OR (p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_STGXFR) then

      l_comingle_sub := p_mmtt_rec.transfer_subinventory;
      l_comingle_loc := p_mmtt_rec.transfer_to_location;
      l_comingle_cg := p_mmtt_rec.transfer_cost_group_id;
      if (p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_ORGXFR) then
	 l_comingle_org := Nvl(p_mmtt_rec.transfer_organization,p_mmtt_rec.organization_id);
      end if;

   end if;

   --Bug 2892207 moved this from above so that l_wms_org_flag is
   --queried for the right organization
   l_wms_org_flag := wms_install.check_install
     ( x_return_status =>l_return_status,
       x_msg_count =>l_msg_count,
       x_msg_data =>l_msg_data,
       p_organization_id => l_comingle_org);
   if (l_return_status = FND_API.G_RET_STS_ERROR) then
      RAISE FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   l_lpn_id := p_mmtt_rec.lpn_id;
   l_content_lpn_id := p_mmtt_rec.content_lpn_id;
   l_transfer_lpn_id := p_mmtt_rec.transfer_lpn_id;
   --bug 2712046 fix
   IF (p_mmtt_rec.content_lpn_id IS NOT NULL
       OR p_mmtt_rec.transfer_lpn_id IS NOT NULL) THEN
         BEGIN
	    SELECT
	      Nvl(lpn_controlled_flag,2)
	      INTO
	      l_lpn_controlled_flag
	      FROM
	      mtl_secondary_inventories
	      WHERE
	      secondary_inventory_name = l_comingle_sub
	      AND organization_id = l_comingle_org;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_lpn_controlled_flag := 2;
	 END;

	 IF l_lpn_controlled_flag = 2 THEN
	    print_debug('l_comingle_sub '||l_comingle_sub||
			' is lpn ctrld:setting clpn-xfr lpn as null');
	    l_content_lpn_id := NULL;
	    l_transfer_lpn_id := NULL;
	 END IF;
   END IF;



   -- Check if Co-mingling occurs for transacting data
   -- skip this if this is an Issue/Shipment/CostGroupXfr/LotSplit
   -- transaction OR if it is occuring in a Non-WMS enabled ORG as these
   -- could not result on CoMingle. Loop through MTL_LOT_NUMBERS_TEMP
   -- in case item is lot controlled. If content_lpn_id is present, then this
   -- transaction could not result in comingling, skip check
   -- Skip comingle-check if (from)_lpn_id is same as transfer_lpn_id. This is the
   -- case when receiving an LPN through the RcvTrxManager.
   -- If a stageXfr transaction and packing to an LPN, then allow comingle.
   -- Skip check if cycle/physical count and Issue transaction (qty < 0)
   -- Skip check if cost-group is null OR it is a transfer-transaction
   -- and transfer-cost-group is null. This is the case where the CostGroupAPI
   -- does not populate cost-group as CostGroup is derived by INV_WWACST.
   if (l_content_lpn_id is NULL)
     AND (l_wms_org_flag)
     AND (p_mmtt_rec.transaction_action_id <> inv_globals.G_ACTION_ISSUE)
     AND (p_mmtt_rec.transaction_action_id <> inv_globals.g_action_inv_lot_translate)
     AND (p_mmtt_rec.transaction_action_id <> inv_globals.G_Action_CostGroupXfr)
     AND (p_mmtt_rec.transaction_action_id <> inv_globals.G_Action_IntransitShipment)
     AND (p_mmtt_rec.transaction_action_id <> inv_globals.G_Action_inv_lot_split)
     AND (NOT ((p_mmtt_rec.transaction_action_id = inv_globals.G_Action_CycleCountAdj)
	       AND  (p_mmtt_rec.primary_quantity < 0) ))
     AND (NOT ((p_mmtt_rec.transaction_action_id = inv_globals.G_Action_PhysicalCountAdj)
	       AND  (p_mmtt_rec.primary_quantity < 0) ))
     AND (NOT ((p_mmtt_rec.transaction_action_id = inv_globals.G_ACTION_STGXFR)
	       AND  (l_transfer_lpn_id is not NULL)))
     AND ( nvl(l_lpn_id, 1) <> nvl(l_transfer_lpn_id, 2))
     AND l_comingle_cg IS NOT NULL then

      /**2912538 Commenting the below code because with the below
      ** condition, for a transfer transaction, if the transfer cost group
	** is null(we expect such a case when the destination is a project
	** locator) and cost group is not null, instead of skipping comingle
	** check on the destination side,it continues with the comingle
	**check
	**((p_mmtt_rec.cost_group_id is not NULL)
	**   OR
	**  (p_mmtt_rec.transaction_action_id in
	**   (inv_globals.G_ACTION_SUBXFR,
	**    inv_globals.G_ACTION_ORGXFR,
	**    inv_globals.G_ACTION_STGXFR)
        **    AND p_mmtt_rec.transfer_cost_group_id is not NULL) ) THEN ***/

      l_check_done := FALSE;  --4576727
      OPEN mtlt_cur;
      LOOP

	 l_lot_number := NULL;
	 l_return_status := fnd_api.g_ret_sts_success;
	 l_msg_data      := NULL;
	 l_msg_count     := NULL;
	 l_comingling_occurs := 'N';

	 FETCH mtlt_cur INTO l_lot_number;

	 IF mtlt_cur%rowcount = 0 THEN
	    --there are no lots involved
	    l_lot_number := NULL;
	 END IF;

	 EXIT WHEN  ( mtlt_cur%notfound and l_check_done ); -- 4576727

	 print_debug('calling comingle_check:org '||l_comingle_org||
		     'item '||p_mmtt_rec.inventory_item_id||
		     'rev '||p_mmtt_rec.revision||
		     'lot '||l_lot_number||
		     'sub '||l_comingle_sub||
		     'loc '||l_comingle_loc||
		     'lpn '||l_transfer_lpn_id||
		     'cg '||l_comingle_cg);

         print_debug(' Calling Comingle Check');
         l_check_done := TRUE; --4576727

	 INV_COMINGLING_UTILS.comingle_check
	   ( x_return_status       => l_return_status
	     , x_msg_count         => l_msg_count
	     , x_msg_data          => l_msg_data
	     , x_comingling_occurs => l_comingling_occurs
	     , x_count             => l_count
	     , p_organization_id   => l_comingle_org
	     , p_inventory_item_id => p_mmtt_rec.inventory_item_id
	     , p_revision          => p_mmtt_rec.revision
	     , p_lot_number        => l_lot_number
	     , p_subinventory_code => l_comingle_sub
	     , p_locator_id        => l_comingle_loc
	     , p_lpn_id            => l_transfer_lpn_id
	     , p_cost_group_id     => l_comingle_cg);


	 IF l_return_status <> fnd_api.g_ret_sts_success THEN

	    x_return_status          := l_return_status;
	    x_msg_count              := l_msg_count;
	    x_msg_data               := l_msg_data;

	    IF mtlt_cur%isopen  THEN
	       CLOSE mtlt_cur;
	    END IF;

	    RETURN;

	  ELSIF l_comingling_occurs = 'Y' THEN

	    x_comingling_occurs := 'Y';

	    IF mtlt_cur%isopen  THEN
	       CLOSE mtlt_cur;
	    END IF;

	    fnd_message.set_name('INV', 'INV_COMINGLE_FAIL');
	    FND_MESSAGE.SET_TOKEN('CG', l_comingle_cg);
	    fnd_msg_pub.add;
	    RETURN;

	 END IF;--l_comingling_occurs = 'Y'


      END LOOP;

      --Begin bug 4471702
      IF mtlt_cur%isopen  THEN
	 CLOSE mtlt_cur;
      END IF;
      --End bug 4471702

   END IF;

   x_comingling_occurs := 'N';

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
	  );
      IF mtlt_cur%isopen  THEN
	 CLOSE mtlt_cur;
      END IF;
      --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
      IF mtlt_cur%isopen  THEN
	 CLOSE mtlt_cur;
      END IF;
      --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg ('inv_comingling_utils'
				  , 'comingle_check'
				  );
      END IF;
      --dbms_output.put_line(replace(x_msg_data,chr(0),' '));
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
      IF mtlt_cur%isopen  THEN
	 CLOSE mtlt_cur;
      END IF;
end comingle_check;




end inv_comingling_utils;

/

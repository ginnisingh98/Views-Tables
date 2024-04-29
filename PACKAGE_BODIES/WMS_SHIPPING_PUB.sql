--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_PUB" AS
/* $Header: WMSSHPPB.pls 120.2 2005/10/21 18:15:25 mrana noship $ */

G_Debug BOOLEAN := TRUE;

PROCEDURE DEBUG(p_message	IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   if( G_Debug = TRUE ) then
      inv_mobile_helper_functions.tracelog
	(p_err_msg => p_message,
	 p_module => 'WMS_SHIPPING_PUB',
	 p_level => 9);
   end if;
END;


PROCEDURE DEL_WSTT_RECS_BY_DELIVERY_ID (x_return_status  OUT NOCOPY VARCHAR2,
					x_msg_count      OUT NOCOPY NUMBER,
					x_msg_data       OUT NOCOPY VARCHAR2,
					p_commit         IN  VARCHAR2 := FND_API.g_false,
					p_init_msg_list  IN  VARCHAR2 := FND_API.g_false,
					p_api_version    IN  NUMBER := 1.0, --3555636 changed from varchar2 to number
					p_delivery_ids   IN  wsh_util_core.id_tab_type
					)
  IS
     l_delivery_id        NUMBER;
     l_delivery_detail_id NUMBER;
     l_outermost_lpn_id   NUMBER;
     l_api_version        CONSTANT NUMBER := 1.0;
     l_api_name           CONSTANT VARCHAR2(30) := 'DEL_WSTT_RECS_BY_DELIVERY_ID';
     l_organization_id    NUMBER;
     l_direct_ship_flag   VARCHAR2(1) := 'N';

     CURSOR get_delivery_detail_id (l_delivery_id NUMBER)
       IS
	  SELECT delivery_detail_id
	    FROM wsh_delivery_assignments_v
	    WHERE delivery_id = l_delivery_id;
     CURSOR get_lpn_id (l_delivery_detail_id NUMBER)
       IS
	  SELECT DISTINCT outermost_lpn_id
	    FROM wms_shipping_transaction_temp
	    WHERE delivery_detail_id = l_delivery_detail_id ;
	    --  MRANA .. bug4287561 ..AND nvl(direct_ship_flag,'N') = 'N';
            /* MRANA .. bug4287561 ...commented the above condition since we
            --want to process lines loaded thru direct ship page too */

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN debug('IN ... DEL_WSTT_RECS_BY_DELIVERY_ID ' ); END IF;

   -- Initialize return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF NOT FND_API.compatible_api_call(l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   SAVEPOINT DEL_WSTT_RECS_BY_DELIVERY_ID;

   IF (p_delivery_ids.COUNT <> 0) THEN
      FOR i IN p_delivery_ids.first .. p_delivery_ids.last
	LOOP
	   l_delivery_id := p_delivery_ids(i);

	   IF (l_debug = 1) THEN
	      debug('Deleted Delivery : '||l_delivery_id);
	      debug('wms_globals.g_ship_confirm_method: ' || wms_globals.g_ship_confirm_method);
	   END IF;

	   OPEN get_delivery_detail_id(l_delivery_id);
	   LOOP
	      FETCH get_delivery_detail_id
               INTO l_delivery_detail_id;
	      EXIT WHEN get_delivery_detail_id%notfound;

           IF l_debug = 1 THEN
              debug('wms_globals.g_ship_confirm_method : ' || wms_globals.g_ship_confirm_method);
           END IF;

            -- MRANA .. bug4287561
            -- Added the condition around the delete, as it should happen only if
            --it is not called from direct ship
           IF (wms_globals.g_ship_confirm_method IS NULL OR
               wms_globals.g_ship_confirm_method <> 'DIRECT') THEN

              IF l_organization_id IS NULL THEN
                 -- Assuming that all deliveries being ship confirmed belong to the same org
                SELECT organization_id
                INTO l_organization_id
                FROM wsh_delivery_details
                WHERE delivery_detail_id = l_delivery_detail_id;
              END IF;
              IF l_debug = 1 THEN debug('Deleting mtl_material_transactions_temp '); END IF;

              /* MRANA :
                -- {{- Delete all pending staging move transactions in MMTT/WDT, for }}
                -- {{  all the staged LPNs belonging to the given delivery }} */
              BEGIN

	         DELETE FROM wms_dispatched_tasks wdt
		   WHERE task_type = 7
		   AND organization_id = l_organization_id
		   AND transfer_lpn_id IN
		  (SELECT wlpn.outermost_lpn_id
		    FROM wms_license_plate_numbers wlpn,
		         wsh_delivery_details wdd,
		         wsh_delivery_assignments_v wda
		    WHERE wda.delivery_detail_id = l_delivery_detail_id
		    AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
		    AND wdd.lpn_id = wlpn.lpn_id);
                 IF l_debug = 1 THEN debug('Deleted Staging move WDTs ' || l_delivery_detail_id); END IF;
                 IF SQL%NOTFOUND THEN
                    NULL; -- will not find for direct ship case
		    IF l_debug = 1 THEN
                        debug('could not fine Staging move WDTs ' || l_delivery_detail_id);
		    END IF;
                 END IF;
	         DELETE FROM mtl_material_transactions_temp
		   WHERE wms_task_type = 7
		   AND organization_id = l_organization_id
		   AND content_lpn_id IN
		  ( SELECT wlpn.outermost_lpn_id
		    FROM wms_license_plate_numbers wlpn,
		         wsh_delivery_details wdd,
		         wsh_delivery_assignments_v wda
		    WHERE wda.delivery_detail_id = l_delivery_detail_id
		    AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
		    AND wdd.lpn_id = wlpn.lpn_id);
                  IF l_debug = 1 THEN debug('Deleted Staging move MMTT ' || l_delivery_detail_id); END IF;
                 IF SQL%NOTFOUND THEN
                    NULL; -- will not find for direct ship case
		    IF l_debug = 1 THEN
                        debug('could not fine Staging move MMTT ' || l_delivery_detail_id);
		    END IF;
                 END IF;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 null;
                 IF l_debug = 1 THEN debug('No lpn found in WDD for DDL: ' || l_delivery_detail_id); END IF;
              END ;


              IF l_debug = 1 THEN debug('Open get_lpn_id '); END IF;

	      -- get lpn_ids to update the context
	   /*   Mrana: MDC & LPN Convergence : The following updates should not be necessary
 *            OPEN get_lpn_id(l_delivery_detail_id);
	      LOOP
		 FETCH get_lpn_id INTO l_outermost_lpn_id;
		 EXIT WHEN get_lpn_id%notfound;
		 -- update lpns with context of picked

                 IF l_debug = 1 THEN debug('Ready to update wms_license_plate_numbers '); END IF;

		 --// Talk to Jason/Tharian  **MRANA
		 UPDATE wms_license_plate_numbers
		   SET lpn_context = 11,
		   last_update_date = Sysdate,
		   last_updated_by = fnd_global.user_id
		   WHERE lpn_id IN (SELECT lpn_id
				    FROM wms_license_plate_numbers
				    START WITH lpn_id = l_outermost_lpn_id
				    CONNECT BY parent_lpn_id = PRIOR lpn_id);

                 IF l_debug = 1 THEN
                    debug('Updated wms_license_plate_numbers : ' || l_outermost_lpn_id);
                 END IF;
	      END LOOP;
	      CLOSE get_lpn_id; */
           END IF; -- wms_globals.g_ship_confirm_method <> 'DIRECT' THEN
	   END LOOP;

           IF l_debug = 1 THEN
              debug('deleting   wms_direct_ship_temp ' || l_delivery_detail_id);
           END IF;

	   CLOSE get_delivery_detail_id;

            -- MRANA .. bug4287561
            -- Moved the deletion of the temp table records from delivery
            -- detail loop to delivery_id loop for better efficieny.
            -- In case this API is called from direct ship page, we do
            -- not want to delete these records since it happens in DS page
           IF (wms_globals.g_ship_confirm_method IS NULL OR
               wms_globals.g_ship_confirm_method <> 'DIRECT') THEN
              BEGIN
                IF l_debug = 1 THEN debug('Ready to delete  wms_direct_ship_temp '); END IF;

                DELETE FROM wms_direct_ship_temp
                WHERE LPN_ID IN (SELECT DISTINCT  outermost_lpn_id
                                 FROM wms_shipping_transaction_temp
                                 WHERE delivery_id = l_delivery_id);
                IF l_debug = 1 THEN
                  debug('sucessful deleting wms_direct_ship_temp for all lpns with delivery_id = ' || l_delivery_id);
                END IF;
                IF SQL%NOTFOUND THEN
                   NULL;
                   IF l_debug = 1 THEN
                      debug('could not find any wms_direct_ship_temp for lpns with delivery_id = ' || l_delivery_id);
                   END IF;
                END IF ;
              END ;
              BEGIN
                IF l_debug = 1 THEN debug('Ready to delete wms_shipping_transaction_temp '); END IF;
                 DELETE FROM wms_shipping_transaction_temp
                 WHERE delivery_id = l_delivery_id ;
                 IF l_debug = 1 THEN
                    debug('sucessful deleting   wms_shipping_transaction_temp  where delivery_id = ' || l_delivery_id);
                 END IF;
                 IF SQL%NOTFOUND THEN
                    NULL;
                    IF l_debug = 1 THEN
                       debug('Could not delete wms_shipping_transaction_temp  where delivery_id = ' || l_delivery_id);
                    END IF;
                 END IF ;
              END;
           END IF;


	END LOOP;
   END IF;

   -- Standard check of p_commit.
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (l_debug = 1) THEN debug('OUT ... DEL_WSTT_RECS_BY_DELIVERY_ID ' ); END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK  to DEL_WSTT_RECS_BY_DELIVERY_ID;
      fnd_msg_pub.count_and_get
	( p_encoded	=> FND_API.G_FALSE,
	  p_count 	=> x_msg_count,
	  p_data  	=> x_msg_data
	  );
      IF (l_debug = 1) THEN
         DEBUG('Error ! SQL Code : '||sqlcode);
      END IF;

   WHEN fnd_api.g_exc_unexpected_error  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK to DEL_WSTT_RECS_BY_DELIVERY_ID;
      fnd_msg_pub.count_and_get
	( p_encoded	=> FND_API.G_FALSE,
	  p_count 	=> x_msg_count,
	  p_data  	=> x_msg_data
	  );
      IF (l_debug = 1) THEN
         DEBUG('Unknown Error ! SQL Code : '||sqlcode);
      END IF;

   WHEN others  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DEL_WSTT_RECS_BY_DELIVERY_ID;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg
	   (  'WMS_SHIPPING_PUB',
	      'DEL_WSTT_RECS_BY_DELIVERY_ID'
	      );
      END IF;
      fnd_msg_pub.count_and_get
	( p_encoded	=> FND_API.G_FALSE,
	  p_count 	=> x_msg_count,
	  p_data  	=> x_msg_data
	  );
      IF (l_debug = 1) THEN
         DEBUG('Other Error ! SQL Code : '||sqlcode);
      END IF;

END DEL_WSTT_RECS_BY_DELIVERY_ID;

END WMS_SHIPPING_PUB;

/

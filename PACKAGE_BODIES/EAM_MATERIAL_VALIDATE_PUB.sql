--------------------------------------------------------
--  DDL for Package Body EAM_MATERIAL_VALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIAL_VALIDATE_PUB" AS
/* $Header: EAMPMTSB.pls 120.7.12010000.3 2009/09/25 00:52:16 mashah ship $ */


/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPMTSB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_MATERIAL_VALIDATE_PUB
--
--  NOTES
--
--  HISTORY
--
--  02-FEB-2005    Girish Rajan     Initial Creation
***************************************************************************/

/*******************************************************************
    * Procedure : Get_Open_Qty
    * Returns   : Number
    * Parameters IN : Required Quantity, Allocated Quantity, Issued Quantity
    * Parameters OUT NOCOPY: Open Quantity
    * Purpose   : Calculate Open Quantity and return 0 if open quantity < 0
    *********************************************************************/

FUNCTION Get_Open_Qty(p_required_quantity NUMBER, p_allocated_quantity NUMBER, p_issued_quantity NUMBER)
RETURN NUMBER
IS
	l_open_qty NUMBER := 0;
BEGIN
	l_open_qty := p_required_quantity - p_allocated_quantity - p_issued_quantity;
	IF (l_open_qty < 0 ) THEN
		RETURN 0;
	END IF;
	RETURN l_open_qty;
END Get_Open_Qty;


/*******************************************************************
    * Procedure : Check_Shortage
    * Returns   : None
    * Parameters IN : Wip Entity Id
    * Parameters OUT NOCOPY: x_shortage_exists flag = 'Y' means there is material shortage
    *                                               = 'N' means there is no material shortage
    * Purpose   : For any given work order, this wrapper API will
    *             determine whether there is material shortage
    *             or not and then update that field at the work order
    *             level. API will return whether shortage
    *             exists in p_shortage_exists parameter.
    *********************************************************************/

PROCEDURE Check_Shortage
         (p_api_version                 IN  NUMBER
        , p_init_msg_lst                IN  VARCHAR2 :=  FND_API.G_FALSE
        , p_commit	                IN  VARCHAR2 :=  FND_API.G_FALSE
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2
        , p_wip_entity_id		IN  NUMBER
	, p_source_api			IN  VARCHAR2 DEFAULT null
        , x_shortage_exists		OUT NOCOPY VARCHAR2
        )
IS
     CURSOR get_materials_csr(p_wip_entity_id NUMBER) IS
     SELECT wro.organization_id,
            wro.wip_entity_id,
	    SUM(Get_Open_Qty(NVL(wro.required_quantity,0) ,
	                     eam_material_allocqty_pkg.allocated_quantity(wro.wip_entity_id , wro.operation_seq_num,wro.organization_id,wro.inventory_item_id),
			     NVL(wro.quantity_issued,0))) open_quantity,
            REPLACE(mtlbkfv.concatenated_segments,'&','&amp;') inventory_item,
            wro.inventory_item_id,
            mtlbkfv.lot_control_code,
            mtlbkfv.serial_number_control_code,
            mtlbkfv.revision_qty_control_code
       FROM mtl_system_items_b_kfv mtlbkfv,
            wip_requirement_operations wro
      WHERE wro.inventory_item_id=mtlbkfv.inventory_item_id
        AND wro.organization_id = mtlbkfv.organization_id
        AND wro.wip_entity_id = p_wip_entity_id
        AND NVL(mtlbkfv.stock_enabled_flag,'N')='Y'
   GROUP BY  wro.organization_id,
            wro.wip_entity_id,
	    wro.inventory_item_id,
	    mtlbkfv.concatenated_segments,
            mtlbkfv.lot_control_code,
            mtlbkfv.serial_number_control_code,
            mtlbkfv.revision_qty_control_code;

     CURSOR get_direct_items_csr(p_wip_entity_id NUMBER) IS
     SELECT NVL(REPLACE(item_description,'&','&amp;'),REPLACE(description,'&','&amp;')) AS item_description,
	    SUM(Get_Open_Qty(required_quantity, quantity_received, 0)) open_quantity
       FROM eam_direct_item_recs_v
      WHERE wip_entity_id = p_wip_entity_id
      GROUP BY item_description, description;

     CURSOR wip_entity_name_csr(p_wip_entity_id NUMBER) IS
     SELECT wip_entity_name
       FROM wip_entities
      WHERE wip_entity_id = p_wip_entity_id;

     CURSOR get_yes_no(p_lookup_code NUMBER) IS
     SELECT meaning
       FROM mfg_lookups
      WHERE lookup_type = 'EAM_YES_NO'
        AND lookup_code = p_lookup_code
	AND enabled_flag = 'Y'
	AND (start_date_active is NULL OR sysdate >= start_date_active)
	AND (end_date_active is NULL OR sysdate <= end_date_active);

     CURSOR get_asset_number(p_wip_entity_id NUMBER) IS
     SELECT instance_number
       FROM csi_item_instances cii, wip_discrete_jobs wdj
      WHERE decode(wdj.maintenance_object_type,3, wdj.maintenance_object_id,NULL) = cii.instance_id(+)
        AND wdj.wip_entity_id = p_wip_entity_id;

     l_is_revision_control      BOOLEAN;
     l_is_lot_control           BOOLEAN;
     l_is_serial_control        BOOLEAN;
     x_qoh                      NUMBER;
     x_rqoh                     NUMBER;
     x_qr                       NUMBER;
     x_qs                       NUMBER;
     x_att                      NUMBER;
     x_atr                      NUMBER;
     x_work_order_printed       BOOLEAN :=FALSE;
     x_tree_id			NUMBER;
     l_asset_sub_only		BOOLEAN;
     l_api_version CONSTANT     NUMBER:=1;
     l_api_name                 VARCHAR2(100);
     l_unexpected_excep		EXCEPTION;
     l_wip_entity_name		wip_entities.wip_entity_name%TYPE;
     l_asset_number		csi_item_instances.instance_number%TYPE;
     l_yes_no			mfg_lookups.meaning%TYPE;
BEGIN
	l_asset_sub_only      := FALSE;
        l_api_name            :='Check_Shortage';

	-- Standard Start of API savepoint
	SAVEPOINT Check_Shortage_Start;

        IF NOT FND_API.Compatible_API_Call (l_api_version
                                            ,p_api_version
                                            ,l_api_name
                                            ,G_PKG_NAME)
        THEN
                x_return_status := FND_API.g_ret_sts_unexp_error;
                RAISE l_unexpected_excep;
        END IF;

        -- Check p_init_msg_list
        IF FND_API.to_Boolean( p_init_msg_lst ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_shortage_exists := 'N';

	OPEN wip_entity_name_csr(p_wip_entity_id);
	FETCH wip_entity_name_csr INTO l_wip_entity_name;
	CLOSE wip_entity_name_csr;

	OPEN get_asset_number(p_wip_entity_id);
	FETCH get_asset_number INTO l_asset_number;
	CLOSE get_asset_number;


        FOR p_materials_csr IN get_materials_csr(p_wip_entity_id)
        LOOP
		x_att := 0;

		IF (p_source_api = 'Concurrent') THEN
			fnd_message.set_name('EAM','EAM_PROCESS_MATERIAL');
			fnd_message.set_token('INVENTORY_ITEM',p_materials_csr.inventory_item,TRUE);
			fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
		END IF;
                IF (p_materials_csr.revision_qty_control_code = 2) THEN
                        l_is_revision_control:=TRUE;
                ELSE
                        l_is_revision_control:=FALSE;
                END IF;
                IF (p_materials_csr.lot_control_code = 2) THEN
                        l_is_lot_control:=TRUE;
                ELSE
                        l_is_lot_control:=FALSE;
                END IF;
                IF (p_materials_csr.serial_number_control_code = 1) THEN
                        l_is_serial_control:=FALSE;
                ELSE
                        l_is_serial_control:=TRUE;
                END IF;

                IF (p_materials_csr.open_quantity > 0 ) THEN
			Inv_Quantity_Tree_Grp.create_tree( p_api_version_number => p_api_version
			   , p_init_msg_lst => p_init_msg_lst
			   , x_return_status => x_return_status
			   , x_msg_count => x_msg_count
			   , x_msg_data => x_msg_data
			   , p_organization_id => p_materials_csr.organization_id
			   , p_inventory_item_id => p_materials_csr.inventory_item_id
			   , p_tree_mode => 2 -- available to transact
			   , p_is_revision_control => l_is_revision_control
			   , p_is_lot_control => l_is_lot_control
			   , p_is_serial_control => l_is_serial_control
			   , p_asset_sub_only => l_asset_sub_only
			   , x_tree_id => x_tree_id);

			   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE l_unexpected_excep;
			   END IF;

			Inv_Quantity_Tree_Grp.query_tree
			  (  p_api_version_number => p_api_version
			   , p_init_msg_lst => p_init_msg_lst
			   , x_return_status => x_return_status
			   , x_msg_count => x_msg_count
			   , x_msg_data => x_msg_data
			   , p_tree_id => x_tree_id
			   , p_revision => null
			   , p_lot_number => null
			   , p_subinventory_code => null
			   , p_locator_id => null
			   , x_qoh => x_qoh
			   , x_rqoh => x_rqoh
			   , x_qr => x_qr
			   , x_qs => x_qs
			   , x_att => x_att
			   , x_atr => x_atr
			   , p_transfer_subinventory_code => null
			   );

			   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				RAISE l_unexpected_excep;
			   END IF;

	 	   END IF;
		   IF (p_materials_csr.open_quantity > x_att ) THEN
			-- The update statement will be replaced by call to Work Order API
			-- Waiting for necessary changed in Work Order API to be done
			UPDATE eam_work_order_details
			   SET material_shortage_flag = 1,
			       material_shortage_check_date = sysdate,
			       last_update_date  = sysdate,
			       last_updated_by   = fnd_global.user_id,
			       last_update_login = fnd_global.login_id
			WHERE wip_entity_id = p_wip_entity_id;
 			x_shortage_exists := 'Y';

		        IF (p_source_api = 'Concurrent') THEN
				OPEN get_yes_no(1);
				FETCH get_yes_no INTO l_yes_no;
				CLOSE get_yes_no;

        		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<G_WORK_ORDER>');
                IF (x_work_order_printed = FALSE) THEN
            		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<WORK_ORDER>' || l_wip_entity_name || '</WORK_ORDER>');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ASSET_NUMBER>' || l_asset_number || '</ASSET_NUMBER>');
                    fnd_file.put_line(FND_FILE.OUTPUT, '<SHORTAGE_STATUS>' || l_yes_no|| '</SHORTAGE_STATUS>' );
                    x_work_order_printed :=TRUE;
                END IF;
        		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<MATERIAL>' || p_materials_csr.inventory_item || '</MATERIAL>');
        		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<QUANTITY>' || to_char(p_materials_csr.open_quantity - x_att )|| '</QUANTITY>');
        		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');

   		        ELSE
				IF FND_API.To_Boolean( p_commit ) THEN
					COMMIT;
		 		END IF;
				RETURN;
			END IF;
		   END IF;
        END LOOP;



	FOR p_direct_items_csr IN get_direct_items_csr(p_wip_entity_id)
	LOOP
		IF (p_source_api = 'Concurrent') THEN
			fnd_message.set_name('EAM','EAM_PROCESS_MATERIAL');
			fnd_message.set_token('INVENTORY_ITEM',p_direct_items_csr.item_description,TRUE);
			fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
		END IF;

		IF (p_direct_items_csr.open_quantity > 0 ) THEN

			-- The update statement will be replaced by call to Work Order API
			-- Waiting for necessary changed in Work Order API to be done
			UPDATE eam_work_order_details
			   SET material_shortage_flag = 1,
			       material_shortage_check_date = sysdate,
			       last_update_date  = sysdate,
			       last_updated_by   = fnd_global.user_id,
			       last_update_login = fnd_global.login_id
			 WHERE wip_entity_id = p_wip_entity_id;
			x_shortage_exists := 'Y';

		        IF (p_source_api = 'Concurrent') THEN
				OPEN get_yes_no(1);
				FETCH get_yes_no INTO l_yes_no;
				CLOSE get_yes_no;

            		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<G_WORK_ORDER>');

                    IF (x_work_order_printed = FALSE) THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<WORK_ORDER>' || l_wip_entity_name || '</WORK_ORDER>');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ASSET_NUMBER>' || l_asset_number || '</ASSET_NUMBER>');
                        fnd_file.put_line(FND_FILE.OUTPUT, '<SHORTAGE_STATUS>' || l_yes_no|| '</SHORTAGE_STATUS>' );
                        x_work_order_printed := TRUE;
                    END IF;

                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<MATERIAL>' || p_direct_items_csr.item_description || '</MATERIAL>');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<QUANTITY>' || p_direct_items_csr.open_quantity || '</QUANTITY>');
            		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');

			ELSE
				IF FND_API.To_Boolean( p_commit ) THEN
					COMMIT;
		 		END IF;
				RETURN;
			END IF;
		END IF;
	END LOOP;

	IF (x_shortage_exists = 'N') THEN
     IF (p_source_api = 'Concurrent') THEN --fix for 8840976
		     OPEN get_yes_no(2);
		     FETCH get_yes_no INTO l_yes_no;
		     CLOSE get_yes_no;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<G_WORK_ORDER>');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<WORK_ORDER>' || l_wip_entity_name || '</WORK_ORDER>');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ASSET_NUMBER>' || l_asset_number || '</ASSET_NUMBER>');
        fnd_file.put_line(FND_FILE.OUTPUT, '<SHORTAGE_STATUS>' || l_yes_no||'</SHORTAGE_STATUS>' );
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');
    END IF;
		UPDATE eam_work_order_details
		   SET material_shortage_flag = 2,
		       material_shortage_check_date = sysdate,
		       last_update_date  = sysdate,
		       last_updated_by   = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		 WHERE wip_entity_id = p_wip_entity_id;
	END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT;
	END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Check_Shortage_Start;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
		x_return_status := FND_API.G_RET_STS_ERROR ;

		IF (p_source_api = 'Concurrent') THEN
			fnd_file.put_line(FND_FILE.LOG,x_msg_data);
--			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<X_MSG_DATA>' || x_msg_data || '</X_MSG_DATA>');
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');
		END IF;
		x_shortage_exists := 'E';
		UPDATE eam_work_order_details
		   SET material_shortage_flag = null,
		       material_shortage_check_date = sysdate,
		       last_update_date  = sysdate,
		       last_updated_by   = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		 WHERE wip_entity_id = p_wip_entity_id;
		IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT;
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Check_Shortage_Start;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
		IF (p_source_api = 'Concurrent') THEN
			fnd_file.put_line(FND_FILE.LOG,x_msg_data);
--			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<X_MSG_DATA>' || x_msg_data || '</X_MSG_DATA>');
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');
		END IF;
		x_shortage_exists := 'E';
		UPDATE eam_work_order_details
		   SET material_shortage_flag = null,
		       material_shortage_check_date = sysdate,
		       last_update_date  = sysdate,
		       last_updated_by   = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		 WHERE wip_entity_id = p_wip_entity_id;
		IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT;
		END IF;
	WHEN OTHERS THEN
		ROLLBACK TO Check_Shortage_Start;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		 l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
		IF (p_source_api = 'Concurrent') THEN
			fnd_file.put_line(FND_FILE.LOG,x_msg_data);
--			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<X_MSG_DATA>' || x_msg_data || '</X_MSG_DATA>');
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</G_WORK_ORDER>');
		END IF;
		x_shortage_exists := 'E';
		UPDATE eam_work_order_details
		   SET material_shortage_flag = null,
		       material_shortage_check_date = sysdate,
		       last_update_date  = sysdate,
		       last_updated_by   = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		 WHERE wip_entity_id = p_wip_entity_id;
		IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT;
		END IF;
END Check_Shortage;

END EAM_MATERIAL_VALIDATE_PUB;

/

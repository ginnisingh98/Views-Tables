--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_MOVE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_MOVE_PUB" 
 /* $Header: EAMPAMTB.pls 120.15.12010000.13 2009/10/28 10:58:22 somitra ship $ */
AS

g_pkg_name CONSTANT VARCHAR2(30):= 'EAM_ASSET_MOVE_PUB';

PROCEDURE prepareMoveAsset
        (
	x_return_status OUT NOCOPY  VARCHAR2 ,
	x_return_message OUT NOCOPY VARCHAR2 ,
	p_parent_instance_id IN     NUMBER ,
	p_dest_org_id        IN     NUMBER ,
	p_includeChild       IN     VARCHAR2 ,
	p_move_type          IN     NUMBER ,
	p_curr_org_id        IN     NUMBER ,
	p_curr_subinv_code   IN     VARCHAR2 ,
	p_shipment_no        IN     VARCHAR2 ,
	p_dest_subinv_code   IN     VARCHAR2 ,
	p_context            IN     VARCHAR2,
	p_dest_locator_id    IN   NUMBER  :=NULL
	)
           IS
        l_parent_instance_id NUMBER;
        l_asset_count        NUMBER;
        l_header_id          NUMBER;
        l_curr_org_id        NUMBER;
        l_asset_move_hierarchy_tbl asset_move_hierarchy_tbl_type;
        l_return_status            VARCHAR2(240);
        l_return_message           VARCHAR2(240);
        l_Parent_inventory_item_id NUMBER ;
        l_openperiod_flag          BOOLEAN;
        l_openperiod_message       VARCHAR2(240);
        l_prepare_count            NUMBER ;
        l_move_txn_type_id NUMBER;
        l_intransit_type NUMBER; -- Transaction Type Id for Inventory Transaction

        --logging variables
        l_api_name  constant VARCHAR2(30) := 'prepareMoveAsset';
        l_module    VARCHAR2(200);
        l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
        l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
        l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
        l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
	l_eam_asset_move_count NUMBER;
	--locator variables
	x_locator_error_flag  NUMBER;
	x_locator_error_messg   VARCHAR2(240);
        --loop variables
	l_counter_for_validation     NUMBER  :=1;

BEGIN
        IF(p_dest_subinv_code is NULL) THEN
	    x_return_status:='DS';
	    RETURN;
	END IF;

	SELECT  inventory_item_id
	INTO    l_Parent_inventory_item_id
	FROM    CSI_ITEM_INSTANCES
	WHERE   instance_id=p_parent_instance_id ;

        IF (l_ulog) THEN
            l_module := 'eam.plsql.'|| l_full_name;
        END IF;

	IF (l_plog) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
        END IF;


	DELETE FROM EAM_ASSET_MOVE_TEMP;

	if (l_slog) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Going to get the asset Hierarchy ');
	end if;

        getAssetHierarchy( p_parent_instance_id,
			   p_includeChild,
			   l_asset_move_hierarchy_tbl,
			   p_curr_org_id );

	if (l_slog) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Completed getting the asset Hierarchy ');
	end if;

	IF (p_move_type <> 1) THEN
	IF(NOT(EAM_ASSET_MOVE_UTIL.isItemAssigned(l_Parent_inventory_item_id
						 ,p_dest_org_id))) THEN
	--validation to check whether item is assigned for the destination_org or not.applicable only in case of inter-org transfers
		x_return_status:='A';
		x_return_message:='EAM_ITEM_NOT_ASSIGN';
		RETURN ;
	END IF;
	END IF;

        FOR i IN l_asset_move_hierarchy_tbl.FIRST .. l_asset_move_hierarchy_tbl.LAST
        LOOP		--should be done only for second to last rows.
			--maint validation should not be done for first asset
			--hence isItemAssigned validation for the first asset should be done from Controller Class itself
			--bug 6966482
        if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
            'Processing asset ' || l_asset_move_hierarchy_tbl(i).instance_id );
        end if;

            eam_asset_move_util.isValidAssetMove( l_asset_move_hierarchy_tbl(i)
						 ,p_dest_org_id
						 ,l_counter_for_validation
						 ,l_return_status
						 ,l_return_message );

	    l_asset_move_hierarchy_tbl(i).prepare_status := l_return_status;
            l_asset_move_hierarchy_tbl(i).prepare_msg    := l_return_message;
	    l_counter_for_validation:=l_counter_for_validation+1;
        END LOOP;

	 -- Generate an Header id from the sequence
        SELECT  APPS.mtl_material_transactions_s.NEXTVAL
        INTO l_header_id FROM sys.dual;

	if (l_slog) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Going to populate the temp ');
	end if;

            populateTemp(l_header_id
	                ,l_asset_move_hierarchy_tbl
		        ,p_parent_instance_id );

	if (l_slog) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Completed populating the temp ');
	end if;

	IF (p_move_type = 1) THEN -- SubInv Transfer
                l_move_txn_type_id := 2;
        ELSE
              BEGIN
				if (l_slog) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
				'Selecting the intrasit type from mtl_shipping_network ');
				end if;
	      SELECT  intransit_type INTO l_intransit_type
              FROM    MTL_SHIPPING_NETWORK_VIEW   WHERE
              FROM_organization_id = p_curr_org_id
              AND to_organization_id = p_dest_org_id;

	      exception
			when no_data_found then
				raise no_data_found;
	      end;

              IF l_intransit_type = 1  -- Direct Inter Org Transfer
                THEN  l_move_txn_type_id := 3;
              ELSE      l_move_txn_type_id := 21; -- In-Transit Inter Org Transfer
              END IF;
        END IF;
	SELECT Count(*) INTO l_eam_asset_move_count
	FROM EAM_ASSET_MOVE_TEMP;
				if (l_slog) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
				'The l_eam_asset_move_count is : '||l_eam_asset_move_count);
				end if;

        SELECT Count(*) INTO l_prepare_count
	FROM EAM_ASSET_MOVE_TEMP
	WHERE PREPARE_STATUS = 'N';
				if (l_slog) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
				'The l_prepare_count is : '||l_prepare_count);
				end if;
        IF(l_prepare_count = 0 OR p_context = 'M') THEN   -- If Transaction has to happen (User Clicked Apply after Validation Messages are displayed

	   addAssetsToInterface( l_header_id,
				 l_parent_inventory_item_id,
				 p_curr_org_id,
				 p_curr_subinv_code,
				 p_dest_org_id,
				 p_dest_subinv_code,
				 l_move_txn_type_id,
				 p_shipment_no,
				 p_dest_locator_id,
				 x_locator_error_flag,
				 x_locator_error_messg);

              IF x_locator_error_flag =1  THEN
                  IF x_locator_error_messg='EAM_RET_MAT_LOCATOR_NEEDED' THEN
                    x_return_status:='L';
                   ELSIF x_locator_error_messg= 'EAM_RET_MAT_LOCATOR_RESTRICTED' THEN
                    x_return_status:='R';
		   ELSIF x_locator_error_messg='EAM_INT_LOCATOR_NEEDED' THEN
		    x_return_status:='IL';
                   ELSIF x_locator_error_messg='EAM_INT_LOCATOR_RESTRICTED' THEN
		    x_return_status:='IR';
		   ELSIF x_locator_error_messg='EAM_INT_SUBINVENTORY_NEEDED' THEN
		    x_return_status:='IS';
                  END IF;
                RETURN;
              END IF;
	   processAssetMoveTxn(l_header_id, x_return_status , x_return_message );
                --Dbms_Output.put_line('x_return_status is:  '||x_return_status);
        ELSE
            x_return_status:='P';
            x_return_message:='EAM_ASSET_MOVE_PREPARE_WARN';
            --Dbms_Output.put_line('x_return_status is:  '||x_return_status);
            RETURN ;
        END IF;

    COMMIT;

END prepareMoveAsset;

PROCEDURE getAssetHierarchy
        (
         p_parent_instance_id IN NUMBER,
         p_includeChild       IN VARCHAR2,
         x_asset_move_hierarchy_tbl OUT NOCOPY asset_move_hierarchy_tbl_type,
         p_curr_org_id IN NUMBER
	 )
          IS
        l_parent_inf_rec eam_asset_move_pub.asset_move_hierarchy_REC_TYPE;
        --logging variables
        l_api_name         constant VARCHAR2(30) := 'getAssetHierarchy';
        l_module           VARCHAR2(200);
        l_log_level        CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
        l_uLog             CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
        l_pLog             CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
        l_sLog             CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
        l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_cursor_count     NUMBER                :=1;
        l_parent_object_id NUMBER;
        CURSOR PARENT_ASSET_HIERARCHY_CUR(p_parent_instance_id IN NUMBER,p_current_org_id IN NUMBER)
                                                               IS
        SELECT  cii.instance_id            ,
                 cii.serial_number          ,
                 msn.gen_object_id          ,
                 cii.inventory_item_id      ,
                 msn.CURRENT_ORGANIZATION_ID,
                 cii.INV_SUBINVENTORY_NAME  ,
                 cii.maintainable_flag      ,
                 msi.eam_item_type          ,
                 mp.MAINT_ORGANIZATION_ID
         FROM    mtl_serial_numbers msn  ,
                 mtl_object_genealogy mog,
                 mtl_system_items_b msi  ,
                 csi_item_instances cii  ,
                 mtl_parameters mp
         WHERE   mog.object_id                          = msn.gen_object_id
             AND msn.current_organization_id            = msi.organization_id
             --AND msn.current_organization_id            = p_current_org_id
             AND msi.inventory_item_id                  = msn.inventory_item_id
             AND msi.eam_item_type                     IN (1,3)
             AND msn.inventory_item_id                  = cii.inventory_item_id
             AND msn.serial_number                      = cii.serial_number
             AND NVL(cii.active_start_date, sysdate-1) <= sysdate
             AND NVL(cii.active_end_date, sysdate  +1) >= sysdate
             AND msn.current_organization_id            = mp.organization_id
             AND mp.organization_id                     = cii.last_vld_organization_id
             AND sysdate                               >= NVL(mog.start_date_active(+), sysdate)
             AND sysdate                               <= NVL(mog.end_date_active(+), sysdate) START
         WITH mog.parent_object_id                      = l_parent_object_id CONNECT BY prior mog.object_id = mog.parent_object_id ;
								-- Parametrized cursor along with the serial                                                       number information with parent_instance and                                                      org_id as parameters

BEGIN
        --dbms_output.put_line('started getting the asset hierarchy..................');
			IF (l_ulog) THEN
				l_module := 'eam.plsql.'|| l_full_name;
			END IF;
			IF (l_plog) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
			END IF;

	/*if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'getting the asset hierarchy of' || l_asset_move_hierarchy_tbl(i).instance_id );                  --%%%SAVEPOINT LOOP_START;
        END IF;  */

	BEGIN
          SELECT  msn.GEN_OBJECT_ID
            INTO    l_parent_object_id
            FROM    mtl_serial_numbers msn,
                   csi_item_instances cii
            WHERE   cii.instance_id  =p_parent_instance_id
            AND cii.serial_number=msn.serial_number
	    AND cii.inventory_item_id=msn.inventory_item_id; --Added for 6955393
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
            SELECT  0
            INTO    l_parent_object_id
            FROM    dual;

			if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
			'Exception while searching for parent object id' );
		        END IF;
				-- dbms_output.put_line('Exception while searching for parent object id');
        END;
				--dbms_output.put_line('l_parent_object_id is'||l_parent_object_id);

			if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
			'l_parent_object_id is' || l_parent_object_id );
			 END IF;   --Commented for 6955393

        SELECT  cii.instance_id           ,
                cii.serial_number         ,
                msn.gen_object_id         ,
                cii.inventory_item_id     ,
                nvl(cii.inv_organization_id, cii.last_vld_organization_id),
                cii.INV_SUBINVENTORY_NAME ,
                cii.maintainable_flag     ,
                msi.eam_item_type         ,
                mp.MAINT_ORGANIZATION_ID  ,
                NULL                      ,
                NULL
        INTO    l_parent_inf_rec
        FROM    CSI_ITEM_INSTANCES cii,
                MTL_PARAMETERS mp     ,
                MTL_SERIAL_NUMBERS msn,
                MTL_SYSTEM_ITEMS_B msi
        WHERE   cii.instance_id             =p_parent_instance_id
            AND cii.SERIAL_NUMBER           = msn.SERIAL_NUMBER
            AND mp.organization_id          =cii.last_vld_organization_id
            AND msn.current_organization_id = msi.organization_id
            AND msi.inventory_item_id       = msn.inventory_item_id
	    AND msn.inventory_item_id     =cii.inventory_item_id  --6955393
            AND msi.eam_item_type          IN (1,3);
         -- AND  cii.INV_MASTER_ORGANIZATION_ID = msn.CURRENT_ORGANIZATION_ID
         --AND cii.INVENTORY_ITEM_ID = msn.INVENTORY_ITEM_ID
        x_asset_move_hierarchy_tbl(0).instance_id               := l_parent_inf_rec.instance_id;
        x_asset_move_hierarchy_tbl(0).serial_number             := l_parent_inf_rec.serial_number;
        x_asset_move_hierarchy_tbl(0).gen_object_id             := l_parent_inf_rec.gen_object_id;
        x_asset_move_hierarchy_tbl(0).inventory_item_id         := l_parent_inf_rec.inventory_item_id;
        x_asset_move_hierarchy_tbl(0).current_org_id            := l_parent_inf_rec.current_org_id;
        x_asset_move_hierarchy_tbl(0).current_subinventory_code :=l_parent_inf_rec.current_subinventory_code;
        x_asset_move_hierarchy_tbl(0).maintainable_flag         :=l_parent_inf_rec.maintainable_flag;
        x_asset_move_hierarchy_tbl(0).eam_item_type             := l_parent_inf_rec.eam_item_type;
        x_asset_move_hierarchy_tbl(0).maint_org_id              := l_parent_inf_rec.maint_org_id;
        --populating the values of the parent instance id into the asset_hierarchy_table

	IF(p_includeChild='Y') THEN

			if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
			'including the child assets' );
			END IF;
		--dbms_output.put_line('including the child assets');

		FOR PARENT_ASSET_HIERARCHY_REC IN PARENT_ASSET_HIERARCHY_CUR(p_parent_instance_id,p_curr_org_id)
                LOOP
                        EXIT WHEN PARENT_ASSET_HIERARCHY_CUR%NOTFOUND;
                        x_asset_move_hierarchy_tbl(l_cursor_count).instance_id               := PARENT_ASSET_HIERARCHY_REC.instance_id;
                        x_asset_move_hierarchy_tbl(l_cursor_count).serial_number             := PARENT_ASSET_HIERARCHY_REC.serial_number;
                        x_asset_move_hierarchy_tbl(l_cursor_count).gen_object_id             := PARENT_ASSET_HIERARCHY_REC.gen_object_id;
                        x_asset_move_hierarchy_tbl(l_cursor_count).inventory_item_id         := PARENT_ASSET_HIERARCHY_REC.inventory_item_id;
                        x_asset_move_hierarchy_tbl(l_cursor_count).current_org_id            := PARENT_ASSET_HIERARCHY_REC.current_organization_id;
                        x_asset_move_hierarchy_tbl(l_cursor_count).current_subinventory_code :=PARENT_ASSET_HIERARCHY_REC.INV_SUBINVENTORY_NAME;
                        x_asset_move_hierarchy_tbl(l_cursor_count).maintainable_flag         :=PARENT_ASSET_HIERARCHY_REC.maintainable_flag;
                        x_asset_move_hierarchy_tbl(l_cursor_count).eam_item_type             := PARENT_ASSET_HIERARCHY_REC.eam_item_type;
                        x_asset_move_hierarchy_tbl(l_cursor_count).maint_org_id              := PARENT_ASSET_HIERARCHY_REC.MAINT_ORGANIZATION_ID;
                        -- Dbms_Output.put_line('x_asset_move_hierarchy_tbl(l_cursor_count).instance_id is'||x_asset_move_hierarchy_tbl(l_cursor_count).instance_id);
                        -- dbms_output.put_line('x_asset_move_hierarchy_tbl(0).instance_id is '||x_asset_move_hierarchy_tbl(l_cursor_count).instance_id);
                        --dbms_output.put_line('x_asset_move_hierarchy_tbl(0).current_subinventory_code is '||x_asset_move_hierarchy_tbl(l_cursor_count).current_subinventory_code);
                       l_cursor_count:=l_cursor_count+1;
                END LOOP ;
        END IF;
			if (l_slog) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'exiting the getassethierarchy' );
			END IF;
			 --dbms_output.put_line('exiting the getassethierarchy..................');
END getAssetHierarchy ;
PROCEDURE populateTemp
        (
          p_header_id                IN NUMBER,
          p_asset_move_hierarchy_tbl IN asset_move_hierarchy_tbl_type,
          p_parent_instance_id       IN NUMBER
	  )
            IS
        l_parent_object_id NUMBER; --required for verification of parent assets of each child asset
        l_parent_status    VARCHAR2(2);
        l_parent_msg   VARCHAR2(240);
	l_intermediate_subinventory VARCHAR2(20);
		--logging variables
        l_api_name         constant VARCHAR2(30) := 'populateTemp';
        l_module           VARCHAR2(200);
        l_log_level        CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
        l_uLog             CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
        l_pLog             CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
        l_sLog             CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
        l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        CURSOR child_parent_cur
        IS
                SELECT  *
                FROM    EAM_ASSET_MOVE_TEMP FOR UPDATE OF PREPARE_STATUS,
                        PREPARE_MSG;
BEGIN

	IF (l_ulog) THEN
                l_module := 'eam.plsql.'|| l_full_name;
        END IF;

        IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
        END IF;

	IF (l_slog) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Started populating the temp' );
	END IF;

	--dbms_output.put_line('Populating Temp');
        FOR i IN p_asset_move_hierarchy_tbl.FIRST .. p_asset_move_hierarchy_tbl.LAST
        LOOP
	BEGIN
		SELECT INTERMEDIATE_SUBINVENTORY
		INTO l_intermediate_subinventory FROM WIP_EAM_PARAMETERS
		WHERE ORGANIZATION_ID = p_asset_move_hierarchy_tbl(i).maint_org_id ;

		INSERT
                INTO    EAM_ASSET_MOVE_TEMP
                        (
                                INSTANCE_ID              ,
                                SERIAL_NUMBER            ,
                                GEN_OBJECT_ID            ,
                                INVENTORY_ITEM_ID        ,
                                CURRENT_ORG_ID           ,
                                CURRENT_SUBINVENTORY_CODE,
                                EAM_ITEM_TYPE            ,
                                MAINT_ORG_ID             ,
                                PREPARE_STATUS           ,
                                PREPARE_MSG              ,
                                TRANSACTION_HEADER_ID
                        )
                        VALUES
                        (
                                p_asset_move_hierarchy_tbl(i).instance_id              ,
                                p_asset_move_hierarchy_tbl(i).serial_number            ,
                                p_asset_move_hierarchy_tbl(i).gen_object_id            ,
                                p_asset_move_hierarchy_tbl(i).inventory_item_id        ,
                                p_asset_move_hierarchy_tbl(i).current_org_id	       ,
                                NVL(p_asset_move_hierarchy_tbl(i).current_subinventory_code,l_intermediate_subinventory),
						/*for 7370638-AMWB-MR --intermediate_subinventory is the place where the
						Asset is recieved if the asset is not present any of the subinventory and
						from there asset is transferred to dest_subinv and/or dest-org.*/
                                NVL(p_asset_move_hierarchy_tbl(i).eam_item_type,1)     ,
                                p_asset_move_hierarchy_tbl(i).maint_org_id             ,
                                p_asset_move_hierarchy_tbl(i).prepare_status           ,
                                p_asset_move_hierarchy_tbl(i).prepare_msg              ,
                                p_header_id
                        );

	END;
        END LOOP;
        FOR child_parent_rec IN child_parent_cur
        LOOP
                EXIT
        WHEN child_parent_cur%NOTFOUND;
                IF
                        (
                                child_parent_rec.INSTANCE_ID<>p_parent_instance_id
                        )
                        THEN

		IF (l_slog) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'selecting the parent objectId for validating child asset'||child_parent_rec.INSTANCE_ID );
		END IF;


                        SELECT  parent_object_id
                        INTO    l_parent_object_id
                        FROM    mtl_object_genealogy
                        WHERE   object_id         =child_parent_rec.gen_object_id
			AND    START_DATE_ACTIVE<=SYSDATE
			AND Nvl(end_DATE_ACTIVE,SYSDATE+1)>=sysdate
			AND    PARENT_OBJECT_TYPE  = 2; --Added for the bug 7721062
							--can use the below statement as well for filtering out the records
							--AND parent_object_id IN (SELECT gen_object_id FROM mtl_serial_numbers)
		IF (l_slog) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'parent objectId for validating the child assest is '||l_parent_object_id);
		END IF;

		    BEGIN
                        SELECT  PREPARE_STATUS
                        INTO    l_parent_status
                        FROM    EAM_ASSET_MOVE_TEMP
                        WHERE   gen_object_id=l_parent_object_id;
		      EXCEPTION
			 WHEN NO_DATA_FOUND THEN
			 SELECT 'U' INTO  l_parent_status FROM dual;
			 IF (l_slog) then
			 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'No_data_found exception occured when checking for parent status');
			 END IF;
                     END;

                    BEGIN
                        SELECT  PREPARE_MSG
                        INTO    l_parent_msg
                        FROM    EAM_ASSET_MOVE_TEMP
                        WHERE   gen_object_id=l_parent_object_id;
                      EXCEPTION
			WHEN NO_DATA_FOUND THEN
			SELECT 'Unknown' INTO  l_parent_msg FROM dual;
			 IF (l_slog) then
			 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'No_data_found exception occured when checking for parent message');
			 END IF;
                     END;

                        IF(l_parent_status   ='N') THEN
                                UPDATE EAM_ASSET_MOVE_TEMP
                                SET     PREPARE_STATUS = 'N',
                                        PREPARE_MSG    ='EAM_PAR_ASSET_FAIL'
                                WHERE   CURRENT OF child_parent_cur;

			   	IF (l_slog) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'populated its parent status to this asset as it is not moving');
				END IF;

                        END IF;
                END IF;
        END LOOP;
        IF (l_slog) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Exiting the PopulateTemp' );
	END IF;
	-- dbms_output.put_line('End of Populating Temp');
END populateTemp;

PROCEDURE addAssetsToInterface
        (
                p_header_id                  IN NUMBER ,
                p_inventory_item_id          IN NUMBER ,
                p_CURRENT_ORGANIZATION_ID    IN NUMBER ,
                p_current_subinventory_code  IN VARCHAR2 ,
                p_transfer_organization_id   IN NUMBER ,
                p_transfer_subinventory_code IN VARCHAR2 ,
                p_transaction_type_id        IN NUMBER ,
                p_shipment_number            IN VARCHAR2 := NULL,
		p_transfer_locator_id        IN NUMBER   :=NULL,
                x_locator_error_flag  OUT NOCOPY NUMBER,
                x_locator_error_mssg  OUT NOCOPY VARCHAR2)
                                             IS
        l_EAM_ASSET_MOVE_REC EAM_ASSET_MOVE_TEMP%ROWTYPE ;
        l_txn_if_id     NUMBER;
        l_SERIAL_NUMBER VARCHAR2(30);
        l_Transaction_UOM mtl_system_items_b_kfv.primary_uom_code%type;
        l_serial_number_control_code mtl_system_items_b_kfv.serial_number_control_code%TYPE;
        l_Item_Revision CSI_ITEM_INSTANCES.INVENTORY_REVISION%TYPE;
        l_Transaction_Quantity NUMBER;
        x_Message              VARCHAR2(240);
        x_Status               VARCHAR2(30);
        l_lot_control_code     NUMBER;
        l_from_ser_number      VARCHAR2(30);
        l_to_ser_number        VARCHAR2(30);
        l_temp_header_id       NUMBER;
        l_current_subinventory_code	VARCHAR2(240);
        l_CURRENT_ORGANIZATION_ID NUMBER;
	l_inventory_item_id NUMBER;
	l_current_locator_id NUMBER;
	l_intransit_type_for_child NUMBER;
	l_transaction_type_id NUMBER;

        -- logging variables
        l_api_name  constant VARCHAR2(30) := 'addAssetsToInterface';
        l_module    VARCHAR2(200);
        l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
        l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
        l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
        l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
        l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
	l_quantity NUMBER;

	--locator control verification variables
	x_verif_locator_ctrl	       NUMBER ; -- Holds the Locator Control information
	x_verif_locator_error_flag     NUMBER;           -- returns 0 if no error , >1 if any error .
        x_verif_locator_error_mssg     VARCHAR2(200);

	--variables added for 7370638 (Enhancement on AMWB)
	l_misc_rec_asset_count   NUMBER;
	l_transaction_batch_id   NUMBER;
	l_intermediate_subinventory varchar2(10);
	l_intermediate_locator varchar2(20);
	l_intermediate_locator_id NUMBER;
	x_verif_loc_ctrl_for_MR	       NUMBER ;
	x_verif_loc_err_flag_for_MR     NUMBER;
	x_verif_loc_err_mssg_for_MR     VARCHAR2(200);
	l_asset_count_for_MR	NUMBER;
	l_maint_organization_id NUMBER;
	--variables added for 7370638 (Enhancement on AMWB)
	l_transfer_organization_id NUMBER;

	-- Define a cursor with all the entries from Temp Table whose move status is 'Y' and 'MR'
	CURSOR validAssets_cur
        IS
                SELECT  *
                FROM    EAM_ASSET_MOVE_TEMP
                WHERE   prepare_status        IN ('Y','MR')
                    AND TRANSACTION_HEADER_ID = p_header_id FOR UPDATE OF TRANSACTION_INTERFACE_ID;
BEGIN
				--Dbms_Output.put_line('adding assets to interface tables');
				-- Dbms_Output.put_line('p_header_id is '||p_header_id);
        IF (l_ulog) THEN
                l_module := 'eam.plsql.'|| l_full_name;
        END IF;
        IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Entering ' || l_full_name);
        END IF;

	IF (l_slog) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'p_header_id is '||p_header_id );
	END IF;
l_transfer_organization_id := p_transfer_organization_id;

/* Check for Locator Control which could be defined
   at 3 level Organization,Subinventory,Item .
*/--Similar to code from the package--eam_mtl_txn_process i.e., EAMMTTXB.pls

			--Dbms_Output.put_line('before entering Get_LocatorControl_Code');
 Get_LocatorControl_Code(
                      l_transfer_organization_id,
                      p_transfer_subinventory_code,
                      p_inventory_item_id,
                      32,--p_action in the proc
                      x_verif_locator_ctrl,
                      x_verif_locator_error_flag,
                      x_verif_locator_error_mssg);

			-- Dbms_Output.put_line('x_verif_locator_ctrl is '||x_verif_locator_ctrl);
			-- Dbms_Output.put_line('x_verif_locator_error_flag is'||x_verif_locator_error_flag );
			-- Dbms_Output.put_line('x_verif_locator_error_mssg is'||x_verif_locator_error_mssg)  ;

if(x_verif_locator_error_flag <> 0) THEN

 return;
end if;

-- if the locator control is Predefined or Dynamic Entry
if(x_verif_locator_ctrl = 2 or x_verif_locator_ctrl = 3) then
 if(p_transfer_locator_id IS NULL) then
   x_locator_error_flag := 1;
   x_locator_error_mssg := 'EAM_RET_MAT_LOCATOR_NEEDED';

   return;
 end if;
elsif(x_verif_locator_ctrl = 1) then -- If the locator control is NOControl
 if(p_transfer_locator_id IS NOT NULL) then
   x_locator_error_flag := 1;
   x_locator_error_mssg := 'EAM_RET_MAT_LOCATOR_RESTRICTED';

   return;
 end if;
end if; -- end of locator_control checkif for Asset Move Transfers



BEGIN
select MAINT_ORGANIZATION_ID  into l_maint_organization_id
from MTL_PARAMETERS
where ORGANIZATION_ID = P_CURRENT_ORGANIZATION_ID;
					--Added for the bug 7681240
select INTERMEDIATE_SUBINVENTORY into l_intermediate_subinventory
	from wip_eam_parameters
	where ORGANIZATION_ID = l_maint_organization_id;
EXCEPTION
     WHEN No_Data_Found THEN
       l_intermediate_subinventory := NULL;
   END;

 BEGIN
select INTERMEDIATE_LOCATOR into l_intermediate_locator
	from wip_eam_parameters
	where ORGANIZATION_ID = l_maint_organization_id;
  EXCEPTION
     WHEN No_Data_Found THEN
       l_intermediate_locator := NULL;
   END;
       BEGIN
     SELECT  inventory_location_id
       INTO  l_intermediate_locator_id
       FROM  mtl_item_locations_kfv
       WHERE concatenated_segments = l_intermediate_locator
         AND organization_id      = l_maint_organization_id;
   EXCEPTION
     WHEN No_Data_Found THEN
       l_intermediate_locator_id := NULL;
   END;



--Locator control check up for intermediate subinventories and intermediate locators For Misc Rec for 7370638

SELECT COUNT(*) into l_asset_count_for_MR FROM EAM_ASSET_MOVE_TEMP WHERE prepare_status LIKE 'MR';
						--count required to verify whether any assets that are ready for Misc Receipt

	if(l_asset_count_for_MR > 0) THEN
		if (l_intermediate_subinventory IS NULL) THEN
		x_locator_error_flag := 1;
                x_locator_error_mssg := 'EAM_INT_SUBINVENTORY_NEEDED';
		return;				--if the Intermediate subinventory in eAM parameters form
		END IF;				--is null..Error message is thrown for 7370638
/*Locator control verification for the intermediate subinventory,intermediate locator and Inventory Item combination */
		Get_LocatorControl_Code(
                      l_maint_organization_id,  --changed for the bug 7681240
                      l_intermediate_subinventory,
                      p_inventory_item_id,
                      32,--p_action in the proc
                       x_verif_loc_ctrl_for_MR,
                      x_verif_loc_err_flag_for_MR,
                      x_verif_loc_err_mssg_for_MR);


		if(x_verif_loc_err_flag_for_MR <> 0) THEN
		 return;
		end if;

		-- if the locator control is Predefined or Dynamic Entry
		if(x_verif_loc_ctrl_for_MR = 2 or x_verif_loc_ctrl_for_MR = 3) then
		 if(l_intermediate_locator IS NULL) then
		   x_locator_error_flag := 1;
		   x_locator_error_mssg := 'EAM_INT_LOCATOR_NEEDED';

		   return;
		 end if;
		elsif(x_verif_loc_ctrl_for_MR = 1) then -- If the locator control is NOControl
		 if(l_intermediate_locator IS NOT NULL) then
		   x_locator_error_flag := 1;
		   x_locator_error_mssg := 'EAM_INT_LOCATOR_RESTRICTED';

		   return;
		 end if;
		end if; -- end of locator_control checkif for Miscellanous Receipt
	end if;

	FOR validAssets_rec IN validAssets_cur
        LOOP
        EXIT WHEN validAssets_cur%NOTFOUND;
				-- get serial number from the cursor
           l_serial_number  :=validAssets_rec.serial_number;
           l_from_ser_number:=validAssets_rec.serial_number;
           l_to_ser_number  :=validAssets_rec.serial_number;
           l_CURRENT_ORGANIZATION_ID:=validAssets_rec.CURRENT_ORG_ID;
	   	   --make nvl(validAssets_rec.CURRENT_SUBINVENTORY_CODE,WIP_EAM_PARAMETERS.default_Subinventory) for the current SI

	   l_current_subinventory_code :=nvl(validAssets_rec.CURRENT_SUBINVENTORY_CODE,l_intermediate_subinventory);
	   l_transaction_type_id:=p_transaction_type_id;

	    BEGIN
	     select INV_LOCATOR_ID INTO l_current_locator_id
	     from csi_item_instances where INSTANCE_ID=validAssets_rec.instance_id;
	     EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_current_locator_id:=NULL;
            END;

	   IF(validAssets_rec.prepare_status='MR') then		--Call For Misc Receipt for 7370638
--for 7370638
	    SELECT  mtl_material_transactions_s.nextval
             INTO    l_transaction_batch_id
             FROM    dual;

	    addAssetsForMiscReceipt(p_header_id,
				    l_transaction_batch_id,
				    l_serial_number,
				    l_CURRENT_ORGANIZATION_ID,
				    validAssets_rec.inventory_item_id,
				    l_current_subinventory_code,
				    l_intermediate_locator_id--need to read the value from EAM-parameters
				     );

		IF (l_current_locator_id IS NULL) THEN
			l_current_locator_id := l_intermediate_locator_id;
	        END IF;
				-- Added for bug 7758197
	   END IF;						--End of call for misc rec

           BEGIN
              SELECT  primary_uom_code          ,
                      serial_number_control_code,
                      LOT_CONTROL_CODE
              INTO    l_Transaction_UOM           ,
                      l_serial_number_control_code,
                      l_lot_control_code
              FROM    mtl_system_items_b
              WHERE   inventory_item_id=p_inventory_item_id
              AND organization_id  =p_CURRENT_ORGANIZATION_ID;

	      EXCEPTION
                WHEN NO_DATA_FOUND THEN
				IF (l_plog) THEN
					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'UOM Code, Serial control code, Lot control code could not be derived in addAssetsToInterface.'|| l_full_name);
				END IF;
                       -- l_Transaction_UOM:='Ea';
					--Dbms_Output.put_line('ecxeption occured while selecting');
            END;
					--   SELECT INVENTORY_REVISION INTO   l_Item_Revision FROM CSI_ITEM_INSTANCES WHERE INVENTORY_ITEM_ID=p_inventory_item_id ;
             SELECT  mtl_material_transactions_s.nextval
             INTO    l_temp_header_id
             FROM    dual;
					--dbms_output.put_line('l_serial_number_control_code IS'||' '||l_serial_number_control_code);
             Begin
	      SELECT inventory_item_id INTO l_inventory_item_id
	      FROM csi_item_instances
	      WHERE instance_id = validAssets_rec.instance_id;
	     exception
			when no_data_found then
				raise no_data_found;
	     end;

	     INV_TRANSACTIONS.G_Header_ID    := p_header_id;
             INV_TRANSACTIONS.G_Interface_ID := l_temp_header_id;
             UPDATE EAM_ASSET_MOVE_TEMP
             SET     TRANSACTION_INTERFACE_ID = l_temp_header_id
             WHERE   CURRENT OF validAssets_cur;
             IF(l_serial_number_control_code <> 1) THEN
                     SELECT  mtl_material_transactions_s.nextval
                     INTO    INV_TRANSACTIONS.G_Serial_ID
                     FROM    dual;
             END IF;


					-- insert into MTI, MSNI
					 --dbms_output.put_line('header_id IS' ||INV_TRANSACTIONS.G_Header_ID);
            IF (l_slog) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Calling the procedure INV_TRANSACTIONS.LINE_INTERFACE_INSERT'  );
	    END IF;

	     IF(p_transaction_type_id=2) THEN --if subinventory transfer
               IF(p_CURRENT_ORGANIZATION_ID<>l_CURRENT_ORGANIZATION_ID)THEN
	       --source organisation_id  for parent asset and child asset are not equal
	       --that means In the case when the child asset is of some production_org and parent asset
	       --is in the maintenance org of that prod_org
	       --In this case the move type for parent asset is subinventory only but for the child asset becomes
	       --interorg type between the production org and maintenance org.
	       --the parent asset in one maint org and child asset in another maint org in a given hierarchy is
	       --however not supported in Asset Move Work Bench
		begin

		SELECT
		 intransit_type
		INTO
		 l_intransit_type_for_child
		FROM    MTL_SHIPPING_NETWORK_VIEW
		WHERE from_organization_id=l_CURRENT_ORGANIZATION_ID
		AND TO_ORGANIZATION_ID=p_CURRENT_ORGANIZATION_ID;

		exception
		   when no_data_found then
		     begin
		     raise no_data_found;   --needs to handle the exception since no shipping network is enbled
				            --between the production org and maint org
	             IF (l_slog) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Null Exception ocuured as no shipping network is enabled between organisation ids'||l_CURRENT_ORGANIZATION_ID||'AND'||p_CURRENT_ORGANIZATION_ID  );
		     END IF;
		     end;
		    end;

		IF(l_intransit_type_for_child=1) THEN -- Direct Inter Org Transfer
	         l_transaction_type_id:=3;
	        ELSE  l_transaction_type_id:=21;-- In-Transit Inter Org Transfer
	        END IF;

	     END IF;
	     END IF;

	     IF(l_transaction_type_id=3) THEN--for direct inter_org transfer the txn quantity is positve
	       l_quantity:=1;
	    ELSE l_quantity:=-1;
	    END IF;

	         IF(validAssets_rec.prepare_status='MR') THEN  --As the Asset is Recieved into Maintenance Org
							 --Making the Current Organisation as Maint Org
                    SELECT maint_organization_id  INTO l_CURRENT_ORGANIZATION_ID
		    FROM MTL_PARAMETERS
		    WHERE organization_id= l_CURRENT_ORGANIZATION_ID;

		    If(l_transfer_organization_id = l_CURRENT_ORGANIZATION_ID) then
			l_transfer_organization_id := NULL;
			l_transaction_type_id := 2;
		    END IF;
			--Added for the 7833252
	   END IF;

	     INV_TRANSACTIONS.LINE_INTERFACE_INSERT(
						l_inventory_item_id,
						NULL, --revision
						l_CURRENT_ORGANIZATION_ID,
						NULL,                    --  l_Transaction_Source_Id,
						NULL,	                 --  l_Transaction_action_Id,
						l_current_subinventory_code ,
						p_transfer_subinventory_code ,
						l_current_locator_id,--NULL,			 --l_From_Locator_Id,     can be null and cant be null
						p_transfer_locator_id,			 --l_To_Locator_Id,    from EAMMATTB.pls  as in eam_mtl_txn_process.PROCESSMTLTXN()
						l_transfer_organization_id,
						l_transaction_type_id,
						NULL,			 --l_Transaction_Source_Type_Id
						l_quantity,			 --1 (quantity default)
						l_Transaction_UOM,	 --from select query
						SYSDATE,
						NULL,			 --l_Reason_Id
						FND_GLOBAL.USER_ID,
						x_Message,
						x_Status
						);

--if transaction type is of interorg-intransit then we need to enter the shipment number into MTI table explicitly.

             IF(p_transaction_type_id=21) THEN
	     --code for entering the shipment values into MTI
	     UPDATE MTL_TRANSACTIONS_INTERFACE
		SET SHIPMENT_NUMBER=p_shipment_number where TRANSACTION_INTERFACE_ID=INV_TRANSACTIONS.G_Interface_ID
		AND TRANSACTION_HEADER_ID=INV_TRANSACTIONS.G_Header_ID;

	     END IF;

	IF(validAssets_rec.prepare_status='MR') THEN    --for --for 7370638 Batch seq to be 2 as the transfer is dependent on the Misc. receipt
	     UPDATE MTL_TRANSACTIONS_INTERFACE
		SET TRANSACTION_BATCH_ID = l_transaction_batch_id,
		    TRANSACTION_BATCH_SEQ = 2
		WHERE TRANSACTION_INTERFACE_ID=INV_TRANSACTIONS.G_Interface_ID
		AND TRANSACTION_HEADER_ID=INV_TRANSACTIONS.G_Header_ID;
	END IF;

             IF(l_serial_number_control_code <> 1
			AND l_from_ser_number IS NOT NULL
			AND l_to_ser_number IS NOT NULL AND
			l_serial_number_control_code IS NOT NULL) THEN
					--dbms_output.put_line('serial_id IS' ||INV_TRANSACTIONS.G_Serial_ID);
                   INV_TRANSACTIONS.SERIAL_INTERFACE_INSERT(
							l_from_ser_number ,
							l_to_ser_number ,
							FND_GLOBAL.USER_ID ,
							l_lot_control_code
							);
             END IF;
	     l_transfer_organization_id := p_transfer_organization_id;
        END LOOP;

	 IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
         END IF;

		--Dbms_Output.put_line('end of add assets to interface');
END addAssetsToInterface;

PROCEDURE processAssetMoveTxn
        (
         p_txn_header_id IN          NUMBER,
         x_return_status OUT NOCOPY  VARCHAR2,
         x_return_message OUT NOCOPY VARCHAR2
	 )
IS
         l_api_version            NUMBER ;
         l_init_msg_list          VARCHAR2(30);
         l_commit                 VARCHAR2(30);
         l_validation_level       NUMBER ;
         x_ret_status             VARCHAR2(240);
         x_mssg_count             NUMBER ;
         x_error_mssg             VARCHAR2(240);
         x_transs_count           NUMBER ;
         l_table                  NUMBER ;
         l_txn_count         NUMBER;
                                          --  x_process_txn_ret_status VARCHAR2(240);
                                          --logging variables
         l_api_name  constant VARCHAR2(30) := 'processAssetMoveTxn';
         l_module    VARCHAR2(200);
         l_log_level CONSTANT NUMBER             := fnd_log.g_current_runtime_level;
         l_uLog      CONSTANT BOOLEAN            := fnd_log.level_unexpected >= l_log_level;
         l_pLog      CONSTANT BOOLEAN            := l_uLog AND fnd_log.level_procedure >= l_log_level;
         l_sLog      CONSTANT BOOLEAN            := l_pLog AND fnd_log.level_statement >= l_log_level;
         l_full_name CONSTANT VARCHAR2(60)       := g_pkg_name || '.' || l_api_name;

	 CURSOR Txn_STAT_MMT_CUR(p_txn_header_id IN NUMBER) IS
           SELECT   MTI.TRANSACTION_HEADER_ID   ,
                    MTI.TRANSACTION_INTERFACE_ID,
                    MTI.ERROR_CODE              ,
                    MTI.ERROR_EXPLANATION
             FROM   MTL_TRANSACTIONS_INTERFACE MTI
             WHERE  MTI.TRANSACTION_HEADER_ID  = p_txn_header_id      ;

BEGIN
                                         --Dbms_Output.put_line('begining of processAssetMoveTxn');
        IF (l_ulog) THEN
                l_module := 'eam.plsql.'|| l_full_name;
        END IF;
        IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
        END IF;
                                          --Dbms_Output.put_line('Calling the INV transaction process API for the above txn_header_id');
                                          -- Call the INV transaction process API for the above txn_header_id
        l_txn_count := INV_TXN_MANAGER_PUB.process_Transactions
	 (
          p_api_version   => 1.0,
	  p_header_id     =>   p_txn_header_id,
	  p_table         => 1,             -- meant for process from MTI table.
          x_return_status => x_return_status,
          x_msg_count     => x_mssg_count,
          x_msg_data      => x_error_mssg,
          x_trans_count   => x_transs_count
          );
					   -- dbms_output.put_line('x_return_status: '||x_return_status); --status of whole txn
					   -- dbms_output.put_line(x_transs_count);  --no of moves gone for
					   -- dbms_output.put_line('l_txn_count: '||l_txn_count);   --number of moves successful
					   -- dbms_output.put_line(x_error_mssg);    --error message

          IF(x_return_status IS NULL) THEN
             x_return_status:='N';
             x_return_message:=x_return_message;
          END IF;
					   --dbms_output.put_line('x_return_status: '||x_return_status);


                                           -- Get the Transaction Status from the respective tables
					   -- Update the Temporary Table with the transaction status
					   --*******************important part**********************************
					   -- dbms_output.put_line('updating EAM_ASSET_MOVE_TEMP after');
        FOR Txn_STAT_MTT_REC IN Txn_STAT_MMT_CUR(p_txn_header_id) LOOP
           EXIT WHEN Txn_STAT_MMT_CUR%NOTFOUND;
           UPDATE  EAM_ASSET_MOVE_TEMP
           SET     TRANSACTION_STATUS      ='Failed',--NVL(Txn_STAT_MTT_REC.ERROR_CODE,'YES'),
                   TRANSACTION_MSG         =Txn_STAT_MTT_REC.ERROR_EXPLANATION
           WHERE   TRANSACTION_INTERFACE_ID = Txn_STAT_MTT_REC.TRANSACTION_INTERFACE_ID;
					   -- AND instance_id = p_instance_id;
        END LOOP;
        COMMIT ;

	 IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
        END IF;

	IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || g_pkg_name);
        END IF;

END processAssetMoveTxn;
Procedure Get_LocatorControl_Code(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER,
                          x_locator_ctrl     OUT NOCOPY NUMBER,
                          x_error_flag       OUT NOCOPY NUMBER, -- returns 0 if no error ,1 if any error .
                          x_error_mssg       OUT NOCOPY VARCHAR2
) IS
x_org_ctrl      NUMBER;
x_sub_ctrl      NUMBER;
x_item_ctrl     NUMBER;
x_neg_flag      NUMBER;
x_restrict_flag NUMBER;
BEGIN

-- initialize the output .
x_error_flag := 0;
x_error_mssg := '';
		--Dbms_Output.put_line('Get_LocatorControl_Code verification');

-- retrive organization level control information
Begin
SELECT
negative_inv_receipt_code,stock_locator_control_code into
x_neg_flag,x_org_ctrl FROM MTL_PARAMETERS
WHERE
organization_id = p_org;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_INVALID_ORGANIZATION';
End;
		 --Dbms_Output.put_line('Get_LocatorControl_Code- EAM_INVALID_ORGANIZATION');

-- retrive subinventory level control information
Begin
SELECT
locator_type into x_sub_ctrl
FROM MTL_SECONDARY_INVENTORIES
WHERE
organization_id = p_org and
secondary_inventory_name = p_subinv ;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_RET_MAT_INVALID_SUBINV1';
End;
		 --Dbms_Output.put_line('Get_LocatorControl_Code- EAM_RET_MAT_INVALID_SUBINV1');
-- retrive Item level control information
Begin
SELECT
location_control_code,restrict_locators_code into
x_item_ctrl,x_restrict_flag
FROM MTL_SYSTEM_ITEMS
WHERE
inventory_item_id = p_item_id and
organization_id = p_org;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_NO_ITEM_FOUND';
End;
			--Dbms_Output.put_line('Get_LocatorControl_Code - EAM_NO_ITEM_FOUND');

 if(x_org_ctrl = 1) then
       x_locator_ctrl := 1;
    elsif(x_org_ctrl = 2) then
       x_locator_ctrl := 2;
    elsif(x_org_ctrl = 3) then
       x_locator_ctrl := 3;
       if(Dynamic_Entry_Not_Allowed(x_restrict_flag,
            x_neg_flag,p_action)) then
         x_locator_ctrl := 2;
       end if;
    elsif(x_org_ctrl = 4) then
      if(x_sub_ctrl = 1) then
         x_locator_ctrl := 1;
      elsif(x_sub_ctrl = 2) then
         x_locator_ctrl := 2;
      elsif(x_sub_ctrl = 3) then
         x_locator_ctrl := 3;
         if(dynamic_entry_not_allowed(x_restrict_flag,
              x_neg_flag,p_action)) then
           x_locator_ctrl := 2;
         end if;
      elsif(x_sub_ctrl = 5) then
        if(x_item_ctrl = 1) then
           x_locator_ctrl := 1;
        elsif(x_item_ctrl = 2) then
           x_locator_ctrl := 2;
        elsif(x_item_ctrl = 3) then
           x_locator_ctrl := 3;
           if(dynamic_entry_not_allowed(x_restrict_flag,
                x_neg_flag,p_action)) then
             x_locator_ctrl := 2;
           end if;
        elsif(x_item_ctrl IS NULL) then
           x_locator_ctrl := x_sub_ctrl;
        else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_LOCATOR';
          return ;
        end if;

     else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_SUBINV';
          return ;
      end if;
    else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_ORG';
          return ;
    end if;


END Get_LocatorControl_Code; -- end of get_locatorcontrol_code procedure

Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER) return Boolean IS
BEGIN

if(p_restrict_flag = 2 or p_restrict_flag = null) then
 if(p_neg_flag = 2) then
   if(p_action = 1 or p_action = 2 or p_action = 3 or
      p_action = 21 or  p_action = 30 or  p_action = 32) then
       return TRUE;
   end if;
  else
   return FALSE;
  end if; -- end of neg_flag check
elsif(p_restrict_flag = 1) then
 return TRUE;
end if;
return TRUE;


End Dynamic_Entry_Not_Allowed ;

--Procedure for performing the Miscellanoeus receipt on assets
-- for 7370638

PROCEDURE addAssetsForMiscReceipt(p_header_id IN NUMBER,
				  p_batch_transaction_id IN NUMBER,
				  p_serial_number IN VARCHAR2,
				  p_CURRENT_ORGANIZATION_ID IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_current_subinventory_code IN VARCHAR2,
				  p_intermediate_locator_id IN NUMBER
					) IS



 l_org_id   NUMBER;
 l_qty      NUMBER;
 l_uom      VARCHAR2(3);
 l_txn_if_id                   NUMBER;
 l_sysdate                     DATE;
 l_acc_per_id                  NUMBER;
 l_api_name  constant VARCHAR2(30) := 'processAssetMoveTxn';
 l_module    VARCHAR2(200);
 l_log_level CONSTANT NUMBER             := fnd_log.g_current_runtime_level;
 l_uLog      CONSTANT BOOLEAN            := fnd_log.level_unexpected >= l_log_level;
 l_pLog      CONSTANT BOOLEAN            := l_uLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog      CONSTANT BOOLEAN            := l_pLog AND fnd_log.level_statement >= l_log_level;
 l_full_name CONSTANT VARCHAR2(60)       := g_pkg_name || '.' || l_api_name;

BEGIN
--Dbms_Output.PUT_LINE( '  entered the addassetsformiscrec');
    IF (l_ulog) THEN
                l_module := 'eam.plsql.'|| l_full_name;
    END IF;

   l_qty      := 1;
   l_sysdate := SYSDATE-1;

   BEGIN

   SELECT  primary_uom_code
              INTO    l_uom
              FROM    mtl_system_items_b
              WHERE   inventory_item_id=p_inventory_item_id
              AND organization_id  =p_CURRENT_ORGANIZATION_ID;
	EXCEPTION
		When no_data_found then

		IF (l_plog) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'UOM Code could not be derived in addAssetsForMiscReceipt.'|| l_full_name);
        END IF;

	END;


   SELECT maint_organization_id  INTO l_org_id
   FROM MTL_PARAMETERS WHERE
	organization_id= p_CURRENT_ORGANIZATION_ID;

    SELECT ACCT_PERIOD_ID
    INTO   l_acc_per_id
    FROM   ORG_ACCT_PERIODS
    WHERE  PERIOD_CLOSE_DATE IS NULL
    AND ORGANIZATION_ID = l_org_id
    AND (SCHEDULE_CLOSE_DATE + 1) > l_sysdate
    AND PERIOD_START_DATE <= l_sysdate ;

    SELECT APPS.mtl_material_transactions_s.NEXTVAL
    INTO l_txn_if_id
    FROM sys.dual;

    INSERT INTO mtl_transactions_interface
      (transaction_header_id,
	source_code,
	source_line_id,
	source_header_id,
	process_flag ,
	transaction_mode,
	lock_flag,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	organization_id,
	inventory_item_id,
	--distribution_account_id,
	subinventory_code,
	locator_id,
	transaction_quantity,
	transaction_uom,
	transaction_date,
	transaction_type_id,
	transaction_action_id,
	transaction_source_type_id,
	transaction_interface_id,
	transaction_batch_id,
	TRANSACTION_BATCH_SEQ
	)
	VALUES
	(p_header_id,
	1,
	-1,
	-1,
	1,
	3,
	2,
	l_sysdate,
	FND_GLOBAL.USER_ID,
	l_sysdate,
	FND_GLOBAL.USER_ID,
	l_org_id,
	p_inventory_item_id,
	--20594,
	p_current_subinventory_code,
	p_intermediate_locator_id,
	l_qty,
	l_uom,
	l_sysdate,
	42,
	27,
	13,
	l_txn_if_id,
	p_batch_transaction_id,
	1
	);

    INSERT INTO mtl_serial_numbers_interface
      (transaction_interface_id,
	SOURCE_CODE,
	SOURCE_LINE_ID,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	fm_serial_number,
	to_serial_number,
	ERROR_CODE,
	PROCESS_FLAG)
	VALUES
	(l_txn_if_id, --l_txn_ser_if_id
	null,
	1,
	l_sysdate,
	FND_GLOBAL.USER_ID,
	l_sysdate,
	FND_GLOBAL.USER_ID,
	p_serial_number,
	p_serial_number,
	NULL,
	1
	);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
     raise no_data_found;

END addAssetsForMiscReceipt;


END eam_asset_move_pub;

/

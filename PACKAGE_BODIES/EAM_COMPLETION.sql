--------------------------------------------------------
--  DDL for Package Body EAM_COMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_COMPLETION" AS
/* $Header: EAMWCMPB.pls 120.7 2006/06/02 07:16:11 kmurthy noship $*/



FUNCTION IS_WORKFLOW_ENABLED
(p_maint_obj_source    IN   NUMBER,
  p_organization_id         IN    NUMBER
) RETURN VARCHAR2
IS
    l_workflow_enabled      VARCHAR2(1);
BEGIN

  BEGIN
              SELECT enable_workflow
	      INTO   l_workflow_enabled
	      FROM EAM_ENABLE_WORKFLOW
	      WHERE MAINTENANCE_OBJECT_SOURCE =p_maint_obj_source;
     EXCEPTION
          WHEN NO_DATA_FOUND   THEN
	      l_workflow_enabled    :=         'N';
   END;

  --IF EAM workorder,check if workflow is enabled for this organization or not
  IF(l_workflow_enabled ='Y'   AND   p_maint_obj_source=1) THEN
       BEGIN
               SELECT eam_wo_workflow_enabled
	       INTO l_workflow_enabled
	       FROM WIP_EAM_PARAMETERS
	       WHERE organization_id =p_organization_id;
       EXCEPTION
               WHEN NO_DATA_FOUND THEN
		       l_workflow_enabled := 'N';
       END;
  END IF;  --check for workflow enabled at org level

     RETURN l_workflow_enabled;

END IS_WORKFLOW_ENABLED;



-- Bug 2803819-dgupta: This qa_enable API is now redundant and should be
-- removed in next cleanup.
PROCEDURE qa_enable(qa_id      NUMBER,
                    errCode  OUT NOCOPY NUMBER,
                    errMsg   OUT NOCOPY VARCHAR2) IS

  i_msg_data      VARCHAR2(250);
  i_return_status VARCHAR2(250);
  i_msg_count     NUMBER;

BEGIN
  errCode := 0;      --initial to success
  QA_RESULT_GRP.ENABLE(p_api_version => 1.0,
                       p_init_msg_list => 'F',
                       p_commit => 'F',
                       p_validation_level => 0,
                       p_collection_id => qa_id,
                       p_return_status => i_return_status,
                       p_msg_count => i_msg_count,
                       p_msg_data => i_msg_data);
  if (i_return_status <> 'S') then
    if (i_msg_count = -1) then
      fnd_message.set_name('QA','QA_ACTION_FAILED');
    else
      fnd_message.set_name('QA', i_msg_data);
    end if; -- end message count check
    errCode := 1;     --fail
    errMsg := fnd_message.get;
    return;
  end if;  -- end error check

END qa_enable;

PROCEDURE process_lot_serial(
		       s_subinventory     VARCHAR2,
                       s_locator_id       VARCHAR2,
		       s_lot_serial_tbl   Lot_Serial_Tbl_Type,
                       s_org_id           NUMBER,
                       s_wip_entity_id    NUMBER,
                       s_qa_collection_id NUMBER,
                       s_rebuild_item_id  NUMBER,
                       s_acct_period_id   NUMBER,
                       s_user_id          NUMBER,
                       s_transaction_type NUMBER,
                       s_project_id       NUMBER,
                       s_task_id          NUMBER,
                       s_commit           VARCHAR2,
                       errCode        OUT NOCOPY NUMBER,
                       errMsg         OUT NOCOPY VARCHAR2,
                       x_statement    OUT NOCOPY NUMBER) IS

  i_transaction_header_id NUMBER;
  i_transaction_temp_id NUMBER;
  i_serial_transaction_temp_id NUMBER;
  i_transaction_temp_id_s NUMBER;
  i_transaction_quantity NUMBER;
  i_primary_quantity NUMBER;
  i_transaction_action_id NUMBER;
  i_transaction_type_id NUMBER;
  i_transaction_source_type_id NUMBER;
  i_project_id NUMBER;
  i_task_id NUMBER;
  i_revision VARCHAR2(3) := null;
  item wma_common.Item;
  l_statement NUMBER := 0;
  l_revision_control_code NUMBER := 1;
  l_transaction_quantity NUMBER;
  l_initial_msg_count NUMBER := 0;

BEGIN

  -- prepare the data to insert into MTL_MATERIAL_TRANSACTIONS_TEMP,
  -- MTL_SERIAL_NUMBERS_TEMP, and MTL_TRANSACTION_LOTS_TEMP
  select mtl_material_transactions_s.nextval into i_transaction_header_id
  from   dual;

  l_statement := 1;
  x_statement := l_statement;

  -- get the item info
  item := wma_derive.getItem(s_rebuild_item_id, s_org_id, s_locator_id);
  if (item.invItemID is null) then
    fnd_message.set_name ('EAM', 'EAM_ITEM_DOES_NOT_EXIST');
    errCode := 1;
    errMsg  := fnd_message.get;
    return;
  end if; -- end item info check

  l_statement := 2;
  x_statement := l_statement;


  begin
      select nvl(revision_qty_control_code,1)
      into l_revision_control_code
      from mtl_system_items
      where inventory_item_id = s_rebuild_item_id
      and organization_id = s_org_id;

      exception
      when others then
      null;
      end;

     if (l_revision_control_code = 2) then

      -- get bom_revision
      bom_revisions.get_revision (examine_type => 'ALL',
                                  org_id       => s_org_id,
                                  item_id      => s_rebuild_item_id,
                                  rev_date     => sysdate,
                                  itm_rev      => i_revision);
   end if;

  -- get transaction source type id
  i_transaction_source_type_id := inv_reservation_global.g_source_type_wip;

   l_statement := 3;
   x_statement := l_statement;

  -- set i_transaction_quantity and i_primary_quantity to be the sum of all
  -- quantities in the lot_serial_tbl
  -- also verify all quantities are greater than 0
  i_transaction_quantity := 0;
  FOR i IN 1..s_lot_serial_tbl.COUNT LOOP
      IF s_lot_serial_tbl(i).quantity is null or s_lot_serial_tbl(i).quantity < 1 THEN
	  errCode := 1;
          fnd_message.set_name('EAM', 'EAM_NEGATIVE_TXN_QUANTITY');
          errMsg := fnd_message.get;
          return;
      ELSE
	  i_transaction_quantity := i_transaction_quantity + s_lot_serial_tbl(i).quantity;
      END IF;
  END LOOP;
  i_primary_quantity := i_transaction_quantity;

  -- prepare the rest data
  if(s_transaction_type = 1) then  -- Complete Transaction
    i_transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
    i_transaction_type_id := WIP_CONSTANTS.CPLASSY_TYPE;
  elsif(s_transaction_type = 2) then -- Uncomplete Transaction
    i_transaction_quantity := - i_transaction_quantity;
    i_primary_quantity := - i_primary_quantity;
    i_transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
    i_transaction_type_id := WIP_CONSTANTS.RETASSY_TYPE;
  else
    fnd_message.set_name('EAM','EAM_INVALID_TRANSACTION_TYPE');
    errCode := 1;
    errMsg := fnd_message.get;
    return;
  end if; -- end prepare data

  l_statement := 4;
  x_statement := l_statement;

  -- call inventory API to insert data to mtl_material_transactions_temp
  -- the spec file is INVTRXUS.pls

   errCode := inv_trx_util_pub.insert_line_trx(
             p_trx_hdr_id      => i_transaction_header_id,
             p_item_id         => s_rebuild_item_id,
             p_revision        => i_revision,
             p_org_id          => s_org_id,
             p_trx_action_id   => i_transaction_action_id,
             p_subinv_code     => s_subinventory,
             p_locator_id      => s_locator_id,
             p_trx_type_id     => i_transaction_type_id,
             p_trx_src_type_id => i_transaction_source_type_id,
             p_trx_qty         => i_transaction_quantity,
             p_pri_qty         => i_primary_quantity,
             p_uom             => item.primaryUOMCode,
             p_date            => sysdate,
             p_user_id         => s_user_id,
             p_trx_src_id      => s_wip_entity_id,
             x_trx_tmp_id      => i_transaction_temp_id,
             x_proc_msg        => errMsg);

 l_statement := 5;
 x_statement := l_statement;

  if (errCode <> 0) then
    return;
  end if;

 FOR i IN 1..s_lot_serial_tbl.COUNT LOOP

  if(s_transaction_type = 1) then  -- Complete Transaction
     l_transaction_quantity := s_lot_serial_tbl(i).quantity;
  else -- Uncomplete Transaction
     l_transaction_quantity := - s_lot_serial_tbl(i).quantity;
  end if;

  -- Check whether the item is under lot or serial control or not
  -- If it is, insert the data to coresponding tables
  if(item.lotControlCode = WIP_CONSTANTS.LOT) then

    -- the item is under lot control

    -- call inventory API to insert data to mtl_transaction_lots_temp
    -- the spec file is INVTRXUS.pls
    errCode := inv_trx_util_pub.insert_lot_trx(
               p_trx_tmp_id    => i_transaction_temp_id,
               p_user_id       => s_user_id,
               p_lot_number    => s_lot_serial_tbl(i).lot_number,
               p_trx_qty       => l_transaction_quantity,
               p_pri_qty       => l_transaction_quantity,
               x_ser_trx_id    => i_serial_transaction_temp_id,
               x_proc_msg      => errMsg);

    if (errCode <> 0) then
      return;
    end if;

  else
    null;
  end if; -- end lot control check

  -- Check if the item is under serial control or not
  if(item.serialNumberControlCode in (WIP_CONSTANTS.FULL_SN,
                                      WIP_CONSTANTS.DYN_RCV_SN)) then
    -- item is under serial control

    -- Check if the item is under lot control or not
    if(item.lotControlCode = WIP_CONSTANTS.LOT) then

      -- under lot control
      i_transaction_temp_id_s := i_serial_transaction_temp_id;
    else
      i_transaction_temp_id_s := i_transaction_temp_id;
    end if;   -- end lot control check


    -- call inventory API to insert data to mtl_serial_numbers_temp
    -- the spec file is INVTRXUS.pls
    errCode := inv_trx_util_pub.insert_ser_trx(
               p_trx_tmp_id     => i_transaction_temp_id_s,
               p_user_id        => s_user_id,
               p_fm_ser_num     => s_lot_serial_tbl(i).serial_number,
               p_to_ser_num     => s_lot_serial_tbl(i).serial_number,
               x_proc_msg       => errMsg);
    if (errCode <> 0) then
      return;
    end if;

  else
    null;
  end if;  -- end serial control check

 end LOOP;

 l_statement := 6;
 x_statement := l_statement;

 l_initial_msg_count := FND_MSG_PUB.count_msg;
  -- Call Inventory API to process to item
  -- the spec file is INVTRXWS.pls
  errCode := inv_lpn_trx_pub.process_lpn_trx(
             p_trx_hdr_id => i_transaction_header_id,
             p_commit     => s_commit,
             x_proc_msg   => errMsg);
/* Added as a FIX for the Issue 1 of bug:2881879 */
if(FND_MSG_PUB.count_msg> 0) then
  if(l_initial_msg_count = 0 and  errCode = 0) then
    FND_MSG_PUB.Delete_msg;
  end if;
end if;
/* Added for bug no :2911698
   Since the error message is not getting added into the message stack
*/
if(errCode <> 0 and errMsg is not null) then
  eam_execution_jsp.add_message(p_app_short_name => 'EAM',p_msg_name =>
                                 'EAM_RET_MAT_PROCESS_MESSAGE',p_token1=> 'ERRMESSAGE',
								  p_value1 => errMsg);
end if;

l_statement := 7;
x_statement := l_statement;

END process_lot_serial;


PROCEDURE process_item(
		       s_inventory_item_tbl EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type,
                       s_org_id           NUMBER,
                       s_wip_entity_id    NUMBER,
                       s_qa_collection_id NUMBER,
                       s_rebuild_item_id  NUMBER,
                       s_acct_period_id   NUMBER,
                       s_user_id          NUMBER,
                       s_transaction_type NUMBER,
                       s_project_id       NUMBER,
                       s_task_id          NUMBER,
                       s_commit           VARCHAR2,
                       errCode        OUT NOCOPY NUMBER,
                       errMsg         OUT NOCOPY VARCHAR2,
                       x_statement    OUT NOCOPY NUMBER) IS
    l_subinventory VARCHAR2(30);
    l_locator VARCHAR2(30);
    l_lot_serial_rec Lot_Serial_Rec_Type;
    l_lot_serial_tbl Lot_Serial_Tbl_Type;
BEGIN
    IF s_inventory_item_tbl.COUNT = 0 THEN
        RETURN;
    END IF;

    l_subinventory := s_inventory_item_tbl(1).subinventory;
    l_locator := s_inventory_item_tbl(1).locator;
    l_lot_serial_rec.lot_number := s_inventory_item_tbl(1).lot_number;
    l_lot_serial_rec.serial_number := s_inventory_item_tbl(1).serial_number;
    l_lot_serial_rec.quantity := s_inventory_item_tbl(1).quantity;
    l_lot_serial_tbl(1) := l_lot_serial_rec;

    FOR i in 2..(s_inventory_item_tbl.COUNT+1) LOOP
        IF (i > s_inventory_item_tbl.COUNT
            OR s_inventory_item_tbl(i).subinventory <> l_subinventory
	    OR s_inventory_item_tbl(i).locator <> l_locator) THEN

	    process_lot_serial(l_subinventory,
			   l_locator,
			   l_lot_serial_tbl,
			   s_org_id,
			   s_wip_entity_id,
			   s_qa_collection_id,
			   s_rebuild_item_id,
			   s_acct_period_id,
			   s_user_id,
			   s_transaction_type,
			   s_project_id,
			   s_task_id,
			   s_commit,
			   errCode,
			   errMsg,
			   x_statement);
            if (errCode <> 0) then
	     	return;
	    end if;
            l_lot_serial_tbl.DELETE;
        END IF;
        IF (i <= s_inventory_item_tbl.COUNT) THEN
            l_subinventory := s_inventory_item_tbl(i).subinventory;
            l_locator := s_inventory_item_tbl(i).locator;
            l_lot_serial_rec.lot_number := s_inventory_item_tbl(i).lot_number;
            l_lot_serial_rec.serial_number := s_inventory_item_tbl(i).serial_number;
            l_lot_serial_rec.quantity := s_inventory_item_tbl(i).quantity;
            l_lot_serial_tbl(l_lot_serial_tbl.COUNT+1) := l_lot_serial_rec;
	END IF;
    END LOOP;

END process_item;

-- Added three arguments as part of bug 3448770 fix
PROCEDURE process_shutdown(s_asset_group_id     NUMBER,
                           s_organization_id    NUMBER,
                           s_asset_number       VARCHAR2,
                           s_start_date         DATE,
                           s_end_date           DATE,
                           s_user_id            NUMBER,
			   s_maintenance_object_type NUMBER,
                           s_maintenance_object_id   NUMBER,
                           s_wip_entity_id	     NUMBER DEFAULT NULL ) IS

  i_asset_status_id NUMBER;
BEGIN
  -- get the asset_status_id from eam_asset_status_history_s sequence
  SELECT eam_asset_status_history_s.nextval INTO i_asset_status_id FROM dual;

-- Enhancement Bug 3852846
  UPDATE eam_asset_status_history
  SET enable_flag = 'N'
      , last_update_date  = SYSDATE
      , last_updated_by   = FND_GLOBAL.user_id
      , last_update_login = FND_GLOBAL.login_id
  WHERE organization_id = s_organization_id
  AND   wip_entity_id = s_wip_entity_id
  AND   operation_seq_num IS NULL
  AND (enable_flag is NULL OR enable_flag = 'Y');

  INSERT INTO eam_asset_status_history(asset_status_id,
                                       organization_id,
                                       asset_group_id,
                                       asset_number,
                                       start_date,
                                       end_date,
				       wip_entity_id,             -- Fix for Bug 3448770
                                       maintenance_object_type,
                                       maintenance_object_id,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
				       enable_flag)   -- Enhancement Bug 3852846
                               VALUES (i_asset_status_id,
                                       s_organization_id,
                                       s_asset_group_id,
                                       s_asset_number,
                                       s_start_date,
                                       s_end_date,
				       s_wip_entity_id,            -- Fix for Bug 3448770
                                       s_maintenance_object_type,
                                       s_maintenance_object_id,
                                       s_user_id,
                                       sysdate,
                                       s_user_id,
                                       sysdate,
				       'Y');   -- Enhancement Bug 3852846

END process_shutdown;

PROCEDURE lock_row(
  p_wip_entity_id         IN NUMBER,
  p_organization_id       IN NUMBER,
  p_rebuild_item_id       IN NUMBER,
  p_parent_wip_entity_id  IN NUMBER,
  p_asset_number          IN VARCHAR2,
  p_asset_group_id        IN NUMBER,
  p_manual_rebuild_flag   IN VARCHAR2,
  p_asset_activity_id     IN NUMBER,
  p_status_type           IN NUMBER,
  x_return_status        OUT NOCOPY NUMBER,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_full_name      CONSTANT VARCHAR2(60) := 'eam_completion' || '.' ||
                                            l_api_name;

  CURSOR C IS
    SELECT wip_entity_id, organization_id, rebuild_item_id,
           rebuild_serial_number, parent_wip_entity_id, asset_number,
           asset_group_id, manual_rebuild_flag, primary_item_id, status_type,
           completion_subinventory, completion_locator_id, lot_number,
           project_id, task_id
    FROM wip_discrete_jobs
    WHERE  wip_entity_id = P_WIP_ENTITY_ID
    FOR UPDATE OF status_type NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT apiname_apitype;

   /*Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
             l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;*/

   -- Initialize API return status to success
      x_return_status := 0;

   -- API body

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('EAM', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
       (p_wip_entity_id is null or
        Recinfo.wip_entity_id =  p_wip_entity_id)
       AND (p_organization_id is null or
            Recinfo.organization_id = p_organization_id)
       AND (p_rebuild_item_id is null or
            Recinfo.rebuild_item_id = p_rebuild_item_id)
       AND (p_parent_wip_entity_id is null or
            Recinfo.parent_wip_entity_id =  p_parent_wip_entity_id)
       AND (p_asset_number is null
            or Recinfo.asset_number = p_asset_number)
       AND (p_asset_group_id is null or
            Recinfo.asset_group_id = p_asset_group_id)
       AND (p_manual_rebuild_flag is null or
            Recinfo.manual_rebuild_flag = p_manual_rebuild_flag)
       AND (p_asset_activity_id is null or
            Recinfo.primary_item_id = p_asset_activity_id)
       AND (p_status_type is null or
            Recinfo.status_type = p_status_type)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('EAM', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;


   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := 1;
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := 1;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);

      WHEN OTHERS THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := 1;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg('eam_completion', l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);


END Lock_Row;

PROCEDURE complete_work_order_form(
          x_wip_entity_id       IN NUMBER,
	        x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	        x_request_id          IN NUMBER   := null,
	        x_application_id      IN NUMBER   := null,
   	      x_program_id          IN NUMBER   := null,
	        x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2) IS
    l_inventory_item_rec EAM_WorkOrderTransactions_PUB.Inventory_Item_Rec_Type;
    l_inventory_item_tbl EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;
BEGIN
    l_inventory_item_rec.subinventory := x_subinventory;
    l_inventory_item_rec.locator := x_locator_id;
    l_inventory_item_rec.lot_number := x_lot_number;
    l_inventory_item_rec.serial_number := x_serial_number;
    l_inventory_item_rec.quantity := 1;
    l_inventory_item_tbl(1) := l_inventory_item_rec;

  complete_work_order_generic(x_wip_entity_id       =>  x_wip_entity_id,
	                    x_rebuild_jobs        =>  x_rebuild_jobs,
                      x_transaction_type    =>  x_transaction_type,
                      x_transaction_date    =>  x_transaction_date,
                      x_user_id             =>  x_user_id,
	      	            x_request_id          =>  x_request_id,
	                    x_application_id      =>  x_application_id,
   	                  x_program_id          =>  x_program_id,
			                x_reconcil_code       =>  x_reconcil_code,
                      x_actual_start_date   =>  x_actual_start_date,
                      x_actual_end_date     =>  x_actual_end_date,
                      x_actual_duration     =>  x_actual_duration,
        	      x_inventory_item_info =>  l_inventory_item_tbl,
                      x_reference           =>  x_reference,
                      x_qa_collection_id    =>  x_qa_collection_id,
                      x_shutdown_start_date =>  x_shutdown_start_date,
                      x_shutdown_end_date   =>  x_shutdown_end_date,
                      x_attribute_category  =>  x_attribute_category,
                      x_attribute1          =>  x_attribute1,
                      x_attribute2          =>  x_attribute2,
                      x_attribute3          =>  x_attribute3,
                      x_attribute4          =>  x_attribute4,
                      x_attribute5          =>  x_attribute5,
                      x_attribute6          =>  x_attribute6,
                      x_attribute7          =>  x_attribute7,
                      x_attribute8          =>  x_attribute8,
                      x_attribute9          =>  x_attribute9,
                      x_attribute10         =>  x_attribute10,
                      x_attribute11         =>  x_attribute11,
                      x_attribute12         =>  x_attribute12,
                      x_attribute13         =>  x_attribute13,
                      x_attribute14         =>  x_attribute14,
                      x_attribute15         =>  x_attribute15,
                      errCode               =>  errCode,
                      errMsg                =>  errMsg);

END complete_work_order_form;

/* Added for bug# 3238163 */
PROCEDURE complete_work_order_commit(
          x_wip_entity_id       IN NUMBER,
	        x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	        x_request_id          IN NUMBER   := null,
	        x_application_id      IN NUMBER   := null,
   	      x_program_id          IN NUMBER   := null,
	        x_reconcil_code       IN VARCHAR2 := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2) IS
    l_inventory_item_rec EAM_WorkOrderTransactions_PUB.Inventory_Item_Rec_Type;
    l_inventory_item_tbl EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;
BEGIN
    l_inventory_item_rec.subinventory := x_subinventory;
    l_inventory_item_rec.locator := x_locator_id;
    l_inventory_item_rec.lot_number := x_lot_number;
    l_inventory_item_rec.serial_number := x_serial_number;
    l_inventory_item_rec.quantity := 1;
    l_inventory_item_tbl(1) := l_inventory_item_rec;

  complete_work_order_generic(x_wip_entity_id       =>  x_wip_entity_id,
	                    x_rebuild_jobs        =>  x_rebuild_jobs,
                      x_transaction_type    =>  x_transaction_type,
                      x_transaction_date    =>  x_transaction_date,
                      x_user_id             =>  x_user_id,
	      	            x_request_id          =>  x_request_id,
	                    x_application_id      =>  x_application_id,
   	                  x_program_id          =>  x_program_id,
			                x_reconcil_code       =>  x_reconcil_code,
                      x_commit              => x_commit,
                      x_actual_start_date   =>  x_actual_start_date,
                      x_actual_end_date     =>  x_actual_end_date,
                      x_actual_duration     =>  x_actual_duration,
        	      x_inventory_item_info =>  l_inventory_item_tbl,
                      x_reference           =>  x_reference,
                      x_qa_collection_id    =>  x_qa_collection_id,
                      x_shutdown_start_date =>  x_shutdown_start_date,
                      x_shutdown_end_date   =>  x_shutdown_end_date,
                      x_attribute_category  =>  x_attribute_category,
                      x_attribute1          =>  x_attribute1,
                      x_attribute2          =>  x_attribute2,
                      x_attribute3          =>  x_attribute3,
                      x_attribute4          =>  x_attribute4,
                      x_attribute5          =>  x_attribute5,
                      x_attribute6          =>  x_attribute6,
                      x_attribute7          =>  x_attribute7,
                      x_attribute8          =>  x_attribute8,
                      x_attribute9          =>  x_attribute9,
                      x_attribute10         =>  x_attribute10,
                      x_attribute11         =>  x_attribute11,
                      x_attribute12         =>  x_attribute12,
                      x_attribute13         =>  x_attribute13,
                      x_attribute14         =>  x_attribute14,
                      x_attribute15         =>  x_attribute15,
                      errCode               =>  errCode,
                      errMsg                =>  errMsg);

END complete_work_order_commit;

-- Procedure called via JSP

PROCEDURE complete_work_order(
          x_wip_entity_id       IN NUMBER,
	  x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	  x_request_id          IN NUMBER   := null,
	  x_application_id      IN NUMBER   := null,
   	  x_program_id          IN NUMBER   := null,
	  x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2)  IS


 l_inventory_item_rec EAM_WorkOrderTransactions_PUB.Inventory_Item_Rec_Type;
 l_inventory_item_tbl EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;
 BEGIN
     l_inventory_item_rec.subinventory := x_subinventory;
     l_inventory_item_rec.locator := x_locator_id;
     l_inventory_item_rec.lot_number := x_lot_number;
     l_inventory_item_rec.serial_number := x_serial_number;
     l_inventory_item_rec.quantity := 1;
     l_inventory_item_tbl(1) := l_inventory_item_rec;

   complete_work_order_generic(x_wip_entity_id       =>  x_wip_entity_id,
 	               x_rebuild_jobs        =>  x_rebuild_jobs,
                       x_transaction_type    =>  x_transaction_type,
                       x_transaction_date    =>  x_transaction_date,
                       x_user_id             =>  x_user_id,
 	      	       x_request_id          =>  x_request_id,
 	               x_application_id      =>  x_application_id,
    	               x_program_id          =>  x_program_id,
 		       x_reconcil_code       =>  x_reconcil_code,
                       x_actual_start_date   =>  x_actual_start_date,
                       x_actual_end_date     =>  x_actual_end_date,
                       x_actual_duration     =>  x_actual_duration,
         	       x_inventory_item_info =>  l_inventory_item_tbl,
                       x_reference           =>  x_reference,
                       x_qa_collection_id    =>  x_qa_collection_id,
                       x_shutdown_start_date =>  x_shutdown_start_date,
                       x_shutdown_end_date   =>  x_shutdown_end_date,
                       x_attribute_category  =>  x_attribute_category,
                       x_attribute1          =>  x_attribute1,
                       x_attribute2          =>  x_attribute2,
                       x_attribute3          =>  x_attribute3,
                       x_attribute4          =>  x_attribute4,
                       x_attribute5          =>  x_attribute5,
                       x_attribute6          =>  x_attribute6,
                       x_attribute7          =>  x_attribute7,
                       x_attribute8          =>  x_attribute8,
                       x_attribute9          =>  x_attribute9,
                       x_attribute10         =>  x_attribute10,
                       x_attribute11         =>  x_attribute11,
                       x_attribute12         =>  x_attribute12,
                       x_attribute13         =>  x_attribute13,
                       x_attribute14         =>  x_attribute14,
                       x_attribute15         =>  x_attribute15,
                       errCode               =>  errCode,
                      errMsg                =>  errMsg);

 END complete_work_order;



/***************************************************************************
 *
 * This procedure will be used to complete and uncomplete EAM work order
 *
 * PARAMETER:
 *
 * x_wip_entity_id        Work Order ID
 * x_rebuild_jobs         A flag used to determine work order type
 *                        (N:Regular EAM work order/ Y:Rebuild work order)
 * x_transaction_type     The type of transaction (Complete(1) / Uncomplete(2))
 * x_transaction_date     The date of transaction
 * x_user_id              User ID
 * x_request_id,          For concurrent processing
 * x_appplication_id,     For concurrent processing
 * x_program_id           For concurrent processing
 * x_reconcil_code        This parameter was predefined in FND_LOOKUP_VALUES
 *                        where lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
 * x_subinventory         For rebuild work order with material issue only
 * x_locator_id           For rebuild work order with material issue only
 * x_lot_number           For rebuild work order with material issue only
 * x_serial_number        For rebuild work order with material issue only
 * x_reference            For regular EAM work order only
 * x_qa_collection_id     For regular EAM work order only
 *                        (null if the the work order is not under QA control)
 * x_shutdown_start_date  Shutdown information for regular EAM
 * x_shutdown_end_date    Shutdown information for regular EAM
 * x_commit               default to fnd_api.g_true
 *                        whether to commit the changes to DB
 * x_attribute_category   For descriptive flex field
 * x_attribute1-15        For descriptive flex field
 * errCode  OUT           0 if procedure success, 1 otherwise
 * errMsg   OUT NOCOPY           The informative error message
 *
 ***************************************************************************/

PROCEDURE complete_work_order_generic(
          x_wip_entity_id       IN NUMBER,
	        x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	      	x_request_id          IN NUMBER   := null,
	        x_application_id      IN NUMBER   := null,
   	      x_program_id          IN NUMBER   := null,
			    x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
	  x_inventory_item_info IN EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type := INVENTORY_ITEM_NULL,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2) IS


  i_asset_number         VARCHAR2(30);
  i_manual_rebuild_flag  VARCHAR2(1);
  i_acct_period_id       NUMBER;
  i_asset_group_id       NUMBER;
  i_asset_activity_id    NUMBER;
  i_org_id               NUMBER;
  i_parent_wip_entity_id NUMBER;
  i_parent_status_type   NUMBER;          -- used for uncomplete transaction
  i_project_id           NUMBER;
  i_rebuild_item_id      NUMBER;
  i_rebuild_serial_number VARCHAR2(30);
  i_status_type          NUMBER;          -- status of work order
  i_task_id              NUMBER;
  i_transaction_id       NUMBER;
  msg_count              NUMBER;
  i_work_request_status  NUMBER;
  i_completion_date      DATE;
  i_program_update_date  DATE;
  l_statement            NUMBER := 0;
  x_statement            NUMBER := 0;
  l_valid                NUMBER := 0;
  l_subinventory 	VARCHAR2(30) := null;
  l_locator             NUMBER := null;
  l_lot_number          VARCHAR2(80) := null;
  i_maintenance_source_id NUMBER;   -- added as part of bug #2774571 to check whether the work order is of 'EAM' or 'CMRO'

  -- this boolean need to pass to invttmtx.tdatechk
  i_open_past_period     BOOLEAN;

/* --replaced with select statement for bug #2414513.
|  -- Cursor to hold all child jobs information
|  cursor child_jobs_cursor(c_wip_entity_id NUMBER) is
|  select we.wip_entity_name, wdj.status_type
|  from   wip_discrete_jobs wdj, wip_entities we
|  where  wdj.wip_entity_id =  we.wip_entity_id
|         and wdj.parent_wip_entity_id = c_wip_entity_id
|         and wdj.manual_rebuild_flag = 'Y';
|
|  -- Aggregate variable to hold each child job information
|  child_job child_jobs_cursor%ROWTYPE;
*/
   child_job_var   VARCHAR2(2):='0';
   network_child_job_var   VARCHAR2(2):='0'; -- Bug no 3049128 added as part to check for Work Order Completion as part of  Work Order Linking Project
   network_parent_job_var   VARCHAR2(2):='0'; -- Bug no 3049128 added as part to check for Work Order Completion as part of  Work Order Linking Project
   sibling_parent_job_var   VARCHAR2(2):='0';

   i_maintenance_object_type NUMBER;    -- Fix for Bug 3448770
   i_maintenance_object_id   NUMBER;    -- Fix for Bug 3448770
       l_wip_entity_name                VARCHAR2(240);
	l_workflow_enabled             VARCHAR2(1);
	l_approval_required              BOOLEAN;
	l_workflow_name                   VARCHAR2(200);
	l_workflow_process              VARCHAR2(200);
	l_status_pending_event       VARCHAR2(240);
	l_status_changed_event      VARCHAR2(240);
	l_new_eam_status                NUMBER;
	l_new_system_status           NUMBER;
	l_old_eam_status                   NUMBER;
        l_old_system_status             NUMBER;
	l_workflow_type                       NUMBER;
	l_event_name			VARCHAR2(240);
	l_parameter_list			wf_parameter_list_t;
	 l_event_key				VARCHAR2(200);
	 l_wf_event_seq			NUMBER;
	 l_cost_estimate                   NUMBER;


BEGIN

  SAVEPOINT job_comp;
  errCode := 0;    -- initial to success
  msg_count := 0;
  i_open_past_period := FALSE;

  l_statement := 15;
  x_statement := l_statement;

  -- Validate all required information
  if(x_wip_entity_id = null or x_rebuild_jobs = null
     or x_transaction_type = null or x_transaction_date = null
     or x_actual_start_date = null or x_actual_end_date = null
     or x_actual_duration = null) then
    ROLLBACK TO job_comp;
    fnd_message.set_name('EAM','EAM_WORK_ORDER_MISSING_INFO');
    errCode := 1;
    errMsg := fnd_message.get;
    return;
  end if; -- end validate data

 l_statement := 25;
 x_statement := l_statement;

  -- get transaction_id from sequence eam_job_completion_txns_s
  select eam_job_completion_txns_s.nextval into i_transaction_id from dual;

  if(x_request_id is not null and x_application_id is not null and
     x_program_id is not null) then
    i_program_update_date := sysdate;
  else
    i_program_update_date := null;
  end if;  -- end concurrent program check

 l_statement := 35;
 x_statement := l_statement;

  -- get some value from wip_discrete_jobs table
  select wdj.parent_wip_entity_id,
         wdj.asset_group_id,
         wdj.asset_number,
         wdj.primary_item_id,
         wdj.manual_rebuild_flag,
         wdj.rebuild_item_id,
         wdj.rebuild_serial_number,
         wdj.project_id,
         wdj.task_id,
         wdj.organization_id,
	 wdj.maintenance_object_source,   -- added as part of bug #2774571 to check whether the work order is of 'EAM' or 'CMRO'
	 wdj.maintenance_object_type,     -- Fix for Bug 3448770
         wdj.maintenance_object_id,
	 wdj.status_type,
	 ewod.user_defined_status_id,
	 ewod.workflow_type,
	 we.wip_entity_name
    into i_parent_wip_entity_id,
         i_asset_group_id,
         i_asset_number,
         i_asset_activity_id,
         i_manual_rebuild_flag,
         i_rebuild_item_id,
         i_rebuild_serial_number,
         i_project_id,
         i_task_id,
         i_org_id,
	 i_maintenance_source_id,     -- added as part of bug #2774571 to check whether the work order is of 'EAM' or 'CMRO'
	 i_maintenance_object_type,   -- Fix for Bug 3448770
         i_maintenance_object_id,
         l_old_system_status,
         l_old_eam_status,
         l_workflow_type,
	 l_wip_entity_name
    from wip_discrete_jobs wdj,eam_work_order_details ewod,wip_entities we
   where wdj.wip_entity_id = x_wip_entity_id
   AND wdj.wip_entity_id = ewod.wip_entity_id(+)
   AND wdj.wip_entity_id = we.wip_entity_id;

   l_workflow_enabled:=Is_Workflow_enabled(i_maintenance_source_id,i_org_id);
   l_status_changed_event := 'oracle.apps.eam.workorder.status.changed';
   l_status_pending_event := 'oracle.apps.eam.workorder.status.change.pending';

  l_statement := 45;
  x_statement := l_statement;

--fix for bug # 2446276 ----------------------------------------
if(x_transaction_type = 2) then
  if(x_rebuild_jobs <> 'Y') then
    l_valid := EAM_WORKORDER_UTIL_PKG.check_released_onhold_allowed(
           'N',
            i_org_id,
            i_asset_group_id,
            i_asset_number,
            i_asset_activity_id);
  else
    l_valid := EAM_WORKORDER_UTIL_PKG.check_released_onhold_allowed(
           'Y',
           i_org_id,
           i_rebuild_item_id,
           i_rebuild_serial_number,
           i_asset_activity_id);
  end if;
  if l_valid = 1 then
        FND_MESSAGE.SET_NAME('EAM', 'EAM_WO_NO_UNCOMPLETE');
       errCode := 2;
       errMsg := fnd_message.get;
       return;
   end if;
end if;  /* end if for fix 2446276 */

  -- get acct_period_id from routine invttmtx.tdatechk
  -- this routine will return the value via acct_period_id OUT variable
  -- open_past_period is an IN OUT boolean
  invttmtx.tdatechk(i_org_id,x_transaction_date,i_acct_period_id,
                    i_open_past_period);

  -- Check whether the transaction type is Complete or Uncomplete
  If (x_transaction_type = 1) then -- Complete Transaction
  -- Bug no 3049128 added as part to check for Work Order Completion as part of  Work Order Linking Project

     begin
	SELECT '1'
	   INTO network_child_job_var
	   FROM dual
	WHERE EXISTS (SELECT '1'
			   FROM wip_discrete_jobs
			 WHERE wip_entity_id IN
			 (
			  SELECT DISTINCT  child_object_id
				FROM eam_wo_relationships
			  WHERE parent_relationship_type =1
				START WITH parent_object_id =    x_wip_entity_id AND parent_relationship_type = 1
				CONNECT BY  parent_object_id  = prior child_object_id   AND parent_relationship_type = 1
			 )
		       AND status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
                        WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED,WIP_CONSTANTS.CANCELLED, WIP_CONSTANTS.PEND_CLOSE)

                     );

       if (network_child_job_var = '1') then  --In the network Work Order has Uncompleted Child Work Orders
            ROLLBACK TO job_comp;
            fnd_message.set_name('EAM','EAM_NETWRK_CHILD_JOB_NOT_COMP');
            errCode := 1;
            errMsg  := 'EAM_NETWRK_CHILD_JOB_NOT_COMP';
            return;
       else
           null;
       end if;
     exception
      WHEN OTHERS THEN
	null;
    end;
    -- end of Bug fix 3049128

    --  Bug no 3735589
    begin
	SELECT '1'
	   INTO sibling_parent_job_var
	   FROM dual
	WHERE EXISTS (SELECT '1'
			   FROM wip_discrete_jobs
			 WHERE wip_entity_id IN
			 (
			 SELECT DISTINCT  parent_object_id
				FROM eam_wo_relationships
			  WHERE parent_relationship_type =2 and
				child_object_id  =    x_wip_entity_id
			 )
		       AND status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
                        WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED)

                     );

       if (sibling_parent_job_var = '1') then
            ROLLBACK TO job_comp;
            fnd_message.set_name('EAM','EAM_NETWRK_SIB_JOB_NOT_COM');
            errCode := 1;
            errMsg  := 'EAM_NETWRK_SIB_JOB_NOT_COM';
            return;
       else
           null;
       end if;
     exception
      WHEN OTHERS THEN
	null;
    end;
    -- end of bug fix 3735589



      IF(l_workflow_enabled='Y'  AND    x_transaction_type=2
	                  AND (WF_EVENT.TEST(l_status_pending_event) <> 'NONE') )THEN
							 EAM_WORKFLOW_DETAILS_PUB.Eam_Wf_Is_Approval_Required(p_old_wo_rec =>  NULL,
															   p_new_wo_rec  =>  NULL,
															    p_wip_entity_id        =>    x_wip_entity_id,
															    p_new_system_status  => 3,
															    p_new_wo_status           =>  3,
															    p_old_system_status     =>   l_old_system_status,
															    p_old_wo_status             =>   l_old_eam_status,
															   x_approval_required  =>  l_approval_required,
															   x_workflow_name   =>   l_workflow_name,
															   x_workflow_process    =>   l_workflow_process
															   );

						IF(l_approval_required) THEN
								   UPDATE EAM_WORK_ORDER_DETAILS
								   SET user_defined_status_id=3,
									    pending_flag='Y',
									    last_update_date=SYSDATE,
									    last_update_login=FND_GLOBAL.login_id,
									    last_updated_by=FND_GLOBAL.user_id
								   WHERE wip_entity_id= x_wip_entity_id;



                                                            --Find the total estimated cost of workorder
											   BEGIN
												 SELECT NVL((SUM(system_estimated_mat_cost) + SUM(system_estimated_lab_cost) + SUM(system_estimated_eqp_cost)),0)
												 INTO l_cost_estimate
												 FROM WIP_EAM_PERIOD_BALANCES
												 WHERE wip_entity_id =x_wip_entity_id;
											   EXCEPTION
											      WHEN NO_DATA_FOUND THEN
												  l_cost_estimate := 0;
											   END;


										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_pending_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released change event','Building parameter list');


										     INSERT INTO EAM_WO_WORKFLOWS
										     (WIP_ENTITY_ID,WF_ITEM_TYPE,WF_ITEM_KEY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
										     CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
										     VALUES
										     (x_wip_entity_id,l_workflow_name,l_event_key,SYSDATE,FND_GLOBAL.user_id,
										     SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id
										     );


										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(x_wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(i_org_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value =>'3' ,
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_old_system_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(l_old_eam_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => '3',
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_NAME',
													    p_value => l_workflow_name,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_PROCESS',
													    p_value => l_workflow_process,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'ESTIMATED_COST',
													    p_value => TO_CHAR(l_cost_estimate),
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Released Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released Event','After raising event');



								              IF(i_maintenance_source_id =1) THEN      --update text index for EAM workorders
										     EAM_TEXT_UTIL.PROCESS_WO_EVENT
										     (
										          p_event  => 'UPDATE',
											  p_wip_entity_id =>x_wip_entity_id,
											  p_organization_id =>i_org_id,
											  p_last_update_date  => SYSDATE,
											  p_last_updated_by  => FND_GLOBAL.user_id,
											  p_last_update_login =>FND_GLOBAL.login_id
										     );
									       END IF;

                                                          RETURN;
						END IF;
       END IF; -- end of check for workflow enabled




    -- Check the type of Work Order
    if (x_rebuild_jobs = 'Y') then -- Rebuild Work Order

      -- Check whether there is material issue or not
/* Bug 3637201 - manual rebuild wo on out of stores serials should also be completed to subinv */

	  /* Subinventory check is added for bug no :2911698  */
      if ((i_manual_rebuild_flag = 'N' and x_inventory_item_info(1).subinventory is not null)
     or (I_MANUAL_REBUILD_FLAG <> 'N' and i_parent_wip_entity_id is null and
x_inventory_item_info(1).subinventory is not null)) then  -- there is material issue

        l_statement := 55;
        x_statement := l_statement;

        -- return item back to inventory
        process_item(s_inventory_item_tbl => x_inventory_item_info,
                     s_org_id           => i_org_id,
                     s_wip_entity_id    => x_wip_entity_id,
                     s_qa_collection_id => x_qa_collection_id,
                     s_rebuild_item_id  => i_rebuild_item_id,
                     s_acct_period_id   => i_acct_period_id,
                     s_user_id          => x_user_id,
                     s_transaction_type => x_transaction_type,
                     s_project_id       => i_project_id,
                     s_task_id          => i_task_id,
                     s_commit           => x_commit,
                     errCode            => errCode,
                     errMsg             => errMsg,
                     x_statement        => l_statement);

         l_statement := 65;
         x_statement := l_statement;

        -- Check if there is an error to return item or not
        if(errCode <> 0) then
          ROLLBACK TO job_comp;
          return;
        end if;  -- end errCode check

      end if;  -- end material issue check

    elsif (x_rebuild_jobs = 'N') then -- Regular EAM Work Order


   -- Replaced the above cursor loop and cursor with the following query.
   -- for bug #2414513.
    begin
      SELECT '1'
        INTO child_job_var
        FROM dual
       WHERE EXISTS (SELECT '1'
                       FROM wip_discrete_jobs wdj, wip_entities we
                      WHERE wdj.wip_entity_id =  we.wip_entity_id
                        AND wdj.parent_wip_entity_id = x_wip_entity_id
                        AND wdj.manual_rebuild_flag = 'Y'
                        AND wdj.status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
                        WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED));
      if (child_job_var = '1') then
            ROLLBACK TO job_comp;
            fnd_message.set_name('EAM','EAM_CHILD_JOB_NOT_COMPLETE');
            errCode := 1;
            errMsg  := fnd_message.get;
            return;
      else
           null;
      end if;
    exception
     WHEN OTHERS THEN
     null;
    end;

    else
      ROLLBACK TO job_comp;
      fnd_message.set_name('EAM','EAM_INVALID_WORK_ORDER_TYPE');
      errCode := 1;
      errMsg := fnd_message.get;
      return;
    end if;  -- end work order check

    /* Bug # 5165813 : Allow shutdown info for rebuild wo also.
       Hence moved out of IF block mentioned above */

    -- Check whether the user provide Shutdown Information or not
    -- If the user provide shutdown information, insert the data to
    -- eam_asset_status_history table for history purpose
    if(x_shutdown_start_date is not null and
       x_shutdown_end_date is not null) then
        process_shutdown(s_asset_group_id  => i_asset_group_id,
                         s_organization_id => i_org_id,
                         s_asset_number    => i_asset_number,
                         s_start_date      => x_shutdown_start_date,
                         s_end_date        => x_shutdown_end_date,
                         s_user_id         => x_user_id,
			 s_maintenance_object_type => i_maintenance_object_type, -- Fix for Bug 3448770
                         s_maintenance_object_id   => i_maintenance_object_id,
                         s_wip_entity_id	   => x_wip_entity_id);

    end if;  -- end shutdown check




    -- initial the rest important variable
    i_status_type := WIP_CONSTANTS.COMP_CHRG;
    i_completion_date := x_actual_end_date;
    i_work_request_status := 6;  -- Work request complete

  elsif (x_transaction_type = 2) then -- Uncomplete Transaction
    -- Check the type of Work Order
    if (x_rebuild_jobs = 'Y') then -- Rebuild Work Order

      -- Check whether there is material issue or not
/* Bug 3637201 */
  	  /* Subinventory check is added for bug no :2911698  */
      if ((i_manual_rebuild_flag = 'N' and x_inventory_item_info(1).subinventory is not null) or
     (I_MANUAL_REBUILD_FLAG <> 'N' and i_parent_wip_entity_id is null and
x_inventory_item_info(1).subinventory is not null)) then  -- there is material issue
       l_statement := 50;
        -- get item back from inventory
        process_item(s_inventory_item_tbl => x_inventory_item_info,
                     s_org_id           => i_org_id,
                     s_wip_entity_id    => x_wip_entity_id,
                     s_qa_collection_id => x_qa_collection_id,
                     s_rebuild_item_id  => i_rebuild_item_id,
                     s_acct_period_id   => i_acct_period_id,
                     s_user_id          => x_user_id,
                     s_transaction_type => x_transaction_type,
                     s_project_id       => i_project_id,
                     s_task_id          => i_task_id,
                     s_commit           => x_commit,
                     errCode            => errCode,
                     errMsg             => errMsg,
                     x_statement        => l_statement);

        -- Check if there is an error to return item or not
        if(errCode <> 0) then
          ROLLBACK TO job_comp;
          return;
        end if; --end errCode check
      else
        -- get parent work order status
        begin   -- Handled the exception for bug#2762312
          select status_type into i_parent_status_type
          from   wip_discrete_jobs
          where  wip_entity_id = i_parent_wip_entity_id;
        exception
         when NO_DATA_FOUND then
         null;
        end;

        -- Check whether parent job already completed or not
        if(i_parent_status_type = WIP_CONSTANTS.COMP_CHRG) then
          ROLLBACK TO job_comp;
          fnd_message.set_name('EAM','EAM_PARENT_JOB_COMPLETED');
          errCode := 1;
          errMsg := fnd_message.get;
          return;
        else
          null;
        end if; --end parent job check
      end if;

    elsif (x_rebuild_jobs = 'N') then -- Regular EAM Work Order
      null;

    else
      ROLLBACK TO job_comp;
      fnd_message.set_name('EAM','EAM_INVALID_WORK_ORDER_TYPE');
      errCode := 1;
      errMsg := fnd_message.get;
      return;
    end if; --end work order check

    /* Bug # 5165813 : Allow shutdown info for rebuild wo also.
       Hence moved out of IF block mentioned above */
    UPDATE eam_asset_status_history
      SET enable_flag = 'N'
      	  , last_update_date  = SYSDATE
	  , last_updated_by   = FND_GLOBAL.user_id
          , last_update_login = FND_GLOBAL.login_id
      WHERE organization_id = i_org_id
      AND   wip_entity_id = x_wip_entity_id
      AND   operation_seq_num IS NULL
      AND (enable_flag = 'Y' OR enable_flag IS null);


 -- Update Meter ... Placed here as part of bug #2774571
 /*
 Last service info needs to be uncompleted for both the work orders.
 */
      if(i_maintenance_source_id = 1) then -- added to check whether work order is of 'EAM' or 'CRMO'.'EAM=1'
	      eam_pm_utils.update_pm_when_uncomplete(i_org_id, x_wip_entity_id);
      end if; -- end of source entity check

    -- initial the rest important variable
    i_status_type := WIP_CONSTANTS.RELEASED;
    i_completion_date := null;
    i_work_request_status := 4; -- Work request in process

  else   -- Other Transactions
    ROLLBACK TO job_comp;
    fnd_message.set_name('EAM','EAM_INVALID_TRANSACTION_TYPE');
    errCode := 1;
    errMsg := fnd_message.get;
    return;
  end if;  -- end transaction type check

 l_statement := 75;
 x_statement := l_statement;

  if (x_inventory_item_info.COUNT = 1) then
      l_subinventory := x_inventory_item_info(1).subinventory;
      l_locator := x_inventory_item_info(1).locator;
      l_lot_number := x_inventory_item_info(1).lot_number;
  end if;

  -- insert all information to eam_job_completion_txns table for tracking
  -- history
 -- check for the type of work order to insert the values appropriately
 -- The check is added as part of bug #2774571
 if(x_rebuild_jobs = 'N') then -- for normal work order
  insert into eam_job_completion_txns (transaction_id,
                                       transaction_date,
                                       transaction_type,
                                       wip_entity_id,
                                       organization_id,
                                       parent_wip_entity_id,
                                       reference,
                                       reconciliation_code,
                                       acct_period_id,
                                       qa_collection_id,
                                       asset_group_id,
                                       asset_number,
                                       asset_activity_id,
                                       actual_start_date,
                                       actual_end_date,
                                       actual_duration,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       request_id,
                                       program_application_id,
                                       program_id,
                                       program_update_date,
                                       completion_subinventory,
                                       completion_locator_id,
                                       lot_number,
                                       attribute_category,
                                       attribute1,
                                       attribute2,
                                       attribute3,
                                       attribute4,
                                       attribute5,
                                       attribute6,
                                       attribute7,
                                       attribute8,
                                       attribute9,
                                       attribute10,
                                       attribute11,
                                       attribute12,
                                       attribute13,
                                       attribute14,
                                       attribute15
                                       )
                               values (i_transaction_id,
                                       x_transaction_date,
                                       x_transaction_type,
                                       x_wip_entity_id,
                                       i_org_id,
                                       i_parent_wip_entity_id,
                                       x_reference,
                                       x_reconcil_code,
                                       i_acct_period_id,
                                       x_qa_collection_id,
                                       i_asset_group_id,
                                       i_asset_number,
                                       i_asset_activity_id,
                                       x_actual_start_date,
                                       x_actual_end_date,
                                       x_actual_duration,
                                       x_user_id,
                                       sysdate,
                                       x_user_id,
                                       sysdate,
                                       x_user_id,
                                       x_request_id,
                                       x_application_id,
                                       x_program_id,
                                       i_program_update_date,
                                       l_subinventory,
                                       l_locator,
                                       l_lot_number,
                                       x_attribute_category,
                                       x_attribute1,
                                       x_attribute2,
                                       x_attribute3,
                                       x_attribute4,
                                       x_attribute5,
                                       x_attribute6,
                                       x_attribute7,
                                       x_attribute8,
                                       x_attribute9,
                                       x_attribute10,
                                       x_attribute11,
                                       x_attribute12,
                                       x_attribute13,
                                       x_attribute14,
                                       x_attribute15
                                       );
else  -- rebuild work orders.
   insert into eam_job_completion_txns (transaction_id,
                                       transaction_date,
                                       transaction_type,
                                       wip_entity_id,
                                       organization_id,
                                       parent_wip_entity_id,
                                       reference,
                                       reconciliation_code,
                                       acct_period_id,
                                       qa_collection_id,
                                       asset_group_id,
                                       asset_number,
                                       asset_activity_id,
                                       actual_start_date,
                                       actual_end_date,
                                       actual_duration,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       request_id,
                                       program_application_id,
                                       program_id,
                                       program_update_date,
                                       completion_subinventory,
                                       completion_locator_id,
                                       lot_number,
                                       attribute_category,
                                       attribute1,
                                       attribute2,
                                       attribute3,
                                       attribute4,
                                       attribute5,
                                       attribute6,
                                       attribute7,
                                       attribute8,
                                       attribute9,
                                       attribute10,
                                       attribute11,
                                       attribute12,
                                       attribute13,
                                       attribute14,
                                       attribute15
                                       )
                               values (i_transaction_id,
                                       x_transaction_date,
                                       x_transaction_type,
                                       x_wip_entity_id,
                                       i_org_id,
                                       i_parent_wip_entity_id,
                                       x_reference,
                                       x_reconcil_code,
                                       i_acct_period_id,
                                       x_qa_collection_id,
                                       i_rebuild_item_id,    -- changed from asset_group_id to rebuild_item_id
                                       i_rebuild_serial_number, -- changed from asset_serial_number to rebuild_serial_number
                                       i_asset_activity_id,
                                       x_actual_start_date,
                                       x_actual_end_date,
                                       x_actual_duration,
                                       x_user_id,
                                       sysdate,
                                       x_user_id,
                                       sysdate,
                                       x_user_id,
                                       x_request_id,
                                       x_application_id,
                                       x_program_id,
                                       i_program_update_date,
                                       l_subinventory,
                                       l_locator,
                                       l_lot_number,
                                       x_attribute_category,
                                       x_attribute1,
                                       x_attribute2,
                                       x_attribute3,
                                       x_attribute4,
                                       x_attribute5,
                                       x_attribute6,
                                       x_attribute7,
                                       x_attribute8,
                                       x_attribute9,
                                       x_attribute10,
                                       x_attribute11,
                                       x_attribute12,
                                       x_attribute13,
                                       x_attribute14,
                                       x_attribute15
                                       );
end if; -- end insert check
  l_statement := 85;
  x_statement := l_statement;

  -- Update wip_discrete_jobs table
  update wip_discrete_jobs
     set last_update_date         = sysdate,
         last_updated_by          = x_user_id,
         last_update_login        = x_user_id,
         status_type              = i_status_type,
         date_completed           = i_completion_date,
         request_id               = x_request_id,
         program_application_id   = x_application_id,
         program_id               = x_program_id,
         program_update_date      = i_program_update_date
   where wip_entity_id            = x_wip_entity_id and
         organization_id          = i_org_id;


--Update Eam_Work_Order_Details with user_defined_status_id
  UPDATE EAM_WORK_ORDER_DETAILS
  SET last_update_date         = sysdate,
         last_updated_by          = x_user_id,
         last_update_login        = x_user_id,
	 user_defined_status_id=i_status_type
  WHERE wip_entity_id = x_wip_entity_id;

  l_statement := 95;
  x_statement := l_statement;

  -- Update wip_eam_work_requests table
  update wip_eam_work_requests
     set work_request_status_id = i_work_request_status,
         last_update_date         = sysdate,
         last_updated_by          = x_user_id,
         last_update_login        = fnd_global.login_id
   where wip_entity_id          = x_wip_entity_id;

   l_statement := 105;
   x_statement := l_statement;


  --Raise status changed event when a workorder is completed/uncompleted

	                 IF(l_workflow_enabled='Y'  AND (WF_EVENT.TEST(l_status_changed_event) <> 'NONE')  --if status change event enabled
					) THEN

										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_changed_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(x_wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(i_org_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(i_status_type),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value => TO_CHAR(i_status_type),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_old_system_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(l_old_eam_status),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Staus Changed Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status Changed Event','After raising event');
			END IF;   --end of check for status change event


									 IF(i_maintenance_source_id =1) THEN      --update text index for EAM workorders

										     EAM_TEXT_UTIL.PROCESS_WO_EVENT
										     (
										          p_event  => 'UPDATE',
											  p_wip_entity_id =>x_wip_entity_id,
											  p_organization_id =>i_org_id,
											  p_last_update_date  => SYSDATE,
											  p_last_updated_by  => FND_GLOBAL.user_id,
											  p_last_update_login =>FND_GLOBAL.login_id
										     );

									END IF;     --end of check for EAM workorders


  if (x_commit = fnd_api.g_true) then
    COMMIT; -- commit all changes
  end if;

END complete_work_order_generic;

END eam_completion;

/

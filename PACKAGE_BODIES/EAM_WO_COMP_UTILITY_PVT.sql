--------------------------------------------------------
--  DDL for Package Body EAM_WO_COMP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_COMP_UTILITY_PVT" AS
/* $Header: EAMVWCUB.pls 120.16 2006/08/21 09:21:03 sshahid noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_COMP_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_WO_COMP_UTILITY_PVT';


PROCEDURE Perform_Writes
 (
	p_eam_wo_comp_rec	IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )
  IS
	    l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Perform Writes'); END IF;


	IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE OR
	   p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE
	THEN
		Insert_Row
		(  p_eam_wo_comp_rec    => p_eam_wo_comp_rec
		 , x_mesg_token_Tbl     => l_mesg_token_tbl
		 , x_return_Status      => l_return_status
		 );
	END IF;

	x_return_status  := l_return_status;
	x_mesg_token_tbl := l_mesg_token_tbl;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	   EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion completed Perform Writes');
	END IF;

END Perform_Writes;

PROCEDURE insert_row
   (
	p_eam_wo_comp_rec     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status     OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl    OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
   )
   IS
    l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
   BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing insert row'); END IF;

	begin
		INSERT INTO EAM_JOB_COMPLETION_TXNS (
				       transaction_id,
                                       transaction_date,
                                       transaction_type,
                                       wip_entity_id,
                                       organization_id,
                                       parent_wip_entity_id,
                                       reference,
                                       reconciliation_code,
                                       acct_period_id,
                                       qa_collection_id,
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
                               VALUES (
				       p_eam_wo_comp_rec.transaction_id,
                                       p_eam_wo_comp_rec.transaction_date,
                                       decode(p_eam_wo_comp_rec.transaction_type,EAM_PROCESS_WO_PVT.G_OPR_COMPLETE,1,EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE,2),
                                       p_eam_wo_comp_rec.wip_entity_id,
                                       p_eam_wo_comp_rec.organization_id,
                                       p_eam_wo_comp_rec.parent_wip_entity_id,
                                       p_eam_wo_comp_rec.reference,
                                       p_eam_wo_comp_rec.reconciliation_code,
                                       p_eam_wo_comp_rec.acct_period_id,
                                       p_eam_wo_comp_rec.qa_collection_id,
                                       p_eam_wo_comp_rec.actual_start_date,
                                       p_eam_wo_comp_rec.actual_end_date,
                                       p_eam_wo_comp_rec.actual_duration,
                                       FND_GLOBAL.user_id,
                                       sysdate,
                                       FND_GLOBAL.user_id,
                                       sysdate,
                                       FND_GLOBAL.login_id,
                                       p_eam_wo_comp_rec.request_id,
                                       p_eam_wo_comp_rec.program_application_id,
                                       p_eam_wo_comp_rec.program_id,
                                       p_eam_wo_comp_rec.program_update_date,
                                       p_eam_wo_comp_rec.completion_subinventory,
                                       p_eam_wo_comp_rec.completion_locator_id,
                                       p_eam_wo_comp_rec.lot_number,
                                       p_eam_wo_comp_rec.attribute_category,
                                       p_eam_wo_comp_rec.attribute1,
                                       p_eam_wo_comp_rec.attribute2,
                                       p_eam_wo_comp_rec.attribute3,
                                       p_eam_wo_comp_rec.attribute4,
                                       p_eam_wo_comp_rec.attribute5,
                                       p_eam_wo_comp_rec.attribute6,
                                       p_eam_wo_comp_rec.attribute7,
                                       p_eam_wo_comp_rec.attribute8,
                                       p_eam_wo_comp_rec.attribute9,
                                       p_eam_wo_comp_rec.attribute10,
                                       p_eam_wo_comp_rec.attribute11,
                                       p_eam_wo_comp_rec.attribute12,
                                       p_eam_wo_comp_rec.attribute13,
                                       p_eam_wo_comp_rec.attribute14,
                                       p_eam_wo_comp_rec.attribute15
                                       );
            IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	      EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion completed insert row');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_SUCCESS;


	EXCEPTION
		WHEN OTHERS THEN

		    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		       EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion : insert row : inside exception : ' || SQLERRM);
		    END IF;

		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );
                     x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
	END;
END insert_row;

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

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	   EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Shutdown info ');
	END IF;

  -- get the asset_status_id from eam_asset_status_history_s sequence
	SELECT eam_asset_status_history_s.nextval
	  INTO i_asset_status_id
	  FROM dual;

	-- Enhancement Bug 3852846
	  UPDATE eam_asset_status_history
	     SET enable_flag = 'N'
	       , last_update_date  = SYSDATE
	       , last_updated_by   = FND_GLOBAL.user_id
	       , last_update_login = FND_GLOBAL.login_id
	   WHERE organization_id = s_organization_id
	     AND wip_entity_id = s_wip_entity_id
	     AND operation_seq_num IS NULL
	     AND (enable_flag is NULL OR enable_flag = 'Y')
	     AND maintenance_object_type = s_maintenance_object_type
	     AND maintenance_object_id = s_maintenance_object_id;

	INSERT INTO eam_asset_status_history
				      (asset_status_id,
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

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	   EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion completed Shutdown info processing');
	END IF;

END process_shutdown;

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
                       errMsg         OUT NOCOPY VARCHAR2
          ) IS

	  i_transaction_header_id	NUMBER;
	  i_transaction_temp_id		NUMBER;
	  i_serial_transaction_temp_id	NUMBER;
	  i_transaction_temp_id_s	NUMBER;
	  i_transaction_quantity	NUMBER;
	  i_primary_quantity		NUMBER;
	  i_transaction_action_id	NUMBER;
	  i_transaction_type_id		NUMBER;
	  i_transaction_source_type_id	NUMBER;
	  i_project_id			NUMBER;
	  i_task_id			NUMBER;
	  i_revision VARCHAR2(3)	:= null;
	  item				wma_common.Item;
	  l_revision_control_code	NUMBER := 1;
	  l_transaction_quantity	NUMBER;
	  l_initial_msg_count		NUMBER := 0;

BEGIN

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
    EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : Start ');
  END IF;

  -- prepare the data to insert into MTL_MATERIAL_TRANSACTIONS_TEMP,
  -- MTL_SERIAL_NUMBERS_TEMP, and MTL_TRANSACTION_LOTS_TEMP
  select mtl_material_transactions_s.nextval into i_transaction_header_id
  from   dual;


  -- get the item info
  item := wma_derive.getItem(s_rebuild_item_id, s_org_id, s_locator_id);
  if (item.invItemID is null) then
    fnd_message.set_name ('EAM', 'EAM_ITEM_DOES_NOT_EXIST');
    errCode := 1;
    errMsg  := fnd_message.get;
    return;
  end if; -- end item info check

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

     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : before bom_revisions.get_revision ');
     END IF;

      -- get bom_revision
      bom_revisions.get_revision (examine_type => 'ALL',
                                  org_id       => s_org_id,
                                  item_id      => s_rebuild_item_id,
                                  rev_date     => sysdate,
                                  itm_rev      => i_revision);

     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : after bom_revisions.get_revision ');
     END IF;
   end if;

  -- get transaction source type id
  i_transaction_source_type_id := inv_reservation_global.g_source_type_wip;

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

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : before inv_trx_util_pub.insert_line_trx');
  END IF;


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
  if (errCode <> 0) then
    return;
    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial : inv_trx_util_pub.insert_line_trx : ' || errMsg);
    END IF;
  end if;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : after inv_trx_util_pub.insert_line_trx');
  END IF;

 FOR i IN 1..s_lot_serial_tbl.COUNT LOOP

  if(s_transaction_type = 1) then  -- Complete Transaction
     l_transaction_quantity := s_lot_serial_tbl(i).quantity;
  else -- Uncomplete Transaction
     l_transaction_quantity := - s_lot_serial_tbl(i).quantity;
  end if;

  -- Check whether the item is under lot or serial control or not
  -- If it is, insert the data to coresponding tables
  if(item.lotControlCode = WIP_CONSTANTS.LOT) then

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : before inv_trx_util_pub.insert_lot_trx');
    END IF;

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

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : after inv_trx_util_pub.insert_lot_trx');
    END IF;

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

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : before inv_trx_util_pub.insert_ser_trx');
    END IF;

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

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : after inv_trx_util_pub.insert_ser_trx');
    END IF;

  else
    null;
  end if;  -- end serial control check

 end LOOP;

 l_initial_msg_count := FND_MSG_PUB.count_msg;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : before inv_lpn_trx_pub.process_lpn_trx');
  END IF;
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
/* need to work on this
if(errCode <> 0 and errMsg is not null) then
  eam_execution_jsp.add_message(p_app_short_name => 'EAM',p_msg_name =>
                                 'EAM_RET_MAT_PROCESS_MESSAGE',p_token1=> 'ERRMESSAGE',
								  p_value1 => errMsg);
end if;
*/
    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
        EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_lot_serial  : End');
    END IF;
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
                       errMsg         OUT NOCOPY VARCHAR2)IS
--                       x_statement    OUT NOCOPY NUMBER) IS
    l_subinventory VARCHAR2(30);
    l_locator VARCHAR2(30);
    l_lot_serial_rec Lot_Serial_Rec_Type;
    l_lot_serial_tbl Lot_Serial_Tbl_Type;
BEGIN

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
      EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_item  : Start ');
    END IF;

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
			   errMsg);
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

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
      EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.process_item  : End ');
    END IF;

END process_item;

PROCEDURE update_row (
	 p_eam_wo_comp_rec     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
        , x_return_status      OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)
IS
	l_asset_group_id		NUMBER;
	l_asset_number			VARCHAR2(30);
	i_maintenance_object_type	NUMBER;
        i_maintenance_object_id		NUMBER;
	i_work_request_status	        NUMBER;
	i_status_type			NUMBER;
	i_completion_date		DATE;
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(2000);

	x_inventory_item_rec		EAM_WorkOrderTransactions_PUB.Inventory_Item_Rec_Type;
        x_inventory_item_tbl		EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;

	i_parent_wip_entity_id          NUMBER;
	i_asset_group_id		NUMBER;
	i_asset_number			VARCHAR2(30);
	i_asset_activity_id		NUMBER;
	i_manual_rebuild_flag		VARCHAR2(1);
	i_rebuild_item_id		NUMBER;
	i_rebuild_serial_number		VARCHAR2(30);
	i_project_id			NUMBER;
	i_task_id			NUMBER;
	i_maintenance_source_id		NUMBER;
	i_open_past_period		BOOLEAN;

	i_acct_period_id		NUMBER;
	x_commit                        VARCHAR2(1) := fnd_api.g_false;
	errCode				NUMBER;
        errMsg				VARCHAR2(2000);
	l_statement			NUMBER := 0;
	l_Mesg_Token_Tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_out_Mesg_Token_Tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_Token_Tbl			EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
	l_txn_type			NUMBER;

	l_cmpl_sub			VARCHAR2(10);
	l_locator			NUMBER;
	l_lot				VARCHAR2(80);
BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing update_row'); END IF;

	  -- get some value from wip_discrete_jobs table
	  select parent_wip_entity_id,
		 asset_group_id,
		 asset_number,
		 primary_item_id,
		 manual_rebuild_flag,
		 rebuild_item_id,
		 rebuild_serial_number,
		 project_id,
		 task_id,
		 maintenance_object_source,   -- added as part of bug #2774571 to check whether the work order is of 'EAM' or 'CMRO'
		 maintenance_object_type,     -- Fix for Bug 3448770
		 maintenance_object_id
	    into i_parent_wip_entity_id,
		 i_asset_group_id,
		 i_asset_number,
		 i_asset_activity_id,
		 i_manual_rebuild_flag,
		 i_rebuild_item_id,
		 i_rebuild_serial_number,
		 i_project_id,
		 i_task_id,
		 i_maintenance_source_id,     -- added as part of bug #2774571 to check whether the work order is of 'EAM' or 'CMRO'
		 i_maintenance_object_type,   -- Fix for Bug 3448770
		 i_maintenance_object_id
	    from wip_discrete_jobs
	   where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

	   IF p_eam_wo_comp_rec.transaction_type = 4 THEN
		l_txn_type:=1;
	   ELSE
   		l_txn_type:=2;
	   END IF;

		invttmtx.tdatechk(p_eam_wo_comp_rec.organization_id,p_eam_wo_comp_rec.transaction_date,
			    i_acct_period_id,i_open_past_period);

		IF p_eam_wo_comp_rec.rebuild_job <> 'Y'  THEN
			i_rebuild_serial_number := i_asset_number;
			i_rebuild_item_id := i_asset_group_id;
		END IF;

		x_inventory_item_rec.subinventory := p_eam_wo_comp_rec.completion_subinventory;
		x_inventory_item_rec.locator := p_eam_wo_comp_rec.completion_locator_id;
		x_inventory_item_rec.lot_number := p_eam_wo_comp_rec.lot_number;
		x_inventory_item_rec.serial_number := i_rebuild_serial_number;
		x_inventory_item_rec.quantity := 1;
		x_inventory_item_tbl(1) := x_inventory_item_rec;

	IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
	 -- if (p_eam_wo_comp_rec.rebuild_job = 'Y') then -- Rebuild Work Order

	      -- Check whether there is material issue or not

	--      if (x_inventory_item_tbl(1).subinventory is not null) then  -- there is material issue

	      if (EAM_COMMON_UTILITIES_PVT.showCompletionFields(p_eam_wo_comp_rec.wip_entity_id) = 'Y'
		  and x_inventory_item_tbl(1).subinventory is not null) then -- there is material issue

		-- return item back to inventory
		process_item(s_inventory_item_tbl => x_inventory_item_tbl,
			     s_org_id           => p_eam_wo_comp_rec.organization_id,
			     s_wip_entity_id    => p_eam_wo_comp_rec.wip_entity_id,
			     s_qa_collection_id => p_eam_wo_comp_rec.qa_collection_id,
			     s_rebuild_item_id  => i_rebuild_item_id,
			     s_acct_period_id   => i_acct_period_id,
			     s_user_id          => fnd_global.user_id,
			     s_transaction_type => l_txn_type,
			     s_project_id       => i_project_id,
			     s_task_id          => i_task_id,
			     s_commit           => x_commit,
			     errCode            => errCode,
			     errMsg             => errMsg);
--			     x_statement        => l_statement);

		if(errCode <> 0) then
			    /* l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  p_eam_wo_comp_rec.wip_entity_id;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;
			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WO_COMPL_RETURN_ITEM'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );
			    l_mesg_token_tbl      := l_out_mesg_token_tbl;
			    x_mesg_token_tbl	  := l_mesg_token_tbl ;

		  	    x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
			    return; */

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                          (  p_message_name       => NULL
                           , p_message_text       => errMsg
                           , x_mesg_token_Tbl     => x_mesg_token_tbl
                          );
			   x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
			    return;

		end if;

	      end if;  -- end material issue check
	 -- -- end if;
        ELSE
	--  if (p_eam_wo_comp_rec.rebuild_job = 'Y') then -- Rebuild Work Order

	 -- Check whether there is material issue or not
	/* Bug 3637201 */
		  /* Subinventory check is added for bug no :2911698  */
		 begin

			select
			    completion_subinventory,
			    completion_locator_id,
			    lot_number
    			into l_cmpl_sub,
			     l_locator,
			     l_lot

			from EAM_JOB_COMPLETION_TXNS
			where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
			and transaction_type = 1
			and transaction_date = (select max(transaction_date) from EAM_JOB_COMPLETION_TXNS
						where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
						   and transaction_type =1);

				x_inventory_item_rec.subinventory := l_cmpl_sub;
				x_inventory_item_rec.locator := l_locator;
				x_inventory_item_rec.lot_number := l_lot;

				x_inventory_item_tbl(1) := x_inventory_item_rec;
		  exception when others then
			null;
		end;

	      if (x_inventory_item_tbl(1).subinventory is not null) then  -- there is material issue
		-- get item back from inventory

		process_item(s_inventory_item_tbl => x_inventory_item_tbl,
			     s_org_id           => p_eam_wo_comp_rec.organization_id,
			     s_wip_entity_id    => p_eam_wo_comp_rec.wip_entity_id,
			     s_qa_collection_id => p_eam_wo_comp_rec.qa_collection_id,
			     s_rebuild_item_id  => i_rebuild_item_id,
			     s_acct_period_id   => i_acct_period_id,
			     s_user_id          => fnd_global.user_id,
			     s_transaction_type => l_txn_type,
			     s_project_id       => i_project_id,
			     s_task_id          => i_task_id,
			     s_commit           => x_commit,
			     errCode            => errCode,
			     errMsg             => errMsg);
--			     x_statement        => l_statement);

		-- Check if there is an error to return item or not
		/* if(errCode <> 0) then
		  ROLLBACK TO job_comp;
		  return;
		end if; --end errCode check */
		if(errCode <> 0) then
			  /*  l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  p_eam_wo_comp_rec.wip_entity_id;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;
			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WO_COMPL_GET_ITEM'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );
			    l_mesg_token_tbl      := l_out_mesg_token_tbl;
			    x_mesg_token_tbl	  := l_mesg_token_tbl ;

		  	    x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
			    return;
				*/
			  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                          (  p_message_name       => NULL
                           , p_message_text       => errMsg
                           , x_mesg_token_Tbl     => x_mesg_token_tbl
                          );

			   x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;

			  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
                                EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.update_row  : Exception1 : '|| errMsg);
                          END IF;
			    return;
		end if;
	     end if;
	 --  end if;
        END IF;

	select system_status into i_status_type
	  from eam_wo_statuses_V
	 where status_id = p_eam_wo_comp_rec.user_status_id
	   and enabled_flag = 'Y';

	IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
		i_work_request_status := 6;  -- Work request complete
		i_completion_date     := p_eam_wo_comp_rec.actual_end_date;
	ELSE
		i_work_request_status := 4; -- Work request in process
		i_completion_date     := null;
	END IF;


	SELECT NVL(asset_group_id,rebuild_item_id),
	       NVL(asset_number,rebuild_serial_number),
	       maintenance_object_type,
	       maintenance_object_id
	  INTO l_asset_group_id ,
	       l_asset_number,
	       i_maintenance_object_type,
   	       i_maintenance_object_id
	  FROM WIP_DISCRETE_JOBS
	 WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;


	IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
						      eam_meters_util.update_last_service_dates_wo(
									p_wip_entity_id => p_eam_wo_comp_rec.wip_entity_id,
									p_start_date => p_eam_wo_comp_rec.actual_start_date,
									p_end_date => p_eam_wo_comp_rec.actual_end_date,
									x_return_status => x_return_status,
									x_msg_count => l_msg_count,
									x_msg_data => l_msg_data);

							if(x_return_status <> 'S') then
								    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
								  (  p_message_name       => NULL
								   , p_message_text       => l_msg_data
								   , x_mesg_token_Tbl     => x_mesg_token_tbl
								  );
								   x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
								   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
									EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.update_row  : Exception2 : '|| l_msg_data);
								   END IF;
								   return;
							end if;

						   --Bug#5451093..Moved code inside check for completion transaction as shutdown dates have to be processed
						              -- only during completion
							 /* Bug # 5165813 : Allow shutdown info for rebuild wo also */
						 IF p_eam_wo_comp_rec.shutdown_start_date IS NOT NULL AND
						    p_eam_wo_comp_rec.shutdown_end_date IS NOT NULL THEN
							if (l_asset_number is not null) then --If not Non-Serialized Rebuild
									 process_shutdown
									       ( s_asset_group_id  => l_asset_group_id,
										 s_organization_id => p_eam_wo_comp_rec.organization_id,
										 s_asset_number    => l_asset_number,
										 s_start_date      => p_eam_wo_comp_rec.shutdown_start_date,
										 s_end_date        => p_eam_wo_comp_rec.shutdown_end_date,
										 s_user_id         => fnd_global.user_id,
										 s_maintenance_object_type => i_maintenance_object_type, -- Fix for Bug 3448770
										 s_maintenance_object_id   => i_maintenance_object_id,
										 s_wip_entity_id	   => p_eam_wo_comp_rec.wip_entity_id
										);
							End IF;
						 END IF;
	END IF;  --end of check for transaction type=completion


	UPDATE WIP_DISCRETE_JOBS
	    SET  last_update_date         = sysdate,
		 last_updated_by          = FND_GLOBAL.user_id,
		 last_update_login        = FND_GLOBAL.login_id,
		 status_type              = i_status_type,
		 date_completed           = i_completion_date,
		 request_id               = p_eam_wo_comp_rec.request_id,
		 program_application_id   = p_eam_wo_comp_rec.program_application_id,
		 program_id               = p_eam_wo_comp_rec.program_id,
		 program_update_date      = p_eam_wo_comp_rec.program_update_date
	  WHERE  wip_entity_id            = p_eam_wo_comp_rec.wip_entity_id
	    AND  organization_id	  = p_eam_wo_comp_rec.organization_id;

	    UPDATE EAM_WORK_ORDER_DETAILS
	       SET USER_DEFINED_STATUS_ID  = p_eam_wo_comp_rec.user_status_id
	     WHERE wip_entity_id           = p_eam_wo_comp_rec.wip_entity_id
	       AND organization_id	   = p_eam_wo_comp_rec.organization_id ;

	-- Update wip_eam_work_requests table
	UPDATE WIP_EAM_WORK_REQUESTS
	   SET work_request_status_id   = i_work_request_status,
	       last_update_date         = sysdate,
	       last_updated_by          = fnd_global.user_id,
	       last_update_login        = fnd_global.login_id
	 WHERE wip_entity_id            = p_eam_wo_comp_rec.wip_entity_id;



	x_return_status := FND_API.G_RET_STS_SUCCESS;
      EXCEPTION
		WHEN OTHERS THEN
			EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
                        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
                            EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_UTILITY_PVT.update_row  : Exception3 : '|| SQLERRM);
                        END IF;

END update_row;


END EAM_WO_COMP_UTILITY_PVT;

/

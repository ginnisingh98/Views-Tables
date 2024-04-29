--------------------------------------------------------
--  DDL for Package Body EAM_MATERIALISSUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIALISSUE_PVT" AS
  /* $Header: EAMMATTB.pls 120.5.12010000.8 2011/01/25 11:07:57 vchidura ship $*/
  g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_materialissue_pvt';
  g_debug    CONSTANT  VARCHAR2(1):=NVL(fnd_profile.value('APPS_DEBUG'),'N');
procedure Fork_Logic(  p_api_version   IN  NUMBER   ,
  p_init_msg_list             IN      VARCHAR2,
  p_commit                    IN      VARCHAR2 ,
  p_validation_level          IN      NUMBER   ,
  x_return_status             OUT     NOCOPY VARCHAR2  ,
  x_msg_count                 OUT     NOCOPY NUMBER,
  x_msg_data                  OUT     NOCOPY VARCHAR2,
  p_wip_entity_type           IN      NUMBER,
  p_organization_id           IN      NUMBER,
  p_wip_entity_id             IN      NUMBER,
  p_operation_seq_num         IN      NUMBER   ,
  p_inventory_item_id         IN      NUMBER  ,
  p_revision                  IN      VARCHAR2 := null,
  p_requested_quantity        IN      NUMBER ,
  p_source_subinventory       IN      VARCHAR2 ,
  p_source_locator            IN      VARCHAR2 ,
  p_lot_number                IN      VARCHAR2 ,
  p_fm_serial                 IN      VARCHAR2 ,
  p_to_serial                 IN      VARCHAR2,
  p_reasons                   IN      VARCHAR2 ,
  p_reference                 IN      VARCHAR2  ,
  p_date                      IN       date,
  p_rebuild_item_id           IN     Number,
  p_rebuild_item_name         IN     varchar2,
  p_rebuild_serial_number     IN     Varchar2,
  p_rebuild_job_name          IN OUT NOCOPY  Varchar2 ,
  p_rebuild_activity_id       IN     Number,
  p_rebuild_activity_name     IN     varchar2,
  p_user_id                   IN    Number,
  p_inventory_item            IN    varchar2 := null,  --Added for bug 8661513
  p_locator_name              IN     varchar2 := null)  --Added for bug 8661513
  is

  l_api_name                CONSTANT VARCHAR2(30) := 'Fork_Logic';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_module    constant varchar2(60) := 'eam.plsql.'||l_full_name;
  l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
  l_log  constant boolean := FND_LOG.LEVEL_UNEXPECTED >= l_current_log_level ;
  l_plog constant boolean := l_log and FND_LOG.LEVEL_PROCEDURE >=l_current_log_level ;
  l_slog constant boolean := l_plog and FND_LOG.LEVEL_STATEMENT >= l_current_log_level ;


  l_material_issue_by_mo  varchar2(1);
  l_project_id number := null;
  l_task_id number := null;
  l_issue_by_mo boolean := true;
  l_inventory_item_name  mtl_system_items_b_kfv.concatenated_segments%type := null;
  l_quantity   Number;
  l_primary_uom_code   mtl_system_items_b_kfv.primary_uom_code%type;
  l_serial_number_control_code  Number;
  l_revision_qty_control_code NUMBER;
  l_lot_control_code Number;
  l_onhand_quantity NUMBER;
  l_is_serial_control BOOLEAN;
  l_is_lot_control BOOLEAN;
  l_is_revision_control BOOLEAN;
  l_reason_id Number;
  x_err_flag Number;
  x_error_msg  Varchar2(200);
  x_tmp_id    Number;
  l_inventory_item_id  Number;
  l_organization_id Number;
  l_source_locator_id Number;
  l_source_subinventory Varchar2(2000);
  l_ret_status_qoh VARCHAR2(2000);
  l_msg_count_qoh NUMBER;
  l_msg_data_qoh VARCHAR2(2000);
  l_rqoh NUMBER;
  l_qr  NUMBER;
  l_qs  NUMBER;
  l_att NUMBER;
  l_atr NUMBER;
  x_wip_ret_status  Varchar2(200);
  x_error_mssg1  Varchar2(200);
  l_eam_one_step_mat_issue   varchar2(1);
  l_rebuild_item_id number := null;
  l_rebuild_activity_id number := null;
  l_rebuild_job_name mtl_transactions_interface.rebuild_job_name%type;
  l_rebuild_job_temp   Number;
  l_prefix  wip_eam_parameters.easy_work_order_prefix%type;
  l_lot_number     Varchar2(80);
  l_fm_serial_number  Varchar2(30);
  l_to_serial_number  Varchar2(30);
  l_tx_hdr_id number := null;
  l_tx_count number := 0;
  l_txmgr_ret_code number := -1;
  l_num_valid_serials number;
  l_num_range_serials number;
  l_material    VARCHAR2(40);
  l_neg_inv_receipt_code number;
  l_within_open_period varchar2(1):= 'N';
  l_inventory_item_id_wl Number; --8667921/8661513 to derive the inventory_item_id for wireless application
  l_source_locator_wl Number; --8667921/8661513 to derive the inventory_item_id for wireless application
  l_rebuild_item_id_wl Number; --8667921/8661513 to derive the inventory_item_id for wireless application
   l_sec_sta_valid boolean;
BEGIN

	--derive the inventory_item_id in case of wireless (for bug 8661513)
 	     IF (p_inventory_item is not null and p_inventory_item_id is null) THEN
 	        select Inventory_item_id into l_inventory_item_id_wl
 	        from mtl_system_items
 	        where SEGMENT1 = p_inventory_item
 	        and ORGANIZATION_ID = p_organization_id;
 	     END IF;

 	--derive the locator_id (p_source_locator) in case of wireless--for bug 8661513
 	     IF(p_locator_name is not null and p_source_locator is null) THEN
 	        SELECT  inventory_location_id into l_source_locator_wl
 	        FROM mtl_item_locations_kfv
 	        WHERE organization_id = p_organization_id
 	        AND subInventory_code = p_source_subinventory
 	        AND NVL(disable_date,TRUNC(sysdate)+1) > TRUNC(sysdate)
 	        AND concatenated_segments = p_locator_name;
 	     END IF; -- end of deriving locator id


 	--derive the rebuild_item_id (p_rebuild_item_id) in case of wireless--for bug 8661513
 	      IF(p_rebuild_item_name is not null and p_rebuild_item_id is null) THEN
 	        select Inventory_item_id into l_rebuild_item_id_wl
 	        from mtl_system_items
 	        where SEGMENT1 = p_rebuild_item_name
 	        and ORGANIZATION_ID = p_organization_id;
 	     END IF; -- end of rebuild id

  SAVEPOINT	fork_logic;
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
    l_api_name,	G_PKG_NAME ) THEN
  	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	  FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
	if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_full_name || '('
    || 'p_commit='|| p_commit ||','
    || 'p_wip_entity_type='|| p_wip_entity_type || ','
    || 'p_organization_id='|| p_organization_id || ','
    || 'p_wip_entity_id='|| p_wip_entity_id || ','
    || 'p_operation_seq_num='|| p_operation_seq_num || ','
    || 'p_inventory_item_id='|| p_inventory_item_id || ','
    || 'p_reasons='|| p_reasons || ','
    || 'p_reference='|| p_reference || ','
    || 'p_date='|| p_date || ','
    || 'p_rebuild_item_id='|| p_rebuild_item_id || ','
    || 'p_rebuild_item_name='|| p_rebuild_item_name || ','
    || 'p_rebuild_serial_number='|| p_rebuild_serial_number || ','
    || 'p_rebuild_job_name='|| p_rebuild_job_name || ','
    || 'p_rebuild_activity_id='|| p_rebuild_activity_id || ','
    || 'p_rebuild_activity_name='|| p_rebuild_activity_name || ','
    || 'p_user_id='|| p_user_id || ','
    || 'p_requested_quantity='|| p_requested_quantity || ','
    || 'p_source_subinventory='|| p_source_subinventory ||','
    || 'p_source_locator='|| p_source_locator ||','
    || 'p_lot_number='|| p_lot_number ||','
    || 'p_fm_serial='|| p_fm_serial ||','
    || 'p_to_serial='|| p_to_serial ||','
    || ')');
  end if;

  select nvl(material_issue_by_mo,'Y'), project_id, task_id
    into l_material_issue_by_mo, l_project_id, l_task_id
    from wip_discrete_jobs where
    wip_entity_id=p_wip_entity_id
    and organization_id=p_organization_id;
  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'l_material_issue_by_mo=' || l_material_issue_by_mo);
  end if;
  if (l_project_id is null) then l_project_id := fnd_api.G_MISS_NUM;
  end if;
  if (l_task_id is null) then l_task_id := fnd_api.G_MISS_NUM;
  end if;
  if (l_material_issue_by_mo = 'N')  then
    l_issue_by_mo := false;
  end if;

  --selecting the item name,UOM,serial_control_code
  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Getting serial, lot control codes');
  end if;
  --fix for 3454251.added code to fetch material name
  select primary_uom_code,
    serial_number_control_code ,
    lot_control_code,
    concatenated_segments,
    REVISION_QTY_CONTROL_CODE
  into
    l_primary_uom_code ,
    l_serial_number_control_code,
    l_lot_control_code,
    l_material,
    l_revision_qty_control_code
  from mtl_system_items_b_kfv
  where inventory_item_id= nvl(p_inventory_item_id,l_inventory_item_id_wl) --bug 8661513
  and organization_id=p_organization_id;

  l_inventory_item_id:= nvl(p_inventory_item_id,l_inventory_item_id_wl); --bug 8661513
  l_organization_id:=p_organization_id;
  l_source_subinventory:=p_source_subinventory;
  -- Added to fix bug# 3579816
  l_source_locator_id := to_number(nvl(p_source_locator,l_source_locator_wl));--bug 8661513

  l_lot_number:=p_lot_number;
  l_fm_serial_number:=p_fm_serial;
  l_to_serial_number:=p_to_serial;

  --if item is not lot controlled then
  --set lot number to null value
  if (l_lot_control_code=1)   then   --(2)
  l_lot_number:=null;
  l_is_lot_control:=FALSE;
    ELSE
  l_is_lot_control:=TRUE;
  end if;  ---(2)

 --start for bug 11669073
   IF(l_serial_number_control_code=1) THEN
 	     l_is_serial_control :=FALSE;
 	   ELSE
 	     l_is_serial_control:= TRUE;
 	   END IF;

 	   IF(l_revision_qty_control_code=1) THEN
 	    l_is_revision_control:=FALSE;
 	   ELSE
 	    l_is_revision_control:=TRUE;
 	   END IF;


 	 BEGIN

 	 inv_quantity_tree_pub.query_quantities(
 	         p_api_version_number =>1.0,
 	         p_organization_id=>p_organization_id,
 	         p_inventory_item_id=>p_inventory_item_id,
 	         p_tree_mode=>inv_quantity_tree_pub.g_transaction_mode,
 	         p_is_revision_control=>l_is_revision_control,
 	         p_is_lot_control=>l_is_lot_control,
 	         p_is_serial_control=>l_is_serial_control,
 	         p_revision=> p_revision,
 	         p_lot_number=> p_lot_number,
 	         p_subinventory_code=> p_source_subinventory,
 	         p_locator_id=> l_source_locator_id,
 	         x_qoh=> l_onhand_quantity,
 	   x_rqoh=>l_rqoh,
 	   x_qr  =>l_qr,
 	   x_qs  =>l_qs,
 	   x_att =>l_att,
 	   x_atr =>l_atr,
 	         x_return_status=> l_ret_status_qoh,
 	   x_msg_count=>  l_msg_count_qoh,
 	   x_msg_data =>l_msg_data_qoh
 	 );

 	 IF(l_ret_status_qoh = FND_API.G_RET_STS_UNEXP_ERROR OR
 	                   l_ret_status_qoh = FND_API.G_RET_STS_ERROR
 	                   ) THEN

 	      x_return_status := FND_API.G_RET_STS_ERROR;
 	            fnd_message.set_name('EAM', 'EAM_INV_ONHAND_NOT_DETERMINED');
 	      fnd_message.set_token('MATERIAL',l_material);
 	      fnd_msg_pub.add;
 	            fnd_msg_pub.Count_And_Get(
 	           p_count                 =>      x_msg_count,
 	       p_data            =>      x_msg_data);
 	      return;


 	 END IF;


 	 exception
 	     when others then
 	     x_return_status := fnd_api.g_ret_sts_unexp_error;

 	 END;



 	   IF(l_onhand_quantity IS NULL) THEN
 	     l_onhand_quantity:=0;
 	   END IF;


 	   select NEGATIVE_INV_RECEIPT_CODE
 	   into l_neg_inv_receipt_code
 	   from mtl_parameters
 	   where organization_id = p_organization_id;

 	   IF l_neg_inv_receipt_code = 2 THEN

 	     IF (p_requested_quantity > l_onhand_quantity) THEN

 	     x_return_status := FND_API.G_RET_STS_ERROR;
 	            fnd_message.set_name('EAM', 'EAM_INV_QUANTITY_NEGATIVE');
 	      fnd_message.set_token('OPERATION',p_operation_seq_num);
 	      fnd_message.set_token('MATERIAL',l_material);
 	            fnd_message.set_token('ONHAND',l_onhand_quantity);
 	      fnd_msg_pub.add;
 	            fnd_msg_pub.Count_And_Get(
 	           p_count                 =>      x_msg_count,
 	       p_data            =>      x_msg_data);
 	      return;

 	    END IF;
 	  END IF;


 	 BEGIN
 	         select
 	         'Y'
 	         into l_within_open_period
 	         FROM
 	         org_acct_periods
 	         WHERE
 	         organization_id=p_organization_id
 	         and period_close_date is null
 	         and p_date between
 	         period_start_date and schedule_close_date + 1 - (1/(24*3600));
 	         EXCEPTION
 	            WHEN NO_DATA_FOUND THEN
 	                   l_within_open_period:='N';
 	 END;

 	 IF (l_within_open_period<>'Y') THEN
 	          x_return_status := FND_API.G_RET_STS_ERROR;
 	          fnd_message.set_name('EAM', 'EAM_ISSUE_TXN_NOT_OPEN_PERIOD');
 	      fnd_message.set_token('OPERATION',p_operation_seq_num);
 	      fnd_message.set_token('MATERIAL',l_material);
 	      fnd_msg_pub.add;
 	            fnd_msg_pub.Count_And_Get(
 	           p_count                 =>      x_msg_count,
 	       p_data            =>      x_msg_data);
 	      return;
 	 END IF;

--end for bug 11669073

 --fix for security validation rules..Bug 8649230

 	 IF(l_source_locator_id IS NOT NULL) THEN
 	    l_sec_sta_valid :=     fnd_flex_keyval.validate_ccid(
 	                 appl_short_name              => 'INV'
 	               , key_flex_code                => 'MTLL'
 	               , structure_number             => 101
 	               , combination_id               => l_source_locator_id--to_number(name_in('MTL_TRX_LINE.LOCATOR_ID'))
 	               , displayable                  => 'ALL'
 	               , data_set                     => p_organization_id--to_number(name_in('PARAMETER.ORG_ID'))
 	               , vrule                        => NULL
 	               , security                     => 'ENFORCE'--'IGNORE'
 	               , get_columns                  => NULL
 	               , resp_appl_id                 => NULL
 	               , resp_id                      => NULL
 	               , user_id                      => NULL
 	               );

 	       IF NOT (l_sec_sta_valid )    THEN
 	              x_return_status := FND_API.G_RET_STS_ERROR;
 	              fnd_message.set_name('EAM', 'EAM_INV_SEC_LOC_RULE');
 	              fnd_message.set_token('OPERATION',p_operation_seq_num);
 	              fnd_message.set_token('MATERIAL',l_material);
 	              fnd_message.set_token('LOCATOR',l_source_locator_id);
 	              fnd_msg_pub.add;
 	              fnd_msg_pub.Count_And_Get(
 	              p_count                 =>      x_msg_count,
 	              p_data             =>      x_msg_data);
 	          return;
 	       END IF;
 	 END IF;

--fix for 3454251.raise an error message if quantity to be issued is negative or zero

    if(p_requested_quantity<=0) then
      x_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('EAM', 'EAM_REQUESTED_QUAN_NEG_ZERO');
     fnd_message.set_token('OPERATION',p_operation_seq_num);
     fnd_message.set_token('MATERIAL',l_material);
     fnd_msg_pub.add;
	   fnd_msg_pub.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
     return;
    end if;
--if the transaction date is in future raise an error message
   if(p_date > sysdate) then
    x_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('EAM', 'EAM_TRANS_DATE_FUTURE');
     fnd_message.set_token('OPERATION',p_operation_seq_num);
     fnd_message.set_token('MATERIAL',l_material);
     fnd_msg_pub.add;
	   fnd_msg_pub.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
     return;
   end if;

  --if item is not serial controlled then
  --set serial numbers to be null

  if (l_serial_number_control_code=1)  then   --(3)
    l_fm_serial_number:=null;
    l_to_serial_number:=null;
  else
    l_num_range_serials := inv_serial_number_pub.get_serial_diff(
      l_fm_serial_number, l_to_serial_number);
    if (l_num_range_serials <> p_requested_quantity) then
     x_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('EAM', 'EAM_SERIAL_RANGE_QTY_MISMATCH');
     fnd_message.set_token('OPERATION',p_operation_seq_num);
     fnd_message.set_token('MATERIAL',l_material);
     fnd_message.set_token('QTY_RANGE',l_num_range_serials);
     fnd_message.set_token('FM_SERIAL',l_fm_serial_number);
     fnd_message.set_token('TO_SERIAL',l_to_serial_number);
     fnd_message.set_token('QTY_ENTERED',p_requested_quantity);
     fnd_msg_pub.add;
	   fnd_msg_pub.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
     return;
    end if;



    SELECT COUNT(serial_number)
    INTO l_num_valid_serials
    FROM mtl_serial_numbers msn
    WHERE msn.inventory_item_id = l_inventory_item_id
    and msn.current_organization_id = l_organization_id
    and msn.current_subinventory_code = l_source_subinventory
    and (msn.group_mark_id is null or msn.group_mark_id = -1)
    and (msn.revision is null or msn.revision = p_revision)
    and (msn.lot_number is null or msn.lot_number = l_lot_number)
    and msn.current_status=3
    AND msn.serial_number between l_fm_serial_number and l_to_serial_number
    AND LENGTH(msn.serial_number) = LENGTH(l_fm_serial_number);

	  if (l_num_valid_serials <> p_requested_quantity) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('EAM', 'EAM_N_SERIALS_UNAVAILABLE');
      fnd_message.set_token('OPERATION',p_operation_seq_num);
      fnd_message.set_token('MATERIAL',l_material);
      fnd_message.set_token('NUM_UNAVAILABLE', p_requested_quantity - l_num_valid_serials);
      fnd_msg_pub.add;
      fnd_msg_pub.Count_And_Get(
      p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
      return;
    end if;
  end if;  --(3) of if (l_serial_number_control_code=1)



begin    ----------------(1)
--quantity signed is reversed when values are inserted in MTI
l_quantity:=-1*p_requested_quantity;
begin
  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Calling PROCESSMTLTXN');
  end if;
savepoint before_insert_mti;
--inserting values into MTI Table

eam_mtl_txn_process.PROCESSMTLTXN(
  p_txn_header_id    =>NULL,--can be null
  p_item_id          =>l_inventory_item_id,
  p_item          => l_inventory_item_name,--concatenated_segment
  p_revision         => p_revision,
  p_org_id          =>l_organization_id,
  p_trx_action_id    => 1,-- issue from inventory to wip
  p_subinv_code     =>l_source_subinventory ,
  p_tosubinv_code   => NULL,
  p_locator_id      =>l_source_locator_id,
  p_locator         => NULL,
  p_tolocator_id    =>Null,
  p_trx_type_id     =>35,
  p_trx_src_type_id  =>5,
  p_trx_qty         => l_quantity,
  p_pri_qty          => l_quantity ,
  p_uom              => l_primary_uom_code,
  p_date             => p_date,
  p_reason_id        =>l_reason_id,
  p_reason           => p_reasons,
  p_user_id          =>p_user_id ,
  p_trx_src_id       =>p_wip_entity_id,
  x_trx_temp_id      =>x_tmp_id ,
  p_operation_seq_num  =>p_operation_seq_num,
  p_wip_entity_type    =>wip_constants.eam,
  p_trx_reference      =>p_reference,
  p_negative_req_flag  =>1,
  p_serial_ctrl_code   =>l_serial_number_control_code,--1
  p_lot_ctrl_code     => l_lot_control_code,--1
  p_from_ser_number    =>l_fm_serial_number,
  P_to_ser_number      =>l_to_serial_number,
  p_lot_num            =>l_lot_number,
  p_wip_supply_type    =>1,
  p_subinv_ctrl      =>null,
  p_locator_ctrl      =>null,
  p_wip_process        =>0, -- determines to call WIP Transaction API
                                            -- 0 -> No call,1 -> Call
  p_dateNotInFuture   =>1,    -- 1 --> do check,0 --> no check
  x_error_flag        =>x_err_flag,           -- returns 0 if no error , >1 if any error .
  x_error_mssg       =>x_error_msg );


  if (x_err_flag = 1) then
   eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => x_error_msg);
   x_return_status := FND_API.G_RET_STS_ERROR;
   return;
  elsif (x_err_flag = 2) then
   eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_CANNOT_DELETE_RESOURCE',
                                  p_token1=>'EAM_RET_MAT_PROCESS_MESSAGE', p_value1=>x_error_msg);
   x_return_status := FND_API.G_RET_STS_ERROR;
   return;
  end if; -- end of x_error_flag check

   exception
    when others then --some unhandled exception occurred. rollback everything.
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    rollback to before_insert_mti;
   return ;
    end;

 -- dbms_output.put_line('transaction_interface_id  ' ||  x_tmp_id);
 --dbms_output.put_line('x_error_flag  ' ||  x_err_flag);
 --dbms_output.put_line('x-error_mssg  ' ||  x_error_msg);

  if ((x_tmp_id is not null))  then
  begin
   if  ((nvl(p_rebuild_item_id,l_rebuild_item_id_wl) is not null) or (p_rebuild_item_name is not null))  then --changed for bug 8661513
  begin
    l_rebuild_item_id := nvl(p_rebuild_item_id,l_rebuild_item_id_wl); --changed for bug 8661513
     if (nvl(p_rebuild_item_id,l_rebuild_item_id_wl) is null) then --changed for bug 8661513
      select msi.inventory_item_id into l_rebuild_item_id
      from mtl_system_items_b_kfv msi, mtl_parameters mp
      where concatenated_segments = p_rebuild_item_name
      and msi.organization_id = mp.organization_id
	  and mp.maint_organization_id = p_organization_id
	  and eam_item_type = 3 --3 for rebuild
	  and rownum = 1;
    end if;
    if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Inserting rebuild item id: '|| l_rebuild_item_id);
    end if;
    update mtl_transactions_interface
    set rebuild_item_id=l_rebuild_item_id
    where transaction_interface_id=  x_tmp_id;
  end;
  end if;

  if (p_rebuild_serial_number is not null) then
  begin
  --dbms_output.put_line('p_rebuild_serial_number  ' ||  p_rebuild_serial_number);
  update mtl_transactions_interface
  set rebuild_serial_number=p_rebuild_serial_number
  where transaction_interface_id=  x_tmp_id;
  end;
  end if;

  if ((p_rebuild_activity_id is not null) or (p_rebuild_activity_name is not null)) then
  begin
    l_rebuild_activity_id := p_rebuild_activity_id;
    if (p_rebuild_activity_id is null) then -- activity name must be non null
      select inventory_item_id into l_rebuild_activity_id
      from mtl_system_items_b_kfv
      where concatenated_segments = p_rebuild_activity_name
      and organization_id = p_organization_id
      and eam_item_type = 2; --2 for activity
    end if;
    if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Inserting rebuild activity id: '|| l_rebuild_activity_id);
    end if;
    update mtl_transactions_interface
    set rebuild_activity_id=l_rebuild_activity_id
    where transaction_interface_id=  x_tmp_id;
  end;
  end if;

  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'inserting rebuild job');
  end if;
  if ((p_rebuild_job_name     is null) and (l_rebuild_item_id is not null))then

   /* BUG#2988552  wip_job_number_s sequence is to be used for work order name*/
   SELECT
     wip_job_number_s.nextval INTO l_rebuild_job_temp
   FROM
     DUAL;

   l_rebuild_job_name:=   l_rebuild_job_temp ;
   else
     l_rebuild_job_name := p_rebuild_job_name;
   end if;

   p_rebuild_job_name := l_rebuild_job_name;

   --dbms_output.put_line('p_rebuild_job_name  ' || l_rebuild_job_name);
   update mtl_transactions_interface
   set rebuild_job_name=l_rebuild_job_name
   where transaction_interface_id=  x_tmp_id;

  if (p_reference is not null) then
  begin
  update mtl_transactions_interface
  set transaction_reference=p_reference
  where transaction_interface_id=  x_tmp_id;
  end;
  end if;

  if (l_reason_id is not null) then
  begin
  --dbms_output.put_line('l_reason_id  ' || l_reason_id);
  update mtl_transactions_interface
  set reason_id=l_reason_id
  where transaction_interface_id=  x_tmp_id;
  end;
  end if;

  select transaction_header_id into l_tx_hdr_id
  from mtl_transactions_interface
  where transaction_interface_id = x_tmp_id;


  -- only call txn processor if online processing. 4(form level) is treated as 1.
  if (EAM_MATERIALISSUE_PVT.get_tx_processor_mode() in  (1,4)) then
    if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Calling INV_TXN_MANAGER_PUB.process_Transactions');
    end if;
    l_txmgr_ret_code := INV_TXN_MANAGER_PUB.process_Transactions(
       p_api_version => 1.0,
       p_header_id => l_tx_hdr_id,
       p_table => 1, -- 1 for MTI, 2 for MMTT
       x_return_status => x_wip_ret_status,
       x_msg_count => x_msg_count,
       x_trans_count => l_tx_count,
       x_msg_data => x_error_mssg1);
    if (l_sLog) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'INV_TXN_MANAGER_PUB finished with return code='|| l_txmgr_ret_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'INV_TXN_MANAGER_PUB finished with return status='|| x_wip_ret_status);
    end if;

		     if(x_wip_ret_status = FND_API.G_RET_STS_UNEXP_ERROR OR
		  x_wip_ret_status = FND_API.G_RET_STS_ERROR
		  ) then

		 BEGIN
           SELECT error_explanation into  x_error_mssg1
           FROM mtl_transactions_interface
           WHERE TRANSACTION_header_id =  l_tx_hdr_id  ;
         EXCEPTION
           WHEN others THEN
             x_error_mssg1:='Error from Inventory transaction manager';
         END;

		  rollback to before_insert_mti;
		  x_return_status := x_wip_ret_status;
		  if x_error_mssg1 is not null then
		      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_API_MESG',
                                  p_token1=>'MESG', p_value1=>x_error_mssg1);
		  end if;
		return;
		--fix for 3454251.error out even if the return code is -1
		elsif(l_txmgr_ret_code=-1) then
		   BEGIN
             SELECT error_explanation into  x_error_mssg1
             FROM mtl_transactions_interface
             WHERE TRANSACTION_header_id =  l_tx_hdr_id  ;
           EXCEPTION
             WHEN others THEN
               x_error_mssg1:='Error from Inventory transaction manager';
           END;
		   rollback to before_insert_mti;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  if x_error_mssg1 is not null then
		      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_API_MESG',
                                  p_token1=>'MESG', p_value1=>x_error_mssg1);
		  end if;
		  return;
		end if;

  end if; -- of if tx process mode is 1


end;

end if;

end;-----{1}

  if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
  'End of ' || l_full_name );
  end if;
	-- End of API body.

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit )
	   AND x_return_status = FND_API.g_RET_STS_SUCCESS THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
	  p_count         	=>      x_msg_count,
    p_data          	=>      x_msg_data);
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK TO fork_logic;
    if (l_log) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module, 'Exception occured' );
    end if;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);

  end Fork_Logic;


PROCEDURE process_mmtt(
  p_api_version               IN      NUMBER,
  p_init_msg_list             IN      VARCHAR2,
  p_commit                    IN      VARCHAR2,
  p_validation_level          IN      NUMBER,
  x_return_status             OUT     NOCOPY VARCHAR2,
  x_msg_count                 OUT     NOCOPY NUMBER,
  x_msg_data                  OUT     NOCOPY VARCHAR2,
  p_trx_tmp_id                IN  NUMBER) IS

  l_api_name                CONSTANT VARCHAR2(30) := 'process_mmtt';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_module                  CONSTANT VARCHAR2(60) := 'eam.plsql.'||l_full_name;
  l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
  l_log            boolean := FND_LOG.LEVEL_UNEXPECTED >= l_current_log_level  ;
  l_plog           boolean := l_log and FND_LOG.LEVEL_PROCEDURE >= l_current_log_level  ;
  l_slog           boolean := l_plog and FND_LOG.LEVEL_STATEMENT >= l_current_log_level  ;

  l_msg_data VARCHAR2(50);
  l_return_status VARCHAR2(2000);
  l_header_id number := null;
  NO_ACCT_PERIOD_EXC EXCEPTION;     -- Added for bug 4041420
  l_acct_period_id number := null;  -- Added for bug 4041420

BEGIN
  if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_full_name || '('
    || 'p_init_msg_list='|| p_init_msg_list ||','
    || 'p_commit='|| p_commit ||','
    || 'p_trx_tmp_id='|| to_number(p_trx_tmp_id) || ','
    || ')');
  end if;
	-- Standard Start of API savepoint
  SAVEPOINT	PROCESS_MMTT;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
    l_api_name,	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
  l_msg_data  := NULL;
  l_return_status := NULL;

 /* Added for bug 4041420 - Start */
     SELECT NVL(max(oap.acct_period_id), -1)
     INTO l_acct_period_id
     FROM org_acct_periods oap,
          mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id =  p_trx_tmp_id
     AND oap.organization_id = mmtt.organization_id
     AND oap.open_flag = 'Y'
     AND trunc(SYSDATE)
     BETWEEN trunc(oap.period_start_date) AND
             trunc(oap.schedule_close_date);

     IF (l_acct_period_id = -1) THEN
         raise NO_ACCT_PERIOD_EXC;
     END IF;

     UPDATE mtl_material_transactions_temp
     SET transaction_date = SYSDATE,
         acct_period_id =  l_acct_period_id
     where  transaction_temp_id =  p_trx_tmp_id;
     /* Added for bug 4041420 - End */

  select mtl_material_transactions_s.nextval into l_header_id from dual;
  update mtl_material_transactions_temp
  set transaction_header_id = l_header_id,
  transaction_status = null, --Added since WIP is no longer doing this in 11.5.10
  primary_quantity = -1* primary_quantity,
  transaction_quantity = -1* transaction_quantity
  where transaction_temp_id = p_trx_tmp_id;
  if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Calling wip_mtlTempProc_grp.processTemp. p_txnHdrID=' || l_header_id);
  end if;
  wip_mtlTempProc_grp.processTemp(
    p_initMsgList => fnd_api.G_TRUE,
    p_processInv => fnd_api.G_TRUE, --whether or not to call inventory TM
    p_txnHdrID => l_header_id,
    x_returnStatus => x_return_status,
    x_errorMsg => x_msg_data);
  if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'wip_mtlTempProc_grp.processTemp returned. x_returnStatus='||x_return_status
    ||', x_errorMsg=' || REPLACE(x_msg_data, CHR(0), ' '));
  end if;
  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO PROCESS_MMTT;
	/* Fix for bug no :2719414 */
	if(x_msg_data is not null) then
	  x_msg_count := 1 ;
   	  if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
--         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        FND_MESSAGE.SET_NAME('EAM','EAM_WIP_PROCESSOR_MSG');
		FND_MESSAGE.SET_TOKEN('WIPMSG',x_msg_data);
		FND_MSG_PUB.ADD;
      end if;
    end if;
	/* end of fix for bug no:2719414 */
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    return;
  end if;
  if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End');
  end if;
	-- End of API body.

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
	  p_count         	=>      x_msg_count,
    p_data          	=>      x_msg_data);
EXCEPTION
        /* Added for bug 4041420 - Start */
        WHEN NO_ACCT_PERIOD_EXC THEN
               eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_TRANSACTION_DATE_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
     /* Added for bug 4041420 - End */
	WHEN OTHERS THEN
		ROLLBACK TO PROCESS_MMTT;
    if (l_log) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module, 'Exception occured');
    end if;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
END process_mmtt;

PROCEDURE insert_ser_trx(p_trx_tmp_id 		IN	VARCHAR2,
			 p_serial_trx_tmp_id 	IN 	NUMBER,
			 p_trx_header_id	IN	NUMBER,
			 p_user_id 		IN	NUMBER,
			 p_fm_ser_num 		IN	VARCHAR2,
			 p_to_ser_num		IN	VARCHAR2,
			 p_item_id		IN      NUMBER,
			 p_org_id		IN 	NUMBER,
			 x_err_code		OUT NOCOPY	NUMBER,
		 	 x_err_message  	OUT NOCOPY	VARCHAR2) IS
BEGIN

    x_err_code := inv_trx_util_pub.insert_ser_trx(
               p_trx_tmp_id     => p_serial_trx_tmp_id,
               p_user_id        => p_user_id,
               p_fm_ser_num     => p_fm_ser_num,
               p_to_ser_num     => p_to_ser_num,
               x_proc_msg       => x_err_message);

    if (x_err_code = 0) then
	serial_check.inv_mark_serial(
		from_serial_number	=> p_fm_ser_num,
		to_serial_number	=> p_to_ser_num,
		item_id			=> p_item_id,
		org_id			=> p_org_id,
		hdr_id			=> p_trx_header_id,
		temp_id			=> p_trx_tmp_id,
		lot_temp_id		=> p_serial_trx_tmp_id,
		success			=> x_err_code);
    end if;

END insert_ser_trx;


PROCEDURE INSERT_REASON_REF_INTO_MMTT(l_reason_id  IN Number,
p_reference  IN varchar2,
p_transaction_temp_id  In Number)  IS

begin

if ((l_reason_id is not null) and (p_reference is not null) )  then
update mtl_material_transactions_temp
set reason_id=l_reason_id,
transaction_reference=p_reference
where transaction_temp_id=p_transaction_temp_id;

elsif ((l_reason_id is  null) and (p_reference is not null) )  then

update mtl_material_transactions_temp
set transaction_reference=p_reference
where transaction_temp_id=p_transaction_temp_id;

elsif ((l_reason_id is not null) and (p_reference is null) )  then

update mtl_material_transactions_temp
set reason_id=l_reason_id
where transaction_temp_id=p_transaction_temp_id;

end if;
 END INSERT_REASON_REF_INTO_MMTT;

 ---Entering the rebuild details
 PROCEDURE ENTER_REBUILD_DETAILS(p_rebuild_item_id   IN Number,
 p_rebuild_job_name  IN OUT NOCOPY Varchar2,
 p_rebuild_activity_id  IN Number,
 p_rebuild_serial_number  IN varchar2,
 P_transaction_temp_id  IN Number,
 p_organization_id   IN Number)

 is
 l_rebuild_job_name mtl_material_transactions_temp.rebuild_job_name%type;
 l_rebuild_job_temp     Number;
 begin

--the program will work if users transact rebuild-item-id
--with the transactions qty =1
--this program will produce abug when users will is tarsnacting more than one rebuild-item

if (p_rebuild_job_name is null)  then

   /* BUG#2988552  wip_job_number_s sequence is to be used for work order name*/
   SELECT
     wip_job_number_s.nextval INTO l_rebuild_job_temp
   FROM
     DUAL;

l_rebuild_job_name:=  l_rebuild_job_temp ;
else
l_rebuild_job_name :=p_rebuild_job_name;
end if;

p_rebuild_job_name := l_rebuild_job_name;       --set the output variable

if  ((p_rebuild_activity_id is not null) and (p_rebuild_serial_number is not null))
then

update mtl_material_transactions_temp
set rebuild_item_id=p_rebuild_item_id,
rebuild_job_name =l_rebuild_job_name,
rebuild_activity_id=p_rebuild_activity_id,
rebuild_serial_number=p_rebuild_serial_number
where transaction_temp_id=p_transaction_temp_id;

elsif ((p_rebuild_activity_id is  null) and (p_rebuild_serial_number is not null)) then

update mtl_material_transactions_temp
set rebuild_item_id=p_rebuild_item_id,
rebuild_job_name =l_rebuild_job_name,
rebuild_serial_number=p_rebuild_serial_number
where transaction_temp_id=p_transaction_temp_id;
 elsif ((p_rebuild_activity_id is  not null) and (p_rebuild_serial_number is  null))  then

update mtl_material_transactions_temp
set rebuild_item_id=p_rebuild_item_id,
rebuild_job_name =l_rebuild_job_name,
rebuild_activity_id=p_rebuild_activity_id
where transaction_temp_id=p_transaction_temp_id;
elsif ((p_rebuild_activity_id is  null) and (p_rebuild_serial_number is  null))  then

update mtl_material_transactions_temp
set rebuild_item_id=p_rebuild_item_id,
rebuild_job_name =l_rebuild_job_name
where transaction_temp_id=p_transaction_temp_id;

end if;


end ENTER_REBUILD_DETAILS;


-- Procedure to cancel allocations if a material is deleted
 -- Author : amondal

PROCEDURE cancel_alloc_matl_del (p_api_version        IN       NUMBER,
                    p_init_msg_list      IN       VARCHAR2 ,
                    p_commit             IN       VARCHAR2,
                    p_validation_level   IN       NUMBER,
                    p_wip_entity_id IN NUMBER,
                    p_operation_seq_num  IN NUMBER,
                    p_inventory_item_id  IN NUMBER,
                    p_wip_entity_type    IN NUMBER,
                    p_repetitive_schedule_id IN NUMBER DEFAULT NULL,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_data OUT NOCOPY VARCHAR2,
                    x_msg_count  OUT NOCOPY NUMBER) IS

l_api_name       CONSTANT VARCHAR2(30) := 'cancel_alloc_matl_del';
l_api_version    CONSTANT NUMBER       := 1.0;
l_wip_entity_id  NUMBER;
l_operation_seq_num NUMBER;
l_inventory_item_id NUMBER;
l_return_status VARCHAR2(1);
l_msg_data  VARCHAR2(2000);


BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT cancel_alloc_matl_del;

  -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
               l_api_version
               ,p_api_version
               ,l_api_name
               ,g_pkg_name) THEN
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

  --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success; -- line 892

  -- API body



    l_wip_entity_id := p_wip_entity_id;
    l_operation_seq_num := p_operation_seq_num;
    l_inventory_item_id := p_inventory_item_id;

    wip_picking_pub.cancel_comp_allocations (p_wip_entity_id => l_wip_entity_id,
                    p_operation_seq_num  => l_operation_seq_num,
                    p_inventory_item_id  => l_inventory_item_id,
                    p_wip_entity_type    => wip_constants.eam,
                    p_repetitive_schedule_id => NULL,
                    x_return_status => l_return_status,
                    x_msg_data => l_msg_data);

                    x_msg_data := l_msg_data;
                    x_return_status := l_return_status;

 -- End of API body.
    -- Standard check of p_commit.

          IF fnd_api.to_boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

       --   l_stmt_num    := 999;

       -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(
             p_count => x_msg_count,
             p_data => x_msg_data);
       EXCEPTION
          WHEN fnd_api.g_exc_error THEN
             ROLLBACK TO cancel_alloc_matl_del;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get(
    --            p_encoded => FND_API.g_false
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN fnd_api.g_exc_unexpected_error THEN
             ROLLBACK TO cancel_alloc_matl_del;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             fnd_msg_pub.count_and_get(
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN OTHERS THEN
             ROLLBACK TO cancel_alloc_matl_del;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             IF fnd_msg_pub.check_msg_level(
                   fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
             END IF;

             fnd_msg_pub.count_and_get(p_count => x_msg_count
               ,p_data => x_msg_data);



END cancel_alloc_matl_del;


-- Procedure to cancel allocations if required quantity for a material is decreased
  -- Procedure to create allocations if required quantity for a material is increased
  -- Both cases are for Released Work Orders
  -- Author : amondal

PROCEDURE comp_alloc_chng_qty(p_api_version        IN       NUMBER,
                             p_init_msg_list      IN       VARCHAR2,
                             p_commit             IN       VARCHAR2,
                             p_validation_level   IN       NUMBER,
                             p_wip_entity_id IN NUMBER,
                             p_organization_id  IN NUMBER,
                             p_operation_seq_num  IN NUMBER,
                             p_inventory_item_id  IN NUMBER,
                             p_qty_required       IN NUMBER,
                             p_supply_subinventory  IN     VARCHAR2 DEFAULT NULL, --12.1 source sub project
                             p_supply_locator_id    IN     NUMBER DEFAULT NULL, --12.1 source sub project
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_data           OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER) IS

  l_api_name       CONSTANT VARCHAR2(30)  := 'comp_alloc_chng_qty';
  l_module         constant varchar2(200) := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
  l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
  l_log            boolean := FND_LOG.LEVEL_UNEXPECTED >= l_current_log_level ;
  l_plog           boolean := l_log and FND_LOG.LEVEL_PROCEDURE >= l_current_log_level ;
  l_slog           boolean := l_plog and FND_LOG.LEVEL_STATEMENT >= l_current_log_level ;
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_wip_entity_id NUMBER;
  l_organization_id NUMBER;
  l_operation_seq_num  NUMBER;
  l_inventory_item_id NUMBER;
  l_required_quantity  NUMBER;
  l_quantity_issued  NUMBER;
  l_quantity_allocated NUMBER;
  l_quantity_available NUMBER;
  l_auto_request_material VARCHAR2(1);
  l_project_id  NUMBER;
  l_task_id  NUMBER;
  l_status_type   NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data  VARCHAR2(2000);

  l_msg_count   NUMBER;
  l_request_number  VARCHAR2(30);

  l_allocate_comp_red_rec wip_picking_pub.allocate_comp_rec_t;
  l_allocate_comp_red_tbl wip_picking_pub.allocate_comp_tbl_t;

  l_allocate_comp_inc_rec wip_picking_pub.allocate_comp_rec_t;
  l_allocate_comp_inc_tbl wip_picking_pub.allocate_comp_tbl_t;

  BEGIN
  -- Standard Start of API savepoint
     SAVEPOINT comp_alloc_chng_qty;

  -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
               l_api_version
               ,p_api_version
               ,l_api_name
               ,g_pkg_name) THEN
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

  --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

  -- API body

  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_organization_id='|| p_organization_id || ','
    || 'p_wip_entity_id='|| p_wip_entity_id || ','
    || 'p_operation_seq_num='|| p_operation_seq_num || ','
    || 'p_inventory_item_id='|| p_inventory_item_id || ','
    || 'p_qty_required='|| p_qty_required ||','
    || 'p_commit='|| p_commit
    || ')');
  end if;

  l_wip_entity_id := p_wip_entity_id;
  l_operation_seq_num := p_operation_seq_num;
  l_inventory_item_id := p_inventory_item_id;
  l_organization_id := p_organization_id;

  -- Get required, issued, allocated quantity and auto_request_material flag

  select required_quantity,
         quantity_issued,
         eam_material_allocqty_pkg.allocated_quantity(wip_entity_id,operation_seq_num,organization_id,inventory_item_id),
         auto_request_material
  into   l_required_quantity,
         l_quantity_issued,
         l_quantity_allocated,
         l_auto_request_material
  from wip_requirement_operations
  where inventory_item_id = l_inventory_item_id
  and organization_id = l_organization_id
  and wip_entity_id = l_wip_entity_id
  and operation_seq_num = l_operation_seq_num;

  l_quantity_available :=  l_quantity_issued + nvl(l_quantity_allocated,0);

  -- Get project id, task id, work order status and entity type

  select wdj.project_id,
         wdj.task_id,
         wdj.status_type
  into   l_project_id,
         l_task_id,
         l_status_type
  from  wip_discrete_jobs wdj, wip_entities we
  where wdj.wip_entity_id = we.wip_entity_id
  and wdj.organization_id = we.organization_id
  and wdj.organization_id = l_organization_id
  and wdj.wip_entity_id = l_wip_entity_id;

  if (l_status_type = 3 and p_qty_required <> l_quantity_available) then  -- EAM Job in Released Status

        if (p_qty_required < l_quantity_available) then  -- Reduce required quantity

         if (p_qty_required > l_quantity_issued) then  -- Reduce quantity lesser that issued quantity

           if (p_qty_required <= l_quantity_allocated) then

           l_allocate_comp_red_rec.wip_entity_id := l_wip_entity_id;
	   l_allocate_comp_red_rec.repetitive_schedule_id := null;
	   l_allocate_comp_red_rec.use_pickset_flag := null;
	   l_allocate_comp_red_rec.project_id := l_project_id;
	   l_allocate_comp_red_rec.task_id := l_task_id;
	   l_allocate_comp_red_rec.operation_seq_num := l_operation_seq_num;
	   l_allocate_comp_red_rec.inventory_item_id := l_inventory_item_id;
	   l_allocate_comp_red_rec.requested_quantity := (l_quantity_available - p_qty_required);
	   l_allocate_comp_red_rec.source_subinventory_code := p_supply_subinventory; --12.1 source sub project
	   l_allocate_comp_red_rec.source_locator_id := p_supply_locator_id; --12.1 source sub project
	   l_allocate_comp_red_rec.lot_number := null;
	   l_allocate_comp_red_rec.start_serial := null;
	   l_allocate_comp_red_rec.end_serial := null;

           l_allocate_comp_red_tbl(1) := l_allocate_comp_red_rec;

           wip_picking_pub.reduce_comp_allocations ( p_comp_tbl => l_allocate_comp_red_tbl,
                                   p_wip_entity_type => wip_constants.eam,
	   	                           p_organization_id => l_organization_id,
	   	                           x_return_status => l_return_status,
	                               x_msg_data => l_msg_data);


           end if;  -- End of check for quantity allocated


         else

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   fnd_message.set_name('EAM', 'EAM_ALLOCATE_QTY_ERROR');  -- Error message to be provided
	   x_msg_data := fnd_message.get;


	 end if;   -- End of check for quantity issued


        else  -- If Requested Quantity is increased

          if l_auto_request_material = 'Y' then


            l_allocate_comp_inc_rec.wip_entity_id := l_wip_entity_id;
	    l_allocate_comp_inc_rec.repetitive_schedule_id := null;
	    l_allocate_comp_inc_rec.use_pickset_flag := null;
	    l_allocate_comp_inc_rec.project_id := l_project_id;
	    l_allocate_comp_inc_rec.task_id := l_task_id;
	    l_allocate_comp_inc_rec.operation_seq_num := l_operation_seq_num;
	    l_allocate_comp_inc_rec.inventory_item_id := l_inventory_item_id;
            l_allocate_comp_inc_rec.requested_quantity := (p_qty_required - l_quantity_available);
	    l_allocate_comp_inc_rec.source_subinventory_code := p_supply_subinventory; --12.1 source sub project
	    l_allocate_comp_inc_rec.source_locator_id := p_supply_locator_id; -- 12.1 source sub project
	    l_allocate_comp_inc_rec.lot_number := null;
	    l_allocate_comp_inc_rec.start_serial := null;
	    l_allocate_comp_inc_rec.end_serial := null;
	    l_allocate_comp_inc_tbl(1) := l_allocate_comp_inc_rec;

      EAM_MATERIAL_request_PVT.allocate(p_api_version  => 1.0,
        p_init_msg_list => fnd_api.g_false ,
        p_commit  => fnd_api.g_false,
        p_validation_level => fnd_api.g_valid_level_full,
        x_return_status => l_return_status,
        x_msg_count  => l_msg_count,
        x_msg_data => l_msg_data,
        x_request_number  => l_request_number,
        p_wip_entity_type  => wip_constants.eam ,
        p_organization_id  => l_organization_id,
        p_wip_entity_id  => l_allocate_comp_inc_tbl(1).wip_entity_id,
        p_operation_seq_num  => l_allocate_comp_inc_tbl(1).operation_seq_num,
        p_inventory_item_id  => l_allocate_comp_inc_tbl(1).inventory_item_id,
        p_requested_quantity  => l_allocate_comp_inc_tbl(1).requested_quantity   ,
        p_source_subinventory  => l_allocate_comp_inc_tbl(1).source_subinventory_code, --12.1 source sub project
        p_source_locator  => l_allocate_comp_inc_tbl(1).source_locator_id); --12.1 source sub project

         end if;  -- End of Check for Qty


    end if; -- End of Check for Released status

end if;

x_msg_data := l_msg_data;
x_return_status := l_return_status;

   -- End of API body.
    -- Standard check of p_commit.

          IF fnd_api.to_boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

         -- l_stmt_num    := 999;

       -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(
             p_count => x_msg_count
            ,p_data => x_msg_data);
       EXCEPTION
          WHEN fnd_api.g_exc_error THEN
             ROLLBACK TO comp_alloc_chng_qty;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get(
    --            p_encoded => FND_API.g_false
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN fnd_api.g_exc_unexpected_error THEN
             ROLLBACK TO comp_alloc_chng_qty;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             fnd_msg_pub.count_and_get(
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN OTHERS THEN
             ROLLBACK TO comp_alloc_chng_qty;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             IF fnd_msg_pub.check_msg_level(
                   fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
             END IF;

             fnd_msg_pub.count_and_get(p_count => x_msg_count
               ,p_data => x_msg_data);



   END comp_alloc_chng_qty;


  -- Procedure to create new allocations for a newly added material to a Released Work Order
  -- Author : amondal

  PROCEDURE comp_alloc_new_mat(p_api_version        IN       NUMBER,
                             p_init_msg_list      IN       VARCHAR2,
                             p_commit             IN       VARCHAR2,
                             p_validation_level   IN       NUMBER,
                             p_wip_entity_id IN NUMBER,
                             p_organization_id  IN NUMBER,
                             p_operation_seq_num  IN NUMBER,
                             p_inventory_item_id  IN NUMBER,
                             p_qty_required       IN NUMBER,
                             p_supply_subinventory  IN     VARCHAR2 DEFAULT NULL, --12.1 source sub project
                             p_supply_locator_id    IN     NUMBER DEFAULT NULL, --12.1 source sub project
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_data           OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'comp_alloc_chng_qty';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_wip_entity_id NUMBER;
  l_organization_id NUMBER;
  l_operation_seq_num  NUMBER;
  l_inventory_item_id NUMBER;
  l_required_quantity  NUMBER;
  l_auto_request_material VARCHAR2(1);
  l_project_id NUMBER;
  l_task_id  NUMBER;
  l_status_type NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);

  l_msg_count   NUMBER;
  l_request_number  VARCHAR2(80);

  l_allocate_comp_inc_rec wip_picking_pub.allocate_comp_rec_t;
  l_allocate_comp_inc_tbl wip_picking_pub.allocate_comp_tbl_t;

  BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT comp_alloc_new_mat;

  -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
               l_api_version
               ,p_api_version
               ,l_api_name
               ,g_pkg_name) THEN
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

  --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

  -- API body

  l_wip_entity_id := p_wip_entity_id;
  l_operation_seq_num := p_operation_seq_num;
  l_inventory_item_id := p_inventory_item_id;
  l_organization_id := p_organization_id;

  select required_quantity,
         auto_request_material
  into   l_required_quantity,
         l_auto_request_material
  from wip_requirement_operations
  where inventory_item_id = l_inventory_item_id
  and organization_id = l_organization_id
  and wip_entity_id = l_wip_entity_id
  and operation_seq_num = l_operation_seq_num;

  -- Get project id, task id, work order status and entity type

  select wdj.project_id,
         wdj.task_id,
         wdj.status_type
  into   l_project_id,
         l_task_id,
         l_status_type
  from  wip_discrete_jobs wdj, wip_entities we
  where wdj.wip_entity_id = we.wip_entity_id
  and wdj.organization_id = we.organization_id
  and wdj.organization_id = l_organization_id
  and wdj.wip_entity_id = l_wip_entity_id;


     if (l_status_type = 3) then -- Released EAM work order

          if l_auto_request_material = 'Y' then


        l_allocate_comp_inc_rec.wip_entity_id := l_wip_entity_id;
	    l_allocate_comp_inc_rec.repetitive_schedule_id := null;
	    l_allocate_comp_inc_rec.use_pickset_flag := null;
	    l_allocate_comp_inc_rec.project_id := l_project_id;
	    l_allocate_comp_inc_rec.task_id := l_task_id;
	    l_allocate_comp_inc_rec.operation_seq_num := l_operation_seq_num;
	    l_allocate_comp_inc_rec.inventory_item_id := l_inventory_item_id;
		/* Following subtraction expression has been commented as Fix for Issue5 of bug:2755159 */
	    l_allocate_comp_inc_rec.requested_quantity := p_qty_required; --(p_qty_required - l_required_quantity);
	    l_allocate_comp_inc_rec.source_subinventory_code := p_supply_subinventory; --12.1 source sub project
	    l_allocate_comp_inc_rec.source_locator_id := p_supply_locator_id; --12.1 source sub project
	    l_allocate_comp_inc_rec.lot_number := null;
	    l_allocate_comp_inc_rec.start_serial := null;
	    l_allocate_comp_inc_rec.end_serial := null;


	    l_allocate_comp_inc_tbl(1) := l_allocate_comp_inc_rec;

      EAM_MATERIAL_request_PVT.allocate(p_api_version  => 1.0,
        p_init_msg_list => fnd_api.g_false ,
        p_commit  => fnd_api.g_false,
        p_validation_level => fnd_api.g_valid_level_full,
        x_return_status => l_return_status,
        x_msg_count  => l_msg_count,
        x_msg_data => l_msg_data,
        x_request_number  => l_request_number,
        p_wip_entity_type  => wip_constants.eam ,
        p_organization_id  => l_organization_id,
        p_wip_entity_id  => l_allocate_comp_inc_tbl(1).wip_entity_id,
        p_operation_seq_num  => l_allocate_comp_inc_tbl(1).operation_seq_num,
        p_inventory_item_id  => l_allocate_comp_inc_tbl(1).inventory_item_id,
        p_requested_quantity  => l_allocate_comp_inc_tbl(1).requested_quantity   ,
        p_source_subinventory  => l_allocate_comp_inc_tbl(1).source_subinventory_code, -- 12.1 source sub project
        p_source_locator  => l_allocate_comp_inc_tbl(1).source_locator_id); --12.1 source sub project

           end if;

     end if;  -- end of Released EAM work order

   -- End of API body.
    -- Standard check of p_commit.

          IF fnd_api.to_boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

         -- l_stmt_num    := 999;

       -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(
             p_count => x_msg_count
            ,p_data => x_msg_data);
       EXCEPTION
          WHEN fnd_api.g_exc_error THEN
             ROLLBACK TO comp_alloc_new_mat;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get(
    --            p_encoded => FND_API.g_false
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN fnd_api.g_exc_unexpected_error THEN
             ROLLBACK TO comp_alloc_new_mat;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             fnd_msg_pub.count_and_get(
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN OTHERS THEN
             ROLLBACK TO comp_alloc_new_mat;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             IF fnd_msg_pub.check_msg_level(
                   fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
             END IF;

             fnd_msg_pub.count_and_get(p_count => x_msg_count
               ,p_data => x_msg_data);

   END comp_alloc_new_mat;


  -- Procedure to create allocations during Release of a work order
   -- Procedure to cancel allocations during Cancel of a work order
   -- author : amondal

   PROCEDURE alloc_at_release_cancel (
     p_api_version        IN       NUMBER,
     p_init_msg_list      IN       VARCHAR2,
     p_commit             IN       VARCHAR2,
     p_validation_level   IN       NUMBER,
     p_wip_entity_id IN NUMBER,
     p_organization_id  IN NUMBER,
     p_status_type   IN NUMBER,
     x_return_status      OUT NOCOPY VARCHAR2, --later on add x_request_number
     x_msg_data           OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER) IS

    l_api_name       CONSTANT VARCHAR2(30) := 'alloc_at_release_cancel';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_wip_entity_id NUMBER;
    l_organization_id NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_data  VARCHAR2(2000);
    l_project_id NUMBER;
    l_task_id NUMBER;
    l_status_type NUMBER;
    l_request_number VARCHAR2(30);
    l_pickslip_conc_req_id NUMBER := 0;
    l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
    l_pLog BOOLEAN := FND_LOG.LEVEL_PROCEDURE >= l_current_log_level;
    l_sLog BOOLEAN := l_pLog AND FND_LOG.LEVEL_STATEMENT >= l_current_log_level ;
    l_module CONSTANT VARCHAR2(100):= 'eam.plsql.'||g_pkg_name||'.'||l_api_name;
    l_msg VARCHAR2(2000);


   l_allocate_rec wip_picking_pub.allocate_rec_t;
   l_allocate_tbl wip_picking_pub.allocate_tbl_t;

   BEGIN

   -- Standard Start of API savepoint

     SAVEPOINT alloc_at_release_cancel;

  -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
               l_api_version
               ,p_api_version
               ,l_api_name
               ,g_pkg_name) THEN
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

  --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

  -- API body
    if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Start');
    end if;

    l_wip_entity_id := p_wip_entity_id;
    l_organization_id := p_organization_id;


    if (p_status_type = 3) then -- Work Order is Released

       select project_id, task_id into l_project_id, l_task_id
       from wip_discrete_jobs
       where wip_entity_id = p_wip_entity_id
       and organization_id=p_organization_id;

      l_allocate_rec.wip_entity_id := l_wip_entity_id;
      l_allocate_rec.repetitive_schedule_id := null;
      l_allocate_rec.use_pickset_flag := null;
      l_allocate_rec.project_id := l_project_id;
      l_allocate_rec.task_id := l_task_id;
      l_allocate_rec.bill_seq_id := null;
      l_allocate_rec.bill_org_id := null;
      l_allocate_rec.alt_rtg_dsg := null;
      l_allocate_tbl(1) := l_allocate_rec;

      if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calling wip_picking_pub.allocate');
      end if;
      wip_picking_pub.allocate(p_alloc_tbl => l_allocate_tbl,
       p_cutoff_date => null,
       p_wip_entity_type => wip_constants.eam,
       p_organization_id => l_organization_id,
       x_mo_req_number  => l_request_number,
       x_conc_req_id => l_pickslip_conc_req_id,
       x_return_status => l_return_status,
       x_msg_data => l_msg_data);

        if(l_return_status<>null) then /*8941280 - return status is null if no material added for WO*/
	       x_return_status := l_return_status; /*8941280*/
	end if;
	if(l_msg_data<>null) then
	       x_msg_data := l_msg_data;
	end if;

      if (l_sLog) then
        l_msg :=  'wip_picking_pub.allocate returned:'|| 'x_return_status:'
        ||x_return_status||' x_mo_req_number:'||l_request_number;
        l_msg := REPLACE(l_msg, CHR(0), ' ');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,l_msg);
      end if;

    elsif p_status_type IN (5,7) then --status_type 5 is added for bug 7631627
      if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calling wip_picking_pub.cancel_allocations');
      end if;
      wip_picking_pub.cancel_allocations (p_wip_entity_id => l_wip_entity_id,
        p_wip_entity_type =>  wip_constants.eam,
        p_repetitive_schedule_id => NULL,
        x_return_status => l_return_status,
        x_msg_data => l_msg_data);

        if(l_return_status<>null) then /*8941280 - return status is null if no material added for WO*/
	       x_return_status := l_return_status; /*8941280*/
  	end if;
	if(l_msg_data<>null) then
        	x_msg_data := l_msg_data;
	end if;

      if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'wip_picking_pub.cancel_allocations returned:'|| 'x_return_status:'
        ||x_return_status);
      end if;
    end if;

    -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

     -- Standard call to get message count and if count is 1, get message info.
    if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End');
    end if;
    fnd_msg_pub.count_and_get(
       p_count => x_msg_count
      ,p_data => x_msg_data);
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO alloc_at_release_cancel;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
    --            p_encoded => FND_API.g_false
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO alloc_at_release_cancel;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO alloc_at_release_cancel;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count
           ,p_data => x_msg_data);

   END alloc_at_release_cancel;

FUNCTION get_tx_processor_mode(p_dummy IN boolean := false
) return number IS
l_proc_mode number := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'get_tx_processor_mode';
l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_module                  CONSTANT VARCHAR2(60) := 'eam.plsql.'||l_full_name;
l_slog           boolean := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
begin
  l_proc_mode := FND_PROFILE.VALUE('TRANSACTION_PROCESS_MODE');
  if (l_slog) then  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Inventory transaction processor mode (TRANSACTION_PROCESS_MODE) = '||l_proc_mode);
  end if;
  return l_proc_mode;
end;


END  EAM_MATERIALISSUE_PVT;


/

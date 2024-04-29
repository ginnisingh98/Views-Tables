--------------------------------------------------------
--  DDL for Package Body EAM_MTL_TXN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MTL_TXN_PROCESS" AS
/* $Header: EAMMTTXB.pls 120.3.12010000.3 2009/08/26 12:28:17 vboddapa ship $ */

g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_mtl_txn_process';
Procedure PROCESSMTLTXN(
                           p_txn_header_id    IN NUMBER,
                          p_item_id          IN OUT NOCOPY NUMBER,
                          p_item             IN VARCHAR2 := NULL,
                          p_revision         IN VARCHAR2 := NULL,
                          p_org_id           IN OUT NOCOPY NUMBER,
                          p_trx_action_id    IN NUMBER ,
                          p_subinv_code      IN OUT NOCOPY VARCHAR2 ,
                          p_tosubinv_code    IN VARCHAR2 := NULL,
                          p_locator_id       IN OUT NOCOPY NUMBER,
                          p_locator          IN VARCHAR2 := NULL,
                          p_tolocator_id     IN NUMBER   := NULL,
                          p_trx_type_id      IN NUMBER ,
                          p_trx_src_type_id  IN NUMBER ,
                          p_trx_qty          IN NUMBER ,
                          p_pri_qty          IN NUMBER ,
                          p_uom              IN VARCHAR2 ,
                          p_date             IN DATE     := sysdate,
                          p_reason_id        IN OUT NOCOPY NUMBER,
                          p_reason           IN VARCHAR2 := NULL,
                          p_user_id          IN NUMBER ,
                          p_trx_src_id       IN NUMBER   := NULL,
                          x_trx_temp_id      OUT NOCOPY NUMBER ,
                          p_operation_seq_num  IN NUMBER   := NULL,
                          p_wip_entity_type    IN NUMBER   := NULL,
                          p_trx_reference      IN VARCHAR2 := NULL,
                          p_negative_req_flag  IN NUMBER   := NULL,
                          p_serial_ctrl_code   IN NUMBER   := NULL,
                          p_lot_ctrl_code      IN NUMBER   := NULL,
                          p_from_ser_number    IN VARCHAR2 := NULL,
                          P_to_ser_number      IN VARCHAR2 := NULL,
                          p_lot_num            IN VARCHAR2 := NULL,
                          p_wip_supply_type    IN NUMBER   := NULL,
                          p_subinv_ctrl        IN NUMBER   := 0,
                          p_locator_ctrl       IN NUMBER   := 0,
                          p_wip_process        IN NUMBER   := NULL, -- determines to call WIP Transaction API
                                                                    -- 0 -> No call,1 -> Call
                          p_dateNotInFuture    IN NUMBER   := 1,    -- 1 --> do check,0 --> no check
                          x_error_flag        OUT NOCOPY NUMBER,           -- returns 0 if no error , >1 if any error .
                          x_error_mssg        OUT NOCOPY VARCHAR2 ) IS

x_status      NUMBER;    -- holds the status returned from every transaction API call
x_status_flag VARCHAR2(240);
x_header_id   NUMBER;    -- holds the header id from MMTT table
x_ser_txn_id  NUMBER;    -- holds Serial transaction id which will lind MTL_SERIAL_NUMBERS_TEMP
                         -- with MTL_SYSTEM_ITEMS or MTL_TRANSACTION_LOTS_TEMP
x_wip_ret_status VARCHAR2(250); -- holds the status returned from WIP Transaction API
x_future_date NUMBER;

x_locator_ctrl  NUMBER ; -- Holds the Locator Control information

x_mssg_count    NUMBER;
x_trans_count   NUMBER;
x_inv_ret_status NUMBER;
l_proc_mode number := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'processmtltxn';
l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_module                  CONSTANT VARCHAR2(60) := 'eam.plsql.'||l_full_name;
l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
l_log            boolean := FND_LOG.LEVEL_UNEXPECTED >= l_current_log_level ;
l_plog           boolean := l_log and FND_LOG.LEVEL_PROCEDURE >= l_current_log_level ;
l_slog           boolean := l_plog and FND_LOG.LEVEL_STATEMENT >= l_current_log_level ;
l_mti_qty        number;
l_qty_issued     number;
l_remain_qty     number;
l_tx_mode        number;
l_tx_mode_mti    number := 1;
l_department_id  NUMBER; -- for bug 8669096
-- x_proc_msg        OUT VARCHAR2 ,
/*x_item_id     NUMBER;
x_reason_id   NUMBER;
x_locator_id  NUMBER;
*/

Begin

if (l_plog) then
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
  'Start of ' || l_module || '('
  || 'p_txn_header_id='|| p_txn_header_id || ',p_item_id='|| p_item_id
  || ',p_trx_type_id='|| p_trx_type_id || ',p_trx_src_id='|| p_trx_src_id
  || ',p_operation_seq_num='|| p_operation_seq_num
  || ',p_item='|| p_item || ',p_revision='|| p_revision
  || ',p_org_id='|| p_org_id || ',p_subinv_code='|| p_subinv_code
  || ',p_locator_id='|| p_locator_id || ',p_tolocator_id='|| p_tolocator_id
  || ',p_trx_type_id='|| p_trx_type_id || ',p_trx_src_id='|| p_trx_src_id
  || ',p_trx_qty='|| p_trx_qty || ',p_uom='|| p_uom
  || ',p_date='|| p_date || ',p_reason_id='|| p_reason_id
  || ',p_trx_reference='|| p_trx_reference || ',p_lot_num='|| p_lot_num
  || ',p_lot_ctrl_code='|| p_lot_ctrl_code
  || ',p_serial_ctrl_code='|| p_serial_ctrl_code
  || ',p_from_ser_number='|| p_from_ser_number
  || ',p_to_ser_number='|| p_to_ser_number
  || ')');
end if;

/* initialize the error flag */
x_error_flag := 0;

/* Checking the Transaction date */
if(p_dateNotInFuture = 1) then
begin
 select 1 into x_future_date from dual where p_date <= sysdate ;
exception
 when no_data_found then
  x_error_flag := 1;
  x_error_mssg := 'EAM_FUTURE_DATE';
  return;
end; -- end of p_item_id check
end if;


/* Finding out Item ID from Name */
if(p_item_id IS NULL and p_item IS NOT NULL) then
begin
 select inventory_item_id into p_item_id
 from mtl_system_items_b_kfv
 where
 concatenated_segments = p_item
 and organization_id = p_org_id;
exception
 when no_data_found then
  x_error_flag := 1;
  x_error_mssg := 'EAM_NO_ITEM_FOUND';
  return;
end; -- end of p_item_id check
end if;


-- Check if unprocessed records for return tx exist in MTI.
-- Validate: Qty for unprocessed records + return qty <= Issued Qty
if (p_trx_type_id = 43) then
  --transaction qty is same as primary qty since we always
  --transact in primary UOM.
  select sum(transaction_quantity) into l_mti_qty
  from mtl_transactions_interface
  where transaction_source_id = p_trx_src_id
  and transaction_type_id = 43
  and organization_id = p_org_id
  and inventory_item_id = p_item_id
  and process_flag = 1;  --1(ready). Do not pick up 3(errored) or 2(not ready)

  if (l_mti_qty > 0) then
    select quantity_issued into l_qty_issued
    from wip_requirement_operations
    where wip_entity_id = p_trx_src_id
    and inventory_item_id = p_item_id;
    if (l_slog) then  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Qty to return in MTI='|| l_mti_qty|| ', Qty to return by user='
      || p_trx_qty|| ', Qty issued to job=' || l_qty_issued);
    end if;
    l_remain_qty := l_qty_issued - l_mti_qty;
    if (l_remain_qty <= 0) then
      x_error_flag := 2;
      fnd_message.set_name('EAM','EAM_NOTHING_TO_RETURN');
      x_error_mssg := fnd_message.get;
      return;
    elsif (l_remain_qty - p_trx_qty  < 0) then
      x_error_flag := 2;
      fnd_message.set_name('EAM','EAM_REDUCE_RETURN_QTY');
      fnd_message.set_token('QTY', to_char(l_remain_qty) );
      x_error_mssg := fnd_message.get;
      return;
    end if;
  end if;
end if;

/* Finding out SubInventory is Correct or Not */
if(p_subinv_code IS NOT NULL) then
Begin

 if(p_subinv_ctrl <> 1) then
 select secondary_inventory_name into p_subinv_code
 from mtl_secondary_inventories
 where
 secondary_inventory_name = p_subinv_code
 and organization_id = p_org_id
 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
 and inv_material_status_grp.is_status_applicable(NULL,NULL,p_trx_type_id,NULL,NULL,
     p_org_id,p_item_id,secondary_inventory_name,NULL,NULL,NULL,'Z') = 'Y' ;

 elsif(p_subinv_ctrl = 1) then
 select secondary_inventory_name into p_subinv_code
 from mtl_secondary_inventories
 where
 secondary_inventory_name = p_subinv_code
 and organization_id = p_org_id
 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
 and inv_material_status_grp.is_status_applicable(NULL,NULL,p_trx_type_id,NULL,NULL,
     p_org_id,p_item_id,secondary_inventory_name,NULL,NULL,NULL,'Z') = 'Y'
 and EXISTS (select secondary_inventory from mtl_item_sub_inventories
                       where secondary_inventory = secondary_inventory_name
                       and  inventory_item_id = p_item_id
                       and organization_id = p_org_id);
 end if ; -- end of inner if

 exception
  when no_data_found then
  x_error_flag := 1;
  x_error_mssg := 'EAM_RET_MAT_INVALID_SUBINV';
  return;
  when others then
  x_status := 1;
  x_error_mssg := 'Other error occured during subinv check ';
  return;
end;
end if;



/* Finding out Locator ID  from Locator */
if(p_locator_id IS NULL and p_locator IS NOT NULL) then
Begin

 if(p_locator_ctrl <> 1) then
 select Inventory_Location_ID into p_locator_id
 from mtl_item_locations_kfv where
 concatenated_segments = p_locator
 and subinventory_code = p_subinv_code
 and organization_id   = p_org_id;

 elsif(p_locator_ctrl = 1) then
 select Inventory_Location_ID into p_locator_id
 from mtl_item_locations_kfv where
 concatenated_segments = p_locator
 and subinventory_code = p_subinv_code
 and organization_id   = p_org_id
 and EXISTS (select '1' from mtl_secondary_locators
                      where inventory_item_id = p_item_id
                      and organization_id = p_org_id
                      and secondary_locator = inventory_location_id) ;


 end if; -- end of inner if

exception
 when no_data_found then
  x_error_flag := 1;
  x_error_mssg := 'EAM_RET_MAT_INVALID_LOCATOR';
  return;
end;
end if;

/* Check for Locator Control which could be defined
   at 3 level Organization,Subinventory,Item .
*/
 Get_LocatorControl_Code(
                      p_org_id,
                      p_subinv_code,
                      p_item_id,
                      p_trx_action_id,
                      x_locator_ctrl,
                      x_error_flag,
                      x_error_mssg);

if(x_error_flag <> 0) then
 return;
end if;

-- if the locator control is Predefined or Dynamic Entry
if(x_locator_ctrl = 2 or x_locator_ctrl = 3) then
 if(p_locator_id IS NULL) then
   x_error_flag := 1;
   x_error_mssg := 'EAM_RET_MAT_LOCATOR_NEEDED';
   return;
 end if;
elsif(x_locator_ctrl = 1) then -- If the locator control is NOControl
 if(p_locator_id IS NOT NULL) then
   x_error_flag := 1;
   x_error_mssg := 'EAM_RET_MAT_LOCATOR_RESTRICTED';
   return;
 end if;
end if; -- end of locator_control checkif

/* Finding out Reason ID from Reason Name */
if(p_reason_id IS NULL and p_reason IS NOT NULL) then
Begin
 select reason_id into p_reason_id
 from mtl_transaction_reasons
 where
 reason_name = p_reason
 and nvl(disable_date,sysdate+1) > sysdate ;
 exception
  when no_data_found then
  x_error_flag := 1;
  x_error_mssg := 'EAM_RET_MAT_INVALID_REASON';
  return;
end;
end if;


Savepoint eammttxnsp;

/* Initializing the Global variables for MTI Transaction API */
if(p_txn_header_id is null) then
  select
  mtl_material_transactions_s.nextval into x_header_id
  from dual;
  x_trx_temp_id := x_header_id;
else
  x_header_id := p_txn_header_id;
end if;


INV_TRANSACTIONS.G_Header_ID := x_header_id;
INV_TRANSACTIONS.G_Interface_ID := x_header_id;

if(p_serial_ctrl_code <> 1) then
  select mtl_material_transactions_s.nextval into INV_TRANSACTIONS.G_Serial_ID
  from dual;
end if;

if (l_slog) then  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
  'Inserting into MTI with Tx Header ID=' || x_header_id);
end if;
/* Calling the Inventory Transaction API to insert data into MTI table .*/

INV_TRANSACTIONS.Line_Interface_Insert(
                                p_item_id,
                                p_revision,
                                p_org_id,
                                p_trx_src_id,
                                p_trx_action_id,
                                p_subinv_code,
                                p_tosubinv_code,
       p_locator_id,
       p_tolocator_id,
       null,/* Added for bug# 5896548*/
       /*p_org_id,Commented for bug# 5896548*/
       p_trx_type_id,
       p_trx_src_type_id,
       p_trx_qty,
       p_uom,
       p_date,
       p_reason_id,
       p_user_id,
       x_error_mssg,
       x_status_flag
);

if(x_status_flag <> 'C') then
 x_error_flag := 1;
 x_error_mssg := 'EAM_RET_MAT_UNEXPECTED_ERROR';
 raise fnd_api.g_exc_unexpected_error;
end if;
/*
if(p_txn_header_id is null) then
  x_header_id := x_trx_temp_id ;
else
  x_header_id := p_txn_header_id;
end if;
*/

l_tx_mode := EAM_MATERIALISSUE_PVT.get_tx_processor_mode();
if (l_tx_mode not in  (1,4)) then
  l_tx_mode_mti := 3;  --background mode if not online or form level. form level=online.
end if;

-- fix for 8669096 to populate department_id in MTI
 -- Get Department Id

begin
    select department_id
    into l_department_id
    from wip_requirement_operations
    where wip_entity_id = p_trx_src_id
          and operation_seq_num = p_operation_seq_num
    and organization_id = p_org_id
    and inventory_item_id=p_item_id;
exception
  when no_data_found then
     l_department_id:=null;
end;


/* Updating MTI data which are not populated by the above API */

UPDATE MTL_TRANSACTIONS_INTERFACE SET
WIP_ENTITY_TYPE = p_wip_entity_type,
OPERATION_SEQ_NUM = p_operation_seq_num,
TRANSACTION_REFERENCE = p_trx_reference,
NEGATIVE_REQ_FLAG = negative_req_flag,
TRANSACTION_SOURCE_ID = p_trx_src_id,
TRANSACTION_MODE = l_tx_mode_mti,  --else background transactions wont be picked up
department_id = l_department_id  -- fix for 8669096
where
TRANSACTION_HEADER_ID = x_header_id ;



-- ------------------------------------------------------------------------------------
-- Performing LOT Transaction entries .
-- ------------------------------------------------------------------------------------

if(p_lot_ctrl_code <> 1 and p_lot_num IS NOT NULL) then

 INV_TRANSACTIONS.LOT_INTERFACE_INSERT(
                                   p_Transaction_Quantity => p_trx_qty,
                                   p_Lot_Number => p_lot_num,
                                   p_User_Id => p_user_id,
                                   p_serial_number_control_code => p_serial_ctrl_code
);

end if; -- end of lot ctrl code check


-- ------------------------------------------------------------------------------------
-- Performing Serial Transaction entries
-- ------------------------------------------------------------------------------------

if(p_serial_ctrl_code <> 1 and p_from_ser_number IS NOT NULL
and p_to_ser_number IS NOT NULL and p_serial_ctrl_code IS NOT NULL) then

INV_TRANSACTIONS.SERIAL_INTERFACE_INSERT(
                                 p_From_Serial => p_from_ser_number,
                                 p_To_Serial => p_to_ser_number,
                                 p_User_Id => p_user_id,
                                 p_lot_control_code => p_lot_ctrl_code
);

end if; --  end of ser ctrl code check


-- ------------------------------------------------------------------------------------
-- Performing MTI data processing by calling WIP API
-- ------------------------------------------------------------------------------------

if(p_wip_process = 1) then
  -- only call txn processor if online processing. 4(form level) is treated as 1.
  if (l_tx_mode in  (1,4)) then
    if (l_slog) then  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Calling tx processor: INV_TXN_MANAGER_PUB.process_Transactions');
    end if;
    x_inv_ret_status := INV_TXN_MANAGER_PUB.process_Transactions(
        p_api_version => 1.0,
        p_header_id   => x_header_id,
        p_table       => 1,          -- meant for process from MTI table.
        x_return_status => x_wip_ret_status,
        x_msg_count    => x_mssg_count,
        x_msg_data     => x_error_mssg,
        x_trans_count   => x_trans_count
        );
    if (l_slog) then  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'INV_TXN_MANAGER_PUB.process_Transactions returned. '||
      'Return status:'|| x_wip_ret_status);
    end if;
    if(x_wip_ret_status = FND_API.G_RET_STS_UNEXP_ERROR OR
      x_wip_ret_status = FND_API.G_RET_STS_ERROR OR
      x_inv_ret_status <> 0) then
      if (l_log) then  FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module,
        'INV_TXN_MANAGER_PUB.process_Transactions returned a error. '||
        'Return message:'|| x_error_mssg);
      end if;
      x_error_flag := 2;
      --   x_error_mssg := 'EAM_RET_MAT_UNEXPECTED_ERROR';
      return;
    end if;
  end if; -- end of if EAM_MATERIALISSUE_PVT.get_tx_processor_mode() = 1
end if; -- end of check for p_wip_process

Exception
 When fnd_api.g_exc_unexpected_error then
 rollback to eammttxnsp;
End PROCESSMTLTXN;


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

 if(x_org_ctrl = 1) then
       x_locator_ctrl := 1;
    elsif(x_org_ctrl = 2) then
       x_locator_ctrl := 2;
    elsif(x_org_ctrl = 3) then
       x_locator_ctrl := 3;
       if(dynamic_entry_not_allowed(x_restrict_flag,
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

    PROCEDURE MoreMaterial_Add
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_organization_id             IN      NUMBER,
        p_operation_seq_num             IN      NUMBER,
        p_item_id                 IN      NUMBER,
        p_required_quantity   IN  NUMBER,
        p_requested_quantity   IN  NUMBER,
	p_supply_subinventory  IN     VARCHAR2, --12.1 source sub project
        p_supply_locator_id             IN     NUMBER, --12.1 source sub project
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
  l_api_name      CONSTANT VARCHAR2(30) := 'MoreMaterial_Add';
  l_api_version             CONSTANT NUMBER   := 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_organization_id           NUMBER;
    l_operation_seq_num         NUMBER;
    l_item_id         NUMBER;
    l_required_quantity   NUMBER;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    l_error_message             VARCHAR2(1000);
    l_output_dir    VARCHAR2(512);

    l_eam_mat_req_rec   EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;

	l_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	l_out_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_out_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    BEGIN
  -- Standard Start of API savepoint
    SAVEPOINT EAM_WO_MATERIAL_UTIL_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (    l_api_version         ,
                                    p_api_version         ,
                                      l_api_name        ,
                                  G_PKG_NAME )
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

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_work_object_id        := p_work_object_id;
    l_organization_id       := p_organization_id;
    l_operation_seq_num     := p_operation_seq_num;
    l_item_id           := p_item_id;
    l_required_quantity     := p_required_quantity;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;

    /* get output directory path from database */
    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    /* set the required quantity for the corresponding inventory item */

  l_eam_mat_req_rec.batch_id      :=  1;
  l_eam_mat_req_rec.header_id     :=  l_work_object_id;
  l_eam_mat_req_rec.wip_entity_id     :=  l_work_object_id;
  l_eam_mat_req_rec.organization_id     :=  l_organization_id;
  l_eam_mat_req_rec.operation_seq_num   :=  l_operation_seq_num;
  l_eam_mat_req_rec.inventory_item_id   :=  l_item_id;
  l_eam_mat_req_rec.required_quantity   :=  l_required_quantity;
  l_eam_mat_req_rec.supply_subinventory :=  p_supply_subinventory;
  l_eam_mat_req_rec.supply_locator_id   :=  p_supply_locator_id;

  --fix for 3405115.populate the requested_quantity
  l_eam_mat_req_rec.requested_quantity   :=  p_requested_quantity;
  l_eam_mat_req_rec.auto_request_material   :=  'Y';
  l_eam_mat_req_rec.transaction_type    :=  EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

  l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

      l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;

    /* Call Work Order API to perform the operations */

  eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
	   , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
	   , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	   , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
	   , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	, p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_direct_items_tbl    => l_out_eam_direct_items_tbl
	 , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
	  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
	 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
	 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
	 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
	 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
	 , x_eam_request_tbl          => l_out_eam_request_tbl
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'eamwomii.log'
   , p_debug_file_mode       => 'w'
         , p_output_dir              => l_output_dir
         );



        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;

        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

        END IF;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    --dbms_output.put_line('committing');
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count       ,
          p_data            =>      x_msg_data
      );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count     ,
            p_data            =>      x_msg_data
        );


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (
            p_count           =>      x_msg_count,
      p_data            =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME,
                l_api_name||'('||l_stmt_num||')'
          );
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
            p_data            =>      x_msg_data
        );


    END MoreMaterial_Add;

PROCEDURE MoreDirectItem_Add
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_organization_id             IN      NUMBER,
        p_operation_seq_num             IN      NUMBER,
        p_direct_item_type  IN NUMBER,
        p_item_id             IN      NUMBER,
  p_need_by_date      IN  DATE,
  p_required_quantity   IN  NUMBER,
    p_requested_quantity   IN  NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
  l_api_name      CONSTANT VARCHAR2(30) := 'MoreDirectItem_Add';
  l_api_version             CONSTANT NUMBER   := 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_organization_id           NUMBER;
    l_operation_seq_num         NUMBER;
    l_item_id       NUMBER;
    l_need_by_date    DATE;
    l_required_quantity   NUMBER;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    l_error_message             VARCHAR2(1000);
    l_output_dir    VARCHAR2(512);

    l_eam_direct_items_rec  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;

	l_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	l_out_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_out_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;


    BEGIN
  -- Standard Start of API savepoint
    SAVEPOINT EAM_WO_MATERIAL_UTIL_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (    l_api_version         ,
                                    p_api_version         ,
                                      l_api_name        ,
                                  G_PKG_NAME )
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

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_work_object_id        := p_work_object_id;
    l_organization_id       := p_organization_id;
    l_operation_seq_num     := p_operation_seq_num;
    l_item_id       := p_item_id;
    l_need_by_date      := p_need_by_date;
    l_required_quantity     := p_required_quantity;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;

    /* get output directory path from database */
  EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


if(p_direct_item_type =1) then

    /* set the required quantity for the corresponding direct item */

         l_eam_direct_items_rec.batch_id    :=  1;
        l_eam_direct_items_rec.header_id      :=  l_work_object_id;

  l_eam_direct_items_rec.wip_entity_id      :=  l_work_object_id;
  l_eam_direct_items_rec.organization_id    :=  l_organization_id;
  l_eam_direct_items_rec.operation_seq_num  :=  l_operation_seq_num;
  l_eam_direct_items_rec.direct_item_sequence_id  :=  l_item_id;
  l_eam_direct_items_rec.need_by_date   :=  l_need_by_date;
  l_eam_direct_items_rec.required_quantity  :=  l_required_quantity;

  --fix for 3405115.populate requested_quantity
  l_eam_direct_items_rec.requested_quantity  :=  p_requested_quantity;
  -- l_eam_direct_items_rec.auto_request_material :=  'Y';
  l_eam_direct_items_rec.transaction_type   :=  EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

  l_eam_direct_items_tbl(1) := l_eam_direct_items_rec;


 else

        l_eam_mat_req_rec.batch_id    :=  1;
        l_eam_mat_req_rec.header_id     :=  l_work_object_id;
  l_eam_mat_req_rec.wip_entity_id     :=  l_work_object_id;
  l_eam_mat_req_rec.organization_id     :=  l_organization_id;
  l_eam_mat_req_rec.operation_seq_num   :=  l_operation_seq_num;
  l_eam_mat_req_rec.inventory_item_id   :=  l_item_id;
  l_eam_mat_req_rec.required_quantity   :=  l_required_quantity;

  --fix for 3405115.populate requested_quantity
   l_eam_mat_req_rec.requested_quantity   :=  p_requested_quantity;
  l_eam_mat_req_rec.auto_request_material   :=  'Y';
  l_eam_mat_req_rec.transaction_type    :=  EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

  l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

  end if;

        l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
    l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

    /* Call Work Order API to perform the operations */

  eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
	   , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
	   , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	   , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
	   , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	, p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
	, x_eam_direct_items_tbl    => l_out_eam_direct_items_tbl
	, x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
	, x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
	, x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
	, x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	, x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
	, x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
	, x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
	, x_eam_request_tbl          => l_out_eam_request_tbl
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'eamwomdi.log'
   , p_debug_file_mode       => 'w'
         , p_output_dir              => l_output_dir
         );


        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;

        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

        END IF;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    --dbms_output.put_line('committing');
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count       ,
          p_data            =>      x_msg_data
      );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count     ,
            p_data            =>      x_msg_data
        );


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (
            p_count           =>      x_msg_count,
      p_data            =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME,
                l_api_name||'('||l_stmt_num||')'
          );
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
            p_data            =>      x_msg_data
        );


END MoreDirectItem_Add;


PROCEDURE insert_into_wro(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
      ,p_inventory_item_id  IN    NUMBER
      ,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
            ,p_supply               IN    NUMBER
                ,p_mode      IN   VARCHAR2  :=  'INSERT'
      ,p_required_date        IN     DATE
      ,p_quantity            IN      NUMBER
      ,p_comments            IN      VARCHAR2
      ,p_supply_subinventory  IN     VARCHAR2
      ,p_locator    IN     VARCHAR2
      ,p_mrp_net_flag         IN     VARCHAR2
      ,p_material_release     IN     VARCHAR2
                 ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                 )

                IS
                   l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wro';
                   l_api_version    CONSTANT NUMBER       := 1.0;
                   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

         l_stmt_num                   NUMBER;
         l_wip_entity_id              NUMBER;
         l_inventory_item_id          NUMBER;
         l_department_id              NUMBER;
         l_supply                     NUMBER;
         l_locator                    NUMBER;
         l_mrp_net_flag               NUMBER;
         l_material_release           VARCHAR2(1);
         l_material_exists            NUMBER := 0;
                   l_existing_operation         NUMBER;
                   l_existing_department        NUMBER;
                   l_existing_description       VARCHAR2(240);
                   l_req_qty                    NUMBER := 0;
                   l_status_type                NUMBER := 0;
                   l_material_issue_by_mo       VARCHAR2(1);
                   l_auto_request_material      VARCHAR2(1);
         invalid_update_operation     NUMBER := 0;
                   invalid_update_department    NUMBER := 0;
         invalid_update_description   NUMBER := 0;
                   l_update_status              NUMBER := 0;
                   l_return_status              NUMBER := 0;
                   l_msg_count                  NUMBER := 0;
                   l_msg_data                   VARCHAR2(2000) := '';
                   l_return_status1             VARCHAR2(30) := '';
                   l_output_dir           VARCHAR2(512);


		l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
		l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

  BEGIN
                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_insert_into_wro_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;
                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
                   -- API body

    /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    l_wip_entity_id := p_wip_entity_id ;


          -- Get Department Id

begin
          select department_id
          into l_department_id
    from wip_operations
    where wip_entity_id = l_wip_entity_id
          and operation_seq_num = p_operation_seq_num
    and organization_id = p_organization_id;
exception
  when no_data_found then
     l_department_id:=null;
end;


    -- Get Locator Id

          if (p_locator is not null) then

    select inventory_location_id
          into l_locator
    from mtl_item_locations_kfv
    where organization_id = p_organization_id
    and concatenated_segments = p_locator
    and subinventory_code = p_supply_subinventory ;

    end if;

    -- Get MRP Net Flag

    if (p_mrp_net_flag is not null) then
             l_mrp_net_flag := 1;
    else
      l_mrp_net_flag := 2;
    end if;




    if(p_mode='INSERT') then
         -- entry into WIP_REQUIREMENT_OPERATIONS

                l_eam_mat_req_rec.batch_id := 1;
                l_eam_mat_req_rec.header_id := p_wip_entity_id;
                l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := p_inventory_item_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
                l_eam_mat_req_rec.wip_supply_type := p_supply;
		    l_eam_mat_req_rec.date_required := p_required_date;
		    l_eam_mat_req_rec.required_quantity := p_quantity;
		    l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
                l_eam_mat_req_rec.supply_locator_id := l_locator;
    l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
    l_eam_mat_req_rec.comments := p_comments;
                l_eam_mat_req_rec.auto_request_material := p_material_release;

        l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;


    EAM_PROCESS_WO_PUB.Process_WO
               ( p_bo_identifier           => 'EAM'
               , p_init_msg_list           => TRUE
               , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
               , p_eam_wo_rec              => l_eam_wo_rec
               , p_eam_op_tbl              => l_eam_op_tbl
               , p_eam_op_network_tbl      => l_eam_op_network_tbl
               , p_eam_res_tbl             => l_eam_res_tbl
               , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
               , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
               , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
               , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
               , p_eam_direct_items_tbl    => l_eam_di_tbl
	       , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
	       , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	       , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	       , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
               , x_eam_wo_rec              => l_out_eam_wo_rec
               , x_eam_op_tbl              => l_out_eam_op_tbl
               , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
               , x_eam_res_tbl             => l_out_eam_res_tbl
               , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
               , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
               , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
               , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
               , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	        , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
               , x_return_status           => x_return_status
               , x_msg_count               => x_msg_count
               , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
               , p_debug_filename          => 'insertwro.log'
               , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

    else

	l_eam_mat_req_rec.batch_id := 1;
	l_eam_mat_req_rec.header_id := p_wip_entity_id;
	l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
	l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
	l_eam_mat_req_rec.organization_id := p_organization_id;
	l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
	l_eam_mat_req_rec.inventory_item_id := p_inventory_item_id;
	l_eam_mat_req_rec.quantity_per_assembly := p_quantity;
	l_eam_mat_req_rec.department_id := l_department_id;
	l_eam_mat_req_rec.wip_supply_type := p_supply;
	l_eam_mat_req_rec.date_required := p_required_date;
	l_eam_mat_req_rec.required_quantity := p_quantity;
	l_eam_mat_req_rec.supply_subinventory := p_supply_subinventory;
	l_eam_mat_req_rec.supply_locator_id := l_locator;
	l_eam_mat_req_rec.mrp_net_flag := l_mrp_net_flag;
	l_eam_mat_req_rec.comments := p_comments;
	l_eam_mat_req_rec.auto_request_material := p_material_release;

        l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;


    EAM_PROCESS_WO_PUB.Process_WO
               ( p_bo_identifier           => 'EAM'
               , p_init_msg_list           => TRUE
               , p_api_version_number      => 1.0
               , p_commit                  => 'N'
               , p_eam_wo_rec              => l_eam_wo_rec
               , p_eam_op_tbl              => l_eam_op_tbl
               , p_eam_op_network_tbl      => l_eam_op_network_tbl
               , p_eam_res_tbl             => l_eam_res_tbl
               , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
               , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
               , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
               , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
               , p_eam_direct_items_tbl    => l_eam_di_tbl
	       , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
               , x_eam_wo_rec              => l_out_eam_wo_rec
               , x_eam_op_tbl              => l_out_eam_op_tbl
               , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
               , x_eam_res_tbl             => l_out_eam_res_tbl
               , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
               , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
               , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
               , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
               , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	        , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
               , x_return_status           => x_return_status
               , x_msg_count               => x_msg_count
               , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
               , p_debug_filename          => 'updatewro.log'
               , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );


  end if;

                  IF(x_return_status<>'S') THEN
		     ROLLBACK TO get_insert_into_wro_pvt;
		  END IF;

                   -- End of API body.
                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
                   and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;

                   l_stmt_num    := 999;
                   -- Standard call to get message count and if count is 1, get message info.
                   fnd_msg_pub.count_and_get(
                      p_count => x_msg_count
                     ,p_data => x_msg_data);
            EXCEPTION
                   WHEN fnd_api.g_exc_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_error;
                      fnd_msg_pub.count_and_get(
             --            p_encoded => FND_API.g_false
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN fnd_api.g_exc_unexpected_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN OTHERS THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      IF fnd_msg_pub.check_msg_level(
                            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                      END IF;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);

 END insert_into_wro;


PROCEDURE insert_into_wdi(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
      ,p_direct_item_seq_id  IN   NUMBER  := NULL
      ,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
                 ,p_mode      IN   VARCHAR2  :=  'INSERT'
                 ,p_direct_item_type    IN VARCHAR2 :='1'
                  ,p_purchasing_category_id    NUMBER          :=null
                 ,p_suggested_vendor_id         NUMBER   :=null
                 ,p_suggested_vendor_name         VARCHAR2    :=null
                 ,p_suggested_vendor_site         VARCHAR2    :=null
                 ,p_suggested_vendor_contact      VARCHAR2    :=null
                  ,p_suggested_vendor_phone        VARCHAR2    :=null,
                  p_suggested_vendor_item_num     VARCHAR2    :=null,
                  p_unit_price                    NUMBER          :=null,
                 p_auto_request_material       VARCHAR2     :=null,
                 p_required_quantity            NUMBER          :=null,
                 p_uom                          VARCHAR2     :=null,
                  p_need_by_date                 DATE            :=null
                 ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                 )
               IS
                   l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wro';
                   l_api_version    CONSTANT NUMBER       := 1.0;
                   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

		l_stmt_num                   NUMBER;
		l_wip_entity_id              NUMBER;
		l_inventory_item_id          NUMBER;
		l_department_id              NUMBER;
		l_supply                     NUMBER;
		l_locator                    NUMBER;
		l_mrp_net_flag               NUMBER;
		l_material_release           VARCHAR2(1);
		l_material_exists            NUMBER := 0;
		l_existing_operation         NUMBER;
		l_existing_department        NUMBER;
		l_existing_description       VARCHAR2(240);
		l_req_qty                    NUMBER := 0;
		l_status_type                NUMBER := 0;
		l_material_issue_by_mo       VARCHAR2(1);
		l_auto_request_material      VARCHAR2(1);
		invalid_update_operation     NUMBER := 0;
		invalid_update_department    NUMBER := 0;
		invalid_update_description   NUMBER := 0;
		l_update_status              NUMBER := 0;
		l_return_status              NUMBER := 0;
		l_msg_count                  NUMBER := 0;
		l_msg_data                   VARCHAR2(2000) := '';
		l_return_status1             VARCHAR2(30) := '';
		l_purchasing_category_id   NUMBER :=0;
		l_site_id          NUMBER :=0;
		l_contact_id       NUMBER :=0;

		l_seq_id  NUMBER;
		l_output_dir  VARCHAR2(512);

		l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
		l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_eam_di_req_rec  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
		l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
		l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

		l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
		l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
		l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
		l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
		l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
		l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
		l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
		l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
		l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
		l_eam_di_req_rec1  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
		l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
		l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
		l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
		l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
		l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
		l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
		l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
                l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
  BEGIN
                   -- Standard Start of API savepoint
                   l_stmt_num    := 10;
                   SAVEPOINT get_insert_into_wro_pvt;

                   l_stmt_num    := 20;
                   -- Standard call to check for call compatibility.
                   IF NOT fnd_api.compatible_api_call(
                         l_api_version
                        ,p_api_version
                        ,l_api_name
                        ,g_pkg_name) THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;

                   l_stmt_num    := 30;
                   -- Initialize message list if p_init_msg_list is set to TRUE.
                   IF fnd_api.to_boolean(p_init_msg_list) THEN
                      fnd_msg_pub.initialize;
                   END IF;

                   l_stmt_num    := 40;
                   --  Initialize API return status to success
                   x_return_status := fnd_api.g_ret_sts_success;

                   l_stmt_num    := 50;
                   -- API body

    l_wip_entity_id := p_wip_entity_id ;

          -- Get Inventory Item Id

   /* get output directory path from database */
    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


          -- Get Department Id

 begin
          select department_id
          into l_department_id
    from wip_operations
    where wip_entity_id = l_wip_entity_id
          and operation_seq_num = p_operation_seq_num
    and organization_id = p_organization_id;
exception
  when no_data_found then
     l_department_id:=null;
end;


       l_seq_id :=    p_direct_item_seq_id;


   if(p_direct_item_type='1') then


               if(p_mode='INSERT') then
                       l_eam_di_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
               else
                       l_eam_di_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
               end if;

                l_eam_di_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_di_req_rec.organization_id := p_organization_id;
                l_eam_di_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_di_req_rec.direct_item_sequence_id :=l_seq_id;
                l_eam_di_req_rec.required_quantity := p_required_quantity;
                l_eam_di_req_rec.department_id := l_department_id;
                l_eam_di_req_rec.description := p_description;
		l_eam_di_req_rec.need_by_date := p_need_by_date;
		l_eam_di_req_rec.purchasing_category_id := p_purchasing_category_id  ;
                l_eam_di_req_rec.suggested_vendor_id := p_suggested_vendor_id;
                l_eam_di_req_rec.suggested_vendor_name := p_suggested_vendor_name;
                l_eam_di_req_rec.suggested_vendor_site := p_suggested_vendor_site;
                l_eam_di_req_rec.suggested_vendor_site_id := l_site_id;
                l_eam_di_req_rec.suggested_vendor_contact := p_suggested_vendor_contact;
                l_eam_di_req_rec.suggested_vendor_contact_id := l_contact_id;
                l_eam_di_req_rec.suggested_vendor_phone := p_suggested_vendor_phone;
                l_eam_di_req_rec.suggested_vendor_item_num := p_suggested_vendor_item_num;
                l_eam_di_req_rec.unit_price := p_unit_price;
                l_eam_di_req_rec.uom := p_uom;
                l_eam_di_req_rec.auto_request_material := p_auto_request_material;


        l_eam_di_tbl(1) := l_eam_di_req_rec;


    EAM_PROCESS_WO_PUB.Process_WO
               ( p_bo_identifier           => 'EAM'
               , p_init_msg_list           => TRUE
               , p_api_version_number      => 1.0
               , p_commit                  => 'N'
               , p_eam_wo_rec              => l_eam_wo_rec
               , p_eam_op_tbl              => l_eam_op_tbl
               , p_eam_op_network_tbl      => l_eam_op_network_tbl
               , p_eam_res_tbl             => l_eam_res_tbl
               , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
               , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
               , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
               , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
               , p_eam_direct_items_tbl    => l_eam_di_tbl
	       , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
               , x_eam_wo_rec              => l_out_eam_wo_rec
               , x_eam_op_tbl              => l_out_eam_op_tbl
               , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
               , x_eam_res_tbl             => l_out_eam_res_tbl
               , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
               , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
               , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
               , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
               , x_eam_direct_items_tbl    => l_out_eam_di_tbl
		 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
               , x_return_status           => x_return_status
               , x_msg_count               => x_msg_count
               , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
               , p_debug_filename          => 'insertwdi.log'
               , p_output_dir              => l_output_dir
               , p_debug_file_mode         => 'w'
                       );


    else
           if(p_mode='INSERT') then
               l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
           else
               l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
           end if;

                l_eam_mat_req_rec.batch_id := 1;
                l_eam_mat_req_rec.header_id :=p_wip_entity_id;

                l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
                l_eam_mat_req_rec.organization_id := p_organization_id;
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
                l_eam_mat_req_rec.inventory_item_id := l_seq_id;
                l_eam_mat_req_rec.quantity_per_assembly := p_required_quantity;
                l_eam_mat_req_rec.department_id := l_department_id;
                l_eam_mat_req_rec.date_required := p_need_by_date;
		l_eam_mat_req_rec.required_quantity := p_required_quantity;
                l_eam_mat_req_rec.auto_request_material := p_auto_request_material;
                l_eam_mat_req_rec.unit_price := p_unit_price;
                l_eam_mat_req_rec.suggested_vendor_name := p_suggested_vendor_name;
                l_eam_mat_req_rec.vendor_id := p_suggested_vendor_id;


        l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;


                EAM_PROCESS_WO_PUB.Process_WO
               ( p_bo_identifier           => 'EAM'
               , p_init_msg_list           => TRUE
               , p_api_version_number      => 1.0
               , p_commit                  => 'N'
               , p_eam_wo_rec              => l_eam_wo_rec
               , p_eam_op_tbl              => l_eam_op_tbl
               , p_eam_op_network_tbl      => l_eam_op_network_tbl
               , p_eam_res_tbl             => l_eam_res_tbl
               , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
               , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
               , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
               , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
               , p_eam_direct_items_tbl    => l_eam_di_tbl
	       , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
               , x_eam_wo_rec              => l_out_eam_wo_rec
               , x_eam_op_tbl              => l_out_eam_op_tbl
               , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
               , x_eam_res_tbl             => l_out_eam_res_tbl
               , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
               , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
               , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
               , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
               , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	        , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
               , x_return_status           => x_return_status
               , x_msg_count               => x_msg_count
               , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
               , p_debug_filename          => 'insertwdi.log'
               , p_output_dir              => l_output_dir
              , p_debug_file_mode         => 'w'
                       );



   end if;

                IF(x_return_status<>'S') THEN
                    ROLLBACK TO get_insert_into_wro_pvt;
                END IF;

                   -- End of API body.
                   -- Standard check of p_commit.
                   IF fnd_api.to_boolean(p_commit)
                      and x_return_status = 'S' THEN
                      COMMIT WORK;
                   END IF;

                   l_stmt_num    := 999;
                   -- Standard call to get message count and if count is 1, get message info.
                   fnd_msg_pub.count_and_get(
                      p_count => x_msg_count
                     ,p_data => x_msg_data);
            EXCEPTION
                   WHEN fnd_api.g_exc_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_error;
                      fnd_msg_pub.count_and_get(
             --            p_encoded => FND_API.g_false
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN fnd_api.g_exc_unexpected_error THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);
                   WHEN OTHERS THEN
                      ROLLBACK TO get_insert_into_wro_pvt;
                      x_return_status := fnd_api.g_ret_sts_unexp_error;
                      IF fnd_msg_pub.check_msg_level(
                            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                      END IF;

                      fnd_msg_pub.count_and_get(
                         p_count => x_msg_count
                        ,p_data => x_msg_data);

END insert_into_wdi;




Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER) return Boolean IS
Begin
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

Function Is_LocatorControlled(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER
) return VARCHAR2 IS
x_locator_ctrl NUMBER;
x_error_flag   NUMBER;
x_error_mssg   VARCHAR2(250);
Begin
Get_LocatorControl_Code(
                 p_org,
                 p_subinv,
                 p_item_id,
                 p_action,
                 x_locator_ctrl,
                 x_error_flag,
                 x_error_mssg);

if(x_locator_ctrl IN (2,3)) then
 return 'Y';
else
 return 'N';
end if;
End Is_LocatorControlled;


End eam_mtl_txn_process; -- end of eam_mtl_txt_process package


/

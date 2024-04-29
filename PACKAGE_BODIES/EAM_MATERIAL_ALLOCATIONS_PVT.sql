--------------------------------------------------------
--  DDL for Package Body EAM_MATERIAL_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIAL_ALLOCATIONS_PVT" AS
  /* $Header: EAMMTALB.pls 115.1 2003/10/09 03:24:49 dgupta noship $*/

/*
This package manages material allocations in MMTT, MTLT, MSNT along with related
interactions with move orders and WIP material requirements. Some of the APIS here
are not meant to be called in isolation. For example, reduce_allocation_header
is called in conjunction with subsequent calls to APIs as add_serial,
remove_serial, update_lot, inv_trx_util_pub.insert_lot_trx. If proper care is
not exercised in calling them in conjunction, the state of allocations
can become invalid.
*/

g_pkg_name    CONSTANT VARCHAR2(50):= 'eam_material_allocations_pvt';
g_module_name CONSTANT VARCHAR2(60):= 'eam.plsql.' || g_pkg_name;

--A helper function to fetch necessary information from MMTT for further processing.
function get_mmtt_info(
  p_transaction_temp_id   IN            NUMBER,
  x_primary_mmtt_qty      OUT NOCOPY    NUMBER,
  x_tx_qty                OUT NOCOPY    NUMBER,
  x_move_order_line_id    OUT NOCOPY    NUMBER
) return boolean IS
  l_module  constant varchar2(200) := g_module_name||'.get_mmtt_info';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
begin
  --get primary qty from MMTT
  select primary_quantity, transaction_quantity, move_order_line_id
  into x_primary_mmtt_qty, x_tx_qty, x_move_order_line_id
  from mtl_material_transactions_temp
  where transaction_temp_id = p_transaction_temp_id;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'MMTT: x_primary_mmtt_qty=' || x_primary_mmtt_qty|| ',x_tx_qty=' || x_tx_qty
    || ',x_move_order_line_id=' || x_move_order_line_id);
  end if;
  return true;
exception
when no_data_found then
  if (l_log and (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
    'Transaction Temp Id '|| p_transaction_temp_id || ' not found');
  end if;
  fnd_message.set_name('EAM', 'EAM_ALLOCATION_NOT_FOUND');
  fnd_msg_pub.add;
  return false;
WHEN OTHERS THEN
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Unhandled exception in get_mmtt_info');
  end if;
  return false;
end get_mmtt_info;

/* A private procedure to reduce a move order line. This is useful in cases when
after reducing a allocation, we also want to reduce the move order and optionally
the WIP requirements for this material
*/
procedure reduce_move_order(
  p_move_order_line_id in  number,
  p_qty_to_reduce in number,
  p_reduce_wip_requirements in varchar2
) IS
  l_module  constant varchar2(200) := g_module_name||'.reduce_move_order';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_txn_source_id    number;
  l_inventory_item_id number;
begin
  -- Propagate changes to Move Order header,line and WRO if propagate parameter is set
  -- As per Inventory, if a move order line has no allocations, it should be
  -- closed (status 5), not cancelled (status 6)
  update mtl_txn_request_lines
  set quantity = quantity - p_qty_to_reduce,
  quantity_detailed = quantity_detailed - p_qty_to_reduce,
  line_status = decode(quantity,p_qty_to_reduce,5,line_status)
  where line_id = p_move_order_line_id
  returning txn_source_id, inventory_item_id
  into l_txn_source_id, l_inventory_item_id;

  if ((p_reduce_wip_requirements is null) or (p_reduce_wip_requirements= 'Y')) then
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'MTRL: l_txn_source_id (wip entity id)=' || l_txn_source_id );
    end if;
    update wip_requirement_operations
    set quantity_allocated = quantity_allocated - p_qty_to_reduce
    where wip_entity_id = l_txn_source_id
    and inventory_item_id = l_inventory_item_id;
  end if;
end reduce_move_order;

/* This procedure deletes a allocation and reduces the move order and WIP material
requirements by a corresponding amount. Thus this is to be used when the allocated
material is no longer wanted by the requestor.
*/
PROCEDURE delete_allocation(
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_transaction_temp_id   IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
) IS
  l_module              constant varchar2(200) := g_module_name||'.delete_allocation';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_primary_mmtt_qty    number;
  l_tx_qty              number;
  l_move_order_line_id  number;
BEGIN
  SAVEPOINT DELETE_ALLOCATION;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of '||l_module ||'('||'p_transaction_temp_id='||p_transaction_temp_id||')');
  end if;

  --API start
  --get primary qty and other information from MMTT
  --Later on can reduce dependance on this by optional parameters which give this
  --information(saves a db hit). If these are not provided, then we cn query up MMTT
  if (not get_mmtt_info(p_transaction_temp_id,l_primary_mmtt_qty,
  l_tx_qty, l_move_order_line_id)) then
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
	  return;
  end if;
  --Reduce the allocation quantities in Move order headers, lines and in WRO
  reduce_move_order(l_move_order_line_id, l_primary_mmtt_qty, 'Y');
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Calling inv_trx_util_pub.delete_transaction');
  end if;
  --Call the inventory delete API.
  --This API is similar to the wrapper inv_mo_line_detail_util.delete_allocation
  inv_trx_util_pub.delete_transaction(
      x_return_status       => x_return_status
    , x_msg_data            => x_msg_data
    , x_msg_count           => x_msg_count
    , p_transaction_temp_id => p_transaction_temp_id
  );
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    eam_common_utilities_pvt.log_api_return(l_module,
      'inv_trx_util_pub.delete_transaction',x_return_status,x_msg_count,x_msg_data);
  end if;
  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    raise fnd_api.g_exc_error;
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
WHEN fnd_api.g_exc_error THEN
  x_return_status  := fnd_api.g_ret_sts_error;
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  ROLLBACK to delete_allocation;
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 	FND_MSG_PUB.Count_And_Get(
    p_count         	=>      x_msg_count,
    p_data          	=>      x_msg_data);
  ROLLBACK to delete_allocation;
end delete_allocation;

/* Reduces the allocation header at the MMTT level and reduces the move order
and WIP material requirements by a corresponding amount. Thus this is to be used
when the requestor wants to reduce his requirement and free up the allocation.
For lot and/or serial controlled items, this API is to be followed by subsequent
calls to other APIs to adjust the lot and serial allocations.
*/
PROCEDURE reduce_allocation_header(
  p_init_msg_list            IN            VARCHAR2,
  p_commit                   IN            VARCHAR2,
  p_transaction_temp_id      IN            NUMBER,
  p_organization_id          IN            NUMBER,
  p_qty_to_reduce            IN            NUMBER,
  p_final_qty                IN            NUMBER,
  p_delete_remaining         IN            VARCHAR2,
  x_new_transaction_temp_id  OUT NOCOPY    NUMBER,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
) IS
  l_module              constant varchar2(200) := g_module_name||'.reduce_allocation_header';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_qty_to_reduce       number;
  l_final_qty           number;
  l_primary_mmtt_qty    number;
  l_tx_qty              number;
  l_move_order_line_id  number;
BEGIN
  SAVEPOINT reduce_allocation_header;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_transaction_temp_id='|| p_transaction_temp_id
    || ',p_qty_to_reduce='|| p_qty_to_reduce || ',p_final_qty='|| p_final_qty
    || ',p_delete_remaining='|| p_delete_remaining || ')');
  end if;

  --API start
  --get primary qty and other information from MMTT
  if (not get_mmtt_info(p_transaction_temp_id,l_primary_mmtt_qty,
  l_tx_qty, l_move_order_line_id)) then
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
	  return;
	end if;
  --Qty can be entered as either reduction amount (delta) or final reduced amount
  --Assume that the quantity specified is in terms of primary UOM
  if (p_qty_to_reduce is not null) then
    l_final_qty := l_primary_mmtt_qty - p_qty_to_reduce;
    l_qty_to_reduce := p_qty_to_reduce;
  else
    l_final_qty := p_final_qty;
    l_qty_to_reduce := l_primary_mmtt_qty - p_final_qty;
  end if;
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calculated l_final_qty='||l_final_qty||
        ',l_qty_to_reduce='||l_qty_to_reduce);
    end if;
  --Validate final qty and if correct, reduce MMTT
  if (l_final_qty <= 0) then
    if (l_log and (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'Cannot reduce qty to below 0');
    end if;
    fnd_message.set_name('EAM', 'EAM_NON_POSITIVE_ISSUE_QTY');
    fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
	  return;
	--Following elsif (3 lines): not sure whether we should allow delete here
  --also or only in delete_allocation
	--elsif (l_final_qty = 0) then
	--  delete mtl_material_transactions_temp
	--  where transaction_temp_id = p_transaction_temp_id;
	else
    update mtl_material_transactions_temp
    set primary_quantity = l_final_qty,  --following line converts between base to tx uom
    transaction_quantity = l_final_qty * (l_tx_qty/l_primary_mmtt_qty)
    where transaction_temp_id = p_transaction_temp_id;
  end if;

  if (p_delete_remaining is not null and (p_delete_remaining = 'Y')) then
    --Reduce the allocation quantities in Move order headers, lines and in WRO
    reduce_move_order(l_move_order_line_id, l_qty_to_reduce, 'Y');
  elsif (l_qty_to_reduce > 0) then
    -- save the remainder allocation by splitting current allocation.
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calling inv_trx_util_pub.copy_insert_line_trx');
    end if;
    --call the split API passing in current transaction temp id, split qty
    inv_trx_util_pub.copy_insert_line_trx(
      x_return_status       => x_return_status
    , x_msg_data            => x_msg_data
    , x_msg_count           => x_msg_count
    , x_new_txn_temp_id     => x_new_transaction_temp_id
    , p_transaction_temp_id => p_transaction_temp_id
    , p_organization_id     => p_organization_id
    , p_txn_qty             => l_qty_to_reduce
    , p_primary_qty         => l_qty_to_reduce
    );
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      eam_common_utilities_pvt.log_api_return(l_module,
        'inv_trx_util_pub.copy_insert_line_trx',x_return_status,x_msg_count,x_msg_data);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'inv_trx_util_pub.copy_insert_line_trx returned '
        || 'x_new_txn_temp_id='|| x_new_transaction_temp_id);
    end if;
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise fnd_api.g_exc_error;
    end if;
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
WHEN fnd_api.g_exc_error THEN
  x_return_status  := fnd_api.g_ret_sts_error;
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  ROLLBACK to reduce_allocation_header;
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 	FND_MSG_PUB.Count_And_Get(
    p_count         	=>      x_msg_count,
    p_data          	=>      x_msg_data);
  ROLLBACK to reduce_allocation_header;
end reduce_allocation_header;

/* Removes a serial allocation from MSNT and frees up/unmarks the serial in MSN.
Optionally if a new allocation temp id is provided, it can split this serial to
the new allocation temp id. This API does not adjust the quantities at the MMTT
or MTLT level and assumes that they have been adjusted by another API call.
Currently this API assumes that the serial numbers have a range of 1 (the
pick release process allocates serial numbers individually, not in ranges), this
assumption can be relaxed in the future by first splitting the range into
individual rows, then deleting just the row for this serial number.
*/
PROCEDURE remove_serial(
  p_init_msg_list              IN            VARCHAR2,
  p_commit                     IN            VARCHAR2,
  p_transaction_temp_id        IN            NUMBER,
  p_serial                     IN            VARCHAR2,
  p_lot                        IN            VARCHAR2,
  p_inventory_item_id          IN            NUMBER,
  p_new_transaction_temp_id    IN            NUMBER,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
) IS
  l_module              constant varchar2(200) := g_module_name||'.remove_serial';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
BEGIN
  SAVEPOINT remove_serial;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_transaction_temp_id='|| p_transaction_temp_id
    || ',p_serial='|| p_serial || ',p_lot='|| p_lot
    || ',p_new_transaction_temp_id='|| p_new_transaction_temp_id ||')');
  end if;

  --API start
  if (p_new_transaction_temp_id is not null) then
    --replace the transaction_temp_id for msnt row with this one.
    UPDATE mtl_serial_numbers_temp
       SET transaction_temp_id = p_new_transaction_temp_id
     WHERE transaction_temp_id = p_transaction_temp_id
       AND fm_serial_number = p_serial;
     --restamp the group mark id in msn.
    UPDATE mtl_serial_numbers
       SET group_mark_id = p_new_transaction_temp_id
     WHERE group_mark_id = p_transaction_temp_id
       AND serial_number = p_serial;
  else
    --delete current msnt row and then unmark serial
    DELETE FROM mtl_serial_numbers_temp
    WHERE transaction_temp_id = p_transaction_temp_id
    and fm_serial_number = p_serial;
    --Can also use serial_check.inv_unmark_serial
    UPDATE mtl_serial_numbers
       SET line_mark_id = -1
         , group_mark_id = -1
         , lot_line_mark_id = -1
     WHERE group_mark_id =  p_transaction_temp_id
       AND serial_number = p_serial;
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    ROLLBACK to remove_serial;
end remove_serial;

/* Adds a serial allocation to MSNT and reserves/marks the serial in MSN.
This API does not adjust the quantities at the MMTT or MTLT level and assumes
that they have been adjusted by another API call.
*/
PROCEDURE add_serial(
  p_init_msg_list              IN            VARCHAR2,
  p_commit                     IN            VARCHAR2,
  p_transaction_temp_id        IN            NUMBER,
  p_organization_id            IN            NUMBER,
  p_inventory_item_id          IN            NUMBER,
  p_serial                     IN            VARCHAR2,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
) IS
  l_module              constant varchar2(200) := g_module_name||'.add_serial';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_insert_count number;
  l_update_count number;
BEGIN
  SAVEPOINT add_serial;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('  ||
    'p_transaction_temp_id='|| p_transaction_temp_id ||
    'p_organization_id='|| p_organization_id ||
    'p_inventory_item_id='|| p_inventory_item_id ||
    ',p_serial='|| p_serial ||')');
  end if;

  --API start
  --Not using inv_trx_util_pub.insert_ser_trx and serial_check.inv_mark_serial
  --because of bug 2798128
  INSERT INTO mtl_serial_numbers_temp(transaction_temp_id
   , fm_serial_number, to_serial_number, serial_prefix
   , last_update_date, last_updated_by, creation_date, created_by
   )
  VALUES(p_transaction_temp_id,p_serial, p_serial, 1
    , SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.user_id);
  l_insert_count := SQL%ROWCOUNT;

  UPDATE mtl_serial_numbers
     SET group_mark_id = p_transaction_temp_id
   WHERE serial_number = p_serial
     AND current_organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;
  l_update_count := SQL%ROWCOUNT;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
   l_insert_count|| ' serials inserted into MSNT. '||l_update_count||
   ' serials marked in MSN');
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    ROLLBACK to add_serial;
end add_serial;

/* This API serves three functions:
1) Update lot quantity (if p_lot_quantity is non zero)
2) Delete a lot (if p_lot_quantity is zero)
3) Split a lot (if p_lot_quantity is less than current qty and new tx temp id is provided)
This API does not adjust the quantities at the MMTT or MSNT level and assumes
that they have been adjusted by another API call. Future work may need
to be done on the uniqueness of temp id, lot_number and qty combination.
*/
PROCEDURE update_lot(
  p_init_msg_list              IN            VARCHAR2,
  p_commit                     IN            VARCHAR2,
  p_transaction_temp_id        IN            NUMBER,
  p_serial_transaction_temp_id IN            NUMBER,
  p_lot                        IN            VARCHAR2,
  p_lot_quantity               IN            NUMBER,
  p_old_lot_quantity           IN            NUMBER,
  p_new_transaction_temp_id    IN            NUMBER,
  x_ser_trx_id                 OUT NOCOPY    NUMBER,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
) IS
  l_module    constant varchar2(200) := g_module_name||'.update_lot';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_update_count number := 0;
  l_delete_count number := 0;
  l_insert_ret_status number := null;
  l_reduction_qty number := null;
BEGIN
  SAVEPOINT reduce_lot;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_transaction_temp_id='|| p_transaction_temp_id
    || ' p_serial_transaction_temp_id='|| p_serial_transaction_temp_id
    || ',p_lot='|| p_lot || ',p_lot_quantity='|| p_lot_quantity
    || ',p_old_lot_quantity='|| p_old_lot_quantity
    || ',p_new_transaction_temp_id='|| p_new_transaction_temp_id|| ')');
  end if;

  --API start
  --update the qty of the current row. If qty = 0, delete this row.
  if (p_lot_quantity > 0) then
    if (p_serial_transaction_temp_id is not null) then
      update mtl_transaction_lots_temp
      set primary_quantity = p_lot_quantity,
      transaction_quantity = p_lot_quantity
      where serial_transaction_temp_id = p_serial_transaction_temp_id
      and transaction_temp_id = p_transaction_temp_id
      and lot_number = p_lot
      and primary_quantity = p_old_lot_quantity;
    else
      update mtl_transaction_lots_temp
      set primary_quantity = p_lot_quantity,
      transaction_quantity = p_lot_quantity
      where transaction_temp_id = p_transaction_temp_id
      and lot_number = p_lot
      and primary_quantity = p_old_lot_quantity
      and rownum = 1;--update only one row since there is no PK in this table
                     --and it is discouraged to use rowid: distributed databases
                     --or partitioning may change it within a transaction
    end if;
    l_update_count := SQL%ROWCOUNT;
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      l_update_count || ' row(s) updated in MTLT');
    end if;
    l_reduction_qty := (p_old_lot_quantity - p_lot_quantity);
    if (p_new_transaction_temp_id is not null and (l_reduction_qty >0)) then
      --split this mtlt row under a new MMTT row with remaining qty
      if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calling inv_trx_util_pub.insert_lot_trx('|| 'p_pri_qty=p_trx_qty='|| l_reduction_qty);
      end if;
      l_insert_ret_status := inv_trx_util_pub.insert_lot_trx(
        p_trx_tmp_id => p_new_transaction_temp_id
      , p_user_id    => fnd_global.user_id
      , p_lot_number => p_lot
      , p_trx_qty    => l_reduction_qty
      , p_pri_qty    => l_reduction_qty
      , x_proc_msg   => x_msg_data
      , x_ser_trx_id => x_ser_trx_id);
      if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'inv_trx_util_pub.insert_lot_trx returned: Status='||
        l_insert_ret_status|| ' (0 success, -1 failure)'||
        ', Return Message='|| x_msg_data|| ', Serial Temp Id='||
        x_ser_trx_id);
      end if;
    end if;
  elsif (p_lot_quantity = 0) then
    delete from mtl_transaction_lots_temp
    where transaction_temp_id = p_transaction_temp_id
    and lot_number = p_lot
    and primary_quantity = p_old_lot_quantity
    and rownum = 1;
    l_delete_count := SQL%ROWCOUNT;
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      l_delete_count || ' row(s) deleted in MTLT');
    end if;
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    ROLLBACK to reduce_lot;
end update_lot;

/* Marks a lot row in MTLT with a serial transaction temp id so that
child records in MSNT can be inserted for this lot.
*/
PROCEDURE mark_lot_with_ser_temp_id(
  p_init_msg_list              IN            VARCHAR2,
  p_commit                     IN            VARCHAR2,
  p_transaction_temp_id        IN            NUMBER,
  p_lot                        IN            VARCHAR2,
  p_primary_quantity           IN            NUMBER,
  x_ser_trx_id                 OUT NOCOPY    NUMBER,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
) IS
  l_module    constant varchar2(200) := g_module_name||'.mark_lot_with_ser_temp_id';
  l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
  l_update_count number := 0;
  l_ser_trx_id number;
BEGIN
  SAVEPOINT mark_lot_with_ser_temp_id;
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_count := 0;

  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '(' ||'p_commit=' ||p_commit
     || 'p_transaction_temp_id='|| p_transaction_temp_id
     || ',p_lot='|| p_lot || ',p_primary_quantity='|| p_primary_quantity|| ')');
  end if;

  --API start
  SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL into l_ser_trx_id from dual;
  update mtl_transaction_lots_temp
    set serial_transaction_temp_id = l_ser_trx_id
    where transaction_temp_id = p_transaction_temp_id
    and lot_number = p_lot
    and primary_quantity = p_primary_quantity
    and rownum = 1;
  l_update_count := SQL%ROWCOUNT;
  if (l_update_count = 1) then
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_ser_trx_id := l_ser_trx_id;
  end if;
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, l_update_count ||
    ' row(s) updated in MTLT with serial_transaction_temp_id: '|| x_ser_trx_id);
  end if;
  --API end

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    ROLLBACK to mark_lot_with_ser_temp_id;
end mark_lot_with_ser_temp_id;

END EAM_MATERIAL_ALLOCATIONS_PVT;

/

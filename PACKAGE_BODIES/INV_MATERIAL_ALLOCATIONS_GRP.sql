--------------------------------------------------------
--  DDL for Package Body INV_MATERIAL_ALLOCATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MATERIAL_ALLOCATIONS_GRP" AS
  /* $Header: INVMTALB.pls 120.1.12010000.2 2008/07/29 12:53:25 ptkumar ship $*/

/*
This package manages material allocations in MMTT, MTLT, MSNT along with related
interactions with move orders and WIP material requirements. Some of the APIS here
are not meant to be called in isolation. For example, reduce_allocation_header
is called in conjunction with subsequent calls to APIs as add_serial,
remove_serial, update_lot, inv_trx_util_pub.insert_lot_trx. If proper care is
not exercised in calling them in conjunction, the state of allocations
can become invalid.
*/

g_pkg_name    CONSTANT VARCHAR2(50):= 'inv_material_allocations_grp';
g_module_name CONSTANT VARCHAR2(60):= 'inv.plsql.' || g_pkg_name;

--A helper function to fetch necessary information from MMTT for further processing.
function get_mmtt_info(
  p_transaction_temp_id   IN            NUMBER,
  x_primary_mmtt_qty      OUT NOCOPY    NUMBER,
  x_tx_qty                OUT NOCOPY    NUMBER,
  x_move_order_line_id    OUT NOCOPY    NUMBER,
  x_item_primary_uom_code OUT NOCOPY    VARCHAR2,
  x_transaction_uom       OUT NOCOPY    VARCHAR2,
  x_inventory_item_id     OUT NOCOPY    NUMBER
) return boolean IS
  l_module  constant varchar2(200) := g_module_name||'.get_mmtt_info';
  l_log CONSTANT NUMBER := fnd_log.g_current_runtime_level;
  l_elog  CONSTANT boolean := ((FND_LOG.LEVEL_EXCEPTION >= l_log) and FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= l_log));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= l_log));
begin
  --get primary qty from MMTT
  select primary_quantity, transaction_quantity, move_order_line_id,
  item_primary_uom_code, transaction_uom, inventory_item_id
  into x_primary_mmtt_qty, x_tx_qty, x_move_order_line_id,
  x_item_primary_uom_code, x_transaction_uom, x_inventory_item_id
  from mtl_material_transactions_temp
  where transaction_temp_id = p_transaction_temp_id;

  if (l_slog) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'MMTT: x_primary_mmtt_qty=' || x_primary_mmtt_qty|| ',x_tx_qty=' || x_tx_qty
    || ',x_move_order_line_id=' || x_move_order_line_id
    || ',x_item_primary_uom_code=' || x_item_primary_uom_code
    || ',x_transaction_uom='|| x_transaction_uom
    || ',x_inventory_item_id='  ||  x_inventory_item_id
    );
  end if;
  return true;
exception
when no_data_found then
  if (l_elog) then
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
    'Transaction Temp Id '|| p_transaction_temp_id || ' not found');
  end if;
  fnd_message.set_name('INV', 'INV_ALLOCATION_NOT_FOUND');
  fnd_msg_pub.add;
  return false;
WHEN OTHERS THEN
  if (l_slog) then
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_txn_source_id    number;
  l_inventory_item_id number;
  l_operation_seq_num number;
  l_organization_id number;
begin
  -- Propagate changes to Move Order header,line and WRO if propagate parameter is set
  -- As per Inventory, if a move order line has no allocations, it should be
  -- closed (status 5), not cancelled (status 6)
  update mtl_txn_request_lines     --overpicking not supported for eam
  set quantity = quantity - p_qty_to_reduce,
  quantity_detailed = quantity_detailed - p_qty_to_reduce,
  line_status = decode(quantity,p_qty_to_reduce,5,line_status),
  status_date = sysdate            -- BUG 5636266
  where line_id = p_move_order_line_id
  returning txn_source_id, inventory_item_id,txn_source_line_id,organization_id
  into l_txn_source_id, l_inventory_item_id,l_operation_seq_num,l_organization_id;

  if ((p_reduce_wip_requirements is null) or (p_reduce_wip_requirements= 'Y')) then
    if (l_slog) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'MTRL: l_txn_source_id (wip entity id)=' || l_txn_source_id );
    end if;
    update wip_requirement_operations
    set quantity_allocated = quantity_allocated - p_qty_to_reduce
    where organization_id = l_organization_id
    and wip_entity_id = l_txn_source_id
    and operation_seq_num=l_operation_seq_num
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_primary_mmtt_qty    number;
  l_tx_qty              number;
  l_move_order_line_id  number;
  l_dummy_v             varchar2(3);
  l_dummy_n             number;
BEGIN
  SAVEPOINT DELETE_ALLOCATION;
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of '||l_module ||'('||'p_transaction_temp_id='||p_transaction_temp_id||')');
  end if;

  --API start
  --get primary qty and other information from MMTT
  --Later on can reduce dependance on this by optional parameters which give this
  --information(saves a db hit). If these are not provided, then we cn query up MMTT
  if (not get_mmtt_info(p_transaction_temp_id,l_primary_mmtt_qty,
  l_tx_qty, l_move_order_line_id, l_dummy_v, l_dummy_v, l_dummy_n)) then
    FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    x_return_status  := fnd_api.g_ret_sts_error;
    return;
  end if;
  --Reduce the allocation quantities in Move order headers, lines and in WRO
  reduce_move_order(l_move_order_line_id, l_primary_mmtt_qty, 'Y');
  if (l_slog) then
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
  if (l_slog) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
     'inv_trx_util_pub.delete_transaction returns. Return status='
     || x_return_status|| ', Message Count = '|| x_msg_count
     || ', Message data=' || REPLACE(x_msg_data, CHR(0), ' '));
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
  if (l_plog) then
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
    p_count           =>      x_msg_count,
    p_data            =>      x_msg_data);
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog CONSTANT boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_qty_to_reduce       number;
  l_final_qty           number;
  l_final_tx_qty        number;
  l_primary_mmtt_qty    number;
  l_tx_qty              number;
  l_move_order_line_id  number;
  l_item_primary_uom_code varchar2(3);
  l_transaction_uom     varchar2(3);
  l_inventory_item_id   number;
BEGIN
  SAVEPOINT reduce_allocation_header;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_transaction_temp_id='|| p_transaction_temp_id
    || ',p_qty_to_reduce='|| p_qty_to_reduce || ',p_final_qty='|| p_final_qty
    || ',p_delete_remaining='|| p_delete_remaining || ')');
  end if;

  --API start
  --get primary qty and other information from MMTT
  if (not get_mmtt_info(p_transaction_temp_id,l_primary_mmtt_qty,
  l_tx_qty, l_move_order_line_id, l_item_primary_uom_code, l_transaction_uom,
  l_inventory_item_id)) then
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
  if (l_slog) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Calculated l_final_qty='||l_final_qty||
        ',l_qty_to_reduce='||l_qty_to_reduce);
    end if;
  --Validate final qty and if correct, reduce MMTT
  if (l_final_qty <= 0) then
    if (l_elog) then
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'Cannot reduce qty to below 0');
    end if;
    fnd_message.set_name('INV', 'INV_NON_POSITIVE_ISSUE_QTY');
    fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    return;
  --Following elsif (3 lines): not sure whether we should allow delete here
  --also or only in delete_allocation
  --elsif (l_final_qty = 0) then
  --  delete mtl_material_transactions_temp
  --  where transaction_temp_id = p_transaction_temp_id;
  else
    -- Convert the count quantity into the item primary uom quantity
    l_final_tx_qty :=
      inv_convert.inv_um_convert ( l_inventory_item_id,
                                  5,
                                  l_final_qty,
                                  l_item_primary_uom_code,
                                  l_transaction_uom,
                                  NULL,
                                  NULL
                                );
    update mtl_material_transactions_temp
    set primary_quantity = l_final_qty,  --following line converts between base to tx uom
    transaction_quantity = l_final_tx_qty
    where transaction_temp_id = p_transaction_temp_id;
  end if;

  if (p_delete_remaining is not null and (p_delete_remaining = 'Y')) then
    --Reduce the allocation quantities in Move order headers, lines and in WRO
    reduce_move_order(l_move_order_line_id, l_qty_to_reduce, 'Y');
  elsif (l_qty_to_reduce > 0) then
    -- save the remainder allocation by splitting current allocation.
    if (l_slog) then
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
    if (l_slog) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
       'inv_trx_util_pub.copy_insert_line_trx returns. Return status='
       || x_return_status|| ', Message Count = '|| x_msg_count
       || 'x_new_txn_temp_id='|| x_new_transaction_temp_id
       || ', Message data=' || REPLACE(x_msg_data, CHR(0), ' '));
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
  if (l_plog) then
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
    p_count           =>      x_msg_count,
    p_data            =>      x_msg_data);
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
BEGIN
  SAVEPOINT remove_serial;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_transaction_temp_id='|| p_transaction_temp_id
    || ',p_inventory_item_id='|| p_inventory_item_id
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
     --restamp the group mark id in msn. needed for bug 2798128 (expects temp id)
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
     WHERE inventory_item_id = p_inventory_item_id  --no need of org id, item and serial are unique
       AND serial_number = p_serial;
  end if;
  --API end

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count           =>      x_msg_count,
      p_data            =>      x_msg_data);
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_update_count number;
  l_insert_err_code number;
BEGIN
  SAVEPOINT add_serial;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('  ||
    'p_transaction_temp_id='|| p_transaction_temp_id ||
    'p_organization_id='|| p_organization_id ||
    'p_inventory_item_id='|| p_inventory_item_id ||
    ',p_serial='|| p_serial ||')');
  end if;

  --API start
  l_insert_err_code := inv_trx_util_pub.insert_ser_trx(
    p_trx_tmp_id     => p_transaction_temp_id,
    p_user_id        => FND_GLOBAL.USER_ID,
    p_fm_ser_num     => p_serial,
    p_to_ser_num     => p_serial,
    x_proc_msg       => x_msg_data);
  --Restamping group_mark_id in MSN as transaction temp id. The default from
  --insert_ser_trx or from inv_mark_serial is transaction header id which is
  --not acceptable because of bug 2798128 (expects temp id, not hdr id)
  if (l_insert_err_code = 0) then   -- 0 = success
    UPDATE mtl_serial_numbers
       SET group_mark_id = p_transaction_temp_id
     WHERE serial_number = p_serial
       AND current_organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;
    l_update_count := SQL%ROWCOUNT;
  end if;

  if (l_slog) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    l_update_count||  ' serials marked in MSN');
  end if;
  --API end

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  if (l_insert_err_code = 0) then   -- 0 = success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  else
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if;
  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count           =>      x_msg_count,
      p_data            =>      x_msg_data);
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_update_count number := 0;
  l_delete_count number := 0;
  l_insert_ret_status number := null;
  l_reduction_qty number := null;
BEGIN
  SAVEPOINT reduce_lot;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  if (l_plog) then
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
    if (l_slog) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      l_update_count || ' row(s) updated in MTLT');
    end if;
    l_reduction_qty := (p_old_lot_quantity - p_lot_quantity);
    if (p_new_transaction_temp_id is not null and (l_reduction_qty >0)) then
      --split this mtlt row under a new MMTT row with remaining qty
      if (l_slog) then
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
      if (l_slog) then
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
    if (l_slog) then
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
  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count           =>      x_msg_count,
      p_data            =>      x_msg_data);
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
  l_elog  boolean := ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
    FND_LOG.TEST(FND_LOG.LEVEL_EXCEPTION, l_module));
  l_plog boolean := (l_elog and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_slog boolean := (l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
  l_update_count number := 0;
  l_ser_trx_id number;
BEGIN
  SAVEPOINT mark_lot_with_ser_temp_id;
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_count := 0;

  if (l_plog) then
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
  if (l_slog) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, l_update_count ||
    ' row(s) updated in MTLT with serial_transaction_temp_id: '|| x_ser_trx_id);
  end if;
  --API end

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_plog) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count           =>      x_msg_count,
      p_data            =>      x_msg_data);
    ROLLBACK to mark_lot_with_ser_temp_id;
end mark_lot_with_ser_temp_id;

END INV_MATERIAL_ALLOCATIONS_GRP;

/

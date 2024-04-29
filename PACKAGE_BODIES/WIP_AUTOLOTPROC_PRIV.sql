--------------------------------------------------------
--  DDL for Package Body WIP_AUTOLOTPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_AUTOLOTPROC_PRIV" as
 /* $Header: wiplotpb.pls 120.3.12010000.2 2009/03/03 00:40:36 pding ship $ */


  -----------------------
  --private package types
  -----------------------

  type num_tbl_t is table of number;
  type char_tbl_t is table of varchar2(30);
  type big_char_tbl_t is table of varchar2(2000);

  type itemInfo_recTbl_t is record(txnID             num_tbl_t,  --either temp_id or interface_id
                                   opSeqNum          num_tbl_t,
                                   itemID            num_tbl_t,
                                   itemName          big_char_tbl_t,
                                   priQty            num_tbl_t,
                                   lotPriQty         num_tbl_t,
                                   txnQty            num_tbl_t,
                                   priUomCode        char_tbl_t,
                                   supplySubinv      char_tbl_t,
                                   supplyLocID       num_tbl_t,
--                                   wipSupplyType     num_tbl_t,
                                   txnActionID         num_tbl_t,
                                   txnsEnabledFlag   char_tbl_t,
                                   serialControlCode num_tbl_t,
                                   lotControlCode    num_tbl_t,
                                   revision          char_tbl_t,
                                   movTxnID          num_tbl_t,
                                   cplTxnID          num_tbl_t);


  type itemInfo_rec_t is record(txnID             NUMBER,  --either temp_id or interface_id
                                opSeqNum          NUMBER,
                                itemID            NUMBER,
                                itemName          VARCHAR2(2000),
                                priQty            NUMBER,
                                lotPriQty         NUMBER,
                                txnQty            NUMBER,
                                priUomCode        VARCHAR2(3),
                                supplySubinv      VARCHAR2(30),
                                supplyLocID       NUMBER,
                                wipSupplyType     NUMBER,
                                txnActionID         NUMBER,
                                txnsEnabledFlag   VARCHAR2(1),
                                serialControlCode NUMBER,
                                lotControlCode    NUMBER,
                                revision          VARCHAR2(3));

  ----------------------
  --forward declarations
  ----------------------

  function worstReturnStatus(p_status1 VARCHAR2, p_status2 VARCHAR2) return VARCHAR2;
  function getTxnType(p_txnActionID IN NUMBER) return NUMBER;

  --checks to see if there are any serial requirements unfulfilled
  procedure checkSerial(p_txnTmpID           IN NUMBER,
                        p_txnIntID           IN NUMBER,
                        p_itemID             IN NUMBER,
                        p_itemName           IN VARCHAR2,
                        p_orgID              IN NUMBER,
                        p_revision           IN VARCHAR2,
                        p_subinv             IN VARCHAR2,
                        p_locID              IN NUMBER,
                        p_qty                IN NUMBER,
                        p_txnActionID          IN NUMBER,
                        p_serControlCode     IN NUMBER,
                        x_serialReturnStatus OUT NOCOPY VARCHAR2,
                        x_returnStatus       OUT NOCOPY VARCHAR2);

  --checks to see if there are enough serial numbers to fulfill open requirements
  procedure checkSerialQuantity(p_itemID         IN NUMBER,
                                p_itemName       IN VARCHAR2,
                                p_orgID          IN NUMBER,
                                p_qty            IN NUMBER,
                                p_txnActionID    IN NUMBER,
                                p_serControlCode IN NUMBER,
                                x_returnStatus   OUT NOCOPY VARCHAR2);

  procedure deriveSingleItem(p_orgID        IN NUMBER,
                             p_wipEntityID  IN NUMBER,
                             p_entryType    IN NUMBER,
                             p_treeMode     IN NUMBER,
                             p_treeSrcName  IN VARCHAR2,
                             x_treeID       IN OUT NOCOPY NUMBER, --the qty tree id if one was built
                             x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
                             x_returnStatus OUT NOCOPY VARCHAR2);

  function findTxnAction(p_isForwardTxn IN VARCHAR2,
                         p_qty          IN NUMBER) return number;

  /* Fix for Bug#4956543. Added following lot_selected procedure
       This procedure will return Lot Quantity populated by the system for a
       particular Lot. Since Quantity Tree is not considering MTI records for
       Quantity calculation, we need to look into interface tables
  */
  procedure  lot_selected (
                      p_organization_id      NUMBER,
                      p_inventory_item_id    NUMBER,
                      p_sub_code             VARCHAR2,
                      p_locator_id           NUMBER,
                      p_lot_number           VARCHAR2,
                      p_lot_qty_selected     OUT NOCOPY NUMBER,
                      x_returnStatus         OUT NOCOPY VARCHAR2);



  ---------------------------
  --public/private procedures
  ---------------------------
  procedure deriveLots(x_compLots      IN OUT NOCOPY system.wip_lot_serial_obj_t,
                       p_orgID         IN NUMBER,
                       p_wipEntityID   IN NUMBER,
                       p_initMsgList   IN VARCHAR2,
                       p_endDebug      IN VARCHAR2,
                       p_destroyTrees  IN VARCHAR2,
                       p_treeMode      IN NUMBER,
                       p_treeSrcName   IN VARCHAR2,
                       x_returnStatus OUT NOCOPY VARCHAR2) is
    l_index NUMBER;
    l_returnStatus VARCHAR2(1);
    l_msgCount NUMBER;
    l_msgData VARCHAR2(240);
    l_numLotsDerived NUMBER;
    l_curItem system.wip_component_obj_t;
    l_treeID NUMBER;
    l_prevItem NUMBER := -1;
    l_lotTbl system.wip_txn_lot_tbl_t;
    l_params wip_logger.param_tbl_t;
    l_errMsg VARCHAR2(80);
    l_entryType NUMBER;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveLots',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    select backflush_lot_entry_type
      into l_entryType
      from wip_parameters
     where organization_id = p_orgID;


    x_compLots.reset;
    x_returnStatus := fnd_api.g_ret_sts_success; --assume we will be able to derive everything
    loop
      if(x_compLots.getCurrentItem(l_curItem)) then
        if(l_curItem.wip_supply_type not in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)) then
          goto END_OF_LOOP;
        end if;

        if(l_treeID is not null
           and l_prevItem <> l_curItem.inventory_item_id) then
          --if destroy trees is true, free the tree. otherwise, we just
          --need to reset the l_treeID variable
          if(fnd_api.to_boolean(p_destroyTrees)) then
            inv_quantity_tree_pvt.free_tree(p_api_version_number => 1.0,
                                            p_init_msg_lst       => fnd_api.g_false,
                                            p_tree_id            => l_treeID,
                                            x_return_status      => l_returnStatus,
                                            x_msg_count          => l_msgCount,
                                            x_msg_data           => l_msgData);
          end if;
          l_treeID := null; --reset in out parameter
        end if;

        deriveSingleItem(p_orgID        => p_orgID,
                         p_wipEntityID  => p_wipEntityID,
                         p_entryType    => l_entryType,
                         p_treeMode     => p_treeMode,
                         p_treeSrcName  => p_treeSrcName,
                         x_treeID       => l_treeID,
                         x_compLots     => x_compLots,
                         x_returnStatus => l_returnStatus);
        if(l_returnStatus = fnd_api.g_ret_sts_unexp_error) then
          l_errMsg := 'deriveSingleItem failed';
          raise fnd_api.g_exc_unexpected_error;
        elsif(l_returnStatus = fnd_api.g_ret_sts_error) then
          x_returnStatus := fnd_api.g_ret_sts_error;
        end if;

        --set up data for the next iteration of the loop
        l_prevItem := l_curItem.inventory_item_id;
      end if;
      <<END_OF_LOOP>>
      exit when not x_compLots.setNextItem;
    end loop;

    --destroy the last tree if the user has not requested it persist
    if(l_treeID is not null and
       fnd_api.to_boolean(p_destroyTrees)) then
      inv_quantity_tree_pvt.free_tree(p_api_version_number => 1.0,
                                      p_init_msg_lst       => fnd_api.g_false,
                                      p_tree_id            => l_treeID,
                                      x_return_status      => l_returnStatus,
                                      x_msg_count          => l_msgCount,
                                      x_msg_data           => l_msgData);
      l_treeID := null;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLots',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanup(x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error:' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveLots',
                              p_error_text => SQLERRM);
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
  end deriveLots;
/*
  procedure deriveLotsFromMMTT(p_orgID        IN NUMBER,
                               p_wipEntityID  IN NUMBER,
                               p_txnHdrID     IN NUMBER,
                               p_cplTxnID     IN NUMBER,
                               p_movTxnID     IN NUMBER,
                               p_initMsgList  IN VARCHAR2,
                               p_endDebug     IN VARCHAR2,
                               x_returnStatus OUT NOCOPY VARCHAR2) is
    l_itemRec itemInfo_rec_t;
    l_index NUMBER := 1;
    l_compObj system.wip_lot_serial_obj_t;
    l_item system.wip_component_obj_t;
    l_lot system.wip_txn_lot_obj_t;
    l_lotReturnStatus VARCHAR2(1);
    l_serialReturnStatus VARCHAR2(1);
    l_tempReturnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(80);
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    cursor c_cplItems return itemInfo_rec_t is
      select mmtt.transaction_temp_id,
             mmtt.operation_seq_num,
             mmtt.inventory_item_id,
             msi.concatenated_segments,
             mmtt.primary_quantity * -1,
             sum(mtlt.primary_quantity),
             mmtt.transaction_quantity * -1,
             msi.primary_uom_code,
             mmtt.subinventory_code,
             mmtt.locator_id,
             mmtt.wip_supply_type,
             mmtt.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mmtt.revision
        from mtl_material_transactions_temp mmtt,
             mtl_system_items_kfv msi,
             mtl_transaction_lots_temp mtlt
       where mmtt.completion_transaction_id = p_cplTxnID
         and mmtt.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mmtt.inventory_item_id = msi.inventory_item_id
         and mmtt.organization_id = msi.organization_id
         and mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
       group by mmtt.transaction_temp_id,
             mmtt.operation_seq_num,
             mmtt.inventory_item_id,
             msi.concatenated_segments,
             mmtt.primary_quantity * -1,
             mmtt.transaction_quantity * -1,
             msi.primary_uom_code,
             mmtt.subinventory_code,
             mmtt.locator_id,
             mmtt.wip_supply_type,
             mmtt.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mmtt.revision
       order by mmtt.inventory_item_id, mmtt.transaction_temp_id;

    cursor c_movItems return itemInfo_rec_t is
      select mmtt.transaction_temp_id,
             mmtt.operation_seq_num,
             mmtt.inventory_item_id,
             msi.concatenated_segments,
             mmtt.primary_quantity * -1,
             sum(mtlt.primary_quantity),
             mmtt.transaction_quantity * -1,
             msi.primary_uom_code,
             mmtt.subinventory_code,
             mmtt.locator_id,
             mmtt.wip_supply_type,
             mmtt.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mmtt.revision
        from mtl_material_transactions_temp mmtt,
             mtl_system_items_kfv msi,
             mtl_transaction_lots_temp mtlt
       where mmtt.move_transaction_id = p_movTxnID
         and mmtt.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mmtt.inventory_item_id = msi.inventory_item_id
         and mmtt.organization_id = msi.organization_id
         and mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
       group by mmtt.transaction_temp_id,
             mmtt.operation_seq_num,
             mmtt.inventory_item_id,
             msi.concatenated_segments,
             mmtt.primary_quantity * -1,
             mmtt.transaction_quantity * -1,
             msi.primary_uom_code,
             mmtt.subinventory_code,
             mmtt.locator_id,
             mmtt.wip_supply_type,
             mmtt.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mmtt.revision
       order by mmtt.inventory_item_id, mmtt.transaction_temp_id;
  begin
    savepoint wiplotpb_10;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_cplTxnID';
      l_params(1).paramValue := p_cplTxnID;
      l_params(2).paramName := 'p_movTxnID';
      l_params(2).paramValue := p_movTxnID;
      l_params(3).paramName := 'p_orgID';
      l_params(3).paramValue := p_orgID;
      l_params(4).paramName := 'p_wipEntityID';
      l_params(4).paramValue := p_wipEntityID;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMMTT',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    if(p_cplTxnID is not null) then
      open c_cplItems;
    else
      open c_movItems;
    end if;
    l_compObj := system.wip_lot_serial_obj_t(null,null,null,null,null,null);
    l_compObj.initialize;
    loop
      if(p_cplTxnID is not null) then
        fetch c_cplItems into l_itemRec;
        if(c_cplItems%NOTFOUND) then
          close c_cplItems;
          exit;
        end if;
      else
        fetch c_movItems into l_itemRec;
        if(c_movItems%NOTFOUND) then
          close c_movItems;
          exit;
        end if;
      end if;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('priQty:' || l_itemRec.priQty || '; lot quantity:' ||  l_itemRec.lotPriQty, l_returnStatus);
      end if;
      if(abs(l_itemRec.priQty) > nvl(l_itemRec.lotPriQty, 0)) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('at item ' || l_itemRec.itemName,l_returnStatus);
        end if;
        if(l_itemRec.lotControlCode = wip_constants.lot) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('adding item ' || l_itemRec.itemName || ';' || l_itemRec.itemID, l_returnStatus);
          end if;
          l_compObj.addItem(p_opSeqNum => l_itemRec.opSeqNum,
                            p_itemID => l_itemRec.itemID,
                            p_itemName => l_itemRec.itemName,
                            p_priQty => l_itemRec.priQty - sign(l_itemRec.priQty) * nvl(l_itemRec.lotPriQty, 0),
                            p_priUomCode => l_itemRec.priUomCode,
                            p_supplySubinv => l_itemRec.supplySubinv,
                            p_supplyLocID => l_itemRec.supplyLocID,
                            p_wipSupplyType => l_itemRec.wipSupplyType,
                            p_mtlTxnsEnabledFlag => l_itemRec.txnsEnabledFlag,
                            p_revision => l_itemRec.revision,
                            p_txnActionID => l_itemRec.txnActionID,
                            p_lotControlCode => l_itemRec.lotControlCode,
                            p_serialControlCode => l_itemRec.serialControlCode,
                            p_genericID => l_itemRec.txnID);
        elsif(l_itemRec.serialControlCode in (wip_constants.full_sn, wip_constants.dyn_rcv_sn)) then
          --see if we've derived the entire serial quantity
          checkSerial(p_txnTmpID => l_itemRec.txnID,
                      p_txnIntID => null, --since using temp table
                      p_qty => abs(l_itemRec.priQty),
                      p_itemID => l_itemRec.itemID,
                      p_itemName => l_itemRec.itemName,
                      p_orgID => p_orgID,
                      p_revision => l_itemRec.revision,
                      p_subinv => l_itemRec.supplySubinv,
                      p_locID => l_itemRec.supplyLocID,
                      p_txnActionID => l_itemRec.txnActionID,
                      p_serControlCode => l_itemRec.serialControlCode,
                      x_serialReturnStatus => l_tempReturnStatus,
                      x_returnStatus => x_returnStatus);
          if(x_returnStatus <> fnd_api.g_ret_sts_success) then
            l_errMsg := 'check serial failed';
            raise fnd_api.g_exc_unexpected_error;
          end if;
          l_serialReturnStatus := worstReturnStatus(l_serialReturnStatus, l_tempReturnStatus);
        end if;
      end if;

    end loop;
    deriveLots(x_compLots => l_compObj,
               p_orgID => p_orgID,
               p_wipEntityID => p_wipEntityID,
               p_initMsgList => fnd_api.g_false,
               p_endDebug => fnd_api.g_false,
               p_destroyTrees => fnd_api.g_true,
               p_treeMode => inv_quantity_tree_pvt.g_reservation_mode,
               p_treeSrcName => null,
               x_returnStatus => l_lotReturnStatus);

    x_returnStatus := worstReturnStatus(l_serialReturnStatus, l_lotReturnStatus);
    if(x_returnStatus = fnd_api.g_ret_sts_unexp_error) then
      l_errMsg := 'derive lots failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;
    --otherwise we at least derived some lot info
    if(p_cplTxnID is not null) then
      open c_cplItems;
    else
      open c_movItems;
    end if;

    l_compObj.reset;
    --2nd pass: update all the mmtt rows with lot info
    loop
      <<START_OF_OUTER_LOOP>>
      if(p_cplTxnID is not null) then
        fetch c_cplItems into l_itemRec;
        if(c_cplItems%NOTFOUND) then
          close c_cplItems;
          exit;
        end if;
      else
        fetch c_movItems into l_itemRec;
        if(c_movItems%NOTFOUND) then
          close c_movItems;
          exit;
        end if;
      end if;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('start outer loop for item' || l_itemRec.itemID, l_returnStatus);
      end if;

      if(l_itemRec.lotControlCode <> wip_constants.lot) then
        goto START_OF_OUTER_LOOP; --skip this item if it's not lot controlled
      end if;

      loop
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('start inner loop1',l_returnStatus);
        end if;
        if(l_compObj.setNextItem) then
          if(not l_compObj.getCurrentItem(l_item)) then
            l_errMsg := 'object error';
            raise fnd_api.g_exc_unexpected_error;
          end if;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('found item: ' || l_item.inventory_item_id, l_returnStatus);
          end if;

          if(l_item.inventory_item_id = l_itemRec.itemID and
             l_item.supply_subinventory = l_itemRec.supplySubinv and
             nvl(l_item.supply_locator_id, -1) = nvl(l_itemRec.supplyLocID, -1) and
             l_item.operation_seq_num = l_itemRec.opSeqNum and
             l_item.primary_quantity = l_itemRec.priQty) then
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('item: ' || l_item.inventory_item_id || ' matches cursor item', l_returnStatus);
            end if;
            exit; --found an item to match the cursor
          end if;
        else
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('ran out of items', l_returnStatus);
          end if;
          goto END_OF_OUTER_LOOP; --must exit inner and outer loop!
        end if;
      end loop;


      while(l_compObj.getNextLot(l_lot)) loop
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('start inner loop2', l_returnStatus);
        end if;
        insert into mtl_transaction_lots_temp
         (transaction_temp_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          transaction_quantity,
          primary_quantity,
          lot_number)
        values
         (l_itemRec.txnID,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          fnd_global.conc_request_id,
          fnd_global.prog_appl_id,
          fnd_global.conc_program_id,
          sysdate,
          abs(round(l_lot.primary_quantity * (l_itemRec.txnQty/
            l_itemRec.priQty), wip_constants.inv_max_precision)),
          abs(round(l_lot.primary_quantity, wip_constants.inv_max_precision)),
          l_lot.lot_number);
      end loop;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('end outer loop', l_returnStatus);
      end if;
    end loop;
    <<END_OF_OUTER_LOOP>>
    if(c_cplItems%ISOPEN) then
      close c_cplItems;
    elsif(c_movItems%ISOPEN) then
      close c_movItems;
    end if;

    --return status has already been set at this point
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMMTT',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanup(x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      rollback to wiplotpb_10;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMMTT',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      rollback to wiplotpb_10;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveLotsFromMMTT',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMMTT',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error:' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
  end deriveLotsFromMMTT;
*/

  procedure deriveLotsFromMTI(p_orgID         IN NUMBER,
                              p_wipEntityID   IN NUMBER, --populate for returns
                              p_txnHdrID      IN NUMBER,
                              p_cplTxnID      IN NUMBER := null,
                              p_movTxnID      IN NUMBER := null,
                              p_childMovTxnID IN NUMBER := null,
                              p_initMsgList   IN VARCHAR2,
                              p_endDebug      IN VARCHAR2,
                              x_returnStatus OUT NOCOPY VARCHAR2) is
    l_itemRec itemInfo_rec_t;
    l_index NUMBER := 1;
    l_compObj system.wip_lot_serial_obj_t;
    l_item system.wip_component_obj_t;
    l_lot system.wip_txn_lot_obj_t;
    l_lotReturnStatus VARCHAR2(1);
    l_serialReturnStatus VARCHAR2(1);
    l_tempReturnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(80);
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_itemRecTbl itemInfo_recTbl_t;
    l_supType NUMBER;

    cursor c_allItems is
      select mti.transaction_interface_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             sum(mtli.primary_quantity),
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
--             null,--mti.wip_supply_type,
             mti.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision,
             mti.move_transaction_id,
             mti.completion_transaction_id
        from mtl_transactions_interface mti,
             mtl_system_items_kfv msi,
             mtl_transaction_lots_interface mtli
       where mti.transaction_header_id = p_txnHdrID
         and mti.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mti.inventory_item_id = msi.inventory_item_id
         and mti.organization_id = msi.organization_id
         and mti.transaction_interface_id = mtli.transaction_interface_id (+)
       group by mti.transaction_interface_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
--             null,--mti.wip_supply_type,
             mti.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision,
             mti.move_transaction_id,
             mti.completion_transaction_id
       order by mti.inventory_item_id, mti.transaction_interface_id;

    --backflush items
    cursor c_bflItems is
      select mti.transaction_interface_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             sum(mtli.primary_quantity),
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
--             null,--mti.wip_supply_type,
             mti.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision,
             mti.move_transaction_id,
             mti.completion_transaction_id
        from mtl_transactions_interface mti,
             mtl_system_items_kfv msi,
             mtl_transaction_lots_interface mtli
       where mti.transaction_header_id = p_txnHdrID
         and (   mti.completion_transaction_id = p_cplTxnID
              or mti.move_transaction_id in (p_movTxnID, p_childMovTxnID))
         and mti.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mti.inventory_item_id = msi.inventory_item_id
         and mti.organization_id = msi.organization_id
         and mti.transaction_interface_id = mtli.transaction_interface_id (+)
       group by mti.transaction_interface_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
--             null,--mti.wip_supply_type,
             mti.transaction_action_id,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision,
             mti.move_transaction_id,
             mti.completion_transaction_id
       order by mti.inventory_item_id, mti.transaction_interface_id;

/* no move transaction id in MTI so don''t support for now
     cursor c_movItems return itemInfo_rec_t is
      select mti.transaction_temp_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             sum(mtli.primary_quantity),
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
             mti.wip_supply_type,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision
        from mtl_material_transactions_temp mti,
             mtl_system_items_kfv msi,
             mtl_transaction_lots_temp mtlt
       where mti.move_transaction_id = p_movTxnID
         and mti.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mti.inventory_item_id = msi.inventory_item_id
         and mti.organization_id = msi.organization_id
         and mti.transaction_interface_id = mtlt.transaction_interface_id (+)
       group by mti.transaction_temp_id,
             mti.operation_seq_num,
             mti.inventory_item_id,
             msi.concatenated_segments,
             mti.primary_quantity * -1,
             mti.transaction_quantity * -1,
             msi.primary_uom_code,
             mti.subinventory_code,
             mti.locator_id,
             mti.wip_supply_type,
             msi.mtl_transactions_enabled_flag,
             msi.serial_number_control_code,
             msi.lot_control_code,
             mti.revision
       order by mti.inventory_item_id, mti.transaction_temp_id;
*/
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    savepoint wiplotpb_10;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      l_params(2).paramName := 'p_cplTxnID';
      l_params(2).paramValue := p_cplTxnID;
      l_params(3).paramName := 'p_movTxnID';
      l_params(3).paramValue := p_movTxnID;
      l_params(4).paramName := 'p_orgID';
      l_params(4).paramValue := p_orgID;
      l_params(5).paramName := 'p_wipEntityID';
      l_params(5).paramValue := p_wipEntityID;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMTI',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    l_compObj := system.wip_lot_serial_obj_t(null,null,null,null,null,null);
    l_compObj.initialize;

    if(p_cplTxnID is null and p_movTxnID is null) then
      open c_allItems;
      fetch c_allItems
        bulk collect into l_itemRecTbl.txnID,
                          l_itemRecTbl.opSeqNum,
                          l_itemRecTbl.itemID,
                          l_itemRecTbl.itemName,
                          l_itemRecTbl.priQty,
                          l_itemRecTbl.lotPriQty,
                          l_itemRecTbl.txnQty,
                          l_itemRecTbl.priUomCode,
                          l_itemRecTbl.supplySubinv,
                          l_itemRecTbl.supplyLocID,
--                          l_itemRecTbl.wipSupplyType,
                          l_itemRecTbl.txnActionID,
                          l_itemRecTbl.txnsEnabledFlag,
                          l_itemRecTbl.serialControlCode,
                          l_itemRecTbl.lotControlCode,
                          l_itemRecTbl.revision,
                          l_itemRecTbl.movTxnID,
                          l_itemRecTbl.cplTxnID;

      close c_allItems;
    else
      open c_bflItems;
      fetch c_bflItems
        bulk collect into l_itemRecTbl.txnID,
                          l_itemRecTbl.opSeqNum,
                          l_itemRecTbl.itemID,
                          l_itemRecTbl.itemName,
                          l_itemRecTbl.priQty,
                          l_itemRecTbl.lotPriQty,
                          l_itemRecTbl.txnQty,
                          l_itemRecTbl.priUomCode,
                          l_itemRecTbl.supplySubinv,
                          l_itemRecTbl.supplyLocID,
--                              l_itemRecTbl.wipSupplyType,
                          l_itemRecTbl.txnActionID,
                          l_itemRecTbl.txnsEnabledFlag,
                          l_itemRecTbl.serialControlCode,
                          l_itemRecTbl.lotControlCode,
                          l_itemRecTbl.revision,
                          l_itemRecTbl.movTxnID,
                          l_itemRecTbl.cplTxnID;

      close c_bflItems;
    end if;

    for i in 1..l_itemRecTbl.itemID.count loop
      <<START_OF_OUTER_LOOP>>
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('priQty:' || l_itemRecTbl.priQty(i) || '; lot quantity:' ||  l_itemRecTbl.lotPriQty(i), l_returnStatus);
      end if;

      if(abs(l_itemRecTbl.priQty(i)) > abs(nvl(l_itemRecTbl.lotPriQty(i), 0))) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('adding item ' || l_itemRecTbl.itemName(i) || ';' || l_itemRecTbl.itemID(i), l_returnStatus);
        end if;

        if(l_itemRecTbl.lotControlCode(i) = wip_constants.lot) then
          if(l_itemRecTbl.movTxnID(i) is not null) then
            l_supType := wip_constants.op_pull;
          elsif(l_itemRecTbl.cplTxnID(i) is not null) then
            l_supType := wip_constants.assy_pull;
          else
            l_supType := wip_constants.push;
          end if;

          l_compObj.addItem(p_opSeqNum => l_itemRecTbl.opSeqNum(i),
                            p_itemID => l_itemRecTbl.itemID(i),
                            p_itemName => l_itemRecTbl.itemName(i),
                            p_priQty => l_itemRecTbl.priQty(i) - sign(l_itemRecTbl.priQty(i)) * nvl(l_itemRecTbl.lotPriQty(i), 0),
                            p_priUomCode => l_itemRecTbl.priUomCode(i),
                            p_supplySubinv => l_itemRecTbl.supplySubinv(i),
                            p_supplyLocID => l_itemRecTbl.supplyLocID(i),
                            p_wipSupplyType => l_supType,
                            p_txnActionID => l_itemRecTbl.txnActionID(i),
                            p_mtlTxnsEnabledFlag => l_itemRecTbl.txnsEnabledFlag(i),
                            p_revision => l_itemRecTbl.revision(i),
                            p_lotControlCode => l_itemRecTbl.lotControlCode(i),
                            p_serialControlCode => l_itemRecTbl.serialControlCode(i),
                            p_genericID => l_itemRecTbl.txnID(i));
        elsif(l_itemRecTbl.serialControlCode(i) in (wip_constants.full_sn, wip_constants.dyn_rcv_sn)) then
          --see if we've derived the entire serial quantity
          checkSerial(p_txnTmpID => null, --since using interface table
                      p_txnIntID => l_itemRecTbl.txnID(i),
                      p_qty => abs(l_itemRecTbl.priQty(i)),
                      p_itemID => l_itemRecTbl.itemID(i),
                      p_itemName => l_itemRecTbl.itemName(i),
                      p_orgID => p_orgID,
                      p_revision => l_itemRecTbl.revision(i),
                      p_subinv => l_itemRecTbl.supplySubinv(i),
                      p_locID => l_itemRecTbl.supplyLocID(i),
                      p_txnActionID => l_itemRecTbl.txnActionID(i),
                      p_serControlCode => l_itemRecTbl.serialControlCode(i),
                      x_serialReturnStatus => l_tempReturnStatus,
                      x_returnStatus => x_returnStatus);
          if(x_returnStatus <> fnd_api.g_ret_sts_success) then
            l_errMsg := 'check serial failed';
            raise fnd_api.g_exc_unexpected_error;
          end if;
          l_serialReturnStatus := worstReturnStatus(l_serialReturnStatus, l_tempReturnStatus);
        end if;
      end if;
    end loop;

    deriveLots(x_compLots => l_compObj,
               p_orgID => p_orgID,
               p_wipEntityID => p_wipEntityID,
               p_initMsgList => fnd_api.g_false,
               p_endDebug => fnd_api.g_false,
               p_destroyTrees => fnd_api.g_true,
               p_treeMode => inv_quantity_tree_pvt.g_reservation_mode,
               p_treeSrcName => null,
               x_returnStatus => l_lotReturnStatus);

    x_returnStatus := worstReturnStatus(l_serialReturnStatus, l_lotReturnStatus);
    if(x_returnStatus = fnd_api.g_ret_sts_unexp_error) then
      l_errMsg := 'derive lots failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --otherwise we at least derived some lot info
    l_compObj.reset;
    --2nd pass: update all the mti rows with lot info
    for i in 1..l_itemRecTbl.txnID.count loop
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('start outer loop for item' || l_itemRecTbl.itemID(i), l_returnStatus);
      end if;

      if(l_itemRecTbl.lotControlCode(i) <> wip_constants.lot) then
        goto END_OF_OUTER_LOOP;
      end if;

      loop
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('start inner loop1', l_returnStatus);
        end if;
        if(l_compObj.setNextItem) then
          if(not l_compObj.getCurrentItem(l_item)) then
            l_errMsg := 'object error';
            raise fnd_api.g_exc_unexpected_error;
          end if;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('found item: ' || l_item.inventory_item_id, l_returnStatus);
          end if;

          if(l_item.inventory_item_id = l_itemRecTbl.itemID(i) and
             l_item.supply_subinventory = l_itemRecTbl.supplySubinv(i) and
             nvl(l_item.supply_locator_id, -1) = nvl(l_itemRecTbl.supplyLocID(i), -1) and
             l_item.operation_seq_num = l_itemRecTbl.opSeqNum(i) and
             l_item.primary_quantity = l_itemRecTbl.priQty(i)) then
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('item: ' || l_item.inventory_item_id || ' matches cursor item', l_returnStatus);
            end if;
            exit; --found an item to match the cursor
          end if;
        else
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('ran out of items', l_returnStatus);
          end if;
          goto END_OF_OUTER_LOOP; --must exit inner and outer loop!
        end if;
      end loop;


      while(l_compObj.getNextLot(l_lot)) loop
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('start inner loop2', l_returnStatus);
        end if;
        insert into mtl_transaction_lots_interface
          (transaction_interface_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           transaction_quantity,
           primary_quantity,
           lot_number)
        values
          (l_itemRecTbl.txnID(i),
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
           abs(round(l_lot.primary_quantity * (l_itemRecTbl.txnQty(i)/
             l_itemRecTbl.priQty(i)), wip_constants.inv_max_precision)),
           abs(round(l_lot.primary_quantity, wip_constants.inv_max_precision)),
           l_lot.lot_number);
      end loop;
      <<END_OF_OUTER_LOOP>>
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('end outer loop', l_returnStatus);
      end if;
    end loop;

    --return status has already been set at this point
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMTI',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanup(x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      rollback to wiplotpb_10;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMTI',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      rollback to wiplotpb_10;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveLotsFromMTI',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveLotsFromMTI',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error:' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanup(x_returnStatus => l_returnStatus);
      end if;
  end deriveLotsFromMTI;


  --derive lots procedure for return txns
  procedure deriveTxnLots(p_orgID        IN NUMBER,
                          p_wipEntityID  IN NUMBER, --only needed for returns and neg returns
                          p_txnActionID    IN NUMBER,
                          p_entryType    IN NUMBER,
                          x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
                          x_returnStatus OUT NOCOPY VARCHAR2) is

    cursor c_retTxnBasedLots(v_itemID NUMBER) is
            select tln.lot_number,
                   max(mln.expiration_date),
                   abs(round(sum(tln.primary_quantity), wip_constants.max_displayed_precision))
            from mtl_transaction_lot_numbers tln,
                 mtl_material_transactions mmt,
                 mtl_lot_numbers mln
            where tln.organization_id = p_orgID
              and tln.transaction_source_id = p_wipEntityID
              and tln.transaction_source_type_id = 5
              and tln.inventory_item_id = v_itemID
              and tln.organization_id = mln.organization_id
              and tln.inventory_item_id = mln.inventory_item_id
              and tln.lot_number = mln.lot_number
              and nvl(mln.expiration_date, sysdate + 1) > sysdate
              and mmt.transaction_id = tln.transaction_id
              and mmt.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action)
            group by tln.lot_number
           having sign(round(sum(tln.primary_quantity), wip_constants.max_displayed_precision)) < 0 --more issued quantity than returned
             order by max(sign(round(tln.primary_quantity, wip_constants.max_displayed_precision))),  --give priority to lots that have ret txns
                      max(tln.transaction_date) desc, --then sort by most recent txn date
                      tln.lot_number desc; --finally sort by lot number, descending b/c issues are ascending

    cursor c_negRetTxnBasedLots(v_itemID NUMBER) is
            select tln.lot_number,
                   max(mln.expiration_date),
                   abs(round(sum(tln.primary_quantity), wip_constants.max_displayed_precision))
            from mtl_transaction_lot_numbers tln,
                 mtl_material_transactions mmt,
                 mtl_lot_numbers mln
            where tln.organization_id = p_orgID
              and tln.transaction_source_id = p_wipEntityID
              and tln.transaction_source_type_id = 5
              and tln.inventory_item_id = v_itemID
              and tln.organization_id = mln.organization_id
              and tln.inventory_item_id = mln.inventory_item_id
              and tln.lot_number = mln.lot_number
              and nvl(mln.expiration_date, sysdate + 1) > sysdate
              and mmt.transaction_id = tln.transaction_id
              and mmt.transaction_action_id in (wip_constants.issnegc_action, wip_constants.retnegc_action)
            group by tln.lot_number
           having sign(round(sum(tln.primary_quantity), wip_constants.max_displayed_precision)) > 0 --more neg issues than neg returns
            order by max(sign(round(tln.primary_quantity, wip_constants.max_displayed_precision))),  --give priority to lots that have ret txns
                     max(tln.transaction_date) desc, --then sort by most recent txn date
                     tln.lot_number desc; --finally sort by lot number, descending b/c issues are ascending

    l_item system.wip_component_obj_t;
    l_rmnQty NUMBER;
    /* ER 4378835: Increased length of l_lotNumber from 30 to 80 to support OPM Lot-model changes */
    l_lotNumber VARCHAR2(80);
    l_expDate DATE;
    l_lotQty NUMBER;
    l_cond boolean;
    l_params wip_logger.param_tbl_t;
    l_errMsg VARCHAR2(80);
    l_returnStatus VARCHAR2(1);
    l_enabled VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_cond := x_compLots.getCurrentItem(l_item);

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_txnActionID';
      l_params(3).paramValue := p_txnActionID;
      if(l_cond) then
        l_params(4).paramName := 'x_compLot(cur_item).inventory_item_id';
        l_params(4).paramValue := l_item.inventory_item_id;
        l_params(5).paramName := 'x_compLot(cur_item).supply_subinventory';
        l_params(5).paramValue := l_item.supply_subinventory;
        l_params(6).paramName := 'x_compLot(cur_item).supply_locator_id';
        l_params(6).paramValue := l_item.supply_locator_id;
        l_params(7).paramName := 'x_compLot(cur_item).revision';
        l_params(7).paramValue := l_item.revision;
        l_params(8).paramName := 'x_compLot(cur_item).primary_quantity';
        l_params(8).paramValue := l_item.primary_quantity;
      end if;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveTxnLots',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if (not l_cond) then
      l_errMsg := 'current item not set';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    l_rmnQty := abs(l_item.primary_quantity);

    if(p_txnActionID = wip_constants.retcomp_action) then
      open c_retTxnBasedLots(v_itemID => l_item.inventory_item_id);
    else
      open c_negRetTxnBasedLots(v_itemID => l_item.inventory_item_id);
    end if;

    loop
      if(p_txnActionID = wip_constants.retcomp_action) then
        fetch c_retTxnBasedLots into l_lotNumber, l_expDate, l_lotQty;
        exit when c_retTxnBasedLots%NOTFOUND;
      else
        fetch c_negRetTxnBasedLots into l_lotNumber, l_expDate, l_lotQty;
        exit when c_negRetTxnBasedLots%NOTFOUND;
      end if;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('lot: ' || l_lotNumber || '; qty: ' || l_lotQty, l_returnStatus);
      end if;
      l_enabled := wip_utilities.is_status_applicable(p_trx_type_id => getTxnType(l_item.transaction_action_id),
                                                      p_organization_id => p_orgID,
                                                      p_inventory_item_id => l_item.inventory_item_id,
                                                      p_sub_code => l_item.supply_subinventory,
                                                      p_locator_id => l_item.supply_locator_id,
                                                      p_lot_number => l_lotNumber,
                                                      p_object_type => 'O');
      if(l_enabled <> 'Y') then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('lot is not enabled', l_returnStatus);
        end if;
        goto END_OF_LOOP;
      end if;
      --processing here is slightly different than deriveIssueLots b/c sign of quantities could be either + or -
      if(l_lotQty >= l_rmnQty) then --lot has more than we need. only fill in the remaining qty
        x_compLots.addLot(p_lotNumber => l_lotNumber,
                          p_priQty => l_rmnQty,
                          p_attributes => null);
        l_rmnQty := 0;
        exit;
      else --exhaust all remaining qty in the lot
        x_compLots.addLot(p_lotNumber => l_lotNumber,
                          p_priQty => l_lotQty,
                          p_attributes => null);
        l_rmnQty := l_rmnQty - l_lotQty;
      end if;
      <<END_OF_LOOP>>
      null;
    end loop;

    if(c_retTxnBasedLots%ISOPEN) then
      close c_retTxnBasedLots;
    elsif(c_retTxnBasedLots%ISOPEN) then
      close c_negRetTxnBasedLots;
    end if;

    if(l_rmnQty <> 0) then
      l_errMsg := 'could not derive all qty. ' || l_rmnQty || ' remaining.';
      raise fnd_api.g_exc_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveTxnLots',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_error then
      x_returnStatus:= fnd_api.g_ret_sts_error; --let caller know item was not fully derived
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveTxnLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveTxnLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error: ' || l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(c_retTxnBasedLots%ISOPEN) then
        close c_retTxnBasedLots;
      elsif(c_retTxnBasedLots%ISOPEN) then
        close c_negRetTxnBasedLots;
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveTxnLots',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveTxnLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end deriveTxnLots;

  --derive lots procedure for issue txns
  procedure deriveIssueLots(p_orgID        IN NUMBER,
                            p_wipentityID  IN NUMBER,
                            p_entryType    IN NUMBER,
                            p_treeMode      IN NUMBER,
                            p_treeSrcName   IN VARCHAR2,
                            x_treeID       IN OUT NOCOPY NUMBER,
                            x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
                            x_returnStatus OUT NOCOPY VARCHAR2) is
    l_rmnQty NUMBER;
    l_item system.wip_component_obj_t;
    l_treeID NUMBER;
    /* ER 4378835: Increased length of l_lotNumber from 30 to 80 to support OPM Lot-model changes */
    l_lotNumber VARCHAR2(80);
    l_returnStatus VARCHAR2(1);
    l_msgData VARCHAR2(240);
    l_errMsg VARCHAR2(240);
    l_expDate DATE;
    l_msgCount NUMBER;
    l_qtyOnHand NUMBER;
    l_rsvableQtyOnHand NUMBER;
    l_qtyRsved NUMBER;
    l_qtySuggested NUMBER;
    l_qtyAvailToRsv NUMBER;
    l_qtyAvailToTxt NUMBER;
    l_qtyOnHand2 NUMBER;
    l_rsvableQtyOnHand2 NUMBER;
    l_qtyRsved2 NUMBER;
    l_qtySuggested2 NUMBER;
    l_qtyAvailToRsv2 NUMBER;
    l_qtyAvailToTxt2 NUMBER;
    l_params wip_logger.param_tbl_t;
    l_cond boolean;
    l_enabled VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
/* Added for Wilson Greatbatch Enhancement */
    l_alt_lot_selection_method NUMBER ;
    l_flag NUMBER ;
    l_lot_qty_selected NUMBER ; /* Fix for Bug#4956543 */

    cursor c_receiptOrderedLots(v_itemID NUMBER,
                                v_supplySubinv VARCHAR2,
                                v_supplyLocID NUMBER,
                                v_revision VARCHAR2) is
      select  moq.lot_number,
              min(mln.expiration_date)
        from mtl_lot_numbers mln,
             mtl_onhand_quantities_detail moq
       where moq.inventory_item_id = v_itemID
         and moq.organization_id = p_orgID
         and moq.subinventory_code = v_supplySubinv
         and nvl(moq.locator_id, -1) = nvl(v_supplyLocID, -1)
         and nvl(moq.revision, 'NONE') = nvl(v_revision, 'NONE')
         and mln.lot_number = moq.lot_number
         and mln.inventory_item_id = moq.inventory_item_id
         and mln.organization_id = moq.organization_id
         and nvl(mln.expiration_date, sysdate + 1) > sysdate
         group by moq.lot_number
         order by min(moq.date_received), moq.lot_number;

    cursor c_expDateOrderedLots(v_itemID NUMBER,
                                v_supplySubinv VARCHAR2,
                                v_supplyLocID NUMBER,
                                v_revision VARCHAR2) is
      select moq.lot_number,
             min(mln.expiration_date)
        from mtl_lot_numbers mln,
             mtl_onhand_quantities_detail moq
       where moq.inventory_item_id = v_itemID
         and moq.organization_id = p_orgID
         and moq.subinventory_code = v_supplySubinv
         and nvl(moq.locator_id, -1) = nvl(v_supplyLocID, -1)
         and nvl(moq.revision, 'NONE') = nvl(v_revision, 'NONE')
         and mln.lot_number = moq.lot_number
         and mln.inventory_item_id = moq.inventory_item_id
         and mln.organization_id = moq.organization_id
         and nvl(mln.expiration_date, sysdate + 1) > sysdate
       group by moq.lot_number
       order by min(mln.expiration_date),
                min(moq.date_received),
                moq.lot_number;

/* Added for Wilson Greatbatch Enhancement */

    cursor c_TxnHistoryOrderedLots(v_itemID NUMBER,
                                v_supplySubinv VARCHAR2,
                                v_supplyLocID NUMBER,
                                v_revision VARCHAR2) is
        select tln.lot_number
          from mtl_transaction_lot_numbers tln ,
               mtl_lot_numbers mln ,
               mtl_onhand_quantities_detail moq
         where tln.transaction_date =
               ( select max(transaction_date)
                   from mtl_material_transactions
                  where organization_id = p_OrgID
                    and transaction_source_id =p_wipEntityID
                    and transaction_source_type_id = 5
                    and inventory_item_id = v_ItemId
                    and  ( MOVE_TRANSACTION_ID IS NOT NULL or
                           COMPLETION_TRANSACTION_ID IS NOT NULL )
               )
           and tln.organization_id = moq.organization_id
           and tln.inventory_item_id = moq.inventory_item_id
           and tln.lot_number = moq.lot_number
           and tln.lot_number = mln.lot_number
           and moq.subinventory_code = v_supplySubinv
           and nvl(moq.locator_id, -1) = nvl(v_supplyLocID, -1)
           and nvl(moq.revision, 'NONE') = nvl(v_revision, 'NONE')
           and nvl(mln.expiration_date, sysdate + 1) > sysdate
         group by tln.lot_number
         order by tln.lot_number ;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_cond := x_compLots.getCurrentItem(l_item);

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_treeMode';
      l_params(2).paramValue := p_treeMode;
      l_params(3).paramName := 'p_treeSrcName';
      l_params(3).paramValue := p_treeSrcName;
      l_params(4).paramName := 'x_treeID';
      l_params(5).paramValue := x_treeID;
      if(l_cond) then

        l_params(4).paramName := 'x_compLot(cur_item).inventory_item_id';
        l_params(4).paramValue := l_item.inventory_item_id;
        l_params(5).paramName := 'x_compLot(cur_item).supply_subinventory';
        l_params(5).paramValue := l_item.supply_subinventory;
        l_params(6).paramName := 'x_compLot(cur_item).supply_locator_id';
        l_params(6).paramValue := l_item.supply_locator_id;
        l_params(7).paramName := 'x_compLot(cur_item).revision';
        l_params(7).paramValue := l_item.revision;
        l_params(8).paramName := 'x_compLot(cur_item).primary_quantity';
        l_params(8).paramValue := l_item.primary_quantity;
      end if;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveIssueLots',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if(l_cond) then
      l_rmnQty := l_item.primary_quantity;
    else
      l_rmnQty := 0;
    end if;

    if(x_treeID is null) then
      inv_quantity_tree_pvt.create_tree(p_api_version_number => 1.0,
                                        p_init_msg_lst => fnd_api.g_false,
                                        p_organization_id => p_orgID,
                                        p_inventory_item_id => l_item.inventory_item_id,
                                        p_tree_mode => p_treeMode,
                                        p_is_revision_control => (l_item.revision is not null),
                                        p_is_lot_control => true,
                                        p_is_serial_control => false,
                                        p_asset_sub_only    => false,
                                        p_include_suggestion => false,
                                        p_demand_source_type_id => 5, --wip...set to match INVTTMTX form's trees
                                        p_demand_source_header_id => 0, --set to match INVTTMTX form's trees Change value from -1 to 0 for fix a bug 7561942
                                        p_demand_source_line_id => null, --set to match INVTTMTX form's trees
                                        p_demand_source_name => p_treeSrcName,
                                        p_demand_source_delivery => null,
                                        p_lot_expiration_date => null,
                                        x_return_status => x_returnStatus,
                                        x_msg_count => l_msgCount,
                                        x_msg_data => l_msgData,
                                        x_tree_id => x_treeID);
    end if;

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      l_errMsg := 'tree creation failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(p_entryType in (wip_constants.recdate_full, wip_constants.recdate_exc)) then
      open c_receiptOrderedLots(v_itemID => l_item.inventory_item_id,
                                v_supplySubinv => l_item.supply_subinventory,
                                v_supplyLociD => l_item.supply_locator_id,
                                v_revision => l_item.revision);
    elsif(p_entryType in (wip_constants.expdate_full, wip_constants.expdate_exc)) then
      open c_expDateOrderedLots(v_itemID => l_item.inventory_item_id,
                                v_supplySubinv => l_item.supply_subinventory,
                                v_supplyLociD => l_item.supply_locator_id,
                                v_revision => l_item.revision);
/* Added for Wilson Greatbatch Enhancement */
    elsif(p_entryType in (wip_constants.txnHistory_full, wip_constants.txnHistory_exc)) then
      open c_TxnHistoryOrderedLots(v_itemID => l_item.inventory_item_id,
                                v_supplySubinv => l_item.supply_subinventory,
                                v_supplyLociD => l_item.supply_locator_id,
                                v_revision => l_item.revision);
            select alternate_lot_selection_method
              into l_alt_lot_selection_method
              from wip_parameters
             where organization_id = p_orgID ;
             l_flag := 0 ;
        if (l_alt_lot_selection_method in (wip_constants.recdate_full,wip_constants.recdate_exc)) then
          open c_receiptOrderedLots(v_itemID => l_item.inventory_item_id,
                                v_supplySubinv => l_item.supply_subinventory,
                                v_supplyLociD => l_item.supply_locator_id,
                                v_revision => l_item.revision);
        elsif (l_alt_lot_selection_method in (wip_constants.expdate_full,wip_constants.expdate_exc)) then
          open c_expDateOrderedLots(v_itemID => l_item.inventory_item_id,
                                v_supplySubinv => l_item.supply_subinventory,
                                v_supplyLociD => l_item.supply_locator_id,
                                v_revision => l_item.revision);
        end if ;
/* End of addition for Wilson Greatbatch Enhancement */
    else
      l_errMsg := 'manual entry';
      raise fnd_api.g_exc_error; --manual selection.
    end if;

    loop
      if(p_entryType in (wip_constants.recdate_full, wip_constants.recdate_exc)) then
        fetch c_receiptOrderedLots into l_lotNumber, l_expDate;
        exit when c_receiptOrderedLots%NOTFOUND;
      elsif(p_entryType in (wip_constants.expdate_full, wip_constants.expdate_exc)) then
        fetch c_expDateOrderedLots into l_lotNumber, l_expDate;
        exit when c_expDateOrderedLots%NOTFOUND;
/* Added for Wilson Greatbatch Enhancement */
      elsif(p_entryType in (wip_constants.txnHistory_full, wip_constants.txnHistory_exc)) then
        if ( l_flag = 0 ) then
          fetch c_txnHistoryOrderedLots into l_lotNumber;
        end if ;
          if ( (c_txnHistoryOrderedLots%ROWCOUNT = 0) OR ( c_txnHistoryOrderedLots%NOTFOUND AND ( l_rmnQty <> 0)) ) then
            l_flag := 1;
            if(l_alt_lot_selection_method in (wip_constants.recdate_full, wip_constants.recdate_exc)) then
               fetch c_receiptOrderedLots into l_lotNumber, l_expDate;
               exit when c_receiptOrderedLots%NOTFOUND;
            elsif(l_alt_lot_selection_method in (wip_constants.expdate_full, wip_constants.expdate_exc)) then
               fetch c_expDateOrderedLots into l_lotNumber, l_expDate;
               exit when c_expDateOrderedLots%NOTFOUND;
         /*Fix for bug 4090078 */
            else
               exit when c_txnHistoryOrderedLots%NOTFOUND;
            end if; -- end if for l_alt_lot_selection
          else  -- else condition if c_TxnHistoryordered fetches rows
            exit when c_txnHistoryOrderedLots%NOTFOUND;
          end if;    -- end if for row count
/* End of addition for Wilson Greatbatch Enhancement */
      end if; -- end if for p_entrytype

      l_enabled := wip_utilities.is_status_applicable(p_trx_type_id => getTxnType(l_item.transaction_action_id),
                                                      p_organization_id => p_orgID,
                                                      p_inventory_item_id => l_item.inventory_item_id,
                                                      p_sub_code => l_item.supply_subinventory,
                                                      p_locator_id => l_item.supply_locator_id,
                                                      p_lot_number => l_lotNumber,
                                                      p_object_type => 'O');
      --if this lot is not enabled, skip it.
      if(l_enabled <> 'Y') then
        goto END_OF_LOOP;
      end if;

      inv_quantity_tree_pvt.query_tree(p_api_version_number => 1.0,
                                       p_init_msg_lst => fnd_api.g_false,
                                       p_tree_id => x_treeID,
                                       p_revision => l_item.revision,
                                       p_lot_number => l_lotNumber,
                                       p_subinventory_code => l_item.supply_subinventory,
                                       p_locator_id => l_item.supply_locator_id,
                                       p_transfer_subinventory_code => null,
                                       p_cost_group_id => null,
                                       p_lpn_id => null,
                                       p_transfer_locator_id => null,
                                       x_return_status => x_returnStatus,
                                       x_msg_count => l_msgCount,
                                       x_msg_data => l_msgData,
                                       x_qoh => l_qtyOnHand,
                                       x_rqoh => l_rsvableQtyOnHand,
                                       x_qr => l_qtyRsved,
                                       x_qs => l_qtySuggested,
                                       x_att => l_qtyAvailToTxt,
                                       x_atr => l_qtyAvailToRsv);


      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'qty tree query failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      -- Check if Lot is already entered into MTLI and populate into l_lot_qty_selected
      -- If Lot Number is not found then l_lot_qty_selected will be populated as zero Qty.

      /* Fix for Bug#4956543 */

      lot_selected (  p_organization_id   => p_orgID,
                      p_inventory_item_id => l_item.inventory_item_id,
                      p_sub_code          => l_item.supply_subinventory,
                      p_locator_id        => l_item.supply_locator_id,
                      p_lot_number        => l_lotNumber,
                      p_lot_qty_selected  => l_lot_qty_selected,
                      x_returnStatus      => x_returnStatus ) ;

      /* Begin Bug#4956543. l_qtyAvailToTxt is updated if Lot is already selected */

      if ((l_qtyAvailToTxt > 0) and (l_qtyAvailToTxt - l_lot_qty_selected ) > 0) then
          if (l_lot_qty_selected > 0 ) then
              wip_logger.log ('Changing l_qtyAvailToTxt', l_returnStatus ) ;
              l_qtyAvailToTxt := l_qtyAvailToTxt - l_lot_qty_selected  ;
          end if ;

      /* End  Bug#4956543 */

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('adding lot ' || l_lotNumber || 'w/qty ' || least(l_rmnQty, l_qtyAvailToTxt), l_returnStatus);
          wip_logger.log('qty avail to txt:' || l_qtyAvailToTxt, l_returnStatus);
          wip_logger.log('l_rmnQty:' || l_rmnQty, l_returnStatus);
        end if;

        x_compLots.addLot(p_lotNumber => l_lotNumber,
                          p_priQty => least(l_rmnQty, l_qtyAvailToTxt),
                          p_attributes => null);


        inv_quantity_tree_pvt.update_quantities(p_api_version_number => 1.0,
                                                p_init_msg_lst => fnd_api.g_false,
                                                p_tree_id => x_treeID,
                                                p_revision => l_item.revision,
                                                p_lot_number => l_lotNumber,
                                                p_subinventory_code => l_item.supply_subinventory,
                                                p_locator_id => l_item.supply_locator_id,
                                                p_primary_quantity => -1 * least(l_rmnQty, l_qtyAvailToTxt),
                                                p_quantity_type => 1, --pending txn
                                                p_transfer_subinventory_code => null,
                                                p_cost_group_id => null,
                                                p_containerized => inv_quantity_tree_pvt.g_containerized_false,
                                                p_lpn_id => null,
                                                p_transfer_locator_id => null,
                                                x_return_status => x_returnStatus,
                                                x_msg_count => l_msgCount,
                                                x_msg_data => l_msgData,
                                                x_qoh => l_qtyOnHand2,
                                                x_rqoh => l_rsvableQtyOnHand2,
                                                x_qr => l_qtyRsved2,
                                                x_qs => l_qtySuggested2,
                                                x_att => l_qtyAvailToTxt2,
                                                x_atr => l_qtyAvailToRsv2);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          l_errMsg := 'qty tree update failed';
          raise fnd_api.g_exc_unexpected_error;
        end if;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('updating treeID' || x_treeID, l_returnStatus);
          wip_logger.log('  item=' || l_item.inventory_item_id, l_returnStatus);
          wip_logger.log('  lot=' ||  l_lotNumber, l_returnStatus);
          wip_logger.log('  qty=' || -1 * least(l_rmnQty, l_qtyAvailToTxt), l_returnStatus);
        end if;
        l_rmnQty := l_rmnQty - least(l_rmnQty, l_qtyAvailToTxt);
        if(l_rmnQty = 0) then
          exit;
        end if;
      end if;

      <<END_OF_LOOP>>
      null;
    end loop;

    if(c_receiptOrderedLots%ISOPEN) then
      close c_receiptOrderedLots;
    elsif(c_expDateOrderedLots%ISOPEN) then
      close c_expDateOrderedLots;
    end if;
/* Added for Wilson Greatbatch Enhancement */
    if(c_TxnHistoryOrderedLots%ISOPEN) then
      close c_TxnHistoryOrderedLots;
    end if;

    if(l_rmnQty > 0) then
      l_errMsg := 'could not derive all qty. ' || l_rmnQty || ' remaining.';
      raise fnd_api.g_exc_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveIssueLots',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_error then
      x_returnStatus:= fnd_api.g_ret_sts_error; --let caller know item was not fully derived
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveIssueLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(c_receiptOrderedLots%ISOPEN) then
        close c_receiptOrderedLots;
      elsif(c_expDateOrderedLots%ISOPEN) then
        close c_expDateOrderedLots;
      end if;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveIssueLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error: ' || l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(c_receiptOrderedLots%ISOPEN) then
        close c_receiptOrderedLots;
      elsif(c_expDateOrderedLots%ISOPEN) then
        close c_expDateOrderedLots;
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveIssueLots',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveIssueLots',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

  end deriveIssueLots;

  procedure deriveSingleItem(p_orgID        IN NUMBER,
                             p_wipEntityID  IN NUMBER, --only needed for returns and neg returns
                             p_entryType    IN NUMBER,
                             p_treeMode      IN NUMBER,
                             p_treeSrcName   IN VARCHAR2,
                             x_treeID       IN OUT NOCOPY NUMBER, --the qty tree id if one was built
                             x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
                             x_returnStatus OUT NOCOPY VARCHAR2) is
    l_lotControlCode NUMBER;
    l_serialControlCode NUMBER;
    l_errMsg VARCHAR2(80);
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_item system.wip_component_obj_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    begin

    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_treeMode';
      l_params(3).paramValue := p_treeMode;
      l_params(4).paramName := 'p_treeSrcName';
      l_params(4).paramValue := p_treeSrcName;
      l_params(5).paramName := 'x_treeID';
      l_params(5).paramValue := x_treeID;

      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    savepoint wipbflpb40;

    if(not x_compLots.getCurrentItem(l_item)) then
      l_errMsg := 'unable to get current item';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select lot_control_code, serial_number_control_code
      into l_lotControlCode, l_serialControlCode
      from mtl_system_items
     where inventory_item_id = l_item.inventory_item_id
       and organization_id = p_orgID;

    --if under serial control, we can not derive lots
    if(l_serialControlCode in (wip_constants.full_sn, wip_constants.dyn_rcv_sn)) then
      checkSerialQuantity(p_itemID => l_item.inventory_item_id,
                          p_itemName => l_item.item_name,
                          p_orgID => p_orgID,
                          p_qty => abs(l_item.primary_quantity),
                          p_txnActionID => l_item.transaction_action_id,
                          p_serControlCode => l_serialControlCode,
                          x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'not enough serial #s';
        raise fnd_api.g_exc_unexpected_error;
      else
        l_errMsg := 'item under serial control';
        raise fnd_api.g_exc_error;
      end if;
    end if;

    --if uncontrolled, return success (no derivation necessary)
    if(l_lotControlCode = wip_constants.no_lot) then
      x_returnStatus := fnd_api.g_ret_sts_success;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'procedure success (no derivation necessary)',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      return;
    end if;


    --else under lot control only

    --cannot derive lots for any other statuses besides these 3
    if(l_item.transaction_action_id not in (wip_constants.isscomp_action,
                                          wip_constants.retcomp_action,
                                          wip_constants.retnegc_action)) then
      l_errMsg := 'non-derivable txn action:' || l_item.transaction_action_id;
      raise fnd_api.g_exc_error;
    end if;


    --for issues, check out all the lots in the specified location
    if(l_item.transaction_action_id = wip_constants.isscomp_action) then
      deriveIssueLots(p_orgID        => p_orgID,
                      p_wipEntityID  => p_wipEntityID,
                      p_entryType    => p_entryType,
                      p_treeMode     => p_treeMode,
                      p_treeSrcName  => p_treeSrcName,
                      x_treeID       => x_treeID,
                      x_compLots     => x_compLots,
                      x_returnStatus => x_returnStatus);

    --for returns, look at the past issue transactions and try to return those lots
    else
      deriveTxnLots(p_orgID        => p_orgID,
                    p_wipEntityID  => p_wipEntityID,
                    p_txnActionID    => l_item.transaction_action_id,
                    p_entryType    => p_entryType,
                    x_compLots     => x_compLots,
                    x_returnStatus => x_returnStatus);
    end if;
    if(x_returnStatus = fnd_api.g_ret_sts_unexp_error) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_error then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error' || l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      rollback to wipbflpb40;
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexp error raised:',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      rollback to wipbflpb40;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'deriveSingleItem',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.deriveSingleItem',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexp error:' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      rollback to wipbflpb40;
  end deriveSingleItem;


  function findTxnAction(p_isForwardTxn in VARCHAR2,
                         p_qty          in NUMBER) return number is
  begin
    if(fnd_api.to_boolean(p_isForwardTxn)) then
      if(p_qty > 0) then
        return wip_constants.isscomp_action;
      else
        return wip_constants.issnegc_action;
      end if;
    else
      if(p_qty < 0) then
        return wip_constants.retcomp_action;
      else
        return wip_constants.retnegc_action;
      end if;
    end if;
  end findTxnAction;

  procedure checkSerialQuantity(p_itemID IN NUMBER,
                                p_itemName IN VARCHAR2,
                                p_orgID IN NUMBER,
                                p_qty IN NUMBER,
                                p_txnActionID IN NUMBER,
                                p_serControlCode IN NUMBER,
                                x_returnStatus OUT NOCOPY VARCHAR2) IS
    l_serCount NUMBER;
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(80);
    l_txnTypeID NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin

    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_itemID';
      l_params(1).paramValue := p_itemID;
      l_params(2).paramName := 'p_orgID';
      l_params(2).paramValue := p_orgID;
      l_params(3).paramName := 'p_qty';
      l_params(3).paramValue := p_qty;
      l_params(4).paramName := 'p_txnActionID';
      l_params(4).paramValue := p_txnActionID;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.checkSerialQuantity',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('qty:' || p_qty, l_returnStatus);
      wip_logger.log('round(qty)' || round(p_qty), l_returnStatus);
    end if;
    if(p_qty <> round(p_qty)) then --serial requirements must be whole numbers
       l_errMsg := 'serial requirement not a whole #';
       fnd_message.set_name('WIP', 'COMP_INVALID_SER_QTY');
       fnd_message.set_token('ITEM', p_itemName);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_unexpected_error;
    end if;

    l_txnTypeID := getTxnType(p_txnActionID);

    if(p_txnActionID in (wip_constants.isscomp_action, wip_constants.retnegc_action)) then
      select nvl(max(count(*)), 0)
        into l_serCount
        from mtl_serial_numbers
       where current_organization_id = p_orgID
         and inventory_item_id = p_itemID
         and current_status = 3
         and (group_mark_id = -1 OR group_mark_id is null)
         and lpn_id is null
         and (wip_utilities.is_status_applicable(/*p_trx_status_enabled    => */ null,
                                                 /*p_trx_type_id           => */ l_txnTypeID,
                                                 /*p_lot_status_enabled    => */ null,
                                                 /*p_serial_status_enabled => */ null,
                                                 /*p_organization_id       => */ current_organization_id,
                                                 /*p_inventory_item_id     => */ inventory_item_id,
                                                 /*p_sub_code              => */ current_subinventory_code,
                                                 /*p_locator_id            => */ current_locator_id,
                                                 /*p_lot_number            => */ lot_number,
                                                 /*p_serial_number         => */ serial_number,
                                                 /*p_object_type           => */ 'S') = 'Y')
      group by current_subinventory_code, current_locator_id, revision;

    elsif(p_txnActionID = wip_constants.retcomp_action) then
      select nvl(max(count(*)), 0)
        into l_serCount
        from mtl_serial_numbers
       where current_organization_id = p_orgID
         and inventory_item_id = p_itemID
         and current_status = 4
         and (group_mark_id = -1 OR group_mark_id is null)
         and (wip_utilities.is_status_applicable(/*p_trx_status_enabled    => */ null,
                                                 /*p_trx_type_id           => */ l_txnTypeID,
                                                 /*p_lot_status_enabled    => */ null,
                                                 /*p_serial_status_enabled => */ null,
                                                 /*p_organization_id       => */ current_organization_id,
                                                 /*p_inventory_item_id     => */ inventory_item_id,
                                                 /*p_sub_code              => */ current_subinventory_code,
                                                 /*p_locator_id            => */ current_locator_id,
                                                 /*p_lot_number            => */ lot_number,
                                                 /*p_serial_number         => */ serial_number,
                                                 /*p_object_type           => */ 'S') = 'Y')
       group by revision;

    elsif(p_txnActionID = wip_constants.issnegc_action) then
      if(p_serControlCode = wip_constants.dyn_rcv_sn) then
        x_returnStatus := fnd_api.g_ret_sts_success;
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerialQuantity',
                               p_procReturnStatus => x_returnStatus,
                               p_msg => 'procedure success (neg issue and serial is dyn at recpt)',
                               x_returnStatus => l_returnStatus);
        end if;
        return;
      else
        select count(*)
          into l_serCount
          from mtl_serial_numbers
         where current_organization_id = p_orgID
           and inventory_item_id = p_itemID
           and current_status in (1, 6)
           and (group_mark_id = -1 OR group_mark_id is null)
           and (wip_utilities.is_status_applicable(/*p_trx_status_enabled    => */ null,
                                                   /*p_trx_type_id           => */ l_txnTypeID,
                                                   /*p_lot_status_enabled    => */ null,
                                                   /*p_serial_status_enabled => */ null,
                                                   /*p_organization_id       => */ current_organization_id,
                                                   /*p_inventory_item_id     => */ inventory_item_id,
                                                   /*p_sub_code              => */ current_subinventory_code,
                                                   /*p_locator_id            => */ current_locator_id,
                                                   /*p_lot_number            => */ lot_number,
                                                   /*p_serial_number         => */ serial_number,
                                                   /*p_object_type           => */ 'S') = 'Y');

      end if;
    end if;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('serial count is ' || l_serCount, l_returnStatus);
    end if;
    if(l_serCount < p_qty) then
      fnd_message.set_name('WIP', 'NO_COMP_SERIAL_NUMBERS');
      fnd_message.set_token('ITEM', p_itemName);
      fnd_msg_pub.add;
      l_errMsg := 'error: not enough serials available';
      raise fnd_api.g_exc_unexpected_error;
    else
      x_returnStatus := fnd_api.g_ret_sts_success;
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerialQuantity',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerialQuantity',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus);
      end if;
    when others then
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'checkSerialQuantity',
                              p_error_text => SQLERRM);
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerialQuantity',
                             p_procReturnStatus => x_returnStatus,
                             p_msg =>  'unexp error ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      end if;
  end checkSerialQuantity;

  procedure checkSerial(p_txnTmpID IN NUMBER,
                        p_txnIntID IN NUMBER,
                        p_itemID IN NUMBER,
                        p_itemName IN VARCHAR2,
                        p_orgID IN NUMBER,
                        p_revision IN VARCHAR2,
                        p_subinv IN VARCHAR2,
                        p_locID IN NUMBER,
                        p_qty IN NUMBER,
                        p_txnActionID IN NUMBER,
                        p_serControlCode IN NUMBER,
                        x_serialReturnStatus OUT NOCOPY VARCHAR2,
                        x_returnStatus OUT NOCOPY VARCHAR2) IS
    l_serQty NUMBER;
    l_totalQty NUMBER := 0;
    /* ER 4378835: Increased length of lot variables from 30 to 80 to support OPM Lot-model changes */
    l_prefix VARCHAR2(80);
    l_fmNumber VARCHAR2(80);
    l_toNumber VARCHAR2(80);
    l_errCode NUMBER;
    l_errMsg VARCHAR2(80);
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_fmSerial VARCHAR2(30);
    l_toSerial VARCHAR2(30);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    cursor c_tmpSerials is
      select fm_serial_number fmSerial,
             to_serial_number toSerial
        from mtl_serial_numbers_temp
       where transaction_temp_id = p_txnTmpID;

    cursor c_intSerials is
      select fm_serial_number fmSerial,
             to_serial_number toSerial
        from mtl_serial_numbers_interface
       where transaction_interface_id = p_txnIntID;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTmpID';
      l_params(1).paramValue := p_txnTmpID;
      l_params(2).paramName := 'p_txnIntID';
      l_params(2).paramValue := p_txnIntID;
      l_params(3).paramName := 'p_itemID';
      l_params(3).paramValue := p_itemID;
      l_params(4).paramName := 'p_itemName';
      l_params(4).paramValue := p_itemName;
      l_params(5).paramName := 'p_orgID';
      l_params(5).paramValue := p_orgID;
      l_params(6).paramName := 'p_revision';
      l_params(6).paramValue := p_revision;
      l_params(7).paramName := 'p_subinv';
      l_params(7).paramValue := p_subinv;
      l_params(8).paramName := 'p_locID';
      l_params(8).paramValue := p_locID;
      l_params(9).paramName := 'p_qty';
      l_params(9).paramValue := p_qty;
      l_params(10).paramName := 'p_txnActionID';
      l_params(10).paramValue := p_txnActionID;
      l_params(11).paramName := 'p_serControlCode';
      l_params(11).paramValue := p_serControlCode;
      wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.checkSerial',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_txnTmpID is not null) then
      open c_tmpSerials;
    else
      open c_intSerials;
    end if;

    loop
      if(p_txnTmpID is not null) then
        fetch c_tmpSerials into l_fmSerial, l_toSerial;
        exit when c_tmpSerials%NOTFOUND;
      else
        fetch c_intSerials into l_fmSerial, l_toSerial;
        exit when c_intSerials%NOTFOUND;
      end if;
      if(MTL_Serial_Check.inv_serial_info(p_from_serial_number  =>  l_fmSerial,
                                          p_to_serial_number    =>  l_toSerial,
                                          x_prefix              =>  l_prefix,
                                          x_quantity            =>  l_serQty,
                                          x_from_number         =>  l_fmNumber,
                                          x_to_number           =>  l_toNumber,
                                          x_errorcode           =>  l_errCode)) then
        l_totalQty := l_totalQty + l_serQty;
      else
        l_errMsg := 'mtl_serial_check.inv_serial_info returned false';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end loop;

    if(c_tmpSerials%ISOPEN) then
      close c_tmpSerials;
    elsif(c_intSerials%ISOPEN) then
      close c_intSerials;
    end if;

    if(l_totalQty <> abs(p_qty)) then
      checkSerialQuantity(p_itemID => p_itemID,
                          p_itemName => p_itemName,
                          p_orgID => p_orgID,
                          p_qty => abs(p_qty),
                          p_txnActionID => p_txnActionID,
                          p_serControlCode => p_serControlCode,
                          x_returnStatus => x_serialReturnStatus);
      if(x_serialReturnStatus = fnd_api.g_ret_sts_success) then --enough serial numbers exist to complete this transaction
        raise fnd_api.g_exc_error;
      else
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerial',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_error then
      x_serialReturnStatus := fnd_api.g_ret_sts_error;
      x_returnStatus := fnd_api.g_ret_sts_success;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerial',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'insufficient serial qty. only found ' || l_totalQty,
                             x_returnStatus => l_returnStatus);
      end if;
    when fnd_api.g_exc_unexpected_error then
      x_serialReturnStatus := fnd_api.g_ret_sts_unexp_error;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(c_tmpSerials%ISOPEN) then
        close c_tmpSerials;
      elsif(c_intSerials%ISOPEN) then
        close c_intSerials;
      end if;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerial',
                             p_procReturnStatus => x_returnStatus,
                             p_msg =>  l_errMsg,
                             x_returnStatus => l_returnStatus);
      end if;
    when others then
      x_serialReturnStatus := fnd_api.g_ret_sts_unexp_error;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(c_tmpSerials%ISOPEN) then
        close c_tmpSerials;
      elsif(c_intSerials%ISOPEN) then
        close c_intSerials;
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_autoLotProc_priv',
                              p_procedure_name => 'checkSerial',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.checkSerial',
                             p_procReturnStatus => x_returnStatus,
                             p_msg =>  'unexp error ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      end if;
  end checkSerial;

  function worstReturnStatus(p_status1 VARCHAR2, p_status2 VARCHAR2) return VARCHAR2 is
  begin
    if(p_status1 = fnd_api.g_ret_sts_unexp_error or
       p_status2 = fnd_api.g_ret_sts_unexp_error) then
      return fnd_api.g_ret_sts_unexp_error;
    elsif(p_status1 = fnd_api.g_ret_sts_error or
          p_status2 = fnd_api.g_ret_sts_error) then
      return fnd_api.g_ret_sts_error;
    else
      return fnd_api.g_ret_sts_success;
    end if;
  end worstReturnStatus;

  function getTxnType(p_txnActionID IN NUMBER) return NUMBER is
  begin
    if(p_txnActionID = wip_constants.isscomp_action) then
      return wip_constants.isscomp_type;
    elsif(p_txnActionID = wip_constants.retnegc_action) then
      return wip_constants.retnegc_type;
    elsif(p_txnActionID = wip_constants.retcomp_action) then
      return wip_constants.retcomp_type;
    elsif(p_txnActionID = wip_constants.issnegc_action) then
      return wip_constants.issnegc_type;
    end if;
    return -1; --this procedure only works for component txn types
  end getTxnType;


  /* Fix for Bug#4737216 . Added following procedure */
  procedure lot_selected (
                      p_organization_id      NUMBER,
                      p_inventory_item_id    NUMBER,
                      p_sub_code             VARCHAR2,
                      p_locator_id           NUMBER,
                      p_lot_number           VARCHAR2,
                      p_lot_qty_selected     OUT NOCOPY NUMBER,
                      x_returnStatus         OUT NOCOPY VARCHAR2) is
      l_qty NUMBER ;
      l_returnStatus varchar2(1) ;
      l_params wip_logger.param_tbl_t;
      l_logLevel NUMBER := fnd_log.g_current_runtime_level;
      begin

          l_qty := 0 ;

          x_returnStatus := fnd_api.g_ret_sts_success;

          if (l_logLevel <= wip_constants.trace_logging) then
             l_params(1).paramName := 'p_organization_id';
             l_params(1).paramValue := p_organization_id;
             l_params(2).paramName := 'p_inventory_item_id';
             l_params(2).paramValue := p_inventory_item_id;
             l_params(3).paramName := 'p_sub_code';
             l_params(3).paramValue := p_sub_code;
             l_params(4).paramName := 'p_locator_id';
             l_params(4).paramValue := p_locator_id;
             l_params(5).paramName := 'p_lot_number';
             l_params(5).paramValue := p_lot_number;

              wip_logger.entryPoint(p_procName => 'wip_autoLotProc_priv.lot_selected',
                                    p_params => l_params,
                                    x_returnStatus => x_returnStatus);
          end if ;

           begin

            select sum(abs(nvl(transaction_quantity, 0)))
            into  l_qty
            from  mtl_transaction_lots_interface
            where transaction_interface_id in
                (select transaction_interface_id
                 from   mtl_transactions_interface
                 where  inventory_item_id = p_inventory_item_id
                 and    organization_id = p_organization_id
                 and    subinventory_code = p_sub_code
                 and    nvl(locator_id, -1) = nvl(p_locator_id, -1))
            and  lot_number = p_lot_number  ;

           exception
           when others then
               wip_logger.log( 'In exception Lots entered **** ' , l_returnStatus) ;
               l_qty := 0 ;
           end ;

           p_lot_qty_selected := nvl(l_qty, 0) ;

           wip_logger.log( 'Lot Qty Selected ' || p_lot_qty_selected || ' for Lot ' || p_lot_number, l_returnStatus) ;

           if (l_logLevel <= wip_constants.trace_logging) then
                 wip_logger.exitPoint(p_procName => 'wip_autoLotProc_priv.lot_selected',
                                      p_procReturnStatus => x_returnStatus,
                                      p_msg => 'procedure success',
                                      x_returnStatus => l_returnStatus); --discard logging return status
           end if;

  end lot_selected ;

  PROCEDURE deriveSingleItemFromMOG
            (p_parentObjID      IN        NUMBER,
             p_orgID            IN        NUMBER,
             p_item             IN        system.wip_component_obj_t,
             x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
             x_returnStatus    OUT NOCOPY VARCHAR2) IS

  CURSOR c_lotComp IS

    SELECT mtln.lot_number lot,
           mtln.primary_quantity * -1 lot_qty
      FROM mtl_object_genealogy mog,
           mtl_material_transactions mmt,
           mtl_transaction_lot_numbers mtln,
           mtl_lot_numbers mln
     WHERE mog.object_id = mln.gen_object_id
       AND mog.end_date_active IS NULL
       AND mog.parent_object_id = p_parentObjID
       AND mtln.inventory_item_id = p_item.inventory_item_id
       AND mtln.organization_id = p_orgID
       AND mtln.organization_id = mln.organization_id
       AND mtln.inventory_item_id = mln.inventory_item_id
       AND mtln.lot_number = mln.lot_number
       AND nvl(mln.expiration_date, sysdate + 1) > sysdate
       AND mmt.transaction_id = mog.origin_txn_id
       AND mmt.transaction_id = mtln.transaction_id
       AND mmt.transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                         WIP_CONSTANTS.RETCOMP_ACTION)
       AND mmt.operation_seq_num = p_item.operation_seq_num;

  l_derivedQty   NUMBER := 0;
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_errMsg       VARCHAR2(240);
  l_returnStatus VARCHAR2(1);
  l_lotComp      c_lotComp%ROWTYPE;
  l_params       wip_logger.param_tbl_t;

  BEGIN
    -- Don't need to check the return status because already check in
    -- deriveSerial()

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName := 'p_parentObjID';
      l_params(1).paramValue := p_parentObjID;
      l_params(2).paramName := 'p_orgID';
      l_params(2).paramValue := p_orgID;
      l_params(3).paramName := 'p_item.inventory_item_id';
      l_params(3).paramValue := p_item.inventory_item_id;
      l_params(4).paramName := 'p_item.operation_seq_num';
      l_params(4).paramValue := p_item.operation_seq_num;
      l_params(5).paramName := 'p_item.supply_subinventory';
      l_params(5).paramValue := p_item.supply_subinventory;
      l_params(6).paramName := 'p_item.supply_locator_id';
      l_params(6).paramValue := p_item.supply_locator_id;
      l_params(7).paramName := 'p_item.revision';
      l_params(7).paramValue := p_item.revision;
      l_params(8).paramName := 'p_item.primary_quantity';
      l_params(8).paramValue := p_item.primary_quantity;
      l_params(9).paramName := 'p_item.transaction_action_id';
      l_params(9).paramValue := p_item.transaction_action_id;
      wip_logger.entryPoint(
                 p_procName => 'wip_autoLotProc_priv.deriveSingleItemFromMOG',
                 p_params => l_params,
                 x_returnStatus => x_returnStatus);
    END IF;
    -- Under lot control only
    FOR l_lotComp IN c_lotComp LOOP

      x_compLots.addLot(p_lotNumber => l_lotComp.lot,
                        p_priQty    => l_lotComp.lot_qty,
                        p_attributes => null);

      l_derivedQty := l_derivedQty + l_lotComp.lot_qty;

      IF (l_logLevel <= wip_constants.full_logging) THEN
        wip_logger.log('Added Lot : ' || l_lotComp.lot, l_returnStatus);
        wip_logger.log('Added Lot Qty : '|| l_lotComp.lot_qty, l_returnStatus);
      END IF;
    END LOOP; -- l_lotComp IN c_lotComp
    -- Check whether derived quantity equal to backflush quantity or not
    -- If not, error out.
    IF(p_item.lot_control_code = WIP_CONSTANTS.LOT AND
       p_item.primary_quantity <> l_derivedQty * -1) THEN
      wip_logger.log('item : ' || p_item.item_name, l_returnStatus);
      wip_logger.log('primary_quantity : ' || p_item.primary_quantity,
                      l_returnStatus);
      wip_logger.log('derived_quantity : ' || l_derivedQty, l_returnStatus);
      l_errMsg := 'return quantity missmatch';
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
                 p_procName => 'wip_autoLotProc_priv.deriveSingleItemFromMOG',
                 p_procReturnStatus => x_returnStatus,
                 p_msg => 'procedure success',
                 x_returnStatus => l_returnStatus); --discard return status
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoLotProc_priv.deriveSingleItemFromMOG',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => l_errMsg,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;

      fnd_message.set_name('WIP', 'WIP_RET_QTY_MISSMATCH');
      fnd_message.set_token('ENTITY1', p_item.item_name);
      fnd_msg_pub.add;

    WHEN others THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoLotProc_priv.deriveSingleItemFromMOG',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexp error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
  END deriveSingleItemFromMOG;

  PROCEDURE setItemRevision
            (p_parentObjID      IN        NUMBER,
             p_orgID            IN        NUMBER,
             p_item             IN        system.wip_component_obj_t,
             x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
             x_returnStatus    OUT NOCOPY VARCHAR2) IS

  CURSOR c_revisionComp IS

    SELECT mmt.revision revision
      FROM mtl_object_genealogy mog,
           mtl_material_transactions mmt,
           mtl_transaction_lot_numbers mtln,
           mtl_lot_numbers mln
     WHERE mog.object_id = mln.gen_object_id
       AND mog.end_date_active IS NULL
       AND mog.parent_object_id = p_parentObjID
       AND mtln.inventory_item_id = p_item.inventory_item_id
       AND mtln.organization_id = p_orgID
       AND mtln.organization_id = mln.organization_id
       AND mtln.inventory_item_id = mln.inventory_item_id
       AND mtln.lot_number = mln.lot_number
       AND nvl(mln.expiration_date, sysdate + 1) > sysdate
       AND mmt.transaction_id = mog.origin_txn_id
       AND mmt.transaction_id = mtln.transaction_id
       AND mmt.transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                         WIP_CONSTANTS.RETCOMP_ACTION)
       AND mmt.operation_seq_num = p_item.operation_seq_num;

  l_errMsg       VARCHAR2(240);
  l_returnStatus VARCHAR2(1);
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_params       wip_logger.param_tbl_t;
  l_revisionComp c_revisionComp%ROWTYPE;
  BEGIN

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName := 'p_parentObjID';
      l_params(1).paramValue := p_parentObjID;
      l_params(2).paramName := 'p_orgID';
      l_params(2).paramValue := p_orgID;
      l_params(3).paramName := 'p_item.inventory_item_id';
      l_params(3).paramValue := p_item.inventory_item_id;
      l_params(4).paramName := 'p_item.operation_seq_num';
      l_params(4).paramValue := p_item.operation_seq_num;
      l_params(5).paramName := 'p_item.supply_subinventory';
      l_params(5).paramValue := p_item.supply_subinventory;
      l_params(6).paramName := 'p_item.supply_locator_id';
      l_params(6).paramValue := p_item.supply_locator_id;
      l_params(7).paramName := 'p_item.revision';
      l_params(7).paramValue := p_item.revision;
      l_params(8).paramName := 'p_item.primary_quantity';
      l_params(8).paramValue := p_item.primary_quantity;
      l_params(9).paramName := 'p_item.transaction_action_id';
      l_params(9).paramValue := p_item.transaction_action_id;
      wip_logger.entryPoint(
                 p_procName => 'wip_autoLotProc_priv.setItemRevision',
                 p_params => l_params,
                 x_returnStatus => x_returnStatus);
    END IF;

    OPEN c_revisionComp;
    -- Since revision is at the item level, we can just get the revision of
    -- the first record.
    FETCH c_revisionComp INTO l_revisionComp;

    IF(c_revisionComp%FOUND AND
       l_revisionComp.revision IS NOT NULL) THEN
      x_compLots.setRevision(p_revision => l_revisionComp.revision);
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
                 p_procName => 'wip_autoLotProc_priv.setItemRevision',
                 p_procReturnStatus => x_returnStatus,
                 p_msg => 'procedure success',
                 x_returnStatus => l_returnStatus); --discard return status
    END IF;
    CLOSE c_revisionComp;
  EXCEPTION
    WHEN others THEN
      IF(c_revisionComp%ISOPEN) THEN
        CLOSE c_revisionComp;
      END IF;

      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoLotProc_priv.setItemRevision',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexp error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
  END setItemRevision;


  PROCEDURE deriveLotsFromMOG(
              x_compLots  IN OUT NOCOPY system.wip_lot_serial_obj_t,
              p_orgID         IN        NUMBER,
              p_objectID      IN        NUMBER,
              p_initMsgList   IN        VARCHAR2,
              x_returnStatus OUT NOCOPY VARCHAR2) IS

  l_returnStatus VARCHAR2(1);
  l_errMsg VARCHAR2(80);
  l_params wip_logger.param_tbl_t;
  l_curItem system.wip_component_obj_t;
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  BEGIN
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_objectID';
      l_params(2).paramValue := p_objectID;

      wip_logger.entryPoint(
        p_procName => 'wip_autoLotProc_priv.deriveLotsFromMOG',
        p_params => l_params,
        x_returnStatus => x_returnStatus);
    END IF;

    SAVEPOINT s_deriveLotsFromMOG;

    IF(fnd_api.to_boolean(p_initMsgList)) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_compLots.reset;
    --assume we will be able to derive everything
    x_returnStatus := fnd_api.g_ret_sts_success;

    LOOP
      IF(x_compLots.getCurrentItem(l_curItem)) THEN
        IF(l_curItem.wip_supply_type NOT IN (WIP_CONSTANTS.PUSH,
                                             WIP_CONSTANTS.OP_PULL,
                                             WIP_CONSTANTS.ASSY_PULL)
           OR
           l_curItem.lot_control_code = WIP_CONSTANTS.NO_LOT
           OR
           l_curItem.serial_number_control_code IN(WIP_CONSTANTS.FULL_SN,
                                                   WIP_CONSTANTS.DYN_RCV_SN)
           OR
           l_curItem.transaction_action_id <> WIP_CONSTANTS.RETCOMP_ACTION
          ) THEN
          GOTO END_OF_LOOP;
        ELSE
          -- Instead of defaulting revision to the current revision, we should
          -- derive revision that got transacted from forward move transaction.
          setItemRevision(p_parentObjID  => p_objectID,
                          p_orgID        => p_orgID,
                          p_item         => l_curItem,
                          x_compLots     => x_compLots,
                          x_returnStatus => l_returnStatus);

          IF(l_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
            l_errMsg := 'setItemRevision failed';
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        deriveSingleItemFromMOG(p_parentObjID  => p_objectID,
                                p_orgID        => p_orgID,
                                p_item         => l_curItem,
                                x_compLots     => x_compLots,
                                x_returnStatus => l_returnStatus);

        IF(l_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
          l_errMsg := 'deriveSingleItemFromMOG failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF;

      END IF; -- x_compLots.getCurrentItem(l_curItem)
      <<END_OF_LOOP>>

      EXIT WHEN NOT x_compLots.setNextItem;
    END LOOP;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
        p_procName => 'wip_autoLotProc_priv.deriveLotsFromMOG',
        p_procReturnStatus => x_returnStatus,
        p_msg => 'procedure success',
        x_returnStatus => l_returnStatus);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoLotProc_priv.deriveLotsFromMOG',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => l_errMsg,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
      ROLLBACK TO s_deriveLotsFromMOG;

    WHEN others THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoLotProc_priv.deriveLotsFromMOG',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexpected error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
      ROLLBACK TO s_deriveLotsFromMOG;

  END deriveLotsFromMOG;

end wip_autoLotProc_priv;

/

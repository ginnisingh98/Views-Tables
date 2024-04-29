--------------------------------------------------------
--  DDL for Package Body WIP_AUTOSERIALPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_AUTOSERIALPROC_PRIV" AS
 /* $Header: wipserpb.pls 115.5 2004/03/30 00:15:16 kboonyap ship $ */

  PROCEDURE deriveSingleItem
            (p_parentObjID      IN        NUMBER,
             p_orgID            IN        NUMBER,
             x_compLots     IN OUT NOCOPY system.wip_lot_serial_obj_t,
             x_returnStatus    OUT NOCOPY VARCHAR2) IS

  CURSOR c_lotComp(p_parentObjID NUMBER,
                   p_componentID NUMBER,
                   p_orgID       NUMBER,
                   p_opSeqNum    NUMBER) IS

    SELECT msn.lot_number lot,
           count(msn.lot_number) lot_qty
      FROM mtl_object_genealogy mog,
           mtl_material_transactions mmt,
           mtl_serial_numbers msn
     WHERE mog.object_id = msn.gen_object_id
       AND msn.last_transaction_id = mmt.transaction_id
       AND mog.end_date_active IS NULL
       AND mog.parent_object_id = p_parentObjID
       AND msn.inventory_item_id = p_componentID
       AND msn.current_organization_id = p_orgID
       AND mmt.operation_seq_num = p_opSeqNum
       AND msn.lot_number IS NOT NULL
  GROUP BY msn.lot_number;

  CURSOR c_serialComp(p_parentObjID NUMBER,
                      p_componentID NUMBER,
                      p_orgID       NUMBER,
                      p_opSeqNum    NUMBER,
                      p_lotNumber   VARCHAR2) IS

    SELECT msn.parent_serial_number parent_serial,
           msn.serial_number serial
      FROM mtl_object_genealogy mog,
           mtl_material_transactions mmt,
           mtl_serial_numbers msn
     WHERE mog.object_id = msn.gen_object_id
       AND msn.last_transaction_id = mmt.transaction_id
       AND mog.end_date_active IS NULL
       AND mog.parent_object_id = p_parentObjID
       AND msn.inventory_item_id = p_componentID
       AND msn.current_organization_id = p_orgID
       AND mmt.operation_seq_num = p_opSeqNum
       AND ((p_lotNumber IS NULL AND msn.lot_number IS NULL)
            OR
            (p_lotNumber IS NOT NULL AND msn.lot_number = p_lotNumber))
  ORDER BY msn.serial_number;

  l_cond         BOOLEAN;
  l_derivedQty   NUMBER := 0;
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_curLot       VARCHAR2(30) := null;
  l_errMsg       VARCHAR2(240);
  l_returnStatus VARCHAR2(1);
  l_item         system.wip_component_obj_t;
  l_lotComp      c_lotComp%ROWTYPE;
  l_params       wip_logger.param_tbl_t;
  l_serialComp   c_serialComp%ROWTYPE;

  BEGIN
    -- Don't need to check the return status because already check in
    -- deriveSerial()
    l_cond := x_compLots.getCurrentItem(l_item);

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName := 'p_parentObjID';
      l_params(1).paramValue := p_parentObjID;
      l_params(2).paramName := 'p_orgID';
      l_params(2).paramValue := p_orgID;
      l_params(3).paramName := 'x_compLot(cur_item).inventory_item_id';
      l_params(3).paramValue := l_item.inventory_item_id;
      l_params(4).paramName := 'x_compLot(cur_item).operation_seq_num';
      l_params(4).paramValue := l_item.operation_seq_num;
      l_params(5).paramName := 'x_compLot(cur_item).supply_subinventory';
      l_params(5).paramValue := l_item.supply_subinventory;
      l_params(6).paramName := 'x_compLot(cur_item).supply_locator_id';
      l_params(6).paramValue := l_item.supply_locator_id;
      l_params(7).paramName := 'x_compLot(cur_item).revision';
      l_params(7).paramValue := l_item.revision;
      l_params(8).paramName := 'x_compLot(cur_item).primary_quantity';
      l_params(8).paramValue := l_item.primary_quantity;
      l_params(9).paramName := 'x_compLot(cur_item).transaction_action_id';
      l_params(9).paramValue := l_item.transaction_action_id;
      wip_logger.entryPoint(
                 p_procName => 'wip_autoSerialProc_priv.deriveSingleItem',
                 p_params => l_params,
                 x_returnStatus => x_returnStatus);
    END IF;

    -- Under lot and serial control
    FOR l_lotComp IN c_lotComp
                     (p_parentObjID => p_parentObjID,
                      p_componentID => l_item.inventory_item_id,
                      p_orgID       => p_orgID,
                      p_opSeqNum    => l_item.operation_seq_num) LOOP

      x_compLots.addLot(p_lotNumber => l_lotComp.lot,
                        p_priQty    => l_lotComp.lot_qty,
                        p_attributes => null);

      l_derivedQty := l_derivedQty + l_lotComp.lot_qty;

      IF (l_logLevel <= wip_constants.full_logging) THEN
        wip_logger.log('Added Lot : ' || l_lotComp.lot, l_returnStatus);
        wip_logger.log('Added Lot Qty : '|| l_lotComp.lot_qty, l_returnStatus);
      END IF;

      -- derive lot/serial genealogy
      FOR l_serialComp IN c_serialComp
                       (p_parentObjID => p_parentObjID,
                        p_componentID => l_item.inventory_item_id,
                        p_orgID       => p_orgID,
                        p_opSeqNum    => l_item.operation_seq_num,
                        p_lotNumber   => l_lotComp.lot) LOOP

        x_compLots.addLotSerial(p_fmSerial     => l_serialComp.serial,
                                p_toSerial     => l_serialComp.serial,
                                p_parentSerial => l_serialComp.parent_serial,
                                p_priQty       => 1,
                                p_attributes   => null);
        IF (l_logLevel <= wip_constants.full_logging) THEN
          wip_logger.log('Added Serial : ' || l_serialComp.serial,
                          l_returnStatus);
        END IF;
      END LOOP; -- l_serialComp IN c_serialComp
    END LOOP; -- l_lotComp IN c_lotComp

    -- Check whether derived quantity equal to backflush quantity or not
    -- If not, error out. (for lot and serial control component)
    IF(l_item.lot_control_code = WIP_CONSTANTS.LOT AND
       l_item.primary_quantity <> l_derivedQty * -1) THEN
      wip_logger.log('item : ' || l_item.item_name, l_returnStatus);
      wip_logger.log('primary_quantity : ' || l_item.primary_quantity,
                      l_returnStatus);
      wip_logger.log('derived_quantity : ' || l_derivedQty, l_returnStatus);
      l_errMsg := 'return quantity missmatch';
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    -- Serial control only
    FOR l_serialComp IN c_serialComp
                       (p_parentObjID => p_parentObjID,
                        p_componentID => l_item.inventory_item_id,
                        p_orgID       => p_orgID,
                        p_opSeqNum    => l_item.operation_seq_num,
                        p_lotNumber   => null) LOOP

      x_compLots.addSerial(p_fmSerial     => l_serialComp.serial,
                           p_toSerial     => l_serialComp.serial,
                           p_parentSerial => l_serialComp.parent_serial,
                           p_priQty       => 1,
                           p_attributes   => null);

      l_derivedQty := l_derivedQty + 1;

      IF (l_logLevel <= wip_constants.full_logging) THEN
        wip_logger.log('Added Serial : ' || l_serialComp.serial,
                        l_returnStatus);
      END IF;
    END LOOP; -- l_serialComp IN c_serialComp

    -- Check whether derived quantity equal to backflush quantity or not
    -- If not, error out. (for serial control only component)
    IF(l_item.lot_control_code = WIP_CONSTANTS.NO_LOT AND
       l_item.primary_quantity <> l_derivedQty * -1) THEN
      wip_logger.log('item : ' || l_item.item_name, l_returnStatus);
      wip_logger.log('primary_quantity : ' || l_item.primary_quantity,
                      l_returnStatus);
      wip_logger.log('derived_quantity : ' || l_derivedQty, l_returnStatus);
      l_errMsg := 'return quantity missmatch : ' || l_item.item_name;
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
                 p_procName => 'wip_autoSerialProc_priv.deriveSingleItem',
                 p_procReturnStatus => x_returnStatus,
                 p_msg => 'procedure success',
                 x_returnStatus => l_returnStatus); --discard return status
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoSerialProc_priv.deriveSingleItem',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => l_errMsg,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;

      fnd_message.set_name('WIP', 'WIP_RET_QTY_MISSMATCH');
      fnd_message.set_token('ENTITY1', l_item.item_name);
      fnd_msg_pub.add;

    WHEN others THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoSerialProc_priv.deriveSingleItem',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexp error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
  END deriveSingleItem;

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
           mtl_serial_numbers msn
     WHERE mog.object_id = msn.gen_object_id
       AND msn.last_transaction_id = mmt.transaction_id
       AND mog.end_date_active IS NULL
       AND mog.parent_object_id = p_parentObjID
       AND msn.inventory_item_id = p_item.inventory_item_id
       AND msn.current_organization_id = p_orgID
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
                 p_procName => 'wip_autoSerialProc_priv.setItemRevision',
                 p_params => l_params,
                 x_returnStatus => x_returnStatus);
    END IF;

    OPEN c_revisionComp;
    -- Since revision is at the item level, we can just get the revision of
    -- the first record.
    FETCH c_revisionComp INTO l_revisionComp;

    IF(c_revisionComp%FOUND AND
       l_revisionComp.revision IS NOT NULL) THEN
   --   x_item.revision := l_revisionComp.revision;
      x_compLots.setRevision(p_revision => l_revisionComp.revision);
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
                 p_procName => 'wip_autoSerialProc_priv.setItemRevision',
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
                   p_procName => 'wip_autoSerialProc_priv.setItemRevision',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexp error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
  END setItemRevision;

 /*****************************************************************************
  * This package will do serial derivation. It will take an object of items and
  * then derive serials for those items based on the genealogy built for
  * assembly. Serials can be derived as follows:
  *
  * Return           : A quantity tree is built to query the amount of onhand
  *                    serial quantities in the given backflush location.
  *
  * Issues           : Serial cannot be derived for this transaction type
  *                    because no genealogy have been built yet.
  *
  * Negative Return/ : Serial cannot be derived for these transaction types
  * Negative Issue     because no genealogy have been built for these txns
  *
  * parameters:
  * x_compLots        This parameter contains all the items that need to be
  *                   unbackflushed. On output, derived serial/lot are added to
  *                   the object appropriately.
  * p_objectID        Object_id of the parent serial(assembly). Used to derive
  *                   all the child serial number
  * p_orgID           Organization ID
  * p_initMsgList     Initialize the message list?
  * x_returnStatus    fnd_api.g_ret_sts_success if success without any errors.
  *                   Otherwise return fnd_api.g_ret_sts_unexp_error.
  ****************************************************************************/
  PROCEDURE deriveSerial(x_compLots  IN OUT NOCOPY system.wip_lot_serial_obj_t,
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
      l_params(1).paramName := 'p_objectID';
      l_params(1).paramValue := p_objectID;
      wip_logger.entryPoint(
        p_procName => 'wip_autoSerialProc_priv.deriveSerial',
        p_params => l_params,
        x_returnStatus => x_returnStatus);
    END IF;

    SAVEPOINT wipbflpb40;

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
           l_curItem.serial_number_control_code NOT IN(WIP_CONSTANTS.FULL_SN,
                                                      WIP_CONSTANTS.DYN_RCV_SN)
           OR
           l_curItem.transaction_action_id NOT IN(WIP_CONSTANTS.RETCOMP_ACTION)
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

        deriveSingleItem(p_parentObjID  => p_objectID,
                         p_orgID        => p_orgID,
                         x_compLots     => x_compLots,
                         x_returnStatus => l_returnStatus);

        IF(l_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
          l_errMsg := 'deriveSingleItem failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF;

      END IF; -- x_compLots.getCurrentItem(l_curItem)
      <<END_OF_LOOP>>

      EXIT WHEN NOT x_compLots.setNextItem;
    END LOOP;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(
        p_procName => 'wip_autoSerialProc_priv.deriveSerial',
        p_procReturnStatus => x_returnStatus,
        p_msg => 'procedure success',
        x_returnStatus => l_returnStatus);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoSerialProc_priv.deriveSerial',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => l_errMsg,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
      ROLLBACK TO wipbflpb40;

    WHEN others THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
                   p_procName => 'wip_autoSerialProc_priv.deriveSerial',
                   p_procReturnStatus => x_returnStatus,
                   p_msg => 'unexpected error:' || SQLERRM,
                   x_returnStatus => l_returnStatus); --discard return status
      END IF;
      ROLLBACK TO wipbflpb40;

  END deriveSerial;
END wip_autoSerialProc_priv;

/

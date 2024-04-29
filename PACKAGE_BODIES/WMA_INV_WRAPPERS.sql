--------------------------------------------------------
--  DDL for Package Body WMA_INV_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_INV_WRAPPERS" AS
/* $Header: wmainvwb.pls 115.12 2003/09/08 22:11:58 rlohani ship $ */

  type tree_tbl_t is table of NUMBER index by binary_integer;

  g_tree_tbl tree_tbl_t;
  g_lotTree_tbl tree_tbl_t;

  PROCEDURE validateLot(p_inventory_item_id IN NUMBER,
                        p_organization_id   IN NUMBER,
                        p_lot_number        IN VARCHAR2,
                        x_lot_exp           OUT NOCOPY DATE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_err_msg           OUT NOCOPY VARCHAR2) IS
  l_msg_count NUMBER;
  BEGIN
    WMS_WIP_INTEGRATION.perform_lot_validations(p_item_id =>  p_inventory_item_id,
                                                p_org_id => p_organization_id,
                                                p_lot_number => p_lot_number,
                                                x_return_status => x_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => x_err_msg);
    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;

    if(x_return_status = FND_API.G_RET_STS_SUCCESS) then --lot exists in mtl_lot_numbers
      select expiration_date
        into x_lot_exp
        from mtl_lot_numbers
       where lot_number = p_lot_number
         and inventory_item_id = p_inventory_item_id
         and organization_id = p_organization_id;
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END validateLot;

  PROCEDURE insertLot(p_header_id     IN NUMBER,
                      p_lot_number    IN VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2) IS
  l_msg_count NUMBER;
  BEGIN
    WMS_WIP_INTEGRATION.insert_lot(p_header_id     => p_header_id,
                                   p_lot_number    => p_lot_number,
                                   x_return_status => x_return_status,
                                   x_msg_count     => l_msg_count,
                                   x_msg_data      => x_err_msg);

    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  end insertLot;

  PROCEDURE createLots(p_header_id IN NUMBER,
                       x_err_msg   OUT NOCOPY VARCHAR2,
                       x_return_status   OUT NOCOPY VARCHAR2) IS
    cursor lots(v_header_id in NUMBER) IS
      select lot_number
        from wip_lpn_completions_lots
       where header_id = v_header_id;

    l_msg_count NUMBER;

    BEGIN
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      SAVEPOINT preProc;
      FOR lots_rec in lots(p_header_id) LOOP
        wms_wip_integration.insert_lot(p_header_id, lots_rec.lot_number,  x_return_status, l_msg_count, x_err_msg);
        if(x_return_status = fnd_api.g_ret_sts_unexp_error) then
          ROLLBACK TO SAVEPOINT preProc;
          exit;
        end if;
      end LOOP;
      if(l_msg_count > 1) then
        inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
      end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END createLots;

  PROCEDURE updateSerials(p_header_id IN NUMBER,
                          x_err_msg   OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2) IS
  cursor serials(v_header_id NUMBER) IS
    select fm_serial_number
      from wip_lpn_completions_serials
     where header_id = v_header_id;

  l_msg_count NUMBER;

  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    SAVEPOINT preProc;
    FOR serials_rec in serials(p_header_id) LOOP
      wms_wip_integration.update_serial(p_header_id     => p_header_id,
                                        p_serial_number => serials_rec.fm_serial_number,
                                        x_return_status => x_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => x_err_msg);
      if(x_return_status <> fnd_api.g_ret_sts_success) then
        ROLLBACK TO SAVEPOINT preProc;
        if(l_msg_count > 1) then
          inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
        end if;
        exit;
      end if;
    end loop;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END updateSerials;

  PROCEDURE updateLSAttributes(p_header_id       IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_err_msg         OUT NOCOPY VARCHAR2) IS BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    createLots(p_header_id, x_err_msg, x_return_status);
    if(x_return_status = fnd_api.G_RET_STS_SUCCESS) then
      updateSerials(p_header_id, x_err_msg, x_return_status);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  end updateLSAttributes;

  PROCEDURE backflush(p_header_id     IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2) IS
  l_msg_count NUMBER;

  BEGIN
    wms_wip_integration.backflush(p_header_id => p_header_id,
                                  x_return_status => x_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => x_err_msg);

    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END backflush;

  PROCEDURE createLpn(p_api_version     IN NUMBER,
                      p_commit          IN VARCHAR2,
                      p_lpn             IN VARCHAR2,
                      p_organization_id IN NUMBER,
                      p_source          IN NUMBER,
                      p_source_type_id  IN NUMBER,
                      x_return_status   OUT NOCOPY VARCHAR2,
                      x_err_msg         OUT NOCOPY VARCHAR2,
                      x_lpn_id          OUT NOCOPY VARCHAR2) IS

  l_msg_count NUMBER;

  BEGIN
    wms_container_pub.create_lpn (p_api_version => p_api_version,
                                  p_commit => p_commit,
                                  p_lpn => p_lpn,
                                  p_organization_id => p_organization_id,
                                  p_source => p_source,
                                  p_source_type_id => p_source_type_id,
                                  x_return_status => x_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => x_err_msg,
                                  x_lpn_id => x_lpn_id);

    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END createLpn;

  PROCEDURE packLpnContainer(p_api_version IN NUMBER,
                      p_commit             IN VARCHAR2,
                      p_lpn_id             IN NUMBER,
                      p_content_item_id    IN NUMBER,
                      p_revision           IN VARCHAR2,
                      p_lot_number         IN VARCHAR2,
                      p_from_serial_number IN VARCHAR2,
                      p_to_serial_number   IN VARCHAR2,
                      p_quantity           IN NUMBER,
                      p_organization_id    IN NUMBER,
                      p_source_type_id     IN NUMBER,
                      p_uom                IN VARCHAR2,
                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_err_msg            OUT NOCOPY VARCHAR2) IS

  l_msg_count NUMBER;

  BEGIN
    wms_container_pub.packunpack_container (p_api_version => p_api_version,
                                            p_commit => p_commit,
                                            p_lpn_id => p_lpn_id,
                                            p_content_item_id => p_content_item_id,
                                            p_revision => p_revision,
                                            p_lot_number => p_lot_number,
                                            p_from_serial_number => p_from_serial_number,
                                            p_to_serial_number => p_to_serial_number,
                                            p_quantity => p_quantity,
                                            p_organization_id => p_organization_id,
                                            p_operation => 1,
                                            p_source_type_id => p_source_type_id,
                                            p_uom => p_uom,
                                            x_return_status => x_return_status,
                                            x_msg_count => l_msg_count,
                                            x_msg_data => x_err_msg);

    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END packLpnContainer;

  PROCEDURE packSerials(p_api_version IN NUMBER,
                      p_commit             IN VARCHAR2,
                      p_lpn_id             IN NUMBER,
                      p_content_item_id    IN NUMBER,
                      p_revision           IN VARCHAR2,
                      p_lot_number         IN VARCHAR2,
                      p_from_serial_number IN VARCHAR2,
                      p_to_serial_number   IN VARCHAR2,
                      p_quantity           IN NUMBER,
                      p_organization_id    IN NUMBER,
                      p_source_type_id     IN NUMBER,
                      p_uom                IN VARCHAR2,
                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_err_msg            OUT NOCOPY VARCHAR2) IS

  l_msg_count NUMBER;

  BEGIN
    wms_container_pub.pack_prepack_container (p_api_version => p_api_version,
                        p_commit => p_commit,
                        p_lpn_id => p_lpn_id,
                        p_content_item_id => p_content_item_id,
                        p_revision => p_revision,
                        p_lot_number => p_lot_number,
                        p_from_serial_number => p_from_serial_number,
                        p_to_serial_number => p_to_serial_number,
                        p_quantity => p_quantity,
                        p_organization_id => p_organization_id,
                        p_operation => 1,
                        p_source_type_id => p_source_type_id,
                        p_uom => p_uom,
                        x_return_status => x_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => x_err_msg);

    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END packSerials;

  PROCEDURE createMO(p_organization_id            IN NUMBER,
                     p_inventory_item_id          IN NUMBER,
                     p_quantity                   IN NUMBER,
                     p_uom                        IN VARCHAR2,
                     p_lpn_id                     IN NUMBER,
                     p_reference_id               IN NUMBER,
                     p_lot_number                 IN VARCHAR2,
                     p_revision                   IN VARCHAR2,
                     p_transaction_source_id      IN NUMBER,
                     p_transaction_type_id        IN NUMBER,
                     p_transaction_source_type_id IN NUMBER,
                     p_wms_process_flag           IN NUMBER,
                     p_project_id                 IN NUMBER,
                     p_task_id                    IN NUMBER,
                     p_header_id                  IN OUT NOCOPY NUMBER,
                     x_line_id                    OUT NOCOPY NUMBER,
                     x_return_status              OUT NOCOPY VARCHAR2,
                     x_err_msg                    OUT NOCOPY VARCHAR2) IS

  l_msg_count NUMBER;

  BEGIN
   wms_task_dispatch_gen.create_mo (p_org_id => p_organization_id,
                                    p_inventory_item_id => p_inventory_item_id,
                                    p_qty => p_quantity,
                                    p_uom => p_uom,
                                    p_lpn => p_lpn_id,
                                    p_reference_id => p_reference_id,
                                    p_lot_number => p_lot_number,
                                    p_revision => p_revision,
                                    p_header_id => p_header_id,
                                    p_project_id => p_project_id,
                                    p_task_id => p_task_id,
                                    x_line_id => x_line_id,
                                    p_txn_source_id => p_transaction_source_id,
                                    p_transaction_type_id => p_transaction_type_id,
                                    p_transaction_source_type_id => p_transaction_source_type_id,
                                    p_wms_process_flag => p_wms_process_flag,
                                    x_return_status => x_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => x_err_msg);
    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END createMO;

  PROCEDURE OkMOLines(p_lpn_id        IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2) IS

  l_msg_count NUMBER;

  BEGIN
    wms_wip_integration.update_mo_line(p_lpn_id => p_lpn_id,
                                       p_wms_process_flag => 1,
                                       x_return_status => x_return_status,
                                       x_msg_count => l_msg_count,
                                       x_msg_data => x_err_msg);
    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END OkMOLines;

  PROCEDURE updateLpnContext(p_api_version   IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             p_commit        IN VARCHAR2,
                             p_lpn_id        IN NUMBER,
                             p_lpn_context   IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_err_msg       OUT NOCOPY VARCHAR2) IS
  lpnRec WMS_CONTAINER_PUB.LPN;
  l_msg_count NUMBER;

  BEGIN
    lpnRec.lpn_id := p_lpn_id;
    lpnRec.lpn_context := p_lpn_context;

    wms_container_pub.Modify_LPN(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 p_commit        => p_commit,
                                 x_return_status => x_return_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => x_err_msg,
                                 p_lpn           => lpnRec);
    if(l_msg_count > 1) then
      inv_mobile_helper_functions.get_stacked_messages(x_err_msg);
    end if;
  EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END updateLpnContext;

  PROCEDURE transferReservation(p_header_id         IN NUMBER, --the header_id to the wlc table
                                p_subinventory_code IN VARCHAR2,
                                p_locator_id        IN NUMBER,
                                p_primary_quantity  IN NUMBER,
                                p_lpn_id            IN NUMBER,
                                p_lot_number        IN VARCHAR2,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_err_msg           OUT NOCOPY VARCHAR2) IS
    l_orgID NUMBER;
    l_wipID NUMBER;
    l_itemID NUMBER;
    l_entityType NUMBER;
    l_ctoItemCount NUMBER;
    l_soExistsFlag NUMBER;
    l_dummy VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  BEGIN
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_header_id';
      l_params(1).paramValue := p_header_id;
      l_params(2).paramName := 'p_subinventory_code';
      l_params(2).paramValue := p_subinventory_code;
      l_params(3).paramName := 'p_locator_id';
      l_params(3).paramValue := p_locator_id;
      l_params(4).paramName := 'p_primary_quantity';
      l_params(4).paramValue := p_primary_quantity;
      l_params(5).paramName := 'p_lpn_id';
      l_params(5).paramValue := p_lpn_id;
      l_params(6).paramName := 'p_lot_number';
      l_params(6).paramValue := p_lot_number;

      wip_logger.entryPoint(p_procName => 'wma_inv_wrappers.transferReservation',
                            p_params => l_params,
                            x_returnStatus => l_dummy);
    end if;
    update wip_lpn_completions
       set subinventory_code = p_subinventory_code,
           locator_id        = p_locator_id
     where header_id = p_header_id
    returning wip_entity_id, organization_id, inventory_item_id, wip_entity_type
      into l_wipID, l_orgID, l_itemID, l_entityType;

    if(l_entityType = wip_constants.discrete) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('discrete', l_dummy);
      end if;
      wip_so_reservations.allocate_completion_to_so(p_organization_id => l_orgID,
                                                    p_wip_entity_id   => l_wipID,
                                                    p_inventory_item_id => l_itemID,
                                                    p_transaction_header_id => p_header_id,
                                                    p_table_type => 'WLC',
                                                    p_lpn_id => p_lpn_id,
                                                    p_primary_quantity => p_primary_quantity,
                                                    p_lot_number => p_lot_number,
                                                    x_return_status => x_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_err_msg);
    elsif(l_entityType = wip_constants.flow) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('flow', l_dummy);
      end if;
      /* commented out as Sales Order will be entered through UI
      --only transfer reservations for CTO items
      select count(*)
        into l_ctoItemCount
        from mtl_system_items
       where inventory_item_id = l_itemID
         and organization_id = l_orgID
         and build_in_wip_flag = 'Y'
         and base_item_id is not null
         and bom_item_type = wip_constants.standard_type
         and replenish_to_order_flag = 'Y';
      if(l_ctoItemCount > 0) then
      */
      select count(*)
      into l_soExistsFlag
      from wip_lpn_completions
      where header_id = p_header_id
        and demand_source_header_id is not null
        and demand_source_line is not null;
      if(l_soExistsFlag > 0) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found cto item', l_dummy);
        end if;
        wip_so_reservations.complete_flow_sched_to_so(p_header_id => p_header_id,
                                                      p_lpn_id => p_lpn_id,
                                                      p_primary_quantity => p_primary_quantity,
                                                      p_lot_number => p_lot_number,
                                                      x_return_status => x_return_status,
                                                      x_msg_count => x_msg_count,
                                                      x_msg_data => x_err_msg);
      end if;
    end if;
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_inv_wrappers.transferReservation',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'success',
                           x_returnStatus => l_dummy);
    end if;
  exception
    when others then
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_inv_wrappers.transferReservation',
                             p_procReturnStatus => x_return_status,
                             p_msg => 'error:' || x_err_msg,
                             x_returnStatus => l_dummy);
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      wip_logger.log('unhandled exception ' || SQLERRM, l_dummy);
      fnd_message.set_name('WIP', 'GENERIC_ERROR');
      fnd_message.set_token('FUNCTION', 'wmainvwb.transferReservation');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data => x_err_msg);
  end transferReservation;

  PROCEDURE clearQtyTrees(x_return_status OUT NOCOPY VARCHAR2,
                          x_err_msg OUT NOCOPY VARCHAR2) is
  begin
    x_return_status := fnd_api.g_ret_sts_success;
    inv_quantity_tree_pub.clear_quantity_cache;
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wma_inv_wrappers',
                              p_procedure_name => 'clearQtyTrees',
                              p_error_text => SQLERRM);
  end clearQtyTrees;
END wma_inv_wrappers;

/

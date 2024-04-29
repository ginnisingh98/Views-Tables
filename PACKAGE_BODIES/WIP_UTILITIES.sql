--------------------------------------------------------
--  DDL for Package Body WIP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_UTILITIES" AS
/* $Header: wiputilb.pls 120.11.12010000.2 2008/10/06 17:00:28 hliew ship $ */

  procedure do_sql(p_sql_stmt in varchar2) is
    cursor_id  integer;
    return_val integer;
    sql_stmt   varchar2(8192);
  begin
    -- set sql statement
    sql_stmt := p_sql_stmt;

    -- open a cursor
    cursor_id  := dbms_sql.open_cursor;

    -- parse sql statement
    dbms_sql.parse(cursor_id, sql_stmt, DBMS_SQL.V7);

    -- execute statement
    return_val := dbms_sql.execute(cursor_id);

    -- close cursor
    dbms_sql.close_cursor(cursor_id);
  end do_sql;

  Function is_status_applicable(p_trx_status_enabled         IN NUMBER :=NULL,
                           p_trx_type_id                IN NUMBER :=NULL,
                           p_lot_status_enabled         IN VARCHAR2 :=NULL,
                           p_serial_status_enabled      IN VARCHAR2 :=NULL,
                           p_organization_id            IN NUMBER :=NULL,
                           p_inventory_item_id          IN NUMBER :=NULL,
                           p_sub_code                   IN VARCHAR2 :=NULL,
                           p_locator_id                 IN NUMBER :=NULL,
                           p_lot_number                 IN VARCHAR2 :=NULL,
                           p_serial_number              IN VARCHAR2 :=NULL,
                           p_object_type                IN VARCHAR2 :=NULL)
  return varchar2 is
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(256);

  BEGIN
    IF not wms_install.check_install(l_return_status,
                                   l_msg_count,
                                   l_msg_data,
                                   NULL ) then
             return 'Y';
    END IF;

    return INV_MATERIAL_STATUS_GRP.is_status_applicable('TRUE', p_trx_status_enabled, p_trx_type_id,
                    p_lot_status_enabled, p_serial_status_enabled, p_organization_id, p_inventory_item_id,
                    p_sub_code, p_locator_id, p_lot_number, p_serial_number, p_object_type);

    exception
      when others then
          return 'Y';
  END is_status_applicable;

  /*******************************************************************
   * This is the wrapper to call the WMS label printing routine
   * This one should be used instead of the print_label if called from
   * java.  The p_err_msg basically is a concatenated version of all
   * the error message on the stack if an error is returned from WMS.
   ******************************************************************/
  procedure print_label_java(p_txn_id              IN NUMBER,
                             p_table_type          IN  NUMBER, -- 1 MTI, 2 MMTT
                             p_ret_status          OUT  NOCOPY VARCHAR2,
                             p_err_msg             OUT  NOCOPY VARCHAR2,
                             p_business_flow_code  IN  NUMBER) IS
    l_msg_count number;
    l_label_status varchar2(30);
    l_msg_data varchar2(240);
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    p_ret_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txn_id';
      l_params(1).paramValue := p_txn_id;
      l_params(2).paramName := 'p_table_type';
      l_params(2).paramValue := p_table_type;
      l_params(3).paramName := 'p_business_flow_code';
      l_params(3).paramValue := p_business_flow_code;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_label_java',
                            p_params => l_params,
                            x_returnStatus => p_ret_status);
      if(p_ret_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    print_label(p_txn_id => p_txn_id,
                p_table_type => p_table_type,
                p_ret_status => p_ret_status,
                p_msg_count => l_msg_count,
                p_msg_data => l_msg_data,
                p_label_status => l_label_status,
                p_business_flow_code => p_business_flow_code);

    -- if error, pack the message into p_err_msg for java
    if (p_ret_status <> 'S') then
      get_message_stack(p_msg => p_err_msg);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_label_java',
                           p_procReturnStatus => p_ret_status,
                           p_msg => p_err_msg,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end print_label_java;

  /*******************************************************************
   * This is the wrapper to call the WMS label printing routine
   ******************************************************************/
  procedure print_label(p_txn_id              IN NUMBER,
                        p_table_type          IN  NUMBER, -- 1 MTI, 2 MMTT
                        p_ret_status          OUT  NOCOPY VARCHAR2,
                        p_msg_count           OUT  NOCOPY NUMBER,
                        p_msg_data            OUT  NOCOPY VARCHAR2,
                        p_label_status        OUT  NOCOPY VARCHAR2,
                        p_business_flow_code  IN  NUMBER) IS
    -- only want to retrieve the assembly completion records
    -- no label printing for return
    cursor get_mmtt(x_txn_header_id number) is
      select transaction_temp_id, rowid
        from mtl_material_transactions_temp
       where transaction_header_id = x_txn_header_id
         and transaction_source_type_id = 5
         and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION;
    cursor get_mti(x_txn_header_id number) is
      select transaction_interface_id, rowid
        from mtl_transactions_interface
       where transaction_header_id = x_txn_header_id
         and transaction_source_type_id = 5
         and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION;
    l_temp_id number;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    p_ret_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txn_id';
      l_params(1).paramValue := p_txn_id;
      l_params(2).paramName := 'p_table_type';
      l_params(2).paramValue := p_table_type;
      l_params(3).paramName := 'p_business_flow_code';
      l_params(3).paramValue := p_business_flow_code;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_label',
                            p_params => l_params,
                            x_returnStatus => p_ret_status);
      if(p_ret_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if (p_table_type = 1) then  -- mti
      for inv_rec in get_mti(p_txn_id) loop
        if (inv_rec.transaction_interface_id is null) then
        -- transaction interface id not assigned to mti, probably no lot/serial
        -- generate one
          select mtl_material_transactions_s.nextval into l_temp_id
            from sys.dual;
          update mtl_transactions_interface
             set transaction_interface_id = l_temp_id
           where rowid = inv_rec.rowid;
        else
          l_temp_id := inv_rec.transaction_interface_id;
        end if;

         -- the p_txn_identifier is defined in INVLA10B.pls
         -- 1 is MMTT, 2 is MTI, 3 MTRL, 4 WFS
        INV_LABEL.print_label_wrap(x_return_status => p_ret_status,
                         x_msg_count => p_msg_count,
                         x_msg_data => p_msg_data,
                         x_label_status => p_label_status,
                         p_business_flow_code => p_business_flow_code,
                         p_transaction_id => l_temp_id,
                         p_transaction_identifier => 2);   -- interface
      end loop;
    elsif (p_table_type = 2) then -- mmtt
      for inv_rec in get_mmtt(p_txn_id) loop
        if (inv_rec.transaction_temp_id is null) then
          -- temp id not assigned to mmtt record (probably no lot/serial),
          -- generate one
          select mtl_material_transactions_s.nextval into l_temp_id
            from sys.dual;
          update mtl_material_transactions_temp
             set transaction_temp_id = l_temp_id
           where rowid = inv_rec.rowid;
        else
          l_temp_id := inv_rec.transaction_temp_id;
        end if;

        INV_LABEL.print_label_wrap(x_return_status => p_ret_status,
                           x_msg_count => p_msg_count,
                           x_msg_data => p_msg_data,
                           x_label_status => p_label_status,
                           p_business_flow_code => p_business_flow_code,
                           p_transaction_id => l_temp_id,
                           p_transaction_identifier => 1);   -- MMTT
      end loop;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_label',
                           p_procReturnStatus => p_ret_status,
                           p_msg => p_msg_data,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  END print_label;

procedure print_label(p_business_flow_code  IN  NUMBER := NULL,
                      p_label_type_id       IN  NUMBER := NULL,
                      p_organization_id     IN  NUMBER := NULL,
                      p_inventory_item_id   IN  NUMBER := NULL,
                      p_revision            IN  VARCHAR2 := NULL,
                      p_lot_number          IN  VARCHAR2 := NULL,
                      p_fm_serial_number    IN  VARCHAR2 := NULL,
                      p_to_serial_number    IN  VARCHAR2 := NULL,
                      p_lpn_id              IN  NUMBER := NULL,
                      p_subinventory_code   IN  VARCHAR2 := NULL,
                      p_locator_id          IN  NUMBER := NULL,
                      p_delivery_id         IN  NUMBER := NULL,
                      p_quantity            IN  NUMBER := NULL,
                      p_uom                 IN  VARCHAR2 := NULL,
                      p_no_of_copies        IN  NUMBER := NULL,
                      p_ret_status          OUT  NOCOPY VARCHAR2,
                      p_msg_count           OUT  NOCOPY NUMBER,
                      p_msg_data            OUT  NOCOPY VARCHAR2,
                      p_label_status        OUT NOCOPY VARCHAR2) is
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    p_ret_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_business_flow_code';
      l_params(1).paramValue := p_business_flow_code;
      l_params(2).paramName := 'p_label_type_id';
      l_params(2).paramValue := p_label_type_id;
      l_params(3).paramName := 'p_organization_id';
      l_params(3).paramValue := p_organization_id;
      l_params(4).paramName := 'p_inventory_item_id';
      l_params(4).paramValue := p_inventory_item_id;
      l_params(5).paramName := 'p_revision';
      l_params(5).paramValue := p_revision;
      l_params(6).paramName := 'p_lot_number';
      l_params(6).paramValue := p_lot_number;
      l_params(7).paramName := 'p_fm_serial_number';
      l_params(7).paramValue := p_fm_serial_number;
      l_params(8).paramName := 'p_to_serial_number';
      l_params(8).paramValue := p_to_serial_number;
      l_params(9).paramName := 'p_lpn_id';
      l_params(9).paramValue := p_lpn_id;
      l_params(10).paramName := 'p_subinventory_code';
      l_params(10).paramValue := p_subinventory_code;
      l_params(11).paramName := 'p_locator_id';
      l_params(11).paramValue := p_locator_id;
      l_params(12).paramName := 'p_delivery_id';
      l_params(12).paramValue := p_delivery_id;
      l_params(13).paramName := 'p_quantity';
      l_params(13).paramValue := p_quantity;
      l_params(14).paramName := 'p_uom';
      l_params(14).paramValue := p_uom;
      l_params(15).paramName := 'p_no_of_copies';
      l_params(15).paramValue := p_no_of_copies;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_label',
                            p_params => l_params,
                            x_returnStatus => p_ret_status);
      if(p_ret_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    inv_label.print_label_manual_wrap(p_business_flow_code  => p_business_flow_code,
                                      p_label_type          => p_label_type_id,
                                      p_organization_id     => p_organization_id,
                                      p_inventory_item_id   => p_inventory_item_id,
                                      p_revision            => p_revision,
                                      p_lot_number          => p_lot_number,
                                      p_fm_serial_number    => p_fm_serial_number,
                                      p_to_serial_number    => p_to_serial_number,
                                      p_lpn_id              => p_lpn_id,
                                      p_subinventory_code   => p_subinventory_code,
                                      p_locator_id          => p_locator_id,
                                      p_delivery_id         => p_delivery_id,
                                      p_quantity            => p_quantity,
                                      p_uom                 => p_uom,
                                      p_no_of_copies        => p_no_of_copies,
                                      x_return_status       => p_ret_status,
                                      x_msg_count           => p_msg_count,
                                      x_msg_data            => p_msg_data,
                                      x_label_status        => p_label_status);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_label',
                           p_procReturnStatus => p_ret_status,
                           p_msg => p_msg_data,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end print_label;

  procedure get_message_stack(p_delete_stack in varchar2 := null,
                              p_separator in varchar2 := null,
                              p_msg OUT NOCOPY VARCHAR2) is
     l_curMsg VARCHAR2(2000) := '';
     l_msgCount NUMBER;
     l_separator VARCHAR2(30) := nvl(p_separator,' ');
  begin
    fnd_msg_pub.Count_And_Get(p_encoded => fnd_api.g_false,
                              p_count => l_msgCount,
                              p_data => p_msg);

    IF(l_msgCount > 1) THEN
      FOR i IN 1..l_msgCount LOOP
        l_curMsg := fnd_msg_pub.get(p_msg_index => l_msgCount - i + 1,
                                    p_encoded   => FND_API.g_false);
        if(nvl(length(p_msg), 0) + length(l_curMsg) + length(l_separator) < 2000) then
          p_msg := p_msg || l_separator || l_curMsg;
        end if;
      END LOOP;
    END IF;

    if(fnd_api.to_boolean(nvl(p_delete_stack,fnd_api.g_true))) then
      fnd_msg_pub.delete_msg;
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_utilities',
                              p_procedure_name => 'get_message_stack',
                              p_error_text => SQLERRM);
      p_msg := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
      if(fnd_api.to_boolean(nvl(p_delete_stack,fnd_api.g_true))) then
        fnd_msg_pub.delete_msg;
      end if;
  END get_message_stack;

  /* Deletes transaction records from the mtl temp tables */
  procedure delete_temp_records(p_header_id IN NUMBER) is
  begin
     -- Delete all serial numbers tied to lots
     delete from mtl_serial_numbers_temp
     where transaction_temp_id in
           ( select msnt.transaction_temp_id
             from mtl_serial_numbers_temp msnt,
                  mtl_transaction_lots_temp mtlt,
                  mtl_material_transactions_temp mmtt
             where mmtt.transaction_header_id = p_header_id
               and mtlt.transaction_temp_id = mmtt.transaction_temp_id
               and mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
           );

     -- Delete all serial numbers (sn control only)
     delete from mtl_serial_numbers_temp
     where transaction_temp_id in
           ( select msnt.transaction_temp_id
             from mtl_serial_numbers_temp msnt,
                  mtl_material_transactions_temp mmtt
             where mmtt.transaction_header_id = p_header_id
               and mmtt.transaction_temp_id = msnt.transaction_temp_id
           );

     -- Delete all lots
     delete from mtl_transaction_lots_temp
     where transaction_temp_id in
           ( select mtlt.transaction_temp_id
             from mtl_material_transactions_temp mmtt,
                  mtl_transaction_lots_temp mtlt
             where mmtt.transaction_header_id = p_header_id
               and mtlt.transaction_temp_id = mmtt.transaction_temp_id
           );

     -- Finally, delete all records in mmtt for this transaction
     delete from mtl_material_transactions_temp
     where transaction_header_id = p_header_id;

  end delete_temp_records;

  /* Deletes transaction records from the mtl temp tables */
  procedure delete_temp_records(p_temp_id IN NUMBER) is
  begin
     -- Delete all serial numbers tied to lots
     delete from mtl_serial_numbers_temp msnt
     where transaction_temp_id in
           (select mtlt.serial_transaction_temp_id
              from mtl_transaction_lots_temp mtlt
             where mtlt.transaction_temp_id = p_temp_id
           );

     -- Delete all serial numbers (sn control only)
     delete from mtl_serial_numbers_temp
     where transaction_temp_id = p_temp_id;

     -- Delete all lots
     delete from mtl_transaction_lots_temp
     where transaction_temp_id = p_temp_id;

     -- Finally, delete all records in mmtt for this transaction
     delete from mtl_material_transactions_temp
     where transaction_header_id = p_temp_id;
  end delete_temp_records;

procedure update_serial(p_serial_number in VARCHAR2,
                        p_inventory_item_id in number,
                        p_organization_id in number,
                        p_wip_entity_id in number,
                        p_line_mark_id in number := null,
                        p_operation_seq_num in number,
                        p_intraoperation_step_type in number,
                        x_return_status OUT NOCOPY VARCHAR2) is
  l_objID NUMBER;
  l_msg_data VARCHAR2(2000);
  l_msg_count VARCHAR2(2000);
  l_current_status NUMBER;
  l_initialization_date DATE;
  l_completion_date DATE;
  l_ship_date DATE;
  l_revision VARCHAR2(3);
  /* ER 4378835: Increased length of lot_number from 30 to 80 to support OPM Lot-model changes */
  l_lot_number VARCHAR2(80);
  l_group_mark_id NUMBER;
  l_lot_line_mark_id NUMBER;
  l_current_organization_id NUMBER;
  l_current_locator_id NUMBER;
  l_current_subinventory_code VARCHAR2(30);
  l_original_wip_entity_id NUMBER;
  l_original_unit_vendor_id NUMBER;
  l_vendor_lot_number VARCHAR2(80);
  l_vendor_serial_number VARCHAR2(30);
  l_last_receipt_issue_type NUMBER;
  l_last_txn_source_id NUMBER;
  l_last_txn_source_type_id NUMBER;
  l_last_txn_source_name VARCHAR2(30);
  l_parent_item_id NUMBER;
  l_parent_serial_number VARCHAR2(30);
  l_dummy VARCHAR2(1);
  l_last_status NUMBER;
begin
  savepoint wipupdserial0;
  --check for existence of serial number while locking it
  select current_status,
         initialization_date,
         completion_date,
         ship_date,
         revision,
         lot_number,
         group_mark_id,
         lot_line_mark_id,
         current_organization_id,
         current_locator_id,--10
         current_subinventory_code,
         original_wip_entity_id,
         original_unit_vendor_id,
         vendor_lot_number,
         vendor_serial_number,
         last_receipt_issue_type,
         last_txn_source_id,
         last_txn_source_type_id,
         last_txn_source_name,
         parent_item_id,--20
         parent_serial_number
    into l_current_status,
         l_initialization_date,
         l_completion_date,
         l_ship_date,
         l_revision,
         l_lot_number,
         l_group_mark_id,
         l_lot_line_mark_id,
         l_current_organization_id,
         l_current_locator_id,--10
         l_current_subinventory_code,
         l_original_wip_entity_id,
         l_original_unit_vendor_id,
         l_vendor_lot_number,
         l_vendor_serial_number,
         l_last_receipt_issue_type,
         l_last_txn_source_id,
         l_last_txn_source_type_id,
         l_last_txn_source_name,
         l_parent_item_id,--20
         l_parent_serial_number
    from mtl_serial_numbers
   where serial_number = p_serial_number
     and inventory_item_id = p_inventory_item_id
     and current_organization_id = p_organization_id
     for update nowait;

  if(l_current_status = 6) then
    l_last_status := 1;
  else
    l_last_status := l_current_status;
  end if;

  inv_serial_number_pub.updateserial(p_api_version              => 1.0,
                                     p_inventory_item_id        => p_inventory_item_id,
                                     p_organization_id          => p_organization_id,
                                     p_serial_number            => p_serial_number,
                                     p_initialization_date      => l_initialization_date,
                                     p_completion_date          => l_completion_date,
                                     p_ship_date                => l_ship_date,
                                     p_revision                 => l_revision,
                                     p_lot_number               => l_lot_number,
                                     p_current_locator_id       => l_current_locator_id,
                                     p_subinventory_code        => l_current_subinventory_code,
                                     p_trx_src_id               => l_original_wip_entity_id,
                                     p_unit_vendor_id           => l_original_unit_vendor_id,
                                     p_vendor_lot_number        => l_vendor_lot_number,
                                     p_vendor_serial_number     => l_vendor_serial_number,
                                     p_receipt_issue_type       => l_last_receipt_issue_type,
                                     p_txn_src_id               => l_last_txn_source_id,
                                     p_txn_src_name             => l_last_txn_source_name,
                                     p_txn_src_type_id          => l_last_txn_source_type_id,
                                     p_current_status           => l_current_status,
                                     p_parent_item_id           => l_parent_item_id,
                                     p_parent_serial_number     => l_parent_serial_number,
                                     p_serial_temp_id           => null,
                                     p_last_status              => l_last_status,
                                     p_status_id                => null,
                                     x_object_id                => l_objID,
                                     x_return_status            => x_return_status,
                                     x_msg_count                => l_msg_count,
                                     x_msg_data                 => l_msg_data,
                                     p_wip_entity_id            => p_wip_entity_id,
                                     p_operation_seq_num        => p_operation_seq_num,
                                     p_intraoperation_step_type => p_intraoperation_step_type,
                                     p_line_mark_id             => p_line_mark_id);

  if(x_return_status <> fnd_api.g_ret_sts_success) then
    raise fnd_api.g_exc_unexpected_error;
  end if;
  exception
    when wip_constants.records_locked then
      rollback to wipupdserial0;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WIP', 'SERIAL_NUMBERS_LOCKED');
      fnd_msg_pub.add;
    when fnd_api.g_exc_unexpected_error then
      rollback to wipupdserial0;
      --status and message should have been set by inv api. set status
      --just in case.
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    when others then
      rollback to wipupdserial0;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_utilities',
                              p_procedure_name => 'update_serial',
                              p_error_text => SQLERRM);
end update_serial;

procedure generate_serials(p_org_id in NUMBER,
                           p_item_id in NUMBER,
                           p_qty IN NUMBER,
                           p_wip_entity_id IN NUMBER,
                           p_revision in VARCHAR2,
                           p_lot in varchar2,
                           x_start_serial IN OUT  NOCOPY VARCHAR2,
                           x_end_serial OUT  NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_err_msg OUT NOCOPY VARCHAR2) is
  l_status NUMBER;
  l_qty NUMBER := p_qty;
begin
  x_return_status := fnd_api.g_ret_sts_success;
  if(x_start_serial is null) then
    l_status := inv_serial_number_pub.generate_serials(p_org_id => p_org_id,
                                                       p_item_id => p_item_id,
                                                       p_qty => p_qty,
                                                       p_wip_id => p_wip_entity_id,
                                                       p_group_mark_id => p_wip_entity_id,
                                                       p_line_mark_id => null,
                                                       p_rev => p_revision,
                                                       p_lot => p_lot,
                                                       p_skip_serial => wip_constants.yes,
                                                       x_start_ser => x_start_serial,
                                                       x_end_ser => x_end_serial,
                                                       x_proc_msg => x_err_msg);
  else
    l_qty := p_qty;
    l_status := inv_serial_number_pub.validate_serials(p_org_id => p_org_id,
                                                       p_item_id => p_item_id,
                                                       p_qty => l_qty,
                                                       p_wip_entity_id => p_wip_entity_id,
                                                       p_group_mark_id => p_wip_entity_id,
                                                       p_line_mark_id => null,
                                                       p_rev => p_revision,
                                                       p_lot => p_lot,
                                                       p_start_ser => x_start_serial,
                                                       p_trx_src_id => null,
                                                       p_trx_action_id => null,
                                                       p_subinventory_code => null,
                                                       p_locator_id => null,
                                                       x_end_ser => x_end_serial,
                                                       x_proc_msg => x_err_msg);
    if(l_qty <> p_qty AND
       l_status = 0) then
      fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
      fnd_msg_pub.add;
      get_message_stack(p_msg => x_err_msg,
                        p_delete_stack => fnd_api.g_false,
                        p_separator => ' ');
    end if;
  end if;
  /* For Bug 5860709 : Returning 'W' for status 2-Warning*/
  if(l_status = 2 ) then
          x_return_status := WIP_CONSTANTS.WARN;
  --if(l_status <> 0) then
  elsif(l_status <> 0) then
    x_return_status := fnd_api.g_ret_sts_error;
  end if;
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_err_msg := SQLERRM;
end generate_serials;

FUNCTION require_lot_attributes(p_org_id         IN NUMBER,
                                p_item_id        IN NUMBER,
                                p_lot_number     IN VARCHAR2)
RETURN NUMBER IS

l_require_lot_attr NUMBER;
BEGIN
  SELECT inv_lot_sel_attr.is_enabled(
         'Lot Attributes',
          p_org_id,
          p_item_id)
    INTO l_require_lot_attr
    FROM dual
   WHERE NOT EXISTS -- new lot
        (SELECT 'X'
           FROM mtl_lot_numbers mln
          WHERE mln.organization_id = p_org_id
            AND mln.inventory_item_id = p_item_id
            AND mln.lot_number = p_lot_number);

  IF(l_require_lot_attr = 2) THEN
    RETURN WIP_CONSTANTS.YES;
  ELSE
    RETURN WIP_CONSTANTS.NO;
  END IF;

EXCEPTION
  WHEN others THEN -- include NO_DATA_FOUND exception too
    RETURN  WIP_CONSTANTS.NO;
END require_lot_attributes;

PROCEDURE get_locator(p_locator_id         IN NUMBER,
                      p_org_id             IN NUMBER,
                      p_locator            OUT NOCOPY VARCHAR2)
IS
BEGIN
   p_locator := inv_project.get_locator(p_locator_id, p_org_id);
END get_locator;

FUNCTION is_user_defined_lot_exp(p_org_id         IN NUMBER,
                                 p_item_id        IN NUMBER,
                                 p_lot_number     IN VARCHAR2)
RETURN NUMBER IS

l_shelf_life_code NUMBER;
BEGIN
  SELECT msi.shelf_life_code
    INTO l_shelf_life_code
    FROM mtl_system_items msi
   WHERE msi.inventory_item_id = p_item_id
     AND msi.organization_id = p_org_id
     AND NOT EXISTS -- new lot
         (SELECT 'X'
            FROM mtl_lot_numbers mln
           WHERE mln.organization_id = p_org_id
             AND mln.inventory_item_id = p_item_id
             AND mln.lot_number = p_lot_number);

  IF(l_shelf_life_code = WIP_CONSTANTS.USER_DEFINED_EXP) THEN
    RETURN WIP_CONSTANTS.YES;
  ELSE
    RETURN WIP_CONSTANTS.NO;
  END IF;

EXCEPTION
  WHEN others THEN -- include NO_DATA_FOUND exception too
    RETURN  WIP_CONSTANTS.NO;
END is_user_defined_lot_exp;

FUNCTION is_dff_required(p_application_id IN NUMBER,
                         p_dff_name       IN VARCHAR2)
RETURN VARCHAR2 IS

l_dff_required BOOLEAN;
BEGIN
  l_dff_required := fnd_flex_apis.is_descr_required(
                      x_application_id => p_application_id,
                      x_desc_flex_name => p_dff_name);

  IF(l_dff_required) THEN
    RETURN fnd_api.g_true;
  ELSE
    RETURN fnd_api.g_false;
  END IF;
END is_dff_required;

FUNCTION is_dff_setup(p_application_id IN NUMBER,
                      p_dff_name       IN VARCHAR2)
RETURN VARCHAR2 IS

l_dff_setup BOOLEAN;
BEGIN
  l_dff_setup := fnd_flex_apis.is_descr_setup(
                   x_application_id => p_application_id,
                   x_desc_flex_name => p_dff_name);

  IF(l_dff_setup) THEN
    RETURN fnd_api.g_true;
  ELSE
    RETURN fnd_api.g_false;
  END IF;
END is_dff_setup;

/*Added the following function for bug 7138983(FP 7028072)*/
 	    FUNCTION validate_scrap_account_id ( scrap_account_id     IN NUMBER,
 	                                         chart_of_accounts_id IN NUMBER )
 	    RETURN VARCHAR2 IS
 	      x_flex_result boolean;
 	    BEGIN

 	          x_flex_result := fnd_flex_keyval.validate_ccid(appl_short_name => 'SQLGL',
 	                                      key_flex_code => 'GL#',
 	                                      structure_number => chart_of_accounts_id,
 	                                      combination_id => scrap_account_id,
 	                                      security => 'ENFORCE'
 	                                      );

 	          if x_flex_result then
 	            return 'Y';
 	          else
 	            return 'N';
 	          end if;
 	    EXCEPTION
 	    WHEN OTHERS THEN
 	      RETURN 'N';
 	    END validate_scrap_account_id;






/**************************************************************************/
--VJ: Label Printing - Start

PROCEDURE print_job_labels(p_wip_entity_id      IN NUMBER,
--                           p_op_seq_num         IN NUMBER,
                           x_status             IN OUT NOCOPY VARCHAR2,
                           x_msg_count          IN OUT NOCOPY NUMBER,
                           x_msg                IN OUT NOCOPY VARCHAR2
                          )
IS
    l_org_id        NUMBER;
    l_item_id       NUMBER;
    l_label_status  VARCHAR2(30);
    l_returnStatus  VARCHAR2(1);
    l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
    l_params        wip_logger.param_tbl_t;
    l_msg_data      VARCHAR2(100);

    CURSOR job_serials (p_org_id NUMBER, p_we_id NUMBER, p_item_id NUMBER)
    IS
      SELECT serial_number
      FROM   mtl_serial_numbers
      WHERE  current_organization_id = p_org_id
      and    wip_entity_id = p_we_id
      AND    inventory_item_id = p_item_id;

BEGIN
    x_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_wip_entity_id';
      l_params(1).paramValue := p_wip_entity_id;
--      l_params(2).paramName := 'p_op_seq_num';
--      l_params(2).paramValue := p_op_seq_num;
      l_params(2).paramName := 'x_status';
      l_params(2).paramValue := x_status;
      l_params(3).paramName := 'x_msg_count';
      l_params(3).paramValue := x_msg_count;
      l_params(4).paramName := 'x_msg';
      l_params(4).paramValue := x_msg;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_job_labels',
                            p_params => l_params,
                            x_returnStatus => x_status);
      if(x_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select organization_id, primary_item_id
    into   l_org_id, l_item_id
    from   wip_discrete_jobs
    where  wip_entity_id = p_wip_entity_id;

    INV_LABEL.PRINT_LABEL_MANUAL_WRAP (
                P_BUSINESS_FLOW_CODE  => NULL,
                P_LABEL_TYPE          => 9,
                P_ORGANIZATION_ID     => l_org_id,
                P_INVENTORY_ITEM_ID   => NULL,
                P_REVISION            => NULL,
                P_LOT_NUMBER          => NULL,
                P_FM_SERIAL_NUMBER    => NULL,
                P_TO_SERIAL_NUMBER    => NULL,
                P_LPN_ID              => NULL,
                P_SUBINVENTORY_CODE   => NULL,
                P_LOCATOR_ID          => NULL,
                P_DELIVERY_ID         => NULL,
                P_QUANTITY            => NULL,
                P_UOM                 => NULL,
                P_WIP_ENTITY_ID       => p_wip_entity_id,
                P_NO_OF_COPIES        => NULL,
                X_RETURN_STATUS       => x_status,
                X_MSG_COUNT           => x_msg_count,
                X_MSG_DATA            => l_msg_data,
                X_LABEL_STATUS        => l_label_status);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log(p_msg => 'INV_LABEL.PRINT_LABEL_MANUAL_WRAP results',
                     x_returnStatus => l_returnStatus); --discard logging return status
      wip_logger.log(p_msg => x_status,
                     x_returnStatus => l_returnStatus); --discard logging return status
      wip_logger.log(p_msg => l_msg_data,
                     x_returnStatus => l_returnStatus); --discard logging return status
    end if;


    FOR serial_num in job_serials(l_org_id,p_wip_entity_id,l_item_id) LOOP

        -- Start : Changes to fix bug #6860138 --
        /***********
        INV_LABEL.PRINT_LABEL_MANUAL_WRAP (
                    P_BUSINESS_FLOW_CODE  => NULL,
                    P_LABEL_TYPE          => 2,
                    P_ORGANIZATION_ID     => l_org_id,
                    P_INVENTORY_ITEM_ID   => l_item_id,
                    P_REVISION            => NULL,
                    P_LOT_NUMBER          => NULL,
                    P_FM_SERIAL_NUMBER    => serial_num.serial_number,
                    P_TO_SERIAL_NUMBER    => serial_num.serial_number,
                    P_LPN_ID              => NULL,
                    P_SUBINVENTORY_CODE   => NULL,
                    P_LOCATOR_ID          => NULL,
                    P_DELIVERY_ID         => NULL,
                    P_QUANTITY            => NULL,
                    P_UOM                 => NULL,
                    P_WIP_ENTITY_ID       => p_wip_entity_id,
                    P_NO_OF_COPIES        => NULL,
                    X_RETURN_STATUS       => x_status,
                    X_MSG_COUNT           => x_msg_count,
                    X_MSG_DATA            => l_msg_data,
                    X_LABEL_STATUS        => l_label_status);
        ***********/

        print_serial_label(p_org_id        => l_org_id,
                           p_serial_number => serial_num.serial_number,
                           p_item_id       => l_item_id,
                           x_status        => x_status,
                           x_msg_count     => x_msg_count,
                           x_msg           => l_msg_data
                          );
        -- End : Changes to fix bug #6860138 --

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log(p_msg => 'INV_LABEL.PRINT_LABEL_MANUAL_WRAP results for serial '||serial_num.serial_number,
                         x_returnStatus => l_returnStatus); --discard logging return status
          wip_logger.log(p_msg => x_status,
                         x_returnStatus => l_returnStatus); --discard logging return status
          wip_logger.log(p_msg => l_msg_data,
                         x_returnStatus => l_returnStatus); --discard logging return status
        end if;

    END LOOP;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_job_labels',
                           p_procReturnStatus => x_status,
                           p_msg => l_msg_data,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
END print_job_labels;

/**************************************************************************/

PROCEDURE print_serial_label(p_org_id           IN NUMBER,
                             p_serial_number    IN VARCHAR2,
                             p_item_id          IN NUMBER,
                             x_status           IN OUT NOCOPY VARCHAR2,
                             x_msg_count        IN OUT NOCOPY NUMBER,
                             x_msg              IN OUT NOCOPY VARCHAR2
                            )
IS
    l_wip_entity_id NUMBER;
    l_item_id       NUMBER;
    l_label_status  VARCHAR2(30);
    l_msg_data      VARCHAR2(100);
    l_returnStatus  VARCHAR2(1);
    l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
    l_params        wip_logger.param_tbl_t;

    -- Start : Changes to fix bug #6860138 --
    l_lot_number    VARCHAR2(80);
    l_sch_st_date   DATE;
    l_item_rev      VARCHAR2(3);
    -- End : Changes to fix bug #6860138 --

BEGIN
    x_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_org_id';
      l_params(1).paramValue := p_org_id;
      l_params(2).paramName := 'p_serial_number';
      l_params(2).paramValue := p_serial_number;
      l_params(3).paramName := 'p_item_id';
      l_params(3).paramValue := p_item_id;
      l_params(4).paramName := 'x_status';
      l_params(4).paramValue := x_status;
      l_params(5).paramName := 'x_msg_count';
      l_params(5).paramValue := x_msg_count;
      l_params(6).paramName := 'x_msg';
      l_params(6).paramValue := x_msg;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_serial_label',
                            p_params => l_params,
                            x_returnStatus => x_status);
      if(x_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    l_item_id := p_item_id;

    SELECT wip_entity_id, inventory_item_id
    INTO   l_wip_entity_id, l_item_id
    FROM   mtl_serial_numbers
    WHERE  current_organization_id = p_org_id
    AND    serial_number = p_serial_number
    AND    inventory_item_id = nvl(l_item_id, inventory_item_id);

    -- For completed serial number, wip_entity_id in mtl_serial_numbers will
    -- be null. Link mtl_object_genealogy to get wip_entity_id
    if(l_wip_entity_id is null) then
      SELECT we.wip_entity_id
      INTO l_wip_entity_id
      FROM mtl_serial_numbers msn,
           wip_entities we,
           mtl_object_genealogy mog
      WHERE
	  ((mog.genealogy_origin = 1 and
		mog.parent_object_id = we.gen_object_id and
		mog.object_id = msn.gen_object_id)
		or
		(mog.genealogy_origin = 2 and
		mog.parent_object_id = msn.gen_object_id and
		mog.object_id = we.gen_object_id))
	  and mog.end_date_active is null
          and msn.serial_number = p_serial_number
          and msn.current_organization_id = p_org_id;
    end if;

    -- Start : Changes to fix bug #6860138 --
    SELECT wdj.lot_number,
           wdj.scheduled_start_date,
           DECODE(msi.revision_qty_control_code,
                  WIP_CONSTANTS.REV,
                  NVL(wdj.bom_revision,
                      BOM_revisions.GET_ITEM_REVISION_FN
                          ('EXCLUDE_OPEN_HOLD',-- eco_status
                           'ALL',              -- examine_type
                           p_org_id,           -- org_id
                           l_item_id,          -- item_id
                           l_sch_st_date)      -- rev_date
                     ),
                  NULL
                 )
    INTO   l_lot_number,
           l_sch_st_date,
           l_item_rev
    FROM   mtl_system_items msi,
           wip_discrete_jobs wdj
    WHERE  wdj.wip_entity_id = l_wip_entity_id
    AND    msi.organization_id = wdj.organization_id
    AND    msi.inventory_item_id = wdj.primary_item_id;
    -- End : Changes to fix bug #6860138 --

    INV_LABEL.PRINT_LABEL_MANUAL_WRAP (
                P_BUSINESS_FLOW_CODE  => NULL,
                P_LABEL_TYPE          => 2,
                P_ORGANIZATION_ID     => p_org_id,
                P_INVENTORY_ITEM_ID   => l_item_id,
                P_REVISION            => l_item_rev, --Fixed bug#6860138 --NULL,
                P_LOT_NUMBER          => l_lot_number, --Fixed bug#6860138 --NULL,
                P_FM_SERIAL_NUMBER    => p_serial_number,
                P_TO_SERIAL_NUMBER    => p_serial_number,
                P_LPN_ID              => NULL,
                P_SUBINVENTORY_CODE   => NULL,
                P_LOCATOR_ID          => NULL,
                P_DELIVERY_ID         => NULL,
                P_QUANTITY            => NULL,
                P_UOM                 => NULL,
                P_WIP_ENTITY_ID       => l_wip_entity_id,
                P_NO_OF_COPIES        => NULL,
                X_RETURN_STATUS       => x_status,
                X_MSG_COUNT           => x_msg_count,
                X_MSG_DATA            => l_msg_data,
                X_LABEL_STATUS        => l_label_status);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_serial_label',
                           p_procReturnStatus => x_status,
                           p_msg => l_msg_data,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
END print_serial_label;

/**************************************************************************/

PROCEDURE print_move_txn_label(p_txn_id         IN NUMBER,
                               x_status         IN OUT NOCOPY VARCHAR2,
                               x_msg_count      IN OUT NOCOPY NUMBER,
                               x_msg            IN OUT NOCOPY VARCHAR2
                              )
IS
    l_label_status VARCHAR2(30);
    l_returnStatus VARCHAR2(1);
    l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
    l_params       wip_logger.param_tbl_t;
    l_msg_data     VARCHAR2(100);

BEGIN
    x_status := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txn_id';
      l_params(1).paramValue := p_txn_id;
      l_params(2).paramName := 'x_status';
      l_params(2).paramValue := x_status;
      l_params(3).paramName := 'x_msg_count';
      l_params(3).paramValue := x_msg_count;
      l_params(4).paramName := 'x_msg';
      l_params(4).paramValue := x_msg;
      wip_logger.entryPoint(p_procName => 'wip_utils.print_move_txn_label',
                            p_params => l_params,
                            x_returnStatus => x_status);
      if(x_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    INV_LABEL.PRINT_LABEL_WRAP (
                X_RETURN_STATUS          => x_status,
                X_MSG_COUNT              => x_msg_count,
                X_MSG_DATA               => x_msg,
                X_LABEL_STATUS           => l_label_status,
                P_BUSINESS_FLOW_CODE     => 41,
                P_TRANSACTION_ID         => p_txn_id, -- from WMT
                P_TRANSACTION_IDENTIFIER => 9);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_utils.print_move_txn_label',
                           p_procReturnStatus => x_status,
                           p_msg => l_msg_data,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
END print_move_txn_label;



--VJ: Label Printing - End
/**************************************************************************/




END WIP_UTILITIES;

/

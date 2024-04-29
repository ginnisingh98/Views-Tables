--------------------------------------------------------
--  DDL for Package Body WIP_PICKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PICKING_PVT" as
 /* $Header: wippckvb.pls 120.18.12010000.8 2010/02/25 06:20:13 hliew ship $ */

  procedure explode(p_organization_id NUMBER,
                    p_bill_sequence_id NUMBER,
                    p_revision_date DATE,
                    p_primary_item_id NUMBER,
                    p_alternate_bom_designator VARCHAR2,
                    p_user_id NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_data OUT NOCOPY VARCHAR2) IS
      l_errCode NUMBER;
      l_count NUMBER;
      CURSOR c_components IS
        select row_id, component_quantity, component_item_id,
               component_code, operation_seq_num
          from wip_explosions_v
         where top_bill_sequence_id = p_bill_sequence_id
           and organization_id = p_organization_id
           and wip_supply_type = wip_constants.phantom
         order by component_code;

      CURSOR c_lock
          IS select '1'
               from bom_explosions
              where top_bill_sequence_id = p_bill_sequence_id
                and organization_id = p_organization_id
                for update nowait;
    BEGIN
      SAVEPOINT WIP_EXPLODE_START;
      --delete any previous explosions as effectivity/disable dates could be changed
      --make sure the records are not locked.
      open c_lock;

      delete bom_explosions
       where top_bill_sequence_id = p_bill_sequence_id
         and organization_id = p_organization_id;



      bom_oe_exploder_pkg.be_exploder(arg_org_id => p_organization_id,
                                      arg_starting_rev_date => p_revision_date,
                                      arg_expl_type => 'ALL',
                                      arg_item_id => p_primary_item_id,
                                      arg_alt_bom_desig => p_alternate_bom_designator,
                                      arg_error_code => l_errCode,
                                      arg_err_msg => x_msg_data);
      if(l_errCode <> 0) then
        raise fnd_api.G_EXC_UNEXPECTED_ERROR;
      else
        x_return_status := fnd_api.g_ret_sts_success;
      end if;

      FOR l_compRec IN c_components LOOP
        update bom_explosions
           set component_quantity = component_quantity * l_compRec.component_quantity,
               operation_seq_num = l_compRec.operation_seq_num
         where component_code <> l_compRec.component_code
           and component_code like l_compRec.component_code || '%'
           and top_bill_sequence_id = p_bill_sequence_id
           and organization_id = p_organization_id;
      END LOOP;

      close c_lock; -- done processing...remove the lock on the rows, however note that the delete statement
                    -- has placed a new lock on the rows.
    exception
      when RECORDS_LOCKED then
        ROLLBACK TO WIP_EXPLODE_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
      when others then
        if(c_lock%ISOPEN) then
          close c_lock;
        end if;
        ROLLBACK TO WIP_EXPLODE_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', SQLERRM);
        /*This line is added as a fix for bug#2629809*/
        x_msg_data := fnd_message.get;
  end explode;

  procedure cancel_allocations(p_wip_entity_id NUMBER,
                               p_wip_entity_type NUMBER,
                               p_repetitive_schedule_id NUMBER := NULL,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2) IS
      l_msgCount NUMBER;
      l_lineID NUMBER;
      l_wroRowID ROWID;
      l_openQty NUMBER;

      /* Bugfix 4743190 : Modified the query to avoid merge join (cartesian). Instead of joining with
         bind variables, use table joins. Also added rownum in the subquery */

      CURSOR c_repLines IS
        select line_id, (nvl(quantity_detailed,0) - nvl(quantity_delivered,0)) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where wro.wip_entity_id = p_wip_entity_id
           and wro.repetitive_schedule_id = p_repetitive_schedule_id
           and mtrl.txn_source_id = wro.wip_entity_id
           and mtrl.reference_id = wro.repetitive_schedule_id
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK
                         and rownum = 1)

        for update of wro.quantity_allocated, quantity_backordered nowait;

/* Bugfix 4211265: Cursor c_discLines is doing an FTS on mtrl. We will join with wip_entities to get the organization_id and join with mtrl thru wro so that index MTL_TXN_REQUEST_LINES_N1 can be used. */

      CURSOR c_discLines IS
        select line_id, (nvl(quantity_detailed,0) - nvl(quantity_delivered,0)) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro, wip_entities we      /* bug 4211266 */
         where we.wip_entity_id = p_wip_entity_id
           and wro.organization_id = we.organization_id
           and wro.wip_entity_id = we.wip_entity_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.txn_source_id = we.wip_entity_id
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK
                         and rownum = 1)

        for update of wro.quantity_allocated, quantity_backordered nowait;

        /* End of Bugfix 4743190 */

      CURSOR c_flowLines IS
       select line_id
            from mtl_txn_request_lines mtrl, wip_entities we
        where mtrl.TRANSACTION_TYPE_ID = INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR -- 51
          and mtrl.TRANSACTION_SOURCE_TYPE_ID = INV_Globals.G_SOURCETYPE_INVENTORY --13
          and mtrl.txn_source_id = we.wip_entity_id
          and mtrl.organization_id = we.organization_id
          and we.wip_entity_id = p_wip_entity_id
          and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK);

    BEGIN
     if(p_wip_entity_type not in (wip_constants.discrete,
                                  wip_constants.lotbased,
				  wip_constants.repetitive,
				  wip_constants.flow,
				  wip_constants.eam)) then
 	         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	         fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
 	         fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.Incorrect Entity type passed');
 	         x_msg_data := fnd_message.get;
		 return ;
      end if ;

    SAVEPOINT WIP_CANCEL_ALLOCS_START;

      x_return_status := FND_API.G_RET_STS_SUCCESS; -- in case no open lines are found
      if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
        open c_discLines;
      elsif(p_wip_entity_type = wip_constants.repetitive) then
        open c_repLines;
      elsif(p_wip_entity_type = wip_constants.flow) then
        open c_flowLines;
      end if;
      loop --need to handle failure conditions!!!
        if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
          fetch c_discLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_discLines%NOTFOUND;
        elsif(p_wip_entity_type = wip_constants.repetitive) then
          fetch c_repLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_repLines%NOTFOUND;
        elsif(p_wip_entity_type = wip_constants.flow) then
          fetch c_flowLines into l_lineID;
          exit when c_flowLines%NOTFOUND;
        end if;

            cancel_MO_line(p_lineId =>l_lineID ,
                     p_rowId => l_wroRowID,
                     p_wip_entity_type => p_wip_entity_type,
                     p_openQty => l_openQty,
                     x_return_status => x_return_status,
                     x_msg_data => x_msg_data);

           if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
              if(c_discLines%ISOPEN) then
                close c_discLines;
              elsif(c_repLines%ISOPEN) then
                close c_repLines;
              elsif(c_flowLines%ISOPEN) then
                close c_flowLines;
              end if;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
      end loop;
      if(c_discLines%ISOPEN) then
        close c_discLines;
      elsif(c_repLines%ISOPEN) then
        close c_repLines;
      elsif(c_flowLines%ISOPEN) then
        close c_flowLines;
      end if;

    --finally update all backordered quantity to 0
    if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
      update wip_requirement_operations
         set quantity_backordered = 0
       where wip_entity_id = p_wip_entity_id;
    elsif(p_wip_entity_type = wip_constants.repetitive) then
      update wip_requirement_operations
         set quantity_backordered = 0
       where wip_entity_id = p_wip_entity_id
         and repetitive_schedule_id = p_repetitive_schedule_id;
    end if;
    exception
      when fnd_api.g_exc_unexpected_error then
        ROLLBACK TO WIP_CANCEL_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      when others then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        elsif(c_flowLines%ISOPEN) then
          close c_flowLines;
        end if;
        ROLLBACK TO WIP_CANCEL_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.cancel_allocations: ' || SQLERRM);
        x_msg_data := fnd_message.get;
  end cancel_allocations;


   Procedure cancel_comp_allocations(p_wip_entity_id NUMBER,
                     p_operation_seq_num NUMBER,
                     p_inventory_item_id NUMBER,
                     p_wip_entity_type NUMBER,
                     p_repetitive_schedule_id NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2) IS
      l_msgCount NUMBER;
      l_lineID NUMBER;
      l_wroRowID ROWID;
      l_openQty NUMBER;
      l_logLevel NUMBER := fnd_log.g_current_runtime_level;
      l_dummy VARCHAR2(1);

      CURSOR c_repLines IS
        select line_id, (nvl(quantity_detailed,0) - nvl(quantity_delivered,0)) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = p_wip_entity_id
           and mtrl.reference_id = p_repetitive_schedule_id
           and wro.wip_entity_id = p_wip_entity_id
           and wro.repetitive_schedule_id = p_repetitive_schedule_id
           and wro.operation_seq_num = p_operation_seq_num
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and wro.inventory_item_id = p_inventory_item_id
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)

        for update of wro.quantity_allocated, quantity_backordered nowait;

      CURSOR c_discLines IS
        select line_id, (nvl(quantity_detailed,0) - nvl(quantity_delivered,0)) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = p_wip_entity_id
           and wro.wip_entity_id = p_wip_entity_id
           and wro.operation_seq_num = p_operation_seq_num
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and wro.inventory_item_id = p_inventory_item_id
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)

        for update of wro.quantity_allocated, quantity_backordered nowait;


    BEGIN
      SAVEPOINT WIP_CANCEL_COMP_ALLOCS_START;
      x_return_status := FND_API.G_RET_STS_SUCCESS; -- in case no open lines are found

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log('In wip_picking_pvt.cancel_comp_allocations', l_dummy);
      end if;
      if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
        open c_discLines;
      elsif(p_wip_entity_type = wip_constants.repetitive) then
        open c_repLines;
      else
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('Invalid entity type passed to wip_picking_pvt.cancel_comp_allocations:'
                              || p_wip_entity_type, l_dummy);
        end if;
      end if;

      loop
        if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
          fetch c_discLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_discLines%NOTFOUND;
        elsif(p_wip_entity_type = wip_constants.repetitive) then
          fetch c_repLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_repLines%NOTFOUND;
        end if;

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('line ID:' || l_lineID || ',Open Qty:' || l_openQty || ',WRO RowID:'
                         || l_wroRowID || ',p_wip_entity_type:' || p_wip_entity_type, l_dummy);
        end if;

        cancel_MO_line(p_lineId =>l_lineID ,
                     p_rowId => l_wroRowID,
                     p_wip_entity_type => p_wip_entity_type,
                     p_openQty => l_openQty,
                     x_return_status => x_return_status,
                     x_msg_data => x_msg_data);

      end loop;

      if(c_discLines%ISOPEN) then
        close c_discLines;
      elsif(c_repLines%ISOPEN) then
        close c_repLines;
      end if;
      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        end if;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

    --finally update backordered quantity to 0
    if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
      update wip_requirement_operations
         set quantity_backordered = 0
       where wip_entity_id = p_wip_entity_id
         and operation_seq_num = p_operation_seq_num
         and inventory_item_id = p_inventory_item_id;
    elsif(p_wip_entity_type = wip_constants.repetitive) then
      update wip_requirement_operations
         set quantity_backordered = 0
       where wip_entity_id = p_wip_entity_id
         and repetitive_schedule_id = p_repetitive_schedule_id
         and operation_seq_num = p_operation_seq_num
         and inventory_item_id = p_inventory_item_id;
    end if;
    exception
      when fnd_api.g_exc_unexpected_error then
        ROLLBACK TO WIP_CANCEL_COMP_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      when others then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        end if;
        ROLLBACK TO WIP_CANCEL_COMP_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.cancel_comp_allocations: ' || SQLERRM);
        x_msg_data := fnd_message.get;
  END cancel_comp_allocations;

   Procedure cancel_MO_line(p_lineId  IN NUMBER,
                 p_rowId ROWID,
                 p_wip_entity_type NUMBER,
                 p_openQty NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2
                 ) IS

   l_msgCount NUMBER;

   BEGIN
           update wip_requirement_operations
             set quantity_allocated = nvl(quantity_allocated,0) - p_openQty,
                 last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
           where rowid = p_rowId;

           INV_MO_Cancel_PVT.Cancel_Move_Order_Line(x_return_status       => x_return_status,
                                                 x_msg_count           => l_msgCount,
                                                 x_msg_data            => x_msg_data,
                                                 p_line_id             => p_lineId,
                                                 p_delete_reservations => 'N');
   END cancel_MO_line;

   procedure reduce_comp_allocations(p_comp_tbl IN wip_picking_pub.allocate_comp_tbl_t,
                               p_wip_entity_type NUMBER,
                               p_organization_id NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2)IS

      l_msgCount NUMBER;
      l_lineID NUMBER;
      l_wroRowID ROWID;
      l_openQty NUMBER;
      l_reductionQty NUMBER;

      CURSOR c_repLines(v_wip_entity_id NUMBER, v_repetitive_schedule_id NUMBER, v_operation_seq_num NUMBER, v_inventory_item_id NUMBER) IS
        select line_id, nvl(mtrl.required_quantity,(nvl(quantity_detailed,0) - nvl(quantity_delivered,0))) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = v_wip_entity_id
           and mtrl.reference_id = v_repetitive_schedule_id
           and wro.wip_entity_id = v_wip_entity_id
           and wro.repetitive_schedule_id = v_repetitive_schedule_id
           and wro.operation_seq_num = v_operation_seq_num
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and wro.inventory_item_id = v_inventory_item_id
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)

           order by mtrl.creation_date desc  /* Traverse thru move orders in LIFO fashion */

        for update of wro.quantity_allocated, quantity_backordered nowait;

      CURSOR c_discLines(v_wip_entity_id NUMBER, v_operation_seq_num NUMBER, v_inventory_item_id NUMBER) IS
        select line_id, nvl(mtrl.required_quantity,(nvl(quantity_detailed,0) - nvl(quantity_delivered,0))) open_quantity, wro.rowid
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = v_wip_entity_id
           and wro.wip_entity_id = v_wip_entity_id
           and wro.operation_seq_num = v_operation_seq_num
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and wro.inventory_item_id = v_inventory_item_id
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)

           order by mtrl.creation_date desc  /* Traverse thru move orders in LIFO fashion */
        for update of wro.quantity_allocated, quantity_backordered nowait;


    BEGIN
      SAVEPOINT WIP_REDUCE_COMP_ALLOCS_START;
      x_return_status := FND_API.G_RET_STS_SUCCESS; -- in case no open lines are found
      for i in 1..p_comp_tbl.COUNT LOOP /* Component Loop*/
        if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
          open c_discLines(p_comp_tbl(i).wip_entity_id, p_comp_tbl(i).operation_seq_num, p_comp_tbl(i).inventory_item_id);
        elsif(p_wip_entity_type  = wip_constants.repetitive) then
          open c_repLines(p_comp_tbl(i).wip_entity_id, p_comp_tbl(i).repetitive_schedule_id, p_comp_tbl(i).operation_seq_num, p_comp_tbl(i).inventory_item_id);
        end if;
        l_reductionQty := p_comp_tbl(i).requested_quantity;

      Loop                   /* Loop through all the MO lines for this component */

        if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
          fetch c_discLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_discLines%NOTFOUND;
        elsif(p_wip_entity_type = wip_constants.repetitive) then
          fetch c_repLines into l_lineID, l_openQty, l_wroRowID;
          exit when c_repLines%NOTFOUND;
        end if;

        if(l_openQty <= l_reductionQty) then
          INV_MO_Cancel_PVT.Cancel_Move_Order_Line(x_return_status       => x_return_status,
                                                 x_msg_count           => l_msgCount,
                                                 x_msg_data            => x_msg_data,
                                                 p_line_id             => l_lineId,
                                                 p_delete_reservations => 'N');
          l_reductionQty := l_reductionQty - l_openQty;
        else
          INV_MO_Cancel_PVT.Reduce_Move_Order_Quantity(x_return_status       => x_return_status,
                                                 x_msg_count           => l_msgCount,
                                                 x_msg_data            => x_msg_data,
                                                 p_line_id             => l_lineId,
                                                 p_reduction_quantity  => l_reductionQty);
         l_reductionQty := 0;
         end if;

       if (l_reductionQty = 0) then
       exit ;
       end if;
      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        end if;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

       end Loop;  /* End of MO lines loop */

      if(l_reductionQty <> 0) then  /* if requested quantity is more than total allocated quantity */
        x_return_status := 'P';     /*then, return a warning message that only allocated quantity has been reduced*/
        fnd_message.set_name('WIP', 'WIP_PICKING_PARTIAL_REDUCTION');
        x_msg_data := fnd_message.get;
      end if;

      if(c_discLines%ISOPEN) then
        close c_discLines;
      elsif(c_repLines%ISOPEN) then
        close c_repLines;
      end if;

    /*finally update backordered quantity and allocated quantity for this component*/
    if(p_wip_entity_type in (wip_constants.discrete, wip_constants.lotbased, wip_constants.eam)) then
      update wip_requirement_operations
         set quantity_backordered = greatest((quantity_backordered - p_comp_tbl(i).requested_quantity), 0),
             quantity_allocated   = quantity_allocated - p_comp_tbl(i).requested_quantity
       where wip_entity_id = p_comp_tbl(i).wip_entity_id
         and operation_seq_num = p_comp_tbl(i).operation_seq_num
         and inventory_item_id = p_comp_tbl(i).inventory_item_id;
    elsif(p_wip_entity_type = wip_constants.repetitive) then
      update wip_requirement_operations
         set quantity_backordered = greatest(quantity_backordered - p_comp_tbl(i).requested_quantity, 0),
             quantity_allocated   = quantity_allocated - p_comp_tbl(i).requested_quantity
       where wip_entity_id  = p_comp_tbl(i).wip_entity_id
         and repetitive_schedule_id = p_comp_tbl(i).repetitive_schedule_id
         and operation_seq_num  = p_comp_tbl(i).operation_seq_num
         and inventory_item_id  = p_comp_tbl(i).inventory_item_id;
    end if;
    end LOOP; /*End of component loop*/
    exception
      when fnd_api.g_exc_unexpected_error then
        ROLLBACK TO WIP_REDUCE_COMP_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      when others then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        end if;
        ROLLBACK TO WIP_REDUCE_COMP_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.cancel_allocations: ' || SQLERRM);
        x_msg_data := fnd_message.get;
   END reduce_comp_allocations;




  procedure update_allocation_op_seqs(p_wip_entity_id IN NUMBER,
                                      p_repetitive_schedule_id IN NUMBER := null,
                                      p_operation_seq_num IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data OUT NOCOPY VARCHAR2) IS
      CURSOR c_repLines IS
        select line_id
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = p_wip_entity_id
           and mtrl.txn_source_line_id = p_repetitive_schedule_id
           and wro.wip_entity_id = p_wip_entity_id
           and wro.repetitive_schedule_id = p_repetitive_schedule_id
           and wro.operation_seq_num = 1
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)

        for update of wro.quantity_allocated, wro.quantity_backordered nowait; --make sure no orders are transacted in the meantime

      CURSOR c_discLines IS
        select line_id
          from mtl_txn_request_lines mtrl, wip_requirement_operations wro
         where mtrl.txn_source_id = p_wip_entity_id
           and wro.wip_entity_id = p_wip_entity_id
           and wro.operation_seq_num = 1
           and mtrl.txn_source_line_id = wro.operation_seq_num
           and mtrl.inventory_item_id = wro.inventory_item_id
           and mtrl.organization_id = wro.organization_id
           and mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
           and exists(select 1
                        from mtl_txn_request_headers mtrh
                       where mtrl.header_id = mtrh.header_id
                         and mtrh.move_order_type = INV_Globals.G_MOVE_ORDER_MFG_PICK)
        for update of wro.quantity_allocated, wro.quantity_backordered nowait;--make sure no orders are transacted in the meantime

      l_lineID NUMBER;
      l_msgCount NUMBER;
    BEGIN
      SAVEPOINT WIP_UPDATE_ALLOCS_START;
      x_return_status := FND_API.G_RET_STS_SUCCESS; -- in case no open lines are found
      if(p_repetitive_schedule_id is null) then
        open c_discLines;
      else
        open c_repLines;
      end if;
      loop --need to handle failure conditions!!!
        if(p_repetitive_schedule_id is null) then
          fetch c_discLines into l_lineID;
          exit when c_discLines%NOTFOUND;
        else
          fetch c_repLines into l_lineID;
          exit when c_repLines%NOTFOUND;
        end if;

        inv_wip_picking_pvt.update_mol_for_wip(p_move_order_line_id => l_lineID,
                                               p_op_seq_num => p_operation_seq_num,
                                               x_msg_count  => l_msgCount,
                                               x_msg_data => x_msg_data,
                                               x_return_status => x_return_status);
        if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          if(c_discLines%ISOPEN) then
            close c_discLines;
          elsif(c_repLines%ISOPEN) then
            close c_repLines;
          end if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end loop;
      if(c_discLines%ISOPEN) then
        close c_discLines;
      elsif(c_repLines%ISOPEN) then
        close c_repLines;
      end if;

    exception
      when fnd_api.g_exc_unexpected_error then
        ROLLBACK TO WIP_UPDATE_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      when others then
        if(c_discLines%ISOPEN) then
          close c_discLines;
        elsif(c_repLines%ISOPEN) then
          close c_repLines;
        end if;
        ROLLBACK TO WIP_UPDATE_ALLOCS_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.update_allocation_op_seqs: ' || SQLERRM);
  end update_allocation_op_seqs;

  /* Starting for p_index element of p_alloc_tbl, find number of consective flow schedules
     that contain the same assembly, assembly qty, and required date. This number allows
     allocate() to explode the bom just once for the whole group
     Parameters:
       p_alloc_tbl:   table of schedules to search through
       p_index:       index of the table to start at
       p_item_id, p_ably_qty, p_req_date:
                      assembly, assembly qty, and required date of the schedule that
                      all subsequent schedules compare to to see if there is a match.
       x_opt_total:   the total of number schedules that can be grouped together.
  */
  procedure getOptimalFlowSchGrp(p_alloc_tbl IN wip_picking_pub.allocate_tbl_t,
                                      p_index IN NUMBER,
                                      p_item_id IN NUMBER,
                                      p_ably_qty IN NUMBER,
                                      p_req_date IN DATE,
                                      x_opt_total OUT NOCOPY NUMBER) IS
   l_orgid NUMBER;
   l_billSeqId NUMBER;
   l_itemID NUMBER;
   l_reqDate DATE;
   l_assemblyQty NUMBER;

   CURSOR c_flowSchedules(v_wip_entity_id NUMBER) IS
            select a.organization_id,
                 a.bill_sequence_id,
                 wfs.primary_item_id,
                 wfs.SCHEDULED_COMPLETION_DATE,
                 wfs.planned_quantity
            from bom_bill_of_materials a, bom_bill_of_materials b, wip_flow_schedules wfs
            where a.bill_sequence_id = b.common_bill_sequence_id
                and b.assembly_item_id = wfs.primary_item_id
                and wfs.wip_entity_id = v_wip_entity_id
                and b.organization_id = wfs.organization_id
                and (   nvl(b.alternate_bom_designator, 'none') = nvl(wfs.alternate_bom_designator, 'none')
                  or (    b.alternate_bom_designator IS NULL
                      and not exists(select 'x'
                                       from bom_bill_of_materials c
                                      where c.assembly_item_id = wfs.primary_item_id
                                       and c.organization_id = wfs.organization_id
                                       and c.alternate_bom_designator = wfs.alternate_bom_designator
                                    )
                      )
                   )
             for update of wfs.allocated_flag nowait;

  begin
    x_opt_total := 1;

    for i in (p_index+1)..p_alloc_tbl.COUNT LOOP
        open c_flowSchedules(p_alloc_tbl(i).wip_entity_id);
        fetch c_flowSchedules into l_orgid, l_billSeqId, l_itemID,
                                   l_reqDate, l_assemblyQty;
        exit when c_flowSchedules%NOTFOUND;

        if (p_alloc_tbl(p_index).bill_org_id <> l_orgid or
            p_alloc_tbl(p_index).bill_seq_id <> l_billSeqId or
            p_item_id <> l_itemID or
            trunc(p_req_date) <>  trunc(l_reqDate) or
            p_ably_qty <> l_assemblyQty) then
          exit;
        end if;

        x_opt_total := x_opt_total + 1;
        close c_flowSchedules;
    end loop;

  end;

  /* After finding the optimzed group of schedules to group together(that has the same
     assembly, job qty, and required date), make sure the bom exploded at the begin
     of the required date and at the end of required date are the same, otherwise,
     this group is not optimzable, because there is likely a component on the BOM that
     is disabled in the middle of the date.
     Parameters:
        All p_* input parameters: used to explode the bom
        x_comp_sql_tbl:           return the exploded bom
        x_explode_status:         status of explosion code
        x_optimize_status:        status indicatign if group can be optimzed, i.e. explode
                                  once for the whole group
        x_msg_data:               any error messages
   */
  procedure isFlowSchGrpOptimizable(p_organization_id NUMBER,
                              p_assembly_item_id NUMBER,
                              p_assembly_qty NUMBER,
                              p_alt_bom_desig VARCHAR2,
                              p_rev_date DATE,
                              p_project_id NUMBER,
                              p_task_id NUMBER,
                              p_alt_rout_desig VARCHAR2,
                              x_comp_sql_tbl OUT NOCOPY wip_picking_pub.allocate_comp_tbl_t,
                              x_explode_status OUT NOCOPY VARCHAR2,
                              x_optimize_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2) IS
  l_comp_sql_tbl wip_picking_pub.allocate_comp_tbl_t;
  l_dummy VARCHAR2(1);

  begin

    explodeMultiLevel(p_organization_id => p_organization_id,
                      p_assembly_item_id => p_assembly_item_id,
                      p_alt_option => 1,
                      p_assembly_qty => p_assembly_qty,
                      p_alt_bom_desig => p_alt_bom_desig,
                      p_rev_date => trunc(p_rev_date),
                      p_project_id => p_project_id,
                      p_task_id => p_task_id,
                      -- explode components at all line ops/events
                      p_to_op_seq_num => null,
                      p_alt_rout_desig => p_alt_rout_desig,
                      x_comp_sql_tbl => x_comp_sql_tbl,
                      x_return_status => l_dummy,
                      x_msg_data => x_msg_data);
   if(l_dummy <> FND_API.G_RET_STS_SUCCESS) then
      x_explode_status := l_dummy;
      x_optimize_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
   end if;

    explodeMultiLevel(p_organization_id => p_organization_id,
                      p_assembly_item_id => p_assembly_item_id,
                      p_alt_option => 1,
                      p_assembly_qty => p_assembly_qty,
                      p_alt_bom_desig => p_alt_bom_desig,
                      p_rev_date => trunc(p_rev_date) + 1,
                      p_project_id => p_project_id,
                      p_task_id => p_task_id,
                      -- explode components at all line ops/events
                      p_to_op_seq_num => null,
                      p_alt_rout_desig => p_alt_rout_desig,
                      x_comp_sql_tbl => l_comp_sql_tbl,
                      x_return_status => l_dummy,
                      x_msg_data => x_msg_data);
   if(l_dummy <> FND_API.G_RET_STS_SUCCESS) then
      x_explode_status := l_dummy;
      x_optimize_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
   end if;

   x_explode_status := FND_API.G_RET_STS_SUCCESS;
   if l_comp_sql_tbl.count <> x_comp_sql_tbl.count then
     x_optimize_status := 'F';
   end if;

   for i in 1..x_comp_sql_tbl.count LOOP
      -- compared the exploded bom of the first and last flow sched in the optimized
      -- group, ie with same assembly
      if (l_comp_sql_tbl(i).inventory_item_id <> x_comp_sql_tbl(i).inventory_item_id or
          l_comp_sql_tbl(i).operation_seq_num <> x_comp_sql_tbl(i).operation_seq_num) then
         x_optimize_status := 'F';
         -- if not optimizable, return table of components exploded
         -- from untruncated time/date
         explodeMultiLevel(p_organization_id => p_organization_id,
                      p_assembly_item_id => p_assembly_item_id,
                      p_alt_option => 1,
                      p_assembly_qty => p_assembly_qty,
                      p_alt_bom_desig => p_alt_bom_desig,
                      p_rev_date => p_rev_date,
                      p_project_id => p_project_id,
                      p_task_id => p_task_id,
                      -- explode components at all line ops/events
                      p_to_op_seq_num => null,
                      p_alt_rout_desig => p_alt_rout_desig,
                      x_comp_sql_tbl => x_comp_sql_tbl,
                      x_return_status => l_dummy,
                      x_msg_data => x_msg_data);
         return;
      end if;
   end loop;

   x_optimize_status := FND_API.G_RET_STS_SUCCESS;

  end;


 --this version is used by the form and
  --called by the conc. request wrapper version
  procedure allocate(p_alloc_tbl IN OUT NOCOPY wip_picking_pub.allocate_tbl_t,
                     p_days_to_alloc NUMBER := NULL, --only used for rep scheds
                     p_auto_detail_flag VARCHAR2 DEFAULT NULL,
                     p_start_date DATE DEFAULT NULL, /* Enh#2824753 */
                     p_cutoff_date DATE,
                     p_wip_entity_type NUMBER,
                     p_organization_id NUMBER,
                     p_operation_seq_num_low NUMBER := NULL, /* Enh#2824753 */
                     p_operation_seq_num_high NUMBER := NULL,
                     p_pick_grouping_rule_id NUMBER := NULL, /* Added as part of Enhancement#2578514*/
                     p_print_pick_slip VARCHAR2 DEFAULT NULL,      /* Added as part of Enhancement#2578514*/
                     p_plan_tasks BOOLEAN DEFAULT NULL,           /* Added as part of Enhancement#2578514*/
                     x_conc_req_id OUT NOCOPY NUMBER,
                     x_mo_req_number OUT NOCOPY VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2) IS
    l_explodeStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_explodeMessage VARCHAR2(2000);
    l_lineCount NUMBER := 0;
    l_lineCountHolder NUMBER;
    l_pickStatus VARCHAR2(1) := 'N';
    l_backflushStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_optimizeStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_pickSetId NUMBER := 1;
    l_itemID NUMBER;
    l_operationSeqNum NUMBER;
    l_subinv VARCHAR2(10);
    l_locator NUMBER;
    l_uom VARCHAR2(4);
    l_supplyType NUMBER;
    l_reqDate DATE;
    l_openQty NUMBER;
    l_assemblyQty NUMBER;
    l_linesTable INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
    l_linesRec INV_MOVE_ORDER_PUB.Trolin_Rec_Type;
    l_hdrRec INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
    l_defaultSub VARCHAR2(10);
    l_defaultLocator NUMBER;
    l_disc NUMBER := wip_constants.discrete;
    l_eam NUMBER := wip_constants.eam;
    l_lotbased NUMBER := wip_constants.lotbased;
    l_repetitive NUMBER := wip_constants.repetitive;
    l_msgCount NUMBER;
    l_dummy VARCHAR2(1);
    l_abm VARCHAR2(10);
    l_revControlCode varchar2(3);
    l_carton_grouping_id NUMBER :=0;
    l_string1 VARCHAR2(200);
    l_string2 VARCHAR2(200);
    l_flowCompTbl wip_picking_pub.allocate_comp_tbl_t;
    l_routing_seq_id NUMBER;
    j NUMBER := 1;
    h NUMBER;
    k NUMBER;
    l_dummy2 VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_opt_cnt NUMBER := 0;
    l_include_yield NUMBER; /*Component Yield Enhancement(Bug 4369064)*/
    x_MOLineErrTbl      INV_WIP_Picking_Pvt.Trolin_ErrTbl_type;
    l_include_comp_yield_factor NUMBER := 1 ;


    CURSOR c_discJobs(v_wip_entity_id NUMBER ) IS
      select wro.operation_seq_num,
             wro.inventory_item_id,
               /*Component Yield Enhancement(Bug 4369064)-> Derive quantity to allocate based on yield parameter*/
             (wro.required_quantity * decode(l_include_yield,2,nvl(wro.component_yield_factor,1),1)
              - wro.quantity_issued
--                -  nvl(wro.quantity_allocated, 0)
                - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                -  nvl(wo.CUMULATIVE_SCRAP_QUANTITY*wro.QUANTITY_PER_ASSEMBLY /
                       decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1)), 0)) open_quantity,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.primary_uom_code,
             wro.wip_supply_type,
             wro.date_required,
             msi.revision_qty_control_code

       from wip_requirement_operations wro, mtl_system_items_b msi, wip_operations wo
       where wro.wip_entity_id = v_wip_entity_id
         and ((p_start_date is NULL) OR  (wro.date_required >= p_start_date))   /* Enh#2824753 */
         and ((p_cutoff_date is NULL) OR (wro.date_required <= p_cutoff_date))
         and (
                 (    'Y' = (select allocate_backflush_components
                               from wip_parameters wp
                              where organization_id = wro.organization_id)
                  and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                 )
              or wro.wip_supply_type = wip_constants.push
             )
          /*Bug 5255566 (FP Bug 5504661) : Changed below condition to show only components having open quantity greater then
		                  0.00001 (least amount inventory can transfer)*/
          and (wro.required_quantity - (wro.quantity_issued
                    + nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) >= 0.00001)
          and wro.inventory_item_id = msi.inventory_item_id
          and wro.wip_entity_id = wo.wip_entity_id (+)
          and ( p_operation_seq_num_low IS NULL OR wro.operation_seq_num >= p_operation_seq_num_low)
          and ( p_operation_seq_num_high IS NULL OR wro.operation_seq_num <= p_operation_seq_num_high)
          and wro.operation_seq_num = wo.operation_seq_num (+)
          and (wo.count_point_type is null or wo.count_point_type in (1,2))
          and wro.organization_id = msi.organization_id
          and wro.organization_id = p_organization_id
          and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
          for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;

    CURSOR c_eamwo(v_wip_entity_id NUMBER) IS
      select wro.operation_seq_num,
             wro.inventory_item_id,
               /*Component Yield Enhancement(Bug 4369064)-> Derive quantity to allocate based on yield parameter*/
             (wro.required_quantity * decode(l_include_yield,2,nvl(wro.component_yield_factor,1),1)
              - wro.quantity_issued
  --               - nvl(wro.quantity_allocated, 0)
                - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                - nvl(wo.CUMULATIVE_SCRAP_QUANTITY*wro.QUANTITY_PER_ASSEMBLY /
                       decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1)), 0)) open_quantity,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.primary_uom_code,
             wro.wip_supply_type,
             wro.date_required,
             msi.revision_qty_control_code

        from wip_requirement_operations wro, mtl_system_items_b msi, wip_operations wo
       where wro.wip_entity_id = v_wip_entity_id
          and ((p_start_date is NULL) OR  (wro.date_required >= p_start_date))   /* Enh#2824753 */
          and ((p_cutoff_date is NULL) OR (wro.date_required <= p_cutoff_date))
          /*Bug 5255566 (FP Bug 5504661) : Changed below condition to show only components having open quantity greater then
		                  0.00001 (least amount inventory can transfer)*/
          and (wro.required_quantity - (wro.quantity_issued +
               nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) >= 0.00001)
          and wro.inventory_item_id = msi.inventory_item_id
          and wro.wip_entity_id = wo.wip_entity_id (+)
          and ( p_operation_seq_num_low IS NULL OR wro.operation_seq_num >= p_operation_seq_num_low) /* Enh#2824753: op seq converted to range for EAM work orders */
          and ( p_operation_seq_num_high IS NULL OR wro.operation_seq_num <= p_operation_seq_num_high)
          and wro.operation_seq_num = wo.operation_seq_num (+)
          and (wo.count_point_type is null or wo.count_point_type in (1,2))
          and wro.auto_request_material = 'Y'
          and wro.organization_id = msi.organization_id
          and wro.organization_id = p_organization_id
          and wro.wip_supply_type <> wip_constants.bulk
          and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
          for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;
/*Bug 5119650 and 5119601 */
/* Modified the calculation of open quantity considering lot basis of component and yield factor*/
    CURSOR c_lotJobs(v_wip_entity_id NUMBER) IS
      select wro.operation_seq_num,
             wro.inventory_item_id,
             ((decode (nvl(wro.basis_type,wip_constants.item_based_mtl),wip_constants.item_based_mtl,
	     (wo.quantity_in_queue + wo.quantity_running + wo.quantity_completed),1) *
	      wro.quantity_per_assembly /
	     decode(l_include_yield,l_include_comp_yield_factor,nvl(wro.component_yield_factor,1),1))
                   - wro.quantity_issued
                   - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) open_quantity,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.primary_uom_code,
             wro.wip_supply_type,
             wro.date_required,
             msi.revision_qty_control_code

        from wip_requirement_operations wro, wip_operations wo, mtl_system_items_b msi
       where wro.wip_entity_id = v_wip_entity_id
         and wro.wip_entity_id = wo.wip_entity_id
         and wro.operation_seq_num = wo.operation_seq_num
         and ((p_start_date is NULL) OR  (wro.date_required >= p_start_date))   /* Enh#2824753 */
         and ((p_cutoff_date is NULL) OR (wro.date_required <= p_cutoff_date))
         and (
                 (    'Y' = (select allocate_backflush_components
                               from wip_parameters wp
                              where organization_id = wro.organization_id)
                  and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                 )
              or wro.wip_supply_type = wip_constants.push
             )
--          and (nvl(wro.quantity_allocated,0) + wro.quantity_issued) < ((wo.quantity_in_queue + wo.quantity_running +
--                                                                        wo.quantity_completed) * wro.quantity_per_assembly)
          /*Bug 5255566 (FP Bug 5504661) : Changed below condition to show only components having open quantity greater then
		                  0.00001 (least amount inventory can transfer)*/
          and (((wo.quantity_in_queue + wo.quantity_running + wo.quantity_completed) * wro.quantity_per_assembly) -
                 (wro.quantity_issued +
                  nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) >= 0.00001)
          and wro.inventory_item_id = msi.inventory_item_id
          and wro.organization_id = msi.organization_id
          and wro.organization_id = p_organization_id
          and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
          for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;

    CURSOR c_rep(v_rep_sched_id NUMBER) IS
      select wro.operation_seq_num,
             wro.inventory_item_id,
               /*Component Yield Enhancement(Bug 4369064)-> Derive quantity to allocate based on yield parameter*/
             least(  --open qty is the smaller of the remaining quantity and the quantity determined by the #days to allocate for
               (wro.required_quantity * decode(l_include_yield,2,nvl(wro.component_yield_factor,1),1)
                   - wro.quantity_issued
                   - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,WRO. REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                   - nvl(wo.CUMULATIVE_SCRAP_QUANTITY*wro.QUANTITY_PER_ASSEMBLY /
                            decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1)),0)),
               (wrs.daily_production_rate * wro.quantity_per_assembly * p_days_to_alloc) + nvl(wro.quantity_backordered, 0)) open_quantity,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.primary_uom_code,
             wro.wip_supply_type,
             wro.date_required,
             msi.revision_qty_control_code

        from wip_requirement_operations wro,
             wip_repetitive_schedules wrs,
             mtl_system_items_b msi,
             wip_operations wo
       where wro.repetitive_schedule_id = v_rep_sched_id
         and wrs.repetitive_schedule_id = v_rep_sched_id
         and ((p_start_date is NULL) OR  (wro.date_required >= p_start_date))   /* Enh#2824753 */
         and ((p_cutoff_date is null) OR (wro.date_required <= p_cutoff_date))
         and (
                 (    'Y' = (select allocate_backflush_components
                               from wip_parameters wp
                              where organization_id = wro.organization_id)
                  and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                 )
              or wro.wip_supply_type = wip_constants.push
             )
          /*Bug 5255566 (FP Bug 5504661) : Changed below condition to show only components having open quantity greater then
		                  0.00001 (least amount inventory can transfer)*/
         and (wro.required_quantity - (wro.quantity_issued +
             nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID,WRO.QUANTITY_ISSUED),0))  >= 0.00001)
         and wro.inventory_item_id = msi.inventory_item_id
         and wro.organization_id = msi.organization_id
         and wro.organization_id = p_organization_id
         and wro.repetitive_schedule_id = wo.repetitive_schedule_id (+)
         and wro.operation_seq_num = wo.operation_seq_num (+)
         and (wo.count_point_type is null or wo.count_point_type in (1,2))
         and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
         for update of wro.quantity_allocated, wro.quantity_backordered, quantity_issued nowait;

    --The following variables are used for performance reasons in order
    --to avoid multiple unnecessary cross package calls when creating lines.
    l_sysDate DATE := sysdate;
    l_backflushTxnType NUMBER := INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR;
    l_issueTxnType NUMBER := INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE;
    l_push NUMBER := wip_constants.push;
    /* Bug 4917429 */
    l_jobname VARCHAR2(240);
    l_item VARCHAR2(2000);

  BEGIN
    SAVEPOINT WIP_ALLOCATE_PVT_START;
    x_msg_data := null;
    select default_pull_supply_subinv, default_pull_supply_locator_id
      into l_defaultSub, l_defaultLocator
      from wip_parameters
     where organization_id = p_organization_id;

      /*Component Yield Enhancement(Bug 4369064) -> Fetch the value of component yield parameter*/
      select nvl(include_component_yield,1)
      into  l_include_yield
      from wip_parameters
      where organization_id = p_organization_id;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log('wip_picking_pvt.allocate => job count in table passed into allocate(): '
                           || p_alloc_tbl.COUNT, l_dummy2);
      wip_logger.log('p_days_to_alloc=' || p_days_to_alloc || ',p_auto_detail_flag=' || p_auto_detail_flag ||
                ',p_start_date=' || p_start_date || ',p_cutoff_date=' || p_cutoff_date ||
                ',p_wip_entity_type=' || p_wip_entity_type ||  ',p_organization_id=' || p_organization_id ||
                ',p_operation_seq_num_low=' || p_operation_seq_num_low ||
                ',p_operation_seq_num_high=' || p_operation_seq_num_high ||
                ',p_pick_grouping_rule_id=' || p_pick_grouping_rule_id || ',p_print_pick_slip=' ||
                p_print_pick_slip, l_dummy2);
      wip_logger.log('wip_picking_pvt.allocate => add comp:', l_dummy2);
     end if;

     for i in 1..p_alloc_tbl.COUNT LOOP

      if(p_wip_entity_type = l_disc) then
        open c_discJobs(p_alloc_tbl(i).wip_entity_id);
      elsif(p_wip_entity_type = l_eam) then
        open c_eamwo(p_alloc_tbl(i).wip_entity_id);
      elsif(p_wip_entity_type = l_lotbased) then
        open c_lotJobs(p_alloc_tbl(i).wip_entity_id);
      elsif(p_wip_entity_type  = l_repetitive) then
        open c_rep(p_alloc_tbl(i).repetitive_schedule_id);
      elsif(p_wip_entity_type = wip_constants.flow) then --flow

         if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.log('wip_picking_pvt.allocate => processing job: (wei)'
                           || p_alloc_tbl(i).wip_entity_id
                           || ';job counter=' || i || ';total=' || p_alloc_tbl.COUNT, l_dummy2);
         end if;


        --flow schedules, lock the allocated flag column as to not allocate a flow schedule 2x.
        --checking the allocated flag takes place in the flow cursor
        if(p_alloc_tbl(i).bill_seq_id is null or p_alloc_tbl(i).bill_org_id is null) then
          begin
            select a.organization_id,
                 a.bill_sequence_id,
                 wfs.primary_item_id,
                 wfs.alternate_bom_designator,
                 wfs.alternate_routing_designator,
                 wfs.SCHEDULED_COMPLETION_DATE,
                 wfs.planned_quantity
            into p_alloc_tbl(i).bill_org_id, p_alloc_tbl(i).bill_seq_id, l_itemID, l_abm,
                 p_alloc_tbl(i).alt_rtg_dsg, l_reqDate, l_assemblyQty
            from bom_bill_of_materials a, bom_bill_of_materials b, wip_flow_schedules wfs
            where a.bill_sequence_id = b.common_bill_sequence_id
                and b.assembly_item_id = wfs.primary_item_id
                and wfs.wip_entity_id = p_alloc_tbl(i).wip_entity_id
                and b.organization_id = wfs.organization_id
                and (   nvl(b.alternate_bom_designator, 'none') = nvl(wfs.alternate_bom_designator, 'none')
                  or (    b.alternate_bom_designator IS NULL
                      and not exists(select 'x'
                                       from bom_bill_of_materials c
                                      where c.assembly_item_id = wfs.primary_item_id
                                       and c.organization_id = wfs.organization_id
                                       and c.alternate_bom_designator = wfs.alternate_bom_designator
                                    )
                      )
                   )
             for update of wfs.allocated_flag nowait;
           exception
             when NO_DATA_FOUND then
               wip_logger.log('wip_picking_pvt.allocate => ' ||
                              'no BOM found for wip_entity_id:' ||
                              p_alloc_tbl(i).wip_entity_id, l_dummy2 );
               GOTO END_OF_FOR_LOOP;
           end;

           begin
             select a.routing_sequence_id
                   into l_routing_seq_id
             from bom_operational_routings a, bom_operational_routings b, wip_flow_schedules wfs
             where a.routing_sequence_id = b.common_routing_sequence_id
                  and b.assembly_item_id = wfs.primary_item_id
                  and wfs.wip_entity_id = p_alloc_tbl(i).wip_entity_id
                  and b.organization_id = wfs.organization_id
                  and (   nvl(b.alternate_routing_designator, 'none') = nvl(wfs.alternate_routing_designator, 'none')
                       or (    b.alternate_routing_designator IS NULL
                               and not exists(select 'x'
                                   from bom_operational_routings c
                                  where c.assembly_item_id = wfs.primary_item_id
                                   and c.organization_id = wfs.organization_id
                                   and c.alternate_routing_designator = wfs.alternate_routing_designator
                                   )
                           )
                      );

             exception
               when NO_DATA_FOUND then
	         /* BugFix 6964780: Corrected the wip_logger.log API call */
                 wip_logger.log('wip_picking_pvt.allocate => no routing found for wip_entity_id:'|| p_alloc_tbl(i).wip_entity_id, l_dummy2 );
             end;

             -- bug#3409239 Begin: Improve Flow picking performance by grouping
             -- if 0, then this schedule is not grouped with the schedule
             -- in the previous iteration
             p_alloc_tbl(i).required_date := l_reqDate;
             if (l_opt_cnt = 0) then
               getOptimalFlowSchGrp(p_alloc_tbl => p_alloc_tbl,
                                      p_index => i,
                                      p_item_id => l_itemID,
                                      p_ably_qty => l_assemblyQty,
                                      p_req_date => p_alloc_tbl(i).required_date,
                                      x_opt_total => l_opt_cnt);

               if (l_logLevel <= wip_constants.trace_logging) then
                 wip_logger.log('wip_picking_pvt.allocate => ' ||
                                'flow optimal group total: ' || l_opt_cnt, l_dummy2);
               end if;
               -- no flow sched can be grouped together
               if (l_opt_cnt < 3) then
                 l_opt_cnt := 0;
                 explodeMultiLevel(p_organization_id => p_alloc_tbl(i).bill_org_id,
                              p_assembly_item_id => l_itemID,
                              p_alt_option => 1,
                              p_assembly_qty => l_assemblyQty,
                              p_alt_bom_desig => l_abm,
                              p_rev_date => p_alloc_tbl(i).required_date,
                              p_project_id => p_alloc_tbl(i).project_id,
                              p_task_id => p_alloc_tbl(i).task_id,
                              -- explode components at all line ops/events
                              p_to_op_seq_num => null,
                              p_alt_rout_desig => p_alloc_tbl(i).alt_rtg_dsg,
                              x_comp_sql_tbl => l_flowCompTbl,
                              x_return_status => l_dummy,
                              x_msg_data => l_explodeMessage);
                 if(l_dummy <> FND_API.G_RET_STS_SUCCESS) then
                   l_explodeStatus := l_dummy;
                   p_alloc_tbl(i).bill_seq_id := null; --reset the bill seq and org as the assy's bill could not be exploded
                   P_alloc_tbl(i).bill_org_id := null;
                 end if;
               else -- if (l_opt_cnt >= 3)
                 -- some flow sch can be grouped together

                 -- check if same bom for the grouped flow schedule
                 isFlowSchGrpOptimizable(p_organization_id => p_alloc_tbl(i).bill_org_id,
                              p_assembly_item_id => l_itemID,
                              p_assembly_qty => l_assemblyQty,
                              p_alt_bom_desig => l_abm,
                              p_rev_date => p_alloc_tbl(i).required_date,
                              p_project_id => p_alloc_tbl(i).project_id,
                              p_task_id => p_alloc_tbl(i).task_id,
                              p_alt_rout_desig => p_alloc_tbl(i).alt_rtg_dsg,
                              x_comp_sql_tbl => l_flowCompTbl,
                              x_explode_status => l_explodeStatus,
                              x_optimize_status => l_optimizeStatus,
                              x_msg_data => l_explodeMessage);
                 if(l_explodeStatus <> FND_API.G_RET_STS_SUCCESS) then
                 -- assy's bill could not be exploded, then reset the bill seq and org
                   l_opt_cnt := 0;
                   p_alloc_tbl(i).bill_seq_id := null;
                   P_alloc_tbl(i).bill_org_id := null;
                 elsif (l_optimizeStatus <> FND_API.G_RET_STS_SUCCESS) then
                 -- can not optimize, b/c bom is not the same for the group,
                 -- reset counter, and proceed as normal(one record at a time)
                   l_opt_cnt := 0;

                   if (l_logLevel <= wip_constants.trace_logging) then
                     wip_logger.log('wip_picking_pvt.allocate => ' ||
                                'flow optimal group NOT optimzable', l_dummy2);
                   end if;
                 else
                 -- can be optimized, do nothing here, it will be processed
                 -- as a whole right before passing to INV
                   if (l_logLevel <= wip_constants.trace_logging) then
                     wip_logger.log('wip_picking_pvt.allocate => ' ||
                                'flow optimal group IS optimzable', l_dummy2);
                   end if;
                 end if;
               end if;
             else -- if (l_opt_cnt > 0)
               -- in the middle of an optimized flow sched group, jump to the end
               -- of the jobs loop, since this whole group has been added to
               -- l_linesTable to pass to INV
               if (l_logLevel <= wip_constants.trace_logging) then
                     wip_logger.log('wip_picking_pvt.allocate => ' ||
                                'processing flow optimal group..', l_dummy2);
               end if;
               l_opt_cnt := l_opt_cnt-1;
               GOTO END_OF_FOR_LOOP;
             end if; -- bug#3409239 End
        else -- if(p_alloc_tbl(i).bill_seq_id is null..
               select allocated_flag
               into l_dummy
               from wip_flow_schedules
               where wip_entity_id = p_alloc_tbl(i).wip_entity_id
               for update of allocated_flag nowait;
        end if;

        if(p_alloc_tbl(i).bill_seq_id is null or p_alloc_tbl(i).bill_org_id is null) then
          GOTO END_OF_FOR_LOOP; --since the bill could not be exploded, skip it!!!

        end if;

      else -- if(p_wip_entity_type = l_disc)
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pvt.allocate: invalid entity_type' );
        x_msg_data := fnd_message.get;
        return;
      end if;

      /* Added as part of Enhancement#2578514*/
      select wsh_delivery_group_s.nextval
      into  l_carton_grouping_id
      from dual;

      j := 0;

      LOOP         /*Component Loop*/
        if(p_wip_entity_type = l_repetitive) then
          fetch c_rep into l_operationSeqNum, l_itemID, l_openQty, l_subinv, l_locator, l_uom, l_supplyType, l_reqDate, l_revControlCode;
          exit when c_rep%NOTFOUND;
        elsif(p_wip_entity_type = l_disc) then
          fetch c_discJobs into l_operationSeqNum, l_itemID, l_openQty, l_subinv, l_locator, l_uom, l_supplyType, l_reqDate,l_revControlCode;
          exit when c_discJobs%NOTFOUND;
        elsif(p_wip_entity_type = l_eam) then
          fetch c_eamwo into l_operationSeqNum, l_itemID, l_openQty, l_subinv, l_locator, l_uom, l_supplyType, l_reqDate,l_revControlCode;
          exit when c_eamwo%NOTFOUND;

        elsif(p_wip_entity_type = l_lotbased) then
          fetch c_lotJobs into l_operationSeqNum, l_itemID, l_openQty, l_subinv, l_locator, l_uom, l_supplyType, l_reqDate,l_revControlCode;
          exit when c_lotJobs%NOTFOUND;

        elsif(p_wip_entity_type = wip_constants.flow) then --flow
          j := j+1;
          if (j > l_flowCompTbl.COUNT) then
            exit;
          end if;

          -- Get Line Op
          begin
          SELECT bos1.operation_seq_num
              into l_operationSeqNum
          FROM bom_operation_sequences bos1
          WHERE bos1.operation_sequence_id = (select bos2.line_op_seq_id from bom_operation_sequences bos2
                         where bos2.routing_sequence_id = l_routing_seq_id
                         and bos2.operation_seq_num = l_flowCompTbl(j).operation_seq_num
                         and bos2.operation_type = 1 );

          exception
            when NO_DATA_FOUND then
              -- Bug#2784239, for event/op seq 1 that's not part of the BOM routing, then the component was added in BOM Bom
              -- before routing was created, which defaults op seq/event to 1. In which case, we set op seq num = 1;
              l_operationSeqNum := 1;
            end;

          l_itemID := l_flowCompTbl(j).inventory_item_id;
          -- bug#2769993 quantity returned is total open quantity and no longer qty per.
          l_openQty := l_flowCompTbl(j).requested_quantity;
          l_subinv := l_flowCompTbl(j).source_subinventory_code;
          l_locator := l_flowCompTbl(j).source_locator_id;
          l_uom := l_flowCompTbl(j).primary_uom_code;
          l_revControlCode := l_flowCompTbl(j).revision;
          l_supplyType := wip_constants.ASSY_PULL; --although defined as push, flow allocations always behave as pull components
        end if;

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log(' op_seq_num=' || l_operationSeqNum || ',item_id=' || l_itemID || ',open qty=' || l_openQty
                      || ',subinv=' || l_subinv || ',loc=' || l_locator || ',supplyType=' || l_supplyType
                      || ',reqDate=' || l_reqDate, l_dummy2);
        end if;

        get_HdrLinesRec( p_wip_entity_id => p_alloc_tbl(i).wip_entity_id,
                        p_project_id => p_alloc_tbl(i).project_id,
                        p_task_id => p_alloc_tbl(i).task_id,
                        p_wip_entity_type => p_wip_entity_type,
                        p_repetitive_schedule_id => p_alloc_tbl(i).repetitive_schedule_id,
                        p_operation_seq_num => l_operationSeqNum,
                        p_inventory_item_id => l_itemID,
                        p_use_pickset_flag => p_alloc_tbl(i).use_pickset_flag,
                        p_pickset_id =>l_pickSetId,
                        p_open_qty => l_openQty,
                        p_to_subinv => l_subinv,
                        p_to_locator => l_locator,
                        p_default_subinv => l_defaultSub,
                        p_default_locator => l_defaultLocator,
                        p_uom => l_uom,
                        p_supply_type => l_supplyType,
                        p_req_date => l_reqDate,
                        p_rev_control_code =>l_revControlCode ,
                        p_organization_id => p_organization_id,
                        p_pick_grouping_rule_id => p_pick_grouping_rule_id,
                        p_carton_grouping_id => l_carton_grouping_id,
                        p_hdrRec => l_hdrRec,
                        p_linesRec => l_linesRec,
                        x_return_status => x_return_status,
                        x_msg_data => x_msg_data);

       if(x_return_status <> fnd_api.g_ret_sts_success) then
          raise FND_API.G_EXC_ERROR;
        end if;

        --we must do this check rather than supply types as a push component with a supply subinv provided only triggers a
        --sub transfer, not a wip issue
        if(l_linesRec.to_subinventory_code is null) then
          l_linesRec.transaction_type_id := l_issueTxnType;
        else
          l_linesRec.transaction_type_id := l_backflushTxnType;
        end if;
        /* Both issue and backflush lines will be stored in the same PLSQL table and INV API is called only once for both types. This change is as part of Enhancement#2578514*/
        /* Start Enhancement EAM source-subinventory project for 12.1*/

        if (p_wip_entity_type = l_eam) then
          l_linesRec.from_subinventory_code := l_subinv;
          l_linesRec.from_locator_id := l_locator;
        end if;

        /* End Enhancement EAM source-subinventory project for 12.1*/

        l_lineCount               := l_lineCount + 1;
        l_linesTable(l_lineCount) := l_linesRec;
      end LOOP; --end per component loop
      l_pickSetId := l_pickSetId + 1; --increment regardless
      --close per entity cursors
      if(c_rep%ISOPEN) then
        close c_rep;
      elsif(c_discJobs%ISOPEN) then
        close c_discJobs;
      elsif(c_eamwo%ISOPEN) then
        close c_eamwo;
      elsif(c_lotJobs%ISOPEN) then
        close c_lotJobs;
      else -- for flow, clear table that stores the results of explodeMultiLevel exploder.
        -- bug#3409239 Begin
        if l_opt_cnt > 0 then
          -- found an optimizable group of l_opt_cnt number of flow schedules
          -- add l_linesRec to l_linesTable 'l_opt_cnt' number of times
          l_lineCountHolder := l_lineCount;
          For h in 1..(l_opt_cnt-1) LOOP
            k := l_flowCompTbl.COUNT-1;
            LOOP
              if k < 0 then
                 exit;
              end if;
              l_linesRec := l_linesTable(l_lineCountHolder-k);
              l_linesRec.txn_source_id := p_alloc_tbl(i+h).wip_entity_id;
              -- required_date currently is not being passed in from picking form
              -- so must use the time truncated date of the first flow schedule
              -- in the optimized group
              --l_linesRec.date_required := p_alloc_tbl(i+h).required_date;
              l_linesRec.date_required := trunc(p_alloc_tbl(i).required_date);
              l_linesRec.ship_set_id := l_pickSetId+h;
              l_lineCount               := l_lineCount + 1;
              l_linesTable(l_lineCount) := l_linesRec;
              k := k-1;
            end LOOP;
          end LOOP;
          l_opt_cnt := l_opt_cnt-1;
        end if;
        -- bug#3409239 End

        l_flowCompTbl.delete;
      end if;
      <<END_OF_FOR_LOOP>>
      null;
    end loop; --end per entity loop

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log('wip_picking_pvt.allocate => line count passed to inv_wip_picking_pvt.release_pick_batch: '
                           || l_lineCount || ';total=' || p_alloc_tbl.COUNT, l_dummy2);
    end if;
    if(l_lineCount > 0) then
      l_hdrRec.move_order_type := INV_Globals.G_MOVE_ORDER_MFG_PICK;
      inv_wip_picking_pvt.release_pick_batch(p_mo_header_rec => l_hdrRec,
                                             p_mo_line_rec_tbl => l_linesTable,
                                             p_auto_detail_flag => nvl(p_auto_detail_flag,'T'),
                                             p_print_pick_slip => nvl(p_print_pick_slip,'F'),
                                             p_plan_tasks => nvl(p_plan_tasks,FALSE),
                                             x_conc_req_id => x_conc_req_id,
                                             x_return_status => l_pickStatus,
                                             x_msg_data => x_msg_data,
                                             x_msg_count => l_msgCount,
                                             p_init_msg_lst => fnd_api.g_true,
					     x_mo_line_errrec_tbl => x_MOLineErrTbl);
      fnd_file.put_line(which => fnd_file.log, buff => 'return status = ' ||l_pickStatus);

      if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.log('returned status from call to inv_wip_picking_pvt.release_pick_batch() = ' || l_pickStatus || ';total=' || p_alloc_tbl.COUNT,  l_dummy2);
      end if;

    --bugfix 4435437
    /* if thru srs, print the records that errored out and set the global variable so that we can
     set the request to warning. Decided to use global variable instead of a new parameter
     to avoid chain-dependencies. */

  if (nvl(fnd_global.CONC_REQUEST_ID, -1) <> -1) then
    if x_MOLineErrTbl.count > 0 then

      WIP_PICKING_PVT.g_PickRelease_Failed := TRUE;
      fnd_file.put_line(which => fnd_file.log, buff => 'The errored Records are as follows:');

      for i in x_MOLineErrTbl.FIRST..x_MOLineErrTbl.LAST
        loop
        if( x_MOLineErrTbl.exists(i) ) then
	  if x_MOLineErrTbl(i).txn_source_id = FND_API.G_MISS_NUM then
	    x_MOLineErrTbl(i).txn_source_id := null;
	  end if;
	  if x_MOLineErrTbl(i).txn_source_line_id = FND_API.G_MISS_NUM then
	    x_MOLineErrTbl(i).txn_source_line_id := null;
	  end if;
	  if x_MOLineErrTbl(i).inventory_item_id = FND_API.G_MISS_NUM then
	    x_MOLineErrTbl(i).inventory_item_id := null;
	  end if;
	  if x_MOLineErrTbl(i).reference_id = FND_API.G_MISS_NUM then
	    x_MOLineErrTbl(i).reference_id := null;
	  end if;
	  /* Bug 4917429 */
 	  if x_MOLineErrTbl(i).organization_id = FND_API.G_MISS_NUM then
 	    x_MOLineErrTbl(i).organization_id := null;
 	  end if;
	/* Fix for bug 4917429: Print job name and item number to make
	    the messages user-friendly */
  	  begin
	    select we.wip_entity_name, msi.concatenated_segments
	    into   l_jobname, l_item
	    from   wip_entities we, mtl_system_items_vl msi
	    where  we.wip_entity_id = x_MOLineErrTbl(i).txn_source_id
	    and    msi.inventory_item_id = x_MOLineErrTbl(i).inventory_item_id
	    and    msi.organization_id = x_MOLineErrTbl(i).organization_id;
	  exception
	    when NO_DATA_FOUND then
		 l_jobname := NULL;
		 l_item := NULL;
	  end;

       fnd_file.put_line(
               which => fnd_file.log,
               buff => 'Wip_Entity_Id:'        || x_MOLineErrTbl(i).txn_source_id ||
	       ' Job Name: '                   || l_jobName || /* Bug 4917429 */
               ' OpSeqNum: '                        || x_MOLineErrTbl(i).txn_source_line_id||
               ' Repetitve Schedule Id: '        || x_MOLineErrTbl(i).reference_id||
               ' Inventory Item Id : '                || x_MOLineErrTbl(i).inventory_item_id||
	        ' Item: '                       || l_item /* Bug 4917429 */);
       fnd_file.put_line(
               which => fnd_file.log,
               buff => '==>Error:'||x_MOLineErrTbl(i).error_message);
         end if;
      end loop;
        end if;
 end if; /* end of conc_req_id <> -1 condition */
  /*Fix for bug 8940535(FP 8557198), raise exception after error message are printed out in log*/
  if(l_pickStatus not in ('P','N', FND_API.G_RET_STS_SUCCESS)) then
        x_return_status := l_pickStatus;
        raise FND_API.G_EXC_ERROR;
  end if;
end if; /* end of l_lineCount > 0 */

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log('wip_picking_pvt.allocate => inv_wip_picking_pvt.release_pick_batch return_status='
                          || l_pickStatus, l_dummy2);
      wip_logger.log('wip_picking_pvt.allocate => inv_wip_picking_pvt.release_pick_batch return_msg='
                          || x_msg_data, l_dummy2);
    end if;

    if(nvl(p_print_pick_slip,'T') = 'T') then
      fnd_message.set_name('WIP','WIP_PICKING_PRINT_SLIP');
      fnd_message.set_token('REQ_NUMBER',x_conc_req_id);
      l_string2 := fnd_message.get;
    else
      l_string2 := ' ';
    end if;
    if((l_pickStatus = 'P') OR l_explodeStatus <> fnd_api.g_ret_sts_success) then --if either the issue or backflush partially allocated, or one or more flow assemblies' bill could not be exploded
      x_return_status := 'P';                         --return partial status
      fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
      fnd_message.set_token('MO_NUMBER',l_hdrRec.request_number);
      l_string1 := fnd_message.get;
      fnd_message.set_name('WIP', 'WIP_PICKING_PARTIAL_ALLOCATION');
      fnd_message.set_token('WIP_PICKING_MO_NUMBER', l_string1);
      fnd_message.set_token('WIP_PICKING_PRINT_SLIP', l_string2);
      x_msg_data := fnd_message.get;
    elsif (l_pickStatus = 'N') then
      -- 'N' could also result from l_lineCount = 0, and inv_wip_picking_pvt.release_pick_batch
      -- was never called
      x_return_status := 'N';
      fnd_message.set_name('WIP','WIP_PICKING_NO_ALLOCATION');
      x_msg_data := fnd_message.get;
    else
      x_return_status := fnd_api.g_ret_sts_success; --above ifs test for other return statuses from inv call
      fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
      fnd_message.set_token('MO_NUMBER',l_hdrRec.request_number);
      l_string1 := fnd_message.get;
      fnd_message.set_name('WIP','WIP_PICKING_SUCCESS_ALLOCATION');
      fnd_message.set_token('WIP_PICKING_MO_NUMBER', l_string1);
      fnd_message.set_token('WIP_PICKING_PRINT_SLIP', l_string2);
      x_msg_data := fnd_message.get;
    end if;
    x_mo_req_number := l_hdrRec.request_number;    /* Added as part of enhancement 2478446 */

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.cleanup(l_dummy2);
    end if;

  exception
    when FND_API.G_EXC_ERROR then --msg_data, return_status set by inventory calls
      -- ROLLBACK TO WIP_ALLOCATE_PVT_START;  -- Fix bug 4341138
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log(x_msg_data, l_dummy2);
        wip_logger.cleanup(l_dummy2);
      end if;
    when RECORDS_LOCKED then
      -- ROLLBACK TO WIP_ALLOCATE_PVT_START; -- Fix bug 4341138
      x_return_status := 'L';
      fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
      x_msg_data := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log(x_msg_data, l_dummy2);
        wip_logger.cleanup(l_dummy2);
      end if;
    when others then
      -- ROLLBACK TO WIP_ALLOCATE_PVT_START; -- Fix bug 4341138
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_picking_pvt.allocate: ' || SQLERRM);
      x_msg_data := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log(x_msg_data, l_dummy2);
        wip_logger.cleanup(l_dummy2);
      end if;
   end allocate;


   /* This procedure is called by allocate to update WRO and fill in header and lines record appropriately */
  procedure get_HdrLinesRec( p_wip_entity_id NUMBER,
                        p_project_id NUMBER,
                        p_task_id NUMBER,
                        p_wip_entity_type NUMBER,
                        p_repetitive_schedule_id NUMBER,
                        p_operation_seq_num NUMBER,
                        p_inventory_item_id NUMBER,
                        p_use_pickset_flag VARCHAR2,
                        p_pickset_id NUMBER,
                        p_open_qty NUMBER,
                        p_to_subinv VARCHAR2,
                        p_to_locator NUMBER,
                        p_default_subinv VARCHAR2,
                        p_default_locator NUMBER,
                        p_uom VARCHAR2  ,
                        p_supply_type NUMBER  ,
                        p_req_date DATE,
                        p_rev_control_code VARCHAR2 ,
                        p_organization_id NUMBER,
                        p_pick_grouping_rule_id NUMBER := NULL, /* Added as part of Enhancement#2578514*/
                        p_carton_grouping_id NUMBER := NULL,    /* Added as part of Enhancement#2578514*/
                        p_hdrRec IN OUT NOCOPY INV_MOVE_ORDER_PUB.Trohdr_Rec_Type,
                        p_linesRec IN OUT NOCOPY INV_MOVE_ORDER_PUB.Trolin_Rec_Type,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data OUT NOCOPY VARCHAR2)

IS

    l_sysDate DATE := sysdate;
    l_userId NUMBER := fnd_global.user_id;
    l_loginId NUMBER := fnd_global.login_id;
    l_lineStatus NUMBER := INV_Globals.G_TO_STATUS_PREAPPROVED;
    l_push NUMBER := wip_constants.push;
    l_pick_grouping_rule_id NUMBER;
    l_unit_number VARCHAR2(30);
BEGIN

   SAVEPOINT GET_HDR_LINES_START;
    x_msg_data := NULL;
    x_return_status := fnd_api.g_ret_sts_success;
    p_hdrRec.created_by := l_userId;
    p_hdrRec.creation_date := l_sysDate;
    p_hdrRec.last_updated_by := l_userId;
    p_hdrRec.last_update_date := l_sysDate;
    p_hdrRec.last_update_login := l_loginId;
    p_hdrRec.organization_id := p_organization_id;
    p_hdrRec.operation := INV_Globals.G_OPR_CREATE;
    p_hdrRec.header_status := INV_Globals.G_TO_STATUS_PREAPPROVED;
    p_linesRec.created_by := l_userId;
    p_linesRec.creation_date := l_sysDate;
    p_linesRec.last_updated_by := l_userId;
    p_linesRec.last_update_date := l_sysDate;
    p_linesRec.last_update_login := l_loginId;
    p_linesRec.organization_id := p_organization_id;
    p_linesRec.line_status := l_lineStatus;
    p_linesRec.operation :=  INV_Globals.G_OPR_CREATE;

    /* for EAM entity type, select picksilp grouping rule from wip_parameters. If no rule is defined, raise an exception with suitable message */
    if(p_wip_entity_type = wip_constants.eam) then

      select pickslip_grouping_rule_id
        into l_pick_grouping_rule_id
      from   wip_parameters
      where organization_id = p_organization_id;

      if(l_pick_grouping_rule_id IS NULL) then
        fnd_message.set_name('WIP','WIP_PICKING_EAM_PICKSLIP_ERROR');
        x_msg_data      := fnd_message.get;
        x_return_status := FND_API.G_RET_STS_ERROR;
        raise FND_API.G_EXC_ERROR;
      else
        p_hdrRec.grouping_rule_id := l_pick_grouping_rule_id;
      end if;
    else                                                     /* for other entity types, get the rule from the parameter passed to allocate() */
      p_hdrRec.grouping_rule_id := p_pick_grouping_rule_id;
    end if;

    /* moved to pre_allocate_material in wippckpb.pls per bug#2642679
        if(p_wip_entity_type in(wip_constants.repetitive,wip_constants.discrete,wip_constants.eam,wip_constants.lotbased)) then
          if(p_use_pickset_flag = 'N') then
            update wip_requirement_operations
               set quantity_backordered = p_open_qty,
                   last_update_date = l_sysDate,
                   last_updated_by = l_userId,
                   last_update_login = l_loginId
             where inventory_item_id = p_inventory_item_id
               and organization_id = p_organization_id
               and wip_entity_id = p_wip_entity_id
               and operation_seq_num = p_operation_seq_num;
          end if;
        end if;
     */

        p_linesRec.txn_source_id := p_wip_entity_id;
        p_linesRec.txn_source_line_id := p_operation_seq_num;
        p_linesRec.reference_id := p_repetitive_schedule_id;
        p_linesRec.date_required := p_req_date;
        if(p_wip_entity_type = wip_constants.eam) then
          p_linesRec.to_subinventory_code := NULL;
          p_linesRec.to_locator_id := NULL;
        elsif(p_supply_type = l_push) then --push
          p_linesRec.to_subinventory_code := p_to_subinv;
          p_linesRec.to_locator_id := p_to_locator;
        elsif(p_to_subinv is null) then
          p_linesRec.to_subinventory_code := p_default_subinv;
          p_linesRec.to_locator_id := p_default_locator;
        else
          p_linesRec.to_subinventory_code := p_to_subinv;
          p_linesRec.to_locator_id := p_to_locator;
        end if;
        p_linesRec.inventory_item_id := p_inventory_item_id;
        if(p_use_pickset_flag = 'Y') then
          p_linesRec.ship_set_id := p_pickset_id;
        else
           p_linesRec.ship_set_id := null;
        end if;
        p_linesRec.quantity := p_open_qty;
        p_linesRec.uom_code := p_uom;
        p_linesRec.carton_grouping_id := p_carton_grouping_id;  /* Added as part of Enhancement#2578514*/
        p_linesRec.project_id := p_project_id;
        p_linesRec.task_id := p_task_id;

        /* Fix for bug#3683053. get_revision call is commented out.
           Now WIP populate null revision in lines record
        if(p_rev_control_code = 2) then
        Fix for bug 3028470: Passing eco_status as 'EXCLUDE_OPEN_HOLD'
          to prevent unimplemented revisions from being transacted
          bom_revisions.get_revision(examine_type => 'ALL',
                                     eco_status   => 'EXCLUDE_OPEN_HOLD',
                                     org_id       => p_organization_id,
                                     item_id      => p_inventory_item_id,
                                     rev_date     => l_sysDate,
                                     itm_rev      => p_linesRec.revision);
        else
          p_linesRec.revision := null;
        end if;
       */
          p_linesRec.revision := null;
          /* Fix bug 8274922 set unit_number for Unit Effective Assembly */
          if (p_wip_entity_type = wip_constants.discrete) then
            select end_item_unit_number
            into l_unit_number
            from wip_discrete_jobs
            where wip_entity_id = p_wip_entity_id
            and organization_id = p_organization_id;

            if (l_unit_number is not null) then
            p_linesRec.unit_number := l_unit_number;
            end if;
          end if;

      exception

      when FND_API.G_EXC_ERROR then   /* return status and message_data are set at the place of raising this error */
      ROLLBACK TO GET_HDR_LINES_START;
      when others then
      ROLLBACK TO GET_HDR_LINES_START;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_picking_pvt.get_HdrLinesRec: ' || SQLERRM);
      x_msg_data := fnd_message.get;


end get_HdrLinesRec;


--this procedure is used for allocation of specific material

  procedure allocate_comp(p_alloc_comp_tbl IN OUT NOCOPY wip_picking_pub.allocate_comp_tbl_t,
                     p_days_to_alloc NUMBER DEFAULT NULL, --only used for rep scheds
                     p_auto_detail_flag VARCHAR2 DEFAULT NULL,
                     p_cutoff_date DATE,
                     p_wip_entity_type NUMBER,
                     p_organization_id NUMBER,
                     p_pick_grouping_rule_id NUMBER := NULL,
                     p_print_pick_slip VARCHAR2 DEFAULT NULL,
                     p_plan_tasks BOOLEAN DEFAULT NULL,
                     x_conc_req_id OUT NOCOPY NUMBER,
                     x_mo_req_number OUT NOCOPY VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2) IS
    l_lineCount NUMBER := 0;
    l_pickStatus VARCHAR2(1) := 'N';
    l_backflushStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_pickSetId NUMBER := 1;
    l_subinv VARCHAR2(10);
    l_locator NUMBER;
    l_uom VARCHAR2(4);
    l_supplyType NUMBER;
    l_openQty NUMBER;
    l_reqDate DATE;
    l_linesTable INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
    l_linesRec INV_MOVE_ORDER_PUB.Trolin_Rec_Type;
    l_hdrRec INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
    l_defaultSub VARCHAR2(10);
    l_defaultLocator NUMBER;
    l_disc NUMBER := wip_constants.discrete;
    l_eam NUMBER := wip_constants.eam;
    l_lotbased NUMBER := wip_constants.lotbased;
    l_repetitive NUMBER := wip_constants.repetitive;
    l_msgCount NUMBER;
    l_revControlCode VARCHAR2(3);
    l_backflushTxnType NUMBER := INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR;
    l_issueTxnType NUMBER := INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE;
    l_push NUMBER := wip_constants.push;
    l_carton_grouping_id NUMBER;
    TYPE carton_tbl_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    carton_tbl carton_tbl_t;
    l_string1 VARCHAR2(200);
    l_string2 VARCHAR2(200);
    x_MOLineErrTbl      INV_WIP_Picking_Pvt.Trolin_ErrTbl_type;                --bugfix 4435437
  BEGIN
    SAVEPOINT WIP_ALLOCATE_COMP_PVT_START;
    x_msg_data := null;

   select default_pull_supply_subinv, default_pull_supply_locator_id
      into l_defaultSub, l_defaultLocator
      from wip_parameters
     where organization_id = p_organization_id;

    for i in 1..p_alloc_comp_tbl.COUNT LOOP
      if(p_wip_entity_type = l_disc) then
        select (wro.required_quantity - wro.quantity_issued
                 - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                 -  wo.CUMULATIVE_SCRAP_QUANTITY*wro.QUANTITY_PER_ASSEMBLY) open_quantity,
                     wro.supply_subinventory,
                     wro.supply_locator_id,
                     msi.primary_uom_code,
                     wro.wip_supply_type,
                     wro.date_required,
                     msi.revision_qty_control_code

               into l_openQty,
                    l_subinv,
                    l_locator,
                    l_uom,
                    l_supplyType,
                    l_reqDate,
                    l_revControlCode

               from wip_requirement_operations wro, mtl_system_items_b msi, wip_operations wo
               where wro.wip_entity_id = p_alloc_comp_tbl(i).wip_entity_id
                 and ((p_cutoff_date is NULL) OR (wro.date_required < p_cutoff_date))
                 and (
                         (    'Y' = (select allocate_backflush_components
                                       from wip_parameters wp
                                      where organization_id = wro.organization_id)
                          and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                         )
                      or wro.wip_supply_type = wip_constants.push
                     )
                  and wro.required_quantity > (wro.quantity_issued +
                        nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                              WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0))
                  and wro.inventory_item_id = p_alloc_comp_tbl(i).inventory_item_id
                  and wro.inventory_item_id = msi.inventory_item_id
                  and wro.wip_entity_id = wo.wip_entity_id (+)
                  and wro.operation_seq_num = p_alloc_comp_tbl(i).operation_seq_num
                  and wro.operation_seq_num = wo.operation_seq_num (+)
                  and wro.organization_id = msi.organization_id
                  and wro.organization_id = p_organization_id
                  and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
                  for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;

      elsif(p_wip_entity_type = l_eam) then
        select (wro.required_quantity - wro.quantity_issued
                  -  nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                     WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                  -  wo.CUMULATIVE_SCRAP_QUANTITY*wro.QUANTITY_PER_ASSEMBLY) open_quantity,
                     wro.supply_subinventory,
                     wro.supply_locator_id,
                     msi.primary_uom_code,
                     wro.wip_supply_type,
                     wro.date_required,
                     msi.revision_qty_control_code

                into l_openQty,
                     l_subinv,
                     l_locator,
                     l_uom,
                     l_supplyType,
                     l_reqDate,
                     l_revControlCode

                from wip_requirement_operations wro, mtl_system_items_b msi, wip_operations wo
               where wro.wip_entity_id = p_alloc_comp_tbl(i).wip_entity_id
                  and ((p_cutoff_date is NULL) OR (wro.date_required < p_cutoff_date))
                  and wro.required_quantity > (wro.quantity_issued +
                      nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                       WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0))
                  and wro.inventory_item_id = p_alloc_comp_tbl(i).inventory_item_id
                  and wro.inventory_item_id = msi.inventory_item_id
                  and wro.wip_entity_id = wo.wip_entity_id (+)
                  and wro.operation_seq_num = p_alloc_comp_tbl(i).operation_seq_num
                  and wro.operation_seq_num = wo.operation_seq_num (+)
                  and wro.organization_id = msi.organization_id
                  and wro.organization_id = p_organization_id
                  and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
                  for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;

      elsif(p_wip_entity_type = l_lotbased) then
        select (((wo.quantity_in_queue + wo.quantity_running + wo.quantity_completed) * wro.quantity_per_assembly)
                        - wro.quantity_issued
                        - nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                               WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) open_quantity,
                     wro.supply_subinventory,
                     wro.supply_locator_id,
                     msi.primary_uom_code,
                     wro.wip_supply_type,
                     wro.date_required,
                     msi.revision_qty_control_code

                into  l_openQty,
                      l_subinv,
                      l_locator,
                      l_uom,
                      l_supplyType,
                      l_reqDate,
                      l_revControlCode

               from wip_requirement_operations wro, wip_operations wo, mtl_system_items_b msi
               where wro.wip_entity_id = p_alloc_comp_tbl(i).wip_entity_id
                 and wro.wip_entity_id = wo.wip_entity_id
                 and wro.operation_seq_num = p_alloc_comp_tbl(i).operation_seq_num
                 and wro.operation_seq_num = wo.operation_seq_num
                 and ((p_cutoff_date is NULL) OR (wro.date_required < p_cutoff_date))
                 and (
                         (    'Y' = (select allocate_backflush_components
                                       from wip_parameters wp
                                      where organization_id = wro.organization_id)
                          and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                         )
                      or wro.wip_supply_type = wip_constants.push
                     )
                  and ((wo.quantity_in_queue + wo.quantity_running + wo.quantity_completed) * wro.quantity_per_assembly) > (wro.quantity_issued +
                     nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                      WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0))
                  and wro.inventory_item_id = p_alloc_comp_tbl(i).inventory_item_id
                  and wro.inventory_item_id = msi.inventory_item_id
                  and wro.organization_id = msi.organization_id
                  and wro.organization_id = p_organization_id
                  and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
          for update of wro.quantity_allocated, wro.quantity_backordered, wro.quantity_issued nowait;
      elsif(p_wip_entity_type  = l_repetitive) then

         select least(  --open qty is the smaller of the remaining quantity and the quantity determined by the #days to allocate for
                       (wro.required_quantity - wro.quantity_issued
                           -  nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                              WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)
                           -  wo.CUMULATIVE_SCRAP_QUANTITY*wro. QUANTITY_PER_ASSEMBLY),
                       (wrs.daily_production_rate * wro.quantity_per_assembly * p_days_to_alloc) + nvl(wro.quantity_backordered, 0)) open_quantity,
                     wro.supply_subinventory,
                     wro.supply_locator_id,
                     msi.primary_uom_code,
                     wro.wip_supply_type,
                     wro.date_required,
                     msi.revision_qty_control_code

               into l_openQty,
                    l_subinv,
                    l_locator,
                    l_uom,
                    l_supplyType,
                    l_reqDate,
                    l_revControlCode

               from wip_requirement_operations wro,
                     wip_repetitive_schedules wrs,
                     mtl_system_items_b msi,
                     wip_operations wo
               where wro.repetitive_schedule_id = p_alloc_comp_tbl(i).repetitive_schedule_id
                 and wrs.repetitive_schedule_id = p_alloc_comp_tbl(i).repetitive_schedule_id
                 and ((p_cutoff_date is null) OR (wro.date_required < p_cutoff_date))
                 and (
                         (    'Y' = (select allocate_backflush_components
                                       from wip_parameters wp
                                      where organization_id = wro.organization_id)
                          and wro.wip_supply_type in (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull)
                         )
                      or wro.wip_supply_type = wip_constants.push
                     )
                  and wro.required_quantity > (wro.quantity_issued +
                      nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                       WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0))
                 and wro.inventory_item_id = p_alloc_comp_tbl(i).inventory_item_id
                 and wro.inventory_item_id = msi.inventory_item_id
                 and wro.organization_id = msi.organization_id
                 and wro.organization_id = p_organization_id
                 and wro.repetitive_schedule_id = wo.repetitive_schedule_id (+)
                 and wro.operation_seq_num = p_alloc_comp_tbl(i).operation_seq_num
                 and wro.operation_seq_num = wo.operation_seq_num (+)
                 and msi.mtl_transactions_enabled_flag = 'Y' /* fix for bug# 2468515 */
                 for update of wro.quantity_allocated, wro.quantity_backordered, quantity_issued nowait;

      end if;
             /* Carton grouping id should be same for all components of same entity. It should differ from entity to entity*/
             if(carton_tbl.EXISTS(p_alloc_comp_tbl(i).wip_entity_id)) then
             l_carton_grouping_id := carton_tbl(p_alloc_comp_tbl(i).wip_entity_id);
             else
             select wsh_delivery_group_s.nextval
             into  l_carton_grouping_id
             from dual;
             carton_tbl(p_alloc_comp_tbl(i).wip_entity_id) := l_carton_grouping_id;
             end if;

              get_HdrLinesRec( p_wip_entity_id => p_alloc_comp_tbl(i).wip_entity_id,
                        p_project_id => p_alloc_comp_tbl(i).project_id,
                        p_task_id => p_alloc_comp_tbl(i).task_id,
                        p_wip_entity_type => p_wip_entity_type,
                        p_repetitive_schedule_id => p_alloc_comp_tbl(i).repetitive_schedule_id,
                        p_operation_seq_num => p_alloc_comp_tbl(i).operation_seq_num,
                        p_inventory_item_id => p_alloc_comp_tbl(i).inventory_item_id,
                        p_use_pickset_flag => p_alloc_comp_tbl(i).use_pickset_flag,
                        p_pickset_id =>l_pickSetId,
                        p_open_qty => l_openQty,
                        p_to_subinv => l_subinv,
                        p_to_locator => l_locator,
                        p_default_subinv => l_defaultSub,
                        p_default_locator => l_defaultLocator,
                        p_uom => l_uom,
                        p_supply_type => l_supplyType,
                        p_req_date => l_reqDate,
                        p_rev_control_code =>l_revControlCode ,
                        p_organization_id => p_organization_id,
                        p_pick_grouping_rule_id => p_pick_grouping_rule_id,
                        p_carton_grouping_id => l_carton_grouping_id,
                        p_hdrRec => l_hdrRec,
                        p_linesRec => l_linesRec,
                        x_return_status => x_return_status,
                        x_msg_data => x_msg_data);
        if(x_return_status <> fnd_api.g_ret_sts_success) then
          raise FND_API.G_EXC_ERROR;
        end if;
        if (p_alloc_comp_tbl(i).requested_quantity IS NOT NULL) then
           if(p_alloc_comp_tbl(i).requested_quantity > l_linesRec.quantity) then /* Do not allow overpick */
           fnd_message.set_name('WIP','WIP_PICKING_OVERPICK_ERROR');
           x_msg_data      := fnd_message.get;
           x_return_status := FND_API.G_RET_STS_ERROR;
           raise FND_API.G_EXC_ERROR;
           else
             l_linesRec.quantity := p_alloc_comp_tbl(i).requested_quantity;
           end if;

        end if;

        l_linesRec.from_subinventory_code := p_alloc_comp_tbl(i).source_subinventory_code;
        l_linesRec.from_locator_id := p_alloc_comp_tbl(i).source_locator_id;
        l_linesRec.lot_number := p_alloc_comp_tbl(i).lot_number;
        l_linesRec.serial_number_start := p_alloc_comp_tbl(i).start_serial;
        l_linesRec.serial_number_end := p_alloc_comp_tbl(i).end_serial;

        --we must do this check rather than supply types as a push component with a supply subinv provided only triggers a
        --sub transfer, not a wip issue
        if(l_linesRec.to_subinventory_code is null) then
          l_linesRec.transaction_type_id := l_issueTxnType;
        else
          l_linesRec.transaction_type_id := l_backflushTxnType;
        end if;
        /* Both issue and backflush lines will stored in the same PLSQL table and INV API is called only once for both types. This change is as part of Enhancement#2578514*/
        l_lineCount               := l_lineCount + 1;
        l_linesTable(l_lineCount) := l_linesRec;
        l_pickSetId := l_pickSetId + 1; --increment regardless
    end loop;

    if(l_lineCount > 0) then
      l_hdrRec.move_order_type := INV_Globals.G_MOVE_ORDER_MFG_PICK;
      inv_wip_picking_pvt.release_pick_batch(p_mo_header_rec => l_hdrRec,
                                             p_mo_line_rec_tbl => l_linesTable,
                                             p_auto_detail_flag => nvl(p_auto_detail_flag,'T'),
                                             p_print_pick_slip => nvl(p_print_pick_slip,'F'),
                                             p_plan_tasks => nvl(p_plan_tasks,FALSE),
                                             x_conc_req_id => x_conc_req_id,
                                             x_return_status => l_pickStatus,
                                             x_msg_data => x_msg_data,
                                             x_msg_count => l_msgCount,
                                             p_init_msg_lst => fnd_api.g_true,
   				             x_mo_line_errrec_tbl => x_MOLineErrTbl);   --bugfix 4435437

      if(l_pickStatus not in ('P','N',FND_API.G_RET_STS_SUCCESS)) then
        x_return_status := l_pickStatus;
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;

    if(nvl(p_print_pick_slip,'T') = 'T') then
      fnd_message.set_name('WIP','WIP_PICKING_PRINT_SLIP');
      fnd_message.set_token('REQ_NUMBER',x_conc_req_id);
      l_string2 := fnd_message.get;
    else
      l_string2 := ' ';
    end if;

    if(l_pickStatus = 'P')  then --if either the issue or backflush partially allocated
      x_return_status := 'P';                         --return partial status
      fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
      fnd_message.set_token('MO_NUMBER',l_hdrRec.request_number);
      l_string1 := fnd_message.get;
      fnd_message.set_name('WIP', 'WIP_PICKING_PARTIAL_ALLOCATION');
      fnd_message.set_token('WIP_PICKING_MO_NUMBER', l_string1);
      fnd_message.set_token('WIP_PICKING_PRINT_SLIP', l_string2);
      x_msg_data := fnd_message.get;
    elsif (l_pickStatus = 'N') then
      -- 'N' could also result from l_lineCount = 0, and inv_wip_picking_pvt.release_pick_batch
      -- was never called
      x_return_status := 'N';
      fnd_message.set_name('WIP','WIP_PICKING_NO_ALLOCATION');
      x_msg_data := fnd_message.get;
    else
      x_return_status := fnd_api.g_ret_sts_success; --above ifs test for other return statuses from inv call
      fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
      fnd_message.set_token('MO_NUMBER',l_hdrRec.request_number);
      l_string1 := fnd_message.get;
      fnd_message.set_name('WIP','WIP_PICKING_SUCCESS_ALLOCATION');
      fnd_message.set_token('WIP_PICKING_MO_NUMBER', l_string1);
      fnd_message.set_token('WIP_PICKING_PRINT_SLIP', l_string2);
      x_msg_data := fnd_message.get;
    end if;
    x_mo_req_number := l_hdrRec.request_number;    /* Added as part of enhancement 2478446 */
  exception
    when FND_API.G_EXC_ERROR then --msg_data, return_status set by inventory calls
      ROLLBACK TO WIP_ALLOCATE_COMP_PVT_START;
    when RECORDS_LOCKED then
      ROLLBACK TO WIP_ALLOCATE_COMP_PVT_START;
      x_return_status := 'L';
      fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
      x_msg_data := fnd_message.get;
    when others then
      ROLLBACK TO WIP_ALLOCATE_COMP_PVT_START;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_picking_pvt.allocate: ' || SQLERRM);
      x_msg_data := fnd_message.get;
  end allocate_comp;

  --this version is used in the concurrent request
  --note the commit at the end of this procedure
  procedure allocate(errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     p_wip_entity_type NUMBER,
                     p_job_type NUMBER DEFAULT 4,   /*Bug 5932126 (FP of 5880558): Added one new parameter for job type*/
                     p_days_forward NUMBER,
                     p_organization_id NUMBER,
                     p_use_pickset_indicator NUMBER,
                     p_pick_grouping_rule_id NUMBER := NULL, /* Added as part of Enhancement#2578514*/
                     p_print_pickslips NUMBER DEFAULT NULL,   /* lookup code is 1 for default YES. This parameter is added as part of Enhancement#2578514*/
                     p_plan_tasks NUMBER DEFAULT NULL,         /* lookup code is 2 for default NO. This parameter is added as part of Enhancement#2578514*/
                     p_days_to_alloc NUMBER := NULL)    --only used for rep scheds
  IS


   /* Modified the cursor c_jobs for to improve performance of Component Pick Release for bug 8472970(FP 8263887)*/
  CURSOR c_jobs is
    select we.wip_entity_id,
         we.wip_entity_name,
         wdj.project_id,
         wdj.task_id
    from wip_entities we,
         wip_discrete_jobs wdj,
         wip_parameters wp
   where we.wip_entity_id = wdj.wip_entity_id
     and we.organization_id = wdj.organization_id
     and wp.organization_id = wdj.organization_id
     and wp.organization_id = we.organization_id
     and we.entity_type = 1
     and wdj.status_type in (3,4)
     and wdj.job_type = decode(p_job_type, 4, wdj.job_type, p_job_type) /*Bug 5932126 (FP of 5880558): Added to check job type*/
     and we.organization_id = p_organization_id
     and exists(
     select 1
     from wip_requirement_operations wro,
     wip_operations wo
   where we.wip_entity_id = wro.wip_entity_id
     and we.organization_id = wro.organization_id
     and wro.wip_entity_id = wo.wip_entity_id(+)
     and wro.operation_seq_num = wo.operation_seq_num(+)
     and (wo.count_point_type in (1,2) or wo.count_point_type is null)
     and wro.required_quantity > wro.quantity_issued  /*Bug 7447655 (FP of 7495308) Fix*/
     and ( ( wp.allocate_backflush_components = 'Y' and wro.wip_supply_type in (1,2,3) ) or ( ( wp.allocate_backflush_components = 'N' or wp.allocate_backflush_components is null )
     and wro.wip_supply_type = 1 ) )
     and wro.date_required < sysdate + p_days_forward)
 order by we.wip_entity_name;



    CURSOR c_lotjobs is
    select distinct we.wip_entity_id,
                    we.wip_entity_name,
                    wdj.project_id,
                    wdj.task_id
      from wip_entities we,
           wip_discrete_jobs wdj,
           wip_requirement_operations wro,
           wip_parameters wp,
           wip_operations wo
     where wo.wip_entity_id = we.wip_entity_id
       and wo.operation_seq_num = wro.operation_seq_num
       and we.wip_entity_id = wdj.wip_entity_id
       and we.entity_type = 5
       and wdj.status_type in (3,4)
       and wro.wip_entity_id = we.wip_entity_id
       and wp.organization_id = we.organization_id
       and (wo.quantity_in_queue + quantity_running +
               wo.quantity_waiting_to_move + wo.quantity_rejected +
               wo.quantity_scrapped + wo.quantity_completed) *
                  wro.quantity_per_assembly > wro.quantity_issued
                          + nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                            WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED), 0)
       and (
               (    wp.allocate_backflush_components = 'Y'
                and wro.wip_supply_type in (1,2,3)
               )
            or (
                    (wp.allocate_backflush_components = 'N' or wp.allocate_backflush_components is null)
                and wro.wip_supply_type = 1
               )
           )
       and wro.date_required < sysdate + p_days_forward
       and we.organization_id = p_organization_id
     order by we.wip_entity_name;

   CURSOR c_rep is
   select distinct we.wip_entity_id,
          (wl.line_code || ':' || msik.concatenated_segments || ':' || wrs.first_unit_start_date ) title,
          wrs.repetitive_schedule_id
     from wip_entities we,
          mtl_system_items_kfv msik,
          wip_repetitive_schedules wrs,
          wip_repetitive_items wri,
          wip_requirement_operations wro,
          wip_parameters wp,
          wip_lines wl,
          wip_operations wo
    where we.wip_entity_id = wrs.wip_entity_id
      and wrs.repetitive_schedule_id = wro.repetitive_schedule_id
      and we.wip_entity_id = wri.wip_entity_id
      and we.primary_item_id = msik.inventory_item_id
      and wrs.status_type in (3,4)
      and wrs.line_id = wl.line_id
      and wri.line_id = wl.line_id
      and msik.organization_id = we.organization_id
      and wro.wip_entity_id = we.wip_entity_id
      and wp.organization_id = we.organization_id
      and wro.wip_entity_id = wo.wip_entity_id (+)
      and wro.repetitive_schedule_id = wo.repetitive_schedule_id (+)
      and wro.operation_seq_num = wo.operation_seq_num(+)
      and (wo.count_point_type in (1,2) or wo.count_point_type is null)
      and wro.required_quantity > (wro.quantity_issued +
                      nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                                       WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID,  WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0))
      and ( ( wp.allocate_backflush_components = 'Y' and wro.wip_supply_type in (1,2,3) ) or ( ( wp.allocate_backflush_components = 'N' or wp.allocate_backflush_components is null ) and wro.wip_supply_type = 1 ) )
      and wro.date_required < sysdate + p_days_forward
      and we.organization_id = p_organization_id
 order by title;

    /* BugFix 6964780: Modified the query */
    CURSOR c_flow is
      select wip_entity_id,
             (line_code || ':' || primary_item_id || ':' || schedule_number) title,
             project_id,
             task_id
        from wip_flow_open_allocations_v
       where scheduled_start_date < sysdate + p_days_forward
         and organization_id = p_organization_id
       order by title;

    l_wipEntityID NUMBER;
    l_repSchedID NUMBER;
    l_projectID NUMBER;
    l_taskID NUMBER;
    i NUMBER := 0;
    l_allocTbl wip_picking_pub.allocate_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_msgData VARCHAR2(2000);
    l_picksetFlag VARCHAR2(1);
    l_outBuffer VARCHAR2(240);
    l_conc_req_id NUMBER;
    l_msgCount NUMBER := 0;
    l_mo_req_number VARCHAR2(30);
    l_print_pickslips varchar2(1);
    l_plan_tasks   BOOLEAN;

    BEGIN

    retcode := 0;
    savepoint wip_allocate_concurrent;

    if(p_wip_entity_type = wip_constants.discrete) then
      open c_jobs;
    elsif(p_wip_entity_type = wip_constants.lotbased) then
      open c_lotjobs;
    elsif(p_wip_entity_type = wip_constants.repetitive) then
      open c_rep;
    else
      open c_flow;
    end if;

    if(p_use_pickset_indicator = 2) then
      l_picksetFlag := 'N';
    else
      l_picksetFlag := 'Y';
    end if;
    if((p_print_pickslips IS NULL) OR (p_print_pickslips = 1)) then
      l_print_pickslips:= 'T';
    else
      l_print_pickslips:='F';
    end if;

    if (p_plan_tasks = 1) then
      l_plan_tasks:= TRUE;
    else
      l_plan_tasks:= FALSE;
    end if;

    fnd_message.set_name('FND', 'CONC-PARAMETERS');
    fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);


    select meaning
      into l_outBuffer
      from mfg_lookups
     where lookup_type = 'SYS_YES_NO'
       and lookup_code = p_use_pickset_indicator;

    fnd_message.set_name('WIP', 'WIP_PICKING_USE_PICKSETS');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);
    /* Added as part of Enhancement#2578514*/
    select meaning
      into l_outBuffer
      from mfg_lookups
     where lookup_type = 'SYS_YES_NO'
       and lookup_code = p_print_pickslips;

    fnd_message.set_name('WIP', 'WIP_PICKING_PRINT_PICKSLIPS');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);
    /* Added as part of Enhancement#2578514*/
    if(p_pick_grouping_rule_id IS NOT NULL) then
    select name
      into l_outBuffer
      from wsh_pick_grouping_rules
    where pick_grouping_rule_id = p_pick_grouping_rule_id;

    fnd_message.set_name('WIP', 'WIP_PICKING_PICK_GROUPING_RULE');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);
    end if;

     /* Added as part of Enhancement#2578514*/
    select meaning
      into l_outBuffer
      from mfg_lookups
     where lookup_type = 'SYS_YES_NO'
       and lookup_code = p_plan_tasks;

    fnd_message.set_name('WIP', 'WIP_PICKING_PLAN_TASKS');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);

/* Fixed bug 4890898 Changed table from org_organization_definitions to MTL_PARAMETERS  */
    select organization_code
      into l_outBuffer
      from MTL_PARAMETERS
     where organization_id = p_organization_id;

    fnd_message.set_name('WIP', 'WIP_PICKING_ORG');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);

    fnd_message.set_name('WIP', 'WIP_PICKING_DAYS_FORWARD');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || p_days_forward);

    select meaning
      into l_outBuffer
      from mfg_lookups
     where lookup_type = 'WIP_ENTITY'
       and lookup_code = p_wip_entity_type;

    fnd_message.set_name('WIP', 'WIP_PICKING_MFG_MODE');
    fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);

    /* Bug 6046963: Added below if to print job type parameter in case of Discrete Job Comp Pick Release request only*/
    if(p_wip_entity_type = wip_constants.discrete) then
            /*Start - Bug 5932126 (FP of 5880558): Added following code to print new parameter for job type*/
            select meaning
              into l_outBuffer
              from mfg_lookups
            where lookup_type = 'WIP_ENTITIES'
            and   lookup_code = p_job_type ;

            fnd_message.set_name('WIP', 'WIP_PICKING_JOB_TYPE');
            fnd_file.put_line(which => fnd_file.output, buff => '  ' || fnd_message.get || ' ' || l_outBuffer);
            /*End - Bug 5932126 (FP of 5880558): Added code to print new parameter for job type*/
    end if;

    fnd_file.put_line(which => fnd_file.output, buff => '');
    fnd_file.put_line(which => fnd_file.output, buff => '');

    LOOP
      if(p_wip_entity_type = wip_constants.discrete) then
        fetch c_jobs into l_wipEntityID, l_outBuffer, l_projectID, l_taskID;
        exit when c_jobs%NOTFOUND;
      elsif(p_wip_entity_type = wip_constants.lotbased) then
        fetch c_lotjobs into l_wipEntityID, l_outBuffer, l_projectID, l_taskID;
        exit when c_lotjobs%NOTFOUND;
      elsif(p_wip_entity_type = wip_constants.repetitive) then
        fetch c_rep into l_wipEntityID, l_outBuffer, l_repSchedID;
        exit when c_rep%NOTFOUND;
      else
        fetch c_flow into l_wipEntityID, l_outBuffer, l_projectID, l_taskID;
        exit when c_flow%NOTFOUND;
      end if;
      fnd_file.put_line(which => fnd_file.output, buff => l_outBuffer);
      i := i + 1;
      l_allocTbl(i).wip_entity_id := l_wipEntityID;
      l_allocTbl(i).repetitive_schedule_id := l_repSchedID;
      l_allocTbl(i).project_id := l_projectID;
      l_allocTbl(i).task_id := l_taskID;
      l_allocTbl(i).use_pickset_flag := l_picksetFlag;
    end loop;

    if(c_jobs%ISOPEN) then
      close c_jobs;
    elsif(c_lotjobs%ISOPEN) then
      close c_lotjobs;
    elsif(c_rep%ISOPEN) then
      close c_rep;
    elsif(c_flow%ISOPEN) then
      close c_flow;
    end if;

    fnd_file.put_line(which => fnd_file.output, buff => 'Total job count: ' || i);
    if(i > 0) then
      allocate(p_alloc_tbl => l_allocTbl,
               p_days_to_alloc => p_days_to_alloc, --not null only for rep scheds
               p_cutoff_date => sysdate + p_days_forward,
               p_wip_entity_type => p_wip_entity_type,
               p_organization_id => p_organization_id,
               p_pick_grouping_rule_id => p_pick_grouping_rule_id,  /* Added as part of Enhancement#2578514*/
               p_print_pick_slip => l_print_pickslips,              /* Added as part of Enhancement#2578514*/
               p_plan_tasks      => l_plan_tasks,                   /* Added as part of Enhancement#2578514*/
               x_conc_req_id => l_conc_req_id,
               x_mo_req_number => l_mo_req_number,
               x_return_status => l_returnStatus,
               x_msg_data => errbuf);

     if(l_returnStatus = 'P') then
        fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
        fnd_message.set_token('MO_NUMBER',l_mo_req_number);
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        fnd_message.set_name('WIP', 'WIP_PICKING_PARTIAL_ALLOC_CONC');
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        if(l_print_pickslips = 'T') then
          fnd_message.set_name('WIP','WIP_PICKING_PRINT_SLIP');
          fnd_message.set_token('REQ_NUMBER',l_conc_req_id);
          fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        end if;

      elsif(l_returnStatus = 'S') then
        fnd_message.set_name('WIP','WIP_PICKING_MO_NUMBER');
        fnd_message.set_token('MO_NUMBER',l_mo_req_number);
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        if(l_print_pickslips = 'T') then
          fnd_message.set_name('WIP','WIP_PICKING_PRINT_SLIP');
          fnd_message.set_token('REQ_NUMBER',l_conc_req_id);
          fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        end if;
        fnd_message.set_name('WIP', 'WIP_TXN_COMPLETED');
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);

      elsif(l_returnStatus = 'N') then
        fnd_message.set_name('WIP','WIP_PICKING_NO_ALLOCATION_CONC');
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);

      else
        fnd_file.put_line(which => fnd_file.output, buff => '');
        fnd_message.set_name('WIP', 'ERROR_DIALOG_TITLE');
        fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
        fnd_file.put_line(which => fnd_file.output,
                          buff => 'Returned status: ' || l_returnStatus);
        fnd_file.put_line(which => fnd_file.output,
                          buff => 'Returned message: ' || errbuf);
        fnd_file.put_line(which => fnd_file.output,
                          buff => 'Parameters passed to allocate():');
        fnd_file.put_line(which => fnd_file.output, buff => 'p_days_to_alloc='  ||
              p_days_to_alloc || ';p_days_forward=' || p_days_forward ||
              ';p_wip_entity_type=' || p_wip_entity_type || ';p_organization_id=' ||
              p_organization_id || ';p_pick_grouping_rule_id=' || p_pick_grouping_rule_id
              || ';l_print_pickslips=' || l_print_pickslips );
    end if;
   end if;
   /*bugfix 4435437: set the process to warning if failed */
   if (WIP_PICKING_PVT.g_PickRelease_Failed = TRUE) then
      retcode := 1 ;
   end if;
    commit;
  exception
    when others then
      errbuf := SQLERRM;
      retcode := 2;
      fnd_file.put_line(which => fnd_file.output, buff => '');
      fnd_file.put_line(which => fnd_file.output, buff => '');
      fnd_message.set_name('WIP', 'ERROR_DIALOG_TITLE');
      fnd_file.put_line(which => fnd_file.output, buff => fnd_message.get);
      for i in 1..l_msgCount loop
        fnd_file.put_line(which => fnd_file.output, buff => fnd_msg_pub.get(p_msg_index => l_msgCount - i + 1, p_encoded => fnd_api.g_false));
      end loop;
      rollback to wip_allocate_concurrent;
  end allocate;


   /**
   * Explodes an item's bom and returns the components in a pl/sql table
   * p_organization_id  The organization.
   * p_assembly_item_id The assembly.
   * p_alt_option  2 if an exact match to the alternate bom designator is necessary
   *               1 if the alternate is not found, the main bom will be used.
   * p_assembly_qty  Qty to explode. Pass a negative value for returns.
   * p_alt_bom_desig  The alternate bom designator if one was provided. Null otherwise.
   * p_rev_date  The date of the transaction. This is used to retrieve the correct bom.
   */
  procedure explodeMultiLevel(p_organization_id NUMBER,
                              p_assembly_item_id NUMBER,
                              p_alt_option NUMBER,
                              p_assembly_qty NUMBER,
                              p_alt_bom_desig VARCHAR2,
                              p_rev_date DATE,
                              p_project_id NUMBER,
                              p_task_id NUMBER,
                              p_to_op_seq_num NUMBER,
                              p_alt_rout_desig VARCHAR2,
                              x_comp_sql_tbl OUT NOCOPY wip_picking_pub.allocate_comp_tbl_t,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2) IS
  l_comp_sys_rec SYSTEM.WIP_COMPONENT_OBJ_T;
  l_comp_sys_table SYSTEM.WIP_COMPONENT_TBL_T;
  l_comp_sql_rec wip_picking_pub.allocate_comp_rec_t;
  i NUMBER;
  j NUMBER;
  begin

     wip_flowUtil_priv.explodeRequirementsAndDefault(p_assyID => p_assembly_item_id,
                                          p_orgID           => p_organization_id,
                                          p_qty             => p_assembly_qty,
                                          p_altBomDesig     => p_alt_bom_desig,
                                          p_altOption       => p_alt_option,
                                          p_txnDate         => p_rev_date,
					  p_implFlag        => 1,
                                          p_projectID       => p_project_id,
                                          p_taskID          => p_task_id,
                                          p_toOpSeqNum      => p_to_op_seq_num,
                                          p_altRoutDesig    => p_alt_rout_desig,
         /* fix for bug 4538135*/         p_txnFlag         => true, /*  ER 4369064 */
                                          x_compTbl         => l_comp_sys_table,
                                          x_returnStatus    => x_return_status);

    if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        wip_utilities.get_message_stack(p_msg => x_msg_data,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_true);
        return;
    end if;

    i := l_comp_sys_table.FIRST;  -- get subscript of first element
    j := 1;
    WHILE i IS NOT NULL LOOP
      l_comp_sys_rec := l_comp_sys_table(i);
      --all to pl/sql table
      if (l_comp_sys_rec.wip_supply_type = wip_constants.push) then
        l_comp_sql_rec.operation_seq_num := l_comp_sys_rec.operation_seq_num ;
        l_comp_sql_rec.inventory_item_id := l_comp_sys_rec.inventory_item_id ;
        l_comp_sql_rec.requested_quantity := l_comp_sys_rec.primary_quantity ;
        l_comp_sql_rec.source_subinventory_code := l_comp_sys_rec.supply_subinventory ;
        l_comp_sql_rec.source_locator_id := l_comp_sys_rec.supply_locator_id ;
        l_comp_sql_rec.revision := l_comp_sys_rec.revision;
        l_comp_sql_rec.primary_uom_code := l_comp_sys_rec.primary_uom_code;
        l_comp_sql_rec.item_name:= l_comp_sys_rec.item_name;
        if(round(abs(l_comp_sys_rec.primary_quantity), WIP_CONSTANTS.INV_MAX_PRECISION) <> 0) then
          x_comp_sql_tbl(j) := l_comp_sql_rec;
          j := j+1;
        end if;
      end if;
      i := l_comp_sys_table.NEXT(i);  -- get subscript of next element
    END LOOP;

  end explodeMultiLevel;

 Procedure Post_Explosion_CleanUp(p_wip_entity_id in number,
             p_repetitive_schedule_id in NUMBER DEFAULT NULL,
             p_org_id in NUMBER,
             x_return_status OUT NOCOPY VARCHAR2,
             x_msg_data OUT NOCOPY VARCHAR2  ) IS
        l_supply_subinventory VARCHAR2(30) := NULL;
        l_supply_locator_id NUMBER := NULL;
        l_operation_seq_num NUMBER;
        l_resource_seq_num NUMBER;
        l_dummy2 VARCHAR2(1);
        l_logLevel number;

        CURSOR c_disc_operations(v_wip_entity_id NUMBER, v_organization_id NUMBER) IS
          select unique operation_seq_num
          from wip_requirement_operations
          where wip_entity_id = v_wip_entity_id
            and organization_id = v_organization_id
            and wip_supply_type in (wip_constants.op_pull, wip_constants.assy_pull);

        CURSOR c_rep_operations(v_wip_entity_id NUMBER, v_repetitive_schedule_id NUMBER,
                        v_organization_id NUMBER) IS
          select unique operation_seq_num
          from wip_requirement_operations
          where wip_entity_id = v_wip_entity_id
            and organization_id = v_organization_id
            and repetitive_schedule_id = v_repetitive_schedule_id
            and wip_supply_type in (wip_constants.op_pull, wip_constants.assy_pull);
  Begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_logLevel := fnd_log.g_current_runtime_level;
        if (l_logLevel <= wip_constants.trace_logging) then
           wip_logger.log('In wip_picking_pvt.Post_Explosion_CleanUp():'
                        || p_wip_entity_id || ':' || p_org_id
                        || ':' || p_repetitive_schedule_id, l_dummy2);
        end if;

        If (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
           Open c_disc_operations(p_wip_entity_id, p_org_id);
        Else
           Open c_rep_operations(p_wip_entity_id, p_repetitive_schedule_id, p_org_id);
        End if;

        LOOP
        l_supply_subinventory := null;
        l_supply_locator_id := null;

        If (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
          fetch c_disc_operations into l_operation_seq_num;
          exit when c_disc_operations%NOTFOUND;

          begin
            select br1.supply_subinventory, br1.supply_locator_id
              into l_supply_subinventory, l_supply_locator_id
            from bom_resources br1, wip_operation_resources wor1
            where br1.resource_id =  wor1.resource_id
              and br1.organization_id = wor1.organization_id
              and wor1.wip_entity_id = p_wip_entity_id
               and wor1.organization_id = p_org_id
               and wor1.operation_seq_num = l_operation_seq_num
               and wor1.resource_seq_num =
                   (select min(wor2.resource_seq_num)
                    from bom_resources br2, wip_operation_resources wor2
                    where wor2.wip_entity_id = wor1.wip_entity_id
                       and wor2.organization_id= wor1.organization_id
                       and wor2.operation_seq_num =  wor1.operation_seq_num
                       and br2.supply_subinventory is not null
                       and br2.organization_id = wor2.organization_id
                       and br2.resource_id =  wor2.resource_id
                       and br2.resource_type= 1);   -- machine type
          exception
            when no_data_found then
               null;
          end;

          if (l_supply_subinventory is not null) then
             wip_picking_pub.Update_Requirement_SubinvLoc(p_wip_entity_id => p_wip_entity_id,
                            p_repetitive_schedule_id => p_repetitive_schedule_id,
                            p_operation_seq_num => l_operation_seq_num,
                            p_supply_subinventory => l_supply_subinventory,
                            p_supply_locator_id => l_supply_locator_id,
                            x_return_status => x_return_status,
                            x_msg_data => x_msg_data);

              if (x_return_status <> fnd_api.g_ret_sts_success) then
                if (l_logLevel <= wip_constants.trace_logging) then
                  wip_logger.log('wip_picking_pvt.Post_Explosion_CleanUp: ' ||
                      'wip_picking_pub.Update_Requirement_SubinvLoc failed..', l_dummy2);
                end if;
                Return;
              End if;
          end if;
        else

          fetch c_rep_operations into l_operation_seq_num;
          exit when c_rep_operations%NOTFOUND;

          begin
            select br1.supply_subinventory, br1.supply_locator_id
              into l_supply_subinventory, l_supply_locator_id
            from bom_resources br1, wip_operation_resources wor1
            where br1.resource_id =  wor1.resource_id
              and br1.organization_id = wor1.organization_id
              and wor1.wip_entity_id = p_wip_entity_id
               and wor1.repetitive_schedule_id = p_repetitive_schedule_id
               and wor1.organization_id = p_org_id
               and wor1.operation_seq_num = l_operation_seq_num
               and wor1.resource_seq_num =
                   (select min(wor2.resource_seq_num)
                    from bom_resources br2, wip_operation_resources wor2
                    where wor2.wip_entity_id = wor1.wip_entity_id
                       and wor2.organization_id= wor1.organization_id
                       and wor2.operation_seq_num =  wor1.operation_seq_num
                       and br2.supply_subinventory is not null
                       and br2.organization_id = wor2.organization_id
                       and br2.resource_id =  wor2.resource_id
                       and br2.resource_type= 1);   -- machine type
          exception
            when no_data_found then
               null;
          end;

          if l_supply_subinventory is not null then
             wip_picking_pub.Update_Requirement_SubinvLoc(p_wip_entity_id => p_wip_entity_id,
                            p_repetitive_schedule_id => p_repetitive_schedule_id,
                            p_operation_seq_num => l_operation_seq_num,
                            p_supply_subinventory => l_supply_subinventory,
                            p_supply_locator_id => l_supply_locator_id,
                            x_return_status => x_return_status,
                            x_msg_data => x_msg_data);

            if (x_return_status <> fnd_api.g_ret_sts_success) then
                if (l_logLevel <= wip_constants.trace_logging) then
                   wip_logger.log('wip_picking_pvt.Post_Explosion_CleanUp: ' ||
                      'wip_picking_pub.Update_Requirement_SubinvLoc failed..', l_dummy2);
                end if;
                Return;
            End if;
          end if;
        end if;

      End Loop;

      if(c_disc_operations%ISOPEN) then
                close c_disc_operations;
      elsif(c_rep_operations%ISOPEN) then
                close c_rep_operations;
      end if;

  EXCEPTION
    when RECORDS_LOCKED then
      x_return_status := 'L';
      fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
      x_msg_data := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log( x_msg_data, l_dummy2);
        wip_logger.cleanup(l_dummy2);
      end if;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'WIP_EXPLODER_UTITLITIES.Post_Explosion_CleanUp:'
                     || SQLERRM);
      x_msg_data := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log( x_msg_data, l_dummy2);
        wip_logger.cleanup(l_dummy2);
      end if;
  End Post_Explosion_CleanUp;


end wip_picking_pvt;

/

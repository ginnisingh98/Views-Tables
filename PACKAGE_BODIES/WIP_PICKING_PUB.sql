--------------------------------------------------------
--  DDL for Package Body WIP_PICKING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PICKING_PUB" as
 /* $Header: wippckpb.pls 120.4.12010000.2 2009/06/24 19:21:41 hliew ship $ */

   /* This procedure is callback for INV to set backorder qty in WRO, and should only be called
      for all but flow */
   procedure pre_allocate_material(p_wip_entity_id in NUMBER,
                              p_operation_seq_num in NUMBER,
                              p_inventory_item_id in NUMBER,
                              p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                              p_use_pickset_flag in VARCHAR2, -- null is no,
                              p_allocate_quantity in NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2) IS

     l_entityType NUMBER;
     l_sysDate DATE := sysdate;
     l_userId NUMBER := fnd_global.user_id;
     l_loginId NUMBER := fnd_global.login_id;

  begin

    SAVEPOINT WIP_PRE_ALLOC_MATERIAL_START;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select entity_type
      into l_entityType
    from wip_entities
    where wip_entity_id = p_wip_entity_id;

    if(l_entityType = wip_constants.flow) then --flow schedule
        return;
    end if;

    --for repetitive, lot-based and discrete...
    if(p_repetitive_schedule_id IS NULL) then
      if(p_use_pickset_flag = 'N') then
        update wip_requirement_operations
        set quantity_backordered = p_allocate_quantity,
                   last_update_date = l_sysDate,
                   last_updated_by = l_userId,
                   last_update_login = l_loginId
        where inventory_item_id = p_inventory_item_id
               and wip_entity_id = p_wip_entity_id
               and operation_seq_num = p_operation_seq_num;
      end if;
    else
      if(p_use_pickset_flag = 'N') then
         update wip_requirement_operations
         set quantity_backordered = p_allocate_quantity,
                   last_update_date = l_sysDate,
                   last_updated_by = l_userId,
                   last_update_login = l_loginId
         where inventory_item_id = p_inventory_item_id
               and wip_entity_id = p_wip_entity_id
               and repetitive_schedule_id = p_repetitive_schedule_id
               and operation_seq_num = p_operation_seq_num;
      end if;
    end if;

    exception
      when RECORDS_LOCKED then
        ROLLBACK TO WIP_PRE_ALLOC_MATERIAL_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
      when others then
        ROLLBACK TO WIP_PRE_ALLOC_MATERIAL_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.pre_allocate_material: ' || SQLERRM);
        x_msg_data := fnd_message.get;

  end pre_allocate_material;

  procedure issue_material(p_wip_entity_id in NUMBER,
                           p_operation_seq_num in NUMBER,
                           p_inventory_item_id in NUMBER,
                           p_repetitive_line_id in NUMBER DEFAULT NULL,
                           p_transaction_id in NUMBER DEFAULT NULL,
                           p_primary_quantity in NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_data OUT NOCOPY VARCHAR2) IS
    l_entityType NUMBER;
    l_status NUMBER;
    l_statusCode VARCHAR2(80);
    l_rmnQty NUMBER;
    l_allocQty NUMBER;
    l_updQty NUMBER;
    l_repSchedID NUMBER;

    cursor c_rep is
        SELECT WRO.REPETITIVE_SCHEDULE_ID,
               WRO.ORGANIZATION_ID,
               WRO.ROWID,
               LEAST(GREATEST((WRO.REQUIRED_QUANTITY - WRO.QUANTITY_ISSUED), 0),
--                      nvl(wro.quantity_allocated, 0)) open_quantity,
                 nvl(wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM, WRO.ORGANIZATION_ID,
                   WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID, WRO.QUANTITY_ISSUED),0)) open_quantity,
--               wro.quantity_allocated
               wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM, WRO.ORGANIZATION_ID,
                 WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID,WRO.QUANTITY_ISSUED) quantity_allocated
          FROM WIP_REQUIREMENT_OPERATIONS WRO,
               WIP_REPETITIVE_SCHEDULES WRS
         WHERE WRO.WIP_ENTITY_ID = p_wip_entity_id
           AND WRO.INVENTORY_ITEM_ID = p_inventory_item_id
           AND WRO.OPERATION_SEQ_NUM = p_operation_seq_num
           AND WRS.REPETITIVE_SCHEDULE_ID = WRO.REPETITIVE_SCHEDULE_ID
           AND WRS.ORGANIZATION_ID = wro.organization_id
           AND WRS.WIP_ENTITY_ID = p_wip_entity_id
           AND WRS.LINE_ID = p_repetitive_line_id
           AND WRS.STATUS_TYPE in (3,4)
         ORDER BY WRS.FIRST_UNIT_START_DATE
         for update of wro.quantity_issued, wro.quantity_allocated;

    begin
      SAVEPOINT WIP_ISSUE_MATERIAL_START;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      select entity_type
        into l_entityType
        from wip_entities
       where wip_entity_id = p_wip_entity_id;

      if(l_entityType <> wip_constants.REPETITIVE) then
        select wdj.status_type
          into l_status
          from wip_discrete_jobs wdj, wip_requirement_operations wro
         where wdj.wip_entity_id = p_wip_entity_id
           and wro.wip_entity_id = wdj.wip_entity_id
           and wro.inventory_item_id = p_inventory_item_id
           and wro.operation_seq_num = p_operation_seq_num
           and wro.wip_supply_type = 1
           for update of wro.quantity_issued, wro.quantity_allocated nowait;

        if(l_status NOT IN (3,4)) then
          select meaning
            into l_statusCode
            from mfg_lookups
           where lookup_type = 'WIP_JOB_STATUS'
             and lookup_code = l_status;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        --up issued
        --lower allocated
        update wip_requirement_operations
           set quantity_issued = quantity_issued - p_primary_quantity,
               quantity_allocated = greatest(0, quantity_allocated + p_primary_quantity)
         where wip_entity_id = p_wip_entity_id
           and operation_seq_num = p_operation_seq_num
           and inventory_item_id = p_inventory_item_id
           and wip_supply_type = 1; -- a push component

      else --repetitive schedules
        l_rmnQty := -1 * p_primary_quantity;
        FOR l_rec in c_rep loop
          if(l_rmnQty > l_rec.open_quantity) then
            l_updQty := l_rec.open_quantity;
            l_rmnQty := l_rmnQty - l_rec.open_quantity;
          else
           l_updQty := l_rmnQty;
           l_rmnQty := 0;
          end if;
          update wip_requirement_operations
             set quantity_issued = quantity_issued + l_updQty,
                 quantity_allocated = greatest(0, quantity_allocated - l_updQty)
           where repetitive_schedule_id = l_rec.repetitive_schedule_id
             and operation_seq_num = p_operation_seq_num
             and inventory_item_id = p_inventory_item_id
             and wip_supply_type = 1; -- a push component

          insert into mtl_material_txn_allocations(
              transaction_id,
              repetitive_schedule_id,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              primary_quantity,
              transaction_quantity,
              transaction_date)
            values(
              p_transaction_id,
              l_rec.repetitive_schedule_id,
              l_rec.organization_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              -1 * round(l_updQty, 6),
              -1 * round(l_updQty, 6),
              sysdate);

          exit when l_rmnQty = 0;
          l_repSchedID := l_rec.repetitive_schedule_id;
        end loop;
        if(l_rmnQty > 0) then
          --apply remaining qty to last open schedule
          update wip_requirement_operations
             set quantity_issued = quantity_issued + l_rmnQty,
                 quantity_allocated = 0
           where repetitive_schedule_id = l_repSchedID
             and operation_seq_num = p_operation_seq_num
             and inventory_item_id = p_inventory_item_id
             and wip_supply_type = 1; -- a push component

          update mtl_material_txn_allocations
             set primary_quantity = primary_quantity - ROUND(l_rmnQty, 6),
                 transaction_quantity = transaction_quantity - ROUND(l_rmnQty, 6)
           where repetitive_schedule_id = l_repSchedID
             and transaction_id = p_transaction_id;
        end if;
      end if;
    exception
      when NO_DATA_FOUND then
        ROLLBACK TO WIP_ISSUE_MATERIAL_START;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('WIP', 'WIP_NO_PUSH_REQUIREMENT');
        x_msg_data := fnd_message.get;
      when RECORDS_LOCKED then
        ROLLBACK TO WIP_ISSUE_MATERIAL_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
      when FND_API.G_EXC_UNEXPECTED_ERROR then
        ROLLBACK TO WIP_ISSUE_MATERIAL_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_PICKING_STATUS_ERROR');
        fnd_message.set_token('STATUS', l_statusCode);
        x_msg_data := fnd_message.get;
      when others then
        ROLLBACK TO WIP_ISSUE_MATERIAL_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.issue_material: ' || SQLERRM);
        x_msg_data := fnd_message.get;
  end issue_material;

  procedure allocate_material(p_wip_entity_id in NUMBER,
                              p_operation_seq_num in NUMBER,
                              p_inventory_item_id in NUMBER,
                              p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                              p_primary_quantity in NUMBER,
                              x_quantity_allocated out nocopy NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2) IS
     l_rowid ROWID;
     l_backordered NUMBER;
     l_allocated NUMBER;
     l_entityType NUMBER;
     l_flow VARCHAR2(1);
     l_openQty NUMBER;
    begin
      SAVEPOINT WIP_ALLOCATE_MATERIAL_START;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_quantity_allocated := 0;

      select entity_type
        into l_entityType
        from wip_entities
       where wip_entity_id = p_wip_entity_id;
      if(l_entityType = wip_constants.flow) then --flow schedule
        select allocated_flag
          into l_flow
          from wip_flow_schedules
         where wip_entity_id = p_wip_entity_id
           for update of allocated_flag nowait; --set error code if row is locked

        update wip_flow_schedules
           set allocated_flag = 'Y'
         where wip_entity_id = p_wip_entity_id;
        return;
      end if;
      --for repetitive, lot-based and discrete...
      if(p_repetitive_schedule_id IS NULL) then
        select nvl(quantity_allocated, 0),
               nvl(quantity_backordered,0),
               p_primary_quantity,
               -- above line replaces line below. quantity_allocated() is not equivalent
               -- to wro.quantity_allocated column in this case. And the former was
               -- used to replace the latter. The difference is the api is already
               -- updated with the current pick release, and the column still shows
               -- qty allocate before the current pick release.
               /*least(greatest(required_quantity - quantity_issued - nvl(
                   quantity_allocated(WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
                                      INVENTORY_ITEM_ID, QUANTITY_ISSUED),0), 0),
                 p_primary_quantity), */
               rowid
          into l_allocated,
               l_backordered,
               l_openQty,
               l_rowid
          from wip_requirement_operations
         where wip_entity_id = p_wip_entity_id
           and operation_seq_num = p_operation_seq_num
           and inventory_item_id = p_inventory_item_id
         for update of quantity_backordered, quantity_allocated nowait;
      else
               select nvl(quantity_allocated, 0),
               nvl(quantity_backordered,0),
               p_primary_quantity,
               -- above line replaces line below. quantity_allocated() is not equivalent
               -- to wro.quantity_allocated column in this case. And the former was
               -- used to replace the latter. The difference is the api is already
               -- updated with the current pick release, and the column still shows
               -- qty allocate before the current pick release.
               /*least(greatest(required_quantity - quantity_issued - nvl(
                   quantity_allocated(WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
                                      INVENTORY_ITEM_ID, QUANTITY_ISSUED),0), 0),
                 p_primary_quantity), */
               rowid
          into l_allocated,
               l_backordered,
               l_openQty,
               l_rowid
          from wip_requirement_operations
         where wip_entity_id = p_wip_entity_id
           and operation_seq_num = p_operation_seq_num
           and inventory_item_id = p_inventory_item_id
           and repetitive_schedule_id = p_repetitive_schedule_id
         for update of quantity_backordered, quantity_allocated nowait;
      end if;

      x_quantity_allocated := l_openQty;

      --if unallocating, make sure you are unallocating less than or equal to
      --what has been allocated

      /* Comment out following for Bug#5962196. Quantity_allocated will be zero
         when components are issued to a job manually in stead of transacting move
         order line. Following condition will raise error while backordering line
      */

      -- if((p_primary_quantity < 0) and ((p_primary_quantity * -1) > l_allocated)) then
      --  raise fnd_api.G_EXC_UNEXPECTED_ERROR;
      -- end if;

      if(p_primary_quantity > l_backordered) then
        update wip_requirement_operations
           set quantity_backordered = 0,
               quantity_allocated = l_allocated + l_openQty
         where rowid = l_rowid;
      else
        /* Fix for Bug#5962196. Added decode */
        update wip_requirement_operations
           set quantity_backordered = l_backordered - l_openQty,
               quantity_allocated =   decode(sign(l_allocated + l_openQty), -1, l_allocated, 0,
                                                0,
                                                (l_allocated + l_openQty))
         where rowid = l_rowid;
      end if;
    exception
      when NO_DATA_FOUND then
        x_quantity_allocated := 0;
      when fnd_api.G_EXC_UNEXPECTED_ERROR then
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_PICKING_DEALLOCATE_ERROR');
        x_msg_data := fnd_message.get;
      when RECORDS_LOCKED then
        ROLLBACK TO WIP_ALLOCATE_MATERIAL_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
      when others then
        ROLLBACK TO WIP_ALLOCATE_MATERIAL_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.allocate_material: ' || SQLERRM);
        x_msg_data := fnd_message.get;
  end allocate_material;

  procedure unallocate_material(p_wip_entity_id in NUMBER,
                                p_operation_seq_num in NUMBER,
                                p_inventory_item_id in NUMBER,
                                p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                                p_primary_quantity in NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY VARCHAR2) is
       l_quantityAllocated NUMBER; --dummy
     begin
     --can just call allocate material w/a negative quantity
     allocate_material(p_wip_entity_id => p_wip_entity_id,
                       p_operation_seq_num => p_operation_seq_num,
                       p_inventory_item_id => p_inventory_item_id,
                       p_repetitive_schedule_id => p_repetitive_schedule_id,
                       p_primary_quantity => (-1) * p_primary_quantity,
                       x_quantity_allocated => l_quantityAllocated,
                       x_return_status => x_return_status,
                       x_msg_data => x_msg_data);
  end unallocate_material;


  procedure cancel_allocations(p_wip_entity_id NUMBER,
                               p_wip_entity_type NUMBER,
                               p_repetitive_schedule_id NUMBER DEFAULT NULL,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2) IS
  BEGIN
     wip_picking_pvt.cancel_allocations(p_wip_entity_id => p_wip_entity_id,
                               p_wip_entity_type => p_wip_entity_type,
                               p_repetitive_schedule_id => p_repetitive_schedule_id,
                               x_return_status => x_return_status,
                               x_msg_data => x_msg_data);
  END cancel_allocations;




  Procedure cancel_comp_allocations(p_wip_entity_id NUMBER,
		     p_operation_seq_num NUMBER,
		     p_inventory_item_id NUMBER,
                     p_wip_entity_type NUMBER,
                     p_repetitive_schedule_id NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2) IS
  BEGIN
      wip_picking_pvt.cancel_comp_allocations(p_wip_entity_id => p_wip_entity_id,
		                 p_operation_seq_num => p_operation_seq_num,
		                 p_inventory_item_id => p_inventory_item_id,
                                 p_wip_entity_type => p_wip_entity_type,
                                 p_repetitive_schedule_id => p_repetitive_schedule_id,
                                 x_return_status => x_return_status,
                                 x_msg_data => x_msg_data);
  END cancel_comp_allocations;


   procedure reduce_comp_allocations(p_comp_tbl IN allocate_comp_tbl_t,
                               p_wip_entity_type NUMBER,
                               p_organization_id NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2) IS
  BEGIN
    wip_picking_pvt.reduce_comp_allocations(p_comp_tbl => p_comp_tbl,
                               p_wip_entity_type => p_wip_entity_type,
                               p_organization_id => p_organization_id,
                               x_return_status => x_return_status,
                               x_msg_data => x_msg_data);
  END reduce_comp_allocations;


   procedure allocate(p_alloc_tbl IN OUT NOCOPY allocate_tbl_t,
                     p_days_to_alloc NUMBER := NULL, --only used for rep scheds
                     p_auto_detail_flag VARCHAR2 DEFAULT NULL,
                     p_start_date DATE DEFAULT NULL,
                     p_cutoff_date DATE,
                     p_operation_seq_num_low NUMBER DEFAULT NULL,
                     p_operation_seq_num_high NUMBER DEFAULT NULL,
                     p_wip_entity_type NUMBER,
                     p_organization_id NUMBER,
                     p_pick_grouping_rule_id NUMBER := NULL,
                     p_print_pick_slip VARCHAR2 DEFAULT NULL,
                     p_plan_tasks BOOLEAN DEFAULT NULL,
                     x_conc_req_id OUT NOCOPY NUMBER,
                     x_mo_req_number OUT NOCOPY VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2) IS
  BEGIN
    wip_picking_pvt.allocate(p_alloc_tbl => p_alloc_tbl,
                     p_days_to_alloc => p_days_to_alloc,
                     p_auto_detail_flag => p_auto_detail_flag,
                     p_start_date => p_start_date,
                     p_cutoff_date => p_cutoff_date,
                     p_operation_seq_num_low => p_operation_seq_num_low,
                     p_operation_seq_num_high => p_operation_seq_num_high,
                     p_wip_entity_type => p_wip_entity_type,
                     p_organization_id => p_organization_id,
                     p_pick_grouping_rule_id => p_pick_grouping_rule_id,
                     p_print_pick_slip => p_print_pick_slip,
                     p_plan_tasks => p_plan_tasks,
                     x_conc_req_id => x_conc_req_id,
                     x_mo_req_number => x_mo_req_number,
                     x_return_status => x_return_status,
                     x_msg_data => x_msg_data);
  END  allocate;



  procedure allocate_comp(p_alloc_comp_tbl IN OUT NOCOPY allocate_comp_tbl_t,
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
  BEGIN
    wip_picking_pvt.allocate_comp(p_alloc_comp_tbl => p_alloc_comp_tbl,
                     p_days_to_alloc => p_days_to_alloc, --only used for rep scheds
                     p_auto_detail_flag => p_auto_detail_flag,
                     p_cutoff_date => p_cutoff_date,
                     p_wip_entity_type => p_wip_entity_type,
                     p_organization_id => p_organization_id,
                     p_pick_grouping_rule_id => p_pick_grouping_rule_id,
                     p_print_pick_slip => p_print_pick_slip,
                     p_plan_tasks => p_plan_tasks,
                     x_conc_req_id => x_conc_req_id,
                     x_mo_req_number => x_mo_req_number,
                     x_return_status => x_return_status,
                     x_msg_data => x_msg_data);
  END allocate_comp;


  /*
   This function replaces the quantity_allocated column in WRO.
   Note: for pull components:
         l_quantity_allocated := l_mtrl_quantity - l_quantity_issued
       but when calculating open_quantity:
         open_qty = required_quantity - quantity_issued -  Quantity_Allocated()
       so, the quantity_issued cancels and is not considered for open_qty
   */
  Function quantity_allocated(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
                              p_repetitive_schedule_id IN NUMBER DEFAULT NULL,
                              p_quantity_issued IN NUMBER DEFAULT NULL)
    return NUMBER
  is
    l_quantity_allocated number;
    l_mtrl_quantity number;
    l_quantity_issued number := NULL;
    l_txn_type_id number;
    l_dummy2 VARCHAR2(1);
    l_wro_quantity_allocated number := 0 ; /* 5468293 */
    l_dummy  number := 0 ; /* 5468293 */
  begin
      begin
        -- Modified Query for performance bug 8561606 (FP 8523754).
        select mtrl.transaction_type_id
        into l_txn_type_id
        from MTL_TXN_REQUEST_LINES mtrl
        where
          mtrl.TXN_SOURCE_ID = p_wip_entity_id and
          mtrl.TXN_SOURCE_LINE_ID = p_operation_seq_num and
          mtrl.organization_id = p_organization_id and
          mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
          rownum = 1;
      exception
        when TOO_MANY_ROWS then
          wip_logger.log('Error occured in wip_picking_pub.quantity_allocated():', l_dummy2);
          wip_logger.log('   Inconsistent transaction_type_id in rows of MTRL table!', l_dummy2);
        -- Bug 5336791. saugupta 17th-Jun-2006
        -- When calling wip_picking_pub.quantity_allocated for a newly released
        -- repetitive schedule for which no component picking move order lines exist,
        -- it is throwing a NO_DATA_FOUND exception.
        when NO_DATA_FOUND then
          wip_logger.log('Function wip_picking_pub.quantity_allocated(): No data found', l_dummy2);
          return 0;
      end;

      l_quantity_issued := p_quantity_issued;
      if l_quantity_issued is null then
         select quantity_issued into l_quantity_issued
         from WIP_REQUIREMENT_OPERATIONS
         where wip_entity_id = p_wip_entity_id
           and operation_seq_num = p_operation_seq_num
           and repetitive_schedule_id  = p_repetitive_schedule_id
           and organization_id = p_organization_id
           and inventory_item_id = p_inventory_item_id;
       end if;

      begin
        if (l_txn_type_id = INV_GLOBALS.G_TYPE_XFER_ORDER_WIP_ISSUE) then
          select sum(nvl(mtrl.quantity,0) - nvl(mtrl.quantity_delivered,0))
             into l_quantity_allocated
          from MTL_TXN_REQUEST_LINES mtrl
          where
            mtrl.TXN_SOURCE_ID = p_wip_entity_id and
            mtrl.TXN_SOURCE_LINE_ID = p_operation_seq_num and
            ( p_repetitive_schedule_id is null or
              mtrl.reference_id = p_repetitive_schedule_id) and
            mtrl.organization_id = p_organization_id and
            mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
            -- preapproved status or open lines
            mtrl.line_status = INV_GLOBALS.G_TO_STATUS_PREAPPROVED
          group by mtrl.organization_id, mtrl.TXN_SOURCE_ID,
            mtrl.TXN_SOURCE_LINE_ID, mtrl.INVENTORY_ITEM_ID;
        else
          select sum(nvl(mtrl.quantity,0))
           into l_mtrl_quantity
          from MTL_TXN_REQUEST_LINES mtrl
          where
            mtrl.TXN_SOURCE_ID = p_wip_entity_id and
            mtrl.TXN_SOURCE_LINE_ID = p_operation_seq_num and
            ( p_repetitive_schedule_id is null or
               mtrl.reference_id = p_repetitive_schedule_id) and
            mtrl.organization_id = p_organization_id and
            mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
            mtrl.line_status in (INV_GLOBALS.G_TO_STATUS_CLOSED,
                 INV_GLOBALS.G_TO_STATUS_PREAPPROVED) -- preapproved or closed
          group by mtrl.organization_id, mtrl.TXN_SOURCE_ID,
            mtrl.TXN_SOURCE_LINE_ID, mtrl.INVENTORY_ITEM_ID;

	/*   Start for the Fix for Bug#5468293.
             Check for Cross Docking.
             backorder_deliver_detail_id is wip_entity_id for cross dock.
             However Operation info is not populated in mtrl.
             Hence get it from WRO.
        */
          begin

            select 1
            into l_dummy
            from dual
            where exists
             ( select 1
             from MTL_TXN_REQUEST_LINES mtrl
             where
              mtrl.backorder_delivery_detail_id = p_wip_entity_id and
              mtrl.TXN_SOURCE_LINE_ID is null and
              ( p_repetitive_schedule_id is null or
               mtrl.reference_id = p_repetitive_schedule_id) and
             mtrl.crossdock_type = 2 and -- WIP
             mtrl.organization_id = p_organization_id and
             mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
             mtrl.line_status in (INV_GLOBALS.G_TO_STATUS_CLOSED,
                 INV_GLOBALS.G_TO_STATUS_PREAPPROVED)) ;  -- preapproved or closed

            select quantity_allocated
            into   l_wro_quantity_allocated
            from   wip_requirement_operations
            where  wip_entity_id = p_wip_entity_id
            and    inventory_item_id = p_inventory_item_id
            and    operation_seq_num = p_operation_seq_num
            and    organization_id = p_organization_id
            and    nvl(repetitive_schedule_id, -1 ) = nvl(p_repetitive_schedule_id, -1) ;


	    l_mtrl_quantity := l_wro_quantity_allocated ;

           exception
		when no_data_found then
		     l_wro_quantity_allocated := 0 ;
           end ;
           /* End for the #5468293 */

          l_quantity_allocated := l_mtrl_quantity - l_quantity_issued;
        end if;
      exception
        when NO_DATA_FOUND then
          l_quantity_allocated := 0;
      end;

      return l_quantity_allocated;
  end;


  function Is_Component_Pick_Released(p_wip_entity_id in number,
                     p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                     p_org_id in NUMBER,
                     p_operation_seq_num in NUMBER,
                     p_inventory_item_id in NUMBER) return BOOLEAN IS
  l_dummy NUMBER := 0;
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;

  Begin
        if (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
           begin
		Select 1 Into l_dummy
                from wip_requirement_operations
		Where wip_entity_id = p_wip_entity_id
                  And Organization_id = p_org_id
                  And operation_seq_num = p_operation_seq_num
                  And inventory_item_id = nvl(p_inventory_item_id, inventory_item_id)
                  And quantity_backordered is not null;
           exception
                when no_data_found then
                	null;
           end;
	Else
           begin
		Select 1 Into l_dummy
                from wip_requirement_operations
		Where wip_entity_id = p_wip_entity_id
                  And repetitive_schedule_id = p_repetitive_schedule_id
                  And Organization_id = p_org_id
                  And operation_seq_num = p_operation_seq_num
                  And inventory_item_id = nvl(p_inventory_item_id, inventory_item_id)
                  And quantity_backordered is not null;
           exception
                when no_data_found then
                	null;
           end;
	End if;

        return (l_dummy = 1);

  EXCEPTION
    when others then
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.Is_Component_Pick_Released: ' || SQLERRM);
      raise fnd_api.g_exc_unexpected_error;

  End Is_Component_Pick_Released;

  Function Is_Job_Pick_Released(p_wip_entity_id in number,
                   p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                   p_org_id in NUMBER) RETURN BOOLEAN IS
  l_dummy NUMBER := 0;
  Begin

        if (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
           begin
		Select 1 Into l_dummy
		From dual
		Where exists
			(select 1
                         from wip_requirement_operations
		         Where wip_entity_id = p_wip_entity_id
				And Organization_id = p_org_id
				And quantity_backordered is not null);
           exception
                when no_data_found then
                	null;
           end;
	Else
           begin
                Select 1 Into l_dummy
		From dual
		Where exists
			(select 1
                         from wip_requirement_operations
                         Where wip_entity_id = p_wip_entity_id
				And repetitive_schedule_id = p_repetitive_schedule_id
				And Organization_id = p_org_id
				And quantity_backordered is not null);
           exception
                when no_data_found then
                	null;
           end;
	End if;
        Return( l_dummy = 1);
  EXCEPTION
    when others then
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_picking_pub.Is_Job_Pick_Released: ' || SQLERRM);
      raise fnd_api.g_exc_unexpected_error;
  End Is_Job_Pick_Released;

  Procedure Update_Requirement_SubinvLoc(p_wip_entity_id number,
                 p_repetitive_schedule_id in NUMBER DEFAULT NULL,
		 p_operation_seq_num in NUMBER,
                 p_supply_subinventory in VARCHAR2,
                 p_supply_locator_id in NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2) IS
     l_entityType NUMBER;
     l_sysDate DATE := sysdate;
     l_userId NUMBER := fnd_global.user_id;
     l_loginId NUMBER := fnd_global.login_id;

Begin
    SAVEPOINT WIP_UPDATE_REQ_SUBINVLOC_START;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --for repetitive, lot-based and discrete...
    if (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
	   update wip_requirement_operations
           set supply_subinventory = p_supply_subinventory,
               supply_locator_id = p_supply_locator_id
           where wip_entity_id = p_wip_entity_id
              and operation_seq_num = p_operation_seq_num
              and wip_supply_type in
                   (wip_constants.assy_pull, wip_constants.op_pull);
    else
	   update wip_requirement_operations
           set supply_subinventory = p_supply_subinventory,
               supply_locator_id = p_supply_locator_id
           where wip_entity_id = p_wip_entity_id
              and operation_seq_num = p_operation_seq_num
              and p_repetitive_schedule_id = p_repetitive_schedule_id
              and wip_supply_type in
                  (wip_constants.assy_pull, wip_constants.op_pull);
    end if;

    exception
    when no_data_found then
        null;
    when RECORDS_LOCKED then
        ROLLBACK TO WIP_UPDATE_REQ_SUBINVLOC_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
    when others then
        ROLLBACK TO WIP_UPDATE_REQ_SUBINVLOC_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT',
              'wip_utilities.Update_Requirement_SubinvLoc: ' || SQLERRM);
        x_msg_data := fnd_message.get;
  End Update_Requirement_SubinvLoc;

  Procedure Update_Component_BackOrdQty(p_wip_entity_id number,
                 p_repetitive_schedule_id in NUMBER DEFAULT NULL,
		 p_operation_seq_num in  NUMBER,
                 p_new_component_qty in NUMBER,
                 p_inventory_item_id in NUMBER DEFAULT NULL,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2) IS
     l_entityType NUMBER;
     l_sysDate DATE := sysdate;
     l_userId NUMBER := fnd_global.user_id;
     l_loginId NUMBER := fnd_global.login_id;
     l_dummy VARCHAR2(1);
  Begin
    SAVEPOINT WIP_COMP_BACKORDQTY_START;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select entity_type
      into l_entityType
    from wip_entities
    where wip_entity_id = p_wip_entity_id;

    If (l_entityType = wip_constants.flow) then
       Return;
    End if;

    --for repetitive, lot-based and discrete...
    if (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
	   Update wip_requirement_operations wro
           set quantity_backordered = GREATEST(p_new_component_qty
-- replaced wro.quantity_allocated with function quantity_allocated
--                             - quantity_issued - quantity_allocated , 0)
               - quantity_issued - wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                     WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID,QUANTITY_ISSUED) , 0)
           where wip_entity_id = p_wip_entity_id
              and operation_seq_num = p_operation_seq_num
              and inventory_item_id = NVL(p_inventory_item_id, inventory_item_id)
              and (
                    ('Y' = (select allocate_backflush_components from wip_parameters wp
                             where organization_id = wro.organization_id)
                       and wip_supply_type in
                         (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull))
                    or wip_supply_type = wip_constants.push
             	  );
    else
	   Update wip_requirement_operations wro
           set quantity_backordered = GREATEST(p_new_component_qty
-- replaced wro.quantity_allocated with function quantity_allocated
--                             - quantity_issued - quantity_allocated , 0)
               - quantity_issued - wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                     WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID,QUANTITY_ISSUED) , 0)
           where wip_entity_id=p_wip_entity_id
           and operation_seq_num=p_operation_seq_num
           and p_repetitive_schedule_id = p_repetitive_schedule_id
           and inventory_item_id = NVL(p_inventory_item_id, inventory_item_id)
           and (
                 ('Y' = (select allocate_backflush_components
                               from wip_parameters wp
                              where organization_id = wro.organization_id)
                      and wip_supply_type in
                          (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull))
                 or wip_supply_type = wip_constants.push
               );
    end if;

    exception
    when RECORDS_LOCKED then
        ROLLBACK TO WIP_COMP_BACKORDQTY_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
    when others then
        ROLLBACK TO WIP_COMP_BACKORDQTY_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_private.Update_Component_BackOrdQty: '
                                 || SQLERRM);
        x_msg_data := fnd_message.get;
    End Update_Component_BackOrdQty;

    Procedure Update_Job_BackOrdQty(p_wip_entity_id number,
                            p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                            p_new_job_qty in NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data OUT NOCOPY VARCHAR2) IS
     l_entityType NUMBER;
     l_sysDate DATE := sysdate;
     l_userId NUMBER := fnd_global.user_id;
     l_loginId NUMBER := fnd_global.login_id;
    Begin
    SAVEPOINT WIP_JOB_BACKORDQTY_START;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select entity_type
      into l_entityType
    from wip_entities
    where wip_entity_id = p_wip_entity_id;

    If (l_entityType = wip_constants.flow) then
       Return;
    End if;

    --for repetitive, lot-based and discrete
    if (p_repetitive_schedule_id is null or p_repetitive_schedule_id = 0) then
	   Update wip_requirement_operations wro
           set quantity_backordered = GREATEST(p_new_job_qty* quantity_per_assembly -
                   wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID, QUANTITY_ISSUED)
                   - quantity_issued, 0)
           where wip_entity_id=p_wip_entity_id
             and quantity_backordered is not null
             and (
               ('Y' = (select allocate_backflush_components
                               from wip_parameters wp
                              where organization_id = wro.organization_id)
                  and wip_supply_type in
                        (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull))
                or wip_supply_type = wip_constants.push
               );
    else
	   Update wip_requirement_operations wro
           set quantity_backordered = GREATEST(p_new_job_qty* quantity_per_assembly
                    - wip_picking_pub.quantity_allocated(WRO.WIP_ENTITY_ID, WRO.OPERATION_SEQ_NUM,
                        WRO.ORGANIZATION_ID, WRO.INVENTORY_ITEM_ID, WRO.REPETITIVE_SCHEDULE_ID,QUANTITY_ISSUED)
                    - quantity_issued, 0)
           where wip_entity_id=p_wip_entity_id
             and repetitive_schedule_id = p_repetitive_schedule_id
             and quantity_backordered is not null
             and (
                   ('Y' = (select allocate_backflush_components
                           from wip_parameters wp
                           where organization_id = wro.organization_id)
                             and wro.wip_supply_type in
                               (wip_constants.push, wip_constants.op_pull, wip_constants.assy_pull))
                  or wro.wip_supply_type = wip_constants.push
             	  ) ;
    end if;

    exception
    when RECORDS_LOCKED then
        ROLLBACK TO WIP_JOB_BACKORDQTY_START;
        x_return_status := 'L';
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        x_msg_data := fnd_message.get;
      when others then
        ROLLBACK TO WIP_JOB_BACKORDQTY_START;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', 'wip_picking_private.Update_Job_BackOrdQty: '
                                                   || SQLERRM);
        x_msg_data := fnd_message.get;
    End Update_Job_BackOrdQty;

end wip_picking_pub;

/

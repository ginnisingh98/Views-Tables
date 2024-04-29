--------------------------------------------------------
--  DDL for Package WIP_PICKING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PICKING_PUB" AUTHID CURRENT_USER as
 /* $Header: wippckps.pls 120.1.12000000.1 2007/01/18 22:19:35 appldev ship $ */

  type allocate_rec_t IS RECORD(wip_entity_id NUMBER,
                                repetitive_schedule_id NUMBER, --only populated for rep schedules
                                use_pickset_flag VARCHAR2(1),
                                project_id NUMBER,
                                task_id NUMBER,
                                bill_seq_id NUMBER, --these 2 are only populated for flow schedules if
                                bill_org_id NUMBER, --the schedule has been exploded in the bom_explosions table
                                required_date DATE,
                                alt_rtg_dsg VARCHAR2(10));

  type allocate_tbl_t IS TABLE OF allocate_rec_t INDEX BY BINARY_INTEGER;

  /* ER 4378835: Increased length of lot_number from 30 to 80 to support OPM Lot-model changes */
  type allocate_comp_rec_t IS RECORD(wip_entity_id NUMBER,
                                     repetitive_schedule_id NUMBER,
                                     use_pickset_flag VARCHAR2(1),
                                     project_id NUMBER,
                                     task_id NUMBER,
                                     operation_seq_num NUMBER,
                                     inventory_item_id NUMBER,
                                     item_name VARCHAR2(2000),
                                     primary_uom_code VARCHAR2(3),
                                     revision VARCHAR2(3),
                                     requested_quantity NUMBER,
                                     source_subinventory_code VARCHAR2(10),
                                     source_locator_id NUMBER,
                                     lot_number VARCHAR2(80),
                                     start_serial VARCHAR2(30),
                                     end_serial VARCHAR2(30));

  type allocate_comp_tbl_t IS TABLE OF allocate_comp_rec_t INDEX BY BINARY_INTEGER;

  /* This procedure is callback for INV to set backorder qty in WRO */
  procedure pre_allocate_material(p_wip_entity_id in NUMBER,
                              p_operation_seq_num in NUMBER,
                              p_inventory_item_id in NUMBER,
                              p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                              p_use_pickset_flag in VARCHAR2, -- null is no,
                              p_allocate_quantity in NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2);

  /* This procedure issues material to a job/repetitive_schedule.
     However, it fails if the requirement does not exist!
     Parameters:
       p_wip_entity_id: the wip entity_id
       p_inventory_item_id: id of the item being issued
       p_repetitive_line_id: line id of the repetitive schedule if
                               issuing to a rep sched
       p_transaction_id: the transaction id from mmt. Only used for
                         repetitive schedules
       p_primary_quantity: quantity being issued, in item's primary UOM and negative
                           since it is a pull from inventory. e.g., set this to -5
                           to issue 5 to the job
       x_return_status: FND_API return codes are used, also
                        'L' if rows are locked
       x_msg_data: error message if error occurred. This is not put on the message
                   stack!
  */
  procedure  issue_material(p_wip_entity_id in NUMBER,
                            p_operation_seq_num in NUMBER,
                            p_inventory_item_id in NUMBER,
                            p_repetitive_line_id in NUMBER DEFAULT NULL,
                            p_transaction_id in NUMBER DEFAULT NULL,
                            p_primary_quantity in NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data OUT NOCOPY VARCHAR2);


  /* This procedure deallocates material from a job/repetitive_schedule, i.e. it
     lowers the quantity_allocated column in wro.
     Parameters:
       p_wip_entity_id: the wip entity_id
       p_operation_seq_num: op seq of item being deallocated
       p_inventory_item_id: id of the item being issued
       p_repetitive_schedule_id: repetitive schedule id if entity is rep sched
       p_primary_quantity: quantity being issued, in item's primary UOM
       x_return_status: FND_API return codes are used, also
                        'L' if rows are locked
       x_msg_data: error message if error occurred. This is not put on the message
                   stack!
  */
  procedure unallocate_material(p_wip_entity_id in NUMBER,
                                p_operation_seq_num in NUMBER,
                                p_inventory_item_id in NUMBER,
                                p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                                p_primary_quantity in NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY VARCHAR2);


  /* This procedure allocates material to a job/repetitive_schedule, i.e. it
     ups the quantity_allocated column in wro.
     Parameters:
       p_wip_entity_id: the wip entity_id
       p_operation_seq_num: op seq of item being deallocated
       p_inventory_item_id: id of the item being issued
       p_repetitive_schedule_id: repetitive schedule id if entity is rep sched
       p_primary_quantity: quantity being issued, in item's primary UOM
       x_return_status: FND_API return codes are used, also
                        'L' if rows are locked
       x_msg_data: error message if error occurred. This is not put on the message
                   stack!
  */
  procedure allocate_material(p_wip_entity_id in NUMBER,
                              p_operation_seq_num in NUMBER,
                              p_inventory_item_id in NUMBER,
                              p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                              p_primary_quantity in NUMBER,
                              x_quantity_allocated OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2);

  /* This procedure cancels open allocations. It should be called when a job/schedule is cancelled to prevent addional move orders
     or tasks from being transacted.
     Parameters:
       p_wip_entity_id: The wip entity id of the job/schedule
       p_wip_entity_type: The wip entity type of the job/schedule
       p_repetitive_schedule_id: The rep sched id of the schedule if cancelling a rep. sched.
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */
  procedure cancel_allocations(p_wip_entity_id NUMBER,
                               p_wip_entity_type NUMBER,
                               p_repetitive_schedule_id NUMBER DEFAULT NULL,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2);


 /* This procedure called for cancellation of move orders for specific components. This procedure queries for the move order
    lines related to the specified component of the entity and calls cancel_MO_line for each of this component and zeros the
    backorder quantity in WRO.*/

  Procedure cancel_comp_allocations(p_wip_entity_id NUMBER,
		     p_operation_seq_num NUMBER,
		     p_inventory_item_id NUMBER,
                     p_wip_entity_type NUMBER,
                     p_repetitive_schedule_id NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2);

  /* This procedure reduces the allocated quantity for a component
   by the requested quantity */
   procedure reduce_comp_allocations(p_comp_tbl IN allocate_comp_tbl_t,
                               p_wip_entity_type NUMBER,
                               p_organization_id NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2);

   /* This procedure is used in the WIPCMPPK form to allocate material.
     Parameters:
       p_alloc_tbl: A table of records containing the entities for which to allocate.
       p_days_to_alloc: For rep scheds, the maximum number of days to allocate. Less may
                        be allocated if the open quantity is less.
       p_start_date : The start date to allocate for.
       p_cutoff_date: The last date to allocate for.
       p_operation_seq_num_low : Starting operation seq to allocate for. Only for Discrete jobs and EAM work orders
       p_operation_seq_num_high: Ending operation seq to allocate for. Only for Discrete jobs and EAM work orders
       p_wip_entity_type: The wip entity type of the jobs/schedules.
       p_organization_id: The organization id of the jobs/schedules.
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */
   procedure allocate(p_alloc_tbl IN OUT NOCOPY allocate_tbl_t,
                     p_days_to_alloc NUMBER := NULL, --only used for rep scheds
                     p_auto_detail_flag VARCHAR2 DEFAULT NULL,
                     p_start_date  DATE DEFAULT NULL,
                     p_cutoff_date DATE,
                     p_operation_seq_num_low NUMBER DEFAULT NULL,
                     p_operation_seq_num_high NUMBER DEFAULT NULL,
                     p_wip_entity_type NUMBER,
                     p_organization_id NUMBER,
                     p_pick_grouping_rule_id NUMBER := NULL, /* Added as part of Enhancement#2578514*/
                     p_print_pick_slip VARCHAR2 DEFAULT NULL,      /* Added as part of Enhancement#2578514*/
                     p_plan_tasks BOOLEAN DEFAULT NULL,           /* Added as part of Enhancement#2578514*/
                     x_conc_req_id OUT NOCOPY NUMBER,
                     x_mo_req_number OUT NOCOPY VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2);

                      /* This procedure is called for allocating specific components .
     Parameters:
       p_alloc_comp_tbl: A table of records containing the (entity,operation sequence,component) combination for which to allocate.
       p_days_to_alloc: For rep scheds, the maximum number of days to allocate. Less may
                        be allocated if the open quantity is less.
       p_auto_detail_flag: Indicates automatic detailing of Move Order lines to Inventory.
       p_cutoff_date: The last date to allocate for.
       p_wip_entity_type: The wip entity type of the jobs/schedules.
       p_organization_id: The organization id of the jobs/schedules.
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */


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
                     x_msg_data OUT NOCOPY VARCHAR2);

    Function Quantity_Allocated(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
                              p_repetitive_schedule_id IN NUMBER DEFAULT NULL,
                              p_quantity_issued IN NUMBER DEFAULT NULL) RETURN NUMBER;

    Function Is_Component_Pick_Released(p_wip_entity_id in number,
                     p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                     p_org_id in NUMBER,
                     p_operation_seq_num in NUMBER,
                     p_inventory_item_id in NUMBER) RETURN BOOLEAN;

    Function Is_Job_Pick_Released(p_wip_entity_id in number,
                     p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                     p_org_id in NUMBER) RETURN BOOLEAN;

    Procedure Update_Requirement_SubinvLoc(p_wip_entity_id number,
                 p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                 p_operation_seq_num NUMBER,
                 p_supply_subinventory in VARCHAR2,
                 p_supply_locator_id in NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2);

    Procedure Update_Component_BackOrdQty(p_wip_entity_id number,
                 p_repetitive_schedule_id in NUMBER DEFAULT NULL,
		 p_operation_seq_num NUMBER,
                 p_new_component_qty in NUMBER,
                 p_inventory_item_id in NUMBER DEFAULT NULL,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2);

    Procedure Update_Job_BackOrdQty(p_wip_entity_id number,
                 p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                 p_new_job_qty in NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2);

    RECORDS_LOCKED  EXCEPTION;
    PRAGMA EXCEPTION_INIT (RECORDS_LOCKED, -0054);
end wip_picking_pub;

 

/

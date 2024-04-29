--------------------------------------------------------
--  DDL for Package WIP_PICKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PICKING_PVT" AUTHID CURRENT_USER as
 /* $Header: wippckvs.pls 120.2.12010000.1 2008/07/24 05:25:07 appldev ship $ */


  /* This procedure explodes the BOM of a flow schedule. It also purges any components that were incorrectly exploded if
     the supply type for their assembly was sub-assy, not phantom
     Parameters:
       p_organization_id: The org of the bill.
       p_bill_sequence_id: The bill sequence of the assembly
       p_revision_date: The revision date of the assembly
       p_primary_item_id: The item id of the assembly
       p_alternate_bom_designator: the abm of the assembly, if it is being used
       p_user_id: To set the standard WHO column in bom_explosions
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */
  procedure explode(p_organization_id NUMBER,
                    p_bill_sequence_id NUMBER,
                    p_revision_date DATE,
                    p_primary_item_id NUMBER,
                    p_alternate_bom_designator VARCHAR2,
                    p_user_id NUMBER,
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


/* This procedure is called from cancel_allocations and cancel_comp_allocations.
   It updates the allocated quantity appropriately for the received row id and calls inventory's API
   to cancel the move order line. */

  Procedure cancel_MO_line(p_lineId  IN NUMBER,
		 p_rowId ROWID,
                 p_wip_entity_type NUMBER,
                 p_openQty NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2);


  /* This procedure updates the operation sequence number of  open allocations. It should be called when a routing is added
     to the job schedule after a pick release has occurred. In this case, all move orders w/op_seq = 1 will get updated to the
     lowest added operation of the new routing.

     Parameters:
       p_wip_entity_id: The wip entity id of the job/schedule
       p_operation_seq_num: The new op seq of the move orders
       p_repetitive_schedule_id: The rep sched id of the schedule if cancelling a rep. sched.
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */
  procedure update_allocation_op_seqs(p_wip_entity_id IN NUMBER,
                                      p_repetitive_schedule_id IN NUMBER := null,
                                      p_operation_seq_num IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data OUT NOCOPY VARCHAR2);

   /* This procedure reduces the allocated quantity for a component
   by the requested quantity */
   procedure reduce_comp_allocations(p_comp_tbl IN wip_picking_pub.allocate_comp_tbl_t,
                               p_wip_entity_type NUMBER,
                               p_organization_id NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2);


  /* This procedure is used in the picking concurrent request.
     Parameters:
       errbuf: Error message returned to conc. manager.
       retcode: return status to conc. manager. See app developer guide for meanings
       p_wip_entity_type: The wip entity type of the job/schedule
       p_days_forward: Number of days to allocate for (from sysdate).
       p_organization_id: The org to allocate material for.
       p_use_pickset_indicator: Whether to use picksets or not
       p_days_to_alloc: For rep scheds, the maximum number of days to allocate. Less may
                        be allocated if the open quantity is less.
  */
  procedure allocate(errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     p_wip_entity_type NUMBER,
                     p_job_type NUMBER DEFAULT 4,   /*Bug 5932126 (FP of 5880558): Added one new parameter for job type*/
                     p_days_forward NUMBER,
                     p_organization_id NUMBER,
                     p_use_pickset_indicator NUMBER,
                     p_pick_grouping_rule_id NUMBER := NULL,
                     p_print_pickslips NUMBER DEFAULT NULL,  -- lookup code is 1 for default value YES
                     p_plan_tasks NUMBER DEFAULT NULL,         -- lookup code is 2 for default value NO
                     p_days_to_alloc NUMBER DEFAULT NULL);      --only used for rep scheds

  /* This procedure is used in the WIPCMPPK form to allocate material.
     Parameters:
       p_alloc_tbl: A table of records containing the entities for which to allocate.
       p_days_to_alloc: For rep scheds, the maximum number of days to allocate. Less may
                        be allocated if the open quantity is less.
       p_cutoff_date: The last date to allocate for.
       p_wip_entity_type: The wip entity type of the jobs/schedules.
       p_organization_id: The organization id of the jobs/schedules.
       x_return_status: FND_API return codes are used
       x_msg_data: The error message. This message is not put on the stack!
  */
   procedure allocate(p_alloc_tbl IN OUT NOCOPY wip_picking_pub.allocate_tbl_t,
                     p_days_to_alloc NUMBER := NULL, --only used for rep scheds
                     p_auto_detail_flag VARCHAR2 DEFAULT NULL,
                     p_start_date DATE DEFAULT NULL,  /* Enh#2824753 */
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
                     x_msg_data OUT NOCOPY VARCHAR2);

 /* This procedure is called by allocate and allocate_comp to get the MO header and lines records appropriately filled in. */

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
                     x_msg_data OUT NOCOPY VARCHAR2);

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
                              x_msg_data OUT NOCOPY VARCHAR2 );

   Procedure Post_Explosion_CleanUp(p_wip_entity_id number,
                              p_repetitive_schedule_id in NUMBER DEFAULT NULL,
                              p_org_id in NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_data OUT NOCOPY VARCHAR2  );

    RECORDS_LOCKED  EXCEPTION;
    PRAGMA EXCEPTION_INIT (RECORDS_LOCKED, -0054);
    g_PickRelease_Failed  BOOLEAN := FALSE; /* used to set the request to warning */
end wip_picking_pvt;

/

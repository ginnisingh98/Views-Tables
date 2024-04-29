--------------------------------------------------------
--  DDL for Package Body WIP_DEFAULT_SHOPFLOORMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DEFAULT_SHOPFLOORMOVE" AS
/* $Header: WIPDSFMB.pls 120.10.12010000.4 2010/04/05 20:09:08 hliew ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Default_Shopfloormove';

--  Package global used within the package.

g_ShopFloorMove_rec           WIP_Transaction_PUB.Shopfloormove_Rec_Type;
g_OSP_rec                     WIP_Transaction_PUB.Res_Rec_Type;
g_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type;
g_osp_mov_details             WIP_Transaction_PUB.OSP_Move_Details_Type;

--  Get functions.

PROCEDURE get_we_attr
IS
     l_Wip_Entities_rec WIP_Work_Order_PUB.Wip_Entities_Rec_Type :=
                        WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_REC;
BEGIN

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL THEN

      l_Wip_Entities_rec := WIP_Wip_Entities_Util.Query_Row(g_ShopFloorMove_rec.wip_entity_id);
      IF g_ShopFloorMove_rec.wip_entity_name IS NULL THEN
         g_Wip_Entities_rec.wip_entity_name := l_Wip_Entities_rec.wip_entity_name;
      END IF;
      IF g_ShopFloorMove_rec.primary_item_id IS NULL THEN
         g_Wip_Entities_rec.primary_item_id := l_Wip_Entities_rec.primary_item_id;
      END IF;
      IF g_ShopFloorMove_rec.entity_type IS NULL THEN
         g_Wip_Entities_rec.entity_type := l_Wip_Entities_rec.entity_type;
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_we_attr');
END get_we_attr;

PROCEDURE validate_default_sub_loc (p_wip_entity_id     IN      NUMBER,
                                p_org_id                IN      NUMBER,
                                p_line_id               IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
BEGIN

        /*  you must have a default completion subinventory/locator
            for move-completions and return-moves
        */

        select count(*) into x_valid_ez_complete
        from WIP_ENTITIES WE
        where we.wip_entity_id = p_wip_entity_id
        and we.organization_id = p_org_id
        and (((we.entity_type = WIP_CONSTANTS.DISCRETE)
                and not exists (select 'X'
                            from WIP_DISCRETE_JOBS DJ
                            where DJ.WIP_ENTITY_ID = p_wip_entity_id
                            and DJ.ORGANIZATION_ID = p_org_id
                            and DJ.COMPLETION_SUBINVENTORY IS NOT NULL))
                or (we.entity_type = WIP_CONSTANTS.REPETITIVE)
                    and not exists (select 'X' from WIP_REPETITIVE_ITEMS WRI
                                    where WRI.WIP_ENTITY_ID = p_wip_entity_id
                                    and WRI.ORGANIZATION_ID = p_org_id
                                    and WRI.LINE_ID = p_line_id
                                    and WRI.COMPLETION_SUBINVENTORY IS NOT NULL));

        exception
        when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','validate_default_sub_loc');

END validate_default_sub_loc;

PROCEDURE validate_lot_control (p_wip_entity_id         IN      NUMBER,
                                p_org_id                IN      NUMBER,
                                p_line_id               IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
BEGIN


        -- If it's discrete, and does not have a default lot then can't move_complete/return
        -- if it's repetitive then can't move_complete/return_move

        select count(*) into x_valid_ez_complete
        from wip_entities we, mtl_system_items msi
        where we.wip_entity_id = p_wip_entity_id
        and we.organization_id = p_org_id
        and msi.inventory_item_id = we.primary_item_id
        and msi.organization_id = we.organization_id
        and msi.lot_control_code = WIP_CONSTANTS.LOT
        and (  ( we.entity_type = WIP_CONSTANTS.DISCRETE
                 and exists (select 'X'
                            from wip_discrete_jobs wdj
                            where wdj.wip_entity_id = we.wip_entity_id
                            and wdj.organization_id = we.organization_id
                            and wdj.lot_number is null))
            or (we.entity_type = WIP_CONSTANTS.REPETITIVE)  );

        exception
        when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','validate_lot_control');
END validate_lot_control;

PROCEDURE validate_serial_control(p_wip_entity_id       IN      NUMBER,
                                p_org_id                IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
BEGIN

        select count(*) into x_valid_ez_complete
        from MTL_SYSTEM_ITEMS msi, WIP_ENTITIES we
        where we.organization_id = p_org_id
        and we.wip_entity_id = p_wip_entity_id
        and msi.inventory_item_id = we.primary_item_id
        and msi.organization_id = we.organization_id
        and msi.serial_number_control_code in (2,5);

        exception
        when others then
             fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','validate_serial_control');
END validate_serial_control;

PROCEDURE validate_shop_floor_status (p_wip_entity_id   IN      NUMBER,
                                p_org_id                IN      NUMBER,
                                p_line_id               IN      NUMBER,
                                p_rep_sched_id          IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
BEGIN


        select count(*) into x_valid_ez_complete
        from WIP_SHOP_FLOOR_STATUSES wsfs, WIP_OPERATIONS wo,
                WIP_SHOP_FLOOR_STATUS_CODES wsfsc
        where wsfs.wip_entity_id = p_wip_entity_id
        and wsfs.organization_id = p_org_id
        and nvl (wsfs.line_id, -1) = nvl (p_line_id, -1)
        and wo.wip_entity_id = wsfs.wip_entity_id
        and nvl (wo.repetitive_schedule_id, -1) = nvl (p_rep_sched_id, -1)
        and wo.organization_id = wsfs.organization_id
        and wo.next_operation_seq_num is null
        and wo.operation_seq_num = wsfs.operation_seq_num
        and wsfs.intraoperation_step_type=WIP_CONSTANTS.TOMOVE
        and wsfsc.shop_floor_status_code = wsfs.shop_floor_status_code
        and wsfsc.organization_id = wsfs.organization_id
        and wsfsc.status_move_flag = 2
        and nvl(wsfsc.disable_date, sysdate + 1) > sysdate;

        exception
        when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','validate_shop_floor_status');
END validate_shop_floor_status;

PROCEDURE validate_item_revision (p_wip_entity_id       IN      NUMBER,
                                p_org_id                IN      NUMBER,
                                p_line_id               IN      NUMBER,
                                p_rep_sched_id          IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
BEGIN

        /*item revision must exist as a BOM revision */
        /* Fix for bug 4095809: Need to do the comparison only if a bill
           is referenced in the job ie., common_bill_sequence_id IS NOT NULL */
        select count(*) into x_valid_ez_complete
        from wip_entities we
        where we.wip_entity_id = p_wip_entity_id
        and we.organization_id = p_org_id
        and exists (
                select 'X'
                from MTL_SYSTEM_ITEMS msi
                where msi.organization_id = p_org_id
                and msi.inventory_item_id = we.primary_item_id
                and msi.revision_qty_control_code=2)
        and ( ( we.entity_type = WIP_CONSTANTS.DISCRETE
                and not exists (
                        select 'X'
                        from WIP_DISCRETE_JOBS wdj, MTL_ITEM_REVISIONS MIR
                        where wdj.organization_id = we.organization_id
                        and wdj.wip_entity_id = we.wip_entity_id
                        and mir.organization_id = wdj.organization_id
                        and mir.inventory_item_id = we.primary_item_id
                        and ( wdj.common_bom_sequence_id is null
                              or ( wdj.common_bom_sequence_id is not null
                                   and mir.revision = wdj.bom_revision
                                  )
                            )
                        ))
            or (we.entity_type = WIP_CONSTANTS.REPETITIVE
                and not exists (
                        select 'X'
                        from WIP_REPETITIVE_SCHEDULES WRS, MTL_ITEM_REVISIONS MIR
                        where wrs.organization_id = we.organization_id
                        and wrs.repetitive_schedule_id = p_rep_sched_id
                        and mir.inventory_item_id = we.primary_item_id
                        and mir.organization_id = we.organization_id
                        and mir.inventory_item_id = we.primary_item_id
                        and ( wrs.common_bom_sequence_id is null
                              or ( wrs.common_bom_sequence_id is not null
                                   and mir.revision = wrs.bom_revision
                                  )
                            )
                        )) );

        exception
        when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','validate_item_revision');
END validate_item_revision;

PROCEDURE validate_last_op (p_wip_entity_id     IN      NUMBER,
                                p_org_id        IN      NUMBER,
                                p_line_id       IN      NUMBER,
                                p_rep_sched_id  IN      NUMBER,
                                x_valid_ez_complete     OUT NOCOPY     NUMBER) IS
begin

        validate_default_sub_loc (p_wip_entity_id, p_org_id, p_line_id,
                                x_valid_ez_complete);
        if (x_valid_ez_complete <> VALID) then
                return ;
        end if;

        validate_lot_control (p_wip_entity_id, p_org_id, p_line_id,
                                x_valid_ez_complete);
        if (x_valid_ez_complete <> VALID) then
                return ;
        end if;

        validate_serial_control (p_wip_entity_id, p_org_id,
                                x_valid_ez_complete);
        if (x_valid_ez_complete <> VALID) then
                return ;
        end if;

        validate_shop_floor_status (p_wip_entity_id, p_org_id, p_line_id,
                                p_rep_sched_id, x_valid_ez_complete);
        if (x_valid_ez_complete <> VALID) then
                return ;
        end if;

        validate_item_revision (p_wip_entity_id, p_org_id, p_line_id,
                                p_rep_sched_id, x_valid_ez_complete);

END validate_last_op;

PROCEDURE get_actual_move_ops(p_correction_type  IN     NUMBER,
                         p_org_id       IN      NUMBER,
                         p_wip_entity_id        IN      NUMBER,
                         p_operation_seq_num    IN      NUMBER,
                         p_rep_sched_id IN      NUMBER,
                         p_line_id      IN      NUMBER,
                         p_next_op      IN OUT NOCOPY  NUMBER,
                         p_current_op   IN OUT NOCOPY  NUMBER,
                         p_next_dept_id IN OUT NOCOPY  NUMBER,
                         p_current_dept_id  IN OUT NOCOPY      NUMBER,
                         x_next_step    OUT NOCOPY     NUMBER,
                         x_current_step OUT NOCOPY     NUMBER,
                         x_txn_type     OUT NOCOPY     NUMBER) IS

                         x_temp         NUMBER;
                         x_valid_ez_complete    NUMBER;
                         l_ncp_after_current_op NUMBER;		/*Added for bug 6146597*/
                         l_lot_control_code NUMBER;		/*Added for bug 8826087*/
                         l_shelf_life_code NUMBER;		/*Added for bug 8826087*/

BEGIN
        x_txn_type := WIP_CONSTANTS.MOVE_TXN;
        if (p_correction_type = MOVE_FORWARD) then

                if (p_next_op > p_current_op) then
                        x_current_step := WIP_CONSTANTS.QUEUE;
                        x_next_step := WIP_CONSTANTS.QUEUE;
                else
	                        validate_last_op(p_wip_entity_id, p_org_id, p_line_id,
                                        p_rep_sched_id, x_valid_ez_complete);

							 /*Bug 6146597: Added the following query to check if there any non count point operations
						 	   after the OSP operation. The code reaches this point beacuse OSP operation
						 	   is the last count point operation */
 	                          select count(*)
 	                             into l_ncp_after_current_op
 	                            from wip_operations
 	                           where operation_seq_num > p_current_op
 	                             and count_point_type = 2
 	                             and wip_entity_id = p_wip_entity_id ;

               /*Added for bug 8826087, check that if assembly is set to lot control and lot expiration is set to USER_DEFINED,
                 Do move transaction instead of easy completion to aviod error WIP_USER_DEF_EXP_NOT_ALLOW*/

                               begin
                                 select msi.lot_control_code, msi.shelf_life_code
                                  into l_lot_control_code, l_shelf_life_code
                                  from mtl_system_items msi, wip_entities we
                                  where we.wip_entity_id = p_wip_entity_id
                                  and we.organization_id = p_org_id
                                  and msi.organization_id = we.organization_id
                                  and INVENTORY_ITEM_ID = we.primary_item_id;
                              exception
                                  when others then
                                  fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_actual_move_ops: select from MSI,WE');
                               end;



               /*Fix for bug 8826087*/
                             if (l_ncp_after_current_op > 0 or (l_lot_control_code = WIP_CONSTANTS.LOT and l_shelf_life_code = WIP_CONSTANTS.USER_DEFINED_EXP))  then
								 	 /*To make the completion invalid because there are Non count point operation
								 	    after this operation*/
	 	                             x_valid_ez_complete := -999 ;
 	                            end if ;


		                        if (x_valid_ez_complete = VALID) then
		                                x_txn_type := WIP_CONSTANTS.COMP_TXN;
								end if;

								p_next_op := p_current_op;
                                p_next_dept_id := p_current_dept_id;
                                x_current_step := WIP_CONSTANTS.QUEUE;
                                x_next_step := WIP_CONSTANTS.TOMOVE;

                end if;
        else
                if (p_next_op > p_current_op) then
                        x_temp := p_current_op;
                        p_current_op := p_next_op;
                        p_next_op := x_temp;
                        x_temp := p_current_dept_id;
                        p_current_dept_id := p_next_dept_id;
                        p_next_dept_id := x_temp;
                        x_current_step := WIP_CONSTANTS.QUEUE;
                        x_next_step := WIP_CONSTANTS.QUEUE;
                else
                        validate_last_op(p_wip_entity_id, p_org_id, p_line_id,
                                        p_rep_sched_id, x_valid_ez_complete);
                        if (x_valid_ez_complete = VALID) then
                                x_txn_type := WIP_CONSTANTS.RET_TXN;
                        end if;
                        p_next_op := p_current_op;
                        p_next_dept_id := p_current_dept_id;
                        x_current_step := WIP_CONSTANTS.TOMOVE;
                        x_next_step := WIP_CONSTANTS.QUEUE;
                end if;
        end if;

        exception
        when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_actual_move_ops');
END get_actual_move_ops;

PROCEDURE get_osp_move_details
  IS
     l_transaction_type         NUMBER := FND_API.G_MISS_NUM;
     l_transaction_quantity     NUMBER := FND_API.G_MISS_NUM;
     l_primary_quantity         NUMBER := FND_API.G_MISS_NUM;
     l_fm_operation_seq_num     NUMBER := FND_API.G_MISS_NUM;
     l_fm_intraop_step_type     NUMBER := FND_API.G_MISS_NUM;
     l_fm_department_id         NUMBER := FND_API.G_MISS_NUM;
     l_to_operation_seq_num     NUMBER := FND_API.G_MISS_NUM;
     l_to_intraop_step_type     NUMBER := FND_API.G_MISS_NUM;
     l_to_department_id         NUMBER := FND_API.G_MISS_NUM;
     l_correction_type          NUMBER;
     l_wip_entity_id            NUMBER := FND_API.G_MISS_NUM;
     l_organization_id          NUMBER := FND_API.G_MISS_NUM;
     l_osp_op_seq               NUMBER := FND_API.G_MISS_NUM;
     l_line_id                  NUMBER := FND_API.G_MISS_NUM;
     l_rep_sch_id               NUMBER := FND_API.G_MISS_NUM;
     l_cur_op_seq               NUMBER := FND_API.G_MISS_NUM;
     l_cur_qty_in_queue         NUMBER := FND_API.G_MISS_NUM;
     l_cur_qty_to_move          NUMBER := FND_API.G_MISS_NUM;
     l_next_op_seq              NUMBER := FND_API.G_MISS_NUM;
     l_next_qty_in_queue        NUMBER := FND_API.G_MISS_NUM;
     l_next_qty_to_move         NUMBER := FND_API.G_MISS_NUM;
     l_basis_type               NUMBER := FND_API.G_MISS_NUM;
     l_neg_qty_indicator        boolean;
BEGIN

   l_wip_entity_id    := g_OSP_rec.wip_entity_id;
   l_organization_id  := g_OSP_rec.organization_id;
   l_osp_op_seq       := g_OSP_rec.operation_seq_num;
   l_line_id          := g_OSP_rec.line_id;
   l_rep_sch_id       := g_OSP_rec.repetitive_schedule_id;
   l_basis_type       := g_OSP_rec.basis_type;

   SELECT Decode(msi.outside_operation_uom_type,
          'ASSEMBLY' , rti.primary_quantity,
          Decode(Nvl(g_OSP_rec.usage_rate_or_amount,0) ,
                     0 , 0,
                     (rti.primary_quantity/g_OSP_rec.usage_rate_or_amount)))
   INTO
          l_primary_quantity
   FROM
          mtl_system_items msi,
          rcv_transactions_interface rti
   WHERE rti.interface_transaction_id = g_OSP_rec.source_line_id
      AND msi.inventory_item_id = rti.item_id
      AND msi.organization_id = g_OSP_rec.organization_id;

   if(l_primary_quantity < 0) then
     l_neg_qty_indicator := true;
     l_primary_quantity := l_primary_quantity * -1;
   else
     l_neg_qty_indicator := false;
   end if;
   --at this point, l_primary_quantity is always positive
   l_transaction_quantity := l_primary_quantity;

   IF g_osp_mov_details.transaction_quantity IS NULL THEN
      g_osp_mov_details.transaction_quantity := l_transaction_quantity;
   END IF;

   IF g_OSP_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_RCV
     OR g_OSP_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_VEND
     THEN
      l_correction_type := MOVE_BACKWARD;
    ELSIF g_OSP_rec.action = WIP_Transaction_PUB.G_ACT_OSP_CORRECT_TO_RCV
      THEN
      IF l_neg_qty_indicator
        THEN
         l_correction_type := MOVE_FORWARD;
       ELSE
         l_correction_type := MOVE_BACKWARD;
      END IF;
    ELSE
      IF l_neg_qty_indicator
        THEN
         l_correction_type := MOVE_BACKWARD;
       ELSE
         l_correction_type := MOVE_FORWARD;
      END IF;
   END IF;

        BEGIN
           SELECT       wop.operation_seq_num,
                        wop.department_id,
                        nvl(nwop.operation_seq_num, -1),
                        nvl(nwop.department_id, -1),
                        wop.operation_seq_num,
                        wop.quantity_in_queue,
                        decode(wop.quantity_waiting_to_move, 0,
                               wop.quantity_completed,
                               wop.quantity_waiting_to_move),
                        nvl(nwop.operation_seq_num, -1),
                        nwop.quantity_in_queue,
                        decode(nwop.quantity_waiting_to_move, 0,
                               nwop.quantity_completed,
                               nwop.quantity_waiting_to_move)
                INTO    l_fm_operation_seq_num,
                        l_fm_department_id,
                        l_to_operation_seq_num,
                        l_to_department_id,
                        l_cur_op_seq,
                        l_cur_qty_in_queue,
                        l_cur_qty_to_move,
                        l_next_op_seq,
                        l_next_qty_in_queue,
                        l_next_qty_to_move
                /*Bug 6146597 Start*/
                FROM    (select  wip_entity_id,
                                  organization_id,
                                  operation_seq_num,
                                  department_id,
                                  quantity_in_queue,
                                  quantity_waiting_to_move,
                                  quantity_completed,
                                  repetitive_schedule_id
                             from wip_operations
                             where wip_entity_id= l_wip_entity_id
                               and nvl (repetitive_schedule_id, -1) = nvl (l_rep_sch_id, -1)
                               and organization_id= l_organization_id
                               and operation_seq_num > l_osp_op_seq
                               and count_point_type = 1
                               and ROWNUM=1
                             ORDER BY operation_seq_num)  nwop,
		/*Bug 6146597 End*/
                        wip_operations wop
                WHERE   wop.organization_id     = l_organization_id
                    and wop.wip_entity_id       = l_wip_entity_id
                    and wop.operation_seq_num   = l_osp_op_seq
                    and nvl (wop.repetitive_schedule_id, -1) =
                        nvl (l_rep_sch_id, -1)
                    and wop.organization_id        = nwop.organization_id(+)
                    and wop.wip_entity_id          = nwop.wip_entity_id(+)
                 /*Bug 6146597   and wop.next_operation_seq_num = nwop.operation_seq_num(+)*/
                    and nvl(wop.repetitive_schedule_id, -1) =
                              nvl(nwop.repetitive_schedule_id(+), -1);

        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_osp_move_details');
        end ;

        get_actual_move_ops(
                            p_correction_type   =>l_correction_type,
                            p_org_id            =>l_organization_id,
                            p_wip_entity_id     =>l_wip_entity_id,
                            p_operation_seq_num =>l_osp_op_seq,
                            p_rep_sched_id      =>l_rep_sch_id,
                            p_line_id           =>l_line_id,
                            p_next_op           =>l_to_operation_seq_num,
                            p_current_op        =>l_fm_operation_seq_num,
                            p_next_dept_id      =>l_to_department_id,
                            p_current_dept_id   =>l_fm_department_id,
                            x_next_step         =>l_to_intraop_step_type,
                            x_current_step      =>l_fm_intraop_step_type,
                            x_txn_type          =>l_transaction_type);

   -- set the primary quantity to job qty if basis type is LOT based
   -- fix bug 1832111
   if (l_basis_type = 2) then -- lot based resource
     if (l_fm_operation_seq_num = l_cur_op_seq) then
       if (l_fm_intraop_step_type = WIP_CONSTANTS.QUEUE) then
         l_primary_quantity := l_cur_qty_in_queue;
       elsif (l_fm_intraop_step_type = WIP_CONSTANTS.TOMOVE) then
         l_primary_quantity := l_cur_qty_to_move;
       end if;
     elsif (l_fm_operation_seq_num = l_next_op_seq) then
       if (l_fm_intraop_step_type = WIP_CONSTANTS.QUEUE) then
         l_primary_quantity := l_next_qty_in_queue;
       elsif (l_fm_intraop_step_type = WIP_CONSTANTS.TOMOVE) then
         l_primary_quantity := l_next_qty_to_move;
       end if;
     end if;
     -- need to also change the transaction_quantity
     g_osp_mov_details.transaction_quantity := l_primary_quantity;
   end if;  -- end of basis_type = 2 (lot based resource)

   -- Default all the local variables.

   IF g_osp_mov_details.move_direction IS NULL THEN
      g_osp_mov_details.move_direction := l_correction_type;
   END IF;

   IF g_osp_mov_details.transaction_type IS NULL THEN
      g_osp_mov_details.transaction_type := l_transaction_type;
   END IF;

   IF g_osp_mov_details.primary_quantity IS NULL THEN
      g_osp_mov_details.primary_quantity := l_primary_quantity;
   END IF;

   IF g_osp_mov_details.fm_operation_seq_num IS NULL THEN
      g_osp_mov_details.fm_operation_seq_num := l_fm_operation_seq_num;
   END IF;

   IF g_osp_mov_details.fm_intraop_step_type IS NULL THEN
      g_osp_mov_details.fm_intraop_step_type := l_fm_intraop_step_type;
   END IF;

   IF g_osp_mov_details.fm_department_id IS NULL THEN
      g_osp_mov_details.fm_department_id := l_fm_department_id;
   END IF;

   IF g_osp_mov_details.to_operation_seq_num IS NULL THEN
      g_osp_mov_details.to_operation_seq_num := l_to_operation_seq_num;
   END IF;

   IF g_osp_mov_details.to_intraop_step_type IS NULL THEN
      g_osp_mov_details.to_intraop_step_type := l_to_intraop_step_type;
   END IF;

   IF g_osp_mov_details.to_department_id IS NULL THEN
      g_osp_mov_details.to_department_id := l_to_department_id;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_osp_move_details');
END get_osp_move_details;


FUNCTION Get_Acct_Period
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.acct_period_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.acct_period_id;
   END IF;

   IF g_OSP_rec.acct_period_id IS NOT NULL THEN
      RETURN g_OSP_rec.acct_period_id;
   END IF;


   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Acct_Period;

FUNCTION Get_Created_By_Name
RETURN VARCHAR2
IS
BEGIN

    IF g_ShopFloorMove_rec.created_by_name IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.created_by_name;
   END IF;

   IF g_OSP_rec.created_by_name IS NOT NULL THEN
      RETURN g_OSP_rec.created_by_name;
   END IF;


   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Created_By_Name;

FUNCTION Get_Created_By
RETURN VARCHAR2
IS
BEGIN

  IF g_ShopFloorMove_rec.created_by IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.created_by;
   END IF;

   IF g_OSP_rec.created_by IS NOT NULL THEN
      RETURN g_OSP_rec.created_by;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Created_By;

FUNCTION Get_Entity_Type
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.entity_type IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.entity_type;
   END IF;

   IF g_OSP_rec.entity_type IS NOT NULL THEN
      RETURN g_OSP_rec.entity_type;
   END IF;

   IF g_Wip_Entities_rec.entity_type IS NOT NULL THEN
      RETURN g_Wip_Entities_rec.entity_type;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL THEN
      get_we_attr();
      RETURN g_ShopFloorMove_rec.entity_type;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Entity_Type;

FUNCTION Get_Fm_Department_Code
RETURN VARCHAR2
IS
BEGIN

  IF g_ShopFloorMove_rec.fm_department_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.fm_department_code;
   END IF;

   IF g_ShopFloorMove_rec.fm_department_id IS NOT NULL then

         SELECT department_code
           INTO g_ShopFloorMove_rec.fm_department_code
           FROM bom_departments
           WHERE department_id = g_ShopFloorMove_rec.fm_department_id;

           RETURN g_ShopFloorMove_rec.fm_department_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Fm_Department_Code;

FUNCTION Get_Fm_Department_Id
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.fm_department_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.fm_department_id;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.fm_department_id IS NOT NULL THEN
         RETURN g_osp_mov_details.fm_department_id;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.fm_department_id;
      END IF;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL
     AND g_ShopFloorMove_rec.fm_operation_seq_num IS NOT NULL
     AND g_ShopFloorMove_rec.organization_id IS NOT NULL THEN

      SELECT department_id
        INTO g_ShopFloorMove_rec.fm_department_id
        FROM wip_operations
        WHERE wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
        AND   organization_id = g_ShopFloorMove_rec.organization_id
        AND   operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num
        AND   (repetitive_schedule_id IS NULL
               OR repetitive_schedule_id = g_ShopFloorMove_rec.repetitive_schedule_id);

        RETURN g_ShopFloorMove_rec.fm_department_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Fm_Department_Id;

FUNCTION Get_Fm_Intraop_Step_Type
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.fm_intraop_step_type IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.fm_intraop_step_type;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.fm_intraop_step_type IS NOT NULL THEN
         RETURN g_osp_mov_details.fm_intraop_step_type;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.fm_intraop_step_type;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Fm_Intraop_Step_Type;

FUNCTION Get_Fm_Operation
RETURN VARCHAR2
IS
BEGIN

 IF g_ShopFloorMove_rec.fm_operation_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.fm_operation_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Fm_Operation;

FUNCTION Get_Fm_Operation_Seq_Num
RETURN NUMBER
IS
BEGIN


   IF g_ShopFloorMove_rec.fm_operation_seq_num IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.fm_operation_seq_num;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.fm_operation_seq_num IS NOT NULL THEN
         RETURN g_osp_mov_details.fm_operation_seq_num;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.fm_operation_seq_num;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Fm_Operation_Seq_Num;

FUNCTION Get_Group
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.group_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.group_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Group;

FUNCTION Get_Kanban_Card
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.kanban_card_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.kanban_card_id;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL
--     AND g_ShopFloorMove_rec.transaction_type = --easy complete
     AND g_ShopFloorMove_rec.entity_type = 1 THEN
--      get_wdj_attr();
      RETURN g_ShopFloorMove_rec.kanban_card_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Kanban_Card;

FUNCTION Get_Last_Updated_By_Name
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.last_updated_by_name IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.last_updated_by_name;
   END IF;

   IF g_OSP_rec.last_updated_by_name IS NOT NULL THEN
      RETURN g_OSP_rec.last_updated_by_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Updated_By_Name;

FUNCTION Get_Last_Update_Login
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.last_update_login IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.last_update_login;
   END IF;

   IF g_OSP_rec.last_update_login IS NOT NULL THEN
      RETURN g_OSP_rec.last_update_login;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Update_Login;

FUNCTION Get_Request_Id
RETURN VARCHAR2
IS
BEGIN

    IF g_ShopFloorMove_rec.request_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.request_id;
   END IF;

   IF g_OSP_rec.request_id IS NOT NULL THEN
      RETURN g_OSP_rec.request_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Request_Id;

FUNCTION Get_Program_Id
RETURN VARCHAR2
IS
BEGIN

    IF g_ShopFloorMove_rec.program_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.program_id;
   END IF;

   IF g_OSP_rec.program_id IS NOT NULL THEN
      RETURN g_OSP_rec.program_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Program_Id;

FUNCTION Get_Program_Application_Id
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.program_application_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.program_application_id;
   END IF;

   IF g_OSP_rec.program_application_id IS NOT NULL THEN
      RETURN g_OSP_rec.program_application_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Program_Application_Id;

FUNCTION Get_Program_Update_Date
RETURN DATE
IS
BEGIN

   IF g_ShopFloorMove_rec.program_update_date IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.program_update_date;
   END IF;

   IF g_OSP_rec.program_update_date IS NOT NULL THEN
      RETURN g_OSP_rec.program_update_date;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Program_Update_Date;

FUNCTION Get_Last_Updated_By
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.last_updated_by IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.last_updated_by;
   END IF;

   IF g_OSP_rec.last_updated_by IS NOT NULL THEN
      RETURN g_OSP_rec.last_updated_by;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Updated_By;

FUNCTION Get_Line_Code
RETURN VARCHAR2
IS
l_line_code     VARCHAR2(10);
BEGIN

 IF g_ShopFloorMove_rec.line_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.line_code;
   END IF;

   IF g_ShopFloorMove_rec.line_id IS NOT NULL
   AND g_ShopFloorMove_rec.organization_id IS NOT NULL THEN
      SELECT line_code
        INTO l_line_code
        FROM wip_lines
        WHERE line_id = g_ShopFloorMove_rec.line_id
        AND   organization_id = g_ShopFloorMove_rec.organization_id;

      RETURN l_line_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Line_Code;

FUNCTION Get_Line_Id
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.line_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.line_id;
   END IF;

   IF g_OSP_rec.line_id IS NOT NULL THEN
      RETURN g_OSP_rec.line_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Line_Id;

FUNCTION Get_Organization_Code
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.organization_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.organization_code;
   END IF;

   IF g_ShopFloorMove_rec.organization_id IS NOT NULL THEN
      SELECT organization_code
        INTO g_ShopFloorMove_rec.organization_code
        FROM mtl_parameters
        WHERE organization_id = g_ShopFloorMove_rec.organization_id;

      RETURN g_ShopFloorMove_rec.organization_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Organization_Code;

FUNCTION Get_Organization_Id
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.organization_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.organization_id;
   END IF;

   IF g_OSP_rec.organization_id IS NOT NULL THEN
      RETURN g_OSP_rec.organization_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Organization_Id;

FUNCTION Get_Overcpl_Primary_Qty
RETURN NUMBER
IS
l_overcpl_primary_qty NUMBER;

l_total_po_qty_delivered        NUMBER;
l_total_pri_qty_delivered       NUMBER;
l_total_prev_qty_delivered      NUMBER;
l_curr_qty_delivered            NUMBER;
l_quantity_in_queue             NUMBER;
l_scheduled_quantity            NUMBER;
l_usage_rate_or_amount          NUMBER;
l_po_uom_code                   mtl_units_of_measure.uom_code%type;
l_interface_txn_id              NUMBER;
l_osp_item_id                   NUMBER;
l_remaining_qty                 NUMBER;

/* Added for bug 6649174 */
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_returnStatus                  VARCHAR2(1);
l_quantity_completed            NUMBER;
l_quantity_running              NUMBER;
l_total_qty                     NUMBER;

BEGIN

   IF g_ShopFloorMove_rec.overcpl_primary_qty IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.overcpl_primary_qty;
   END IF;

    IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF  g_ShopFloorMove_rec.wip_entity_id IS NOT NULL
      AND nvl(g_ShopFloorMove_rec.repetitive_schedule_id, -1) IS NOT NULL
      AND g_ShopFloorMove_rec.organization_id IS NOT NULL
      AND g_ShopFloorMove_rec.fm_operation_seq_num IS NOT NULL
      AND g_ShopFloorMove_rec.primary_quantity IS NOT NULL
      AND g_osp_mov_details.move_direction = MOVE_FORWARD THEN

       /* Added wip_resource_seq_num and transaction_type condition for Bug#3248542 */
       /* Modified for bug 6649174. commented condition on wip_repetitive_schedule_id
          and added condition on wip_line_id */

        select nvl(sum(nvl(quantity_delivered,0)),0)
        into   l_total_po_qty_delivered
        from po_distributions_all
        where po_distribution_id in
                 ( select distinct rt.po_distribution_id
                   from rcv_transactions rt
                   where rt.wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
                   /*and  nvl(rt.wip_repetitive_schedule_id, -1)
                          = nvl(g_ShopFloorMove_rec.repetitive_schedule_id, -1) */
                   and  nvl(rt.wip_line_id,-1) = nvl(g_osp_rec.line_id,-1)
                   and  rt.organization_id = g_ShopFloorMove_rec.organization_id
                   and  rt.wip_operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num
                   and  rt.wip_resource_seq_num = g_OSP_rec.resource_seq_num
                   and  rt.transaction_type = 'DELIVER'
                   and  rt.po_distribution_id is not null) ;
        IF (l_logLevel <= wip_constants.full_logging) THEN
               wip_logger.log('Get_Overcpl_Primary_Qty: l_total_po_qty_delivered: '||l_total_po_qty_delivered,l_returnStatus);
        END IF ;

        begin
          SELECT wor.usage_rate_or_amount
          INTO l_usage_rate_or_amount
          FROM wip_operation_resources wor
          WHERE wor.wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
          and NVL(wor.repetitive_schedule_id, -1) = NVL(g_ShopFloorMove_rec.repetitive_schedule_id, -1)
          and wor.operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num
          and wor.organization_id = g_ShopFloorMove_rec.organization_id
          and wor.resource_seq_num = g_osp_rec.Resource_Seq_Num;
        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from WOR');
        end;

        /* Modified sql for performance bug 9552415 (FP 9398894) */
        begin
          select uom.uom_code
          into   l_po_uom_code
          from mtl_units_of_measure_vl uom
          where uom.unit_of_measure =
                ( select  PL.unit_meas_lookup_code
                  from    po_lines_all Pl
                  where   (pl.po_header_id,pl.po_line_id) =
                                 ( select pd.po_header_id, pd.po_line_id
                                   from   po_distributions_all pd
                                   where  pd.po_distribution_id =
                                          ( select rt.po_distribution_id
                                            from rcv_transactions rt
                                            where rt.wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
                                            and  nvl(rt.wip_repetitive_schedule_id, -1)
                                                  = nvl(g_ShopFloorMove_rec.repetitive_schedule_id, -1)
                                            and  rt.organization_id = g_ShopFloorMove_rec.organization_id
                                            and  rt.wip_operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num
                                            and rt.po_distribution_id is not null
                                            and rownum = 1 -- Fix bug 9552415 (FP 9398894)
                                           )
                                    and   rownum = 1
                                  )
               );
        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from UOM');
        end;



        begin
          SELECT interface_transaction_id
          INTO l_interface_txn_id
          FROM rcv_transactions
          WHERE transaction_id = g_osp_rec.rcv_transaction_id;
        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from RT');
        end;

       IF (l_interface_txn_id IS NULL) THEN
           RAISE fnd_api.g_exc_error;
       END IF;

        begin
          SELECT item_id
          INTO l_osp_item_id
          FROM rcv_transactions_interface
          WHERE interface_transaction_id = l_interface_txn_id;
        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from RTI');
        end;

        begin
          select decode (msi.outside_operation_uom_type,
                  'ASSEMBLY',
                   inv_convert.inv_um_convert(
                        l_osp_item_id,    -- item_id
                        NULL,         -- precision
                        l_total_po_qty_delivered,   -- from_quantity
                        l_po_uom_code,        -- from_unit
                        g_ShopFloorMove_rec.primary_uom,              -- to_unit
                        NULL,   -- from_name
                        NULL -- to_name
                        ),
                  decode (nvl(l_usage_rate_or_amount, 0) ,
                          0, 0,
                          l_total_po_qty_delivered/l_usage_rate_or_amount))
          into l_total_pri_qty_delivered
          from mtl_system_items msi
          where msi.inventory_item_id = l_osp_item_id
          and msi.organization_id = g_ShopFloorMove_rec.organization_id;
        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from MSI');
        end;

        IF (l_logLevel <= wip_constants.full_logging) THEN
             wip_logger.log('Get_Overcpl_Primary_Qty: l_total_pri_qty_delivered: '||l_total_pri_qty_delivered,l_returnStatus);
        END IF;

        begin

          /* Modified for bug 6649174 */

          select quantity_in_queue,
                 quantity_running,
                 quantity_completed
          into   l_quantity_in_queue,
                 l_quantity_running,
                 l_quantity_completed
          from wip_operations wo
          where wo.wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
          and  nvl(wo.repetitive_schedule_id, -1)  = nvl(g_ShopFloorMove_rec.repetitive_schedule_id, -1)
          and  wo.organization_id = g_ShopFloorMove_rec.organization_id
          and  wo.operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num;

          /* Fix for Bug#5912963. Sum quantity in queue for repetitive schedule of same item
             on the same line
          */

          if g_ShopFloorMove_rec.repetitive_schedule_id is not null then

             /* Modified for bug 6649174 */

             select sum(quantity_in_queue) ,
                    sum(wo.quantity_running) ,
                    sum(wo.quantity_completed)
             into   l_quantity_in_queue,
                    l_quantity_running,
                    l_quantity_completed
             from   wip_operations wo,
                    wip_repetitive_schedules wrs
             where  wo.wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
             and    wrs.wip_entity_id = wo.wip_entity_id
             and    wo.organization_id = wrs.organization_id
             and    wo.repetitive_schedule_id = wrs.repetitive_schedule_id
             and    wrs.line_id = g_osp_rec.line_id
             and    wrs.status_type = WIP_CONSTANTS.RELEASED
             and    wo.organization_id = g_ShopFloorMove_rec.organization_id
             and    wo.operation_seq_num = g_ShopFloorMove_rec.fm_operation_seq_num;

          end if ;

          l_total_qty := l_quantity_in_queue + l_quantity_running + l_quantity_completed ;

          IF (l_logLevel <= wip_constants.full_logging) THEN
            wip_logger.log('Get_Overcpl_Primary_Qty: l_total_qty: '||l_total_qty,l_returnStatus);
            wip_logger.log('Get_Overcpl_Primary_Qty: l_quantity_in_queue: '||l_quantity_in_queue,l_returnStatus);
            wip_logger.log('Get_Overcpl_Primary_Qty: l_quantity_running: '||l_quantity_running,l_returnStatus);
            wip_logger.log('Get_Overcpl_Primary_Qty: l_quantity_completed: '||l_quantity_completed,l_returnStatus);
          END IF;

        exception
           when others then
                fnd_msg_pub.add_exc_msg('WIP_Default_Shopfloormove','get_overcpl_primary_qty: select from WO');
        end;


        l_curr_qty_delivered := nvl(g_ShopFloorMove_rec.primary_quantity,0);
        l_total_prev_qty_delivered  := l_total_pri_qty_delivered - l_curr_qty_delivered;

        IF (l_logLevel <= wip_constants.full_logging) THEN
          wip_logger.log('Get_Overcpl_Primary_Qty: l_curr_qty_delivered: '||l_curr_qty_delivered,l_returnStatus);
          wip_logger.log('Get_Overcpl_Primary_Qty: l_total_prev_qty_delivered: '||l_total_prev_qty_delivered,l_returnStatus);
        END IF;

       /* Fix for Bug#5020591. OverCompletion quantity should be completed only when Current delivered Qty
           is more than remaining quantity to be completed on Operation. Greatest condition is added
           to take care of test case mentioned in #4232649. This fix actually same as fix made in 11.5.9
           11.5.9 code has flaw when half quantity is delivered . This case is also fixed with new if
           condition.

           Reverted changes done in bug 4686257; FP 4769587
        */

        /* Modified for bug 6649174 */
        --l_remaining_qty := greatest(l_scheduled_quantity, l_quantity_in_queue)  - l_total_prev_qty_delivered ; -- Open Qty
        l_remaining_qty :=  l_total_qty  - l_total_prev_qty_delivered ; -- Open Qty

        IF (l_logLevel <= wip_constants.full_logging) THEN
         wip_logger.log('Get_Overcpl_Primary_Qty: l_remaining_qty: '||l_remaining_qty,l_returnStatus);
        END IF;

        /* Modified calculation logic for bug 6649174 */
        if  l_curr_qty_delivered > l_remaining_qty then -- Current Qty is going to overcomplete an Op.

         If  ( l_total_prev_qty_delivered >= l_total_qty ) then -- You delivered more quantity last time
            l_overcpl_primary_qty :=  l_curr_qty_delivered;
            IF (l_logLevel <= wip_constants.full_logging) THEN
              wip_logger.log('Get_Overcpl_Primary_Qty: l_overcpl_primary_qty1: '||l_overcpl_primary_qty,l_returnStatus);
            END IF;
         elsif (l_total_pri_qty_delivered > l_total_qty) then  -- You are over receiving this time
            l_overcpl_primary_qty := l_total_pri_qty_delivered - l_total_qty;
            IF (l_logLevel <= wip_constants.full_logging) THEN
              wip_logger.log('Get_Overcpl_Primary_Qty: l_overcpl_primary_qty2: '||l_overcpl_primary_qty,l_returnStatus);
            END IF;
         end if;

        end if ;


    END IF;
 END IF;

 IF (l_logLevel <= wip_constants.full_logging) THEN
  wip_logger.log('Get_Overcpl_Primary_Qty: l_overcpl_primary_qty3: '||l_overcpl_primary_qty,l_returnStatus);
 END IF;

   RETURN l_overcpl_primary_qty;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;
END Get_Overcpl_Primary_Qty;

FUNCTION Get_Overcpl_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.overcpl_transaction_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.overcpl_transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Overcpl_Transaction;

FUNCTION Get_Overcpl_Transaction_Qty
RETURN NUMBER
IS
l_overcpl_transaction_qty NUMBER;
BEGIN

   IF g_ShopFloorMove_rec.overcpl_transaction_qty IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.overcpl_transaction_qty;
   END IF;

    IF g_ShopFloorMove_rec.overcpl_primary_qty IS NOT NULL
   AND g_ShopFloorMove_rec.primary_uom IS NOT NULL
   AND g_ShopFloorMove_rec.transaction_uom IS NOT NULL
   AND g_ShopFloorMove_rec.primary_item_id IS NOT NULL THEN

     l_overcpl_transaction_qty := inv_convert.inv_um_convert (
                g_ShopFloorMove_rec.primary_item_id,     -- item_id
                NULL,                                   -- precision
                g_ShopFloorMove_rec.overcpl_primary_qty,-- from_quantity
                g_ShopFloorMove_rec.primary_uom,        -- from_unit
                g_ShopFloorMove_rec.transaction_uom,    -- to_unit
                NULL,                                   -- from_name
                NULL                                    -- to_name
     );

     return l_overcpl_transaction_qty;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Overcpl_Transaction_Qty;

FUNCTION Get_Primary_Item
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.primary_item_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.primary_item_id;
   END IF;

   IF g_OSP_rec.primary_item_id IS NOT NULL THEN
      RETURN g_OSP_rec.primary_item_id;
   END IF;

   IF g_Wip_Entities_rec.primary_item_id IS NOT NULL THEN
      RETURN g_Wip_Entities_rec.primary_item_id;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL THEN
      get_we_attr();
      RETURN g_ShopFloorMove_rec.primary_item_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Primary_Item;

FUNCTION Get_Primary_Quantity
RETURN NUMBER
IS
BEGIN

    IF g_ShopFloorMove_rec.primary_quantity IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.primary_quantity;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.primary_quantity IS NOT NULL THEN
         RETURN g_osp_mov_details.primary_quantity;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.primary_quantity;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Primary_Quantity;

FUNCTION Get_Primary_Uom
RETURN VARCHAR2
IS
   l_primary_uom        VARCHAR2(3);
BEGIN

    IF g_ShopFloorMove_rec.primary_uom IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.primary_uom;
   END IF;

   IF g_ShopFloorMove_rec.primary_item_id IS NOT NULL
     AND g_ShopFloorMove_rec.organization_id IS NOT NULL THEN

      SELECT primary_uom_code
        INTO l_primary_uom
        FROM mtl_system_items
        WHERE inventory_item_id = g_ShopFloorMove_rec.primary_item_id
        AND   organization_id   = g_ShopFloorMove_rec.organization_id;

        RETURN l_primary_uom;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Primary_Uom;

FUNCTION Get_Process_Phase
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.process_phase IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.process_phase;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      RETURN WIP_CONSTANTS.MOVE_VAL;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Process_Phase;

FUNCTION Get_Process_Status
RETURN NUMBER
IS
BEGIN

  IF g_ShopFloorMove_rec.process_status IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.process_status;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      RETURN WIP_CONSTANTS.PENDING;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Process_Status;

FUNCTION Get_Qa_Collection
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.qa_collection_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.qa_collection_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Qa_Collection;

FUNCTION Get_Reason
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.reason_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.reason_id;
   END IF;

   IF g_OSP_rec.reason_id IS NOT NULL THEN
      RETURN g_OSP_rec.reason_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Reason;

FUNCTION Get_Reason_Name
RETURN VARCHAR2
IS
BEGIN

    IF g_ShopFloorMove_rec.reason_name IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.reason_name;
   END IF;

   IF g_OSP_rec.reason_name IS NOT NULL THEN
      RETURN g_OSP_rec.reason_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Reason_Name;

FUNCTION Get_Reference
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.reference IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.reference;
   END IF;

   IF g_OSP_rec.reference IS NOT NULL THEN
      RETURN g_OSP_rec.reference;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Reference;

FUNCTION Get_Repetitive_Schedule
RETURN NUMBER
IS
BEGIN

  IF g_ShopFloorMove_rec.repetitive_schedule_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.repetitive_schedule_id;
   END IF;

   IF g_OSP_rec.repetitive_schedule_id IS NOT NULL THEN
      RETURN g_OSP_rec.repetitive_schedule_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Repetitive_Schedule;

FUNCTION Get_Scrap_Account
RETURN NUMBER
IS
BEGIN

  IF g_ShopFloorMove_rec.scrap_account_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.scrap_account_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Scrap_Account;

FUNCTION Get_Source
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.source_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.source_code;
   END IF;

   IF g_OSP_rec.source_code IS NOT NULL THEN
      RETURN g_OSP_rec.source_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Source;

FUNCTION Get_Source_Line
RETURN NUMBER
IS
BEGIN

  IF g_ShopFloorMove_rec.source_line_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.source_line_id;
   END IF;

   IF g_OSP_rec.source_line_id IS NOT NULL THEN
      RETURN g_OSP_rec.source_line_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Source_Line;

FUNCTION Get_To_Department_Code
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.to_department_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.to_department_code;
   END IF;

/* IF g_OSP_rec.department_code IS NOT NULL THEN
      RETURN g_OSP_rec.department_code;
   END IF;
*/

   IF g_ShopFloorMove_rec.to_department_id IS NOT NULL then

         SELECT department_code
           INTO g_ShopFloorMove_rec.to_department_code
           FROM bom_departments
           WHERE department_id = g_ShopFloorMove_rec.to_department_id;

           RETURN g_ShopFloorMove_rec.to_department_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_To_Department_Code;

FUNCTION Get_To_Department_Id
RETURN NUMBER
IS
BEGIN

  IF g_ShopFloorMove_rec.to_department_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.to_department_id;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.to_department_id IS NOT NULL THEN
         RETURN g_osp_mov_details.to_department_id;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.to_department_id;
      END IF;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL
     AND g_ShopFloorMove_rec.to_operation_seq_num IS NOT NULL
     AND g_ShopFloorMove_rec.organization_id IS NOT NULL THEN

      SELECT department_id
        INTO g_ShopFloorMove_rec.to_department_id
        FROM wip_operations
        WHERE wip_entity_id = g_ShopFloorMove_rec.wip_entity_id
        AND   operation_seq_num = g_ShopFloorMove_rec.to_operation_seq_num
        AND   organization_id = g_ShopFloorMove_rec.organization_id
        AND   (repetitive_schedule_id IS NULL
               OR repetitive_schedule_id = g_ShopFloorMove_rec.repetitive_schedule_id);

        RETURN g_ShopFloorMove_rec.to_department_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_To_Department_Id;

FUNCTION Get_To_Intraop_Step_Type
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.to_intraop_step_type IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.to_intraop_step_type;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.to_intraop_step_type IS NOT NULL THEN
         RETURN g_osp_mov_details.to_intraop_step_type;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.to_intraop_step_type;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_To_Intraop_Step_Type;

FUNCTION Get_To_Operation
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.to_operation_code IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.to_operation_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_To_Operation;

FUNCTION Get_To_Operation_Seq_Num
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.to_operation_seq_num IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.to_operation_seq_num;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.to_operation_seq_num IS NOT NULL THEN
         RETURN g_osp_mov_details.to_operation_seq_num;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.to_operation_seq_num;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_To_Operation_Seq_Num;

FUNCTION Get_Transaction_Date
RETURN DATE
IS
BEGIN

    IF g_ShopFloorMove_rec.transaction_date IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.transaction_date;
   END IF;

   IF g_OSP_rec.transaction_date IS NOT NULL THEN
      RETURN g_OSP_rec.transaction_date;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Transaction_Date;

FUNCTION Get_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.transaction_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction;

FUNCTION Get_Transaction_Quantity
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.transaction_quantity IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.transaction_quantity;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.transaction_quantity IS NOT NULL THEN
         RETURN g_osp_mov_details.transaction_quantity;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.transaction_quantity;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction_Quantity;

FUNCTION Get_Transaction_Type
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.transaction_type IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.transaction_type;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      IF g_osp_mov_details.transaction_type IS NOT NULL THEN
         RETURN g_osp_mov_details.transaction_type;
      ELSE
         get_osp_move_details();
         RETURN g_osp_mov_details.transaction_type;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction_Type;

FUNCTION Get_Transaction_Uom
RETURN VARCHAR2
IS
BEGIN

   IF g_ShopFloorMove_rec.transaction_uom IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.transaction_uom;
   END IF;

   IF g_ShopFloorMove_rec.source_code = 'RCV' THEN
      RETURN g_ShopFloorMove_rec.primary_uom;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction_Uom;

FUNCTION Get_Wip_Entity
RETURN NUMBER
IS
BEGIN

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.wip_entity_id;
   END IF;

   IF g_OSP_rec.wip_entity_id IS NOT NULL THEN
      RETURN g_OSP_rec.wip_entity_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Wip_Entity;

FUNCTION Get_Wip_Entity_Name
RETURN VARCHAR2
IS
BEGIN

     IF g_ShopFloorMove_rec.wip_entity_name IS NOT NULL THEN
      RETURN g_ShopFloorMove_rec.wip_entity_name;
   END IF;

   IF g_OSP_rec.wip_entity_name IS NOT NULL THEN
      RETURN g_OSP_rec.wip_entity_name;
   END IF;

   IF g_Wip_Entities_rec.wip_entity_name IS NOT NULL THEN
      RETURN g_Wip_Entities_rec.wip_entity_name;
   END IF;

   IF g_ShopFloorMove_rec.wip_entity_id IS NOT NULL THEN
      get_we_attr();
      RETURN g_ShopFloorMove_rec.wip_entity_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Wip_Entity_Name;

PROCEDURE Get_Flex_Shopfloormove
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_ShopFloorMove_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute1 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute10 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute11 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute12 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute13 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute14 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute15 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute2 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute3 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute4 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute5 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute6 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute7 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute8 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute9 := NULL;
    END IF;

    IF g_ShopFloorMove_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_ShopFloorMove_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Shopfloormove;

--  Procedure Attributes
PROCEDURE Attributes
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_iteration                     IN  NUMBER := NULL
,   x_ShopFloorMove_rec            IN OUT NOCOPY WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_OSP_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF nvl(p_iteration,1) > WIP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize global variables

    g_ShopFloorMove_rec := WIP_Transaction_PUB.G_MISS_SHOPFLOORMOVE_REC;
    g_OSP_rec := WIP_Transaction_PUB.G_MISS_RES_REC;
    g_Wip_Entities_rec := WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_REC;
    g_osp_mov_details := WIP_Transaction_PUB.G_MISS_OSP_MOVE_DET_REC;

    g_ShopFloorMove_rec := p_ShopFloorMove_rec;
    g_OSP_rec := p_OSP_rec;

    --  Default missing attributes.
    g_ShopFloorMove_rec.source_code := Get_Source;
    g_ShopFloorMove_rec.source_line_id := Get_Source_Line;
    g_ShopFloorMove_rec.acct_period_id := Get_Acct_Period;
    g_ShopFloorMove_rec.created_by_name := Get_Created_By_Name;
    g_ShopFloorMove_rec.created_by := Get_Created_By;
    g_ShopFloorMove_rec.last_updated_by_name := Get_Last_Updated_By_Name;
    g_ShopFloorMove_rec.last_updated_by := Get_Last_Updated_By;
    g_ShopFloorMove_rec.last_update_login := Get_Last_Update_Login;
    g_ShopFloorMove_rec.request_id := Get_Request_Id;
    g_ShopFloorMove_rec.program_id := Get_Program_Id;
    g_ShopFloorMove_rec.program_application_id := Get_Program_Application_Id;
    g_ShopFloorMove_rec.program_update_date := Get_Program_Update_Date;
    g_ShopFloorMove_rec.organization_id := Get_Organization_Id;
    g_ShopFloorMove_rec.organization_code := Get_Organization_Code;
    g_ShopFloorMove_rec.primary_item_id := Get_Primary_Item;
    g_ShopFloorMove_rec.primary_uom := Get_Primary_Uom;
    g_ShopFloorMove_rec.transaction_uom := Get_Transaction_Uom;
    g_ShopFloorMove_rec.reason_id := Get_Reason;
    g_ShopFloorMove_rec.reference := Get_Reference;
    g_ShopFloorMove_rec.repetitive_schedule_id := Get_Repetitive_Schedule;
    g_ShopFloorMove_rec.line_id := Get_Line_Id;
    g_ShopFloorMove_rec.transaction_date := Get_Transaction_Date;
    g_ShopFloorMove_rec.wip_entity_id := Get_Wip_Entity;
    g_ShopFloorMove_rec.wip_entity_name := Get_Wip_Entity_Name;
    g_ShopFloorMove_rec.entity_type := Get_Entity_Type;
    g_ShopFloorMove_rec.fm_department_id := Get_Fm_Department_Id;
    g_ShopFloorMove_rec.fm_department_code := Get_Fm_Department_Code;
    g_ShopFloorMove_rec.fm_intraop_step_type := Get_Fm_Intraop_Step_Type;
    g_ShopFloorMove_rec.fm_operation_seq_num := Get_Fm_Operation_Seq_Num;
    g_ShopFloorMove_rec.fm_operation_code := Get_Fm_Operation;
    g_ShopFloorMove_rec.to_department_id := Get_To_Department_Id;
    g_ShopFloorMove_rec.to_department_code := Get_To_Department_Code;
    g_ShopFloorMove_rec.to_intraop_step_type := Get_To_Intraop_Step_Type;
    g_ShopFloorMove_rec.to_operation_seq_num := Get_To_Operation_Seq_Num;
    g_ShopFloorMove_rec.to_operation_code := Get_To_Operation;
    g_ShopFloorMove_rec.primary_quantity := Get_Primary_Quantity;
    g_ShopFloorMove_rec.transaction_quantity := Get_Transaction_Quantity;
    g_ShopFloorMove_rec.transaction_type := Get_Transaction_Type;
    g_ShopFloorMove_rec.group_id := Get_Group;
    g_ShopFloorMove_rec.kanban_card_id := Get_Kanban_Card;
    g_ShopFloorMove_rec.line_code := Get_Line_Code;
    g_ShopFloorMove_rec.overcpl_primary_qty := Get_Overcpl_Primary_Qty;
    g_ShopFloorMove_rec.overcpl_transaction_id := Get_Overcpl_Transaction;
    g_ShopFloorMove_rec.overcpl_transaction_qty := Get_Overcpl_Transaction_Qty;
    g_ShopFloorMove_rec.process_phase := Get_Process_Phase;
    g_ShopFloorMove_rec.process_status := Get_Process_Status;
    g_ShopFloorMove_rec.qa_collection_id := Get_Qa_Collection;
    g_ShopFloorMove_rec.reason_name := Get_Reason_Name;
    g_ShopFloorMove_rec.scrap_account_id := Get_Scrap_Account;
    g_ShopFloorMove_rec.transaction_id := Get_Transaction;

    IF g_ShopFloorMove_rec.creation_date IS NULL THEN
        g_ShopFloorMove_rec.creation_date := Sysdate;
    END IF;

    IF g_ShopFloorMove_rec.last_update_date IS NULL THEN
        g_ShopFloorMove_rec.last_update_date := Sysdate;
    END IF;

        x_ShopFloorMove_rec := g_ShopFloorMove_rec;

END Attributes;

END WIP_Default_Shopfloormove;

/

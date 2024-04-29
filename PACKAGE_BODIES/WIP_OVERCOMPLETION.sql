--------------------------------------------------------
--  DDL for Package Body WIP_OVERCOMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OVERCOMPLETION" AS
/* $Header: wipocmpb.pls 120.1.12010000.3 2010/02/23 04:38:53 pfauzdar ship $ */


/*=====================================================================+
 | PROCEDURE
 |   update_wip_req_operations
 |
 | PURPOSE
 |   Updates the required quantity values of all the components.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

procedure update_wip_req_operations
         ( P_GROUP_ID IN     NUMBER,
           P_TXN_DATE IN     VARCHAR2,
           P_USER_ID  IN     NUMBER default -1,
           P_LOGIN_ID IN     NUMBER default -1,
           P_REQ_ID   IN     NUMBER default -1,
           P_APPL_ID  IN     NUMBER default -1,
           P_PROG_ID  IN     NUMBER default -1
         ) is
BEGIN

   update wip_requirement_operations wro
     set (wro.required_quantity
          ,last_updated_by,
          last_update_date,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date ) =
     ( select
       MIN(required_quantity)
       + NVL(
             SUM(
                 NVL(wma1.primary_quantity,wti1.primary_quantity)),0)
                 * MIN(quantity_per_assembly),
       DECODE(p_user_id,-1,NULL,p_user_id),
       SYSDATE,
       DECODE(p_login_id,-1,NULL,p_login_id),
       DECODE(p_req_id,-1,NULL,p_req_id),
       DECODE(p_appl_id,-1,NULL,p_appl_id),
       DECODE(p_prog_id,-1,NULL,p_prog_id),
       DECODE(p_req_id,-1,NULL,SYSDATE)
       from wip_requirement_operations wro1,
       wip_move_txn_interface wti1,
       WIP_MOVE_TXN_ALLOCATIONS wma1
       where
       wro1.rowid = wro.rowid
       -- The WO rows to be updated are identified by the rowids.
       -- For each such row, go back and sum the quantities from WMTI
       and wti1.group_id = p_group_id
       and wti1.process_phase = WIP_CONSTANTS.MOVE_PROC
       and wti1.process_status = WIP_CONSTANTS.RUNNING
       and TRUNC(wti1.transaction_date)
       = TO_DATE(P_TXN_DATE, WIP_CONSTANTS.DATE_FMT)
       and wti1.overcompletion_transaction_id is not null
         and wti1.overcompletion_primary_qty IS NULL
           and wro1.wip_entity_id = wti1.wip_entity_id
           and wro1.organization_id = wti1.organization_id
           AND wti1.organization_id = wma1.organization_id (+)
           AND wti1.transaction_id = wma1.transaction_id (+)
           AND nvl(wma1.repetitive_schedule_id,0)
           = nvl(wro1.repetitive_schedule_id,0)
           )
           where wro.rowid in
           (
            select wro2.rowid from
            wip_requirement_operations wro2,
            wip_move_txn_interface wti2,
            WIP_MOVE_TXN_ALLOCATIONS wma2
            where
            wti2.group_id = p_group_id
            and wti2.process_phase = WIP_CONSTANTS.MOVE_PROC
            and wti2.process_status = WIP_CONSTANTS.RUNNING
            and TRUNC(wti2.transaction_date)
            = TO_DATE(P_TXN_DATE, WIP_CONSTANTS.DATE_FMT)
            and wti2.overcompletion_transaction_id is not null
            and wti2.overcompletion_primary_qty IS NULL
            -- Picked a Move txn
            and wro2.wip_entity_id = wti2.wip_entity_id
            and wro2.organization_id = wti2.organization_id
            AND wti2.organization_id = wma2.organization_id (+)
            AND wti2.transaction_id = wma2.transaction_id (+)
            AND nvl(wma2.repetitive_schedule_id,0)
            = nvl(wro2.repetitive_schedule_id,0));

exception
   when NO_DATA_FOUND then
      null;
      /* The whole "group_id" may not have any such transactions */
end ;

/*=====================================================================+
 | PROCEDURE
 |   update_wip_req_operations_mmtt
 |
 | PURPOSE
 |   Updates the required quantity values of all the components.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

procedure update_wip_req_operations_mmtt
   (
     P_CPL_TXN_ID     IN     NUMBER,
     P_USER_ID  IN     NUMBER default -1,
     P_LOGIN_ID IN     NUMBER default -1,
     P_REQ_ID   IN     NUMBER default -1,
     P_APPL_ID  IN     NUMBER default -1,
     P_PROG_ID  IN     NUMBER default -1
     ) is
BEGIN

   UPDATE wip_requirement_operations wro
     SET (wro.required_quantity
          ,last_updated_by,
          last_update_date,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date ) =
     ( SELECT
       MIN(required_quantity)
       + Nvl(
             SUM(
                 Nvl(mmta1.primary_quantity, nvl(mmtt1.overcompletion_primary_qty,0))),0)
                 * MIN(quantity_per_assembly),
       Decode(p_user_id,-1,NULL,p_user_id),
       Sysdate,
       Decode(p_login_id,-1,NULL,p_login_id),
       Decode(p_req_id,-1,NULL,p_req_id),
       Decode(p_appl_id,-1,NULL,p_appl_id),
       Decode(p_prog_id,-1,NULL,p_prog_id),
       Decode(p_req_id,-1,NULL,Sysdate)
       FROM wip_requirement_operations wro1,
       mtl_material_transactions_temp mmtt1,
       mtl_material_txn_allocations mmta1
       WHERE
       wro1.ROWID = wro.ROWID
       -- The WO rows to be updated are identified by the rowids.
       -- For each such row, go back and sum the quantities from WMTI
       and mmtt1.completion_transaction_id = p_cpl_txn_id
       AND mmtt1.transaction_action_id = wip_constants.cplassy_action
       AND mmtt1.overcompletion_primary_qty IS NOT NULL
       AND wro1.wip_entity_id = mmtt1.transaction_source_id
       AND wro1.organization_id = mmtt1.organization_id
       AND mmtt1.organization_id = mmta1.organization_id (+)
       AND mmtt1.transaction_temp_id = mmta1.transaction_id (+)
       AND Nvl(mmta1.repetitive_schedule_id,0)
         = Nvl(wro1.repetitive_schedule_id,0)
         )
         WHERE wro.ROWID IN
         (
          SELECT wro2.ROWID FROM
          wip_requirement_operations wro2,
          mtl_material_transactions_temp mmtt2,
          mtl_material_txn_allocations mmta2
          WHERE
          mmtt2.transaction_action_id = wip_constants.cplassy_action
          AND mmtt2.overcompletion_primary_qty IS NOT NULL
          and mmtt2.completion_transaction_id = p_cpl_txn_id
          -- Picked a cpl txn
          AND wro2.wip_entity_id = mmtt2.transaction_source_id
          AND wro2.organization_id = mmtt2.organization_id
          AND mmtt2.organization_id = mmta2.organization_id (+)
          AND mmtt2.transaction_temp_id = mmta2.transaction_id (+)
          AND Nvl(mmta2.repetitive_schedule_id,0)
          = Nvl(wro2.repetitive_schedule_id,0));

exception
   when NO_DATA_FOUND then
      null;

end ;

/*=====================================================================+
 | PROCEDURE
 |   update_wip_operations
 |
 | PURPOSE
 |   Updates the quantity in the queue step of the from operation for
 |   the child move transactions
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
procedure update_wip_operations
   (
    p_txn_id   IN     NUMBER,    -- must be of the CHILD
    P_GROUP_ID IN     NUMBER,
    P_TXN_DATE IN     VARCHAR2,
    P_USER_ID  IN     NUMBER default -1,
    P_LOGIN_ID IN     NUMBER default -1,
    P_REQ_ID   IN     NUMBER default -1,
    P_APPL_ID  IN     NUMBER default -1,
    P_PROG_ID  IN     NUMBER default -1
    ) is
BEGIN
      update wip_operations wop
        set (quantity_in_queue
             ,last_updated_by
             , last_update_date,
             last_update_login, request_id, program_application_id,
             program_id, program_update_date  ) =
        (select
         wop.quantity_in_queue
         + wti1.primary_quantity,
         DECODE(P_user_id,-1,NULL,P_user_id),
         SYSDATE,
         DECODE(P_login_id,-1,NULL,P_login_id),
         DECODE(P_req_id,-1,NULL,P_req_id),
         DECODE(P_appl_id,-1,NULL,P_appl_id),
         DECODE(P_prog_id,-1,NULL,P_prog_id),
         DECODE(P_req_id,-1,NULL,SYSDATE)
         from
         wip_operations wop1,
         wip_move_txn_interface wti1,
         wip_move_txn_allocations wma1
         where
         wop1.rowid = wop.rowid
         -- The WO rows to be updated are identified by the rowids.
         -- For each such row, go back and sum the quantities from WMTI
         and wti1.group_id = p_group_id
         and TRUNC(wti1.transaction_date)
         = TO_DATE(P_TXN_DATE, WIP_CONSTANTS.DATE_FMT)
         AND wti1.transaction_id = p_txn_id
         and wop1.wip_entity_id = wti1.wip_entity_id
         and wop1.organization_id = wti1.organization_id
         and wop1.operation_seq_num = wti1.fm_operation_seq_num
         AND wti1.organization_id = wma1.organization_id (+)
         AND wti1.transaction_id = wma1.transaction_id (+)
         AND nvl(wma1.repetitive_schedule_id,0) = nvl(wop1.repetitive_schedule_id,0)
         )
        -- the select below must return just 1 row. When Online, group_id
        -- is the same as transaction_id. When in BG, then the transaction_id
        -- must be passed.
        where wop.rowid =
        (
         select wop2.rowid from
         wip_operations wop2,
         wip_move_txn_interface wti2,
         wip_move_txn_allocations wma2
         where
         wti2.group_id = p_group_id
         and TRUNC(wti2.transaction_date)
         = TO_DATE(P_TXN_DATE, WIP_CONSTANTS.DATE_FMT)
         and wti2.transaction_id = p_txn_id
         -- Picked a Move txn
         and wop2.wip_entity_id = wti2.wip_entity_id
         and wop2.organization_id = wti2.organization_id
         and wop2.operation_seq_num = wti2.fm_operation_seq_num
         AND wti2.organization_id = wma2.organization_id (+)
         AND wti2.transaction_id = wma2.transaction_id (+)
         AND nvl(wma2.repetitive_schedule_id,0) = nvl(wop2.repetitive_schedule_id,0)
         );
      -- Picked the row corresponding to the txn. 1 each for such txns
      -- Rowids can be duplicate because there might be 2 wmti records with
      -- the same fm_op

exception
   when NO_DATA_FOUND then
      null;

      /* The whole "group_id" may not have any such transactions */

END;


/*=====================================================================+
 | PROCEDURE
 |    undo_overcompletion
 |
 | PURPOSE
 |    Resets the "Required quantity" field of wip_requirement_operations
 |    during Unrelease of a Job since Overcompletions would have updated it
 |    if there were any overcompletions.
 |
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

PROCEDURE undo_overcompletion
                   (p_org_id        IN NUMBER,
                    p_wip_entity_id IN NUMBER,
                    p_rep_id        IN NUMBER DEFAULT NULL
                    ) is
BEGIN

   IF( nvl(p_rep_id, -1) = -1 ) THEN
      /*Bugfix:8838245.Changed below update to divide with component yield factor
        as yield is separated from quantity per assembly as part of component yield        factor project during R12 */
        update wip_requirement_operations wro
        set wro.required_quantity =
        ( select
          ( wro1.quantity_per_assembly * wdj.start_quantity)/wro1.component_yield_factor
          from
          wip_requirement_operations wro1,
          wip_discrete_jobs wdj
          WHERE
          wro1.rowid = wro.rowid
          and wro1.wip_entity_id = wdj.wip_entity_id
          AND wro1.organization_id = wdj.organization_id)
        where wro.wip_entity_id = p_wip_entity_id
        and wro.organization_id = p_org_id
	and wro.basis_type = wip_constants.ITEM_BASED_MTL;     /* Bug fix 9337675 */
    ELSIF ( p_rep_id > 0 ) then
      /*Bugfix:8838245.Changed below update to divide with component yield factor
        as yield is separated from quantity per assembly as part of component yield        factor project during R12 */
        update wip_requirement_operations wro
        set wro.required_quantity =
          ( select
            ( wro1.quantity_per_assembly *
              round(wrs.processing_work_days * wrs.daily_production_rate, 6))/wro1.component_yield_factor
            from
            wip_requirement_operations wro1,
            wip_repetitive_schedules wrs
            where
            wro1.rowid = wro.rowid
            and wro1.repetitive_schedule_id =wrs.repetitive_schedule_id
            AND wro1.organization_id = wrs.organization_id
            AND wro1.wip_entity_id = wrs.wip_entity_id
            )
          where
          wro.organization_id = p_org_id
          AND wro.wip_entity_id = p_wip_entity_id
          AND wro.repetitive_schedule_id = p_rep_id
      	  and wro.basis_type = wip_constants.ITEM_BASED_MTL;     /* Bug fix 9337675 */
   END IF;

END;

/*=====================================================================+
 | PROCEDURE
 |   insert_child_move_txn
 |
 | PURPOSE
 |      Inserts the child WIP Move transaction for an Overcomplete transaction.
 |
 | ARGUMENTS
 |
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE insert_child_move_txn
   (
    p_primary_quantity        IN   NUMBER,
    p_parent_txn_id           IN   NUMBER,
    p_move_profile            IN   NUMBER,
    p_sched_id                IN   NUMBER,
    p_user_id                 IN   NUMBER default -1,
    p_login_id                IN   NUMBER default -1,
    p_req_id                  IN   NUMBER default -1,
    p_appl_id                 IN   NUMBER default -1,
    p_prog_id                 IN   NUMBER default -1,
    p_child_txn_id         IN OUT NOCOPY  NUMBER,
    p_oc_txn_id               OUT NOCOPY  NUMBER,
    p_first_operation_seq_num OUT NOCOPY  NUMBER,
    p_first_operation_code    OUT NOCOPY  VARCHAR2,
    p_first_department_id     OUT NOCOPY  NUMBER,
    p_first_department_code   OUT NOCOPY  VARCHAR2,
    p_err_mesg                OUT NOCOPY  VARCHAR2
    ) is

       x_org_id                 NUMBER;
       x_wip_entity_id          NUMBER;
       x_line_id                NUMBER;
       x_first_schedule_id      NUMBER;
       x_result                 NUMBER := wip_constants.yes;
       x_sched_id               NUMBER;

       cursor get_move_transaction_id is
          select wip_transactions_s.nextval from dual;

   BEGIN

      if( p_sched_id is null OR p_sched_id < 0) then
        x_sched_id := NULL;
      else
        x_sched_id := p_sched_id;
      end if;

      p_err_mesg := NULL;
      p_oc_txn_id := NULL;
      p_first_operation_seq_num  := NULL;
      p_first_operation_code := NULL;
      p_first_department_id := NULL;
      p_first_department_code := NULL;
      p_err_mesg := NULL;

      /* Pick up the parent transaction and its associated details */

      SELECT
        organization_id,
        wip_entity_id,
        line_id,
        repetitive_schedule_id  /* first_schedule_id */
        INTO
        x_org_id,
        x_wip_entity_id,
        x_line_id,
        x_first_schedule_id
        FROM WIP_MOVE_TXN_INTERFACE
        WHERE
        transaction_id = p_parent_txn_id
        AND overcompletion_primary_qty IS NOT NULL
          ;


      IF( p_move_profile = wip_constants.background) THEN
         -- when the Move is done Online, the tolerance is validated in the
         -- form.
      x_result := wip_constants.no;
        check_tolerance(
                        x_org_id,
                        x_wip_entity_id,
                        x_sched_id,
                        p_primary_quantity,
                        x_result
                        );
      END IF;

        IF( x_result = wip_constants.no ) THEN
           fnd_message.set_name ('WIP', 'WIP_OC_TOLERANCE_FAIL');
           p_err_mesg := fnd_message.get;
           --p_err_mesg := 'Transaction violates Tolerance Level';
        ELSE
           IF(p_child_txn_id IS NULL OR
              p_child_txn_id = -1 OR
              p_child_txn_id = 0) THEN
             -- generate transaction_id
             open get_move_transaction_id;
             fetch get_move_transaction_id into p_child_txn_id;
             close get_move_transaction_id;
           END IF;

           open get_move_transaction_id;
           fetch get_move_transaction_id into p_oc_txn_id;
           close get_move_transaction_id;

           UPDATE wip_move_txn_interface
             SET overcompletion_transaction_id = p_oc_txn_id
             WHERE transaction_id = p_parent_txn_id;


           /* For the parent wip_entity_id, find the first operation */

           WIP_OPERATIONS_INFO.first_operation
             (
              p_org_id =>to_number(x_org_id),
              p_wip_entity_id => to_number(x_wip_entity_id),
              p_line_id => to_number(x_line_id),
              p_first_schedule_id => to_number(x_first_schedule_id),
              p_first_op_seq              => P_first_operation_seq_num,
              p_first_op_code             => P_first_operation_code,
              p_first_dept_id             => P_first_department_id,
              p_first_dept_code           => P_first_department_code);


           insert into wip_move_txn_interface
             (
              transaction_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              group_id,
              source_code,
              source_line_id,
              process_phase,
              process_status,
              organization_id,
              organization_code,
              wip_entity_id,
              wip_entity_name,
              entity_type,
              primary_item_id,
              line_id,
              line_code,
              repetitive_schedule_id,
              transaction_date,
              acct_period_id,
              fm_operation_seq_num,
              fm_operation_code,
              fm_department_id,
              fm_department_code,
              fm_intraoperation_step_type,
              to_operation_seq_num,
              to_operation_code,
              to_department_id,
              to_department_code,
              to_intraoperation_step_type,
              transaction_quantity,
              transaction_uom,
              primary_quantity,
             primary_uom,
             scrap_account_id,
             reason_id,
             reason_name,
             reference,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             transaction_type,
             qa_collection_id,
             overcompletion_transaction_id,
             overcompletion_transaction_qty,
             overcompletion_primary_qty
             ) (
                SELECT
                p_child_txn_id,
                Sysdate,               /* last_update_date, */
                p_user_id,             /* last_updated_by */
                SYSDATE,               /* creation_date */
                p_user_id,             /* created_by */
                p_login_id,            /* last_update_login */
                p_req_id,              /* request_id */
                p_appl_id,             /* program_application_id */
                p_prog_id,             /* program_id */
                decode(p_req_id, -1, NULL, SYSDATE), /* program_update_date */
                decode(p_move_profile, /* group_id */
                       wip_constants.online ,  p_child_txn_id,
                       wip_constants.background, wti.group_id),
                /* Use the parent''s group_id if in BG */
                NULL, /* source_code */
                NULL, /* source_line_id */
                WIP_CONSTANTS.MOVE_PROC,         /* process phase  */
                WIP_CONSTANTS.RUNNING,          /* process status */
                /* Process status is RUNNING even for BG,
                since the child record is
                inserted only when the parent is in Running status */
                organization_id,
                organization_code,
                wip_entity_id,
                wip_entity_name,
                entity_type,
             primary_item_id,
             line_id,
             line_code,
             repetitive_schedule_id,
             transaction_date,
             acct_period_id,
             P_first_operation_seq_num,
             P_first_operation_code,
             P_first_department_id,
             P_first_department_code,
             WIP_CONSTANTS.QUEUE,
             fm_operation_seq_num,
             fm_operation_code,
             fm_department_id,
             fm_department_code,
             fm_intraoperation_step_type,
             p_primary_quantity, /* transaction_quantity */
             primary_uom,        /* transaction_uom */
             p_primary_quantity,
             primary_uom,        /* primary_uom */
             scrap_account_id,
             NULL, /* reason_id, */
             NULL, /* reason_name, */
             NULL, /* reference, */
             NULL, /* attribute_category, */
             NULL, /* attribute1, */
             NULL, /* attribute2, */
             NULL, /* attribute3, */
             NULL, /* attribute4, */
             NULL, /* attribute5, */
             NULL, /* attribute6, */
             NULL, /* attribute7, */
             NULL, /* attribute8, */
             NULL, /* attribute9, */
             NULL, /* attribute10, */
             NULL, /* attribute11, */
             NULL, /* attribute12, */
             NULL, /* attribute13, */
             NULL, /* attribute14, */
             NULL, /* attribute15, */
             WIP_CONSTANTS.MOVE_TXN,
             NULL, /* qa_collection_id, */
             overcompletion_transaction_id,
             NULL, /* overcompletion_transaction_qty */
             NULL /* overcompletion_primary_qty */
             from wip_move_txn_interface wti
             where overcompletion_transaction_id = P_oc_txn_id
             and overcompletion_primary_qty IS NOT NULL
               );

        END IF;  -- if (x_result = no )
END;


 /*=====================================================================+
 | PROCEDURE
 |   delete_child_records
 |
 | PURPOSE
 |      This call would delete the child rows that have the fm_op &
 |      to_op to be the first operation and the step types to be
 |      'Queue'.
 |
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE delete_child_records
   ( p_group_id    IN   NUMBER,
     p_txn_date    IN   VARCHAR2,
     p_outcome     OUT NOCOPY  NUMBER) IS
   BEGIN

      DELETE FROM wip_move_txn_interface wti
        WHERE
        wti.group_id = p_group_id
        AND Trunc(wti.transaction_date)
        = TO_DATE(p_txn_date,WIP_CONSTANTS.date_fmt)
        AND wti.process_phase = wip_constants.move_proc
        AND wti.process_status = wip_constants.running
        AND wti.overcompletion_transaction_id IS NOT NULL
        AND wti.overcompletion_primary_qty IS NULL
        AND wti.fm_operation_seq_num = wti.to_operation_seq_num
        AND wti.fm_intraoperation_step_type = wti.to_intraoperation_step_type
        AND wti.fm_intraoperation_step_type = wip_constants.queue
        ;
        -- This first operation check is not necessary since, no other transaction
        -- will have their op seq and steps match !!
/*          AND exists
            ( SELECT 'x'
              FROM wip_operations wop
              WHERE
              wti.organization_id = wop.organization_id
              AND wti.wip_entity_id = wop.wip_entity_id
              AND wti.fm_operation_seq_num = wop.operation_seq_num
              AND wop.previous_operation_seq_num IS NULL
              -- First operation
              ); */

        if (SQL%found) THEN
           p_outcome := wip_constants.yes;
         ELSE
           p_outcome := wip_constants.no;
        END IF;


   EXCEPTION
      WHEN no_data_found THEN
         p_outcome := wip_constants.no;
         /* There may be no such Move records in WMTI */

   END delete_child_records;

 /*=====================================================================+
 | PROCEDURE
 |   check_tolerance
 |
 | PURPOSE
 |    This procedure would check if the transaciton primary quantity +
 | total quantity already in the job would still be less than the tolerance.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE check_tolerance
   (
    p_organization_id             IN   NUMBER,
    p_wip_entity_id               IN   NUMBER,
    p_repetitive_schedule_id      IN   NUMBER DEFAULT NULL,
    p_primary_quantity            IN   NUMBER,
    p_result                      OUT NOCOPY  NUMBER  -- 1 = yes, 2 = No
    ) IS
       x_total_qty NUMBER;
       x_repetitive_schedule_id NUMBER;
       l_default_tolerance NUMBER := NULL;
   BEGIN
      p_result := wip_constants.no;

      if(p_repetitive_schedule_id is null OR p_repetitive_schedule_id < 0) then
        x_repetitive_schedule_id := NULL;
      else
        x_repetitive_schedule_id := p_repetitive_schedule_id;
      end if;

      -- find default overcompletion tolerance for item without tolerance setting
      begin
        select  default_overcompl_tolerance
        into    l_default_tolerance
        from    wip_parameters
        where   organization_id = p_organization_id;
      exception
        when NO_DATA_FOUND then
          -- do nothing, and let the default tolerance to be 0
          NULL;
      end;

      if (l_default_tolerance IS NULL) then
        l_default_tolerance := 0;
      else
        l_default_tolerance := l_default_tolerance / 100;
      end if;


      wip_common.get_total_quantity
        (
         p_organization_id,
         p_wip_entity_id,
         x_repetitive_schedule_id,
         x_total_qty
         );

      IF( x_repetitive_schedule_id IS NULL) THEN

         SELECT
           Decode
           (
            Sign(
                 x_total_qty + p_primary_quantity - wdj.start_quantity -
                 Decode(wdj.overcompletion_tolerance_type,
                        wip_constants.percent,
                        wdj.start_quantity
                        * wdj.overcompletion_tolerance_value/100,
                        wip_constants.amount,
                        wdj.overcompletion_tolerance_value,
                        NULL,
             -- if both org and job tolerance is not set, need to offset the
             -- p_primary_quantity
                        decode(l_default_tolerance,
                               0, 0,
                               l_default_tolerance * wdj.start_quantity ))),
            1, wip_constants.no,
            0, wip_constants.yes,
            -1, wip_constants.yes
            )
           INTO p_result
           FROM wip_discrete_jobs wdj
           WHERE
           wdj.organization_id = p_organization_id
           AND wdj.wip_entity_id = p_wip_entity_id;

       ELSE
         SELECT
           Decode
           (
            Sign(
                 x_total_qty + p_primary_quantity -
                 (wrs.daily_production_rate * wrs.processing_work_days) -
                 Decode(wri.overcompletion_tolerance_type,
                        wip_constants.percent,
                        (wrs.daily_production_rate * wrs.processing_work_days)
                        * wri.overcompletion_tolerance_value/100,
                        wip_constants.amount,
                        wri.overcompletion_tolerance_value,
                        NULL,
                        decode(l_default_tolerance,
                               0,
                               0,
                               l_default_tolerance * wrs.daily_production_rate
                                    * wrs.processing_work_days))),
            1, wip_constants.no,
            0, wip_constants.yes,
            -1, wip_constants.yes
            )
           INTO p_result
           FROM wip_repetitive_items wri,
           wip_repetitive_schedules wrs
           WHERE
           wrs.organization_id = p_organization_id
           AND wrs.repetitive_schedule_id = x_repetitive_schedule_id
           AND wrs.organization_id = wri.organization_id
           AND wrs.wip_entity_id = wri.wip_entity_id
           AND wrs.line_id = wri.line_id;
      END IF;
   END;

 /*=====================================================================+
 | PROCEDURE
 |   get_tolerance_default
 |
 | PURPOSE
 |    This procedure takes as input the assembly item id and returns the
 | tolerance column values.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE get_tolerance_default
   (
    p_primary_item_id             IN      NUMBER,
    p_org_id                      IN      NUMBER,
    p_tolerance_type              OUT NOCOPY     NUMBER,
    p_tolerance_value             OUT NOCOPY     NUMBER
    ) IS
   BEGIN

      SELECT
        overcompletion_tolerance_type,
        overcompletion_tolerance_value
        INTO p_tolerance_type, p_tolerance_value
        FROM mtl_system_items msi
        WHERE
        msi.inventory_item_id = p_primary_item_id
        AND msi.organization_id = p_org_id;

   END;

/*=====================================================================+
 | PROCEDURE
 |   insert_oc_move_txn
 |
 | PURPOSE
 |      Inserts the child WIP Move transaction for an Overcomplete transaction.
 |   This is used for Assembly Completion
 | ARGUMENTS
 |
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE insert_oc_move_txn
   (
    p_primary_quantity        IN   NUMBER,
    p_cpl_profile             IN   NUMBER,
    p_oc_txn_id               IN   NUMBER,
    p_parent_cpl_txn_id       IN   NUMBER,
    p_first_schedule_id       IN   NUMBER,
    -- Have to pass this since it is not populated in MMTT !!
    p_user_id                 IN   NUMBER default -1,
    p_login_id                IN   NUMBER default -1,
    p_req_id                  IN   NUMBER default -1,
    p_appl_id                 IN   NUMBER default -1,
    p_prog_id                 IN   NUMBER default -1,
    p_child_txn_id            IN OUT NOCOPY  NUMBER,
    p_first_operation_seq_num OUT NOCOPY  NUMBER,
    p_err_mesg                OUT NOCOPY  VARCHAR2
    ) is

       x_result                 NUMBER;
       x_first_schedule_id      NUMBER;     /* dummy */
       x_org_code               VARCHAR2(3);
       x_line_code              VARCHAR2(10);
       x_first_operation_code   VARCHAR2(4);
       x_first_department_id    NUMBER;
       x_first_department_code  VARCHAR2(10);
       x_last_operation_code    VARCHAR2(4);
       x_last_department_id     NUMBER;
       x_last_department_code   VARCHAR2(10);

       x_org_id                 NUMBER;
       x_wip_entity_id          NUMBER;
       x_line_id                NUMBER;
       x_last_operation_seq_num NUMBER;

       CURSOR get_move_transaction_id is
          SELECT wip_transactions_s.nextval
            FROM dual;

   BEGIN

      p_err_mesg := NULL;
      p_first_operation_seq_num  := NULL;

      if( p_first_schedule_id is null OR p_first_schedule_id < 0) then
        x_first_schedule_id := NULL;
      else
        x_first_schedule_id  := p_first_schedule_id;
      end if;

      /* Pick up the parent transaction and its associated details */
           SELECT
             MIN(organization_id),
             MIN(transaction_source_id),
             MIN(repetitive_line_id),
             MIN(operation_seq_num)
             INTO x_org_id, x_wip_entity_id, x_line_id,
             x_last_operation_seq_num
             FROM mtl_material_transactions_temp
             WHERE completion_transaction_id = p_parent_cpl_txn_id
             AND transaction_action_id = wip_constants.cplassy_action;

        IF( x_result = wip_constants.no ) THEN
           fnd_message.set_name ('WIP', 'WIP_OC_TOLERANCE_FAIL');
           p_err_mesg := fnd_message.get;
           --p_err_mesg := 'Transaction violates Tolerance Level';

        ELSE
           if(p_child_txn_id is null or
              p_child_txn_id  <= 0) then
             -- generate transaction_id
             open get_move_transaction_id;
             fetch get_move_transaction_id into p_child_txn_id;
             close get_move_transaction_id;
           end if;

           SELECT organization_code
             INTO x_org_code
             FROM mtl_parameters
             WHERE organization_id = x_org_id;

           IF( x_line_id IS NOT NULL ) THEN
              SELECT line_code
                INTO x_line_code
                FROM wip_lines
                WHERE line_id = x_line_id;
           END IF;


           /* For the parent wip_entity_id, find the first operation */

           WIP_OPERATIONS_INFO.first_operation
             (
              p_org_id                    => to_number(x_org_id),
              p_wip_entity_id             => to_number(x_wip_entity_id),
              p_line_id                   => to_number(x_line_id),
              p_first_schedule_id         => to_number(x_first_schedule_id),
              p_first_op_seq              => p_first_operation_seq_num,
              p_first_op_code             => x_first_operation_code,
              p_first_dept_id             => x_first_department_id,
              p_first_dept_code           => x_first_department_code);

           select
             bso.operation_code,
             wo.department_id,
             bd.department_code
             INTO
             x_last_operation_code,
             x_last_department_id,
             x_last_department_code
             from   bom_standard_operations bso,
             bom_departments bd,
             wip_operations wo
             WHERE   wo.operation_seq_num = x_last_operation_seq_num
             AND     wo.department_id = bd.department_id
             AND     wo.standard_operation_id = bso.standard_operation_id (+)
             AND     wo.organization_id = x_org_id
             AND     wo.wip_entity_id = x_wip_entity_id
             AND     (wo.repetitive_schedule_id is NULL
                      OR
                      wo.repetitive_schedule_id = x_first_schedule_id);


           insert into wip_move_txn_interface
             (
              transaction_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              group_id,
              source_code,
              source_line_id,
              process_phase,
              process_status,
              organization_id,
              organization_code,
              wip_entity_id,
              wip_entity_name,
              entity_type,
              primary_item_id,
              line_id,
              line_code,
              repetitive_schedule_id,
              transaction_date,
              acct_period_id,
              fm_operation_seq_num,
              fm_operation_code,
              fm_department_id,
              fm_department_code,
              fm_intraoperation_step_type,
              to_operation_seq_num,
              to_operation_code,
              to_department_id,
              to_department_code,
              to_intraoperation_step_type,
              transaction_quantity,
              transaction_uom,
              primary_quantity,
             primary_uom,
             scrap_account_id,
             reason_id,
             reason_name,
             reference,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             transaction_type,
             qa_collection_id,
             overcompletion_transaction_id,
             overcompletion_transaction_qty,
             overcompletion_primary_qty
             ) (
                SELECT UNIQUE            /* Online may have several cpl txns */
                p_child_txn_id,
                Sysdate,                  /* last_update_date, */
                p_user_id,                /* last_updated_by */
                SYSDATE,                  /* creation_date */
                p_user_id,                /* created_by */
                p_login_id,               /* last_update_login */
                p_req_id,                 /* request_id */
                p_appl_id,                /* program_application_id */
                p_prog_id,                /* program_id */
                decode(p_req_id, -1, NULL, SYSDATE),  /* program_update_date */
                p_child_txn_id,
                /* group_id - Always Online, even when cpl is in BG */
                NULL,                     /* source_code */
                NULL,                     /* source_line_id */
                WIP_CONSTANTS.MOVE_PROC,  /* process phase  */
                decode(p_cpl_profile, WIP_CONSTANTS.ONLINE,
                        WIP_CONSTANTS.RUNNING,
                       WIP_CONSTANTS.BACKGROUND,
                        WIP_CONSTANTS.PENDING),
                /* process status. wiltws requires it to be in Pending */
                x_org_id,
                x_org_code,
                x_wip_entity_id,          /* wip_entity_id */
                mmtt.transaction_source_name,  /* wip_entity_name */
                mmtt.wip_entity_type,          /* entity_type */
                mmtt.inventory_item_id,        /* primary_item_id */
                x_line_id,                /* line_id */
                x_line_code,
                x_first_schedule_id,      /* repetitive_schedule_id */
                mmtt.transaction_date,
                mmtt.acct_period_id,
                p_first_operation_seq_num,
                x_first_operation_code,
                x_first_department_id,
                x_first_department_code,
                WIP_CONSTANTS.QUEUE,
                x_last_operation_seq_num,
                x_last_operation_code,
                x_last_department_id,
                x_last_department_code,
                wip_constants.tomove,     /* p_intraoperation_step_type */
                p_primary_quantity,       /* transaction_quantity */
                msi.primary_uom_code,    /* transaction_uom */
                p_primary_quantity,
                msi.primary_uom_code,    /* primary_uom */
                NULL,                     /* scrap_account_id */
                NULL,                     /* reason_id, */
                NULL,                     /* reason_name, */
                NULL,                     /* reference, */
                NULL,                     /* attribute_category, */
                NULL,                     /* attribute1, */
                NULL,                     /* attribute2, */
                NULL,                     /* attribute3, */
                NULL,                     /* attribute4, */
                NULL,                     /* attribute5, */
                NULL,                     /* attribute6, */
                NULL,                     /* attribute7, */
                NULL,                     /* attribute8, */
                NULL,                     /* attribute9, */
                NULL,                     /* attribute10, */
                NULL,                     /* attribute11, */
                NULL,                     /* attribute12, */
                NULL,                     /* attribute13, */
                NULL,                     /* attribute14, */
                NULL,                     /* attribute15, */
                WIP_CONSTANTS.MOVE_TXN,
                NULL,                     /* qa_collection_id, */
                p_oc_txn_id,              /* overcompletion_transaction_id */
                NULL,                     /* overcompletion_transaction_qty */
                NULL                      /* overcompletion_primary_qty */
             from mtl_material_transactions_temp mmtt,
                  mtl_system_items msi
             where
             mmtt.completion_transaction_id = p_parent_cpl_txn_id
             and mmtt.transaction_action_id = wip_constants.cplassy_action
             and mmtt.overcompletion_primary_qty IS NOT NULL
             and mmtt.inventory_item_id = msi.inventory_item_id
             and mmtt.organization_id = msi.organization_id
               );

        END IF;  -- if (x_result = no )
END;

END WIP_OVERCOMPLETION;

/

--------------------------------------------------------
--  DDL for Package Body CSTPPWRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWRO" AS
/* $Header: CSTPWROB.pls 120.10.12010000.2 2008/10/29 19:23:39 vjavli ship $ */

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURES/FUNCTIONS                                              |
*----------------------------------------------------------------------------*/

PROCEDURE charge_operation(
        p_pac_period_id IN      NUMBER,
        p_cost_group_id IN      NUMBER,
        p_cost_type_id  IN      NUMBER,
        p_org_id        IN      NUMBER,
        p_entity_id     IN      NUMBER,
        p_entity_type   IN      NUMBER,
        p_line_id       IN      NUMBER,
        p_op_seq        IN      NUMBER,
        p_pri_qty       IN      NUMBER,
        p_forward_flag  IN      NUMBER,
        p_user_id       IN      NUMBER,
        p_request_id    IN      NUMBER,
        p_prog_app_id   IN      NUMBER,
        p_prog_id       IN      NUMBER,
        p_login_id      IN      NUMBER,
        x_err_num       OUT NOCOPY      NUMBER,
        x_err_code      OUT NOCOPY      VARCHAR2,
        x_err_msg       OUT NOCOPY      VARCHAR2) ;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       charge_operation                                                     |
*----------------------------------------------------------------------------*/
PROCEDURE charge_operation(
        p_pac_period_id IN      NUMBER,
        p_cost_group_id IN      NUMBER,
        p_cost_type_id  IN      NUMBER,
        p_org_id        IN      NUMBER,
        p_entity_id     IN      NUMBER,
        p_entity_type   IN      NUMBER,
        p_line_id       IN      NUMBER,
        p_op_seq        IN      NUMBER,
        p_pri_qty       IN      NUMBER,
        p_forward_flag  IN      NUMBER,
        p_user_id       IN      NUMBER,
        p_request_id    IN      NUMBER,
        p_prog_app_id   IN      NUMBER,
        p_prog_id       IN      NUMBER,
        p_login_id      IN      NUMBER,
        x_err_num       OUT NOCOPY      NUMBER,
        x_err_code      OUT NOCOPY      VARCHAR2,
        x_err_msg       OUT NOCOPY      VARCHAR2)

IS

l_pri_qty               NUMBER;
l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(2000);
l_stmt_num              NUMBER;
cst_process_error       EXCEPTION;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_stmt_num := 5;

        ----------------------------------------------------------------------
        -- Check Forward flag
        ----------------------------------------------------------------------
        IF p_forward_flag = 1 THEN
                l_pri_qty := p_pri_qty;
        ELSE
                l_pri_qty := -1 * p_pri_qty;
        END IF;

        ----------------------------------------------------------------------
        -- Check and create , if necessary the WIPBAL record.
        ----------------------------------------------------------------------
        l_stmt_num := 10;

        check_pacwip_bal_record (p_pac_period_id => p_pac_period_id,
                                 p_cost_group_id => p_cost_group_id,
                                 p_cost_type_id  => p_cost_type_id,
                                 p_org_id        => p_org_id,
                                 p_entity_id     => p_entity_id,
                                 p_entity_type   => p_entity_type,
                                 p_line_id       => p_line_id,
                                 p_op_seq        => p_op_seq,
                                 p_user_id       => p_user_id,
                                 p_request_id    => p_request_id,
                                 p_prog_app_id   => p_prog_app_id,
                                 p_prog_id       => p_prog_id,
                                 p_login_id      => p_login_id,
                                 x_err_num       => l_err_num,
                                 x_err_code      => l_err_code,
                                 x_err_msg       => l_err_msg
                                );

        IF (l_err_num <>0) THEN

                l_err_msg := SUBSTR('Fail_check_bal_rec: ent/line/op'
                                             ||TO_CHAR(p_entity_id)
                                             ||'/'
                                             ||TO_CHAR(p_line_id)
                                             ||'/'
                                             ||TO_CHAR(p_op_seq)
                                             ||':'
                                             ||l_err_msg,1,2000);

                RAISE CST_PROCESS_ERROR;

        END IF;

        l_stmt_num := 15;

        UPDATE  wip_pac_period_balances wppb
        SET     wppb.operation_completed_units
                        = NVL(wppb.operation_completed_units,0) + l_pri_qty,
                wppb.last_update_date = SYSDATE,
                wppb.request_id = p_request_id,
                wppb.program_update_date = SYSDATE
        WHERE
                wppb.pac_period_id = p_pac_period_id
        AND     wppb.cost_group_id = p_cost_group_id
        AND     wppb.wip_entity_id = p_entity_id
        AND     NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
        AND     wppb.operation_seq_num = p_op_seq;

EXCEPTION

        WHEN CST_PROCESS_ERROR THEN
                x_err_num  := l_err_num;
                x_err_code := l_err_code;
                x_err_msg  := SUBSTR(l_err_msg,1,2000);

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWRO.charge_operation('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);

END charge_operation;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       check_pacwip_bal_record                                              |
*----------------------------------------------------------------------------*/
PROCEDURE check_pacwip_bal_record (
                        p_pac_period_id         IN      NUMBER,
                        p_cost_group_id         IN      NUMBER,
                        p_cost_type_id          IN      NUMBER,
                        p_org_id                IN      NUMBER,
                        p_entity_id             IN      NUMBER,
                        p_entity_type           IN      NUMBER,
                        p_line_id               IN      NUMBER,
                        p_op_seq                IN      NUMBER,
                        p_user_id               IN      NUMBER,
                        p_request_id            IN      NUMBER,
                        p_prog_app_id           IN      NUMBER,
                        p_prog_id               IN      NUMBER,
                        p_login_id              IN      NUMBER,
                        x_err_num               OUT NOCOPY      NUMBER,
                        x_err_code              OUT NOCOPY      VARCHAR2,
                        x_err_msg               OUT NOCOPY      VARCHAR2
                                )
IS

l_stmt_num              NUMBER;
l_err_num               NUMBER;
l_err_code              NUMBER;
l_err_msg               NUMBER;

BEGIN

        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';

        ----------------------------------------------------------------------
        -- Create Row if it does not exist
        ----------------------------------------------------------------------

        l_stmt_num := 5;

        INSERT INTO wip_pac_period_balances
        (
        pac_period_id,
        cost_group_id,
        cost_type_id,
        organization_id,
        wip_entity_id,
        wip_entity_type,
        line_id,
        operation_seq_num,
        operation_completed_units,
        relieved_assembly_units,
        tl_resource_in,
        tl_resource_out,
        tl_outside_processing_in,
        tl_outside_processing_out,
        tl_overhead_in,
        tl_overhead_out,
        pl_material_in,
        pl_material_out,
        pl_resource_in,
        pl_resource_out,
        pl_overhead_in,
        pl_overhead_out,
        pl_outside_processing_in,
        pl_outside_processing_out,
        pl_material_overhead_in,
        pl_material_overhead_out,
        /*added for _apull columns for bug#3229515*/
        pl_material_in_apull,
        pl_resource_in_apull,
        pl_overhead_in_apull,
        pl_outside_processing_in_apull,
        pl_material_overhead_in_apull,
        /*end of addition for bug#3229515*/
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login
        )
        SELECT
        p_pac_period_id,
        p_cost_group_id,
        p_cost_type_id,
        p_org_id,
        p_entity_id,
        p_entity_type,
        decode(p_entity_type, 4, null, p_line_id),
        p_op_seq,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id,
        p_request_id,
        p_prog_app_id,
        p_prog_id,
        SYSDATE,
        p_login_id
        FROM    DUAL
        WHERE NOT EXISTS
                ( SELECT        'X'
                  FROM          wip_pac_period_balances wppb2
                  WHERE         wppb2.pac_period_id = p_pac_period_id
                  AND           wppb2.cost_group_id = p_cost_group_id
                  AND           wppb2.wip_entity_id = p_entity_id
                  AND           NVL(wppb2.line_id,-99) = decode(p_entity_type,4,-99,NVL(p_line_id,-99))
                  AND           wppb2.operation_seq_num = p_op_seq
                );

EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWRO.check_pacwip_bal_record('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);

END check_pacwip_bal_record;


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       get_adj_operations                                                   |
*----------------------------------------------------------------------------*/

PROCEDURE get_adj_operations (
                                p_entity_id     IN      NUMBER,
                                p_line_id       IN      NUMBER,
                                p_rep_sched_id  IN      NUMBER,
                                p_op_seq        IN      NUMBER,
                                x_prev_op       OUT NOCOPY      NUMBER,
                                x_next_op       OUT NOCOPY      NUMBER,
                                x_err_num       OUT NOCOPY      NUMBER,
                                x_err_code      OUT NOCOPY      VARCHAR2,
                                x_err_msg       OUT NOCOPY      VARCHAR2)
IS

l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(2000);

/*Bug#3136153 - converted to cursor*/
CURSOR c_ops IS
        SELECT  wo.previous_operation_seq_num prev_op_seq,
                wo.next_operation_seq_num next_op_seq
        FROM    wip_operations wo
        WHERE   wo.wip_entity_id = p_entity_id
                AND NVL(wo.repetitive_schedule_id,-99)
                                = NVL(p_rep_sched_id,-99)
                AND wo.operation_seq_num = p_op_seq;
BEGIN

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';

        l_stmt_num := 5;
    OPEN c_ops;
        FETCH c_ops INTO x_prev_op,x_next_op;

         /*Bug#3136153 - Added the below code to deduce adj. ops. if
          current op. is deleted*/
        IF c_ops%NOTFOUND THEN /*current op has been deleted.*/
        /*Next op. is the  min(op_seq). with op_seq > current op.*/
            SELECT MIN(wo.operation_seq_num) next_op_seq
            INTO   x_next_op
            FROM   wip_operations wo
                WHERE  wo.wip_entity_id = p_entity_id
            AND NVL(wo.repetitive_schedule_id,-99)
                  = NVL(p_rep_sched_id,-99)
            AND wo.operation_seq_num > p_op_seq;
        /*Prev op. is that op. with next_op_seq as the next op. of current op.*/
               BEGIN
                        SELECT wo.operation_seq_num prev_op_seq
                        INTO   x_prev_op
                        FROM   wip_operations wo
                WHERE  wo.wip_entity_id = p_entity_id
                      AND NVL(wo.repetitive_schedule_id,-99)
                                        = NVL(p_rep_sched_id,-99)
                  AND nvl(wo.next_operation_seq_num,-99) = nvl(x_next_op,-99);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN /*This is first op*/
                       x_prev_op := null;
               END;
        END IF;
    CLOSE c_ops;
    /*End Bug#3136153*/
EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
        IF c_ops%ISOPEN THEN CLOSE c_ops; END IF; /*Bug#3136153*/
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWRO.get_adj_operations('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);


END get_adj_operations;

/*---------------------------------------------------------------------------*
|  PRIVATE FUNCTION                                                          |
|       check_operation_exists                                               |
|  added for bug#3136153                                                     |
*----------------------------------------------------------------------------*/
FUNCTION check_operation_exists(
        p_entity_id     IN      NUMBER,
                p_rep_sched_id  IN      NUMBER DEFAULT NULL,
                p_op_seq        IN      NUMBER)
RETURN BOOLEAN
IS
l_count NUMBER;
BEGIN
        SELECT count(*)
        INTO l_count
        FROM    wip_operations wo
        WHERE   wo.wip_entity_id = p_entity_id
                AND NVL(wo.repetitive_schedule_id,-99)
                                = NVL(p_rep_sched_id,-99)
                AND wo.operation_seq_num = p_op_seq;

       IF (l_count = 0) THEN
                return FALSE;
       ELSE
                return TRUE;
       END IF;
END;


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       build_wip_operation_qty                                              |
*----------------------------------------------------------------------------*/
PROCEDURE build_wip_operation_qty(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_entity_id             IN      NUMBER,
        p_entity_type           IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER,
        p_prog_app_id           IN      NUMBER,
        x_err_num               OUT NOCOPY      NUMBER,
        x_err_code              OUT NOCOPY      VARCHAR2,
        x_err_msg               OUT NOCOPY      VARCHAR2)
IS

l_stmt_num              NUMBER;
l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(2000);
l_curr_op_seq           NUMBER;
l_rep_sched_id          NUMBER;
l_wt                    NUMBER;
l_next_op               NUMBER;
l_prev_op               NUMBER;
l_forward_flag          NUMBER;
l_done                  NUMBER;
l_same_op               NUMBER;
l_counter               NUMBER;
l_rec_counter           NUMBER;
cst_process_error       EXCEPTION;

-------------------------------------------------------------------------------
        -- For repetitive entites:
        -- Get the repetitive schedule_id for this move transaction if
        -- the entity is a rep entity.  We need to know the sched id
        -- cause schedules can have different routing (and operations).
        -- We need to know exactly which operations of the routing
        -- are being charged.  We can only have rollforward or rollbackward
        -- between schedules that have the same routing.  In other words,
        -- all schedules in wip_txn_allocations tables for a given
        -- wip_transaction_id WILL HAVE THE SAME ROUTING.
        -- WIP_MOVE_TRANSACTIONS table does not store rep schedule_id
        -- therefore the only way to find the schedule (and thus the
        -- routing) for which this move transaction is being done is to
        -- join to wip_txn and wip_txn_alloc tables and get the appropriate
        -- schedule_id.
        -- Consider the follwoing two schedule routings for the same line_id:
        --      10--->20--->30--->40-->50       :SCHED-1
        --      10--->20--------->40------->60  :SCHED-2
        -- If a move is done from Op20 to Op40 we do not know whether to
        -- charge the intermediate Op30 unless we know for which schedule
        -- the move is being done for.

-------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- This cursor will give you all the move transactions for the given
-- entity/line that
--      1. Occured in this period and
--      2. NOT (in same Op Q/R--> Q/R or Rej/S/T --> Rej/S/T)
------------------------------------------------------------------------------

CURSOR c_wmt IS

        SELECT  wmt.organization_id org_id,
                wmt.transaction_id move_txn_id,
                wmt.wip_entity_id entity_id,
                wmt.line_id line_id,
                wmt.fm_operation_seq_num fm_op_seq,
                wmt.to_operation_seq_num to_op_seq,
                wmt.fm_intraoperation_step_type fm_step,
                wmt.to_intraoperation_step_type to_step,
                wmt.primary_quantity pri_qty
        FROM
                wip_move_transactions wmt
        WHERE   wmt.wip_entity_id = p_entity_id
        AND     wmt.transaction_date BETWEEN TRUNC(p_start_date)
                                     AND (TRUNC(p_end_date) + 0.99999)
        AND NOT  ( wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                           AND  (     (wmt.fm_intraoperation_step_type <=2
                                       AND wmt.to_intraoperation_step_type <= 2)
                                  OR  (wmt.fm_intraoperation_step_type  > 2
                                       AND wmt.to_intraoperation_step_type > 2)
                                )
                 );

BEGIN

        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_rec_counter := 0;


        ----------------------------------------------------------------------
        -- Build operation qty based on this period's moves
        ----------------------------------------------------------------------

        l_stmt_num := 5;

        FOR c_rec IN c_wmt LOOP

          --------------------------------------------------------------------
          --For each Move txn, determine whether move is forward or backward
          --------------------------------------------------------------------

          l_rec_counter := l_rec_counter + 1;
          l_forward_flag := 1;
          l_same_op := -1;
          l_counter := 0;
          l_done := -1;
          l_rep_sched_id := -99;

          l_stmt_num := 10;
          IF c_rec.fm_op_seq > c_rec.to_op_seq THEN
                l_forward_flag := -1;
          ELSIF c_rec.fm_op_seq = c_rec.to_op_seq THEN
                l_same_op := 1;
                IF c_rec.fm_step > c_rec.to_step THEN
                        l_forward_flag := -1;
                END IF;
          END IF;


          --------------------------------------------------------------------
          -- Process all operations
          --------------------------------------------------------------------

          l_curr_op_seq :=  c_rec.fm_op_seq;

          l_stmt_num := 15;

          WHILE (l_done  = -1 )LOOP
                l_counter := l_counter + 1;
                l_next_op := NULL;
                l_prev_op := NULL;

               /*bug#3136153  - Moved from l_stmt_num := 55*/
                l_stmt_num := 16;
                        -------------------------------------------------------
                        -- Attempt to find schedule_id if this is a rep entity
                        -- and the schedule has not already been found for
                        -- this record.
                        -------------------------------------------------------

                        IF (p_entity_type = 2 AND l_rep_sched_id = -99)
                        THEN

                          l_stmt_num := 17;

                          SELECT  NVL(MAX(wt.transaction_id),-99)
                          INTO    l_wt
                          FROM    wip_transactions wt
                          WHERE   wt.wip_entity_id = p_entity_id
                          AND     wt.line_id       = c_rec.line_id
                          AND     wt.move_transaction_id = c_rec.move_txn_id;

                          l_stmt_num := 18;

                          SELECT  NVL(MAX(wip_alloc.repetitive_schedule_id),-99)
                          INTO    l_rep_sched_id
                          FROM    wip_txn_allocations wip_alloc
                          WHERE   wip_alloc.transaction_id = l_wt;

                        END IF; --check to see if it is rep sched
               /*End of Move from l_stmt_num := 55*/

                --------------------------------------------------------------
                -- Move is in the same op
                --------------------------------------------------------------
                IF l_same_op = 1 THEN

                        l_stmt_num := 20;

                        l_done := 1;

                        ------------------------------------------------------
                        -- forward: charge if fm_step: Q/R to_step: T/S/Re
                        -- back: charged if fm_step T/S/Re to_step: Q/R
                        ------------------------------------------------------

                        IF ((c_rec.fm_step <= 2 AND c_rec.to_step > 2  AND
                                l_forward_flag = 1) OR
                           (c_rec.fm_step > 2 AND c_rec.to_step <= 2 AND
                                l_forward_flag = -1 ))
                        THEN
                                l_stmt_num := 23;
                                /*bug#3136153  -added if clause */
                                IF ((p_entity_type = 2 AND l_rep_sched_id = -99)
                                     OR
                                    (check_operation_exists(p_entity_id=>c_rec.entity_id,
                                                           p_rep_sched_id=>l_rep_sched_id,
                                                           p_op_seq=>c_rec.fm_op_seq))
                                     ) THEN
                                ----------------------------------------------
                                -- charge from_op_seq
                                ----------------------------------------------

                                l_stmt_num := 25;
                                charge_operation(p_pac_period_id,
                                        p_cost_group_id,
                                        p_cost_type_id,
                                        c_rec.org_id,
                                        c_rec.entity_id,
                                        p_entity_type,
                                        c_rec.line_id ,
                                        c_rec.fm_op_seq ,
                                        c_rec.pri_qty ,
                                        l_forward_flag,
                                        p_user_id,
                                        p_request_id,
                                        p_prog_app_id,
                                        p_prog_id,
                                        p_login_id,
                                        l_err_num,
                                        l_err_code,
                                        l_err_msg);

                                IF (l_err_num <>0) THEN
                                        RAISE CST_PROCESS_ERROR;
                                END IF;
                            END IF;
                        END IF;
                ELSE

                --------------------------------------------------------------
                -- Move is across operations
                --------------------------------------------------------------

                        ------------------------------------------------------
                        -- forward: from_op charged if fm_step Q/R
                        -- back: from_op charged if fm_step T/S/Re
                        ------------------------------------------------------

                        l_stmt_num := 30;

                        IF (c_rec.fm_op_seq = l_curr_op_seq) THEN
                                IF ((c_rec.fm_step <= 2 AND l_forward_flag = 1)
                                OR (c_rec.fm_step > 2 AND l_forward_flag = -1))
                        THEN
                                         l_stmt_num := 33;
                                 /*bug#3136153  -added if clase */
                                    IF ((p_entity_type = 2 AND l_rep_sched_id = -99)
                                            OR
                                           (check_operation_exists(p_entity_id=>c_rec.entity_id,
                                                           p_rep_sched_id=>l_rep_sched_id,
                                                           p_op_seq=>c_rec.fm_op_seq))
                                            )THEN
                                        --------------------------------------
                                        -- Charge fm_op_seq
                                        --------------------------------------

                                        l_stmt_num := 35;
                                        charge_operation(p_pac_period_id,
                                                p_cost_group_id,
                                                p_cost_type_id,
                                                c_rec.org_id,
                                                c_rec.entity_id ,
                                                p_entity_type,
                                                c_rec.line_id ,
                                                c_rec.fm_op_seq,
                                                c_rec.pri_qty ,
                                                l_forward_flag,
                                                p_user_id,
                                                p_request_id,
                                                p_prog_app_id,
                                                p_prog_id,
                                                p_login_id,
                                                l_err_num,
                                                l_err_code,
                                                l_err_msg);

                                        IF (l_err_num <>0) THEN
                                                RAISE CST_PROCESS_ERROR;
                                        END IF;
                                    END IF;
                                END IF;
                        ELSE

                                ----------------------------------------------
                                -- Check if curr op is the destination op
                                ----------------------------------------------

                                l_stmt_num := 40;
                /*bug#3136153 -added 2 if clauses
                l_done=1 if we reach/overshoot to_op*/
                 IF (l_curr_op_seq > c_rec.to_op_seq AND
                         l_forward_flag = 1) THEN
                    l_done := 1;
                 ELSIF (l_curr_op_seq < c_rec.to_op_seq AND
                         l_forward_flag = -1) THEN
                    l_done := 1;
                 ELSIF l_curr_op_seq = c_rec.to_op_seq THEN
                                        l_done := 1;

                                        ---------------------------------------
                                        -- forward: Charge if to_step T/S/Re
                                        -- back: Charge if to_step Q/R
                                        ---------------------------------------

                                        l_stmt_num := 45;

                                        IF ((c_rec.to_step > 2 AND
                                                l_forward_flag = 1 )
                                                OR (c_rec.to_step <=2
                                                AND l_forward_flag = -1))
                                        THEN
                                        l_stmt_num := 47;
                                 /*bug#3136153  -added if clase */
                                             IF ((p_entity_type = 2 AND l_rep_sched_id = -99)
                                                    OR
                                                    (check_operation_exists(p_entity_id=>c_rec.entity_id,
                                                           p_rep_sched_id=>l_rep_sched_id,
                                                           p_op_seq=>c_rec.to_op_seq))
                                                    )THEN
                                                charge_operation
                                                        (p_pac_period_id,
                                                        p_cost_group_id,
                                                        p_cost_type_id,
                                                        c_rec.org_id,
                                                        c_rec.entity_id ,
                                                        p_entity_type,
                                                        c_rec.line_id ,
                                                        c_rec.to_op_seq,
                                                        c_rec.pri_qty ,
                                                        l_forward_flag,
                                                        p_user_id,
                                                        p_request_id,
                                                        p_prog_app_id,
                                                        p_prog_id,
                                                        p_login_id,
                                                        l_err_num,
                                                        l_err_code,
                                                        l_err_msg);

                                                IF (l_err_num <>0) THEN
                                                        RAISE CST_PROCESS_ERROR;
                                                END IF;
                                            END IF;
                                        END IF;
                                ELSE

                                        ---------------------------------------
                                        -- Charge this intermediate curr op
                                        -- We ignore the autocharge flag.
                                        -- The relief formula is:
                                        -- value * txn_qty/op_qty
                                        -- We may have subtle inaccuracy
                                        -- when autocharge is off and
                                        -- a manual move to this op was made
                                        -- while there were other moves that
                                        -- skipped this operation (i.e. it was
                                        -- not charged.) In such case, since,
                                        -- we build op_qty for all moves (
                                        -- irrespective of autocharge) the
                                        -- operation will be underrelieved.
                                        -- In summary, the underlying
                                        -- assumption is autocharge controls
                                        -- op value not the qty.
                                        ---------------------------------------
                                        l_stmt_num := 49;
                                         /*bug#3136153  -added if clase */
                                        IF ((p_entity_type = 2 AND l_rep_sched_id = -99)
                                             OR
                                            (check_operation_exists(p_entity_id=>c_rec.entity_id,
                                                           p_rep_sched_id=>l_rep_sched_id,
                                                           p_op_seq=>l_curr_op_seq))
                                            )THEN
                                        l_stmt_num := 50;
                                        charge_operation(p_pac_period_id,
                                                p_cost_group_id,
                                                p_cost_type_id,
                                                c_rec.org_id,
                                                c_rec.entity_id ,
                                                p_entity_type,
                                                c_rec.line_id ,
                                                l_curr_op_seq,
                                                c_rec.pri_qty ,
                                                l_forward_flag,
                                                p_user_id,
                                                p_request_id,
                                                p_prog_app_id,
                                                p_prog_id,
                                                p_login_id,
                                                l_err_num,
                                                l_err_code,
                                                l_err_msg);

                                        IF (l_err_num <>0) THEN
                                                RAISE CST_PROCESS_ERROR;
                                        END IF;
                                    END IF;
                                END IF;
                        END IF; -- Check for first op

                        -------------------------------------------------------
                        -- forward: get Next operation
                        -- back: get previous operation
                        -------------------------------------------------------
                        /*bug#3136153  - Moved l_stmt_num 55,60,65 to 16,17,18 */
                        -------------------------------------------------------
                        -- Call next operation only if sched was found for line
                        -- or if the entity is not a repetitive entity
                        -------------------------------------------------------

                        l_stmt_num := 70;

                        IF (p_entity_type = 2 AND l_rep_sched_id= -99)
                        THEN

                                ----------------------------------------------
                                -- This means that we could not obtain
                                -- the repetitive scedule for this move.
                                -- Therefore, we will charge to_op and stop.
                                -- The fm_op has already been charged.
                                ----------------------------------------------

                                l_stmt_num := 75;
                                /* Bug 2670917. Changes for Bug 2624568
                                 * Check forward_flag before assigning
                                 * next operation */

                                IF l_forward_flag = 1 THEN

                                        l_next_op := c_rec.to_op_seq;
                                        l_prev_op := c_rec.fm_op_seq;
                                ELSE
                                        l_next_op := c_rec.fm_op_seq;
                                        l_prev_op := c_rec.to_op_seq;
                                END IF;

                        ELSE
                                l_stmt_num := 80;

                                get_adj_operations (p_entity_id,
                                        c_rec.line_id,
                                        l_rep_sched_id,
                                        l_curr_op_seq,
                                        l_prev_op,
                                        l_next_op,
                                        l_err_num,
                                        l_err_code,
                                        l_err_msg);

                                IF (l_err_num <> 0) THEN
                                        RAISE CST_PROCESS_ERROR;
                                END IF;

                        END IF; -- check line_id/rep_sched_id

                        l_stmt_num := 85;
            /*bug#3136153 -
            If we are reaching here, for curr move txn we are yet to
            reach/overshoot to_op.Need to exit if nowhere to go.
            This scenario is possible if first/last op was deleted.*/
            IF ((l_forward_flag=1 AND l_next_op IS NULL)
                 OR
               (l_forward_flag=-1 AND l_prev_op IS NULL))
            THEN
               l_done := 1;
            END IF;

                        IF l_forward_flag = 1 THEN
                                l_curr_op_seq := l_next_op;
                        ELSE
                                l_curr_op_seq := l_prev_op;
                        END IF;

                END IF; -- Move is past operations
          END LOOP; -- While loop for all intermediate ops
        END LOOP; -- Cursor loop for each move txn


EXCEPTION

        WHEN CST_PROCESS_ERROR THEN
                x_err_num := l_err_num;
                x_err_code := l_err_code;
                x_err_msg := l_err_msg;

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWRO.build_wip_operation_qty('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);

END build_wip_operation_qty;


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_wip_resovhd_txns                                             |
*----------------------------------------------------------------------------*/
PROCEDURE process_wip_resovhd_txns(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_item_id               IN      NUMBER,
        p_pac_ct_id             IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER,
        p_prog_app_id           IN      NUMBER,
        x_err_num               OUT NOCOPY      NUMBER,
        x_err_code              OUT NOCOPY      VARCHAR2,
        x_err_msg               OUT NOCOPY      VARCHAR2)

IS

l_acq_cost              NUMBER;
l_cfm_flag              NUMBER;
l_open_flag             VARCHAR2(1);
l_cost_element          NUMBER;
l_rbo_value             NUMBER;
l_stmt_num              NUMBER;
l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(2000);
l_pending_txns          NUMBER;
cst_process_error       EXCEPTION;
cst_fail_acq_cost       EXCEPTION;
cst_wip_pending_txns    EXCEPTION;

-- Variables added for eAM Support in PAC
l_return_status		VARCHAR2(1);
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(8000);
l_legal_entity_id       NUMBER;
l_eam_cost_element      NUMBER;

l_applied_value     NUMBER;
l_actual_cost       NUMBER;
l_del_qty           NUMBER;

-- Cursor to get all wip_entities in the Cost Group that has move transactions

CURSOR c_wip_entities_mov  IS
        SELECT  we.wip_entity_id entity_id,
                we.entity_type entity_type
        FROM    wip_entities we,
                cst_cost_group_assignments ccga
        WHERE   ccga.cost_group_id = p_cost_group_id
        AND     we.organization_id = ccga.organization_id
        AND     we.entity_type <> 4 -- NOT CFM
        AND     we.primary_item_id IS NOT NULL
        AND     EXISTS
                        (  SELECT  'X'
                           FROM    wip_move_transactions wmt
                           WHERE   wmt.wip_entity_id = we.wip_entity_id
                           AND     wmt.transaction_date BETWEEN
                                        TRUNC(p_start_date) AND
                                        (TRUNC(p_end_date) + 0.99999)
                        );

-- Cursor to get all wip_entities in the Cost Group that has resource transactions

CURSOR c_wip_entities_res  IS
        SELECT  we.wip_entity_id entity_id,
                we.entity_type entity_type,
                we.organization_id org_id
        FROM    wip_entities we,
                cst_cost_group_assignments ccga
        WHERE   ccga.cost_group_id = p_cost_group_id
        AND     we.organization_id = ccga.organization_id
        AND     EXISTS
                        (  SELECT  'X'
                           FROM    wip_transactions wt
                           WHERE   wt.wip_entity_id = we.wip_entity_id
                           AND     wt.transaction_type IN (1,2,3,17)
                           -- Direct Item txns should be picked too.
                           AND     wt.transaction_date BETWEEN
                                        TRUNC(p_start_date) AND
                                        (TRUNC(p_end_date) + 0.99999)
                           AND     ccga.organization_id = wt.organization_id
                        );

-- Cursor to process resource/OSP transaction for a given wip_entity/cost_type
-- It will get all resource/osp type records from WIP_TRANSACTIONS where the
-- resource/osp has a non zero rate defined for the PAC_RATES cost type.

CURSOR c_res_txn (      p_entity_id     NUMBER) IS
        SELECT  wt.transaction_id txn_id,
                wt.organization_id org_id,
                wt.wip_entity_id entity_id,
                wt.line_id line_id,
                wt.department_id dept_id,
                wt.operation_seq_num op_seq,
                wt.resource_id resource_id,
                wt.resource_seq_num resource_seq_num, -- Added for eAM project
                crc.resource_rate actual_cost,
                wt.transaction_type wip_txn_type,
                wt.primary_quantity applied_units,
                wt.primary_quantity*nvl(crc.resource_rate,0) applied_value,
		wt.rcv_transaction_id  -- Added for 4735668
        FROM    wip_transactions wt,
                cst_resource_costs crc,
                bom_resources br /* Bug 4641635; Include resources which are to be costed */

        WHERE   wt.wip_entity_id = p_entity_id
        AND     wt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
        AND     wt.transaction_type = 1 -- RES
  /* fix for bug 2988196 */
        AND     crc.resource_id(+) = wt.resource_id
        AND     crc.organization_id(+) = wt.organization_id
        AND     crc.cost_type_id(+) = p_pac_ct_id
        -- AND  crc.resource_rate <> 0
        /*Bug 4641635: Exclude resources with allow_costs_flag set to no*/
        AND     br.resource_id = wt.resource_id
        AND     br.allow_costs_flag = 1
        UNION ALL
        SELECT  wt.transaction_id txn_id,
                wt.organization_id org_id,
                wt.wip_entity_id entity_id,
                wt.line_id line_id,
                wt.department_id dept_id,
                wt.operation_seq_num op_seq,
                wt.resource_id resource_id,
                wt.resource_seq_num resource_seq_num, -- Added for eAM project
                0 actual_cost,
                wt.transaction_type wip_txn_type,
                wt.primary_quantity applied_units,
                0 applied_value,
		wt.rcv_transaction_id -- Added for 4735668
        FROM    wip_transactions wt,
                bom_resources br /* Bug 4641635; Include resources which are to be costed */
        WHERE   wt.wip_entity_id = p_entity_id
        AND     wt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
        AND     wt.transaction_type = 3 -- OSP
        /*Bug 4641635: Exclude resources with allow_costs_flag set to no */
        AND     br.resource_id = wt.resource_id
        AND     br.allow_costs_flag = 1
        UNION ALL
        /* Bug:4641635 Separating out the query for Direct Items */
        SELECT  wt.transaction_id txn_id,
                wt.organization_id org_id,
                wt.wip_entity_id entity_id,
                wt.line_id line_id,
                wt.department_id dept_id,
                wt.operation_seq_num op_seq,
                wt.resource_id resource_id,
                wt.resource_seq_num resource_seq_num, -- Added for eAM project
                0 actual_cost,
                wt.transaction_type wip_txn_type,
                nvl(wt.primary_quantity, rt.amount)  applied_units, /* Bug 4180323*/
                0 applied_value,
		wt.rcv_transaction_id -- Added for 4735668
        FROM    wip_transactions wt,
                rcv_transactions rt
        WHERE   wt.wip_entity_id = p_entity_id
        AND     rt.transaction_id = wt.rcv_transaction_id
        AND     wt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
        AND     wt.transaction_type = 17; -- Direct Items



-- Cursor to obtain all resource based overheads for a given org/dept/res/ct

CURSOR c_rbo (  p_resource_id   NUMBER,
                p_dept_id       NUMBER,
                p_org_id        NUMBER,
                p_res_units     NUMBER,
                p_res_value     NUMBER) IS

        SELECT  cdo.overhead_id ovhd_id,
                cdo.rate_or_amount actual_cost,
                cdo.basis_type basis_type,
                cdo.rate_or_amount * decode(cdo.basis_type,
                                3, p_res_units,
                                p_res_value) applied_value,
                decode(cdo.basis_type, 3, p_res_units,
                                p_res_value) basis_units
        FROM    cst_resource_overheads cro,
                cst_department_overheads cdo
        WHERE   cdo.department_id = p_dept_id
        AND     cdo.organization_id = p_org_id
        AND     cdo.cost_type_id = p_pac_ct_id
        AND     cdo.basis_type IN (3,4)
        AND     cro.cost_type_id = cdo.cost_type_id
        AND     cro.resource_id = p_resource_id
        AND     cro.overhead_id = cdo.overhead_id
        AND     cro.organization_id = cdo.organization_id;

-- Cursor to process move based ovhd transaction for a given entity/cost_type
-- It will get all overhead type records from WIP_TRANSACTIONS where the
-- overhead has a non zero rate defined for the PAC_RATES cost type.

CURSOR c_mbo_txn(       p_entity_id     NUMBER) IS
        SELECT  wt.transaction_id txn_id,
                wt.organization_id org_id,
                wt.wip_entity_id entity_id,
                wt.line_id line_id,
                wt.operation_seq_num op_seq,
                wt.department_id dept_id,
                wta.resource_id overhead_id,
                cdo.rate_or_amount actual_cost,
                wt.basis_type basis_type,
                wt.primary_quantity*cdo.rate_or_amount applied_value
        FROM
                wip_transactions wt,
                wip_transaction_accounts wta,
                cst_department_overheads cdo
        WHERE   wt.wip_entity_id = p_entity_id
        AND     wt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
        AND     wt.transaction_type = 2 -- MBO
        AND     wta.transaction_id = wt.transaction_id
        AND     wta.accounting_line_type = 3
        AND     wta.cost_element_id = 5
        AND     cdo.department_id = wt.department_id
        AND     cdo.overhead_id = wta.resource_id
        AND     cdo.cost_type_id = p_pac_ct_id
        AND     NVL(wta.repetitive_schedule_id,-99) =
                        (SELECT  NVL(MAX(wip_alloc.repetitive_schedule_id),-99)
                         FROM    wip_txn_allocations wip_alloc
                         WHERE   wip_alloc.transaction_id = wt.transaction_id
                         AND     rownum = 1
                        )
        AND     cdo.rate_or_amount <> 0
        ORDER BY wt.transaction_id;

BEGIN

        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_acq_cost := 0;
        l_pending_txns := 0;

        l_return_status	:= FND_API.G_RET_STS_SUCCESS;
        l_msg_count		:= 0;
        l_msg_data		:= '';
        l_legal_entity_id := 0 ;
        l_eam_cost_element := 0;



        ----------------------------------------------------------------------
        -- Error out if there are any pending txns
        ----------------------------------------------------------------------

        l_stmt_num := 5;

        SELECT  count(*)
        INTO    l_pending_txns
        FROM    wip_cost_txn_interface wcti
        WHERE   wcti.transaction_date BETWEEN TRUNC(p_start_date)
                                      AND (TRUNC(p_end_date) + 0.99999)
        AND     wcti.transaction_type IN (1,2,3,6)
        AND     EXISTS (
                          SELECT  'X'
                          FROM    cst_cost_group_assignments ccga
                          WHERE   ccga.cost_group_id = p_cost_group_id
                          AND     ccga.organization_id = wcti.organization_id
                        );

        IF (l_pending_txns <> 0) THEN

                RAISE CST_WIP_PENDING_TXNS;

        END IF;

        -- Select the legal entity for the pac period, to be used in eAM part
        SELECT legal_entity
        INTO   l_legal_entity_id
        FROM   cst_pac_periods
        WHERE  pac_period_id = p_pac_period_id;

        l_stmt_num := 7;

        ----------------------------------------------------------------------
        -- Process Non-CFM WIP entities with move transactions
        ----------------------------------------------------------------------
        l_stmt_num := 10;

        FOR c_ent_mov_rec IN c_wip_entities_mov LOOP
          ------------------------------------------------------
          -- Update op qty snapshot for this entity based on
          -- this period's move txns.
          ------------------------------------------------------

          l_stmt_num := 15;

          build_wip_operation_qty (
            p_pac_period_id => p_pac_period_id ,
            p_start_date    => p_start_date,
            p_end_date      => p_end_date,
            p_cost_group_id => p_cost_group_id,
            p_cost_type_id  => p_cost_type_id,
            p_entity_id     => c_ent_mov_rec.entity_id,
            p_entity_type   => c_ent_mov_rec.entity_type,
            p_user_id       => p_user_id,
            p_login_id      => p_login_id,
            p_request_id    => p_request_id,
            p_prog_id       => p_prog_id,
            p_prog_app_id   => p_prog_app_id,
            x_err_num       => l_err_num,
            x_err_code      => l_err_code,
            x_err_msg       => l_err_msg);

          IF (l_err_num <> 0) THEN
            l_err_msg := SUBSTR('fail_build_wip_op entity: '
                                ||TO_CHAR(c_ent_mov_rec.entity_id)
                                ||':'
                                ||l_err_msg,1,2000);
            RAISE CST_PROCESS_ERROR;
          END IF;

        END LOOP;

        ----------------------------------------------------------------------
        -- Process WIP entities with resource transactions
        ----------------------------------------------------------------------
        l_stmt_num := 20;

        FOR c_ent_rec IN c_wip_entities_res LOOP

          --------------------------------------------------------------
          -- Get Resource/OSP (and RBO) Transactions
          --------------------------------------------------------------

          l_stmt_num := 25;

          FOR c_res_rec IN c_res_txn(c_ent_rec.entity_id) LOOP

                l_stmt_num := 30;

                check_pacwip_bal_record (p_pac_period_id => p_pac_period_id,
                        p_cost_group_id         => p_cost_group_id,
                        p_cost_type_id          => p_cost_type_id,
                        p_org_id                => c_res_rec.org_id,
                        p_entity_id             => c_res_rec.entity_id,
                        p_entity_type           => c_ent_rec.entity_type,
                        p_line_id               => c_res_rec.line_id,
                        p_op_seq                => c_res_rec.op_seq,
                        p_user_id               => p_user_id,
                        p_request_id            => p_request_id,
                        p_prog_app_id           => p_prog_app_id,
                        p_prog_id               => p_prog_id,
                        p_login_id              => p_login_id,
                        x_err_num               => l_err_num,
                        x_err_code              => l_err_code,
                        x_err_msg               => l_err_msg
                        );

                IF (l_err_num <> 0) THEN
                         l_err_msg := SUBSTR('fail_bal_rec entity: '
                                                ||TO_CHAR(c_res_rec.entity_id)
                                                ||':'
                                                ||l_err_msg,1,2000);
                        RAISE CST_PROCESS_ERROR;
                END IF;

                l_stmt_num := 35;

                IF c_res_rec.wip_txn_type = 1 THEN   --RES

                  l_stmt_num := 40;

                  UPDATE wip_pac_period_balances wppb
                  SET    tl_resource_in = NVL(tl_resource_in,0) +
                                                c_res_rec.applied_value,
                         request_id = p_request_id,
                         last_update_date = SYSDATE,
                         program_update_date = SYSDATE
                  WHERE  wppb.pac_period_id = p_pac_period_id
                  AND    wppb.cost_group_id = p_cost_group_id
                  AND    wppb.wip_entity_id = c_res_rec.entity_id
                  AND    NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                  AND    wppb.operation_seq_num = c_res_rec.op_seq;

                /* Bug 4180323- Initializing the variables so that correct value is inserted into
                   wip_pac_actual_cost_details table
                */

                  l_actual_cost   := c_res_rec.actual_cost;
                  l_applied_value := c_res_rec.applied_value;

                -- Check if eAM entity then compute actuals
                  IF c_ent_rec.entity_type in (6,7) THEN /* Also include closed WO for Actuals Bug 5366094 */
                    CST_PacEamCost_GRP.Compute_PAC_JobActuals(
                                    p_api_version      => 1.0,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_legal_entity_id  => l_legal_entity_id,
                                    p_cost_group_id    => p_cost_group_id,
                                    p_cost_type_id     => p_cost_type_id,
                                    p_pac_period_id    => p_pac_period_id,
                                    p_pac_ct_id        => p_pac_ct_id,
                                    p_organization_id  => c_res_rec.org_id,
                                    p_txn_mode         => 2,
                                    p_txn_id           => c_res_rec.txn_id,
                                    p_value            => c_res_rec.applied_value,
                                    p_wip_entity_id    => c_res_rec.entity_id,
                                    p_op_seq           => c_res_rec.op_seq,
                                    p_resource_id      => c_res_rec.resource_id,
                                    p_resource_seq_num => c_res_rec.resource_seq_num,
                                    p_user_id          => p_user_id,
                                    p_request_id       => p_request_id,
                                    p_prog_app_id      => p_prog_app_id,
                                    p_prog_id          => p_prog_id,
                                    p_login_id         => p_login_id);

                    l_stmt_num := 43;

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_err_msg := SUBSTR('fail_RES_PAC_comt_jobAct ent/res_id : '
                                                ||TO_CHAR(c_res_rec.entity_id)
                                                ||'/'
                                                ||TO_CHAR(c_res_rec.resource_id)
                                                ||': (' || to_char(l_stmt_num) || '): '
                                                ||l_err_msg,1,2000);
                        RAISE CST_PROCESS_ERROR;
                  END IF;

                  End if; -- end eAM check

                ELSIF c_res_rec.wip_txn_type = 3 THEN  --OSP

                  ------------------------------------------------------------
                  -- Call acquisition cost Procedure to get the per unit
                  -- cost of this  osp receipt transaction.
                  ------------------------------------------------------------

                  l_stmt_num := 45;
                  CSTPPACQ.get_acq_cost(
                                i_cost_group_id => p_cost_group_id,
                                i_cost_type_id  => p_cost_type_id,
                                i_txn_id        => c_res_rec.txn_id,
                                i_wip_inv_flag  => 'W',
                                o_acq_cost      => l_acq_cost,
                                o_err_num       => l_err_num,
                                o_err_code      => l_err_code,
                                o_err_msg       => l_err_msg);


                  IF (l_err_num <>0) THEN
                         l_err_msg := SUBSTR('fail_acq_cost txn: '
                                                ||TO_CHAR(c_res_rec.txn_id)
                                                ||' '
                                                ||l_err_msg,1,2000);
                        RAISE CST_FAIL_ACQ_COST;
                  END IF;


                  l_stmt_num := 47;

                  l_acq_cost      := NVL(l_acq_cost,0);
                  l_actual_cost   := l_acq_cost;

		  /* Added for bug4735668 to get the primary quantity of deliver
                     as acquistion cost would be in the UOM of receipt */
                  SELECT rt.primary_quantity
                  INTO   l_del_qty
                  FROM   RCV_TRANSACTIONS RT
                  WHERE  rt.transaction_id = c_res_rec.rcv_transaction_id;

                 /* FP Bug 7346249 fix: check for -ve quantities */
                 IF Sign(c_res_rec.applied_units) = -1 THEN
                   l_del_qty := -1 * l_del_qty;
                 END IF;

                  l_applied_value := l_acq_cost * l_del_qty;


                  l_stmt_num := 50;

                  UPDATE wip_pac_period_balances wppb
                  SET    tl_outside_processing_in =
                                NVL(tl_outside_processing_in,0) +
                                        l_applied_value,
                         request_id = p_request_id,
                         last_update_date = SYSDATE,
                         program_update_date = SYSDATE
                  WHERE  wppb.pac_period_id = p_pac_period_id
                  AND    wppb.cost_group_id = p_cost_group_id
                  AND    wppb.wip_entity_id = c_res_rec.entity_id
                  AND    NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                  AND    wppb.operation_seq_num = c_res_rec.op_seq;

                  -- Check if eAM entity then compute actuals
                  IF c_ent_rec.entity_type in (6,7) THEN /* Also include closed WO for Actuals Bug 5366094*/

                      l_stmt_num := 52;

                      CST_PacEamCost_GRP.Compute_PAC_JobActuals(
                                    p_api_version      => 1.0,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_legal_entity_id  => l_legal_entity_id,
                                    p_cost_group_id    => p_cost_group_id,
                                    p_cost_type_id     => p_cost_type_id,
                                    p_pac_period_id    => p_pac_period_id,
                                    p_pac_ct_id        => p_pac_ct_id,
                                    p_organization_id  => c_res_rec.org_id,
                                    p_txn_mode         => 2,
                                    p_txn_id           => c_res_rec.txn_id,
                                    p_value            => l_applied_value,
                                    p_wip_entity_id    => c_res_rec.entity_id,
                                    p_op_seq           => c_res_rec.op_seq,
                                    p_resource_id      => c_res_rec.resource_id,
                                    p_resource_seq_num => c_res_rec.resource_seq_num,
                                    p_user_id          => p_user_id,
                                    p_request_id       => p_request_id,
                                    p_prog_app_id      => p_prog_app_id,
                                    p_prog_id          => p_prog_id,
                                    p_login_id         => p_login_id);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_err_msg := SUBSTR('fail_OSP_PAC_comt_jobAct ent/res_id : '
                                                ||TO_CHAR(c_res_rec.entity_id)
                                                ||'/'
                                                ||TO_CHAR(c_res_rec.resource_id)
                                                ||': (' || to_char(l_stmt_num) || '): '
                                                ||l_err_msg,1,2000);
                        RAISE CST_PROCESS_ERROR;
                  END IF;

                  END IF; -- end eAM check

                END IF;

                -- Check if eAM entity and Direct Item txn
                IF (c_ent_rec.entity_type in (6,7) /* Also include closed WO for Actuals Bug 5366094 */
                    AND c_res_rec.wip_txn_type = 17) THEN

                        CSTPPACQ.get_acq_cost(
                                i_cost_group_id => p_cost_group_id,
                                i_cost_type_id  => p_cost_type_id,
                                i_txn_id        => c_res_rec.txn_id,
                                i_wip_inv_flag  => 'W',
                                o_acq_cost      => l_acq_cost,
                                o_err_num       => l_err_num,
                                o_err_code      => l_err_code,
                                o_err_msg       => l_err_msg);

                        IF (l_err_num <>0) THEN
                                l_err_msg := SUBSTR('fail_acq_cost txn: '
                                                    ||TO_CHAR(c_res_rec.txn_id) ||' '
                                                   ||l_err_msg,1,2000);
                                RAISE CST_FAIL_ACQ_COST;
                        END IF;


                        l_stmt_num := 54;

                        l_acq_cost    :=NVL(l_acq_cost,0);
                        l_actual_cost := l_acq_cost;

                          l_applied_value := l_acq_cost * c_res_rec.applied_units;

                        CST_PacEamCost_GRP.Compute_PAC_JobActuals(
                                    p_api_version      => 1.0,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_legal_entity_id  => l_legal_entity_id,
                                    p_cost_group_id    => p_cost_group_id,
                                    p_cost_type_id     => p_cost_type_id,
                                    p_pac_period_id    => p_pac_period_id,
                                    p_pac_ct_id        => p_pac_ct_id,
                                    p_organization_id  => c_res_rec.org_id,
                                    p_txn_mode         => 17,
                                    p_txn_id           => c_res_rec.txn_id,
                                    p_value            => l_applied_value,
                                    p_wip_entity_id    => c_res_rec.entity_id,
                                    p_op_seq           => c_res_rec.op_seq,
                                    p_resource_id      => c_res_rec.resource_id,
                                    p_resource_seq_num => c_res_rec.resource_seq_num,
                                    p_user_id          => p_user_id,
                                    p_request_id       => p_request_id,
                                    p_prog_app_id      => p_prog_app_id,
                                    p_prog_id          => p_prog_id,
                                    p_login_id         => p_login_id);

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          l_err_msg := SUBSTR('fail_DIR_PAC_comt_jobAct ent/res_id : '
                                                ||TO_CHAR(c_res_rec.entity_id)
                                                ||'/'
                                                ||TO_CHAR(c_res_rec.resource_id)
                                                ||': (' || to_char(l_stmt_num) || '): '
                                                ||l_err_msg,1,2000);
                          RAISE CST_PROCESS_ERROR;
                        END IF;

                        -- get the direct item cost element
                        CST_EAMCOST_PUB.get_CostEle_for_DirectItem (
                                                p_api_version     =>  1.0,
                                                x_return_status   =>  l_return_status,
                                                x_msg_count       =>  l_msg_count,
                                                x_msg_data        =>  l_msg_data,
                                                p_txn_id          =>  c_res_rec.txn_id,
                                                p_mnt_or_mfg      =>  2,
                                                p_pac_or_perp     =>  1,
                                                x_cost_element_id =>  l_eam_cost_element);

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          l_err_msg := SUBSTR('fail_get_CostEle_for_DirectItem txn_id : '
                                                ||TO_CHAR(c_res_rec.txn_id)
                                                ||': (' || to_char(l_stmt_num) || '): '
                                                ||l_err_msg,1,2000);
                          RAISE CST_PROCESS_ERROR;
                        END IF;

                          l_stmt_num := 56;


                        /* Check for cost element of direct item to update the required
                        colimns. */

                        IF l_eam_cost_element = 1 THEN

                               /* Update PL-material for materials */
                               UPDATE  wip_pac_period_balances wppb
                               SET     pl_material_in =
                                          NVL(pl_material_in,0) +
                                          l_applied_value,
                                       request_id = p_request_id,
                                       last_update_date = SYSDATE,
                                       program_update_date = SYSDATE
                               WHERE   wppb.pac_period_id = p_pac_period_id
                               AND     wppb.cost_group_id = p_cost_group_id
                               AND     wppb.wip_entity_id = c_res_rec.entity_id
                               AND     NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                               AND     wppb.operation_seq_num = c_res_rec.op_seq;

                               l_stmt_num := 58;

                        ELSIF l_eam_cost_element = 3 THEN

                               /* Update PL-resource for Resources */
                               UPDATE  wip_pac_period_balances wppb
                               SET     pl_resource_in = NVL(pl_resource_in,0)
                                                + l_applied_value,
                                       request_id = p_request_id,
                                       last_update_date = SYSDATE,
                                       program_update_date = SYSDATE
                               WHERE   wppb.pac_period_id = p_pac_period_id
                               AND     wppb.cost_group_id = p_cost_group_id
                               AND     wppb.wip_entity_id = c_res_rec.entity_id
                               AND     NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                               AND     wppb.operation_seq_num = c_res_rec.op_seq;

                               l_stmt_num := 60;

                         ELSE

                               /* Update PL-OSP cols for OSP */
                               UPDATE  wip_pac_period_balances wppb
                               SET     pl_outside_processing_in =
                                       NVL (pl_outside_processing_in,0) +
                                            l_applied_value,
                                       request_id = p_request_id,
                                       last_update_date = SYSDATE,
                                       program_update_date = SYSDATE
                               WHERE   wppb.pac_period_id = p_pac_period_id
                               AND     wppb.cost_group_id = p_cost_group_id
                               AND     wppb.wip_entity_id = c_res_rec.entity_id
                               AND     NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                               AND     wppb.operation_seq_num = c_res_rec.op_seq;

                               l_stmt_num := 62;

                        END IF; -- IF l_eam_cost_element

                END IF; -- END for Direct Items

                --------------------------------------------------------------
                -- Insert Res/OSP txn costs in WPTCD
                --------------------------------------------------------------

                l_stmt_num := 64;

                INSERT INTO wip_pac_actual_cost_details
                    (
                      pac_period_id,
                      cost_group_id,
                      cost_type_id,
                      transaction_id,
                      level_type,
                      cost_element_id,
                      resource_id,
                      basis_resource_id,
                      transaction_costed_date,
                      actual_cost,
                      actual_value,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      last_update_login
                    )
                SELECT
                      p_pac_period_id,
                      p_cost_group_id,
                      p_cost_type_id,
                      c_res_rec.txn_id,
                      1,                         -- Level Type
                      decode(c_res_rec.wip_txn_type,
                                1, 3,
                                3, 4,
                                17,l_eam_cost_element), -- Cost element_id
                                -- Insert Direct Item cost element id here too.
                      c_res_rec.resource_id,
                      NULL,                      -- basis_res_id
                      SYSDATE,
                      l_actual_cost,
                      l_applied_value,
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM DUAL;

                --------------------------------------------------------------
                -- Get all Res Based Ovhds for this resource/dept/ct
                --------------------------------------------------------------

                l_stmt_num := 66;

                FOR c_rbo_rec IN c_rbo (c_res_rec.resource_id,
                                        c_res_rec.dept_id,
                                        c_res_rec.org_id,
                                        c_res_rec.applied_units,
                                        l_applied_value)
                LOOP
                  IF (c_rbo_rec.applied_value <> 0) THEN

                    l_stmt_num := 70;

                    UPDATE wip_pac_period_balances wppb
                    SET  tl_overhead_in = NVL(tl_overhead_in,0) +
                                                c_rbo_rec.applied_value,
                         request_id = p_request_id,
                         last_update_date = SYSDATE,
                         program_update_date = SYSDATE
                    WHERE        wppb.pac_period_id = p_pac_period_id
                    AND  wppb.cost_group_id = p_cost_group_id
                    AND  wppb.wip_entity_id = c_res_rec.entity_id
                    AND  NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_res_rec.line_id,-99))
                    AND  wppb.operation_seq_num = c_res_rec.op_seq;


                    -- Check if eAM entity then compute actuals
                    IF c_ent_rec.entity_type in (6,7) THEN /* Also include closed WO for Actuals Bug 5366094 */
                        CST_PacEamCost_GRP.Compute_PAC_JobActuals(
                                    p_api_version      => 1.0,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_legal_entity_id  => l_legal_entity_id,
                                    p_cost_group_id    => p_cost_group_id,
                                    p_cost_type_id     => p_cost_type_id,
                                    p_pac_period_id    => p_pac_period_id,
                                    p_pac_ct_id        => p_pac_ct_id,
                                    p_organization_id  => c_res_rec.org_id,
                                    p_txn_mode         => 2,
                                    p_txn_id           => c_res_rec.txn_id,
                                    p_value            => c_rbo_rec.applied_value,
                                    p_wip_entity_id    => c_res_rec.entity_id,
                                    p_op_seq           => c_res_rec.op_seq,
                                    p_resource_id      => c_res_rec.resource_id,
                                    p_resource_seq_num => c_res_rec.resource_seq_num,
                                    p_user_id          => p_user_id,
                                    p_request_id       => p_request_id,
                                    p_prog_app_id      => p_prog_app_id,
                                    p_prog_id          => p_prog_id,
                                    p_login_id         => p_login_id);
                    End if; /* end eAM check */

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       l_err_msg := SUBSTR('fail_RBO_PAC_comt_jobAct ent/res_id : '
                                                ||TO_CHAR(c_res_rec.entity_id)
                                                ||'/'
                                                ||TO_CHAR(c_res_rec.resource_id)
                                                ||': (' || to_char(l_stmt_num) || '): '
                                                ||l_err_msg,1,2000);
                        RAISE CST_PROCESS_ERROR;
                    END IF;

                    l_stmt_num := 75;

                    INSERT INTO wip_pac_actual_cost_details
                    (
                      pac_period_id,
                      cost_group_id,
                      cost_type_id,
                      transaction_id,
                      level_type,
                      cost_element_id,
                      resource_id,
                      basis_resource_id,
                      transaction_costed_date,
                      actual_cost,
                      actual_value,
                      basis_type,
                      basis_units,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      last_update_login
                    )
                    SELECT
                      p_pac_period_id,
                      p_cost_group_id,
                      p_cost_type_id,
                      c_res_rec.txn_id,
                      1,                         -- Level Type
                      5,                         -- CE
                      c_rbo_rec.ovhd_id,
                      c_res_rec.resource_id,
                      SYSDATE,
                      c_rbo_rec.actual_cost,
                      c_rbo_rec.applied_value,
                      c_rbo_rec.basis_type,
                      c_rbo_rec.basis_units,
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                    FROM DUAL;

                  END IF; -- check c_rbo_rec.applied_value <>0

                END LOOP; -- c_rbo loop


          END LOOP; -- RES_REC loop

          --------------------------------------------------------------
          -- Get Move based Overhead (MBO) Transactions
          --------------------------------------------------------------

          l_stmt_num := 80;

          FOR c_mbo_rec IN c_mbo_txn(   c_ent_rec.entity_id) LOOP

                l_stmt_num := 85;

                check_pacwip_bal_record (p_pac_period_id => p_pac_period_id,
                        p_cost_group_id         => p_cost_group_id,
                        p_cost_type_id          => p_cost_type_id,
                        p_org_id                => c_mbo_rec.org_id,
                        p_entity_id             => c_mbo_rec.entity_id,
                        p_entity_type           => c_ent_rec.entity_type,
                        p_line_id               => c_mbo_rec.line_id,
                        p_op_seq                => c_mbo_rec.op_seq,
                        p_user_id               => p_user_id,
                        p_request_id            => p_request_id,
                        p_prog_app_id           => p_prog_app_id,
                        p_prog_id               => p_prog_id,
                        p_login_id              => p_login_id,
                        x_err_num               => l_err_num,
                        x_err_code              => l_err_code,
                        x_err_msg               => l_err_msg
                        );

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('fail_bal_rec ent/line/op: '
                                                ||TO_CHAR(c_mbo_rec.entity_id)
                                                ||'/'
                                                ||TO_CHAR(c_mbo_rec.line_id)
                                                ||'/'
                                                ||TO_CHAR(c_mbo_rec.op_seq)
                                                ||':'
                                                ||l_err_msg,1,2000);
                        RAISE CST_PROCESS_ERROR;
                END IF;

                l_stmt_num := 90;


                UPDATE  wip_pac_period_balances wppb
                SET     tl_overhead_in = NVL(tl_overhead_in,0) +
                                                c_mbo_rec.applied_value,
                        request_id = p_request_id,
                        last_update_date = SYSDATE,
                        program_update_date = SYSDATE
                WHERE   wppb.pac_period_id = p_pac_period_id
                AND     wppb.cost_group_id = p_cost_group_id
                AND     wppb.wip_entity_id = c_mbo_rec.entity_id
                AND     NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(c_mbo_rec.line_id,-99))
                AND     wppb.operation_seq_num = c_mbo_rec.op_seq;

                l_stmt_num := 95;

                INSERT INTO wip_pac_actual_cost_details
                    (
                      pac_period_id,
                      cost_group_id,
                      cost_type_id,
                      transaction_id,
                      level_type,
                      cost_element_id,
                      resource_id,
                      basis_resource_id,
                      transaction_costed_date,
                      actual_cost,
                      actual_value,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      last_update_login
                    )
                SELECT
                      p_pac_period_id,
                      p_cost_group_id,
                      p_cost_type_id,
                      c_mbo_rec.txn_id,
                      1,                         -- Level Type
                      5,                         -- CE
                      c_mbo_rec.overhead_id,
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      c_mbo_rec.actual_cost,
                      c_mbo_rec.applied_value,
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM DUAL;

          END LOOP; -- MBO_REC loop

        END LOOP; -- ENT_REC loop


EXCEPTION

        WHEN CST_WIP_PENDING_TXNS THEN
                x_err_num  := 20003;
                x_err_code := SUBSTR('CSTPPWRO.process_wip_resovhd_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                || l_err_msg
                                || '. ',1,2000);
                fnd_message.set_name('BOM', 'CST_WIP_PENDING_TXNS');
                x_err_msg  := SUBSTR(fnd_message.get,1,2000);

        WHEN CST_FAIL_ACQ_COST THEN
                x_err_num  := 20003;
                x_err_code := SUBSTR('CSTPPWRO.process_wip_resovhd_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                || l_err_msg
                                || '. ',1,2000);
                fnd_message.set_name('BOM', 'CST_FAIL_ACQ_COST');
                x_err_msg  := SUBSTR(fnd_message.get,1,2000);

        WHEN CST_PROCESS_ERROR THEN
                x_err_num  := l_err_num;
                x_err_code := l_err_code;
                x_err_msg  := l_err_msg;

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num  := SQLCODE;
                x_err_code := NULL;
                x_err_msg  := SUBSTR('CSTPPWRO.process_wip_resovhd_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,2000);

END process_wip_resovhd_txns;

END cstppwro;

/

--------------------------------------------------------
--  DDL for Package Body CSTPPWCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWCL" AS
/* $Header: CSTPWCLB.pls 120.4 2005/07/20 04:22:11 skayitha noship $ */

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_wip_close_txns                                               |
| This routine will be called by the worker as the last step in processing.  |
*----------------------------------------------------------------------------*/
PROCEDURE process_wip_close_txns(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER DEFAULT -1,
        p_prog_app_id           IN      NUMBER DEFAULT -1,
        x_err_num               OUT NOCOPY      NUMBER,
        x_err_code              OUT NOCOPY      VARCHAR2,
        x_err_msg               OUT NOCOPY      VARCHAR2)
IS

l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
cst_process_error               EXCEPTION;

-----------------------------------------------------------------------------
-- Entities that were closed in the prior period will not be copied to
-- the next period.  If they are reopened they will be treated as new
-- for that period.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Cursor to process period Job close transaction for all wip entities
-- you could have more than one job close transaction in the same
-- period but we are concerned with just one because at the end of
-- the period we flush out everything from the job if there is at
-- least one job close txn in that period.  There would be actual cost
-- information in WPTCD for the last job close transaction against the
-- entity in the period.
-- Make sure that PAC record exists for this wip entity id
-- If record does not exist it means there has been
-- no activity for this entity, therefore no
-- wipclose calculations are required. This will be the case
-- when the job is defined but no issue/move/assy txns has
-- ever been done for the job till this period and it was
-- closed.
-- Job close in such cases have no fiscal cost impacts.
-----------------------------------------------------------------------------

CURSOR c_jobclose_txn IS
        SELECT  NVL(MAX(wt.transaction_id),-1) txn_id,
                wt.organization_id org_id,
                wt.wip_entity_id entity_id
        FROM    wip_transactions wt,
                wip_entities we
        WHERE   wt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
        AND     wt.transaction_type = 6 --Job Close
        AND     we.wip_entity_id = wt.wip_entity_id
        AND     we.entity_type <> 2 -- Not a rep schedule
        AND     EXISTS  (
                                SELECT  'X'
                                FROM    wip_pac_period_balances wppb
                                WHERE   wppb.pac_period_id = p_pac_period_id
                                AND     wppb.cost_group_id = p_cost_group_id
                                AND     wppb.wip_entity_id = wt.wip_entity_id
                        )
        GROUP BY
                wt.organization_id,
                wt.wip_entity_id;


-----------------------------------------------------------------------------
-- Cursor to select rows for Rep. schedule.  Rep. Schedules will be flushed out
-- at the end of each period.  The balance will be written off to variance.
-- There will be no actual cost info in WPTCD as these costs are recognized
-- as period expenses and do not have any corresponding txn_id in WT
-----------------------------------------------------------------------------

CURSOR c_schedclose IS
        SELECT  wppb.wip_entity_id entity_id,
                wppb.cost_group_id cost_group_id,
                wppb.line_id line_id,
                wppb.operation_seq_num op_seq_num
        FROM    wip_pac_period_balances wppb
        WHERE   wppb.pac_period_id = p_pac_period_id
        AND     wppb.cost_group_id = p_cost_group_id
        AND     wppb.wip_entity_type = 2; -- Rep. Svhedule

-----------------------------------------------------------------------------
-- Cursor to identify those WIP entities that do not have any assembly
-- reference.  Such entities will be flushed out at the end of the period
-- as a period expense.
-----------------------------------------------------------------------------

CURSOR c_noassy_entity IS
        SELECT  wppb.wip_entity_id entity_id,
                wppb.line_id,
                SUM(NVL(wppb.pl_material_in,0)) +
                SUM(NVL(wppb.pl_material_overhead_in,0)) +
                SUM(NVL(wppb.pl_resource_in,0)) +
                SUM(NVL(wppb.pl_outside_processing_in,0)) +
                SUM(NVL(wppb.pl_overhead_in,0)) +
                SUM(NVL(wppb.tl_resource_in,0)) +
                SUM(NVL(wppb.tl_outside_processing_in,0)) +
                SUM(NVL(wppb.tl_overhead_in,0)) value_in,
                SUM(NVL(pl_material_out,0)) +
                SUM(NVL(wppb.pl_material_overhead_out,0)) +
                SUM(NVL(wppb.pl_resource_out,0)) +
                SUM(NVL(wppb.pl_outside_processing_out,0)) +
                SUM(NVL(wppb.pl_overhead_out,0)) +
                SUM(NVL(wppb.tl_resource_out,0)) +
                SUM(NVL(wppb.tl_outside_processing_out,0)) +
                SUM(NVL(wppb.tl_overhead_out,0)) value_out
        FROM    wip_pac_period_balances wppb
        WHERE   wppb.pac_period_id = p_pac_period_id
        AND     wppb.cost_group_id = p_cost_group_id
        AND     EXISTS
                (       SELECT  'X'
                        FROM    wip_entities we
                        WHERE   we.wip_entity_id = wppb.wip_entity_id
                        AND     we.primary_item_id IS NULL
                        AND     we.entity_type not in (6,7) -- Added for R12 PAC eAM enhancement to
                        -- exclude eAM jobs at the PAC period close
                )
        GROUP BY
                wppb.wip_entity_id,
                wppb.line_id;


BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_stmt_num := 5;

        ----------------------------------------------------------------------
        -- Process Job Close Transactions
        ----------------------------------------------------------------------

        l_stmt_num := 10;

        FOR c_jobclose_rec IN c_jobclose_txn LOOP

                l_stmt_num := 15;

                flush_wip_costs(
                                   p_pac_period_id => p_pac_period_id,
                                   p_cost_group_id => p_cost_group_id,
                                   p_entity_id => c_jobclose_rec.entity_id,
                                   p_user_id => p_user_id,
                                   p_login_id => p_login_id,
                                   p_request_id => p_request_id,
                                   p_prog_id => p_prog_id,
                                   p_prog_app_id => p_prog_app_id,
                                   x_err_num => l_err_num,
                                   x_err_code => l_err_code,
                                   x_err_msg => l_err_msg);

                IF (l_err_num <>0) THEN

                        l_err_msg := SUBSTR('Fail_flush_wip_cost- Job:'
                                             ||TO_CHAR(c_jobclose_rec.entity_id)
                                             ||':'
                                             ||l_err_msg,1,240);


                        RAISE CST_PROCESS_ERROR;

                END IF;

                l_stmt_num := 20;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      1,                         -- Level Type
                      3,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.tl_resource_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 25;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      1,                         -- Level Type
                      4,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.tl_outside_processing_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 30;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      1,                         -- Level Type
                      5,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.tl_overhead_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 35;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      2,                         -- Level Type
                      1,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.pl_material_temp_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 40;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      2,                         -- Level Type
                      2,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.pl_material_overhead_temp_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 45;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      2,                         -- Level Type
                      3,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.pl_resource_temp_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 50;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      2,                         -- Level Type
                      4,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.pl_outside_processing_temp_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

                l_stmt_num := 55;

                INSERT INTO wip_pac_actual_cost_details wpacd
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
                      c_jobclose_rec.txn_id,
                      2,                         -- Level Type
                      5,                         -- CE
                      NULL,                      -- resource_id
                      NULL,                      -- basis_resource_id
                      SYSDATE,
                      SUM(NVL(wppb.pl_overhead_temp_var,0)),
                      NULL,                      -- applied_value
                      SYSDATE,
                      p_user_id,
                      SYSDATE,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      SYSDATE,
                      p_login_id
                FROM  wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                AND   wppb.cost_group_id = p_cost_group_id
                AND   wppb.wip_entity_id = c_jobclose_rec.entity_id;

        END LOOP; -- JOBCLOSE_REC loop

        FOR c_schedclose_rec IN c_schedclose LOOP

                l_stmt_num := 60;

                --------------------------------------------------------------
                -- Flush Out Repetitive Schedule's Costs to variance.
                --------------------------------------------------------------
                flush_wip_costs(
                                   p_pac_period_id => p_pac_period_id,
                                   p_cost_group_id => p_cost_group_id,
                                   p_entity_id => c_schedclose_rec.entity_id,
                                   p_user_id => p_user_id,
                                   p_login_id => p_login_id,
                                   p_request_id => p_request_id,
                                   p_prog_id => p_prog_id,
                                   p_prog_app_id => p_prog_app_id,
                                   x_err_num => l_err_num,
                                   x_err_code => l_err_code,
                                   x_err_msg => l_err_msg);

                IF (l_err_num <>0) THEN

                        l_err_msg := SUBSTR('Fail_flush_wip_cost- Repetitive:'
                                           ||TO_CHAR(c_schedclose_rec.entity_id)
                                           ||':'
                                           ||l_err_msg,1,240);
                        RAISE CST_PROCESS_ERROR;

                END IF;

        END LOOP; -- SCHEDCLOSE_REC loop

        ----------------------------------------------------------------------
        -- Now flush out those non standard entities that
        -- do not have an assembly reference.  Sunch entities
        -- cannot have an assembly transactions.
        -- These are treated as period expenses.  This information
        -- will not make it to WPTCD because flushing does not have
        -- a txn_id in WT.
        ----------------------------------------------------------------------


        l_stmt_num := 65;

        FOR c_noassy_rec IN c_noassy_entity LOOP

                --------------------------------------------------------------
                -- Flush only if there is value available to flush
                --------------------------------------------------------------

                IF (c_noassy_rec.value_in <> c_noassy_rec.value_out) THEN

                  l_stmt_num := 70;

                  flush_wip_costs (
                                p_pac_period_id => p_pac_period_id,
                                p_cost_group_id => p_cost_group_id,
                                p_entity_id     => c_noassy_rec.entity_id,
                                p_user_id       => p_user_id,
                                p_login_id      => p_login_id,
                                p_request_id    => p_request_id,
                                p_prog_id       => p_prog_id,
                                p_prog_app_id   => p_prog_app_id,
                                x_err_num       => l_err_num,
                                x_err_code      => l_err_code,
                                x_err_msg       => l_err_msg);

                  IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Fail_flush_wip_cost- Non Std Ent:'
                                           ||TO_CHAR(c_noassy_rec.entity_id)
                                           ||':'
                                           ||l_err_msg,1,240);

                        RAISE CST_PROCESS_ERROR;

                  END IF;

                END IF; -- check value_in <> value_out

        END LOOP; -- NOASSY_REC loop


EXCEPTION

        WHEN CST_PROCESS_ERROR THEN
                x_err_num  := l_err_num;
                x_err_code := l_err_code;
                x_err_msg  := l_err_msg;

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWCL.process_wip_close_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END process_wip_close_txns;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       flush_wip_costs                                                      |
*----------------------------------------------------------------------------*/
PROCEDURE flush_wip_costs(
        p_pac_period_id         IN      NUMBER,
        p_cost_group_id         IN      NUMBER,
        p_entity_id             IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER DEFAULT -1,
        p_prog_app_id           IN      NUMBER DEFAULT -1,
        x_err_num               OUT NOCOPY      NUMBER,
        x_err_code              OUT NOCOPY      VARCHAR2,
        x_err_msg               OUT NOCOPY      VARCHAR2)
IS

l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';

        ----------------------------------------------------------------------
        -- Flush out WIP entity's costs, write off to variance
        ----------------------------------------------------------------------

        -- Update the PL variance TEMP columns. TEMPVar = IN- - OUT - VAR
        -- Because if Cost type is based on BOM based Algo, then if Job has negative balance
        -- VAR columns will be updated and this amount will be flush to Variance account
        -- while processing the Assembly txns
        -- So only left value in the Job should be flushed to TEMP Variance
        --------------------------------------------------------------------------------------
        l_stmt_num := 5;

        UPDATE  wip_pac_period_balances wppb
        SET     tl_resource_var = NVL(tl_resource_in,0)
                                            - NVL(tl_resource_out,0),
                tl_outside_processing_var = NVL(tl_outside_processing_in,0)
                                             - NVL(tl_outside_processing_out,0),
                tl_overhead_var = NVL(tl_overhead_in,0) - NVL(tl_overhead_out,0),

                pl_material_var = NVL(pl_material_in,0) -  NVL(pl_material_out,0),

                pl_material_overhead_var = NVL(pl_material_overhead_in,0) - NVL(pl_material_overhead_out,0),

                pl_resource_var =  NVL(pl_resource_in,0) - NVL(pl_resource_out,0),

                pl_outside_processing_var = NVL(pl_outside_processing_in,0) - NVL(pl_outside_processing_out,0),

                pl_overhead_var =  NVL(pl_overhead_in,0) - NVL(pl_overhead_out,0),

                -- Update the vartemp columns with Actual variance during job close
                -- var columns contains total variance

                pl_material_temp_var = NVL(pl_material_in,0) -  NVL(pl_material_out,0)
                                                        -  NVL(pl_material_var,0),

                pl_material_overhead_temp_var = NVL(pl_material_overhead_in,0) - NVL(pl_material_overhead_out,0)
                                                                          - NVL(pl_material_overhead_var,0),
                pl_resource_temp_var =  NVL(pl_resource_in,0) - NVL(pl_resource_out,0)
                                                         -  NVL(pl_resource_var,0),
                pl_outside_processing_temp_var = NVL(pl_outside_processing_in,0) - NVL(pl_outside_processing_out,0)
                                                                            -  NVL(pl_outside_processing_var,0),
                pl_overhead_temp_var =  NVL(pl_overhead_in,0) - NVL(pl_overhead_out,0)
                                                         - NVL(pl_overhead_var,0),

                request_id = p_request_id,
                last_update_date = SYSDATE,
                program_update_date = SYSDATE
        WHERE   wppb.pac_period_id = p_pac_period_id
        AND     wppb.cost_group_id = p_cost_group_id
        AND     wppb.wip_entity_id = p_entity_id;

EXCEPTION

        WHEN OTHERS THEN
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWCL.flush_wip_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END flush_wip_costs;

END cstppwcl;

/

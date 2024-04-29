--------------------------------------------------------
--  DDL for Package Body CSTPPPUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPPUR" AS
/* $Header: CSTPPURB.pls 120.6.12010000.2 2008/08/08 12:32:22 smsasidh ship $ */

g_bulk_limit NUMBER := 3000; -- bulk fetch limit
TYPE rowidstruc IS TABLE OF VARCHAR2(30);  /* added for perf bug 4461176 */
rowidtab rowidstruc;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURES/FUNCTIONS                                              |
*----------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       purge_period_data                                                     |
*----------------------------------------------------------------------------*/
PROCEDURE purge_period_data (
                        i_pac_period_id         IN         NUMBER,
                        i_legal_entity          IN         NUMBER,
                        i_cost_group_id         IN         NUMBER,
                        i_acquisition_flag      IN         NUMBER DEFAULT 0,
                        i_user_id               IN         NUMBER,
                        i_login_id              IN         NUMBER DEFAULT -1,
                        i_request_id            IN         NUMBER,
                        i_prog_id               IN         NUMBER DEFAULT -1,
                        i_prog_app_id           IN         NUMBER DEFAULT -1,
                        o_err_num               OUT NOCOPY NUMBER,
                        o_err_code              OUT NOCOPY VARCHAR2,
                        o_err_msg               OUT NOCOPY VARCHAR2
)
IS

l_stmt_num              NUMBER;
l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(240);
PROCESS_ERROR           EXCEPTION;
l_count                 NUMBER;

BEGIN

  l_count := 0;
  l_stmt_num := 0;
  IF (i_acquisition_flag = 1) THEN

    DELETE FROM cst_rcv_acq_cost_details cracd
    WHERE cracd.header_id in (SELECT  header_id FROM cst_rcv_acq_costs
                          WHERE   period_id     = i_pac_period_id
                            AND   cost_group_id = i_cost_group_id);

     DELETE FROM cst_rcv_acq_costs
     WHERE period_id     = i_pac_period_id
       AND cost_group_id = i_cost_group_id;

  END IF;


  l_stmt_num := 10;
  DELETE FROM cst_pac_low_level_codes
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  l_stmt_num := 20;
  DELETE /*+ index(cst_pac_explosion_temp CST_PAC_EXPLOSION_TEMP_N1) */
  FROM cst_pac_explosion_temp
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  l_stmt_num := 30;
  DELETE FROM wip_pac_period_balances
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  l_stmt_num := 40;
  DELETE FROM mtl_pac_txn_cost_details
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id
    AND new_periodic_cost IS NULL
    AND value_change IS NULL
    AND percentage_change IS NULL;

  l_stmt_num := 50;
  DELETE FROM mtl_pac_actual_cost_details
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  l_stmt_num := 55;
  DELETE FROM wip_pac_actual_cost_details
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  l_stmt_num := 60;
  DELETE FROM mtl_pac_cost_subelements
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

 ---------------------------------------
 -- Added R12 PAC enhancement
 ---------------------------------------
  l_stmt_num := 65;
  DELETE FROM cst_pac_req_oper_cost_details
  WHERE pac_period_id = i_pac_period_id
  AND   cost_group_id = i_cost_group_id;

  l_stmt_num := 70;

  DELETE from cst_pac_quantity_layers
  WHERE  cost_layer_id in (SELECT cost_layer_id
                             FROM cst_pac_item_costs
                            WHERE pac_period_id = i_pac_period_id
                              AND cost_group_id = i_cost_group_id);

  l_stmt_num := 80;

  DELETE FROM cst_pac_item_cost_details
   WHERE cost_layer_id in (SELECT cost_layer_id from cst_pac_item_costs
                            WHERE pac_period_id = i_pac_period_id
                              AND cost_group_id = i_cost_group_id);

  l_stmt_num := 90;
  DELETE FROM cst_pac_item_costs
  WHERE pac_period_id = i_pac_period_id
    AND cost_group_id = i_cost_group_id;

  -- l_stmt_num := 100;
  -- Deletion from cst_pc_txn_history removed
  -- as part of performance bug 6751847 fix

  l_stmt_num := 110; -- PAC enhancements project R12
  DELETE FROM cst_pac_period_balances
  WHERE  pac_period_id = i_pac_period_id
    AND  cost_group_id = i_cost_group_id;

  -- Changes made to support eAM in PAC.
  -- Update all actual cols in cpeapb abd cpepb to 0
  -- delete from cpeapb abd wepb where actual and estimate cols are 0

  l_stmt_num := 120;
  -- Delete ceapb rows with zeros in ALL value columns
  UPDATE cst_pac_eam_asset_per_balances
  SET    actual_mat_cost = 0,
         actual_lab_cost = 0,
         actual_eqp_cost = 0
  WHERE  legal_entity_id = i_legal_entity
  AND    cost_group_id = i_cost_group_id
  AND    cost_type_id = (SELECT cost_type_id
                         FROM   cst_pac_periods
                         WHERE  pac_period_id = i_pac_period_id);

  l_stmt_num := 130;
  DELETE FROM cst_pac_eam_asset_per_balances
  WHERE  NVL(actual_mat_cost,0) = 0
  AND    NVL(actual_lab_cost,0) = 0
  AND    NVL(actual_eqp_cost,0) = 0
  AND    NVL(system_estimated_mat_cost,0) = 0
  AND    NVL(system_estimated_lab_cost,0) = 0
  AND    NVL(system_estimated_eqp_cost,0) = 0
  AND    legal_entity_id = i_legal_entity
  AND    cost_group_id = i_cost_group_id
  AND    cost_type_id = (SELECT cost_type_id
                         FROM   cst_pac_periods
                         WHERE  pac_period_id = i_pac_period_id);

  l_stmt_num := 140;
  -- Delete cpepb rows with zeros in ALL value columns
  UPDATE cst_pac_eam_period_balances
  SET    actual_mat_cost = 0,
         actual_lab_cost = 0,
         actual_eqp_cost = 0
  WHERE  cost_group_id = i_cost_group_id
  AND    pac_period_id = i_pac_period_id;

  l_stmt_num := 150;
  DELETE FROM cst_pac_eam_period_balances
  WHERE  NVL(actual_mat_cost,0) = 0
  AND    NVL(actual_lab_cost,0) = 0
  AND    NVL(actual_eqp_cost,0) = 0
  AND    NVL(system_estimated_mat_cost,0) = 0
  AND    NVL(system_estimated_lab_cost,0) = 0
  AND    NVL(system_estimated_eqp_cost,0) = 0
  AND    cost_group_id = i_cost_group_id
  AND    pac_period_id = i_pac_period_id;

  l_stmt_num := 160;
  purge_distribution_data (i_pac_period_id,i_legal_entity,i_cost_group_id,i_user_id,
                           i_login_id,i_request_id,i_prog_id,i_prog_app_id,
                           l_err_num, l_err_code, l_err_msg);
  IF (l_err_num <> 0) THEN
    raise PROCESS_ERROR;
  END IF;

  ----------------------------------------------------------------------
  -- Update Process_status to Pending.
  -- It will :
  --    a. If i_acquisition_flag = 1 (Being called from phase 1), then
  --       set the process status for all phases (1-5) to pending
  --    b. If i_acquisition_flag = 0 (Being called from phase 2) ,then
  --       set the process status for phases 2-5 to pending. It means
  --       that this rerun starting from phase 2.
  -- 2 conditions for setting phase 6 :
  --    a. If CREATE_ACCT_ENTRIES='N', set phase 6 status to 0 ('N/A').
  --    b. If CREATE_ACCT_ENTRIES='Y', set phase 6 status to 1 ('N/P').
  --  Bug 6520942 fix:  set Phase 8 status to 0 (N/A) when transfer
  --  cost flag is not enabled, very similar behavior as that of current
  --  phase 7 where it is set to 0.
  --  Set phase 8 status to 1 (unprocessed) when transfer cost flag is
  --  enabled, very similar to behavior as that of current phase 7 where
  --  it is set to 1.
  --  NOTE: When transfer cost flag is disabled in organization cost
  --  group / cost type association screen, phase 7 and 8 status are set
  --  to 0.   It is important to have the status of phase 7 and 8 set to 0
  --  even after acquisition cost processor or after periodic cost processor
 ----------------------------------------------------------------------

 /* changes to support the PAC IO transfer cost processor project.If the transfer cost flag
    is set then we should set the status to 1 otherwise we should set it not applicable(0) */


  l_stmt_num := 170;
  UPDATE cst_pac_process_phases cppp
  SET (cppp.process_status,cppp.last_update_date, cppp.process_upto_date) =
    (SELECT decode(cppp.process_phase,6,
              decode(NVL(clct.CREATE_ACCT_ENTRIES,'N'),'N',0,1),
              7,
              decode(NVL(clct.transfer_cost_flag,'N'),'N',0,1),
              8,
              decode(NVL(clct.transfer_cost_flag,'N'),'N',0,1),
              1),
            SYSDATE,
            NULL
    FROM cst_le_cost_types clct, cst_pac_periods cpp
    WHERE cpp.pac_period_id = i_pac_period_id
      AND clct.legal_entity = i_legal_entity
      AND clct.cost_type_id = cpp.cost_type_id)
  WHERE cppp.pac_period_id = i_pac_period_id
    AND cppp.cost_group_id = i_cost_group_id
    AND cppp.process_phase <> decode(i_acquisition_flag, 0, 1, 0);


EXCEPTION

  WHEN PROCESS_ERROR THEN
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPPUR.purge_period_data:' || l_err_msg;

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_code := NULL;
    o_err_msg := SUBSTR('CSTPPPUR.purge_period_data(' || to_char(l_stmt_num)
                        || '): ' ||SQLERRM,1,240);

END purge_period_data;

PROCEDURE purge_distribution_data (
                        i_pac_period_id         IN      NUMBER,
                        i_legal_entity          IN      NUMBER,
                        i_cost_group_id         IN      NUMBER,
                        i_user_id               IN      NUMBER,
                        i_login_id              IN      NUMBER DEFAULT -1,
                        i_request_id            IN      NUMBER,
                        i_prog_id               IN      NUMBER DEFAULT -1,
                        i_prog_app_id           IN      NUMBER DEFAULT -1,
                        o_err_num               OUT NOCOPY     NUMBER,
                        o_err_code              OUT NOCOPY     VARCHAR2,
                        o_err_msg               OUT NOCOPY     VARCHAR2
) IS

l_stmt_num                      NUMBER;
l_count                         NUMBER;

BEGIN

  l_count := 0;
  l_stmt_num := 10;

  DELETE from cst_ae_lines
   where ae_header_id in
      (SELECT ae_header_id
         FROM cst_ae_headers
        WHERE period_id = i_pac_period_id
          AND cost_group_id = i_cost_group_id);

  l_stmt_num := 20;
  DELETE FROM cst_encumbrance_lines
   WHERE ae_header_id in
     (SELECT ae_header_id
        FROM cst_ae_headers
       WHERE period_id = i_pac_period_id
         AND cost_group_id = i_cost_group_id);

  l_stmt_num := 30;
  DELETE FROM cst_ae_headers
  WHERE period_id = i_pac_period_id
  AND cost_group_id = i_cost_group_id;

  l_stmt_num := 40;
  DELETE FROM CST_PAC_ACCRUAL_RECONCILE_TEMP
  WHERE period_id = i_pac_period_id
  AND cost_group_id = i_cost_group_id;

  l_stmt_num := 50;
  DELETE FROM CST_PAC_ACCRUAL_WRITE_OFFS
  WHERE period_id = i_pac_period_id
  AND cost_group_id = i_cost_group_id;

EXCEPTION

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_code := NULL;
    o_err_msg := SUBSTR('CSTPPPUR.purge_distribution_data(' || to_char(l_stmt_num)
                        || '): ' ||SQLERRM,1,240);

END purge_distribution_data;


END CSTPPPUR;

/

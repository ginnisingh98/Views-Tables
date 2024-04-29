--------------------------------------------------------
--  DDL for Package Body WIP_MOVE_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVE_VALIDATOR" AS
/* $Header: wipmovvb.pls 120.12.12010000.2 2009/12/17 23:10:12 pding ship $ */
/*********************************************
 * declare global variables for this package *
 *********************************************/
g_group_id NUMBER;
enums txnID_list;

-- error handling procedure
PROCEDURE add_error(p_txn_id  IN NUMBER,
                    p_err_col IN VARCHAR2,
                    p_err_msg IN VARCHAR2) IS
error_record request_error;
BEGIN
  -- create error record
  error_record.transaction_id := p_txn_id;
  error_record.error_column   := p_err_col;
  error_record.error_message  := substrb(p_err_msg,1,240);

  -- add error record to error table (current_errors)
  current_errors(current_errors.count + 1) := error_record;
END add_error;

-- error handling procedure
PROCEDURE add_error(p_txn_ids IN txnID_list,
                    p_err_col IN VARCHAR2,
                    p_err_msg IN VARCHAR2) IS

error_record request_error;

BEGIN
  /* Bug#3123422 - Moved the invariable statements out of the loop
     to optimize the code */
    error_record.error_column   := p_err_col;
    error_record.error_message  := substrb(p_err_msg,1,240);

  FOR i IN 1..p_txn_ids.count LOOP
    -- create error record
    error_record.transaction_id := p_txn_ids(i);
    -- add error record to error table (current_errors)
    current_errors(current_errors.count + 1) := error_record;
  END LOOP;
END add_error;

Procedure load_errors IS

  n_errors NUMBER;
  error_no NUMBER := 1;

BEGIN

  n_errors := current_errors.count;

  WHILE (error_no <= n_errors) LOOP

    INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT current_errors(error_no).transaction_id, -- transaction_id
           current_errors(error_no).error_message,  -- error_message
           current_errors(error_no).error_column,   -- error_column
           SYSDATE,                                 -- last_update_date
           NVL(last_updated_by, -1),
           SYSDATE,                                 -- creation_date
           NVL(created_by, -1),
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date
      FROM wip_move_txn_interface
     WHERE transaction_id = current_errors(error_no).transaction_id
       AND group_id = g_group_id;

    error_no := error_no + 1;
  END LOOP;

  -- cleare error table
  current_errors.delete ;

END load_errors;
-- end error handling procedure

-- validate organization_id. The caller have an option to provide either
-- organization_id or organization_code. If the caller pass organization_id,
-- the id need to be valid. If the caller pass organization_code, we will
-- derive the organization_id. If the caller pass both, both value must be
-- consistent to each other.

/* Bug#2956953 - This procedure will be called only from wip move manager.
Call to this procedure from wip move worker code is commented
- Changes done as part of Wip Move Sequencing Project */

PROCEDURE organization_id(p_count_of_errored OUT NOCOPY NUMBER) IS
BEGIN
  -- Derive ORGANIZATIOIN_ID if user provided only ORGANIZATION_CODE
  UPDATE wip_move_txn_interface wmti
     SET wmti.organization_id =
         (SELECT mp.organization_id
            FROM mtl_parameters mp
           WHERE mp.organization_code = wmti.organization_code) --Fix by bug 9220479
   WHERE wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.PENDING
     AND wmti.organization_id IS NULL
     AND wmti.organization_code IS NOT NULL;

  -- reset enums table
     enums.delete;

  -- If cannot derive ORGANIZATION_ID or ORGANIZATION_ID not corresponding to
  -- ORGANIZATION_CODE provided, error out.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.PENDING
     AND ((wmti.organization_id IS NULL) -- cannot derive ORGANIZATION_ID
         OR
          (NOT EXISTS
           (SELECT 'X'
              FROM mtl_parameters mp
             WHERE mp.organization_code = NVL(wmti.organization_code,
                                                    mp.organization_code)--Fix by bug 9220479
               AND mp.organization_id = wmti.organization_id
           )
          ))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  p_count_of_errored := sql%rowcount;

  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'ORGANIZATION_ID');
  fnd_message.set_token('ENTITY2', 'ORGANIZATION_CODE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'ORGANIZATION_ID/CODE',
            p_err_msg  => fnd_message.get);

  load_errors;

END organization_id;

-- validate wip_entity_id against wip_entities table. The caller have an
-- option to provide either wip_entity_id or wip_entity_name. If the caller
-- pass wip_entity_id, the id need to be valid. If the caller pass
-- wip_entity_name, we will derive the wip_entity_id. If the caller pass both,
-- both value must be consistent to each other. Moreover, the wip_entity_id
-- provided must have status that allow move transaction(3,4)
-- The wip_entity_id provided also need to have assembly associated with it.

-- Also validate line_id against wip_lines table. The caller have an option to
-- provide either line_id or line_code. If the caller pass line_id, the id
-- need to be valid. If the caller pass line_code, we will derive the
-- line_id. If the caller pass both, both value must be consistent to
-- each other. Only validate these values if the transaction type is
-- repetitive. If line_id and line_code are null, the caller need to pass
-- repetitive_schedule_id.
-- this routine will also derive the first transactable schedule if the
-- caller do not provide repetitive schedule id for repetitive transaction

-- Also Check that the job is not serilized. We do not support serialized
-- transaction for background.
PROCEDURE wip_entity_id IS
BEGIN
  -- Derive WIP_ENTITY_ID if user provided only WIP_ENTITY_NAME
  UPDATE wip_move_txn_interface wmti
     SET wmti.wip_entity_id =
         (SELECT we.wip_entity_id
            FROM wip_entities we
           WHERE we.wip_entity_name = wmti.wip_entity_name
             AND we.organization_id = wmti.organization_id
             AND entity_type IN (WIP_CONSTANTS.DISCRETE,
                                 WIP_CONSTANTS.REPETITIVE,
                                 WIP_CONSTANTS.LOTBASED))
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.wip_entity_id IS NULL
     AND wmti.wip_entity_name IS NOT NULL;

  -- reset enums table
  enums.delete;
  -- If unable to derive WIP_ENTITY_ID or WIP_ENTITY_ID not conresponding
  -- to WIP_ENTITY_NAME specified, error out.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND ((wmti.wip_entity_id IS NULL) -- cannot derive WIP_ENTITY_ID
         OR
          (NOT EXISTS
           (SELECT 'X'
              FROM wip_entities we
             WHERE we.wip_entity_name = NVL(wmti.wip_entity_name,
                                            we.wip_entity_name)
               AND we.wip_entity_id = wmti.wip_entity_id
               AND we.organization_id = wmti.organization_id
               AND entity_type IN (WIP_CONSTANTS.DISCRETE,
                                   WIP_CONSTANTS.REPETITIVE,
                                   WIP_CONSTANTS.LOTBASED)
           )
          ))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'WIP_ENTITY_ID - WIP_ENTITY_NAME');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WIP_ENTITY_ID/NAME',
            p_err_msg  => fnd_message.get);

  -- Derive ENTITY_TYPE and PRIMARY_ITEM_ID from WIP_ENTITY_ID
  UPDATE wip_move_txn_interface wmti
     SET (wmti.entity_type, wmti.primary_item_id) =
         (SELECT we.entity_type,
                 we.primary_item_id
            FROM wip_entities we
           WHERE we.wip_entity_id = wmti.wip_entity_id)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;

  -- reset enums table
  enums.delete;
  -- If non-standard job and no assembly defined, error out
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.primary_item_id IS NULL
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_ASSY_NO_TXN');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WIP_ENTITY_ID/NAME',
            p_err_msg  => fnd_message.get);

  /************************
   * Start Repetitive Check
   ************************/
  -- Derive LINE_ID if user provided only LINE_CODE.
  UPDATE wip_move_txn_interface wmti
     SET wmti.line_id =
         (SELECT wl.line_id
            FROM wip_lines wl
           WHERE wl.line_code = wmti.line_code
             AND wl.organization_id = wmti.organization_id
             AND NVL(wl.disable_date, SYSDATE) >= SYSDATE)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.line_id IS NULL
     AND wmti.line_code IS NOT NULL;

  -- reset enums table
  enums.delete;
  -- If unable to derive LINE_ID or LINE_ID not conresponding to LINE_CODE
  -- specified, error out.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND ((wmti.line_id IS NULL)
         OR
          (NOT EXISTS
           (SELECT 'X'
              FROM wip_lines wl
             WHERE wl.line_code = NVL(wmti.line_code, wl.line_code)
               AND wl.line_id = wmti.line_id
               AND wl.organization_id = wmti.organization_id
               AND NVL(wl.disable_date, SYSDATE) >= SYSDATE
           )
          ))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_LINE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'LINE_ID/CODE',
            p_err_msg  => fnd_message.get);

  -- derive the first transactable schedule if REPETITIVE_SCHEDULE_ID is null
  UPDATE wip_move_txn_interface wmti
     SET wmti.repetitive_schedule_id =
         (SELECT wrs1.repetitive_schedule_id
            FROM wip_repetitive_schedules wrs1
           WHERE wrs1.wip_entity_id = wmti.wip_entity_id
             AND wrs1.organization_id = wmti.organization_id
             AND wrs1.line_id = wmti.line_id
             AND wrs1.status_type IN (WIP_CONSTANTS.RELEASED,
                                      WIP_CONSTANTS.COMP_CHRG)
             AND wrs1.first_unit_start_date =
                (SELECT MIN(wrs2.first_unit_start_date)
                   FROM wip_repetitive_schedules wrs2
                  WHERE wrs2.wip_entity_id = wmti.wip_entity_id
                    AND wrs2.organization_id = wmti.organization_id
                    AND wrs2.line_id = wmti.line_id
                    AND wrs2.status_type IN (WIP_CONSTANTS.RELEASED,
                                             WIP_CONSTANTS.COMP_CHRG)))
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.repetitive_schedule_id IS NULL;

  -- reset enums table
  enums.delete;
  -- By this time, all repetive transaction should have REPETITIVE_SCHEDULE_ID
  -- Otherwise, error out
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.repetitive_schedule_id IS NULL
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_LINE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'LINE_ID/CODE',
            p_err_msg  => fnd_message.get);

  /************************
   * End Repetitive Check
   ************************/

  /************************
   * Start Discrete Check
   ************************/
  -- reset enums table
  enums.delete;
  -- For Discrete and Lotbased, user should not provide these 3 values
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
     AND (wmti.line_id IS NOT NULL OR
          wmti.line_code IS NOT NULL OR
          wmti.repetitive_schedule_id IS NOT NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NULL_LINE_ID');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WIP_ENTITY_ID/NAME',
            p_err_msg  => fnd_message.get);

  /************************
   * End Discrete Check
   ************************/
  -- reset enums table
  enums.delete;
  -- Check job status not either Complete or Release, error out.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND ((wmti.entity_type = WIP_CONSTANTS.REPETITIVE
           AND NOT EXISTS
           (SELECT 'X'
              FROM wip_repetitive_schedules wrs
             WHERE wrs.wip_entity_id = wmti.wip_entity_id
               AND wrs.organization_id = wmti.organization_id
               AND wrs.line_id = wmti.line_id
               AND wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                       WIP_CONSTANTS.COMP_CHRG)))
          OR
          (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                WIP_CONSTANTS.LOTBASED)
           AND NOT EXISTS
           (SELECT 'X'
              FROM wip_discrete_jobs wdj
             WHERE wdj.wip_entity_id = wmti.wip_entity_id
               AND wdj.organization_id = wmti.organization_id
               AND wdj.status_type IN (WIP_CONSTANTS.RELEASED,
                                       WIP_CONSTANTS.COMP_CHRG))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_CHARGES_ALLOWED');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WIP_ENTITY_ID/NAME',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- If job/schedule specified has no routing, error out
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND NOT EXISTS
         (SELECT 'X'
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_ROUTING_NOT_FOUND');
  fnd_message.set_token('ROUTINE', 'for Job/Schedule specified');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WIP_ENTITY_ID/NAME',
            p_err_msg  => fnd_message.get);

END wip_entity_id;

-- validate transaction_type. If the callers did not provide this info,
-- default to regular move. We do not support easy completion/return for
-- both discrete and repetitive if the assembly is under serial control.
-- We allow easy completion/return if the assembly is under lot control,
-- but the caller need to provide lot information when define a job.
-- However, we support only discrete and lotbased for this feature.
-- For repetitive, if the assembly is under lot control, it will error out.
PROCEDURE transaction_type IS
BEGIN
  -- Default TRANSACTION_TYPE to Move if users do not provide one
  UPDATE wip_move_txn_interface wmti
     SET wmti.transaction_type = WIP_CONSTANTS.MOVE_TXN
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type IS NULL;

  -- reset enums table
  enums.delete;
  -- Errot out, if transaction type not either Move or EZ Complete or
  -- EZ Return
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type NOT IN (WIP_CONSTANTS.MOVE_TXN,
                                       WIP_CONSTANTS.COMP_TXN,
                                       WIP_CONSTANTS.RET_TXN)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'TRANSACTION_TYPE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if easy completion/return and the assembly is under serial
  -- control because we cannot gather or derive serial number for background
  -- txns
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.RET_TXN)
     AND EXISTS
         (SELECT 'X'
            FROM mtl_system_items msi,
                 wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND wdj.serialization_start_op IS NULL
             AND msi.serial_number_control_code IN (WIP_CONSTANTS.FULL_SN,
                                                    WIP_CONSTANTS.DYN_RCV_SN))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_NO_SERIAL_CONTROL2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if easy completion/return and no default completion subinventory
  -- locator defined for both Discrete and Repetitive Schedule
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.RET_TXN)
     AND ((wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND EXISTS
              (SELECT 'X'
                 FROM wip_repetitive_items wri
                WHERE wri.wip_entity_id = wmti.wip_entity_id
                  AND wri.organization_id = wmti.organization_id
                  AND wri.line_id = wmti.line_id
                  AND wri.completion_subinventory IS NULL))
         OR
          (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                   WIP_CONSTANTS.LOTBASED)
          AND EXISTS
              (SELECT 'X'
                 FROM wip_discrete_jobs wdj
                WHERE wdj.wip_entity_id = wmti.wip_entity_id
                  AND wdj.organization_id = wmti.organization_id
                  AND wdj.completion_subinventory IS NULL)))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_NO_SUBINV_DEFAULT2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if item revision does not exist as a BOM revision
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.RET_TXN)
     AND EXISTS
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND msi.revision_qty_control_code =
                 WIP_CONSTANTS.REVISION_CONTROLLED)
     AND ((wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND NOT EXISTS
          (SELECT 'X'
             FROM wip_repetitive_schedules wrs,
                  mtl_item_revisions mir
            WHERE wrs.organization_id = wmti.organization_id
              AND wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
              AND mir.organization_id = wmti.organization_id
              AND mir.inventory_item_id = wmti.primary_item_id
              -- Fixed bug 2387630
              AND (wrs.bom_revision IS NULL OR
                   mir.revision = wrs.bom_revision)))
          OR
          (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                WIP_CONSTANTS.LOTBASED)
           AND NOT EXISTS
           (SELECT 'X'
              FROM wip_discrete_jobs wdj,
                   mtl_item_revisions mir
             WHERE wdj.organization_id = wmti.organization_id
               AND wdj.wip_entity_id = wmti.wip_entity_id
               AND mir.organization_id = wmti.organization_id
               AND mir.inventory_item_id = wmti.primary_item_id
               -- Fixed bug 2387630
               AND (wdj.bom_revision IS NULL OR
                    mir.revision = wdj.bom_revision))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_BOM_ITEM_REVISION');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if easy completion /return for repetitive schedule
  -- and the assembly is under lot control
   UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.RET_TXN)
     AND EXISTS
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND msi.lot_control_code = WIP_CONSTANTS.LOT)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_NO_REP_LOT_CONTROL2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if easy completion /return for Discrete job and the assembly
  -- is under lot control and there is no default completion lot defined
   UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.RET_TXN)
     AND EXISTS
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND msi.lot_control_code = WIP_CONSTANTS.LOT)
     AND EXISTS
         (SELECT 'X'
            FROM wip_discrete_jobs wdj
           WHERE wdj.organization_id = wmti.organization_id
             AND wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.lot_number IS NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_NO_JOB_LOT_DEFAULT2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if easy completion to the new lot number and and either this
  -- item or this item category requires "Lot Attributes".
   UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND EXISTS -- lot control
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND msi.lot_control_code = WIP_CONSTANTS.LOT)
     -- This is the first time to complete this assembly to this lot number
     AND NOT EXISTS
         (SELECT 'X'
            FROM mtl_lot_numbers mln,
                 wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.organization_id = wmti.organization_id
             AND mln.inventory_item_id = wmti.primary_item_id
             AND mln.organization_id = wmti.organization_id
             AND mln.lot_number = wdj.lot_number)
     -- This item or item category requires lot attributes
     AND 2 = inv_lot_sel_attr.is_enabled(
               'Lot Attributes',     -- p_flex_name
               wmti.organization_id, -- p_organization_id
               wmti.primary_item_id) -- p_inventory_item_id
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_LOT_ATTR_NOT_ALLOW');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

   -- reset enums table
  enums.delete;
  -- Error out if easy completion to the new lot number and lot expiration date
  -- was set to user-defined
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND EXISTS -- lot control and expiration date is user-defined
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND msi.lot_control_code = WIP_CONSTANTS.LOT
             AND msi.shelf_life_code = WIP_CONSTANTS.USER_DEFINED_EXP)
     -- This is the first time to complete this assembly to this lot number
     AND NOT EXISTS
         (SELECT 'X'
            FROM mtl_lot_numbers mln,
                 wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.organization_id = wmti.organization_id
             AND mln.inventory_item_id = wmti.primary_item_id
             AND mln.organization_id = wmti.organization_id
             AND mln.lot_number = wdj.lot_number)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_USER_DEF_EXP_NOT_ALLOW');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_TYPE',
            p_err_msg  => fnd_message.get);

END transaction_type;

-- validate transaction_date. Transaction date must be less than or equal
-- to SYSDATE, and greater than or equal to released date.
PROCEDURE transaction_date IS
BEGIN
  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_DATE is the future date
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_date > SYSDATE
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_FORWARD_DATING');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_DATE',
            p_err_msg  => fnd_message.get);

  /* Fix for bug 5685099 : Validate if TRANSACTION_DATE falls in open accounting period. */
  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_DATE does not fall in open period
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND NOT EXISTS
         (SELECT 'X'
            FROM ORG_ACCT_PERIODS OAP
           WHERE OAP.ORGANIZATION_ID = WMTI.ORGANIZATION_ID
             AND OAP.PERIOD_CLOSE_DATE IS NULL
             AND OAP.OPEN_FLAG = 'Y'
             AND TRUNC(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                       WMTI.TRANSACTION_DATE,  -- p_trxn_date
                       WMTI.ORGANIZATION_ID    -- p_inv_org_id
                      ))
                 BETWEEN OAP.PERIOD_START_DATE AND OAP.SCHEDULE_CLOSE_DATE)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_DATE_IN_OPEN_PERIOD');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_DATE',
            p_err_msg  => fnd_message.get);

/* end fix for bug 5685099 */

  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_DATE is before released date
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND ((wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND EXISTS
          (SELECT 'X'
             FROM wip_repetitive_schedules wrs
            WHERE wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
              AND wrs.organization_id = wmti.organization_id
              AND wrs.date_released > wmti.transaction_date))
         OR
          (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                WIP_CONSTANTS.LOTBASED)
           AND EXISTS
           (SELECT 'X'
              FROM wip_discrete_jobs wdj
             WHERE wdj.wip_entity_id = wmti.wip_entity_id
               AND wdj.organization_id = wmti.organization_id
               AND wdj.date_released > wmti.transaction_date)))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_RELEASE_DATE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_DATE',
            p_err_msg  => fnd_message.get);

  -- Derive ACCT_PERIOD_ID from TRANSACTION_DATE
  UPDATE wip_move_txn_interface wmti
     SET wmti.acct_period_id =
         (SELECT oap.acct_period_id
            FROM org_acct_periods oap
           WHERE oap.organization_id = wmti.organization_id
             -- modified the statement below for timezone project in J
             AND TRUNC(inv_le_timezone_pub.get_le_day_for_inv_org(
                         wmti.transaction_date,  -- p_trxn_date
                         wmti.organization_id    -- p_inv_org_id
                         )) BETWEEN
                 oap.period_start_date AND oap.schedule_close_date)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;

  -- reset enums table
  enums.delete;
  -- Error out if there is no open accout period for the TRANSACTION_DATE
  -- specified or there is no WIP_PERIOD_BALANCES
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.acct_period_id IS NULL
         OR
         NOT EXISTS
         (SELECT 'X'
            FROM wip_period_balances wpb
           WHERE wpb.acct_period_id = wmti.acct_period_id
             AND wpb.wip_entity_id = wmti.wip_entity_id
             AND wpb.organization_id = wmti.organization_id
             AND (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                       WIP_CONSTANTS.LOTBASED)
                 OR (wmti.entity_type = WIP_CONSTANTS.REPETITIVE
                     AND repetitive_schedule_id IN
                    (SELECT wrs.repetitive_schedule_id
                       FROM wip_repetitive_schedules wrs
                      WHERE wrs.wip_entity_id = wmti.wip_entity_id
                       AND wrs.organization_id = wmti.organization_id
                       AND wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                               WIP_CONSTANTS.COMP_CHRG))))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_BALANCE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_DATE',
            p_err_msg  => fnd_message.get);

END transaction_date;

-- validate fm_operation_seq_num. From operation must be a valid operation.
-- For easy return transaction, from operation must be the last operation.
-- Callers always need to pass this value except for Return transactions.
-- If callers do not provide this info and it is return transaction, just
-- default fm_operation to last_op
PROCEDURE fm_operation IS
l_last_op NUMBER;
BEGIN
  -- Set FM_OPERATION_SEQ_NUM to last_operation if TRANSACTION_TYPE is
  -- EZ Return and FM_OPERATION_SEQ_NUM is null
  UPDATE wip_move_txn_interface wmti
     SET wmti.fm_operation_seq_num =
         (SELECT wo.operation_seq_num
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1)
             AND wo.next_operation_seq_num IS NULL)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN
     AND wmti.fm_operation_seq_num IS NULL;

  -- reset enums table
  enums.delete;
  -- Error out if FM_OPERATION_SEQ_NUM is null or FM_OPERATION_SEQ_NUM
  -- is invalid
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.fm_operation_seq_num IS NULL
          OR
          (NOT EXISTS
               (SELECT 'X'
                  FROM wip_operations wo
                 WHERE wo.wip_entity_id = wmti.wip_entity_id
                   AND wo.organization_id = wmti.organization_id
                   AND wo.operation_seq_num = wmti.fm_operation_seq_num
                   AND NVL(wo.repetitive_schedule_id, -1) =
                       NVL(wmti.repetitive_schedule_id, -1))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_OPERATION');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_OPERATION_SEQ_NUM',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_TYPE is EZ Return and FM_OPERATION_SEQ_NUM
  -- is not equal to the last operation.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN
     AND wmti.fm_operation_seq_num <>
         (SELECT wo.operation_seq_num
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1)
             AND wo.next_operation_seq_num IS NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_FM_LAST_OP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_OPERATION_SEQ_NUM',
            p_err_msg  => fnd_message.get);
END fm_operation;

-- validate fm_intraoperation_step_type. From step must be valid.
-- If easy return transaction, from step must be "To move". If easy complete,
-- from step cannot be "To move" when from operation is the last operation.
-- You cannot move out of an operaion/step that has a No Move shop floor status
-- attached. If callers do not provide this info and it is return transaction,
-- just default fm_step to to move
PROCEDURE fm_step IS
BEGIN
  -- Set FM_INTRAOPERATION_STEP_TYPE to Tomove if TRANSACTION_TYPE is
  -- EZ Return and FM_INTRAOPERATION_STEP_TYPE is null
  UPDATE wip_move_txn_interface wmti
     SET wmti.fm_intraoperation_step_type = WIP_CONSTANTS.TOMOVE
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN
     AND wmti.fm_intraoperation_step_type IS NULL;

  -- reset enums table
  enums.delete;
  -- Error out if FM_INTRAOPERATION_STEP_TYPE is null or invalid
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.fm_intraoperation_step_type IS NULL
          OR
          (NOT EXISTS
               (SELECT 'X'
                  FROM wip_valid_intraoperation_steps wvis,
                       wip_operations wo
                 WHERE wvis.organization_id = wmti.organization_id
                   AND wvis.step_lookup_type = wmti.fm_intraoperation_step_type
                   AND wo.organization_id = wmti.organization_id
                   AND wo.wip_entity_id = wmti.wip_entity_id
                   AND wo.operation_seq_num = wmti.fm_operation_seq_num
                   AND NVL(wo.repetitive_schedule_id, -1) =
                       NVL(wmti.repetitive_schedule_id, -1)
                   AND ((wvis.record_creator = 'USER' OR
                        wvis.step_lookup_type = WIP_CONSTANTS.QUEUE)
                        OR
                        (wvis.record_creator = 'SYSTEM' AND
                         wo.next_operation_seq_num IS NULL)))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'FM_INTRAOPERATION_STEP_TYPE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if FM_OPERATION_SEQ_NUM/FM_INTRAOPERATION_STEP_TYPE has
  -- no move shop floor status attached
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS
         (SELECT 'X'
            FROM wip_shop_floor_status_codes wsc,
                 wip_shop_floor_statuses ws
           WHERE wsc.organization_id = wmti.organization_id
             AND ws.organization_id = wmti.organization_id
             AND ws.wip_entity_id = wmti.wip_entity_id
             AND (wmti.line_id IS NULL OR ws.line_id = wmti.line_id)
             AND ws.operation_seq_num = wmti.fm_operation_seq_num
             AND ws.intraoperation_step_type = wmti.fm_intraoperation_step_type
             AND ws.shop_floor_status_code = wsc.shop_floor_status_code
             AND wsc.status_move_flag = WIP_CONSTANTS.NO
             AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE
             AND (wmti.source_code IS NULL OR
                  wmti.source_code <> 'RCV' OR
                  (wmti.source_code = 'RCV' AND
                   NOT EXISTS
                      (SELECT 'X'
                         FROM wip_parameters wp
                        WHERE wp.organization_id = wmti.organization_id
                          AND wp.osp_shop_floor_status =
                              wsc.shop_floor_status_code))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_STATUS_NO_TXN1');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if users try to perform easy completion from Tomove of the
  -- last operation
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND wmti.fm_intraoperation_step_type = WIP_CONSTANTS.TOMOVE
     AND wmti.fm_operation_seq_num =
         (SELECT wo.operation_seq_num
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1)
             AND wo.next_operation_seq_num IS NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_NO_CMP_LAST_OP2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_TYPE is EZ Return and
  -- FM_INTRAOPERATION_STEP_TYPE not equal to Tomove
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN
     AND wmti.fm_intraoperation_step_type <> WIP_CONSTANTS.TOMOVE
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_FM_LAST_STEP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);
END fm_step;

-- validate to_operation_seq_num. To operation must be a valid operation.
-- For easy complete transaction, To operation must be the last operation.
-- Callers always need to pass this value except for Easy complete
-- transactions. If callers do not provide this info and it is complete
-- transaction, just default to_operation to last_op
PROCEDURE to_operation IS
BEGIN
  -- Set TO_OPERATION_SEQ_NUM to last_operation if TRANSACTION_TYPE is
  -- EZ Completion and TO_OPERATION_SEQ_NUM is null
  UPDATE wip_move_txn_interface wmti
     SET wmti.to_operation_seq_num =
         (SELECT wo.operation_seq_num
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1)
             AND wo.next_operation_seq_num IS NULL)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND wmti.to_operation_seq_num IS NULL;

  /*Bug 4421485->Even for plain moves we will derive to_operation as
   next count point operation */
  UPDATE wip_move_txn_interface wmti
     SET wmti.to_operation_seq_num =
         (SELECT MIN(wo.operation_seq_num)
          FROM wip_operations wo
          WHERE wo.organization_id = wmti.organization_id
          AND wo.wip_entity_id = wmti.wip_entity_id
          AND NVL(wo.repetitive_schedule_id, -1) =
              NVL(wmti.repetitive_schedule_id, -1)
          AND wo.operation_seq_num > wmti.fm_operation_seq_num
          AND wo.count_point_type = 1)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.MOVE_TXN
     AND wmti.to_operation_seq_num IS NULL;

  -- reset enums table
  enums.delete;
  -- Error out if TO_OPERATION_SEQ_NUM is null or TO_OPERATION_SEQ_NUM
  -- is invalid
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.to_operation_seq_num IS NULL
          OR
          (NOT EXISTS
               (SELECT 'X'
                  FROM wip_operations wo
                 WHERE wo.wip_entity_id = wmti.wip_entity_id
                   AND wo.organization_id = wmti.organization_id
                   AND wo.operation_seq_num = wmti.to_operation_seq_num
                   AND NVL(wo.repetitive_schedule_id, -1) =
                       NVL(wmti.repetitive_schedule_id, -1))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_OPERATION');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_OPERATION_SEQ_NUM',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_TYPE is EZ Ccmplete and TO_OPERATION_SEQ_NUM
  -- is not equal to the last operation.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND wmti.to_operation_seq_num <>
         (SELECT wo.operation_seq_num
            FROM wip_operations wo
           WHERE wo.wip_entity_id = wmti.wip_entity_id
             AND wo.organization_id = wmti.organization_id
             AND NVL(wo.repetitive_schedule_id, -1) =
                 NVL(wmti.repetitive_schedule_id, -1)
             AND wo.next_operation_seq_num IS NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_TO_LAST_OP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_OPERATION_SEQ_NUM',
            p_err_msg  => fnd_message.get);
END to_operation;

-- validate to_intraoperation_step_type. To step must be valid.
-- If easy complete transaction, to step must be "To move". If easy return,
-- to step cannot be "To move" when to operation is the last operation.
-- If callers do not provide this info and it is complete transaction,
-- just default to_step to to move
PROCEDURE to_step IS
BEGIN
  -- Set TO_INTRAOPERATION_STEP_TYPE to Tomove if TRANSACTION_TYPE is
  -- EZ Complete and TO_INTRAOPERATION_STEP_TYPE is null
  UPDATE wip_move_txn_interface wmti
     /*Bug Bug 4421485*/
     SET wmti.to_intraoperation_step_type =
         DECODE(wmti.transaction_type,
           WIP_CONSTANTS.COMP_TXN,WIP_CONSTANTS.TOMOVE, WIP_CONSTANTS.QUEUE)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     /*Bug Bug 4421485*/
     AND wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.MOVE_TXN)
     AND wmti.to_intraoperation_step_type IS NULL;

  -- reset enums table
  enums.delete;
  -- Error out if TO_INTRAOPERATION_STEP_TYPE is null or invalid
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.to_intraoperation_step_type IS NULL
          OR
          (NOT EXISTS
               (SELECT 'X'
                  FROM wip_valid_intraoperation_steps wvis,
                       wip_operations wo
                 WHERE wvis.organization_id = wmti.organization_id
                   AND wvis.step_lookup_type = wmti.to_intraoperation_step_type
                   AND wo.organization_id = wmti.organization_id
                   AND wo.wip_entity_id = wmti.wip_entity_id
                   AND wo.operation_seq_num = wmti.to_operation_seq_num
                   AND NVL(wo.repetitive_schedule_id, -1) =
                       NVL(wmti.repetitive_schedule_id, -1)
  -- Fixed bug 5059521. Since OSFM build routing as it goes, we cannot rely on
  -- wo.next_operation_seq_num IS NULL to determine that it is the last
  -- operation or not.
                   AND (((wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                               WIP_CONSTANTS.REPETITIVE)
                         OR
                         (wmti.entity_type = WIP_CONSTANTS.LOTBASED AND
                          wmti.transaction_type = WIP_CONSTANTS.COMP_TXN))
                        AND
                        ((wvis.record_creator = 'USER' OR
                         wvis.step_lookup_type = WIP_CONSTANTS.QUEUE)
                         OR
                        (wvis.record_creator = 'SYSTEM' AND
                         wo.next_operation_seq_num IS NULL)))
                         OR
                        (wmti.entity_type = WIP_CONSTANTS.LOTBASED AND
                         wmti.transaction_type <> WIP_CONSTANTS.COMP_TXN AND
                        (wvis.record_creator = 'USER' OR
                         wvis.step_lookup_type = WIP_CONSTANTS.QUEUE))))))

  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'TO_INTRAOPERATION_STEP_TYPE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if users try to move to the same operation and step as the
  -- FM_OPERATION_SEQ_NUM and FM_INTRAOPERATION_STEP_TYPE
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.fm_operation_seq_num = wmti.to_operation_seq_num
     AND wmti.fm_intraoperation_step_type = wmti.to_intraoperation_step_type
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_SAME_OP_AND_STEP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_TYPE is EZ Complete and
  -- TO_INTRAOPERATION_STEP_TYPE not equal to Tomove
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND wmti.to_intraoperation_step_type <> WIP_CONSTANTS.TOMOVE
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_EZ_TO_LAST_STEP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if user try to easy complete job/schedule that has No Move shop
  -- floor status attached to Tomove of the last operation
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND EXISTS
         (SELECT 'X'
            FROM wip_shop_floor_status_codes wsc,
                 wip_shop_floor_statuses ws
           WHERE wsc.organization_id = wmti.organization_id
             AND ws.organization_id = wmti.organization_id
             AND ws.wip_entity_id = wmti.wip_entity_id
             AND (wmti.line_id IS NULL OR ws.line_id = wmti.line_id)
             AND ws.operation_seq_num = wmti.to_operation_seq_num
             AND ws.intraoperation_step_type = WIP_CONSTANTS.TOMOVE
             AND ws.shop_floor_status_code = wsc.shop_floor_status_code
             AND wsc.status_move_flag = WIP_CONSTANTS.NO
             AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_STATUS_NO_TXN2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

   -- reset enums table
  enums.delete;
  -- Error out if wip_parameter do not allow move over no_move shop floor
  -- status, and there are no_move status in between
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wip_sf_status.count_no_move_statuses(
           wmti.organization_id,             -- p_org_id
           wmti.wip_entity_id,               -- p_wip_id
           wmti.line_id,                     -- p_line_id
           wmti.repetitive_schedule_id,      -- p_sched_id
           wmti.fm_operation_seq_num,        -- p_fm_op
           wmti.fm_intraoperation_step_type, -- p_fm_step
           wmti.to_operation_seq_num,        -- p_to_op
           wmti.to_intraoperation_step_type, -- p_to_step
           -- Fixed bug 2121222
           wmti.source_code) > 0             -- p_source_code
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name ('WIP', 'WIP_NO_MOVE_SF_STATUS_BETWEEN');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);
END to_step;

-- transaction_quantity must be positive
PROCEDURE transaction_qty IS
BEGIN
  -- reset enums table
  enums.delete;

  -- Error out if TRANSACTION_QUANTITY is negative or zero
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_quantity <= 0
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('MFG', 'MFG_GREATER_THAN');
  fnd_message.set_token('ENTITY1', 'TRANSACTION_QUANTITY');
  fnd_message.set_token('ENTITY2', 'zero');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_QUANTITY',
            p_err_msg  => fnd_message.get);

END transaction_qty;


-- transaction_uom must be defined
PROCEDURE transaction_uom IS
BEGIN
  -- reset enums table
  enums.delete;
  -- Error out if TRANSACTION_UOM is invalid
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND NOT EXISTS
         (SELECT 'X'
            FROM mtl_item_uoms_view miuv
           WHERE miuv.organization_id = wmti.organization_id
             AND miuv.inventory_item_id = wmti.primary_item_id
             AND miuv.uom_code = wmti.transaction_uom)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'TRANSACTION_UOM');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_UOM',
            p_err_msg  => fnd_message.get);

END transaction_uom;

-- validate overcompletion_transaction_qty. This is an optional info.
-- The caller need to provide this only for overmove/overcompletion txns.
-- However, we do not allow overreturn, and over move for backward move.
-- We also not allow overmove/overcomplete from scrap or reject step.
-- This value cannot be zero or negative either.
PROCEDURE ocpl_txn_qty IS
BEGIN
  -- reset enums table
  enums.delete;

  -- Error out if OVERCOMPLETION_TRANSACTION_QTY is negative or zero
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.overcompletion_transaction_qty IS NOT NULL
     AND wmti.overcompletion_transaction_qty <= 0
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('MFG', 'MFG_GREATER_THAN');
  fnd_message.set_token('ENTITY1', 'OVERCOMPLETION_TRANSACTION_QTY');
  fnd_message.set_token('ENTITY2', 'zero');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'OVERCOMPLETION_TRANSACTION_QTY',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if OVERCOMPLETION_TRANSACTION_QTY is greater than
  -- TRANSACTION_QUANTITY
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.overcompletion_transaction_qty IS NOT NULL
     AND wmti.overcompletion_transaction_qty > wmti.transaction_quantity
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('MFG', 'MFG_GREATER_OR_EQUAL');
  fnd_message.set_token('ENTITY1', 'TRANSACTION_QUANTITY');
  fnd_message.set_token('ENTITY2', 'OVERCOMPLETION_TRANSACTION_QTY');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'OVERCOMPLETION_TRANSACTION_QTY',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if user try to do over Return
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN
     AND wmti.overcompletion_transaction_qty IS NOT NULL
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_OC_RET');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'OVERCOMPLETION_TRANSACTION_QTY',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if user try to do over Return from Scrap/Return from Reject
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.fm_intraoperation_step_type IN (WIP_CONSTANTS.SCRAP,
                                              WIP_CONSTANTS.REJECT)
     AND wmti.overcompletion_transaction_qty IS NOT NULL
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_OC_SCR_REJ');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'OVERCOMPLETION_TRANSACTION_QTY',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if OVERCOMPLETION_TRANSACTION_QTY is specified for backward
  -- move txns
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.to_operation_seq_num < wmti.fm_operation_seq_num OR
         (wmti.to_operation_seq_num = wmti.fm_operation_seq_num AND
          wmti.to_intraoperation_step_type <
          wmti.fm_intraoperation_step_type))
     AND wmti.overcompletion_transaction_qty IS NOT NULL
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_OC_REV_MOVE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'OVERCOMPLETION_TRANSACTION_QTY',
            p_err_msg  => fnd_message.get);

END ocpl_txn_qty;

-- validate transaction_id against the one in WIP_MOVE_TRANSACTIONS, and
-- WIP_MOVE_TXN_INTERFACE. This value need to be unique.
PROCEDURE transaction_id IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Generate TRANSACTION_ID if user does not provide this value
  UPDATE wip_move_txn_interface wmti
     SET wmti.transaction_id = wip_transactions_s.nextval
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_id IS NULL;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'TRANSACTION_ID');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti1.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'TRANSACTION_ID',                -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti1.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti1.created_by, -1),
           wmti1.last_update_login,
           wmti1.request_id,
           wmti1.program_application_id,
           wmti1.program_id,
           wmti1.program_update_date
      FROM wip_move_txn_interface wmti1
     WHERE wmti1.group_id = g_group_id
       AND wmti1.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti1.process_status = WIP_CONSTANTS.RUNNING
       AND (EXISTS
           (SELECT 'X'
              FROM wip_move_transactions wmt
             WHERE wmt.transaction_id = wmti1.transaction_id)
            OR
           (1 <>
           (SELECT count(*)
              FROM wip_move_txn_interface wmti2
             WHERE wmti2.transaction_id = wmti1.transaction_id)));

END transaction_id;

-- derive primary_quantity from transaction_quantity and transaction_uom.
-- you cannot easy return more than available quantity and organization do
-- not allow negative balance
PROCEDURE primary_qty IS

CURSOR c_availQty IS
  SELECT wmti.transaction_id txn_id,
         wmti.organization_id org_id,
         wmti.primary_item_id item_id,
         wmti.primary_quantity primary_qty,
         DECODE(msik.serial_number_control_code,
           WIP_CONSTANTS.FULL_SN, fnd_api.g_true,
           WIP_CONSTANTS.DYN_RCV_SN, fnd_api.g_true,
           fnd_api.g_false) is_ser_ctrl,
         DECODE(msik.lot_control_code,
           WIP_CONSTANTS.LOT, fnd_api.g_true,
           fnd_api.g_false) is_lot_ctrl,
         DECODE(msik.revision_qty_control_code,
           WIP_CONSTANTS.REV, fnd_api.g_true,
           fnd_api.g_false) is_rev_ctrl,
         DECODE(msik.revision_qty_control_code, -- revision
                 WIP_CONSTANTS.REV, NVL(wdj.bom_revision,
                   bom_revisions.get_item_revision_fn
                    ('EXCLUDE_OPEN_HOLD',        -- eco_status
                     'ALL',                      -- examine_type
                      wmti.organization_id,       -- org_id
                      wmti.primary_item_id,       -- item_id
                      wmti.transaction_date       -- rev_date
                     )),
                 NULL) revision,                  -- revision
         wdj.lot_number lot,
         wmti.transaction_date txn_date,
         wdj.completion_subinventory subinv,
         wdj.completion_locator_id locID,
         mp.negative_inv_receipt_code negative_allow,
         msik.concatenated_segments assembly_name
    FROM wip_discrete_jobs wdj,
         mtl_system_items_kfv msik,
         mtl_parameters mp,
         wip_move_txn_interface wmti
   WHERE wdj.primary_item_id = msik.inventory_item_id
     AND wdj.organization_id = msik.organization_id
     AND wdj.organization_id = mp.organization_id
     AND wmti.wip_entity_id  = wdj.wip_entity_id
     AND wmti.organization_id = wdj.organization_id
     AND wmti.entity_type <> WIP_CONSTANTS.REPETITIVE
     AND wmti.group_id   = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN;


CURSOR c_repAvailQty IS
  SELECT wmti.transaction_id txn_id,
         wmti.organization_id org_id,
         wmti.primary_item_id item_id,
         wmti.primary_quantity primary_qty,
         DECODE(msik.serial_number_control_code,
           WIP_CONSTANTS.FULL_SN, fnd_api.g_true,
           WIP_CONSTANTS.DYN_RCV_SN, fnd_api.g_true,
           fnd_api.g_false) is_ser_ctrl,
         DECODE(msik.lot_control_code,
           WIP_CONSTANTS.LOT, fnd_api.g_true,
           fnd_api.g_false) is_lot_ctrl,
         DECODE(msik.revision_qty_control_code,
           WIP_CONSTANTS.REV, fnd_api.g_true,
           fnd_api.g_false) is_rev_ctrl,
         DECODE(msik.revision_qty_control_code, -- revision
                 WIP_CONSTANTS.REV, NVL(wrs.bom_revision,
                   bom_revisions.get_item_revision_fn
                    ('EXCLUDE_OPEN_HOLD',        -- eco_status
                     'ALL',                      -- examine_type
                      wmti.organization_id,       -- org_id
                      wmti.primary_item_id,       -- item_id
                      wmti.transaction_date       -- rev_date
                     )),
                 NULL) revision,                  -- revision
         NULL lot,
         wmti.transaction_date txn_date,
         wri.completion_subinventory subinv,
         wri.completion_locator_id locID,
         mp.negative_inv_receipt_code negative_allow,
         msik.concatenated_segments assembly_name
    FROM wip_repetitive_schedules wrs,
         wip_repetitive_items wri,
         mtl_system_items_kfv msik,
         mtl_parameters mp,
         wip_move_txn_interface wmti
   WHERE wmti.primary_item_id = msik.inventory_item_id
     AND wmti.organization_id = msik.organization_id
     AND wmti.organization_id = mp.organization_id
     AND wrs.wip_entity_id = wmti.wip_entity_id
     AND wrs.organization_id = wmti.organization_id
     AND wrs.line_id = wmti.line_id
     AND wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
     AND wri.organization_id = wmti.organization_id
     AND wri.wip_entity_id = wmti.wip_entity_id
     AND wri.line_id = wmti.line_id
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.group_id   = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN;

l_availQty     c_availQty%ROWTYPE;
l_repAvailQty  c_repAvailQty%ROWTYPE;
l_returnStatus VARCHAR2(1);
l_qoh          NUMBER;
l_rqoh         NUMBER;
l_qr           NUMBER;
l_qs           NUMBER;
l_att          NUMBER;
l_atr          NUMBER;
l_errMsg       VARCHAR2(240);
l_msg_count    NUMBER;
l_msg_data     VARCHAR2(2000);
BEGIN
  -- Derive PRIMARY_QUANTITY from TRANSACTION_QUANTITY and TRANSACTION_UOM
  -- if PRIMARY_QUANTITY is null

  /** Bug fix 5000113.  primary_quantity should be updated in sync with
   *  transaction_quantity, and not just when primary_quantity is null.
   */

  UPDATE wip_move_txn_interface wmti
     SET wmti.primary_quantity =
         (SELECT ROUND(wmti.transaction_quantity * mucv.conversion_rate,
                       WIP_CONSTANTS.INV_MAX_PRECISION)
            FROM mtl_uom_conversions_view mucv
           WHERE mucv.organization_id = wmti.organization_id
             AND mucv.inventory_item_id = wmti.primary_item_id
             AND mucv.uom_code = wmti.transaction_uom)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;
     --AND wmti.primary_quantity IS NULL;

  /* End of bug fix 5000113.

  -- Set Error Message
  fnd_message.set_name('MFG', 'MFG_GREATER_THAN');
  fnd_message.set_token('ENTITY1', 'PRIMARY_QUANTITY');
  fnd_message.set_token('ENTITY2', 'zero');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if PRIMARY_QUANTITY is zero
  -- Insert error record into WIP_TXN_INTERFACE_ERRORS. Do not update
  -- WMTI.PROCESS_STATUS to Error because it is a minor issue. We will
  -- continue validating other values.
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'PRIMARY_QUANTITY',              -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wmti.primary_quantity = 0;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'PRIMARY_QUANTITY');
  fnd_message.set_token('ENTITY2', 'TRANSACTION_QUANTITY');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if PRIMARY_QUANTITY is not consistent with TRANSACTION_QUANTITY
  -- Insert error record into WIP_TXN_INTERFACE_ERRORS. Do not update
  -- WMTI.PROCESS_STATUS to Error because it is a minor issue. We will
  -- continue validating other values.
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'PRIMARY_QUANTITY',              -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           mtl_uom_conversions_view mucv
     WHERE mucv.organization_id = wmti.organization_id
       AND mucv.inventory_item_id = wmti.primary_item_id
       AND mucv.uom_code = wmti.transaction_uom
       AND wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       -- Fixed bug 4900010. Round both transaction_quantity and
       -- primary_quantity before making comparison.
       AND ROUND(wmti.transaction_quantity * mucv.conversion_rate,
                 WIP_CONSTANTS.INV_MAX_PRECISION) <>
           ROUND(wmti.primary_quantity, WIP_CONSTANTS.INV_MAX_PRECISION);

  -- Set Error Message
  /* Fix for Bug#4192541. Removed following check as this is only warning
     condition
  */

  /*
  fnd_message.set_name('WIP', 'WIP_MIN_XFER_QTY');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if PRIMARY_QUANTITY less than MININUM_TRANSFER_QUANTITY
  -- defined at FM_OPERATION_SEQ_NUM and transactions are  not Scrap/Reject
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'PRIMARY_QUANTITY',              -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           wip_operations wo
     WHERE wo.organization_id = wmti.organization_id
       AND wo.wip_entity_id = wmti.wip_entity_id
       AND NVL(wo.repetitive_schedule_id, -1) =
           NVL(wmti.repetitive_schedule_id, -1)
       AND wo.operation_seq_num = wmti.fm_operation_seq_num
       AND wmti.fm_intraoperation_step_type NOT IN (WIP_CONSTANTS.SCRAP,
                                                    WIP_CONSTANTS.REJECT)
       AND wmti.to_intraoperation_step_type NOT IN (WIP_CONSTANTS.SCRAP,
                                                    WIP_CONSTANTS.REJECT)
       AND wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wo.minimum_transfer_quantity > wmti.primary_quantity;


  */
  -- Set Error Message
  fnd_message.set_name ('INV', 'INV_NO_NEG_BALANCES');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- User cannot do easy return more than available quantity if
  -- organization do not allow negative balance. (Discrete/OSFM)
  FOR l_availQty IN c_availQty
  LOOP
    inv_quantity_tree_pub.query_quantities(
      p_api_version_number    => 1.0,
      p_init_msg_lst          => 'T',
      p_onhand_source         => inv_quantity_tree_pvt.g_all_subs,
      p_organization_id       => l_availQty.org_id,
      p_inventory_item_id     => l_availQty.item_id,
      p_tree_mode             => inv_quantity_tree_pvt.g_loose_only_mode,
      p_is_revision_control   => fnd_api.to_boolean(l_availQty.is_rev_ctrl),
      p_is_lot_control        => fnd_api.to_boolean(l_availQty.is_lot_ctrl),
      p_is_serial_control     => fnd_api.to_boolean(l_availQty.is_ser_ctrl),
      p_demand_source_type_id => 5, -- WIP
      p_revision              => l_availQty.revision,
      p_lot_number            => l_availQty.lot,
      p_lot_expiration_date   => l_availQty.txn_date,
      p_subinventory_code     => l_availQty.subinv,
      p_locator_id            => l_availQty.locID,
      x_return_status         => l_returnStatus,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      x_qoh                   => l_qoh,
      x_rqoh                  => l_rqoh,
      x_qr                    => l_qr,
      x_qs                    => l_qs,
      x_att                   => l_att,
      x_atr                   => l_atr);

    IF(l_returnStatus <> 'S')THEN
      add_error(p_txn_id   => l_availQty.txn_id,
                p_err_col  => 'PRIMARY_QUANTITY',
                p_err_msg  => l_msg_data);
    ELSE
      IF(l_availQty.negative_allow = WIP_CONSTANTS.NO AND
         l_att < l_availQty.primary_qty) THEN
        add_error(p_txn_id   => l_availQty.txn_id,
                  p_err_col  => 'PRIMARY_QUANTITY',
                  p_err_msg  => l_availQty.assembly_name||':'||l_errMsg);
      END IF;
    END IF;
  END LOOP; -- Only for EZ Return transactions (Discrete/OSFM)

  -- User cannot do easy return more than available quantity if
  -- organization do not allow negative balance (Repetitive)
  FOR l_repAvailQty IN c_repAvailQty
  LOOP
    inv_quantity_tree_pub.query_quantities(
      p_api_version_number    => 1.0,
      p_init_msg_lst          => 'T',
      p_onhand_source         => inv_quantity_tree_pvt.g_all_subs,
      p_organization_id       => l_repAvailQty.org_id,
      p_inventory_item_id     => l_repAvailQty.item_id,
      p_tree_mode             => inv_quantity_tree_pvt.g_loose_only_mode,
      p_is_revision_control   => fnd_api.to_boolean(l_repAvailQty.is_rev_ctrl),
      p_is_lot_control        => fnd_api.to_boolean(l_repAvailQty.is_lot_ctrl),
      p_is_serial_control     => fnd_api.to_boolean(l_repAvailQty.is_ser_ctrl),
      p_demand_source_type_id => 5, -- WIP
      p_revision              => l_repAvailQty.revision,
      p_lot_number            => l_repAvailQty.lot,
      p_lot_expiration_date   => l_repAvailQty.txn_date,
      p_subinventory_code     => l_repAvailQty.subinv,
      p_locator_id            => l_repAvailQty.locID,
      x_return_status         => l_returnStatus,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      x_qoh                   => l_qoh,
      x_rqoh                  => l_rqoh,
      x_qr                    => l_qr,
      x_qs                    => l_qs,
      x_att                   => l_att,
      x_atr                   => l_atr);

    IF(l_returnStatus <> 'S')THEN
      add_error(p_txn_id   => l_repAvailQty.txn_id,
                p_err_col  => 'PRIMARY_QUANTITY',
                p_err_msg  => l_msg_data);
    ELSE
      IF(l_repAvailQty.negative_allow = WIP_CONSTANTS.NO AND
         l_att < l_repAvailQty.primary_qty) THEN
        add_error(p_txn_id   => l_repAvailQty.txn_id,
                  p_err_col  => 'PRIMARY_QUANTITY',
                  p_err_msg  => l_repAvailQty.assembly_name||':'||l_errMsg);
      END IF;
    END IF;
  END LOOP; -- Only for EZ Return transactions(Repetitive)
END primary_qty;

-- derive primary_uom from primary_item_id
PROCEDURE primary_uom IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Derive PRIMARY_UOM from PRIMARY_ITEM_ID provided if PRIMARY_UOM is null
  UPDATE wip_move_txn_interface wmti
     SET wmti.primary_uom =
         (SELECT msi.primary_uom_code
            FROM mtl_system_items msi
           WHERE msi.organization_id = wmti.organization_id
             AND msi.inventory_item_id = wmti.primary_item_id)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.primary_uom IS NULL;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'PRIMARY_UOM');
  fnd_message.set_token('ENTITY2', 'PRIMARY_ITEM_ID');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- If caller provide PRIMARY_UOM, it must be consistent with
  -- primary_item_id provided
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,              -- transaction_id
           l_errMsg,                         -- error_message
           'PRIMARY_UOM',                    -- error_column
           SYSDATE,                          -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                          -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           mtl_system_items msi
     WHERE msi.organization_id = wmti.organization_id
       AND msi.inventory_item_id = wmti.primary_item_id
       AND wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND msi.primary_uom_code <> wmti.primary_uom;

END primary_uom;

-- derive overcomplete_primary_quantity from overcomplete_transaction_quantity
-- and transaction_uom provided.
PROCEDURE ocpl_primary_qty IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Derive OVERCOMPLETE_PRIMARY_QUANTITY from
  -- OVERCOMPLETE_TRANSACTION_QUANTITY and TRANSACTION_UOM provided.

  /** Bug fix 5000113.  overcompletion_primary_qty should be updated in sync with
   *  transaction_quantity, and not just when overcompletion_quantity is null.
   */

  UPDATE wip_move_txn_interface wmti
     SET wmti.overcompletion_primary_qty =
         (SELECT ROUND(wmti.overcompletion_transaction_qty *
                       mucv.conversion_rate, WIP_CONSTANTS.INV_MAX_PRECISION)
            FROM mtl_uom_conversions_view mucv
           WHERE mucv.organization_id = wmti.organization_id
             AND mucv.inventory_item_id = wmti.primary_item_id
             AND mucv.uom_code = wmti.transaction_uom)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.overcompletion_transaction_qty IS NOT NULL;
     --AND wmti.overcompletion_primary_qty IS NULL;

  -- End of bug fix 5000113.

  -- Set Error Message
  fnd_message.set_name('MFG', 'MFG_GREATER_THAN');
  fnd_message.set_token('ENTITY1', 'OVERCOMPLETION_PRIMARY_QTY');
  fnd_message.set_token('ENTITY2', 'zero');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if OVERCOMPLETION_PRIMARY_QTY is zero
  -- Insert error record into WIP_TXN_INTERFACE_ERRORS. Do not update
  -- WMTI.PROCESS_STATUS to Error because it is a minor issue. We will
  -- continue validating other values.
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'OVERCOMPLETION_PRIMARY_QTY',    -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wmti.overcompletion_primary_qty = 0;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'OVERCOMPLETION_PRIMARY_QTY');
  fnd_message.set_token('ENTITY2', 'OVERCOMPLETION_TRANSACTION_QTY');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- If caller provide this info, it must be consistent with
  -- overcompletion_transaction_qty provided
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'OVERCOMPLETION_PRIMARY_QTY',    -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           mtl_uom_conversions_view mucv
     WHERE mucv.organization_id = wmti.organization_id
       AND mucv.inventory_item_id = wmti.primary_item_id
       AND mucv.uom_code = wmti.transaction_uom
       AND wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wmti.overcompletion_transaction_qty IS NOT NULL
       -- Fixed bug 4900010. Round both transaction_quantity and
       -- primary_quantity before making comparison.
       AND ROUND(wmti.overcompletion_transaction_qty * mucv.conversion_rate,
                 WIP_CONSTANTS.INV_MAX_PRECISION) <>
           ROUND(wmti.overcompletion_primary_qty,
                 WIP_CONSTANTS.INV_MAX_PRECISION);
END ocpl_primary_qty;

-- This value must be null. The move processor will be the one who insert
-- child record and link it with parent record
PROCEDURE ocpl_txn_id IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'OVERCOMPLETION_TRANSACTION_ID');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- This value must be null because New Move Processor will be the one
  -- who insert child record and populate this value
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'OVERCOMPLETION_TRANSACTION_ID',    -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wmti.overcompletion_transaction_id IS NOT NULL;

END ocpl_txn_id;

-- This is an optional info. However, if the caller provided some values,
-- it must be valid. If the caller pass reason_name, we will derive the
-- reason_id. If the caller pass both, both value must be consistent to
-- each other.
PROCEDURE reason_id IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Derive REASON_ID from REASON_NAME provided
  UPDATE wip_move_txn_interface wmti
     SET wmti.reason_id =
         (SELECT mtr.reason_id
            FROM mtl_transaction_reasons mtr
           WHERE mtr.reason_name = wmti.reason_name
             AND NVL(mtr.disable_date, SYSDATE) >= SYSDATE)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.reason_id IS NULL
     AND wmti.reason_name IS NOT NULL;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'REASON_ID');
  fnd_message.set_token('ENTITY2', 'REASON_NAME');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- If caller provide REASON_ID, it must be consistent with
  -- REASON_NAME provided
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,              -- transaction_id
           l_errMsg,                         -- error_message
           'REASON_ID/NAME',                 -- error_column
           SYSDATE,                          -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                          -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND (wmti.reason_id IS NOT NULL OR wmti.reason_name IS NOT NULL)
       AND NOT EXISTS
           (SELECT 'X'
              FROM mtl_transaction_reasons mtr
             WHERE mtr.reason_id = NVL(wmti.reason_id, mtr.reason_id)
               AND mtr.reason_name = NVL(wmti.reason_name, mtr.reason_name)
               AND NVL(mtr.disable_date, SYSDATE) >= SYSDATE);

END reason_id;

-- validate scrap_account_id. This value can be either required or optional
-- info for the discrete and repetitive scrap transaction. It depends on the
-- value setup in WIP_PARAMETERS. However it is always an optional info for
-- OSFM txns. If the caller provided this info, it must be valid account_id
PROCEDURE scrap_account_id IS
l_scrap_flag NUMBER;
l_errMsg VARCHAR2(240);
BEGIN
  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_NOT_VALID');
  fnd_message.set_token('ENTITY', 'SCRAP_ACCOUNT_ID');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'SCRAP_ACCOUNT_ID',              -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           wip_parameters wp
     WHERE wp.organization_id = wmti.organization_id
       AND wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP OR
            wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
       AND ((wmti.scrap_account_id IS NULL
             AND wp.mandatory_scrap_flag = WIP_CONSTANTS.YES
             AND wmti.entity_type NOT IN(WIP_CONSTANTS.LOTBASED,
                                         WIP_CONSTANTS.CLOSED_OSFM))
            OR
             (wmti.scrap_account_id IS NOT NULL AND
              NOT EXISTS
                  (SELECT 'X'
                     FROM hr_organization_information hoi,
                          gl_sets_of_books gsob,
                          gl_code_combinations gcc
                    WHERE gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
                      and gsob.set_of_books_id =
                          to_number(decode(rtrim(translate(
                            hoi.org_information1,'0123456789',' ')),
                            null, hoi.org_information1,
                            -99999))
                      and (hoi.org_information_context || '') =
                          'Accounting Information'
                      AND hoi.organization_id = wmti.organization_id
                      AND gcc.code_combination_id = wmti.scrap_account_id
                      AND gcc.detail_posting_allowed_flag = 'Y'
                      AND gcc.summary_flag = 'N'
                      and gcc.enabled_flag = 'Y'
                      AND TRUNC(wmti.transaction_date) BETWEEN
                          NVL(gcc.start_date_active,
                              TRUNC(wmti.transaction_date))
                          AND NVL(gcc.end_date_active,
                                  TRUNC(wmti.transaction_date)))));

END scrap_account_id;

-- validate last_updated_by against fnd_user table. The caller have an option
-- to provide either last_updated_by or last_updated_by_name. If the caller
-- pass last_updated_by, the id need to be valid. If the caller pass
-- last_updated_by_name, we will derive the ID. If the caller pass both
-- both value must be consistent to each other.
PROCEDURE last_updated_by IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Derive LAST_UPDATED_BY if user provided only LAST_UPDATED_BY_NAME
  UPDATE wip_move_txn_interface wmti
     SET wmti.last_updated_by =
         (SELECT fu.user_id
            FROM fnd_user fu
           WHERE fu.user_name = wmti.last_updated_by_name
             AND SYSDATE BETWEEN fu.start_date AND NVL(fu.end_date, SYSDATE))
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.last_updated_by IS NULL
     AND wmti.last_updated_by_name IS NOT NULL;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'LAST_UPDATED_BY');
  fnd_message.set_token('ENTITY2', 'LAST_UPDATED_BY_NAME');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if LAST_UPDATED_BY is not consistent with LAST_UPDATED_BY_NAME
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'LAST_UPDATED_BY/BY_NAME',       -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wmti.last_updated_by IS NULL; -- cannot derive LAST_UPDATED_BY

END last_updated_by;

-- validate created_by against fnd_user table. The caller have an option
-- to provide either created_by or created_by_name. If the caller
-- pass created_by, the id need to be valid. If the caller pass
-- created_by_name, we will derive the ID. If the caller pass both
-- both value must be consistent to each other.
PROCEDURE created_by IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Derive CREATED_BY if user provided only CREATED_BY_NAME
  UPDATE wip_move_txn_interface wmti
     SET wmti.created_by =
         (SELECT fu.user_id
            FROM fnd_user fu
           WHERE fu.user_name = wmti.created_by_name
             AND SYSDATE BETWEEN fu.start_date AND NVL(fu.end_date, SYSDATE))
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.created_by IS NULL
     AND wmti.created_by_name IS NOT NULL;

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_ID_CODE_COMBINATION');
  fnd_message.set_token('ENTITY1', 'CREATED_BY');
  fnd_message.set_token('ENTITY2', 'CREATED_BY_NAME');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if CREATED_BY is not consistent with CREATED_BY_NAME
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'CREATED_BY/BY_NAME',            -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND ((wmti.created_by IS NULL) -- cannot derive LAST_UPDATED_BY
            OR
             (NOT EXISTS
              (SELECT 'X'
                 FROM fnd_user fu
                WHERE fu.user_name = NVL(wmti.created_by_name,
                                         fu.user_name)
                  AND fu.user_id = wmti.created_by
                  AND SYSDATE BETWEEN fu.start_date AND
                                      NVL(fu.end_date, SYSDATE))));
END created_by;

-- This procedure is used to validate osp transactions. User cannot move into
-- a queue of OSP operation unless the department associated to that operation
-- has a location for PO_RECEIVE. For PO_MOVE the department associated with
-- the next operation after to_op must have location. If to_op is the last op
-- , the department associated to that operation must have location.
-- The user must be a valid employee to perform osp transactions.
PROCEDURE osp_validation IS
l_errMsg VARCHAR2(240);
BEGIN
  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_PO_MOVE_LOCATION');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if user try to move into a queue of OSP operation and the
  -- department associated to that operation does not have a location
  -- for PO_RECEIVE. For PO_MOVE the department associated with
  -- the next operation after to_op must have location. If to_op is the last op
  --  the department associated to that operation must have location.
  INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'TO_OP_SEQ_NUM/CREATED_BY',      -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND EXISTS
           (SELECT 'X'
              FROM bom_departments bd,
                   wip_operation_resources wor,
                   wip_operations wo1,
                   wip_operations wo2
             WHERE wor.organization_id = wmti.organization_id
               AND wor.wip_entity_id = wmti.wip_entity_id
               AND wor.operation_seq_num = wmti.to_operation_seq_num
               AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
               AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
               AND (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                          WIP_CONSTANTS.LOTBASED)
                    OR
                    (wmti.entity_type = WIP_CONSTANTS.REPETITIVE AND
                     wor.repetitive_schedule_id IN
                     (SELECT wrs.repetitive_schedule_id
                        FROM wip_repetitive_schedules wrs
                       WHERE wrs.wip_entity_id = wmti.wip_entity_id
                         AND wrs.organization_id = wmti.organization_id
                         AND wrs.line_id = wmti.line_id
                         AND wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                                 WIP_CONSTANTS.COMP_CHRG))))
               AND wo1.organization_id = wor.organization_id
               AND wo1.wip_entity_id = wor.wip_entity_id
               AND NVL(wo1.repetitive_schedule_id,-1) =
                   NVL(wor.repetitive_schedule_id,-1)
               AND wo1.operation_seq_num = wor.operation_seq_num
               AND wo2.organization_id = wo1.organization_id
               AND wo2.wip_entity_id = wo1.wip_entity_id
               AND NVL(wo2.repetitive_schedule_id,-1) =
                   NVL(wo1.repetitive_schedule_id,-1)
               AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
                     wo2.operation_seq_num = wor.operation_seq_num)
                     OR
                    (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
                    ((wo1.next_operation_seq_num IS NOT NULL AND
                      wo1.next_operation_seq_num = wo2.operation_seq_num)
                      OR
                     (wo1.next_operation_seq_num IS NULL AND
                      wo2.operation_seq_num = wor.operation_seq_num))))
               AND bd.organization_id = wmti.organization_id
               AND wo2.department_id = bd.department_id
               AND bd.location_id IS NULL);

  -- Set Error Message
  fnd_message.set_name('WIP', 'WIP_VALID_EMPLOYEE');
  l_errMsg := substrb(fnd_message.get, 1, 240);

  -- Error out if the user who try to do OSP transaction is not an employee
   INSERT INTO wip_txn_interface_errors(
      transaction_id,
      error_message,
      error_column,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT wmti.transaction_id,             -- transaction_id
           l_errMsg,                        -- error_message
           'TO_OP_SEQ_NUM/CREATED_BY',      -- error_column
           SYSDATE,                         -- last_update_date
           NVL(wmti.last_updated_by, -1),
           SYSDATE,                         -- creation_date
           NVL(wmti.created_by, -1),
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = g_group_id
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND EXISTS
           (SELECT 'Outside processing resources exist'
              FROM wip_operation_resources wor
             WHERE wor.organization_id = wmti.organization_id
               AND wor.wip_entity_id = wmti.wip_entity_id
               AND wor.operation_seq_num = wmti.to_operation_seq_num
               AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
               AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
               AND wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                           WIP_CONSTANTS.PO_MOVE)
               AND (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                         WIP_CONSTANTS.LOTBASED)
                    OR
                    (wmti.entity_type = WIP_CONSTANTS.REPETITIVE AND
                     wor.repetitive_schedule_id IN
                      (SELECT wrs.repetitive_schedule_id
                         FROM wip_repetitive_schedules wrs
                        WHERE wrs.organization_id = wmti.organization_id
                          AND wrs.wip_entity_id = wmti.wip_entity_id
                          AND wrs.line_id = wmti.line_id
                          AND wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                                  WIP_CONSTANTS.COMP_CHRG)))))
       AND NOT EXISTS
           (SELECT 'Current user is an employee'
                FROM fnd_user fu,
                     per_people_f ppf
               WHERE fu.user_id = wmti.created_by
                 AND fu.employee_id = ppf.person_id);

END osp_validation;

-- validate serial related information. This validation is only useful if
-- user try to do background serialized txns.
PROCEDURE serial_validation IS
BEGIN
  -- reset enums table
  enums.delete;
  -- Users cannot move cross 'Queue' of serialization start op. User need to
  -- move 2 step. The first time move to Queue of serialization start op, then
  -- serial move. For backward move, do serial move first.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS -- serialized job
         (SELECT 'X'
            FROM wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.serialization_start_op IS NOT NULL
             AND (-- Forward move
                  (wmti.fm_operation_seq_num < wdj.serialization_start_op AND
                   (wmti.to_operation_seq_num > wdj.serialization_start_op
                    OR
                   (wmti.to_operation_seq_num = wdj.serialization_start_op AND
                    wmti.to_intraoperation_step_type <> WIP_CONSTANTS.QUEUE)))
                   OR
                   -- Backward move
                  (wmti.to_operation_seq_num < wdj.serialization_start_op AND
                   (wmti.fm_operation_seq_num > wdj.serialization_start_op
                    OR
                   (wmti.fm_operation_seq_num = wdj.serialization_start_op AND
                    wmti.fm_intraoperation_step_type <> WIP_CONSTANTS.QUEUE)))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_MOVE_CROSS_START_OP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM/TO_STEP, FM/TO_OP',
            p_err_msg  => fnd_message.get);

-- Comment out the validation below because Express Move can be done for more
-- then one quantity. Moreover, this validation was already done through the
-- UI(mobile and MES), and we do not support serilized move in the background.
/*
  -- reset enums table
  enums.delete;
  -- If user try to do serialized transaction, primary_quantity must be 1.
  -- This validation is only for serialized discrete job. For serialized
  -- OSFM job, primary_quantity can be more than 1.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS -- serialized discrete job and serialized transaction
         (SELECT 'X'
            FROM wip_discrete_jobs wdj,
                 wip_entities we
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.wip_entity_id = we.wip_entity_id
             AND we.entity_type = WIP_CONSTANTS.DISCRETE
             AND wdj.serialization_start_op IS NOT NULL
             AND wmti.fm_operation_seq_num >= wdj.serialization_start_op
             AND wmti.to_operation_seq_num >= wdj.serialization_start_op
             AND wmti.primary_quantity <> 1)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_SERIAL_QTY');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION/PRIMARY_QUANTITY',
            p_err_msg  => fnd_message.get);
*/

  -- reset enums table
  enums.delete;
  -- if user provide serial number information for non-serialized job, or
  -- serialized job with non-serialized move, error out.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS -- regular job
         (SELECT 'X'
            FROM wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND (wdj.serialization_start_op IS NULL -- non-serialized job
                  OR -- serialized job with non-serialized move
                  (wdj.serialization_start_op IS NOT NULL
                   AND
                  (wmti.fm_operation_seq_num < wdj.serialization_start_op OR
                   (wmti.fm_operation_seq_num = wdj.serialization_start_op AND
                    wmti.fm_intraoperation_step_type = WIP_CONSTANTS.QUEUE))
                   AND
                  (wmti.to_operation_seq_num < wdj.serialization_start_op OR
                   (wmti.to_operation_seq_num = wdj.serialization_start_op AND
                    wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE))))
         )
     AND EXISTS
         (SELECT 'X'
            FROM wip_serial_move_interface wsmi
           WHERE wsmi.transaction_id = wmti.transaction_id)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_SERIAL_INFO_NOT_ALLOW');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WSMI.ASSEMBLY_SERIAL_NUMBER',
            p_err_msg  => fnd_message.get);


  -- reset enums table
  enums.delete;
  -- if user try to do serialized transaction, number of serial records must be
  -- equal to wmti.primary_quantity
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS -- serialized job and serialized transaction
         (SELECT 'X'
            FROM wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.serialization_start_op IS NOT NULL
             AND wmti.fm_operation_seq_num >= wdj.serialization_start_op
             AND wmti.to_operation_seq_num >= wdj.serialization_start_op)
     AND wmti.primary_quantity <>
         (SELECT COUNT(*)
            FROM wip_serial_move_interface wsmi,
                 mtl_serial_numbers msn
           WHERE wsmi.transaction_id = wmti.transaction_id
             AND wsmi.assembly_serial_number = msn.serial_number
             AND wmti.organization_id = msn.current_organization_id
             AND wmti.primary_item_id = msn.inventory_item_id
             AND msn.wip_entity_id IS NOT NULL
             AND msn.wip_entity_id = wmti.wip_entity_id)
     AND wmti.primary_quantity <>
         (SELECT COUNT(*)
            FROM wip_serial_move_interface wsmi,
                 wip_entities we,
                 mtl_serial_numbers msn,
                 mtl_object_genealogy mog
           WHERE wsmi.transaction_id = wmti.transaction_id
             AND wsmi.assembly_serial_number = msn.serial_number
             AND wmti.organization_id = msn.current_organization_id
             AND wmti.primary_item_id = msn.inventory_item_id
             AND msn.current_status = WIP_CONSTANTS.IN_STORES
             AND wmti.wip_entity_id = we.wip_entity_id
             AND ((mog.genealogy_origin = 1 AND
                   mog.parent_object_id = we.gen_object_id AND
                   mog.object_id = msn.gen_object_id)
                   OR
                  (mog.genealogy_origin = 2 AND
                   mog.parent_object_id = msn.gen_object_id  AND
                   mog.object_id = we.gen_object_id))
             AND mog.end_date_active IS NULL)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_SERIAL_QTY_MISSMATCH');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WSMI.ASSEMBLY_SERIAL_NUMBER',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- if user try to do serialized transaction, the status of the serial
  -- must correspond to the transaction type.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS -- serialized job and serialized transaction
         (SELECT 'X'
            FROM wip_discrete_jobs wdj
           WHERE wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.serialization_start_op IS NOT NULL
             AND wmti.fm_operation_seq_num >= wdj.serialization_start_op
             AND wmti.to_operation_seq_num >= wdj.serialization_start_op)
     AND NOT EXISTS
         (SELECT 'X'
            FROM wip_serial_move_interface wsmi,
                 mtl_serial_numbers msn
           WHERE wsmi.transaction_id = wmti.transaction_id
             AND wsmi.assembly_serial_number = msn.serial_number
             AND wmti.organization_id = msn.current_organization_id
             AND wmti.primary_item_id = msn.inventory_item_id
             AND msn.line_mark_id IS NULL
             AND ((wmti.transaction_type = WIP_CONSTANTS.RET_TXN AND
                   msn.group_mark_id IS NULL AND
                   msn.wip_entity_id IS NULL AND
                   msn.current_status = WIP_CONSTANTS.IN_STORES)
                   OR
                  (wmti.transaction_type IN (WIP_CONSTANTS.MOVE_TXN,
                                             WIP_CONSTANTS.COMP_TXN) AND
                   msn.group_mark_id IS NOT NULL AND
                   msn.wip_entity_id IS NOT NULL AND
                   wmti.wip_entity_id = msn.wip_entity_id AND
                   -- Define but not use or Issue out of store.
                   msn.current_status IN (WIP_CONSTANTS.DEF_NOT_USED,
                                          WIP_CONSTANTS.OUT_OF_STORES))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_INVALID_SERIAL_STATUS');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'WSMI.ASSEMBLY_SERIAL_NUMBER',
            p_err_msg  => fnd_message.get);

END serial_validation;

-- If there are some errors occur, this routine will set
-- PROCESS_STATUS to WIP_CONSTANTS.ERROR. Then it will insert all the errors
-- into WIP_TXN_INTERFACE_ERRORS
PROCEDURE update_interface_tbl IS
BEGIN
  -- there are some errors occur, so set the process_status to error so that
  -- move processor will not pick up this record
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS
         (SELECT 'X'
            FROM wip_txn_interface_errors wtie
           WHERE wtie.transaction_id = wmti.transaction_id);

  -- insert error message to WIP_TXN_INTERFACE_ERRORS, and clear error table
  load_errors;
END update_interface_tbl;

/* Fixed bug 5056289. Added more validation for assembly to prevent the whole
   batch error out when assembly fail inventory validation.
 */
-- Validate assembly related information to prevent the whole batch failing
-- if there is something wrong with the assembly like assembly is not
-- transactable, or assembly is not an inventory item. This check is only for
-- EZ Completion and EZ Return.
PROCEDURE assembly_validation IS
BEGIN
  -- reset enums table
  enums.delete;
  -- Users cannot do EZ Completion/EZ Return if an assembly is not transactable
  -- or an assembly is not an inventory item.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type IN (WIP_CONSTANTS.RET_TXN,
                                   WIP_CONSTANTS.COMP_TXN)
     AND EXISTS -- Item flag was not set properly.
         (SELECT 'X'
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = wmti.primary_item_id
             AND msi.organization_id = wmti.organization_id
             AND (msi.inventory_item_flag = 'N' OR
                  msi.mtl_transactions_enabled_flag = 'N'))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('INV', 'INV_INT_ITMEXP');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'PRIMARY_ITEM_ID',
            p_err_msg  => fnd_message.get);

END assembly_validation;


-- If pass all the validation, and there is no error, this routine will
-- derive all the rest info (fm_operation_code, fm_department_id,
-- fm_department_code, to_operation_code, to_department_id, to_department_code)
-- , then update PROCESS_PHASE to WIP_CONSTANTS.MOVE_PROC. This routine
-- should be called after we called all the validation code and
--  update_interface_tbl
PROCEDURE derive IS
l_PrevOpSeq NUMBER;
l_NextOpSeq NUMBER;
l_OpExists  BOOLEAN;
BEGIN

  UPDATE wip_move_txn_interface wmti
     SET (wmti.fm_operation_code,
          wmti.fm_department_id,
          wmti.fm_department_code,
          wmti.to_operation_code,
          wmti.to_department_id,
          wmti.to_department_code,
          wmti.process_phase) =
         (SELECT bso1.operation_code,
                 wo1.department_id,
                 bd1.department_code,
                 bso2.operation_code,
                 wo2.department_id,
                 bd2.department_code,
                 WIP_CONSTANTS.MOVE_PROC
            FROM bom_standard_operations bso1,
                 bom_standard_operations bso2,
                 bom_departments bd1,
                 bom_departments bd2,
                 wip_operations wo1,
                 wip_operations wo2
           WHERE wo1.organization_id = wmti.organization_id
             AND wo1.wip_entity_id = wmti.wip_entity_id
             AND wo1.operation_seq_num = wmti.fm_operation_seq_num
             AND wo2.organization_id = wmti.organization_id
             AND wo2.wip_entity_id = wmti.wip_entity_id
             AND wo2.operation_seq_num = wmti.to_operation_seq_num
  /* Standard operation ID is optional, so we should use outer join */
             AND bso1.standard_operation_id(+) = wo1.standard_operation_id
             AND bso2.standard_operation_id(+) = wo2.standard_operation_id
             AND wo1.department_id = bd1.department_id
             AND wo2.department_id = bd2.department_id
             AND (wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                       WIP_CONSTANTS.LOTBASED)
                 OR
                 (wmti.entity_type = WIP_CONSTANTS.REPETITIVE AND
                  wo1.repetitive_schedule_id = wmti.repetitive_schedule_id AND
                  wo2.repetitive_schedule_id = wmti.repetitive_schedule_id)))
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;

END derive;

PROCEDURE validate(p_group_id    IN  NUMBER,
                   p_initMsgList IN VARCHAR2) IS
l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR2(1);
l_logLevel     NUMBER ;

BEGIN
  l_logLevel     := fnd_log.g_current_runtime_level;
  IF(fnd_api.to_boolean(p_initMsgList)) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- write parameter value to log file
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;
    wip_logger.entryPoint(p_procName     => 'wip_move_validator.validate',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  -- reset global_variable everytime this routine is called
  g_group_id := p_group_id;
  enums.delete;
  -- Call last_updatd_by and created_by first even if it is a low priority
  -- validation because we want to insert last_updated_by and created_by
  -- into WIP_TXN_INTERFACE_ERRORS
  last_updated_by;
  created_by;
 /*****************************
  * Start critical validation *
  *****************************/
  -- If any of the procedure below error out, set WMTI.PROCESS_STATUS to
  -- Error and stop validation.
/* Bug#2956953 - commented call to organization_id procedure as the validation
   for organization_id/organization_code are called from wip move manager code
   - Changes done as part of the Wip Move Sequencing Project */
--  organization_id;
  wip_entity_id;
  transaction_type;
  transaction_date;
  fm_operation;
  fm_step;
  to_operation;
  to_step;
  transaction_qty;
  transaction_uom;
  ocpl_txn_qty;
 /*****************************
  * End critical validation *
  *****************************/

 /*********************************
  * Start low priority validation *
  *********************************/
  -- If any of the procedure below error out, continue validating other
  -- low priority validation because we support multiple error message
  -- for one record.
  transaction_id;
  primary_qty;
  primary_uom;
  ocpl_primary_qty;
  ocpl_txn_id;
  reason_id;
  scrap_account_id;

  -- need to call this routine before osp_validation because use
  -- created_by as a user_id to validate OSP
  osp_validation;
  serial_validation;
  /* Fixed bug 5056289. */
  -- Add more validation for assembly to prevent the whole batch failing if
  -- there is something wrong with the assembly. This check is only for
  -- EZ Completion and EZ Return.
  assembly_validation;
 /*******************************
  * End low priority validation *
  *******************************/
  -- set WMTI.PROCESS_STATUS to error if there is an error from any
  -- validation and insert error message into WIP_TXN_INTERFACE_ERRORS
  update_interface_tbl;
  -- derive the rest nessary info
  derive;
  -- write to the log file
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wip_move_validator.validate',
                         p_procReturnStatus => fnd_api.g_ret_sts_success,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  end if;
EXCEPTION
  WHEN others THEN
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_move_validator.validate',
                           p_procReturnStatus => fnd_api.g_ret_sts_unexp_error,
                           p_msg => 'Unexpected Errors: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    end if;

END validate;

PROCEDURE get_move_txn_type(p_move_id        IN NUMBER,
                            p_org_id         IN NUMBER DEFAULT NULL,
                            p_wip_entity_id  IN NUMBER DEFAULT NULL,
                            p_assm_item_id   IN NUMBER DEFAULT NULL,
                            p_txn_type       OUT NOCOPY VARCHAR2)
IS
BEGIN
  p_txn_type := move_txn_type(p_move_id       => p_move_id,
                              p_org_id        => p_org_id,
                              p_wip_entity_id => p_wip_entity_id,
                              p_assm_item_id  => p_assm_item_id);
END get_move_txn_type;


FUNCTION move_txn_type(p_move_id         IN NUMBER,
                       p_org_id         IN NUMBER DEFAULT NULL,
                       p_wip_entity_id  IN NUMBER DEFAULT NULL,
                       p_assm_item_id   IN NUMBER DEFAULT NULL) return VARCHAR2
IS
  p_txn_type VARCHAR2(80);
  l_org_id        NUMBER ;
  l_wip_entity_id NUMBER ;
  l_assm_item_id  NUMBER ;
BEGIN
  l_org_id        := p_org_id;
  l_wip_entity_id := p_wip_entity_id;
  l_assm_item_id  := p_assm_item_id;


  if (l_org_id is NULL or l_wip_entity_id is NULL) then
    select organization_id,
            wip_entity_id
       into l_org_id,
            l_wip_entity_id
       from wip_move_transactions
      where transaction_id = p_move_id;
  end if;

  if (l_assm_item_id is NULL) then
    select wdj.primary_item_id
      into l_assm_item_id
      from wip_discrete_jobs wdj
     where wdj.organization_id = l_org_id
       and wdj.wip_entity_id = l_wip_entity_id;
  end if;

  begin
    -- Should have at most one match
    select distinct lu.meaning
      into p_txn_type
      from mfg_lookups lu,
           mtl_material_transactions mmt
     where mmt.move_transaction_id = p_move_id
       and mmt.organization_id = l_org_id
       and mmt.transaction_source_id = l_wip_entity_id
       and mmt.inventory_item_id = l_assm_item_id
       and mmt.transaction_type_id in (wip_constants.CPLASSY_TYPE, wip_constants.RETASSY_TYPE)
       and lu.lookup_type = 'WIP_MOVE_TRANSACTION_TYPE'
       and lu.lookup_code = decode(mmt.transaction_type_id, wip_constants.CPLASSY_TYPE, wip_constants.comp_txn, wip_constants.RETASSY_TYPE, wip_constants.ret_txn);
  exception
    -- no inv txn involved; just a plain move txn
    when no_data_found then
       select meaning
         into p_txn_type
         from mfg_lookups
        where lookup_type = 'WIP_MOVE_TRANSACTION_TYPE'
          and lookup_code = wip_constants.move_txn;
    when others then
       p_txn_type := -1;
  end;

  return p_txn_type;
END move_txn_type;

PROCEDURE validateOATxn(p_group_id    IN  NUMBER) IS
l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR2(1);
l_logLevel     NUMBER ;

BEGIN
  l_logLevel     := fnd_log.g_current_runtime_level;

  -- write parameter value to log file
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;
    wip_logger.entryPoint(p_procName     => 'wip_move_validator.validateOATxn',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  -- reset global_variable everytime this routine is called
  g_group_id := p_group_id;
  enums.delete;

  -- Derive ACCT_PERIOD_ID from TRANSACTION_DATE
  UPDATE wip_move_txn_interface wmti
     SET wmti.acct_period_id =
         (SELECT oap.acct_period_id
            FROM org_acct_periods oap
           WHERE oap.organization_id = wmti.organization_id
             -- modified the statement below for timezone project in J
             AND TRUNC(inv_le_timezone_pub.get_le_day_for_inv_org(
                         wmti.transaction_date,  -- p_trxn_date
                         wmti.organization_id    -- p_inv_org_id
                         )) BETWEEN
                 oap.period_start_date AND oap.schedule_close_date)
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;

  -- reset enums table
  enums.delete;
  -- Error out if there is no open accout period for the TRANSACTION_DATE
  -- specified or there is no WIP_PERIOD_BALANCES
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.acct_period_id IS NULL
         OR
         NOT EXISTS
         (SELECT 'X'
            FROM wip_period_balances wpb
           WHERE wpb.acct_period_id = wmti.acct_period_id
             AND wpb.wip_entity_id = wmti.wip_entity_id
             AND wpb.organization_id = wmti.organization_id))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_NO_BALANCE');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TRANSACTION_DATE',
            p_err_msg  => fnd_message.get);

  -- Fixed bug 5310474
  -- reset enums table
  enums.delete;
  -- Error out if FM_OPERATION_SEQ_NUM/FM_INTRAOPERATION_STEP_TYPE has
  -- no move shop floor status attached
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND EXISTS
         (SELECT 'X'
            FROM wip_shop_floor_status_codes wsc,
                 wip_shop_floor_statuses ws
           WHERE wsc.organization_id = wmti.organization_id
             AND ws.organization_id = wmti.organization_id
             AND ws.wip_entity_id = wmti.wip_entity_id
             AND (wmti.line_id IS NULL OR ws.line_id = wmti.line_id)
             AND ws.operation_seq_num = wmti.fm_operation_seq_num
             AND ws.intraoperation_step_type = wmti.fm_intraoperation_step_type
             AND ws.shop_floor_status_code = wsc.shop_floor_status_code
             AND wsc.status_move_flag = WIP_CONSTANTS.NO
             AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE
             AND (wmti.source_code IS NULL OR
                  wmti.source_code <> 'RCV' OR
                  (wmti.source_code = 'RCV' AND
                   NOT EXISTS
                      (SELECT 'X'
                         FROM wip_parameters wp
                        WHERE wp.organization_id = wmti.organization_id
                          AND wp.osp_shop_floor_status =
                              wsc.shop_floor_status_code))))
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_STATUS_NO_TXN1');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'FM_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- reset enums table
  enums.delete;
  -- Error out if user try to easy complete job/schedule that has No Move shop
  -- floor status attached to Tomove of the last operation
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.transaction_type = WIP_CONSTANTS.COMP_TXN
     AND EXISTS
         (SELECT 'X'
            FROM wip_shop_floor_status_codes wsc,
                 wip_shop_floor_statuses ws
           WHERE wsc.organization_id = wmti.organization_id
             AND ws.organization_id = wmti.organization_id
             AND ws.wip_entity_id = wmti.wip_entity_id
             AND (wmti.line_id IS NULL OR ws.line_id = wmti.line_id)
             AND ws.operation_seq_num = wmti.to_operation_seq_num
             AND ws.intraoperation_step_type = WIP_CONSTANTS.TOMOVE
             AND ws.shop_floor_status_code = wsc.shop_floor_status_code
             AND wsc.status_move_flag = WIP_CONSTANTS.NO
             AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE)
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name('WIP', 'WIP_STATUS_NO_TXN2');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);
  -- End of fix for bug 5310474

  -- Validate whether there is no move shopfloor status in between or not.
  -- reset enums table
  enums.delete;
  -- Error out if wip_parameter do not allow move over no_move shop floor
  -- status, and there are no_move status in between
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wip_sf_status.count_no_move_statuses(
           wmti.organization_id,             -- p_org_id
           wmti.wip_entity_id,               -- p_wip_id
           wmti.line_id,                     -- p_line_id
           wmti.repetitive_schedule_id,      -- p_sched_id
           wmti.fm_operation_seq_num,        -- p_fm_op
           wmti.fm_intraoperation_step_type, -- p_fm_step
           wmti.to_operation_seq_num,        -- p_to_op
           wmti.to_intraoperation_step_type, -- p_to_step
           -- Fixed bug 2121222
           wmti.source_code) > 0             -- p_source_code
  RETURNING wmti.transaction_id BULK COLLECT INTO enums;

  fnd_message.set_name ('WIP', 'WIP_NO_MOVE_SF_STATUS_BETWEEN');
  add_error(p_txn_ids  => enums,
            p_err_col  => 'TO_INTRAOPERATION_STEP_TYPE',
            p_err_msg  => fnd_message.get);

  -- Do OSP related validation.
  osp_validation;

  -- Set WMTI.PROCESS_STATUS to error if there is an error from any
  -- validation and insert error message into WIP_TXN_INTERFACE_ERRORS
  update_interface_tbl;

  -- Set WMTI.PROCESS_PHASE to WIP_CONSTANTS.MOVE_PROC so that move processing
  -- code can process these records.
  UPDATE wip_move_txn_interface wmti
     SET process_phase = WIP_CONSTANTS.MOVE_PROC
   WHERE wmti.group_id = g_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_VAL
     AND wmti.process_status = WIP_CONSTANTS.RUNNING;

  -- write to the log file
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wip_move_validator.validateOATxn',
                         p_procReturnStatus => fnd_api.g_ret_sts_success,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  end if;
EXCEPTION
  WHEN others THEN
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_move_validator.validateOATxn',
                           p_procReturnStatus => fnd_api.g_ret_sts_unexp_error,
                           p_msg => 'Unexpected Errors: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    end if;

END validateOATxn;

END wip_move_validator;

/

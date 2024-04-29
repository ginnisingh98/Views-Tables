--------------------------------------------------------
--  DDL for Package Body WIP_BATCH_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BATCH_MOVE" AS
/* $Header: wipbmovb.pls 120.7.12010000.2 2008/09/09 22:48:02 ntangjee ship $*/

---------------
--private types
---------------
TYPE move_record_pvt IS RECORD(wip_entity_id               NUMBER,
                               wip_entity_name             VARCHAR2(240),
                               fm_operation_seq_num        NUMBER,
                               fm_operation_code           VARCHAR2(4),
                               fm_department_id            NUMBER,
                               fm_department_code          VARCHAR2(10),
                               fm_intraoperation_step_type NUMBER,
                               fm_intraoperation_step      VARCHAR2(80),
                               to_operation_seq_num        NUMBER,
                               to_operation_code           VARCHAR2(4),
                               to_department_id            NUMBER,
                               to_department_code          VARCHAR2(10),
                               to_intraoperation_step_type NUMBER,
                               to_intraoperation_step      VARCHAR2(80),
                               primary_item_id             NUMBER,
                               primary_item_name           VARCHAR2(40),
                           --  primary_item_category       VARCHAR2(30),
                               transaction_quantity        NUMBER,
                               transaction_uom             VARCHAR2(3),
                           --    reason_id                   NUMBER,
                           --    reason_name                 VARCHAR2(30),
                               transaction_type            NUMBER,
                               project_id                  NUMBER,
                               project_number              VARCHAR2(25),
                               task_id                     NUMBER,
                               task_number                 VARCHAR2(25),
                               bom_revision                VARCHAR2(3),
                               scrap_account_id            NUMBER);

TYPE move_table_pvt IS TABLE OF move_record_pvt INDEX BY binary_integer;

TYPE error_record_pvt IS RECORD(job_name    VARCHAR2(240),
                                op_seq_num  NUMBER,
                                error_text  VARCHAR2(1000));

TYPE error_table_pvt IS TABLE OF error_record_pvt INDEX BY binary_integer;

---------------------
-- globale variables
---------------------
error_lists      error_table_pvt;
queue_meaning    VARCHAR2(80);
run_meaning      VARCHAR2(80);
tomove_meaning   VARCHAR2(80);
reject_meaning   VARCHAR2(80);
scrap_meaning    VARCHAR2(80);
move_txn_meaning VARCHAR2(80);
---------------------
-- functions
---------------------
FUNCTION get_step_meaning(p_step_type NUMBER) RETURN VARCHAR2 IS

BEGIN
 IF(p_step_type = wip_constants.queue)THEN
   RETURN queue_meaning;
 ELSIF(p_step_type = wip_constants.run)THEN
   RETURN run_meaning;
 ELSIF(p_step_type = wip_constants.tomove)THEN
   RETURN tomove_meaning;
 ELSIF(p_step_type = wip_constants.reject)THEN
   RETURN reject_meaning;
 ELSIF(p_step_type = wip_constants.scrap)THEN
   RETURN scrap_meaning;
 END IF;
END get_step_meaning;

---------------------
-- procedures
---------------------

-- error handling procedure
PROCEDURE add_error(p_job_name   IN VARCHAR2,
                    p_op_seq_num IN NUMBER,
                    p_error_text IN VARCHAR2) IS

  error_record error_record_pvt;

BEGIN
  error_record.job_name   := p_job_name;
  error_record.op_seq_num := p_op_seq_num;
  error_record.error_text := p_error_text;
  error_lists(error_lists.count + 1) := error_record;
END add_error;

PROCEDURE derive_move(p_org_id              IN         NUMBER,
                      p_wip_entity_id       IN         NUMBER,
                      p_wip_entity_name     IN         VARCHAR2,
                      p_fm_op_seq           IN         NUMBER,
                      p_move_qty            IN         NUMBER,
                      p_default_step_type   IN         NUMBER,
                      p_fm_step_type        IN         NUMBER,
                      x_move_table_pvt   IN OUT NOCOPY wip_batch_move.move_table_pvt,
                      x_return_status       OUT NOCOPY VARCHAR2) IS

CURSOR c_move_info IS
  SELECT p_wip_entity_id wip_entity_id,
         p_wip_entity_name wip_entity_name,
         p_fm_op_seq fm_op_seq,
         bso1.operation_code fm_op_code,
         wo1.department_id fm_dept_id,
         bd1.department_code fm_dept_code,
         p_fm_step_type fm_step_type,
         wo2.operation_seq_num to_op_seq,
         bso2.operation_code to_op_code,
         wo2.department_id to_dept_id,
         bd2.department_code to_dept_code,
         p_default_step_type to_step_type,
         wdj.primary_item_id item_id,
         msik.concatenated_segments item_name,
         p_move_qty txn_qty,
         msik.primary_uom_code txn_uom,
         WIP_CONSTANTS.MOVE_TXN txn_type,
         wdj.project_id project_id,
         pjm_project.all_proj_idtonum(wdj.project_id) project_number,
         wdj.task_id task_id,
         pjm_project.all_task_idtonum(wdj.task_id) task_number,
         wdj.bom_revision bom_revision
    FROM wip_discrete_jobs wdj,
         wip_operations wo1,
         wip_operations wo2,
         mtl_system_items_kfv msik,
         bom_standard_operations bso1,
         bom_standard_operations bso2,
         bom_departments bd1,
         bom_departments bd2
   WHERE wo1.wip_entity_id = wdj.wip_entity_id
     AND wo1.organization_id = wdj.organization_id
     AND wo1.operation_seq_num = p_fm_op_seq
     AND wo1.standard_operation_id = bso1.standard_operation_id(+)
     AND wo1.department_id = bd1.department_id
     AND wo2.wip_entity_id = wdj.wip_entity_id
     AND wo2.organization_id = wdj.organization_id
     AND wo2.operation_seq_num =
         (SELECT min(wo3.operation_seq_num)
            FROM wip_operations wo3
           WHERE wo3.wip_entity_id = p_wip_entity_id
             AND wo3.organization_id = p_org_id
             AND ((wo1.next_operation_seq_num IS NOT NULL AND
                   wo3.operation_seq_num > wo1.operation_seq_num) OR
                  (wo1.next_operation_seq_num IS NULL AND
                   wo3.operation_seq_num >= wo1.operation_seq_num))
             AND wo3.count_point_type = WIP_CONSTANTS.YES_AUTO)
     AND wo2.standard_operation_id = bso2.standard_operation_id(+)
     AND wo2.department_id = bd2.department_id
     AND wdj.primary_item_id = msik.inventory_item_id
     AND wdj.organization_id = msik.organization_id
     AND wdj.wip_entity_id = p_wip_entity_id
     AND wdj.organization_id = p_org_id;

l_log_level     NUMBER := fnd_log.g_current_runtime_level;
l_error_msg     VARCHAR2(240);
l_process_phase VARCHAR2(3);
l_return_status VARCHAR(1);
l_move_info     c_move_info%ROWTYPE;
l_move_record   move_record_pvt;
l_params        wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_wip_entity_id';
    l_params(2).paramValue  :=  p_wip_entity_id;
    l_params(3).paramName   := 'p_wip_entity_name';
    l_params(3).paramValue  :=  p_wip_entity_name;
    l_params(4).paramName   := 'p_fm_op_seq';
    l_params(4).paramValue  :=  p_fm_op_seq;
    l_params(5).paramName   := 'p_move_qty';
    l_params(5).paramValue  :=  p_move_qty;
    l_params(6).paramName   := 'p_default_step_type';
    l_params(6).paramValue  :=  p_default_step_type;
    l_params(7).paramName   := 'p_fm_step_type';
    l_params(7).paramValue  :=  p_fm_step_type;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.derive_move',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;

  l_process_phase := '2';
  -- Derive move information
  FOR l_move_info IN c_move_info LOOP
    -- There will be only 1 record found in the cursor.
    l_move_record.wip_entity_id               := l_move_info.wip_entity_id;
    l_move_record.wip_entity_name             := l_move_info.wip_entity_name;
    l_move_record.fm_operation_seq_num        := l_move_info.fm_op_seq;
    l_move_record.fm_operation_code           := l_move_info.fm_op_code;
    l_move_record.fm_department_id            := l_move_info.fm_dept_id;
    l_move_record.fm_department_code          := l_move_info.fm_dept_code;
    l_move_record.fm_intraoperation_step_type := l_move_info.fm_step_type;
    l_move_record.fm_intraoperation_step      := get_step_meaning(l_move_info.fm_step_type);

    IF(p_default_step_type > p_fm_step_type) THEN
      -- If default step is greater than currect step, set to op to from op.
      l_move_record.to_operation_seq_num      := l_move_info.fm_op_seq;
    ELSE
      l_move_record.to_operation_seq_num      := l_move_info.to_op_seq;
    END IF;
    l_move_record.to_operation_code           := l_move_info.to_op_code;
    l_move_record.to_department_id            := l_move_info.to_dept_id;
    l_move_record.to_department_code          := l_move_info.to_dept_code;
    IF(l_move_info.fm_op_seq = l_move_info.to_op_seq AND
       p_default_step_type <= p_fm_step_type) THEN
      -- If it is the last operation and default step is less than or equal to
      -- current step, set to_step to 'To Move'
      l_move_record.to_intraoperation_step_type := WIP_CONSTANTS.TOMOVE;
    ELSE
      l_move_record.to_intraoperation_step_type := l_move_info.to_step_type;
    END IF;
    l_move_record.to_intraoperation_step      := get_step_meaning(l_move_info.to_step_type);
    l_move_record.primary_item_id             := l_move_info.item_id;
    l_move_record.primary_item_name           := l_move_info.item_name;
    l_move_record.transaction_quantity        := l_move_info.txn_qty;
    l_move_record.transaction_uom             := l_move_info.txn_uom;
    l_move_record.transaction_type            := l_move_info.txn_type;
    l_move_record.project_id                  := l_move_info.project_id;
    l_move_record.project_number              := l_move_info.project_number;
    l_move_record.task_id                     := l_move_info.task_id;
    l_move_record.task_number                 := l_move_info.task_number;
    l_move_record.bom_revision                := l_move_info.bom_revision;
    x_move_table_pvt(x_move_table_pvt.count + 1) := l_move_record;
  END LOOP;

  x_return_status := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_move',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF(c_move_info%ISOPEN) THEN
      CLOSE c_move_info;
    END IF;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.derive_move',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;

END derive_move;

PROCEDURE derive_scrap(p_org_id                IN         NUMBER,
                       p_wip_entity_id         IN         NUMBER,
                       p_wip_entity_name       IN         VARCHAR2,
                       p_fm_op_seq             IN         NUMBER,
                       p_scrap_qty             IN         NUMBER,
                       p_require_scrap_acct    IN         NUMBER,
                       p_default_scrap_acct_id IN         NUMBER,
                       p_default_step_type     IN         NUMBER,
                       p_fm_step_type          IN         NUMBER,
                       p_resp_key              IN         VARCHAR2,
                       x_move_table_pvt    IN OUT NOCOPY wip_batch_move.move_table_pvt,
                       x_return_status        OUT NOCOPY VARCHAR2) IS

CURSOR c_scrap_info IS
  SELECT p_wip_entity_id wip_entity_id,
         p_wip_entity_name wip_entity_name,
         p_fm_op_seq fm_op_seq,
         bso1.operation_code fm_op_code,
         wo1.department_id fm_dept_id,
         bd1.department_code fm_dept_code,
         p_fm_step_type fm_step_type,
         wo2.operation_seq_num to_op_seq,
         bso2.operation_code to_op_code,
         wo2.department_id to_dept_id,
         bd2.department_code to_dept_code,
         WIP_CONSTANTS.SCRAP to_step_type,
         wdj.primary_item_id item_id,
         msik.concatenated_segments item_name,
         p_scrap_qty txn_qty,
         msik.primary_uom_code txn_uom,
         WIP_CONSTANTS.MOVE_TXN txn_type,
         wdj.project_id project_id,
         pjm_project.all_proj_idtonum(wdj.project_id) project_number,
         wdj.task_id task_id,
         pjm_project.all_task_idtonum(wdj.task_id) task_number,
         wdj.bom_revision bom_revision,
         p_default_scrap_acct_id scrap_acct_id
    FROM wip_discrete_jobs wdj,
         wip_operations wo1,
         wip_operations wo2,
         mtl_system_items_kfv msik,
         bom_standard_operations bso1,
         bom_standard_operations bso2,
         bom_departments bd1,
         bom_departments bd2
   WHERE wo1.wip_entity_id = wdj.wip_entity_id
     AND wo1.organization_id = wdj.organization_id
     AND wo1.operation_seq_num = p_fm_op_seq
     AND wo1.standard_operation_id = bso1.standard_operation_id(+)
     AND wo1.department_id = bd1.department_id
     AND wo2.wip_entity_id = wdj.wip_entity_id
     AND wo2.organization_id = wdj.organization_id
     AND wo2.operation_seq_num =
         (SELECT min(wo3.operation_seq_num)
            FROM wip_operations wo3
           WHERE wo3.wip_entity_id = p_wip_entity_id
             AND wo3.organization_id = p_org_id
             AND ((wo1.next_operation_seq_num IS NOT NULL AND
                   wo3.operation_seq_num > wo1.operation_seq_num) OR
                  (wo1.next_operation_seq_num IS NULL AND
                   wo3.operation_seq_num >= wo1.operation_seq_num))
             AND wo3.count_point_type = WIP_CONSTANTS.YES_AUTO)
     AND wo2.standard_operation_id = bso2.standard_operation_id(+)
     AND wo2.department_id = bd2.department_id
     AND wdj.primary_item_id = msik.inventory_item_id
     AND wdj.organization_id = msik.organization_id
     AND wdj.wip_entity_id = p_wip_entity_id
     AND wdj.organization_id = p_org_id;

l_level_id              NUMBER;
l_log_level             NUMBER := fnd_log.g_current_runtime_level;
l_default_scrap_acct_id VARCHAR2(30);
l_error_msg             VARCHAR2(240);
l_process_phase         VARCHAR2(3);
l_return_status         VARCHAR2(1);
l_scrap_info            c_scrap_info%ROWTYPE;
l_scrap_record          move_record_pvt;
l_params                wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_wip_entity_id';
    l_params(2).paramValue  :=  p_wip_entity_id;
    l_params(3).paramName   := 'p_wip_entity_name';
    l_params(3).paramValue  :=  p_wip_entity_name;
    l_params(4).paramName   := 'p_fm_op_seq';
    l_params(4).paramValue  :=  p_fm_op_seq;
    l_params(5).paramName   := 'p_scrap_qty';
    l_params(5).paramValue  :=  p_scrap_qty;
    l_params(6).paramName   := 'p_require_scrap_acct';
    l_params(6).paramValue  :=  p_require_scrap_acct;
    l_params(7).paramName   := 'p_default_scrap_acct_id';
    l_params(7).paramValue  :=  p_default_scrap_acct_id;
    l_params(8).paramName   := 'p_default_step_type';
    l_params(8).paramValue  :=  p_default_step_type;
    l_params(9).paramName   := 'p_fm_step_type';
    l_params(9).paramValue  :=  p_fm_step_type;
    l_params(10).paramName  := 'p_resp_key';
    l_params(10).paramValue :=  p_resp_key;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.derive_scrap',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;

  l_process_phase := '2';
  -- Derive move information
  FOR l_scrap_info IN c_scrap_info LOOP
    -- There will be only 1 record found in the cursor.
    l_scrap_record.wip_entity_id               := l_scrap_info.wip_entity_id;
    l_scrap_record.wip_entity_name             := l_scrap_info.wip_entity_name;
    l_scrap_record.fm_operation_seq_num        := l_scrap_info.fm_op_seq;
    l_scrap_record.fm_operation_code           := l_scrap_info.fm_op_code;
    l_scrap_record.fm_department_id            := l_scrap_info.fm_dept_id;
    l_scrap_record.fm_department_code          := l_scrap_info.fm_dept_code;
    l_scrap_record.fm_intraoperation_step_type := l_scrap_info.fm_step_type;
    l_scrap_record.fm_intraoperation_step      := get_step_meaning(l_scrap_info.fm_step_type);
    IF(p_fm_step_type = WIP_CONSTANTS.TOMOVE AND
       p_default_step_type = WIP_CONSTANTS.TOMOVE) THEN
      -- If user move from 10TM to 20TM, we will scrap at operation 20.
      l_scrap_record.to_operation_seq_num := l_scrap_info.to_op_seq;
      l_scrap_record.to_operation_code    := l_scrap_info.to_op_code;
      l_scrap_record.to_department_id     := l_scrap_info.to_dept_id;
      l_scrap_record.to_department_code   := l_scrap_info.to_dept_code;
      IF(p_require_scrap_acct = WIP_CONSTANTS.YES) THEN
        l_process_phase := '3';
        l_level_id := wip_ws_util.get_preference_level_id(
                        p_pref_id  => 10, -- Default Scrap Account
                        p_resp_key => p_resp_key,
                        p_org_id   => p_org_id,
                        p_dept_id  => l_scrap_info.to_dept_id);
        l_process_phase := '4';
        l_default_scrap_acct_id := wip_ws_util.get_preference_value_code(
                                     p_pref_id  => 10, -- Default Scrap Account
                                     p_level_id => l_level_id);
        l_process_phase := '5';
        IF(l_default_scrap_acct_id IS NULL) THEN
          fnd_message.set_name('WIP','WIP_NO_SCRAP_ACCT_NO_BATCH');
          fnd_msg_pub.add;
          l_error_msg := 'No default scrap accout defined.';
          raise fnd_api.g_exc_unexpected_error;
        ELSE
          l_scrap_record.scrap_account_id := to_number(l_default_scrap_acct_id);
        END IF;-- default scrap is null
      END IF;
    ELSE
      -- Most of the time we can scrap at from operation.
      l_scrap_record.to_operation_seq_num := l_scrap_info.fm_op_seq;
      l_scrap_record.to_operation_code    := l_scrap_info.fm_op_code;
      l_scrap_record.to_department_id     := l_scrap_info.fm_dept_id;
      l_scrap_record.to_department_code   := l_scrap_info.fm_dept_code;
      IF(p_require_scrap_acct = WIP_CONSTANTS.YES) THEN
        l_scrap_record.scrap_account_id := l_scrap_info.scrap_acct_id;
      END IF;
    END IF;
    l_scrap_record.to_intraoperation_step_type := l_scrap_info.to_step_type;
    l_scrap_record.to_intraoperation_step      := get_step_meaning(l_scrap_info.to_step_type);
    l_scrap_record.primary_item_id             := l_scrap_info.item_id;
    l_scrap_record.primary_item_name           := l_scrap_info.item_name;
    l_scrap_record.transaction_quantity        := l_scrap_info.txn_qty;
    l_scrap_record.transaction_uom             := l_scrap_info.txn_uom;
    l_scrap_record.transaction_type            := l_scrap_info.txn_type;
    l_scrap_record.project_id                  := l_scrap_info.project_id;
    l_scrap_record.project_number              := l_scrap_info.project_number;
    l_scrap_record.task_id                     := l_scrap_info.task_id;
    l_scrap_record.task_number                 := l_scrap_info.task_number;
    l_scrap_record.bom_revision                := l_scrap_info.bom_revision;
    x_move_table_pvt(x_move_table_pvt.count + 1) := l_scrap_record;
  END LOOP;

  x_return_status := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_scrap',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF(c_scrap_info%ISOPEN) THEN
      CLOSE c_scrap_info;
    END IF;
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.derive_scrap',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF(c_scrap_info%ISOPEN) THEN
      CLOSE c_scrap_info;
    END IF;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.derive_scrap',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;

END derive_scrap;

PROCEDURE derive_row(p_org_id                IN         NUMBER,
                     p_wip_entity_id         IN         NUMBER,
                     p_wip_entity_name       IN         VARCHAR2,
                     p_fm_op_seq             IN         NUMBER,
                     p_move_qty              IN         NUMBER,
                     p_scrap_qty             IN         NUMBER,
                     p_require_scrap_acct    IN         NUMBER,
                     p_default_scrap_acct_id IN         NUMBER,
                     p_default_step_type     IN         NUMBER,
                     p_fm_step_type          IN         NUMBER,
                     p_resp_key              IN         VARCHAR2,
                     x_move_table_pvt        OUT NOCOPY wip_batch_move.move_table_pvt,
                     x_return_status         OUT NOCOPY VARCHAR2) IS

l_log_level     NUMBER := fnd_log.g_current_runtime_level;
l_error_msg     VARCHAR2(240);
l_process_phase VARCHAR2(3);
l_return_status VARCHAR2(1);
l_params        wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_wip_entity_id';
    l_params(2).paramValue  :=  p_wip_entity_id;
    l_params(3).paramName   := 'p_wip_entity_name';
    l_params(3).paramValue  :=  p_wip_entity_name;
    l_params(4).paramName   := 'p_fm_op_seq';
    l_params(4).paramValue  :=  p_fm_op_seq;
    l_params(5).paramName   := 'p_move_qty';
    l_params(5).paramValue  :=  p_move_qty;
    l_params(6).paramName   := 'p_scrap_qty';
    l_params(6).paramValue  :=  p_scrap_qty;
    l_params(7).paramName   := 'p_require_scrap_acct';
    l_params(7).paramValue  :=  p_require_scrap_acct;
    l_params(8).paramName   := 'p_default_scrap_acct_id';
    l_params(8).paramValue  :=  p_default_scrap_acct_id;
    l_params(9).paramName   := 'p_default_step_type';
    l_params(9).paramValue  :=  p_default_step_type;
    l_params(10).paramName  := 'p_fm_step_type';
    l_params(10).paramValue :=  p_fm_step_type;
    l_params(11).paramName  := 'p_resp_key';
    l_params(11).paramValue :=  p_resp_key;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.derive_row',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';
  IF(p_move_qty > 0) THEN
    -- Derive move transaction information.
    derive_move(p_org_id            => p_org_id,
                p_wip_entity_id     => p_wip_entity_id,
                p_wip_entity_name   => p_wip_entity_name,
                p_fm_op_seq         => p_fm_op_seq,
                p_move_qty          => p_move_qty,
                p_default_step_type => p_default_step_type,
                p_fm_step_type      => p_fm_step_type,
                x_move_table_pvt    => x_move_table_pvt,
                x_return_status     => x_return_status);

    IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_error_msg := 'wip_batch_move.derive_move failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;
  l_process_phase := '3';
  IF(p_scrap_qty > 0) THEN
    -- Derive move transaction information.
    derive_scrap(p_org_id                => p_org_id,
                 p_wip_entity_id         => p_wip_entity_id,
                 p_wip_entity_name       => p_wip_entity_name,
                 p_fm_op_seq             => p_fm_op_seq,
                 p_scrap_qty             => p_scrap_qty,
                 p_require_scrap_acct    => p_require_scrap_acct,
                 p_default_scrap_acct_id => p_default_scrap_acct_id,
                 p_default_step_type     => p_default_step_type,
                 p_fm_step_type          => p_fm_step_type,
                 p_resp_key              => p_resp_key,
                 x_move_table_pvt        => x_move_table_pvt,
                 x_return_status         => x_return_status);

    IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_error_msg := 'wip_batch_move.derive_scrap failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;
  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_row',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_row',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_error_msg,
                           x_returnStatus => l_return_status);
    END IF;

  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_row',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_error_msg,
                           x_returnStatus => l_return_status);
    END IF;
END derive_row;

PROCEDURE get_preferences(p_resp_key              IN         VARCHAR2,
                          p_org_id                IN         NUMBER,
                          p_dept_id               IN         NUMBER,
                          x_default_step_type     OUT NOCOPY NUMBER,
                          x_default_scrap_acct_id OUT NOCOPY NUMBER,
                          x_return_status         OUT NOCOPY VARCHAR2) IS

l_level_id              NUMBER;
l_log_level             NUMBER := fnd_log.g_current_runtime_level;
l_default_scrap_acct_id VARCHAR2(30);
l_default_step_type     VARCHAR2(1);
l_error_msg             VARCHAR2(240);
l_process_phase         VARCHAR2(3);
l_return_status         VARCHAR2(1);
l_params                wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_resp_key';
    l_params(1).paramValue  :=  p_resp_key;
    l_params(2).paramName   := 'p_org_id';
    l_params(2).paramValue  :=  p_org_id;
    l_params(3).paramName   := 'p_dept_id';
    l_params(3).paramValue  :=  p_dept_id;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.get_preferences',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';
  l_level_id := wip_ws_util.get_preference_level_id(
                  p_pref_id  => 9, -- Default Intra Op Step
                  p_resp_key => p_resp_key,
                  p_org_id   => p_org_id,
                  p_dept_id  => p_dept_id);
  l_process_phase := '3';
  l_default_step_type := wip_ws_util.get_preference_value_code(
                           p_pref_id  => 9, -- Default Intra Op Step
                           p_level_id => l_level_id);
  l_process_phase := '4';
  x_default_step_type := to_number(l_default_step_type);
  l_process_phase := '5';
  l_level_id := wip_ws_util.get_preference_level_id(
                  p_pref_id  => 10, -- Default Scrap Account
                  p_resp_key => p_resp_key,
                  p_org_id   => p_org_id,
                  p_dept_id  => p_dept_id);
  l_process_phase := '6';
  l_default_scrap_acct_id := wip_ws_util.get_preference_value_code(
                               p_pref_id  => 10, -- Default Scrap Account
                               p_level_id => l_level_id);
  l_process_phase := '7';
  x_default_scrap_acct_id := to_number(l_default_scrap_acct_id);

  x_return_status := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.get_preferences',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.get_preferences',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;

END get_preferences;

PROCEDURE initialize_lookups IS

CURSOR c_step_meaning IS
  SELECT lookup_code step,
         meaning
    FROM mfg_lookups
   WHERE lookup_type='WIP_INTRAOPERATION_STEP';

l_step_meaning c_step_meaning%ROWTYPE;

BEGIN
  -- Put step lookup meaning in to global variables
  FOR l_step_meaning IN c_step_meaning LOOP
    IF(l_step_meaning.step = wip_constants.queue)THEN
      queue_meaning := l_step_meaning.meaning;
    ELSIF(l_step_meaning.step = wip_constants.run)THEN
      run_meaning := l_step_meaning.meaning;
    ELSIF(l_step_meaning.step = wip_constants.tomove)THEN
      tomove_meaning := l_step_meaning.meaning;
    ELSIF(l_step_meaning.step = wip_constants.reject)THEN
      reject_meaning := l_step_meaning.meaning;
    ELSIF(l_step_meaning.step = wip_constants.scrap)THEN
      scrap_meaning := l_step_meaning.meaning;
    END IF;
  END LOOP;
  -- Get meaning of move transaction type
  SELECT meaning
    INTO move_txn_meaning
    FROM mfg_lookups
   WHERE lookup_type = 'WIP_MOVE_TRANSACTION_TYPE'
     AND lookup_code = wip_constants.move_txn;
EXCEPTION
  WHEN others THEN
    IF(c_step_meaning%ISOPEN) THEN
      CLOSE c_step_meaning;
    END IF;
END initialize_lookups;

PROCEDURE insert_move_records(p_org_id         IN         NUMBER,
                              p_employee_id    IN         NUMBER,
                              p_move_table_pvt IN         wip_batch_move.move_table_pvt,
                              p_assy_serial    IN         VARCHAR2,
                              x_group_id       OUT NOCOPY NUMBER,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

l_log_level     NUMBER := fnd_log.g_current_runtime_level;
l_total_row     NUMBER;
l_error_msg     VARCHAR2(240);
l_process_phase VARCHAR2(3);
l_return_status VARCHAR2(1);
l_params        wip_logger.param_tbl_t;
l_txn_id        NUMBER;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_employee_id';
    l_params(2).paramValue  :=  p_employee_id;
    l_params(3).paramName   := 'p_assy_serial';
    l_params(3).paramValue  :=  p_assy_serial;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.insert_move_records',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';

  SELECT wip_transactions_s.nextval
    INTO x_group_id
    FROM dual;

  l_total_row := p_move_table_pvt.count;
  FOR i IN 1..l_total_row LOOP
    INSERT INTO wip_move_txn_interface(
      group_id,
      transaction_id,
      last_update_date,
      last_updated_by,
      last_updated_by_name,
      creation_date,
      created_by,
      created_by_name,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      kanban_card_id,
      source_code,
      source_line_id,
      process_phase,
      process_status,
      transaction_type,
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
      qa_collection_id,
      overcompletion_transaction_qty,
      overcompletion_primary_qty,
      overcompletion_transaction_id,
      employee_id)
    VALUES(
      x_group_id,    -- group_id
      wip_transactions_s.nextval,    -- transaction_id
      SYSDATE,    -- last_update_date
      fnd_global.user_id,    -- last_updated_by
      NULL,    -- last_updated_by_name
      SYSDATE,    -- creation_date
      fnd_global.user_id,    -- created_by
      NULL,    -- created_by_name
      fnd_global.conc_login_id,    -- last_update_login
      NULL,    -- request_id
      NULL,    -- program_application_id
      NULL,    -- program_id
      NULL,    -- program_update_date
      NULL,    -- kanban_card_id
      NULL,    -- source_code
      NULL,    -- source_line_id
      WIP_CONSTANTS.MOVE_VAL,    -- process_phase
      WIP_CONSTANTS.RUNNING,    -- process_status
      WIP_CONSTANTS.MOVE_TXN,    -- transaction_type
      p_org_id,    -- organization_id
      NULL,    -- organization_code
      p_move_table_pvt(i).wip_entity_id,
      p_move_table_pvt(i).wip_entity_name,
      WIP_CONSTANTS.DISCRETE,    -- entity_type
      p_move_table_pvt(i).primary_item_id,
      NULL,    -- line_id
      NULL,    -- line_code
      NULL,    -- repetitive_schedule_id
      SYSDATE,    -- transaction_date
      NULL,    -- acct_period_id
      p_move_table_pvt(i).fm_operation_seq_num,
      p_move_table_pvt(i).fm_operation_code,
      p_move_table_pvt(i).fm_department_id,
      p_move_table_pvt(i).fm_department_code,
      p_move_table_pvt(i).fm_intraoperation_step_type,
      p_move_table_pvt(i).to_operation_seq_num,
      p_move_table_pvt(i).to_operation_code,
      p_move_table_pvt(i).to_department_id,
      p_move_table_pvt(i).to_department_code,
      p_move_table_pvt(i).to_intraoperation_step_type,
      p_move_table_pvt(i).transaction_quantity,
      p_move_table_pvt(i).transaction_uom,
      NULL,    -- primary_quantity
      NULL,    -- primaty_uom
      p_move_table_pvt(i).scrap_account_id,
      NULL,    -- reason_id
      NULL,    -- reason_name
      NULL,    -- reference
      NULL,    -- qa_collection_id
      NULL,    -- overcompletion_transaction_qty
      NULL,    -- overcompletion_primary_qty
      NULL,    -- overcompletion_transaction_id
      p_employee_id)
    RETURNING transaction_id INTO l_txn_id;
  END LOOP;

  l_process_phase := '3';

  l_process_phase := '4';
  IF(p_assy_serial IS NOT NULL) THEN
    -- If serialized express move from search serial, quantity is always 1.
    -- Need to insert record into WIP_SERIAL_MOVE_INTERFACE
    IF(wma_move.insertSerial(groupID       => x_group_id,
                             transactionID => l_txn_id,
                             serialNumber  => p_assy_serial,
                             errMessage    => l_error_msg) = FALSE) THEN
      -- insert statement error out
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  ELSE
    -- If serialized express move from dispatch list or search job, quantity
    -- can be more than one. Need to insert serial records into wsmi.
    INSERT INTO wip_serial_move_interface
         (transaction_id,
          assembly_serial_number,
          creation_date,
          created_by,
          created_by_name,
          last_update_date,
          last_updated_by,
          last_updated_by_name,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date
         )
    SELECT wmti.transaction_id,
           msn.serial_number,
           wmti.creation_date,
           wmti.created_by,
           wmti.created_by_name,
           wmti.last_update_date,
           wmti.last_updated_by,
           wmti.last_updated_by_name,
           wmti.last_update_login,
           wmti.request_id,
           wmti.program_application_id,
           wmti.program_id,
           wmti.program_update_date
      FROM wip_move_txn_interface wmti,
           mtl_serial_numbers msn,
           wip_discrete_jobs wdj
     WHERE wmti.transaction_id = l_txn_id
       AND wmti.group_id = x_group_id
       AND wmti.organization_id = wdj.organization_id
       AND wmti.wip_entity_id = wdj.wip_entity_id
       AND wmti.fm_operation_seq_num >= wdj.serialization_start_op
       AND msn.wip_entity_id = wmti.wip_entity_id
       AND (msn.operation_seq_num IS NULL OR
            msn.operation_seq_num = wmti.fm_operation_seq_num)
       AND (msn.intraoperation_step_type IS NULL OR
            msn.intraoperation_step_type=
            wmti.fm_intraoperation_step_type)
       AND rownum <= wmti.transaction_quantity
  ORDER BY msn.serial_number;

  END IF;

  x_return_status := fnd_api.g_ret_sts_success;
  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.insert_move_records',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.insert_move_records',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_error_msg,
                           x_returnStatus => l_return_status);
    END IF;
END insert_move_records;

Procedure load_errors IS

  total_errors NUMBER;
  error_no     NUMBER := 1;

BEGIN

  total_errors := error_lists.count;
  WHILE (error_no <= total_errors) LOOP
    fnd_message.set_name('WIP', 'WIP_BATCH_MOVE_ERROR');
    fnd_message.set_token('JOB', error_lists(error_no).job_name);
    fnd_message.set_token('OPERATION', error_lists(error_no).op_seq_num);
    fnd_message.set_token('ERROR',error_lists(error_no).error_text);
    fnd_msg_pub.add;
    error_no := error_no + 1;
  END LOOP;

  -- cleare error table
  error_lists.delete ;

END load_errors;

PROCEDURE process_move_records(p_group_id      IN         NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_errors IS
  SELECT wtie.error_column,
         wtie.error_message
    FROM wip_txn_interface_errors wtie,
         wip_move_txn_interface wmti
   WHERE wtie.transaction_id = wmti.transaction_id
     AND wmti.group_id = p_group_id;

CURSOR c_move_intf_records IS
  SELECT wmti.wip_entity_id wip_id,
         wmti.fm_operation_seq_num fm_op,
         wmti.to_operation_seq_num to_op
    FROM wip_move_txn_interface wmti
   WHERE wmti.group_id = p_group_id
ORDER BY wmti.transaction_id;

l_log_level         NUMBER := fnd_log.g_current_runtime_level;
l_error_msg         VARCHAR2(1000);
l_error_text        VARCHAR2(2000);
l_process_phase     VARCHAR2(3);
l_return_status     VARCHAR2(1);
l_errors            c_errors%ROWTYPE;
l_move_intf_records c_move_intf_records%ROWTYPE;
l_params            wip_logger.param_tbl_t;

BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.process_move_records',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';

  OPEN c_move_intf_records;
  FETCH c_move_intf_records INTO l_move_intf_records;
  CLOSE c_move_intf_records;
  l_process_phase := '3';

  wip_movProc_priv.processIntf(p_group_id      => p_group_id,
                               p_child_txn_id  => -1,
                               p_mtl_header_id => -1,
                               p_proc_phase    => WIP_CONSTANTS.MOVE_VAL,
                               p_time_out      => 0,
                               p_move_mode     => WIP_CONSTANTS.BACKGROUND,
                               p_bf_mode       => WIP_CONSTANTS.ONLINE,
                               p_mtl_mode      => WIP_CONSTANTS.ONLINE,
                               p_endDebug      => fnd_api.g_false,
                               p_initMsgList   => fnd_api.g_true,
                               p_insertAssy    => fnd_api.g_true,
                               p_do_backflush  => fnd_api.g_true,
                               x_returnStatus  => x_return_status);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    l_process_phase := '4';
    l_error_msg := 'wip_movProc_priv.processIntf failed';
    raise fnd_api.g_exc_unexpected_error;
  ELSE
    l_process_phase := '5';
    -- If move success, call time entry API to clock off operator if there
    -- is no quantity left at the operation.
    wip_ws_time_entry.process_time_records_move(
      p_wip_entity_id => l_move_intf_records.wip_id,
      p_from_op       => l_move_intf_records.fm_op,
      p_to_op         => l_move_intf_records.to_op);
    l_process_phase := '6';
  END IF;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.process_move_records',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF(c_errors%ISOPEN) THEN
      CLOSE c_errors;
    END IF;
    IF(c_move_intf_records%ISOPEN) THEN
      CLOSE c_move_intf_records;
    END IF;
    FOR l_errors IN c_errors LOOP
      l_error_text := l_error_text || l_errors.error_column ||':' ||
                     l_errors.error_message || '; ';
    END LOOP;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.process_move_records',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'wip_movProc_grp.processInterface failed',
                           x_returnStatus => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_text);
    fnd_msg_pub.add;
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF(c_errors%ISOPEN) THEN
      CLOSE c_errors;
    END IF;
    IF(c_move_intf_records%ISOPEN) THEN
      CLOSE c_move_intf_records;
    END IF;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.process_move_records',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_error_msg,
                           x_returnStatus => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;
END process_move_records;

PROCEDURE quality_require(p_org_id          IN         NUMBER,
                          p_move_tbl        IN         wip_batch_move.move_table_pvt,
                          x_quality_require OUT NOCOPY VARCHAR2,
                          x_plan_names      OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2)IS

l_log_level          NUMBER := fnd_log.g_current_runtime_level;
l_total_row          NUMBER;
l_commit_allow       VARCHAR2(1);
l_context_values     VARCHAR2(10000);
l_error_msg          VARCHAR2(240);
l_plan_txn_ids       VARCHAR2(10000);
l_plan_ids           VARCHAR2(10000);
l_quality_plan_exist VARCHAR2(1);
l_return_status      VARCHAR2(1);
l_params             wip_logger.param_tbl_t;
BEGIN
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.quality_require',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  x_quality_require := fnd_api.g_false;
  l_total_row := p_move_tbl.count;

  FOR i IN 1..l_total_row LOOP
    -- Build l_context_values to pass to quality API.
    l_context_values :=
      qa_ss_const.department||'='||p_move_tbl(i).fm_department_code||'@'||
      qa_ss_const.quantity||'='||p_move_tbl(i).transaction_quantity||'@'||
      qa_ss_const.item||'='||p_move_tbl(i).primary_item_name||'@'||
      -- Pass empty string to item category as Bryan suggested.
      qa_ss_const.item_category||'=@'||
      qa_ss_const.uom||'='||p_move_tbl(i).transaction_uom||'@'||
      qa_ss_const.reason_code||'=@'||
      qa_ss_const.job_name||'='||p_move_tbl(i).wip_entity_name||'@'||
      qa_ss_const.production_line||'=@'||
      qa_ss_const.to_op_seq_num||'='||p_move_tbl(i).to_operation_seq_num||'@'||
      qa_ss_const.from_op_seq_num||'='||p_move_tbl(i).fm_operation_seq_num||'@'||
      qa_ss_const.to_intraoperation_step||'='||p_move_tbl(i).to_intraoperation_step||'@'||
      qa_ss_const.from_intraoperation_step||'='||p_move_tbl(i).fm_intraoperation_step||'@'||
      qa_ss_const.sales_order||'=@'||
      qa_ss_const.operation_code||'='||p_move_tbl(i).fm_operation_code||'@'||
      qa_ss_const.transaction_type||'='||move_txn_meaning||'=@'||
      qa_ss_const.to_department||'='||p_move_tbl(i).to_department_code||'@'||
      qa_ss_const.to_operation_code||'='||p_move_tbl(i).to_operation_code||'@'||
      qa_ss_const.project_number||'='||p_move_tbl(i).project_number||'@'||
      qa_ss_const.task_number||'='||p_move_tbl(i).task_number||'@'||
      qa_ss_const.bom_revision||'='||p_move_tbl(i).bom_revision;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.log(p_msg          => 'l_context_values='||l_context_values,
                     x_returnStatus => l_return_status);
    END IF;

    BEGIN
      -- Check whether qualtiy collection plan exist or not
      l_quality_plan_exist := qa_txn_grp.evaluate_triggers(
                                p_txn_number     => qa_ss_const.wip_move_txn,
                                p_org_id         => p_org_id,
                                p_context_values => l_context_values,
                                x_plan_txn_ids   => l_plan_txn_ids);
      IF(l_quality_plan_exist = fnd_api.g_false)THEN
        -- If no collection plan exist, there is no need to call
        -- qa_txn_grp.commit_allowed().
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      -- If quality collection plan exist, we have to check whether it is
      -- mandatory or not.
      -- Fixed bug 5335024.Call is_commit_allowed() instead of commit_allowed()
      -- because is_commit_allowed will also check child quality plan.
      -- Moreover, is_commit_allowed will also return quality plan name.
      l_commit_allow := qa_txn_grp.is_commit_allowed(
                          p_txn_number    => qa_ss_const.wip_move_txn,
                          p_org_id        => p_org_id,
                          p_plan_txn_ids  => l_plan_txn_ids,
                          --Pass 0 as Bryan suggested.
                          p_collection_id => 0,
                          x_plan_names    => x_plan_names);

      IF(l_commit_allow = fnd_api.g_false)THEN
        -- If quality plan is mandatory, no need to do more check.
        x_quality_require := fnd_api.g_true;
        GOTO end_quality_check;
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
        -- This is not a real error, so we do not have to do anything.
        NULL;
      WHEN others THEN
        l_error_msg := ' unexpected error: ' || SQLERRM || 'SQLCODE = ' ||
                       SQLCODE;
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_error_msg);
        fnd_msg_pub.add;

        IF (l_log_level <= wip_constants.trace_logging) THEN
          wip_logger.log(p_msg          => l_error_msg,
                         x_returnStatus => l_return_status);
        END IF;
    END;
  END LOOP;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.quality_require',
                         p_procReturnStatus => fnd_api.g_ret_sts_success,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
  <<end_quality_check>>
  x_return_status := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_move',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_batch_move.derive_move',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_error_msg,
                           x_returnStatus => l_return_status);
    END IF;
END quality_require;

PROCEDURE validate_batch(p_default_step_type  IN NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2) IS

l_dff_required          BOOLEAN;
l_log_level             NUMBER := fnd_log.g_current_runtime_level;
l_error_msg             VARCHAR2(240);
l_process_phase         VARCHAR2(3);
l_return_status         VARCHAR2(1);
l_params                wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_default_step_type';
    l_params(1).paramValue  :=  p_default_step_type;

    wip_logger.entryPoint(p_procName     => 'wip_batch_move.validate_batch',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';
  IF(p_default_step_type IS NULL) THEN
    -- If no default step defined error out because we do not know what step
    -- we should move assembly to.
    fnd_message.set_name('WIP','WIP_NO_DEFAULT_STEP_NO_BATCH');
    fnd_msg_pub.add;
    l_error_msg := 'No default intraoperation step defined.';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  l_process_phase := '3';
  l_dff_required := fnd_flex_apis.is_descr_required(
                      x_application_id => 706, -- WIP
                      x_desc_flex_name => 'WIP_MOVE_TRANSACTIONS');

  IF(l_dff_required) THEN
    -- If DFF required for this transaction, error out because user cannot
    -- provide DFF information for this type of transaction.
    fnd_message.set_name('WIP','WIP_DFF_REQUIRE_NO_BATCH');
    fnd_msg_pub.add;
    l_error_msg := 'DFF is mandatory.';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;
  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.validate_batch',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.validate_batch',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;

  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.validate_batch',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;

END validate_batch;

PROCEDURE validate_row(p_org_id                IN         NUMBER,
                       p_wip_entity_id         IN         NUMBER,
                       p_wip_entity_name       IN         VARCHAR2,
                       p_op_seq                IN         NUMBER,
                       p_move_qty              IN         NUMBER,
                       p_scrap_qty             IN         NUMBER,
                       p_default_step_type     IN         NUMBER,
                       p_default_scrap_acct_id IN         NUMBER,
                       p_resp_key              IN         VARCHAR2,
                       p_assy_serial           IN         VARCHAR2,
                       x_move_table_pvt        OUT NOCOPY wip_batch_move.move_table_pvt,
                       x_return_status         OUT NOCOPY VARCHAR2) IS

l_available_qty         NUMBER;
l_fm_step_type          NUMBER;
l_log_level             NUMBER := fnd_log.g_current_runtime_level;
l_queue_qty             NUMBER;
l_run_qty               NUMBER;
l_to_move_qty           NUMBER;
l_require_scrap_acct    NUMBER;
l_error_msg             VARCHAR2(240);
l_process_phase         VARCHAR2(3);
l_quality_require       VARCHAR2(1);
l_plan_names            VARCHAR2(4000);
l_return_status         VARCHAR2(1);
l_params                wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_wip_entity_id';
    l_params(2).paramValue  :=  p_wip_entity_id;
    l_params(3).paramName   := 'p_wip_entity_name';
    l_params(3).paramValue  :=  p_wip_entity_name;
    l_params(4).paramName   := 'p_op_seq';
    l_params(4).paramValue  :=  p_op_seq;
    l_params(5).paramName   := 'p_move_qty';
    l_params(5).paramValue  :=  p_move_qty;
    l_params(6).paramName   := 'p_scrap_qty';
    l_params(6).paramValue  :=  p_scrap_qty;
    l_params(7).paramName   := 'p_default_step_type';
    l_params(7).paramValue  :=  p_default_step_type;
    l_params(8).paramName   := 'p_default_scrap_acct_id';
    l_params(8).paramValue  :=  p_default_scrap_acct_id;
    l_params(9).paramName   := 'p_resp_key';
    l_params(9).paramValue  :=  p_resp_key;
    l_params(10).paramName  := 'p_assy_serial';
    l_params(10).paramValue :=  p_assy_serial;
    wip_logger.entryPoint(p_procName     => 'wip_batch_move.validate_row',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;

  l_process_phase := '2';
  SELECT quantity_in_queue,
         quantity_running,
         quantity_waiting_to_move,
         quantity_in_queue + quantity_running + quantity_waiting_to_move
    INTO l_queue_qty,
         l_run_qty,
         l_to_move_qty,
         l_available_qty
    FROM wip_operations
   WHERE organization_id = p_org_id
     AND wip_entity_id = p_wip_entity_id
     AND operation_seq_num = p_op_seq;

  -- If express move from search serial page, we should skip quantity split
  -- validation because we know exactly what serial user want to move even if
  -- quantity is splitted.
  IF(p_assy_serial IS NULL) THEN
    l_process_phase := '2.1';
    -- Quantity cannot split between queue, run and to move of the from
    -- operation because user cannot provide this information for batch move.
    IF(l_queue_qty <> l_available_qty AND
       l_run_qty <> l_available_qty AND
       l_to_move_qty <> l_available_qty) THEN
      fnd_message.set_name('WIP','WIP_QTY_SPLIT_NO_BATCH');
      fnd_msg_pub.add;
      l_error_msg := 'Quantity split at from operation.';
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    -- If quantity not split, derive from step.
    IF(l_queue_qty = l_available_qty)THEN
      l_fm_step_type := WIP_CONSTANTS.QUEUE;
    ELSIF(l_run_qty = l_available_qty) THEN
      l_fm_step_type := WIP_CONSTANTS.RUN;
    ELSIF(l_to_move_qty = l_available_qty) THEN
      l_fm_step_type := WIP_CONSTANTS.TOMOVE;
    END IF;
  ELSE -- Express move from search serial page, quantity can be splitted.
    l_process_phase := '2.2';
    -- From_step is the current location of the serial.
    SELECT nvl(msn.intraoperation_step_type, WIP_CONSTANTS.QUEUE)
      INTO l_fm_step_type
      FROM mtl_serial_numbers msn,
           wip_discrete_jobs wdj
     WHERE wdj.organization_id = p_org_id
       AND wdj.wip_entity_id = p_wip_entity_id
       AND msn.inventory_item_id = wdj.primary_item_id
       AND msn.serial_number = p_assy_serial;
  END IF; -- If not express move from search serial page.

  l_process_phase := '3';
  -- Quantity to move pluse quantity to scrap must be less than or equal to
  -- available quantity because we will not support overmove for batch move.
  IF(p_move_qty + p_scrap_qty > l_available_qty) THEN
    fnd_message.set_name('WIP','WIP_NOT_ENOUGH_QTY_FOR_BATCH');
    fnd_msg_pub.add;
    l_error_msg := 'Transaction quantity is greater than available quantity.';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  l_process_phase := '4';
  SELECT mandatory_scrap_flag
    INTO l_require_scrap_acct
    FROM wip_parameters
   WHERE organization_id = p_org_id;
  -- If user provide scrap quantity and organization require scrap account,
  -- preference "Default Scrap Account" must be set.
  IF(p_scrap_qty > 0 AND
     l_require_scrap_acct = WIP_CONSTANTS.YES AND
     p_default_scrap_acct_id IS NULL) THEN
    fnd_message.set_name('WIP','WIP_NO_SCRAP_ACCT_NO_BATCH');
    fnd_msg_pub.add;
    l_error_msg := 'No default scrap accout defined.';
    raise fnd_api.g_exc_unexpected_error;
  END IF;
  l_process_phase := '5';
  -- Derive move/scrap information
  derive_row(p_org_id                => p_org_id,
             p_wip_entity_id         => p_wip_entity_id,
             p_wip_entity_name       => p_wip_entity_name,
             p_fm_op_seq             => p_op_seq,
             p_move_qty              => p_move_qty,
             p_scrap_qty             => p_scrap_qty,
             p_require_scrap_acct    => l_require_scrap_acct,
             p_default_scrap_acct_id => p_default_scrap_acct_id,
             p_default_step_type     => p_default_step_type,
             p_fm_step_type          => l_fm_step_type,
             p_resp_key              => p_resp_key,
             x_move_table_pvt        => x_move_table_pvt,
             x_return_status         => x_return_status);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    l_error_msg := 'wip_batch_move.derive_row failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF;
  l_process_phase := '6';
  -- Check whether quality collection is mandatory or not.
  quality_require(p_org_id          => p_org_id,
                  p_move_tbl        => x_move_table_pvt,
                  x_quality_require => l_quality_require,
                  x_plan_names      => l_plan_names,
                  x_return_status   => x_return_status);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    l_error_msg := 'wip_batch_move.quality_require failed';
    raise fnd_api.g_exc_unexpected_error;
  ELSE -- If success, check whether quality is mandatory or not.
    IF(l_quality_require = fnd_api.g_true) THEN
      -- Fixed bug 5335024. Change error message from a generic error message
      -- WIP_QUALITY_REQUIRE_NO_BATCH to QA_TXN_INCOMPLETE which contain plan
      -- name.
      fnd_message.set_name('QA','QA_TXN_INCOMPLETE');
      fnd_message.set_token('PLANS1', l_plan_names);
      fnd_msg_pub.add;
      l_error_msg := 'Quality collection is mandatory.';
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.validate_row',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.validate_row',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;

  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                   ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.validate_row',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;
END validate_row;

PROCEDURE process(p_move_table    IN         wip_batch_move.move_table,
                  p_resp_key      IN         VARCHAR2,
                  p_org_id        IN         NUMBER,
                  p_dept_id       IN         NUMBER,
                  p_employee_id   IN         NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2) IS

l_default_scrap_acct_id NUMBER;
l_default_step_type     NUMBER;
l_error_row             NUMBER := 0;
l_group_id              NUMBER;
l_log_level             NUMBER := fnd_log.g_current_runtime_level;
l_total_row             NUMBER;
l_error_msg             VARCHAR2(240);
l_error_text            VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_move_table_pvt        wip_batch_move.move_table_pvt;
l_params                wip_logger.param_tbl_t;
BEGIN
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_resp_key';
    l_params(1).paramValue  :=  p_resp_key;
    l_params(2).paramName   := 'p_org_id';
    l_params(2).paramValue  :=  p_org_id;
    l_params(3).paramName   := 'p_dept_id';
    l_params(3).paramValue  :=  p_dept_id;
    l_params(4).paramName   := 'p_employee_id';
    l_params(4).paramValue  :=  p_employee_id;
    wip_logger.entryPoint(p_procName     => 'wip_batch_move.process',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;

  -- Initialize message stack
  fnd_msg_pub.initialize;
  -- Get neccessary lookups from the database
  initialize_lookups;
  -- Get preferences required to perform batch move transactions.
  get_preferences(p_resp_key              => p_resp_key,
                  p_org_id                => p_org_id,
                  p_dept_id               => p_dept_id,
                  x_default_step_type     => l_default_step_type,
                  x_default_scrap_acct_id => l_default_scrap_acct_id,
                  x_return_status         => x_return_status);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    l_error_msg := 'wip_batch_move.get_preferences failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF;
  -- Perform generic validation for the whole batch.
  validate_batch(p_default_step_type  => l_default_step_type,
                 x_return_status      => x_return_status);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    l_error_msg := 'wip_batch_move.validate_batch failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  l_total_row := p_move_table.count;

  FOR i IN 1..l_total_row LOOP
    BEGIN
      SAVEPOINT s_batch_move1;
      -- Perform row specific validation.
      validate_row(p_org_id                => p_org_id,
                   p_wip_entity_id         => p_move_table(i).wip_entity_id,
                   p_wip_entity_name       => p_move_table(i).wip_entity_name,
                   p_op_seq                => p_move_table(i).op_seq,
                   p_move_qty              => p_move_table(i).move_qty,
                   p_scrap_qty             => p_move_table(i).scrap_qty,
                   p_default_step_type     => l_default_step_type,
                   p_default_scrap_acct_id => l_default_scrap_acct_id,
                   p_resp_key              => p_resp_key,
                   p_assy_serial           => p_move_table(i).assy_serial,
                   x_move_table_pvt        => l_move_table_pvt,
                   x_return_status         => x_return_status);

      IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
        l_error_msg := 'wip_batch_move.validate_row failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      -- Insert move/scrap record into WMTI
      insert_move_records(p_org_id         => p_org_id,
                          p_employee_id    => p_employee_id,
                          p_move_table_pvt => l_move_table_pvt,
                          p_assy_serial    => p_move_table(i).assy_serial,
                          x_group_id       => l_group_id,
                          x_return_status  => x_return_status);

      IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
        l_error_msg := 'wip_batch_move.insert_move_records failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      -- Clear all move information.
      l_move_table_pvt.delete;

      -- Process move records
      process_move_records(p_group_id      => l_group_id,
                           x_return_status => x_return_status);

      IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
        l_error_msg := 'wip_batch_move.process_move_records failed';
        raise fnd_api.g_exc_unexpected_error;
      ELSE
        -- Initialize message stack to clear "Txn Success" inventory put in
        -- the stack.
        fnd_msg_pub.initialize;
        COMMIT;
      END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO SAVEPOINT s_batch_move1;
        -- Put a useful error message in the stack to display back to the user.
        wip_utilities.get_message_stack(p_msg => l_error_text);
        add_error(p_job_name   => p_move_table(i).wip_entity_name,
                  p_op_seq_num => p_move_table(i).op_seq,
                  p_error_text => l_error_text);
        l_error_row := l_error_row + 1;
        l_error_msg := 'row = ' || i || ' : ' || l_error_msg;
        IF (l_log_level <= wip_constants.trace_logging) THEN
          wip_logger.log(p_msg          => l_error_msg,
                         x_returnStatus => l_return_status);
        END IF;

      WHEN others THEN
        ROLLBACK TO SAVEPOINT s_batch_move1;
        -- Put a useful error message in the stack to display back to the user.
        wip_utilities.get_message_stack(p_msg => l_error_text);
        add_error(p_job_name   => p_move_table(i).wip_entity_name,
                  p_op_seq_num => p_move_table(i).op_seq,
                  p_error_text => l_error_text);
        l_error_row := l_error_row + 1;
        l_error_msg := 'row = ' || i || ' : ' ||
                       ' unexpected error: ' || SQLERRM || 'SQLCODE = ' ||
                       SQLCODE;
        IF (l_log_level <= wip_constants.trace_logging) THEN
          wip_logger.log(p_msg          => l_error_msg,
                         x_returnStatus => l_return_status);
        END IF;
    END;
  END LOOP;

  IF(l_error_row = 0) THEN
    x_return_status := fnd_api.g_ret_sts_success;
  ELSE
    -- Put all error message to message stack.
    load_errors;
    x_return_status := fnd_api.g_ret_sts_error;
  END IF;
  -- Write to the log file.
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_batch_move.process',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
    wip_logger.cleanUp(x_returnStatus => l_return_status);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.process',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
      wip_logger.cleanUp(x_returnStatus => l_return_status);
    END IF;

  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    l_error_msg := ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName         => 'wip_batch_move.process',
                           p_procReturnStatus => x_return_status,
                           p_msg              => l_error_msg,
                           x_returnStatus     => l_return_status);
      wip_logger.cleanUp(x_returnStatus => l_return_status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;
END process;
END wip_batch_move;

/

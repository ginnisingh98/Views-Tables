--------------------------------------------------------
--  DDL for Package Body CSTPPLLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPLLC" as
/* $Header: CSTPLLCB.pls 120.1.12010000.2 2008/08/08 12:32:11 smsasidh ship $*/

/*--------------------------------------------------------------------------
  PRIVATE PROCEDURE
    get_assembly_components
    This procedure gets components of the assembly item which has the
    completion/return/scrap.

  i_method:
    1: use WIP Bill to get the components
    2: use material transactions to get the components
  --------------------------------------------------------------------------*/

PROCEDURE get_assembly_components(
  i_pac_period_id IN  NUMBER,
  i_cost_group_id IN  NUMBER,
  i_start_date    IN  DATE,
  i_end_date      IN  DATE,
  i_user_id       IN  NUMBER,
  i_login_id      IN  NUMBER,
  i_request_id    IN  NUMBER,
  i_prog_id       IN  NUMBER,
  i_prog_app_id   IN  NUMBER,
  i_method	  IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_code      OUT NOCOPY VARCHAR2,
  o_err_msg       OUT NOCOPY VARCHAR2)
IS
  CURSOR C_assm_comp(
    c_start_date    IN DATE,
    c_end_date      IN DATE,
    c_cost_group_id IN NUMBER)
  IS
    SELECT transaction_id,
           completion_transaction_id,
           transaction_source_id,
           repetitive_line_id,
           inventory_item_id,
           organization_id,
           flow_schedule
    FROM   mtl_material_transactions mmt
    WHERE  transaction_source_type_id = 5        /* job or schedule */
    AND    transaction_action_id IN (30, 31, 32) /* scrap,completion,return */
    AND    transaction_date BETWEEN trunc(c_start_date)
           AND (trunc(c_end_date) + 0.99999)
    AND    EXISTS(
             SELECT 'exists'
             FROM   cst_cost_group_assignments
             WHERE  cost_group_id = c_cost_group_id
             AND    organization_id = mmt.organization_id);

  comp_rec     C_assm_comp%ROWTYPE;
  l_start_date DATE;
  l_end_date   DATE;
  l_stmt_num   NUMBER;
  l_loop_count NUMBER;
BEGIN
  o_err_num    := 0;
  o_err_code   := '';
  o_err_msg    := '';
  l_loop_count := 0;
  l_stmt_num   := 10;

  FOR comp_rec in C_assm_comp(i_start_date, i_end_date, i_cost_group_id)
  LOOP
    l_loop_count := l_loop_count + 1;

    /*----------------------------------------------------------------------
     The (-1, inventory_item_id) combination inserted will signify that there
     has been a completion/scrap/return for the item
    ------------------------------------------------------------------------*/

    INSERT INTO
	   cst_pac_explosion_temp (
           pac_period_id,
           cost_group_id,
           assembly_item_id,
           component_item_id,
           deleted,
           loop_count)
    SELECT i_pac_period_id,
           i_cost_group_id,
           -1,
           comp_rec.inventory_item_id,
           'N',
           1000
    FROM   dual
    WHERE  NOT EXISTS (
             SELECT 'exists'
    	     FROM   cst_pac_explosion_temp
       	     WHERE  assembly_item_id = -1
       	     AND    component_item_id =  comp_rec.inventory_item_id
       	     AND    pac_period_id = i_pac_period_id
       	     AND    cost_group_id = i_cost_group_id);

    IF(NVL(comp_rec.flow_schedule,'N') <> 'Y') THEN /* not CFM */
      IF (comp_rec.repetitive_line_id IS NULL) THEN /* discrete jobs */
        IF (i_method = 1) THEN
          INSERT INTO
	         cst_pac_explosion_temp(
                 pac_period_id,
       	         cost_group_id,
       	         assembly_item_id,
       	         component_item_id,
       	         deleted,
       	         loop_count)
          SELECT DISTINCT
       	         i_pac_period_id,
       	         i_cost_group_id,
       	         comp_rec.inventory_item_id,
       	         wro.inventory_item_id,
       	         'N',
       	         1000
          FROM   wip_requirement_operations wro
          WHERE  wro.wip_entity_id = comp_rec.transaction_source_id
          AND    NOT EXISTS (
                   SELECT 'exists'
                   FROM   cst_pac_explosion_temp
                   WHERE  assembly_item_id = comp_rec.inventory_item_id
                   AND    component_item_id = inventory_item_id
                   AND    pac_period_id = i_pac_period_id
                   AND    cost_group_id = i_cost_group_id);
        ELSE /* i_method = 2 */
          INSERT INTO
		 cst_pac_explosion_temp(
                 pac_period_id,
                 cost_group_id,
                 assembly_item_id,
                 component_item_id,
                 deleted,
                 loop_count)
          SELECT DISTINCT
                 i_pac_period_id,
                 i_cost_group_id,
                 comp_rec.inventory_item_id,
                 mmt.inventory_item_id,
                 'N',
                 1000
          FROM   mtl_material_transactions mmt
          WHERE  transaction_source_id = comp_rec.transaction_source_id
          AND    transaction_source_type_id = 5
          AND    transaction_action_id IN (1,27,33,34)
          AND    transaction_date BETWEEN trunc(i_start_date)
	         AND (trunc(i_end_date) + 0.99999)
          AND    NOT EXISTS (
                   SELECT 'exists'
                   FROM   cst_pac_explosion_temp
                   WHERE  assembly_item_id = comp_rec.inventory_item_id
                   AND    component_item_id = inventory_item_id
                   AND    pac_period_id = i_pac_period_id
                   AND    cost_group_id = i_cost_group_id)
          GROUP  BY
                 mmt.inventory_item_id
          HAVING sum(mmt.primary_quantity) <> 0;
        END IF;
      ELSE /* repetitive schedules */
        IF (i_method = 1) THEN
          INSERT INTO
		 cst_pac_explosion_temp(
                 pac_period_id,
                 cost_group_id,
                 assembly_item_id,
                 component_item_id,
                 deleted,
                 loop_count)
          SELECT DISTINCT
                 i_pac_period_id,
                 i_cost_group_id,
                 comp_rec.inventory_item_id,
                 wro.inventory_item_id,
                 'N',
                 1000
          FROM   mtl_material_txn_allocations mmta ,
                 wip_requirement_operations wro
          WHERE  mmta.transaction_id = comp_rec.transaction_id
          AND    mmta.repetitive_schedule_id = wro.repetitive_schedule_id
          AND    wro.wip_entity_id = comp_rec.transaction_source_id
          AND    NOT EXISTS (
		   SELECT 'exists'
                   FROM   cst_pac_explosion_temp
                   WHERE  assembly_item_id = comp_rec.inventory_item_id
                   AND    component_item_id = inventory_item_id
                   AND    pac_period_id = i_pac_period_id
                   AND    cost_group_id = i_cost_group_id);
        ELSE /* i_method = 2 */
          INSERT INTO
		 cst_pac_explosion_temp(
                 pac_period_id,
                 cost_group_id,
                 assembly_item_id,
                 component_item_id,
                 deleted,
                 loop_count)
          SELECT DISTINCT
                 i_pac_period_id,
                 i_cost_group_id,
                 comp_rec.inventory_item_id,
                 mmt.inventory_item_id,
                 'N',
                 1000
          FROM   mtl_material_transactions mmt
          WHERE  transaction_source_id = comp_rec.transaction_source_id
          AND    repetitive_line_id = comp_rec.repetitive_line_id
          AND    transaction_source_type_id = 5
          AND    transaction_action_id IN (1,27,33,34)
          AND    transaction_date BETWEEN trunc(i_start_date)
	         AND (trunc(i_end_date) + 0.99999)
          AND    NOT EXISTS (
		   SELECT 'exists'
                   FROM   cst_pac_explosion_temp
                   WHERE  assembly_item_id = comp_rec.inventory_item_id
                   AND    component_item_id = inventory_item_id
                   AND    pac_period_id = i_pac_period_id
                   AND    cost_group_id = i_cost_group_id)
	  GROUP  BY
                 mmt.inventory_item_id
          HAVING sum(mmt.primary_quantity) <> 0;
        END IF;
      END IF;
    ELSE /* CFM */
      -- For CFM we go to MMT, because BBOM, BIC might be altered all the
      -- time, effectivity dates changed so its difficult to get the bill
      -- back in time
      IF (i_method = 1) THEN
	INSERT INTO
	       cst_pac_explosion_temp(
               pac_period_id,
               cost_group_id,
               assembly_item_id,
               component_item_id,
               deleted,
               loop_count)
        SELECT DISTINCT
               i_pac_period_id,
               i_cost_group_id,
               comp_rec.inventory_item_id,
               mmt.inventory_item_id,
               'N',
               1000
        FROM   mtl_material_transactions mmt
        WHERE  mmt.completion_transaction_id =
                 comp_rec.completion_transaction_id
        AND    transaction_date BETWEEN trunc(i_start_date)
               AND    (trunc(i_end_date) + 0.99999)
        AND    mmt.transaction_action_id in (1,27,33,34)
        AND    NOT EXISTS (
                 SELECT 'exists'
                 FROM   cst_pac_explosion_temp
                 WHERE  assembly_item_id = comp_rec.inventory_item_id
                 AND    component_item_id = inventory_item_id
                 AND    pac_period_id = i_pac_period_id
                 AND    cost_group_id = i_cost_group_id);
      ELSE /* i_method = 2 */
	INSERT INTO
	       cst_pac_explosion_temp(
               pac_period_id,
               cost_group_id,
               assembly_item_id,
               component_item_id,
               deleted,
               loop_count)
        SELECT DISTINCT
               i_pac_period_id,
               i_cost_group_id,
               comp_rec.inventory_item_id,
               mmt.inventory_item_id,
               'N',
               1000
        FROM   mtl_material_transactions mmt
        WHERE  mmt.completion_transaction_id =
                 comp_rec.completion_transaction_id
        AND    transaction_date BETWEEN trunc(i_start_date)
               AND    (trunc(i_end_date) + 0.99999)
        AND    mmt.transaction_action_id in (1,27,33,34)
        AND    NOT EXISTS (
                 SELECT 'exists'
                 FROM   cst_pac_explosion_temp
                 WHERE  assembly_item_id = comp_rec.inventory_item_id
                 AND    component_item_id = inventory_item_id
                 AND    pac_period_id = i_pac_period_id
                 AND    cost_group_id = i_cost_group_id)
        GROUP  BY
	       mmt.inventory_item_id
        HAVING sum(primary_quantity) <> 0;
      END IF;
    END IF;
  END LOOP;

  /*------------------------------------------------------------------------
    Not really an error but still filling in error message for debugging
    ------------------------------------------------------------------------*/

  IF (l_loop_count = 0) THEN
    o_err_msg := 'No assembly completions/returns/scrap txns in period '
                 || TO_CHAR(i_pac_period_id)
                 || ' for the cost group/legal entity '
                 || TO_CHAR(i_cost_group_id) ;
  END IF;
EXCEPTION
  WHEN others THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPLLC:'
                 || 'get_assembly_components:'
                 || to_char(l_stmt_num)
                 || ' '
                 || substr(SQLERRM,1,150);

END get_assembly_components;

/*--------------------------------------------------------------------------
  PRIVATE PROCEDURE
    calc_low_level_codes
    This procedure will actually calculate the low level codes for
    assembly items with completion/scrap/return.
  --------------------------------------------------------------------------*/

PROCEDURE calc_low_level_codes(
  i_pac_period_id IN  NUMBER,
  i_cost_group_id IN  NUMBER,
  i_start_date    IN  DATE,
  i_end_date      IN  DATE,
  i_user_id       IN  NUMBER,
  i_login_id      IN  NUMBER,
  i_request_id    IN  NUMBER,
  i_prog_id       IN  NUMBER,
  i_prog_app_id   IN  NUMBER,
  i_method        IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_code      OUT NOCOPY VARCHAR2,
  o_err_msg       OUT NOCOPY VARCHAR2)
IS
  CURSOR C_comp_not_deleted (
    c_pac_period_id IN NUMBER,
    c_cost_group_id IN NUMBER)
  IS
    SELECT DISTINCT
           component_item_id cii
    FROM   cst_pac_explosion_temp
    WHERE  pac_period_id = c_pac_period_id
    AND    cost_group_id = c_cost_group_id
    AND    deleted = 'N';

  -- cursor of job/schedules whose assemblies and components forms a loop

  CURSOR C_looping_transactions (
    c_start_date	IN DATE,
    c_end_date	        IN DATE,
    c_pac_period_id     IN NUMBER,
    c_cost_group_id     IN NUMBER)
  IS
    SELECT DISTINCT
	   msik1.inventory_item_id assembly_item_id,
	   msik1.concatenated_segments assembly_item,
	   msik2.inventory_item_id component_item_id,
	   msik2.concatenated_segments component_item,
	   we.wip_entity_id wip_entity_id,
	   we.wip_entity_name wip_entity
    FROM   cst_pac_explosion_temp cpet,
           mtl_material_transactions mmt1,
	   mtl_material_transactions mmt2,
           mtl_system_items_kfv msik1,
           mtl_system_items_kfv msik2,
           wip_entities we
    WHERE  cpet.pac_period_id = c_pac_period_id
    AND    cpet.cost_group_id = c_cost_group_id
    AND    cpet.deleted = 'N'
    AND    mmt1.inventory_item_id = cpet.assembly_item_id
    AND    mmt1.transaction_source_type_id = 5
    AND    mmt1.transaction_action_id IN (30,31,32)
    AND    mmt1.transaction_date BETWEEN trunc(c_start_date)
           AND (trunc(c_end_date) + 0.99999)
    AND    (
             SELECT count('exists')
             FROM   cst_cost_group_assignments
	     WHERE  cost_group_id = c_cost_group_id
             AND    organization_id = mmt1.organization_id
             and    rownum < 2 ) > 0
    AND    mmt2.inventory_item_id = cpet.component_item_id
    AND    mmt2.transaction_action_id IN (1,27,33,34)
    AND    mmt2.transaction_date BETWEEN trunc(c_start_date)
           AND (trunc(c_end_date) + 0.99999)
    AND    (   (   (   NVL(mmt1.flow_schedule,'N') <> 'Y')
	       AND mmt1.repetitive_line_id IS NULL
	       AND mmt2.transaction_source_id = mmt1.transaction_source_id
	       AND mmt2.transaction_source_type_id = 5)
	   OR  (   (   NVL(mmt1.flow_schedule,'N') <> 'Y')
	       AND mmt1.repetitive_line_id IS NOT NULL
	       AND mmt2.transaction_source_id = mmt1.transaction_source_id
	       AND mmt2.repetitive_line_id = mmt1.repetitive_line_id
	       AND mmt2.transaction_source_type_id = 5)
	   OR  (   (   NVL(mmt1.flow_schedule,'N') = 'Y')
	       AND mmt2.completion_transaction_id = mmt1.completion_transaction_id))
    AND    msik1.organization_id = mmt1.organization_id
    AND    msik1.inventory_item_id = mmt1.inventory_item_id
    AND    msik2.organization_id = msik2.organization_id
    AND    msik2.inventory_item_id = mmt2.inventory_item_id
    AND    we.wip_entity_id = mmt2.transaction_source_id
    GROUP  BY
	   msik1.inventory_item_id,
           msik1.concatenated_segments,
	   msik2.inventory_item_id,
	   msik2.concatenated_segments,
	   we.wip_entity_id,
	   we.wip_entity_name
    HAVING sum(mmt2.primary_quantity) <> 0;

  l_counter              NUMBER;
  l_iteration            NUMBER DEFAULT 0;
  l_level_code           NUMBER DEFAULT 1001;
  l_update_flag          BOOLEAN DEFAULT FALSE;
  l_Processed_all_rows   BOOLEAN DEFAULT FALSE;
  l_cii                  cst_pac_explosion_temp.component_item_id%TYPE;
  l_looping_transaction  C_looping_transactions%ROWTYPE;
  l_stmt_num             NUMBER;
  LOOP_ERROR             EXCEPTION;
  LOOP_WARNING           EXCEPTION;
BEGIN
  o_err_num  := 0;
  o_err_code := '';
  o_err_msg  := '';
  l_stmt_num := 10;

  /*------------------------------------------------------------------------
    Marking for deletion rows which have component item same as the
    assembly item. This is for non standard jobs
    ------------------------------------------------------------------------*/

  UPDATE cst_pac_explosion_temp
  SET    deleted = 'Y',
         loop_count = l_iteration
  WHERE  component_item_id = assembly_item_id
  AND    deleted = 'N'
  AND    pac_period_id = i_pac_period_id
  AND    cost_group_id = i_cost_group_id;

  WHILE NOT (l_Processed_all_rows) LOOP
    l_update_flag := FALSE;
    l_counter     := 0;
    l_level_code  := l_level_code - 1;
    l_iteration   := l_iteration + 1;
    l_stmt_num    := 20;

    OPEN C_comp_not_deleted(i_pac_period_id,i_cost_group_id);
    LOOP
      l_stmt_num := 30;
      FETCH C_comp_not_deleted INTO l_cii;
      EXIT when C_comp_not_deleted%NOTFOUND;

      l_counter := l_counter + 1;

      /*---------------------------------------------------------------------
        Mark for deletion those rows where the component itself is not a
        parent. Need to only check with rows that have been updated by
        previous iterations since components can occur at different levels
        --------------------------------------------------------------------*/
      l_stmt_num := 40;

      UPDATE /*+ index(cet1 CST_PAC_EXPLOSION_TEMP_N1) */
            cst_pac_explosion_temp cet1
      SET    deleted = 'Y',
             loop_count = l_iteration
      WHERE  component_item_id = l_cii
      AND    deleted = 'N'
      AND    pac_period_id = i_pac_period_id
      AND    cost_group_id = i_cost_group_id
      AND    NOT EXISTS (
               SELECT 'exists as a parent'
               FROM   cst_pac_explosion_temp cet2
               WHERE  cet2.assembly_item_id = l_cii
               AND    pac_period_id = i_pac_period_id
               AND    cost_group_id = i_cost_group_id
               AND    loop_count >= l_iteration);

      /*---------------------------------------------------------------------
        if no rows are updated then it implies that the component exists as a
        parent and should not for now be inserted into the CPLLC table
        --------------------------------------------------------------------*/
      l_stmt_num := 50;

      IF (SQL%ROWCOUNT > 0) THEN
        l_update_flag := TRUE;
        INSERT INTO
	       cst_pac_low_level_codes (
                 pac_period_id,
                 cost_group_id,
                 inventory_item_id,
                 low_level_code,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by)
               VALUES (
	         i_pac_period_id,
                 i_cost_group_id,
                 l_cii,
                 l_level_code,
                 sysdate,
                 -1,
                 sysdate,
                 -1);
      END IF;
    END LOOP;
    CLOSE C_comp_not_deleted;

    IF (l_counter = 0) then
      l_processed_all_rows := TRUE;
    END IF;

    l_stmt_num := 60;

    /*------------------------------------------------------------------------
      if "undeleted" rows still exist in cst_pac_explosion_temp and no rows
      were updated, then this implies there is a LOOP.
      ----------------------------------------------------------------------*/

    IF (NOT l_update_flag AND l_counter > 0) THEN
      IF (i_method = 1) THEN
        raise LOOP_WARNING;
      ELSE
        raise LOOP_ERROR;
      END IF;
      exit;
    END IF;

  END LOOP;

  /*-------------------------------------------------------------------------
    We need to have low level codes only for assembly items which have
    completion/return/scrap. So we delete all leaf node items from cpllc. We
    make sure that assembly items with completion/scrap/return are not
    considered as leaf nodes even if they might appear with LLC of 1000
    ------------------------------------------------------------------------*/

  DELETE FROM
         cst_pac_low_level_codes cpllc
  WHERE  low_level_code = 1000
  AND    cost_group_id = i_cost_group_id
  AND    pac_period_id = i_pac_period_id
  AND    NOT EXISTS (
           SELECT component_item_id FROM cst_pac_explosion_temp cpet
           WHERE  assembly_item_id = -1
           AND    component_item_id = cpllc.inventory_item_id
           AND    cost_group_id = i_cost_group_id
           AND    pac_period_id = i_pac_period_id);

EXCEPTION
  WHEN LOOP_WARNING THEN
    DELETE FROM
           cst_pac_low_level_codes
    WHERE  cost_group_id = i_cost_group_id
    AND    pac_period_id = i_pac_period_id;
    DELETE FROM
           cst_pac_explosion_temp
    WHERE  cost_group_id = i_cost_group_id
    AND    pac_period_id = i_pac_period_id;

    o_err_num  := -999;
    o_err_code := 'LOOP';
    o_err_msg  := 'CSTPPLLC:'
                  || 'calc_low_level_codes:'
                  || to_char(l_stmt_num)
                  || ' '
                  || 'A potential loop dependency is detected between the '
                  || 'transactions within this period. Recalculating the '
                  || 'low level codes to verify...';
  WHEN LOOP_ERROR THEN
    DELETE FROM
           cst_pac_low_level_codes
    WHERE  cost_group_id = i_cost_group_id
    AND    pac_period_id = i_pac_period_id;

    o_err_num  := -999;
    o_err_code := 'LOOP';
    o_err_msg  := 'CSTPPLLC:'
                  || 'calc_low_level_codes:'
                  || to_char(l_stmt_num)
                  || ' '
                  || 'A loop dependency is detected between '
	          || 'the transactions listed below (in the plsql section)';
    OPEN C_looping_transactions(
      i_start_date,
      i_end_date,
      i_pac_period_id,
      i_cost_group_id);
    LOOP
      FETCH C_looping_transactions INTO l_looping_transaction;
      EXIT when C_looping_transactions%NOTFOUND;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Component '
        || l_looping_transaction.component_item
        || ' is issued for assembly '
        || l_looping_transaction.assembly_item
     	|| ' in job / repetitive assembly / flow schedule '
       	|| l_looping_transaction.wip_entity);
    END LOOP;
    CLOSE C_looping_transactions;
  WHEN others THEN
    o_err_num  := SQLCODE;
    o_err_code := '';
    o_err_msg  := 'CSTPPLLC:'
                  || 'calc_low_level_codes:'
                  || to_char(l_stmt_num)
                  || ' '
                  || substr(SQLERRM,1,150);
END calc_low_level_codes;

/*--------------------------------------------------------------------------
  PUBLIC PROCEDURE
    pac_low_level_codes
    This is the public interface to the package.  It will inturn call the
    private procedures
  --------------------------------------------------------------------------*/
PROCEDURE pac_low_level_codes(
  i_pac_period_id IN  NUMBER,
  i_cost_group_id IN  NUMBER,
  i_start_date	  IN  DATE,
  i_end_date      IN  DATE,
  i_user_id       IN  NUMBER,
  i_login_id      IN  NUMBER,
  i_request_id    IN  NUMBER,
  i_prog_id       IN  NUMBER,
  i_prog_app_id   IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_code      OUT NOCOPY VARCHAR2,
  o_err_msg       OUT NOCOPY VARCHAR2)
IS
  l_err_num NUMBER;
  l_err_code VARCHAR2(240);
  l_err_msg VARCHAR2(240);
  l_stmt_num NUMBER;
  process_error EXCEPTION;
BEGIN
  l_stmt_num := 10;
  o_err_num  := 0;
  o_err_code := '';
  o_err_msg  := '';

  -- get the assembly components using WRO for fast checking

  get_assembly_components(
    i_pac_period_id,
    i_cost_group_id,
    i_start_date,
    i_end_date,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_app_id,
    1,
    l_err_num,
    l_err_code,
    l_err_msg);

  IF (l_err_num <> 0) THEN
    raise process_error;
  END IF;

  calc_low_level_codes(
    i_pac_period_id,
    i_cost_group_id,
    i_start_date,
    i_end_date,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_app_id,
    1,
    l_err_num,
    l_err_code,
    l_err_msg);

  IF (l_err_code = 'LOOP') THEN
    -- Potential loop, try getting the assembly components
    -- using MMT for accurate checking
    get_assembly_components(
      i_pac_period_id,
      i_cost_group_id,
      i_start_date,
      i_end_date,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_id,
      i_prog_app_id,
      2,
      l_err_num,
      l_err_code,
      l_err_msg);

    IF (l_err_num <> 0) THEN
      raise process_error;
    END IF;

    calc_low_level_codes(
      i_pac_period_id,
      i_cost_group_id,
      i_start_date,
      i_end_date,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_id,
      i_prog_app_id,
      2,
      l_err_num,
      l_err_code,
      l_err_msg);
  END IF;

  IF (l_err_num <> 0) THEN
    raise process_error;
  END IF;
EXCEPTION
  WHEN process_error THEN
    o_err_num := l_err_num;
    o_err_msg := l_err_msg;
  WHEN others THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPLLC:'
                 || 'pac_low_level_codes:'
                 || to_char(l_stmt_num)
                 || ' '
                 || substr(SQLERRM,1,150);
END pac_low_level_codes;

END CSTPPLLC;

/

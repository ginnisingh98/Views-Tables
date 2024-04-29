--------------------------------------------------------
--  DDL for Package Body MIGRATE_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MIGRATE_BATCH" AS
/* $Header: GMEMIGBB.pls 120.1 2005/06/09 08:25:43 appldev  $ */

/***********************************************************/
-- Oracle Process Manufacturing Process Execution APIs
--
-- File Name:   GMEMIGBB.pls
-- Contents:    Package body for GME data migration
-- Description:
--   This package migrates GME data from 11.5.1H and prior to
--   11.5.1I.
--
--   The general architecture is a table by table
--   copy via INSERT INTO...SELECT FROM.  If calculations are
--   required, functions are used for that purpose inline.

--   There are 3 batch by batch processing sections:
--   1. check_wip_batches,
--   2. split_trans_line, and
--   3. insert_batch_step_dtls.
--   check_wip_batches finds completed default transactions and reports them.  It also
--   reverses the transaction and creates a new pending transaction.
--   split_trans_line deals with completed default transactions that are
--   either plain or non-plain with 0 qty.  Here, for 0 qty completed, the
--   transaction can be flipped to pending.  For non-zero completed plain, a
--   0 qty pending transaction is inserted.  insert_batch_step_dtls performs
--   batch by batch processing in order to normalize pm_oprn_dtl
--   into gme_batch_step_activities and gme_batch_step_resources.
--
--   The main package to call is migrate_batch.run.  If it is called with no parameters,
--   or as migrate_batch.run(p_commit => FALSE) a rollback is performed at the end of the
--   migration.  This is for purposes of validation, so that the user can find all data
--   conditions that exist without changing data.  Call migrate_batch.run(p_commit => TRUE)
--   and this will migrate data with a commit at each phase of migration.
--
--   Messages are logged to gme_temp_exceptions.
--   Message types are: 'P' for progress, 'I' for information, 'E' for error, and 'D' for
--   unexpected error.  'D' will come from WHEN OTHERS exception block and there can only be
--   one 'D' because WHEN OTHERS do a RAISE and will not continue processing further.  This
--   will typically occur because of unexpected SQL errors.
--
--
-- Author:    Antonia Newbury
-- Date:      March 2002
--
-- History
-- =======
--  Shrikant Nene - 06/19/2002 B2417758 .
--    Moved 1 line of code, so that it will print the correct
--    message.
--    Also changed l_tran_reverse.trans_id to l_tran_row.trans_id
-- Shrikant Nene - 02/10/2003 B2792583
--    Corrected reference of pm_matl_dt to pm_matl_dtl_bak
--    in procedure renumber_duplicate_line_no.
--    Since it was looking at the original table, this procedure
--    did not find anything.
-- Antonia Newbury - 2/26/2003 Added fixes which came out of 4.1
--    validation testing:
--    1. Set IN_USE = 0 for in_use of NULL and in_use NOT in (0,100)
--    2. Set delete mark for step details and resource trxns on steps
--    that are deleted.
--    3. Perform a tablespace check to inform the user if the tablespace
--    for GME is less than a defined %.  (Currently 60).
--    4. Report item/step associations and step dependencies that are
--    orphaned from the parent table because these will not be migrated.
-- Antonia Newbury - 2/28/2003 Added fixes which are required to make
--    migration patchset candidate checkin to run with the 11.5.9 install.
--    1. Continue with migration even if validation didn't run.
--    2. Return from migration if there are no batches in pm_btch_hdr.  This
--    is a speed optimization for new GME/OPM customers.  No need to run through
--    all the checks in this program if there are no batches.
--    3. Remove all GANTT table logic.  This will be done via bug # 2565952.
--    That is a patchset candidate checkin for MP J and the sql file to run
--    the code which populates the tables is being changed to run after this runs.
--    (dbdrv hints are being changed).  This way it rus after migration runs (so
--    that there is data to be populated in the GANTT table.
--    4. Added nocopy.
-- Antonia Newbury - 01/14/2004 Changed call to gmi_locks.lock_inventory to have
--    named parameters.
--
-- G. Muratore     - 06/09/2005 Bug 4249832 Removed hard coded schemas per gscc.
/***********************************************************/

   g_resource       pm_oprn_dtl.resources%TYPE;
   g_batch_id       pm_btch_hdr_bak.batch_id%TYPE;
   g_min_capacity   NUMBER;
   g_max_capacity   NUMBER;
   g_capacity_uom   VARCHAR2 (4);
   g_mig_date       DATE                                := NULL;
   g_date_format    VARCHAR2(100) := 'YYYY-MM-DD HH24:MI:SS';
   g_tablespace_target_free NUMBER := 60;
   g_tablespace_User        VARCHAR2(10) := 'GME';

   PROCEDURE insert_message_into_table (
      p_table_name       IN   VARCHAR2,
      p_procedure_name   IN   VARCHAR2,
      p_parameters       IN   VARCHAR2,
      p_message          IN   VARCHAR2,
      p_error_type       IN   VARCHAR2
   ) IS
      PRAGMA autonomous_transaction;
   BEGIN

	IF p_error_type = 'V' THEN
		/* This is validation control; if error_typpe is V, then we are ensuring that validation		*/
		/* was run at least once.																							*/
		/* This was combined with log table because it was found that having 2 separate autonomous	*/
		/* transactions didn't behave properly.  So, for now these 2 events will be combined.			*/

		IF p_procedure_name = 'set_GME_validated' THEN
			set_GME_validated;
		ELSIF p_procedure_name = 'reset_GME_validated' THEN
			reset_GME_validated;
		END IF;
	ELSE
      INSERT INTO gme_temp_exceptions
                  (table_name,
                   procedure_name,
                   parameters,
                   message,
                   error_type,
                   script_date
                  )
           VALUES (p_table_name,
                   p_procedure_name,
                   p_parameters,
                   TO_CHAR (SYSDATE, g_date_format) || ':  ' || p_message,
                   p_error_type,
                   g_mig_date
                  );
	END IF;

   COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('SQLERRM = '||SQLERRM);

         RAISE;
   END insert_message_into_table;

   PROCEDURE insert_message (
      p_table_name       IN   VARCHAR2,
      p_procedure_name   IN   VARCHAR2,
      p_parameters       IN   VARCHAR2,
      p_message          IN   VARCHAR2,
      p_error_type       IN   VARCHAR2
   ) IS
   BEGIN
      insert_message_into_table (
         p_table_name => p_table_name,
         p_procedure_name => p_procedure_name,
         p_parameters => p_parameters,
         p_message => p_message,
         p_error_type => p_error_type
      );
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('SQLERRM = '||SQLERRM);

         RAISE;
   END insert_message;

   PROCEDURE initialize_migration IS
      l_pos   NUMBER := 0;
   BEGIN
      l_pos := 1;

      IF g_mig_date IS NULL THEN
         g_mig_date := SYSDATE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'DUAL',
            p_procedure_name => 'initialize_migration',
            p_parameters => 'none',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END initialize_migration;

   PROCEDURE unlock_all IS
      l_pos   NUMBER := 0;
   BEGIN
      l_pos := 1;

      UPDATE pm_btch_hdr_bak
      SET in_use = 0
      WHERE in_use IS NULL OR
            in_use NOT in (0,100);

      l_pos := 2;

      insert_message (
         p_table_name => 'pm_btch_hdr',
         p_procedure_name => 'unlock_all',
         p_parameters => 'none',
         p_message => 'number of records unlocked = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      l_pos := 3;

      UPDATE pm_matl_dtl_bak
      SET in_use = 0
      WHERE in_use IS NULL OR
            in_use NOT in (0,100);

      l_pos := 4;

      insert_message (
         p_table_name => 'pm_matl_dtl',
         p_procedure_name => 'unlock_all',
         p_parameters => 'none',
         p_message => 'number of records unlocked = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      l_pos := 5;

      UPDATE pm_rout_dtl
      SET in_use = 0
      WHERE in_use IS NULL OR
            in_use NOT in (0,100);

      l_pos := 6;

      insert_message (
         p_table_name => 'pm_rout_dtl',
         p_procedure_name => 'unlock_all',
         p_parameters => 'none',
         p_message => 'number of records unlocked = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      l_pos := 7;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_btch_hdr/pm_matl_dtl/pm_rout_dtl',
            p_procedure_name => 'unlock_all',
            p_parameters => 'none',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END unlock_all;

   PROCEDURE del_step_dtl_for_del_steps IS
      l_pos   NUMBER := 0;

      CURSOR cur_get_del_steps IS
      SELECT batch_id, batchstep_no
      FROM   pm_rout_dtl
      WHERE  delete_mark = 1;

      CURSOR cur_get_del_step_dtls IS
      SELECT batchstepline_id
      FROM   pm_oprn_dtl
      WHERE  delete_mark = 1;

      l_cur_get_del_steps        cur_get_del_steps%ROWTYPE;
      l_cur_get_del_step_dtls    cur_get_del_step_dtls%ROWTYPE;

   BEGIN
      l_pos := 1;

      OPEN cur_get_del_steps;
      FETCH cur_get_del_steps INTO l_cur_get_del_steps;
      WHILE cur_get_del_steps%FOUND LOOP
         UPDATE pm_oprn_dtl
         SET delete_mark = 1
         WHERE batch_id = l_cur_get_del_steps.batch_id AND
               batchstep_no = l_cur_get_del_steps.batchstep_no;

         FETCH cur_get_del_steps INTO l_cur_get_del_steps;
      END LOOP;
      CLOSE cur_get_del_steps;

      OPEN cur_get_del_step_dtls;
      FETCH cur_get_del_step_dtls INTO l_cur_get_del_step_dtls;
      WHILE cur_get_del_step_dtls%FOUND LOOP
         UPDATE pc_tran_pnd
         SET delete_mark = 1
         WHERE line_id = l_cur_get_del_step_dtls.batchstepline_id;

         FETCH cur_get_del_step_dtls INTO l_cur_get_del_step_dtls;
      END LOOP;
      CLOSE cur_get_del_step_dtls;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_oprn_dtl/pc_tran_pnd',
            p_procedure_name => 'del_step_dtl_for_del_steps',
            p_parameters => 'none',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END del_step_dtl_for_del_steps;

   FUNCTION get_actual_date (p_date IN DATE)
      RETURN DATE IS
      l_pos   NUMBER := 0;
   BEGIN
      l_pos := 1;

      IF TO_CHAR (p_date, 'YYYYMMDDHH24MISS') = '19700101000000' THEN
         l_pos := 2;
         RETURN NULL;
      ELSE
         l_pos := 3;
         RETURN p_date;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'get_actual_date',
            p_parameters => TO_CHAR (p_date, g_date_format),
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_actual_date;

   FUNCTION get_planned_usage (p_batchstepline_id IN NUMBER)
      RETURN NUMBER IS
      v_resource_usage   NUMBER;
      l_pos              NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT plan_rsrc_count * plan_rsrc_usage
        INTO v_resource_usage
        FROM pm_oprn_dtl
       WHERE batchstepline_id = p_batchstepline_id;
      l_pos := 2;
      RETURN v_resource_usage;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_oprn_dtl',
            p_procedure_name => 'get_planned_usage',
            p_parameters => p_batchstepline_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_planned_usage;

   FUNCTION get_actual_activity_factor (
      p_batchstep_id   IN   gme_batch_steps.batchstep_id%TYPE
   )
      RETURN gme_batch_step_activities.actual_activity_factor%TYPE IS
      l_step_status   gme_batch_steps.step_status%TYPE;
      l_pos           NUMBER                             := 0;
   BEGIN
      l_pos := 1;
      SELECT step_status
        INTO l_step_status
        FROM gme_batch_steps
       WHERE batchstep_id = p_batchstep_id;
      l_pos := 2;

      IF l_step_status IN (1, 5) THEN
         l_pos := 3;
         RETURN NULL;
      ELSE
         l_pos := 4;
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_batch_steps',
            p_procedure_name => 'get_actual_activity_factor',
            p_parameters => p_batchstep_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_actual_activity_factor;

   FUNCTION get_actual_usage (p_line_id IN NUMBER)
      RETURN NUMBER IS
      v_resource_usage   NUMBER;
      l_pos              NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT SUM (resource_usage)
        INTO v_resource_usage
        FROM pc_tran_pnd
       WHERE line_id = p_line_id AND
             delete_mark <> 1 AND
             completed_ind = 1;
      l_pos := 2;
      RETURN NVL (v_resource_usage, 0);
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pc_tran_pnd',
            p_procedure_name => 'get_actual_usage',
            p_parameters => p_line_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_actual_usage;

   FUNCTION get_oprn_id (p_batch_id IN NUMBER, p_batchstep_no IN NUMBER)
      RETURN NUMBER IS
      v_oprn_id   NUMBER;
      l_pos       NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT oprn_id
        INTO v_oprn_id
        FROM gme_batch_steps
       WHERE batch_id = p_batch_id AND
             batchstep_no = p_batchstep_no;
      l_pos := 2;
      RETURN v_oprn_id;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_batch_steps',
            p_procedure_name => 'get_oprn_id',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' batchstep_no = '
                            || p_batchstep_no,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_oprn_id;

   FUNCTION get_process_qty_uom (p_oprn_id NUMBER)
      RETURN VARCHAR2 IS
      v_process_qty_uom   VARCHAR2 (4);
      l_pos               NUMBER       := 0;
   BEGIN
      l_pos := 1;
      SELECT process_qty_um
        INTO v_process_qty_uom
        FROM fm_oprn_mst
       WHERE oprn_id = p_oprn_id;
      l_pos := 2;
      RETURN v_process_qty_uom;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'fm_oprn_mst',
            p_procedure_name => 'get_process_qty_uom',
            p_parameters => p_oprn_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_process_qty_uom;

   FUNCTION get_actual_cost_ind (p_batch_id IN NUMBER)
      RETURN VARCHAR2 IS
      v_actual_cost_ind   NUMBER;
      l_pos               NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT NVL (MAX (rollover_ind), -1)
        INTO v_actual_cost_ind
        FROM cm_cmpt_dtl ccd,
             cm_acst_led acl,
             pm_matl_dtl_bak bdtl,
             pm_btch_hdr_bak bhdr
       WHERE ccd.cmpntcost_id = acl.cmpntcost_id AND
             ccd.delete_mark = 0 AND
             acl.source_ind = 0 AND
             acl.transline_id = bdtl.line_id AND
             bdtl.batch_id = bhdr.batch_id AND
             bhdr.batch_id = p_batch_id;
      l_pos := 2;

      IF v_actual_cost_ind IN (0, 1) THEN
         l_pos := 3;
         RETURN 'Y';
      ELSE
         l_pos := 4;
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'cm_cmpt_dtl, cm_acst_led, pm_matl_dtl_bak, pm_btch_hdr_bak',
            p_procedure_name => 'get_actual_cost_ind',
            p_parameters => p_batch_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_actual_cost_ind;

   FUNCTION get_gl_posted_ind (p_batch_id IN NUMBER)
      RETURN NUMBER IS
      v_gl_posted_ind   NUMBER;
      l_pos             NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT NVL (
                MAX (gl_posted_ind),
                0
             ) -- for those customers (IMCO and maybe others) who have manually reopened
               -- batches via sqlplus and then closed through the application.
        INTO v_gl_posted_ind
        FROM pm_hist_hdr
       WHERE batch_id = p_batch_id AND
             new_status = 4;
      l_pos := 2;
      RETURN v_gl_posted_ind;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_hist_hdr',
            p_procedure_name => 'get_gl_posted_ind',
            p_parameters => p_batch_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_gl_posted_ind;

   FUNCTION get_poc_data_ind (p_batch_id IN NUMBER)
      RETURN VARCHAR2 IS
      v_exist   NUMBER := 0;
      l_pos     NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT 1
        INTO v_exist
        FROM pm_rout_dtl
       WHERE batch_id = p_batch_id AND
             delete_mark <> 1 AND
             ROWNUM = 1;
      l_pos := 2;

      IF v_exist = 1 THEN
         l_pos := 3;
         RETURN 'Y';
      ELSE
         l_pos := 4;
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 'N';
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_rout_dtl',
            p_procedure_name => 'get_poc_data_ind',
            p_parameters => p_batch_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_poc_data_ind;

   FUNCTION get_ref_uom (p_uom_class IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_ref_uom   VARCHAR2 (4);
      l_pos       NUMBER       := 0;
   BEGIN
      l_pos := 1;
      SELECT std_um
        INTO v_ref_uom
        FROM sy_uoms_typ
       WHERE um_type = p_uom_class;
      l_pos := 2;
      RETURN v_ref_uom;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'sy_uoms_typ',
            p_procedure_name => 'get_ref_uom',
            p_parameters => p_uom_class,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_ref_uom;

   FUNCTION get_batchstep_id (p_batch_id IN NUMBER, p_batchstep_no IN NUMBER)
      RETURN NUMBER IS
      v_batchstep_id   NUMBER := 0;
      l_pos            NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT batchstep_id
        INTO v_batchstep_id
        FROM gme_batch_steps
       WHERE batch_id = p_batch_id AND
             batchstep_no = p_batchstep_no;
      l_pos := 2;
      RETURN v_batchstep_id;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_batch_steps',
            p_procedure_name => 'get_batchstep_id',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' batchstep_no = '
                            || p_batchstep_no,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_batchstep_id;

   FUNCTION get_activity_id (
      p_batch_id       IN   NUMBER,
      p_batchstep_no   IN   NUMBER,
      p_activity       IN   VARCHAR2
   )
      RETURN NUMBER IS
      v_activity_id   NUMBER := 0;
      v_step_id       NUMBER := 0;
      l_pos           NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT batchstep_id
        INTO v_step_id
        FROM gme_batch_steps
       WHERE batch_id = p_batch_id AND
             batchstep_no = p_batchstep_no;
      l_pos := 2;
      SELECT batchstep_activity_id
        INTO v_activity_id
        FROM gme_batch_step_activities
       WHERE batch_id = p_batch_id AND
             batchstep_id = v_step_id AND
             activity = p_activity;
      l_pos := 3;
      RETURN v_activity_id;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_batch_steps, gme_batch_step_activities',
            p_procedure_name => 'get_activity_id',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' batchstep_no = '
                            || p_batchstep_no
                            || ' activity = '
                            || p_activity,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_activity_id;

   FUNCTION get_rsrc_offset (
      p_batch_id       IN   pm_btch_hdr_bak.batch_id%TYPE,
      p_batchstep_no   IN   pm_rout_dtl.batchstep_no%TYPE,
      p_activity       IN   pm_oprn_dtl.activity%TYPE,
      p_offset         IN   pm_oprn_dtl.offset_interval%TYPE
   )
      RETURN NUMBER IS
      l_act_offset   NUMBER;
      l_pos          NUMBER := 0;
   BEGIN
      l_pos := 1;
      SELECT offset_interval
        INTO l_act_offset
        FROM gme_batch_step_activities
       WHERE activity = p_activity AND
             batch_id = p_batch_id AND
             batchstep_id = (SELECT batchstep_id
                               FROM gme_batch_steps
                              WHERE batch_id = p_batch_id AND
                                    batchstep_no = p_batchstep_no);
      l_pos := 2;
      RETURN p_offset - l_act_offset;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_batch_step_activities',
            p_procedure_name => 'get_rsrc_offset',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' batchstep_no = '
                            || p_batchstep_no
                            || ' activity = '
                            || p_activity
                            || ' activity offset = '
                            || p_offset,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_rsrc_offset;

   PROCEDURE get_capacity (
      p_batch_id        IN       pm_btch_hdr_bak.batch_id%TYPE,
      p_resources       IN       pm_oprn_dtl.resources%TYPE,
      x_min_capacity    OUT NOCOPY      NUMBER,
      x_max_capacity    OUT NOCOPY      NUMBER,
      x_capacity_uom    OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR get_resource_capacity (
         v_rsrc       pm_oprn_dtl.resources%TYPE,
         v_batch_id   pm_btch_hdr_bak.batch_id%TYPE
      ) IS
         SELECT min_capacity,
                max_capacity,
                capacity_uom
           FROM cr_rsrc_dtl
          WHERE resources = v_rsrc AND
                orgn_code = (SELECT plant_code
                               FROM pm_btch_hdr_bak
                              WHERE batch_id = v_batch_id);

      l_return_status   VARCHAR2 (1);
      l_pos             NUMBER       := 0;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_pos := 1;
      OPEN get_resource_capacity (p_resources, p_batch_id);
      l_pos := 2;
      FETCH get_resource_capacity INTO x_min_capacity,
                                       x_max_capacity,
                                       x_capacity_uom;
      l_pos := 3;

      IF get_resource_capacity%NOTFOUND THEN
         l_pos := 4;

         x_min_capacity := NULL;
         x_max_capacity := NULL;
         x_capacity_uom := NULL;

         l_pos := 5;
      END IF;

      l_pos := 6;

      CLOSE get_resource_capacity;

      l_pos := 7;

      g_resource := p_resources;
      l_pos := 8;
      g_batch_id := p_batch_id;
      l_pos := 9;
      g_min_capacity := x_min_capacity;
      l_pos := 10;
      g_max_capacity := x_max_capacity;
      l_pos := 11;
      g_capacity_uom := x_capacity_uom;

      l_pos := 12;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'cr_rsrc_dtl',
            p_procedure_name => 'get_capacity',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' resource = '
                            || p_resources,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_capacity;

   FUNCTION get_min_capacity (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN NUMBER IS
      l_min_c           NUMBER;
      l_max_c           NUMBER;
      l_cap_uom         VARCHAR2 (4);
      l_return_status   VARCHAR2 (1);
      l_pos             NUMBER       := 0;
   BEGIN
      l_pos := 1;

      IF  p_batch_id = g_batch_id AND
          p_rsrc = g_resource THEN
         l_pos := 2;
         RETURN g_min_capacity;
      ELSE
         l_pos := 3;
         get_capacity (
            p_batch_id,
            p_rsrc,
            l_min_c,
            l_max_c,
            l_cap_uom,
            l_return_status
         );
         l_pos := 4;
         g_resource := p_rsrc;
         l_pos := 5;
         g_batch_id := p_batch_id;
         l_pos := 6;
         g_min_capacity := l_min_c;
         l_pos := 7;
         g_max_capacity := l_max_c;
         l_pos := 8;
         g_capacity_uom := l_cap_uom;
         l_pos := 9;
      END IF;

      l_pos := 10;
      RETURN g_min_capacity;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'get_min_capacity',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' resource = '
                            || p_rsrc,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_min_capacity;

   FUNCTION get_max_capacity (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN NUMBER IS
      l_min_c           NUMBER;
      l_max_c           NUMBER;
      l_cap_uom         VARCHAR2 (4);
      l_return_status   VARCHAR2 (1);
      l_pos             NUMBER       := 0;
   BEGIN
      l_pos := 1;

      IF  p_batch_id = g_batch_id AND
          p_rsrc = g_resource THEN
         l_pos := 2;
         RETURN g_max_capacity;
      ELSE
         l_pos := 3;
         get_capacity (
            p_batch_id,
            p_rsrc,
            l_min_c,
            l_max_c,
            l_cap_uom,
            l_return_status
         );
         l_pos := 4;
         g_resource := p_rsrc;
         l_pos := 5;
         g_batch_id := p_batch_id;
         l_pos := 6;
         g_min_capacity := l_min_c;
         l_pos := 7;
         g_max_capacity := l_max_c;
         l_pos := 8;
         g_capacity_uom := l_cap_uom;
         l_pos := 9;
      END IF;

      l_pos := 10;
      RETURN g_max_capacity;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'get_max_capacity',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' resource = '
                            || p_rsrc,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_max_capacity;

   FUNCTION get_capacity_uom (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN VARCHAR2 IS
      l_min_c           NUMBER;
      l_max_c           NUMBER;
      l_cap_uom         VARCHAR2 (4);
      l_return_status   VARCHAR2 (1);
      l_pos             NUMBER       := 0;
   BEGIN
      l_pos := 1;

      IF  p_batch_id = g_batch_id AND
          p_rsrc = g_resource THEN
         l_pos := 2;
         RETURN g_capacity_uom;
      ELSE
         l_pos := 3;
         get_capacity (
            p_batch_id,
            p_rsrc,
            l_min_c,
            l_max_c,
            l_cap_uom,
            l_return_status
         );
         l_pos := 4;
         g_resource := p_rsrc;
         l_pos := 5;
         g_batch_id := p_batch_id;
         l_pos := 6;
         g_min_capacity := l_min_c;
         l_pos := 7;
         g_max_capacity := l_max_c;
         l_pos := 8;
         g_capacity_uom := l_cap_uom;
         l_pos := 9;
      END IF;

      l_pos := 10;
      RETURN g_capacity_uom;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'get_capacity_uom',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' resource = '
                            || p_rsrc,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_capacity_uom;

   FUNCTION get_actual_qty (
      p_batch_id     IN   NUMBER,
      p_line_id      IN   NUMBER,
      p_actual_qty   IN   NUMBER
   )
      RETURN NUMBER IS
      v_batch_status   NUMBER;
      v_qty            NUMBER;
      v_line_type      pm_matl_dtl_bak.line_type%TYPE;
      v_batch_type     pm_btch_hdr_bak.batch_type%TYPE;
      l_pos            NUMBER                               := 0;
   BEGIN
      l_pos := 1;
      SELECT batch_status, batch_type
        INTO v_batch_status, v_batch_type
        FROM gme_batch_header
       WHERE batch_id = p_batch_id;
      l_pos := 2;

      IF v_batch_status <> 2 OR v_batch_type = 10 THEN
         l_pos := 3;
         RETURN p_actual_qty;
      END IF;

      l_pos := 4;
      SELECT SUM (
                gmicuom.uom_conversion (
                   i.item_id,
                   i.lot_id,
                   i.trans_qty,
                   i.trans_um,
                   l.item_um,
                   0
                )
             )
        INTO v_qty
        FROM ic_tran_pnd i, pm_matl_dtl_bak l
       WHERE doc_id = p_batch_id AND
             doc_type IN ('PROD', 'FPO') AND
             i.line_id = p_line_id AND
             i.line_id = l.line_id AND
             completed_ind = 1 AND
             delete_mark = 0;
      l_pos := 5;

      IF v_qty IS NULL THEN
         l_pos := 6;
         v_qty := 0;
      END IF;

      l_pos := 7;
      SELECT line_type
        INTO v_line_type
        FROM pm_matl_dtl_bak
       WHERE line_id = p_line_id;
      l_pos := 8;

      IF  v_line_type = -1 AND
          v_qty <> 0 THEN
         l_pos := 9;
         v_qty := -1 * v_qty;
      END IF;

      l_pos := 10;
      RETURN v_qty;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'ic_tran_pnd',
            p_procedure_name => 'get_actual_qty',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' line_id = '
                            || p_line_id
                            || ' old actual_qty = '
                            || p_actual_qty,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_actual_qty;

   FUNCTION get_planned_qty (
      p_batch_id   IN   NUMBER,
      p_line_id    IN   NUMBER,
      p_plan_qty   IN   NUMBER
   )
      RETURN NUMBER IS
      v_batch_status   NUMBER;
      v_plant_code     pm_btch_hdr_bak.plant_code%TYPE;
      v_batch_no       pm_btch_hdr_bak.batch_no%TYPE;
      v_batch_type     pm_btch_hdr_bak.batch_type%TYPE;
      v_qty            NUMBER;
      v_line_type      pm_matl_dtl_bak.line_type%TYPE;
      v_line_no        pm_matl_dtl_bak.line_no%TYPE;
      l_pos            NUMBER                               := 0;
      l_line_type_desc VARCHAR2(80);
      l_batch_type_desc VARCHAR2(10);

      plan_qty_null    EXCEPTION;
   BEGIN
      l_pos := 1;
      SELECT batch_status, plant_code, batch_no, batch_type
        INTO v_batch_status, v_plant_code, v_batch_no, v_batch_type
        FROM gme_batch_header
       WHERE batch_id = p_batch_id;
      l_pos := 2;

      IF v_batch_status <> 1 OR v_batch_type = 10 THEN
         RETURN p_plan_qty;
      END IF;

      l_pos := 3;
      SELECT SUM (
                gmicuom.uom_conversion (
                   i.item_id,
                   i.lot_id,
                   i.trans_qty / (1 + l.scrap_factor),
                   i.trans_um,
                   l.item_um,
                   0
                )
             )
        INTO v_qty
        FROM ic_tran_pnd i, pm_matl_dtl_bak l
       WHERE doc_id = p_batch_id AND
             doc_type IN ('PROD', 'FPO') AND
             i.line_id = p_line_id AND
             i.line_id = l.line_id AND
             delete_mark = 0;
      l_pos := 4;

      SELECT line_type, line_no
        INTO v_line_type, v_line_no
        FROM pm_matl_dtl_bak
       WHERE line_id = p_line_id;
      l_pos := 5;

      IF v_qty IS NULL THEN
         IF v_line_type = -1 THEN
            l_line_type_desc := 'ingredient';
         ELSIF v_line_type = 1 THEN
            l_line_type_desc := 'product';
         ELSE
            l_line_type_desc := 'byproduct';
         END IF;

         IF v_batch_type = 0 THEN
            l_batch_type_desc := 'Batch';
         ELSE
            l_batch_type_desc := 'FPO';
         END IF;

         RAISE plan_qty_null;
      END IF;

      IF  v_line_type = -1 AND
          v_qty <> 0 THEN
         l_pos := 6;
         v_qty := -1 * v_qty;
      END IF;

      l_pos := 7;
      RETURN v_qty;
   EXCEPTION
      WHEN plan_qty_null THEN
         insert_message (
            p_table_name => 'ic_tran_pnd',
            p_procedure_name => 'get_planned_qty',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' line_id = '
                            || p_line_id
                            || ' original plan_qty = '
                            || p_plan_qty,
            p_message =>
              'Plan quantity could not be calculated from transactions for '||l_batch_type_desc||
              ' with plant code = '||v_plant_code||'- batch no = '||v_batch_no||
              ' and '||l_line_type_desc||' line no = '||v_line_no||'. Using original plan_qty.',
            p_error_type => 'I'
         );
         RETURN p_plan_qty;
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'ic_tran_pnd',
            p_procedure_name => 'get_planned_qty',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' line_id = '
                            || p_line_id
                            || ' original plan_qty = '
                            || p_plan_qty,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_planned_qty;

   FUNCTION get_wip_planned_qty (
      p_batch_id     IN   NUMBER,
      p_line_id      IN   NUMBER,
      p_actual_qty   IN   NUMBER
   )
      RETURN NUMBER IS
      v_batch_status   NUMBER;
      v_qty            NUMBER;
      v_line_type      pm_matl_dtl_bak.line_type%TYPE;
      v_scrap_factor   pm_matl_dtl_bak.scrap_factor%TYPE;
      v_item_um        pm_matl_dtl_bak.item_um%TYPE;
      l_pos            NUMBER                                  := 0;
   BEGIN
      l_pos := 1;
      SELECT batch_status
        INTO v_batch_status
        FROM gme_batch_header
       WHERE batch_id = p_batch_id;
      l_pos := 2;

      IF v_batch_status = -1 /* Cancelled */ OR
         v_batch_status = 1 /* Pending */ THEN
         l_pos := 3;
         RETURN NULL;
      END IF;

      l_pos := 4;
      SELECT scrap_factor,
             item_um,
             line_type
        INTO v_scrap_factor,
             v_item_um,
             v_line_type
        FROM pm_matl_dtl_bak
       WHERE line_id = p_line_id;
      l_pos := 5;

      IF v_batch_status = 3 /* Certified */ OR
         v_batch_status = 4 /* Closed */ THEN
         l_pos := 6;
         v_qty := p_actual_qty / (1 + v_scrap_factor);
         RETURN v_qty;
      END IF;

      l_pos := 7;
      SELECT SUM (
                gmicuom.uom_conversion (
                   item_id,
                   lot_id,
                   trans_qty / (1 + v_scrap_factor),
                   trans_um,
                   v_item_um,
                   0
                )
             )
        INTO v_qty
        FROM ic_tran_pnd
       WHERE doc_id = p_batch_id AND
             doc_type IN ('PROD', 'FPO') AND
             line_id = p_line_id AND
             delete_mark = 0;
      l_pos := 8;

      IF  v_line_type = -1 AND
          v_qty <> 0 THEN
         l_pos := 9;
         v_qty := -1 * v_qty;
      END IF;

      l_pos := 10;
      RETURN v_qty;
   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'ic_tran_pnd',
            p_procedure_name => 'get_wip_planned_qty',
            p_parameters =>    'batch_id = '
                            || p_batch_id
                            || ' line_id = '
                            || p_line_id
                            || ' old actual_qty = '
                            || p_actual_qty,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END get_wip_planned_qty;

   PROCEDURE check_wip_batches (
      x_return_status            OUT NOCOPY      VARCHAR2,
      p_reverse_compl_def_txns   IN       BOOLEAN DEFAULT FALSE
   ) IS
      /* Local variables */
      l_batch_header            pm_btch_hdr_bak%ROWTYPE;
      l_return_status           VARCHAR2 (1);
      l_trans_is_reversed       NUMBER;
      l_is_plain                BOOLEAN;
      l_def_lot_id              ic_tran_pnd.trans_id%TYPE;
      l_completed_ind           ic_tran_pnd.completed_ind%TYPE;
      l_trans_qty               ic_tran_pnd.trans_qty%TYPE;
      l_ic_tran_cmp_out         ic_tran_cmp%ROWTYPE;
      l_ic_tran_pnd_out         ic_tran_pnd%ROWTYPE;
      l_tran_row                ic_tran_pnd%ROWTYPE;
      l_tran_reverse            gmi_trans_engine_pub.ictran_rec;
      l_tran_pending            gmi_trans_engine_pub.ictran_rec;
      l_lock_status             BOOLEAN;
      l_reversible              BOOLEAN;
      l_reversal_count          NUMBER                           := 0;
      l_line_type_desc          VARCHAR2 (20);
      l_pos                     NUMBER                           := 0;
      l_msg_data                VARCHAR2 (2000);
      l_message                 VARCHAR2 (2000);
      l_msg_count               NUMBER;
      l_load_trans_fail         BOOLEAN;
      error_create_tran         EXCEPTION;
      error_inserting_txn       EXCEPTION;
      error_build_ic_tran_row   EXCEPTION;

      /* Cursor definitions */
      CURSOR cur_get_batches IS
         SELECT   h.batch_id,
                  h.plant_code,
                  h.batch_type,
                  h.batch_no,
                  d.line_no,
                  d.line_id
             FROM pm_btch_hdr_bak h, pm_matl_dtl_bak d
            WHERE h.batch_status = 2 AND
                  d.batch_id = h.batch_id AND
                  d.line_type IN (-1, 1) AND
                  d.in_use <
                        100 -- => ensure you only get those materials that were not migrated.
         ORDER BY h.plant_code, h.batch_type, h.batch_no, d.line_no;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_pos := 1;

      IF g_mig_date IS NULL THEN
         g_mig_date := SYSDATE;
      END IF;

      l_pos := 2;

      -- Retrieve all ingredients and products for wip batches
      -- NOTE: we must check the products because there could be a phantom product corresponding to an
      -- auto release phantom ingredient which will have a completed default txn.
      FOR get_rec IN cur_get_batches
      LOOP
         l_pos := 3;
         l_batch_header.batch_id := get_rec.batch_id;
         load_trans (l_batch_header, l_return_status);

         IF l_return_status <> x_return_status THEN
            l_load_trans_fail := TRUE;
            l_def_lot_id := NULL;

            insert_message (
               p_table_name => 'gme_inventory_txns_gtmp/ic_tran_pnd',
               p_procedure_name => 'check_wip_batches',
               p_parameters =>    'batch_id = '
                               || l_batch_header.batch_id
                               || ' line_id = '
                               || get_rec.line_id,
               p_message => 'Unable to load the transactions',
               p_error_type => FND_API.G_RET_STS_ERROR
            );
         ELSE
            l_load_trans_fail := FALSE;
            l_pos := 4;
            get_default_lot (
               get_rec.line_id,
               l_def_lot_id,
               l_is_plain,
               l_return_status
            );
         END IF;

         l_pos := 5;

         IF l_def_lot_id IS NULL OR
            l_return_status <> x_return_status THEN
            l_pos := 6;
            -- No need to write message if the load trans failed, because message
            -- for that was already written, and if load_trans failed, it follows that def lot
            -- could not be found.
            IF l_load_trans_fail = FALSE THEN
               insert_message (
                  p_table_name => 'gme_inventory_txns_gtmp/ic_tran_pnd',
                  p_procedure_name => 'check_wip_batches',
                  p_parameters =>    'batch_id = '
                                  || l_batch_header.batch_id
                                  || ' line_id = '
                                  || get_rec.line_id,
                  p_message => 'Unable to determine the default lot.',
                  p_error_type => FND_API.G_RET_STS_ERROR
               );
            END IF;
         ELSE
            l_pos := 7;
            SELECT completed_ind,
                   trans_qty
              INTO l_completed_ind,
                   l_trans_qty
              FROM ic_tran_pnd
             WHERE trans_id = l_def_lot_id;
            l_pos := 8;

            IF (l_is_plain = TRUE OR
                l_completed_ind = 0 OR
                l_trans_qty = 0
               ) THEN
               l_pos := 9;
               /* skip it
                  1. if it's plain, it'll be dealt with later; i.e the def trans will be split if necessary
                  2. if it's not completed, we don't care about it here
                  3. if the trans_qty is 0 and it's completed, that will be un-completed later
                  Items 1 and 3 will both be dealt with in split_trans_line... */
               NULL;
            ELSE
               l_pos := 10;

               IF p_reverse_compl_def_txns THEN
                  /* Let's reverse the completed transaction and create a pending transaction for the same qty. */
                  SELECT *
                    INTO l_tran_row
                    FROM ic_tran_pnd
                   WHERE trans_id = l_def_lot_id;

                  /* The cursor is only retrieving ingredients and products (only phantom products will ever   */
                  /* fall into this because phantom products are the only products that can be completed       */
                  /* in a WIP state.   */
                  IF l_tran_row.line_type = -1 THEN
                     l_line_type_desc := 'ingredient';
                  ELSE
                     l_line_type_desc := 'product';
                  END IF;

                  l_pos := 11;
                  -- Set the USER_ID for each transaction reversed.  This is required for the inventory API
                  fnd_profile.put ('USER_ID', TO_CHAR (l_tran_row.created_by));
                  l_pos := 12;

                  -- Bug 3372169 Changed call lock_inventory procedure to pass parameters by name.
                  gmi_locks.lock_inventory (
                     i_item_id     => l_tran_row.item_id,
                     i_whse_code   => l_tran_row.whse_code,
                     i_lot_id      => l_tran_row.lot_id,
                     i_location    => l_tran_row.location,
                     o_lock_status => l_lock_status
                  );

                  l_pos := 13;

                  IF l_lock_status OR
                     l_lock_status IS NULL THEN
                     build_gmi_trans (
                        p_ic_tran_row => l_tran_row,
                        x_tran_row => l_tran_reverse,
                        x_return_status => l_return_status
                     );

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE error_build_ic_tran_row;
                     END IF;

                     -- Check that the trans_date is in an open calendar period and whse.
                     IF (gmiccal.trans_date_validate (
                            trans_date => l_tran_reverse.trans_date,
                            porgn_code => l_tran_reverse.orgn_code,
                            pwhse_code => l_tran_reverse.whse_code
                         ) <> 0
                        ) THEN
                        IF (gmiccal.trans_date_validate (
                               trans_date => g_mig_date,
                               porgn_code => l_tran_reverse.orgn_code,
                               pwhse_code => l_tran_reverse.whse_code
                            ) <> 0
                           ) THEN
                           l_reversible := FALSE;
                           l_message :=    'Cannot reverse trans_id '
                                        || l_tran_row.trans_id
                                        || ' '
                                        || 'with trans date '
                                        || TO_CHAR (
                                              l_tran_reverse.trans_date,
                                              g_date_format
                                           )
                                        || ' '
                                        || 'and system date '
                                        || TO_CHAR (
                                              g_mig_date,
                                             g_date_format
                                           );
                           insert_message (
                              p_table_name => 'IC_TRAN_PND',
                              p_procedure_name => 'CHECK_WIP_BATCHES',
                              p_parameters =>    'Batch_Id=>'
                                              || TO_CHAR (get_rec.batch_id),
                              p_message => l_message,
                              p_error_type => FND_API.G_RET_STS_ERROR
                           );
                        ELSE
                           l_reversible := TRUE;
                           l_message :=
                                    'Cannot reverse trans_id '
                                 || l_tran_row.trans_id
                                 || ' '
                                 || 'with trans date '
                                 || TO_CHAR (
                                       l_tran_reverse.trans_date,
                                       g_date_format
                                    )
                                 || '. '
                                 || 'Using system date '
                                 || TO_CHAR (
                                       g_mig_date,
                                       g_date_format
                                    )
                                 || ' for the reversal of this transaction';
                           /* B2417758 Moved this line from the statemet above
                              So that the message will have the correct date */
                           l_tran_reverse.trans_date := g_mig_date;
                           insert_message (
                              p_table_name => 'IC_TRAN_PND',
                              p_procedure_name => 'CHECK_WIP_BATCHES',
                              p_parameters =>    'Batch_Id=>'
                                              || TO_CHAR (get_rec.batch_id),
                              p_message => l_message,
                              p_error_type => 'I'
                           );
                        END IF;
                     ELSE
                        -- trans_date_validate returned 0 for trans_date, so we can use the trans_date to reverse
                        l_reversible := TRUE;
                     END IF;

                     IF l_reversible THEN
                        -- Reverse Out The Amount and Re-Post
                        l_tran_reverse.trans_qty :=
                                                -1 * l_tran_reverse.trans_qty;
                        l_tran_reverse.trans_qty2 :=
                                               -1 * l_tran_reverse.trans_qty2;
                        gmi_trans_engine_pub.create_completed_transaction (
                           p_api_version => 1,
                           p_init_msg_list => FND_API.g_false,
                           p_commit => FND_API.g_false,
                           p_validation_level => FND_API.g_valid_level_full,
                           p_tran_rec => l_tran_reverse,
                           x_tran_row => l_ic_tran_cmp_out,
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data => l_msg_data,
                           p_table_name => 'IC_TRAN_PND'
                        );

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

--dbms_output.put_line (fnd_msg_pub.get (p_encoded => FND_API.g_false));

                           l_message :=
                                    'Error creating reversing transaction for trans_id '
                                 || l_tran_row.trans_id
                                 || ' in batch no '
                                 || get_rec.batch_no
                                 || ' in plant '
                                 || get_rec.plant_code
                                 || ' for '
                                 || l_line_type_desc
                                 || ' line number '
                                 || get_rec.line_no;

                           IF l_msg_count > 0 THEN
                              l_message :=
                                       l_message
                                    || ' with following error:  '
                                    || fnd_msg_pub.get (
                                          p_encoded => FND_API.g_false
                                       );
                           END IF;

                           l_return_status := FND_API.G_RET_STS_ERROR;
                           insert_message (
                              p_table_name => 'IC_TRAN_PND',
                              p_procedure_name => 'CHECK_WIP_BATCHES',
                              p_parameters =>    'Batch_Id=>'
                                              || TO_CHAR (get_rec.batch_id)
					      || ' line_id=>'
					      || TO_CHAR (get_rec.line_id)
					      || ' trans_id=>'
					      || TO_CHAR(l_tran_row.trans_id),
                              p_message => l_message,
                              p_error_type => l_return_status
                           );
                           RAISE error_create_tran;
                        END IF;

                        insert_inv_txns_gtmp (
                           p_batch_id => l_ic_tran_cmp_out.doc_id,
                           p_doc_type => l_ic_tran_cmp_out.doc_type,
                           p_trans_id => l_ic_tran_cmp_out.trans_id,
                           x_return_status => l_return_status
                        );

                        IF l_return_status <> x_return_status THEN
                           RAISE error_inserting_txn;
                        END IF;

                        /* Create corresponding pending transaction  */
                        build_gmi_trans (
                           p_ic_tran_row => l_tran_row,
                           x_tran_row => l_tran_pending,
                           x_return_status => l_return_status
                        );

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE error_build_ic_tran_row;
                        END IF;

                        -- Stamp the pending transaction with sysdate if it was determined that trans_date is not usable
                        IF l_tran_reverse.trans_date = g_mig_date THEN
                           l_tran_pending.trans_date := g_mig_date;
                        END IF;

                        /* Insert a pending transaction  */

                        gmi_trans_engine_pub.create_pending_transaction (
                           1,
                           FND_API.g_false,
                           FND_API.g_false,
                           FND_API.g_valid_level_full,
                           l_tran_pending,
                           l_ic_tran_pnd_out,
                           l_return_status,
                           l_msg_count,
                           l_msg_data
                        );

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           l_message :=
                                    'Error creating pending transaction for trans_id '
                                 || l_tran_row.trans_id
                                 || ' in batch no '
                                 || get_rec.batch_no
                                 || ' in plant '
                                 || get_rec.plant_code
                                 || ' for '
                                 || l_line_type_desc
                                 || ' line number '
                                 || get_rec.line_no;

                           IF l_msg_count > 0 THEN
                              l_message :=
                                       l_message
                                    || ' with following error:  '
                                    || fnd_msg_pub.get (
                                          p_encoded => FND_API.g_false
                                       );
                           END IF;

                           l_return_status := FND_API.G_RET_STS_ERROR;
                           insert_message (
                              p_table_name => 'IC_TRAN_PND',
                              p_procedure_name => 'CHECK_WIP_BATCHES',
                              p_parameters =>    'Batch_Id=>'
                                              || TO_CHAR (get_rec.batch_id)
															 || ' line_id=>'
															 || TO_CHAR (get_rec.line_id)
															 || ' trans_id=>'
															 || TO_CHAR(l_tran_row.trans_id),
                              p_message => l_message,
                              p_error_type => l_return_status
                           );
                           RAISE error_create_tran;
                        END IF;

                        insert_inv_txns_gtmp (
                           p_batch_id => l_ic_tran_pnd_out.doc_id,
                           p_doc_type => l_ic_tran_pnd_out.doc_type,
                           p_trans_id => l_ic_tran_pnd_out.trans_id,
                           x_return_status => l_return_status
                        );

                        IF l_return_status <> x_return_status THEN
                           RAISE error_inserting_txn;
                        END IF;

                        /* Now let's indicate in the temporary table about the reversals */
                        UPDATE gme_inventory_txns_gtmp
                           SET transaction_no = 2
                         WHERE trans_id IN
                                   (l_def_lot_id, l_ic_tran_cmp_out.trans_id);
                     END IF;   /* IF l_reversible THEN */
                  ELSE
                     l_message :=
                              'Unable to lock inventory tables for trans_id '
                           || l_tran_row.trans_id
                           || ' in batch no '
                           || get_rec.batch_no
                           || ' in plant '
                           || get_rec.plant_code
                           || ' for '
                           || l_line_type_desc
                           || ' line number '
                           || get_rec.line_no;
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     insert_message (
                        p_table_name => 'IC_TRAN_PND',
                        p_procedure_name => 'CHECK_WIP_BATCHES',
                        p_parameters =>    'Batch_Id=>'
                                        || TO_CHAR (get_rec.batch_id),
                        p_message => l_message,
                        p_error_type => l_return_status
                     );
                     RAISE error_create_tran;
                  END IF;   /* IF l_lock_status OR */
               END IF;   /* IF p_reverse_compl_def_txns THEN */

               insert_message (
                  p_table_name => 'IC_TRAN_PND',
                  p_procedure_name => 'CHECK_WIP_BATCHES',
                  p_parameters => 'Batch_Id=>' || TO_CHAR (get_rec.batch_id),
                  p_message =>    'Completed default lot transaction found for batch '
                               || get_rec.batch_no
                               || ' in plant '
                               || get_rec.plant_code
                               || ' for '
                               || l_line_type_desc
                               || ' line number '
                               || get_rec.line_no,
                  p_error_type => 'I'
               );
               l_reversal_count := l_reversal_count + 1;
            END IF;   /* IF (l_is_plain = TRUE OR */
         END IF;   /* IF l_def_lot_id IS NULL OR l_return_status ... */
      END LOOP;

      insert_message (
         p_table_name => 'ic_tran_pnd',
         p_procedure_name => 'check_wip_batches',
         p_parameters => 'none',
         p_message => 'number of transactions reversed = ' || l_reversal_count,
         p_error_type => 'P'
      );
   EXCEPTION
      WHEN error_create_tran OR error_build_ic_tran_row OR error_inserting_txn THEN
         x_return_status := l_return_status;
         RAISE;
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'IC_TRAN_PND',
            p_procedure_name => 'CHECK_WIP_BATCHES',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => 'D'
         );
         RAISE;
   END check_wip_batches;

   PROCEDURE build_gmi_trans (
      p_ic_tran_row     IN       ic_tran_pnd%ROWTYPE,
      x_tran_row        OUT NOCOPY      gmi_trans_engine_pub.ictran_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name   CONSTANT VARCHAR2 (30)                   := 'BUILD_GMI_TRANS';
      l_return_status       VARCHAR2 (1)               := FND_API.G_RET_STS_SUCCESS;
      l_tran_row            gmi_trans_engine_pub.ictran_rec;
   BEGIN
      -- The trans_um,trans_um will Should always be in the Items Base
      -- Units of measure. No Conversions are done in this routine.
      -- Assumes all IN data is correct.


      -- Lets Populate Inventory TRAN Row
      --gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Build INV tran Row');
      l_tran_row.trans_um := p_ic_tran_row.trans_um;
      l_tran_row.trans_qty := p_ic_tran_row.trans_qty;
      l_tran_row.trans_um2 := p_ic_tran_row.trans_um2;
      l_tran_row.trans_qty2 := p_ic_tran_row.trans_qty2;
      l_tran_row.item_id := p_ic_tran_row.item_id;
      l_tran_row.line_id := p_ic_tran_row.line_id;
      l_tran_row.co_code := p_ic_tran_row.co_code;
      l_tran_row.orgn_code := p_ic_tran_row.orgn_code;
      l_tran_row.whse_code := p_ic_tran_row.whse_code;
      l_tran_row.lot_id := NVL (p_ic_tran_row.lot_id, 0);
      l_tran_row.location := NVL (p_ic_tran_row.location, p_default_loct);
      l_tran_row.doc_id := p_ic_tran_row.doc_id;
      l_tran_row.doc_type := p_ic_tran_row.doc_type;
      l_tran_row.doc_line := p_ic_tran_row.doc_line;
      l_tran_row.line_type := p_ic_tran_row.line_type;
      l_tran_row.reason_code := p_ic_tran_row.reason_code;
      l_tran_row.trans_date := p_ic_tran_row.trans_date;
      l_tran_row.qc_grade := p_ic_tran_row.qc_grade;
      l_tran_row.lot_status := p_ic_tran_row.lot_status;
      l_tran_row.trans_stat := p_ic_tran_row.trans_stat;
      l_tran_row.event_id := p_ic_tran_row.event_id;
      l_tran_row.staged_ind := NVL (p_ic_tran_row.staged_ind, 0);
      l_tran_row.text_code := p_ic_tran_row.text_code;
      l_tran_row.user_id := TO_NUMBER (fnd_profile.VALUE ('USER_ID'));
      x_return_status := l_return_status;
      x_tran_row := l_tran_row;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'IC_TRAN_PND',
            p_procedure_name => 'BUILD_GMI_TRANS',
            p_parameters =>    'Batch_Id=>'
                            || TO_CHAR (p_ic_tran_row.doc_id)
                            || 'Trans ID=>'
                            || TO_CHAR (p_ic_tran_row.trans_id),
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END build_gmi_trans;

   FUNCTION is_GME_validated RETURN BOOLEAN IS
      l_table_name		VARCHAR2(50) := 'GME_validation';
   BEGIN

      RETURN TRUE;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_migration_control',
            p_procedure_name => 'is_GME_validated',
            p_parameters => l_table_name,
            p_message => SQLERRM,
            p_error_type => 'D'
         );
         RAISE;
   END is_GME_validated;

   PROCEDURE set_GME_validated IS
      l_pos   NUMBER := 0;
      l_table_name      VARCHAR2(50) := 'GME_validation';

   BEGIN
      l_pos := 1;

      UPDATE gme_migration_control
         SET migrated_ind = 'Y',
             last_update_date = g_mig_date
       WHERE table_name = l_table_name;

      l_pos := 2;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_migration_control',
            p_procedure_name => 'set_GME_validated',
            p_parameters => l_table_name,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END set_GME_validated;

   PROCEDURE reset_GME_validated IS
      l_mig_ind         VARCHAR2(1);
      l_pos             NUMBER := 0;

		l_table_name      VARCHAR2(50) := 'GME_validation';

      CURSOR cur_check_control (v_table_name VARCHAR2) IS
         SELECT migrated_ind
           FROM gme_migration_control
          WHERE table_name = v_table_name;

   BEGIN

      l_pos := 1;
      OPEN cur_check_control (l_table_name);
      l_pos := 2;
      FETCH cur_check_control INTO l_mig_ind;
      l_pos := 3;

      IF cur_check_control%NOTFOUND THEN
         INSERT INTO gme_migration_control
                     (table_name,
                      migrated_ind,
                      last_update_date
                     )
              VALUES (l_table_name,
                      'N',
                      g_mig_date
                     );

         l_pos := 4;
		ELSE
	      UPDATE gme_migration_control
         	SET migrated_ind = 'N',
             	last_update_date = g_mig_date
       	WHERE table_name = l_table_name;
      END IF;

      l_pos := 5;
      CLOSE cur_check_control;
      l_pos := 6;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_migration_control',
            p_procedure_name => 'reset_GME_validated',
            p_parameters => l_table_name,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END reset_GME_validated;

   FUNCTION is_table_migrated (p_table_name IN VARCHAR2)
      RETURN BOOLEAN IS
      l_mig_ind         VARCHAR2(1);
      l_pos             NUMBER := 0;



      CURSOR cur_check_control (v_table_name VARCHAR2) IS
         SELECT migrated_ind
           FROM gme_migration_control
          WHERE table_name = v_table_name;

   BEGIN

      l_pos := 1;
      OPEN cur_check_control (p_table_name);
      l_pos := 2;
      FETCH cur_check_control INTO l_mig_ind;
      l_pos := 3;

      IF cur_check_control%NOTFOUND THEN
         INSERT INTO gme_migration_control
                     (table_name,
                      migrated_ind,
                      last_update_date
                     )
              VALUES (p_table_name,
                      'N',
                      g_mig_date
                     );

         l_pos := 4;
         RETURN FALSE;
      END IF;

      l_pos := 5;
      CLOSE cur_check_control;
      l_pos := 6;

      IF l_mig_ind = 'Y' THEN
         l_pos := 7;
         RETURN TRUE;
      ELSE
         l_pos := 8;
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_migration_control',
            p_procedure_name => 'is_table_migrated',
            p_parameters => p_table_name,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END is_table_migrated;

   PROCEDURE set_table_migrated (
      p_table_name      IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_pos   NUMBER := 0;
   BEGIN
      /* NOTE: this assumes that a record already exists in gme_migration_control
         for p_table_name.  This is because in is_table_migrated, if the record is
         not found, it is created.  And since is_table_migrated is always called before
         this procedure, we can assume that the record is there. */

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_pos := 1;

      UPDATE gme_migration_control
         SET migrated_ind = 'Y',
             last_update_date = g_mig_date
       WHERE table_name = p_table_name;

      l_pos := 2;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_migration_control',
            p_procedure_name => 'set_table_migrated',
            p_parameters => p_table_name,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END set_table_migrated;

   PROCEDURE tablespace_check(
      p_User         IN VARCHAR2,
      p_pct_free     IN NUMBER) IS

      l_pos                  NUMBER := 0;

      l_tablespace_name      VARCHAR2(50);

      l_total_space          NUMBER(12);
      l_free_space           NUMBER(12);
      l_pct_free             NUMBER(6,3);

      CURSOR cur_get_tablespace_name(v_User VARCHAR2) IS
         SELECT default_tablespace tablespace_name
         FROM   dba_users
         WHERE  username like v_User
            UNION
         SELECT distinct tablespace_name
         FROM   all_tables
         WHERE  owner like v_User;

      l_cur_ts_name   cur_get_tablespace_name%ROWTYPE;

   BEGIN
      l_pos := 1;

      OPEN cur_get_tablespace_name(p_User);

      l_pos := 2;

      FETCH cur_get_tablespace_name INTO l_cur_ts_name;

      l_pos := 3;

      WHILE cur_get_tablespace_name%FOUND LOOP

         l_pos := 3.1;

         --
         -- Get the total space for the current tablespace
         --
         SELECT sum(bytes) into l_total_space
         FROM   dba_data_files
         WHERE  TABLESPACE_NAME = l_cur_ts_name.tablespace_name;
         --
         -- Get the free space for the current tablespace
         --

         l_pos := 3.2;

         SELECT sum(bytes) into l_free_space
         FROM   dba_free_space
         WHERE  TABLESPACE_NAME = l_cur_ts_name.tablespace_name;

         l_pos := 3.3;

         --
         -- calculate the percent free for the current tablespace
         --
         l_pct_free := (l_free_space / l_total_space) * 100;

         l_pos := 3.4;

         -- Validate that the percent free is sufficient
         IF l_pct_free < p_pct_free THEN
            insert_message (
               p_table_name => 'none',
               p_procedure_name => 'tablespace_check',
               p_parameters => 'USER= '||p_User||
                               ' tablespace name= '||l_cur_ts_name.tablespace_name||
                               ' total space= '||to_char(l_total_space)||' bytes'||
                               ' free space= '||to_char(l_free_space)||' bytes'||
                               ' target minimum % free= '||to_char(p_pct_free)||
                               ' actual % free= '||to_char(l_pct_free),
               p_message => 'Tablespace information',
               p_error_type => 'I'
            );
         END IF;

         l_pos := 3.5;

         FETCH cur_get_tablespace_name INTO l_cur_ts_name;

         l_pos := 3.6;

      END LOOP;

      l_pos := 4;

      CLOSE cur_get_tablespace_name;

      l_pos := 5;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'tablespace_check',
            p_parameters => '',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
         RAISE;
   END tablespace_check;

   FUNCTION GME_data_exists RETURN BOOLEAN IS

      CURSOR cur_num_batches IS
      SELECT count(1)
      FROM   pm_btch_hdr_bak;

      l_num_batches NUMBER;
      l_pos         NUMBER;
   BEGIN
      l_pos := 1;
      OPEN cur_num_batches;
      l_pos := 2;
      FETCH cur_num_batches INTO l_num_batches;
      l_pos := 3;
      CLOSE cur_num_batches;
      l_pos := 4;

      IF l_num_batches > 0 THEN
         l_pos := 4.1;
         RETURN TRUE;
      ELSE
         l_pos := 4.2;
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'GME_data_exists',
            p_parameters => '',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
   END GME_data_exists;

   PROCEDURE run (p_commit IN BOOLEAN DEFAULT FALSE) IS
      l_pos             NUMBER         := 0;
      l_message         VARCHAR2 (2000);
      l_return_status   VARCHAR2 (1);
      l_commit_text     VARCHAR2 (10);
      error_detail      EXCEPTION;
      ERROR_NO_VALIDATION EXCEPTION;
      GME_NO_DATA         EXCEPTION;
   BEGIN

      l_pos := 0.5;

      initialize_migration;

      IF p_commit THEN
         l_commit_text := 'TRUE';
      ELSE
         l_commit_text := 'FALSE';
      END IF;

      IF GME_data_exists THEN
         NULL;
      ELSE
         RAISE GME_NO_DATA;
      END IF;

      tablespace_check(p_User => g_tablespace_User, p_pct_free => g_tablespace_target_free);

      l_pos := 1;

      IF p_commit THEN
         IF is_GME_validated THEN
            NULL;
         ELSE
            RAISE ERROR_NO_VALIDATION;
         END IF;
      ELSE
         insert_message (
            p_table_name => NULL,
            p_procedure_name => 'reset_GME_validated',
            p_parameters => NULL,
            p_message => NULL,
            p_error_type => 'V'	-- validation control
         );
      END IF;

      insert_message (
         p_table_name => 'none',
         p_procedure_name => 'run',
         p_parameters => 'p_commit = '||l_commit_text,
         p_message => 'Procedure has started',
         p_error_type => 'P'
      );

      IF (is_table_migrated (p_table_name => 'UNLOCK_ALL') = FALSE) THEN
         l_pos := 1.010;
         unlock_all;
         l_pos := 1.011;

         set_table_migrated (
            p_table_name => 'UNLOCK_ALL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'DEL_STEP_DTL') = FALSE) THEN
         l_pos := 1.020;
         del_step_dtl_for_del_steps;
         l_pos := 1.021;

         set_table_migrated (
            p_table_name => 'DEL_STEP_DTL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'DUPLICATE_LINE_NO') = FALSE) THEN
         l_pos := 1.1;
			renumber_duplicate_line_no;
         l_pos := 1.2;

         set_table_migrated (
            p_table_name => 'DUPLICATE_LINE_NO',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_BTCH_HDR') = FALSE) THEN
         l_pos := 2;
         insert_batch_header (x_return_status => l_return_status);
         l_pos := 3;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_BTCH_HDR',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'IC_TRAN_PND_WIP') = FALSE) THEN
         l_pos := 4;
         -- check_wip_batches must be before insert_material_details because it only checks those
         -- materials that have not been migrated
         check_wip_batches (
            x_return_status => l_return_status,
            p_reverse_compl_def_txns => TRUE
         );
         l_pos := 5;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'IC_TRAN_PND_WIP',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_MATL_DTL') = FALSE) THEN
         l_pos := 6;
         insert_material_details (x_return_status => l_return_status);
         l_pos := 7;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_MATL_DTL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_ROUT_DTL') = FALSE) THEN
         l_pos := 8;
         insert_batch_steps (x_return_status => l_return_status);
         l_pos := 9;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_ROUT_DTL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_OPRN_DTL') = FALSE) THEN
         l_pos := 10;
         insert_batch_step_dtls (x_return_status => l_return_status);
         l_pos := 11;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_OPRN_DTL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_ROUT_MTL') = FALSE) THEN
         l_pos := 12;
         insert_batch_step_items (x_return_status => l_return_status);
         l_pos := 13;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_ROUT_MTL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_ROUT_DEP') = FALSE) THEN
         l_pos := 14;
         insert_batch_step_dependencies (x_return_status => l_return_status);
         l_pos := 15;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_ROUT_DEP',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_HIST_HDR') = FALSE) THEN
         l_pos := 16;
         insert_batch_history (x_return_status => l_return_status);
         l_pos := 17;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_HIST_HDR',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_OPRN_WIP') = FALSE) THEN
         l_pos := 18;
         insert_batch_step_transfers (x_return_status => l_return_status);
         l_pos := 19;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_OPRN_WIP',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_TEXT_HDR_PC_TEXT_HDR') =
                                                                         FALSE
         ) THEN
         l_pos := 20;
         insert_text_header (x_return_status => l_return_status);
         l_pos := 21;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_TEXT_HDR_PC_TEXT_HDR',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'PM_TEXT_TBL_TL_PC_TEXT_TBL_TL') =
                                                                         FALSE
         ) THEN
         l_pos := 22;
         insert_text_dtl (x_return_status => l_return_status);
         l_pos := 23;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_detail;
         END IF;

         set_table_migrated (
            p_table_name => 'PM_TEXT_TBL_TL_PC_TEXT_TBL_TL',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF (is_table_migrated (p_table_name => 'BLANK_LINE_NO') = FALSE) THEN
         l_pos := 25.1;
			renumber_blank_line_no;
         l_pos := 25.2;

         set_table_migrated (
            p_table_name => 'BLANK_LINE_NO',
            x_return_status => l_return_status
         );

         IF p_commit THEN
            COMMIT;
         END IF;
      END IF;

      IF NOT p_commit THEN
         ROLLBACK;

      	insert_message (
         	p_table_name => NULL,
         	p_procedure_name => 'set_GME_validated',
         	p_parameters => NULL,
         	p_message => NULL,
         	p_error_type => 'V'  -- validation control
      	);
      END IF;

      insert_message (
         p_table_name => 'none',
         p_procedure_name => 'run',
         p_parameters => 'p_commit = '||l_commit_text,
         p_message => 'Procedure has ended',
         p_error_type => 'P'
      );

      l_pos := 26;
   EXCEPTION
      WHEN GME_NO_DATA THEN
         IF p_commit THEN
            l_message := 'migration';
         ELSE
            l_message := 'validation';
         END IF;

         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'run',
            p_parameters => 'p_commit = ' || l_commit_text,
            p_message => 'GME '||l_message||' found no data.',
            p_error_type => 'I'
         );
      WHEN error_detail THEN
         ROLLBACK;
         RAISE;
      WHEN ERROR_NO_VALIDATION THEN
         ROLLBACK;
         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'run',
            p_parameters => 'p_commit = ' || l_commit_text,
            p_message => 'Validation must be successfully run prior to running migration.',
            p_error_type => 'D'
         );
         RAISE;
      WHEN OTHERS THEN
         IF p_commit THEN
            l_message :=
                     ' Note: migrate_batch.run was called with commit on so any commits prior to pos = '
                  || l_pos
                  || ' has occurred';
         END IF;

         insert_message (
            p_table_name => 'none',
            p_procedure_name => 'run',
            p_parameters => 'p_commit = ' || l_commit_text,
            p_message => SQLERRM || ' with pos = ' || l_pos || l_message,
            p_error_type => 'D'
         );
         ROLLBACK;
         RAISE;
   END run;

   PROCEDURE insert_batch_header (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_batch_header
                  (batch_id,
                   plant_code,
                   batch_no,
                   batch_type,
                   prod_id,
                   prod_sequence,
                   recipe_validity_rule_id,
                   formula_id,
                   routing_id,
                   plan_start_date,
                   actual_start_date,
                   due_date,
                   plan_cmplt_date,
                   actual_cmplt_date,
                   batch_status,
                   priority_value,
                   priority_code,
                   print_count,
                   fmcontrol_class,
                   wip_whse_code,
                   batch_close_date,
                   poc_ind,
                   actual_cost_ind,
                   gl_posted_ind,
                   update_inventory_ind,
                   automatic_step_calculation,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   delete_mark,
                   text_code,
                   parentline_id,
                   fpo_id,
                   migrated_batch_ind,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category
                  )
         SELECT batch_id,
                plant_code,
                batch_no,
                batch_type,
                prod_id,
                prod_sequence,
                fmeff_id,
                formula_id,
                routing_id,
                plan_start_date,
                get_actual_date (actual_start_date),
                due_date,
                expct_cmplt_date,
                get_actual_date (actual_cmplt_date),
                batch_status,
                priority_value,
                priority_code,
                print_count,
                fmcontrol_class,
                wip_whse_code,
                get_actual_date (batch_close_date),
                get_poc_data_ind (batch_id),
                get_actual_cost_ind (batch_id),
                get_gl_posted_ind (batch_id),
                'Y' --update_inventory_ind => lab batches introduced in 11I+
                   ,
                0 --automatic_step_calculation
                 ,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                delete_mark,
                text_code,
                parentline_id,
                NULL --fpo_id
                    ,
                'Y' --migrated_batch_ind
                    ,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category
           FROM pm_btch_hdr_bak
          WHERE in_use < 100;

      insert_message (
         p_table_name => 'gme_batch_header',
         p_procedure_name => 'insert_batch_header',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      /* If we get here, that means that the above insert was successful;
         let's indicate that the base batches were migrated */
      UPDATE pm_btch_hdr_bak
         SET in_use = in_use + 100
       WHERE in_use < 100;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'pm_btch_hdr_bak/gme_batch_header',
            p_procedure_name => 'insert_batch_header',
            p_parameters => 'none',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_header;

   PROCEDURE insert_material_details (x_return_status OUT NOCOPY VARCHAR2) IS
      l_count           NUMBER (5)   DEFAULT 0;
      l_return_status   VARCHAR2 (1);
      error_detail      EXCEPTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_material_details
                  (material_detail_id,
                   batch_id,
                   formulaline_id,
                   line_no,
                   item_id,
                   line_type,
                   plan_qty,
                   item_um,
                   item_um2,
                   actual_qty,
                   original_qty,
                   wip_plan_qty,
                   release_type,
                   scrap_factor,
                   scale_type,
                   contribute_yield_ind,
                   scale_multiple,
                   scale_rounding_variance,
                   rounding_direction,
                   contribute_step_qty_ind,
                   phantom_type,
                   cost_alloc,
                   alloc_ind,
                   cost,
                   text_code,
                   phantom_id,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category
                  )
         SELECT line_id,
                batch_id,
                formulaline_id,
                line_no,
                item_id,
                line_type,
                get_planned_qty (batch_id, line_id, plan_qty),
                item_um,
                item_um2,
                get_actual_qty (batch_id, line_id, actual_qty),
                plan_qty --original_qty
                        ,
                get_wip_planned_qty (batch_id, line_id, actual_qty),
                release_type,
                scrap_factor,
                DECODE (scale_type, 0, 0, 1, 1, 2, 0, 3, 1, scale_type),
                DECODE (scale_type, 2, 'N', 'Y') --contribute_yield_ind
                                                ,
                NULL --scale_multiple
                    ,
                NULL --scale_rounding_variance
                    ,
                NULL --rounding_direction
                    ,
                'Y' --contribute_step_qty_ind
                   ,
                phantom_type,
                cost_alloc,
                alloc_ind,
                cost,
                text_code,
                phantom_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category
           FROM pm_matl_dtl_bak
          WHERE in_use < 100;

      insert_message (
         p_table_name => 'gme_material_details',
         p_procedure_name => 'insert_material_details',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );
      split_trans_line (x_return_status => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE error_detail;
      END IF;

      UPDATE pm_matl_dtl_bak
         SET in_use = in_use + 100
       WHERE in_use < 100;
   EXCEPTION
      WHEN error_detail THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_MATERIAL_DETAILS',
            p_procedure_name => 'INSERT_MATERIAL_DETAILS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_material_details;

   PROCEDURE insert_batch_steps (x_return_status OUT NOCOPY VARCHAR2) IS
      v_step_rec            pm_rout_dtl%ROWTYPE;
      v_mass_ref_uom        VARCHAR2 (4);
      v_volume_ref_uom      VARCHAR2 (4);
      v_mass_qty            NUMBER;
      v_volume_qty          NUMBER;
      v_max_step_capacity   NUMBER;
      v_step_capacity_uom   VARCHAR2 (4);
      v_planned_charges     NUMBER;
      v_actual_charges      NUMBER;
      v_process_qty_uom     VARCHAR2 (4);
      l_return_status       VARCHAR2 (1);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_batch_steps
                  (batch_id,
                   batchstep_id,
                   routingstep_id,
                   batchstep_no,
                   oprn_id,
                   plan_step_qty,
                   actual_step_qty,
                   step_qty_uom,
                   backflush_qty,
                   plan_start_date,
                   actual_start_date,
                   due_date,
                   plan_cmplt_date,
                   actual_cmplt_date,
                   step_close_date,
                   step_status,
                   priority_code,
                   priority_value,
                   steprelease_type,
                   max_step_capacity,
                   max_step_capacity_uom,
                   plan_charges,
                   actual_charges,
                   text_code,
                   delete_mark,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category,
                   mass_ref_uom,
                   volume_ref_uom,
                   plan_volume_qty,
                   plan_mass_qty,
                   actual_volume_qty,
                   actual_mass_qty
                  )
         SELECT batch_id,
                gme_batch_step_s.NEXTVAL --batchstep_id
                                        ,
                routingstep_id,
                batchstep_no,
                oprn_id,
                plan_step_qty,
                actual_step_qty,
                get_process_qty_uom (oprn_id) --step_qty_uom
                                             ,
                backflush_qty,
                plan_start_date,
                get_actual_date (actual_start_date),
                due_date,
                expct_cmplt_date,
                get_actual_date (actual_cmplt_date),
                get_actual_date (step_close_date),
                step_status,
                priority_code,
                priority_value,
                1 --steprelease_type
                 ,
                NULL --max_step_capacity
                    ,
                NULL --max_step_capacity_uom
                    ,
                NULL --plan_charges
                    ,
                NULL --actual_charges
                    ,
                text_code,
                delete_mark,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category,
                get_ref_uom (
                   fnd_profile.VALUE ('LM$UOM_MASS_TYPE')
                ) --mass_ref_uom
                 ,
                get_ref_uom (
                   fnd_profile.VALUE ('LM$UOM_VOLUME_TYPE')
                ) --volume_ref_uom
                 ,
                NULL --plan_volume_qty
                    ,
                NULL --plan_mass_qty
                    ,
                NULL --actual_volume_qty
                    ,
                NULL --actual_mass_qty
           FROM pm_rout_dtl
          WHERE in_use < 100 AND
                delete_mark <> 1;

      insert_message (
         p_table_name => 'gme_batch_steps',
         p_procedure_name => 'insert_batch_steps',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pm_rout_dtl
         SET in_use = in_use + 100
       WHERE in_use < 100 AND
             delete_mark <> 1;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_BATCH_STEPS',
            p_procedure_name => 'INSERT_BATCH_STEPS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_steps;

   PROCEDURE insert_batch_step_dtls (x_return_status OUT NOCOPY VARCHAR2) IS
      CURSOR get_activities IS
         SELECT   batch_id,
                  batchstep_no,
                  activity,
                  MIN (offset_interval) min_offset,
                  MIN (plan_start_date) plan_start_date,
                  MAX (plan_cmplt_date) plan_cmplt_date,
                  MIN (actual_start_date) actual_start_date,
                  MAX (actual_cmplt_date) actual_cmplt_date
             FROM pm_oprn_dtl
            WHERE delete_mark < 100 AND
                  delete_mark <> 1
         GROUP BY batch_id, batchstep_no, activity;

      CURSOR get_oprn_dtl (
         v_batch_id   pm_oprn_dtl.batch_id%TYPE,
         v_step_no    pm_oprn_dtl.batchstep_no%TYPE,
         v_activity   pm_oprn_dtl.activity%TYPE,
         v_offset     pm_oprn_dtl.offset_interval%TYPE
      ) IS
         SELECT *
           FROM pm_oprn_dtl
          WHERE batch_id = v_batch_id AND
                batchstep_no = v_step_no AND
                activity = v_activity AND
                offset_interval = v_offset AND
                delete_mark < 100 AND
                delete_mark <> 1;

      v_activities        get_activities%ROWTYPE;
      v_oprn_dtl          get_oprn_dtl%ROWTYPE;
      l_return_status     VARCHAR2 (1);
      l_act_cnt           NUMBER                   := 0;
      error_insert_rsrc_txns EXCEPTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN get_activities;
      FETCH get_activities INTO v_activities;

      WHILE (get_activities%FOUND)
      LOOP
         OPEN get_oprn_dtl (
            v_activities.batch_id,
            v_activities.batchstep_no,
            v_activities.activity,
            v_activities.min_offset
         );
         -- Take the first one that comes back if there are more than 1 resulting from this CURSOR.
         FETCH get_oprn_dtl INTO v_oprn_dtl;

         INSERT INTO gme_batch_step_activities
                     (batch_id,
                      activity,
                      batchstep_id,
                      batchstep_activity_id,
                      oprn_line_id,
                      offset_interval,
                      plan_start_date,
                      actual_start_date,
                      plan_cmplt_date,
                      actual_cmplt_date,
                      plan_activity_factor,
                      actual_activity_factor,
                      delete_mark,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login
                     )
            SELECT v_oprn_dtl.batch_id,
                   v_oprn_dtl.activity,
                   get_batchstep_id (
                      v_oprn_dtl.batch_id,
                      v_oprn_dtl.batchstep_no
                   ) --batchstep_id
                    ,
                   gme_batch_step_activity_s.NEXTVAL --batchstep_activity_id
                                                    ,
                   v_oprn_dtl.oprn_line_id,
                   v_oprn_dtl.offset_interval,
                   v_activities.plan_start_date,
                   get_actual_date (v_activities.actual_start_date),
                   v_activities.plan_cmplt_date,
                   get_actual_date (v_activities.actual_cmplt_date),
                   1 --plan_activity_factor
                    ,
                   get_actual_activity_factor (
                      get_batchstep_id (
                         v_oprn_dtl.batch_id,
                         v_oprn_dtl.batchstep_no
                      )
                   ) --actual_activity_factor
                    ,
                   v_oprn_dtl.delete_mark,
                   v_oprn_dtl.created_by,
                   v_oprn_dtl.creation_date,
                   v_oprn_dtl.last_updated_by,
                   v_oprn_dtl.last_update_date,
                   v_oprn_dtl.last_update_login
              FROM sys.DUAL;

         CLOSE get_oprn_dtl;
         l_act_cnt := l_act_cnt + 1;
         FETCH get_activities INTO v_activities;
      END LOOP;

      CLOSE get_activities;
      insert_message (
         p_table_name => 'gme_batch_step_activities',
         p_procedure_name => 'insert_batch_step_dtls',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || l_act_cnt,
         p_error_type => 'P'
      );

      INSERT INTO gme_batch_step_resources
                  (batchstep_resource_id,
                   batchstep_activity_id,
                   resources,
                   cost_analysis_code,
                   cost_cmpntcls_id,
                   prim_rsrc_ind,
                   scale_type,
                   plan_rsrc_count,
                   actual_rsrc_count,
                   resource_qty_uom,
                   plan_rsrc_usage,
                   actual_rsrc_usage,
                   usage_uom,
                   plan_start_date,
                   actual_start_date,
                   plan_cmplt_date,
                   actual_cmplt_date,
                   offset_interval,
                   min_capacity,
                   max_capacity,
                   process_parameter_1,
                   process_parameter_2,
                   process_parameter_3,
                   process_parameter_4,
                   process_parameter_5,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   text_code,
                   batch_id,
                   batchstep_id,
                   capacity_uom,
                   actual_rsrc_qty,
                   plan_rsrc_qty,
                   calculate_charges
                  )
         SELECT batchstepline_id --batchstep_resource_id
                                /* batchstepline_id is used as the line_id for the pc_tran_pnd table */
                                ,
                get_activity_id (
                   batch_id,
                   batchstep_no,
                   activity
                ) --batchstep_activity_id
                 ,
                resources,
                cost_analysis_code,
                cost_cmpntcls_id,
                prim_rsrc_ind,
                scale_type,
                plan_rsrc_count,
                actual_rsrc_count,
                get_process_qty_uom (
                   get_oprn_id (batch_id, batchstep_no)
                ) --resource_qty_uom
                 ,
                get_planned_usage (batchstepline_id) --plan_rsrc_usage
                                                    ,
                get_actual_usage (batchstepline_id) --actual_rsrc_usage
                                                   ,
                usage_um,
                plan_start_date,
                get_actual_date (actual_start_date),
                plan_cmplt_date,
                get_actual_date (actual_cmplt_date),
                get_rsrc_offset (
                   batch_id,
                   batchstep_no,
                   activity,
                   offset_interval
                ) --offset_interval
                 ,
                get_min_capacity (batch_id, resources) --min_capacity
                                                      ,
                get_max_capacity (batch_id, resources) --max_capacity
                                                      ,
                NULL --process_parameter_1
                    ,
                NULL --process_parameter_2
                    ,
                NULL --process_parameter_3
                    ,
                NULL --process_parameter_4
                    ,
                NULL --process_parameter_5
                    ,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                text_code,
                batch_id,
                get_batchstep_id (batch_id, batchstep_no) --batchstep_id
                                                         ,
                get_capacity_uom (batch_id, resources) --capacity_uom
                                                      ,
                actual_rsrc_qty,
                plan_rsrc_qty,
                0 --calculate_charges
           FROM pm_oprn_dtl
          WHERE delete_mark < 100 AND
                delete_mark <> 1;

      insert_message (
         p_table_name => 'gme_batch_step_resources',
         p_procedure_name => 'insert_batch_step_dtls',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pm_oprn_dtl
         SET delete_mark = delete_mark + 100
       WHERE delete_mark < 100 AND
             delete_mark <> 1;

      insert_resource_txns (l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE error_insert_rsrc_txns;
      END IF;

   EXCEPTION
      WHEN error_insert_rsrc_txns THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'PM_OPRN_DTL',
            p_procedure_name => 'INSERT_BATCH_STEP_DTLS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_step_dtls;

   PROCEDURE insert_batch_step_items (x_return_status OUT NOCOPY VARCHAR2) IS
      l_return_status   VARCHAR2 (1);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      report_step_item_orphans;

      INSERT INTO gme_batch_step_items
                  (material_detail_id,
                   batch_id,
                   batchstep_id,
                   text_code,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login
                  )
         SELECT   batchline_id,
                  MIN (batch_id),
                  get_batchstep_id (
                     MIN (batch_id),
                     MIN (batchstep_no)
                  ) --batchstep_id
                   ,
                  MIN (text_code),
                  MIN (created_by),
                  MIN (creation_date),
                  MIN (last_updated_by),
                  MIN (last_update_date),
                  MIN (last_update_login)
             FROM pm_rout_mtl pm
            WHERE NOT EXISTS ( SELECT 1
                                 FROM gme_batch_step_items
                                WHERE material_detail_id = pm.batchline_id)
                      AND
                      EXISTS ( SELECT 1
                                 FROM gme_batch_steps step
                                WHERE step.batch_id = pm.batch_id AND
                                      step.batchstep_no = pm.batchstep_no)
                      AND
                      EXISTS ( SELECT 1
                                 FROM gme_material_details matl
                                WHERE matl.batch_id = pm.batch_id AND
                                      matl.material_detail_id = pm.batchline_id)
         GROUP BY batchline_id;

      insert_message (
         p_table_name => 'gme_batch_step_items',
         p_procedure_name => 'insert_batch_step_items',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_BATCH_STEP_ITEMS',
            p_procedure_name => 'INSERT_BATCH_STEP_ITEMS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_step_items;

   PROCEDURE report_step_item_orphans IS

     CURSOR cur_get_orphans IS
     SELECT batch_id, batchstep_no, batchline_id
       FROM pm_rout_mtl pm
      WHERE NOT EXISTS ( SELECT 1
                           FROM gme_batch_step_items
                          WHERE material_detail_id = pm.batchline_id)
                   AND
           (
            NOT EXISTS ( SELECT 1
                           FROM gme_batch_steps step
                          WHERE step.batch_id = pm.batch_id AND
                                step.batchstep_no = pm.batchstep_no) OR
            NOT EXISTS ( SELECT 1
                           FROM gme_material_details matl
                          WHERE matl.batch_id = pm.batch_id AND
                                matl.material_detail_id = pm.batchline_id)
            );

     l_cur_get_orphans     cur_get_orphans%ROWTYPE;

   BEGIN

     OPEN cur_get_orphans;
     FETCH cur_get_orphans INTO l_cur_get_orphans;
     WHILE cur_get_orphans%FOUND LOOP
        insert_message (
           p_table_name => 'gme_batch_step_items',
           p_procedure_name => 'report_step_item_orphans',
           p_parameters => 'Batch_id=>'||to_char(l_cur_get_orphans.batch_id)
                         ||' step_no=>'||l_cur_get_orphans.batchstep_no
                         ||' material_detail_id=>'||to_char(l_cur_get_orphans.batchline_id),
           p_message => 'Step or material does not exist in parent table; item / step association will not be migrated',
           p_error_type => 'I'
        );

        FETCH cur_get_orphans INTO l_cur_get_orphans;
     END LOOP;
     CLOSE cur_get_orphans;

   EXCEPTION
     WHEN OTHERS THEN
        insert_message (
           p_table_name => 'GME_BATCH_STEP_ITEMS',
           p_procedure_name => 'REPORT_STEP_ITEM_ORPHANS',
           p_parameters => '',
           p_message => SQLERRM,
           p_error_type => 'D'
        );
   END report_step_item_orphans;

   PROCEDURE insert_batch_step_dependencies (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      report_step_dep_orphans;

      INSERT INTO gme_batch_step_dependencies
                  (batch_id,
                   batchstep_id,
                   dep_type,
                   dep_step_id,
                   rework_code,
                   standard_delay,
                   min_delay,
                   max_delay,
                   transfer_qty,
                   transfer_um,
                   transfer_percent,
                   text_code,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category
                  )
         SELECT batch_id,
                get_batchstep_id (batch_id, batchstep_no) --batchstep_id
                                                         ,
                dep_type,
                get_batchstep_id (batch_id, dep_step_no) --dep_step_id
                                                        ,
                rework_code,
                standard_delay,
                min_delay,
                max_delay,
                transfer_qty,
                transfer_um,
                100 --transfer_percent
                   ,
                text_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                NULL --attribute1
                    ,
                NULL --attribute2
                    ,
                NULL --attribute3
                    ,
                NULL --attribute4
                    ,
                NULL --attribute5
                    ,
                NULL --attribute6
                    ,
                NULL --attribute7
                    ,
                NULL --attribute8
                    ,
                NULL --attribute9
                    ,
                NULL --attribute10
                    ,
                NULL --attribute11
                    ,
                NULL --attribute12
                    ,
                NULL --attribute13
                    ,
                NULL --attribute14
                    ,
                NULL --attribute15
                    ,
                NULL --attribute16
                    ,
                NULL --attribute17
                    ,
                NULL --attribute18
                    ,
                NULL --attribute19
                    ,
                NULL --attribute20
                    ,
                NULL --attribute21
                    ,
                NULL --attribute22
                    ,
                NULL --attribute23
                    ,
                NULL --attribute24
                    ,
                NULL --attribute25
                    ,
                NULL --attribute26
                    ,
                NULL --attribute27
                    ,
                NULL --attribute28
                    ,
                NULL --attribute29
                    ,
                NULL --attribute30
                    ,
                NULL --attribute_category
           FROM pm_rout_dep dep
          WHERE dep_type <
                      100 -- Only bring over dependencies for which both steps are still defined...
                          -- If there is a record in dep table and not the 2 corresponding rows in step table, that means
                          -- the record was marked for delete in the steps table, and, the old code
                          -- did not delete the dependency.
                         AND
                EXISTS ( SELECT 1
                           FROM gme_batch_steps step
                          WHERE step.batch_id = dep.batch_id AND
                                step.batchstep_no = dep.batchstep_no) AND
                EXISTS ( SELECT 1
                           FROM gme_batch_steps step
                          WHERE step.batch_id = dep.batch_id AND
                                step.batchstep_no = dep.dep_step_no);

      insert_message (
         p_table_name => 'gme_batch_step_dependencies',
         p_procedure_name => 'insert_batch_step_dependencies',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pm_rout_dep
         SET dep_type = dep_type + 100
       WHERE dep_type < 100;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_BATCH_STEP_DEPENDENCIES',
            p_procedure_name => 'INSERT_BATCH_STEP_DEPENDENCIES',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_step_dependencies;

   PROCEDURE report_step_dep_orphans IS

     CURSOR cur_get_orphans IS
     SELECT batch_id, batchstep_no, dep_step_no
     FROM pm_rout_dep dep
     WHERE dep_type < 100 AND
          (NOT EXISTS ( SELECT 1
                          FROM gme_batch_steps step
                         WHERE step.batch_id = dep.batch_id AND
                               step.batchstep_no = dep.batchstep_no) OR
           NOT EXISTS ( SELECT 1
                          FROM gme_batch_steps step
                         WHERE step.batch_id = dep.batch_id AND
                               step.batchstep_no = dep.dep_step_no));


     l_cur_get_orphans     cur_get_orphans%ROWTYPE;

   BEGIN

     OPEN cur_get_orphans;
     FETCH cur_get_orphans INTO l_cur_get_orphans;
     WHILE cur_get_orphans%FOUND LOOP
        insert_message (
           p_table_name => 'gme_batch_step_dependencies',
           p_procedure_name => 'report_step_dep_orphans',
           p_parameters => 'Batch_id=>'||to_char(l_cur_get_orphans.batch_id)
                         ||' step_no=>'||l_cur_get_orphans.batchstep_no
                         ||' dep_step_no=>'||l_cur_get_orphans.dep_step_no,
           p_message => 'Step or dependent step does not exist in steps table; dependency will not be migrated',
           p_error_type => 'I'
        );

        FETCH cur_get_orphans INTO l_cur_get_orphans;
     END LOOP;
     CLOSE cur_get_orphans;

   EXCEPTION
     WHEN OTHERS THEN
        insert_message (
           p_table_name => 'GME_BATCH_STEP_DEPENDENCIES',
           p_procedure_name => 'REPORT_STEP_DEP_ORPHANS',
           p_parameters => '',
           p_message => SQLERRM,
           p_error_type => 'D'
        );
   END report_step_dep_orphans;

   PROCEDURE insert_resource_txns (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_resource_txns
                  (poc_trans_id,
                   orgn_code,
                   doc_type,
                   doc_id,
                   line_type,
                   line_id,
                   resources,
                   resource_usage,
                   trans_um,
                   trans_date,
                   completed_ind,
                   event_id,
                   posted_ind,
                   overrided_protected_ind,
                   reason_code,
                   start_date,
                   end_date,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   delete_mark,
                   text_code,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category,
                   program_id,
                   program_application_id,
                   request_id,
                   program_update_date
                  )
         SELECT poc_trans_id,
                orgn_code,
                doc_type,
                doc_id,
                line_type,
                line_id,
                resources,
                resource_usage,
                trans_um,
                trans_date,
                completed_ind,
                event_id,
                posted_ind,
                'N' --overrided_protected_ind
                   ,
                reason_code,
                start_date,
                end_date,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                delete_mark,
                text_code,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category,
                program_id,
                program_application_id,
                request_id,
                program_update_date
           FROM pc_tran_pnd
          WHERE delete_mark < 100 AND
                delete_mark <> 1 AND
                (completed_ind = 1 OR
                 (completed_ind = 0 AND
                  resource_usage <> 0
                 )
                ); --don't migrate 0 pending

      insert_message (
         p_table_name => 'gme_resource_txns',
         p_procedure_name => 'insert_resource_txns',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pc_tran_pnd
         SET delete_mark = delete_mark + 100
       WHERE delete_mark < 100 AND
             delete_mark <> 1;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_RESOURCE_TXNS',
            p_procedure_name => 'INSERT_RESOURCE_TXNS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_resource_txns;

   PROCEDURE insert_batch_history (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_batch_history
                  (event_id,
                   batch_id,
                   orig_status,
                   new_status,
                   orig_wip_whse,
                   new_wip_whse,
                   gl_posted_ind,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   program_application_id,
                   program_id,
                   request_id,
                   program_update_date
                  )
         SELECT event_id,
                batch_id,
                orig_status,
                new_status,
                orig_wip_whse,
                new_wip_whse,
                gl_posted_ind,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_application_id,
                program_id,
                request_id,
                program_update_date
           FROM pm_hist_hdr
          WHERE orig_status < 100;

      insert_message (
         p_table_name => 'gme_batch_history',
         p_procedure_name => 'insert_batch_history',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pm_hist_hdr
         SET orig_status = orig_status + 100
       WHERE orig_status < 100;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_BATCH_HISTORY',
            p_procedure_name => 'INSERT_BATCH_HISTORY',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_history;

   PROCEDURE insert_batch_step_transfers (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_batch_step_transfers
                  (wip_trans_id,
                   batch_id,
                   batchstep_no,
                   transfer_step_no,
                   line_type,
                   trans_qty,
                   trans_um,
                   trans_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   creation_date,
                   created_by,
                   delete_mark,
                   text_code,
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
                   attribute16,
                   attribute17,
                   attribute18,
                   attribute19,
                   attribute20,
                   attribute21,
                   attribute22,
                   attribute23,
                   attribute24,
                   attribute25,
                   attribute26,
                   attribute27,
                   attribute28,
                   attribute29,
                   attribute30,
                   attribute_category
                  )
         SELECT wip_trans_id,
                batch_id,
                batchstep_no,
                transfer_step_no,
                line_type,
                trans_qty,
                trans_um,
                trans_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                creation_date,
                created_by,
                delete_mark,
                text_code,
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
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category
           FROM pm_oprn_wip
          WHERE delete_mark < 100;

      insert_message (
         p_table_name => 'gme_batch_step_transfers',
         p_procedure_name => 'insert_batch_step_transfers',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      UPDATE pm_oprn_wip
         SET delete_mark = delete_mark + 100
       WHERE delete_mark < 100;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_BATCH_STEP_TRANSFERS',
            p_procedure_name => 'INSERT_BATCH_STEP_TRANSFERS',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_batch_step_transfers;

   PROCEDURE insert_text_header (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_text_header
                  (text_code,
                   last_updated_by,
                   created_by,
                   last_update_date,
                   creation_date,
                   last_update_login
                  )
         SELECT text_code,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                last_update_login
           FROM pm_text_hdr pm
          WHERE NOT EXISTS ( SELECT 1
                               FROM gme_text_header
                              WHERE text_code = pm.text_code);

      insert_message (
         p_table_name => 'gme_text_header/pm_text_hdr',
         p_procedure_name => 'insert_text_header',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      INSERT INTO gme_text_header
                  (text_code,
                   last_updated_by,
                   created_by,
                   last_update_date,
                   creation_date,
                   last_update_login
                  )
         SELECT text_code,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                last_update_login
           FROM pc_text_hdr pc
          WHERE NOT EXISTS ( SELECT 1
                               FROM gme_text_header
                              WHERE text_code = pc.text_code);

      insert_message (
         p_table_name => 'gme_text_header/pc_text_hdr',
         p_procedure_name => 'insert_text_header',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_TEXT_HEADER',
            p_procedure_name => 'INSERT_TEXT_HEADER',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_text_header;

   PROCEDURE insert_text_dtl (x_return_status OUT NOCOPY VARCHAR2) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_text_table_tl
                  (text_code,
                   lang_code,
                   paragraph_code,
                   sub_paracode,
                   line_no,
                   text,
                   language,
                   source_lang,
                   last_updated_by,
                   created_by,
                   last_update_date,
                   creation_date,
                   last_update_login
                  )
         SELECT text_code,
                lang_code,
                paragraph_code,
                sub_paracode,
                line_no,
                text,
                language,
                source_lang,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                last_update_login
           FROM pm_text_tbl_tl pm
          WHERE NOT EXISTS ( SELECT 1
                               FROM gme_text_table_tl
                              WHERE text_code = pm.text_code);

      insert_message (
         p_table_name => 'gme_text_table_tl/pm_text_tbl_tl',
         p_procedure_name => 'insert_text_dtl',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );

      INSERT INTO gme_text_table_tl
                  (text_code,
                   lang_code,
                   paragraph_code,
                   sub_paracode,
                   line_no,
                   text,
                   language,
                   source_lang,
                   last_updated_by,
                   created_by,
                   last_update_date,
                   creation_date,
                   last_update_login
                  )
         SELECT text_code,
                lang_code,
                paragraph_code,
                sub_paracode,
                line_no,
                text,
                language,
                source_lang,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                last_update_login
           FROM pc_text_tbl_tl pc
          WHERE NOT EXISTS ( SELECT 1
                               FROM gme_text_table_tl
                              WHERE text_code = pc.text_code);

      insert_message (
         p_table_name => 'gme_text_table_tl/pc_text_tbl_tl',
         p_procedure_name => 'insert_text_dtl',
         p_parameters => 'none',
         p_message => 'number of records inserted = ' || SQL%ROWCOUNT,
         p_error_type => 'P'
      );
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'GME_TEXT_TABLE_TL',
            p_procedure_name => 'INSERT_TEXT_DTL',
            p_parameters => '',
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
   END insert_text_dtl;

   PROCEDURE split_trans_line (x_return_status OUT NOCOPY VARCHAR2) IS
      CURSOR cur_get_materials IS
         SELECT   b.batch_id,
                  m.line_id
             FROM pm_matl_dtl_bak m, pm_btch_hdr_bak b
            WHERE m.in_use < 100 AND -- => only check for lines that were not migrated
                  b.batch_id = m.batch_id AND
                  b.batch_status IN (2, 3) AND
                  b.batch_type = 0
         ORDER BY m.batch_id;

      l_matl            cur_get_materials%ROWTYPE;
      l_tran_rec        ic_tran_pnd%ROWTYPE;
      l_def_lot_id      ic_tran_pnd.trans_id%TYPE;
      l_trans_id        ic_tran_pnd.trans_id%TYPE;
      l_is_plain        BOOLEAN;
      l_load_trans_fail BOOLEAN;
      l_batch_header    pm_btch_hdr_bak%ROWTYPE;
      l_pos             NUMBER                        := 0;
      l_flip_count      NUMBER                        := 0;
      l_new_txn_count   NUMBER                        := 0;
      l_return_status   VARCHAR2 (1);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_pos := 1;
      OPEN cur_get_materials;
      l_pos := 2;
      FETCH cur_get_materials INTO l_matl;
      l_pos := 3;

      WHILE cur_get_materials%FOUND
      LOOP
         l_batch_header.batch_id := l_matl.batch_id;
         l_pos := 4;
         load_trans (l_batch_header, l_return_status);

         IF l_return_status <> x_return_status THEN
            l_load_trans_fail := TRUE;
            l_def_lot_id := NULL;

            insert_message (
               p_table_name => 'gme_inventory_txns_gtmp/ic_tran_pnd',
               p_procedure_name => 'check_wip_batches',
               p_parameters =>    'batch_id = '
                               || l_batch_header.batch_id
                               || ' line_id = '
                               || l_matl.line_id,
               p_message => 'Unable to load the transactions',
               p_error_type => FND_API.G_RET_STS_ERROR
            );
         ELSE
            l_load_trans_fail := FALSE;
            l_pos := 5;
            get_default_lot (
               l_matl.line_id,
               l_def_lot_id,
               l_is_plain,
               l_return_status
            );
            l_pos := 6;
         END IF;

         IF l_def_lot_id IS NULL OR
            l_return_status <> x_return_status THEN
            -- No need to write message if the load trans failed, because message
            -- for that was already written, and if load_trans failed, it follows that def lot
            -- could not be found.
            IF l_load_trans_fail = FALSE THEN
               insert_message (
                  p_table_name => 'gme_inventory_txns_gtmp/ic_tran_pnd',
                  p_procedure_name => 'check_wip_batches',
                  p_parameters =>    'batch_id = '
                                  || l_batch_header.batch_id
                                  || ' line_id = '
                                  || l_matl.line_id,
                  p_message => 'Unable to determine the default lot.',
                  p_error_type => FND_API.G_RET_STS_ERROR
               );
            END IF;
         ELSE
            SELECT *
              INTO l_tran_rec
              FROM ic_tran_pnd
             WHERE trans_id = l_def_lot_id;

            IF l_tran_rec.completed_ind = 1 THEN
               IF (l_is_plain = FALSE) THEN
                  /* transaction is zero qty and it's completed... let's un-complete it...
                     if the def transaction is non zero qty for non plain item and completed, it would have
                     been caught in check_wip_batches routine.
                     Note, that data condition is only valid in WIP batch. */
                  -- Can get here for non-plain items which could not be reversed in check_wip_batches.
                  -- So, before flipping the completed ind, make sure it's zero qty and that we can flip the ind.
                  IF l_tran_rec.trans_qty = 0 THEN
                     UPDATE ic_tran_pnd
                        SET completed_ind = 0
                      WHERE trans_id = l_tran_rec.trans_id;
                  END IF;

                  l_flip_count := l_flip_count + 1;
               ELSE -- this is a plain item
                  -- Just create a new 0 transaction record that's pending if the qty is non zero.
                  IF l_tran_rec.trans_qty = 0 THEN
                     UPDATE ic_tran_pnd
                        SET completed_ind = 0
                      WHERE trans_id = l_tran_rec.trans_id;
                  ELSE
                     SELECT gem5_trans_id_s.NEXTVAL
                       INTO l_trans_id
                       FROM sys.DUAL;

                     INSERT INTO ic_tran_pnd
                                 (trans_id,
                                  item_id,
                                  line_id,
                                  co_code,
                                  orgn_code,
                                  whse_code,
                                  lot_id,
                                  location,
                                  doc_id,
                                  doc_type,
                                  doc_line,
                                  line_type,
                                  reason_code,
                                  creation_date,
                                  trans_date,
                                  trans_qty,
                                  trans_qty2,
                                  qc_grade,
                                  lot_status,
                                  trans_stat,
                                  trans_um,
                                  trans_um2,
                                  op_code,
                                  completed_ind,
                                  staged_ind,
                                  gl_posted_ind,
                                  event_id,
                                  delete_mark,
                                  text_code,
                                  last_update_date,
                                  created_by,
                                  last_updated_by,
                                  last_update_login,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  request_id,
                                  reverse_id
                                 )
                          VALUES (l_trans_id,
                                  l_tran_rec.item_id,
                                  l_tran_rec.line_id,
                                  l_tran_rec.co_code,
                                  l_tran_rec.orgn_code,
                                  l_tran_rec.whse_code,
                                  l_tran_rec.lot_id,
                                  l_tran_rec.location,
                                  l_tran_rec.doc_id,
                                  l_tran_rec.doc_type,
                                  l_tran_rec.doc_line,
                                  l_tran_rec.line_type,
                                  l_tran_rec.reason_code,
                                  l_tran_rec.creation_date,
                                  l_tran_rec.trans_date,
                                  0 /* l_tran_rec.trans_qty */,
                                  0 /* l_tran_rec.trans_qty2 */,
                                  l_tran_rec.qc_grade,
                                  l_tran_rec.lot_status,
                                  l_tran_rec.trans_stat,
                                  l_tran_rec.trans_um,
                                  l_tran_rec.trans_um2,
                                  l_tran_rec.op_code,
                                  0 /* l_tran_rec.completed_ind */,
                                  l_tran_rec.staged_ind,
                                  l_tran_rec.gl_posted_ind,
                                  l_tran_rec.event_id,
                                  l_tran_rec.delete_mark,
                                  l_tran_rec.text_code,
                                  l_tran_rec.last_update_date,
                                  l_tran_rec.created_by,
                                  l_tran_rec.last_updated_by,
                                  l_tran_rec.last_update_login,
                                  l_tran_rec.program_application_id,
                                  l_tran_rec.program_id,
                                  l_tran_rec.program_update_date,
                                  l_tran_rec.request_id,
                                  l_tran_rec.reverse_id
                                 );

                     l_new_txn_count := l_new_txn_count + 1;
                  END IF;   /* IF l_tran_rec.trans_qty = 0 */
               END IF;   /* IF (l_is_plain = FALSE) THEN */
            END IF;   /* IF l_tran_rec.completed_ind = 1 THEN */
         END IF;

         /* IF l_def_lot_id IS NULL OR l_return_status <> x_return_status THEN */

         FETCH cur_get_materials INTO l_matl;
      END LOOP;   /* WHILE cur_get_materials%FOUND LOOP */

      CLOSE cur_get_materials;
      insert_message (
         p_table_name => 'ic_tran_pnd',
         p_procedure_name => 'split_trans_line',
         p_parameters => 'none',
         p_message =>    'number of zero quantity transactions uncompleted = '
                      || l_flip_count,
         p_error_type => 'P'
      );
      insert_message (
         p_table_name => 'ic_tran_pnd',
         p_procedure_name => 'split_trans_line',
         p_parameters => 'none',
         p_message =>    'number of zero quantity transactions inserted = '
                      || l_new_txn_count,
         p_error_type => 'P'
      );
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'gme_inventory_txns_gtmp/ic_tran_pnd',
            p_procedure_name => 'SPLIT_TRANS_LINE',
            p_parameters =>    'Batch ID='
                            || l_matl.batch_id
                            || ' Line ID='
                            || l_matl.line_id,
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
         RAISE;
   END split_trans_line;

   PROCEDURE load_trans (
      p_batch_row       IN       pm_btch_hdr_bak%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_get_init_reversal IS
         SELECT   *
             FROM gme_inventory_txns_gtmp
            WHERE transaction_no = 2 AND
                  trans_qty <>
                        0 -- these are already matched up... don't match them again.
         ORDER BY line_type,
                  item_id,
                  material_detail_id,
                  whse_code,
                  lot_id,
                  location,
                  completed_ind,
                  trans_id;

      CURSOR c_get_match_reversal IS
         SELECT   *
             FROM gme_inventory_txns_gtmp
            WHERE transaction_no <> 2 -- Should this be indexed.
         ORDER BY line_type,
                  item_id,
                  material_detail_id,
                  whse_code,
                  lot_id,
                  location,
                  completed_ind,
                  trans_id;

      CURSOR c_get_cmplt_zero_def_txns IS
         SELECT   *
             FROM gme_inventory_txns_gtmp
            WHERE completed_ind = 1 AND
                  trans_qty = 0
         ORDER BY line_type,
                  item_id,
                  material_detail_id,
                  whse_code,
                  lot_id,
                  location,
                  completed_ind,
                  trans_id;

      CURSOR c_check_mat_transactions (
         p_batch_id     IN   NUMBER,
         p_batch_type   IN   VARCHAR2
      ) IS
         SELECT 1
           FROM gme_inventory_txns_gtmp
          WHERE doc_id = p_batch_id AND
                doc_type = p_batch_type AND
                ROWNUM = 1;

      l_api_name   CONSTANT VARCHAR2 (30)                       := 'LOAD_TRANS';
      l_inv_exists          NUMBER                              := 0;
      l_batch_id            pm_btch_hdr_bak.batch_id%TYPE;
      l_doc_type            ic_tran_pnd.doc_type%TYPE;
      init_revs             c_get_init_reversal%ROWTYPE;
      match_revs            c_get_match_reversal%ROWTYPE;
      l_last_txn            c_get_cmplt_zero_def_txns%ROWTYPE;
      l_current_txn         c_get_cmplt_zero_def_txns%ROWTYPE;
      l_return_status       VARCHAR2 (1)               := FND_API.G_RET_STS_SUCCESS;
      l_batch_row           pm_btch_hdr_bak%ROWTYPE;
      no_batch_id           EXCEPTION;
      error_inserting_txn   EXCEPTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Check that we have at least a BATCH ID */
      IF ((p_batch_row.batch_id IS NULL) OR
          (p_batch_row.batch_id = FND_API.g_miss_num)
         ) THEN
         RAISE no_batch_id;
      END IF;

      l_batch_id := p_batch_row.batch_id;
      SELECT *
        INTO l_batch_row
        FROM pm_btch_hdr_bak
       WHERE batch_id = l_batch_id;

      -- Detemine Transactional Doc Type
      -- 0 - PROD 10 - FPO

      IF (l_batch_row.batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSIF (l_batch_row.batch_type = 10) THEN
         l_doc_type := 'FPO';
      END IF;

      /* Now Validate Transactions */
      /* Have Been Loaded */

      -- Check if values already exist in Table

      OPEN c_check_mat_transactions (l_batch_row.batch_id, l_doc_type);
      FETCH c_check_mat_transactions INTO l_inv_exists;
      CLOSE c_check_mat_transactions;

      IF (l_inv_exists > 0) THEN -- We have Alreay Loaded INV Batch Data
         NULL;
      ELSE -- Now Populate The GME_INVENTORY_TXNS_GTMP table
           -- Should this be in same file as other table routines
         /* Clear out the temp table when a new batch is encountered;
         -- The code that calls this orders the batches by batch_id so, once a batch
         -- is loaded to the temp table, it doesn't have to be loaded for subsequent matl lines;
         -- however, once a new batch_id is started, we know we are done with the old batch, so,
         -- we can remove the data from the previous batch. */
         DELETE FROM gme_inventory_txns_gtmp;

         insert_inv_txns_gtmp (
            p_batch_id => l_batch_id,
            p_doc_type => l_doc_type,
            x_return_status => l_return_status
         );

         IF l_return_status <> x_return_status THEN
            RAISE error_inserting_txn;
         END IF;

         /* Lets Now Mark all Transactions That are Reversals */

         /* Let's look at zero completed def transactions first    */
         OPEN c_get_cmplt_zero_def_txns;
         FETCH c_get_cmplt_zero_def_txns INTO l_last_txn;

         IF c_get_cmplt_zero_def_txns%FOUND THEN
            LOOP
               FETCH c_get_cmplt_zero_def_txns INTO l_current_txn;
               EXIT WHEN c_get_cmplt_zero_def_txns%NOTFOUND;

               IF  (l_last_txn.material_detail_id =
                                             l_current_txn.material_detail_id
                   ) AND
                   (l_last_txn.line_type = l_current_txn.line_type) AND
                   (l_last_txn.item_id = l_current_txn.item_id) AND
                   (l_last_txn.whse_code = l_current_txn.whse_code) AND
                   (l_last_txn.lot_id = l_current_txn.lot_id) AND
                   (l_last_txn.location = l_current_txn.location) THEN
                  UPDATE gme_inventory_txns_gtmp
                     SET transaction_no = 2
                   WHERE trans_id IN
                               (l_last_txn.trans_id, l_current_txn.trans_id);

                  FETCH c_get_cmplt_zero_def_txns INTO l_last_txn;
               ELSE
                  l_last_txn := l_current_txn;
               END IF;
            END LOOP;
         END IF;

         CLOSE c_get_cmplt_zero_def_txns;

         UPDATE gme_inventory_txns_gtmp
            SET transaction_no = 2
          WHERE ((line_type = -1 AND -- Ingredient
                  trans_qty > 0
                 ) OR
                 (line_type <> -1 AND
                  trans_qty < 0
                 )
                );

         IF (SQL%ROWCOUNT > 0) THEN
            OPEN c_get_init_reversal;

            LOOP
               FETCH c_get_init_reversal INTO init_revs;
               EXIT WHEN c_get_init_reversal%NOTFOUND;
               OPEN c_get_match_reversal;

               LOOP
                  FETCH c_get_match_reversal INTO match_revs;
                  EXIT WHEN c_get_match_reversal%NOTFOUND;

                  IF ((init_revs.material_detail_id =
                                                match_revs.material_detail_id
                      ) AND
                      (init_revs.line_type = match_revs.line_type) AND
                      (init_revs.item_id = match_revs.item_id) AND
                      (init_revs.whse_code = match_revs.whse_code) AND
                      (init_revs.lot_id = match_revs.lot_id) AND
                      (init_revs.location = match_revs.location) AND
                      (init_revs.completed_ind = match_revs.completed_ind) AND
                      ((init_revs.trans_qty) + (match_revs.trans_qty) = 0)
                     ) THEN
                     UPDATE gme_inventory_txns_gtmp
                        SET transaction_no = 2
                      WHERE trans_id = match_revs.trans_id;

                     EXIT;
                  END IF;
               END LOOP;

               CLOSE c_get_match_reversal;
            END LOOP;

            CLOSE c_get_init_reversal;
         END IF;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN no_batch_id THEN
         x_return_status := 'E';
         insert_message (
            p_table_name => 'gme_inventory_txns_gtmp',
            p_procedure_name => 'load_trans',
            p_parameters => '',
            p_message => 'Batch_id not specified for load',
            p_error_type => x_return_status
         );
      WHEN error_inserting_txn THEN
         x_return_status := l_return_status;
         RAISE;
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'gme_inventory_txns_gtmp',
            p_procedure_name => 'load_trans',
            p_parameters => 'batch_id = ' || l_batch_id,
            p_message => SQLERRM -- || ' with pos = ' || l_pos
                                ,
            p_error_type => x_return_status
         );
         RAISE;
   END load_trans;

   PROCEDURE insert_inv_txns_gtmp (
      p_batch_id        IN       pm_btch_hdr_bak.batch_id%TYPE,
      p_doc_type        IN       ic_tran_pnd.doc_type%TYPE,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_trans_id        IN       ic_tran_pnd.trans_id%TYPE DEFAULT NULL
   ) IS
      l_all_txns   VARCHAR2 (100);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO gme_inventory_txns_gtmp
                  (trans_id,
                   item_id,
                   co_code,
                   orgn_code,
                   whse_code,
                   lot_id,
                   location,
                   doc_id,
                   doc_type,
                   doc_line,
                   line_type,
                   reason_code,
                   trans_date,
                   trans_qty,
                   trans_qty2,
                   qc_grade,
                   lot_status,
                   trans_stat,
                   trans_um,
                   trans_um2,
                   completed_ind,
                   staged_ind,
                   gl_posted_ind,
                   event_id,
                   delete_mark,
                   text_code,
                   action_code,
                   material_detail_id,
                   transaction_no,
                   organization_id,
                   locator_id,
                   subinventory,
                   alloc_um,
                   alloc_qty
                  )
         SELECT i.trans_id,
                i.item_id,
                i.co_code,
                i.orgn_code,
                i.whse_code,
                i.lot_id,
                i.location,
                i.doc_id,
                i.doc_type,
                i.doc_line,
                i.line_type,
                i.reason_code,
                i.trans_date,
                i.trans_qty,
                i.trans_qty2,
                i.qc_grade,
                i.lot_status,
                i.trans_stat,
                i.trans_um,
                i.trans_um2,
                i.completed_ind,
                i.staged_ind,
                i.gl_posted_ind,
                i.event_id,
                i.delete_mark,
                i.text_code,
                'NONE',
                i.line_id,
                1,
                0,
                0,
                NULL,
                NULL,
                NULL
           FROM ic_tran_pnd i
          WHERE doc_id = p_batch_id AND
                doc_type = p_doc_type AND
                -- retrieve only the trans_id passed or if that's NULL, all txns for the batch
                (i.trans_id = p_trans_id OR
                 p_trans_id IS NULL
                ) AND
                -- return only those txns that look like they may be def txns
                -- in get_default_lot, if more than one of these came back, we will determine which
                -- txn is really the default txn
                lot_id = 0 AND
                location = p_default_loct AND
                delete_mark = 0;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';

         IF p_trans_id IS NULL THEN
            l_all_txns := ' Note: Attempted to insert all batch txns.';
         ELSE
            l_all_txns := ' Attempt to insert single transaction.';
         END IF;

         insert_message (
            p_table_name => 'GME_INVENTORY_TXNS_GTMP',
            p_procedure_name => 'INSERT_INV_TXNS_GTMP',
            p_parameters =>    ' Batch_Id=>'
                            || p_batch_id
                            || ' Doc Type=>'
                            || p_doc_type
                            || ' Trans ID=>'
                            || p_trans_id
                            || l_all_txns,
            p_message => SQLERRM,
            p_error_type => x_return_status
         );
         RAISE;
   END insert_inv_txns_gtmp;

   PROCEDURE get_default_lot (
      p_line_id         IN       pm_matl_dtl_bak.line_id%TYPE,
      x_def_lot_id      OUT NOCOPY      ic_tran_pnd.trans_id%TYPE,
      x_is_plain        OUT NOCOPY      BOOLEAN,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_matl_dtl        pm_matl_dtl_bak%ROWTYPE;
      l_item_mst        ic_item_mst%ROWTYPE;
      l_ic_tran_pnd     ic_tran_pnd%ROWTYPE;
      l_whse_loct_ctl   ic_whse_mst.whse_code%TYPE;
      l_def_lot_found   BOOLEAN;

      CURSOR cur_get_def_trans (
         v_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
         v_line_id    pm_matl_dtl_bak.line_id%TYPE,
         v_doc_type   gme_inventory_txns_gtmp.doc_type%TYPE
      ) IS
         -- The following cursor does not look at lot_id and loct because these were already screened
         -- in the cursor which populated gme_inventory_txns_gtmp in load_trans.
         SELECT   trans_id,
                  whse_code
             FROM gme_inventory_txns_gtmp
            WHERE doc_id = v_batch_id AND
                  doc_type = v_doc_type AND
                  material_detail_id = v_line_id AND
                  transaction_no <> 2 -- don't look at the reversals...
         ORDER BY line_type,
                  item_id,
                  material_detail_id,
                  whse_code,
                  lot_id,
                  location,
                  completed_ind,
                  trans_id;

      CURSOR cur_get_whse_ctl (v_whse_code IN VARCHAR2) IS
         SELECT loct_ctl
           FROM ic_whse_mst
          WHERE whse_code = v_whse_code;

      CURSOR cur_get_batch_info (v_batch_id IN NUMBER) IS
         SELECT batch_no,
                plant_code
           FROM pm_btch_hdr_bak
          WHERE batch_id = v_batch_id;

      get_batch_info    cur_get_batch_info%ROWTYPE;
      get_trans_rec     cur_get_def_trans%ROWTYPE;
      l_tran_whse       ps_whse_eff.whse_code%TYPE;
      l_batch_type      pm_btch_hdr_bak.batch_type%TYPE;
      l_doc_type        gme_inventory_txns_gtmp.doc_type%TYPE;
      l_pos             NUMBER                                  := 0;
      l_cnt             NUMBER;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_pos := 1;
      SELECT *
        INTO l_matl_dtl
        FROM pm_matl_dtl_bak
       WHERE line_id = p_line_id;
      l_pos := 2;
      SELECT *
        INTO l_item_mst
        FROM ic_item_mst
       WHERE item_id = l_matl_dtl.item_id;
      l_pos := 3;
      l_def_lot_found := FALSE;
      x_def_lot_id := 0;
      SELECT batch_type
        INTO l_batch_type
        FROM pm_btch_hdr_bak
       WHERE batch_id = l_matl_dtl.batch_id;
      l_pos := 4;

      IF (l_batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSIF (l_batch_type = 10) THEN
         l_doc_type := 'FPO';
      END IF;

      SELECT COUNT (1)
        INTO l_cnt
        FROM gme_inventory_txns_gtmp
       WHERE doc_id = l_matl_dtl.batch_id AND
             doc_type = l_doc_type AND
             material_detail_id = p_line_id AND
             transaction_no <> 2 AND
             trans_qty = 0;
      l_pos := 5;

      IF l_cnt = 1 THEN
         -- This is the default lot for sure, because there can only at most one zero qty txn, completed
         -- or pending.  No need for further processing.

         l_pos := 6;
         SELECT trans_id
           INTO x_def_lot_id
           FROM gme_inventory_txns_gtmp
          WHERE doc_id = l_matl_dtl.batch_id AND
                doc_type = l_doc_type AND
                material_detail_id = p_line_id AND
                transaction_no <> 2 AND
                trans_qty = 0;
         l_pos := 7;
         l_def_lot_found := TRUE;
      ELSE
         l_pos := 9;

         FOR get_rec IN cur_get_def_trans (
                           l_matl_dtl.batch_id,
                           p_line_id,
                           l_doc_type
                        )
         LOOP
            l_pos := 10;
            OPEN cur_get_whse_ctl (get_rec.whse_code);
            FETCH cur_get_whse_ctl INTO l_whse_loct_ctl;
            CLOSE cur_get_whse_ctl;
            l_pos := 11;

            IF l_item_mst.lot_ctl = 1 OR
               (l_item_mst.loct_ctl > 0 AND
                l_whse_loct_ctl > 0
               ) THEN
               -- This should be the only transaction that was returned for lot or loct ctrl
               x_def_lot_id := get_rec.trans_id;
               x_is_plain := FALSE;
               l_def_lot_found := TRUE;
               -- If you find a lot or loct ctrl whse, then don't look any further.  Looking further may
               -- get you in trouble if there is a plain controlled transaction fetched after this record
               -- which belongs to the cons/respl whse for the item.  In that case, the plain txn will override
               -- this transaction and we definitely don't want that.
               l_pos := 12;
            ELSE
               IF l_def_lot_found = FALSE THEN
                  l_pos := 13;
                  x_is_plain := TRUE;
                  SELECT *
                    INTO l_ic_tran_pnd
                    FROM ic_tran_pnd
                   WHERE trans_id = get_rec.trans_id;
                  deduce_transaction_warehouse (
                     p_transaction => l_ic_tran_pnd,
                     p_item_master => l_item_mst,
                     x_whse_code => l_tran_whse
                  );
                  l_pos := 14;

                  IF (l_tran_whse = l_ic_tran_pnd.whse_code) THEN
                     x_def_lot_id := get_rec.trans_id;

                     IF l_ic_tran_pnd.completed_ind = 0 OR
                        l_ic_tran_pnd.trans_qty = 0 THEN
                        l_def_lot_found := TRUE;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         l_pos := 15;

         IF x_def_lot_id = 0 THEN
            l_pos := 16;
            OPEN cur_get_def_trans (
               l_matl_dtl.batch_id,
               p_line_id,
               l_doc_type
            );
            FETCH cur_get_def_trans INTO get_trans_rec;
            x_def_lot_id := get_trans_rec.trans_id;
            CLOSE cur_get_def_trans;
            x_is_plain := TRUE;
            l_pos := 17;
         END IF;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'D';
         insert_message (
            p_table_name => 'gme_inventory_txns_gtmp',
            p_procedure_name => 'get_default_lot',
            p_parameters => 'line_id= ' || p_line_id,
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => x_return_status
         );
   END get_default_lot;

   PROCEDURE deduce_transaction_warehouse (
      p_transaction   IN       ic_tran_pnd%ROWTYPE,
      p_item_master   IN       ic_item_mst%ROWTYPE,
      x_whse_code     OUT NOCOPY      ps_whse_eff.whse_code%TYPE
   ) IS
      CURSOR cur_eff_whse (
         p_orgn_code   VARCHAR2,
         p_item_id     NUMBER,
         p_line_type   NUMBER
      ) IS
         SELECT   whse_code
             FROM ps_whse_eff
            WHERE plant_code = p_orgn_code AND
                  (whse_item_id IS NULL OR whse_item_id = p_item_id) AND
                  ((p_line_type > 0 AND replen_ind = 1) OR
                   (p_line_type < 0 AND consum_ind = 1)
                  )
         ORDER BY whse_item_id, whse_code;
   BEGIN
      OPEN cur_eff_whse (
         p_transaction.orgn_code,
         p_item_master.whse_item_id,
         p_transaction.line_type
      );
      FETCH cur_eff_whse INTO x_whse_code;

      IF cur_eff_whse%NOTFOUND THEN
         x_whse_code := NULL;
      END IF;

      CLOSE cur_eff_whse;
   EXCEPTION
      WHEN OTHERS THEN
         x_whse_code := NULL;
   END deduce_transaction_warehouse;

/*****************************************************************
*    Shrikant Nene - 02/10/2003 B2792583                         *
*    Changed the reference of pm_matl_dt to pm_matl_dtl_bak  *
*     in the following procedure                                 *
*****************************************************************/

	PROCEDURE renumber_duplicate_line_no IS

		CURSOR cur_get_dup_line_no IS
			SELECT batch_id, line_type, line_no
			FROM   pm_matl_dtl_bak
			GROUP BY batch_id, line_type, line_no
			HAVING COUNT(1) > 1;

		CURSOR get_matl (v_batch_id NUMBER, v_line_type NUMBER) IS
         SELECT line_id
         FROM pm_matl_dtl_bak
         WHERE batch_id = v_batch_id
         AND line_type = v_line_type
         ORDER BY line_no asc;

      l_line_no NUMBER := 0;
      l_dup_rec cur_get_dup_line_no%ROWTYPE;

		l_dup_no	NUMBER := 0;
      l_pos NUMBER := 0;

	BEGIN
		l_pos := 1;

		l_dup_no := 0;

		OPEN cur_get_dup_line_no;
		l_pos := 2;
		FETCH cur_get_dup_line_no INTO l_dup_rec;
		l_pos := 3;

		WHILE cur_get_dup_line_no%FOUND LOOP
			l_pos := 4;

         insert_message (
                  p_table_name => 'pm_matl_dtl',
                  p_procedure_name => 'renumber_duplicate_line_no',
                  p_parameters => 'batch_id = '||l_dup_rec.batch_id||
                                 ' line_type = '||l_dup_rec.line_type||
                                 ' line_no = '||l_dup_rec.line_no,
                  p_message => 'Found batch with duplicate batch_id, line_type, line_no',
                  p_error_type => 'I'
			);

			l_pos := 4.1;

			l_dup_no := l_dup_no + 1;

         l_pos := 5;
         l_line_no := 1;
         l_pos := 6;
         FOR rec IN get_matl(l_dup_rec.batch_id, l_dup_rec.line_type) LOOP
            l_pos := 7;

            UPDATE pm_matl_dtl_bak
            SET line_no = l_line_no
            WHERE line_id = rec.line_id;

            l_pos := 8;
            l_line_no := l_line_no + 1;
            l_pos := 9;
         END LOOP;

         l_pos := 10;
			FETCH cur_get_dup_line_no INTO l_dup_rec;
         l_pos := 11;

		END LOOP;

      l_pos := 12;
		CLOSE cur_get_dup_line_no;

      l_pos := 13;

      insert_message (
         p_table_name => 'pm_matl_dtl',
         p_procedure_name => 'renumber_duplicate_line_no',
         p_parameters => 'none',
         p_message => 'Number of batches to renumber for duplicate batch_id/line_type/line_no = ' || l_dup_no,
         p_error_type => 'P'
      );

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'pm_matl_dtl',
            p_procedure_name => 'renumber_duplicate_line_no',
            p_parameters => 'none',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
	END renumber_duplicate_line_no;

	PROCEDURE renumber_blank_line_no IS

      CURSOR get_blank_line_batches IS
         SELECT d.batch_id, line_type, max(line_no) max_line_no,
						count(1) line_count
         FROM gme_material_details d, gme_batch_header b
         WHERE d.batch_id=b.batch_id
         AND batch_status in (1,2,3)
         AND batch_type = 0
         GROUP BY d.batch_id, line_type
         HAVING max(line_no) <> count(1);

      CURSOR get_matl (v_batch_id NUMBER, v_line_type NUMBER) IS
         SELECT material_detail_id
         FROM gme_material_details
         WHERE batch_id = v_batch_id
         AND line_type = v_line_type
         ORDER BY line_no asc;

      l_line_no NUMBER := 0;
      l_get_bl_batches get_blank_line_batches%ROWTYPE;

      l_pos NUMBER := 0;
		l_dup_no	NUMBER := 0;

   BEGIN

      l_pos := 1;
		l_dup_no := 0;

      OPEN get_blank_line_batches;
      l_pos := 2;
      FETCH get_blank_line_batches INTO l_get_bl_batches;
      l_pos := 3;
      WHILE get_blank_line_batches%FOUND LOOP
         l_pos := 4;
         insert_message (
                  p_table_name => 'gme_material_details',
                  p_procedure_name => 'renumber_blank_line_no',
                  p_parameters => 'batch_id = '||l_get_bl_batches.batch_id||
                                 ' line_type = '||l_get_bl_batches.line_type||
                                 ' max_line_no = '||
															l_get_bl_batches.max_line_no ||
                                 ' line_count = '||l_get_bl_batches.line_count,
                  p_message => 'Found batch that required renumbering',
                  p_error_type => 'I'
         );

			l_dup_no := l_dup_no + 1;
         l_pos := 5;
         l_line_no := 1;
         l_pos := 6;
         FOR rec IN get_matl(l_get_bl_batches.batch_id,
										l_get_bl_batches.line_type) LOOP
            l_pos := 7;

            UPDATE gme_material_details
            SET line_no = l_line_no
            WHERE material_detail_id = rec.material_detail_id;

            l_pos := 8;
            l_line_no := l_line_no + 1;
            l_pos := 9;
         END LOOP;

         l_pos := 10;
         FETCH get_blank_line_batches INTO l_get_bl_batches;
         l_pos := 11;
      END LOOP;

      l_pos := 12;
      insert_message (
         p_table_name => 'gme_material_details',
         p_procedure_name => 'renumber_blank_line_no',
         p_parameters => 'none',
         p_message => 'Number of batches to renumber for blank line_no = ' || l_dup_no,
         p_error_type => 'P'
      );

   EXCEPTION
      WHEN OTHERS THEN
         insert_message (
            p_table_name => 'gme_material_details',
            p_procedure_name => 'renumber_blank_line_no',
            p_parameters => 'none',
            p_message => SQLERRM || ' with pos = ' || l_pos,
            p_error_type => 'D'
         );
	END renumber_blank_line_no;

END migrate_batch;

/

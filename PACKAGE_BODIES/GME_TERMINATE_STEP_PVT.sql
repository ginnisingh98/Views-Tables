--------------------------------------------------------
--  DDL for Package Body GME_TERMINATE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_TERMINATE_STEP_PVT" AS
/*  $Header: GMEVTRSB.pls 120.1 2005/06/03 12:25:21 appldev  $    */
   g_debug      VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   VARCHAR2 (30) := 'GME_TERMINATE_STEP_PVT';

/*
REM *********************************************************************
REM *
REM * FILE:    GMEVTRSB.pls
REM * PURPOSE: Package Body for the GME step terminate api
REM * AUTHOR:  Pawan Kumar
REM * DATE:    2 May 2005
REM * HISTORY:
REM * ========
REM *
REM **********************************************************************
*/

   /*======================================================================================
Procedure
  Terminate_Step
Description
  This procedure call terminates WIP batch steps.
Parameters
  x_batch_step_rec       The batch step row to identify the step.
  x_return_status    outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
======================================================================================*/
   PROCEDURE terminate_step (
      p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,p_update_inventory_ind   IN              VARCHAR2
     ,p_actual_cmplt_date      IN              DATE
     ,x_batch_step_rec         OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2)
   IS
      /* Variable Declarations */
      l_resource_txns              gme_resource_txns_gtmp%ROWTYPE;
      l_resource_txns_tab          gme_common_pvt.resource_transactions_tab;
      l_resources_tab              gme_common_pvt.resources_tab;
      l_activities_tab             gme_common_pvt.activities_tab;
      l_api_name                   VARCHAR2 (20)          := 'Terminate_step';
      /* Exception declarations */
      batch_step_upd_err           EXCEPTION;
      resource_txns_gtmp_del_err   EXCEPTION;
      resource_upd_err             EXCEPTION;
      activity_upd_err             EXCEPTION;

      /* Cursor declarations */
      CURSOR cur_get_resources (v_batchstep_id NUMBER)
      IS
         SELECT *
           FROM gme_batch_step_resources
          WHERE batchstep_id = v_batchstep_id;

      CURSOR cur_get_activities (v_batchstep_id NUMBER)
      IS
         SELECT *
           FROM gme_batch_step_activities
          WHERE batchstep_id = v_batchstep_id;
   BEGIN
      /* Set the save point before processing */
      SAVEPOINT terminate_batch_step;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      -- Set the return status to success initially
      x_return_status := fnd_api.g_ret_sts_success;
      x_batch_step_rec := p_batch_step_rec;

      --   Current step status must be WIP to terminate step

      /*  IF x_batch_step_rec.step_status <> 2
        THEN
           RAISE invalid_step_status;
        END IF;
        Bug#  2841929(back port 2836788) We need to remove the
           resource information for the
           gme_batch_step_rsrc_summary table, as this table
           should only hold data of the resources which are in
           PENDING or WIP */
      DELETE FROM gme_batch_step_rsrc_summary
            WHERE batchstep_id = x_batch_step_rec.batchstep_id;

            /* Get all the activities associated with the step */
           /* OPEN cur_get_activities (x_batch_step.batchstep_id);
            FETCH cur_get_activities BULK COLLECT INTO l_activity_ids;
            CLOSE cur_get_activities;
      */
          --  FOR i IN 1 .. l_activity_ids.COUNT
           /* Pawan Kumar   - bug 3328047- removed bulk collect */
      OPEN cur_get_activities (x_batch_step_rec.batchstep_id);

      FETCH cur_get_activities
      BULK COLLECT INTO l_activities_tab;

      CLOSE cur_get_activities;

      FOR i IN 1 .. l_activities_tab.COUNT LOOP
         -- Update actual completion date for activities
         l_activities_tab (i).actual_cmplt_date := p_actual_cmplt_date;

         IF (l_activities_tab (i).actual_activity_factor IS NULL) THEN
            l_activities_tab (i).actual_activity_factor := 0;
         END IF;

         IF NOT (gme_batch_step_activities_dbl.update_row
                                                         (l_activities_tab (i) ) ) THEN
            RAISE activity_upd_err;
         END IF;
      END LOOP;                                    /*end for l_activity_tab */

      /* Get all the resources associated with the step */
      OPEN cur_get_resources (x_batch_step_rec.batchstep_id);

      FETCH cur_get_resources
      BULK COLLECT INTO l_resources_tab;

      CLOSE cur_get_resources;

      FOR i IN 1 .. l_resources_tab.COUNT LOOP
         -- Update actual completion date for resources
         l_resources_tab (i).actual_cmplt_date := p_actual_cmplt_date;

         IF l_resources_tab (i).actual_rsrc_count IS NULL THEN
            l_resources_tab (i).actual_rsrc_count := 0;
         END IF;

         IF l_resources_tab (i).actual_rsrc_usage IS NULL THEN
            l_resources_tab (i).actual_rsrc_usage := 0;
         END IF;

         IF l_resources_tab (i).actual_rsrc_qty IS NULL THEN
            l_resources_tab (i).actual_rsrc_qty := 0;
         END IF;

         IF NOT (gme_batch_step_resources_dbl.update_row (l_resources_tab (i) ) ) THEN
            RAISE resource_upd_err;
         END IF;

         IF (p_update_inventory_ind = 'Y') THEN
            l_resource_txns.line_id :=
                                    l_resources_tab (i).batchstep_resource_id;
            gme_resource_engine_pvt.fetch_active_resources
                                      (p_resource_rec       => l_resource_txns
                                      ,x_resource_tbl       => l_resource_txns_tab
                                      ,x_return_status      => x_return_status);

            -- Delete the pending resource transactions
            FOR j IN 1 .. l_resource_txns_tab.COUNT LOOP
               IF l_resource_txns_tab (j).completed_ind = 0 THEN
                  l_resource_txns_tab (j).action_code := 'DEL';

                  IF (g_debug <= gme_debug.g_log_procedure) THEN
                     gme_debug.put_line
                                   (   g_pkg_name
                                    || '.'
                                    || l_api_name
                                    || ':'
                                    || 'Calling  resource txn update)delete_row');
                  END IF;

                  IF NOT (gme_resource_txns_gtmp_dbl.update_row
                                   (p_resource_txns      => l_resource_txns_tab
                                                                           (j) ) ) THEN
                     RAISE resource_txns_gtmp_del_err;
                  END IF;
               END IF;                                 /* completed_ind = 0 */
            END LOOP;                         /*end for l_resource_txns_tab */
         END IF;                                  /* update_inventory = 'Y' */
      END LOOP;                                   /*end for l_resources_tab */

      --  Update the Batch Step Status to Completed
      x_batch_step_rec.step_status := 3;
      x_batch_step_rec.terminated_ind := 1;
      x_batch_step_rec.actual_cmplt_date := p_actual_cmplt_date;

      IF x_batch_step_rec.actual_step_qty IS NULL THEN
         x_batch_step_rec.actual_step_qty := 0;
      END IF;

      IF x_batch_step_rec.actual_charges IS NULL THEN
         x_batch_step_rec.actual_charges := 0;
      END IF;

      IF x_batch_step_rec.actual_mass_qty IS NULL THEN
         x_batch_step_rec.actual_mass_qty := 0;
      END IF;

      IF x_batch_step_rec.actual_volume_qty IS NULL THEN
         x_batch_step_rec.actual_volume_qty := 0;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || ' Calling  batch step update_row');
      END IF;

      IF NOT (gme_batch_steps_dbl.update_row (p_batch_step      => x_batch_step_rec) ) THEN
         RAISE batch_step_upd_err;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Exiting');
      END IF;
   EXCEPTION
      WHEN resource_txns_gtmp_del_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'RESOURCE_TXNS_GTMP_DEL_ERR.');
         END IF;

         ROLLBACK TO SAVEPOINT terminate_batch_step;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN resource_upd_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'RESOURCE_UPD_ERR.');
         END IF;

         ROLLBACK TO SAVEPOINT terminate_batch_step;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN activity_upd_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'ACTIVITY_UPD_ERR.');
         END IF;

         ROLLBACK TO SAVEPOINT terminate_batch_step;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_step_upd_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || ' terminate_step, error : BATCH_STEP_UPD_ERR.'
                             ,gme_debug.g_log_error
                             ,'terminate_step');
         END IF;

         ROLLBACK TO SAVEPOINT terminate_batch_step;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT terminate_batch_step;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END terminate_step;
END gme_terminate_step_pvt;

/

--------------------------------------------------------
--  DDL for Package Body GME_CANCEL_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_CANCEL_STEP_PVT" AS
/*  $Header: GMEVCCSB.pls 120.1 2005/06/03 12:26:37 appldev  $    */
   g_debug      VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   VARCHAR2 (30) := 'GME_CANCEL_STEP_PVT';

/*
REM *********************************************************************
REM *
REM * FILE:    GMEVCCSB.pls
REM * PURPOSE: Package Body for the GME step cancel api
REM * AUTHOR:  Pawan Kumar, OPM Development
REM * DATE:    28-April-2005
REM * HISTORY:
REM * ========

REM *
REM *
REM *
REM *
REM **********************************************************************
*/

   /*======================================================================================
Procedure
  Cancel_Step
Description
  This particular procedure call close the batch steps.
Parameters
  p_batch_step       The batch step row to identify the step.
  p_validation_level    Errors to skip before returning - Default 100
  x_message_count    The number of messages in the message stack
  x_message_list     message stack where the api writes its messages
  x_return_status    outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
======================================================================================*/
   PROCEDURE cancel_step (
      p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,p_update_inventory_ind   IN              VARCHAR2
     ,x_batch_step_rec         OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2)
   IS
      /* Miscellaneous */
      l_resource_tab               gme_common_pvt.number_tab;
      l_api_name                   VARCHAR2 (20)             := 'Cancel_step';
      /* Exception definitions */
      invalid_step_status          EXCEPTION;
      batch_step_upd_err           EXCEPTION;
      resource_txns_gtmp_del_err   EXCEPTION;
      l_resource_txns              gme_resource_txns_gtmp%ROWTYPE;
      l_resource_txns_tab          gme_common_pvt.resource_transactions_tab;

      CURSOR cur_get_resource_ids (v_batchstep_id NUMBER)
      IS
         SELECT batchstep_resource_id
           FROM gme_batch_step_resources
          WHERE batchstep_id = v_batchstep_id;
   BEGIN
      /* Set the save point before processing */
      SAVEPOINT cancel_batch_step;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      -- Set the return status to success initially
      x_return_status := fnd_api.g_ret_sts_success;
      -- Initialize output batch step
      x_batch_step_rec := p_batch_step_rec;

      -- remove the resource information for the gme_batch_step_rsrc_summary table
      IF p_update_inventory_ind = 'Y' THEN
         /* Get all the resources associated with the step */
         OPEN cur_get_resource_ids (x_batch_step_rec.batchstep_id);

         FETCH cur_get_resource_ids
         BULK COLLECT INTO l_resource_tab;

         CLOSE cur_get_resource_ids;

         FOR i IN 1 .. l_resource_tab.COUNT LOOP
            l_resource_txns.line_id := l_resource_tab (i);
            gme_resource_engine_pvt.fetch_active_resources
                                      (p_resource_rec       => l_resource_txns
                                      ,x_resource_tbl       => l_resource_txns_tab
                                      ,x_return_status      => x_return_status);

            -- Delete the resource transactions
            FOR j IN 1 .. l_resource_txns_tab.COUNT LOOP
               l_resource_txns_tab (j).action_code := 'DEL';

               IF (g_debug <= gme_debug.g_log_procedure) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || ' Calling  resource delete_row');
               END IF;

               IF NOT (gme_resource_txns_gtmp_dbl.update_row
                                   (p_resource_txns      => l_resource_txns_tab
                                                                           (j) ) ) THEN
                  RAISE resource_txns_gtmp_del_err;
               END IF;
            END LOOP;                         /*end for l_resource_txns_tab */
         END LOOP;                                 /*end for l_resource_tab */
      END IF;                            /* IF p_update_inventory_ind = 'Y' */

      --  Update the Batch Step Status to Cancel
      x_batch_step_rec.step_status := 5;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || ' Calling step update_row');
      END IF;

      IF NOT (gme_batch_steps_dbl.update_row (p_batch_step      => x_batch_step_rec) ) THEN
         RAISE batch_step_upd_err;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line ('Exiting ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN resource_txns_gtmp_del_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ':'
                          || ' cancel_step, error : RESOURCE_TXNS_GTMP_DEL_ERR.');
         END IF;

         ROLLBACK TO SAVEPOINT cancel_batch_step;
      WHEN batch_step_upd_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' cancel_step, error : BATCH_STEP_UPD_ERR.');
         END IF;

         ROLLBACK TO SAVEPOINT cancel_batch_step;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT cancel_batch_step;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END cancel_step;
END gme_cancel_step_pvt;

/

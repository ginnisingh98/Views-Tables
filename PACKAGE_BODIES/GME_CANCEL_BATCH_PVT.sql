--------------------------------------------------------
--  DDL for Package Body GME_CANCEL_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_CANCEL_BATCH_PVT" AS
/*  $Header: GMEVCCBB.pls 120.6.12010000.2 2009/03/23 13:38:54 gmurator ship $    */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_CANCEL_BATCH_PVT';

/*
REM *********************************************************************
REM *
REM * FILE:    GMEVCCBB.pls
REM * PURPOSE: Package Body for the GME batch cancel api
REM * AUTHOR:  Pawan Kumar, OPM Development
REM * DATE:    28th APRIL 2005
REM * HISTORY:
REM * ========
REM * Namit Singhi Bug#5411627. Removed the recursive call to purge_batch_exceptions,
REM * as recusive calls are already added to cancel_batch and terminate_batch APIs.

REM * G. Muratore   22-MAR-09  Bug 8312658 Rework of 5411627
REM *    Reintroduced recursive logic conditionally for those actions that require it. This code
REM *    was removed by bug 5411627 for cancel and terminate, but it is needed for complete batch.
REM *    New parameter p_recursive added. 'R' value will initiate recursive logic.
REM *    PROCEDURE:   purge_batch_exceptions
REM **********************************************************************
*/

   /*================================================================================
Procedure
  Cancel_Batch
Description
  This particular procedure call cancel the batch.
Parameters
  p_batch_header_rec     The batch header row to identify the batch
  p_validation_level    Errors to skip before returning - Default 100
  x_batch_header_rec      The batch header row to identify the batch
  x_message_count    The number of messages in the message stack
  x_message_list     message stack where the api writes its messages
  x_return_status    outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
================================================================================*/
   PROCEDURE cancel_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_steps (v_batch_id NUMBER)
      IS
         SELECT   *
             FROM gme_batch_steps
            WHERE batch_id = v_batch_id
         ORDER BY batchstep_id;

      /* Miscellaneous */
      l_batch_step_rec                 gme_batch_steps%ROWTYPE;
      l_in_batch_step_rec              gme_batch_steps%ROWTYPE;
      l_material_details_rec           gme_material_details%ROWTYPE;
      l_material_details_tab           gme_common_pvt.material_details_tab;
      l_batch_step_tab                 gme_common_pvt.steps_tab;
      l_batch_header_rec               gme_batch_header%ROWTYPE;
      l_ph_batch_header_rec            gme_batch_header%ROWTYPE;
      l_rsrc_trans_count               NUMBER;
      l_message_count                  NUMBER;                     -- 4944024
      l_message_data                   VARCHAR2(2000);             -- 4944024
      l_return_status           VARCHAR2 (1);
      l_api_name              CONSTANT VARCHAR2 (30)        := 'Cancel Batch';
      batch_header_upd_err             EXCEPTION;
      batch_step_cancel_error          EXCEPTION;
      purge_exception_err              EXCEPTION;
      batch_step_fetch_err             EXCEPTION;
      batch_hist_insert_err            EXCEPTION;
      phantom_batch_cancel_error       EXCEPTION;
      material_details_fetch_err       EXCEPTION;
      batch_header_fetch_failure       EXCEPTION;
      reservation_delete_err           EXCEPTION;                  -- 4944024
   BEGIN
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;
      x_batch_header_rec := p_batch_header_rec;
      -- Now Examine the ingredient material rows :
      l_material_details_rec.batch_id := x_batch_header_rec.batch_id;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Call fetch material tab');
      END IF;

      IF NOT (gme_material_details_dbl.fetch_tab
                                 (p_material_detail      => l_material_details_rec
                                 ,x_material_detail      => l_material_details_tab) ) THEN
         RAISE material_details_fetch_err;
      END IF;

      FOR i IN 1 .. l_material_details_tab.COUNT LOOP
         -- 4944024 BEGIN
         -- Need to delete any reservations agains PROD supply
         -- ===================================================
         IF l_material_details_tab(i).line_type <> -1 THEN
           IF (g_debug <= gme_debug.g_log_procedure) THEN
             gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || ' Call delete_prod_supply_resv');
           END IF;

           gme_supply_res_pvt.delete_prod_supply_resv (
             p_matl_dtl_rec         => l_material_details_tab(i)
            ,x_msg_count            => l_message_count
            ,x_msg_data             => l_message_data
            ,x_return_status        => x_return_status);

           IF (g_debug <= gme_debug.g_log_procedure) THEN
             gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || ' Return from delete_prod_supply_resv indicates '
                               || x_return_status);
           END IF;
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE reservation_delete_err;
           END IF;
         END IF;
         -- 4944024 END

         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'phantom_id='
                                || l_material_details_tab (i).phantom_id);
         END IF;
         -- IF PHANTOM_ID is not null,
         --    THEN recurse from the start for each one.
         IF (NVL (l_material_details_tab (i).phantom_id, 0) <> 0) THEN
            IF (g_debug <= gme_debug.g_log_procedure) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'calling cancel batch for phantom_id='
                                   || l_material_details_tab (i).phantom_id);
            END IF;

            -- Recursive call to the private API.
            l_batch_header_rec.batch_id :=
                                         l_material_details_tab (i).phantom_id;
            IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header_rec
                                                ,l_ph_batch_header_rec) ) THEN
              RAISE batch_header_fetch_failure;
            END IF;

            gme_cancel_batch_pvt.cancel_batch
                                 (p_batch_header_rec      => l_ph_batch_header_rec
                                 ,x_batch_header_rec      => l_batch_header_rec
                                 ,x_return_status         => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE phantom_batch_cancel_error;
            END IF;
         END IF;
      END LOOP;

      -- Delete the Inventory transaction under specific conditions
      IF x_batch_header_rec.update_inventory_ind = 'Y' THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'calling purge exceptions for batch_id='
                                || x_batch_header_rec.batch_id);
         END IF;

         -- delete all move-orders including invisble move orders
         purge_batch_exceptions (p_batch_header_rec         => x_batch_header_rec
                                ,p_delete_invis_mo          => 'T'
                                ,p_delete_reservations      => 'T'
                                ,p_delete_trans_pairs       => 'T'
                                ,x_return_status            => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE purge_exception_err;
         END IF;
      END IF;

      -- Now Examine the batch step(POC data) :
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Check routing_id/poc_ind='
                             || x_batch_header_rec.routing_id
                             || '/'
                             || x_batch_header_rec.poc_ind);
      END IF;

      IF x_batch_header_rec.poc_ind = 'Y' THEN
           /* Now update the batch step status to Cancel (5) */
         --  Get batch_step_ids bulk collected for batch
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'routing exists');
         END IF;

         OPEN cur_get_steps (x_batch_header_rec.batch_id);

         FETCH cur_get_steps
         BULK COLLECT INTO l_batch_step_tab;

         CLOSE cur_get_steps;

         FOR i IN 1 .. l_batch_step_tab.COUNT LOOP
            IF (g_debug <= gme_debug.g_log_procedure) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'calling cancel step for step_id='
                                   || l_batch_step_tab (i).batchstep_id);
            END IF;

            /* Call Close step api to cancel the all steps */
            -- This Proc should be written by someone else.
            l_batch_step_rec := l_batch_step_tab (i);
            l_in_batch_step_rec := l_batch_step_rec;
            gme_cancel_step_pvt.cancel_step
               (p_batch_step_rec            => l_in_batch_step_rec
               ,p_update_inventory_ind      => x_batch_header_rec.update_inventory_ind
               ,x_return_status             => l_return_status
               ,x_batch_step_rec            => l_batch_step_rec);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE batch_step_cancel_error;
            END IF;
         END LOOP;
      END IF;

      /* Set up the fields in output structure. */
      x_batch_header_rec.batch_status := -1;

      /* Update the batch status to the database */
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Call batch UPDATE_ROW'
                             || x_batch_header_rec.batch_status);
      END IF;

      IF NOT (gme_batch_header_dbl.update_row (x_batch_header_rec) ) THEN
         RAISE batch_header_upd_err;
      END IF;

      IF x_batch_header_rec.update_inventory_ind = 'Y' THEN
         -- Insert the event into the batch history table
         IF NOT gme_common_pvt.create_history (x_batch_header_rec, -1) THEN
            IF (g_debug <= gme_debug.g_log_procedure) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'create history');
            END IF;

            RAISE batch_hist_insert_err;
         END IF;
      END IF;

      /* Update the row who columns */
      x_batch_header_rec.last_update_date := gme_common_pvt.g_timestamp;
      x_batch_header_rec.last_updated_by := gme_common_pvt.g_user_ident;
      x_batch_header_rec.last_update_login := gme_common_pvt.g_login_id;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiating cancel batch with status'
                             || x_return_status);
      END IF;
   EXCEPTION
     WHEN purge_exception_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'purge_exception_err');
         END IF;

         x_return_status := l_return_status;
      WHEN material_details_fetch_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'MATERIAL_FETCH_ERROR');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
       WHEN batch_header_fetch_failure THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'BATCH_FETCH_ERROR');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN phantom_batch_cancel_error THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'PHANTOM_BATCH_CANCEL_ERROR');
         END IF;

         x_return_status := l_return_status;
      WHEN batch_header_upd_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'BATCH_HEADER_UPD_ERR');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_BATCH_HEADER_UPD_ERROR');
      WHEN batch_hist_insert_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'BATCH_HIST_INSERT_ERR.');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_step_fetch_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' BATCH_STEP_FETCH_ERR.');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_step_cancel_error THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' BATCH_STEP_CANCEL_ERROR.');
         END IF;

         x_return_status := l_return_status;
      -- 4944024 BEGIN
      WHEN reservation_delete_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' DELETE_PROD_SUPPLY_RESV ERROR');
         END IF;
      -- 4944024 END
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END cancel_batch;



   PROCEDURE purge_batch_exceptions (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_delete_invis_mo       IN              VARCHAR2 := 'F'
     ,p_delete_reservations   IN              VARCHAR2 := 'F'
     ,p_delete_trans_pairs    IN              VARCHAR2 := 'F'
     ,p_recursive             IN              VARCHAR2 := 'N'
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS

      l_material_details_rec           gme_material_details%ROWTYPE;
      l_material_details_tab           gme_common_pvt.material_details_tab;
      l_batch_header_rec               gme_batch_header%ROWTYPE;
      l_ph_batch_header_rec            gme_batch_header%ROWTYPE;
      l_api_name         CONSTANT 	VARCHAR2 (30)   := 'purge_batch_exceptions';
      delete_reservations_err     	EXCEPTION;
      delete_move_order_err       	EXCEPTION;
      delete_trans_pair_err       	EXCEPTION;
      delete_pend_prod_lots_err   	EXCEPTION;
      phantom_batch_purge_error	  	EXCEPTION;
      material_details_fetch_err       	EXCEPTION;
      batch_header_fetch_failure       	EXCEPTION;
      l_return_status             	VARCHAR2(1);
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_batch_header_rec := p_batch_header_rec;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'batch_id:'
                             || l_batch_header_rec.batch_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'organization_id:'
                             || l_batch_header_rec.organization_id);
      END IF;
       l_material_details_rec.batch_id := l_batch_header_rec.batch_id;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Call fetch material tab');
      END IF;

      IF NOT (gme_material_details_dbl.fetch_tab
                                 (p_material_detail      => l_material_details_rec
                                 ,x_material_detail      => l_material_details_tab) ) THEN
         RAISE material_details_fetch_err;
      END IF;

      -- Bug 8312658 - Reintroduced recursive logic conditionally for those actions that require it here.
      -- This code was removed by bug 5411627 for cancel and terminate, but it is needed for complete batch.
      IF p_recursive = 'R' THEN
         FOR i IN 1 .. l_material_details_tab.COUNT LOOP
            IF (g_debug <= gme_debug.g_log_procedure) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'phantom_id='
                                   || l_material_details_tab (i).phantom_id);
            END IF;
            -- IF PHANTOM_ID is not null,
            --    THEN recurse from the start for each one.
            IF (NVL (l_material_details_tab (i).phantom_id, 0) <> 0) THEN
               IF (g_debug <= gme_debug.g_log_procedure) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'calling purge batch for phantom_id='
                                      || l_material_details_tab (i).phantom_id);
               END IF;

               -- Recursive call to the private API.
               l_ph_batch_header_rec.batch_id :=
                                            l_material_details_tab (i).phantom_id;
               IF NOT (gme_batch_header_dbl.fetch_row (l_ph_batch_header_rec
                                                   ,l_ph_batch_header_rec) ) THEN
                 RAISE batch_header_fetch_failure;
               END IF;

                purge_batch_exceptions (p_batch_header_rec    => l_ph_batch_header_rec
                                   ,p_delete_invis_mo          => p_delete_invis_mo
                                   ,p_delete_reservations      => p_delete_reservations
                                   ,p_delete_trans_pairs       => p_delete_trans_pairs
                                   ,x_return_status            => l_return_status);

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE phantom_batch_purge_error;
               END IF;
            END IF;
         END LOOP;
      END IF; -- If p_recursive = 'R'


      -- delete move orders
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'deleting move orders for batch_id:'
                             || l_batch_header_rec.batch_id);
      END IF;

       gme_move_orders_pvt.delete_batch_move_orders
                      (p_organization_id      => l_batch_header_rec.organization_id
                      ,p_batch_id             => l_batch_header_rec.batch_id
                      ,p_delete_invis         => p_delete_invis_mo
                      ,x_return_status        => l_return_status);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE delete_move_order_err;
       END IF;

      IF p_delete_reservations  = fnd_api.g_true THEN
      -- delete all reservations
      	IF (g_debug <= gme_debug.g_log_statement) THEN
      	   gme_debug.put_line (   g_pkg_name
      	                       || '.'
      	                       || l_api_name
      	                       || ':'
      	                       || 'deleting reservations for batch_id:'
      	                       || l_batch_header_rec.batch_id);
      	END IF;

      	gme_reservations_pvt.delete_batch_reservations
      	               (p_organization_id      => l_batch_header_rec.organization_id
      	               ,p_batch_id             => l_batch_header_rec.batch_id
      	               ,x_return_status        => l_return_status);

      	IF l_return_status <> fnd_api.g_ret_sts_success THEN
      	   RAISE delete_reservations_err;
      	END IF;
      END IF;

      IF p_delete_trans_pairs = fnd_api.g_true THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || 'deleting trans pairs for batch_id:'
                               || l_batch_header_rec.batch_id);
        END IF;

        gme_transactions_pvt.purge_trans_pairs
                                     (p_batch_id           => l_batch_header_rec.batch_id
                                     ,x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           RAISE delete_trans_pair_err;
        END IF;
      END IF;
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'deleting pending product lots for batch_id:'
                             || l_batch_header_rec.batch_id);
      END IF;

      delete_pending_lots (p_batch_id           => l_batch_header_rec.batch_id
                          ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE delete_pend_prod_lots_err;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN material_details_fetch_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'MATERIAL_FETCH_ERROR');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
       WHEN batch_header_fetch_failure THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'BATCH_FETCH_ERROR');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN phantom_batch_purge_error THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'delete_move_order_err');
         END IF;

         x_return_status := l_return_status;
      WHEN delete_move_order_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'delete_move_order_err');
         END IF;

         x_return_status := l_return_status;
      WHEN delete_reservations_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'delete_reservations_err');
         END IF;

         x_return_status := l_return_status;
       WHEN delete_trans_pair_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'delete_trans_pair_err');
         END IF;

         x_return_status := l_return_status;
      WHEN delete_pend_prod_lots_err THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'delete_pend_prod_lots_err');
         END IF;

         x_return_status := l_return_status;
         WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END purge_batch_exceptions;

   PROCEDURE delete_pending_lots (
      p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2)
   IS
      l_batch_id             NUMBER;
      l_material_detail_id   NUMBER;
      l_api_name    CONSTANT VARCHAR2 (30) := 'delete_pending_lots';
      l_return_status           VARCHAR2 (1);
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF p_batch_id IS NULL AND p_material_detail_id IS NULL THEN
         -- may use required message
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_batch_id');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batch_id := p_batch_id;
      l_material_detail_id := p_material_detail_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'batch_id:'
                             || l_batch_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'material_detail_id:'
                             || l_material_detail_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         DELETE FROM gme_pending_product_lots
               WHERE batch_id = l_batch_id;
      ELSIF l_material_detail_id IS NOT NULL THEN
         DELETE FROM gme_pending_product_lots
               WHERE material_detail_id = l_material_detail_id;
      ELSE
         DELETE FROM gme_pending_product_lots
               WHERE batch_id = l_batch_id
                 AND material_detail_id = l_material_detail_id;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;
   END delete_pending_lots;
END gme_cancel_batch_pvt;

/

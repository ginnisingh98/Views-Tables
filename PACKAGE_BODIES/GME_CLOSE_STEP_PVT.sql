--------------------------------------------------------
--  DDL for Package Body GME_CLOSE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_CLOSE_STEP_PVT" AS
/* $Header: GMEVCLSB.pls 120.3 2006/05/15 05:30:31 svgonugu noship $ */
   g_debug   VARCHAR2 (5) := fnd_profile.VALUE ('AFLOG_LEVEL');

   /*======================================================================================
   Procedure
     close_step
   Description
     This particular procedure call close the batch steps.
   Parameters
     p_api_version         For version specific processing - Default 1
     p_validation_level    Errors to skip before returning - Default 100
     p_init_msg_list    Signals wether the message stack should be initialised
     p_commit        Indicator to commit the changes made
     p_batch_step_rec       The batch step row to identify the step.
     x_message_count    The number of messages in the message stack
     x_message_list     message stack where the api writes its messages
     x_return_status    outcome of the API call
               S - Success
               E - Error
               U - Unexpected error
   ======================================================================================*/
   PROCEDURE close_step (
      p_batch_step_rec   IN              gme_batch_steps%ROWTYPE
     ,p_delete_pending   IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,x_batch_step_rec   OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      /* Miscellaneous */
      l_batch_header             gme_batch_header%ROWTYPE;
      l_in_batch_header          gme_batch_header%ROWTYPE;
      l_return_status            VARCHAR2 (1);
      preceding_step_closed      VARCHAR2 (1)                          := 'Y';
      l_pend_exists              BOOLEAN;
      l_mat_row_count            NUMBER;
      l_rsc_row_count            NUMBER;
      l_phantom_ids              gme_common_pvt.number_tab;
      l_material_ids             gme_common_pvt.number_tab;
      l_tran_row                 gme_inventory_txns_gtmp%ROWTYPE;
      l_default_row              gme_inventory_txns_gtmp%ROWTYPE;
      /* Exception definations */
      batch_step_fetch_error     EXCEPTION;
      invalid_step_status        EXCEPTION;
      close_phant_error          EXCEPTION;
      invalid_batch_status       EXCEPTION;
      batch_header_fetch_error   EXCEPTION;
      step_status_closed         EXCEPTION;
      dep_step_closed_error      EXCEPTION;
      batch_step_upd_err         EXCEPTION;
      gme_invalid_date_range     EXCEPTION;
      invalid_batch_type         EXCEPTION;
      pend_trans_err             EXCEPTION;
      fetch_trans_err            EXCEPTION;
      trans_delete_err           EXCEPTION;
      trans_update_err           EXCEPTION;

      /* This cursor fetches all the steps on which the given step
         is dependent  */
      CURSOR cur_dep_steps
      IS
         SELECT d.dep_step_id, s.step_status
           FROM gme_batch_step_dependencies d, gme_batch_steps s
          WHERE d.batchstep_id = p_batch_step_rec.batchstep_id
            AND s.batchstep_id = d.dep_step_id;

      CURSOR cur_material_ids (v_batchstep_id IN NUMBER)
      IS
         SELECT m.material_detail_id
           FROM gme_material_details m, gme_batch_step_items i
          WHERE m.material_detail_id = i.material_detail_id
            AND i.batchstep_id = v_batchstep_id;

      l_dep_steps_rec            cur_dep_steps%ROWTYPE;
      --Bug#5109119
      error_close_period         EXCEPTION;
   BEGIN
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Initialize output batch step */
      IF NOT (gme_batch_steps_dbl.fetch_row (p_batch_step_rec
                                            ,x_batch_step_rec) ) THEN
         RAISE batch_step_fetch_error;
      END IF;

      l_batch_header.batch_id := x_batch_step_rec.batch_id;

      /* Initialize local batch header */
      IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header, l_batch_header) ) THEN
         RAISE batch_header_fetch_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Closing step '
                             || l_batch_header.batch_no
                             || '/'
                             || x_batch_step_rec.batchstep_no
                             || ' at '
                             || TO_CHAR (p_batch_step_rec.step_close_date
                                        ,'DD-MON-YYYY HH24:MI:SS') );
      END IF;

      /* Check that its a batch and not FPO */
      IF l_batch_header.batch_type = 10 THEN
         RAISE invalid_batch_type;
      END IF;

      /* Batch must be at least wip to close a batch step */
      IF l_batch_header.batch_status = 1 THEN
         RAISE invalid_batch_status;
      END IF;

      /* Return if step status is already closed */
      /* This is not failure but the status will be return with success */
      IF x_batch_step_rec.step_status = 4 THEN
         RAISE step_status_closed;
      /*   Current step status must be certified to close step */
      ELSIF x_batch_step_rec.step_status <> 3 THEN
         RAISE invalid_step_status;
      END IF;

      IF l_batch_header.batch_status = 4 THEN
         x_batch_step_rec.step_status := 4;
      ELSE
         -- coded add for closing the dependent steps only if ASQC is on
         /* Bharati Satpute Bug2395188, Added check for the enforce step dependency*/
         IF    l_batch_header.automatic_step_calculation = 1
            OR l_batch_header.enforce_step_dependency = 1 THEN
            OPEN cur_dep_steps;

            FETCH cur_dep_steps
             INTO l_dep_steps_rec;

            WHILE cur_dep_steps%FOUND LOOP
               IF l_dep_steps_rec.step_status <> 4 THEN
                  CLOSE cur_dep_steps;

                  RAISE dep_step_closed_error;
               END IF;

               /* Bug 2395188 with hanging of close step API fixed */
               FETCH cur_dep_steps
                INTO l_dep_steps_rec;
            END LOOP;

            CLOSE cur_dep_steps;
         END IF;

         /*  Update the Batch Step Status to Close */
         x_batch_step_rec.step_status := 4;
      END IF;

      /* If a valid step_close_date is supplied by user, use it */
      IF p_batch_step_rec.step_close_date IS NOT NULL THEN
         /* Validate Date  */
         IF p_batch_step_rec.step_close_date >=
                                           p_batch_step_rec.actual_cmplt_date THEN
            x_batch_step_rec.step_close_date :=
                                             p_batch_step_rec.step_close_date;
         ELSE
            gme_common_pvt.log_message ('GME_INVALID_DATE_RANGE'
                                       ,'DATE1'
                                       ,'Close Date'
                                       ,'DATE2'
                                       ,'Completion Date');
            RAISE gme_invalid_date_range;
         END IF;                                 /* >= step completion date */
	 x_batch_step_rec.step_close_date := p_batch_step_rec.step_close_date;
      ELSE
         x_batch_step_rec.step_close_date := gme_common_pvt.g_timestamp;
      END IF;                                /* step close date is not null */

      --Bug#5109119 check for close period
      IF NOT gme_common_pvt.check_close_period(p_org_id     => l_batch_header.organization_id
                                              ,p_trans_date => x_batch_step_rec.step_close_date) THEN
        RAISE error_close_period;
      END IF;

      /* Update the batch step to the database */

      IF NOT (gme_batch_steps_dbl.update_row (x_batch_step_rec) ) THEN
         RAISE batch_step_upd_err;
      END IF;

      x_batch_step_rec.last_update_date := gme_common_pvt.g_timestamp;
      x_batch_step_rec.last_updated_by := gme_common_pvt.g_user_ident;
      x_batch_step_rec.last_update_login := gme_common_pvt.g_login_id;

      /* For any ingredient lines attached with the step we have to */
      /* close any phantom batches associated with it               */
      /* We need to do this only if close step is
         called standalone. If this procedure is called from
         close batch, then all the phantom batches are already closed */
      IF l_batch_header.batch_status <> 4 THEN
         gme_phantom_pvt.fetch_step_phantoms
                            (p_batch_id                    => x_batch_step_rec.batch_id
                            ,p_batchstep_id                => x_batch_step_rec.batchstep_id
                            ,p_all_release_type_assoc      => 0
                            ,x_phantom_ids                 => l_phantom_ids
                            ,x_return_status               => l_return_status);

         IF l_return_status <> x_return_status THEN
            RAISE close_phant_error;
         END IF;

         FOR i IN 1 .. l_phantom_ids.COUNT LOOP
            l_batch_header.batch_id := l_phantom_ids (i);
            l_batch_header.batch_close_date :=
                                             x_batch_step_rec.step_close_date;
            l_in_batch_header := l_batch_header;
            gme_close_batch_pvt.close_batch
                                    (p_batch_header_rec      => l_in_batch_header
                                    ,x_batch_header_rec      => l_batch_header
                                    ,x_return_status         => l_return_status);

            IF l_return_status <> x_return_status THEN
               RAISE close_phant_error;
            END IF;
         END LOOP;
      END IF;                           /* l_batch_header.batch_status <> 4 */
   EXCEPTION
      WHEN batch_step_fetch_error OR batch_header_fetch_error OR error_close_period THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_batch_status THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_INV_BATCH_CLOSE_STEP');
      WHEN invalid_batch_type THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('INVALID_BATCH_TYPE_CLS_STEP');
      WHEN step_status_closed THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_CLOSE_STEP_STATUS');
      WHEN invalid_step_status THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_INV_STAT_STEP_CLS');
      WHEN dep_step_closed_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_DEP_STEP_N_CLS');
      WHEN batch_step_upd_err THEN
         gme_common_pvt.log_message ('GME_API_STEP_UPD_ERROR');
      WHEN gme_invalid_date_range THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN close_phant_error OR trans_update_err OR trans_delete_err OR fetch_trans_err THEN
         x_return_status := l_return_status;
      WHEN pend_trans_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_PENDING_TRANS_ERROR');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CLOSE_STEP', 'CLOSE_STEP');
   END close_step;
END gme_close_step_pvt;

/

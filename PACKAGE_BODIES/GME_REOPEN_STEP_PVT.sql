--------------------------------------------------------
--  DDL for Package Body GME_REOPEN_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_REOPEN_STEP_PVT" AS
   /*  $Header: GMEVROSB.pls 120.1 2005/06/03 14:22:02 appldev  $    */
   g_debug   VARCHAR2 (5) := fnd_profile.VALUE ('AFLOG_LEVEL');

   /*
   REM *********************************************************************
   REM *                                                                   *
   REM * FILE:    GMEVROSB.pls                                             *
   REM * PURPOSE: Package Body for the GME step re-open api                *
   REM * AUTHOR:  Navin Sinha, OPM Development                             *
   REM * DATE:    May 19 2005                                              *
   REM * HISTORY:                                                          *
   REM * ========                                                          *
   REM *********************************************************************
   */

   /*======================================================================================
   Procedure
     Reopen_All_Steps
   Description
     This particular procedure call re-open the batch steps.
   Parameters
     p_batch_header_rec          The batch header row to identify the header.
     p_validation_level    Errors to skip before returning - Default 100
                                    when p_validation_level=0, then called from Re-open batch PVT
     x_message_count    The number of messages in the message stack
     x_message_list     message stack where the api writes its messages
     x_return_status    outcome of the API call
               S - Success
               E - Error
               U - Unexpected error
   ======================================================================================*/
   PROCEDURE reopen_all_steps (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      /* Local variables */
      l_batch_steps_tab       gme_close_batch_pvt.step_details_tab;
      l_batch_header          gme_batch_header%ROWTYPE;
      l_in_batch_header       gme_batch_header%ROWTYPE;
      l_phantom_ids           gme_common_pvt.number_tab;
      l_return_status         VARCHAR2 (1);
      batch_step_fetch_err    EXCEPTION;
      batch_step_reopen_err   EXCEPTION;
      batch_step_upd_err      EXCEPTION;
      reopen_phant_error      EXCEPTION;
   BEGIN
      /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;
      /* Get all the step into the tab */
      gme_close_batch_pvt.fetch_batch_steps
                                  (p_batch_id           => p_batch_header_rec.batch_id
                                  ,p_batchstep_id       => NULL
                                  ,x_step_tbl           => l_batch_steps_tab
                                  ,x_return_status      => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_step_fetch_err;
      END IF;

      FOR i IN 1 .. l_batch_steps_tab.COUNT LOOP
         -- Only reopen closed steps.
         IF l_batch_steps_tab (i).step_status = 4 THEN
            l_batch_steps_tab (i).step_close_date := NULL;
            l_batch_steps_tab (i).step_status := 3;

            -- Update Batch Step Record
            IF NOT (gme_batch_steps_dbl.update_row
                                        (p_batch_step      => l_batch_steps_tab
                                                                           (i) ) ) THEN
               RAISE batch_step_upd_err;
            END IF;

            /* For any ingredient lines attached with the step we have to */
            /* reopen any phantom batches associated with it               */
            gme_phantom_pvt.fetch_step_phantoms
                         (p_batch_id                    => l_batch_steps_tab
                                                                           (i).batch_id
                         ,p_batchstep_id                => l_batch_steps_tab
                                                                           (i).batchstep_id
                         ,p_all_release_type_assoc      => 0
                         ,x_phantom_ids                 => l_phantom_ids
                         ,x_return_status               => l_return_status);

            IF l_return_status <> x_return_status THEN
               RAISE reopen_phant_error;
            END IF;

            FOR i IN 1 .. l_phantom_ids.COUNT LOOP
               l_batch_header.batch_id := l_phantom_ids (i);
               l_in_batch_header := l_batch_header;
               gme_reopen_batch_pvt.reopen_batch
                                    (p_batch_header_rec      => l_in_batch_header
                                    ,x_batch_header_rec      => l_batch_header
                                    ,p_reopen_steps          => 'T'
                                    ,x_return_status         => l_return_status);

               IF l_return_status <> x_return_status THEN
                  RAISE reopen_phant_error;
               END IF;
            END LOOP;
         END IF;                                         /* step_status = 4 */
      END LOOP;
   EXCEPTION
      WHEN batch_step_fetch_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_step_upd_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_step_reopen_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_BATCH_STEP_REOPEN_ERR');
      WHEN reopen_phant_error THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_REOPEN_STEP_PVT', 'REOPEN_ALL_STEPS');
   END reopen_all_steps;

   /*======================================================================================
   Procedure
     Reopen_Step
   Description
     This particular procedure call re-open the batch steps.
   Parameters
     p_batch_step_rec       The batch step row to identify the step.
     x_return_status    outcome of the API call
               S - Success
               E - Error
               U - Unexpected error
   ======================================================================================*/
   PROCEDURE reopen_step (
      p_batch_step_rec   IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec   OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      /* Miscellaneous */
      l_batch_status         NUMBER;
      l_batch_header         gme_batch_header%ROWTYPE;
      l_in_batch_header      gme_batch_header%ROWTYPE;
      l_auto                 NUMBER                     := 0;
      l_count                NUMBER                     := 0;
      l_enforce_step_dep     NUMBER                     := -1;
      /* Exception definitions */
      batch_step_fetch_err   EXCEPTION;
      invalid_batch_status   EXCEPTION;
      invalid_step_status    EXCEPTION;
      batch_step_upd_err     EXCEPTION;
      reopen_phant_error     EXCEPTION;
      batch_depend_step      EXCEPTION;

      /* Database cursors for various tables*/
      CURSOR cur_batch_status (l_batch_id IN NUMBER)
      IS
         SELECT batch_status, automatic_step_calculation
               ,enforce_step_dependency
           FROM gme_batch_header
          WHERE batch_id = l_batch_id;

      CURSOR cur_fetch_dep_steps (l_batchstep_id IN NUMBER, l_batch_id NUMBER)
      IS
         SELECT COUNT (*)
           FROM gme_batch_step_dependencies gbsd, gme_batch_steps gbs
          WHERE gbs.batchstep_id = gbsd.batchstep_id
            AND gbsd.dep_step_id = l_batchstep_id
            AND gbs.batch_id = l_batch_id
            AND gbsd.batch_id = gbs.batch_id
            AND gbsd.dep_type = 0
            AND gbs.step_status = 4;

      l_return_status        VARCHAR2 (1);
      l_phantom_ids          gme_common_pvt.number_tab;
   BEGIN
      -- Set the return status to success initially
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT (gme_batch_steps_dbl.fetch_row (p_batch_step      => p_batch_step_rec
                                            ,x_batch_step      => x_batch_step_rec) ) THEN
         RAISE batch_step_fetch_err;
      END IF;

      -- Batch can be Certified(3) or WIP(2) to re-open its closed step
      OPEN cur_batch_status (x_batch_step_rec.batch_id);

      FETCH cur_batch_status
       INTO l_batch_status, l_auto, l_enforce_step_dep;

      CLOSE cur_batch_status;

      IF l_batch_status NOT IN (2, 3) THEN
         RAISE invalid_batch_status;
      END IF;

      -- Return if step status is already closed
      -- Current step status must be closed to reopen step
      IF x_batch_step_rec.step_status <> 4 THEN
         RAISE invalid_step_status;
      END IF;

      -- Added check for enforce_step_dep also
      IF (l_auto = 1) OR (l_enforce_step_dep = 1) THEN
         OPEN cur_fetch_dep_steps (x_batch_step_rec.batchstep_id
                                  ,x_batch_step_rec.batch_id);

         FETCH cur_fetch_dep_steps
          INTO l_count;

         CLOSE cur_fetch_dep_steps;

         IF l_count > 0 THEN
            RAISE batch_depend_step;
         END IF;
      END IF;

      --  Update the Batch Step Status to Certified and step close date to NULL
      x_batch_step_rec.step_close_date := NULL;
      x_batch_step_rec.step_status := 3;

      --  Update Batch Step Record
      IF NOT (gme_batch_steps_dbl.update_row (p_batch_step      => x_batch_step_rec) ) THEN
         RAISE batch_step_upd_err;
      END IF;

      x_batch_step_rec.last_update_date := gme_common_pvt.g_timestamp;
      x_batch_step_rec.last_updated_by := gme_common_pvt.g_user_ident;
      x_batch_step_rec.last_update_login := gme_common_pvt.g_login_id;
      /* For any ingredient lines attached with the step we have to */
      /* reopen any phantom batches associated with it */
      gme_phantom_pvt.fetch_step_phantoms
                             (p_batch_id                    => x_batch_step_rec.batch_id
                             ,p_batchstep_id                => x_batch_step_rec.batchstep_id
                             ,x_phantom_ids                 => l_phantom_ids
                             ,p_all_release_type_assoc      => 0
                             ,x_return_status               => l_return_status);

      IF l_return_status <> x_return_status THEN
         RAISE reopen_phant_error;
      END IF;

      FOR i IN 1 .. l_phantom_ids.COUNT LOOP
         l_batch_header.batch_id := l_phantom_ids (i);
         l_in_batch_header := l_batch_header;
         gme_reopen_batch_pvt.reopen_batch
                                    (p_batch_header_rec      => l_in_batch_header
                                    ,x_batch_header_rec      => l_batch_header
                                    ,p_reopen_steps          => 'F'
                                    ,x_return_status         => l_return_status);

         IF l_return_status <> x_return_status THEN
            RAISE reopen_phant_error;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN batch_step_fetch_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_batch_status THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_INV_BATCH_STATUS_REOP');
      WHEN invalid_step_status THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_INV_STEP_STATUS_REOP');
      WHEN batch_depend_step THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_DEP_STEP_REOPEN');
      WHEN batch_step_upd_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN reopen_phant_error THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_REOPEN_STEP_PVT', 'REOPEN_STEP');
   END reopen_step;
END gme_reopen_step_pvt;

/

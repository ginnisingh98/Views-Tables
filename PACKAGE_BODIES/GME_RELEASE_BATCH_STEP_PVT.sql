--------------------------------------------------------
--  DDL for Package Body GME_RELEASE_BATCH_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_RELEASE_BATCH_STEP_PVT" AS
/* $Header: GMEVRLSB.pls 120.12.12010000.3 2009/06/29 14:04:26 gmurator ship $ */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_release_batch_step_pvt';
   l_first_step_start_date     DATE;

/*===========================================================================================
Procedure
  release_step
Description
  This procedure call releases a batch step and dependent steps
  if the step is automatic.

Parameters
  p_batch_step_rec   The batch step record to release.
  p_batch_header_rec The batch header of the batch that the step belongs to.
  x_batch_step_rec   Output updated batch step record.
  x_exception_material_tbl Table of records of exceptions found while releasing the step, any dependent steps
                           and possibly the batch (if it was released).
  x_return_status    outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
            X - Exceptions found
=============================================================================================*/
   PROCEDURE release_step (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name      CONSTANT VARCHAR2 (30)              := 'RELEASE_STEP';
      /* Exception definitions */
      error_release_batch      EXCEPTION;
      error_release_step_rec   EXCEPTION;
      /* Local variables */
      l_return_status          VARCHAR2 (1);
      l_batch_header_rec       gme_batch_header%ROWTYPE;
      l_batch_step_rec         gme_batch_steps%ROWTYPE;
      --Bug#5109119
      l_in_batch_header_rec    gme_batch_header%ROWTYPE;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Releasing batch_step_id='
                             || p_batch_step_rec.batchstep_id);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      l_batch_step_rec := p_batch_step_rec;
      l_batch_header_rec := p_batch_header_rec;

      /* Bug#5109119 initialize with NULL and it should be NULL as we are testing
         for NULL value later in our code.
       */
      l_first_step_start_date := NULL;

      release_step_recursive
                        (p_batch_step_rec              => l_batch_step_rec
                        ,p_batch_header_rec            => l_batch_header_rec
                        ,x_batch_step_rec              => x_batch_step_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => l_return_status);

      IF l_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         x_return_status := l_return_status;
         RAISE error_release_step_rec;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
         x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;

      /*Bug#5109119 moved the release batch call (which is there before call to release_step_recursive)
        moved here because first step actual start date will be available if and only if the above procedure returns
      */
      /* If the batch status is Pending, then release the batch...  */
      /* check that this is valid already done in Pub               */
      IF (p_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending) THEN
         /* Bug#5109119 intialize Batch actual start date with the passed one or with the calculated
	    first step actual start date no need to check for close period here as it's one of the step actual start
	    dates and already validated in process_Dependent_steps procedure*/
	 l_in_batch_header_rec := p_batch_header_rec;
         l_in_batch_header_rec.actual_start_date := NVL(l_first_step_start_date,p_batch_step_rec.actual_start_date);

         gme_release_batch_pvt.release_batch
                        (p_batch_header_rec            => l_in_batch_header_rec
                        ,p_phantom_product_id          => NULL
                        ,x_batch_header_rec            => l_batch_header_rec
                        ,x_return_status               => l_return_status
                        ,x_exception_material_tbl      => x_exception_material_tbl);

         IF l_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
            x_return_status := l_return_status;
            RAISE error_release_batch;
         END IF;

         IF l_return_status = gme_common_pvt.g_exceptions_err THEN
            x_return_status := gme_common_pvt.g_exceptions_err;
         END IF;
      END IF;


      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN error_release_batch OR error_release_step_rec THEN
         NULL;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_step;

/*===========================================================================================
Procedure
  release_step_recursive
Description
  Recursively call this procedure for dependent steps based on the dependency.
  Once recursion stops, release the step.  Releasing must be an end of recursion process
Parameters
  p_batch_step_rec   The batch step record to release.
  p_batch_header_rec The batch header of the batch that the step belongs to.
  x_batch_step_rec   Output updated batch step record.
  x_exception_material_tbl Table of records of exceptions found while releasing the step, any dependent steps
  x_return_status    outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
            X - Exception found
=============================================================================================*/
   PROCEDURE release_step_recursive (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT VARCHAR2 (30)   := 'release_step_recursive';
      step_rel_cmpl_closed      EXCEPTION;
      rel_step_line_error       EXCEPTION;
      rel_step_ing_error        EXCEPTION;
      update_step_qty_error     EXCEPTION;
      error_process_dep_steps   EXCEPTION;
      error_validation          EXCEPTION;
      /* Local variables */
      l_return_status           VARCHAR2 (1);
      l_msg_count               NUMBER;
      l_msg_stack               VARCHAR2 (2000);
      l_in_batch_step_rec       gme_batch_steps%ROWTYPE;
      l_batch_step_rec          gme_batch_steps%ROWTYPE;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Release step recursive batch_step_id='
                             || p_batch_step_rec.batchstep_id);
         gme_debug.put_line(g_pkg_name
                             || '.'
                             || l_api_name
                             || ' step actual start date='
                             || to_char(p_batch_step_rec.actual_start_date,'YYYY-MON-DD HH24:MI:SS'));
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Exit the recursive loop if the step is already released, completed or closed */
      IF p_batch_step_rec.step_status IN
            (gme_common_pvt.g_step_wip
            ,gme_common_pvt.g_step_completed
            ,gme_common_pvt.g_step_closed) THEN
         RAISE step_rel_cmpl_closed;
      END IF;

      gme_validate_flex_fld_pvt.validate_flex_batch_step
                                           (p_batch_step  => p_batch_step_rec
                                           ,x_batch_step  => l_batch_step_rec
                                           ,x_return_status => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_validation;
      END IF;

      process_dependent_steps
                        (p_batch_step_rec              => p_batch_step_rec
                        ,p_batch_header_rec            => p_batch_header_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => l_return_status);

      IF l_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         x_return_status := l_return_status;
         RAISE error_process_dep_steps;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
         x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('Calling release step line to complete ingredient transactions...');
         gme_debug.put_line ('for step = ' || x_batch_step_rec.batchstep_id);
      END IF;

      release_step_line (p_batch_step_rec              => p_batch_step_rec
                        ,x_batch_step_rec              => x_batch_step_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RAISE rel_step_line_error;
      END IF;

      release_step_ingredients
                 (p_batch_step_rec              => x_batch_step_rec
                 ,p_update_inv_ind              => p_batch_header_rec.update_inventory_ind
                 ,x_exception_material_tbl      => x_exception_material_tbl
                 ,x_return_status               => l_return_status);

      IF l_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         x_return_status := l_return_status;
         RAISE rel_step_ing_error;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
         x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;

      /* Invoke the update step qty API to update the step quantities and the */
      /* quantities of the succeeding steps                                   */
      l_in_batch_step_rec := x_batch_step_rec;
      gme_update_step_qty_pvt.update_step_qty
                                     (p_batch_step_rec      => l_in_batch_step_rec
                                     ,x_message_count       => l_msg_count
                                     ,x_message_list        => l_msg_stack
                                     ,x_return_status       => l_return_status
                                     ,x_batch_step_rec      => x_batch_step_rec);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE update_step_qty_error;
      END IF;

      /* Needs to be done for each step released */
      IF (x_batch_step_rec.quality_status = 2) THEN
         wf_event.RAISE
                      (p_event_name      => gme_common_pvt.G_BSTEP_REL_WF
                      ,p_event_key       => TO_CHAR
                                                (x_batch_step_rec.batchstep_id) );
      END IF;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN error_validation THEN
         NULL;
      WHEN update_step_qty_error THEN
         x_return_status := l_return_status;
      WHEN step_rel_cmpl_closed OR rel_step_line_error OR rel_step_ing_error OR error_process_dep_steps THEN
         NULL;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_step_recursive;

   PROCEDURE process_dependent_steps (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name      CONSTANT VARCHAR2 (30)     := 'process_dependent_steps';

      CURSOR cur_get_dep_steps (v_batchstep_id NUMBER, v_batch_id NUMBER)
      IS
         SELECT d.dep_step_id, d.dep_type, d.standard_delay
               ,s.steprelease_type, s.step_status
           FROM gme_batch_step_dependencies d, gme_batch_steps s
          WHERE d.batchstep_id = v_batchstep_id
            AND s.batchstep_id = d.dep_step_id
            AND s.batch_id = v_batch_id
            AND d.batch_id = s.batch_id;

      l_dep_step_rec           cur_get_dep_steps%ROWTYPE;
      l_return_status          VARCHAR2 (1);
      l_batch_step_rec         gme_batch_steps%ROWTYPE;
      l_in_batch_step_rec      gme_batch_steps%ROWTYPE;
      l_complete_dep_step      BOOLEAN;

      batch_step_fetch_error   EXCEPTION;
      dep_step_rel_error       EXCEPTION;
      dep_step_cmpl_error      EXCEPTION;
      --Bug#5109119
      error_close_period       EXCEPTION;
      error_future_date        EXCEPTION;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Processing batch_step_id='
                             || p_batch_step_rec.batchstep_id);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Bug#5109119 Begin check the close period for current step. this check will be done for current step and dependent steps
         also as process_dependent_steps will be called for each step*/

      -- Bug 8595231 - We do not need to validate the start date if the step is already released.
      -- As this procedure gets called by complete_step_recursive also.
      IF p_batch_step_rec.step_status = 1 THEN
         IF NOT gme_common_pvt.check_close_period(p_org_id     => p_batch_header_rec.organization_id
                                                 ,p_trans_date => p_batch_step_rec.actual_start_date) THEN
           RAISE error_close_period;
         END IF;
      END IF;

      /* because of step depedency types(-ve offset) some time the dependent step might get the date that can greater
         than sysdate. so following check is introduced */
      IF (p_batch_step_rec.actual_start_date > SYSDATE) THEN
         RAISE error_future_date;
      END IF;
      /* Bug#5109119 End */

      /* Get the immediate dependent steps for the current step */
      FOR l_dep_step_rec IN cur_get_dep_steps (p_batch_step_rec.batchstep_id
                                              ,p_batch_header_rec.batch_id) LOOP
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'fetched dep step '
                                || l_dep_step_rec.dep_step_id);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'steprelease_type = '
                                || l_dep_step_rec.steprelease_type);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'dep_type = '
                                || l_dep_step_rec.dep_type);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'standard_delay = '
                                || l_dep_step_rec.standard_delay);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'step_status = '
                                || l_dep_step_rec.step_status);
         END IF;

         /* If the dependent step is set to automatic release */
         IF l_dep_step_rec.steprelease_type =
                                            gme_common_pvt.g_auto_step_release THEN
            l_batch_step_rec.batchstep_id := l_dep_step_rec.dep_step_id;

            IF NOT (gme_batch_steps_dbl.fetch_row (l_batch_step_rec
                                                  ,l_batch_step_rec) ) THEN
               RAISE batch_step_fetch_error;
            END IF;

            /* If the dependency is Finish To Start and their is a positive delay */
            /* then complete the dependent step otherwise call the release API if the step */
            /* status is pending. */
            IF     (l_dep_step_rec.dep_type =
                                        gme_common_pvt.g_dep_type_finish_start)
               AND (l_dep_step_rec.standard_delay >= 0) THEN
              l_complete_dep_step := TRUE;
            ELSE
              l_complete_dep_step := FALSE;
            END IF;  /* IF (l_dep_step_rec.dep_type = gme_common_pvt.g_dep_type_finish_start) AND */

            /* If the step status is pending */
            IF (l_dep_step_rec.step_status = gme_common_pvt.g_step_pending) THEN
  	       /*Bug#5183521 when step dependency is start to start, the dependent should start before the current step
	         considering the standard delay defined in dependencies.commented the ELSE and added OR condition */
               IF     (l_dep_step_rec.dep_type = gme_common_pvt.g_dep_type_finish_start AND
                       l_dep_step_rec.standard_delay < 0) OR
		      (l_dep_step_rec.dep_type = gme_common_pvt.g_dep_type_start_start) THEN
                  l_batch_step_rec.actual_start_date :=
                       p_batch_step_rec.actual_start_date
                     - (l_dep_step_rec.standard_delay / 24);
               /*ELSIF (l_dep_step_rec.dep_type =
                                      gme_common_pvt.g_dep_type_start_start) THEN
                  l_batch_step_rec.actual_start_date :=
                       p_batch_step_rec.actual_start_date
                     + (l_dep_step_rec.standard_delay / 24); */
               END IF;
                    /* dep_type = gme_common_pvt.g_dep_type_finish_start */

               l_in_batch_step_rec := l_batch_step_rec;
	       /* Bug#5109119 when l_complete_dep_step is TRUE call complete_step directly, no need to call release_step */
	       IF NOT l_complete_dep_step THEN
                  release_step_recursive
                      (p_batch_step_rec              => l_in_batch_step_rec
                      ,p_batch_header_rec            => p_batch_header_rec
                      ,x_batch_step_rec              => l_batch_step_rec
                      ,x_exception_material_tbl      => x_exception_material_tbl
                      ,x_return_status               => l_return_status);

                  IF l_return_status NOT IN
                      (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
                     x_return_status := l_return_status;
                     RAISE dep_step_rel_error;
                  END IF;

                  IF l_return_status = gme_common_pvt.g_exceptions_err THEN
                     x_return_status := gme_common_pvt.g_exceptions_err;
                  END IF;
               END IF; /* IF NOT l_complete_dep_step THEN */
            END IF;  /* IF (l_dep_step_rec.step_status = gme_common_pvt.g_step_pending) */

            IF l_complete_dep_step THEN
               l_batch_step_rec.actual_cmplt_date :=
                    p_batch_step_rec.actual_start_date
                  - (l_dep_step_rec.standard_delay / 24);

               --Sunitha Ch. bug#5488991 assigning the completion date to the start only when it is  null
	       IF l_batch_step_rec.actual_start_date IS NULL THEN
	          l_batch_step_rec.actual_start_date :=
                                            l_batch_step_rec.actual_cmplt_date;
               ELSE
	          IF l_batch_step_rec.actual_cmplt_date <  l_batch_step_rec.actual_start_date THEN
		     l_batch_step_rec.actual_cmplt_date :=
                                            l_batch_step_rec.actual_start_date;
		  END IF;
	       END IF;
               l_in_batch_step_rec := l_batch_step_rec;
               gme_complete_batch_step_pvt.complete_step_recursive
                         (p_batch_step_rec              => l_in_batch_step_rec
                         ,p_batch_header_rec            => p_batch_header_rec
                         ,x_return_status               => l_return_status
                         ,x_batch_step_rec              => l_batch_step_rec
                         ,x_exception_material_tbl      => x_exception_material_tbl);

               IF l_return_status NOT IN
                     (fnd_api.g_ret_sts_success
                     ,gme_common_pvt.g_exceptions_err) THEN
                  x_return_status := l_return_status;
                  RAISE dep_step_cmpl_error;
               END IF;

               IF l_return_status = gme_common_pvt.g_exceptions_err THEN
                  x_return_status := gme_common_pvt.g_exceptions_err;
               END IF;
            END IF;  -- IF l_complete_dep_step THEN
         END IF;  -- IF l_dep_step_rec.steprelease_type = gme_common_pvt.g_auto_step_release
      END LOOP;                  /* FOR l_dep_step_rec IN Cur_get_dep_steps */


      /* Bug#5109119 l_first_step_start_date will preserve the min(step dates) between the recursive calls.
         we compare this date with the actual start date of the current step and if this is less than then
	 change
      */
      IF l_first_step_start_date IS NULL OR
         l_first_step_start_date > p_batch_step_rec.actual_start_date THEN
	l_first_step_start_date := p_batch_step_rec.actual_start_date;
      END IF;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
     --Bug#5109119 Begin
      WHEN error_close_period THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_future_date THEN
        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug#5109119 End
      WHEN batch_step_fetch_error THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN dep_step_rel_error OR dep_step_cmpl_error THEN
         NULL;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END process_dependent_steps;

/*===========================================================================================
Procedure
  release_step_line
Description
  This procedure releases the step and updates actual dates for activity and resource.
Parameters
  p_batch_step_rec       Input Batch Step Line
  p_batch_header_rec     Batch Header that step belongs to
  x_batch_step_rec       Output Batch Step Line
  x_return_status        outcome of the API call
            S - Success
            E - Error
            U - Unexpected error
 History

=============================================================================================*/
   PROCEDURE release_step_line (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'release_step_line';
      l_return_status       VARCHAR2 (1);
      l_batch_step_rec      gme_batch_steps%ROWTYPE;
      l_in_batch_step_rec   gme_batch_steps%ROWTYPE;
      batch_step_upd_err    EXCEPTION;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Release step line batchstep_id='
                             || p_batch_step_rec.batchstep_id);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      -- Each time this is called, p_batch_step_rec has already been retrieved from DB... has all
      -- latest data and in addition has the actual start date calculated and set
      x_batch_step_rec := p_batch_step_rec;
      /*  Update the Batch Step Status to WIP */
      x_batch_step_rec.step_status := gme_common_pvt.g_step_wip;

      -- Update the batch step
      IF NOT (gme_batch_steps_dbl.update_row (x_batch_step_rec) ) THEN
         RAISE batch_step_upd_err;
      END IF;

      -- Update WHO columns for output structure
      x_batch_step_rec.last_updated_by := gme_common_pvt.g_user_ident;
      x_batch_step_rec.last_update_date := gme_common_pvt.g_timestamp;
      x_batch_step_rec.last_update_login := gme_common_pvt.g_login_id;

      -- Update activity start date
      -- Does not factor in offset
      UPDATE gme_batch_step_activities
         SET actual_start_date = x_batch_step_rec.actual_start_date
            ,last_updated_by = gme_common_pvt.g_user_ident
            ,last_update_date = gme_common_pvt.g_timestamp
            ,last_update_login = gme_common_pvt.g_login_id
       WHERE batchstep_id = x_batch_step_rec.batchstep_id;

      -- Update resource start date
      -- Does not factor in offset
      UPDATE gme_batch_step_resources
         SET actual_start_date = x_batch_step_rec.actual_start_date
            ,last_updated_by = gme_common_pvt.g_user_ident
            ,last_update_date = gme_common_pvt.g_timestamp
            ,last_update_login = gme_common_pvt.g_login_id
       WHERE batchstep_id = x_batch_step_rec.batchstep_id;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_step_upd_err THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_step_line;

   PROCEDURE release_step_ingredients (
      p_batch_step_rec           IN            gme_batch_steps%ROWTYPE
     ,p_update_inv_ind           IN            VARCHAR2
     ,x_exception_material_tbl   IN OUT NOCOPY gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY    VARCHAR2)
   IS
      CURSOR cur_step_ingredients (v_batchstep_id NUMBER)
      IS
         SELECT matl.*
           FROM gme_material_details matl, gme_batch_step_items item
          WHERE item.batchstep_id = v_batchstep_id
            AND item.material_detail_id = matl.material_detail_id
            AND matl.line_type = gme_common_pvt.g_line_type_ing
            AND matl.release_type = gme_common_pvt.g_mtl_autobystep_release;

      l_api_name   CONSTANT VARCHAR2 (30)        := 'release_step_ingredients';
      l_return_status       VARCHAR2 (1);
      l_matl_dtl_rec        gme_material_details%ROWTYPE;
      l_matl_dtl_tab        gme_common_pvt.material_details_tab;
      l_consume             BOOLEAN;
      error_process_ing     EXCEPTION;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Releasing ingredients for step_id='
                             || p_batch_step_rec.batchstep_id);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- retrieve all autobystep ingredients associated to the step...
      OPEN cur_step_ingredients (p_batch_step_rec.batchstep_id);

      FETCH cur_step_ingredients
      BULK COLLECT INTO l_matl_dtl_tab;

      CLOSE cur_step_ingredients;

      FOR i IN 1 .. l_matl_dtl_tab.COUNT LOOP
         l_matl_dtl_rec := l_matl_dtl_tab (i);
         l_consume := TRUE;

         gme_release_batch_pvt.process_ingredient
                       (p_material_detail_rec         => l_matl_dtl_rec
                       ,p_consume                     => l_consume
                       ,p_trans_date                  => p_batch_step_rec.actual_start_date
                       ,p_update_inv_ind              => p_update_inv_ind
                       ,x_exception_material_tbl      => x_exception_material_tbl
                       ,x_return_status               => l_return_status);

         IF l_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
            x_return_status := l_return_status;
            RAISE error_process_ing;
         END IF;

         IF l_return_status = gme_common_pvt.g_exceptions_err THEN
            x_return_status := gme_common_pvt.g_exceptions_err;
         END IF;
      END LOOP;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN error_process_ing THEN
         NULL;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_step_ingredients;

   PROCEDURE validate_step_for_release  (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
                                        ,x_batch_step_rec       OUT NOCOPY gme_batch_steps%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2) IS

      l_api_name   CONSTANT VARCHAR2 (30)           := 'validate_step_for_release';
      CURSOR cur_validity_rule(v_recipe_validity_rule_id NUMBER)
      IS
         SELECT *
          FROM gmd_recipe_validity_rules
          WHERE recipe_validity_rule_id = v_recipe_validity_rule_id;

      CURSOR cur_validity_status_type(v_validity_rule_status VARCHAR2)
      IS
         SELECT status_type
          FROM gmd_status
          WHERE status_code=v_validity_rule_status;

      l_validity_rule             gmd_recipe_validity_rules%ROWTYPE;
      l_status_type               GMD_STATUS.status_type%TYPE;
      error_vr_not_found          EXCEPTION;
      error_validity_status       EXCEPTION;
      error_future_date           EXCEPTION;
      error_validation            EXCEPTION;
      error_actual_start_date     EXCEPTION;
      --Bug#5109119
      error_close_period          EXCEPTION;
      error_vr_dates              EXCEPTION;
    BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||' batchstep_id = '||p_batch_step_rec.batchstep_id);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- set output structure
      x_batch_step_rec := p_batch_step_rec;

      -- actual start date is filled in for both p_batch_header_rec and p_batch_step_rec

      -- set actual start date if it's not passed
      IF p_batch_step_rec.actual_start_date IS NULL THEN
         x_batch_step_rec.actual_start_date := SYSDATE;
      ELSE  -- user passed in an actual start date; ensure it's not in the future
        IF (p_batch_step_rec.actual_start_date > SYSDATE) THEN
          RAISE error_future_date;
        ELSIF p_batch_header_rec.batch_status = gme_common_pvt.g_batch_wip THEN
          IF p_batch_step_rec.actual_start_date < p_batch_header_rec.actual_start_date THEN
            RAISE error_actual_start_date;
          END IF;
        END IF;
	x_batch_step_rec.actual_start_date := p_batch_step_rec.actual_start_date;
      END IF;
      --Sunith ch.5404329 check validity rule if it's not NULL; it would be NULL in case of LCF
      IF p_batch_header_rec.recipe_validity_rule_id IS NOT NULL THEN
        OPEN cur_validity_rule(p_batch_header_rec.recipe_validity_rule_id);
        FETCH cur_validity_rule INTO l_validity_rule;
        CLOSE cur_validity_rule;

        IF l_validity_rule.recipe_validity_rule_id IS NULL THEN  -- not found
           RAISE error_vr_not_found;
        ELSE
           -- following prevents user from releasing a pending batch
           -- if validity rule is ON_HOLD or OBSOLETE.
           OPEN cur_validity_status_type(l_validity_rule.validity_rule_status);
           FETCH cur_validity_status_type INTO l_status_type;
           CLOSE cur_validity_status_type;

           IF l_status_type IN ('1000' ,'800') THEN
             RAISE error_validity_status;
           END IF;
        END IF;  -- IF l_validity_rule.recipe_validity_rule_id IS NULL

      /*  IF l_validity_rule.start_date > x_batch_header_rec.actual_start_date OR
           (l_validity_rule.end_date IS NOT NULL AND
            l_validity_rule.end_date < x_batch_header_rec.actual_start_date) THEN
          RAISE error_vr_dates;
        END IF;*/
--sunitha ch. Bug 5336007 aded call to check_validity_rule_dates and passed p_validate_plan_dates_ind=1
--to validate planned start date against validate rule dates
        IF NOT gme_common_pvt.check_validity_rule_dates (
                                     p_validity_rule_id           =>  p_batch_header_rec.recipe_validity_rule_id
                                     ,p_start_date                =>  p_batch_header_rec.actual_start_date
                                     ,p_cmplt_date                =>  p_batch_header_rec.actual_cmplt_date
                                     ,p_batch_header_rec          =>  p_batch_header_rec
                                     ,p_validate_plan_dates_ind   => 1) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          RAISE error_vr_dates;
	END IF;
-- End Bug 5336007
      END IF;  -- IF p_batch_header_rec.recipe_validity_rule_id IS NOT NULL
      IF NOT gme_common_pvt.check_close_period(p_org_id     => p_batch_header_rec.organization_id
                                              ,p_trans_date => x_batch_step_rec.actual_start_date) THEN
        RAISE error_close_period;
      END IF;

      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||'actual_cmplt_date='||to_char(x_batch_step_rec.actual_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

      -- Enforce Step Dependency Checks
      IF p_batch_header_rec.enforce_step_dependency = 1 THEN
        -- validate dependent step status and dates
        gme_complete_batch_step_pvt.validate_dependent_steps
                                 (p_batch_id          => x_batch_step_rec.batch_id
                                 ,p_step_id           => x_batch_step_rec.batchstep_id
                                 ,p_step_actual_start_date => x_batch_step_rec.actual_start_date
                                 ,x_return_status     => x_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE error_validation;
        END IF;
      END IF;

      -- will check any auto by step associated to the step; phantom batches - all release types checked
      gme_release_batch_pvt.check_unexploded_phantom
                              (p_batch_id             => x_batch_step_rec.batch_id
                              ,p_auto_by_step         => 1                -- auto by step ingredients
                              ,p_batchstep_id         => x_batch_step_rec.batchstep_id  -- assoc to this step
                              ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE error_validation;
      END IF;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

   EXCEPTION
       --Bug#5109119
      WHEN error_close_period THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      -- 7564922 - Add missing exception clause for validity status check.
      WHEN error_validity_status THEN
        gme_common_pvt.log_message ('GME_VALIDITY_OBSO_OR_ONHOLD');
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_future_date THEN
        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_validation THEN
        NULL;
      WHEN error_actual_start_date THEN
         gme_common_pvt.log_message ('GME_STEP_START_BATCH_START_ERR');
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_vr_dates THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

        IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'Unexpected error: '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ': '
                                || SQLERRM);
        END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
   END validate_step_for_release;

END gme_release_batch_step_pvt;

/

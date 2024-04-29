--------------------------------------------------------
--  DDL for Package Body GME_COMPLETE_BATCH_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_COMPLETE_BATCH_STEP_PVT" AS
/* $Header: GMEVCMSB.pls 120.13.12010000.6 2010/03/30 19:52:01 gmurator ship $ */

G_DEBUG VARCHAR2(5) := FND_PROFILE.VALUE('AFLOG_LEVEL');
g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_complete_batch_step_pvt';

/*===========================================================================================
Procedure
  complete_step
Description
  This particular procedure call completes the batch steps.
Parameters
  p_batch_step_rec              The batch step row to complete
  p_batch_header_rec            The batch he
  x_return_status		outcome of the API call
  				S - Success
  				E - Error
  				U - Unexpected error
  				X - Unallocated Items Found

    History
    =======
      G. Muratore   14-MAY-09  Bug 8472384
         Make a call to purge_batch_exceptions to remove any pending reservations
         when the batch is being completed.
=============================================================================================*/

  PROCEDURE complete_step
    (p_batch_step_rec            IN GME_BATCH_STEPS%ROWTYPE
    ,p_batch_header_rec          IN gme_batch_header%ROWTYPE
    ,x_batch_step_rec            OUT NOCOPY GME_BATCH_STEPS%ROWTYPE
    ,x_exception_material_tbl    IN OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status             OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_step_count(v_batch_id NUMBER) IS
      SELECT count(1)
      FROM   GME_BATCH_STEPS
      WHERE  batch_id = v_batch_id
      AND    step_status < gme_common_pvt.g_step_completed
      AND    rownum = 1;

    l_api_name        CONSTANT VARCHAR2 (30)   := 'complete_step';

    l_batch_header_rec         gme_batch_header%ROWTYPE;
    l_in_batch_header_rec      gme_batch_header%ROWTYPE;
    l_batch_step_rec           gme_batch_steps%ROWTYPE;
    l_return_status	     VARCHAR2(1);
    l_step_count		     NUMBER;

    error_release_batch        EXCEPTION;
    error_complete_step_rec    EXCEPTION;
    error_complete_batch       EXCEPTION;
    error_validation           EXCEPTION;
    error_fetch                EXCEPTION;

    -- Bug 8472384 - Add new exception
    purge_exception_err    EXCEPTION;

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Complete step batchstep_id='||p_batch_step_rec.batchstep_id);
    END IF;

    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    l_batch_step_rec      := p_batch_step_rec;
    l_batch_header_rec    := p_batch_header_rec;

    -- if the step status is pending, call release step first... don't need to worry
    -- about calling release batch if the batch is pending because release step will take
    -- care of this; check for step control batch and not a phantom done in pub
    IF p_batch_step_rec.step_status = gme_common_pvt.g_step_pending THEN
      -- actual start date already populated in p_batch_step_rec
      gme_release_batch_step_pvt.release_step
         (p_batch_step_rec             => p_batch_step_rec
         ,p_batch_header_rec           => p_batch_header_rec
         ,x_batch_step_rec             => l_batch_step_rec
         ,x_exception_material_tbl     => x_exception_material_tbl
         ,x_return_status              => l_return_status);

      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_release_batch;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;

      -- re-retrieve the batch header if the batch status was pending
      IF (p_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending) THEN
        IF NOT gme_batch_header_dbl.fetch_row(l_batch_header_rec, l_batch_header_rec) THEN
          RAISE error_fetch;
        END IF;
      END IF;

    END IF; /* IF p_batch_step_rec.step_status = gme_common_pvt.g_step_pending */

    -- Bug 8252288 - Added last parameter to reinstate behavior before 6348353 was implemented.
    complete_step_recursive
      (p_batch_step_rec           => l_batch_step_rec
      ,p_batch_header_rec         => l_batch_header_rec
      ,x_batch_step_rec           => x_batch_step_rec
      ,x_exception_material_tbl   => x_exception_material_tbl
      ,x_return_status            => l_return_status
      ,p_quality_override         => TRUE);

    IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
      x_return_status := l_return_status;
      RAISE error_complete_step_rec;
    END IF;

    IF l_return_status = gme_common_pvt.g_exceptions_err THEN
      x_return_status := gme_common_pvt.g_exceptions_err;
    END IF;

    /* If the step controls batch status profile is set then to complete the batch */
    /* if all the steps are complete and this is not a phantom batch               */

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' step controls batch= '||gme_common_pvt.g_step_controls_batch_sts_ind);
    END IF;

    IF (gme_common_pvt.g_step_controls_batch_sts_ind = 1) AND (l_batch_header_rec.parentline_id IS NULL) AND
       (l_batch_header_rec.batch_status <> gme_common_pvt.g_batch_completed) THEN
      /* Get the count of the number of steps less than complete for this batch */

      OPEN Cur_step_count(l_batch_header_rec.batch_id);
      FETCH Cur_step_count INTO l_step_count;
      CLOSE Cur_step_count;

      /* If all the steps are complete or closed in the batch then call complete batch */
      IF (l_step_count = 0) THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calling complete batch because step controls batch and all steps complete');
        END IF;

        l_in_batch_header_rec := l_batch_header_rec;
        l_in_batch_header_rec.actual_cmplt_date := x_batch_step_rec.actual_cmplt_date;

        -- call complete batch validation to make sure batch is in position to be completed
        -- can't do this in pub because there's no way to know if other steps may be
        -- completed in the process of this being completed
        gme_complete_batch_pvt.validate_batch_for_complete
                                 (p_batch_header_rec     => l_in_batch_header_rec
                                 ,x_batch_header_rec     => l_batch_header_rec
                                 ,x_return_status        => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE error_validation;
        END IF;

        l_in_batch_header_rec := l_batch_header_rec;
        gme_complete_batch_pvt.complete_batch
              (p_batch_header_rec           => l_in_batch_header_rec
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_batch_header_rec           => l_batch_header_rec
              ,x_return_status              => l_return_status);

        IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
          x_return_status := l_return_status;
          RAISE error_complete_batch;
        END IF;

        IF l_return_status = gme_common_pvt.g_exceptions_err THEN
          x_return_status := gme_common_pvt.g_exceptions_err;
        END IF;

        -- Bug 8472384 - Delete all remaining reservations including for phantom batches.
        gme_cancel_batch_pvt.purge_batch_exceptions (p_batch_header_rec         => l_batch_header_rec
                                                    ,p_delete_invis_mo          => 'F'
                                                    ,p_delete_reservations      => 'T'
                                                    ,p_delete_trans_pairs       => 'F'
                                                    ,p_recursive                => 'R'
                                                    ,x_return_status            => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           IF (g_debug <= gme_debug.g_log_procedure) THEN
              gme_debug.put_line (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || ':'
                                  || 'purge_exception_err');
           END IF;
           RAISE purge_exception_err;
        END IF;
      END IF; /* IF l_step_count = 0 */
    END IF; /* IF (gme_common_pvt.g_step_controls_batch_sts_ind = 'Y') AND  */

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_release_batch OR error_complete_batch OR
         error_complete_step_rec OR error_validation OR purge_exception_err THEN
      NULL;
    WHEN error_fetch THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END complete_step;

  PROCEDURE complete_step_recursive
    (p_batch_step_rec             IN       gme_batch_steps%ROWTYPE
    ,p_batch_header_rec           IN       gme_batch_header%ROWTYPE
    ,x_batch_step_rec             OUT NOCOPY      gme_batch_steps%ROWTYPE
    ,x_exception_material_tbl     IN  OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status              OUT NOCOPY      VARCHAR2
    ,p_quality_override           IN  BOOLEAN := FALSE) IS --Bug#6348353

    l_api_name        CONSTANT VARCHAR2 (30)   := 'complete_step_recursive';

    l_in_batch_step_rec        gme_batch_steps%ROWTYPE;
    l_return_status                VARCHAR2 (1);
    l_msg_count                    NUMBER;
    l_msg_stack                    VARCHAR2 (2000);
    l_lock_status 		       VARCHAR2(1);
    l_locked_by_status	       VARCHAR2(1);
    l_lock_allowed 		       VARCHAR2(1);

    step_cmpl_closed           EXCEPTION;
    cmpl_step_line_error       EXCEPTION;
    cmpl_step_prod_error       EXCEPTION;
    update_step_qty_error      EXCEPTION;
    error_process_dep_steps    EXCEPTION;
    gmo_lock_error	       EXCEPTION;
    error_quality_status       EXCEPTION; --Bug#6348353

  BEGIN
    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' complete step recursive batch_step_id='||p_batch_step_rec.batchstep_id);
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_batch_step_rec := p_batch_step_rec;

    /* Exit the recursive loop if the step is already released, completed or closed */
    IF x_batch_step_rec.step_status IN (gme_common_pvt.g_step_completed
                                       ,gme_common_pvt.g_step_closed) THEN
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||'step is completed or closed; returning');
      END IF;
      RAISE step_cmpl_closed;
    END IF;

    -- Bug 9478698 - Call GMO only if enhanced_pi_ind is activated.
    IF p_batch_header_rec.enhanced_pi_ind = 'Y' THEN
       -- Pawan Kumar added for bug 5034336
       -- check for batch step lock status from gmo
       gmo_vbatch_grp.GET_ENTITY_LOCK_STATUS (
            	P_API_VERSION 		=> 1.0,
     		P_INIT_MSG_LIST 	=> FND_API.G_FALSE,
  		P_COMMIT 		=> FND_API.G_FALSE,
  		P_VALIDATION_LEVEL 	=> FND_API.G_VALID_LEVEL_FULL,
                X_RETURN_STATUS 	=> x_return_status ,
                X_MSG_COUNT 		=> l_msg_count,
                X_MSG_DATA 		=> l_msg_stack,
                P_ENTITY_NAME 		=> 'OPERATION',
  		P_ENTITY_KEY 		=> x_batch_step_rec.batchstep_id,
  		P_REQUESTER 		=> gme_common_pvt.g_user_ident,
  		X_LOCK_STATUS 		=> l_lock_status,
  		X_LOCKED_BY_STATUS 	=> l_locked_by_status,
  		X_LOCK_ALLOWED 		=> l_lock_allowed);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE  gmo_lock_error;
       END IF;

       IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                       || '.'
                       || l_api_name
                       || ':'
                       || 'from gmo the lock_status='
                       || l_lock_status);
       END IF;

       IF l_lock_status = 'Y' THEN
          gme_common_pvt.log_message ('GME_STEP_LOCK_ERROR');
          RAISE gmo_lock_error;
       END IF;
    END IF;


    /* If this procedure is invoked while completing the entire batch */
    /* then there is no need to go through the recursive procedure as */
    /* the complete batch call completes all the steps 		    */
    IF p_batch_header_rec.batch_status <> gme_common_pvt.g_batch_completed THEN
      gme_release_batch_step_pvt.process_dependent_steps
        (p_batch_step_rec             => p_batch_step_rec
        ,p_batch_header_rec           => p_batch_header_rec
        ,x_exception_material_tbl     => x_exception_material_tbl
        ,x_return_status              => l_return_status);

      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_process_dep_steps;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;
    END IF;  -- IF p_batch_header_rec.batch_status <> gme_common_pvt.g_batch_completed THEN

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||'Calling complete step line to create product transactions...');
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' for step = '|| x_batch_step_rec.batchstep_id);
    END IF;

    --Bug#6348353 Adding the below validation
    -- if quality is not complete cannot complete step
    IF (p_batch_step_rec.quality_status NOT IN (1,4,6) AND
       p_quality_override = FALSE) THEN
       RAISE error_quality_status;
    END IF;

    -- Bug 7475553 - Initialize step dates properly.
    -- This code taken from 11i File GMEVCTSB.pls procedure certify_step_line.
    -- If the batch status is certified, then this indicates that the user
    -- is performing a full batch certification.  That is, the call to this
    -- function is via a batch certification and not the certification of the step.
    l_in_batch_step_rec := x_batch_step_rec;
    IF p_batch_header_rec.batch_status = gme_common_pvt.g_batch_completed THEN
       IF l_in_batch_step_rec.actual_cmplt_date IS NULL THEN
          l_in_batch_step_rec.actual_cmplt_date := p_batch_header_rec.actual_cmplt_date;
       END IF;
       /*  If the Batch Step has not yet been Released then the Actual   */
       /*  Start Date must also be assigned here.  It will be set to the */
       /*  actual completion date of the batch.                          */
       IF p_batch_step_rec.step_status < gme_common_pvt.g_step_wip THEN
          l_in_batch_step_rec.actual_start_date := p_batch_header_rec.actual_cmplt_date;
       END IF;
    END IF;

    -- Bug 7475553 - Use l_in_batch_step_rec to make sure dates are passed in properly.
    complete_step_line
      (p_batch_step_rec                => l_in_batch_step_rec
      ,x_batch_step_rec                => x_batch_step_rec
      ,x_exception_material_tbl        => x_exception_material_tbl
      ,x_return_status                 => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RAISE cmpl_step_line_error;
    END IF;

    complete_step_material
              (p_batch_step_rec             => x_batch_step_rec
              ,p_update_inv_ind             => p_batch_header_rec.update_inventory_ind
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_return_status              => l_return_status);

    IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
      x_return_status := l_return_status;
      RAISE cmpl_step_prod_error;
    END IF;

    IF l_return_status = gme_common_pvt.g_exceptions_err THEN
      x_return_status := gme_common_pvt.g_exceptions_err;
    END IF;

    /* Invoke the update step qty API to update the step quantities and the */
    /* quantities of the succeeding steps                                   */
    l_in_batch_step_rec := x_batch_step_rec;
    gme_update_step_qty_pvt.update_step_qty
          (p_batch_step_rec         => l_in_batch_step_rec
          ,x_message_count          => l_msg_count
          ,x_message_list           => l_msg_stack
          ,x_return_status          => l_return_status
          ,x_batch_step_rec         => x_batch_step_rec);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE update_step_qty_error;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN update_step_qty_error THEN
      x_return_status := l_return_status;
    WHEN step_cmpl_closed OR cmpl_step_line_error OR cmpl_step_prod_error OR error_process_dep_steps THEN
      NULL;
    WHEN gmo_lock_error THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'GMO_LOCK_ERROR.');

         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_quality_status THEN --Bug#6348353
        gme_common_pvt.log_message('GME_QUALITY_NOT_COMPLETE'
                                  ,'STEP_NO', x_batch_step_rec.batchstep_no
                                  ,'BATCH_NO', p_batch_header_rec.batch_no);
        x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
   END complete_step_recursive;

/*===========================================================================================
Procedure
  complete_step_line
Description
  This particular procedure is used to complete the step and updates actual dates for activity and resource.
Parameters
  p_batch_step_rec		Batch Step Line
  x_batch_step_rec		Batch Step Line
  x_return_status		outcome of the API call
  				S - Success
  				E - Error
  				U - Unexpected error
History

=============================================================================================*/

  PROCEDURE complete_step_line
    (p_batch_step_rec            IN              gme_batch_steps%ROWTYPE
    ,x_batch_step_rec            OUT NOCOPY      gme_batch_steps%ROWTYPE
    ,x_exception_material_tbl    IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
    ,x_return_status             OUT NOCOPY      VARCHAR2) IS

    l_api_name   CONSTANT VARCHAR2 (30)   := 'complete_step_line';

    batch_step_upd_err    EXCEPTION;
  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Complete step line batchstep_id='||p_batch_step_rec.batchstep_id);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Each time this is called, p_batch_step_rec has already been retrieved from DB... has all
    -- latest data and in addition has the actual completion date calculated and set
    x_batch_step_rec := p_batch_step_rec;

    /*  Update the Batch Step Status to WIP */
    x_batch_step_rec.step_status := gme_common_pvt.g_step_completed;

    -- Update the batch step
    IF NOT (gme_batch_steps_dbl.update_row (x_batch_step_rec)) THEN
      RAISE batch_step_upd_err;
    END IF;

    -- Update WHO columns for output structure
    x_batch_step_rec.last_updated_by := gme_common_pvt.g_user_ident;
    x_batch_step_rec.last_update_date := gme_common_pvt.g_timestamp;
    x_batch_step_rec.last_update_login := gme_common_pvt.g_login_id;

    /* Update the actual completion dates of the activities */
    UPDATE  gme_batch_step_activities
    SET     actual_cmplt_date = x_batch_step_rec.actual_cmplt_date
    WHERE   batchstep_id = x_batch_step_rec.batchstep_id
    AND     batch_id = x_batch_step_rec.batch_id
    AND     actual_cmplt_date IS NULL;

    /* Update the actual start dates of the activities */
    UPDATE  gme_batch_step_activities
    SET     actual_start_date = x_batch_step_rec.actual_start_date
    WHERE   batchstep_id = x_batch_step_rec.batchstep_id
    AND     batch_id = x_batch_step_rec.batch_id
    AND     actual_start_date IS NULL;


    /* Update the actual completion dates of the resources */
    UPDATE  gme_batch_step_resources
    SET     actual_cmplt_date = x_batch_step_rec.actual_cmplt_date
    WHERE   batchstep_id = x_batch_step_rec.batchstep_id
    AND     batch_id = x_batch_step_rec.batch_id
    AND     actual_cmplt_date IS NULL;

    /* Update the actual start dates of the resources */
    UPDATE  gme_batch_step_resources
    SET     actual_start_date = x_batch_step_rec.actual_start_date
    WHERE   batchstep_id = x_batch_step_rec.batchstep_id
    AND     batch_id = x_batch_step_rec.batch_id
    AND     actual_start_date IS NULL;

    /* We need to remove the resource information for the gme_batch_step_rsrc_summary */
    /* table, as this table should only hold data of the resources which are in PENDING or WIP */
    DELETE FROM gme_batch_step_rsrc_summary
    WHERE       batchstep_id = x_batch_step_rec.batchstep_id
    AND         batch_id = x_batch_step_rec.batch_id;

  EXCEPTION
    WHEN batch_step_upd_err THEN
      gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END complete_step_line;

  PROCEDURE complete_step_material
              (p_batch_step_rec             IN         gme_batch_steps%ROWTYPE
              ,p_update_inv_ind             IN         VARCHAR2
              ,x_exception_material_tbl     IN  OUT NOCOPY gme_common_pvt.exceptions_tab
              ,x_return_status              OUT NOCOPY VARCHAR2) IS


    CURSOR Cur_step_prod_byprod(v_batchstep_id NUMBER) IS
    SELECT matl.*
      FROM gme_material_details matl, gme_batch_step_items item
     WHERE item.batchstep_id = v_batchstep_id
       AND item.material_detail_id = matl.material_detail_id
       AND (matl.line_type IN (gme_common_pvt.g_line_type_prod, gme_common_pvt.g_line_type_byprod) OR
            (matl.line_type = gme_common_pvt.g_line_type_ing AND matl.phantom_id IS NOT NULL))
       AND matl.release_type = gme_common_pvt.g_mtl_autobystep_release;

    l_api_name               CONSTANT   VARCHAR2 (30)                := 'complete_step_material';

    l_return_status               VARCHAR2(1);
    l_matl_dtl_rec                gme_material_details%ROWTYPE;
    l_matl_dtl_tab                gme_common_pvt.material_details_tab;
    l_yield                       BOOLEAN;

    error_process_prod             EXCEPTION;

  BEGIN
    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Completing products/byproducts for step_id='||p_batch_step_rec.batchstep_id);
    END IF;

    /* Set the return status to success initially */
    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    -- retrieve all autobystep products and phantom ingredients associated to the step...
    OPEN Cur_step_prod_byprod(p_batch_step_rec.batchstep_id);
    FETCH Cur_step_prod_byprod BULK COLLECT INTO l_matl_dtl_tab;
    CLOSE Cur_step_prod_byprod;

    FOR i IN 1..l_matl_dtl_tab.COUNT LOOP
      l_matl_dtl_rec := l_matl_dtl_tab(i);

      l_yield := TRUE;
      gme_complete_batch_pvt.process_material
              (p_material_detail_rec        => l_matl_dtl_rec
              ,p_yield                      => l_yield
              ,p_trans_date                 => p_batch_step_rec.actual_cmplt_date
              ,p_update_inv_ind             => p_update_inv_ind
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_return_status              => l_return_status);

      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_process_prod;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;
    END LOOP;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
  WHEN  error_process_prod THEN
    NULL;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END complete_step_material;

  PROCEDURE validate_dependent_steps (p_batch_id           IN NUMBER
                                     ,p_step_id            IN NUMBER
                                     ,p_step_actual_start_date IN DATE
                                     ,x_return_status      OUT NOCOPY VARCHAR2) IS

      l_api_name   CONSTANT VARCHAR2 (30)           := 'validate_dependent_steps';

      CURSOR Cur_get_dep_steps(v_batch_id NUMBER, v_step_id NUMBER) IS
      SELECT d.dep_step_id, d.dep_type, d.standard_delay, s.steprelease_type,
             s.step_status,s.actual_cmplt_date,s.actual_start_date
      FROM   gme_batch_step_dependencies d, gme_batch_steps s
      WHERE  d.batchstep_id = v_step_id
      AND    s.batchstep_id = d.dep_step_id
      AND    s.batch_id = v_batch_id
      AND    s.batch_id = d.batch_id;

      l_dep_step_rec        Cur_get_dep_steps%ROWTYPE;

      GME_STEP_DEP_COMPLETE       EXCEPTION;
      GME_STEP_DEP_WIP            EXCEPTION;
      INVALID_START_DATE          EXCEPTION;
  BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||' batchstep_id = '||p_step_id);
      END IF;

      x_return_status := FND_API.g_ret_sts_success;

      FOR l_dep_step_rec IN Cur_get_dep_steps(p_batch_id, p_step_id) LOOP
        /*
           If the dependency is Finish To Start then the prior step should be
           completed or closed; if the dependecy is start to start then prior
           step should be WIP, completed or closed                            */

        IF (l_dep_step_rec.dep_type = gme_common_pvt.g_dep_type_finish_start) THEN
          IF l_dep_step_rec.step_status NOT IN (gme_common_pvt.g_step_completed
                                               ,gme_common_pvt.g_step_closed) THEN
            RAISE GME_STEP_DEP_COMPLETE;
          END IF;
          IF p_step_actual_start_date < l_dep_step_rec.actual_cmplt_date
                                      + (l_dep_step_rec.standard_delay/24) THEN
            RAISE INVALID_START_DATE;
          END IF;
        ELSE    -- start to start
          IF l_dep_step_rec.step_status NOT IN (gme_common_pvt.g_step_wip
                                               ,gme_common_pvt.g_step_completed
                                               ,gme_common_pvt.g_step_closed) THEN
            RAISE GME_STEP_DEP_WIP;
          END IF;
          IF p_step_actual_start_date < l_dep_step_rec.actual_start_date
                                      + (l_dep_step_rec.standard_delay/24) THEN
            RAISE INVALID_START_DATE;
          END IF;
        END IF;
      END LOOP;    -- FOR l_dep_step_rec IN Cur_get_dep_steps

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
  WHEN INVALID_START_DATE THEN
    gme_common_pvt.log_message('GME_INVALID_START_DATE');
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN GME_STEP_DEP_WIP THEN
    gme_common_pvt.log_message('GME_STEP_DEP_WIP');
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN GME_STEP_DEP_COMPLETE THEN
    gme_common_pvt.log_message('GME_STEP_DEP_COMPLETE');
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END validate_dependent_steps;

  PROCEDURE validate_step_for_complete  (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
                                        ,p_override_quality     IN VARCHAR2
                                        ,x_batch_step_rec       OUT NOCOPY gme_batch_steps%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2) IS

      l_api_name   CONSTANT VARCHAR2 (30)           := 'validate_step_for_complete';
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
      error_cmplt_date            EXCEPTION;
      error_no_direct_compl       EXCEPTION;
      error_quality_status        EXCEPTION;
      error_validation            EXCEPTION;
      error_future_date           EXCEPTION;
      --Bug#5109119
      error_close_period          EXCEPTION;
      error_vr_dates              EXCEPTION;

      -- Bug 9277115
      error_actual_start_date     EXCEPTION;
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

      -- Bug 9277115 - Let's also check the step start date if the step is not already released.
      IF p_batch_step_rec.step_status = gme_common_pvt.g_step_pending THEN
          IF p_batch_step_rec.actual_start_date < p_batch_header_rec.actual_start_date THEN
            RAISE error_actual_start_date;
          END IF;
      END IF;

      -- set actual complete date if it's not passed
      IF p_batch_step_rec.actual_cmplt_date IS NULL THEN
         IF p_batch_step_rec.step_status = gme_common_pvt.g_step_pending THEN
	  --Sunitha ch. Bug#5327152 set actual complete start if it's not passed
           IF  x_batch_step_rec.actual_start_date IS NULL THEN
           x_batch_step_rec.actual_start_date:=SYSDATE;
           END IF;

           x_batch_step_rec.actual_cmplt_date := x_batch_step_rec.actual_start_date;
         ELSE
           x_batch_step_rec.actual_cmplt_date := SYSDATE;
         END IF;
      ELSE  -- user passed in an actual cmplt date; validate it against start date
        IF x_batch_step_rec.actual_cmplt_date < x_batch_step_rec.actual_start_date THEN
          RAISE error_cmplt_date;
        ELSIF (x_batch_step_rec.actual_cmplt_date > SYSDATE) THEN
          RAISE error_future_date;
        END IF;
	x_batch_step_rec.actual_cmplt_date := p_batch_step_rec.actual_cmplt_date;
      END IF;

      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||'actual_cmplt_date='||to_char(x_batch_step_rec.actual_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

      --Bug#5109119 check for close period
      IF NOT gme_common_pvt.check_close_period(p_org_id     => p_batch_header_rec.organization_id
                                              ,p_trans_date => x_batch_step_rec.actual_cmplt_date) THEN
        RAISE error_close_period;
      END IF;


      -- Enforce Step Dependency Checks
      IF p_batch_header_rec.enforce_step_dependency = 1 THEN
        IF p_batch_step_rec.step_status <> gme_common_pvt.g_step_wip THEN
          RAISE error_no_direct_compl;
        END IF;

        -- validate dependent step status and dates
        validate_dependent_steps (p_batch_id          => x_batch_step_rec.batch_id
                                 ,p_step_id           => x_batch_step_rec.batchstep_id
                                 ,p_step_actual_start_date => x_batch_step_rec.actual_start_date
                                 ,x_return_status     => x_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE error_validation;
        END IF;
      END IF;

      -- if quality is not complete cannot complete step
      IF (x_batch_step_rec.quality_status NOT IN (1,4,6) AND
          p_override_quality = fnd_api.g_false) THEN
        RAISE error_quality_status;
      END IF;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

   EXCEPTION
      --Bug#5109119 Begin
      WHEN error_close_period THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_validation THEN
        NULL;
      -- 9277115 - add following condition.
      WHEN error_actual_start_date THEN
         gme_common_pvt.log_message ('GME_STEP_START_BATCH_START_ERR');
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_no_direct_compl THEN
        gme_common_pvt.log_message('NO_DIRECT_CERT_ALLOWED');
        x_return_status := FND_API.G_RET_STS_ERROR ;
      WHEN error_future_date THEN
        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_cmplt_date THEN
        gme_common_pvt.log_message('GME_INVALID_DATE_RANGE'
                                  ,'DATE1','Completion date'
                                  ,'DATE2','Start date');
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_quality_status THEN
        gme_common_pvt.log_message('GME_QUALITY_NOT_COMPLETE'
                                  ,'STEP_NO', x_batch_step_rec.batchstep_no
                                  ,'BATCH_NO', p_batch_header_rec.batch_no);
        x_return_status := fnd_api.g_ret_sts_error;
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
   END validate_step_for_complete;

  /*===========================================================================================
   Procedure
     validate_step_cmplt_date
   Description
     This procedure is used to ensure that the step actual start dates are
     not earlier than the batch actual start dates.

     ** no changes for convergence

   Parameters
     p_batch_step_rec           Batch step recrod
     p_batch_header_rec         Batch Header record
     x_batch_start_date         Calculated batch start date
     x_return_status		outcome of the API call
  				S - Success
  				E - Error
  				U - Unexpected error
   History

   =============================================================================================*/

   PROCEDURE validate_step_cmplt_date
      (p_batch_step_rec       IN  GME_BATCH_STEPS%ROWTYPE
      ,p_batch_header_rec     IN  GME_BATCH_HEADER%ROWTYPE
      ,x_batch_start_date     OUT NOCOPY DATE
      ,x_return_status        OUT NOCOPY VARCHAR2) IS

      l_api_name     CONSTANT VARCHAR2 (30)   := 'validate_step_cmplt_date';

      CURSOR Cur_get_dep_steps IS
      SELECT dep_step_id, dep_type, standard_delay
      FROM   gme_batch_step_dependencies
      START WITH  batchstep_id = p_batch_step_rec.batchstep_id
      CONNECT BY  batchstep_id = PRIOR dep_step_id;

      BATCH_STEP_FETCH_ERROR   EXCEPTION;
      INVALID_DATE_ERR         EXCEPTION;
      X_prev_start_date        DATE;
      X_prev_step              NUMBER;
      l_batch_step             GME_BATCH_STEPS%ROWTYPE;

   BEGIN
     IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
     END IF;

     -- Set the return status to success initially *
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Check the date of the step being certified with the batch actual start date
     IF (p_batch_header_rec.actual_start_date IS NOT NULL) THEN
       IF (p_batch_step_rec.actual_start_date < p_batch_header_rec.actual_start_date) THEN
         gme_common_pvt.log_message('GME_BATCH_START_STEP_START_ERR',
                              'STEP_DATE', TO_CHAR(p_batch_step_rec.actual_start_date, 'DD-MON-YYYY HH24:MI:SS'),
                              'STEP_NO', TO_CHAR(p_batch_step_rec.batchstep_no),
                              'BATCH_DATE', TO_CHAR(p_batch_header_rec.actual_start_date, 'DD-MON-YYYY HH24:MI:SS'));
         RAISE INVALID_DATE_ERR;
       END IF;
     END IF;

     -- Here prev refers to the next step since we are moving backwards in the tree
     X_prev_start_date := p_batch_step_rec.actual_start_date;
     X_prev_step       := p_batch_step_rec.batchstep_no;

     -- Move through the dependency tree and see if any dates are invalid
     FOR get_rec IN Cur_get_dep_steps LOOP
       l_batch_step.batchstep_id := get_rec.dep_step_id;

       -- Initialize batch step row
       IF NOT (GME_BATCH_STEPS_DBL.fetch_row(l_batch_step, l_batch_step)) THEN
         RAISE BATCH_STEP_FETCH_ERROR;
       END IF;

       -- Check if the step has a complete date if so validate otherwise assign one to it
       IF (l_batch_step.actual_cmplt_date IS NOT NULL) THEN
         IF  get_rec.dep_type = gme_common_pvt.g_dep_type_finish_start THEN
            IF (p_batch_header_rec.enforce_step_dependency = 1) AND (l_batch_step.actual_cmplt_date + (get_rec.standard_delay/24) > X_prev_start_date) THEN
               gme_common_pvt.log_message('GME_STEP_START_PREV_STEP_CMPLT',
                                    'PREV_DATE',
                                     TO_CHAR(X_prev_start_date, 'DD-MON-YYYY HH24:MI:SS'),
                                    'PREV_STEP', TO_CHAR(X_prev_step),
                                    'CUR_DATE',
                                    TO_CHAR(l_batch_step.actual_cmplt_date +
                                    (get_rec.standard_delay/24), 'DD-MON-YYYY HH24:MI:SS'));
               RAISE INVALID_DATE_ERR;
            END IF;
         ELSIF get_rec.dep_type = gme_common_pvt.g_dep_type_start_start THEN
           IF (p_batch_header_rec.enforce_step_dependency = 1) AND (l_batch_step.actual_start_date + (get_rec.standard_delay/24) > X_prev_start_date) THEN
             gme_common_pvt.log_message('GME_STEP_START_PREV_STEP_START',
                                    'PREV_DATE',
                                     TO_CHAR(X_prev_start_date, 'DD-MON-YYYY HH24:MI:SS'),
                                    'PREV_STEP', TO_CHAR(X_prev_step),
                                    'CUR_DATE',
                                    TO_CHAR(l_batch_step.actual_start_date +
                                     (get_rec.standard_delay/24), 'DD-MON-YYYY HH24:MI:SS'));
             RAISE INVALID_DATE_ERR;
           END IF;
           EXIT;
         END IF;
       ELSIF (get_rec.dep_type = gme_common_pvt.g_dep_type_finish_start) AND
             (get_rec.standard_delay >= 0) THEN
         l_batch_step.actual_cmplt_date := X_prev_start_date - (get_rec.standard_delay/24);
       ELSE
         l_batch_step.actual_cmplt_date := X_prev_start_date;
       END IF;

       -- Check if the step has a start date if so validate otherwise assign one to it
       IF (l_batch_step.actual_start_date IS NULL) THEN
         l_batch_step.actual_start_date := l_batch_step.actual_cmplt_date;
       END IF;

       -- Validate step actual start date against batch actual start date
       IF (p_batch_header_rec.actual_start_date IS NOT NULL) THEN
         IF (l_batch_step.actual_start_date < p_batch_header_rec.actual_start_date) THEN
            gme_common_pvt.log_message('GME_BATCH_START_STEP_START_ERR',
                                'STEP_DATE',
                                 TO_CHAR(l_batch_step.actual_start_date, 'DD-MON-YYYY HH24:MI:SS'),
                                'STEP_NO', TO_CHAR(l_batch_step.batchstep_no),
                                'BATCH_DATE',
                                 TO_CHAR(p_batch_header_rec.actual_start_date, 'DD-MON-YYYY HH24:MI:SS'));
            RAISE INVALID_DATE_ERR;
         END IF;
       END IF;
       X_prev_start_date := l_batch_step.actual_start_date;
       X_prev_step       := l_batch_step.batchstep_no;
     END LOOP;

     x_batch_start_date := X_prev_start_date;

     IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
     END IF;
   EXCEPTION
     WHEN BATCH_STEP_FETCH_ERROR THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
     WHEN INVALID_DATE_ERR THEN
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
   END validate_step_cmplt_date;

END gme_complete_batch_step_pvt;

/

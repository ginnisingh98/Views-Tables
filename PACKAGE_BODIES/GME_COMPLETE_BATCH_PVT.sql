--------------------------------------------------------
--  DDL for Package Body GME_COMPLETE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_COMPLETE_BATCH_PVT" AS
/* $Header: GMEVCMBB.pls 120.22.12010000.5 2009/07/17 05:53:47 apmishra ship $ */

G_DEBUG VARCHAR2(5) := FND_PROFILE.VALUE('AFLOG_LEVEL');

g_pkg_name VARCHAR2(30)  := 'GME_COMPLETE_BATCH_PVT';


  PROCEDURE complete_batch
              (p_batch_header_rec           IN         gme_batch_header%ROWTYPE
              ,x_exception_material_tbl     IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
              ,x_batch_header_rec           OUT NOCOPY gme_batch_header%ROWTYPE
              ,x_return_status              OUT NOCOPY VARCHAR2) IS




    CURSOR Cur_associated_step(v_matl_dtl_id NUMBER) IS
    SELECT step_status
      FROM gme_batch_steps s, gme_batch_step_items item
     WHERE s.batchstep_id = item.batchstep_id
       AND item.material_detail_id = v_matl_dtl_id;

    CURSOR Cur_get_step_to_complete(v_batch_id NUMBER) IS
    SELECT *
      FROM gme_batch_steps
     WHERE batch_id = v_batch_id
       AND step_status NOT IN (gme_common_pvt.g_step_completed, gme_common_pvt.g_step_closed);

    CURSOR Cur_get_phantom_batch(v_batch_id NUMBER) IS
    SELECT hdr.*
      FROM gme_material_details dtl, gme_batch_header hdr
     WHERE dtl.batch_id = v_batch_id
       AND dtl.line_type = gme_common_pvt.g_line_type_ing
       AND dtl.phantom_id IS NOT NULL
       AND hdr.batch_id = dtl.phantom_id
       AND hdr.batch_status NOT IN (gme_common_pvt.g_batch_completed, gme_common_pvt.g_batch_closed);

    CURSOR cur_lock_batch_ingredients (v_batch_id NUMBER) IS
    SELECT *
      FROM gme_material_details
     WHERE batch_id = v_batch_id
       AND (line_type = gme_common_pvt.g_line_type_ing OR
            (line_type = gme_common_pvt.g_line_type_prod AND phantom_line_id IS NOT NULL))
       FOR UPDATE OF actual_qty NOWAIT;

    CURSOR Cur_lock_batch_products(v_batch_id NUMBER) IS
    SELECT *
      FROM gme_material_details
     WHERE batch_id = v_batch_id
       AND line_type IN (gme_common_pvt.g_line_type_prod,gme_common_pvt.g_line_type_byprod)
       AND phantom_line_id IS NULL  -- no phantom products
       FOR UPDATE OF actual_qty NOWAIT;

    l_api_name               CONSTANT   VARCHAR2 (30)                := 'COMPLETE_BATCH';
    l_table_name             CONSTANT   VARCHAR2 (30)                := 'gme_material_details';

    l_step_status            NUMBER;
    l_matl_dtl_tab_ing       gme_common_pvt.material_details_tab;
    l_matl_dtl_tab           gme_common_pvt.material_details_tab;
    l_btch_hdr               gme_batch_header%ROWTYPE;
    l_btch_hdr_tab           gme_common_pvt.batch_headers_tab;
    l_matl_dtl               gme_material_details%ROWTYPE;
    l_matl_dtl_rec           gme_material_details%ROWTYPE;
    l_step_tab               gme_common_pvt.steps_tab;
    l_batch_step_rec         gme_batch_steps%ROWTYPE;
    l_yield_type             NUMBER;
    l_phantom_batch          gme_batch_header%ROWTYPE;
    l_phantom_batch_rec      gme_batch_header%ROWTYPE;
    l_item_rec               mtl_system_items_b%ROWTYPE;
    l_return_status          VARCHAR2(1);
    l_yield                  BOOLEAN;
    l_exception_qty          NUMBER;


    locked_by_other_user     EXCEPTION;
    batch_lines_locked       EXCEPTION;
    --Bug#5296812
    error_get_item           EXCEPTION;
    error_update_batch       EXCEPTION;
    error_process_material   EXCEPTION;
    error_complete_batch     EXCEPTION;
    error_complete_step_rec  EXCEPTION;
    error_release_batch      EXCEPTION;

    PRAGMA exception_init (locked_by_other_user,  -54);

  BEGIN
    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Completing batch_id='||p_batch_header_rec.batch_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' actual_cmplt_date='||to_char(p_batch_header_rec.actual_cmplt_date, 'YYYY-MON-DD HH24:MI:SS'));
    END IF;

    /* Set the return status to success initially */
    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    -- set output structure
    x_batch_header_rec := p_batch_header_rec;

    -- if the batch is pending, call release batch
    IF p_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
      -- call release batch
      gme_release_batch_pvt.release_batch
              (p_batch_header_rec                => p_batch_header_rec
              ,x_batch_header_rec                => x_batch_header_rec
              ,x_return_status                   => l_return_status
              ,x_exception_material_tbl          => x_exception_material_tbl);
      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_release_batch;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;
    END IF;

    -- set batch status
    x_batch_header_rec.batch_status := gme_common_pvt.g_batch_completed;

    -- no need to set the actual completion date because it is expected to have been in p_batch_header_rec

    -- Update the batch header
    IF NOT gme_batch_header_dbl.update_row (p_batch_header => x_batch_header_rec) THEN
      RAISE error_update_batch;
    END IF;

    -- Update WHO columns for output structure
    x_batch_header_rec.last_updated_by := gme_common_pvt.g_user_ident;
    x_batch_header_rec.last_update_date := gme_common_pvt.g_timestamp;
    x_batch_header_rec.last_update_login := gme_common_pvt.g_login_id;

    -- Lock all the ingredents and phantom product lines associated with the batch
    OPEN cur_lock_batch_ingredients (x_batch_header_rec.batch_id);
    FETCH cur_lock_batch_ingredients BULK COLLECT INTO l_matl_dtl_tab_ing;
    IF SQLCODE = -54 THEN
      CLOSE cur_lock_batch_ingredients;
      RAISE batch_lines_locked;
    END IF;
    CLOSE cur_lock_batch_ingredients;

    OPEN Cur_lock_batch_products (x_batch_header_rec.batch_id);
    FETCH Cur_lock_batch_products BULK COLLECT INTO l_matl_dtl_tab;
    IF SQLCODE = -54 THEN
      CLOSE Cur_lock_batch_products;
      RAISE batch_lines_locked;
    END IF;
    CLOSE Cur_lock_batch_products;

    -- Process the products...
    -- 1) yield auto yield products
    -- 2) set wip plan qty

    FOR i IN 1..l_matl_dtl_tab.COUNT LOOP
      l_matl_dtl_rec := l_matl_dtl_tab(i);

      l_yield_type := l_matl_dtl_rec.release_type;
      IF l_yield_type = gme_common_pvt.g_mtl_autobystep_release THEN
        OPEN Cur_associated_step(l_matl_dtl_rec.material_detail_id);
        FETCH Cur_associated_step INTO l_step_status;
        IF Cur_associated_step%NOTFOUND THEN
          l_yield_type := gme_common_pvt.g_mtl_auto_release;
        END IF;
        CLOSE Cur_associated_step;
      END IF;

      IF l_matl_dtl_rec.line_type IN (gme_common_pvt.g_line_type_prod, gme_common_pvt.g_line_type_byprod) THEN
        IF l_yield_type <> gme_common_pvt.g_mtl_autobystep_release THEN
          IF l_yield_type = gme_common_pvt.g_mtl_auto_release THEN
            l_yield := TRUE;
          ELSE
            l_yield := FALSE;
          END IF;

          process_material
              (p_material_detail_rec        => l_matl_dtl_rec
              ,p_yield                      => l_yield
              ,p_trans_date                 => x_batch_header_rec.actual_cmplt_date
              ,p_update_inv_ind             => x_batch_header_rec.update_inventory_ind
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_return_status              => l_return_status);

          IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
            x_return_status := l_return_status;
            RAISE error_process_material;
          END IF;

          IF l_return_status = gme_common_pvt.g_exceptions_err THEN
            x_return_status := gme_common_pvt.g_exceptions_err;
          END IF;
      -- Pawan Kumar added this for bug 5109095
      ELSE -- of l_yield_type <> gme_common_pvt.g_mtl_autobystep_release THEN
	 -- This will insert exception all completed step products and byprodcuts.
     --Bug#5296812  Added the call to the item record.Added the condition to check the inv update ind,and transaction ind.Start
	    gme_material_detail_pvt.get_item_rec
                        (p_org_id                => l_matl_dtl_rec.organization_id
                        ,p_item_id               => l_matl_dtl_rec.inventory_item_id
                        ,x_item_rec              => l_item_rec
                        ,x_return_status         => l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RAISE error_get_item;
       END IF;
      IF p_batch_header_rec.update_inventory_ind = 'Y' AND l_item_rec.mtl_transactions_enabled_flag = 'Y' THEN
       --Bug#5296812 End.
       IF l_step_status = gme_common_pvt.g_step_completed THEN

           l_exception_qty := l_matl_dtl_rec.wip_plan_qty - l_matl_dtl_rec.actual_qty;

         IF l_exception_qty < 0 THEN
           l_exception_qty := 0;
         END IF;

         IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calling create_batch_exception for material_detail_id='||l_matl_dtl_rec.material_detail_id);
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' actual_qty='||l_matl_dtl_rec.actual_qty);
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' wip_plan_qty='||l_matl_dtl_rec.wip_plan_qty);
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception qty='||l_exception_qty);
         END IF;

         gme_release_batch_pvt.create_batch_exception
               (p_material_dtl_rec         => l_matl_dtl_rec
               ,p_pending_move_order_ind   => NULL  -- don't know...allow to calculate
               ,p_pending_rsrv_ind         => NULL  -- don't know...allow to calculate
               ,p_transacted_qty           => 0     -- only auto rel products are transacted.. this is for ing
               ,p_exception_qty            => l_exception_qty
               ,p_force_unconsumed         => fnd_api.g_false
               ,x_exception_material_tbl   => x_exception_material_tbl
               ,x_return_status            => l_return_status);

         IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
           x_return_status := l_return_status;
           RAISE error_complete_batch;
         END IF;

         IF l_return_status = gme_common_pvt.g_exceptions_err THEN
           x_return_status := gme_common_pvt.g_exceptions_err;
         END IF;

        END IF;-- IF l_step_status = gme_common_pvt.g_step_completed THEN
       END IF;--IF p_batch_header_rec.update_inventory_ind = 'Y'.....
       -- Pawan Kumar added above for bug 5109095
      END IF;  -- IF l_yield_type <> gme_common_pvt.g_mtl_autobystep_release THEN
     END IF; -- IF l_matl_dtl_rec.line_type IN (gme_common_pvt.g_line_type_prod, gme_common_pvt.g_line_type_byprod)
    END LOOP;

    -- Complete any steps that are not complete or closed
    OPEN Cur_get_step_to_complete(p_batch_header_rec.batch_id);
    FETCH Cur_get_step_to_complete BULK COLLECT INTO l_step_tab;
    CLOSE Cur_get_step_to_complete;

    FOR i in 1..l_step_tab.COUNT LOOP
      -- Bug 7475553 - removing unconditional overwriting of step dates as it should consider
      -- if the step is already released. The dates will now be set in complete step code.
      -- l_step_tab(i).actual_start_date := p_batch_header_rec.actual_start_date;
      -- l_step_tab(i).actual_cmplt_date := p_batch_header_rec.actual_cmplt_date;
      -- Also, pass in x_batch_header_rec instead of p_batch_header_rec so that step
      -- code logic works properly as it needs the proper batch_status value.
      gme_complete_batch_step_pvt.complete_step_recursive
        (p_batch_step_rec           => l_step_tab(i)
        ,p_batch_header_rec         => x_batch_header_rec
        ,x_batch_step_rec           => l_batch_step_rec
        ,x_exception_material_tbl   => x_exception_material_tbl
        ,x_return_status            => l_return_status);

      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_complete_step_rec;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;
    END LOOP;

    -- Complete any phantom batches that are not complete or closed
    OPEN Cur_get_phantom_batch(p_batch_header_rec.batch_id);
    FETCH Cur_get_phantom_batch BULK COLLECT INTO l_btch_hdr_tab;
    CLOSE Cur_get_phantom_batch;

    -- Complete any phantom batches...
    FOR i IN 1..l_btch_hdr_tab.COUNT LOOP
      l_btch_hdr_tab(i).actual_cmplt_date := x_batch_header_rec.actual_cmplt_date;

      complete_batch
              (p_batch_header_rec           => l_btch_hdr_tab(i)
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_batch_header_rec           => l_btch_hdr
              ,x_return_status              => l_return_status);

      IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
        x_return_status := l_return_status;
        RAISE error_complete_batch;
      END IF;

      IF l_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := gme_common_pvt.g_exceptions_err;
      END IF;

    END LOOP;  -- FOR i IN 1..l_btch_hdr_tab.COUNT LOOP

    -- examine all non-phantom ingredients to determine if there's an exception
    -- phantom products are reported at the time of yield, so don't double report with phantom ingredient
    -- all other products are reported in either process material (non auto yield) or yield_material (auto yield)
    FOR i IN 1..l_matl_dtl_tab_ing.COUNT LOOP
      l_matl_dtl_rec := l_matl_dtl_tab_ing(i);
      IF l_matl_dtl_rec.line_type = gme_common_pvt.g_line_type_ing THEN
        -- don't check for unconsumed first because even if it's fully consumed,
        -- but has reservation or MO, want to report it
        --Bug#5296812  Added the call to the item record.Added the condition to check the inv update ind,and transaction ind.Start.
         gme_material_detail_pvt.get_item_rec
                        (p_org_id                => l_matl_dtl_rec.organization_id
                        ,p_item_id               => l_matl_dtl_rec.inventory_item_id
                        ,x_item_rec              => l_item_rec
                        ,x_return_status         => l_return_status);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             RAISE error_get_item;
          END IF;
       IF p_batch_header_rec.update_inventory_ind = 'Y' AND
         l_item_rec.mtl_transactions_enabled_flag = 'Y' THEN
       --Bug#5296812 End.
        l_exception_qty := l_matl_dtl_rec.wip_plan_qty - l_matl_dtl_rec.actual_qty;

        IF l_exception_qty < 0 THEN
          l_exception_qty := 0;
        END IF;

        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calling create_batch_exception for material_detail_id='||l_matl_dtl_rec.material_detail_id);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' actual_qty='||l_matl_dtl_rec.actual_qty);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' wip_plan_qty='||l_matl_dtl_rec.wip_plan_qty);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception qty='||l_exception_qty);
        END IF;

        gme_release_batch_pvt.create_batch_exception
              (p_material_dtl_rec         => l_matl_dtl_rec
              ,p_pending_move_order_ind   => NULL  -- don't know...allow to calculate
              ,p_pending_rsrv_ind         => NULL  -- don't know...allow to calculate
              ,p_transacted_qty           => 0     -- only auto rel products are transacted.. this is for ing
              ,p_exception_qty            => l_exception_qty
              ,p_force_unconsumed         => fnd_api.g_false
              ,x_exception_material_tbl   => x_exception_material_tbl
              ,x_return_status            => l_return_status);

        IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
          x_return_status := l_return_status;
          RAISE error_complete_batch;
        END IF;

        IF l_return_status = gme_common_pvt.g_exceptions_err THEN
          x_return_status := gme_common_pvt.g_exceptions_err;
        END IF;
       END IF; --IF p_batch_header_rec.update_inventory_ind = 'Y'...
      END IF;
    END LOOP;

    IF NOT gme_common_pvt.create_history
                        (p_batch_header_rec      => p_batch_header_rec
                        ,p_original_status       => gme_common_pvt.g_batch_wip
                        ,p_event_id              => NVL(gme_common_pvt.g_transaction_header_id,-9999)) THEN
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' create history returned error');
      END IF;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
  WHEN  error_update_batch THEN
    gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
    x_return_status := FND_API.g_ret_sts_unexp_error;
    --Bug#5296812 Handling the raised exception error_get_item.
  WHEN  error_process_material OR error_complete_batch OR
        error_complete_step_rec OR error_release_batch OR error_get_item THEN
    NULL;
  WHEN locked_by_other_user or batch_lines_locked THEN
            gme_common_pvt.log_message (
            'GME_RECORD_LOCKED',
            'TABLE_NAME',
            l_table_name
          );
         x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END complete_batch;


  PROCEDURE process_material
              (p_material_detail_rec        IN         gme_material_details%ROWTYPE
              ,p_yield                      IN         BOOLEAN
              ,p_trans_date                 IN         DATE
              ,p_update_inv_ind             IN         VARCHAR2
              ,x_exception_material_tbl     IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
              ,x_return_status              OUT NOCOPY      VARCHAR2) IS


    l_api_name               CONSTANT   VARCHAR2 (30)                := 'process_material';

    l_matl_dtl_rec                gme_material_details%ROWTYPE;
    l_in_phantom_batch_rec        gme_batch_header%ROWTYPE;
    l_phantom_batch_rec           gme_batch_header%ROWTYPE;
    l_return_status               VARCHAR2(1);
    l_item_rec                    mtl_system_items_b%ROWTYPE;
    l_actual_qty                  NUMBER;
    l_start_actual_qty            NUMBER;
    l_exception_qty               NUMBER;

    error_fetch_batch             EXCEPTION;
    error_complete_batch          EXCEPTION;
    error_yield_material          EXCEPTION;
    error_update_row              EXCEPTION;
    error_get_item                EXCEPTION;
    error_batch_exception         EXCEPTION;



  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Processing material material_detail_id='||p_material_detail_rec.material_detail_id);
    END IF;

    /* Set the return status to success initially */
    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    -- Process the material
    -- 1) complete product
    -- 2) complete phantom batch for phantom ingredient

    l_matl_dtl_rec := p_material_detail_rec;

    -- if it's a phantom ingredient, then complete the phantom batch
    -- which will cause the phantom product to be yielded (the passed in ingredient will be consumed in trxm mgr

    -- complete phantom batch
    IF l_matl_dtl_rec.line_type = gme_common_pvt.g_line_type_ing AND l_matl_dtl_rec.phantom_id IS NOT NULL THEN  -- phantom ingredient -> complete the phantom batch
      l_phantom_batch_rec.batch_id := l_matl_dtl_rec.phantom_id;
      IF NOT gme_batch_header_dbl.fetch_row(l_phantom_batch_rec, l_phantom_batch_rec) THEN
        RAISE error_fetch_batch;
      END IF;

      IF l_phantom_batch_rec.batch_status IN (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' processing phantom ingredient material_detail_id='||l_matl_dtl_rec.material_detail_id);
        END IF;
        -- pass in the phantom line id so that release batch will know to yield that product
        l_in_phantom_batch_rec := l_phantom_batch_rec;

        l_in_phantom_batch_rec.actual_start_date := NVL(l_in_phantom_batch_rec.actual_start_date, p_trans_date);
        l_in_phantom_batch_rec.actual_cmplt_date := p_trans_date;

        complete_batch
              (p_batch_header_rec           => l_in_phantom_batch_rec
              ,x_exception_material_tbl     => x_exception_material_tbl
              ,x_batch_header_rec           => l_phantom_batch_rec
              ,x_return_status              => l_return_status);

        IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
          x_return_status := l_return_status;
          RAISE error_complete_batch;
        END IF;

        IF l_return_status = gme_common_pvt.g_exceptions_err THEN
          x_return_status := gme_common_pvt.g_exceptions_err;
        END IF;
      END IF;  -- IF l_phantom_batch_rec.batch_status IN (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip)
    ELSIF l_matl_dtl_rec.line_type IN (gme_common_pvt.g_line_type_prod, gme_common_pvt.g_line_type_byprod) AND p_yield THEN
      gme_material_detail_pvt.get_item_rec
                        (p_org_id                => l_matl_dtl_rec.organization_id
                        ,p_item_id               => l_matl_dtl_rec.inventory_item_id
                        ,x_item_rec              => l_item_rec
                        ,x_return_status         => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        RAISE error_get_item;
      END IF;

      IF p_update_inv_ind = 'Y' AND
         l_item_rec.mtl_transactions_enabled_flag = 'Y' THEN
        l_start_actual_qty := l_matl_dtl_rec.actual_qty;
        yield_material(p_material_dtl_rec    => l_matl_dtl_rec
                      ,p_yield_qty           => NULL  -- take the entire wip plan qty
                      ,p_trans_date          => p_trans_date
                      ,p_item_rec            => l_item_rec
                      ,p_force_unconsumed    => fnd_api.g_false
                      ,x_exception_material_tbl      => x_exception_material_tbl
                      ,x_actual_qty          => l_actual_qty
                      ,x_return_status       => l_return_status);

        IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
          x_return_status := l_return_status;
          RAISE error_yield_material;
        END IF;

        IF l_return_status = gme_common_pvt.g_exceptions_err THEN
          x_return_status := gme_common_pvt.g_exceptions_err;
        END IF;

        l_matl_dtl_rec.actual_qty := l_actual_qty;

        -- if actual qty is met, we still need to see if there are pending product lots...
        -- this is not required in yield material... it's a requirement of complete batch
        IF l_matl_dtl_rec.actual_qty >= l_matl_dtl_rec.wip_plan_qty THEN
          IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
            gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calling create_batch_exception after yield_material not for unyielded but for possibility of pplots for material_detail_id='||l_matl_dtl_rec.material_detail_id);
            gme_debug.put_line (g_pkg_name||'.'||l_api_name||' actual_qty='||l_matl_dtl_rec.actual_qty);
            gme_debug.put_line (g_pkg_name||'.'||l_api_name||' wip_plan_qty='||l_matl_dtl_rec.wip_plan_qty);
            gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception qty='||(l_matl_dtl_rec.actual_qty - l_matl_dtl_rec.wip_plan_qty));
          END IF;

          gme_release_batch_pvt.create_batch_exception
              (p_material_dtl_rec         => l_matl_dtl_rec
              ,p_pending_move_order_ind   => FALSE  -- product doesn't have MO
              ,p_pending_rsrv_ind         => NULL   -- let proc figure out; for product, looks at pplot
              ,p_transacted_qty           => l_actual_qty - l_start_actual_qty
              ,p_exception_qty            => 0
              ,p_force_unconsumed         => fnd_api.g_false
              ,x_exception_material_tbl   => x_exception_material_tbl
              ,x_return_status            => l_return_status);

          IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
            x_return_status := l_return_status;
            RAISE error_yield_material;
          END IF;

          IF l_return_status = gme_common_pvt.g_exceptions_err THEN
            x_return_status := gme_common_pvt.g_exceptions_err;
          END IF;
        END IF;

      ELSE
        l_matl_dtl_rec.actual_qty := l_matl_dtl_rec.plan_qty;
      END IF;
    ELSE  -- check for exception... this should be for all products that are not auto release
    --Bug#5296812 Added the call to the item record.Added the condition to check the inv update ind,and transaction ind.
        gme_material_detail_pvt.get_item_rec
                        (p_org_id                => l_matl_dtl_rec.organization_id
                        ,p_item_id               => l_matl_dtl_rec.inventory_item_id
                        ,x_item_rec              => l_item_rec
                        ,x_return_status         => l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RAISE error_get_item;
        END IF;
       IF p_update_inv_ind = 'Y' AND l_item_rec.mtl_transactions_enabled_flag = 'Y' THEN
       --Bug#5296812 End.
        l_exception_qty := l_matl_dtl_rec.wip_plan_qty - l_matl_dtl_rec.actual_qty;

        IF l_exception_qty < 0 THEN
          l_exception_qty := 0;
        END IF;

        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calling create_batch_exception for material_detail_id='||l_matl_dtl_rec.material_detail_id);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' actual_qty='||l_matl_dtl_rec.actual_qty);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' wip_plan_qty='||l_matl_dtl_rec.wip_plan_qty);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception qty='||l_exception_qty);
        END IF;

        gme_release_batch_pvt.create_batch_exception
              (p_material_dtl_rec         => l_matl_dtl_rec
              ,p_pending_move_order_ind   => FALSE  -- product doesn't have MO
              ,p_pending_rsrv_ind         => NULL   -- let proc figure out; for product, looks at pplot
              ,p_transacted_qty           => 0                -- products other than auto yield don't get transacted in complete
              ,p_exception_qty            => l_exception_qty
              ,p_force_unconsumed         => fnd_api.g_false
              ,x_exception_material_tbl   => x_exception_material_tbl
              ,x_return_status            => l_return_status);

        IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS, gme_common_pvt.g_exceptions_err) THEN
          x_return_status := l_return_status;
          RAISE error_batch_exception;
        END IF;

        IF l_return_status = gme_common_pvt.g_exceptions_err THEN
          x_return_status := gme_common_pvt.g_exceptions_err;
        END IF;
      END IF;--IF p_update_inv_ind = 'Y' AND...
    END IF;  -- IF l_matl_dtl_rec.phantom_id IS NOT NULL...

    -- set WIP plan qty
    -- Commented the below line for Bug 8483455
    --l_matl_dtl_rec.wip_plan_qty := l_matl_dtl_rec.plan_qty;

    IF NOT gme_material_details_dbl.update_row (l_matl_dtl_rec) THEN
      RAISE error_update_row;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
  WHEN error_fetch_batch OR error_update_row THEN
    gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN error_complete_batch OR error_yield_material OR error_get_item OR error_batch_exception THEN
    NULL;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END process_material;


  -- Note: p_yield_qty is the target actual qty; for incr, it's also the target, not the incr
  PROCEDURE yield_material(p_material_dtl_rec  IN gme_material_details%ROWTYPE
                            ,p_yield_qty       IN NUMBER
                            ,p_trans_date      IN DATE
                            ,p_item_rec        IN mtl_system_items_b%ROWTYPE
                            ,p_force_unconsumed IN VARCHAR2
                            ,x_exception_material_tbl    IN OUT NOCOPY gme_common_pvt.exceptions_tab
                            ,x_actual_qty      OUT NOCOPY NUMBER
                            ,x_return_status   OUT NOCOPY VARCHAR2) IS

    l_api_name         CONSTANT   VARCHAR2 (30)                := 'YIELD_MATERIAL';

    l_pending_product_lot_tab     gme_common_pvt.pending_lots_tab;
    l_pp_lot_rec                  gme_pending_product_lots%ROWTYPE;
    i                             NUMBER;

    l_yield_qty                   NUMBER;
    l_trans_date                  DATE;
    l_subinv                      VARCHAR2(10);
    l_locator_id                  NUMBER;
    l_revision                    VARCHAR2(3);
    l_eff_locator_control         NUMBER;
    l_start_actual_qty            NUMBER;
    l_return_status               VARCHAR2(1);

    CURSOR cur_get_item_revision(v_item_id NUMBER, v_org_id NUMBER) IS
    SELECT revision
      FROM mtl_item_revisions_b
     WHERE inventory_item_id = v_item_id
       AND organization_id = v_org_id
       AND effectivity_date <= gme_common_pvt.g_timestamp
     ORDER BY effectivity_date desc;

    error_build_trxn              EXCEPTION;
    error_get_exception           EXCEPTION;
    error_nothing_to_yield        EXCEPTION;
    error_get_pplot               EXCEPTION;
    no_yield_required             EXCEPTION;

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' material_detail_id='||p_material_dtl_rec.material_detail_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_yield_qty='||p_yield_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_trans_date='||to_char(p_trans_date,
                                                                                'YYYY-MON-DD HH24:MI:SS'));
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' line_no='||p_material_dtl_rec.line_no);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' line_type='||p_material_dtl_rec.line_type);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_force_unconsumed='||p_force_unconsumed);
    END IF;

    /* Set the return status to success initially */
    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    x_actual_qty := p_material_dtl_rec.actual_qty;

    -- following global is set only for migration purposes, where transactions need not be created,
    -- this will only be set for complete step; complete batch is not called from migrate; however
    -- if this is needed for complete batch, logic will work there also
    IF gme_release_batch_pvt.g_bypass_txn_creation = 1 THEN
      RAISE no_yield_required;
    END IF;
    /*Pawan Kumar 08-25-2006 bug 5486066 added nvl for wip_plan_qty
      during direct completion, the wip plan qty is also null
      So this was not getting caught in l_yield_qty <= x_actual_qty and this was
      sending transaction quantity as null to transactions where it was failing*/

    l_yield_qty := NVL(p_yield_qty, nvl(p_material_dtl_rec.wip_plan_qty,p_material_dtl_rec.plan_qty));
    l_trans_date := NVL(p_trans_date, gme_common_pvt.g_timestamp);

    l_start_actual_qty := x_actual_qty;

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' l_yield_qty='||l_yield_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' l_trans_date='||to_char(l_trans_date, 'YYYY-MON-DD HH24:MI:SS'));
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' x_actual_qty='||x_actual_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' l_start_actual_qty='||l_start_actual_qty);
    END IF;

    IF l_yield_qty <= x_actual_qty THEN
      -- this returns as success for now; there's nothing additional to yield
      RAISE error_nothing_to_yield;
    END IF;

    IF p_material_dtl_rec.subinventory IS NULL THEN
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line(g_pkg_name||'.'||l_api_name||' subinv on material is NULL; cant yield anything; get exceptions');
      END IF;
      RAISE error_get_exception;
    END IF;

    IF p_material_dtl_rec.locator_id IS NULL THEN
      -- check if it's locator control, we need a locator...
      /* Bug 5441643 Added NVL condition for location control code*/
      l_eff_locator_control :=
               gme_common_pvt.eff_locator_control
                     (p_organization_id        => p_material_dtl_rec.organization_id
                     ,p_org_control            => gme_common_pvt.g_org_locator_control
                     ,p_subinventory           => p_material_dtl_rec.subinventory
                     ,p_item_control           => NVL(p_item_rec.location_control_code,1)
                     ,p_item_loc_restrict      => p_item_rec.restrict_locators_code
                     ,p_action                 => gme_common_pvt.g_prod_comp_txn_action);
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' l_eff_locator_control='||l_eff_locator_control);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' organization_id='||p_material_dtl_rec.organization_id);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' g_org_locator_control='||gme_common_pvt.g_org_locator_control);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' subinventory='||p_material_dtl_rec.subinventory);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' inventory_item_id='||p_item_rec.inventory_item_id);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' location_control_code='||p_item_rec.location_control_code);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' restrict_locators_code='||p_item_rec.restrict_locators_code);
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_action='||gme_common_pvt.g_prod_comp_txn_action);
      END IF;
      IF l_eff_locator_control <> 1 THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' locator on material is NULL and material is eff locator control; cant yield anything; get exceptions');
        END IF;
        RAISE error_get_exception;
      END IF;
    END IF;

    l_subinv := p_material_dtl_rec.subinventory;
    l_locator_id := p_material_dtl_rec.locator_id;

    IF p_item_rec.revision_qty_control_code = 2 THEN -- under revision control
      IF p_material_dtl_rec.revision IS NOT NULL THEN
        l_revision := p_material_dtl_rec.revision;
      ELSE
        OPEN cur_get_item_revision(p_material_dtl_rec.inventory_item_id,
                                   p_material_dtl_rec.organization_id);
        FETCH cur_get_item_revision INTO l_revision;
        CLOSE cur_get_item_revision;
      END IF;
    END IF;  -- IF p_revision_qty_control_code = 2

    IF p_item_rec.lot_control_code = 1 THEN -- not lot control
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' item not lot control');
      END IF;

      build_and_create_transaction
              (p_mtl_dtl_rec           => p_material_dtl_rec
              ,p_pp_lot_rec            => NULL
              ,p_subinv                => l_subinv
              ,p_locator_id            => l_locator_id
              ,p_trans_date            => l_trans_date
              ,p_yield_qty             => l_yield_qty
              ,p_revision              => l_revision
              ,p_sec_uom_code          => p_item_rec.secondary_uom_code
              ,x_actual_qty            => x_actual_qty
              ,x_return_status         => l_return_status);

      IF l_return_status NOT IN (gme_common_pvt.g_not_transactable, FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE error_build_trxn;
      END IF;
    ELSE  -- lot control... go to pending product lots
      gme_pending_product_lots_pvt.get_pending_lot
              (p_material_detail_id           => p_material_dtl_rec.material_detail_id
              ,x_return_status                => l_return_status
              ,x_pending_product_lot_tbl      => l_pending_product_lot_tab);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        RAISE error_get_pplot;
      END IF;

      i := 1;

      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' l_yield_qty='||l_yield_qty);
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' x_actual_qty='||x_actual_qty);
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' count from pplot='||l_pending_product_lot_tab.COUNT);
      END IF;

      WHILE l_yield_qty > x_actual_qty AND i <= l_pending_product_lot_tab.COUNT LOOP

        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' pending lot loop i='||i);
          gme_debug.put_line (g_pkg_name||'.'||l_api_name||' pending lot loop x_actual_qty='||x_actual_qty);
        END IF;

        l_pp_lot_rec := l_pending_product_lot_tab(i);

        build_and_create_transaction
              (p_mtl_dtl_rec           => p_material_dtl_rec
              ,p_pp_lot_rec            => l_pp_lot_rec
              ,p_subinv                => l_subinv
              ,p_locator_id            => l_locator_id
              ,p_trans_date            => l_trans_date
              ,p_yield_qty             => l_yield_qty
              ,p_revision              => l_revision
              ,p_sec_uom_code          => p_item_rec.secondary_uom_code
              ,x_actual_qty            => x_actual_qty
              ,x_return_status         => l_return_status);
        IF l_return_status NOT IN (gme_common_pvt.g_not_transactable, FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE error_build_trxn;
        END IF;

        i := i + 1; -- move on to the next lot
      END LOOP;
    END IF;  -- IF p_item_rec.lot_control_code = 1 THEN

    IF x_actual_qty < l_yield_qty THEN
      RAISE error_get_exception;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;


  EXCEPTION
  WHEN error_build_trxn OR error_get_pplot OR no_yield_required THEN
    NULL;
  WHEN error_nothing_to_yield THEN
    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exiting without yield because actual_qty= '||x_actual_qty||' and target yield qty = '||l_yield_qty);
    END IF;

    WHEN error_get_exception THEN
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception block for get exceptions:');
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' x_actual_qty='||x_actual_qty);
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' l_start_actual_qty='||l_start_actual_qty);
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' l_yield_qty='||l_yield_qty);
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' exception qty='||(l_yield_qty - x_actual_qty));
      END IF;

      gme_release_batch_pvt.create_batch_exception
              (p_material_dtl_rec         => p_material_dtl_rec
              ,p_pending_move_order_ind   => FALSE
              ,p_pending_rsrv_ind         => NULL   -- let proc figure out; for product, looks at pplot
              ,p_transacted_qty           => x_actual_qty - l_start_actual_qty
              ,p_exception_qty            => l_yield_qty - x_actual_qty
              ,p_force_unconsumed         => p_force_unconsumed
              ,x_exception_material_tbl   => x_exception_material_tbl
              ,x_return_status            => x_return_status);

  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END yield_material;

  PROCEDURE build_and_create_transaction
              (p_mtl_dtl_rec           IN gme_material_details%ROWTYPE
              ,p_pp_lot_rec            IN gme_pending_product_lots%ROWTYPE
              ,p_subinv                IN VARCHAR2
              ,p_locator_id            IN NUMBER
              ,p_trans_date            IN DATE
              ,p_yield_qty             IN NUMBER
              ,p_revision              IN VARCHAR2 DEFAULT NULL
              ,p_sec_uom_code          IN VARCHAR2 DEFAULT NULL
              ,x_actual_qty            IN OUT NOCOPY NUMBER
              ,x_return_status         OUT NOCOPY VARCHAR2) IS

    l_api_name               CONSTANT   VARCHAR2 (30)                := 'build_and_create_transaction';

    l_transaction_rec        mtl_transactions_interface%ROWTYPE;
    l_lot_tbl                gme_common_pvt.mtl_trans_lots_inter_tbl;
    l_trxn_qty               NUMBER;
    l_dtl_qty                NUMBER;
    l_sec_qty                NUMBER;

    error_build_mmti         EXCEPTION;
    error_create_trxn        EXCEPTION;
    error_relieve_pp_lot     EXCEPTION;

  BEGIN
    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' material_detail_id='||p_mtl_dtl_rec.material_detail_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_subinv='||p_subinv);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_locator_id='||p_locator_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_yield_qty='||p_yield_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_revision='||p_revision);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_sec_uom_code='||p_sec_uom_code);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' x_actual_qty='||x_actual_qty);
    END IF;

    /* Set the return status to success initially */
    x_return_status       := FND_API.G_RET_STS_SUCCESS;

    constr_mmti(p_mtl_dtl_rec               => p_mtl_dtl_rec
               ,p_yield_qty                 => p_yield_qty
               ,p_subinv                    => p_subinv
               ,p_revision                  => p_revision
               ,p_locator_id                => p_locator_id
               ,p_pp_lot_rec                => p_pp_lot_rec
               ,x_mmti_rec                  => l_transaction_rec
               ,x_mmli_tbl                  => l_lot_tbl
               ,x_sec_qty                   => l_sec_qty
               ,x_dtl_qty                   => l_dtl_qty
               ,x_return_status             => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE error_build_mmti;
    END IF;

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' after constr_mmti l_dtl_qty := '||l_dtl_qty);
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' after constr_mmti l_sec_qty := '||l_sec_qty);
    END IF;

    -- Bug 7262112 - Added '=' to condition. No need to recompute secondary values if yielding the full amount.
    IF l_dtl_qty <= p_yield_qty - x_actual_qty THEN
      l_trxn_qty := l_dtl_qty;
    ELSE
      l_trxn_qty := p_yield_qty - x_actual_qty;
      /* Bug 5256543 l_sec_qty was set to null that was incorrect it has to be recalculated from new l_trxn_qty */
      IF (p_sec_uom_code IS NOT NULL) THEN
        l_sec_qty := INV_CONVERT.inv_um_convert
                              (item_id            => p_mtl_dtl_rec.inventory_item_id
                              ,lot_number         => p_pp_lot_rec.lot_number
                              ,organization_id    => p_mtl_dtl_rec.organization_id
                              ,PRECISION          => gme_common_pvt.g_precision
                              ,from_quantity      => l_trxn_qty
                              ,from_unit          => p_mtl_dtl_rec.dtl_um
                              ,to_unit            => p_sec_uom_code
                              ,from_name          => NULL
                              ,to_name            => NULL);
      END IF;
    END IF;

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calculated l_trxn_qty := '||l_trxn_qty);
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' calculated l_sec_qty := '||l_sec_qty);
    END IF;

    IF p_mtl_dtl_rec.line_type = gme_common_pvt.g_line_type_prod THEN
      l_transaction_rec.transaction_type_id := gme_common_pvt.g_prod_completion;
    ELSE
      l_transaction_rec.transaction_type_id := gme_common_pvt.g_byprod_completion;
    END IF;

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' l_transaction_rec.transaction_type_id := '||l_transaction_rec.transaction_type_id);
    END IF;

    l_transaction_rec.transaction_date := p_trans_date;
    l_transaction_rec.transaction_quantity := l_trxn_qty;
    l_transaction_rec.secondary_uom_code := p_sec_uom_code;

    IF l_sec_qty IS NOT NULL THEN
      l_transaction_rec.secondary_transaction_quantity := l_sec_qty;
    END IF;

    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' transaction_date='||to_char(l_transaction_rec.transaction_date
                                                                         ,'YYYY-MON-DD HH24:MI:SS'));
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||' transaction_qty='||l_transaction_rec.transaction_quantity);
    END IF;

    l_transaction_rec.transaction_uom := p_mtl_dtl_rec.dtl_um;

    IF l_lot_tbl.count > 0 THEN
      IF l_lot_tbl(1).lot_number IS NOT NULL THEN
        l_lot_tbl(1).transaction_quantity := l_transaction_rec.transaction_quantity;
        IF l_sec_qty IS NOT NULL THEN
          l_lot_tbl(1).secondary_transaction_quantity := l_sec_qty;
        END IF;
      END IF;
    END IF;

    gme_transactions_pvt.create_material_txn
                        (p_mmti_rec             => l_transaction_rec
                        ,p_mmli_tbl             => l_lot_tbl
                        ,x_return_status        => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||' gme_transactions_pvt.create_transaction returned error');
      END IF;
      RAISE error_create_trxn;
    END IF;

    x_actual_qty := x_actual_qty + l_trxn_qty;

    -- If pending product lot, then decrease qty, entry remains if the qty goes to zero
    IF p_pp_lot_rec.pending_product_lot_id IS NOT NULL THEN
      gme_pending_product_lots_pvt.relieve_pending_lot
        (p_pending_lot_id           => p_pp_lot_rec.pending_product_lot_id
        ,p_quantity                 => l_trxn_qty
        ,p_secondary_quantity       => l_sec_qty
        ,x_return_status            => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE error_relieve_pp_lot;
      END IF;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' x_actual_qty='||x_actual_qty);
    END IF;

  EXCEPTION
  WHEN error_create_trxn OR error_relieve_pp_lot OR error_build_mmti THEN
    NULL;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END build_and_create_transaction;

  PROCEDURE constr_mmti
    (p_mtl_dtl_rec              IN   gme_material_details%ROWTYPE
    ,p_yield_qty                IN   NUMBER
    ,p_subinv                   IN   VARCHAR2
    ,p_locator_id               IN   NUMBER
    ,p_revision                 IN   VARCHAR2
    ,p_pp_lot_rec               IN   gme_pending_product_lots%ROWTYPE
    ,x_mmti_rec                 OUT  NOCOPY mtl_transactions_interface%ROWTYPE
    ,x_mmli_tbl                 OUT  NOCOPY gme_common_pvt.mtl_trans_lots_inter_tbl
    ,x_sec_qty                  OUT  NOCOPY NUMBER
    ,x_dtl_qty                  OUT  NOCOPY NUMBER
    ,x_return_status            OUT  NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT VARCHAR2 (30)      := 'CONSTR_MMTI';
  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    -- consturct mtl_transactions_interface
    x_mmti_rec.transaction_source_id        := p_mtl_dtl_rec.batch_id;  -- batch_id
    x_mmti_rec.trx_source_line_id           := p_mtl_dtl_rec.material_detail_id;  -- material_detail_id
    x_mmti_rec.inventory_item_id            := p_mtl_dtl_rec.inventory_item_id;
    x_mmti_rec.organization_id              := p_mtl_dtl_rec.organization_id;
    x_mmti_rec.subinventory_code            := p_subinv;
    x_mmti_rec.locator_id                   := p_locator_id;
    x_mmti_rec.revision                     := p_revision;
    x_mmti_rec.transaction_sequence_id      := p_pp_lot_rec.pending_product_lot_id;
    x_dtl_qty                               := p_yield_qty;
    -- construct mtl_transaction_lots_interface
    IF p_pp_lot_rec.lot_number IS NOT NULL THEN
      x_mmli_tbl(1).lot_number := p_pp_lot_rec.lot_number;
      x_mmli_tbl(1).reason_id  := p_pp_lot_rec.reason_id;
      /* Bug 5256543 Assign revision only if not null otherwise it will come from mtl dtl line */
      IF (p_pp_lot_rec.revision IS NOT NULL) THEN
        x_mmti_rec.revision := p_pp_lot_rec.revision;
      END IF;
      x_mmti_rec.reason_id := p_pp_lot_rec.reason_id;
      x_dtl_qty            := p_pp_lot_rec.quantity;
      x_sec_qty            := p_pp_lot_rec.secondary_quantity;
    END IF;

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
  END constr_mmti;

  PROCEDURE validate_batch_for_complete (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,x_batch_header_rec     OUT NOCOPY gme_batch_header%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2) IS

      l_api_name   CONSTANT VARCHAR2 (30)           := 'validate_batch_for_complete';

      CURSOR Cur_gme_batch_steps (v_batch_id NUMBER) IS
      SELECT count(1)
      FROM   gme_batch_steps
      WHERE  step_status NOT IN (gme_common_pvt.g_step_completed, gme_common_pvt.g_step_closed)
      AND    batch_id = v_batch_id
      AND    rownum = 1;

      l_is_step                   NUMBER;
      l_batch_header_rec          gme_batch_header%ROWTYPE;
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
      error_batch_type            EXCEPTION;
      error_batch_status          EXCEPTION;
      error_phantom               EXCEPTION;
      error_steps_not_complete    EXCEPTION;
      error_cmplt_date            EXCEPTION;
      error_future_date           EXCEPTION;
      error_vr_dates              EXCEPTION;
   BEGIN
      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                    gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := FND_API.g_ret_sts_success;

      -- set output structure
      x_batch_header_rec := p_batch_header_rec;

      -- set actual complete date if it's not passed
      IF p_batch_header_rec.actual_cmplt_date IS NULL THEN
         x_batch_header_rec.actual_cmplt_date := SYSDATE;
      END IF;

      IF p_batch_header_rec.batch_type = gme_common_pvt.g_doc_type_fpo THEN
        RAISE error_batch_type;
      END IF;

      IF p_batch_header_rec.batch_status NOT IN
                         (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
        RAISE error_batch_status;
      END IF;

      IF p_batch_header_rec.parentline_id IS NOT NULL THEN
        RAISE error_phantom;
      END IF;

      OPEN Cur_gme_batch_steps (p_batch_header_rec.batch_id);
      FETCH Cur_gme_batch_steps INTO l_is_step;
      CLOSE Cur_gme_batch_steps;

      IF l_is_step > 1 THEN
        RAISE error_steps_not_complete;
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

      -- validate completion date with actual start date and current date
      IF x_batch_header_rec.actual_cmplt_date < x_batch_header_rec.actual_start_date THEN
         RAISE error_cmplt_date;
      ELSIF x_batch_header_rec.actual_cmplt_date > SYSDATE THEN
         RAISE error_future_date;
      END IF;

      IF NVL (g_debug, gme_debug.g_log_procedure + 1) <=
                                                     gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

   EXCEPTION
      WHEN error_phantom THEN
        gme_common_pvt.log_message ('PM_INVALID_PHANTOM_ACTION');
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN error_batch_type OR error_batch_status THEN
        gme_common_pvt.log_message('GME_API_INVALID_BATCH_COMPL');
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_steps_not_complete THEN
        gme_common_pvt.log_message('GME_STEPS_NOT_COMPLETE');
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_cmplt_date THEN
        gme_common_pvt.log_message('GME_INVALID_DATE_RANGE'
                                  ,'DATE1','Completion date'
                                  ,'DATE2','Start date');
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_future_date THEN
        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
        fnd_msg_pub.ADD;
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
   END validate_batch_for_complete;

END gme_complete_batch_pvt;

/

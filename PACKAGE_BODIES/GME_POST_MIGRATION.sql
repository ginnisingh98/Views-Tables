--------------------------------------------------------
--  DDL for Package Body GME_POST_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_POST_MIGRATION" AS
/* $Header: GMEVRCBB.pls 120.9.12010000.3 2009/12/15 19:44:13 gmurator ship $ */
  g_migration_run_id    NUMBER;
  g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
  PROCEDURE recreate_open_batches(err_buf  OUT NOCOPY VARCHAR2,
                                  ret_code OUT NOCOPY VARCHAR2) IS
    l_api_name              VARCHAR2(30) := 'RECREATE_OPEN_BATCHES';
    l_item_rec              mtl_system_items_vl%ROWTYPE;
    l_batch_header          gme_batch_header%ROWTYPE;
    l_batch_tbl             gme_common_pvt.batch_headers_tab;
    l_mtl_dtl_mig_tbl       gme_post_migration.mtl_dtl_mig_tab;
    l_mtl_dtl_tbl           gme_common_pvt.material_details_tab;
    l_in_mtl_dtl_tbl        gme_common_pvt.material_details_tab;
    l_steps_mig_tbl         gme_post_migration.steps_mig_tab;
    l_steps_tbl             gme_common_pvt.steps_tab;
    l_activities_mig_tbl    gme_post_migration.activ_mig_tab;
    l_activities_tbl        gme_common_pvt.activities_tab;
    l_resources_mig_tbl     gme_post_migration.rsrc_mig_tab;
    l_resources_tbl         gme_common_pvt.resources_tab;
    l_proc_param_mig_tbl    gme_post_migration.process_param_mig_tab;
    l_proc_param_tbl        gme_post_migration.process_param_tab;
    l_rsrc_txns_mig_tbl     gme_post_migration.rsrc_txns_mig_tab;
    l_rsrc_txns_tbl         gme_post_migration.rsrc_txns_tab;
    l_trolin_tbl            inv_move_order_pub.trolin_tbl_type;
    l_wip_entity_id         NUMBER;
    l_organization_id       NUMBER;
    l_old_batchstep_id      NUMBER;
    l_old_bstep_activ_id    NUMBER;
    l_old_bstep_rsrc_id     NUMBER;
    l_item_id               NUMBER;
    l_current_org_id        NUMBER := 0;
    l_temp_qty              NUMBER := 0;
    l_msg_count             NUMBER := 0;
    l_actv_count            NUMBER := 0;
    l_rsrc_count            NUMBER := 0;
    l_pprm_count            NUMBER := 0;
    l_rtxn_count            NUMBER := 0;
    l_return_status         VARCHAR2(1);
    l_def_whse              VARCHAR2(4);
    l_subinventory          VARCHAR2(10);
    l_msg_data              VARCHAR2(2000);
    l_batch_prefix          VARCHAR2(30) := FND_PROFILE.VALUE('GME_BATCH_PREFIX');
    l_fpo_prefix            VARCHAR2(30) := FND_PROFILE.VALUE('GME_FPO_PREFIX');
    l_prefix                VARCHAR2(30);
    l_item_no               VARCHAR2(32);
    setup_failed            EXCEPTION;
    calc_mtl_req_date_err   EXCEPTION;
    create_mo_hdr_err       EXCEPTION;
    create_mo_line_err      EXCEPTION;
    item_not_defined        EXCEPTION;

    CURSOR Cur_get_batches IS
      SELECT *
      FROM   gme_batch_header_mig
      WHERE  NVL(migrated_batch_ind, ' ') <> 'M'
             AND organization_id IS NOT NULL
      ORDER BY batch_id;
    CURSOR Cur_get_materials(v_batch_id NUMBER) IS
      SELECT *
      FROM   gme_material_details_mig
      WHERE  batch_id = v_batch_id
      ORDER BY line_type, line_no;
    CURSOR Cur_item_mst(v_item_id NUMBER) IS
      SELECT item_no
      FROM   ic_item_mst
      WHERE  item_id = v_item_id;
    CURSOR Cur_get_item(v_org_id            NUMBER,
                        v_inventory_item_id NUMBER) IS
      SELECT *
      FROM   mtl_system_items_vl
      WHERE  organization_id = v_org_id
             AND inventory_item_id = v_inventory_item_id;
    CURSOR Cur_get_trans_whse(v_trans_id NUMBER) IS
      SELECT whse_code
      FROM   ic_tran_pnd
      WHERE  trans_id = v_trans_id;
    CURSOR Cur_get_steps(v_batch_id NUMBER) IS
      SELECT *
      FROM   gme_batch_steps_mig
      WHERE  batch_id = v_batch_id
      ORDER BY batchstep_no;
    CURSOR Cur_get_activities(v_batchstep_id NUMBER) IS
      SELECT *
      FROM   gme_batch_step_activ_mig
      WHERE  batchstep_id = v_batchstep_id;

    -- Bug 9090024 - Where clause was incorrectly looking at step id instead of step activity id.
    CURSOR Cur_get_resources(v_batchstep_activity_id NUMBER) IS
      SELECT *
      FROM   gme_batch_step_resources_mig
      WHERE  batchstep_activity_id = v_batchstep_activity_id;

    CURSOR Cur_get_process_params(v_batchstep_resource_id NUMBER) IS
      SELECT *
      FROM   gme_process_parameters_mig
      WHERE  batchstep_resource_id = v_batchstep_resource_id;
    CURSOR Cur_get_rsrc_txns(v_batchstep_rsrc_id NUMBER) IS
      SELECT *
      FROM   gme_resource_txns_mig
      WHERE  line_id = v_batchstep_rsrc_id;
  BEGIN
    IF (g_debug IS NOT NULL) THEN
      gme_debug.log_initialize('Migration');
    END IF;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    g_migration_run_id := gma_migration.gma_migration_start ('GME', 'RECREATE_OPEN_BATCHES');
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Migration RUN ID = '||g_migration_run_id);
    END IF;
    FOR get_batches IN Cur_get_batches LOOP
      BEGIN
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Current batch is '||get_batches.plant_code||'-'||get_batches.batch_no);
        END IF;
      	gme_common_pvt.set_timestamp;
      	IF (l_current_org_id <> get_batches.organization_id) THEN
           IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('Doing setup for org = '||get_batches.organization_id);
           END IF;

           -- Bug 9164563 - Reset the global flag to make sure setup is done for new org.
           gme_common_pvt.g_setup_done := FALSE;

      	  IF NOT (gme_common_pvt.setup(p_org_id => get_batches.organization_id)) THEN
      	    RAISE setup_failed;
      	  END IF;
      	  l_current_org_id := get_batches.organization_id;
      	END IF;

        -- Bug 9090024 - Look at batch type from the fetched data not the local variable.
        -- The existing check is wrong because l_batch_header does not get set until later.
        -- IF (l_batch_header.batch_type = 0) THEN
        IF (get_batches.batch_type = 0) THEN
          l_prefix := l_batch_prefix;
        ELSE
          l_prefix := l_fpo_prefix;
        END IF;


      	UPDATE gme_batch_header
      	SET batch_no = SUBSTR(batch_no,1,30)||'-M'
      	WHERE batch_id = get_batches.batch_id;
      	UPDATE wip_entities
      	SET wip_entity_name = wip_entity_name||'-M'
      	WHERE entity_type = DECODE(get_batches.batch_type, 10, gme_common_pvt.g_wip_entity_type_fpo, gme_common_pvt.g_wip_entity_type_batch)
      	      AND organization_id = get_batches.organization_id
      	      AND wip_entity_name = l_prefix||get_batches.batch_no;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Start batch header');
        END IF;
      	/* Process batch header record */
      	build_batch_hdr(p_batch_header_mig => get_batches,
                        x_batch_header     => l_batch_header);
        SELECT wip_entities_s.NEXTVAL INTO l_wip_entity_id FROM DUAL;
        l_batch_header.plant_code              := NULL;
        l_batch_header.batch_status            := 1;
        l_batch_header.enforce_step_dependency := 0;
        l_batch_header.terminated_ind          := 0;
        l_batch_header.enhanced_pi_ind         := 'N';
        l_batch_header.batch_id                := l_wip_entity_id;
        l_batch_header.wip_whse_code           := NULL;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Before wip entities');
        END IF;
        INSERT INTO wip_entities
                   (wip_entity_id, organization_id
                   ,last_update_date, last_updated_by
                   ,creation_date, created_by
                   ,wip_entity_name
                   ,entity_type
                   ,gen_object_id)
        VALUES     (l_wip_entity_id, l_batch_header.organization_id
                   ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                   ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                   ,l_prefix||l_batch_header.batch_no
                   ,DECODE (l_batch_header.batch_type
                   ,0, gme_common_pvt.g_wip_entity_type_batch
                   ,gme_common_pvt.g_wip_entity_type_fpo)
                   ,mtl_gen_object_id_s.NEXTVAL);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After wip entities');
        END IF;
        l_batch_tbl(1) := l_batch_header;
        FORALL a IN 1..l_batch_tbl.count
          INSERT INTO gme_batch_header VALUES l_batch_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After batch header');
        END IF;
      	/* Process material details records */
      	OPEN Cur_get_materials(get_batches.batch_id);
      	FETCH Cur_get_materials BULK COLLECT INTO l_mtl_dtl_mig_tbl;
      	CLOSE Cur_get_materials;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('No. of materials = '||l_mtl_dtl_mig_tbl.count);
        END IF;
      	build_mtl_dtl(p_mtl_dtl_mig => l_mtl_dtl_mig_tbl,
                      x_mtl_dtl     => l_mtl_dtl_tbl);
        FOR i IN 1..l_mtl_dtl_tbl.count LOOP
          OPEN Cur_get_item(l_mtl_dtl_tbl(i).organization_id, l_mtl_dtl_tbl(i).inventory_item_id);
          FETCH Cur_get_item INTO l_item_rec;
          IF (Cur_get_item%NOTFOUND) THEN
            CLOSE Cur_get_item;
            l_item_id := l_mtl_dtl_tbl(i).item_id;
            RAISE item_not_defined;
          END IF;
          CLOSE Cur_get_item;
          IF (l_item_rec.primary_uom_code <> l_mtl_dtl_tbl(i).dtl_um) THEN
            l_temp_qty := inv_convert.inv_um_convert(item_id              => l_mtl_dtl_tbl(i).inventory_item_id
                                                    ,organization_id      => l_mtl_dtl_tbl(i).organization_id
                                                    ,PRECISION            => gme_common_pvt.g_precision
                                                    ,from_quantity        => l_mtl_dtl_tbl(i).original_qty
                                                    ,from_unit            => l_mtl_dtl_tbl(i).dtl_um
                                                    ,to_unit              => l_item_rec.primary_uom_code
                                                    ,from_name            => NULL
                                                    ,to_name              => NULL);
          ELSE
            l_temp_qty := l_mtl_dtl_tbl(i).original_qty;
          END IF;
          /* Locator_id contains the default trans_id, we will try to put default subinventory on material using this */
          l_subinventory := NULL;
          IF (l_mtl_dtl_tbl(i).locator_id IS NOT NULL) THEN
            OPEN Cur_get_trans_whse(l_mtl_dtl_tbl(i).locator_id);
            FETCH Cur_get_trans_whse INTO l_def_whse;
            CLOSE Cur_get_trans_whse;
            get_subinventory(p_whse_code       => l_def_whse,
                             x_subinventory    => l_subinventory,
                             x_organization_id => l_organization_id);
            IF (l_organization_id <> l_mtl_dtl_tbl(i).organization_id) THEN
              l_subinventory := NULL;
            END IF;
          END IF;
          SELECT gem5_line_id_s.NEXTVAL INTO l_mtl_dtl_tbl(i).material_detail_id FROM DUAL;
          l_mtl_dtl_tbl(i).batch_id             := l_batch_header.batch_id;
          l_mtl_dtl_tbl(i).actual_qty           := 0;
          l_mtl_dtl_tbl(i).wip_plan_qty         := NULL;
          l_mtl_dtl_tbl(i).backordered_qty      := 0;
          l_mtl_dtl_tbl(i).dispense_ind         := 'N';
          l_mtl_dtl_tbl(i).original_primary_qty := l_temp_qty;
          l_mtl_dtl_tbl(i).subinventory         := l_subinventory;
          l_mtl_dtl_tbl(i).locator_id           := NULL;
          l_mtl_dtl_tbl(i).revision             := NULL;
        END LOOP;

        FORALL a IN 1..l_mtl_dtl_tbl.count
          INSERT INTO gme_material_details VALUES l_mtl_dtl_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After materials');
        END IF;
        /* Process batch step records */
        l_steps_tbl.delete;
        l_activities_tbl.delete;
        l_resources_tbl.delete;
        l_proc_param_tbl.delete;
        l_rsrc_txns_tbl.delete;
      	OPEN Cur_get_steps(get_batches.batch_id);
      	FETCH Cur_get_steps BULK COLLECT INTO l_steps_mig_tbl;
      	CLOSE Cur_get_steps;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('No.of steps = '||l_steps_mig_tbl.count);
        END IF;
        build_steps(p_steps_mig => l_steps_mig_tbl,
                    x_steps     => l_steps_tbl);
        FOR i IN 1..l_steps_tbl.count LOOP
          l_old_batchstep_id := l_steps_tbl(i).batchstep_id;
          SELECT gme_batch_step_s.NEXTVAL INTO l_steps_tbl(i).batchstep_id FROM DUAL;
          l_steps_tbl(i).batch_id          := l_batch_header.batch_id;
          l_steps_tbl(i).step_status       := 1;
          l_steps_tbl(i).actual_start_date := NULL;
          l_steps_tbl(i).actual_cmplt_date := NULL;
          l_steps_tbl(i).step_close_date   := NULL;
          l_steps_tbl(i).terminated_ind    := NULL;
          /* Process batch step activity records */
          OPEN Cur_get_activities(l_old_batchstep_id);
          FETCH Cur_get_activities BULK COLLECT INTO l_activities_mig_tbl;
          CLOSE Cur_get_activities;
          l_actv_count := l_activities_tbl.count;
          build_activities(p_activities_mig => l_activities_mig_tbl,
                           x_activities     => l_activities_tbl);
          IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line('No. of activities = '||l_activities_mig_tbl.count);
          END IF;
          FOR j IN (l_actv_count + 1)..l_activities_tbl.count LOOP
            l_old_bstep_activ_id := l_activities_tbl(j).batchstep_activity_id;
            SELECT gme_batch_step_activity_s.NEXTVAL INTO l_activities_tbl(j).batchstep_activity_id FROM DUAL;
            l_activities_tbl(j).batch_id          := l_batch_header.batch_id;
            l_activities_tbl(j).batchstep_id      := l_steps_tbl(i).batchstep_id;
            l_activities_tbl(j).actual_start_date := NULL;
            l_activities_tbl(j).actual_cmplt_date := NULL;

            /* Process batch step resource records */
            OPEN Cur_get_resources(l_old_bstep_activ_id);
            FETCH Cur_get_resources BULK COLLECT INTO l_resources_mig_tbl;
            CLOSE Cur_get_resources;
            l_rsrc_count := l_resources_tbl.count;
            build_resources(p_resources_mig => l_resources_mig_tbl,
                            x_resources     => l_resources_tbl);
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('No. of resources = '||l_resources_mig_tbl.count);
            END IF;
            FOR k IN (l_rsrc_count + 1)..l_resources_tbl.count LOOP
              l_old_bstep_rsrc_id := l_resources_tbl(k).batchstep_resource_id;
              SELECT gem5_batchstepline_id_s.NEXTVAL INTO l_resources_tbl(k).batchstep_resource_id FROM DUAL;
              l_resources_tbl(k).batch_id              := l_batch_header.batch_id;
              l_resources_tbl(k).batchstep_id          := l_steps_tbl(i).batchstep_id;
              l_resources_tbl(k).batchstep_activity_id := l_activities_tbl(j).batchstep_activity_id;
              l_resources_tbl(k).actual_start_date     := NULL;
              l_resources_tbl(k).actual_cmplt_date     := NULL;
              /* Process the process parameter records for the resource */
              OPEN Cur_get_process_params(l_old_bstep_rsrc_id);
              FETCH Cur_get_process_params BULK COLLECT INTO l_proc_param_mig_tbl;
              CLOSE Cur_get_process_params;
              l_pprm_count := l_proc_param_tbl.count;
              build_parameters(p_parameters_mig => l_proc_param_mig_tbl,
                               x_parameters     => l_proc_param_tbl);
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('No. of process params = '||l_proc_param_mig_tbl.count);
              END IF;
              FOR m IN (l_pprm_count + 1)..l_proc_param_tbl.count LOOP
              	SELECT gme_process_parameters_id_s.NEXTVAL INTO l_proc_param_tbl(m).process_param_id FROM DUAL;
              	l_proc_param_tbl(m).batch_id              := l_batch_header.batch_id;
              	l_proc_param_tbl(m).batchstep_id          := l_steps_tbl(i).batchstep_id;
              	l_proc_param_tbl(m).batchstep_activity_id := l_activities_tbl(j).batchstep_activity_id;
              	l_proc_param_tbl(m).batchstep_resource_id := l_resources_tbl(k).batchstep_resource_id;
              END LOOP; /* Process parameters Loop */
              OPEN Cur_get_rsrc_txns(l_old_bstep_rsrc_id);
              FETCH Cur_get_rsrc_txns BULK COLLECT INTO l_rsrc_txns_mig_tbl;
              CLOSE Cur_get_rsrc_txns;
              l_rtxn_count := l_rsrc_txns_tbl.count;
              build_rsrc_txns(p_rsrc_txns_mig => l_rsrc_txns_mig_tbl,
                              x_rsrc_txns     => l_rsrc_txns_tbl);
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('No. of rsrc txns = '||l_rsrc_txns_mig_tbl.count);
              END IF;
              FOR n IN (l_rtxn_count + 1)..l_rsrc_txns_tbl.count LOOP
              	SELECT gem5_poc_trans_id_s.NEXTVAL INTO l_rsrc_txns_tbl(n).poc_trans_id FROM DUAL;
              	l_rsrc_txns_tbl(n).orgn_code := NULL;
              	l_rsrc_txns_tbl(n).doc_id    := l_batch_header.batch_id;
              	l_rsrc_txns_tbl(n).line_id   := l_resources_tbl(k).batchstep_resource_id;
              END LOOP; /* Resource Txns Loop */
            END LOOP; /* Resources Loop */
          END LOOP; /* Activities Loop */
        END LOOP; /* Steps Loop */
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After steps processing now inserting all step data');
        END IF;
        FORALL a IN 1..l_steps_tbl.count
          INSERT INTO gme_batch_steps VALUES l_steps_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After insert steps');
        END IF;
        FORALL a IN 1..l_activities_tbl.count
          INSERT INTO gme_batch_step_activities VALUES l_activities_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After insert activities');
        END IF;
        FORALL a IN 1..l_resources_tbl.count
          INSERT INTO gme_batch_step_resources VALUES l_resources_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After insert resources');
        END IF;
        FORALL a IN 1..l_proc_param_tbl.count
          INSERT INTO gme_process_parameters VALUES l_proc_param_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After insert process params');
        END IF;
        FORALL a IN 1..l_rsrc_txns_tbl.count
          INSERT INTO gme_resource_txns VALUES l_rsrc_txns_tbl(a);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After insert rsrc txns');
        END IF;
        create_step_dependencies(p_old_batch_id => get_batches.batch_id,
                                 p_new_batch_id => l_batch_header.batch_id);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After create dependencies');
        END IF;
        create_item_step_assoc(p_old_batch_id => get_batches.batch_id,
                               p_new_batch_id => l_batch_header.batch_id);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After create associations');
        END IF;
        create_batch_step_charges(p_old_batch_id => get_batches.batch_id,
                                  p_new_batch_id => l_batch_header.batch_id);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After create charges');
        END IF;
        create_batch_step_transfers(p_old_batch_id => get_batches.batch_id,
                                    p_new_batch_id => l_batch_header.batch_id);
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After create transfers');
        END IF;
        FOR i IN 1..l_mtl_dtl_tbl.count LOOP
          gme_common_pvt.calc_mtl_req_date(p_batch_header_rec      => l_batch_header
                                          ,p_batchstep_rec         => NULL
                                          ,p_mtl_dtl_rec           => l_mtl_dtl_tbl(i)
                                          ,x_mtl_req_date          => l_mtl_dtl_tbl(i).material_requirement_date
                                          ,x_return_status         => l_return_status);
          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE calc_mtl_req_date_err;
          END IF;
        END LOOP;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After mtl_req_date');
        END IF;
        IF l_batch_header.batch_type = 0 AND NVL (l_batch_header.update_inventory_ind, 'Y') = 'Y' THEN
          gme_move_orders_pvt.create_move_order_hdr
              (p_organization_id           => l_batch_header.organization_id
              ,p_move_order_type           => gme_common_pvt.g_invis_move_order_type
              ,x_move_order_header_id      => l_batch_header.move_order_header_id
              ,x_return_status             => l_return_status);
          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE create_mo_hdr_err;
          ELSE
            l_in_mtl_dtl_tbl := l_mtl_dtl_tbl;
            gme_move_orders_pvt.create_move_order_lines
                 (p_move_order_header_id      => l_batch_header.move_order_header_id
                 ,p_move_order_type           => gme_common_pvt.g_invis_move_order_type
                 ,p_material_details_tbl      => l_in_mtl_dtl_tbl
                 ,x_material_details_tbl      => l_mtl_dtl_tbl
                 ,x_trolin_tbl                => l_trolin_tbl
                 ,x_return_status             => l_return_status);
            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              RAISE create_mo_line_err;
            END IF;
          END IF;
        END IF;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After create move order');
        END IF;
        UPDATE gme_batch_header
        SET move_order_header_id = l_batch_header.move_order_header_id
        WHERE batch_id = l_batch_header.batch_id;

        FOR a IN 1..l_mtl_dtl_tbl.count LOOP
          UPDATE gme_material_details
          SET move_order_line_id = l_mtl_dtl_tbl(a).move_order_line_id,
              material_requirement_date = l_mtl_dtl_tbl(a).material_requirement_date
          WHERE material_detail_id = l_mtl_dtl_tbl(a).material_detail_id;
        END LOOP;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('After update material');
        END IF;
        create_batch_mapping(p_batch_header_mig => get_batches,
                             p_batch_header     => l_batch_header);
        UPDATE gme_batch_header_mig
        SET migrated_batch_ind = 'M'
        WHERE batch_id = get_batches.batch_id;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Done batch basic processing');
        END IF;
      EXCEPTION
      	WHEN item_not_defined THEN
          ROLLBACK;
          OPEN Cur_item_mst(l_item_id);
          FETCH Cur_item_mst INTO l_item_no;
          CLOSE Cur_item_mst;
          gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'INV_IC_INVALID_ITEM_ORG',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'INV',
                  p_token1              => 'ORG',
                  p_param1              => gme_common_pvt.g_organization_code,
                  p_token2              => 'ITEM',
                  p_param2              => l_item_no);
        WHEN setup_failed OR calc_mtl_req_date_err OR create_mo_hdr_err OR create_mo_line_err THEN
          ROLLBACK;
          gme_common_pvt.count_and_get(x_count  => l_msg_count
                                      ,x_data   => l_msg_data);
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_BATCH_MIG_FAILED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_batches.plant_code||'-'||get_batches.batch_no,
                      p_token2              => 'MSG',
                      p_param2              => l_msg_data);
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
          ROLLBACK;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_BATCH_MIG_FAILED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_batches.plant_code||'-'||get_batches.batch_no,
                      p_token2              => 'MSG',
                      p_param2              => SQLERRM);
      END;
      COMMIT;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Create phantom links');
    END IF;
    create_phantom_links;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Create Reservations/Pending Lots');
    END IF;
    /* Bug 5620671 Added param completed ind */
    create_txns_reservations(0);
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Release batches');
    END IF;
    gme_common_pvt.g_transaction_header_id := NULL;
    release_batches;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Create transactions');
    END IF;
    /* Bug 5620671 Added param completed ind */
    create_txns_reservations(1);
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Insert lab lots');
    END IF;
    insert_lab_lots;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Close Steps');
    END IF;
    close_steps;
    /* Bug 5703541 Added update stmt and loop for mtl_lot_conv_audit */
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Update mtl_lot_conv_audit');
    END IF;
    FOR get_rec IN (SELECT old_batch_id, new_batch_id FROM gme_batch_mapping_mig
                    WHERE old_batch_id IN (SELECT DISTINCT(batch_id) FROM mtl_lot_conv_audit)) LOOP
      UPDATE mtl_lot_conv_audit
      SET batch_id = get_rec.new_batch_id
      WHERE batch_id = get_rec.old_batch_id;
    END LOOP;

    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Call QM');
    END IF;
    gmd_qc_migb12.gmd_qc_migrate_batch_id(p_migration_run_id => g_migration_run_id,
                                          p_commit           => FND_API.G_TRUE,
                                          x_exception_count  => l_msg_count);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
    gma_migration.gma_migration_end (l_run_id => g_migration_run_id);
  EXCEPTION
    WHEN OTHERS THEN
      IF (g_debug <= gme_debug.g_log_unexpected) THEN
        gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
      END IF;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => g_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'RECREATE_OPEN_BATCHES',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
  END recreate_open_batches;

  PROCEDURE build_batch_hdr(p_batch_header_mig   IN gme_batch_header_mig%ROWTYPE,
                            x_batch_header       OUT NOCOPY gme_batch_header%ROWTYPE) IS
  BEGIN
    x_batch_header.batch_id                   := p_batch_header_mig.batch_id;
    x_batch_header.plant_code                 := p_batch_header_mig.plant_code;
    x_batch_header.batch_no                   := p_batch_header_mig.batch_no;
    x_batch_header.batch_type                 := p_batch_header_mig.batch_type;
    x_batch_header.prod_id                    := p_batch_header_mig.prod_id;
    x_batch_header.prod_sequence              := p_batch_header_mig.prod_sequence;
    x_batch_header.recipe_validity_rule_id    := p_batch_header_mig.recipe_validity_rule_id;
    x_batch_header.formula_id                 := p_batch_header_mig.formula_id;
    x_batch_header.routing_id                 := p_batch_header_mig.routing_id;
    x_batch_header.plan_start_date            := p_batch_header_mig.plan_start_date;
    x_batch_header.actual_start_date          := p_batch_header_mig.actual_start_date;
    x_batch_header.due_date                   := p_batch_header_mig.due_date;
    x_batch_header.plan_cmplt_date            := p_batch_header_mig.plan_cmplt_date;
    x_batch_header.actual_cmplt_date          := p_batch_header_mig.actual_cmplt_date;
    x_batch_header.batch_status               := p_batch_header_mig.batch_status;
    x_batch_header.priority_value             := p_batch_header_mig.priority_value;
    x_batch_header.priority_code              := p_batch_header_mig.priority_code;
    x_batch_header.print_count                := p_batch_header_mig.print_count;
    x_batch_header.fmcontrol_class            := p_batch_header_mig.fmcontrol_class;
    x_batch_header.wip_whse_code              := p_batch_header_mig.wip_whse_code;
    x_batch_header.batch_close_date           := p_batch_header_mig.batch_close_date;
    x_batch_header.poc_ind                    := p_batch_header_mig.poc_ind;
    x_batch_header.actual_cost_ind            := p_batch_header_mig.actual_cost_ind;
    x_batch_header.update_inventory_ind       := p_batch_header_mig.update_inventory_ind;
    x_batch_header.last_update_date           := p_batch_header_mig.last_update_date;
    x_batch_header.last_updated_by            := p_batch_header_mig.last_updated_by;
    x_batch_header.creation_date              := p_batch_header_mig.creation_date;
    x_batch_header.created_by                 := p_batch_header_mig.created_by;
    x_batch_header.last_update_login          := p_batch_header_mig.last_update_login;
    x_batch_header.delete_mark                := p_batch_header_mig.delete_mark;
    x_batch_header.text_code                  := p_batch_header_mig.text_code;
    x_batch_header.parentline_id              := p_batch_header_mig.parentline_id;
    x_batch_header.fpo_id                     := p_batch_header_mig.fpo_id;
    x_batch_header.attribute1                 := p_batch_header_mig.attribute1;
    x_batch_header.attribute2                 := p_batch_header_mig.attribute2;
    x_batch_header.attribute3                 := p_batch_header_mig.attribute3;
    x_batch_header.attribute4                 := p_batch_header_mig.attribute4;
    x_batch_header.attribute5                 := p_batch_header_mig.attribute5;
    x_batch_header.attribute6                 := p_batch_header_mig.attribute6;
    x_batch_header.attribute7                 := p_batch_header_mig.attribute7;
    x_batch_header.attribute8                 := p_batch_header_mig.attribute8;
    x_batch_header.attribute9                 := p_batch_header_mig.attribute9;
    x_batch_header.attribute10                := p_batch_header_mig.attribute10;
    x_batch_header.attribute11                := p_batch_header_mig.attribute11;
    x_batch_header.attribute12                := p_batch_header_mig.attribute12;
    x_batch_header.attribute13                := p_batch_header_mig.attribute13;
    x_batch_header.attribute14                := p_batch_header_mig.attribute14;
    x_batch_header.attribute15                := p_batch_header_mig.attribute15;
    x_batch_header.attribute16                := p_batch_header_mig.attribute16;
    x_batch_header.attribute17                := p_batch_header_mig.attribute17;
    x_batch_header.attribute18                := p_batch_header_mig.attribute18;
    x_batch_header.attribute19                := p_batch_header_mig.attribute19;
    x_batch_header.attribute20                := p_batch_header_mig.attribute20;
    x_batch_header.attribute21                := p_batch_header_mig.attribute21;
    x_batch_header.attribute22                := p_batch_header_mig.attribute22;
    x_batch_header.attribute23                := p_batch_header_mig.attribute23;
    x_batch_header.attribute24                := p_batch_header_mig.attribute24;
    x_batch_header.attribute25                := p_batch_header_mig.attribute25;
    x_batch_header.attribute26                := p_batch_header_mig.attribute26;
    x_batch_header.attribute27                := p_batch_header_mig.attribute27;
    x_batch_header.attribute28                := p_batch_header_mig.attribute28;
    x_batch_header.attribute29                := p_batch_header_mig.attribute29;
    x_batch_header.attribute30                := p_batch_header_mig.attribute30;
    x_batch_header.attribute_category         := p_batch_header_mig.attribute_category;
    x_batch_header.automatic_step_calculation := p_batch_header_mig.automatic_step_calculation;
    x_batch_header.gl_posted_ind              := p_batch_header_mig.gl_posted_ind;
    x_batch_header.firmed_ind                 := p_batch_header_mig.firmed_ind;
    x_batch_header.finite_scheduled_ind       := p_batch_header_mig.finite_scheduled_ind;
    x_batch_header.order_priority             := p_batch_header_mig.order_priority;
    x_batch_header.attribute31                := p_batch_header_mig.attribute31;
    x_batch_header.attribute32                := p_batch_header_mig.attribute32;
    x_batch_header.attribute33                := p_batch_header_mig.attribute33;
    x_batch_header.attribute34                := p_batch_header_mig.attribute34;
    x_batch_header.attribute35                := p_batch_header_mig.attribute35;
    x_batch_header.attribute36                := p_batch_header_mig.attribute36;
    x_batch_header.attribute37                := p_batch_header_mig.attribute37;
    x_batch_header.attribute38                := p_batch_header_mig.attribute38;
    x_batch_header.attribute39                := p_batch_header_mig.attribute39;
    x_batch_header.attribute40                := p_batch_header_mig.attribute40;
    x_batch_header.migrated_batch_ind         := p_batch_header_mig.migrated_batch_ind;
    x_batch_header.enforce_step_dependency    := p_batch_header_mig.enforce_step_dependency;
    x_batch_header.terminated_ind             := p_batch_header_mig.terminated_ind;
    x_batch_header.enhanced_pi_ind            := p_batch_header_mig.enhanced_pi_ind;
    x_batch_header.laboratory_ind             := p_batch_header_mig.laboratory_ind;
    x_batch_header.move_order_header_id       := p_batch_header_mig.move_order_header_id;
    x_batch_header.organization_id            := p_batch_header_mig.organization_id;
    x_batch_header.terminate_reason_id        := p_batch_header_mig.terminate_reason_id;
  END build_batch_hdr;

  PROCEDURE build_mtl_dtl(p_mtl_dtl_mig   IN  gme_post_migration.mtl_dtl_mig_tab,
                          x_mtl_dtl       OUT NOCOPY gme_common_pvt.material_details_tab) IS
  BEGIN
    FOR i IN 1..p_mtl_dtl_mig.count LOOP
      x_mtl_dtl(i).material_detail_id        := p_mtl_dtl_mig(i).material_detail_id;
      x_mtl_dtl(i).batch_id                  := p_mtl_dtl_mig(i).batch_id;
      x_mtl_dtl(i).formulaline_id            := p_mtl_dtl_mig(i).formulaline_id;
      x_mtl_dtl(i).line_no                   := p_mtl_dtl_mig(i).line_no;
      x_mtl_dtl(i).item_id                   := p_mtl_dtl_mig(i).item_id;
      x_mtl_dtl(i).line_type                 := p_mtl_dtl_mig(i).line_type;
      x_mtl_dtl(i).plan_qty                  := p_mtl_dtl_mig(i).plan_qty;
      x_mtl_dtl(i).item_um                   := p_mtl_dtl_mig(i).item_um;
      x_mtl_dtl(i).item_um2                  := p_mtl_dtl_mig(i).item_um2;
      x_mtl_dtl(i).actual_qty                := p_mtl_dtl_mig(i).actual_qty;
      x_mtl_dtl(i).release_type              := p_mtl_dtl_mig(i).release_type;
      x_mtl_dtl(i).scrap_factor              := p_mtl_dtl_mig(i).scrap_factor;
      x_mtl_dtl(i).scale_type                := p_mtl_dtl_mig(i).scale_type;
      x_mtl_dtl(i).phantom_type              := p_mtl_dtl_mig(i).phantom_type;
      x_mtl_dtl(i).cost_alloc                := p_mtl_dtl_mig(i).cost_alloc;
      x_mtl_dtl(i).alloc_ind                 := p_mtl_dtl_mig(i).alloc_ind;
      x_mtl_dtl(i).cost                      := p_mtl_dtl_mig(i).cost;
      x_mtl_dtl(i).text_code                 := p_mtl_dtl_mig(i).text_code;
      x_mtl_dtl(i).phantom_id                := p_mtl_dtl_mig(i).phantom_id;
      x_mtl_dtl(i).rounding_direction        := p_mtl_dtl_mig(i).rounding_direction;
      x_mtl_dtl(i).creation_date             := p_mtl_dtl_mig(i).creation_date;
      x_mtl_dtl(i).created_by                := p_mtl_dtl_mig(i).created_by;
      x_mtl_dtl(i).last_update_date          := p_mtl_dtl_mig(i).last_update_date;
      x_mtl_dtl(i).last_updated_by           := p_mtl_dtl_mig(i).last_updated_by;
      x_mtl_dtl(i).attribute1                := p_mtl_dtl_mig(i).attribute1;
      x_mtl_dtl(i).attribute2                := p_mtl_dtl_mig(i).attribute2;
      x_mtl_dtl(i).attribute3                := p_mtl_dtl_mig(i).attribute3;
      x_mtl_dtl(i).attribute4                := p_mtl_dtl_mig(i).attribute4;
      x_mtl_dtl(i).attribute5                := p_mtl_dtl_mig(i).attribute5;
      x_mtl_dtl(i).attribute6                := p_mtl_dtl_mig(i).attribute6;
      x_mtl_dtl(i).attribute7                := p_mtl_dtl_mig(i).attribute7;
      x_mtl_dtl(i).attribute8                := p_mtl_dtl_mig(i).attribute8;
      x_mtl_dtl(i).attribute9                := p_mtl_dtl_mig(i).attribute9;
      x_mtl_dtl(i).attribute10               := p_mtl_dtl_mig(i).attribute10;
      x_mtl_dtl(i).attribute11               := p_mtl_dtl_mig(i).attribute11;
      x_mtl_dtl(i).attribute12               := p_mtl_dtl_mig(i).attribute12;
      x_mtl_dtl(i).attribute13               := p_mtl_dtl_mig(i).attribute13;
      x_mtl_dtl(i).attribute14               := p_mtl_dtl_mig(i).attribute14;
      x_mtl_dtl(i).attribute15               := p_mtl_dtl_mig(i).attribute15;
      x_mtl_dtl(i).attribute16               := p_mtl_dtl_mig(i).attribute16;
      x_mtl_dtl(i).attribute17               := p_mtl_dtl_mig(i).attribute17;
      x_mtl_dtl(i).attribute18               := p_mtl_dtl_mig(i).attribute18;
      x_mtl_dtl(i).attribute19               := p_mtl_dtl_mig(i).attribute19;
      x_mtl_dtl(i).attribute20               := p_mtl_dtl_mig(i).attribute20;
      x_mtl_dtl(i).attribute21               := p_mtl_dtl_mig(i).attribute21;
      x_mtl_dtl(i).attribute22               := p_mtl_dtl_mig(i).attribute22;
      x_mtl_dtl(i).attribute23               := p_mtl_dtl_mig(i).attribute23;
      x_mtl_dtl(i).attribute24               := p_mtl_dtl_mig(i).attribute24;
      x_mtl_dtl(i).attribute25               := p_mtl_dtl_mig(i).attribute25;
      x_mtl_dtl(i).attribute26               := p_mtl_dtl_mig(i).attribute26;
      x_mtl_dtl(i).attribute27               := p_mtl_dtl_mig(i).attribute27;
      x_mtl_dtl(i).attribute28               := p_mtl_dtl_mig(i).attribute28;
      x_mtl_dtl(i).attribute29               := p_mtl_dtl_mig(i).attribute29;
      x_mtl_dtl(i).attribute30               := p_mtl_dtl_mig(i).attribute30;
      x_mtl_dtl(i).attribute_category        := p_mtl_dtl_mig(i).attribute_category;
      x_mtl_dtl(i).last_update_login         := p_mtl_dtl_mig(i).last_update_login;
      x_mtl_dtl(i).scale_rounding_variance   := p_mtl_dtl_mig(i).scale_rounding_variance;
      x_mtl_dtl(i).scale_multiple            := p_mtl_dtl_mig(i).scale_multiple;
      x_mtl_dtl(i).contribute_yield_ind      := p_mtl_dtl_mig(i).contribute_yield_ind;
      x_mtl_dtl(i).contribute_step_qty_ind   := p_mtl_dtl_mig(i).contribute_step_qty_ind;
      x_mtl_dtl(i).wip_plan_qty              := p_mtl_dtl_mig(i).wip_plan_qty;
      x_mtl_dtl(i).original_qty              := p_mtl_dtl_mig(i).original_qty;
      x_mtl_dtl(i).by_product_type           := p_mtl_dtl_mig(i).by_product_type;
      x_mtl_dtl(i).backordered_qty           := p_mtl_dtl_mig(i).backordered_qty;
      x_mtl_dtl(i).dispense_ind              := p_mtl_dtl_mig(i).dispense_ind;
      x_mtl_dtl(i).dtl_um                    := p_mtl_dtl_mig(i).dtl_um;
      x_mtl_dtl(i).inventory_item_id         := p_mtl_dtl_mig(i).inventory_item_id;
      x_mtl_dtl(i).locator_id                := p_mtl_dtl_mig(i).locator_id;
      x_mtl_dtl(i).material_requirement_date := p_mtl_dtl_mig(i).material_requirement_date;
      x_mtl_dtl(i).move_order_line_id        := p_mtl_dtl_mig(i).move_order_line_id;
      x_mtl_dtl(i).organization_id           := p_mtl_dtl_mig(i).organization_id;
      x_mtl_dtl(i).original_primary_qty      := p_mtl_dtl_mig(i).original_primary_qty;
      x_mtl_dtl(i).phantom_line_id           := p_mtl_dtl_mig(i).phantom_line_id;
      x_mtl_dtl(i).revision                  := p_mtl_dtl_mig(i).revision;
      x_mtl_dtl(i).subinventory              := p_mtl_dtl_mig(i).subinventory;
    END LOOP;
  END build_mtl_dtl;

  PROCEDURE build_steps(p_steps_mig   IN  gme_post_migration.steps_mig_tab,
                        x_steps       OUT NOCOPY gme_common_pvt.steps_tab) IS
  BEGIN
    FOR i IN 1..p_steps_mig.count LOOP
      x_steps(i).batch_id              := p_steps_mig(i).batch_id;
      x_steps(i).batchstep_id          := p_steps_mig(i).batchstep_id;
      x_steps(i).routingstep_id        := p_steps_mig(i).routingstep_id;
      x_steps(i).batchstep_no          := p_steps_mig(i).batchstep_no;
      x_steps(i).oprn_id               := p_steps_mig(i).oprn_id;
      x_steps(i).plan_step_qty         := p_steps_mig(i).plan_step_qty;
      x_steps(i).actual_step_qty       := p_steps_mig(i).actual_step_qty;
      x_steps(i).step_qty_uom          := p_steps_mig(i).step_qty_uom;
      x_steps(i).backflush_qty         := p_steps_mig(i).backflush_qty;
      x_steps(i).plan_start_date       := p_steps_mig(i).plan_start_date;
      x_steps(i).actual_start_date     := p_steps_mig(i).actual_start_date;
      x_steps(i).due_date              := p_steps_mig(i).due_date;
      x_steps(i).plan_cmplt_date       := p_steps_mig(i).plan_cmplt_date;
      x_steps(i).actual_cmplt_date     := p_steps_mig(i).actual_cmplt_date;
      x_steps(i).step_close_date       := p_steps_mig(i).step_close_date;
      x_steps(i).step_status           := p_steps_mig(i).step_status;
      x_steps(i).priority_code         := p_steps_mig(i).priority_code;
      x_steps(i).priority_value        := p_steps_mig(i).priority_value;
      x_steps(i).delete_mark           := p_steps_mig(i).delete_mark;
      x_steps(i).steprelease_type      := p_steps_mig(i).steprelease_type;
      x_steps(i).max_step_capacity     := p_steps_mig(i).max_step_capacity;
      x_steps(i).max_step_capacity_uom := p_steps_mig(i).max_step_capacity_uom;
      x_steps(i).plan_charges          := p_steps_mig(i).plan_charges;
      x_steps(i).actual_charges        := p_steps_mig(i).actual_charges;
      x_steps(i).mass_ref_uom          := p_steps_mig(i).mass_ref_uom;
      x_steps(i).plan_mass_qty         := p_steps_mig(i).plan_mass_qty;
      x_steps(i).volume_ref_uom        := p_steps_mig(i).volume_ref_uom;
      x_steps(i).plan_volume_qty       := p_steps_mig(i).plan_volume_qty;
      x_steps(i).text_code             := p_steps_mig(i).text_code;
      x_steps(i).actual_mass_qty       := p_steps_mig(i).actual_mass_qty;
      x_steps(i).actual_volume_qty     := p_steps_mig(i).actual_volume_qty;
      x_steps(i).last_update_date      := p_steps_mig(i).last_update_date;
      x_steps(i).creation_date         := p_steps_mig(i).creation_date;
      x_steps(i).created_by            := p_steps_mig(i).created_by;
      x_steps(i).last_updated_by       := p_steps_mig(i).last_updated_by;
      x_steps(i).last_update_login     := p_steps_mig(i).last_update_login;
      x_steps(i).attribute_category    := p_steps_mig(i).attribute_category;
      x_steps(i).attribute1            := p_steps_mig(i).attribute1;
      x_steps(i).attribute2            := p_steps_mig(i).attribute2;
      x_steps(i).attribute3            := p_steps_mig(i).attribute3;
      x_steps(i).attribute4            := p_steps_mig(i).attribute4;
      x_steps(i).attribute5            := p_steps_mig(i).attribute5;
      x_steps(i).attribute6            := p_steps_mig(i).attribute6;
      x_steps(i).attribute7            := p_steps_mig(i).attribute7;
      x_steps(i).attribute8            := p_steps_mig(i).attribute8;
      x_steps(i).attribute9            := p_steps_mig(i).attribute9;
      x_steps(i).attribute10           := p_steps_mig(i).attribute10;
      x_steps(i).attribute11           := p_steps_mig(i).attribute11;
      x_steps(i).attribute12           := p_steps_mig(i).attribute12;
      x_steps(i).attribute13           := p_steps_mig(i).attribute13;
      x_steps(i).attribute14           := p_steps_mig(i).attribute14;
      x_steps(i).attribute15           := p_steps_mig(i).attribute15;
      x_steps(i).attribute16           := p_steps_mig(i).attribute16;
      x_steps(i).attribute17           := p_steps_mig(i).attribute17;
      x_steps(i).attribute18           := p_steps_mig(i).attribute18;
      x_steps(i).attribute19           := p_steps_mig(i).attribute19;
      x_steps(i).attribute20           := p_steps_mig(i).attribute20;
      x_steps(i).attribute21           := p_steps_mig(i).attribute21;
      x_steps(i).attribute22           := p_steps_mig(i).attribute22;
      x_steps(i).attribute23           := p_steps_mig(i).attribute23;
      x_steps(i).attribute24           := p_steps_mig(i).attribute24;
      x_steps(i).attribute25           := p_steps_mig(i).attribute25;
      x_steps(i).attribute26           := p_steps_mig(i).attribute26;
      x_steps(i).attribute27           := p_steps_mig(i).attribute27;
      x_steps(i).attribute28           := p_steps_mig(i).attribute28;
      x_steps(i).attribute29           := p_steps_mig(i).attribute29;
      x_steps(i).attribute30           := p_steps_mig(i).attribute30;
      x_steps(i).quality_status        := p_steps_mig(i).quality_status;
      x_steps(i).minimum_transfer_qty  := p_steps_mig(i).minimum_transfer_qty;
      x_steps(i).terminated_ind        := p_steps_mig(i).terminated_ind;
      x_steps(i).mass_ref_um           := p_steps_mig(i).mass_ref_um;
      x_steps(i).max_step_capacity_um  := p_steps_mig(i).max_step_capacity_um;
      x_steps(i).step_qty_um           := p_steps_mig(i).step_qty_um;
      x_steps(i).volume_ref_um         := p_steps_mig(i).volume_ref_um;
    END LOOP;
  END build_steps;

  PROCEDURE build_activities(p_activities_mig IN gme_post_migration.activ_mig_tab,
                             x_activities     IN OUT NOCOPY gme_common_pvt.activities_tab) IS
    l_cnt   NUMBER := 0;
  BEGIN
    l_cnt := x_activities.count;
    FOR i IN 1..p_activities_mig.count LOOP
      l_cnt := l_cnt + 1;
      x_activities(l_cnt).batch_id               := p_activities_mig(i).batch_id;
      x_activities(l_cnt).activity               := p_activities_mig(i).activity;
      x_activities(l_cnt).batchstep_id           := p_activities_mig(i).batchstep_id;
      x_activities(l_cnt).batchstep_activity_id  := p_activities_mig(i).batchstep_activity_id;
      x_activities(l_cnt).oprn_line_id           := p_activities_mig(i).oprn_line_id;
      x_activities(l_cnt).offset_interval        := p_activities_mig(i).offset_interval;
      x_activities(l_cnt).plan_start_date        := p_activities_mig(i).plan_start_date;
      x_activities(l_cnt).actual_start_date      := p_activities_mig(i).actual_start_date;
      x_activities(l_cnt).plan_cmplt_date        := p_activities_mig(i).plan_cmplt_date;
      x_activities(l_cnt).actual_cmplt_date      := p_activities_mig(i).actual_cmplt_date;
      x_activities(l_cnt).plan_activity_factor   := p_activities_mig(i).plan_activity_factor;
      x_activities(l_cnt).actual_activity_factor := p_activities_mig(i).actual_activity_factor;
      x_activities(l_cnt).delete_mark            := p_activities_mig(i).delete_mark;
      x_activities(l_cnt).attribute_category     := p_activities_mig(i).attribute_category;
      x_activities(l_cnt).attribute1             := p_activities_mig(i).attribute1;
      x_activities(l_cnt).attribute2             := p_activities_mig(i).attribute2;
      x_activities(l_cnt).attribute3             := p_activities_mig(i).attribute3;
      x_activities(l_cnt).attribute4             := p_activities_mig(i).attribute4;
      x_activities(l_cnt).attribute5             := p_activities_mig(i).attribute5;
      x_activities(l_cnt).attribute6             := p_activities_mig(i).attribute6;
      x_activities(l_cnt).attribute7             := p_activities_mig(i).attribute7;
      x_activities(l_cnt).attribute8             := p_activities_mig(i).attribute8;
      x_activities(l_cnt).attribute9             := p_activities_mig(i).attribute9;
      x_activities(l_cnt).attribute10            := p_activities_mig(i).attribute10;
      x_activities(l_cnt).attribute11            := p_activities_mig(i).attribute11;
      x_activities(l_cnt).attribute12            := p_activities_mig(i).attribute12;
      x_activities(l_cnt).attribute13            := p_activities_mig(i).attribute13;
      x_activities(l_cnt).attribute14            := p_activities_mig(i).attribute14;
      x_activities(l_cnt).attribute15            := p_activities_mig(i).attribute15;
      x_activities(l_cnt).attribute16            := p_activities_mig(i).attribute16;
      x_activities(l_cnt).attribute17            := p_activities_mig(i).attribute17;
      x_activities(l_cnt).attribute18            := p_activities_mig(i).attribute18;
      x_activities(l_cnt).attribute19            := p_activities_mig(i).attribute19;
      x_activities(l_cnt).attribute20            := p_activities_mig(i).attribute20;
      x_activities(l_cnt).attribute21            := p_activities_mig(i).attribute21;
      x_activities(l_cnt).attribute22            := p_activities_mig(i).attribute22;
      x_activities(l_cnt).attribute23            := p_activities_mig(i).attribute23;
      x_activities(l_cnt).attribute24            := p_activities_mig(i).attribute24;
      x_activities(l_cnt).attribute25            := p_activities_mig(i).attribute25;
      x_activities(l_cnt).attribute26            := p_activities_mig(i).attribute26;
      x_activities(l_cnt).attribute27            := p_activities_mig(i).attribute27;
      x_activities(l_cnt).attribute28            := p_activities_mig(i).attribute28;
      x_activities(l_cnt).attribute29            := p_activities_mig(i).attribute29;
      x_activities(l_cnt).attribute30            := p_activities_mig(i).attribute30;
      x_activities(l_cnt).creation_date          := p_activities_mig(i).creation_date;
      x_activities(l_cnt).created_by             := p_activities_mig(i).created_by;
      x_activities(l_cnt).last_update_date       := p_activities_mig(i).last_update_date;
      x_activities(l_cnt).last_updated_by        := p_activities_mig(i).last_updated_by;
      x_activities(l_cnt).last_update_login      := p_activities_mig(i).last_update_login;
      x_activities(l_cnt).text_code              := p_activities_mig(i).text_code;
      x_activities(l_cnt).sequence_dependent_ind := p_activities_mig(i).sequence_dependent_ind;
      x_activities(l_cnt).max_break              := p_activities_mig(i).max_break;
      x_activities(l_cnt).break_ind              := p_activities_mig(i).break_ind;
      x_activities(l_cnt).material_ind           := p_activities_mig(i).material_ind;
    END LOOP;
  END build_activities;

  PROCEDURE build_resources(p_resources_mig IN gme_post_migration.rsrc_mig_tab,
                            x_resources     IN OUT NOCOPY gme_common_pvt.resources_tab) IS
    l_cnt   NUMBER := 0;
  BEGIN
    l_cnt := x_resources.count;
    FOR i IN 1..p_resources_mig.count LOOP
      l_cnt := l_cnt + 1;
      x_resources(l_cnt).batchstep_resource_id    := p_resources_mig(i).batchstep_resource_id;
      x_resources(l_cnt).batchstep_activity_id    := p_resources_mig(i).batchstep_activity_id;
      x_resources(l_cnt).resources                := p_resources_mig(i).resources;
      x_resources(l_cnt).batchstep_id             := p_resources_mig(i).batchstep_id;
      x_resources(l_cnt).batch_id                 := p_resources_mig(i).batch_id;
      x_resources(l_cnt).cost_analysis_code       := p_resources_mig(i).cost_analysis_code;
      x_resources(l_cnt).cost_cmpntcls_id         := p_resources_mig(i).cost_cmpntcls_id;
      x_resources(l_cnt).prim_rsrc_ind            := p_resources_mig(i).prim_rsrc_ind;
      x_resources(l_cnt).scale_type               := p_resources_mig(i).scale_type;
      x_resources(l_cnt).plan_rsrc_count          := p_resources_mig(i).plan_rsrc_count;
      x_resources(l_cnt).actual_rsrc_count        := p_resources_mig(i).actual_rsrc_count;
      x_resources(l_cnt).resource_qty_uom         := p_resources_mig(i).resource_qty_uom;
      x_resources(l_cnt).capacity_uom             := p_resources_mig(i).capacity_uom;
      x_resources(l_cnt).plan_rsrc_usage          := p_resources_mig(i).plan_rsrc_usage;
      x_resources(l_cnt).actual_rsrc_usage        := p_resources_mig(i).actual_rsrc_usage;
      x_resources(l_cnt).plan_rsrc_qty            := p_resources_mig(i).plan_rsrc_qty;
      x_resources(l_cnt).actual_rsrc_qty          := p_resources_mig(i).actual_rsrc_qty;
      x_resources(l_cnt).usage_uom                := p_resources_mig(i).usage_uom;
      x_resources(l_cnt).plan_start_date          := p_resources_mig(i).plan_start_date;
      x_resources(l_cnt).actual_start_date        := p_resources_mig(i).actual_start_date;
      x_resources(l_cnt).plan_cmplt_date          := p_resources_mig(i).plan_cmplt_date;
      x_resources(l_cnt).actual_cmplt_date        := p_resources_mig(i).actual_cmplt_date;
      x_resources(l_cnt).offset_interval          := p_resources_mig(i).offset_interval;
      x_resources(l_cnt).min_capacity             := p_resources_mig(i).min_capacity;
      x_resources(l_cnt).max_capacity             := p_resources_mig(i).max_capacity;
      x_resources(l_cnt).calculate_charges        := p_resources_mig(i).calculate_charges;
      x_resources(l_cnt).process_parameter_1      := p_resources_mig(i).process_parameter_1;
      x_resources(l_cnt).process_parameter_2      := p_resources_mig(i).process_parameter_2;
      x_resources(l_cnt).process_parameter_3      := p_resources_mig(i).process_parameter_3;
      x_resources(l_cnt).process_parameter_4      := p_resources_mig(i).process_parameter_4;
      x_resources(l_cnt).process_parameter_5      := p_resources_mig(i).process_parameter_5;
      x_resources(l_cnt).attribute_category       := p_resources_mig(i).attribute_category;
      x_resources(l_cnt).attribute1               := p_resources_mig(i).attribute1;
      x_resources(l_cnt).attribute2               := p_resources_mig(i).attribute2;
      x_resources(l_cnt).attribute3               := p_resources_mig(i).attribute3;
      x_resources(l_cnt).attribute4               := p_resources_mig(i).attribute4;
      x_resources(l_cnt).attribute5               := p_resources_mig(i).attribute5;
      x_resources(l_cnt).attribute6               := p_resources_mig(i).attribute6;
      x_resources(l_cnt).attribute7               := p_resources_mig(i).attribute7;
      x_resources(l_cnt).attribute8               := p_resources_mig(i).attribute8;
      x_resources(l_cnt).attribute9               := p_resources_mig(i).attribute9;
      x_resources(l_cnt).attribute10              := p_resources_mig(i).attribute10;
      x_resources(l_cnt).attribute11              := p_resources_mig(i).attribute11;
      x_resources(l_cnt).attribute12              := p_resources_mig(i).attribute12;
      x_resources(l_cnt).attribute13              := p_resources_mig(i).attribute13;
      x_resources(l_cnt).attribute14              := p_resources_mig(i).attribute14;
      x_resources(l_cnt).attribute15              := p_resources_mig(i).attribute15;
      x_resources(l_cnt).attribute16              := p_resources_mig(i).attribute16;
      x_resources(l_cnt).attribute17              := p_resources_mig(i).attribute17;
      x_resources(l_cnt).attribute18              := p_resources_mig(i).attribute18;
      x_resources(l_cnt).attribute19              := p_resources_mig(i).attribute19;
      x_resources(l_cnt).attribute20              := p_resources_mig(i).attribute20;
      x_resources(l_cnt).attribute21              := p_resources_mig(i).attribute21;
      x_resources(l_cnt).attribute22              := p_resources_mig(i).attribute22;
      x_resources(l_cnt).attribute23              := p_resources_mig(i).attribute23;
      x_resources(l_cnt).attribute24              := p_resources_mig(i).attribute24;
      x_resources(l_cnt).attribute25              := p_resources_mig(i).attribute25;
      x_resources(l_cnt).attribute26              := p_resources_mig(i).attribute26;
      x_resources(l_cnt).attribute27              := p_resources_mig(i).attribute27;
      x_resources(l_cnt).attribute28              := p_resources_mig(i).attribute28;
      x_resources(l_cnt).attribute29              := p_resources_mig(i).attribute29;
      x_resources(l_cnt).attribute30              := p_resources_mig(i).attribute30;
      x_resources(l_cnt).last_update_login        := p_resources_mig(i).last_update_login;
      x_resources(l_cnt).last_update_date         := p_resources_mig(i).last_update_date;
      x_resources(l_cnt).last_updated_by          := p_resources_mig(i).last_updated_by;
      x_resources(l_cnt).created_by               := p_resources_mig(i).created_by;
      x_resources(l_cnt).creation_date            := p_resources_mig(i).creation_date;
      x_resources(l_cnt).text_code                := p_resources_mig(i).text_code;
      x_resources(l_cnt).capacity_tolerance       := p_resources_mig(i).capacity_tolerance;
      x_resources(l_cnt).original_rsrc_qty        := p_resources_mig(i).original_rsrc_qty;
      x_resources(l_cnt).original_rsrc_usage      := p_resources_mig(i).original_rsrc_usage;
      x_resources(l_cnt).sequence_dependent_id    := p_resources_mig(i).sequence_dependent_id;
      x_resources(l_cnt).sequence_dependent_usage := p_resources_mig(i).sequence_dependent_usage;
      x_resources(l_cnt).firm_type                := p_resources_mig(i).firm_type;
      x_resources(l_cnt).group_sequence_id        := p_resources_mig(i).group_sequence_id;
      x_resources(l_cnt).group_sequence_number    := p_resources_mig(i).group_sequence_number;
      x_resources(l_cnt).capacity_um              := p_resources_mig(i).capacity_um;
      x_resources(l_cnt).organization_id          := p_resources_mig(i).organization_id;
      x_resources(l_cnt).resource_qty_um          := p_resources_mig(i).resource_qty_um;
      x_resources(l_cnt).usage_um                 := p_resources_mig(i).usage_um;
    END LOOP;
  END build_resources;

  PROCEDURE build_parameters(p_parameters_mig IN gme_post_migration.process_param_mig_tab,
                             x_parameters     IN OUT NOCOPY gme_post_migration.process_param_tab) IS
    l_cnt   NUMBER := 0;
  BEGIN
    l_cnt := x_parameters.count;
    FOR i IN 1..p_parameters_mig.count LOOP
      l_cnt := l_cnt + 1;
      x_parameters(l_cnt).process_param_id      := p_parameters_mig(i).process_param_id;
      x_parameters(l_cnt).batch_id              := p_parameters_mig(i).batch_id;
      x_parameters(l_cnt).batchstep_id          := p_parameters_mig(i).batchstep_id;
      x_parameters(l_cnt).batchstep_activity_id := p_parameters_mig(i).batchstep_activity_id;
      x_parameters(l_cnt).batchstep_resource_id := p_parameters_mig(i).batchstep_resource_id;
      x_parameters(l_cnt).resources             := p_parameters_mig(i).resources;
      x_parameters(l_cnt).parameter_id          := p_parameters_mig(i).parameter_id;
      x_parameters(l_cnt).target_value          := p_parameters_mig(i).target_value;
      x_parameters(l_cnt).minimum_value         := p_parameters_mig(i).minimum_value;
      x_parameters(l_cnt).maximum_value         := p_parameters_mig(i).maximum_value;
      x_parameters(l_cnt).parameter_uom         := p_parameters_mig(i).parameter_uom;
      x_parameters(l_cnt).attribute_category    := p_parameters_mig(i).attribute_category;
      x_parameters(l_cnt).attribute1            := p_parameters_mig(i).attribute1;
      x_parameters(l_cnt).attribute2            := p_parameters_mig(i).attribute2;
      x_parameters(l_cnt).attribute3            := p_parameters_mig(i).attribute3;
      x_parameters(l_cnt).attribute4            := p_parameters_mig(i).attribute4;
      x_parameters(l_cnt).attribute5            := p_parameters_mig(i).attribute5;
      x_parameters(l_cnt).attribute6            := p_parameters_mig(i).attribute6;
      x_parameters(l_cnt).attribute7            := p_parameters_mig(i).attribute7;
      x_parameters(l_cnt).attribute8            := p_parameters_mig(i).attribute8;
      x_parameters(l_cnt).attribute9            := p_parameters_mig(i).attribute9;
      x_parameters(l_cnt).attribute10           := p_parameters_mig(i).attribute10;
      x_parameters(l_cnt).attribute11           := p_parameters_mig(i).attribute11;
      x_parameters(l_cnt).attribute12           := p_parameters_mig(i).attribute12;
      x_parameters(l_cnt).attribute13           := p_parameters_mig(i).attribute13;
      x_parameters(l_cnt).attribute14           := p_parameters_mig(i).attribute14;
      x_parameters(l_cnt).attribute15           := p_parameters_mig(i).attribute15;
      x_parameters(l_cnt).attribute16           := p_parameters_mig(i).attribute16;
      x_parameters(l_cnt).attribute17           := p_parameters_mig(i).attribute17;
      x_parameters(l_cnt).attribute18           := p_parameters_mig(i).attribute18;
      x_parameters(l_cnt).attribute19           := p_parameters_mig(i).attribute19;
      x_parameters(l_cnt).attribute20           := p_parameters_mig(i).attribute20;
      x_parameters(l_cnt).attribute21           := p_parameters_mig(i).attribute21;
      x_parameters(l_cnt).attribute22           := p_parameters_mig(i).attribute22;
      x_parameters(l_cnt).attribute23           := p_parameters_mig(i).attribute23;
      x_parameters(l_cnt).attribute24           := p_parameters_mig(i).attribute24;
      x_parameters(l_cnt).attribute25           := p_parameters_mig(i).attribute25;
      x_parameters(l_cnt).attribute26           := p_parameters_mig(i).attribute26;
      x_parameters(l_cnt).attribute27           := p_parameters_mig(i).attribute27;
      x_parameters(l_cnt).attribute28           := p_parameters_mig(i).attribute28;
      x_parameters(l_cnt).attribute29           := p_parameters_mig(i).attribute29;
      x_parameters(l_cnt).attribute30           := p_parameters_mig(i).attribute30;
      x_parameters(l_cnt).created_by            := p_parameters_mig(i).created_by;
      x_parameters(l_cnt).creation_date         := p_parameters_mig(i).creation_date;
      x_parameters(l_cnt).last_updated_by       := p_parameters_mig(i).last_updated_by;
      x_parameters(l_cnt).last_update_login     := p_parameters_mig(i).last_update_login;
      x_parameters(l_cnt).last_update_date      := p_parameters_mig(i).last_update_date;
      x_parameters(l_cnt).actual_value          := p_parameters_mig(i).actual_value;
      x_parameters(l_cnt).device_id             := p_parameters_mig(i).device_id;
      x_parameters(l_cnt).parameter_uom         := p_parameters_mig(i).parameter_uom;
    END LOOP;
  END build_parameters;

  PROCEDURE build_rsrc_txns(p_rsrc_txns_mig IN gme_post_migration.rsrc_txns_mig_tab,
                            x_rsrc_txns     IN OUT NOCOPY gme_post_migration.rsrc_txns_tab) IS
    l_cnt   NUMBER := 0;
  BEGIN
    l_cnt := x_rsrc_txns.count;
    FOR i IN 1..p_rsrc_txns_mig.count LOOP
      l_cnt := l_cnt + 1;
      x_rsrc_txns(l_cnt).poc_trans_id            := p_rsrc_txns_mig(i).poc_trans_id;
      x_rsrc_txns(l_cnt).orgn_code               := p_rsrc_txns_mig(i).orgn_code;
      x_rsrc_txns(l_cnt).doc_type                := p_rsrc_txns_mig(i).doc_type;
      x_rsrc_txns(l_cnt).doc_id                  := p_rsrc_txns_mig(i).doc_id;
      x_rsrc_txns(l_cnt).line_type               := p_rsrc_txns_mig(i).line_type;
      x_rsrc_txns(l_cnt).line_id                 := p_rsrc_txns_mig(i).line_id;
      x_rsrc_txns(l_cnt).resources               := p_rsrc_txns_mig(i).resources;
      x_rsrc_txns(l_cnt).resource_usage          := p_rsrc_txns_mig(i).resource_usage;
      x_rsrc_txns(l_cnt).trans_um                := p_rsrc_txns_mig(i).trans_um;
      x_rsrc_txns(l_cnt).trans_date              := p_rsrc_txns_mig(i).trans_date;
      x_rsrc_txns(l_cnt).completed_ind           := p_rsrc_txns_mig(i).completed_ind;
      x_rsrc_txns(l_cnt).event_id                := p_rsrc_txns_mig(i).event_id;
      x_rsrc_txns(l_cnt).posted_ind              := p_rsrc_txns_mig(i).posted_ind;
      x_rsrc_txns(l_cnt).overrided_protected_ind := p_rsrc_txns_mig(i).overrided_protected_ind;
      x_rsrc_txns(l_cnt).reason_code             := p_rsrc_txns_mig(i).reason_code;
      x_rsrc_txns(l_cnt).start_date              := p_rsrc_txns_mig(i).start_date;
      x_rsrc_txns(l_cnt).end_date                := p_rsrc_txns_mig(i).end_date;
      x_rsrc_txns(l_cnt).creation_date           := p_rsrc_txns_mig(i).creation_date;
      x_rsrc_txns(l_cnt).last_update_date        := p_rsrc_txns_mig(i).last_update_date;
      x_rsrc_txns(l_cnt).created_by              := p_rsrc_txns_mig(i).created_by;
      x_rsrc_txns(l_cnt).last_updated_by         := p_rsrc_txns_mig(i).last_updated_by;
      x_rsrc_txns(l_cnt).last_update_login       := p_rsrc_txns_mig(i).last_update_login;
      x_rsrc_txns(l_cnt).delete_mark             := p_rsrc_txns_mig(i).delete_mark;
      x_rsrc_txns(l_cnt).text_code               := p_rsrc_txns_mig(i).text_code;
      x_rsrc_txns(l_cnt).attribute1              := p_rsrc_txns_mig(i).attribute1;
      x_rsrc_txns(l_cnt).attribute2              := p_rsrc_txns_mig(i).attribute2;
      x_rsrc_txns(l_cnt).attribute3              := p_rsrc_txns_mig(i).attribute3;
      x_rsrc_txns(l_cnt).attribute4              := p_rsrc_txns_mig(i).attribute4;
      x_rsrc_txns(l_cnt).attribute5              := p_rsrc_txns_mig(i).attribute5;
      x_rsrc_txns(l_cnt).attribute6              := p_rsrc_txns_mig(i).attribute6;
      x_rsrc_txns(l_cnt).attribute7              := p_rsrc_txns_mig(i).attribute7;
      x_rsrc_txns(l_cnt).attribute8              := p_rsrc_txns_mig(i).attribute8;
      x_rsrc_txns(l_cnt).attribute9              := p_rsrc_txns_mig(i).attribute9;
      x_rsrc_txns(l_cnt).attribute10             := p_rsrc_txns_mig(i).attribute10;
      x_rsrc_txns(l_cnt).attribute11             := p_rsrc_txns_mig(i).attribute11;
      x_rsrc_txns(l_cnt).attribute12             := p_rsrc_txns_mig(i).attribute12;
      x_rsrc_txns(l_cnt).attribute13             := p_rsrc_txns_mig(i).attribute13;
      x_rsrc_txns(l_cnt).attribute14             := p_rsrc_txns_mig(i).attribute14;
      x_rsrc_txns(l_cnt).attribute15             := p_rsrc_txns_mig(i).attribute15;
      x_rsrc_txns(l_cnt).attribute16             := p_rsrc_txns_mig(i).attribute16;
      x_rsrc_txns(l_cnt).attribute17             := p_rsrc_txns_mig(i).attribute17;
      x_rsrc_txns(l_cnt).attribute18             := p_rsrc_txns_mig(i).attribute18;
      x_rsrc_txns(l_cnt).attribute19             := p_rsrc_txns_mig(i).attribute19;
      x_rsrc_txns(l_cnt).attribute20             := p_rsrc_txns_mig(i).attribute20;
      x_rsrc_txns(l_cnt).attribute21             := p_rsrc_txns_mig(i).attribute21;
      x_rsrc_txns(l_cnt).attribute22             := p_rsrc_txns_mig(i).attribute22;
      x_rsrc_txns(l_cnt).attribute23             := p_rsrc_txns_mig(i).attribute23;
      x_rsrc_txns(l_cnt).attribute24             := p_rsrc_txns_mig(i).attribute24;
      x_rsrc_txns(l_cnt).attribute25             := p_rsrc_txns_mig(i).attribute25;
      x_rsrc_txns(l_cnt).attribute26             := p_rsrc_txns_mig(i).attribute26;
      x_rsrc_txns(l_cnt).attribute27             := p_rsrc_txns_mig(i).attribute27;
      x_rsrc_txns(l_cnt).attribute28             := p_rsrc_txns_mig(i).attribute28;
      x_rsrc_txns(l_cnt).attribute29             := p_rsrc_txns_mig(i).attribute29;
      x_rsrc_txns(l_cnt).attribute30             := p_rsrc_txns_mig(i).attribute30;
      x_rsrc_txns(l_cnt).attribute_category      := p_rsrc_txns_mig(i).attribute_category;
      x_rsrc_txns(l_cnt).program_id              := p_rsrc_txns_mig(i).program_id;
      x_rsrc_txns(l_cnt).program_application_id  := p_rsrc_txns_mig(i).program_application_id;
      x_rsrc_txns(l_cnt).request_id              := p_rsrc_txns_mig(i).request_id;
      x_rsrc_txns(l_cnt).program_update_date     := p_rsrc_txns_mig(i).program_update_date;
      x_rsrc_txns(l_cnt).instance_id             := p_rsrc_txns_mig(i).instance_id;
      x_rsrc_txns(l_cnt).sequence_dependent_ind  := p_rsrc_txns_mig(i).sequence_dependent_ind;
      x_rsrc_txns(l_cnt).reverse_id              := p_rsrc_txns_mig(i).reverse_id;
      x_rsrc_txns(l_cnt).organization_id         := p_rsrc_txns_mig(i).organization_id;
      x_rsrc_txns(l_cnt).trans_qty_um            := p_rsrc_txns_mig(i).trans_qty_um;
      x_rsrc_txns(l_cnt).reason_id               := p_rsrc_txns_mig(i).reason_id;
    END LOOP;
  END build_rsrc_txns;

  FUNCTION get_new_step_id(p_old_step_id   IN NUMBER,
                           p_new_batch_id  IN NUMBER) RETURN NUMBER IS
    CURSOR Cur_get_step IS
      SELECT s.batchstep_id
      FROM   gme_batch_steps_mig m, gme_batch_steps s
      WHERE  m.batchstep_id = p_old_step_id
             AND s.batch_id = p_new_batch_id
             AND s.batchstep_no = m.batchstep_no;
    l_batchstep_id   NUMBER;
  BEGIN
    OPEN Cur_get_step;
    FETCH Cur_get_step INTO l_batchstep_id;
    CLOSE Cur_get_step;
    RETURN l_batchstep_id;
  END get_new_step_id;

  FUNCTION get_new_mat_id(p_old_mat_id   IN NUMBER,
                          p_new_batch_id IN NUMBER) RETURN NUMBER IS
    CURSOR Cur_get_mat IS
      SELECT d.material_detail_id
      FROM   gme_material_details_mig m, gme_material_details d
      WHERE  m.material_detail_id = p_old_mat_id
             AND d.batch_id = p_new_batch_id
             AND d.line_type = m.line_type
             AND d.line_no = m.line_no;
    l_material_detail_id   NUMBER;
  BEGIN
    OPEN Cur_get_mat;
    FETCH Cur_get_mat INTO l_material_detail_id;
    CLOSE Cur_get_mat;
    RETURN l_material_detail_id;
  END get_new_mat_id;

  PROCEDURE create_step_dependencies(p_old_batch_id IN NUMBER,
                                     p_new_batch_id IN NUMBER) IS
    CURSOR Cur_get_deps(v_batch_id NUMBER) IS
      SELECT *
      FROM   gme_batch_step_dep_mig
      WHERE  batch_id = v_batch_id;
    TYPE step_dep_mig_tab IS TABLE OF gme_batch_step_dep_mig%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_dep_mig_tbl step_dep_mig_tab;
    TYPE step_dep_tab IS TABLE OF gme_batch_step_dependencies%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_dep_tbl step_dep_tab;
    l_api_name VARCHAR2(30) := 'create_step_dependencies';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    OPEN Cur_get_deps(p_old_batch_id);
    FETCH Cur_get_deps BULK COLLECT INTO l_step_dep_mig_tbl;
    CLOSE Cur_get_deps;
    FOR i IN 1..l_step_dep_mig_tbl.count LOOP
      l_step_dep_tbl(i).batch_id           := p_new_batch_id;
      l_step_dep_tbl(i).batchstep_id       := get_new_step_id(p_old_step_id => l_step_dep_mig_tbl(i).batchstep_id, p_new_batch_id => p_new_batch_id);
      l_step_dep_tbl(i).dep_type           := l_step_dep_mig_tbl(i).dep_type;
      l_step_dep_tbl(i).dep_step_id        := get_new_step_id(p_old_step_id => l_step_dep_mig_tbl(i).dep_step_id, p_new_batch_id => p_new_batch_id);
      l_step_dep_tbl(i).rework_code        := l_step_dep_mig_tbl(i).rework_code;
      l_step_dep_tbl(i).standard_delay     := l_step_dep_mig_tbl(i).standard_delay;
      l_step_dep_tbl(i).min_delay          := l_step_dep_mig_tbl(i).min_delay;
      l_step_dep_tbl(i).max_delay          := l_step_dep_mig_tbl(i).max_delay;
      l_step_dep_tbl(i).transfer_qty       := l_step_dep_mig_tbl(i).transfer_qty;
      l_step_dep_tbl(i).transfer_um        := l_step_dep_mig_tbl(i).transfer_um;
      l_step_dep_tbl(i).text_code          := l_step_dep_mig_tbl(i).text_code;
      l_step_dep_tbl(i).last_update_login  := l_step_dep_mig_tbl(i).last_update_login;
      l_step_dep_tbl(i).last_updated_by    := l_step_dep_mig_tbl(i).last_updated_by;
      l_step_dep_tbl(i).created_by         := l_step_dep_mig_tbl(i).created_by;
      l_step_dep_tbl(i).creation_date      := l_step_dep_mig_tbl(i).creation_date;
      l_step_dep_tbl(i).last_update_date   := l_step_dep_mig_tbl(i).last_update_date;
      l_step_dep_tbl(i).transfer_percent   := l_step_dep_mig_tbl(i).transfer_percent;
      l_step_dep_tbl(i).attribute1         := l_step_dep_mig_tbl(i).attribute1;
      l_step_dep_tbl(i).attribute2         := l_step_dep_mig_tbl(i).attribute2;
      l_step_dep_tbl(i).attribute3         := l_step_dep_mig_tbl(i).attribute3;
      l_step_dep_tbl(i).attribute4         := l_step_dep_mig_tbl(i).attribute4;
      l_step_dep_tbl(i).attribute5         := l_step_dep_mig_tbl(i).attribute5;
      l_step_dep_tbl(i).attribute6         := l_step_dep_mig_tbl(i).attribute6;
      l_step_dep_tbl(i).attribute7         := l_step_dep_mig_tbl(i).attribute7;
      l_step_dep_tbl(i).attribute8         := l_step_dep_mig_tbl(i).attribute8;
      l_step_dep_tbl(i).attribute9         := l_step_dep_mig_tbl(i).attribute9;
      l_step_dep_tbl(i).attribute10        := l_step_dep_mig_tbl(i).attribute10;
      l_step_dep_tbl(i).attribute11        := l_step_dep_mig_tbl(i).attribute11;
      l_step_dep_tbl(i).attribute12        := l_step_dep_mig_tbl(i).attribute12;
      l_step_dep_tbl(i).attribute13        := l_step_dep_mig_tbl(i).attribute13;
      l_step_dep_tbl(i).attribute14        := l_step_dep_mig_tbl(i).attribute14;
      l_step_dep_tbl(i).attribute15        := l_step_dep_mig_tbl(i).attribute15;
      l_step_dep_tbl(i).attribute16        := l_step_dep_mig_tbl(i).attribute16;
      l_step_dep_tbl(i).attribute17        := l_step_dep_mig_tbl(i).attribute17;
      l_step_dep_tbl(i).attribute18        := l_step_dep_mig_tbl(i).attribute18;
      l_step_dep_tbl(i).attribute19        := l_step_dep_mig_tbl(i).attribute19;
      l_step_dep_tbl(i).attribute20        := l_step_dep_mig_tbl(i).attribute20;
      l_step_dep_tbl(i).attribute21        := l_step_dep_mig_tbl(i).attribute21;
      l_step_dep_tbl(i).attribute22        := l_step_dep_mig_tbl(i).attribute22;
      l_step_dep_tbl(i).attribute23        := l_step_dep_mig_tbl(i).attribute23;
      l_step_dep_tbl(i).attribute24        := l_step_dep_mig_tbl(i).attribute24;
      l_step_dep_tbl(i).attribute25        := l_step_dep_mig_tbl(i).attribute25;
      l_step_dep_tbl(i).attribute26        := l_step_dep_mig_tbl(i).attribute26;
      l_step_dep_tbl(i).attribute27        := l_step_dep_mig_tbl(i).attribute27;
      l_step_dep_tbl(i).attribute28        := l_step_dep_mig_tbl(i).attribute28;
      l_step_dep_tbl(i).attribute29        := l_step_dep_mig_tbl(i).attribute29;
      l_step_dep_tbl(i).attribute30        := l_step_dep_mig_tbl(i).attribute30;
      l_step_dep_tbl(i).attribute_category := l_step_dep_mig_tbl(i).attribute_category;
      l_step_dep_tbl(i).chargeable_ind     := l_step_dep_mig_tbl(i).chargeable_ind;
    END LOOP;
    FORALL a IN 1..l_step_dep_tbl.count
      INSERT INTO gme_batch_step_dependencies VALUES l_step_dep_tbl(a);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_step_dependencies;

  PROCEDURE create_item_step_assoc(p_old_batch_id IN NUMBER,
                                   p_new_batch_id IN NUMBER) IS
    CURSOR Cur_item_assocs IS
      SELECT *
      FROM   gme_batch_step_items_mig
      WHERE  batch_id = p_old_batch_id;
    TYPE item_step_mig_tab IS TABLE OF gme_batch_step_items_mig%ROWTYPE INDEX BY BINARY_INTEGER;
    l_item_step_mig_tbl   item_step_mig_tab;
    TYPE item_step_tab IS TABLE OF gme_batch_step_items%ROWTYPE INDEX BY BINARY_INTEGER;
    l_item_step_tbl   item_step_tab;
    l_api_name VARCHAR2(30) := 'create_item_step_assoc';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    OPEN Cur_item_assocs;
    FETCH Cur_item_assocs BULK COLLECT INTO l_item_step_mig_tbl;
    CLOSE Cur_item_assocs;
    FOR i IN 1..l_item_step_mig_tbl.count LOOP
      l_item_step_tbl(i).material_detail_id   := get_new_mat_id(p_old_mat_id => l_item_step_mig_tbl(i).material_detail_id, p_new_batch_id => p_new_batch_id);
      l_item_step_tbl(i).batch_id             := p_new_batch_id;
      l_item_step_tbl(i).batchstep_id         := get_new_step_id(p_old_step_id => l_item_step_mig_tbl(i).batchstep_id, p_new_batch_id => p_new_batch_id);
      l_item_step_tbl(i).text_code            := l_item_step_mig_tbl(i).text_code;
      l_item_step_tbl(i).last_update_login    := l_item_step_mig_tbl(i).last_update_login;
      l_item_step_tbl(i).last_update_date     := l_item_step_mig_tbl(i).last_update_date;
      l_item_step_tbl(i).last_updated_by      := l_item_step_mig_tbl(i).last_updated_by;
      l_item_step_tbl(i).creation_date        := l_item_step_mig_tbl(i).creation_date;
      l_item_step_tbl(i).created_by           := l_item_step_mig_tbl(i).created_by;
      l_item_step_tbl(i).maximum_delay        := l_item_step_mig_tbl(i).maximum_delay;
      l_item_step_tbl(i).minimum_delay        := l_item_step_mig_tbl(i).minimum_delay;
      l_item_step_tbl(i).minimum_transfer_qty := l_item_step_mig_tbl(i).minimum_transfer_qty;
    END LOOP;
    FORALL a IN 1..l_item_step_tbl.count
      INSERT INTO gme_batch_step_items VALUES l_item_step_tbl(a);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_item_step_assoc;

  PROCEDURE create_batch_step_charges(p_old_batch_id IN NUMBER,
                                      p_new_batch_id IN NUMBER) IS
    CURSOR Cur_step_charges IS
      SELECT *
      FROM   gme_batch_step_charges_mig
      WHERE  batch_id = p_old_batch_id;
    TYPE step_chrg_mig_tab IS TABLE OF gme_batch_step_charges_mig%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_chrg_mig_tbl  step_chrg_mig_tab;
    TYPE step_chrg_tab IS TABLE OF gme_batch_step_charges%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_chrg_tbl  step_chrg_tab;
    l_api_name VARCHAR2(30) := 'create_batch_step_charges';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    OPEN Cur_step_charges;
    FETCH Cur_step_charges BULK COLLECT INTO l_step_chrg_mig_tbl;
    CLOSE Cur_step_charges;
    FOR i IN 1..l_step_chrg_mig_tbl.count LOOP
      l_step_chrg_tbl(i).batch_id                 := p_new_batch_id;
      l_step_chrg_tbl(i).batchstep_id             := get_new_step_id(p_old_step_id => l_step_chrg_mig_tbl(i).batchstep_id, p_new_batch_id => p_new_batch_id);
      l_step_chrg_tbl(i).resources                := l_step_chrg_mig_tbl(i).resources;
      l_step_chrg_tbl(i).activity_sequence_number := l_step_chrg_mig_tbl(i).activity_sequence_number;
      l_step_chrg_tbl(i).charge_number            := l_step_chrg_mig_tbl(i).charge_number;
      l_step_chrg_tbl(i).charge_quantity          := l_step_chrg_mig_tbl(i).charge_quantity;
      l_step_chrg_tbl(i).plan_start_date          := l_step_chrg_mig_tbl(i).plan_start_date;
      l_step_chrg_tbl(i).plan_cmplt_date          := l_step_chrg_mig_tbl(i).plan_cmplt_date;
      l_step_chrg_tbl(i).created_by               := l_step_chrg_mig_tbl(i).created_by;
      l_step_chrg_tbl(i).creation_date            := l_step_chrg_mig_tbl(i).creation_date;
      l_step_chrg_tbl(i).last_updated_by          := l_step_chrg_mig_tbl(i).last_updated_by;
      l_step_chrg_tbl(i).last_update_login        := l_step_chrg_mig_tbl(i).last_update_login;
      l_step_chrg_tbl(i).last_update_date         := l_step_chrg_mig_tbl(i).last_update_date;
    END LOOP;
    FORALL a IN 1..l_step_chrg_tbl.count
      INSERT INTO gme_batch_step_charges VALUES l_step_chrg_tbl(a);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_batch_step_charges;

  PROCEDURE create_batch_step_transfers(p_old_batch_id IN NUMBER,
                                        p_new_batch_id IN NUMBER) IS
    CURSOR Cur_step_txfrs IS
      SELECT *
      FROM   gme_batch_step_transfers_mig
      WHERE  batch_id = p_old_batch_id;
    TYPE step_txfrs_mig_tab IS TABLE OF gme_batch_step_transfers_mig%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_txfrs_mig_tbl  step_txfrs_mig_tab;
    TYPE step_txfrs_tab IS TABLE OF gme_batch_step_transfers%ROWTYPE INDEX BY BINARY_INTEGER;
    l_step_txfrs_tbl  step_txfrs_tab;
    l_api_name VARCHAR2(30) := 'create_batch_step_transfers';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    OPEN Cur_step_txfrs;
    FETCH Cur_step_txfrs BULK COLLECT INTO l_step_txfrs_mig_tbl;
    CLOSE Cur_step_txfrs;
    FOR i IN 1..l_step_txfrs_mig_tbl.count LOOP
      SELECT gem5_wip_trans_id_s.NEXTVAL INTO l_step_txfrs_tbl(i).wip_trans_id FROM DUAL;
      l_step_txfrs_tbl(i).batch_id           := p_new_batch_id;
      l_step_txfrs_tbl(i).batchstep_no       := l_step_txfrs_mig_tbl(i).batchstep_no;
      l_step_txfrs_tbl(i).transfer_step_no   := l_step_txfrs_mig_tbl(i).transfer_step_no;
      l_step_txfrs_tbl(i).line_type          := l_step_txfrs_mig_tbl(i).line_type;
      l_step_txfrs_tbl(i).trans_qty          := l_step_txfrs_mig_tbl(i).trans_qty;
      l_step_txfrs_tbl(i).trans_um           := l_step_txfrs_mig_tbl(i).trans_um;
      l_step_txfrs_tbl(i).trans_date         := l_step_txfrs_mig_tbl(i).trans_date;
      l_step_txfrs_tbl(i).last_updated_by    := l_step_txfrs_mig_tbl(i).last_updated_by;
      l_step_txfrs_tbl(i).last_update_date   := l_step_txfrs_mig_tbl(i).last_update_date;
      l_step_txfrs_tbl(i).last_update_login  := l_step_txfrs_mig_tbl(i).last_update_login;
      l_step_txfrs_tbl(i).creation_date      := l_step_txfrs_mig_tbl(i).creation_date;
      l_step_txfrs_tbl(i).created_by         := l_step_txfrs_mig_tbl(i).created_by;
      l_step_txfrs_tbl(i).delete_mark        := l_step_txfrs_mig_tbl(i).delete_mark;
      l_step_txfrs_tbl(i).text_code          := l_step_txfrs_mig_tbl(i).text_code;
      l_step_txfrs_tbl(i).attribute1         := l_step_txfrs_mig_tbl(i).attribute1;
      l_step_txfrs_tbl(i).attribute2         := l_step_txfrs_mig_tbl(i).attribute2;
      l_step_txfrs_tbl(i).attribute3         := l_step_txfrs_mig_tbl(i).attribute3;
      l_step_txfrs_tbl(i).attribute4         := l_step_txfrs_mig_tbl(i).attribute4;
      l_step_txfrs_tbl(i).attribute5         := l_step_txfrs_mig_tbl(i).attribute5;
      l_step_txfrs_tbl(i).attribute6         := l_step_txfrs_mig_tbl(i).attribute6;
      l_step_txfrs_tbl(i).attribute7         := l_step_txfrs_mig_tbl(i).attribute7;
      l_step_txfrs_tbl(i).attribute8         := l_step_txfrs_mig_tbl(i).attribute8;
      l_step_txfrs_tbl(i).attribute9         := l_step_txfrs_mig_tbl(i).attribute9;
      l_step_txfrs_tbl(i).attribute10        := l_step_txfrs_mig_tbl(i).attribute10;
      l_step_txfrs_tbl(i).attribute11        := l_step_txfrs_mig_tbl(i).attribute11;
      l_step_txfrs_tbl(i).attribute12        := l_step_txfrs_mig_tbl(i).attribute12;
      l_step_txfrs_tbl(i).attribute13        := l_step_txfrs_mig_tbl(i).attribute13;
      l_step_txfrs_tbl(i).attribute14        := l_step_txfrs_mig_tbl(i).attribute14;
      l_step_txfrs_tbl(i).attribute15        := l_step_txfrs_mig_tbl(i).attribute15;
      l_step_txfrs_tbl(i).attribute16        := l_step_txfrs_mig_tbl(i).attribute16;
      l_step_txfrs_tbl(i).attribute17        := l_step_txfrs_mig_tbl(i).attribute17;
      l_step_txfrs_tbl(i).attribute18        := l_step_txfrs_mig_tbl(i).attribute18;
      l_step_txfrs_tbl(i).attribute19        := l_step_txfrs_mig_tbl(i).attribute19;
      l_step_txfrs_tbl(i).attribute20        := l_step_txfrs_mig_tbl(i).attribute20;
      l_step_txfrs_tbl(i).attribute21        := l_step_txfrs_mig_tbl(i).attribute21;
      l_step_txfrs_tbl(i).attribute22        := l_step_txfrs_mig_tbl(i).attribute22;
      l_step_txfrs_tbl(i).attribute23        := l_step_txfrs_mig_tbl(i).attribute23;
      l_step_txfrs_tbl(i).attribute24        := l_step_txfrs_mig_tbl(i).attribute24;
      l_step_txfrs_tbl(i).attribute25        := l_step_txfrs_mig_tbl(i).attribute25;
      l_step_txfrs_tbl(i).attribute26        := l_step_txfrs_mig_tbl(i).attribute26;
      l_step_txfrs_tbl(i).attribute27        := l_step_txfrs_mig_tbl(i).attribute27;
      l_step_txfrs_tbl(i).attribute28        := l_step_txfrs_mig_tbl(i).attribute28;
      l_step_txfrs_tbl(i).attribute29        := l_step_txfrs_mig_tbl(i).attribute29;
      l_step_txfrs_tbl(i).attribute30        := l_step_txfrs_mig_tbl(i).attribute30;
      l_step_txfrs_tbl(i).attribute_category := l_step_txfrs_mig_tbl(i).attribute_category;
      l_step_txfrs_tbl(i).trans_qty_um       := l_step_txfrs_mig_tbl(i).trans_qty_um;
    END LOOP;
    FORALL a IN 1..l_step_txfrs_tbl.count
      INSERT INTO gme_batch_step_transfers VALUES l_step_txfrs_tbl(a);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_batch_step_transfers;

  PROCEDURE create_batch_mapping(p_batch_header_mig IN gme_batch_header_mig%ROWTYPE,
                                 p_batch_header     IN gme_batch_header%ROWTYPE) IS
  BEGIN
    INSERT INTO gme_batch_mapping_mig(plant_code,
                                      old_batch_id,
                                      old_batch_no,
                                      organization_id,
                                      new_batch_id,
                                      new_batch_no,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date)
    VALUES                           (p_batch_header_mig.plant_code,
                                      p_batch_header_mig.batch_id,
                                      SUBSTR(p_batch_header_mig.batch_no,1,30)||'-M',
                                      p_batch_header.organization_id,
                                      p_batch_header.batch_id,
                                      p_batch_header.batch_no,
                                      gme_common_pvt.g_user_ident,
                                      gme_common_pvt.g_timestamp,
                                      gme_common_pvt.g_user_ident,
                                      gme_common_pvt.g_timestamp);
  END create_batch_mapping;

  PROCEDURE create_phantom_links IS
    CURSOR Cur_get_phantoms IS
      SELECT d.material_detail_id new_ing_line_id, d.phantom_id old_phantom_id, d.inventory_item_id,
             m.plant_code, m.new_batch_no
      FROM   gme_material_details d, gme_batch_mapping_mig m
      WHERE  d.batch_id = m.new_batch_id
             AND d.line_type = -1
             AND d.phantom_id > 0
             AND d.phantom_id NOT IN (SELECT new_batch_id FROM gme_batch_mapping_mig);
    CURSOR Cur_new_phant_batch(v_batch_id NUMBER) IS
      SELECT new_batch_id
      FROM   gme_batch_mapping_mig
      WHERE  old_batch_id = v_batch_id;
    CURSOR Cur_new_phant_prod(v_batch_id NUMBER, v_inventory_item_id NUMBER) IS
      SELECT material_detail_id
      FROM   gme_material_details
      WHERE  batch_id = v_batch_id
             AND line_type = gme_common_pvt.g_line_type_prod
             AND inventory_item_id = v_inventory_item_id
      ORDER BY line_no;
    l_api_name VARCHAR2(30) := 'create_phantom_links';
    l_new_phantom_id           NUMBER;
    l_new_prod_line_id         NUMBER;
    new_phant_batch_not_found  EXCEPTION;
    new_phant_prod_not_found   EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    FOR get_phantoms IN Cur_get_phantoms LOOP
      BEGIN
      	/* Get new phantom batch ID */
        OPEN Cur_new_phant_batch(get_phantoms.old_phantom_id);
        FETCH Cur_new_phant_batch INTO l_new_phantom_id;
        IF (Cur_new_phant_batch%NOTFOUND) THEN
          CLOSE Cur_new_phant_batch;
          RAISE new_phant_batch_not_found;
        END IF;
        CLOSE Cur_new_phant_batch;
        /* Get new phantom product ID */
        OPEN Cur_new_phant_prod(l_new_phantom_id, get_phantoms.inventory_item_id);
        FETCH Cur_new_phant_prod INTO l_new_prod_line_id;
        IF (Cur_new_phant_prod%NOTFOUND) THEN
          CLOSE Cur_new_phant_prod;
          RAISE new_phant_prod_not_found;
        END IF;
        CLOSE Cur_new_phant_prod;
        /* Update Phantom ing */
        UPDATE gme_material_details
        SET phantom_id = l_new_phantom_id,
            phantom_line_id = l_new_prod_line_id
        WHERE material_detail_id = get_phantoms.new_ing_line_id;
        /* Update phantom batch hdr */
        UPDATE gme_batch_header
        SET parentline_id = get_phantoms.new_ing_line_id
        WHERE batch_id = l_new_phantom_id;
        /* Update phantom product */
        UPDATE gme_material_details
        SET phantom_line_id = get_phantoms.new_ing_line_id
        WHERE material_detail_id = l_new_prod_line_id;
      EXCEPTION
        WHEN new_phant_batch_not_found THEN
          ROLLBACK;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_PHANT_BATCH_NOT_FOUND',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_phantoms.plant_code||'-'||get_phantoms.new_batch_no);
      	WHEN new_phant_prod_not_found THEN
      	  ROLLBACK;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_PHANTOM_PROD_NOT_FOUND',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_phantoms.plant_code||'-'||get_phantoms.new_batch_no);
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
          ROLLBACK;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_PHANT_BATCH_UNEXPECTED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_phantoms.plant_code||'-'||get_phantoms.new_batch_no,
                      p_token2              => 'MSG',
                      p_param2              => SQLERRM);
      END;
      COMMIT;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_phantom_links;

  PROCEDURE release_batches IS
    CURSOR Cur_wip_batches IS
      SELECT m.*, o.actual_start_date
      FROM   gme_batch_header_mig o, gme_batch_mapping_mig m
      WHERE  o.batch_status = gme_common_pvt.g_batch_wip
             AND m.old_batch_id = o.batch_id
             AND o.parentline_id IS NULL
             AND m.new_batch_id NOT IN (SELECT batch_id
                                        FROM   gme_batch_header
                                        WHERE  batch_id = m.new_batch_id
                                               AND batch_status = gme_common_pvt.g_batch_wip)
      ORDER BY m.organization_id, m.new_batch_no;
    CURSOR Cur_get_steps(v_old_batch_id NUMBER, v_new_batch_id NUMBER) IS
      SELECT s.*, m.step_status old_step_status, m.actual_start_date old_actual_start_date,
             m.actual_cmplt_date old_actual_cmplt_date
      FROM   gme_batch_steps_mig m, gme_batch_steps s
      WHERE  m.batch_id = v_old_batch_id
             AND s.batch_id = v_new_batch_id
             AND m.step_status > gme_common_pvt.g_step_pending
             AND s.batchstep_no = m.batchstep_no
             AND NOT(s.step_status = m.step_status)
      ORDER BY s.batchstep_no;
    CURSOR Cur_verify_phantoms(v_batch_id NUMBER) IS
      SELECT 1
      FROM DUAL
      WHERE EXISTS (SELECT batch_id
                    FROM   gme_material_details
                    WHERE  batch_id = v_batch_id
                           AND phantom_type > 0
                           AND phantom_id NOT IN (SELECT new_batch_id FROM gme_batch_mapping_mig));
    l_date             DATE;
    l_temp             NUMBER;
    l_msg_cnt          NUMBER;
    l_current_org_id   NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_return_status    VARCHAR2(1);
    l_api_name VARCHAR2(30) := 'release_batches';
    l_batch_header     gme_batch_header%ROWTYPE;
    l_batch_header_out gme_batch_header%ROWTYPE;
    l_step_rec         gme_batch_steps%ROWTYPE;
    l_step_rec_out     gme_batch_steps%ROWTYPE;
    l_exception_tbl    gme_common_pvt.exceptions_tab;
    no_open_period_err EXCEPTION;
    step_release_err   EXCEPTION;
    step_cmplt_err     EXCEPTION;
    release_batch_err  EXCEPTION;
    inv_phantoms_found EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    gme_release_batch_pvt.g_bypass_txn_creation := 1;
    FOR get_wip_batches IN Cur_wip_batches LOOP
      BEGIN
      	/* Make sure phantom batches have been created before releasing main batch */
      	OPEN Cur_verify_phantoms(get_wip_batches.new_batch_id);
      	FETCH Cur_verify_phantoms INTO l_temp;
      	IF (Cur_verify_phantoms%FOUND) THEN
      	  CLOSE Cur_verify_phantoms;
      	  RAISE inv_phantoms_found;
      	END IF;
      	CLOSE Cur_verify_phantoms;
        l_batch_header.batch_id          := get_wip_batches.new_batch_id;
        l_batch_header.organization_id   := get_wip_batches.organization_id;
        l_batch_header.actual_start_date := get_wip_batches.actual_start_date;
        check_date(p_organization_id => l_batch_header.organization_id,
                   p_date            => l_batch_header.actual_start_date,
                   x_date            => l_date,
                   x_return_status   => l_return_status);
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          RAISE no_open_period_err;
        ELSE
          l_batch_header.actual_start_date := l_date;
        END IF;
        gme_api_pub.release_batch(p_api_version              => 2.0,
                                  p_validation_level         => gme_common_pvt.g_max_errors,
                                  p_init_msg_list            => fnd_api.g_false,
                                  p_commit                   => fnd_api.g_true,
                                  x_message_count            => l_msg_cnt,
                                  x_message_list             => l_msg_data,
                                  x_return_status            => l_return_status,
                                  p_batch_header_rec         => l_batch_header,
                                  p_org_code                 => NULL,
                                  p_ignore_exception         => fnd_api.g_false,
                                  p_validate_flexfields      => fnd_api.g_false,
                                  x_batch_header_rec         => l_batch_header_out,
                                  x_exception_material_tbl   => l_exception_tbl);
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          RAISE release_batch_err;
        END IF;
        FOR get_steps IN Cur_get_steps(get_wip_batches.old_batch_id, l_batch_header.batch_id) LOOP
          BEGIN
            check_date(p_organization_id => l_batch_header.organization_id,
                       p_date            => get_steps.old_actual_start_date,
                       x_date            => l_date,
                       x_return_status   => l_return_status);
            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              RAISE no_open_period_err;
            ELSE
              get_steps.actual_start_date := l_date;
            END IF;
            l_step_rec.batchstep_id      := get_steps.batchstep_id;
            l_step_rec.batch_id          := get_steps.batch_id;
            l_step_rec.actual_start_date := get_steps.old_actual_start_date;
            l_step_rec.actual_cmplt_date := get_steps.old_actual_cmplt_date;
            IF (get_steps.old_step_status IN (gme_common_pvt.g_step_completed, gme_common_pvt.g_step_closed)) THEN
              gme_api_pub.complete_step(p_api_version            => 2.0,
                                        p_validation_level       => gme_common_pvt.g_max_errors,
                                        p_init_msg_list          => fnd_api.g_false,
                                        p_commit                 => fnd_api.g_true,
                                        x_message_count          => l_msg_cnt,
                                        x_message_list           => l_msg_data,
                                        x_return_status          => l_return_status,
                                        p_batch_step_rec         => l_step_rec,
                                        p_batch_no               => NULL,
                                        p_org_code               => NULL,
                                        p_ignore_exception       => fnd_api.g_false,
                                        p_override_quality       => fnd_api.g_false,
                                        p_validate_flexfields    => fnd_api.g_false,
                                        x_batch_step_rec         => l_step_rec_out,
                                        x_exception_material_tbl => l_exception_tbl);
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE step_cmplt_err;
              END IF;
            ELSE
              gme_api_pub.release_step(p_api_version            => 2.0,
                                       p_validation_level       => gme_common_pvt.g_max_errors,
                                       p_init_msg_list          => fnd_api.g_false,
                                       p_commit                 => fnd_api.g_true,
                                       x_message_count          => l_msg_cnt,
                                       x_message_list           => l_msg_data,
                                       x_return_status          => l_return_status,
                                       p_batch_step_rec         => l_step_rec,
                                       p_batch_no               => NULL,
                                       p_org_code               => NULL,
                                       p_ignore_exception       => fnd_api.g_false,
                                       p_validate_flexfields    => fnd_api.g_false,
                                       x_batch_step_rec         => l_step_rec_out,
                                       x_exception_material_tbl => l_exception_tbl);
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE step_release_err;
              END IF;
            END IF;
          EXCEPTION
            WHEN inv_phantoms_found THEN
              NULL;
            WHEN no_open_period_err THEN
              gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_NO_OPEN_PERIODS_STEP',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                      p_token2              => 'STEP_NO',
                      p_param2              => get_steps.batchstep_no);
            WHEN step_cmplt_err THEN
              gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_STEP_CMPLT_ERR',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                      p_token2              => 'STEP_NO',
                      p_param2              => get_steps.batchstep_no,
                      p_token3              => 'MSG',
                      p_param3              => l_msg_data);
            WHEN step_release_err THEN
              gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_STEP_RELEASE_ERR',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                      p_token2              => 'STEP_NO',
                      p_param2              => get_steps.batchstep_no,
                      p_token3              => 'MSG',
                      p_param3              => l_msg_data);
            WHEN OTHERS THEN
              IF (g_debug <= gme_debug.g_log_unexpected) THEN
                gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
              END IF;
              gma_common_logging.gma_migration_central_log
                         (p_run_id              => g_migration_run_id,
                          p_log_level           => fnd_log.level_error,
                          p_message_token       => 'GME_STEP_PROCESS_UNEXP',
                          p_table_name          => 'GME_BATCH_HEADER',
                          p_context             => 'RECREATE_OPEN_BATCHES',
                          p_app_short_name      => 'GME',
                          p_token1              => 'BATCH_NO',
                          p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                          p_token2              => 'STEP_NO',
                          p_param2              => get_steps.batchstep_no,
                          p_token3              => 'MSG',
                          p_param3              => SQLERRM);
          END;
        END LOOP;
      EXCEPTION
        WHEN no_open_period_err THEN
          gma_common_logging.gma_migration_central_log
                   (p_run_id              => g_migration_run_id,
                    p_log_level           => fnd_log.level_error,
                    p_message_token       => 'GME_NO_OPEN_PERIODS_BATCH',
                    p_table_name          => 'GME_BATCH_HEADER',
                    p_context             => 'RECREATE_OPEN_BATCHES',
                    p_app_short_name      => 'GME',
                    p_token1              => 'BATCH_NO',
                    p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no);
        WHEN release_batch_err THEN
          gme_common_pvt.count_and_get(x_count  => l_msg_cnt
                                      ,x_data   => l_msg_data);
          gma_common_logging.gma_migration_central_log
                         (p_run_id              => g_migration_run_id,
                          p_log_level           => fnd_log.level_error,
                          p_message_token       => 'GME_BATCH_RELEASE_ERR',
                          p_table_name          => 'GME_BATCH_HEADER',
                          p_context             => 'RECREATE_OPEN_BATCHES',
                          p_app_short_name      => 'GME',
                          p_token1              => 'BATCH_NO',
                          p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                          p_token2              => 'MSG',
                          p_param2              => l_msg_data);
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
          gma_common_logging.gma_migration_central_log
                   (p_run_id              => g_migration_run_id,
                    p_log_level           => fnd_log.level_error,
                    p_message_token       => 'GME_BATCH_PROCESS_UNEXP',
                    p_table_name          => 'GME_BATCH_HEADER',
                    p_context             => 'RECREATE_OPEN_BATCHES',
                    p_app_short_name      => 'GME',
                    p_token1              => 'BATCH_NO',
                    p_param1              => get_wip_batches.plant_code||'-'||get_wip_batches.new_batch_no,
                    p_token2              => 'MSG',
                    p_param2              => SQLERRM);
      END;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END release_batches;

  PROCEDURE check_date(p_organization_id IN NUMBER,
                       p_date            IN DATE,
                       x_date            OUT NOCOPY DATE,
                       x_return_status   OUT NOCOPY VARCHAR2) IS
    l_period_id      NUMBER;
    l_open_period    BOOLEAN;
    no_open_periods  EXCEPTION;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    invttmtx.tdatechk(org_id           => p_organization_id,
		      transaction_date => p_date,
		      period_id        => l_period_id,
 		      open_past_period => l_open_period);
    IF (l_period_id <= 0) THEN
      invttmtx.tdatechk(org_id           => p_organization_id,
	  	        transaction_date => gme_common_pvt.g_timestamp,
		        period_id        => l_period_id,
 		        open_past_period => l_open_period);
      IF (l_period_id <= 0) THEN
      	RAISE no_open_periods;
      ELSE
      	x_date := gme_common_pvt.g_timestamp;
      END IF;
    ELSE
      x_date := p_date;
    END IF;
  EXCEPTION
    WHEN no_open_periods THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_date;

  PROCEDURE get_subinventory(p_whse_code       IN VARCHAR2,
                             x_subinventory    OUT NOCOPY VARCHAR2,
                             x_organization_id OUT NOCOPY NUMBER) IS
    CURSOR Cur_whse_mst(v_whse_code VARCHAR2) IS
      SELECT subinventory_ind_flag
      FROM   ic_whse_mst
      WHERE  whse_code = v_whse_code;
    CURSOR Cur_subinv_details(v_whse_code VARCHAR2) IS
      SELECT secondary_inventory_name, organization_id
      FROM   mtl_secondary_inventories
      WHERE  secondary_inventory_name = v_whse_code;
    CURSOR Cur_subinv_from_whse(v_whse_code VARCHAR2) IS
      SELECT s.secondary_inventory_name, s.organization_id
      FROM   mtl_secondary_inventories s, ic_whse_mst w
      WHERE  secondary_inventory_name = v_whse_code
             AND w.whse_code = s.secondary_inventory_name
             AND s.organization_id = w.mtl_organization_id;
    l_subinv_ind   VARCHAR2(1);
    l_api_name VARCHAR2(30) := 'get_subinventory';
  BEGIN
    IF (p_whse_code IS NOT NULL) THEN
      BEGIN
      	/* If already exists in PL/SQL table take it */
      	x_subinventory    := p_subinv_tbl(p_whse_code).subinventory;
      	x_organization_id := p_subinv_tbl(p_whse_code).organization_id;
      	RETURN;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    ELSE
      RETURN;
    END IF;
    OPEN Cur_whse_mst(p_whse_code);
    FETCH Cur_whse_mst INTO l_subinv_ind;
    CLOSE Cur_whse_mst;
    IF NVL(l_subinv_ind, 'N') = 'Y' THEN
      OPEN Cur_subinv_details(p_whse_code);
      FETCH Cur_subinv_details INTO x_subinventory, x_organization_id;
      CLOSE Cur_subinv_details;
    ELSE
      OPEN Cur_subinv_from_whse(p_whse_code);
      FETCH Cur_subinv_from_whse INTO x_subinventory, x_organization_id;
      CLOSE Cur_subinv_from_whse;
    END IF;
    /* Add to PL/SQL table so next time this whse is used values can be taken from PL/SQL table */
    p_subinv_tbl(p_whse_code).subinventory    := x_subinventory;
    p_subinv_tbl(p_whse_code).organization_id := x_organization_id;
  END get_subinventory;

  PROCEDURE get_locator(p_location        IN VARCHAR2,
                        p_whse_code       IN VARCHAR2,
                        x_organization_id OUT NOCOPY NUMBER,
                        x_locator_id      OUT NOCOPY NUMBER,
                        x_subinventory    OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_ic_loct_mst IS
      SELECT i.locator_id, m.organization_id, m.subinventory_code
      FROM   ic_loct_mst i, mtl_item_locations m
      WHERE  i.location = p_location
             AND i.whse_code = p_whse_code
             AND m.inventory_location_id = i.locator_id;
    CURSOR Cur_mtl_locs IS
      SELECT m.inventory_location_id locator_id, m.organization_id, m.subinventory_code
      FROM   mtl_item_locations m
      WHERE  m.segment1 = p_location
             AND m.subinventory_code = x_subinventory;
    l_api_name VARCHAR2(30) := 'get_locator';
  BEGIN
    BEGIN
      x_locator_id      := p_locator_tbl(p_whse_code||'**'||p_location).locator_id;
      x_organization_id := p_locator_tbl(p_whse_code||'**'||p_location).organization_id;
      x_subinventory    := p_locator_tbl(p_whse_code||'**'||p_location).subinventory;
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    OPEN Cur_ic_loct_mst;
    FETCH Cur_ic_loct_mst INTO x_locator_id, x_organization_id, x_subinventory;
    IF (Cur_ic_loct_mst%NOTFOUND) THEN
      get_subinventory(p_whse_code       => p_whse_code,
                       x_subinventory    => x_subinventory,
                       x_organization_id => x_organization_id);
      OPEN Cur_mtl_locs;
      FETCH Cur_mtl_locs INTO x_locator_id, x_organization_id, x_subinventory;
      CLOSE Cur_mtl_locs;
    END IF;
    CLOSE Cur_ic_loct_mst;
    p_locator_tbl(p_whse_code||'**'||p_location).locator_id      := x_locator_id;
    p_locator_tbl(p_whse_code||'**'||p_location).organization_id := x_organization_id;
    p_locator_tbl(p_whse_code||'**'||p_location).subinventory    := x_subinventory;
  END get_locator;

  FUNCTION get_latest_revision(p_organization_id   IN NUMBER,
                               p_inventory_item_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR Cur_get_revision IS
      SELECT revision
      FROM   mtl_item_revisions
      WHERE  organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND effectivity_date <= gme_common_pvt.g_timestamp
      ORDER BY effectivity_date DESC;
    l_revision  VARCHAR2(3);
  BEGIN
    OPEN Cur_get_revision;
    FETCH Cur_get_revision INTO l_revision;
    CLOSE Cur_get_revision;
    RETURN l_revision;
  END get_latest_revision;

  FUNCTION get_reason(p_reason_code IN VARCHAR2) RETURN NUMBER IS
    CURSOR Cur_get_reason IS
      SELECT reason_id
      FROM   sy_reas_cds_b
      WHERE  reason_code = p_reason_code;
    l_reason_id  NUMBER;
  BEGIN
    OPEN Cur_get_reason;
    FETCH Cur_get_reason INTO l_reason_id;
    CLOSE Cur_get_reason;
    RETURN l_reason_id;
  END get_reason;

  PROCEDURE create_locator(p_location		IN  VARCHAR2,
                           p_organization_id	IN  NUMBER,
                           p_subinventory_code	IN  VARCHAR2,
                           x_location_id	OUT NOCOPY NUMBER,
                           x_failure_count	OUT NOCOPY NUMBER) IS
    CURSOR Cur_loc_details IS
      SELECT *
      FROM   ic_loct_mst
      WHERE  location = p_location;
    l_loc_rec  ic_loct_mst%ROWTYPE;
    l_api_name VARCHAR2(30) := 'create_locator';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('creating locator '||p_location||'->'||p_organization_id||'-'||p_subinventory_code);
    END IF;
    OPEN Cur_loc_details;
    FETCH Cur_loc_details INTO l_loc_rec;
    CLOSE Cur_loc_details;
    inv_migrate_process_org.create_location (p_migration_run_id	 => g_migration_run_id,
		                             p_organization_id	 => p_organization_id,
		                             p_subinventory_code => p_subinventory_code,
		                             p_location		 => p_location,
			                     p_loct_desc	 => l_loc_rec.loct_desc,
			                     p_start_date_active => l_loc_rec.creation_date,
                                             p_commit		 => fnd_api.g_true,
			                     x_location_id	 => x_location_id,
                                             x_failure_count	 => x_failure_count,
                                             p_disable_date      => NULL,
                                             p_segment2          => NULL,
                                             p_segment3          => NULL,
                                             p_segment4          => NULL,
                                             p_segment5          => NULL,
                                             p_segment6          => NULL,
                                             p_segment7          => NULL,
                                             p_segment8          => NULL,
                                             p_segment9          => NULL,
                                             p_segment10         => NULL,
                                             p_segment11         => NULL,
                                             p_segment12         => NULL,
                                             p_segment13         => NULL,
                                             p_segment14         => NULL,
                                             p_segment15         => NULL,
                                             p_segment16         => NULL,
                                             p_segment17         => NULL,
                                             p_segment18         => NULL,
                                             p_segment19         => NULL,
                                             p_segment20         => NULL);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_locator;

  PROCEDURE get_subinv_locator_type(p_subinventory IN VARCHAR2,
                                    p_organization_id IN NUMBER,
                                    x_locator_type OUT NOCOPY NUMBER) IS
    CURSOR Cur_sub_control(v_org_id NUMBER, v_subinventory VARCHAR2) IS
      SELECT locator_type
      FROM   mtl_secondary_inventories
      WHERE  organization_id = v_org_id
             AND secondary_inventory_name = v_subinventory;
  BEGIN
    BEGIN
      x_locator_type := p_subinv_loctype_tbl(p_subinventory).locator_type;
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    OPEN cur_sub_control (p_organization_id, p_subinventory);
    FETCH cur_sub_control INTO x_locator_type;
    CLOSE cur_sub_control;
    p_subinv_loctype_tbl(p_subinventory).locator_type := x_locator_type;
  END get_subinv_locator_type;

  PROCEDURE get_distribution_account(p_subinventory  IN VARCHAR2,
                                     p_org_id        IN NUMBER,
                                     x_dist_acct_id  OUT NOCOPY NUMBER) IS
    CURSOR Cur_get_acct IS
      SELECT NVL(NVL(s.expense_account, s.material_account),NVL(m.expense_account, m.material_account))
      FROM   mtl_secondary_inventories s, mtl_parameters m
      WHERE  s.secondary_inventory_name = p_subinventory
             AND m.organization_id = p_org_id;
  BEGIN
    OPEN Cur_get_acct;
    FETCH Cur_get_acct INTO x_dist_acct_id;
    CLOSE Cur_get_acct;
  END get_distribution_account;
  /* Bug 5620671 Added param completed ind */
  PROCEDURE create_txns_reservations(p_completed_ind IN NUMBER) IS
    TYPE txns_tab IS TABLE OF Cur_get_txns%ROWTYPE INDEX BY BINARY_INTEGER;
    l_txns_tbl        txns_tab;
    l_date            DATE;
    l_count           NUMBER;
    l_msg_cnt         NUMBER;
    l_mat_detail_id   NUMBER;
    l_curr_detail_id  NUMBER;
    l_curr_batch_id   NUMBER := 0;
    l_org_id          NUMBER;
    l_curr_org_id     NUMBER := 0;
    l_locator_id      NUMBER;
    l_sub_loc_type    NUMBER;
    l_eff_loc_control NUMBER;
    l_failure_count   NUMBER;
    l_api_name VARCHAR2(30) := 'create_txns_reservations';
    l_return_status   VARCHAR2(1);
    l_subinventory    VARCHAR2(10);
    l_in_subinventory VARCHAR2(10);
    l_msg_name        VARCHAR2(32);
    l_lot_no          VARCHAR2(32);
    l_sublot_no       VARCHAR2(32);
    l_lot_number      VARCHAR2(80);
    l_parent_lot_no   VARCHAR2(80);
    l_def_location    VARCHAR2(100) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
    l_msg_data        VARCHAR2(2000);
    l_txn_data        VARCHAR2(2000);
    l_new_data        VARCHAR2(2000);

    CURSOR Cur_mtl_dtl(v_material_detail_id NUMBER) IS
      SELECT d.*, i.mtl_transactions_enabled_flag, i.reservable_type, i.segment1, i.lot_control_code,
             i.revision_qty_control_code, i.primary_uom_code, i.secondary_uom_code, i.restrict_subinventories_code,
             NVL(i.location_control_code,1) location_control_code, i.restrict_locators_code, i.segment1 item_no
      FROM   gme_material_details d, mtl_system_items_b i
      WHERE  d.material_detail_id = v_material_detail_id
             AND i.organization_id = d.organization_id
             AND i.inventory_item_id = d.inventory_item_id;
    CURSOR Cur_lot_mst(v_lot_id NUMBER) IS
      SELECT lot_no,sublot_no
      FROM   ic_lots_mst
      WHERE  lot_id = v_lot_id;
    l_batch_hdr       gme_batch_header%ROWTYPE;
    l_mtl_rec         Cur_mtl_dtl%ROWTYPE;
    l_mmti_rec        mtl_transactions_interface%ROWTYPE;
    l_mmli_tbl        gme_common_pvt.mtl_trans_lots_inter_tbl;
    l_mtl_dtl_rec     gme_material_details%ROWTYPE;
    l_plot_out_rec    gme_pending_product_lots%ROWTYPE;
    l_plot_in_rec     gme_pending_product_lots%ROWTYPE;
    l_mmt_rec         mtl_material_transactions%ROWTYPE;
    l_mmln_rec        gme_common_pvt.mtl_trans_lots_num_tbl;
    uom_conversion_fail     EXCEPTION;
    setup_failed            EXCEPTION;
    create_txn_rsv_pp_err   EXCEPTION;
    batch_fetch_err         EXCEPTION;
    expected_error          EXCEPTION;
    defined_error           EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    /* Bug 5620671 Added param completed ind */
    OPEN Cur_get_txns(p_completed_ind);
    FETCH Cur_get_txns BULK COLLECT INTO l_txns_tbl;
    CLOSE Cur_get_txns;
    l_count := l_txns_tbl.count;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('No. of txns = '||l_count);
    END IF;
    FOR i IN 1..l_count LOOP
      BEGIN
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Processing trans_id = '||l_txns_tbl(i).trans_id);
          gme_debug.put_line('l_curr_org_id = '||l_curr_org_id||' l_txns_tbl(i).organization_id = '||l_txns_tbl(i).organization_id);
        END IF;
        gme_common_pvt.g_transaction_header_id := NULL;
      	l_lot_number   := NULL;
      	l_subinventory := NULL;
      	l_locator_id   := NULL;
      	l_org_id       := NULL;
      	l_mmti_rec     := NULL;
      	l_txn_data     := NULL;
      	l_new_data     := NULL;
      	l_mmli_tbl.delete;
      	IF (l_curr_org_id <> l_txns_tbl(i).organization_id) THEN
           -- Bug 9164563 - Reset the global flag to make sure setup is done for new org.
           gme_common_pvt.g_setup_done := FALSE;

      	  IF NOT (gme_common_pvt.setup(p_org_id => l_txns_tbl(i).organization_id)) THEN
      	    RAISE setup_failed;
      	  END IF;
      	  l_curr_org_id := l_txns_tbl(i).organization_id;
          IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line('gme_common_pvt.g_organization_id = '||gme_common_pvt.g_organization_id||' gme_common_pvt.g_organization_code = '||gme_common_pvt.g_organization_code);
          END IF;
      	END IF;
      	IF (l_curr_batch_id <> l_txns_tbl(i).new_batch_id) THEN
      	  l_batch_hdr.batch_id := l_txns_tbl(i).new_batch_id;
      	  IF NOT(gme_batch_header_dbl.fetch_row(p_batch_header => l_batch_hdr,
      	                                        x_batch_header => l_batch_hdr)) THEN
      	    RAISE batch_fetch_err;
      	  END IF;
      	  l_curr_batch_id := l_txns_tbl(i).new_batch_id;
      	END IF;
      	IF (NVL(l_curr_detail_id,0) <> NVL(l_txns_tbl(i).line_id, -1)) THEN
      	  l_mat_detail_id  := get_new_mat_id(p_old_mat_id => l_txns_tbl(i).line_id, p_new_batch_id => l_txns_tbl(i).new_batch_id);
      	  l_curr_detail_id := l_txns_tbl(i).line_id;
      	  OPEN Cur_mtl_dtl(l_mat_detail_id);
      	  FETCH Cur_mtl_dtl INTO l_mtl_rec;
      	  CLOSE Cur_mtl_dtl;
      	END IF;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Processing transaction for Batch = '||gme_common_pvt.g_organization_code||'-'||l_batch_hdr.batch_no||' Line Type = '||l_mtl_rec.line_type||' Line No = '||l_mtl_rec.line_no||' Phantom_type = '||l_mtl_rec.phantom_type);
        END IF;
      	/* Do not create phantom ing txns these will be created by phantom prod txns */
      	IF NOT(l_mtl_rec.line_type = gme_common_pvt.g_line_type_ing AND l_mtl_rec.phantom_type IN (gme_common_pvt.g_auto_phantom, gme_common_pvt.g_manual_phantom)) THEN
          IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line('Not a phantom ing txn');
          END IF;
      	  IF (l_txns_tbl(i).completed_ind = 1) THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('This is a completed txn');
            END IF;
            IF (l_batch_hdr.batch_status <= 1) THEN
              l_msg_name := 'GME_MIG_BATCH_INVALID_FOR_TXN';
              RAISE defined_error;
            END IF;
      	    IF (l_mtl_rec.mtl_transactions_enabled_flag <> 'Y') THEN
      	      l_msg_name := 'GME_MIG_ITEM_NOT_TXNS_ENABLED';
      	      RAISE defined_error;
      	    END IF;
            SELECT mtl_material_transactions_s.NEXTVAL INTO gme_common_pvt.g_transaction_header_id FROM DUAL;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('Transaction header ID = '||gme_common_pvt.g_transaction_header_id);
            END IF;
            l_mmti_rec.transaction_source_id := l_mtl_rec.batch_id;
            l_mmti_rec.trx_source_line_id    := l_mtl_rec.material_detail_id;
            l_mmti_rec.inventory_item_id     := l_mtl_rec.inventory_item_id;
            l_mmti_rec.organization_id       := l_mtl_rec.organization_id;
            IF (l_mtl_rec.revision_qty_control_code = 2) THEN
              l_mmti_rec.revision := get_latest_revision(p_organization_id => l_mtl_rec.organization_id, p_inventory_item_id => l_mtl_rec.inventory_item_id);
              IF (l_mmti_rec.revision IS NULL) THEN
              	l_msg_name := 'GME_MIG_REVISION_NOT_FOUND';
              	RAISE defined_error;
              END IF;
            ELSE
              l_mmti_rec.revision := NULL;
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('After revision before check date');
            END IF;
            check_date(p_organization_id => l_mtl_rec.organization_id,
                       p_date            => l_txns_tbl(i).trans_date,
                       x_date            => l_date,
                       x_return_status   => l_return_status);
            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              l_msg_name := 'GME_NO_OPEN_PERIODS_TXN';
              RAISE defined_error;
            END IF;
            l_mmti_rec.transaction_date := l_date;
            IF (l_mtl_rec.line_type = gme_common_pvt.g_line_type_ing) THEN
              l_mmti_rec.transaction_type_id   := gme_common_pvt.g_ing_issue;
              l_mmti_rec.transaction_action_id := gme_common_pvt.g_ing_issue_txn_action;
            ELSIF (l_mtl_rec.line_type = gme_common_pvt.g_line_type_prod) THEN
              l_mmti_rec.transaction_type_id   := gme_common_pvt.g_prod_completion;
              l_mmti_rec.transaction_action_id := gme_common_pvt.g_prod_comp_txn_action;
            ELSIF (l_mtl_rec.line_type = gme_common_pvt.g_line_type_byprod) THEN
              l_mmti_rec.transaction_type_id   := gme_common_pvt.g_byprod_completion;
              l_mmti_rec.transaction_action_id := gme_common_pvt.g_byprod_comp_txn_action;
            END IF;
            l_mmti_rec.primary_quantity               := ROUND(ABS(l_txns_tbl(i).trans_qty),5);
            l_mmti_rec.secondary_transaction_quantity := ROUND(ABS(l_txns_tbl(i).trans_qty2),5);
            l_mmti_rec.secondary_uom_code             := l_mtl_rec.secondary_uom_code;
            l_mmti_rec.transaction_uom                := l_mtl_rec.dtl_um;
            l_mmti_rec.transaction_source_type_id     := gme_common_pvt.g_txn_source_type;
            l_mmti_rec.wip_entity_type                := gme_common_pvt.g_wip_entity_type_batch;
            l_mmti_rec.reason_id                      := get_reason(l_txns_tbl(i).reason_code);
            IF (l_txns_tbl(i).reason_code IS NOT NULL AND l_mmti_rec.reason_id IS NULL) THEN
      	      l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
      	      l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||to_char(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
              gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_MIG_REASON_NOT_FOUND',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'TRANS_ID',
                      p_param2              => l_txns_tbl(i).trans_id,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data,
                      p_token4              => 'REASON_CODE',
                      p_param4              => l_txns_tbl(i).reason_code);
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('After putting all values in l_mmti_rec');
            END IF;
            /* If item is location controlled then get locator/sub/org otherwise get sub/org */
            IF (NVL(l_txns_tbl(i).location, l_def_location) <> l_def_location) THEN
              get_locator(p_location        => l_txns_tbl(i).location,
                          p_whse_code       => l_txns_tbl(i).whse_code,
                          x_organization_id => l_org_id,
                          x_locator_id      => l_locator_id,
                          x_subinventory    => l_subinventory);
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('One l_org_id = '||l_org_id||' l_subinventory = '||l_subinventory||' l_locator_id = '||l_locator_id );
            END IF;

            /* If we have sub it means locator exists otherwise get sub */
            IF (l_subinventory IS NULL) THEN
              get_subinventory(p_whse_code       => l_txns_tbl(i).whse_code,
                               x_subinventory    => l_subinventory,
                               x_organization_id => l_org_id);
              IF (l_subinventory IS NULL) THEN
              	l_msg_name := 'GME_MIG_SUBINV_NOT_FOUND';
                RAISE defined_error;
              END IF;
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('Two l_org_id = '||l_org_id||' l_subinventory = '||l_subinventory||' l_locator_id = '||l_locator_id );
              gme_debug.put_line('l_org_id = '||l_org_id||' l_mmti_rec.organization_id = '||l_mmti_rec.organization_id);
            END IF;
            /* If subinventory is in same org as batch then it is fine or we have to do issue/receipt */
            IF (l_org_id <> l_mmti_rec.organization_id) THEN
              /* Create a misc issue in l_org_id and a receipt in l_mmti_rec.organization_id */
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('creating issue/receipt from org = '||l_org_id||' to org = '||l_mmti_rec.organization_id);
              END IF;
              create_issue_receipt(p_curr_org_id       => l_org_id,
                                   p_inventory_item_id => l_mtl_rec.inventory_item_id,
                                   p_txn_rec           => l_txns_tbl(i),
                                   p_mmti_rec          => l_mmti_rec,
                                   p_item_no           => l_mtl_rec.item_no,
                                   p_subinventory      => l_subinventory,
                                   p_locator_id        => l_locator_id,
                                   p_batch_org_id      => l_mmti_rec.organization_id,
                                   x_subinventory      => l_mmti_rec.subinventory_code,
                                   x_locator_id        => l_mmti_rec.locator_id,
                                   x_lot_number        => l_lot_number,
                                   x_return_status     => l_return_status);
              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE expected_error;
              END IF;
            ELSE
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('All in same org');
              END IF;
              IF NOT (gme_common_pvt.check_subinventory(p_organization_id   => l_mtl_rec.organization_id
                                                       ,p_subinventory      => l_subinventory
                                                       ,p_inventory_item_id => l_mtl_rec.inventory_item_id
                                                       ,p_restrict_subinv   => l_mtl_rec.restrict_subinventories_code)) THEN
                l_subinventory := NULL;
                l_locator_id   := NULL;
                l_msg_name := 'GME_MIG_SUBINV_NOT_FOUND';
                RAISE defined_error;
              END IF;
              get_subinv_locator_type(p_subinventory     => l_subinventory,
                                      p_organization_id  => l_mtl_rec.organization_id,
                                      x_locator_type     => l_sub_loc_type);
              l_eff_loc_control := gme_common_pvt.eff_locator_control(p_organization_id   => l_mtl_rec.organization_id,
                                                                      p_subinventory      => l_subinventory,
                                                                      p_inventory_item_id => l_mtl_rec.inventory_item_id,
                                                                      p_org_control       => gme_common_pvt.g_org_locator_control,
                                                                      p_sub_control       => l_sub_loc_type,
                                                                      p_item_control      => NVL(l_mtl_rec.location_control_code,1),
                                                                      p_item_loc_restrict => l_mtl_rec.restrict_locators_code,
                                                                      p_org_neg_allowed   => gme_common_pvt.g_allow_neg_inv,
                                                                      p_action            => l_mmti_rec.transaction_action_id);
              IF (l_eff_loc_control = 1) THEN
                l_locator_id := NULL;
              ELSE
                IF (l_locator_id IS NULL AND NVL(l_txns_tbl(i).location, l_def_location) <> l_def_location) THEN
                  create_locator(p_location	     => l_txns_tbl(i).location,
                                 p_organization_id   => l_mtl_rec.organization_id,
                                 p_subinventory_code => l_subinventory,
                                 x_location_id       => l_locator_id,
                                 x_failure_count     => l_failure_count);
                END IF;
              END IF;
              IF (l_locator_id IS NOT NULL) THEN
                IF NOT (Gme_Common_Pvt.check_locator
                            (p_organization_id        => l_mtl_rec.organization_id
                            ,p_locator_id             => l_locator_id
                            ,p_subinventory           => l_subinventory
                            ,p_inventory_item_id      => l_mtl_rec.inventory_item_id
                            ,p_org_control            => Gme_Common_Pvt.g_org_locator_control
                            ,p_sub_control            => l_sub_loc_type
                            ,p_item_control           => NVL(l_mtl_rec.location_control_code,1)
                            ,p_item_loc_restrict      => l_mtl_rec.restrict_locators_code
                            ,p_org_neg_allowed        => Gme_Common_Pvt.g_allow_neg_inv
                            ,p_txn_action_id          => l_mmti_rec.transaction_action_id)) THEN
                   l_locator_id := NULL;
                   l_msg_name := 'GME_MIG_LOCATOR_NOT_FOUND';
                   RAISE defined_error;
                END IF;
              END IF;
              l_mmti_rec.subinventory_code := l_subinventory;
              l_mmti_rec.locator_id        := l_locator_id;
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('Lot control code is '||l_mtl_rec.lot_control_code);
            END IF;
            IF (l_mtl_rec.lot_control_code = 2) THEN
              IF (l_lot_number IS NULL) THEN
                inv_opm_lot_migration.get_odm_lot(p_migration_run_id  => g_migration_run_id,
                                                  p_item_id           => l_txns_tbl(i).item_id,
                                                  p_lot_id	      => l_txns_tbl(i).lot_id,
                                                  p_whse_code	      => l_txns_tbl(i).whse_code,
                                                  p_orgn_code	      => NULL,
                                                  p_location	      => l_txns_tbl(i).location,
                                                  p_commit	      => fnd_api.g_true,
                                                  x_lot_number	      => l_lot_number,
                                                  x_parent_lot_number => l_parent_lot_no,
                                                  x_failure_count     => l_failure_count);
                IF (l_failure_count > 0 OR l_lot_number IS NULL) THEN
                  l_msg_name := 'GME_MIG_LOT_NOT_FOUND';
                  RAISE defined_error;
                END IF;
              END IF;
              l_mmli_tbl(1).lot_number := l_lot_number;
            END IF;
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('After Lot processing lot is '||l_lot_number);
            END IF;
            IF (l_mtl_rec.dtl_um <> l_mtl_rec.primary_uom_code) THEN
              l_mmti_rec.transaction_quantity := inv_convert.inv_um_convert(item_id         => l_mtl_rec.inventory_item_id
                                                                           ,lot_number      => l_lot_number
                                                                           ,organization_id => l_mtl_rec.organization_id
                                                                           ,PRECISION       => gme_common_pvt.g_precision
                                                                           ,from_quantity   => ABS(l_txns_tbl(i).trans_qty)
                                                                           ,from_unit       => l_mtl_rec.primary_uom_code
                                                                           ,to_unit         => l_mtl_rec.dtl_um
                                                                           ,from_name       => NULL
                                                                           ,to_name         => NULL);
              IF (l_mmti_rec.transaction_quantity < 0) THEN
              	RAISE uom_conversion_fail;
              END IF;
            ELSE
              l_mmti_rec.transaction_quantity := ROUND(ABS(l_txns_tbl(i).trans_qty),5);
            END IF;
            IF (l_mmli_tbl.count > 0) THEN
              l_mmli_tbl(1).transaction_quantity           := l_mmti_rec.transaction_quantity;
              l_mmli_tbl(1).secondary_transaction_quantity := l_mmti_rec.secondary_transaction_quantity;
            END IF;
            l_new_data := gme_common_pvt.g_organization_code||'->'||l_mtl_rec.item_no||'->'||l_mmti_rec.revision||'->'||
            l_mmti_rec.subinventory_code||'->'||l_mmti_rec.locator_id||'->'||l_lot_number||'->'||l_mmti_rec.transaction_quantity||'->'||l_mmti_rec.transaction_uom||'->'||TO_CHAR(l_mmti_rec.transaction_date, 'DD-MON-YYYY HH24:MI:SS');
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('Creating TXN with '||l_new_data);
            END IF;
      	    gme_api_pub.create_material_txn(p_api_version         => 2.0,
                                            p_validation_level    => gme_common_pvt.g_max_errors,
                                            p_init_msg_list       => fnd_api.g_false,
                                            p_commit              => fnd_api.g_false,
                                            x_message_count       => l_msg_cnt,
                                            x_message_list        => l_msg_data,
                                            x_return_status       => l_return_status,
                                            p_org_code            => NULL,
                                            p_mmti_rec            => l_mmti_rec,
                                            p_mmli_tbl            => l_mmli_tbl,
                                            p_batch_no            => NULL,
                                            p_line_no             => NULL,
                                            p_line_type           => NULL,
                                            p_create_lot          => NULL,
                                            p_generate_lot        => NULL,
                                            p_generate_parent_lot => NULL,
                                            x_mmt_rec             => l_mmt_rec,
                                            x_mmln_tbl            => l_mmln_rec);
            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              l_msg_name := 'GME_CREATE_TXN_FAIL';
              RAISE create_txn_rsv_pp_err;
            END IF;
          ELSE /* IF (l_txns_tbl(i).completed_ind = 1) THEN */
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line('This is a pending txn');
            END IF;
            l_mmti_rec.transaction_source_id := l_mtl_rec.batch_id;
            l_mmti_rec.trx_source_line_id    := l_mtl_rec.material_detail_id;
            l_mmti_rec.inventory_item_id     := l_mtl_rec.inventory_item_id;
            l_mmti_rec.organization_id       := l_mtl_rec.organization_id;
            IF (l_mtl_rec.line_type = gme_common_pvt.g_line_type_ing) THEN
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('Ing so we will create a reservation');
              END IF;
              IF (l_mtl_rec.reservable_type <> 1) THEN
              	l_msg_name := 'GME_MIG_ITEM_NOT_RESV_ENABLED';
        	RAISE defined_error;
      	      END IF;
              IF (l_mtl_rec.phantom_type = 0) THEN
                l_mtl_dtl_rec.material_detail_id        := l_mtl_rec.material_detail_id;
                l_mtl_dtl_rec.batch_id                  := l_mtl_rec.batch_id;
                l_mtl_dtl_rec.formulaline_id            := l_mtl_rec.formulaline_id;
                l_mtl_dtl_rec.line_no                   := l_mtl_rec.line_no;
                l_mtl_dtl_rec.item_id                   := l_mtl_rec.item_id;
                l_mtl_dtl_rec.line_type                 := l_mtl_rec.line_type;
                l_mtl_dtl_rec.plan_qty                  := l_mtl_rec.plan_qty;
                l_mtl_dtl_rec.item_um                   := l_mtl_rec.item_um;
                l_mtl_dtl_rec.item_um2                  := l_mtl_rec.item_um2;
                l_mtl_dtl_rec.actual_qty                := l_mtl_rec.actual_qty;
                l_mtl_dtl_rec.release_type              := l_mtl_rec.release_type;
                l_mtl_dtl_rec.scrap_factor              := l_mtl_rec.scrap_factor;
                l_mtl_dtl_rec.scale_type                := l_mtl_rec.scale_type;
                l_mtl_dtl_rec.phantom_type              := l_mtl_rec.phantom_type;
                l_mtl_dtl_rec.cost_alloc                := l_mtl_rec.cost_alloc;
                l_mtl_dtl_rec.alloc_ind                 := l_mtl_rec.alloc_ind;
                l_mtl_dtl_rec.cost                      := l_mtl_rec.cost;
                l_mtl_dtl_rec.text_code                 := l_mtl_rec.text_code;
                l_mtl_dtl_rec.phantom_id                := l_mtl_rec.phantom_id;
                l_mtl_dtl_rec.rounding_direction        := l_mtl_rec.rounding_direction;
                l_mtl_dtl_rec.creation_date             := l_mtl_rec.creation_date;
                l_mtl_dtl_rec.created_by                := l_mtl_rec.created_by;
                l_mtl_dtl_rec.last_update_date          := l_mtl_rec.last_update_date;
                l_mtl_dtl_rec.last_updated_by           := l_mtl_rec.last_updated_by;
                l_mtl_dtl_rec.last_update_login         := l_mtl_rec.last_update_login;
                l_mtl_dtl_rec.scale_rounding_variance   := l_mtl_rec.scale_rounding_variance;
                l_mtl_dtl_rec.scale_multiple            := l_mtl_rec.scale_multiple;
                l_mtl_dtl_rec.contribute_yield_ind      := l_mtl_rec.contribute_yield_ind;
                l_mtl_dtl_rec.contribute_step_qty_ind   := l_mtl_rec.contribute_step_qty_ind;
                l_mtl_dtl_rec.wip_plan_qty              := l_mtl_rec.wip_plan_qty;
                l_mtl_dtl_rec.original_qty              := l_mtl_rec.original_qty;
                l_mtl_dtl_rec.by_product_type           := l_mtl_rec.by_product_type;
                l_mtl_dtl_rec.backordered_qty           := l_mtl_rec.backordered_qty;
                l_mtl_dtl_rec.dispense_ind              := l_mtl_rec.dispense_ind;
                l_mtl_dtl_rec.dtl_um                    := l_mtl_rec.dtl_um;
                l_mtl_dtl_rec.inventory_item_id         := l_mtl_rec.inventory_item_id;
                l_mtl_dtl_rec.locator_id                := l_mtl_rec.locator_id;
                l_mtl_dtl_rec.material_requirement_date := l_mtl_rec.material_requirement_date;
                l_mtl_dtl_rec.move_order_line_id        := l_mtl_rec.move_order_line_id;
                l_mtl_dtl_rec.organization_id           := l_mtl_rec.organization_id;
                l_mtl_dtl_rec.original_primary_qty      := l_mtl_rec.original_primary_qty;
                l_mtl_dtl_rec.phantom_line_id           := l_mtl_rec.phantom_line_id;
                l_mtl_dtl_rec.revision                  := l_mtl_rec.revision;
                l_mtl_dtl_rec.subinventory              := l_mtl_rec.subinventory;
                IF (l_mtl_rec.revision_qty_control_code = 2) THEN
                  l_mtl_dtl_rec.revision := get_latest_revision(p_organization_id => l_mtl_rec.organization_id, p_inventory_item_id => l_mtl_rec.inventory_item_id);
                  IF (l_mtl_dtl_rec.revision IS NULL) THEN
                    l_msg_name := 'GME_MIG_REVISION_NOT_FOUND';
              	    RAISE defined_error;
                  END IF;
                ELSE
                  l_mtl_dtl_rec.revision := NULL;
                END IF;
                IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line('After defaulting ing');
                END IF;
                IF (NVL(l_txns_tbl(i).location, l_def_location) <> l_def_location) THEN
                  get_locator(p_location        => l_txns_tbl(i).location,
                              p_whse_code       => l_txns_tbl(i).whse_code,
                              x_organization_id => l_org_id,
                              x_locator_id      => l_locator_id,
                              x_subinventory    => l_subinventory);
                END IF;
                IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line('Three locator_id = '||l_locator_id||' subinventory = '||l_subinventory||' org_id = '||l_org_id);
                END IF;
                IF (l_subinventory IS NULL) THEN
                  get_subinventory(p_whse_code       => l_txns_tbl(i).whse_code,
                                   x_subinventory    => l_subinventory,
                                   x_organization_id => l_org_id);
                END IF;
                /* If this txn is in a different org than the batch org then do a issue and receipt */
                IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line('Four l_subinventory = '||l_subinventory||' l_org_id = '||l_org_id||' l_mmti_rec.organization_id = '||l_mmti_rec.organization_id);
                  gme_debug.put_line('creating issue/receipt from org = '||l_org_id||' to org = '||l_mmti_rec.organization_id);
                END IF;
                IF (l_org_id <> l_mmti_rec.organization_id) THEN
                  /* Create a misc issue in l_org_id and a receipt in l_mmti_rec.organization_id */
                  l_mmti_rec.primary_quantity               := ROUND(ABS(l_txns_tbl(i).trans_qty),5);
                  l_mmti_rec.reason_id                      := get_reason(l_txns_tbl(i).reason_code);
                  l_mmti_rec.secondary_transaction_quantity := ROUND(ABS(l_txns_tbl(i).trans_qty2),5);
                  l_mmti_rec.secondary_uom_code             := l_mtl_rec.secondary_uom_code;
                  IF (l_mtl_rec.revision_qty_control_code = 2) THEN
                    l_mmti_rec.revision := get_latest_revision(p_organization_id => l_mtl_rec.organization_id, p_inventory_item_id => l_mtl_rec.inventory_item_id);
                    IF (l_mmti_rec.revision IS NULL) THEN
              	      l_msg_name := 'GME_MIG_REVISION_NOT_FOUND';
              	      RAISE defined_error;
                    END IF;
                  ELSE
                    l_mmti_rec.revision := NULL;
                  END IF;
                  check_date(p_organization_id => l_mtl_rec.organization_id,
                             p_date            => l_txns_tbl(i).trans_date,
                             x_date            => l_date,
                             x_return_status   => l_return_status);
                  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                    l_msg_name := 'GME_NO_OPEN_PERIODS_TXN';
                    RAISE defined_error;
                  END IF;
                  l_mmti_rec.transaction_date := l_date;
                  SELECT mtl_material_transactions_s.NEXTVAL INTO gme_common_pvt.g_transaction_header_id FROM DUAL;
                  IF (g_debug <= gme_debug.g_log_statement) THEN
                    gme_debug.put_line('Transaction header ID for reservation is '||gme_common_pvt.g_transaction_header_id);
                  END IF;
                  l_in_subinventory := l_subinventory;
                  create_issue_receipt(p_curr_org_id       => l_org_id,
                                       p_inventory_item_id => l_mtl_rec.inventory_item_id,
                                       p_txn_rec           => l_txns_tbl(i),
                                       p_mmti_rec          => l_mmti_rec,
                                       p_item_no           => l_mtl_rec.item_no,
                                       p_subinventory      => l_in_subinventory,
                                       p_locator_id        => l_locator_id,
                                       p_batch_org_id      => l_mmti_rec.organization_id,
                                       x_subinventory      => l_subinventory,
                                       x_locator_id        => l_locator_id,
                                       x_lot_number        => l_lot_number,
                                       x_return_status     => l_return_status);
                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE expected_error;
                  END IF;
                  gme_api_pub.save_batch(p_header_id    => gme_common_pvt.g_transaction_header_id,
                                         p_table        => gme_common_pvt.g_interface_table,
                                         p_commit       => FND_API.G_FALSE,
                                         x_return_status => l_return_status);
                  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                    l_msg_name := 'GME_MIG_INV_TRANSFER_FAIL';
                    RAISE create_txn_rsv_pp_err;
                  END IF;
                ELSE
                  IF (g_debug <= gme_debug.g_log_statement) THEN
                    gme_debug.put_line('No transfer for this reservation needed');
                  END IF;
                  IF (l_subinventory IS NOT NULL) THEN
                    IF NOT (gme_common_pvt.check_subinventory(p_organization_id   => l_mtl_rec.organization_id
                                                             ,p_subinventory      => l_subinventory
                                                             ,p_inventory_item_id => l_mtl_rec.inventory_item_id
                                                             ,p_restrict_subinv   => l_mtl_rec.restrict_subinventories_code)) THEN
                      l_subinventory := NULL;
                      l_locator_id   := NULL;
                      l_msg_name := 'GME_MIG_SUBINV_NOT_FOUND';
                      RAISE defined_error;
                    END IF;
                    get_subinv_locator_type(p_subinventory     => l_subinventory,
                                            p_organization_id  => l_mtl_rec.organization_id,
                                            x_locator_type     => l_sub_loc_type);
                  ELSE
                    l_msg_name := 'GME_MIG_SUBINV_NOT_FOUND';
                    RAISE defined_error;
                  END IF;
                  l_eff_loc_control := gme_common_pvt.eff_locator_control(p_organization_id   => l_mtl_rec.organization_id,
                                                                          p_subinventory      => l_subinventory,
                                                                          p_inventory_item_id => l_mtl_rec.inventory_item_id,
                                                                          p_org_control       => gme_common_pvt.g_org_locator_control,
                                                                          p_sub_control       => l_sub_loc_type,
                                                                          p_item_control      => NVL(l_mtl_rec.location_control_code,1),
                                                                          p_item_loc_restrict => l_mtl_rec.restrict_locators_code,
                                                                          p_org_neg_allowed   => gme_common_pvt.g_allow_neg_inv,
                                                                          p_action            => 1);
                  IF (l_eff_loc_control = 1) THEN
                    l_locator_id := NULL;
                  ELSE
                    IF (l_locator_id IS NULL AND NVL(l_txns_tbl(i).location, l_def_location) <> l_def_location) THEN
                      create_locator(p_location	       => l_txns_tbl(i).location,
                                     p_organization_id   => l_mtl_rec.organization_id,
                                     p_subinventory_code => l_subinventory,
                                     x_location_id       => l_locator_id,
                                     x_failure_count     => l_failure_count);
                    END IF;
                  END IF;
                  IF (l_locator_id IS NOT NULL) THEN
                    IF NOT (Gme_Common_Pvt.check_locator
                                (p_organization_id        => l_mtl_rec.organization_id
                                ,p_locator_id             => l_locator_id
                                ,p_subinventory           => l_subinventory
                                ,p_inventory_item_id      => l_mtl_rec.inventory_item_id
                                ,p_org_control            => Gme_Common_Pvt.g_org_locator_control
                                ,p_sub_control            => l_sub_loc_type
                                ,p_item_control           => NVL(l_mtl_rec.location_control_code,1)
                                ,p_item_loc_restrict      => l_mtl_rec.restrict_locators_code
                                ,p_org_neg_allowed        => Gme_Common_Pvt.g_allow_neg_inv
                                ,p_txn_action_id          => 1)) THEN
                       l_locator_id := NULL;
                       l_msg_name := 'GME_MIG_LOCATOR_NOT_FOUND';
                       RAISE defined_error;
                    END IF;
                  END IF;
                  IF (l_mtl_rec.lot_control_code <> 2) THEN
                    IF (NVL(l_txns_tbl(i).lot_id,0) > 0) THEN
                      l_msg_name := 'GME_MIG_ITEM_NOT_LOT_ENABLED';
          	      RAISE defined_error;
                    END IF;
                  ELSE
                    IF NVL(l_txns_tbl(i).lot_id, 0) = 0 THEN
                      l_msg_name := 'GME_MIG_ITEM_LOT_ENABLED';
                      RAISE defined_error;
                    END IF;
                  END IF;
                  IF (g_debug <= gme_debug.g_log_statement) THEN
                    gme_debug.put_line('Lot control is for this reservation = '||l_mtl_rec.lot_control_code);
                  END IF;
                  IF (l_mtl_rec.lot_control_code = 2) THEN
                    inv_opm_lot_migration.get_odm_lot(p_migration_run_id  => g_migration_run_id,
                                                      p_item_id           => l_txns_tbl(i).item_id,
                                                      p_lot_id	          => l_txns_tbl(i).lot_id,
                                                      p_whse_code	  => l_txns_tbl(i).whse_code,
                                                      p_orgn_code	  => NULL,
                                                      p_location	  => l_txns_tbl(i).location,
                                                      p_commit	          => fnd_api.g_true,
                                                      x_lot_number	  => l_lot_number,
                                                      x_parent_lot_number => l_parent_lot_no,
                                                      x_failure_count	  => l_failure_count);
                    IF (l_failure_count > 0 OR l_lot_number IS NULL) THEN
                      l_msg_name := 'GME_MIG_LOT_NOT_FOUND';
                      RAISE defined_error;
                    END IF;
                  END IF;
                END IF;
                IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line('Lot is '||l_lot_number);
                END IF;
                l_mtl_dtl_rec.revision := l_mmti_rec.revision;
                l_new_data := gme_common_pvt.g_organization_code||'->'||l_mtl_rec.item_no||'->'||l_mmti_rec.revision||'->'||l_subinventory||'->'||l_locator_id||'->'||l_lot_number||'->'||ABS(l_txns_tbl(i).trans_qty)||'->'||l_mtl_rec.primary_uom_code;
                IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line('Creating reservation with '||l_new_data);
                END IF;
                gme_reservations_pvt.create_material_reservation(p_matl_dtl_rec  => l_mtl_dtl_rec,
                                                                 p_resv_qty      => ABS(l_txns_tbl(i).trans_qty),
                                                                 p_sec_resv_qty  => ABS(l_txns_tbl(i).trans_qty2),
                                                                 p_resv_um       => l_mtl_rec.primary_uom_code,
                                                                 p_subinventory  => l_subinventory,
                                                                 p_locator_id    => l_locator_id,
                                                                 p_lot_number    => l_lot_number,
                                                                 x_return_status => l_return_status);
                IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                  l_msg_name := 'GME_CREATE_RESV_FAIL';
                  RAISE create_txn_rsv_pp_err;
                END IF;
              END IF;
            ELSE /* products and byproducts create pending product lots */
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('Creating pending product lot');
              END IF;
              l_mtl_dtl_rec.material_requirement_date := l_mtl_rec.material_requirement_date;
              l_mtl_dtl_rec.organization_id           := l_mtl_rec.organization_id;
              l_mtl_dtl_rec.inventory_item_id         := l_mtl_rec.inventory_item_id;
              l_mtl_dtl_rec.batch_id                  := l_mtl_rec.batch_id;
              l_mtl_dtl_rec.material_detail_id        := l_mtl_rec.material_detail_id;
              l_mtl_dtl_rec.dtl_um                    := l_mtl_rec.dtl_um;
              l_mtl_dtl_rec.plan_qty                  := l_mtl_rec.plan_qty;
              IF (l_mtl_rec.lot_control_code <> 2) THEN
              	l_msg_name := 'GME_MIG_ITEM_NOT_LOT_ENABLED';
        	RAISE defined_error;
              ELSE
              	IF (NVL(l_txns_tbl(i).lot_id, 0) = 0) THEN
              	  l_msg_name := 'GME_MIG_ITEM_LOT_ENABLED';
        	  RAISE defined_error;
              	END IF;
      	      END IF;
              -- create pend prod lots
              IF (l_mtl_rec.revision_qty_control_code = 2) THEN
                l_plot_in_rec.revision := get_latest_revision(p_organization_id => l_mtl_rec.organization_id, p_inventory_item_id => l_mtl_rec.inventory_item_id);
              ELSE
                l_plot_in_rec.revision := NULL;
              END IF;
              OPEN Cur_lot_mst(l_txns_tbl(i).lot_id);
              FETCH Cur_lot_mst INTO l_lot_no, l_sublot_no;
              CLOSE Cur_lot_mst;
              inv_opm_lot_migration.get_odm_lot(p_migration_run_id  => g_migration_run_id,
                                                p_inventory_item_id => l_mtl_dtl_rec.inventory_item_id,
                                                p_lot_no	    => l_lot_no,
                                                p_sublot_no         => l_sublot_no,
                                                p_organization_id   => l_mtl_dtl_rec.organization_id,
                                                p_locator_id	    => NULL,
                                                p_commit	    => fnd_api.g_true,
                                                x_lot_number	    => l_lot_number,
                                                x_parent_lot_number => l_parent_lot_no,
                                                x_failure_count	    => l_failure_count);
              IF (l_failure_count > 0 OR l_lot_number IS NULL) THEN
                l_msg_name := 'GME_MIG_LOT_NOT_FOUND';
                RAISE defined_error;
              END IF;
              l_plot_in_rec.lot_number := l_lot_number;
              IF (l_mtl_rec.primary_uom_code <> l_mtl_rec.dtl_um) THEN
                l_plot_in_rec.quantity := inv_convert.inv_um_convert(item_id         => l_mtl_rec.inventory_item_id
                                                                    ,lot_number      => l_plot_in_rec.lot_number
                                                                    ,organization_id => l_mtl_rec.organization_id
                                                                    ,PRECISION       => gme_common_pvt.g_precision
                                                                    ,from_quantity   => ABS(l_txns_tbl(i).trans_qty)
                                                                    ,from_unit       => l_mtl_rec.primary_uom_code
                                                                    ,to_unit         => l_mtl_rec.dtl_um
                                                                    ,from_name       => NULL
                                                                    ,to_name         => NULL);
                IF (l_plot_in_rec.quantity < 0) THEN
                  RAISE uom_conversion_fail;
                END IF;
              ELSE
                l_plot_in_rec.quantity := ABS(l_txns_tbl(i).trans_qty);
              END IF;
              l_plot_in_rec.secondary_quantity := l_txns_tbl(i).trans_qty2;
              l_plot_in_rec.reason_id          := get_reason(l_txns_tbl(i).reason_code);
              l_plot_in_rec.sequence           := NULL;
              l_new_data := gme_common_pvt.g_organization_code||'->'||l_mtl_rec.item_no||'->'||l_plot_in_rec.revision||'->'||l_plot_in_rec.lot_number||'->'||l_plot_in_rec.quantity||'->'||l_mtl_dtl_rec.dtl_um;
              IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line('Creating pending product lot with '||l_new_data);
              END IF;
              gme_api_pub.create_pending_product_lot(p_api_version               => 2.0,
                                                     p_validation_level          => gme_common_pvt.g_max_errors,
                                                     p_init_msg_list            => fnd_api.g_false,
                                                     p_commit                   => fnd_api.g_false,
                                                     x_message_count            => l_msg_cnt,
                                                     x_message_list             => l_msg_data,
                                                     x_return_status            => l_return_status,
                                                     p_batch_header_rec         => l_batch_hdr,
                                                     p_org_code                 => gme_common_pvt.g_organization_code,
                                                     p_create_lot               => fnd_api.g_false,
                                                     p_generate_lot             => fnd_api.g_false,
                                                     p_generate_parent_lot      => fnd_api.g_false,
                                                     p_material_detail_rec      => l_mtl_dtl_rec,
                                                     p_expiration_date          => NULL,
                                                     p_pending_product_lots_rec => l_plot_in_rec,
                                                     x_pending_product_lots_rec => l_plot_out_rec);
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              	l_msg_name := 'GME_CREATE_PPLOT_FAIL';
                RAISE create_txn_rsv_pp_err;
              END IF;
      	    END IF;
	  END IF;
	END IF; /* IF NOT(l_mtl_rec.line_type = gme_common_pvt.g_line_type_ing AND l_mtl_rec.phantom_type IN (gme_common_pvt.g_auto_phantom, gme_common_pvt.g_manual_phantom)) THEN */
        UPDATE gme_batch_txns_mig
        SET migrated_ind = 1
        WHERE trans_id = l_txns_tbl(i).trans_id;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line('Done transaction');
        END IF;
        COMMIT;
      EXCEPTION
        WHEN setup_failed OR batch_fetch_err THEN
          gme_common_pvt.count_and_get(x_count  => l_msg_cnt
                                      ,x_data   => l_msg_data);
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_TXNS_MIG_FAILED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'MSG',
                      p_param2              => l_msg_data);
          ROLLBACK;
        WHEN expected_error THEN
          l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
          l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||to_char(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
          gme_common_pvt.count_and_get(x_count  => l_msg_cnt
                                      ,x_data   => l_msg_data);
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_GENERAL_TXN_FAIL',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'MSG',
                      p_param2              => l_msg_data,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data);
          ROLLBACK;
      	WHEN defined_error THEN
      	  l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
      	  l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||to_char(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => l_msg_name,
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'TRANS_ID',
                      p_param2              => l_txns_tbl(i).trans_id,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data);
          ROLLBACK;
        WHEN uom_conversion_fail THEN
      	  l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
      	  l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||TO_CHAR(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_MIG_UOM_CONV_FAIL',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'TRANS_ID',
                      p_param2              => l_txns_tbl(i).trans_id,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data,
                      p_token4              => 'FROM_UOM',
                      p_param4              => l_mtl_rec.primary_uom_code,
                      p_token5              => 'TO_UOM',
                      p_param5              => l_mtl_rec.dtl_um);
          ROLLBACK;
        WHEN create_txn_rsv_pp_err THEN
          gme_common_pvt.count_and_get(p_encoded => FND_API.G_FALSE
                                      ,x_count  => l_msg_cnt
                                      ,x_data   => l_msg_data);
      	  l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
      	  l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||TO_CHAR(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => l_msg_name,
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'TRANS_ID',
                      p_param2              => l_txns_tbl(i).trans_id,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data,
                      p_token4              => 'MSG',
                      p_param4              => l_msg_data,
                      p_token5              => 'NEW_DATA',
                      p_param5              => l_new_data);
          ROLLBACK;
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
          l_txn_data := l_mtl_rec.item_no||'->'||l_txns_tbl(i).whse_code||'->'||l_txns_tbl(i).location||'->'||
          l_txns_tbl(i).lot_id||'->'||l_txns_tbl(i).trans_qty||'->'||l_mtl_rec.primary_uom_code||'->'||TO_CHAR(l_txns_tbl(i).trans_date, 'DD-MON-YYYY HH24:MI:SS');
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_GENERAL_TXN_FAIL',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => l_txns_tbl(i).plant_code||'-'||l_txns_tbl(i).new_batch_no,
                      p_token2              => 'MSG',
                      p_param2              => SQLERRM,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data);
          ROLLBACK;
      END;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END create_txns_reservations;

  PROCEDURE create_issue_receipt(p_curr_org_id       IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_txn_rec           IN Cur_get_txns%ROWTYPE,
                                 p_mmti_rec          IN mtl_transactions_interface%ROWTYPE,
                                 p_item_no           IN VARCHAR2,
                                 p_subinventory      IN VARCHAR2,
                                 p_locator_id        IN NUMBER,
                                 p_batch_org_id      IN NUMBER,
                                 x_subinventory      OUT NOCOPY VARCHAR2,
                                 x_locator_id        OUT NOCOPY NUMBER,
                                 x_lot_number        OUT NOCOPY VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2) IS
    l_api_name            VARCHAR2(30) := 'create_issue_receipt';
    l_organization_code   VARCHAR2(3);
    l_org                 VARCHAR2(3);
    l_return_status       VARCHAR2(1);
    l_def_location        VARCHAR2(100) := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
    l_lot_number          VARCHAR2(80);
    l_parent_lot_no       VARCHAR2(80);
    l_msg_name            VARCHAR2(32);
    l_msg_data            VARCHAR2(2000);
    l_txn_data            VARCHAR2(2000);
    l_msg_cnt             NUMBER;
    l_allow_neg_inv       NUMBER;
    l_org_loc_control     NUMBER;
    l_eff_loc_control     NUMBER;
    l_sub_loc_type        NUMBER;
    l_locator_id          NUMBER;
    l_failure_count       NUMBER;
    l_date                DATE;
    CURSOR Cur_item_dtl(v_organization_id NUMBER, v_inventory_item_id NUMBER) IS
      SELECT i.mtl_transactions_enabled_flag, i.reservable_type, i.segment1, i.lot_control_code,
             i.revision_qty_control_code, i.primary_uom_code, i.secondary_uom_code, i.restrict_subinventories_code,
             NVL(i.location_control_code,1) location_control_code, i.restrict_locators_code, i.segment1 item_no
      FROM   mtl_system_items_b i
      WHERE  i.organization_id = v_organization_id
             AND i.inventory_item_id = v_inventory_item_id;
    CURSOR Cur_new_loc(v_organization_id NUMBER, v_subinventory VARCHAR2, v_location VARCHAR2) IS
      SELECT m.inventory_location_id locator_id
      FROM   mtl_item_locations m
      WHERE  m.segment1 = v_location
             AND m.organization_id = v_organization_id
             AND m.subinventory_code = v_subinventory;
    CURSOR Cur_get_org_params(v_org_id NUMBER) IS
      SELECT negative_inv_receipt_code, stock_locator_control_code, organization_code
      FROM   mtl_parameters
      WHERE organization_id = v_org_id;
    l_item_rec        Cur_item_dtl%ROWTYPE;
    l_issue_rec       mtl_transactions_interface%ROWTYPE;
    l_issue_lot_rec   mtl_transaction_lots_interface%ROWTYPE;
    l_receipt_rec     mtl_transactions_interface%ROWTYPE;
    l_receipt_lot_rec mtl_transaction_lots_interface%ROWTYPE;
    defined_error      EXCEPTION;
    expected_error     EXCEPTION;
    item_not_defined   EXCEPTION;
    no_open_period_err EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Moving from org = '||p_curr_org_id||' to org = '||p_batch_org_id);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN Cur_get_org_params(p_curr_org_id);
    FETCH Cur_get_org_params INTO l_allow_neg_inv, l_org_loc_control, l_organization_code;
    CLOSE Cur_get_org_params;
    l_txn_data := p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||p_txn_rec.trans_qty||'->'||p_txn_rec.trans_um||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('TXN Data = '||l_txn_data);
    END IF;
    gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'GME_MIG_INV_TRANSFER',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'GME',
                  p_token1              => 'BATCH_NO',
                  p_param1              => p_txn_rec.plant_code||'-'||p_txn_rec.new_batch_no,
                  p_token2              => 'TRANS_ID',
                  p_param2              => p_txn_rec.trans_id,
                  p_token3              => 'TXN_DATA',
                  p_param3              => l_txn_data,
                  p_token4              => 'ORG',
                  p_param4              => l_organization_code);
    OPEN Cur_item_dtl(p_curr_org_id, p_inventory_item_id);
    FETCH Cur_item_dtl INTO l_item_rec;
    IF (Cur_item_dtl%NOTFOUND) THEN
      CLOSE Cur_item_dtl;
      l_org := l_organization_code;
      RAISE item_not_defined;
    END IF;
    CLOSE Cur_item_dtl;
    IF (l_item_rec.mtl_transactions_enabled_flag <> 'Y') THEN
      l_msg_name := 'GME_MIG_ITEM_NOT_TXNS_ENABLED';
      RAISE defined_error;
    END IF;
    IF (l_item_rec.lot_control_code <> 2) THEN
      IF (NVL(p_txn_rec.lot_id,0) > 0) THEN
        l_msg_name := 'GME_MIG_ITEM_NOT_LOT_ENABLED';
        RAISE defined_error;
      END IF;
    ELSE
      IF NVL(p_txn_rec.lot_id, 0) = 0 THEN
        l_msg_name := 'GME_MIG_ITEM_LOT_ENABLED';
        RAISE defined_error;
      END IF;
    END IF;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Before subinventory');
    END IF;
    /* Validate if sub found is valid in this org */
    IF NOT (gme_common_pvt.check_subinventory(p_organization_id   => p_curr_org_id
                                             ,p_subinventory      => p_subinventory
                                             ,p_inventory_item_id => p_inventory_item_id
                                             ,p_restrict_subinv   => l_item_rec.restrict_subinventories_code)) THEN
      l_msg_name := 'GME_MIG_SUBINV_NOT_FOUND';
      RAISE defined_error;
    END IF;
    get_subinv_locator_type(p_subinventory     => p_subinventory,
                            p_organization_id  => p_curr_org_id,
                            x_locator_type     => l_sub_loc_type);
    l_eff_loc_control := gme_common_pvt.eff_locator_control(p_organization_id   => p_curr_org_id,
                                                            p_subinventory      => p_subinventory,
                                                            p_inventory_item_id => p_inventory_item_id,
                                                            p_org_control       => l_org_loc_control,
                                                            p_sub_control       => l_sub_loc_type,
                                                            p_item_control      => NVL(l_item_rec.location_control_code,1),
                                                            p_item_loc_restrict => l_item_rec.restrict_locators_code,
                                                            p_org_neg_allowed   => l_allow_neg_inv,
                                                            p_action            => 1);
    IF (l_eff_loc_control = 1) THEN
      l_locator_id := NULL;
    ELSE
      IF (p_locator_id IS NULL AND NVL(p_txn_rec.location, l_def_location) <> l_def_location) THEN
        create_locator(p_location	   => p_txn_rec.location,
                       p_organization_id   => p_curr_org_id,
                       p_subinventory_code => p_subinventory,
                       x_location_id       => l_locator_id,
                       x_failure_count     => l_failure_count);
      ELSE
      	l_locator_id := p_locator_id;
      END IF;
    END IF;
    IF (l_locator_id IS NOT NULL) THEN
      IF NOT (Gme_Common_Pvt.check_locator
                    (p_organization_id        => p_curr_org_id
                    ,p_locator_id             => l_locator_id
                    ,p_subinventory           => p_subinventory
                    ,p_inventory_item_id      => p_inventory_item_id
                    ,p_org_control            => l_org_loc_control
                    ,p_sub_control            => l_sub_loc_type
                    ,p_item_control           => NVL(l_item_rec.location_control_code,1)
                    ,p_item_loc_restrict      => l_item_rec.restrict_locators_code
                    ,p_org_neg_allowed        => l_allow_neg_inv
                    ,p_txn_action_id          => 1)) THEN
        l_locator_id := NULL;
        l_msg_name := 'GME_MIG_LOCATOR_NOT_FOUND';
        RAISE defined_error;
      END IF;
    END IF;
    IF (l_item_rec.lot_control_code = 2) THEN
      inv_opm_lot_migration.get_odm_lot(p_migration_run_id    => g_migration_run_id,
                                        p_item_id             => p_txn_rec.item_id,
                                        p_lot_id	      => p_txn_rec.lot_id,
                                        p_whse_code	      => p_txn_rec.whse_code,
                                        p_orgn_code	      => NULL,
                                        p_location	      => p_txn_rec.location,
                                        p_commit	      => fnd_api.g_true,
                                        x_lot_number	      => l_lot_number,
                                        x_parent_lot_number   => l_parent_lot_no,
                                        x_failure_count       => l_failure_count);
      IF (l_failure_count > 0 OR l_lot_number IS NULL) THEN
      	l_msg_name := 'GME_MIG_LOT_NOT_FOUND';
        RAISE defined_error;
      END IF;
    END IF;
    get_distribution_account(p_subinventory  => p_subinventory,
                             p_org_id        => p_curr_org_id,
                             x_dist_acct_id  => l_issue_rec.distribution_account_id);
    check_date(p_organization_id => p_curr_org_id,
               p_date            => p_mmti_rec.transaction_date,
               x_date            => l_date,
               x_return_status   => l_return_status);
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_txn_data := l_organization_code||'->'||p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||
      p_txn_rec.trans_qty||'->'||l_item_rec.primary_uom_code||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
      gme_common_pvt.log_message(p_product_code => 'INV', p_message_code => 'INV_NO_OPEN_PERIOD');
      RAISE no_open_period_err;
    ELSE
      l_issue_rec.transaction_date := l_date;
    END IF;
    /* Create a misc issue in original org/sub/loc and then a reciept in final org/sub/loc */
    SELECT mtl_material_transactions_s.NEXTVAL INTO
    l_issue_rec.transaction_interface_id FROM DUAL;
    l_issue_rec.transaction_header_id          := gme_common_pvt.g_transaction_header_id;
    l_issue_rec.source_code                    := 'OPM_GME_MIGRATION';
    l_issue_rec.source_line_id                 := p_txn_rec.trans_id;
    l_issue_rec.source_header_id               := p_txn_rec.doc_id;
    l_issue_rec.inventory_item_id              := p_inventory_item_id;
    l_issue_rec.organization_id                := p_curr_org_id;
    l_issue_rec.subinventory_code              := p_subinventory;
    l_issue_rec.locator_id                     := l_locator_id;
    l_issue_rec.transaction_type_id            := 32; --Misc. Issue
    l_issue_rec.transaction_action_id          := 1;
    l_issue_rec.transaction_source_type_id     := 13;
    l_issue_rec.transaction_source_id          := p_txn_rec.trans_id;
    l_issue_rec.transaction_source_name        := 'GME Transaction Migration';
    l_issue_rec.transaction_quantity           := -1 * ABS(p_mmti_rec.primary_quantity);
    l_issue_rec.transaction_uom                := l_item_rec.primary_uom_code;
    l_issue_rec.reason_id                      := p_mmti_rec.reason_id;
    l_issue_rec.secondary_transaction_quantity := -1 * ABS(p_mmti_rec.secondary_transaction_quantity);
    l_issue_rec.secondary_uom_code             := p_mmti_rec.secondary_uom_code;
    l_issue_rec.process_flag                   := 1;
    l_issue_rec.transaction_mode               := 2;
    l_issue_rec.transaction_batch_id           := gme_common_pvt.g_transaction_header_id;
    l_issue_rec.transaction_batch_seq          := 0;
    l_issue_rec.last_update_date               := p_txn_rec.last_update_date;
    l_issue_rec.last_updated_by                := p_txn_rec.last_updated_by;
    l_issue_rec.creation_date                  := p_txn_rec.creation_date;
    l_issue_rec.created_by                     := p_txn_rec.created_by;
    l_issue_rec.revision                       := p_mmti_rec.revision;
    IF (l_item_rec.lot_control_code = 2) THEN
      l_issue_lot_rec.transaction_interface_id       := l_issue_rec.transaction_interface_id;
      l_issue_lot_rec.last_update_date               := p_txn_rec.last_update_date;
      l_issue_lot_rec.last_updated_by                := p_txn_rec.last_updated_by;
      l_issue_lot_rec.creation_date                  := p_txn_rec.creation_date;
      l_issue_lot_rec.created_by                     := p_txn_rec.created_by;
      l_issue_lot_rec.lot_number                     := l_lot_number;
      l_issue_lot_rec.transaction_quantity           := -1 * ABS(p_mmti_rec.primary_quantity);
      l_issue_lot_rec.secondary_transaction_quantity := -1 * ABS(p_mmti_rec.secondary_transaction_quantity);
    END IF;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Issue record '||l_issue_rec.organization_id||'->'||p_item_no||'->'||l_issue_rec.subinventory_code||'->'||
      l_issue_rec.locator_id||'->'||l_lot_number||'->'||l_issue_rec.transaction_quantity||'->'||l_issue_rec.transaction_uom||'->'||to_char(l_issue_rec.transaction_date, 'DD-MON-YYYY HH24:MI:SS'));
    END IF;
    insert_interface_recs(p_mti_rec       => l_issue_rec,
                          p_mtli_rec      => l_issue_lot_rec,
                          x_return_status => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    	RAISE expected_error;
    END IF;
    /* Now start the receipt in the batch org */
    OPEN Cur_item_dtl(p_batch_org_id, p_inventory_item_id);
    FETCH Cur_item_dtl INTO l_item_rec;
    IF (Cur_item_dtl%NOTFOUND) THEN
      CLOSE Cur_item_dtl;
      l_org := gme_common_pvt.g_organization_code;
      RAISE item_not_defined;
    END IF;
    CLOSE Cur_item_dtl;
    IF (l_item_rec.mtl_transactions_enabled_flag <> 'Y') THEN
      l_msg_name := 'GME_MIG_ITEM_NOT_TXNS_ENABLED';
      RAISE defined_error;
    END IF;
    IF (l_item_rec.lot_control_code <> 2) THEN
      IF (NVL(p_txn_rec.lot_id, 0) > 0) THEN
        l_msg_name := 'GME_MIG_ITEM_NOT_LOT_ENABLED';
        RAISE defined_error;
      END IF;
    ELSE
      IF NVL(p_txn_rec.lot_id, 0) = 0 THEN
        l_msg_name := 'GME_MIG_ITEM_LOT_ENABLED';
        RAISE defined_error;
      END IF;
    END IF;
    l_receipt_rec := l_issue_rec;
    check_date(p_organization_id => p_batch_org_id,
               p_date            => l_receipt_rec.transaction_date,
               x_date            => l_date,
               x_return_status   => l_return_status);
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_txn_data := gme_common_pvt.g_organization_code||'->'||p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||
      p_txn_rec.trans_qty||'->'||l_item_rec.primary_uom_code||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
      gme_common_pvt.log_message(p_product_code => 'INV', p_message_code => 'INV_NO_OPEN_PERIOD');
      RAISE no_open_period_err;
    ELSE
      l_receipt_rec.transaction_date := l_date;
    END IF;
    SELECT mtl_material_transactions_s.NEXTVAL INTO
    l_receipt_rec.transaction_interface_id FROM DUAL;
    l_receipt_rec.organization_id                := p_batch_org_id;
    /* We are creating a receipt txn in a sub which has the same name as org. This will always exist */
    BEGIN
      SELECT whse_code
      INTO   l_receipt_rec.subinventory_code
      FROM   ic_whse_mst
      WHERE  mtl_organization_id = p_batch_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_receipt_rec.subinventory_code := gme_common_pvt.g_organization_code;
    END;
    get_distribution_account(p_subinventory  => l_receipt_rec.subinventory_code,
                             p_org_id        => p_batch_org_id,
                             x_dist_acct_id  => l_receipt_rec.distribution_account_id);
    l_receipt_rec.transaction_type_id            := 42; --Misc Receipt
    l_receipt_rec.transaction_action_id          := 27;
    l_receipt_rec.transaction_quantity           := -1 * l_receipt_rec.transaction_quantity;
    l_receipt_rec.secondary_transaction_quantity := -1 * l_receipt_rec.secondary_transaction_quantity;
    get_subinv_locator_type(p_subinventory     => gme_common_pvt.g_organization_code,
                            p_organization_id  => p_batch_org_id,
                            x_locator_type     => l_sub_loc_type);
    /* Check for the eff locator control of this org */
    l_eff_loc_control := gme_common_pvt.eff_locator_control(p_organization_id   => p_batch_org_id,
                                                            p_subinventory      => l_receipt_rec.subinventory_code,
                                                            p_inventory_item_id => p_inventory_item_id,
                                                            p_org_control       => gme_common_pvt.g_org_locator_control,
                                                            p_sub_control       => l_sub_loc_type,
                                                            p_item_control      => NVL(l_item_rec.location_control_code,1),
                                                            p_item_loc_restrict => l_item_rec.restrict_locators_code,
                                                            p_org_neg_allowed   => gme_common_pvt.g_allow_neg_inv,
                                                            p_action            => 27);
    IF (l_eff_loc_control = 1) THEN
      l_locator_id := NULL;
    ELSE
      IF (NVL(p_txn_rec.location, l_def_location) <> l_def_location) THEN
        OPEN Cur_new_loc(p_batch_org_id, l_receipt_rec.subinventory_code, p_txn_rec.location);
        FETCH Cur_new_loc INTO l_receipt_rec.locator_id;
        IF (Cur_new_loc%NOTFOUND) THEN
          create_locator(p_location	     => p_txn_rec.location,
                         p_organization_id   => p_batch_org_id,
                         p_subinventory_code => l_receipt_rec.subinventory_code,
                         x_location_id       => l_receipt_rec.locator_id,
                         x_failure_count     => l_failure_count);
        END IF;
        CLOSE Cur_new_loc;
      END IF;
    END IF;
    IF (l_item_rec.lot_control_code = 2) THEN
      l_receipt_lot_rec.transaction_interface_id       := l_receipt_rec.transaction_interface_id;
      l_receipt_lot_rec.last_update_date               := p_txn_rec.last_update_date;
      l_receipt_lot_rec.last_updated_by                := p_txn_rec.last_updated_by;
      l_receipt_lot_rec.creation_date                  := p_txn_rec.creation_date;
      l_receipt_lot_rec.created_by                     := p_txn_rec.created_by;
      l_receipt_lot_rec.lot_number                     := l_lot_number;
      l_receipt_lot_rec.transaction_quantity           := l_receipt_rec.transaction_quantity;
      l_receipt_lot_rec.secondary_transaction_quantity := l_receipt_rec.secondary_transaction_quantity;
    END IF;
    IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line('Receipt record '||l_receipt_rec.organization_id||'->'||p_item_no||'->'||l_receipt_rec.subinventory_code||'->'||
      l_receipt_rec.locator_id||'->'||l_lot_number||'->'||l_receipt_rec.transaction_quantity||'->'||l_receipt_rec.transaction_uom||'->'||to_char(l_receipt_rec.transaction_date, 'DD-MON-YYYY HH24:MI:SS'));
    END IF;
    insert_interface_recs(p_mti_rec       => l_receipt_rec,
                          p_mtli_rec      => l_receipt_lot_rec,
                          x_return_status => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE expected_error;
    END IF;
    x_subinventory := l_receipt_rec.subinventory_code;
    x_locator_id   := l_receipt_rec.locator_id;
    x_lot_number   := l_receipt_lot_rec.lot_number;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  EXCEPTION
    WHEN item_not_defined THEN
      gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'INV_IC_INVALID_ITEM_ORG',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'INV',
                  p_token1              => 'ORG',
                  p_param1              => l_org,
                  p_token2              => 'ITEM',
                  p_param2              => p_item_no);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN no_open_period_err THEN
      gme_common_pvt.count_and_get(p_encoded => FND_API.G_FALSE
                                  ,x_count   => l_msg_cnt
                                  ,x_data    => l_msg_data);
      gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'GME_GENERAL_TXN_FAIL',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'GME',
                  p_token1              => 'BATCH_NO',
                  p_param1              => p_txn_rec.plant_code||'-'||p_txn_rec.new_batch_no,
                  p_token2              => 'MSG',
                  p_param2              => l_msg_data,
                  p_token3              => 'TXN_DATA',
                  p_param3              => l_txn_data);
      x_return_status := l_return_status;
    WHEN expected_error THEN
      l_txn_data := p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||
      p_txn_rec.trans_qty||'->'||l_item_rec.primary_uom_code||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
      gme_common_pvt.count_and_get(p_encoded => FND_API.G_FALSE
                                  ,x_count   => l_msg_cnt
                                  ,x_data    => l_msg_data);
      gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'GME_GENERAL_TXN_FAIL',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'GME',
                  p_token1              => 'BATCH_NO',
                  p_param1              => p_txn_rec.plant_code||'-'||p_txn_rec.new_batch_no,
                  p_token2              => 'MSG',
                  p_param2              => l_msg_data,
                  p_token3              => 'TXN_DATA',
                  p_param3              => l_txn_data);
      x_return_status := l_return_status;
    WHEN defined_error THEN
      l_txn_data := p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||p_txn_rec.trans_qty||'->'||l_item_rec.primary_uom_code||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
      gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => l_msg_name,
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'GME',
                  p_token1              => 'BATCH_NO',
                  p_param1              => p_txn_rec.plant_code||'-'||p_txn_rec.new_batch_no,
                  p_token2              => 'TRANS_ID',
                  p_param2              => p_txn_rec.trans_id,
                  p_token3              => 'TXN_DATA',
                  p_param3              => l_txn_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (g_debug <= gme_debug.g_log_unexpected) THEN
        gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
      END IF;
      l_txn_data := p_item_no||'->'||p_txn_rec.whse_code||'->'||p_txn_rec.location||'->'||p_txn_rec.lot_id||'->'||p_txn_rec.trans_qty||'->'||l_item_rec.primary_uom_code||'->'||to_char(p_txn_rec.trans_date, 'DD-MON-YYYY HH24:MI:SS');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      gma_common_logging.gma_migration_central_log
                 (p_run_id              => g_migration_run_id,
                  p_log_level           => fnd_log.level_error,
                  p_message_token       => 'GME_GENERAL_TXN_FAIL',
                  p_table_name          => 'GME_BATCH_HEADER',
                  p_context             => 'RECREATE_OPEN_BATCHES',
                  p_app_short_name      => 'GME',
                  p_token1              => 'BATCH_NO',
                  p_param1              => p_txn_rec.plant_code||'-'||p_txn_rec.new_batch_no,
                  p_token2              => 'MSG',
                  p_param2              => SQLERRM,
                  p_token3              => 'TXN_DATA',
                  p_param3              => l_txn_data);
  END create_issue_receipt;

  PROCEDURE insert_interface_recs(p_mti_rec  IN mtl_transactions_interface%ROWTYPE,
                                  p_mtli_rec IN mtl_transaction_lots_interface%ROWTYPE,
                                  x_return_status OUT NOCOPY VARCHAR2) IS
    l_mti_tbl   gme_common_pvt.mtl_tran_int_tbl;
    l_mtli_tbl  gme_common_pvt.mtl_trans_lots_inter_tbl;
    l_api_name  VARCHAR2(30) := 'insert_interface_recs';
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_mti_tbl(1)  := p_mti_rec;
    IF (p_mtli_rec.lot_number IS NOT NULL) THEN
      l_mtli_tbl(1) := p_mtli_rec;
    END IF;
    FORALL a IN 1..l_mti_tbl.COUNT
      INSERT INTO mtl_transactions_interface VALUES l_mti_tbl(a);
    FORALL b IN 1..l_mtli_tbl.COUNT
      INSERT INTO mtl_transaction_lots_interface VALUES l_mtli_tbl(b);
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (g_debug <= gme_debug.g_log_unexpected) THEN
        gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => g_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'RECREATE_OPEN_BATCHES',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
  END insert_interface_recs;

  PROCEDURE close_steps IS
    CURSOR Cur_get_steps IS
      SELECT s.batchstep_id, m.step_close_date, bm.new_batch_no, s.batchstep_no, bm.plant_code, bm.old_batch_id
      FROM   gme_batch_steps_mig m, gme_batch_steps s, gme_batch_mapping_mig bm
      WHERE  m.step_status = gme_common_pvt.g_step_closed
             AND bm.old_batch_id = m.batch_id
             AND s.batch_id = bm.new_batch_id
             AND s.batchstep_no = m.batchstep_no
             AND NOT(s.step_status = m.step_status)
             AND s.step_status = gme_common_pvt.g_step_completed
      ORDER BY s.batch_id, s.batchstep_no;
    CURSOR Cur_verify_txns(v_batchstep_id NUMBER, v_old_batch_id NUMBER) IS
      SELECT 1
      FROM gme_batch_step_items bsi, gme_material_details gmdn,
           gme_material_details gmdo, gme_batch_txns_mig txn, ic_tran_pnd itp
      WHERE bsi.batchstep_id = v_batchstep_id
      AND gmdn.material_detail_id = bsi.material_detail_id
      AND gmdo.batch_id = v_old_batch_id
      AND gmdo.line_type = gmdn.line_type
      AND gmdo.line_no = gmdn.line_no
      AND txn.batch_id = v_old_batch_id
      AND NVL(txn.migrated_ind, 0) = 0
      AND itp.trans_id = txn.trans_id
      AND itp.line_id = gmdo.material_detail_id;
    l_step_rec     gme_batch_steps%ROWTYPE;
    l_out_step_rec gme_batch_steps%ROWTYPE;
    l_msg_cnt       NUMBER;
    l_found         NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    l_api_name  VARCHAR2(30) := 'close_steps';
    step_close_fail EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    FOR get_steps IN Cur_get_steps LOOP
      BEGIN
        l_step_rec.batchstep_id := get_steps.batchstep_id;
        OPEN Cur_verify_txns(get_steps.batchstep_id, get_steps.old_batch_id);
        FETCH Cur_verify_txns INTO l_found;
        IF (Cur_verify_txns%NOTFOUND) THEN
          CLOSE Cur_verify_txns;
          gme_api_pub.close_step (p_api_version      => 2,
                                  p_validation_level => gme_common_pvt.g_max_errors,
                                  p_init_msg_list    => fnd_api.g_true,
                                  p_commit           => fnd_api.g_true,
                                  x_message_count    => l_msg_cnt,
                                  x_message_list     => l_msg_data,
                                  x_return_status    => l_return_status,
                                  p_batch_step_rec   => l_step_rec,
                                  p_delete_pending   => fnd_api.g_false,
                                  p_org_code         => NULL,
                                  p_batch_no         => NULL,
                                  x_batch_step_rec   => l_out_step_rec);
          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE step_close_fail;
          END IF;
        ELSE
          CLOSE Cur_verify_txns;
        END IF;
      EXCEPTION
        WHEN step_close_fail THEN
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_STEP_CLOSE_ERR',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_steps.plant_code||'-'||get_steps.new_batch_no,
                      p_token2              => 'STEP_NO',
                      p_param2              => get_steps.batchstep_no,
                      p_token3              => 'MSG',
                      p_param3              => l_msg_data);
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_STEP_PROCESS_UNEXP',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_steps.plant_code||'-'||get_steps.new_batch_no,
                      p_token2              => 'STEP_NO',
                      p_param2              => get_steps.batchstep_no,
                      p_token3              => 'MSG',
                      p_param3              => SQLERRM);
      END;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END close_steps;

  PROCEDURE insert_lab_lots IS
    l_api_name  VARCHAR2(30) := 'insert_lab_lots';
    CURSOR Cur_lab_lots IS
      SELECT l.*, m.organization_id, m.new_batch_no,  m.new_batch_id, m.plant_code, l.rowid
      FROM   gme_batch_mapping_mig m, gme_lab_batch_lots l
      WHERE  m.old_batch_id = l.batch_id
             AND NVL(attribute27, 'A') <> 'M';
    CURSOR Cur_item_dtl(v_organization_id NUMBER, v_inventory_item_id NUMBER) IS
      SELECT i.segment1, i.lot_control_code
      FROM   mtl_system_items_b i
      WHERE  i.organization_id = v_organization_id
             AND i.inventory_item_id = v_inventory_item_id;
    CURSOR Cur_mtl_dtl(v_material_detail_id NUMBER) IS
      SELECT d.*
      FROM   gme_material_details d
      WHERE  d.material_detail_id = v_material_detail_id;
    l_curr_batch_id   NUMBER;
    l_curr_detail_id  NUMBER;
    l_mat_detail_id   NUMBER;
    l_failure_count   NUMBER;
    l_msg_cnt         NUMBER;
    l_return_status   VARCHAR2(1);
    l_lot_number      VARCHAR2(80);
    l_parent_lot_no   VARCHAR2(80);
    l_txn_data        VARCHAR2(500);
    l_new_data        VARCHAR2(500);
    l_msg_data        VARCHAR2(2000);
    l_item_rec        Cur_item_dtl%ROWTYPE;
    l_batch_hdr       gme_batch_header%ROWTYPE;
    l_mtl_rec         gme_material_details%ROWTYPE;
    l_plot_out_rec    gme_pending_product_lots%ROWTYPE;
    l_plot_in_rec     gme_pending_product_lots%ROWTYPE;
    batch_fetch_err   EXCEPTION;
    create_pp_lot_err EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('Start procedure '||l_api_name);
    END IF;
    FOR get_lots IN Cur_lab_lots LOOP
      BEGIN
      	l_lot_number := NULL;
        l_txn_data   := NULL;
      	IF (NVL(l_curr_batch_id,0) <> NVL(get_lots.new_batch_id, -1)) THEN
      	  l_batch_hdr.batch_id := get_lots.new_batch_id;
      	  IF NOT(gme_batch_header_dbl.fetch_row(p_batch_header => l_batch_hdr,
      	                                        x_batch_header => l_batch_hdr)) THEN
      	    RAISE batch_fetch_err;
      	  END IF;
      	  l_curr_batch_id := get_lots.new_batch_id;
      	END IF;
      	IF (NVL(l_curr_detail_id,0) <> NVL(get_lots.material_detail_id, -1)) THEN
      	  l_mat_detail_id  := get_new_mat_id(p_old_mat_id => get_lots.material_detail_id, p_new_batch_id => get_lots.new_batch_id);
      	  OPEN Cur_mtl_dtl(l_mat_detail_id);
      	  FETCH Cur_mtl_dtl INTO l_mtl_rec;
      	  CLOSE Cur_mtl_dtl;
      	  l_curr_detail_id := get_lots.material_detail_id;
      	  OPEN Cur_item_dtl(l_mtl_rec.organization_id, l_mtl_rec.inventory_item_id);
      	  FETCH Cur_item_dtl INTO l_item_rec;
      	  CLOSE Cur_item_dtl;
      	END IF;
      	IF (l_item_rec.lot_control_code = 2) THEN
          inv_opm_lot_migration.get_odm_lot(p_migration_run_id    => g_migration_run_id,
                                            p_item_id             => get_lots.item_id,
                                            p_lot_id	          => get_lots.lot_id,
                                            p_whse_code	          => NULL,
                                            p_orgn_code	          => get_lots.plant_code,
                                            p_location	          => NULL,
                                            p_commit	          => fnd_api.g_true,
                                            x_lot_number	  => l_lot_number,
                                            x_parent_lot_number   => l_parent_lot_no,
                                            x_failure_count       => l_failure_count);
          IF (l_lot_number IS NOT NULL) THEN
            l_plot_in_rec.quantity           := get_lots.qty;
            l_plot_in_rec.secondary_quantity := get_lots.qty2;
            l_plot_in_rec.lot_number         := l_lot_number;
            gme_api_pub.create_pending_product_lot(p_api_version              => 2.0,
                                                   p_validation_level         => gme_common_pvt.g_max_errors,
                                                   p_init_msg_list            => fnd_api.g_false,
                                                   p_commit                   => fnd_api.g_false,
                                                   x_message_count            => l_msg_cnt,
                                                   x_message_list             => l_msg_data,
                                                   x_return_status            => l_return_status,
                                                   p_batch_header_rec         => l_batch_hdr,
                                                   p_org_code                 => NULL,
                                                   p_create_lot               => fnd_api.g_false,
                                                   p_generate_lot             => fnd_api.g_false,
                                                   p_generate_parent_lot      => fnd_api.g_false,
                                                   p_material_detail_rec      => l_mtl_rec,
                                                   p_expiration_date          => NULL,
                                                   p_pending_product_lots_rec => l_plot_in_rec,
                                                   x_pending_product_lots_rec => l_plot_out_rec);
            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              RAISE create_pp_lot_err;
            END IF;
            UPDATE gme_lab_batch_lots
            SET    attribute27 = 'M'
            WHERE  rowid = get_lots.rowid;
          END IF;
      	END IF;
      	COMMIT;
      EXCEPTION
        WHEN batch_fetch_err THEN
          gme_common_pvt.count_and_get(x_count  => l_msg_cnt
                                      ,x_data   => l_msg_data);
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_TXNS_MIG_FAILED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_lots.plant_code||'-'||get_lots.new_batch_no,
                      p_token2              => 'MSG',
                      p_param2              => l_msg_data);
          ROLLBACK;
        WHEN create_pp_lot_err THEN
          gme_common_pvt.count_and_get(p_encoded => FND_API.G_FALSE
                                      ,x_count   => l_msg_cnt
                                      ,x_data    => l_msg_data);
      	  l_txn_data := l_item_rec.segment1||'->'||get_lots.lot_id||'->'||get_lots.qty||'->'||get_lots.qty2;
      	  l_new_data := l_item_rec.segment1||'->'||l_lot_number||'->'||get_lots.qty||'->'||get_lots.qty2;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_CREATE_PPLOT_FAIL',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_lots.plant_code||'-'||get_lots.new_batch_no,
                      p_token2              => 'TRANS_ID',
                      p_param2              => l_mtl_rec.material_detail_id,
                      p_token3              => 'TXN_DATA',
                      p_param3              => l_txn_data,
                      p_token4              => 'MSG',
                      p_param4              => l_msg_data,
                      p_token5              => 'NEW_DATA',
                      p_param5              => l_new_data);
          ROLLBACK;
        WHEN OTHERS THEN
          IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line('When others in '||l_api_name||' '||SQLERRM);
          END IF;
      	  l_txn_data := l_item_rec.segment1||'->'||get_lots.lot_id||'->'||get_lots.qty||'->'||get_lots.qty2;
          gma_common_logging.gma_migration_central_log
                     (p_run_id              => g_migration_run_id,
                      p_log_level           => fnd_log.level_error,
                      p_message_token       => 'GME_TXNS_MIG_FAILED',
                      p_table_name          => 'GME_BATCH_HEADER',
                      p_context             => 'RECREATE_OPEN_BATCHES',
                      p_app_short_name      => 'GME',
                      p_token1              => 'BATCH_NO',
                      p_param1              => get_lots.plant_code||'->'||get_lots.new_batch_no||'->'||l_mtl_rec.line_type||'->'||
                                               l_mtl_rec.line_no||'->'||l_item_rec.segment1||'->'||get_lots.lot_id||'->'||get_lots.qty,
                      p_token2              => 'MSG',
                      p_param2              => SQLERRM);
          ROLLBACK;
      END;
    END LOOP;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line('End procedure '||l_api_name);
    END IF;
  END insert_lab_lots;
END gme_post_migration;

/

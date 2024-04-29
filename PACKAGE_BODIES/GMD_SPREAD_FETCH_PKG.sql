--------------------------------------------------------
--  DDL for Package Body GMD_SPREAD_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPREAD_FETCH_PKG" AS
/* $Header: GMDSPDFB.pls 120.13.12010000.5 2010/03/12 14:58:20 rnalla ship $ */

  /*##############################################################
  # NAME
  #	load_details
  # SYNOPSIS
  #	proc   load_details
  # DESCRIPTION
  #      This procedure loads the material and lot lines based on
  #      the id passed.
  # HISTORY
  #     15-SEP-06  Kapil M Bug# 5513268
  #                Added the parameter spec_id.
  ###############################################################*/

  PROCEDURE load_details (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,
  			  V_batch_id IN NUMBER,V_formula_id IN NUMBER,V_spec_id IN NUMBER  DEFAULT NULL,
  			  V_orgn_id IN NUMBER,V_update_inv_ind IN VARCHAR2,
  			  V_plant_id IN NUMBER) IS
  BEGIN
    DELETE FROM gmd_material_details_gtmp;
    DELETE FROM gmd_technical_data_gtmp;
    IF (V_sprd_id IS NOT NULL) THEN
      gmd_spread_fetch_pkg.load_spread_details(V_entity_id,V_sprd_id,V_orgn_id);
    ELSIF (V_batch_id IS NOT NULL AND V_spec_id IS NULL) THEN
      gmd_spread_fetch_pkg.load_batch_details(V_entity_id,V_batch_id,V_orgn_id,V_update_inv_ind,V_plant_id);
    ELSIF (V_formula_id IS NOT NULL AND V_spec_id IS NULL) THEN
      gmd_spread_fetch_pkg.load_formula_details(V_entity_id,V_formula_id,V_orgn_id,V_plant_id);
    ELSE
      gmd_spread_fetch_pkg.load_lcf_details(V_entity_id,V_orgn_id,V_plant_id);
    END IF;
  END load_details;

  /*##############################################################
  # NAME
  #	load_spread_details
  # SYNOPSIS
  #	proc   load_spread_details
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_spread_details  (V_entity_id IN NUMBER, V_sprd_id IN NUMBER,V_orgn_id IN NUMBER) IS
    CURSOR Cur_get_spread IS
      SELECT a.*,b.description,b.lot_control_code,b.secondary_default_ind,
             b.grade_control_flag,b.location_control_code,b.tracking_quantity_ind,c.expiration_date expiry_date,
      	     b.primary_uom_code primary, c.lot_number lot, d.batchstep_no
      FROM   lm_sprd_dtl a, mtl_system_items_b b, mtl_lot_numbers c,
             gme_batch_steps d, gme_batch_step_items e
      WHERE  a.inventory_item_id = b.inventory_item_id
             AND a.organization_id = b.organization_id
             AND a.inventory_item_id  = c.inventory_item_id (+)
             AND a.organization_id   = c.organization_id (+)
             AND a.lot_number = c.lot_number (+)
	     AND a.sprd_id  = V_sprd_id
             AND a.material_detail_id = e.material_detail_id (+)
             AND d.batchstep_id(+) = e.batchstep_id
	     AND (a.line_type <> 1 OR a.line_no = 1)
	     ORDER BY a.line_type,a.line_no;

    CURSOR Cur_get_lines IS
      SELECT parent_line_id
      FROM   gmd_material_details_gtmp
      WHERE  entity_id = V_entity_id
             AND line_type <> 3 ;

    CURSOR Cur_get_batch_text(V_matldetlid IN NUMBER) IS
      SELECT text_code
      FROM   gme_material_details
      WHERE  material_detail_id = V_matldetlid;

    CURSOR Cur_get_formula_text(V_formlineid IN NUMBER) IS
      SELECT text_code
      FROM   fm_matl_dtl
      WHERE  formulaline_id = V_formlineid;

    l_text_code 	 NUMBER(10);
    l_line_id            NUMBER DEFAULT 0;
    l_parent_line_id     NUMBER;
    l_secondary_qty 	 NUMBER;
    l_spread_rec     	 Cur_get_spread%ROWTYPE;
  BEGIN
   /* Inserting the item and lot data from spread tables to temp tables*/
    IF (V_sprd_id IS NOT NULL) THEN
      OPEN Cur_get_spread;
      LOOP
        l_line_id := l_line_id + 1;
      FETCH Cur_get_spread INTO l_spread_rec;
      EXIT WHEN Cur_get_spread%NOTFOUND;
      IF (l_spread_rec.material_detail_id IS NOT NULL) THEN
        OPEN Cur_get_batch_text(l_spread_rec.material_detail_id);
        FETCH Cur_get_batch_text INTO l_text_code;
        CLOSE Cur_get_batch_text;
        l_parent_line_id := l_spread_rec.material_detail_id;
      ELSE
        OPEN Cur_get_formula_text(l_spread_rec.formulaline_id);
        FETCH Cur_get_formula_text INTO l_text_code;
        CLOSE Cur_get_formula_text;
        l_parent_line_id := l_spread_rec.formulaline_id;
      END IF;

      INSERT INTO GMD_MATERIAL_DETAILS_GTMP
        (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,
         INVENTORY_ITEM_ID,DESCRIPTION,QTY,SECONDARY_QTY,DETAIL_UOM,ORGANIZATION_ID,
  	 GRADE_CODE,PRIMARY_UOM,SECONDARY_UOM,LOT_CONTROL_CODE,REVISION,
  	 GRADE_CONTROL_FLAG,LOT_NUMBER,TEXT_CODE,ORGINAL_TEXT_CODE,SPRD_LINE_ID,ACTION_CODE,
  	 FORMULALINE_ID,EXPAND_IND,EXPIRATION_DATE,MATERIAL_DETAIL_ID,PARENT_LINE_ID,TPFORMULA_ID,
  	 SUBINVENTORY_CODE,LOCATION,TRANSACTION_ID,RESERVATION_ID,BATCHSTEP_NO,BUFFER_IND, PLANT_ORGANIZATION_ID,
  	 CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,REVISION_QTY_CONTROL_CODE,
  	 MOVE_ORDER_LINE_ID,SECONDARY_DEFAULT_IND,LOCATOR_ID,PROD_PERCENT)
       VALUES
         (l_spread_rec.sprd_id,l_line_id,l_spread_rec.line_type,l_spread_rec.line_no,
          l_spread_rec.rollup_ind,l_spread_rec.tracking_quantity_ind,l_spread_rec.location_control_code,
	  l_spread_rec.inventory_item_id,l_spread_rec.description,
	  l_spread_rec.qty,l_spread_rec.secondary_qty,l_spread_rec.primary,l_spread_rec.organization_id,l_spread_rec.grade_code,
 	  l_spread_rec.primary,l_spread_rec.secondary_uom,l_spread_rec.lot_control_code,
 	  l_spread_rec.revision,l_spread_rec.grade_control_flag,l_spread_rec.lot_number,
 	  l_spread_rec.text_code,l_text_code,l_spread_rec.line_id,'NONE',l_spread_rec.formulaline_id,
 	  DECODE(l_spread_rec.lot_number,NULL,1,0),l_spread_rec.expiry_date,l_spread_rec.material_detail_id,
 	  l_parent_line_id,l_spread_rec.tpformula_id,l_spread_rec.subinventory_code,l_spread_rec.location,
 	  l_spread_rec.transaction_id,l_spread_rec.reservation_id,l_spread_rec.batchstep_no,l_spread_rec.buffer_ind,l_spread_rec.plant_organization_id,
          l_spread_rec.created_by,l_spread_rec.creation_date,l_spread_rec.last_updated_by,
          l_spread_rec.last_update_date,l_spread_rec.revision_qty_control_code,
          l_spread_rec.move_order_line_id,l_spread_rec.secondary_default_ind,l_spread_rec.locator_id,l_spread_rec.prod_percent);
       END LOOP;
       CLOSE Cur_get_spread;
       FOR l_sprd_rec IN Cur_get_lines LOOP
         gmd_spread_fetch_pkg.load_spread_values(V_entity_id,V_sprd_id,V_orgn_id,l_sprd_rec.parent_line_id);
       END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Spread_Details');
  END load_spread_details;

  /*##############################################################
  # NAME
  #	load_batch_details
  # SYNOPSIS
  #	proc   load_batch_details
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_batch_details  (V_entity_id IN NUMBER, V_batch_id IN  NUMBER,
  				 V_orgn_id   IN NUMBER,V_update_inv_ind IN  VARCHAR2,
  				 V_plant_id  IN NUMBER) IS
    CURSOR Cur_get_batch IS
      SELECT a.*,b.description,b.lot_control_code,
             b.grade_control_flag,b.tracking_quantity_ind,b.location_control_code,
             b.default_grade,b.primary_uom_code primary,b.secondary_uom_code secondary,
             c.batchstep_no,e.batch_status, b.revision_qty_control_code,b.secondary_default_ind
      FROM   gme_material_details a, mtl_system_items_b b, gme_batch_steps c,
             gme_batch_step_items d, gme_batch_header e
      WHERE  a.inventory_item_id = b.inventory_item_id
      AND    b.organization_id = a.organization_id
      AND    a.batch_id = V_entity_id
      AND    e.batch_id = V_batch_id
      AND    a.material_detail_id = d.material_detail_id (+)
      AND    c.batchstep_id(+) = d.batchstep_id
	     AND (a.line_type <> 1 OR a.line_no = 1)
	     ORDER BY a.line_type, a.line_no;

    CURSOR Cur_get_lab_lots (V_matl_detl_id NUMBER) IS
      SELECT a.*, c.expiration_date, b.inventory_item_id,
             b.detail_uom, b.primary_uom, b.secondary_uom,
             b.tracking_quantity_ind,b.lot_control_code,b.secondary_default_ind,
             b.grade_control_flag,b.location_control_code, b.organization_id,b.locator_id
      FROM   gme_pending_product_lots a, gmd_material_details_gtmp b,
             mtl_lot_numbers c
      WHERE  a.material_detail_id = b.material_detail_id
      AND    a.material_detail_id = V_matl_detl_id
      AND    a.batch_id           = V_batch_id
      AND    b.organization_id    = c.organization_id
      AND    b.inventory_item_id  = c.inventory_item_id
      AND    a.lot_number         = c.lot_number
      AND    b.lot_control_code   = 2
      AND    b.line_type NOT IN (1,3);

    CURSOR Cur_get_controls (V_inventory_item_id NUMBER,V_lot_number VARCHAR2,V_organization_id NUMBER)  IS
      SELECT b.tracking_quantity_ind,b.lot_control_code,
             b.grade_control_flag,b.location_control_code,
             b.default_grade,b.secondary_default_ind,c.expiration_date,c.organization_id
      FROM   mtl_system_items b,mtl_lot_numbers c
      WHERE  b.inventory_item_id = c.inventory_item_id
      AND    b.organization_id = c.organization_id
      AND    b.inventory_item_id = V_inventory_item_id
      AND    b.organization_id = V_organization_id
      AND    c.lot_number    = V_lot_number;

    CURSOR Cur_get_lines IS
      SELECT material_detail_id
      FROM   gmd_material_details_gtmp
      WHERE  entity_id = V_entity_id
      AND    line_type <> 3 ;

    l_line_id            NUMBER DEFAULT 0;
    l_status       	 VARCHAR2(100);
    l_material_detail_id NUMBER DEFAULT 0;
    l_line_no            NUMBER;
    l_qty		 NUMBER;
    l_secondary_qty	 NUMBER;
    l_primary_qty	 NUMBER;
    l_rsv_qty	         NUMBER;
    l_mat_count          NUMBER;
    l_rsc_count    	 NUMBER;
    l_user_id            NUMBER;

    l_batch_row    	 GME_BATCH_HEADER%ROWTYPE;
    l_batch_rec    	 Cur_get_batch%ROWTYPE;
    l_control     	 Cur_get_controls%ROWTYPE;
    l_labrec          	 Cur_get_lab_lots%ROWTYPE;

    CURSOR Cur_get_formulaid (V_validity_rule_id NUMBER) IS
      SELECT formula_id
      FROM   gmd_recipes r, gmd_recipe_validity_rules v
      WHERE  recipe_validity_rule_id = V_validity_rule_id
      AND    r.recipe_id = v.recipe_id;

    l_return_status		VARCHAR2(1);
    x_return_status             VARCHAR2(1);
    l_msg_data			VARCHAR2(2000);
    l_msg_count			NUMBER(10);
    l_return_code		NUMBER(10);
    l_rec_count			NUMBER(10);
    l_tpformula_id 		NUMBER(10);

    l_recipe_validity_out	GMD_VALIDITY_RULES.recipe_validity_tbl;
    l_reservations_tbl          gme_common_pvt.reservations_tab;
    l_mmt_tbl			gme_common_pvt.mtl_mat_tran_tbl;
    l_mmln_tbl			gme_common_pvt.mtl_trans_lots_num_tbl;
  BEGIN
gmd_debug.log_initialize ('simul');
     /* Inserting the item and lot data from batch material tables to temp tables*/
    l_user_id := TO_NUMBER (fnd_profile.VALUE ('USER_ID'));
    IF (V_batch_id IS NOT NULL) THEN
      OPEN Cur_get_batch;
      LOOP
        l_line_id := l_line_id + 1;
      FETCH Cur_get_batch INTO l_batch_rec;
      EXIT WHEN Cur_get_batch%NOTFOUND;
      IF (l_batch_rec.batch_status = 2) THEN
        l_qty := l_batch_rec.wip_plan_qty;
      ELSE
        l_qty := l_batch_rec.plan_qty;
      END IF;
      l_secondary_qty := null;
      IF (l_qty > 0 AND l_batch_rec.tracking_quantity_ind ='PS') THEN
        l_secondary_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_batch_rec.inventory_item_id,
                                                                    pformula_id => NULL,
                                                                    plot_number => NULL,
                                                                    pcur_qty    => l_qty,
                                                                    pcur_uom    => l_batch_rec.dtl_um,
                                                                    pnew_uom    => l_batch_rec.secondary,
                                                                    patomic	=> 0,
                                                                    plab_id	=> l_batch_rec.organization_id);
        IF (l_secondary_qty < 0) THEN
          l_secondary_qty := 0;
	END IF;
      END IF;
      GMD_VAL_DATA_PUB.get_val_data  (p_api_version		=> 1.0
				     ,p_init_msg_list		=> 'T'
				     ,p_object_type		=> 'L'
				     ,p_item_id			=> l_batch_rec.inventory_item_id
				     ,p_product_qty		=> l_qty
				     ,p_uom			=> l_batch_rec.dtl_um
				     ,p_organization_id  	=> V_orgn_id
				     ,x_return_status		=> l_return_status
                                     ,x_msg_count		=> l_msg_count
				     ,x_msg_data		=> l_msg_data
				     ,x_return_code		=> l_return_code
				     ,x_recipe_validity_out	=> l_recipe_validity_out);
        IF l_return_status = 'S' THEN
          l_rec_count := l_recipe_validity_out.COUNT;
          IF l_rec_count > 0 THEN
            OPEN Cur_get_formulaid (l_recipe_validity_out (l_rec_count).recipe_validity_rule_id);
            FETCH Cur_get_formulaid INTO l_tpformula_id;
            CLOSE Cur_get_formulaid;
          END IF;
        END IF;
      	INSERT INTO GMD_MATERIAL_DETAILS_GTMP
          (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,
           INVENTORY_ITEM_ID,DESCRIPTION,EXPAND_IND,QTY,SECONDARY_QTY,DETAIL_UOM,
           GRADE_CODE,PRIMARY_UOM,SECONDARY_UOM,LOT_CONTROL_CODE,ORGANIZATION_ID,
  	   GRADE_CONTROL_FLAG,REVISION,TEXT_CODE,ORGINAL_TEXT_CODE,MATERIAL_DETAIL_ID,FORMULALINE_ID,
           PARENT_LINE_ID,ACTION_CODE,TPFORMULA_ID,BATCHSTEP_NO,MOVE_ORDER_LINE_ID,
           CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,REVISION_QTY_CONTROL_CODE,
           SECONDARY_DEFAULT_IND)
	VALUES
	  (l_batch_rec.batch_id,l_line_id,l_batch_rec.line_type,l_batch_rec.line_no,1,
	   l_batch_rec.tracking_quantity_ind,l_batch_rec.location_control_code,
	   l_batch_rec.inventory_item_id,l_batch_rec.description,
	   1,l_qty,l_secondary_qty,l_batch_rec.dtl_um,l_batch_rec.default_grade,l_batch_rec.primary,l_batch_rec.secondary,
 	   l_batch_rec.lot_control_code,l_batch_rec.organization_id,l_batch_rec.grade_control_flag,
 	   l_batch_rec.revision,l_batch_rec.text_code,l_batch_rec.text_code,l_batch_rec.material_detail_id,
	   l_batch_rec.formulaline_id,l_batch_rec.material_detail_id,'NONE',l_tpformula_id,
	   l_batch_rec.batchstep_no,l_batch_rec.move_order_line_id,l_batch_rec.created_by,l_batch_rec.creation_date,
	   l_batch_rec.last_updated_by,l_batch_rec.last_update_date,
	   l_batch_rec.revision_qty_control_code, l_batch_rec.secondary_default_ind);

	/*Load the lot transactions into temp table*/
	IF (l_batch_rec.lot_control_code = 2) THEN
          gme_transactions_pvt.get_mat_trans (p_mat_det_id    => l_batch_rec.material_detail_id
                                             ,p_batch_id      => V_batch_id
                                             ,x_mmt_tbl       => l_mmt_tbl
                                             ,x_return_status => l_status);
          IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
            FOR i in 1..l_mmt_tbl.COUNT LOOP
              gme_transactions_pvt.get_lot_trans (p_transaction_id => l_mmt_tbl(i).transaction_id
                                                 ,x_mmln_tbl       => l_mmln_tbl
                                                 ,x_return_status  => x_return_status);
              IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                FOR j IN 1..l_mmln_tbl.COUNT LOOP
                  IF (l_mmln_tbl(j).lot_number IS NOT NULL) THEN
                    l_line_id := l_line_id + 1;
	            IF l_material_detail_id <> l_mmt_tbl(i).transaction_source_id THEN
	              l_line_no := 1;
                      l_material_detail_id := l_mmt_tbl(i).transaction_source_id;
                    END IF;
                    OPEN Cur_get_controls(l_mmln_tbl(j).inventory_item_id,
                                          l_mmln_tbl(j).lot_number,
                                          l_batch_rec.organization_id);
                    FETCH Cur_get_controls INTO l_control;
                    CLOSE Cur_get_controls;
      	            INSERT INTO GMD_MATERIAL_DETAILS_GTMP
                      (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,EXPAND_IND,
                       EXPIRATION_DATE,LOT_NUMBER,QTY,PRIMARY_QTY,PRIMARY_UOM,SECONDARY_QTY,SECONDARY_UOM,
  	               DETAIL_UOM,GRADE_CODE,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,LOT_CONTROL_CODE,
  	               GRADE_CONTROL_FLAG,SUBINVENTORY_CODE,MATERIAL_DETAIL_ID,TRANSACTION_ID,
  	               PARENT_LINE_ID,ACTION_CODE,CREATED_BY,CREATION_DATE,LOCATOR_ID,
  	               LAST_UPDATED_BY,LAST_UPDATE_DATE,SECONDARY_DEFAULT_IND,ORGANIZATION_ID)
	            VALUES
	              (V_batch_id,l_line_id,3,l_line_no,0,l_mmln_tbl(j).inventory_item_id,0,
	               l_control.expiration_date,l_mmln_tbl(j).lot_number,
     	               ABS(l_mmln_tbl(j).transaction_quantity),ABS(l_mmln_tbl(j).primary_quantity),
        	       l_mmt_tbl(i).transaction_uom,ABS(l_mmln_tbl(j).secondary_transaction_quantity),
     	               l_mmt_tbl(i).secondary_uom_code,l_batch_rec.dtl_um,l_mmln_tbl(j).grade_code,
     	               l_control.tracking_quantity_ind,l_control.location_control_code,
     	               l_control.lot_control_code,l_control.grade_control_flag,
	               l_mmt_tbl(i).subinventory_code,l_batch_rec.material_detail_id,
	               l_mmt_tbl(i).transaction_id,l_batch_rec.material_detail_id,
	               'NONE',l_user_id,sysdate,l_mmt_tbl(i).locator_id,
	               l_user_id,sysdate,l_control.secondary_default_ind,l_mmln_tbl(j).organization_id);
                       l_line_no := l_line_no + 1;
                  END IF;
                END LOOP;
              END IF;
            END LOOP;
          END IF;
	END IF;
        /* based on update_inventory_ind data will be loaded either from reservations table
           or pending lots table*/

        IF (V_update_inv_ind = 'Y') THEN
          --Load Reservations
          gme_reservations_pvt.get_material_reservations (p_organization_id    => l_batch_rec.organization_id
                                                         ,p_batch_id           => V_batch_id
                                                         ,p_material_detail_id => l_batch_rec.material_detail_id
                                                         ,x_return_status      => l_status
                                                         ,x_reservations_tbl   => l_reservations_tbl);
          IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
            FOR i IN 1..l_reservations_tbl.COUNT LOOP
              IF (l_reservations_tbl(i).lot_number IS NOT NULL) THEN
                l_line_id := l_line_id + 1;
	        IF l_material_detail_id <> l_reservations_tbl(i).demand_source_line_id THEN
	          l_line_no := 1;
                  l_material_detail_id := l_reservations_tbl(i).demand_source_line_id;
                END IF;
                OPEN Cur_get_controls(l_reservations_tbl(i).inventory_item_id,
                                      l_reservations_tbl(i).lot_number,
                                      l_batch_rec.organization_id);
                FETCH Cur_get_controls INTO l_control;
                CLOSE Cur_get_controls;

                l_rsv_qty := NULL;
                IF (l_reservations_tbl(i).reservation_uom_code = l_batch_rec.dtl_um) THEN
                  l_rsv_qty := l_reservations_tbl(i).reservation_quantity;
                ELSIF (l_reservations_tbl(i).primary_uom_code = l_batch_rec.dtl_um) THEN
                  l_rsv_qty := l_reservations_tbl(i).primary_reservation_quantity;
                ELSIF (l_reservations_tbl(i).secondary_uom_code = l_batch_rec.dtl_um) THEN
                  l_rsv_qty := l_reservations_tbl(i).secondary_reservation_quantity;
                ELSE
                  l_rsv_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_labrec.inventory_item_id,
                                                                        pformula_id => NULL,
                                                                        plot_number => l_reservations_tbl(i).lot_number,
                                                                        pcur_qty    => l_reservations_tbl(i).primary_reservation_quantity,
                                                                        pcur_uom    => l_reservations_tbl(i).primary_uom_code,
                                                                        pnew_uom    => l_batch_rec.dtl_um,
                                                                        patomic     => 0,
                                                                        plab_id     => l_batch_rec.organization_id);

                END IF;

      	        INSERT INTO GMD_MATERIAL_DETAILS_GTMP
                  (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,EXPAND_IND,
                   EXPIRATION_DATE,LOT_NUMBER,QTY,PRIMARY_QTY,PRIMARY_UOM,SECONDARY_QTY,SECONDARY_UOM,
  	           DETAIL_UOM,GRADE_CODE,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,LOT_CONTROL_CODE,
  	           GRADE_CONTROL_FLAG,SUBINVENTORY_CODE,MATERIAL_DETAIL_ID,RESERVATION_ID,
  	           PARENT_LINE_ID,ACTION_CODE,CREATED_BY,CREATION_DATE,LOCATOR_ID,
  	           LAST_UPDATED_BY,LAST_UPDATE_DATE,SECONDARY_DEFAULT_IND,ORGANIZATION_ID)
	        VALUES
	          (V_batch_id,l_line_id,3,l_line_no,0,l_reservations_tbl(i).inventory_item_id,0,
	           l_control.expiration_date,l_reservations_tbl(i).lot_number,
     	           l_rsv_qty,l_reservations_tbl(i).primary_reservation_quantity,
     	           l_reservations_tbl(i).primary_uom_code,l_reservations_tbl(i).secondary_reservation_quantity,
     	           l_reservations_tbl(i).secondary_uom_code,l_batch_rec.dtl_um,l_control.default_grade,
     	           l_control.tracking_quantity_ind,l_control.location_control_code,
     	           l_control.lot_control_code,l_control.grade_control_flag,
	           l_reservations_tbl(i).subinventory_code,l_batch_rec.material_detail_id,
	           l_reservations_tbl(i).reservation_id,l_batch_rec.material_detail_id,
	           'NONE',l_user_id,sysdate,l_reservations_tbl(i).locator_id,l_user_id,sysdate,l_control.secondary_default_ind,l_control.organization_id);
                l_line_no := l_line_no + 1;
              END IF;
            END LOOP;
          END IF;
        ELSE
          OPEN Cur_get_lab_lots (l_batch_rec.material_detail_id);
          LOOP
          l_line_id := l_line_id + 1;
          FETCH Cur_get_lab_lots INTO l_labrec;
          EXIT WHEN Cur_get_lab_lots%NOTFOUND;
          IF l_material_detail_id <> l_labrec.material_detail_id THEN
	    l_line_no := 1;
            l_material_detail_id := l_labrec.material_detail_id;
          END IF;

          l_primary_qty := null;
          IF (l_labrec.quantity > 0) THEN
            l_primary_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_labrec.inventory_item_id,
                                                                      pformula_id => NULL,
                                                                      plot_number => l_labrec.lot_number,
                                                                      pcur_qty    => l_labrec.quantity,
                                                                      pcur_uom    => l_labrec.primary_uom,
                                                                      pnew_uom    => l_labrec.secondary_uom,
                                                                      patomic     => 0,
                                                                      plab_id     => l_batch_rec.organization_id);
            IF (l_primary_qty < 0) THEN
              l_primary_qty := NULL;
            END IF;
          END IF;
          INSERT INTO GMD_MATERIAL_DETAILS_GTMP
            (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,EXPAND_IND,
             EXPIRATION_DATE,SECONDARY_UOM,LOT_NUMBER,QTY,PRIMARY_QTY,PRIMARY_UOM,SECONDARY_QTY,
             DETAIL_UOM,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,LOT_CONTROL_CODE,
  	     GRADE_CONTROL_FLAG,MATERIAL_DETAIL_ID,PARENT_LINE_ID,ACTION_CODE,CREATED_BY,
             CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,SECONDARY_DEFAULT_IND,
             ORGANIZATION_ID,LOCATOR_ID,TRANS_ID)
          VALUES
            (V_batch_id,l_line_id,3,l_line_no,0,l_labrec.inventory_item_id,0,l_labrec.expiration_date,
             l_labrec.secondary_uom,l_labrec.lot_number,l_labrec.quantity,l_primary_qty,l_labrec.primary_uom,
             l_labrec.secondary_quantity,l_labrec.detail_uom,l_labrec.tracking_quantity_ind,
             l_labrec.location_control_code,l_labrec.lot_control_code,l_labrec.grade_control_flag,
             l_labrec.material_detail_id,l_labrec.material_detail_id,'NONE',
             l_user_id,sysdate,l_user_id,sysdate,l_labrec.secondary_default_ind,
             l_labrec.organization_id,l_labrec.locator_id,l_labrec.pending_product_lot_id);
	  l_line_no := l_line_no + 1;
        END LOOP;
        CLOSE Cur_get_lab_lots;
      END IF;
      END LOOP;
      CLOSE Cur_get_batch;
      FOR l_mat_rec IN Cur_get_lines LOOP
        gmd_spread_fetch_pkg.load_batch_values(V_entity_id    => V_entity_id,
                                               V_batch_id     => V_batch_id,
                                               V_orgn_id      => V_orgn_id,
                                               V_matl_detl_id => l_mat_rec.material_detail_id,
                                               V_plant_id     => V_plant_id);
      END LOOP;
    END IF; --IF (V_batch_id IS NOT NULL) THEN

  EXCEPTION
    WHEN OTHERS THEN
    gmd_debug.put_line('error '||SQLERRM);
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Batch_Details');
  END load_batch_details;

  /*##############################################################
  # NAME
  #	load_formula_details
  # SYNOPSIS
  #	proc   load_formula_details
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  # HISTORY
  #      Kapil M 12-FEB-2007  Bug# 5716318 : Auto-Prod Calcualtion ME
  #              Added the newly added column - prod_percent to insert into temp tables
  ###############################################################*/

  PROCEDURE load_formula_details  (V_entity_id IN NUMBER, V_formula_id IN  NUMBER,
                                   V_orgn_id   IN NUMBER, V_plant_id   IN  NUMBER) IS
    CURSOR Cur_get_formula IS
      SELECT a.*,b.description,b.default_grade,
             b.primary_uom_code primary,b.secondary_uom_code secondary,
             b.lot_control_code,b.revision_qty_control_code,b.secondary_default_ind,
             b.grade_control_flag,b.tracking_quantity_ind,b.location_control_code
      FROM   fm_matl_dtl a, mtl_system_items_b b
      WHERE  a.inventory_item_id = b.inventory_item_id
      AND    b.organization_id = a.organization_id
      AND    a.formula_id = V_entity_id
	     AND (a.line_type <> 1 OR a.line_no = 1)
   	     ORDER BY a.line_type, a.line_no;

    CURSOR Cur_get_materials IS
      SELECT a.*, b.lot_number lot,b.expiration_date expire, b.inventory_item_id itemid
      FROM   gmd_material_details_gtmp a, mtl_lot_numbers b,  (select inventory_item_id,lot_number, lot_organization_id
                                                               from gmd_technical_data_vl group by inventory_item_id,lot_number,lot_organization_id) c
      WHERE  a.entity_id  = V_formula_id
      AND    a.inventory_item_id = b.inventory_item_id
      AND    a.inventory_item_id = c.inventory_item_id
      AND    b.organization_id  = c.lot_organization_id
      AND    a.lot_control_code = 2
      AND    (a.line_type <> 1)
      ORDER BY a.formulaline_id,b.lot_number;

    CURSOR Cur_get_lines IS
      SELECT formulaline_id
      FROM   gmd_material_details_gtmp
      WHERE  entity_id = V_entity_id
      AND    line_type <> 3 ;

    l_line_id            NUMBER DEFAULT 0;
    l_matl_rec     	 Cur_get_materials%ROWTYPE;
    l_formula_rec     	 Cur_get_formula%ROWTYPE;
    l_line_no            NUMBER;
    l_secondary_qty	 NUMBER;
    l_formulaline_id     NUMBER DEFAULT 0;

    CURSOR Cur_get_formulaid (V_validity_rule_id NUMBER) IS
      SELECT formula_id
      FROM   gmd_recipes r, gmd_recipe_validity_rules v
      WHERE  recipe_validity_rule_id = V_validity_rule_id
      AND    r.recipe_id = v.recipe_id;

    l_return_status		VARCHAR2(1);
    l_msg_data			VARCHAR2(2000);
    l_msg_count			NUMBER(10);
    l_return_code		NUMBER(10);
    l_recipe_validity_out	GMD_VALIDITY_RULES.recipe_validity_tbl;
    l_rec_count			NUMBER(10);
    l_tpformula_id 		NUMBER(10);

  BEGIN
     /* Inserting the item and lot data from formula detail tables to temp tables*/
    IF (V_formula_id IS NOT NULL) THEN
      OPEN Cur_get_formula;
      LOOP
        l_line_id := l_line_id + 1;
      FETCH Cur_get_formula INTO l_formula_rec;
      EXIT WHEN Cur_get_formula%NOTFOUND;
      /* Getting the secondary qty*/
      l_secondary_qty := null;
      IF (l_formula_rec.qty > 0 AND l_formula_rec.tracking_quantity_ind = 'PS') THEN
        l_secondary_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_formula_rec.inventory_item_id,
                                                                    pformula_id => NULL,
                                                                    plot_number => NULL,
                                                                    pcur_qty    => l_formula_rec.qty,
                                                                    pcur_uom    => l_formula_rec.detail_uom,
                                                                    pnew_uom    => l_formula_rec.secondary,
                                                                    patomic	=> 0,
                                                                    plab_id	=> l_formula_rec.organization_id);
        IF (l_secondary_qty < 0) THEN
          l_secondary_qty := NULL;
        END IF;
      END IF;

      l_tpformula_id := NULL; /* Added in Bug No.7462584 */
      IF l_formula_rec.line_type = -1 THEN /* Added in Bug No.7462584 */
        IF l_formula_rec.tpformula_id IS NULL THEN
                /*GMD_VAL_DATA_PUB.get_val_data  (p_api_version		=> 1.0
					,p_init_msg_list	=> 'T'
					,p_object_type		=> 'L'
					,p_item_id		=> l_formula_rec.inventory_item_id
					,p_product_qty		=> l_formula_rec.qty
					,p_uom			=> l_formula_rec.detail_uom
					,p_organization_id	=> V_orgn_id
					,x_return_status	=> l_return_status
                                        ,x_msg_count		=> l_msg_count
					,x_msg_data		=> l_msg_data
					,x_return_code		=> l_return_code
					,x_recipe_validity_out	=> l_recipe_validity_out);
                IF l_return_status = 'S' THEN
                        l_rec_count := l_recipe_validity_out.COUNT;
                    IF l_rec_count > 0 THEN
                        OPEN Cur_get_formulaid (l_recipe_validity_out (l_rec_count).recipe_validity_rule_id);
                        FETCH Cur_get_formulaid INTO l_tpformula_id;
                        CLOSE Cur_get_formulaid;
                    END IF;
                END IF;
         ELSE
                 l_tpformula_id := l_formula_rec.tpformula_id;
         END IF;   */
        BEGIN
                SELECT a.formula_id INTO l_tpformula_id
                FROM
                 (SELECT a.formula_id
                  FROM Fm_form_mst a, fm_matl_dtl b, gmd_technical_data_hdr g
                  WHERE b.item_id = l_formula_rec.item_id
                        AND a.formula_id = b.formula_id
                        AND g.item_id = b.item_id
                        AND g.formula_id = a.formula_id
                        AND g.organization_id = V_orgn_id
                        AND a.formula_id <>0
                        AND b.line_type = 1
                        AND a.delete_mark =0
                        AND g.delete_mark =0
                  ORDER BY a.formula_id) a
                  WHERE rownum < 2;
        EXCEPTION
          WHEN OTHERS THEN
           l_tpformula_id := l_formula_rec.tpformula_id;
        END;
      ELSE
        l_tpformula_id := l_formula_rec.tpformula_id;
      END IF;
     ELSIF l_formula_rec.line_type = 1 THEN
        l_tpformula_id := V_formula_id ;
     END IF; /*Added in Bug No.7462584 */

      INSERT INTO GMD_MATERIAL_DETAILS_GTMP
        (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,EXPAND_IND,TRACKING_QUANTITY_IND,
         LOCATION_CONTROL_CODE,INVENTORY_ITEM_ID,DESCRIPTION,TPFORMULA_ID,
         QTY,SECONDARY_QTY,DETAIL_UOM,GRADE_CODE,PRIMARY_UOM,SECONDARY_UOM,LOT_CONTROL_CODE,
         GRADE_CONTROL_FLAG,REVISION,TEXT_CODE,ORGINAL_TEXT_CODE,FORMULALINE_ID,PARENT_LINE_ID,
         ACTION_CODE,BUFFER_IND,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         REVISION_QTY_CONTROL_CODE,ORGANIZATION_ID,SECONDARY_DEFAULT_IND,PROD_PERCENT)
      VALUES
        (l_formula_rec.formula_id,l_line_id,l_formula_rec.line_type,l_formula_rec.line_no,1,1,
         l_formula_rec.tracking_quantity_ind,l_formula_rec.location_control_code,
	 l_formula_rec.inventory_item_id,l_formula_rec.description,
	 l_tpformula_id,l_formula_rec.qty,l_secondary_qty,l_formula_rec.detail_uom,
	 l_formula_rec.default_grade,l_formula_rec.primary,l_formula_rec.secondary,
         l_formula_rec.lot_control_code,l_formula_rec.grade_control_flag,
         l_formula_rec.revision,l_formula_rec.text_code,l_formula_rec.text_code,l_formula_rec.formulaline_id,
	 l_formula_rec.formulaline_id,'NONE',l_formula_rec.buffer_ind,l_formula_rec.created_by,
         l_formula_rec.creation_date,l_formula_rec.last_updated_by,
         l_formula_rec.last_update_date,l_formula_rec.revision_qty_control_code,
         l_formula_rec.organization_id, l_formula_rec.secondary_default_ind,l_formula_rec.prod_percent);
       END LOOP;
       CLOSE Cur_get_formula;

       OPEN Cur_get_materials;
       LOOP
        l_line_id := l_line_id + 1;
       FETCH Cur_get_materials INTO l_matl_rec;
       EXIT WHEN Cur_get_materials%NOTFOUND;
	 IF l_formulaline_id <> l_matl_rec.formulaline_id THEN
           l_line_no := 1;
           l_formulaline_id := l_matl_rec.formulaline_id;
	 END IF;
        IF (l_matl_rec.tracking_quantity_ind = 'PS') THEN
          l_secondary_qty := 0;
        ELSE
          l_secondary_qty := NULL;
        END IF;

        INSERT INTO GMD_MATERIAL_DETAILS_GTMP
          (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,TRACKING_QUANTITY_IND,LOCATION_CONTROL_CODE,
           INVENTORY_ITEM_ID,EXPAND_IND,EXPIRATION_DATE,LOT_NUMBER,QTY,SECONDARY_QTY,
  	   DETAIL_UOM,GRADE_CODE,FORMULALINE_ID,PARENT_LINE_ID,LOT_CONTROL_CODE,
           GRADE_CONTROL_FLAG,ACTION_CODE,SECONDARY_UOM,SECONDARY_DEFAULT_IND,
  	   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,ORGANIZATION_ID,PROD_PERCENT)
        VALUES
          (l_matl_rec.entity_id,l_line_id,3,l_line_no,0,l_matl_rec.tracking_quantity_ind,
           l_matl_rec.location_control_code,l_matl_rec.inventory_item_id,0,l_matl_rec.expiration_date,
           l_matl_rec.lot,0,l_secondary_qty,l_matl_rec.detail_uom,l_matl_rec.grade_code,
	   l_matl_rec.formulaline_id,l_matl_rec.formulaline_id,l_matl_rec.lot_control_code,
	   l_matl_rec.grade_control_flag,'NONE',l_matl_rec.secondary_uom,l_matl_rec.secondary_default_ind,
	   l_matl_rec.created_by,l_matl_rec.creation_date,
	   l_matl_rec.last_updated_by,l_matl_rec.last_update_date,l_matl_rec.organization_id,l_formula_rec.prod_percent);
	   l_line_no := l_line_no + 1;
      END LOOP;
      CLOSE Cur_get_materials;
      FOR l_form_rec IN Cur_get_lines LOOP
        gmd_spread_fetch_pkg.load_formula_values(V_entity_id      => V_entity_id,
                                                 V_formula_id     => V_formula_id,
                                                 V_orgn_id        => V_orgn_id,
                                                 V_formulaline_id => l_form_rec.formulaline_id,
                                                 V_plant_id       => V_plant_id);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Formula_Details');
  END load_formula_details;

/*##############################################################
  # NAME
  #	load_tech_params
  # SYNOPSIS
  #	proc   load_tech_params
  # DESCRIPTION
  #      This procedure inserts the data into temp tables for tech
  #      parameters .
  ###############################################################*/

  PROCEDURE load_tech_params (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,V_batch_id IN NUMBER,
  			      V_orgn_id IN NUMBER,V_folder_name IN VARCHAR2,
  			      V_inv_item_id IN NUMBER,V_formula_id IN NUMBER) IS
    CURSOR Cur_get_prod IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl
      WHERE  formula_id = V_entity_id
      AND    line_type = 1
      AND    line_no = 1;

    CURSOR Cur_get_material_prod IS
      SELECT inventory_item_id
      FROM   gme_material_details
      WHERE  batch_id = V_entity_id
      AND    line_type = 1
      AND    line_no = 1;

    CURSOR Cur_get_lcf_prod IS
      SELECT inventory_item_id
      FROM   gmd_lcf_details_gtmp
      WHERE  entity_id = V_entity_id
      AND    line_type = 1
      AND    line_no = 1;

    l_item_id         NUMBER;
    l_category_set_id NUMBER;

    CURSOR Cur_get_category IS
      SELECT category_id
      FROM   mtl_item_categories
      WHERE  category_set_id = l_category_set_id
      AND    inventory_item_id = l_item_id;
    l_category_id NUMBER;

    CURSOR Cur_get_item_count IS
      SELECT count(*)
      FROM   gmd_technical_sequence_vl
      WHERE  organization_id = V_orgn_id
      AND    inventory_item_id = l_item_id
      AND    delete_mark = 0;

    CURSOR Cur_get_category_count IS
      SELECT count(*)
      FROM   gmd_technical_sequence_vl
      WHERE  category_id = l_category_id
      AND    organization_id = V_orgn_id
      AND    delete_mark = 0;
    l_count NUMBER;

    CURSOR Cur_get_folder_cols IS
      SELECT c.*, b.sequence
      FROM   fnd_folders a, fnd_folder_columns b, lm_tech_hdr c
      WHERE  a.folder_id = b.folder_id
      AND    b.item_prompt = c.tech_parm_name
      AND    a.name = V_folder_name
      AND    a.OBJECT = 'SPREAD_DTL_SUB'
      AND    c.organization_id = V_orgn_id;

    l_rec    Cur_get_folder_cols%ROWTYPE;
l_count11 number;
  BEGIN
    DELETE FROM gmd_technical_parameter_gtmp;
    l_category_set_id := TO_NUMBER (FND_PROFILE.VALUE ('GMD_TECH_CATG_SET'));
    IF (V_folder_name IS NOT NULL) THEN
      OPEN Cur_get_folder_cols;
      LOOP
      FETCH Cur_get_folder_cols INTO l_rec;
      EXIT WHEN Cur_get_folder_cols%NOTFOUND;
      INSERT INTO GMD_TECHNICAL_PARAMETER_GTMP
                 (ENTITY_ID,TECH_PARM_NAME,TECH_PARM_ID,PARM_DESCRIPTION,SORT_SEQ,QCASSY_TYP_ID,
		  DATA_TYPE,EXPRESSION_CHAR,LM_UNIT_CODE,SIGNIF_FIGURES,LOWERBOUND_NUM,
		  UPPERBOUND_NUM,LOWERBOUND_CHAR,UPPERBOUND_CHAR,MAX_LENGTH)
      VALUES     (V_entity_id,l_rec.tech_parm_name,l_rec.tech_parm_id,l_rec.parm_description,l_rec.sequence,l_rec.qcassy_typ_id,
		  l_rec.data_type,l_rec.expression_char,l_rec.lm_unit_code,
		  DECODE(l_rec.data_type, 4, NVL(l_rec.signif_figures, 0 ), 11,  NVL(l_rec.signif_figures, 0 ),l_rec.signif_figures ),
		  l_rec.lowerbound_num,l_rec.upperbound_num,l_rec.lowerbound_char,l_rec.upperbound_char,l_rec.max_length);
      END LOOP;
      CLOSE Cur_get_folder_cols;

      ELSIF (V_sprd_id IS NOT NULL) THEN
      INSERT INTO GMD_TECHNICAL_PARAMETER_GTMP
                 (ENTITY_ID,TECH_PARM_NAME,TECH_PARM_ID,PARM_DESCRIPTION,SORT_SEQ,QCASSY_TYP_ID,DATA_TYPE,EXPRESSION_CHAR,
		  LM_UNIT_CODE,SIGNIF_FIGURES,LOWERBOUND_NUM,UPPERBOUND_NUM,OPTIMIZE_TYPE,LOWERBOUND_CHAR,UPPERBOUND_CHAR,MAX_LENGTH)
		  SELECT a.sprd_id,a.tech_parm_name,b.tech_parm_id,b.parm_description,a.sort_seq,b.qcassy_typ_id,
		         b.data_type,b.expression_char,b.lm_unit_code,
                         DECODE(b.data_type, 4, NVL(b.signif_figures, 0 ), 11,  NVL(b.signif_figures, 0 ),b.signif_figures ),
                         a.min_value,a.max_value,a.optimize_type,
                         b.lowerbound_char,b.upperbound_char,b.max_length
		  FROM   lm_sprd_prm a, lm_tech_hdr b
		  WHERE  a.tech_parm_id = b.tech_parm_id
			 AND a.sprd_id    = V_entity_id
                         AND a.organization_id  = V_orgn_id;

    ELSE
      IF (V_inv_item_id IS NOT NULL) THEN
        l_item_id := V_inv_item_id;
      ELSIF (V_batch_id IS NOT NULL) THEN
        OPEN Cur_get_material_prod;
        FETCH Cur_get_material_prod INTO l_item_id;
        CLOSE Cur_get_material_prod;
      ELSIF (V_formula_id IS NOT NULL) THEN
        OPEN Cur_get_prod;
        FETCH Cur_get_prod INTO l_item_id;
        CLOSE Cur_get_prod;
      ELSE
        OPEN Cur_get_lcf_prod;
        FETCH Cur_get_lcf_prod INTO l_item_id;
        CLOSE Cur_get_lcf_prod;
      END IF;

      --Fetching the category id
      OPEN Cur_get_category;
      FETCH Cur_get_category INTO l_category_id;
      CLOSE Cur_get_category;

      --If item has the parameters then insert
      OPEN Cur_get_item_count;
      FETCH Cur_get_item_count INTO l_count;
      CLOSE Cur_get_item_count;
      IF (l_count > 0) THEN
        INSERT INTO GMD_TECHNICAL_PARAMETER_GTMP
                 (ENTITY_ID,TECH_PARM_NAME,TECH_PARM_ID,PARM_DESCRIPTION,SORT_SEQ,QCASSY_TYP_ID,DATA_TYPE,EXPRESSION_CHAR,
		  LM_UNIT_CODE,SIGNIF_FIGURES,LOWERBOUND_NUM,UPPERBOUND_NUM,LOWERBOUND_CHAR,UPPERBOUND_CHAR,MAX_LENGTH)
		  SELECT V_entity_id,a.tech_parm_name,b.tech_parm_id,b.parm_description,a.sort_seq,
		         b.qcassy_typ_id,b.data_type,b.expression_char,b.lm_unit_code,
                         DECODE(b.data_type, 4, NVL(b.signif_figures, 0 ), 11,  NVL(b.signif_figures, 0 ),b.signif_figures ),
                         b.lowerbound_num,b.upperbound_num,
                         b.lowerbound_char,b.upperbound_char,b.max_length
		  FROM   gmd_technical_sequence_vl a, lm_tech_hdr b
		  WHERE  a.tech_parm_id = b.tech_parm_id
                         AND a.inventory_item_id  = l_item_id
                         AND a.organization_id  = V_orgn_id;
      ELSE
      --If item category has the parameters then insert
        OPEN Cur_get_category_count;
        FETCH Cur_get_category_count INTO l_count;
        CLOSE Cur_get_category_count;
        IF (l_count > 0) THEN
          INSERT INTO GMD_TECHNICAL_PARAMETER_GTMP
                 (ENTITY_ID,TECH_PARM_NAME,TECH_PARM_ID,PARM_DESCRIPTION,SORT_SEQ,QCASSY_TYP_ID,DATA_TYPE,EXPRESSION_CHAR,
		  LM_UNIT_CODE,SIGNIF_FIGURES,LOWERBOUND_NUM,UPPERBOUND_NUM,LOWERBOUND_CHAR,UPPERBOUND_CHAR,MAX_LENGTH)
		  SELECT V_entity_id,a.tech_parm_name,b.tech_parm_id,b.parm_description,a.sort_seq,
		         b.qcassy_typ_id,b.data_type,b.expression_char,b.lm_unit_code,
                         DECODE(b.data_type, 4, NVL(b.signif_figures, 0 ), 11,  NVL(b.signif_figures, 0 ),b.signif_figures ),
                         b.lowerbound_num,b.upperbound_num,
                         b.lowerbound_char,b.upperbound_char,b.max_length
		  FROM   gmd_technical_sequence_vl a, lm_tech_hdr b
		  WHERE  a.tech_parm_id = b.tech_parm_id
                         AND a.category_id  = l_category_id
                         AND a.organization_id  = V_orgn_id;
        ELSE
        --If organization has the parameters then insert
          INSERT INTO GMD_TECHNICAL_PARAMETER_GTMP
                 (ENTITY_ID,TECH_PARM_NAME,TECH_PARM_ID,PARM_DESCRIPTION,SORT_SEQ,QCASSY_TYP_ID,DATA_TYPE,EXPRESSION_CHAR,
		  LM_UNIT_CODE,SIGNIF_FIGURES,LOWERBOUND_NUM,UPPERBOUND_NUM,LOWERBOUND_CHAR,UPPERBOUND_CHAR,MAX_LENGTH)
		  SELECT V_entity_id,a.tech_parm_name,b.tech_parm_id,b.parm_description,a.sort_seq,
		         b.qcassy_typ_id,b.data_type,b.expression_char,b.lm_unit_code,
                         DECODE(b.data_type, 4, NVL(b.signif_figures, 0 ), 11,  NVL(b.signif_figures, 0 ),b.signif_figures ),
                         b.lowerbound_num,b.upperbound_num,
                         b.lowerbound_char,b.upperbound_char,b.max_length
		  FROM   gmd_technical_sequence_vl a, lm_tech_hdr b
		  WHERE  a.tech_parm_id = b.tech_parm_id
                         AND a.organization_id = V_orgn_id
                         AND a.inventory_item_id IS NULL
                         AND a.category_id IS NULL;
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Tech_Params');
  END load_tech_params;

  /*##############################################################
  # NAME
  #	add_new_line
  # SYNOPSIS
  #	proc   add_new_line
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE add_new_line  (V_entity_id  IN NUMBER, V_inv_item_id   IN NUMBER, V_line_type IN NUMBER,
  			   V_line_no    IN NUMBER, V_source_ind IN NUMBER,V_formula_id IN NUMBER,V_move_order_header_id IN NUMBER,
  			   V_orgn_id    IN NUMBER, X_line_id  OUT NOCOPY NUMBER,
  			   X_parent_line_id  OUT NOCOPY NUMBER,X_move_order_line_id  OUT NOCOPY NUMBER,
  			   V_plant_id IN NUMBER) IS
    CURSOR Cur_get_item IS
      SELECT b.description,b.default_grade,b.secondary_default_ind,
             b.primary_uom_code,b.secondary_uom_code,b.tracking_quantity_ind,
      	     b.lot_control_code,b.grade_control_flag,b.location_control_code,
      	     b.revision_qty_control_code,b.mtl_transactions_enabled_flag
      FROM   mtl_system_items_b b
      WHERE  b.inventory_item_id = V_inv_item_id
      AND    b.organization_id = V_orgn_id;

    CURSOR Cur_line_id IS
      SELECT MAX(line_id)
      FROM   gmd_material_details_gtmp
      WHERE  entity_id = V_entity_id;

    CURSOR Cur_formulaline_id IS
      SELECT gem5_formulaline_id_s.NEXTVAL
      FROM   dual;

    CURSOR Cur_spreadline_id IS
      SELECT gem5_sprd_line_id_s.nextval
      FROM   dual;

    CURSOR Cur_get_materials (Pline_id	NUMBER) IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_id = Pline_id;

    CURSOR Cur_get_batch IS
      SELECT *
      FROM   gme_batch_header
      WHERE  batch_id = V_entity_id;

    l_line_id            NUMBER;
    l_item_rec     	 Cur_get_item%ROWTYPE;
    l_line_no            NUMBER DEFAULT 0;
    l_parentline_id      NUMBER;
    l_user_id		 NUMBER;
    l_return_status	 VARCHAR2(1);
    l_msg_count		 NUMBER;
    l_msg_data		 VARCHAR2(2000);
    X_return_status	 VARCHAR2(1);
    l_rec		 Cur_get_materials%ROWTYPE;
    l_batch		 Cur_get_batch%ROWTYPE;
    l_materials          gme_common_pvt.material_details_tab;
    l_materials_out      gme_common_pvt.material_details_tab;
    l_trolin		 inv_move_order_pub.trolin_tbl_type;

    create_mo_line_err	EXCEPTION;
    setup_failure       EXCEPTION;
  BEGIN
    l_user_id := TO_NUMBER (fnd_profile.VALUE ('USER_ID'));
    IF NOT (gme_common_pvt.setup(P_org_id => V_orgn_id)) THEN
      RAISE setup_failure;
    END IF;
    /* Inserting the item and lot data for the item entered in the form*/
    OPEN Cur_line_id;
    FETCH Cur_line_id INTO l_line_id;
    CLOSE Cur_line_id;
    IF (V_source_ind = 0) THEN
      OPEN Cur_formulaline_id;
      FETCH Cur_formulaline_id INTO l_parentline_id;
      CLOSE Cur_formulaline_id;
    ELSE
      OPEN Cur_spreadline_id;
      FETCH Cur_spreadline_id INTO l_parentline_id;
      CLOSE Cur_spreadline_id;
    END IF;
    OPEN Cur_get_item;
    FETCH Cur_get_item INTO l_item_rec;
    CLOSE Cur_get_item;
    l_line_id := l_line_id + 1;

    INSERT INTO GMD_MATERIAL_DETAILS_GTMP
      (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,
      DESCRIPTION,EXPAND_IND,QTY,DETAIL_UOM,GRADE_CODE,PRIMARY_UOM,SECONDARY_UOM,TRACKING_QUANTITY_IND,SECONDARY_DEFAULT_IND,
      LOT_CONTROL_CODE,GRADE_CONTROL_FLAG,LOCATION_CONTROL_CODE,TEXT_CODE,ORGINAL_TEXT_CODE,FORMULALINE_ID,
      MATERIAL_DETAIL_ID,PARENT_LINE_ID,ACTION_CODE,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
      LAST_UPDATE_DATE,REVISION_QTY_CONTROL_CODE,ORGANIZATION_ID)
    VALUES
      (V_entity_id,l_line_id,V_line_type,V_line_no,1,V_inv_item_id,
      l_item_rec.description,1,0,l_item_rec.primary_uom_code,l_item_rec.default_grade,l_item_rec.primary_uom_code,
      l_item_rec.secondary_uom_code,l_item_rec.tracking_quantity_ind,l_item_rec.secondary_default_ind,
      l_item_rec.lot_control_code,l_item_rec.grade_control_flag,l_item_rec.location_control_code,
      NULL,NULL,l_parentline_id,l_parentline_id,l_parentline_id,'NONE',l_user_id,SYSDATE,
      l_user_id,SYSDATE,l_item_rec.revision_qty_control_code,V_orgn_id);

    X_line_id := l_line_id;
    X_parent_line_id := l_parentline_id;

    --Create a move order line for SAI form to be called before updating the batch.
    OPEN Cur_get_batch;
    FETCH Cur_get_batch INTO l_batch;
    CLOSE Cur_get_batch;
    IF (V_line_type = -1 AND l_batch.update_inventory_ind = 'Y'
                         AND l_item_rec.mtl_transactions_enabled_flag = 'Y') THEN
      IF (V_source_ind = 1) THEN
        OPEN Cur_get_materials(l_line_id);
        FETCH Cur_get_materials INTO l_rec;
        CLOSE Cur_get_materials;

        IF (l_rec.line_type = -1) THEN
          l_materials(1).material_requirement_date := l_batch.plan_start_date;
        ELSE
          l_materials(1).material_requirement_date := l_batch.plan_cmplt_date;
        END IF;

        l_materials(1).inventory_item_id  := V_inv_item_id;
        l_materials(1).material_detail_id := l_parentline_id;
        l_materials(1).organization_id    := V_orgn_id;
        l_materials(1).plan_qty           := 0;
        l_materials(1).dtl_um             := l_rec.detail_uom;
        l_materials(1).line_type          := V_line_type;
        l_materials(1).batch_id           := V_entity_id;
        l_materials(1).creation_date      := gme_common_pvt.g_timestamp;
        l_materials(1).created_by         := gme_common_pvt.g_user_ident;
        l_materials(1).last_update_date   := gme_common_pvt.g_timestamp;
        l_materials(1).last_updated_by    := gme_common_pvt.g_user_ident;

        gme_move_orders_pvt.create_move_order_lines (p_move_order_header_id => v_move_order_header_id
                                                    ,p_move_order_type      => gme_common_pvt.g_invis_move_order_type
                                                    ,p_material_details_tbl => l_materials
                                                    ,x_material_details_tbl => l_materials_out
                                                    ,x_trolin_tbl           => l_trolin
                                                    ,x_return_status        => l_return_status);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE create_mo_line_err;
        ELSE
          X_move_order_line_id := l_materials_out(1).move_order_line_id;
        END IF;
      END IF;
    END IF;
    --Fixed for ADS demo this code was in the if condition before.
    IF (V_line_type = -1) THEN
        gmd_spread_fetch_pkg.load_formula_values(V_entity_id      => V_entity_id,
                                                 V_formula_id     => V_formula_id,
                                                 V_orgn_id        => V_orgn_id,
                                                 V_formulaline_id => l_parentline_id,
                                                 V_plant_id       => V_plant_id);
    END IF;
    EXCEPTION
    WHEN create_mo_line_err THEN
      FOR i IN 1 .. l_msg_count LOOP
        l_msg_data := fnd_msg_pub.get (p_msg_index      => i
                                      ,p_encoded        => 'T');
      END LOOP;
    WHEN setup_failure THEN
       x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
       fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Add_New_line');
  END add_new_line;

  /*##############################################################
  # NAME
  #	load_spread_values
  # SYNOPSIS
  #	proc   load_spread_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_spread_values (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,
  		                V_orgn_id   IN NUMBER,V_parent_line_id IN NUMBER) IS
    CURSOR Cur_get_line IS
       SELECT line_id
       FROM   gmd_material_details_gtmp
       WHERE  parent_line_id = V_parent_line_id
       ORDER BY line_type;
  BEGIN
     /* Inserting the technical parameter data  of item and lot to temp tables*/
    IF (V_sprd_id IS NOT NULL) THEN
      INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,LINE_ID,TECH_PARM_NAME,TECH_PARM_ID,
		VALUE,SORT_SEQ,NUM_DATA,TEXT_DATA,BOOLEAN_DATA)
		SELECT a.sprd_id,c.line_id,a.tech_parm_name,a.tech_parm_id,
		       DECODE(B.DATA_TYPE,0,TEXT_DATA,2,TEXT_DATA,3,BOOLEAN_DATA,NUM_DATA) VALUE,
		       b.sort_seq,a.num_data,a.text_data,a.boolean_data
		FROM   lm_sprd_tec a, gmd_technical_parameter_gtmp b, gmd_material_details_gtmp c
		WHERE  a.tech_parm_id = b.tech_parm_id
                       AND a.sprd_id    = V_entity_id
                       AND a.line_id    = c.sprd_line_id
                       AND a.organization_id = V_orgn_id
                       AND c.parent_line_id = V_parent_line_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Spread_Values');
  END load_spread_values;

  /*##############################################################
  # NAME
  #	load_batch_values
  # SYNOPSIS
  #	proc   load_batch_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_batch_values  (V_entity_id IN NUMBER,V_batch_id IN NUMBER,
  		                V_orgn_id IN NUMBER,V_matl_detl_id IN NUMBER,
  		                V_line_id IN NUMBER,V_plant_id IN NUMBER) IS
    CURSOR Cur_get_line IS
       SELECT line_id
       FROM   gmd_material_details_gtmp
       WHERE  parent_line_id = V_matl_detl_id
       ORDER BY line_type;
  BEGIN
    /* Inserting the technical parameter data  of item and lot to temp tables*/
    IF (V_batch_id IS NOT NULL) THEN
      INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,LINE_ID,TECH_PARM_NAME,TECH_PARM_ID,
		VALUE,SORT_SEQ,NUM_DATA,TEXT_DATA,BOOLEAN_DATA)
		SELECT V_entity_id,c.line_id,a.tech_parm_name, a.tech_parm_id,
		       DECODE(B.DATA_TYPE,0,TEXT_DATA,2,TEXT_DATA,3,BOOLEAN_DATA,NUM_DATA) VALUE,
		       b.sort_seq,a.num_data,a.text_data,a.boolean_data
		FROM   gmd_technical_data_vl a, gmd_technical_parameter_gtmp b, gmd_material_details_gtmp c
		WHERE  a.tech_parm_id = b.tech_parm_id
		       AND a.organization_id  = V_orgn_id
		       AND a.inventory_item_id    = c.inventory_item_id
		       AND c.parent_line_id  = V_matl_detl_id
		       AND c.entity_id  = V_entity_id
		       AND (V_line_id IS NULL OR c.line_id  = V_line_id)
		       AND (a.batch_id =  V_entity_id OR
                           (a.batch_id IS NULL AND NOT EXISTS ( SELECT 1
                                                       		FROM GMD_TECHNICAL_DATA_VL e
                                                       		WHERE e.inventory_item_id = c.inventory_item_id
                                                       		AND   nvl(e.lot_number, '-1') = nvl(c.lot_number, '-1')
                                                       		AND   nvl(e.lot_organization_id, c.organization_id) = c.organization_id
                                                       		AND   e.formula_id IS NULL
                                                       		AND   e.batch_id = V_entity_id
                                                       		AND   e.organization_id = V_orgn_id)))
		       AND a.formula_id IS NULL
		       AND a.delete_mark = 0
                       AND NVL(c.organization_id, -1) = NVL(a.lot_organization_id, c.organization_id)
		       AND NVL(c.lot_number, '-1') = NVL(a.lot_number, '-1');

      gmd_spread_fetch_pkg.get_lot_density (P_orgn_id        => V_orgn_id,
	                                    P_parent_detl_id => V_matl_detl_id,
                                            P_entity_id      => V_entity_id);


    END IF;
    FOR l_quality_rec IN Cur_get_line LOOP
      load_derived_cost (V_entity_id,V_orgn_id,l_quality_rec.line_id);
      load_quality_data (l_quality_rec.line_id,V_orgn_id,V_plant_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Batch_Values');
  END load_batch_values;

  /*##############################################################
  # NAME
  #	load_formula_values
  # SYNOPSIS
  #	proc   load_formula_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_formula_values (V_entity_id IN NUMBER,V_formula_id IN NUMBER,
  		                 V_orgn_id IN NUMBER,V_formulaline_id IN NUMBER,
  		                 V_line_id IN NUMBER,V_plant_id IN NUMBER) IS
    CURSOR Cur_get_line IS
       SELECT line_id
       FROM   gmd_material_details_gtmp
       WHERE  (V_formulaline_id IS NULL OR parent_line_id = V_formulaline_id)
       ORDER BY line_type;
  BEGIN
      /* Inserting the technical parameter data  of item and lot to temp tables*/
      IF (V_formula_id IS NOT NULL) THEN
        INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,LINE_ID,TECH_PARM_NAME,TECH_PARM_ID,
		VALUE,SORT_SEQ,NUM_DATA,TEXT_DATA,BOOLEAN_DATA)
		SELECT V_entity_id,c.line_id,a.tech_parm_name,a.tech_parm_id,
		       DECODE(B.DATA_TYPE,0,TEXT_DATA,2,TEXT_DATA,3,BOOLEAN_DATA,NUM_DATA) VALUE,
		       b.sort_seq,a.num_data,a.text_data,a.boolean_data
		FROM   gmd_technical_data_vl a, gmd_technical_parameter_gtmp b, gmd_material_details_gtmp c
		WHERE  a.tech_parm_id = b.tech_parm_id
		       AND a.organization_id = V_orgn_id
		       AND a.inventory_item_id = c.inventory_item_id
		       AND (V_formulaline_id IS NULL OR c.parent_line_id  = V_formulaline_id)
		       AND c.entity_id = V_entity_id
		       AND (V_line_id IS NULL OR c.line_id  = V_line_id)
		       AND (a.formula_id = c.tpformula_id OR
		           (a.formula_id IS NULL AND NOT EXISTS (SELECT 1
                                                       		FROM GMD_TECHNICAL_DATA_VL e
                                                       		WHERE e.inventory_item_id = c.inventory_item_id
                     		                                AND   NVL(e.lot_number, '-1') = NVL(c.lot_number, '-1')
                                                       		AND   NVL(e.lot_organization_id, c.organization_id) = c.organization_id
                                                       		AND   e.batch_id IS NULL
                                                       		AND   e.formula_id = c.tpformula_id
                                                       		AND   e.organization_id = V_orgn_id)))
		       AND a.batch_id IS NULL
                       AND NVL(c.organization_id, -1) = NVL(a.lot_organization_id, c.organization_id)
		       AND NVL(c.lot_number, '-1') = NVL(a.lot_number, '-1');

      gmd_spread_fetch_pkg.get_lot_density (P_orgn_id        => V_orgn_id,
	                                    P_parent_detl_id => V_formulaline_id,
                                            P_entity_id      => V_entity_id);

    END IF;

    FOR l_quality_rec IN Cur_get_line LOOP
      load_derived_cost (V_entity_id,V_orgn_id,l_quality_rec.line_id);
      load_quality_data (l_quality_rec.line_id,V_orgn_id,V_plant_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Formula_Values');
  END load_formula_values;

  /*##############################################################
  # NAME
  #	save_spreadsheet
  # SYNOPSIS
  #	proc   save_spreadsheet
  # DESCRIPTION
  #      This procedure inserts the data into spreadsheet tables.
  ###############################################################*/

  PROCEDURE save_spreadsheet (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,
  			      V_formula_id IN NUMBER,V_batch_id IN NUMBER,
  			      V_orgn_id IN NUMBER,V_spread_name IN VARCHAR2,
  			      V_maintain_type IN NUMBER,V_text_code IN NUMBER,
  			      V_last_update_date IN DATE,V_move_order_header_id IN NUMBER) IS
    CURSOR Cur_sprd_id IS
      SELECT gem5_sprd_id_s.nextval
      FROM   fnd_dual;

    CURSOR Cur_line_id IS
      SELECT gem5_sprd_line_id_s.nextval
      FROM   fnd_dual;

    CURSOR Cur_sprd_insert IS
      SELECT  line_id,V_orgn_id,move_order_line_id,line_type,formulaline_id,
              material_detail_id,line_no,rollup_ind,inventory_item_id,qty,detail_uom,
              text_code,subinventory_code,location,locator_id,lot_number,expiration_date,grade_code,
	      transaction_id,reservation_id,secondary_qty,secondary_uom,buffer_ind,revision,
	      revision_qty_control_code,plant_organization_id,organization_id,
	      last_updated_by,last_update_date,created_by,creation_date,prod_percent
      FROM    gmd_material_details_gtmp
      WHERE   entity_id = V_entity_id;
    X_sprd_id	NUMBER(10);
    X_line_id	NUMBER(10);
    l_user_id   NUMBER;
    l_text_code NUMBER;
    type text_table is table of NUMBER(10) index by binary_integer;
    x_text_tab  text_table;
    x_cnt       NUMBER default 0;
  BEGIN
   /* saving the data to spreadsheet tables from temp tables*/
    l_user_id := TO_NUMBER (fnd_profile.VALUE ('USER_ID'));
    IF (V_sprd_id IS NOT NULL) THEN
      X_sprd_id := V_sprd_id;
      UPDATE lm_sprd_fls
      SET    lab_organization_id  = V_orgn_id,
             formula_id           = V_formula_id,
             batch_id             = V_batch_id,
             move_order_header_id = V_move_order_header_id,
             maintain_type        = V_maintain_type,
             last_update_date     = V_last_update_date,
             last_updated_by      = l_user_id,
             text_code            = V_text_code
      WHERE  sprd_name = V_spread_name;
      DELETE FROM lm_sprd_dtl
      WHERE       sprd_id = V_sprd_id;
      DELETE FROM lm_sprd_tec
      WHERE       sprd_id = V_sprd_id;
      DELETE FROM lm_sprd_prm
      WHERE       sprd_id = V_sprd_id;
    ELSE
      OPEN Cur_sprd_id;
      FETCH Cur_sprd_id INTO X_sprd_id;
      CLOSE Cur_sprd_id;
      INSERT INTO lm_sprd_fls (sprd_id, sprd_name, formula_id,batch_id, lab_organization_id, maintain_type,
                               active_ind, delete_mark, creation_date,
			       last_update_date, created_by,
			       last_updated_by, text_code, in_use,move_order_header_id)
      VALUES                  (X_sprd_id, V_spread_name,
			       V_formula_id,V_batch_id,
			       V_orgn_id,V_maintain_type,1,0,V_last_update_date,
			       V_last_update_date,l_user_id,
			       l_user_id, V_text_code, 0, V_move_order_header_id);
    END IF;

    INSERT INTO lm_sprd_prm (sprd_id,organization_id,tech_parm_name,tech_parm_id,sort_seq,data_type,
 			     expression_char,min_value,max_value,precision,optimize_type,
 			     last_updated_by,last_update_date,created_by,creation_date)
      			     SELECT X_sprd_id, V_orgn_id,tech_parm_name,tech_parm_id,sort_seq,data_type,
				    expression_char,lowerbound_num,upperbound_num,signif_figures,optimize_type,
        		     	    l_user_id,sysdate,l_user_id,sysdate
			     FROM   gmd_technical_parameter_gtmp
			     WHERE  entity_id = V_entity_id;

    FOR l_rec IN Cur_sprd_insert LOOP
      OPEN Cur_line_id;
      FETCH Cur_line_id INTO X_line_id;
      CLOSE Cur_line_id;
      INSERT INTO lm_sprd_dtl (line_id,sprd_id,move_order_line_id,line_type,formulaline_id,material_detail_id,line_no,
                               rollup_ind,inventory_item_id,qty,detail_uom,revision,revision_qty_control_code,text_code,subinventory_code,
                               location,lot_number,expiration_date,grade_code,transaction_id,reservation_id,secondary_qty,secondary_uom,
                               buffer_ind, plant_organization_id,organization_id,last_updated_by,last_update_date,
                               created_by,creation_date,locator_id,prod_percent)
      VALUES
				(X_line_id,x_sprd_id,l_rec.move_order_line_id,l_rec.line_type,l_rec.formulaline_id,
				 l_rec.material_detail_id,l_rec.line_no,l_rec.rollup_ind,l_rec.inventory_item_id,
				 l_rec.qty,l_rec.detail_uom,l_rec.revision,l_rec.revision_qty_control_code,l_rec.text_code,
				 l_rec.subinventory_code,l_rec.location,l_rec.lot_number,l_rec.expiration_date,
				 l_rec.grade_code,l_rec.transaction_id,l_rec.reservation_id,l_rec.secondary_qty,
				 l_rec.secondary_uom,l_rec.buffer_ind,l_rec.plant_organization_id,
				 l_rec.organization_id,l_rec.last_updated_by,l_rec.last_update_date,
				 l_rec.created_by,l_rec.creation_date,l_rec.locator_id,l_rec.prod_percent);

      INSERT INTO lm_sprd_tec (line_id,organization_id,tech_parm_name,tech_parm_id,sprd_id,sort_seq,num_data,text_data,
			       boolean_data,last_updated_by,last_update_date,created_by,creation_date)
            	               SELECT X_line_id, V_orgn_id, tech_parm_name,tech_parm_id,
				      X_sprd_id,sort_seq,num_data,text_data,boolean_data,
        		     	      l_user_id,sysdate,l_user_id,sysdate
			       FROM   gmd_technical_data_gtmp
			       WHERE  entity_id  = V_entity_id
				      AND line_id = l_rec.line_id;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Save_Spreadsheet');
  END save_spreadsheet;

  /*##############################################################
  # NAME
  #	get_density_value
  # SYNOPSIS
  #	proc   get_density_value
  # DESCRIPTION
  #      This procedure gets the density value for uom conversion.
  ###############################################################*/

  FUNCTION get_density_value (V_line_id 		IN	NUMBER,
                              V_density_parameter 	IN	VARCHAR2) RETURN NUMBER IS
    CURSOR Cur_density IS
      SELECT value
      FROM   gmd_technical_data_gtmp
      WHERE  line_id = V_line_id
      AND    tech_parm_name = V_density_parameter;
    l_value	NUMBER;
  BEGIN
    OPEN Cur_density;
    FETCH Cur_density INTO l_value;
    CLOSE Cur_density;
    RETURN (l_value);
  END get_density_value;

  /*##############################################################
  # NAME
  #	update_line_mass_vol_qty
  # SYNOPSIS
  #	proc   update_line_mass_vol_qty
  # DESCRIPTION
  #      This procedure calculates the qtys to mass and volume.
  ###############################################################*/

  PROCEDURE update_line_mass_vol_qty (V_orgn_id			IN	NUMBER,
                                      V_line_id			IN	NUMBER,
                                      V_density_parameter	IN	VARCHAR2,
                                      V_mass_uom		IN	VARCHAR2,
                                      V_vol_uom			IN	VARCHAR2,
                                      X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_line_qty IS
      SELECT inventory_item_id, lot_number, qty,
             detail_uom,primary_uom,secondary_uom
      FROM   gmd_material_details_gtmp
      WHERE  line_id = V_line_id;

    CURSOR Cur_line_item_number (V_inventory_item_id NUMBER)IS
      SELECT concatenated_segments
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = V_inventory_item_id;

    l_conv_factor	NUMBER;
    l_mass_qty		NUMBER;
    l_primary_qty	NUMBER;
    l_vol_qty		NUMBER;
    l_item_no		VARCHAR2(1000);
    l_error		NUMBER(5) := 0;
    l_rec		Cur_line_qty%ROWTYPE;
    LINE_NOT_FOUND	EXCEPTION;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    l_conv_factor := get_density_value (V_line_id => V_line_id,
                                        V_density_parameter => V_density_parameter);
    OPEN Cur_line_qty;
    FETCH Cur_line_qty  INTO l_rec;
    IF Cur_line_qty%NOTFOUND THEN
      CLOSE Cur_line_qty;
      RAISE LINE_NOT_FOUND;
    END IF;
    CLOSE Cur_line_qty;

    IF l_rec.detail_uom <> V_mass_uom THEN
      l_mass_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id 	 => l_rec.inventory_item_id,
                                              		     pformula_id => 0,
                                              		     plot_number => l_rec.lot_number,
                                                             pcur_qty	 => l_rec.qty,
                                                             pcur_uom	 => l_rec.detail_uom,
                                                             pnew_uom	 => V_mass_uom,
                                                             patomic	 => 0,
                                                             plab_id	 => V_orgn_id,
                                                             pcnv_factor => l_conv_factor);
      IF l_mass_qty < 0 THEN
        l_error := 1;
        l_mass_qty := NULL;
      END IF;
    ELSE
      l_mass_qty := l_rec.qty;
    END IF;

    IF l_rec.detail_uom <> V_vol_uom THEN
      l_vol_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id 	=> l_rec.inventory_item_id,
                                                            pformula_id	=> 0,
                                              		    plot_number => l_rec.lot_number,
                                                            pcur_qty	=> l_rec.qty,
                                                            pcur_uom	=> l_rec.detail_uom,
                                                            pnew_uom	=> V_vol_uom,
                                                            patomic	=> 0,
                                                            plab_id	=> V_orgn_id,
                                                            pcnv_factor	=> l_conv_factor);
      IF l_vol_qty < 0 THEN
        l_error := 1;
        l_vol_qty := NULL;
      END IF;
    ELSE
      l_vol_qty := l_rec.qty;
    END IF;

    IF l_rec.detail_uom <> l_rec.primary_uom THEN
      l_primary_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_rec.inventory_item_id,
                                                                pformula_id => 0,
                                              		        plot_number => l_rec.lot_number,
                                                                pcur_qty    => l_rec.qty,
                                                                pcur_uom    => l_rec.detail_uom,
                                                                pnew_uom    => l_rec.primary_uom,
                                                                patomic	    => 0,
                                                                plab_id	    => V_orgn_id);
      IF l_primary_qty < 0 THEN
        l_error := 1;
        l_primary_qty := NULL;
      END IF;
    ELSE
      l_primary_qty := l_rec.qty;
    END IF;

    UPDATE gmd_material_details_gtmp
    SET qty_mass    = l_mass_qty,
        mass_uom    = V_mass_uom,
        qty_vol     = l_vol_qty,
        vol_uom     = V_vol_uom,
        primary_qty = l_primary_qty,
        primary_uom  = l_rec.primary_uom
    WHERE line_id = V_line_id;

    OPEN Cur_line_item_number(l_rec.inventory_item_id);
    FETCH Cur_line_item_number INTO l_item_no;
    CLOSE Cur_line_item_number;

    IF l_error = 1 THEN
      X_return_status := FND_API.g_ret_sts_error;
      gmd_api_grp.log_message('LM_BAD_UOMCV', 'ITEM_NO',l_item_no, 'DENSITY',V_density_parameter);
    END IF;

  EXCEPTION
    WHEN line_not_found THEN
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Update_Line_Mass_Vol_Qty');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_line_mass_vol_qty;

  /*##############################################################
  # NAME
  #	update_line_mass_qty
  # SYNOPSIS
  #	proc   update_line_mass_qty
  # DESCRIPTION
  #      This procedure calculates the qtys to mass and volume.
  ###############################################################*/

  PROCEDURE update_mass_vol_qty (V_orgn_id		IN	NUMBER,
                                 V_entity_id		IN	NUMBER,
                                 V_density_parameter	IN	VARCHAR2,
                                 V_mass_uom		IN	VARCHAR2,
                                 V_vol_uom		IN	VARCHAR2,
                                 X_return_status	OUT NOCOPY	VARCHAR2) IS
    CURSOR Cur_get_lines IS
      SELECT line_id
      FROM   gmd_material_details_gtmp
      WHERE  rollup_ind = 1
      AND    line_type <> 1
      AND    entity_id = V_entity_id;

    l_return_status	VARCHAR2(1);
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    FOR l_rec IN Cur_get_lines LOOP
      l_return_status := FND_API.g_ret_sts_success;
      update_line_mass_vol_qty (V_orgn_id	    => V_orgn_id,
                                V_line_id	    => l_rec.line_id,
                                V_density_parameter => V_density_parameter,
                                V_mass_uom	    => V_mass_uom,
                                V_vol_uom	    => V_vol_uom,
                                X_return_status	    => l_return_status);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
        X_return_status := l_return_status;
      END IF;
    END LOOP;
  END update_mass_vol_qty;

  /*##############################################################
  # NAME
  #	load_quality_data
  # SYNOPSIS
  #	proc   load_quality_data
  # DESCRIPTION
  #      This procedure inserts the data into temp tables from quality
  #      tables.
  ###############################################################*/

  PROCEDURE load_quality_data (V_line_id IN NUMBER, V_orgn_id IN NUMBER,V_plant_id IN NUMBER) IS

    CURSOR Cur_get_qmdata IS
      SELECT *
      FROM   gmd_technical_parameter_gtmp
      WHERE  qcassy_typ_id IS NOT NULL;

    CURSOR Cur_get_data IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_id = V_line_id;

    l_rec Cur_get_data%ROWTYPE;
    l_return_status VARCHAR2(1);
    l_value         VARCHAR2(80);
    l_inv_inp_rec_type GMD_QUALITY_GRP.inv_inp_rec_type;
    l_inv_val_out_rec_type GMD_QUALITY_GRP.inv_val_out_rec_type;

    CURSOR Cur_get_value(Pline_id NUMBER,Pparm_id NUMBER) IS
      SELECT value
      FROM   gmd_technical_data_gtmp
      WHERE  line_id = Pline_id
      AND    tech_parm_id = Pparm_id;

    l_temp       VARCHAR2(80);
    l_num_value  NUMBER;
    l_char_value VARCHAR2(240);
    X_return_status VARCHAR2(20);
  BEGIN
    OPEN Cur_get_data;
    FETCH Cur_get_data INTO l_rec;
    CLOSE Cur_get_data;
    l_inv_inp_rec_type.organization_id   := V_orgn_id;
    l_inv_inp_rec_type.inventory_item_id := l_rec.inventory_item_id;
    l_inv_inp_rec_type.grade_code        := l_rec.grade_code;
    l_inv_inp_rec_type.lot_number        := l_rec.lot_number;
    l_inv_inp_rec_type.subinventory      := l_rec.subinventory_code;
    l_inv_inp_rec_type.locator_id        := l_rec.locator_id;
    l_inv_inp_rec_type.plant_id          := V_plant_id;
    FOR l_qmrec IN Cur_get_qmdata LOOP
      l_inv_inp_rec_type.test_id := l_qmrec.qcassy_typ_id;
      gmd_quality_grp.get_inv_test_value (P_inv_test_inp_rec => l_inv_inp_rec_type,
  		            		  x_inv_test_out_rec => l_inv_val_out_rec_type,
  					  x_return_status    => l_return_status);
      l_value := l_inv_val_out_rec_type.entity_value;
      IF (l_rec.line_type = 3) THEN
        IF (l_inv_val_out_rec_type.level BETWEEN 11 AND 20) OR (l_inv_val_out_rec_type.level > 40) THEN
          OPEN Cur_get_value(V_line_id,l_qmrec.tech_parm_id);
          FETCH Cur_get_value INTO l_temp;
          IF (Cur_get_value%FOUND) THEN
            l_value := NULL;
          END IF;
          CLOSE Cur_get_value;
        END IF;
      END IF;
      IF (l_value IS NOT NULL) THEN
        IF l_qmrec.data_type = 1 THEN
          l_num_value := l_value;
          l_char_value := NULL;
        ELSE
          l_char_value := l_value;
          l_num_value := NULL;
        END IF;
        UPDATE gmd_technical_data_gtmp
        SET    value = l_inv_val_out_rec_type.entity_value,
               num_data = l_num_value,
               qm_entity_id = l_inv_val_out_rec_type.entity_id,
               qm_level = l_inv_val_out_rec_type.level,
               text_data = l_char_value
        WHERE  line_id = V_line_id
        AND    tech_parm_id = l_qmrec.tech_parm_id;
        IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
             (ENTITY_ID,LINE_ID,TECH_PARM_NAME,TECH_PARM_ID,VALUE,SORT_SEQ,NUM_DATA,
              TEXT_DATA,QM_ENTITY_ID,QM_LEVEL,COMP_IND,MIN_VALUE,MAX_VALUE,SPEC_ID)
          VALUES (l_rec.entity_id,V_line_id,l_qmrec.tech_parm_name,l_qmrec.tech_parm_id,l_inv_val_out_rec_type.entity_value,
                  l_qmrec.sort_seq,l_num_value,l_char_value,
                  l_inv_val_out_rec_type.entity_id,l_inv_val_out_rec_type.level,l_inv_val_out_rec_type.composite_ind,
                  l_inv_val_out_rec_type.entity_min_value,l_inv_val_out_rec_type.entity_max_value,l_inv_val_out_rec_type.spec_id);
        END IF;
      ELSE
        UPDATE  gmd_technical_data_gtmp
        SET     value = l_inv_val_out_rec_type.entity_value,
                num_data = l_num_value,
                qm_entity_id = l_inv_val_out_rec_type.entity_id,
                qm_level = l_inv_val_out_rec_type.level,
                text_data = l_char_value
        WHERE   line_id = V_line_id
        AND     tech_parm_id = l_qmrec.tech_parm_id;
      END IF;
    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'load_quality_data');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      NULL;
  END load_quality_data;

  /**#############################################################
  # NAME
  #	get_lot_density
  # SYNOPSIS
  #	proc   get_lot_density
  # DESCRIPTION
  #
  # HISTORY
  #     Sriram.S 30Aug04 Created
  #              CAF Enhancement
  ##############################################################**/

  PROCEDURE get_lot_density (P_orgn_id        NUMBER,
                             P_parent_detl_id NUMBER,
               	             P_entity_id      NUMBER) IS

     CURSOR cur_get_param (v_density VARCHAR2) IS
       SELECT tech_parm_id
       FROM gmd_tech_parameters_b
       WHERE tech_parm_name = v_density
       AND organization_id = P_orgn_id;

     CURSOR cur_get_value (v_tech_parm_id NUMBER) IS
       SELECT a.value
       FROM gmd_technical_data_gtmp a, gmd_material_details_gtmp c
       WHERE a.tech_parm_id = v_tech_parm_id
       AND c.parent_line_id = P_parent_detl_id
       AND a.line_id = c.line_id
       AND c.line_type <> 3;

     CURSOR cur_get_data (v_tech_parm_id NUMBER) IS
       SELECT line_id
       FROM gmd_material_details_gtmp p
       WHERE parent_line_id = P_parent_detl_id
       AND line_type = 3
       AND NOT EXISTS ( SELECT 1
                        FROM gmd_technical_data_gtmp g
                        WHERE p.line_id = g.line_id
                        AND g.tech_parm_id = v_tech_parm_id);

     /* Local variables */
     l_density        VARCHAR2 (240);
     l_value          NUMBER;
     l_tech_parm_id   NUMBER;

  BEGIN
     l_density := fnd_profile.VALUE ('LM$DENSITY');

     OPEN cur_get_param (l_density);
     FETCH cur_get_param INTO l_tech_parm_id;
     CLOSE cur_get_param;

     OPEN cur_get_value (l_tech_parm_id);
     FETCH cur_get_value INTO l_value;
     CLOSE cur_get_value;

     IF (l_value IS NOT NULL) THEN
        FOR l_rec IN cur_get_data (l_tech_parm_id) LOOP
           INSERT INTO gmd_technical_data_gtmp
                       (entity_id, line_id, tech_parm_name, tech_parm_id,
                        Value, sort_seq, num_data, TEXT_DATA, BOOLEAN_DATA)
           VALUES
                       (P_entity_id, l_rec.line_id, l_density, l_tech_parm_id,
                        l_value, 1, l_value, NULL, NULL);
        END LOOP;
     END IF;
  END get_lot_density;

  /*##############################################################
  # NAME
  #	load_lcf_details
  # SYNOPSIS
  #	proc   load_lcf_details
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_lcf_details  (V_entity_id		IN NUMBER,
  			       V_orgn_id   		IN NUMBER,
  			       V_plant_id 		IN NUMBER) IS
    CURSOR Cur_get_lcf IS
      SELECT a.*,b.description descrip, b.default_grade,
             b.primary_uom_code primary,b.secondary_uom_code secondary,
             b.lot_control_code,b.secondary_default_ind,
             b.grade_control_flag,b.tracking_quantity_ind,b.location_control_code
      FROM   gmd_lcf_details_gtmp a, mtl_system_items_b b
      WHERE  a.inventory_item_id = b.inventory_item_id
      AND    b.organization_id = V_orgn_id
      ORDER BY a.line_type, a.line_no;
    l_formula_rec     	 Cur_get_lcf%ROWTYPE;
    l_secondary_qty	 NUMBER;
    CURSOR Cur_get_lines IS
      SELECT formulaline_id
      FROM   gmd_material_details_gtmp
      WHERE  entity_id = V_entity_id;
  BEGIN
     /* Inserting the item and lot data from formula detail tables to temp tables*/
    IF (V_orgn_id IS NOT NULL) THEN
      OPEN Cur_get_lcf;
      LOOP
      FETCH Cur_get_lcf INTO l_formula_rec;
      EXIT WHEN Cur_get_lcf%NOTFOUND;
      /* Getting the secondary qty*/
      l_secondary_qty := null;
      IF (l_formula_rec.qty > 0 AND l_formula_rec.tracking_quantity_ind = 'PS') THEN
        l_secondary_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_formula_rec.inventory_item_id,
                                                                    pformula_id => NULL,
                                                                    plot_number => NULL,
                                                                    pcur_qty    => l_formula_rec.qty,
                                                                    pcur_uom    => l_formula_rec.detail_uom,
                                                                    pnew_uom    => l_formula_rec.secondary,
                                                                    patomic	=> 0,
                                                                    plab_id	=> V_orgn_id);
        IF (l_secondary_qty < 0) THEN
          l_secondary_qty := NULL;
        END IF;
      END IF;

      INSERT INTO GMD_MATERIAL_DETAILS_GTMP
        (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,EXPAND_IND,TRACKING_QUANTITY_IND,
         LOCATION_CONTROL_CODE,INVENTORY_ITEM_ID,DESCRIPTION,
         QTY,SECONDARY_QTY,DETAIL_UOM,GRADE_CODE,PRIMARY_UOM,SECONDARY_UOM,LOT_CONTROL_CODE,
         GRADE_CONTROL_FLAG,FORMULALINE_ID,PARENT_LINE_ID,
         CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         ORGANIZATION_ID,SECONDARY_DEFAULT_IND)
      VALUES
        (V_entity_id,l_formula_rec.line_id,l_formula_rec.line_type,l_formula_rec.line_no,1,1,
         l_formula_rec.tracking_quantity_ind,l_formula_rec.location_control_code,
	 l_formula_rec.inventory_item_id,l_formula_rec.descrip,
	 l_formula_rec.qty,l_secondary_qty,l_formula_rec.detail_uom,
	 l_formula_rec.default_grade,l_formula_rec.primary,l_formula_rec.secondary,
         l_formula_rec.lot_control_code,l_formula_rec.grade_control_flag,
         l_formula_rec.formulaline_id,l_formula_rec.line_id,l_formula_rec.created_by,
         l_formula_rec.creation_date,l_formula_rec.last_updated_by,
         l_formula_rec.last_update_date,V_orgn_id,l_formula_rec.secondary_default_ind);

/* Changed  l_formula_rec.line_id to  l_formula_rec.formulaline_id in the Bug No.8439868 */

      END LOOP;
      CLOSE Cur_get_lcf;

      FOR l_form_rec IN Cur_get_lines LOOP
        gmd_spread_fetch_pkg.load_lcf_values(V_entity_id      => V_entity_id,
                                             V_orgn_id        => V_orgn_id,
                                             V_formulaline_id => l_form_rec.formulaline_id,
                                             V_plant_id       => V_plant_id);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Lcf_Details');
  END load_lcf_details;

  /*##############################################################
  # NAME
  #	load_lcf_values
  # SYNOPSIS
  #	proc   load_lcf_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_lcf_values (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,
                             V_formulaline_id IN NUMBER,V_plant_id IN NUMBER,
                             V_line_id IN NUMBER) IS
    CURSOR Cur_get_line IS
       SELECT line_id
       FROM   gmd_material_details_gtmp
       WHERE  (V_formulaline_id IS NULL OR parent_line_id = V_formulaline_id)
       ORDER BY line_type;
  BEGIN
    /* Inserting the technical parameter data  of item and lot to temp tables*/
    IF (V_entity_id IS NOT NULL) THEN
      INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,LINE_ID,TECH_PARM_NAME,TECH_PARM_ID,
		VALUE,SORT_SEQ,NUM_DATA,TEXT_DATA,BOOLEAN_DATA)
		SELECT V_entity_id,c.line_id,b.tech_parm_name,a.tech_parm_id,
		       DECODE(B.DATA_TYPE,0,TEXT_DATA,2,TEXT_DATA,3,BOOLEAN_DATA,NUM_DATA) VALUE,
		       b.sort_seq,a.num_data,a.text_data,a.boolean_data
		FROM   gmd_technical_data_vl a, gmd_technical_parameter_gtmp b, gmd_material_details_gtmp c
		WHERE  a.tech_parm_id = b.tech_parm_id
		       AND a.organization_id = V_orgn_id
		       AND a.inventory_item_id = c.inventory_item_id
		       AND (V_formulaline_id IS NULL OR c.parent_line_id  = V_formulaline_id)
		       AND c.entity_id = V_entity_id
		       AND (V_line_id IS NULL OR c.line_id  = V_line_id)
                       AND NVL(c.organization_id, -1) = NVL(a.lot_organization_id, c.organization_id)
		       AND NVL(c.lot_number, '-1') = NVL(a.lot_number, '-1');
    END IF;
    FOR l_quality_rec IN Cur_get_line LOOP
      load_derived_cost (V_entity_id,V_orgn_id,l_quality_rec.line_id);
      load_quality_data (l_quality_rec.line_id,V_orgn_id,V_plant_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_FETCH_PKG', 'Load_Lcf_Values');
  END load_lcf_values;

  /*##############################################################
  # NAME
  #	load_derived_cost
  # SYNOPSIS
  #	proc   load_derived_cost
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_derived_cost (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,V_line_id IN NUMBER) IS
    CURSOR Cur_get_type IS
      SELECT a.*, c.line_id line, b.tech_parm_id tech, b.tech_parm_name name,b.sort_seq, c.inventory_item_id
      FROM   gmd_tech_parameters_b a, gmd_technical_parameter_gtmp b, gmd_material_details_gtmp c
      WHERE  a.tech_parm_id = b.tech_parm_id
      AND    c.line_id = V_line_id;
    l_value	NUMBER;
    l_parm_value	VARCHAR2(240);
    l_return_status	VARCHAR2(1);
  BEGIN
    gmd_api_grp.fetch_parm_values (P_orgn_id       => V_orgn_id
                                  ,P_parm_name     => 'GMD_COST_SOURCE_ORGN'
                                  ,P_parm_value    => l_parm_value
                                  ,X_return_status => l_return_status);
    FOR l_rec IN Cur_get_type LOOP
      IF l_rec.data_type = 12 THEN
        gmd_lcf_fetch_pkg.load_cost_values (V_orgn_id     => V_orgn_id,
                          		    V_inv_item_id => l_rec.inventory_item_id,
                          		    V_cost_type   => l_rec.cost_type,
                           		    V_date        => SYSDATE,
                           		    V_cost_orgn   => l_parm_value,
                          		    V_source      => l_rec.cost_source,
                          		    X_value       => l_value);
        INSERT INTO GMD_TECHNICAL_DATA_GTMP (ENTITY_ID,LINE_ID,TECH_PARM_NAME,
                                             TECH_PARM_ID,VALUE,NUM_DATA,SORT_SEQ)
        VALUES (V_entity_id,l_rec.line,l_rec.name,l_rec.tech,l_value,l_value,l_rec.sort_seq);
      END IF;
    END LOOP;
  END load_derived_cost;


END GMD_SPREAD_FETCH_PKG;


/
